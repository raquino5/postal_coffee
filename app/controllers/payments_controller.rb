class PaymentsController < ApplicationController
  def success
    session_id = params[:session_id]
    redirect_to root_path, alert: "Missing payment session." and return if session_id.blank?

    stripe_session = Stripe::Checkout::Session.retrieve(session_id)
    order = Order.find_by(payment_reference: stripe_session.id)

    if order.nil?
      redirect_to root_path, alert: "Order not found for this payment." and return
    end

    if stripe_session.payment_status == "paid"
      order.update(
        payment_status: "paid",
        status:         "paid"
      )
      session[:cart] = {}
      redirect_to order_path(order), notice: "Payment successful! Your order is confirmed."
    else
      order.update(payment_status: "failed")
      redirect_to cart_path, alert: "Payment not completed. Please try again."
    end
  end

  def cancel
    order = Order.find_by(id: params[:order_id])
    order&.update(payment_status: "failed")
    redirect_to cart_path, alert: "Payment was canceled."
  end
end
