class CategoriesController < ApplicationController
  def show
    @category = Category.find(params[:id])
    @products = @category.products
                     .where(is_active: true)
                     .order(created_at: :desc)
                     .page(params[:page])
                     .per(9)
    # For showing category list in sidebar if you want
    @categories = Category.all
  end
end
