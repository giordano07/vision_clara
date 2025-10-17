ActiveAdmin.register Budget do
  menu priority: 2, label: "Presupuestos"

  permit_params :nombre, :telefono, :dni, :email, :motivo, :preferencia_contacto, :horario_preferido, :tipo_lentes, :imagen

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
    column :telefono
    column :email
    column :tipo_lentes
    column :preferencia_contacto
    column "Receta" do |budget|
      if budget.imagen.attached?
        "✅ Con receta"
      else
        "❌ Sin receta"
      end
    end
    column :created_at, label: "Fecha de solicitud"
    
    # Botones de acciones personalizados y estilizados
    column "Acciones", class: "text-center" do |budget|
      content_tag :div, style: 'display: flex; gap: 8px; justify-content: center; align-items: center;' do
        link_to('👁️ Ver', admin_budget_path(budget), 
                class: 'btn btn-sm btn-info', 
                style: 'background: #17a2b8; color: white; padding: 6px 12px; border-radius: 4px; text-decoration: none; border: none; font-size: 12px; display: inline-flex; align-items: center; gap: 4px;',
                title: 'Ver detalles') +
        
        link_to('✏️ Editar', edit_admin_budget_path(budget), 
                class: 'btn btn-sm btn-warning', 
                style: 'background: #ffc107; color: #212529; padding: 6px 12px; border-radius: 4px; text-decoration: none; border: none; font-size: 12px; display: inline-flex; align-items: center; gap: 4px;',
                title: 'Editar presupuesto') +
        form_with(url: admin_budget_path(budget), method: :delete, local: true, style: 'display: inline;') do |f|
          f.submit '🗑️ Eliminar', 
                   class: 'btn btn-sm btn-danger', 
                   style: 'background: #dc3545; color: white; padding: 6px 12px; border-radius: 4px; border: none; font-size: 12px; display: inline-flex; align-items: center; gap: 4px; cursor: pointer;',
                   data: { confirm: '¿Estás seguro de que quieres eliminar este presupuesto?' }
        end
        
      end
    end
  end

  filter :nombre
  filter :email
  filter :telefono
  filter :tipo_lentes, as: :select, collection: Budget::TIPOS_LENTES
  filter :preferencia_contacto, as: :select, collection: Budget::PREFERENCIAS_CONTACTO
  filter :created_at, label: "Fecha de solicitud"

  show do
    attributes_table do
      row :id
      row :nombre
      row :telefono
      row :dni
      row :email
      row :tipo_lentes
      row :motivo do |budget|
        budget.motivo.present? ? simple_format(budget.motivo) : "No especificado"
      end
      row :preferencia_contacto
      row :horario_preferido
      row "Foto de Receta" do |budget|
        if budget.imagen.attached?
          image_tag budget.imagen, style: 'max-width: 200px; max-height: 200px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);'
        else
          "No se adjuntó foto de receta"
        end
      end
      row "Fecha de solicitud" do |budget|
        budget.created_at.strftime("%d/%m/%Y %H:%M")
      end
      row "Última actualización" do |budget|
        budget.updated_at.strftime("%d/%m/%Y %H:%M")
      end
    end
  end

  form do |f|
    f.inputs "Datos del Cliente" do
      f.input :nombre
      f.input :telefono
      f.input :dni
      f.input :email
    end

    f.inputs "Detalles de la Solicitud" do
      f.input :tipo_lentes, as: :select, collection: Budget::TIPOS_LENTES, include_blank: "Seleccione una opción"
      f.input :motivo, as: :text, input_html: { rows: 5 }
      f.input :preferencia_contacto, as: :select, collection: Budget::PREFERENCIAS_CONTACTO, include_blank: "Seleccione una opción"
      f.input :horario_preferido, as: :select, collection: Budget::HORARIOS_PREFERIDOS, include_blank: "Seleccione una opción"
      f.input :imagen, as: :file
    end

    f.actions
  end
end
