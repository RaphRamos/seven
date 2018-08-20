# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts 'Seeding DB...'
# Admins
Admin.create!(name: 'Raphael Ramos', email: 'raphael.au@icloud.com', password: 'n7T-2?w8LUF*)5nzb6r)', password_confirmation: 'n7T-2?w8LUF*)5nzb6r)')
Admin.create!(name: 'Laura Ramos', email: 'info@sevenmigration.com.au', password: 'sevenmigration777', password_confirmation: 'sevenmigration777')
Admin.create!(name: 'Claudio Garzini', email: 'claudio@sevenmigration.com.au', password: 'sevenmigration777', password_confirmation: 'sevenmigration777')
Admin.create!(name: 'Ana Julia Caruzi', email: 'ana.julia@sevenmigration.com.au', password: 'sevenmigration777', password_confirmation: 'sevenmigration777')
Admin.create!(name: 'Flavia', email: 'flavia@sevenmigration.com.au', password: 'sevenmigration777', password_confirmation: 'sevenmigration777')
Admin.create!(name: 'Joao Pedro', email: 'pedro.fandinho@informationplanet.com.au', password: 'sevenmigration777', password_confirmation: 'sevenmigration777')

ClientReference.create!(desc: 'Google', active: true)
ClientReference.create!(desc: 'Friend', active: true)
ClientReference.create!(desc: 'Family', active: true)
ClientReference.create!(desc: 'YouTube', active: true)
ClientReference.create!(desc: 'Facebook', active: true)
ClientReference.create!(desc: 'Information Planet Brazil', active: true)
ClientReference.create!(desc: 'Information Planet Australia', active: true)
ClientReference.create!(desc: 'Information Planet Global', active: true)
ClientReference.create!(desc: 'Other', active: true)

Agent.create!(name: 'Ana Julia Carusi', display_name: 'Ana Julia Carusi', email: 'ana.julia@sevenmigration.com.au')
Agent.create!(name: 'Claudio Garzini',  display_name: 'Claudio Garzini',  email: 'claudio@sevenmigration.com.au')

Appointment.create!(desc: 'Outside Australia', price: 215.0, returns: 2, available: true)
Appointment.create!(desc: 'Inside Australia',  price: 180.0, returns: 3, available: true)

EventType.create!(desc: 'Appointment In Person')
EventType.create!(desc: 'Appointment Via Video Conference')
EventType.create!(desc: 'Appointment Via Phone Call')

Timetable.create!(agent_id: 1, dow: '1,5', start_time: '09:00', end_time: '12:00', activated: true)
Timetable.create!(agent_id: 1, dow: '2,4', start_time: '09:30', end_time: '17:00', activated: true)
Timetable.create!(agent_id: 1, dow: '3',   start_time: '14:00', end_time: '17:00', activated: true)

Timetable.create!(agent_id: 2, dow: '2,4', start_time: '09:30', end_time: '12:00', activated: true)
Timetable.create!(agent_id: 2, dow: '2,4', start_time: '13:00', end_time: '17:00', activated: true)
Timetable.create!(agent_id: 2, dow: '5',   start_time: '09:30', end_time: '12:00', activated: true)

# ana skype + phone
TimetableEventType.create!(timetable_id: 1, event_type_id: 2)
TimetableEventType.create!(timetable_id: 1, event_type_id: 3)

# ana in person
TimetableEventType.create!(timetable_id: 2, event_type_id: 1)

# ana skype + phone
TimetableEventType.create!(timetable_id: 3, event_type_id: 2)
TimetableEventType.create!(timetable_id: 3, event_type_id: 3)

# claudio all types
TimetableEventType.create!(timetable_id: 4, event_type_id: 1)
TimetableEventType.create!(timetable_id: 4, event_type_id: 2)
TimetableEventType.create!(timetable_id: 4, event_type_id: 3)
TimetableEventType.create!(timetable_id: 5, event_type_id: 1)
TimetableEventType.create!(timetable_id: 5, event_type_id: 2)
TimetableEventType.create!(timetable_id: 5, event_type_id: 3)

# claudio skype and phone calls
TimetableEventType.create!(timetable_id: 6, event_type_id: 1)
TimetableEventType.create!(timetable_id: 6, event_type_id: 2)

# Load legacy data
csv_path = 'db/legacy_data/seven_from_2016.csv'
csv = CSV.parse(File.read(csv_path), headers: true)
data = csv.map(&:to_h)

puts 'Loading legacy data...'
data.each do |e|
  print '.'
  next if e['Email'].blank?
  next unless e['Status'].downcase == 'confirmed'
  next if e['Label'] == 'No-Show'

  agent = Agent.find_by_name e['Resource Name']
  next unless agent.present?

  next if e['Service/Class'].downcase.include?('no fee')

  event_type_id = 1
  event_type_id = 2 if e['Service/Class'].downcase.include?('skype')
  event_type_id = 3 if e['Service/Class'].downcase.include?('phone')

  client = Client.find_by_email(e['Email'])
  unless client.present?
    client = Client.new(email: e['Email'], name: e['Customer Name'],
                        phone: "#{e['Country Code']}#{e['Phone']}",
                        location: "#{e['City']} - #{e['State']}")
    client.save!(validate: false)
  end

  start_time = "#{e['Date']} #{e['Time'].split(' - ').first} +0800".to_datetime
  end_time = "#{e['Date']} #{e['Time'].split(' - ').second} +0800".to_datetime

  if start_time < '1 Jul 2017'.to_date
    next if client.events.count.positive?
  end

  event = Event.new(agent_id: agent.id, event_type_id: event_type_id,
                    client_id: client.id, start: start_time, end: end_time,
                    temporary: false, appointment_id: event_type_id == 1 ? 2 : 1)
  event.save!(validate: false)
end

puts 'Seeding completed!'
