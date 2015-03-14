class CreateAssociatedModels < ActiveRecord::Migration
  def change
    create_table :associated_models do |t|
      t.references :organism
      t.integer :reactions
      t.integer :species
      t.integer :parameters
      t.integer :compartments
      t.text :comments
      
      t.has_attached_file :sbml
      t.has_attached_file :article

      t.timestamps
    end
    add_index :associated_models, :organism_id
  end
end
