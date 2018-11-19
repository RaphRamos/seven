class EventController < ApplicationController

  def index
    booking = Event.where(id: params[:custom])
    redirect_to booking.first and return if booking&.first&.present?

    @references = build_reference_list_ui
  end

  def fetch_timetable
    agent_id = params[:agent_id]
    service_id = params[:service_id]
    day = params[:date].to_date

    slot_with_60_minutes = booking_slot_size(params[:clientEmail]) == 60

    agent_timetable = Timetable.build_available_slots(day, agent_id, service_id, slot_with_60_minutes)

    render json: { timetable: agent_timetable }
  end

  def fetch_blocked_days
    agent_id = params[:agent_id]
    service_id = params[:service_id]
    start_of_month = params[:date].to_date
    end_of_month =  params[:date].to_date + 2.months

    slot_with_60_minutes = booking_slot_size(params[:clientEmail]) == 60

    list_blocked_days = (start_of_month..end_of_month).to_a.map do |day|
      timetable = Timetable.build_available_slots(day, agent_id, service_id, slot_with_60_minutes)
      day.strftime('%d/%m/%Y') if timetable.empty?
    end.compact

    render json: { blocked_days: list_blocked_days}
  end

  def register_booking
    client = create_or_find_client

    # Calculete correct fee
    fee = ['1', '2'].include?(client.location) ? :onshore : :offshore
    num_bookings = Event.where(client_id: client.id, temporary: false).count
    fee = :returning if num_bookings >= num_free_bookings(client.id)
    fee = :premium if client.premium

    # Booking details
    agent_id = params[:agentRadio]
    service_id = params[:serviceRadio]
    start_booking = "#{params[:selectedDate]} #{params[:availableTimeRadio]}".to_time
    temporary_booking = num_bookings.zero? || fee == :returning
    temporary_booking = false if fee == :premium
    duration = num_bookings >=2 || fee == :premium ? 30.minutes : 1.hour

    appointment_id = case fee
                       when :offshore
                         1
                       when :onshore
                         2
                       else
                         3
                     end

    @event = Event.create(agent_id: agent_id, event_type_id: service_id,
      client_id: client.id, event_type_id: service_id, start: start_booking,
      end: start_booking + duration, temporary: temporary_booking,
      by_admin: false, appointment_id: appointment_id)

    if @event.save!
      # sucess
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
    location = params[:locationRadio]

    client = Client.find_or_create_by(email: email)
    client.update_attributes!(name: name, phone: phone, reference: reference,
      location: location, videocall_details: videocall_details)

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
end
