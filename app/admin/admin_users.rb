ActiveAdmin.register AdminUser do
  permit_params :email, :password, :password_confirmation

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
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    
    # Botones de acciones personalizados y estilizados
    column "Acciones", class: "text-center" do |admin_user|
      content_tag :div, style: 'display: flex; gap: 8px; justify-content: center; align-items: center;' do
        link_to('👁️ Ver', admin_admin_user_path(admin_user), 
                class: 'btn btn-sm btn-info', 
                style: 'background: #17a2b8; color: white; padding: 6px 12px; border-radius: 4px; text-decoration: none; border: none; font-size: 12px; display: inline-flex; align-items: center; gap: 4px;',
                title: 'Ver detalles') +
        
        link_to('✏️ Editar', edit_admin_admin_user_path(admin_user), 
                class: 'btn btn-sm btn-warning', 
                style: 'background: #ffc107; color: #212529; padding: 6px 12px; border-radius: 4px; text-decoration: none; border: none; font-size: 12px; display: inline-flex; align-items: center; gap: 4px;',
                title: 'Editar usuario') +
        form_with(url: admin_admin_user_path(admin_user), method: :delete, local: true, style: 'display: inline;') do |f|
          f.submit '🗑️ Eliminar', 
                   class: 'btn btn-sm btn-danger', 
                   style: 'background: #dc3545; color: white; padding: 6px 12px; border-radius: 4px; border: none; font-size: 12px; display: inline-flex; align-items: center; gap: 4px; cursor: pointer;',
                   data: { confirm: '¿Estás seguro de que quieres eliminar este usuario administrador?' }
        end
        
      end
    end
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end
