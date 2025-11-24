require "faker"

# --- ADMIN USER ---
if Rails.env.development?
  AdminUser.find_or_create_by!(email: 'admin@postalcoffee.test') do |admin|
    admin.password = 'password'
    admin.password_confirmation = 'password'
  end
end

# --- STATIC PAGES ---
Page.find_or_create_by!(slug: "about") do |page|
  page.title = "About Us"
  page.body  = "Write your about page content here."
end

Page.find_or_create_by!(slug: "contact") do |page|
  page.title = "Contact Us"
  page.body  = "Write your contact page content here."
end

# --- CATEGORIES ---
categories = ["House Blends", "Single Origin", "Decaf", "Gear"]

categories.each do |name|
  Category.find_or_create_by!(name: name)
end

puts "Created #{Category.count} categories"

# --- PRODUCTS ---
target = 100
current = Product.count
needed  = target - current

if needed > 0
  needed.times do
    Product.create!(
      name: Faker::Coffee.blend_name,
      description: Faker::Coffee.notes,
      price: rand(8.0..30.0).round(2),
      on_sale: [true, false].sample,
      is_active: true,
      category: Category.all.sample
    )
  end
end

puts "Seeded #{Product.count} products"
