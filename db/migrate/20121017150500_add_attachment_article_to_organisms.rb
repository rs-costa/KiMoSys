class AddAttachmentArticleToOrganisms < ActiveRecord::Migration
  def self.up
    change_table :organisms do |t|
      t.has_attached_file :article
    end
  end

  def self.down
    drop_attached_file :organisms, :article
  end
end
