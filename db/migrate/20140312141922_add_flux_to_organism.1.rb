class AddFluxToOrganism < ActiveRecord::Migration
  def self.up
    change_table :organisms do |t|
      t.has_attached_file :additional_files
    end
  end

  def self.down
    drop_attached_file :organisms, :additional_files
  end
end
