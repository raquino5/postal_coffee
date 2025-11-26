# app/admin/customers.rb
ActiveAdmin.register Customer do
  includes :orders

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :email
    column :province
    column "Orders Count" do |customer|
      customer.orders.size
    end
    column "Total Spent" do |customer|
      total = customer.orders.sum(:total)
      number_to_currency(total)
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row :first_name
      row :last_name
      row :email
      row :address
      row :city
      row :province
      row :postal_code
      row :created_at
      row :updated_at
    end

    panel "Orders" do
      table_for customer.orders do
        column :id
        column :created_at
        column("Subtotal")    { |order| number_to_currency(order.subtotal) }
        column("Tax (GST+PST+HST)") do |order|
          tax_total = order.total_gst.to_f + order.total_pst.to_f + order.total_hst.to_f
          number_to_currency(tax_total)
        end
        column("Grand Total") { |order| number_to_currency(order.total) }
        column "Products" do |order|
          safe_join(
            order.order_items.map { |item| "#{item.product.name} (x#{item.quantity})" },
            tag.br
          )
        end
      end
    end
  end
end
