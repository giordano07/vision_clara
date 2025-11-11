#!/bin/bash
set -e

# Ejecutar migraciones
echo "Running database migrations..."
rails db:migrate RAILS_ENV=production

# Iniciar servidor
echo "Starting Rails server..."
exec rails server -b 0.0.0.0 -p $PORT -e production
