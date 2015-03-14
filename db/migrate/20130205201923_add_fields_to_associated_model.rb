class AddFieldsToAssociatedModel < ActiveRecord::Migration
  def change
    add_column :associated_models, :category, :string
    add_column :associated_models, :used_for, :string
    add_column :associated_models, :model_type, :string
    add_column :associated_models, :pubmed_id, :string
  end
end
