class Admin::EventController < ApplicationController
  before_action :authenticate_admin!

  def calendar
    @agents = Agent.all.order(:name)
  end

  def events
    agent = Agent.find(params[:agent_id])
    events = Event.where('events.start < ? AND events.end >= ?', params[:start].to_date,  params[:start].to_date)
      .or(Event.where(start: params[:start].to_date..params[:end].to_date))
      .or(Event.where(end: params[:start].to_date..params[:end].to_date))
      .where(agent_id: agent.id)
    json = events.map do |e|
      event_color = if e.by_admin
                      '#737476' # cinza
                    elsif e.temporary
                      '#0C481C' # verde
                    else
                      '#474882' # roxo
                    end
      title = e.admin_comment.blank? ? e.client.name : e.admin_comment
      { title: "#{'** ' if e.first_event?}#{title}\n #{_service_type_desc(e)} - #{e.location.name} (#{e.language[0..2]})",
        start: e.start.in_time_zone(params[:timezone]),
        end: e.end.in_time_zone(params[:timezone]),
        color: event_color,
        textColor: e.first_event? ? '#D7C31D' : '#FFFFFF',
        id: e.id,
        url: rails_admin.edit_path(model_name: e.class.name, id: e.id) }
    end.to_json
    render json: json
  end

  def update
    event = Event.find(params[:event_id])
    offset = ActiveSupport::TimeZone[event.location.name].formatted_offset(false)
    event.start = "#{params[:event_start]} #{offset}"
    event.end = "#{params[:event_end]} #{offset}"

    if event.save(validate: false)
      render json: :ok
    else
      render json: {errors: event.errors.full_messages}
    end
  end

  def new
  end

  def new_by_admin
    debugger
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

  private

  def _service_type_desc(event)
    case event.event_type.id
    when 1
      'In Person'
    when 2
      'Video'
    when 3
      'Phone'
    else
      'xxx'
    end
  end
end
