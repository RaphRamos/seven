class AddLocationToEvent < ActiveRecord::Migration[5.2]
  def change
    add_reference :events, :location, index: true, default: 1
  end
end
