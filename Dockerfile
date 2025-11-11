# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.3.1
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Instalar dependencias del sistema + Node + Yarn
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl gnupg2 build-essential git libjemalloc2 libvips postgresql-client pkg-config && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install --global yarn && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development test"

# ===========================
# Etapa de build
# ===========================
FROM base AS build

# Instalar gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache

# Instalar dependencias de SASS
COPY package.json yarn.lock* ./
RUN yarn install --frozen-lockfile || yarn install

# Copiar el resto del proyecto
COPY . .

# Precompilar bootsnap
RUN bundle exec bootsnap precompile app/ lib/

# Precompilar assets (SASS)
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# ===========================
# Imagen final
# ===========================
FROM base

COPY --from=build ${BUNDLE_PATH} ${BUNDLE_PATH}
COPY --from=build /rails /rails
COPY docker-entrypoint.sh /usr/bin/

RUN chmod +x /usr/bin/docker-entrypoint.sh && \
    groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

USER rails
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
