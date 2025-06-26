    # Use the official Nginx image from Docker Hub
    FROM nginx:1.21.6-alpine
    
    # Add bind-tools so we can use `dig` in the start script to force IPv4 resolution
    RUN apk add --no-cache bind-tools
    
    # Remove the default Nginx configuration
    RUN rm /etc/nginx/conf.d/default.conf
    
    # Copy the new configuration template and the start script
    COPY default.conf.template /etc/nginx/conf.d/default.conf.template
    COPY start.sh /start.sh
    
    # Make the start script executable
    RUN chmod +x /start.sh
    
    # Expose port and set the startup command
    EXPOSE 80
    CMD ["/start.sh"]