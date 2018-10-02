class AddAdminFlagToEvents < ActiveRecord::Migration[5.2]
  def up
    add_column :events, :by_admin, :boolean, default: true, null: false
    Event.all.update_all(by_admin: false)
  end

  def down
    remove_column :events, :by_admin
  end
end
