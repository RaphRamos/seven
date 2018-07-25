class CreateTimetableEventTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :timetable_event_types do |t|
      t.references :timetable, foreign_key: true
      t.references :event_type, foreign_key: true

      t.timestamps
    end
  end
end
