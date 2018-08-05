class ClientController < ApplicationController

  def client_by_email
    client = Client.find_by_email(params[:email])
    last_event = client&.events&.last
    render json: { client: client,
                   event_type_id: last_event&.event_type&.id,
                   agent_id: last_event&.agent&.id,
                   appointment_id: last_event&.appointment&.id }
  end

end
