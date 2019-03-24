class CreateEventServices < ActiveRecord::Migration[5.2]
  def change
    create_table :event_services do |t|
      t.string :desc
      t.float :first_app_price
      t.float :return_app_price

      t.timestamps
    end
  end
end
