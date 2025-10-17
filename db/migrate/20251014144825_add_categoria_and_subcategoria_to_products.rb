class AddCategoriaAndSubcategoriaToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :categoria, :string
    add_column :products, :subcategoria, :string
  end
end
