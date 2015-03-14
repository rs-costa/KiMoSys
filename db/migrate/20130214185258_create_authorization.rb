class CreateAuthorization < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.references :authorizable, :polymorphic => true
      t.references :user
      t.timestamps
    end
  end
end
