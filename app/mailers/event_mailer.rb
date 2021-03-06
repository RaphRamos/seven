class EventMailer < ApplicationMailer

  def confirmation_email
    @event = params[:event]
    @event_formated_date = @event.start.in_time_zone(@event.location.timezone).strftime('%a %b %d, %Y %I:%M %P')
    mail(to: @event.client.email, subject: 'Appointment Confirmation - Seven Migration')
  end

  def reminder_email
    @event = params[:event]
    @event_formated_date = @event.start.in_time_zone(@event.location.timezone).strftime('%a %b %d, %Y %I:%M %P')
    mail(to: @event.client.email, subject: 'Appointment Reminder - Seven Migration')
  end
end
