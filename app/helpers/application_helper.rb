module ApplicationHelper
  def cart_count
    session[:cart]&.values&.sum.to_i
  end
end
