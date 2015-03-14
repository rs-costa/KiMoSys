class AddAttachmentImageToTypeParams < ActiveRecord::Migration
  def self.up
    change_table :type_params do |t|
      t.has_attached_file :image
    end
  end

  def self.down
    drop_attached_file :type_params, :image
  end
end
