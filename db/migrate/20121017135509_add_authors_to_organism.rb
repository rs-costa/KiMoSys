class AddAuthorsToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :author, :text
  end
end
