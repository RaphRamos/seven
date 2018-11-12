class AddVideocallInfoToClient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :videocall_details, :string
  end
end
