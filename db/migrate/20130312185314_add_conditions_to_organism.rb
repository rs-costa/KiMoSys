class AddConditionsToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :conditions, :string
  end
end
