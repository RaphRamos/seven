class Agent < ApplicationRecord
  has_paper_trail

  has_many :events
  has_many :agent_locations
  has_many :locations, through: :agent_locations

  scope :active, -> { where(active: true) }

  def self.languages
    Agent.active.pluck(:language).flat_map { |l| l.split(', ') }.map(&:capitalize).uniq.sort
  end

  def self.skill_advice
    Agent.find(3)
  end
end
