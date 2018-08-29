class EventMailer < ApplicationMailer

  def confirmation_email
    @event = params[:event]
    @event_formated_date = @event.start.strftime('%a %b %d, %Y %I:%M %P')
    mail(to: @event.client.email, subject: 'Appointment Confirmation - Seven Migration')
  end
end
