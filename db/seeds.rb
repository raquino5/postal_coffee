# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
AdminUser.create!(email: 'admin@postalcoffee.test', password: 'password', password_confirmation: 'password') if Rails.env.development?

Page.find_or_create_by!(slug: "about") do |page|
  page.title = "About Us"
  page.body  = "Write your about page content here."
end

Page.find_or_create_by!(slug: "contact") do |page|
  page.title = "Contact Us"
  page.body  = "Write your contact page content here."
end