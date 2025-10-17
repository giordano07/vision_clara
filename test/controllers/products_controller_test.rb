require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "debe obtener index" do
    get products_url
    assert_response :success
    assert_select "h1", text: /Productos/
  end

  test "debe filtrar productos por categoria usando ruta amigable" do
    get category_url("ninos")
    assert_response :success
    assert_select "h1", text: /Niños/
  end

  test "debe filtrar productos por categoria usando params" do
    get products_url, params: { category: "ninos" }
    assert_response :success
    assert_select "h1", text: /Niños/
  end

  test "debe filtrar productos por categoria y subcategoria usando ruta amigable" do
    get category_subcategory_url("ninos", "lentes-de-sol")
    assert_response :success
    assert_select "h1", text: /Niños/
    assert_select "h1", text: /Lentes De Sol/i
  end

  test "debe filtrar productos por categoria y subcategoria usando params" do
    get products_url, params: { category: "ninos", subcategory: "lentes-de-sol" }
    assert_response :success
    assert_select "h1", text: /Niños/
    assert_select "h1", text: /Lentes De Sol/i
  end

  test "debe mostrar botones de filtro de subcategoria cuando hay categoria" do
    get category_url("ninos")
    assert_response :success
    assert_select "a", text: /Lentes De Sol/i
    assert_select "a", text: /Lentes Recetados/i
  end

  test "debe mostrar productos cuando existen" do
    # Crear un producto de prueba
    product = Product.create!(
      nombre: "Test Lentes",
      descripcion: "Test",
      precio: 100,
      categoria: "ninos",
      subcategoria: "lentes de sol",
      activo: true
    )
    
    # Ver la subcategoría
    get category_subcategory_url("ninos", "lentes-de-sol")
    assert_response :success
    assert_select ".product-name", text: product.nombre
  end

  test "debe mostrar mensaje cuando no hay productos en subcategoria" do
    # Asegurarse de que no hay productos en esta subcategoría
    Product.where(categoria: "ninos", subcategoria: "lentes de sol").update_all(activo: false)
    
    get category_subcategory_url("ninos", "lentes-de-sol")
    assert_response :success
    assert_select ".empty-products p", text: /No hay productos disponibles/i
  end
  
  test "debe mostrar tarjetas de subcategorias cuando solo hay categoria" do
    get category_url("ninos")
    assert_response :success
    assert_select ".subcategory-card"
  end
end

