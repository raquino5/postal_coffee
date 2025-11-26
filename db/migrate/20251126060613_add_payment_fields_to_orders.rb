class AddPaymentFieldsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :payment_status, :string
    add_column :orders, :payment_provider, :string
    add_column :orders, :payment_reference, :string
  end
end
