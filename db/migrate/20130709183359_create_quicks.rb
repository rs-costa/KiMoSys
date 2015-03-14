class CreateQuicks < ActiveRecord::Migration
  def change
    create_table :quicks do |t|
      t.text :description
      t.string :email
      t.attachment :file
      
      t.timestamps
    end
  end
end
