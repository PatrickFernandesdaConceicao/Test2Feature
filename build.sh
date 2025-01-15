#!/bin/bash

set -e  # Para o script ao encontrar um erro
echo "Iniciando o processo de instalação..."

# Instalar o OpenJDK 8
echo "Instalando OpenJDK 8..."
wget https://download.java.net/openjdk/jdk8u41/ri/openjdk-8u41-b04-linux-x64-14_jan_2020.tar.gz -O openjdk.tar.gz
if [[ -f "openjdk.tar.gz" ]]; then
    tar -xzf openjdk.tar.gz
    mv java-se-8u41-ri "$HOME/openjdk8"
    export JAVA_HOME="$HOME/openjdk8"
    export PATH="$JAVA_HOME/bin:$PATH"

    echo "Validando instalação do OpenJDK 8..."
    if ! "$JAVA_HOME/bin/java" -version 2>/dev/null | grep -q "1.8"; then
        echo "Erro: OpenJDK 8 não foi instalado corretamente. Verifique os passos de instalação e o diretório extraído." >&2
        exit 1
    fi
    echo "OpenJDK versão $("$JAVA_HOME/bin/java" -version 2>&1 | head -n 1) instalado com sucesso."
else
    echo "Erro: Falha ao baixar o OpenJDK 8." >&2
    exit 1
fi

# Instalar Doxygen
DOXYGEN_VERSION="1.9.8"  # Substitua pela versão desejada
echo "Instalando Doxygen versão $DOXYGEN_VERSION..."
wget https://github.com/doxygen/doxygen/releases/download/Release_${DOXYGEN_VERSION//./_}/doxygen-${DOXYGEN_VERSION}.linux.bin.tar.gz -O doxygen.tar.gz
if [[ -f "doxygen.tar.gz" ]]; then
    tar -xvf doxygen.tar.gz
    mv doxygen-${DOXYGEN_VERSION} /opt/doxygen
    export PATH="/opt/doxygen/bin:$PATH"
    if ! command -v doxygen &>/dev/null; then
        echo "Erro: Doxygen não foi instalado corretamente." >&2
        exit 1
    fi
    echo "Doxygen versão $(doxygen --version) instalado com sucesso."
else
    echo "Erro: Falha ao baixar o Doxygen." >&2
    exit 1
fi

# Instalar Gradle
GRADLE_VERSION="4.4"  # Substitua pela versão desejada
echo "Instalando Gradle versão $GRADLE_VERSION..."
wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -O gradle.zip
if [[ -f "gradle.zip" ]]; then
    unzip gradle.zip
    mv gradle-${GRADLE_VERSION} /opt/gradle
    export PATH="/opt/gradle/bin:$PATH"
    if ! command -v gradle &>/dev/null; then
        echo "Erro: Gradle não foi instalado corretamente." >&2
        exit 1
    fi
    echo "Gradle versão $(gradle --version | head -n 1) instalado com sucesso."
else
    echo "Erro: Falha ao baixar o Gradle." >&2
    exit 1
fi

# Garantir que todas as dependências Python estão instaladas
echo "Instalando dependências Python..."
if [[ -f "requirements.txt" ]]; then
    pip install --upgrade pip
    pip install -r requirements.txt
else
    echo "Aviso: Arquivo requirements.txt não encontrado. Pulando esta etapa."
fi

echo "Instalação concluída. Iniciando o servidor..."

# Comando para iniciar o servidor Flask com gunicorn
exec gunicorn app:app --bind 0.0.0.0:10000
