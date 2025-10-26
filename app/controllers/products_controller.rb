class ProductsController < ApplicationController
  def index
    @products = Product.where(activo: true)

    # Filtrar por categoría si se especifica
    if params[:category].present?
      @category = params[:category]
      @products = @products.where(categoria: @category)

      # Filtrar por subcategoría si se especifica
      if params[:subcategory].present?
        # Convertir de formato URL (lentes-de-sol) a formato DB (lentes de sol)
        @subcategory = params[:subcategory].gsub("-", " ")
        @products = @products.where(subcategoria: @subcategory)
      end
    end

    @products = @products.order(created_at: :desc)
  end
end
