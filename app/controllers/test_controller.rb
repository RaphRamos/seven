class TestController < ApplicationController

  def index
    @references = build_reference_list_ui
  end

  def fetch_timetable
    agent_id = params[:agent_id]
    service_id = params[:service_id]
    day = params[:date].to_date

    agent_timetable = Timetable.build_available_slots(day, agent_id, service_id)

    render json: { timetable: agent_timetable }
  end

  def fetch_blocked_days
    agent_id = params[:agent_id]
    service_id = params[:service_id]
    start_of_month = params[:date].to_date
    end_of_month =  params[:date].to_date + 2.months

    list_blocked_days = (start_of_month..end_of_month).to_a.map do |day|
      timetable = Timetable.build_available_slots(day, agent_id, service_id)
      day.strftime('%d/%m/%Y') if timetable.empty?
    end.compact

    render json: { blocked_days: list_blocked_days}
  end

  private

  def build_reference_list_ui
    other = ClientReference.where(desc: 'Other', active: true).first
    (ClientReference.where(active: true) - [other]) << other
  end
end
