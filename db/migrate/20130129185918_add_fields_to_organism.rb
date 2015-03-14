class AddFieldsToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :sampling_method, :string
    add_column :organisms, :quenching, :string
    add_column :organisms, :extraction, :string
    add_column :organisms, :analysis, :string
    add_column :organisms, :type_analysis, :string
    add_column :organisms, :platform, :string
  end
end
