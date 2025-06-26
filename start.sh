#!/bin/sh

# Salimos inmediatamente si un comando falla.
set -e

# ==============================================================================
# Función para resolver la IP de un servicio.
# Es muy robusta y muestra mucha información de depuración.
# ==============================================================================
resolve_ipv4() {
    hostname=$1
    echo "[debug] Resolviendo IPv4 para '$hostname'..." >&2

    # Usamos 'dig' para obtener la IP, tomamos la primera y la limpiamos
    # de cualquier espacio en blanco o carácter invisible.
    ip=$(dig +short A "$hostname" | head -n 1 | tr -d ' \r\n')

    if [ -z "$ip" ]; then
        echo "[error] No se pudo resolver la IP para '$hostname'. 'dig' no devolvió nada." >&2
        exit 1
    fi

    echo "[debug] Resuelto '$hostname' -> '$ip'" >&2
    # La función solo devuelve la IP limpia.
    echo "$ip"
}

# ==============================================================================
# 1. Resolver las IPs
# ==============================================================================
echo "---"
echo "PASO 1: Obteniendo las direcciones IP de los servicios..."
echo "---"
export APPFLOWY_BACKEND_HOST_IPV4=$(resolve_ipv4 ${APPFLOWY_BACKEND_HOST})
export GOTRUE_BACKEND_HOST_IPV4=$(resolve_ipv4 ${GOTRUE_BACKEND_HOST})
export MINIO_API_HOST_IPV4=$(resolve_ipv4 ${MINIO_API_HOST})
echo "Direcciones IP obtenidas con éxito."
echo ""

# ==============================================================================
# 2. Verificar las variables
# ==============================================================================
echo "---"
echo "PASO 2: Verificando las variables de entorno (deben contener una IP)..."
echo "---"
echo "APPFLOWY_BACKEND_HOST_IPV4='${APPFLOWY_BACKEND_HOST_IPV4}'"
echo "GOTRUE_BACKEND_HOST_IPV4='${GOTRUE_BACKEND_HOST_IPV4}'"
echo "MINIO_API_HOST_IPV4='${MINIO_API_HOST_IPV4}'"
echo ""

# ==============================================================================
# 3. Generar el archivo de configuración de NGINX
# ==============================================================================
echo "---"
echo "PASO 3: Creando el archivo de configuración de NGINX..."
echo "---"
envsubst '${APPFLOWY_BACKEND_HOST_IPV4},${APPFLOWY_BACKEND_PORT},${GOTRUE_BACKEND_HOST_IPV4},${GOTRUE_BACKEND_PORT},${MINIO_API_HOST_IPV4},${MINIO_API_PORT},${CORS_ORIGIN}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
echo "Archivo de configuración generado."
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
echo "---"
echo "PASO 5: Pidiéndole a NGINX que verifique el archivo de configuración..."
echo "---"
# 'nginx -t' prueba la configuración. Si hay un error, el script fallará aquí.
nginx -t
echo "¡Prueba de configuración de NGINX exitosa!"
echo ""

# ==============================================================================
# 6. Iniciar NGINX
# ==============================================================================
echo "---"
echo "PASO 6: Iniciando el servidor NGINX..."
echo "---"
nginx -g 'daemon off;'