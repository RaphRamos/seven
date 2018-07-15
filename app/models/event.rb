class Event < ApplicationRecord
  has_paper_trail
  
  belongs_to :agent
  belongs_to :event_type
  belongs_to :appointment
  belongs_to :client
end
