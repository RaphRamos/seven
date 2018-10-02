class Admin::EventController < ApplicationController
  before_action :authenticate_admin!

  def calendar
    @agents = Agent.all
  end

  def events
    agent_id = params[:agent_id]
    events = Event.preload(:client, :event_type).where(agent_id: agent_id, start: params[:start].to_date..params[:end].to_date)
    json = events.map do |e|
      event_color = if e.by_admin
                      '#ffb84d'
                    elsif e.temporary
                      '#6fa026'
                    else
                      '#474882'
                    end
      { title: "#{e.client.name}\n #{e.event_type.desc.split('Appointment ').second}",
        start: e.start,
        end: e.end,
        color: event_color,
        id: e.id,
        url: rails_admin.edit_path(model_name: e.class.name, id: e.id) }
    end.to_json
    render json: json
  end

  def update
    event = Event.find(params[:event_id])
    event.start = params[:event_start]
    event.end = params[:event_end]

    if event.save(validate: false)
      render json: :ok
    else
      render json: {errors: event.errors.full_messages}
    end
  end

  def timetable
    agent_id = params[:agent_id]
    response = Timetable.where(agent_id: agent_id, activated: true).map do |tt|
        { start: tt.start_time.strftime('%R'),
          end: tt.end_time.strftime('%R'),
          dow: tt.dow.split(',').map(&:to_i) }
      end

    render json: response.to_json
  end
end
