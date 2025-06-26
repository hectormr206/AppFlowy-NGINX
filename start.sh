#!/bin/sh

# This script dynamically finds the IPv4 addresses of the upstream services,
# substitutes them into the nginx template, and then starts the server.
# This is a robust workaround for environments with unreliable IPv6 routing
# and ensures we only use the first returned IP address.

# Function to resolve a hostname to a single IPv4 with retries.
# It only outputs the final IP address.
resolve_ipv4() {
    local hostname=$1
    local resolved_ip=""
    local retries=5
    local count=0

    # This loop will run until an IP is found or it runs out of retries.
    while [ -z "${resolved_ip}" ] && [ ${count} -lt ${retries} ]; do
        # We pipe to `head -n 1` to ensure we only get ONE IP address,
        # even if DNS returns multiple for load balancing.
        resolved_ip=$(dig +short A ${hostname} | head -n 1)
        if [ -z "${resolved_ip}" ]; then
            count=$((count+1))
            # Wait 2 seconds before retrying.
            sleep 2
        fi
    done

    # If no IP was found after all retries, exit with an error.
    if [ -z "${resolved_ip}" ]; then
        echo "CRITICAL: Could not resolve ${hostname} to an IPv4 address after ${retries} attempts."
        exit 1
    fi
    
    # This is the ONLY output of the function, ensuring the variable is clean.
    echo "${resolved_ip}"
}

echo "Forcing IPv4 resolution for upstream services..."
export APPFLOWY_BACKEND_HOST_IPV4=$(resolve_ipv4 ${APPFLOWY_BACKEND_HOST})
export GOTRUE_BACKEND_HOST_IPV4=$(resolve_ipv4 ${GOTRUE_BACKEND_HOST})
export MINIO_PRIVATE_HOST_IPV4=$(resolve_ipv4 ${MINIO_PRIVATE_HOST})
export MINIO_API_HOST_IPV4=$(resolve_ipv4 ${MINIO_API_HOST})
echo "All services resolved."

echo "Substituting environment variables..."
envsubst '${APPFLOWY_BACKEND_HOST_IPV4},${APPFLOWY_BACKEND_PORT},${GOTRUE_BACKEND_HOST_IPV4},${GOTRUE_BACKEND_PORT},${MINIO_PRIVATE_HOST_IPV4},${MINIO_PRIVATE_PORT},${MINIO_API_HOST_IPV4},${MINIO_API_PORT},${CORS_ORIGIN}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

echo "Starting Nginx..."
nginx -g 'daemon off;'