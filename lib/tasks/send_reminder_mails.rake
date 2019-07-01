namespace :send_mails do
  desc 'Send Reminder Emails'

  task reminders: :environment do
    events = Event.where(temporary: false, start: 2.days.from_now.beginning_of_day..2.days.from_now.end_of_day)
    events.each do |event|
      EventMailer.with(event: event).reminder_email.deliver_now
    end
  end
end