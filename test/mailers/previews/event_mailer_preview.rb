# Preview all emails at http://localhost:3000/rails/mailers/event_mailer
class EventMailerPreview < ActionMailer::Preview

  def confirmation_email
    @event = Client.find(1241).events.first
    EventMailer.with(event: @event).confirmation_email
  end
end
