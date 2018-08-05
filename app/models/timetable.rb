class Timetable < ApplicationRecord
  has_paper_trail
  belongs_to :agent
  has_many :timetable_event_types
  has_many :event_types, through: :timetable_event_types

  validates_presence_of :dow, :start_time, :end_time

  def self.dow_to_string(dow)
    case dow.to_i
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
