class AddEmaiFlagToOrganismsAssociatedModels < ActiveRecord::Migration
  def change
    add_column :organisms_associated_models, :user_email, :string
  end
end
