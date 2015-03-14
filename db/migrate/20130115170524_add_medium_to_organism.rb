class AddMediumToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :medium, :string
  end
end
