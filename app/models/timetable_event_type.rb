class TimetableEventType < ApplicationRecord
  belongs_to :timetable
  belongs_to :event_type
end
