class AddBiomodelToAssociatedModel < ActiveRecord::Migration
  def change
    add_column :associated_models, :biomodels_id, :string
  end
end
