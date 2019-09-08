class AddFromAndToDateToTimetable < ActiveRecord::Migration[5.2]
  def change
    add_column :timetables, :from_date, :date
    add_column :timetables, :to_date, :date
  end
end
