class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients do |t|
      t.string :name, null: false
      t.string :location, null: false
      t.string :phone, null: false
      t.string :email, null: false
      t.boolean :premium, null: false, default: false

      t.timestamps
    end
  end
end
