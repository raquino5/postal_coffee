ActiveAdmin.register Product do
  # What an admin is allowed to submit in the form
  permit_params :category_id, :name, :description, :price, :on_sale, :is_active

  # List page in the admin (index)
  index do
    selectable_column
    id_column
    column :name
    column :category
    column :price
    column :on_sale
    column :is_active
    actions
  end

  # Optional filters on the side
  filter :name
  filter :category
  filter :price
  filter :on_sale
  filter :is_active

  # Form used for New / Edit product
  form do |f|
    f.semantic_errors
    f.inputs "Product Details" do
      f.input :category
      f.input :name
      f.input :description
      f.input :price
      f.input :on_sale
      f.input :is_active
      f.input :image, as: :file
    end
    f.actions   # Save / Cancel
  end

  # Optional: show page
  show do
    attributes_table do
      row :id
      row :name
      row :category
      row :description
      row :price
      row :on_sale
      row :is_active
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end
end
