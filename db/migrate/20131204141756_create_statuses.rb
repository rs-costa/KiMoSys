class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.integer :statusable_id
      t.string :statusable_type
      t.string :comment
      t.boolean :is_reviewed
      t.integer :user_id

      t.timestamps
    end
  end
end
