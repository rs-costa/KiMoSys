class AddSoftwareToAssociatedModel < ActiveRecord::Migration
  def change
    add_column :associated_models, :software, :string
  end
end
