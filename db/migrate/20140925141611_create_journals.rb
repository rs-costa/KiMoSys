class CreateJournals < ActiveRecord::Migration
  def change
    create_table :review_journals do |t|
      t.string :name
      t.string :link
      t.text :description

      t.timestamps
    end
  end
end
