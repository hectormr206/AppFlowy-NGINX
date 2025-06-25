    # Use an official Nginx runtime as a parent image
    FROM nginx:1.21-alpine
    
    # The `envsubst` command is included in the gettext package.
    RUN apk update && apk add gettext
    
    # Copy the Nginx config template and the startup script
    COPY default.conf.template /etc/nginx/conf.d/default.conf.template
    COPY start.sh /start.sh
    RUN chmod +x /start.sh
    
    # Expose port and set the startup command
    EXPOSE 80
    CMD ["/start.sh"]