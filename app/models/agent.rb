class Agent < ApplicationRecord
  has_paper_trail

  has_many :events
end
