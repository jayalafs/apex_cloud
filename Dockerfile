FROM docker.io/library/tomcat:9.0.82-jdk11

# Definir directorios de trabajo
WORKDIR /opt/oracle/

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y unzip curl && rm -rf /var/lib/apt/lists/*

# Crear estructura de directorios
RUN mkdir -p /opt/oracle/ords/config /opt/oracle/wallet /opt/oracle/apex

# Copiar la configuración de ORDS y la Wallet de Oracle Cloud
COPY ords_config/ /opt/oracle/ords/config/
COPY wallet/ /opt/oracle/wallet/

# Extraer la Wallet de Oracle Cloud
RUN unzip /opt/oracle/wallet/Wallet_apex.zip -d /opt/oracle/wallet/ && \
    rm /opt/oracle/wallet/Wallet_apex.zip

# Descargar y extraer ORDS
RUN curl -o ords.zip https://download.oracle.com/otn_software/apex/ords-latest.zip && \
    unzip ords.zip -d /opt/oracle/ords/ && \
    rm ords.zip

# Descargar y extraer APEX
RUN curl -o apex.zip https://download.oracle.com/otn_software/apex/apex-latest.zip && \
    unzip apex.zip -d /opt/oracle/apex/ && \
    rm apex.zip

# Modificar configuración de Tomcat para usar el puerto 8282
RUN sed -i 's/port="8080"/port="8282"/g' /usr/local/tomcat/conf/server.xml

# Copiar ORDS a la carpeta webapps de Tomcat
RUN cp /opt/oracle/ords/ords.war /usr/local/tomcat/webapps/ || ls -l /opt/oracle/ords/

# Establecer permisos adecuados
RUN chmod -R 755 /opt/oracle/ords/ /opt/oracle/wallet/ /opt/oracle/apex/

# Exponer el puerto 8383
EXPOSE 8383

# Comando de inicio para Tomcat
CMD ["catalina.sh", "run"]