class AddActiveToAgents < ActiveRecord::Migration[5.2]
  def change
    add_column :agents, :active, :boolean, default: true
  end
end
