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

  private
    def event_params
      params.require(:event).permit(:agent_id, :event_type_id, :appointment_id,
        :start, :end, :terms_of_service,
        client_attributes: [:location, :name, :email, :phone])
    end
end
