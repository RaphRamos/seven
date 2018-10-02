class EventController < ApplicationController

  def new
    @event = Event.new
    @event.client = Client.new
    @agents = Agent.all
    @eventTypes = EventType.all
    @appointments = Appointment.all
    @references = ClientReference.where(active: true)
  end

  def create
    event = Event.create!(event_params)
    redirect_to new_event_path
  end

  def busy_events
    render json: Event.busy_events(params[:start].to_date,
                                   params[:end].to_date,
                                   params[:agent_id])
  end

  def temp_events
    render json: Event.temp_events_for(params[:start].to_date,
                                       params[:end].to_date,
                                       params[:client_email])
  end

  def create_temp_event
    event = Event.new(event_params)
    lastTempEvent = Event.joins(:client).where(temporary: true, clients: { email: event.client.email}).last

    if lastTempEvent.present?
      lastTempEvent.start = event.start
      lastTempEvent.event_type_id = event.event_type_id
      lastTempEvent.appointment_id = event.appointment_id
      event = lastTempEvent
    end

    num_events = Client.find_by_email(event.client.email)&.events&.where(temporary: false)&.count || 0
    app_duration = num_events > 0 ? 30.minutes : 1.hour
    event.end = event.start + app_duration
    event.temporary = true
    event.by_admin = false

    if event.save!
      render json: { success: true, event_id: event.id, free: free_appointment?(event.client.email) }
    else
      render json: { success: false, errors: event.errors.full_messages }
    end
  end

  def timetable
    agent_id = params[:agent_id]
    event_type_id = params[:event_type_id]
    first_appointment = !Client.joins(:events).where(email: params[:client_email], events: { temporary: false }).present?
    response = {}
    response[:businessHours] = Timetable.joins(:event_types).where(agent_id: agent_id,
      activated: true, event_types: { id: event_type_id }).map do |tt|
        { start: tt.start_time.strftime('%R'),
          end: (first_appointment ? tt.end_time - 30.minutes : tt.end_time).strftime('%R'),
          dow: tt.dow.split(',').map(&:to_i) }
      end
    response[:hiddenDays] = Array(0..6) - response[:businessHours].map {|d| d[:dow] }.flatten
    render json: response
  end

  def confirm_event
    event = Event.find(params[:event_id])
    if free_appointment?(event.client.email)
      event.temporary = false
      event.save!

      EventMailer.with(event: event).confirmation_email.deliver_now
    end

    redirect_to :root
  end

  private
    def event_params
      params.require(:event).permit(:agent_id, :event_type_id, :appointment_id,
        :start, :end, :terms_of_service,
        client_attributes: [:location, :name, :email, :phone, :reference])
    end

    def free_appointment?(client_email)
      num_events = Client.find_by_email(client_email)&.events&.where(temporary: false)&.count || 0
      qtd_appointment_paid = Client.find_by_email(client_email)&.events&.where(temporary: false)&.last&.appointment&.returns || 0
      num_events > 0 && num_events < qtd_appointment_paid
    end
end
