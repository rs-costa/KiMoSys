class ChangeFields < ActiveRecord::Migration
  def change
    add_column :associated_models, :keywords, :string
    add_column :organisms, :keywords, :string
  end
end
