class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.decimal :subtotal,    precision: 10, scale: 2
      t.decimal :total_gst,    precision: 10, scale: 2
      t.decimal :total_pst,    precision: 10, scale: 2
      t.decimal :total_hst,    precision: 10, scale: 2
      t.decimal :total,    precision: 10, scale: 2
      t.string :status

      t.timestamps
    end
  end
end
