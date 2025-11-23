# app/controllers/pages_controller.rb
class PagesController < ApplicationController
  def show
    # slug will come from routes defaults: { slug: "about" } or { slug: "contact" }
    slug = params[:slug] || params[:id]
    @page = Page.find_by!(slug: slug)
  end
end
