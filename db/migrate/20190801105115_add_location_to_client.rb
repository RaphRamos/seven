class AddLocationToClient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :ip_address, :string
    add_column :clients, :country, :string
    add_column :clients, :state, :string
  end
end
