class CreateEventTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :event_types do |t|
      t.string :desc, null: false
      t.boolean :available, null: false, default: true

      t.timestamps
    end
  end
end
