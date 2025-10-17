class Product < ApplicationRecord
  has_one_attached :imagen

  # Validaciones
  validates :categoria, presence: true
  validates :subcategoria, presence: true, if: -> { categoria.present? }

  # Constantes para categorías
  CATEGORIAS = ['ninos', 'damas', 'caballeros'].freeze
  SUBCATEGORIAS = {
    'ninos' => ['lentes de sol', 'lentes recetados'],
    'damas' => ['lentes de sol', 'lentes recetados', 'clip-on'],
    'caballeros' => ['lentes de sol', 'lentes recetados', 'clip-on']
  }.freeze
  
  # Nombres formateados para mostrar
  CATEGORIA_NOMBRES = {
    'ninos' => 'Niños',
    'damas' => 'Damas',
    'caballeros' => 'Caballeros'
  }.freeze

  # Método para obtener el nombre formateado de una categoría
  def self.categoria_nombre(categoria)
    CATEGORIA_NOMBRES[categoria] || categoria.titleize
  end

  # Atributos que pueden ser buscados con Ransack en ActiveAdmin
  def self.ransackable_attributes(auth_object = nil)
    ["nombre", "descripcion", "precio", "activo", "categoria", "subcategoria", "created_at", "updated_at"]
  end

  # Asociaciones que pueden ser buscadas con Ransack
  def self.ransackable_associations(auth_object = nil)
    []
  end
end
