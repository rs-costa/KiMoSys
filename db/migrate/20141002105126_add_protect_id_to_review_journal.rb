class AddProtectIdToReviewJournal < ActiveRecord::Migration
  def change
    add_column :review_journals, :protect_id, :boolean
  end
end
