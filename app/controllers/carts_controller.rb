class CartsController < ApplicationController
  before_action :load_cart

  def show
    # @cart_items built from @cart
    product_ids = @cart.keys
    @products = Product.where(id: product_ids)

    @cart_items = @products.map do |product|
      {
        product: product,
        quantity: @cart[product.id.to_s],
        line_total: product.price.to_f * @cart[product.id.to_s].to_i
      }
    end

    @subtotal = @cart_items.sum { |item| item[:line_total] }
  end

  def add_item
    product_id = params[:product_id].to_s
    quantity   = params[:quantity].to_i
    quantity   = 1 if quantity <= 0

    @cart[product_id] ||= 0
    @cart[product_id] += quantity

    save_cart

    redirect_to cart_path(request.query_parameters), notice: "Item added to cart."
  end

  def update_item
    product_id = params[:product_id].to_s
    quantity   = params[:quantity].to_i

    if quantity <= 0
      @cart.delete(product_id)
    else
      @cart[product_id] = quantity
    end

    save_cart

    redirect_to cart_path, notice: "Cart updated."
  end

  def remove_item
    product_id = params[:product_id].to_s
    @cart.delete(product_id)

    save_cart

    redirect_to cart_path, notice: "Item removed from cart."
  end

  private

  def load_cart
    @cart = session[:cart] ||= {}
  end

  def save_cart
    session[:cart] = @cart
  end
end
