class OrdersController < ApplicationController
  before_action :load_cart
  before_action :authenticate_user!, only: [ :customer_orders ]

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
    Rails.logger.info ">>> OrdersController#create called"
    redirect_to cart_path, alert: "Your cart is empty." and return if @cart.blank?

    @customer = Customer.new(customer_params)

    if @customer.save
      Rails.logger.info ">>> Customer saved: #{@customer.id}"
      build_order_for(@customer)

      @order.payment_provider = "stripe"
      @order.payment_status   = :pending # will cast to "pending"

      if @order.save
        Rails.logger.info ">>> Order saved: #{@order.id}, creating Stripe Checkout Session"

        begin
          checkout_session = Stripe::Checkout::Session.create(
            mode: "payment",
            payment_method_types: [ "card" ],
            line_items: stripe_line_items_for(@order),
            success_url: success_payments_url + "?session_id={CHECKOUT_SESSION_ID}",
            cancel_url:  cancel_payments_url(order_id: @order.id)
          )

          @order.update(payment_reference: checkout_session.id)
          Rails.logger.info ">>> Stripe session created: #{checkout_session.id}"

          # IMPORTANT: external redirect to Stripe
          redirect_to checkout_session.url, allow_other_host: true
        rescue Stripe::StripeError => e
          Rails.logger.error "Stripe error: #{e.message}"
          @order.update(payment_status: "failed")
          flash.now[:alert] = "There was a problem with the payment service: #{e.message}"
          render :new, status: :unprocessable_entity
        end
      else
        Rails.logger.info ">>> Order NOT saved, errors: #{@order.errors.full_messages}"
        flash.now[:alert] = "Could not save order."
        render :new, status: :unprocessable_entity
      end
    else
      Rails.logger.info ">>> Customer NOT saved, errors: #{@customer.errors.full_messages}"
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
    @order   = customer.orders.build(status: "new")

    products.each do |product|
      quantity = @cart[product.id.to_s].to_i
      next if quantity <= 0

      line_price = product.price.to_f
      subtotal  += line_price * quantity

      @order.order_items.build(
        product:  product,
        quantity: quantity,
        price:    line_price
      )
    end

    rates = TaxTable.for(customer.province)

    gst_rate = rates[:gst]
    pst_rate = rates[:pst]
    hst_rate = rates[:hst]

    gst   = subtotal * gst_rate
    pst   = subtotal * pst_rate
    hst   = subtotal * hst_rate
    total = subtotal + gst + pst + hst

    @order.subtotal   = subtotal
    @order.total_gst  = gst
    @order.total_pst  = pst
    @order.total_hst  = hst
    @order.total      = total

    @order.gst_rate   = gst_rate
    @order.pst_rate   = pst_rate
    @order.hst_rate   = hst_rate
  end

  def stripe_line_items_for(order)
    order.order_items.map do |item|
      {
        price_data: {
          currency: "cad",
          product_data: {
            name: item.product.name
          },
          unit_amount: (item.price.to_f * 100).to_i # cents
        },
        quantity: item.quantity
      }
    end
  end
end
