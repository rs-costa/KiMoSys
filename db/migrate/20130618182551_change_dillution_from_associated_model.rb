class ChangeDillutionFromAssociatedModel < ActiveRecord::Migration
  def change
    change_table :associated_models do |t|
      t.change :dilution_rate, :string
    end
  end
end
