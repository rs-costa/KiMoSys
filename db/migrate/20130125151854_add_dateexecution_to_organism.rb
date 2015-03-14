class AddDateexecutionToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :execution, :date
  end
end
