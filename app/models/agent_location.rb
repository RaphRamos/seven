class AgentLocation < ApplicationRecord
  has_paper_trail
  
  belongs_to :agent
  belongs_to :location
end
