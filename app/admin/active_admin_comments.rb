# Disable ActiveAdmin comments completely
ActiveAdmin.register ActiveAdmin::Comment do
  # Disable all actions
  actions :none
  
  # Override index to redirect or show empty page
  controller do
    def index
      redirect_to admin_root_path, notice: 'Comentarios deshabilitados'
    end
    
    def create
      redirect_to admin_root_path, alert: 'Los comentarios están deshabilitados'
    end
    
    def show
      redirect_to admin_root_path, alert: 'Los comentarios están deshabilitados'
    end
    
    def destroy
      redirect_to admin_root_path, alert: 'Los comentarios están deshabilitados'
    end
  end
end
