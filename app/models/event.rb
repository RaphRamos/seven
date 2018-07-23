class Event < ApplicationRecord
  has_paper_trail

  belongs_to :agent
  belongs_to :event_type
  belongs_to :appointment
  belongs_to :client

  accepts_nested_attributes_for :client

  validates :terms_of_service, acceptance: true

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

  def self.time_available(start_time, end_time)
    Event.where('start <= ? AND end >= ?', start_time, end_time)
      .or(Event.where(start: start_time..end_time))
      .or(Event.where(end: start_time..end_time))
  end

  def self.busy_events(start_time, end_time)
    Event.where(start: start_time..end_time, temporary: false).map do |event|
      { title: 'Not Available',
        start: event.start.iso8601,
        end: event.end.iso8601 }
    end
  end

  def self.temp_events_for(start_time, end_time, client_name, client_email)
    Event.where(start: start_time..end_time, temporary: true)
      .joins(:client)
      .where('clients.email = ? OR clients.name LIKE ?', client_email, "%#{client_name}%")
      .map do |event|
        { title: 'Reserved',
          start: event.start.iso8601,
          end: event.end.iso8601 }
    end
  end
end
