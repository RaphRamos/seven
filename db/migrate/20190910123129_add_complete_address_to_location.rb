class AddCompleteAddressToLocation < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :city, :string
    add_column :locations, :postcode, :string
    add_column :locations, :state, :string
    add_column :locations, :phone, :string
  end
end
