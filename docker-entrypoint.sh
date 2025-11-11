#!/bin/bash
set -e

# Ejecutar migraciones
echo "Running database migrations..."
bin/rails db:migrate RAILS_ENV=production

# Iniciar servidor
echo "Starting Rails server..."
exec bin/rails server -b 0.0.0.0 -p "${PORT:-3000}" -e production
