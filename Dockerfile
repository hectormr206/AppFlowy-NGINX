# Usamos la imagen oficial de Caddy, es ligera y segura.
FROM caddy:2-alpine

# Copiamos nuestro archivo de configuración al lugar correcto dentro del contenedor.
COPY Caddyfile /etc/caddy/Caddyfile