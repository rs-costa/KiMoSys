class AddUserEmailToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :user_email, :string
    add_column :associated_models, :user_email, :string
  end
end
