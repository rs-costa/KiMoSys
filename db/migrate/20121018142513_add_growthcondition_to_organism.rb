class AddGrowthconditionToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :growthcondition, :string
  end
end
