class AddBiomassToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :biomass, :string
  end
end
