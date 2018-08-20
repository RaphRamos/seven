class AddNotesToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :notes, :text
  end
end
