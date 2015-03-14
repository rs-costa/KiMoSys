class AddUserToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :user_id, :integer
  end
end
