class AddTimezoneToAgents < ActiveRecord::Migration[5.2]
  def change
    add_column :agents, :time_zone, :string, default: 'Perth'
  end
end
