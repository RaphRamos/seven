class Timetable < ApplicationRecord
  belongs_to :agent
  has_many :timetable_event_types
  has_many :event_types, through: :timetable_event_types

  validates_presence_of :dow, :start_time, :end_time

  # def desc
  #   "#{agent.name} - #{_dow_to_string(dow).join(', ')}: #{start_time.strftime('%R')} - #{end_time.strftime('%R')}"
  # end

  private

  def _dow_to_string(dow)
    dow.split(',').map do |d|
      case d.to_i
      when 0
        'Sun'
      when 1
        'Mon'
      when 2
        'Tue'
      when 3
        'Wed'
      when 4
        'Thu'
      when 5
        'Fri'
      when 6
        'Sat'
      end
    end
  end
end
