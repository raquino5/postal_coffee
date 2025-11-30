ActiveAdmin.register Product do
  permit_params :name,
                :description,
                :price,
                :on_sale,
                :is_active,
                :category_id,
                :image,
                tag_ids: []

  index do
    selectable_column
    id_column
    column "Image" do |product|
      if product.image.attached?
        image_tag product.image.variant(resize_to_fill: [ 60, 60 ]), style: "border-radius: 6px;"
      else
        "(no image)"
      end
    end
    column :name
    column :category
    column :price
    column :on_sale
    column :is_active
    column :created_at
    actions
  end

  filter :name
  filter :category
  filter :on_sale
  filter :is_active
  filter :price
  filter :created_at

  form do |f|
    f.semantic_errors

    f.inputs "Product Details" do
      f.input :name
      f.input :category
      f.input :price
      f.input :on_sale
      f.input :is_active
      f.input :description
      f.input :tags, as: :check_boxes, collection: Tag.all
      f.input :image, as: :file,
        hint: (f.object.image.attached? ? image_tag(f.object.image.variant(resize_to_fill: [ 100, 100 ])) : content_tag(:span, "No image uploaded yet"))
    end

    f.actions
  end

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

      row :tags do |product|
        product.tags.map(&:name).join(", ")
      end
      row :image do |product|
        if product.image.attached?
          image_tag product.image.variant(resize_to_fit: [ 400, 400 ])
        else
          "(no image)"
        end
      end
    end

    active_admin_comments
  end
end
