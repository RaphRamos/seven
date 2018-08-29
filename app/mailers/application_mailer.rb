class ApplicationMailer < ActionMailer::Base
  default from:     'bookings@sevenmigration.com.au',
          reply_to: 'info@sevenmigration.com.au'

  layout 'mailer'
end
