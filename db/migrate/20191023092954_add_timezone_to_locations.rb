class AddTimezoneToLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :timezone, :string

    Location.all.each do |l|
      l.update(timezone: l.name)
    end
  end
end
