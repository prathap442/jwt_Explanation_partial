class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :firstname
      t.string :lastname
      t.string :token
      t.string :token_expiry

      t.timestamps
    end
  end
end
