class AddDilutionRateToAssociatedModel < ActiveRecord::Migration
  def change
    add_column :associated_models, :dilution_rate, :float
  end
end
