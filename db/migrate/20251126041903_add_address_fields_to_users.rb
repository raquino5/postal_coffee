class AddAddressFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :address, :string
    add_column :users, :city, :string
    add_column :users, :postal_code, :string
    add_reference :users, :province, null: false, foreign_key: true
  end
end
