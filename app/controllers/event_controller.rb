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
    puts params
    render json: Event.temp_events_for(params[:start].to_date,
                                       params[:end].to_date,
                                       params[:client_name],
                                       params[:client_email])
  end

  def create_temp_event
    event = Event.new(event_params)
    event.end = event.start + 30.minutes

    if event.save
      render json: { success: true }
    else
      render json: { success: false, errors: event.errors.full_messages }
    end
  end

  private
    def event_params
      params.require(:event).permit(:agent_id, :event_type_id, :appointment_id,
        :start, :end, :terms_of_service,
        client_attributes: [:location, :name, :email, :phone])
    end
end
