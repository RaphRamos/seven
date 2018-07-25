class EventType < ApplicationRecord
  has_paper_trail
  has_many :timetable_event_types
  has_many :timetables, through: :timetable_event_types
end
