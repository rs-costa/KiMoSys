class AddPublicToAssociatedModel < ActiveRecord::Migration
  def change
    add_column :associated_models, :public, :boolean
  end
end
