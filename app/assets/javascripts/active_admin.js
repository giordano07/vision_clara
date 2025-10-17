//= require active_admin/base

// Subcategorías para productos
const SUBCATEGORIAS = {
  'ninos': ['lentes de sol', 'lentes recetados'],
  'damas': ['lentes de sol', 'lentes recetados', 'clip-on'],
  'caballeros': ['lentes de sol', 'lentes recetados', 'clip-on']
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
});
