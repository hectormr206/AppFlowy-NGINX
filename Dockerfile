    # Usamos la imagen oficial de Nginx
    FROM nginx:latest

    # Copiamos nuestra configuración plantilla al lugar correcto dentro de la imagen
    COPY nginx.conf.template /etc/nginx/templates/default.conf.template