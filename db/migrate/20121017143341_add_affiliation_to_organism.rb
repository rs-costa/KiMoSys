class AddAffiliationToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :affiliation, :text
  end
end
