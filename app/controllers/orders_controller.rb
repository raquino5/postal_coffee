class OrdersController < ApplicationController
  before_action :load_cart
  before_action :authenticate_user!, only: [:customer_orders]

  def new
    redirect_to cart_path, alert: "Your cart is empty." and return if @cart.blank?

    if user_signed_in?
      @customer = Customer.new(
        first_name: "",
        last_name: "",
        email: current_user.email,
        address: current_user.address,
        city: current_user.city,
        postal_code: current_user.postal_code,
        province: current_user.province&.code || current_user.province&.name
      )
    else
      @customer = Customer.new
    end
  end

  def create
    redirect_to cart_path, alert: "Your cart is empty." and return if @cart.blank?

    @customer = Customer.new(customer_params)

    if @customer.save
      build_order_for(@customer)

      if @order.save
        session[:cart] = {}
        redirect_to @order, notice: "Thank you! Your order has been placed."
      else
        flash.now[:alert] = "Could not save order."
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Please correct the errors below."
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  def customer_orders
    @orders = Order.joins(:customer)
                   .where(customers: { email: current_user.email })
                   .includes(order_items: :product)
                   .order(created_at: :desc)
  end

  private

  def load_cart
    @cart = session[:cart] || {}
  end

  def customer_params
    params.require(:customer).permit(
      :first_name, :last_name, :email,
      :address, :city, :province, :postal_code
    )
  end

  def build_order_for(customer)
    product_ids = @cart.keys
    products = Product.where(id: product_ids)

    subtotal = 0.0
    @order = customer.orders.build(status: "new")

    products.each do |product|
      quantity = @cart[product.id.to_s].to_i
      next if quantity <= 0

      line_price = product.price.to_f
      subtotal += line_price * quantity

      @order.order_items.build(
        product: product,
        quantity: quantity,
        price: line_price
      )
    end

    rates = TaxTable.for(customer.province)
    gst   = subtotal * rates[:gst]
    pst   = subtotal * rates[:pst]
    hst   = subtotal * rates[:hst]
    total = subtotal + gst + pst + hst

    @order.subtotal   = subtotal
    @order.total_gst  = gst
    @order.total_pst  = pst
    @order.total_hst  = hst
    @order.total      = total
  end
end
