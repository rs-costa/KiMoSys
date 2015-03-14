class AddConfirmableToDeviseV2 < ActiveRecord::Migration
  def change
    change_table(:users) do |t| 
      ## Confirmable
      t.string   :unconfirmed_email # Only if using reconfirmable
    end
  end
end
