class AddJournalToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :journal, :string
  end
end
