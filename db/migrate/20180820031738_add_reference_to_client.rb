class AddReferenceToClient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :reference, :string
  end
end
