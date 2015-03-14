class AddAttachmentCombineArchiveToAssociatedModels < ActiveRecord::Migration
  def self.up
    change_table :associated_models do |t|
      t.attachment :combine_archive
    end
  end

  def self.down
    drop_attached_file :associated_models, :combine_archive
  end
end
