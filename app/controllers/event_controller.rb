class EventController < ApplicationController

  def new
    @event = Event.new
    @agents = Agent.all
    @eventTypes = EventType.all
  end

  def create
    event = Event.new(event_params)
    event.client.build
    event.save!
    render :new
  end

  private
    def event_params
      params.require(:event).permit(:agent_id, :event_type_id, :start, :end,
        client: [:location, :name, :email, :phone])
    end
end
