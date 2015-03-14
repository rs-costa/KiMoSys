class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :affiliation, :string
    add_column :users, :research_interests, :string
  end
end
