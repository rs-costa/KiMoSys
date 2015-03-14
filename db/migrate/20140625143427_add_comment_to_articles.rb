class AddCommentToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :comment, :string
  end
end
