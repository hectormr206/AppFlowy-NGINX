#!/bin/sh

# Salimos inmediatamente si un comando falla.
set -e

# ==============================================================================
# Función para resolver la IP de un servicio.
# Es muy robusta y muestra mucha información de depuración.
# ==============================================================================
resolve_ipv4() {
    hostname_to_resolve=$1
    # Usamos nslookup, que es más común que dig.
    # Buscamos la línea "Address:", tomamos la IP, filtramos el DNS local y nos quedamos con la primera.
    ip=$(nslookup "$hostname_to_resolve" 2>/dev/null | awk '/^Address: / { print $2 }' | grep -v '127.0.0.11' | head -n 1)
    echo "$ip"
}

# ==============================================================================
# 1. Resolver las IPs
# ==============================================================================
echo "--- Iniciando NGINX con Script Robusto ---"

# ==============================================================================
# 2. Verificar las variables
# ==============================================================================
echo "--- PASO 2: Verificando las variables de entorno (deben contener una IP)..."
echo "---"
echo "APPFLOWY_BACKEND_HOST_IPV4='${APPFLOWY_BACKEND_HOST_IPV4}'"
echo "GOTRUE_BACKEND_HOST_IPV4='${GOTRUE_BACKEND_HOST_IPV4}'"
echo "MINIO_API_HOST_IPV4='${MINIO_API_HOST_IPV4}'"
echo ""

# ==============================================================================
# 3. Generar el archivo de configuración de NGINX
# ==============================================================================
echo "[INFO] Generando la configuración de NGINX..."
envsubst '${APPFLOWY_BACKEND_HOST_IPV4},${APPFLOWY_BACKEND_PORT},${GOTRUE_BACKEND_HOST_IPV4},${GOTRUE_BACKEND_PORT},${MINIO_API_HOST_IPV4},${MINIO_API_PORT},${CORS_ORIGIN}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
echo "[ÉXITO] Configuración de NGINX generada."
echo ""
echo "--- Configuración Generada ---"
cat /etc/nginx/conf.d/default.conf
echo "--------------------------"
echo ""

# ==============================================================================
# 4. Mostrar el archivo generado para inspección manual
# ==============================================================================
echo "---"
echo "PASO 4: Contenido del archivo '/etc/nginx/conf.d/default.conf' generado:"
echo "---"
cat /etc/nginx/conf.d/default.conf
echo "---"
echo ""

# ==============================================================================
# 5. Probar la configuración de NGINX
# ==============================================================================
echo "[INFO] Probando la configuración de NGINX..."
nginx -t
echo "[INFO] Iniciando NGINX..."
nginx -g 'daemon off;'