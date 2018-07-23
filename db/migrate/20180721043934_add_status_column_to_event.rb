class AddStatusColumnToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :temporary, :boolean, default: true, null: false
  end
end
