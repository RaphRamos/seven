class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.integer :status, null: false, default: 0
      t.float :price, null: false, default: 0.0
      t.references :client, foreign_key: true, null: false
      t.references :event, foreign_key: true, null: false
      t.string :transaction_code

      t.timestamps
    end
  end
end
