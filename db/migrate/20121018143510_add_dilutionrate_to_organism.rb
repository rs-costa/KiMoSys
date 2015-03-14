class AddDilutionrateToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :dilutionrate, :string
  end
end
