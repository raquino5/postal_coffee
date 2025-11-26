class CreateProvinces < ActiveRecord::Migration[8.0]
  def change
    create_table :provinces do |t|
      t.string :name
      t.string :code
      t.decimal :gst, precision: 5, scale: 4
      t.decimal :pst, precision: 5, scale: 4
      t.decimal :hst, precision: 5, scale: 4

      t.timestamps
    end
  end
end
