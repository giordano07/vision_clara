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
  console.log('previewMultipleImages called');
  const previewContainer = document.getElementById('images-preview');
  const previewTitle = document.getElementById('preview-title');
  
  console.log('previewContainer:', previewContainer);
  console.log('previewTitle:', previewTitle);
  
  if (!previewContainer) {
    console.log('No preview container found!');
    return;
  }
  
  // Limpiar previsualizaciones anteriores
  previewContainer.innerHTML = '';
  
  if (input.files && input.files.length > 0) {
    console.log('Files selected:', input.files.length);
    previewContainer.style.display = 'flex';
    if (previewTitle) previewTitle.style.display = 'block';
    
    let imageCount = 0;
    Array.from(input.files).forEach(function(file) {
      if (file.type.match('image.*')) {
        console.log('Processing image:', file.name);
        imageCount++;
        const reader = new FileReader();
        
        reader.onload = function(e) {
          const img = document.createElement('img');
          img.src = e.target.result;
          img.style.cssText = 'max-width: 150px; max-height: 150px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); object-fit: cover;';
          previewContainer.appendChild(img);
          console.log('Image added to preview');
        };
        
        reader.readAsDataURL(file);
      }
    });
    
    console.log('Total images processed:', imageCount);
    
    // Si no hay imágenes, ocultar título
    if (imageCount === 0 && previewTitle) {
      previewTitle.style.display = 'none';
    }
  } else {
    console.log('No files selected');
    previewContainer.style.display = 'none';
    if (previewTitle) previewTitle.style.display = 'none';
  }
}

// Función para eliminar imagen con CSRF token
function removeImageWithToken(url) {
  if (!confirm('¿Estás seguro de que quieres eliminar esta imagen?')) {
    return;
  }

  const csrfToken = document.querySelector('meta[name="csrf-token"]');
  if (!csrfToken) {
    alert('Error: No se encontró el token CSRF');
    return;
  }

  const form = document.createElement('form');
  form.method = 'POST';
  form.action = url;
  form.style.display = 'none';

  const tokenInput = document.createElement('input');
  tokenInput.type = 'hidden';
  tokenInput.name = 'authenticity_token';
  tokenInput.value = csrfToken.getAttribute('content');
  form.appendChild(tokenInput);

  const methodInput = document.createElement('input');
  methodInput.type = 'hidden';
  methodInput.name = '_method';
  methodInput.value = 'DELETE';
  form.appendChild(methodInput);

  document.body.appendChild(form);
  form.submit();
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
  console.log('Looking for product_imagenes input:', imagenesInput);
  if (imagenesInput) {
    console.log('Setting up event listener for product_imagenes');
    imagenesInput.addEventListener('change', function() {
      console.log('Change event triggered on product_imagenes');
      previewMultipleImages(this);
    });
  } else {
    console.log('product_imagenes input not found!');
  }
});
