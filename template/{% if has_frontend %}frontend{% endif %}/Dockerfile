# syntax=docker/dockerfile:1
FROM node:24-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY . .
RUN npm run build

# Caddy sirve el frontend y hace de proxy hacia el backend, con HTTPS automático
FROM caddy:2-alpine
COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=build /app/dist /srv
# El binario de caddy ya trae cap_net_bind_service: puede usar 80/443 sin ser root
RUN addgroup -S web && adduser -S -G web web \
    && mkdir -p /data /config && chown -R web:web /data /config /srv
USER web
