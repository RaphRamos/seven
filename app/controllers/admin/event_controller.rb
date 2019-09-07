class Admin::EventController < ApplicationController
  before_action :authenticate_admin!

  def calendar
    @agents = Agent.all.order(:id)
  end

  def events
    agent = Agent.find(params[:agent_id])
    events = Event.where('events.start < ? AND events.end >= ?', params[:start].to_date,  params[:start].to_date)
      .or(Event.where(start: params[:start].to_date..params[:end].to_date))
      .or(Event.where(end: params[:start].to_date..params[:end].to_date))
      .where(agent_id: agent.id)
    json = events.map do |e|
      event_color = if e.by_admin
                      '#ffb84d'
                    elsif e.temporary
                      '#6fa026'
                    else
                      '#474882'
                    end
      title = e.admin_comment.blank? ? e.client.name : e.admin_comment
      { title: "#{title}\n #{e.event_type.desc.split('Appointment ').second}",
        start: e.start.in_time_zone(agent.time_zone),
        end: e.end.in_time_zone(agent.time_zone),
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

  def new
  end

  def create
    agents = params[:agents]
    start_date = params[:start_date].to_time
    end_date = params[:end_date].to_time
    admin_comment = params[:admin_comment]

    events = agents.map do |agent_id|
      e = Event.new(agent_id: agent_id, start: start_date, end: end_date, event_type_id: 1, appointment_id: 1,
                   client_id: 1482, temporary: false, by_admin: true, admin_comment: admin_comment, event_service_id: 1)
      e.save
      e
    end

    if events.any? { |e| e.errors.present? }
      @errors = events.first.errors.full_messages
    else
      @message = 'Block events successfully created!'
    end

    render :new
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
