class CreateAppointments < ActiveRecord::Migration[5.2]
  def change
    create_table :appointments do |t|
      t.string :desc, null: false
      t.float :price, null: false
      t.integer :returns, null: false, default: 1
      t.boolean :available, null: false, default: true

      t.timestamps
    end
  end
end
