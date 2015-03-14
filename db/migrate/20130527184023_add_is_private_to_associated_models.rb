class AddIsPrivateToAssociatedModels < ActiveRecord::Migration
  def change
    add_column :associated_models, :is_private, :boolean
  end
end
