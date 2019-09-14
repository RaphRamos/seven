class AddOffshoreToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :offshore, :boolean
  end
end
