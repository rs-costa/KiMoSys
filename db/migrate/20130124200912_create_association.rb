class CreateAssociation < ActiveRecord::Migration
  def change
    create_table 'associations' do |t|
      t.column :user_id, :integer
      t.column :organism_id, :integer
    end
  end
  
  
  def down
    drop_table :associations
  end
end
