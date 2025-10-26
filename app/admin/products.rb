ActiveAdmin.register Product do
  permit_params :nombre, :descripcion, :precio, :activo, :imagen, :categoria, :subcategoria

  # Habilitar todas las acciones incluyendo destroy
  actions :all

  # Use custom controller with CSRF protection
  controller do
    protect_from_forgery with: :exception

    before_action :ensure_csrf_token

    private

    def ensure_csrf_token
      @csrf_token = form_authenticity_token
    end
  end

  index do
    id_column
    column :nombre
    column :categoria do |product|
      Product.categoria_nombre(product.categoria)
    end
    column :subcategoria
    column :precio do |product|
      number_to_currency(product.precio, unit: "$", precision: 2)
    end
    column :activo do |product|
      product.activo? ? "✅ Activo" : "❌ Inactivo"
    end
    column :imagen do |product|
      if product.imagenes.attached?
        image_tag product.imagenes.first, style: "height: 50px; width: auto;"
      elsif product.imagen.attached?
        image_tag product.imagen, style: "height: 50px; width: auto;"
      else
        "Sin imagen"
      end
    end
    column :created_at

    # Botones de acciones personalizados y estilizados
    column "Acciones", class: "text-center" do |product|
      content_tag :div, style: "display: flex; gap: 8px; justify-content: center; align-items: center;" do
        link_to("\u{1F441}\uFE0F Ver", admin_product_path(product),
                class: "btn btn-sm btn-info",
                style: "background: #17a2b8; color: white; padding: 6px 12px; border-radius: 4px; text-decoration: none; border: none; font-size: 12px; display: inline-flex; align-items: center; gap: 4px;",
                title: "Ver detalles") +

        link_to("\u270F\uFE0F Editar", edit_admin_product_path(product),
                class: "btn btn-sm btn-warning",
                style: "background: #ffc107; color: #212529; padding: 6px 12px; border-radius: 4px; text-decoration: none; border: none; font-size: 12px; display: inline-flex; align-items: center; gap: 4px;",
                title: "Editar producto") +

        form_with(url: admin_product_path(product), method: :delete, local: true, style: "display: inline;") do |f|
          f.submit "\u{1F5D1}\uFE0F Eliminar",
                   class: "btn btn-sm btn-danger",
                   style: "background: #dc3545; color: white; padding: 6px 12px; border-radius: 4px; border: none; font-size: 12px; display: inline-flex; align-items: center; gap: 4px; cursor: pointer;",
                   data: { confirm: "\u00BFEst\u00E1s seguro de que quieres eliminar este producto?" }
        end
      end
    end
  end

  filter :nombre
  filter :categoria, as: :select, collection: Product::CATEGORIAS
  filter :subcategoria
  filter :activo
  filter :created_at

  form do |f|
    f.inputs "Detalles del Producto" do
      f.input :nombre
      f.input :descripcion
      f.input :categoria, as: :select, collection: Product::CATEGORIAS,
              include_blank: "Selecciona una categor\u00EDa",
              input_html: {
                id: "product_categoria",
                onchange: "updateSubcategorias(this.value)"
              }
      f.input :subcategoria, as: :select,
              collection: [],
              include_blank: "Primero selecciona una categor\u00EDa",
              input_html: {
                id: "product_subcategoria",
                'data-value': f.object.subcategoria
              }
      f.input :precio
      f.input :activo

      # Mostrar imagen actual si existe
      if f.object.persisted? && f.object.imagen.attached?
        li do
          label "Imagen actual"
          div style: "margin-top: 10px;" do
            begin
              image_tag f.object.imagen, style: "max-width: 200px; max-height: 200px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);"
            rescue => e
              "Error al cargar imagen: #{e.message}"
            end
          end
        end
      end

      # Input para nueva imagen
      f.input :imagen, as: :file, label: (f.object.persisted? && f.object.imagen.attached?) ? "Cambiar imagen" : "Imagen"

      # Preview de nueva imagen seleccionada
      li do
        label "Vista previa de nueva imagen"
        div id: "image-preview", style: "margin-top: 10px; display: none;" do
          img id: "preview-image", style: "max-width: 200px; max-height: 200px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);"
        end
      end
    end
    f.actions
  end

  show do
    attributes_table do
      row :nombre
      row :descripcion
      row :categoria do |product|
        Product.categoria_nombre(product.categoria)
      end
      row :subcategoria
      row :precio do |product|
        number_to_currency(product.precio, unit: "$", precision: 2)
      end
      row :activo do |product|
        product.activo? ? "✅ Activo" : "❌ Inactivo"
      end
      row :imagenes do |product|
        if product.imagenes.attached?
          content_tag :div, style: "display: flex; flex-wrap: wrap; gap: 10px;" do
            product.imagenes.map do |imagen|
              image_tag imagen, style: "max-width: 200px; max-height: 200px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);"
            end.join.html_safe
          end
        elsif product.imagen.attached?
          content_tag :div do
            image_tag(product.imagen, style: "max-width: 300px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);") +
            content_tag(:p, "(Imagen antigua - se migrará automáticamente)", style: "color: #999; font-size: 12px; margin-top: 8px;")
          end
        else
          "Sin imágenes"
        end
      end
      row :created_at
      row :updated_at
    end
  end
end
