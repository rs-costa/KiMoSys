class AddRegulatorsToOrganism < ActiveRecord::Migration
  def change
    add_column :associated_models, :regulators, :string
  end
end
