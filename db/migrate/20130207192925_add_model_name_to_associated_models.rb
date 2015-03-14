class AddModelNameToAssociatedModels < ActiveRecord::Migration
  def change
    add_column :associated_models, :model_name, :string
  end
end
