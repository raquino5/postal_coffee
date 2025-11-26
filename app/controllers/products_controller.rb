class ProductsController < ApplicationController
  def index
    @filter = params[:filter]

    @products =
      case @filter
      when 'on_sale'
        Product.on_sale
      when 'new'
        Product.new_products
      when 'recently_updated'
        Product.recently_updated
      else
        Product.active
      end

    @products = @products.order(created_at: :desc).page(params[:page]).per(9)

    @categories = Category.all
  end

  def show
    @product = Product.find(params[:id])
  end

  def search
    @categories = Category.all
    @query = params[:q]
    @selected_category_id = params[:category_id]

    @products = Product.active

    if @selected_category_id.present?
      @products = @products.where(category_id: @selected_category_id)
    end

    if @query.present?
      like_query = "%#{@query}%"
      @products = @products.where(
        "name ILIKE :q OR description ILIKE :q",
        q: like_query
      )
    else
      @products = @products.none
    end

    @products = @products.order(created_at: :desc)
                         .page(params[:page])
                         .per(9)
  end
end
