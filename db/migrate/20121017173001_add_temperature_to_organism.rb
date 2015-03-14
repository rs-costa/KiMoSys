class AddTemperatureToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :temperature, :string
  end
end
