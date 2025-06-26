#!/bin/sh

# This script dynamically finds the IPv4 addresses of the upstream services,
# substitutes them into the nginx template, and then starts the server.
# This is a robust workaround for environments with unreliable IPv6 routing.

echo "Forcing IPv4 resolution for upstream services..."

# Use `dig +short A` to get only the IPv4 address (A record).
export APPFLOWY_BACKEND_HOST_IPV4=$(dig +short A ${APPFLOWY_BACKEND_HOST})
export GOTRUE_BACKEND_HOST_IPV4=$(dig +short A ${GOTRUE_BACKEND_HOST})
export MINIO_PRIVATE_HOST_IPV4=$(dig +short A ${MINIO_PRIVATE_HOST})
export MINIO_API_HOST_IPV4=$(dig +short A ${MINIO_API_HOST})

echo "Substituting environment variables..."
envsubst '${APPFLOWY_BACKEND_HOST_IPV4},${APPFLOWY_BACKEND_PORT},${GOTRUE_BACKEND_HOST_IPV4},${GOTRUE_BACKEND_PORT},${MINIO_PRIVATE_HOST_IPV4},${MINIO_PRIVATE_PORT},${MINIO_API_HOST_IPV4},${MINIO_API_PORT},${CORS_ORIGIN}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

echo "Starting Nginx..."
nginx -g 'daemon off;'