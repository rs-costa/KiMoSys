class AddCarbonsourceToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :carbonsource, :text
  end
end
