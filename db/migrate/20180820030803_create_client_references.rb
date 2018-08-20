class CreateClientReferences < ActiveRecord::Migration[5.2]
  def change
    create_table :client_references do |t|
      t.string :desc, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
