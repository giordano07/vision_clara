require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess::FixtureFile
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
    assert_equal [ "ninos", "damas", "caballeros" ], Product::CATEGORIAS
  end

  test "debe tener subcategorias para cada categoria" do
    Product::CATEGORIAS.each do |categoria|
      assert Product::SUBCATEGORIAS.key?(categoria)
      assert_includes Product::SUBCATEGORIAS[categoria], "lentes de sol"
      assert_includes Product::SUBCATEGORIAS[categoria], "lentes recetados"
    end
  end

  test "debe formatear correctamente el nombre de las categorias" do
    assert_equal "Niños", Product.categoria_nombre("ninos")
    assert_equal "Damas", Product.categoria_nombre("damas")
    assert_equal "Caballeros", Product.categoria_nombre("caballeros")
  end

  test "debe permitir adjuntar múltiples imágenes" do
    product = Product.create!(
      nombre: "Test Product",
      descripcion: "Test Description",
      precio: 100,
      categoria: "ninos",
      subcategoria: "lentes de sol",
      activo: true
    )

    # Crear imágenes de prueba
    image1 = fixture_file_upload("test_image.jpg", "image/jpeg")
    image2 = fixture_file_upload("test_image.jpg", "image/jpeg")

    product.imagenes.attach(image1)
    product.imagenes.attach(image2)

    assert product.imagenes.attached?
    assert_equal 2, product.imagenes.count
  end

  test "debe mantener compatibilidad con imagen singular antigua" do
    product = Product.create!(
      nombre: "Test Product",
      descripcion: "Test Description",
      precio: 100,
      categoria: "ninos",
      subcategoria: "lentes de sol",
      activo: true
    )

    # Adjuntar una imagen al sistema antiguo
    image = fixture_file_upload("test_image.jpg", "image/jpeg")
    product.imagen.attach(image)

    assert product.imagen.attached?
  end

  test "debe poder tener tanto imagen singular como múltiples imágenes" do
    product = Product.create!(
      nombre: "Test Product",
      descripcion: "Test Description",
      precio: 100,
      categoria: "ninos",
      subcategoria: "lentes de sol",
      activo: true
    )

    # Adjuntar imagen al sistema antiguo
    old_image = fixture_file_upload("test_image.jpg", "image/jpeg")
    product.imagen.attach(old_image)

    # Adjuntar imágenes al sistema nuevo
    new_image1 = fixture_file_upload("test_image.jpg", "image/jpeg")
    new_image2 = fixture_file_upload("test_image.jpg", "image/jpeg")
    product.imagenes.attach([ new_image1, new_image2 ])

    assert product.imagen.attached?
    assert product.imagenes.attached?
    assert_equal 2, product.imagenes.count
  end
end
