class ProductsController < ApplicationController
  def index
    # Only show active products, newest first
    @products = Product.where(is_active: true).order(created_at: :desc)

    # For category filter sidebar
    @categories = Category.all
  end

  def show
    # Show one product
    @product = Product.find(params[:id])
  end
end
