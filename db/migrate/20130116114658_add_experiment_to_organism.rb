class AddExperimentToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :experiment, :string
  end
end
