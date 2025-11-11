# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.3.1
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# ===========================
# Instalar dependencias del sistema + Node.js + Yarn
# ===========================
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl gnupg2 build-essential git libjemalloc2 libvips postgresql-client pkg-config && \
    # Instalar Node.js 20.x
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    # Instalar Yarn globalmente
    npm install --global yarn && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

# ===========================
# Variables de entorno
# ===========================
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test"

# ===========================
# Etapa de build
# ===========================
FROM base AS build

# Copiar Gemfile y lock antes del resto del código
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache

# Instalar dependencias JS (si existen)
COPY package.json yarn.lock* ./
RUN if [ -f "package.json" ]; then \
      yarn install --frozen-lockfile || npm install; \
    else \
      echo "No package.json found — skipping JS install"; \
    fi

# Copiar aplicación
COPY . .

# Precompilar bootsnap para mejorar tiempos de arranque
RUN bundle exec bootsnap precompile app/ lib/

# ⚙️ Precompilar assets
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# ===========================
# Imagen final para producción
# ===========================
FROM base

# Copiar artefactos construidos
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Crear usuario no-root
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails

# Entrypoint y comando final
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Render expone el puerto 3000 por defecto
EXPOSE 3000

# Iniciar el servidor Rails
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
