class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.references :agent, foreign_key: true, null: false
      t.references :event_type, foreign_key: true, null: false
      t.references :appointment, foreign_key: true, null: false
      t.references :client, foreign_key: true, null: false
      t.datetime :start, null: false
      t.datetime :end, null: false

      t.timestamps
    end
  end
end
