class AddManuscripttitleToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :manuscript_title, :text
  end
end
