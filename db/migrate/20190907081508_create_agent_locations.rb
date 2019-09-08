class CreateAgentLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :agent_locations do |t|
      t.references :agent, foreign_key: true, null: false
      t.references :location, foreign_key: true, null: false
      t.timestamps
    end
  end
end
