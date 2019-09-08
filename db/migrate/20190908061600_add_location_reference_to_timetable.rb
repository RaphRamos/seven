class AddLocationReferenceToTimetable < ActiveRecord::Migration[5.2]
  def change
    add_reference :timetables, :location, index: true
  end
end
