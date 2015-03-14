class AddVolumeToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :volume, :string
  end
end
