#!/bin/sh

# This script dynamically finds the IPv4 addresses of the upstream services,
# substitutes them into the nginx template, and then starts the server.
# This is a robust workaround for environments with unreliable IPv6 routing.

# Function to resolve a hostname to IPv4 with retries
resolve_ipv4() {
    local hostname=$1
    local resolved_ip=""
    local retries=5
    local count=0

    echo "Resolving ${hostname}..."
    while [ -z "${resolved_ip}" ] && [ ${count} -lt ${retries} ]; do
        resolved_ip=$(dig +short A ${hostname})
        if [ -z "${resolved_ip}" ]; then
            count=$((count+1))
            echo "Attempt ${count}/${retries} failed for ${hostname}. Retrying in 2 seconds..."
            sleep 2
        fi
    done

    if [ -z "${resolved_ip}" ]; then
        echo "CRITICAL: Could not resolve ${hostname} to an IPv4 address after ${retries} attempts."
        exit 1
    fi
    echo "Resolved ${hostname} to ${resolved_ip}"
    echo "${resolved_ip}"
}


export APPFLOWY_BACKEND_HOST_IPV4=$(resolve_ipv4 ${APPFLOWY_BACKEND_HOST})
export GOTRUE_BACKEND_HOST_IPV4=$(resolve_ipv4 ${GOTRUE_BACKEND_HOST})
export MINIO_PRIVATE_HOST_IPV4=$(resolve_ipv4 ${MINIO_PRIVATE_HOST})
export MINIO_API_HOST_IPV4=$(resolve_ipv4 ${MINIO_API_HOST})


echo "Substituting environment variables..."
envsubst '${APPFLOWY_BACKEND_HOST_IPV4},${APPFLOWY_BACKEND_PORT},${GOTRUE_BACKEND_HOST_IPV4},${GOTRUE_BACKEND_PORT},${MINIO_PRIVATE_HOST_IPV4},${MINIO_PRIVATE_PORT},${MINIO_API_HOST_IPV4},${MINIO_API_PORT},${CORS_ORIGIN}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf


echo "Starting Nginx..."
nginx -g 'daemon off;'