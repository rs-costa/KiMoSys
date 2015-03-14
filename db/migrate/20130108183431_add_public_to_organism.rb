class AddPublicToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :is_public, :boolean
  end
end
