class CreateJournalsUsers < ActiveRecord::Migration
  def change
    create_table :review_journals_users do |t|
      t.belongs_to :review_journal
      t.belongs_to :user
    end
  end
end
