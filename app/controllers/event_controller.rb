class EventController < ApplicationController

  def index
    booking = Event.where(id: params[:custom])
    redirect_to booking.first and return if booking&.first&.present?

    @references = build_reference_list_ui

    @ui_data = {
    }
  end

  def fetch_timetable
    service_id = params[:service_id]
    agent_id = params[:agent_id] # Skills assessment always agent id 3
    day = params[:date].to_date
    last_temp_event = _last_temp_event(params[:clientEmail])
    office_location = Location.find_by_name(params[:officeLocation])
    # debugger

    agent_timetable = Timetable.build_available_slots(day, agent_id, service_id, last_temp_event, office_location)

    render json: { timetable: agent_timetable }
  end

  def fetch_blocked_days
    service_id = params[:service_id]
    agent_id = params[:agent_id] # Skills assessment always agent id 3
    start_of_month = params[:date].to_date
    end_of_month =  params[:date].to_date + 2.months
    last_temp_event = _last_temp_event(params[:clientEmail])
    off_shore = params[:location] == '3' #offshore
    office_location = Location.find_by_name(params[:officeLocation])

    # debugger
    list_blocked_days = (start_of_month..end_of_month).to_a.map do |day|
      timetable = Timetable.build_available_slots(day, agent_id, service_id, last_temp_event, office_location)
      day.strftime('%d/%m/%Y') if timetable.empty? || (off_shore && _block_off_shore?(day))
    end.compact

    list_blocked_days << start_of_month.strftime('%d/%m/%Y')
    list_blocked_days << (start_of_month + 1.day).strftime('%d/%m/%Y')

    render json: { blocked_days: list_blocked_days}
  end

  def register_booking
    client = create_or_find_client
    @new_booking_rule = _new_booking_rule?(client)
    @bookings_count = client.events.where(temporary: false).count

    if @new_booking_rule
      @event = _new_booking(client)
    else # Remove when old rule (free returns) is not valid anymore.
      event_service_id = params[:eventServiceRadio]
      agent_id = event_service_id == '1' ? 3 : params[:agentRadio] # Skills assessment always agent id 3
      office_location = Location.find_by_name(params[:officeLocationRadio])
      language = params[:languageRadio]
      start_booking = "#{params[:selectedDate]} #{params[:availableTimeRadio]}".in_time_zone(office_location.timezone)
      event_type_id = params[:eventTypeRadio]
      # Calculete correct fee
      fee = ['1', '2'].include?(client.location) ? :onshore : :offshore
      num_bookings = Event.where(client_id: client.id, temporary: false).count
      fee = :returning if num_bookings >= num_free_bookings(client.id)
      fee = :premium if client.premium?

      # Booking details
      temporary_booking = num_bookings.zero? || fee == :returning
      temporary_booking = false if fee.in?([:premium, :returning])
      duration = 30.minutes

      appointment_id = case fee
                       when :offshore
                         1
                       when :onshore
                         2
                       else
                         3
                       end

      last_temp_event = client.events.where(temporary: true).order(:id).last
      @event = if last_temp_event.present?
                 last_temp_event.update(agent_id: agent_id, event_type_id: event_type_id, event_service_id: event_service_id,
                                        start: start_booking, end: start_booking + duration, temporary: temporary_booking,
                                        by_admin: false, appointment_id: appointment_id, location_id: office_location.id,
                                        language: language, offshore: _is_request_offshore?())
                 last_temp_event
               else
                 Event.create(agent_id: agent_id, event_type_id: event_type_id, client_id: client.id, event_service_id: event_service_id,
                              start: start_booking, end: start_booking + duration, temporary: temporary_booking, by_admin: false,
                              appointment_id: appointment_id, location_id: office_location.id, language: language, offshore: _is_request_offshore?())
               end
    end

    if @event
      # sucess
      _send_confirmation_email(@event) unless @event.temporary
    else
      # fail
    end

  end

  def show
    @booking = Event.find(params[:id])
  end

  def send_confirmation_email
    booking = Event.find(params[:id])
    EventMailer.with(event: booking).confirmation_email.deliver_now
  end

  private

  def _new_booking_rule?(client)
    bookings = client.events.where(temporary: false).order(:id)

    return true unless bookings.present?
    return true if bookings.first.created_at > '24/03/2019'.to_date # No bookings, new rules

    # Has bookings but no returns pending, new rules
    !(bookings.first.appointment.returns > bookings.count)
  end

  def _new_booking(client)
    event_service_id = params[:eventServiceRadio]
    agent_id = event_service_id == '1' ? 3 : params[:agentRadio] # Skills assessment always agent id 3
    office_location = Location.find_by_name(params[:officeLocationRadio])
    language = params[:languageRadio]
    start_booking = "#{params[:selectedDate]} #{params[:availableTimeRadio]}".in_time_zone(office_location.timezone)
    event_type_id = params[:eventTypeRadio]
    temporary_booking = !client.premium?
    duration = 60.minutes
    appointment_id =  ['1', '2'].include?(client.location) ? 2 : 1

    last_temp_event = client.events.where(temporary: true).order(:id).last

    if last_temp_event.present?
      last_temp_event.update(agent_id: agent_id, event_type_id: event_type_id, event_service_id: event_service_id,
                             start: start_booking, end: start_booking + duration, temporary: temporary_booking,
                             by_admin: false, appointment_id: appointment_id, location_id: office_location.id,
                             language: language, offshore: _is_request_offshore?())
      last_temp_event
    else
      Event.create(agent_id: agent_id, event_type_id: event_type_id, client_id: client.id, event_service_id: event_service_id,
                   start: start_booking, end: start_booking + duration, temporary: temporary_booking, by_admin: false,
                   appointment_id: appointment_id, location_id: office_location.id, language: language, offshore: _is_request_offshore?())
    end
  end

  def _send_confirmation_email(event)
    EventMailer.with(event: event).confirmation_email.deliver_now
  end

  def build_reference_list_ui
    other = ClientReference.where(desc: 'Other', active: true).first
    (ClientReference.where(active: true) - [other]) << other
  end

  def create_or_find_client
    # CLient details
    email = params[:clientEmail]
    name = params[:clientName]
    phone = params[:clientPhone]
    reference = params[:referenceSelector]
    videocall_details = "#{params[:videocallRadio]}: #{params[:clientVideocallId]}"
    location = params[:officeLocationRadio]

    client = Client.find_or_create_by(email: email)
    client.update_attributes!(name: name, phone: phone, reference: reference,
      location: location, videocall_details: videocall_details, ip_address: request.remote_ip,
      country: request.location.country, state: request.location.state)

    client
  end

  def num_free_bookings(client_id)
    events = Event.where(client_id: client_id, temporary: false).order(created_at: :asc)
    return 1 if events.empty?

    events.first.appointment.returns
  end

  def booking_slot_size(client_email)
    qtd_bookings = Client.find_by_email(client_email)&.events&.where(temporary: false)&.count || 0
    qtd_bookings < 1 ? 60 : 30
  end

  def _last_temp_event(client_email)
    Event.joins(:client).where(clients: { email: client_email}, temporary: true ).order(:id).last
  end

  def _block_off_shore?(day)
    # Ana = 5 / Claudio = 2
    agent_id = params[:agent_id]
    num_events_off_shore = Event.where(start: day.beginning_of_week..day.end_of_week, agent_id: agent_id, appointment_id: 1).count

    if agent_id == '1'
      num_events_off_shore >= 5
    elsif agent_id == '2'
      num_events_off_shore >= 2
    else
      false
    end
  end

  def _is_request_offshore?
    request.location.country != 'AU'
  end
end
