class CreatePlants < ActiveRecord::Migration[7.1]
  def change
    create_table :plants do |t|
      t.float :humidity_soil
      t.float :humidity_env
      t.float :temperature_env
      t.timestamps
    end
  end
end
