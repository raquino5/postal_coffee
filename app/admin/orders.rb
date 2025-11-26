# app/admin/orders.rb
ActiveAdmin.register Order do
  actions :all, except: [:new, :destroy]

  permit_params :status

  includes :customer, order_items: :product

  index do
    selectable_column
    id_column
    column :created_at
    column :status
    column :payment_status
    column "Customer" do |order|
      customer = order.customer
      if customer
        "#{customer.first_name} #{customer.last_name} (#{customer.email})"
      else
        "Unknown customer"
      end
    end

    column "Subtotal" do |order|
      number_to_currency(order.subtotal)
    end

    column "GST" do |order|
      number_to_currency(order.total_gst)
    end

    column "PST" do |order|
      number_to_currency(order.total_pst)
    end

    column "HST" do |order|
      number_to_currency(order.total_hst)
    end

    column "Grand Total" do |order|
      number_to_currency(order.total)
    end

    column "Products" do |order|
      safe_join(
        order.order_items.map { |item| "#{item.product.name} (x#{item.quantity})" },
        tag.br
      )
    end

    actions
  end

  show do
    attributes_table do
      row :id
      row :created_at
      row :updated_at
      row :status
      row :payment_status
      row :customer do |order|
        c = order.customer
        if c
          "#{c.first_name} #{c.last_name} (#{c.email})"
        else
          "Unknown customer"
        end
      end
      row("Subtotal")     { number_to_currency(order.subtotal) }
      row("GST")          { number_to_currency(order.total_gst) }
      row("PST")          { number_to_currency(order.total_pst) }
      row("HST")          { number_to_currency(order.total_hst) }
      row("Grand Total")  { number_to_currency(order.total) }
    end

    panel "Line Items" do
      table_for order.order_items do
        column :product
        column("Price")      { |item| number_to_currency(item.price) }
        column :quantity
        column("Line Total") { |item| number_to_currency(item.line_total) }
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :status, as: :select, collection: Order.statuses.keys
    end
    f.actions
  end

  action_item :mark_shipped, only: :show, if: -> { resource.paid? && !resource.shipped? } do
    link_to "Mark as shipped", mark_shipped_admin_order_path(resource), method: :put
  end

  member_action :mark_shipped, method: :put do
    resource.update(status: "shipped")
    redirect_to resource_path, notice: "Order marked as shipped."
  end

  filter :id
  filter :status
  filter :payment_status
  filter :created_at
  filter :customer_email_cont, as: :string, label: "Customer email"

  controller do
    def scoped_collection
      super.includes(:customer, order_items: :product)
    end
  end
end
