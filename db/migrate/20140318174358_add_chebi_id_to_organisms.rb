class AddChebiIdToOrganisms < ActiveRecord::Migration
  def change
    add_column :organisms, :chebi_id, :string
  end
end
