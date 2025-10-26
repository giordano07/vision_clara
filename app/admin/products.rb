ActiveAdmin.register Product do
  permit_params :nombre, :descripcion, :precio, :activo, :imagen, :categoria, :subcategoria, imagenes: []

  # Habilitar todas las acciones incluyendo destroy
  actions :all

  # Use custom controller with CSRF protection
  controller do
    protect_from_forgery with: :exception

    before_action :ensure_csrf_token

    def update
      Rails.logger.info "=== UPDATE PRODUCT ==="
      Rails.logger.info "Imágenes ANTES de update: #{resource.imagenes.count}"

      # Obtener las nuevas imágenes SI las hay
      has_new_images = false
      new_images = []
      if params[:product] && params[:product][:imagenes].present?
        temp_images = Array(params[:product][:imagenes])
        # Verificar si hay al menos una imagen real (no solo strings vacíos)
        temp_images.each do |img|
          if img.present? && img.respond_to?(:read)
            has_new_images = true
            new_images << img
          end
        end
        Rails.logger.info "Nuevas imágenes a agregar: #{new_images.length}"
      end

      # Construir params sin imagenes para no tocar Active Storage
      safe_params = {}
      if params[:product]
        # Permitir solo los atributos que queremos actualizar y convertir a hash
        safe_params = params[:product].permit(:nombre, :descripcion, :precio, :activo, :categoria, :subcategoria).to_h
        Rails.logger.info "Params seguros: #{safe_params.keys.inspect}"
      end

      # Actualizar el recurso con los parámetros seguros (sin imágenes)
      # Usar update_columns para evitar callbacks de Active Storage
      if safe_params.any?
        resource.update_columns(safe_params)
      end

      Rails.logger.info "Imágenes DESPUÉS de update_columns: #{resource.imagenes.count}"

      # SOLO agregar las nuevas imágenes si realmente hay nuevas
      if has_new_images && new_images.any?
        new_images.each do |image|
          Rails.logger.info "Adjuntando nueva imagen..."
          resource.imagenes.attach(image)
        end
        Rails.logger.info "Total de imágenes después de agregar: #{resource.imagenes.count}"
      end

      redirect_to resource_path, notice: "Producto actualizado correctamente. Total de imágenes: #{resource.imagenes.count}"
    end

    private

    def ensure_csrf_token
      @csrf_token = form_authenticity_token
    end
  end

  # Acción personalizada para eliminar imágenes individuales
  member_action :remove_image, method: :delete do
    product = Product.find(params[:id])
    image_index = params[:image_index].to_i

    if product.imagenes.attached? && image_index < product.imagenes.count
      image_to_remove = product.imagenes[image_index]
      image_to_remove.purge
      redirect_to edit_admin_product_path(product), notice: "Imagen eliminada correctamente"
    else
      redirect_to edit_admin_product_path(product), alert: "No se pudo eliminar la imagen"
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
    # Mostrar información del producto si está siendo editado
    if f.object.persisted?
      div style: "background: #f8f9fa; padding: 1rem; border-radius: 0.5rem; margin-bottom: 1.5rem; border-left: 4px solid #2b3760;" do
        h3 style: "margin: 0 0 0.5rem 0; color: #2b3760; font-size: 1.2rem;" do
          "Editando: #{f.object.nombre}"
        end
        p style: "margin: 0; color: #666; font-size: 0.9rem;" do
          "Categoría: #{Product.categoria_nombre(f.object.categoria)} - #{f.object.subcategoria.titleize}"
        end
        if f.object.imagenes.attached? || f.object.imagen.attached?
          p style: "margin: 0.25rem 0 0 0; color: #666; font-size: 0.9rem;" do
            "Imágenes: #{f.object.imagenes.attached? ? f.object.imagenes.count : 1} #{f.object.imagenes.attached? ? 'imágenes' : 'imagen'}"
          end
        end
      end
    end

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
      f.input :imagenes, as: :file, input_html: { multiple: true, accept: "image/*", id: "product_imagenes" }, hint: "Puedes seleccionar múltiples archivos manteniendo presionada la tecla Ctrl (Cmd en Mac)"
    end

    # Contenedor para la vista previa de imágenes
    panel "Vista previa de imágenes seleccionadas" do
      para "Selecciona imágenes arriba y aparecerán aquí." do
      end
      div id: "preview-title", style: "display: none; font-weight: bold; color: #333; margin-bottom: 10px; padding-bottom: 8px; border-bottom: 1px solid #ddd;" do
        "Imágenes seleccionadas:"
      end
      div id: "images-preview", style: "display: none; flex-wrap: wrap; gap: 10px; padding: 15px; background: #f8f9fa; border-radius: 8px; border: 2px dashed #ddd;"
    end

    # Panel para mostrar imágenes actuales (si el producto ya existe)
    if f.object.persisted?
      panel "Imágenes actuales de este producto" do
        if f.object.imagenes.attached?
          content_tag :div, style: "display: flex; flex-wrap: wrap; gap: 10px;" do
            f.object.imagenes.each_with_index.map do |imagen, index|
              content_tag :div, style: "position: relative; display: inline-block;" do
                image_tag(imagen, style: "max-width: 200px; max-height: 200px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);") +
                content_tag(:button, "×",
                    onclick: "removeImageWithToken('#{remove_image_admin_product_path(f.object, image_index: index)}'); return false;",
                    style: "position: absolute; top: -8px; left: -8px; background: #dc3545; color: white; border: none; border-radius: 50%; width: 28px; height: 28px; font-size: 18px; cursor: pointer; box-shadow: 0 2px 6px rgba(0,0,0,0.3); font-weight: bold;",
                    title: "Eliminar esta imagen")
              end
            end.join.html_safe
          end
        elsif f.object.imagen.attached?
          content_tag :div do
            image_tag(f.object.imagen, style: "max-width: 300px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);") +
            content_tag(:p, "(Imagen antigua - se migrará automáticamente)", style: "color: #999; font-size: 12px; margin-top: 8px;")
          end
        else
          "Sin imágenes"
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
