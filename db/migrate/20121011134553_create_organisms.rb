class CreateOrganisms < ActiveRecord::Migration
  def change
    create_table :organisms do |t|
      t.string :organism
      t.string :strain
      t.string :type_param

      t.timestamps
    end
  end
end
