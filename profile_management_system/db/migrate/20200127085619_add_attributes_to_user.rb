class AddAttributesToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :phone_no, :string
    add_column :users, :address, :text
    add_column :users, :birth_date, :date
    add_column :users, :about_me, :text
  end
end

#phone no. index