class PaymentNotificationsController < ApplicationController
  protect_from_forgery :except => [:create] #Otherwise the request from PayPal wouldn't make it to the controller
  def create
    response = validate_IPN_notification(request.raw_post, request.user_agent)
    case response
    when "VERIFIED"
      event = Event.find(params[:custom]) # custom variable sent to PayPal (Event ID)
      event.temporary = false
      event.save!

      EventMailer.with(event: event).confirmation_email.deliver_now
      Payment.create!(client_id: event.client_id, event_id: event.id, transaction_code: params[:txn_id],
                      price: params[:mc_gross], status: 2)
    when "INVALID"
      puts 'PAYPAL INVALID RESPONSE'
      puts response
    else
      puts 'PAYPAL ERROR'
      puts response
    end
    head :ok
  end

  protected

  def validate_IPN_notification(raw, user_agent)
    uri = URI.parse('https://ipnpb.paypal.com/cgi-bin/webscr?cmd=_notify-validate')
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 60
    http.read_timeout = 60
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.use_ssl = true
    response = http.post(uri.request_uri, raw,
                         'Content-Length' => "#{raw.size}",
                         'User-Agent' => "#{user_agent}"
                       ).body
  end
end
