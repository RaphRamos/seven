class AddAddressToLocation < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :address, :string, default: ''
  end
end
