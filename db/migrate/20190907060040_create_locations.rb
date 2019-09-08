class CreateLocations < ActiveRecord::Migration[5.2]
  def up
    create_table :locations do |t|
      t.string :name
      t.boolean :active, defaut: true

      t.timestamps
    end

    ['Perth', 'Adelaide', 'Sydney'].each do |l|
      Location.create(name: l, active: true)
    end
  end

  def down
    drop_table :locations
  end
end
