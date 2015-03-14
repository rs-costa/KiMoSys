class AddUserToAssociatedModel < ActiveRecord::Migration
  def change
    add_column :associated_models, :user_id, :integer
  end
end
