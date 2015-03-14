class CreateOrganismModels < ActiveRecord::Migration
  def change
    create_table :organisms_associated_models do |t|
      t.integer :organism_id
      t.integer :associated_model_id

      t.timestamps
    end
  end
end
