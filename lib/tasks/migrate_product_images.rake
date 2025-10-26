namespace :products do
  desc "Migrar imágenes antiguas (imagen) al nuevo sistema (imagenes)"
  task migrate_images: :environment do
    puts "Iniciando migración de imágenes de productos..."

    migrated_count = 0
    skipped_count = 0
    error_count = 0

    Product.find_each do |product|
      begin
        # Si el producto ya tiene imágenes en el nuevo sistema, omitirlo
        if product.imagenes.attached?
          puts "  ✓ Producto ##{product.id} (#{product.nombre}) ya tiene imágenes nuevas, omitiendo..."
          skipped_count += 1
          next
        end

        # Si el producto tiene imagen en el sistema antiguo, migrarla
        if product.imagen.attached?
          puts "  → Migrando imagen del producto ##{product.id} (#{product.nombre})..."

          # Adjuntar la imagen antigua al nuevo sistema
          product.imagenes.attach(product.imagen.blob)

          puts "    ✓ Imagen migrada exitosamente"
          migrated_count += 1
        else
          puts "  - Producto ##{product.id} (#{product.nombre}) no tiene imagen, omitiendo..."
          skipped_count += 1
        end
      rescue => e
        puts "    ✗ Error al migrar producto ##{product.id}: #{e.message}"
        error_count += 1
      end
    end

    puts "\n" + "="*50
    puts "Migración completada:"
    puts "  Productos migrados: #{migrated_count}"
    puts "  Productos omitidos: #{skipped_count}"
    puts "  Errores: #{error_count}"
    puts "="*50

    if migrated_count > 0
      puts "\n⚠️  Nota: Las imágenes antiguas se mantienen en el sistema."
      puts "Si deseas eliminarlas después de verificar que todo funciona correctamente,"
      puts "puedes crear una tarea adicional para purgar las imágenes antiguas."
    end
  end

  desc "Limpiar imágenes antiguas (imagen) después de migrar"
  task cleanup_old_images: :environment do
    puts "⚠️  ADVERTENCIA: Esta tarea eliminará todas las imágenes antiguas (imagen)"
    puts "Asegúrate de haber ejecutado 'rake products:migrate_images' primero"
    puts "y de haber verificado que las nuevas imágenes funcionan correctamente."
    puts "\n¿Continuar? (escribe 'SI' para confirmar)"

    # En producción, esto debe ser confirmado manualmente
    # Por ahora, solo mostramos un mensaje informativo
    puts "\nPara ejecutar esta limpieza, agrega el siguiente código a esta tarea:"
    puts <<-CODE
    Product.find_each do |product|
      if product.imagenes.attached? && product.imagen.attached?
        product.imagen.purge
        puts "  ✓ Imagen antigua eliminada del producto #\#{product.id}"
      end
    end
    CODE
  end
end
