class AddPhToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :ph, :string
  end
end
