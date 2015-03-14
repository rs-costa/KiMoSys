class AddTypeToTypeParam < ActiveRecord::Migration
  def change
    add_column :type_params, :type_small, :string
  end
end
