class CreateTimetables < ActiveRecord::Migration[5.2]
  def change
    create_table :timetables do |t|
      t.references :agent, foreign_key: true, null: false
      t.string :dow, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.boolean :activated, default: false

      t.timestamps
    end
  end
end
