class AddHomePageToUser < ActiveRecord::Migration
  def change
    add_column :users, :home_page, :string
  end
end
