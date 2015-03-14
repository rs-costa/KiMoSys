class CreateAttachedFiles < ActiveRecord::Migration
  def change
    create_table :attached_files do |t|
      
      t.integer :attachable_id
      t.string :attachable_type
      
      t.has_attached_file :src
       
      t.timestamps
    end
  end
end
