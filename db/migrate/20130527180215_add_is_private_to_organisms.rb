class AddIsPrivateToOrganisms < ActiveRecord::Migration
  def change
    add_column :organisms, :is_private, :boolean
  end
end
