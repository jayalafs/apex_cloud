FROM docker.io/library/tomcat:9.0.82-jdk17-temurin

# Definir directorio de trabajo
WORKDIR /opt/oracle/

# Instalar dependencias necesarias incluyendo nano, nc, ping y configurar la zona horaria
RUN apt-get update && apt-get install -y unzip curl nano netcat iputils-ping tzdata && \
    ln -fs /usr/share/zoneinfo/America/Asuncion /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    rm -rf /var/lib/apt/lists/*

# Crear estructura de directorios
RUN mkdir -p /opt/oracle/ords/config /opt/oracle/wallet /opt/oracle/apex /opt/oracle/sqlplus

# Copiar configuración de ORDS y Wallet
COPY ords_config/ /opt/oracle/ords/config/
COPY wallet/ /opt/oracle/wallet/

# Descargar y extraer ORDS
RUN curl -o ords-latest.zip https://download.oracle.com/otn_software/java/ords/ords-latest.zip && \
    unzip ords-latest.zip -d /opt/oracle/ords/ && \
    rm ords-latest.zip

# Descargar y extraer APEX
RUN curl -o apex-latest.zip https://download.oracle.com/otn_software/apex/apex-latest.zip && \
    unzip apex-latest.zip -d /opt/oracle/apex/ && \
    rm apex-latest.zip

# Instalacion de SqlPlus


# Modificar configuración de Tomcat para usar el puerto 8080
RUN sed -i 's/port="8080"/port="8080"/g' /usr/local/tomcat/conf/server.xml

# Copiar ORDS al directorio de despliegue de Tomcat
RUN cp /opt/oracle/ords/ords.war /usr/local/tomcat/webapps/

# Establecer permisos adecuados
RUN chmod -R 755 /opt/oracle/ords /opt/oracle/wallet /opt/oracle/apex

# Configurar el PATH de ORDS
RUN echo 'export PATH="$PATH:/opt/oracle/ords/bin"' >> ~/.bash_profile && \
    source ~/.bash_profile

# Exponer el puerto 8080 dentro del contenedor
EXPOSE 8080