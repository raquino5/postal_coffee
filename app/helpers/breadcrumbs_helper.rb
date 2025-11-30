module BreadcrumbsHelper
  # Returns an array of [label, path] pairs
  # e.g. [["Home", "/"], ["House Blends", "/categories/1"], ["Midnight Roast", "/products/3"]]
  def breadcrumbs
    crumbs = []
    crumbs << ["Home", root_path]

    case
    # /products
    when controller_name == "products" && action_name == "index"
      crumbs << ["Products", products_path]

    # /categories/:id
    when controller_name == "categories" && action_name == "show" && defined?(@category) && @category
      # up to two levels: Home / Category
      crumbs << [@category.name, category_path(@category)]

    # /products/:id
    when controller_name == "products" && action_name == "show" && defined?(@product) && @product
      if @product.category
        # three levels: Home / Category / Product
        crumbs << [@product.category.name, category_path(@product.category)]
      end
      crumbs << [@product.name, product_path(@product)]
    end

    crumbs
  end
end
