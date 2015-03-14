class RemoveFluxToOrganism < ActiveRecord::Migration
  def self.up
    drop_attached_file :organisms, :additional_files
  end

  def self.down
    change_table :organisms do |t|
      t.has_attached_file :additional_files
    end
  end
end
