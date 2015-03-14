class AddFieldsToAssociatedModels < ActiveRecord::Migration
  def change
    add_column :associated_models, :manuscript_title, :string
    add_column :associated_models, :authors, :string
    add_column :associated_models, :journal, :string
    add_column :associated_models, :affiliation, :string
    add_column :associated_models, :project_name, :string
  end
end
