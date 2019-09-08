class Event < ApplicationRecord
  has_paper_trail

  belongs_to :agent
  belongs_to :event_type
  belongs_to :appointment
  belongs_to :client
  belongs_to :event_service
  belongs_to :location

  has_one :payment

  accepts_nested_attributes_for :client

  validates :terms_of_service, acceptance: true, unless: :temporary
  validates_presence_of :start, :end
  validates_associated :client

  def autosave_associated_records_for_client
    new_client = Client.where(email: client.email)
    if new_client.size == 0
      self.client.save!
      self.client_id = self.client.id
    else
      self.client = new_client.first if !client.email.blank? && !client.name.blank?
    end
  end

  def self.time_available(start_time, end_time)
    Event.where('start <= ? AND end >= ?', start_time, end_time)
      .or(Event.where(start: start_time..end_time))
      .or(Event.where(end: start_time..end_time))
  end

  def self.busy_events(start_time, end_time, agent_id)
    Event.where('events.start < ? AND events.end >= ?', start_time, start_time)
         .or(Event.where(start: start_time..end_time))
         .or(Event.where(end: start_time..end_time))
         .where(agent_id: agent_id).map do |event|
      { title: 'Not Available',
        start: event.start.iso8601,
        end: event.end.iso8601 }
    end
  end

  def self.temp_events_for(start_time, end_time, client_email, agent_id)
    return if client_email.blank?
    Event.where(start: start_time..end_time, temporary: true, agent_id: agent_id)
      .joins(:client)
      .where('clients.email = ?', client_email)
      .map do |event|
        { title: event.client.name,
          start: event.start.iso8601,
          end: event.end.iso8601 }
    end
  end

  def self.overlaps?(event_start, event_end, agent_id)
    Event.where('events.start > ? AND events.start < ?', event_start, event_end)
         .or(Event.where('events.end > ? AND events.end < ?', event_start, event_end))
         .where(agent_id: agent_id)
         .count.positive?
  end

  def first_event?
    client.events.order(:created_at).first.id == id
  end
end
