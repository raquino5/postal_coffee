ActiveAdmin.register Category do
  permit_params :name

  index do
    selectable_column
    id_column
    column :name
    column "Products count" do |category|
      category.products.count
    end
    column :created_at
    actions
  end

  filter :name
  filter :created_at

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs "Category Details" do
      f.input :name
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :created_at
      row :updated_at
    end

    panel "Products in this category" do
      table_for category.products do
        column :id
        column :name
        column :price
        column :on_sale
        column :is_active
      end
    end
  end
end
