class TestController < ApplicationController

  def index
    @references = build_reference_list_ui
  end

  def fetch_timetable
    agent_id = params[:agent_id]
    service_id = params[:service_id]
    day = params[:date].to_date

    slot_with_60_minutes = true
    client = Client.find_by_email(params[:clientEmail])
    slot_with_60_minutes = client.events.where(temporary: false).count < 2 if client.present?

    agent_timetable = Timetable.build_available_slots(day, agent_id, service_id, slot_with_60_minutes)

    render json: { timetable: agent_timetable }
  end

  def fetch_blocked_days
    agent_id = params[:agent_id]
    service_id = params[:service_id]
    start_of_month = params[:date].to_date
    end_of_month =  params[:date].to_date + 2.months

    slot_with_60_minutes = true
    client = Client.find_by_email(params[:clientEmail])
    slot_with_60_minutes = client.events.where(temporary: false).count < 2 if client.present?

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
    fee = :returning if num_bookings >= 2
    fee = :premium if client.premium

    # Booking details
    agent_id = params[:agentRadio]
    service_id = params[:serviceRadio]
    start_booking = "#{params[:selectedDate]} #{params[:availableTimeRadio]}".to_time
    temporary_booking = num_bookings != 1
    temporary_booking = false if fee == :premium
    duration = num_bookings >=2 || fee == :premium ? 30.minutes : 1.hour

    appointment_id = case fee
                       when :onshore
                         1
                       when :offshore
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
    videcall_info = params[:clientVidecallId]
    location = params[:locationRadio]

    client = Client.find_or_create_by(email: email)
    client.update_attributes!(name: name, phone: phone, reference: reference,
      location: location)

    client
  end
end
