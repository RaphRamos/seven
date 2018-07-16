class Event < ApplicationRecord
  has_paper_trail

  belongs_to :agent
  belongs_to :event_type
  belongs_to :appointment
  belongs_to :client

  accepts_nested_attributes_for :client

  validates :terms_of_service, acceptance: true, presence: true

  def autosave_associated_records_for_client
    c = Client.arel_table
    new_client = Client.where(email: client.email).or(
                  Client.where(c[:name].matches("%#{client.name}%")))
    if new_client.size == 0
      self.client.save!
      self.client_id = self.client.id
    else
      self.client = new_client.first
    end
  end
end
