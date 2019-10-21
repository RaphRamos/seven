class Timetable < ApplicationRecord
  has_paper_trail
  belongs_to :agent
  belongs_to :location
  has_many :timetable_event_types, dependent: :delete_all
  has_many :event_types, through: :timetable_event_types

  validates_presence_of :dow, :start_time, :end_time

  before_save :check_dates

  def self.dow_to_string(dow)
    case dow.to_i
    when 0
      'Sun'
    when 1
      'Mon'
    when 2
      'Tue'
    when 3
      'Wed'
    when 4
      'Thu'
    when 5
      'Fri'
    when 6
      'Sat'
    end
  end

  def self.build_busy_slots(day, agent_id, last_temp_event, location)
    events = Event.where('events.start < ? AND events.end >= ?', day.beginning_of_day, day.beginning_of_day)
                  .or(Event.where(start: day.beginning_of_day..day.end_of_day))
                  .or(Event.where(end: day.beginning_of_day..day.end_of_day))
                  .where(agent_id: agent_id)
                  .order(:start)

    events -= [last_temp_event] # Remove last temporary as it can be overwritten

    busy_slots = []

    events.map do |event|
      first = '0:00'
      last = '23:59'

      event_start = event.start.in_time_zone(location.name)
      event_end = event.end.in_time_zone(location.name)

      if event_start.between?(day.beginning_of_day, day.end_of_day)
        first = event_start.strftime('%R')
      end

      if event_end.between?(day.beginning_of_day, day.end_of_day)
        last = event_end.strftime('%R')
      end

      start_time = first.to_time
      loop do
        busy_slots << start_time.strftime('%H')
        start_time += 30.minutes
        break if start_time >= last.to_time
      end
    end

    busy_slots.uniq
  end

  def self.build_available_slots(day, agent_id, event_type_id, last_temp_event, location)
    slots = []
    timetables = Timetable.joins(:event_types)
                          .where('? BETWEEN from_date AND to_date', day)
                          .where(agent_id: agent_id, event_types: { id: event_type_id }, activated: true)
                          
    if timetables.empty?
      timetables = Timetable.joins(:event_types)
                            .where(agent_id: agent_id, location: location, event_types: { id: event_type_id }, activated: true)
                            .select { |tt| tt.from_date.nil? }
    end

    timetables = timetables.select { |tt| tt.dow.split(',').include?(day.wday.to_s) }
    return slots if timetables.empty? || timetables.any? { |tt| tt.location != location }

    busy_slots = build_busy_slots(day, agent_id, last_temp_event, location)
    timetables.each do |timetable|
      start_time = timetable.start_time

      loop do
        slots << start_time.strftime('%H:%M') unless busy_slots.include?(start_time.strftime('%H'))
        start_time += 60.minutes
        break if start_time >= timetable.end_time
      end
    end

    slots.sort
  end

  def self.build_timetable(day, agent_id)
    timetables = Timetable.where(agent_id: agent_id, activated: true)
                          .where('? BETWEEN from_date AND to_date', day)

    timetables = Timetable.where(agent_id: agent_id, activated: true, from_date: nil) unless timetables.present?

    timetables.map do |tt|
      if day.wday.in?(tt.dow.split(',').map(&:to_i))
        { 
          start: tt.start_time.strftime('%R'), 
          end: tt.end_time.strftime('%R'), 
          dow: [day.wday]
        }
      end
    end.compact
  end

  private

  # Rails Admin esta repassando a hora da tela como se fosse UTC, removendo 8 horas fica horario de Perth
  def check_dates
    self.start_time -= 8.hours
    self.end_time -= 8.hours
  end

  # recebe o dia da semana
  # veja eventos no dia (para o agente)
  # converte events em timeslots
  # gera timeslots do timetable
  # remove slots de eventos
  # gera o DOW para a data recebida

end
