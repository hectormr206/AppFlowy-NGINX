    #!/bin/sh
    
    # This script substitutes environment variables in the nginx template
    # and then starts the nginx server.
    
    envsubst '${APPFLOWY_BACKEND_HOST},${APPFLOWY_BACKEND_PORT},${GOTRUE_BACKEND_HOST},${GOTRUE_BACKEND_PORT},${MINIO_PRIVATE_HOST},${MINIO_PRIVATE_PORT},${MINIO_API_HOST},${MINIO_API_PORT},${CORS_ORIGIN}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
    
    echo "Starting Nginx..."
    nginx -g 'daemon off;'