class ChangeMediumToOrganism < ActiveRecord::Migration
  def change
    change_table :organisms do |t|
      t.change :medium, :text
    end
  end
end
