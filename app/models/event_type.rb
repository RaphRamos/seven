class EventType < ApplicationRecord
  has_paper_trail
  has_many :timetable_event_types
  has_many :timetables, through: :timetable_event_types
end

# Language

#  Location
#  - Name
#  - Timezone (fixo)
#  - Business Hours (nao precisa)

#  Agent
#  - Name
#  - Language

#  Service
#  - Name
#  - Description
#  - Overseas (boolean)
#  - Price (need update paypal)
#  - Return Price (need update paypal)
#  - Active

#  Timetable
#  - Agent
#  - Location
#  - Service ???
#  - Start
#  - End
#  - 

# Event
#  - Agent
#  - In Person (boolean)
#  - Service (migration, skills)
#  - Start
#  - End (duration?)
#  - Return (boolean)
#  - Location

# Client

# Reference

# Payment

# Admin
