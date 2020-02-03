class AddIndextoUser < ActiveRecord::Migration[5.1]
  def change
  	add_index :users, :email
  	add_index :users, :phone_no
  end
end
