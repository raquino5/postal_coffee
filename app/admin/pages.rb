# app/admin/pages.rb
ActiveAdmin.register Page do
  # Allow these fields in the admin form
  permit_params :title, :slug, :body

  index do
    selectable_column
    id_column
    column :title
    column :slug
    column :updated_at
    actions
  end

  filter :title
  filter :slug

  form do |f|
    f.inputs "Page Content" do
      f.input :title
      f.input :slug
      f.input :body
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :slug
      row :body
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end
end
