class EventController < ApplicationController

  def new
    @event = Event.new
    @event.client = Client.new
    @agents = Agent.all
    @eventTypes = EventType.all
    @appointments = Appointment.all
  end

  def create
    event = Event.create!(event_params)
    redirect_to new_event_path
  end

  def busy_events
    render json: Event.busy_events(params[:start].to_date,
                                   params[:end].to_date)
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

    if event.save!
      render json: { success: true }
    else
      render json: { success: false, errors: event.errors.full_messages }
    end
  end

  def timetable
    agent_id = params[:agent_id]
    event_type_id = params[:event_type_id]
    response = {}
    response[:businessHours] = Timetable.joins(:event_types).where(agent_id: agent_id,
      activated: true, event_types: { id: event_type_id }).map do |tt|
        { start: tt.start_time.strftime('%R'),
          end: tt.end_time.strftime('%R'),
          dow: tt.dow.split(',').map(&:to_i) }
      end
    response[:hiddenDays] = Array(0..6) - response[:businessHours].map {|d| d[:dow] }.flatten

    render json: response
  end

  private
    def event_params
      params.require(:event).permit(:agent_id, :event_type_id, :appointment_id,
        :start, :end, :terms_of_service,
        client_attributes: [:location, :name, :email, :phone])
    end
end
