class AddCreatedFlagToOrganismsAssociatedModels < ActiveRecord::Migration
  def change
    add_column :organisms_associated_models, :original, :boolean
  end
end
