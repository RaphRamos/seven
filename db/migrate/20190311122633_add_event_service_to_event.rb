class AddEventServiceToEvent < ActiveRecord::Migration[5.2]
  def change
    add_reference :events, :event_service, foreign_key: true
  end
end
