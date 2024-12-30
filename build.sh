#!/bin/bash

# Instalar Doxygen 1.9.10
wget https://github.com/doxygen/doxygen/releases/download/Release_1_9_10/doxygen-1.9.10.linux.bin.tar.gz
tar -xvf doxygen-1.9.10.linux.bin.tar.gz
mv doxygen-1.9.10 /opt/doxygen

# Adicionar Doxygen ao PATH
export PATH="/opt/doxygen/bin:$PATH"

# Verificar Doxygen
doxygen --version

# Instalar Gradle 4.4
wget https://services.gradle.org/distributions/gradle-4.4-bin.zip
unzip gradle-4.4-bin.zip
mv gradle-4.4 /opt/gradle

# Adicionar Gradle ao PATH
export PATH="/opt/gradle/bin:$PATH"

# Verificar Gradle
gradle --version

# Continuar com o restante da construção (caso precise de mais dependências)
