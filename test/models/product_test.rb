require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "debe requerir categoria" do
    product = Product.new(
      nombre: "Test",
      descripcion: "Test",
      precio: 100,
      subcategoria: "lentes de sol"
    )
    assert_not product.valid?
    assert_includes product.errors[:categoria], "no puede estar en blanco"
  end

  test "debe requerir subcategoria si hay categoria" do
    product = Product.new(
      nombre: "Test",
      descripcion: "Test",
      precio: 100,
      categoria: "ninos"
    )
    assert_not product.valid?
    assert_includes product.errors[:subcategoria], "no puede estar en blanco"
  end

  test "debe ser valido con categoria y subcategoria" do
    product = Product.new(
      nombre: "Test",
      descripcion: "Test",
      precio: 100,
      categoria: "ninos",
      subcategoria: "lentes de sol",
      activo: true
    )
    assert product.valid?
  end

  test "debe tener constantes de categorias definidas" do
    assert_equal ['ninos', 'damas', 'caballeros'], Product::CATEGORIAS
  end

  test "debe tener subcategorias para cada categoria" do
    Product::CATEGORIAS.each do |categoria|
      assert Product::SUBCATEGORIAS.key?(categoria)
      assert_includes Product::SUBCATEGORIAS[categoria], 'lentes de sol'
      assert_includes Product::SUBCATEGORIAS[categoria], 'lentes recetados'
    end
  end

  test "debe formatear correctamente el nombre de las categorias" do
    assert_equal "Niños", Product.categoria_nombre("ninos")
    assert_equal "Damas", Product.categoria_nombre("damas")
    assert_equal "Caballeros", Product.categoria_nombre("caballeros")
  end
end
