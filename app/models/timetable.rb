class Timetable < ApplicationRecord
  has_paper_trail
  belongs_to :agent
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

  private

  # Rails Admin esta repassando a hora da tela como se fosse UTC, removendo 8 horas fica horario de Perth
  def check_dates
    self.start_time -= 8.hours
    self.end_time -= 8.hours
  end
end
