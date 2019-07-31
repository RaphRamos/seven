class ClientController < ApplicationController

  def client_by_email
    client = Client.find_by_email(params[:email])

    render json: { client: client }
  end

  def index
    @filterrific = initialize_filterrific(
      Client,
      params[:filterrific]
    ) or return
    @clients = @filterrific.find.page(params[:page])
 
    respond_to do |format|
      format.html
      format.js
    end
  end

end
