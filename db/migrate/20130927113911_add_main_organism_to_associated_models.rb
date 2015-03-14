class AddMainOrganismToAssociatedModels < ActiveRecord::Migration
  def change
    add_column :associated_models, :main_organism, :string
  end
end
