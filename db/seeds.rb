require "faker"
require "httparty"
require "nokogiri"
require "csv"

# --- SAMPLE PRODUCT IMAGES (for CSV + scraped + fallback) ---
coffee_image_urls = [
  "https://images.pexels.com/photos/374885/pexels-photo-374885.jpeg",
  "https://images.pexels.com/photos/312418/pexels-photo-312418.jpeg",
  "https://images.pexels.com/photos/34085/pexels-photo.jpg",
  "https://images.pexels.com/photos/587741/pexels-photo-587741.jpeg"
]

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
category_names = ["House Blends", "Single Origin", "Decaf", "Gear"]

categories = category_names.map do |name|
  Category.find_or_create_by!(name: name)
end

puts "Ensured #{Category.count} categories"

# --- SEED FROM CSV DATASET (no Faker) ---
def seed_from_csv(categories, coffee_image_urls)
  csv_path = Rails.root.join("db", "coffee_seed_data.csv")

  return puts "CSV file not found at #{csv_path}" unless File.exist?(csv_path)

  puts "Importing products from CSV: #{csv_path}"

  CSV.foreach(csv_path, headers: true) do |row|
    name          = row["name"]&.strip
    description   = row["description"]&.strip
    price         = row["price"].to_f
    category_name = row["category"]&.strip
    image_url     = row["image_url"]&.strip # optional column in CSV

    next if name.blank? || description.blank? || price <= 0 || category_name.blank?

    category = Category.find_or_create_by!(name: category_name)

    # Avoid duplicates on re-running seeds
    Product.find_or_create_by!(name: name, description: description) do |product|
      product.price     = price
      product.category  = category
      product.on_sale   = false
      product.is_active = true
      product.image_url = image_url.presence || coffee_image_urls.sample
    end
  end
end

seed_from_csv(categories, coffee_image_urls)
puts "After CSV import: #{Product.count} products"

# --- SCRAPE PRODUCTS FROM 3RD-PARTY SITE ---
def scrape_products_into_categories(categories, coffee_image_urls)
  url = "https://webscraper.io/test-sites/e-commerce/static/computers/laptops"

  puts "Scraping products from #{url}..."
  response = HTTParty.get(url)
  doc = Nokogiri::HTML(response.body)

  i = 0
  created = 0

  doc.css(".col-sm-4.col-lg-4.col-md-4 .thumbnail").each do |card|
    name        = card.at_css(".title")&.text&.strip
    description = card.at_css(".description")&.text&.strip
    price_text  = card.at_css(".pull-right.price")&.text&.strip

    price = price_text.to_s.gsub(/[^\d\.]/, "").to_f

    next if name.blank? || description.blank? || price <= 0

    # Avoid duplicates with CSV or previous runs
    next if Product.exists?(name: name, description: description)

    category = categories[i % categories.size]
    i += 1

    Product.create!(
      name:        name,
      description: description,
      price:       price,
      category:    category,
      on_sale:     [true, false].sample,
      is_active:   true,
      image_url:   coffee_image_urls.sample
    )

    created += 1
  end

  puts "Scraped and created #{created} new products"
end

scrape_products_into_categories(categories, coffee_image_urls)
puts "After scraping: #{Product.count} products (CSV + scraped)"

# --- ENSURE MINIMUM 10 PRODUCTS (with images) ---
if Product.count < 10
  needed = 10 - Product.count
  puts "Only #{Product.count} products found; creating #{needed} filler products to reach 10."

  needed.times do
    Product.create!(
      name:        Faker::Coffee.blend_name,
      description: Faker::Coffee.notes,
      price:       rand(8.0..30.0).round(2),
      category:    categories.sample,
      on_sale:     [true, false].sample,
      is_active:   true,
      image_url:   coffee_image_urls.sample
    )
  end
end

puts "Final product count: #{Product.count} products"

# --- PROVINCES ---
provinces = [
  { name: "Manitoba",           code: "MB", gst: 0.05, pst: 0.07,    hst: 0.00 },
  { name: "Ontario",            code: "ON", gst: 0.00, pst: 0.00,    hst: 0.13 },
  { name: "British Columbia",   code: "BC", gst: 0.05, pst: 0.07,    hst: 0.00 },
  { name: "Quebec",             code: "QC", gst: 0.05, pst: 0.09975, hst: 0.00 },
  { name: "Saskatchewan",       code: "SK", gst: 0.05, pst: 0.06,    hst: 0.00 }
]

provinces.each do |attrs|
  province = Province.find_or_initialize_by(code: attrs[:code])
  province.update!(
    name: attrs[:name],
    gst:  attrs[:gst],
    pst:  attrs[:pst],
    hst:  attrs[:hst]
  )
end

puts "Seeded #{Province.count} provinces"
