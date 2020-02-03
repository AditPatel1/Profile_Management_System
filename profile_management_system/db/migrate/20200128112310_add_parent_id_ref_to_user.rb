class AddParentIdRefToUser < ActiveRecord::Migration[5.1]
  def change
  	add_reference :users, :parent, index: true
  end
end
