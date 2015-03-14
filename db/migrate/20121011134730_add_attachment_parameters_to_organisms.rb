class AddAttachmentParametersToOrganisms < ActiveRecord::Migration
  def self.up
    change_table :organisms do |t|
      t.has_attached_file :parameters
    end
  end

  def self.down
    drop_attached_file :organisms, :parameters
  end
end
