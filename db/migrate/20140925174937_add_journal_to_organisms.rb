class AddJournalToOrganisms < ActiveRecord::Migration
  def change
    add_column :organisms, :review_journal_id, :integer
    add_column :associated_models, :review_journal_id, :integer
  end
end
