#!/bin/bash

echo "Iniciando o processo de instalação..."

# Instalar Doxygen 1.9.10
echo "Instalando Doxygen..."
wget https://github.com/doxygen/doxygen/releases/download/Release_1_9_10/doxygen-1.9.10.linux.bin.tar.gz
tar -xvf doxygen-1.9.10.linux.bin.tar.gz
mv doxygen-1.9.10 /opt/doxygen
export PATH="/opt/doxygen/bin:$PATH"
doxygen --version

# Instalar Gradle 4.4
echo "Instalando Gradle..."
wget https://services.gradle.org/distributions/gradle-4.4-bin.zip
unzip gradle-4.4-bin.zip
mv gradle-4.4 /opt/gradle
export PATH="/opt/gradle/bin:$PATH"
gradle --version

echo "Doxygen e Gradle instalados com sucesso."

# Garantir que todas as dependências Python estão instaladas
echo "Instalando dependências Python..."
pip install -r requirements.txt

echo "instalação concluída. Iniciando o servidor..."

# Comando para iniciar o servidor Flask com gunicorn
exec gunicorn app:app
