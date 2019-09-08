class AddLanguageToAgents < ActiveRecord::Migration[5.2]
  def change
    add_column :agents, :language, :string, default: 'English, Portuguese'
  end
end
