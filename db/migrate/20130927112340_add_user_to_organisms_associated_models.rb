class AddUserToOrganismsAssociatedModels < ActiveRecord::Migration
  def change
    add_column :organisms_associated_models, :user_id, :integer
  end
end
