FROM tomcat:9.0.82-jdk11

# Variables de entorno para ORDS
ENV ORACLE_WALLET_DIR=/opt/oracle/wallet

# Directorio de trabajo
WORKDIR /opt/oracle

# Instalar herramientas necesarias
RUN apt-get update && apt-get install -y unzip curl && \
    rm -rf /var/lib/apt/lists/*

# Descargar y descomprimir ORDS (Última versión)
RUN curl -O https://download.oracle.com/otn_software/apex/apex-latest.zip && \
    unzip apex-latest.zip -d /opt/oracle/ords && \
    rm apex-latest.zip

# Configuración de ORDS (se montará como volumen)
COPY ords_config/ /opt/oracle/ords/config/

# Configurar Tomcat para usar el puerto 8282 en vez de 8080
RUN sed -i 's/port="8080"/port="8282"/g' /usr/local/tomcat/conf/server.xml

# Copiar ORDS a Tomcat
RUN cp /opt/oracle/ords/ords.war /usr/local/tomcat/webapps/

# Exponer el puerto 8282 para ORDS
EXPOSE 8282

# Comando para iniciar Tomcat
CMD ["catalina.sh", "run"]
