class TimetableEventType < ApplicationRecord
  has_paper_trail
  belongs_to :timetable
  belongs_to :event_type
end
