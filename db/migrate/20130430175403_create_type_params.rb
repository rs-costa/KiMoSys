class CreateTypeParams < ActiveRecord::Migration
  def change
    create_table :type_params do |t|
      t.string :title

      t.timestamps
    end
  end
end
