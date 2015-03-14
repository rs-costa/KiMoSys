class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.references :associated_model
      t.timestamps
    end
  end
end
