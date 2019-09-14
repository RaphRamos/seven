class AddOfficeNameToLocation < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :office_name, :string, default: 'Seven Migration'
  end
end
