# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
if Rails.env.development?
  AdminUser.find_or_create_by!(email: 'admin@example.com') do |u|
    u.password = 'password'
    u.password_confirmation = 'password'
  end
end

products_seed = [
  {
    nombre: "Armazón Clásico Negro",
    descripcion: "Armazón liviano, ideal para uso diario.",
    precio: 45000.00,
    activo: true
  },
  {
    nombre: "Lentes de Sol Polarizados",
    descripcion: "Protección UV400 con filtro polarizado.",
    precio: 62000.00,
    activo: true
  },
  {
    nombre: "Armazón Metálico Dorado",
    descripcion: "Diseño elegante y resistente.",
    precio: 73000.00,
    activo: true
  }
]

products_seed.each do |attrs|
  record = Product.find_or_initialize_by(nombre: attrs[:nombre])
  record.assign_attributes(attrs)
  record.save! if record.changed?
end

# Attach a sample image to products without one
sample_image_path = Rails.root.join('public', 'icon.png')
if File.exist?(sample_image_path)
  Product.find_each do |p|
    next if p.imagen.attached?
    p.imagen.attach(io: File.open(sample_image_path), filename: 'icon.png', content_type: 'image/png')
  end
end