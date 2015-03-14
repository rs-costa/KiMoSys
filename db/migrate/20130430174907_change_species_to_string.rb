class ChangeSpeciesToString < ActiveRecord::Migration
  def change
    change_table :associated_models do |t|
      t.change :species, :string
    end
  end
end
