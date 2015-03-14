class AddDataUnitsToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :data_units, :string
  end
end
