require "faker"
require "httparty"
require "nokogiri"
require "csv"

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

# --- CATEGORIES (ensure your 4 exist) ---
category_names = ["House Blends", "Single Origin", "Decaf", "Gear"]

categories = category_names.map do |name|
  Category.find_or_create_by!(name: name)
end

puts "Ensured #{Category.count} categories"

# --- SEED FROM CSV DATASET (no Faker, real dataset) ---
def seed_from_csv(categories)
  csv_path = Rails.root.join("db", "coffee_seed_data.csv")

  return puts "CSV file not found at #{csv_path}" unless File.exist?(csv_path)

  puts "Importing products from CSV: #{csv_path}"

  CSV.foreach(csv_path, headers: true) do |row|
    name        = row["name"]&.strip
    description = row["description"]&.strip
    price       = row["price"].to_f
    category_name = row["category"]&.strip

    next if name.blank? || description.blank? || price <= 0 || category_name.blank?

    category = Category.find_or_create_by!(name: category_name)

    # Avoid duplicates on re-running seeds
    Product.find_or_create_by!(name: name, description: description) do |product|
      product.price     = price
      product.category  = category
      product.on_sale   = false
      product.is_active = true
    end
  end
end

seed_from_csv(categories)
puts "After CSV import: #{Product.count} products"

# --- SCRAPE PRODUCTS FROM 3RD-PARTY SITE ---
def scrape_products_into_categories(categories)
  url = "https://webscraper.io/test-sites/e-commerce/static/computers/laptops"

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
      is_active:   true
    )

    created += 1
  end

  puts "Scraped and created #{created} new products"
end

puts "Scraping products from webscraper.io..."
scrape_products_into_categories(categories)
puts "Final product count: #{Product.count} products (CSV + scraped)"
