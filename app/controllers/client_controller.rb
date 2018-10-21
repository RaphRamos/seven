class ClientController < ApplicationController

  def client_by_email
    client = Client.find_by_email(params[:email])

    render json: { client: client }
  end

end
