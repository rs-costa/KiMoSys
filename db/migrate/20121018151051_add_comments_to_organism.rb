class AddCommentsToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :comments, :text
  end
end
