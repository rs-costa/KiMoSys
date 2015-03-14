class AddYearToOrganisms < ActiveRecord::Migration
  def change
    add_column :organisms, :year, :integer
    add_column :associated_models, :year, :integer
  end
end
