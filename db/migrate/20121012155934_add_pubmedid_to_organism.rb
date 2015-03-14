class AddPubmedidToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :pubmed_id, :string
  end
end
