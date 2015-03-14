class AddControlToAssociatedModel < ActiveRecord::Migration
  def change
    add_column :associated_models, :control, :timestamp
  end
end
