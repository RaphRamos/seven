class ClientController < ApplicationController

  def client_by_email
    client = Client.find_by_email(params[:email])
    last_event = client&.events&.last
    num_events = client&.events&.count || 0
    render json: { client: client,
                   event_type_id: last_event&.event_type&.id,
                   agent_id: last_event&.agent&.id,
                   appointment_id: last_event&.appointment&.id,
                   subsequent_event: num_events >= 3}
  end

end
