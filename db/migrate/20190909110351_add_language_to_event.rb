class AddLanguageToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :language, :string, default: 'English'
  end
end
