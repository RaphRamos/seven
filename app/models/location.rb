class Location < ApplicationRecord
  has_paper_trail

  has_many :agent_locations, dependent: :destroy
  has_many :agents, through: :agent_locations

  scope :active, -> { where(active: true) }
  scope :available, -> { joins(:agents).merge(Agent.active).order(name: :asc).uniq }

  # def self.available(is_offshore)
  #   locations = if is_offshore
  #                 Location.where(name: 'Other')
  #               else
  #                 Location.where.not(name: 'Other')
  #               end
  #   locations.joins(:agents).merge(Agent.active).order(name: :asc).uniq
  # end
end
