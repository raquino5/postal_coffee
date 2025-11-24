ActiveAdmin.register Product do
  # Allow these fields in the admin form
  permit_params :name,
                :description,
                :price,
                :on_sale,
                :is_active,
                :category_id,
                :image # only if you have an image column or Active Storage

  # List page in /admin/products
  index do
    selectable_column
    id_column
    column :name
    column :category
    column :price
    column :on_sale
    column :is_active
    column :created_at
    actions  # <- gives you View / Edit / Delete links
  end

  # Filters in sidebar
  filter :name
  filter :category
  filter :on_sale
  filter :is_active
  filter :price
  filter :created_at

  # New / Edit form
  form do |f|
    f.semantic_errors

    f.inputs "Product Details" do
      f.input :name
      f.input :category
      f.input :price
      f.input :on_sale
      f.input :is_active
      f.input :description

      # If you're using images:
      # - For Active Storage: has_one_attached :image in Product model
      #   and use file field here
      f.input :image, as: :file
    end

    f.actions
  end

  # Show page
  show do
    attributes_table do
      row :id
      row :name
      row :category
      row :price
      row :on_sale
      row :is_active
      row :description
      row :created_at
      row :updated_at

      # Show the image if attached/available
      if resource.respond_to?(:image) && resource.image.attached?
        row :image do |product|
          image_tag url_for(product.image), style: "max-width: 200px;"
        end
      end
    end

    active_admin_comments
  end
end
