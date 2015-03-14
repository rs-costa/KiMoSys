class AddMeasurementMethodToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :measurement_method, :string
  end
end
