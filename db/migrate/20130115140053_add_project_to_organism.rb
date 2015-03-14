class AddProjectToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :project, :string
  end
end
