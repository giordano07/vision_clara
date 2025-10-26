//= require active_admin/base

// Subcategorías para productos
const SUBCATEGORIAS = {
  'ninos': ['lentes de sol', 'lentes recetados'],
  'damas': ['lentes de sol', 'lentes recetados', 'clip on'],
  'caballeros': ['lentes de sol', 'lentes recetados', 'clip on']
};

// Nombres formateados de categorías
const CATEGORIA_NOMBRES = {
  'ninos': 'Niños',
  'damas': 'Damas',
  'caballeros': 'Caballeros'
};

function updateSubcategorias(categoria) {
  const subcategoriaSelect = document.getElementById('product_subcategoria');
  if (!subcategoriaSelect) return;
  
  // Limpiar opciones actuales
  subcategoriaSelect.innerHTML = '<option value="">Selecciona una subcategoría</option>';
  
  // Agregar nuevas opciones basadas en la categoría seleccionada
  if (categoria && SUBCATEGORIAS[categoria]) {
    SUBCATEGORIAS[categoria].forEach(function(subcategoria) {
      const option = document.createElement('option');
      option.value = subcategoria;
      option.textContent = subcategoria.charAt(0).toUpperCase() + subcategoria.slice(1);
      subcategoriaSelect.appendChild(option);
    });
  }
}

// Función para previsualizar múltiples imágenes
function previewMultipleImages(input) {
  const previewContainer = document.getElementById('images-preview');
  if (!previewContainer) return;
  
  // Limpiar previsualizaciones anteriores
  previewContainer.innerHTML = '';
  
  if (input.files && input.files.length > 0) {
    previewContainer.style.display = 'flex';
    
    Array.from(input.files).forEach(function(file) {
      if (file.type.match('image.*')) {
        const reader = new FileReader();
        
        reader.onload = function(e) {
          const img = document.createElement('img');
          img.src = e.target.result;
          img.style.cssText = 'max-width: 150px; max-height: 150px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);';
          previewContainer.appendChild(img);
        };
        
        reader.readAsDataURL(file);
      }
    });
  } else {
    previewContainer.style.display = 'none';
  }
}

// Inicializar subcategorías cuando se carga la página
document.addEventListener('DOMContentLoaded', function() {
  const categoriaSelect = document.getElementById('product_categoria');
  if (categoriaSelect && categoriaSelect.value) {
    updateSubcategorias(categoriaSelect.value);
    
    // Si hay una subcategoría preseleccionada, seleccionarla
    const subcategoriaSelect = document.getElementById('product_subcategoria');
    const currentSubcategoria = subcategoriaSelect.dataset.value;
    if (currentSubcategoria) {
      subcategoriaSelect.value = currentSubcategoria;
    }
  }
  
  // Agregar event listener para el input de múltiples imágenes
  const imagenesInput = document.getElementById('product_imagenes');
  if (imagenesInput) {
    imagenesInput.addEventListener('change', function() {
      previewMultipleImages(this);
    });
  }
});
