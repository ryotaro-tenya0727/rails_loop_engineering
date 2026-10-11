class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :login_id, null: false
      t.string :password_digest, null: false

      t.timestamps
    end

    add_index :users, :login_id, unique: true
  end
end
