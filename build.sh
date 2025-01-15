#!/bin/bash

set -e  # Interrompe o script ao encontrar um erro
echo "Iniciando o processo de instalação..."

# Instalar JDK 8 manualmente
JDK_VERSION="8u202"
JDK_BUILD="b08"
JDK_URL="https://download.oracle.com/otn-pub/java/jdk/${JDK_VERSION}-${JDK_BUILD}/1961070e4c9b4e26a04e7f5a083f551e/jdk-${JDK_VERSION}-linux-x64.tar.gz"

echo "Baixando e instalando JDK 8..."
wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "$JDK_URL" -O jdk.tar.gz
if [[ -f "jdk.tar.gz" ]]; then
    tar -xzf jdk.tar.gz
    mv jdk1.8.0_202 "$HOME/jdk8"
    export JAVA_HOME="$HOME/jdk8"
    export PATH="$JAVA_HOME/bin:$PATH"
    if ! java -version 2>/dev/null | grep -q "1.8"; then
        echo "Erro: JDK 8 não foi instalado corretamente." >&2
        exit 1
    fi
    echo "JDK $(java -version 2>&1 | head -n 1) instalado com sucesso."
else
    echo "Erro: Falha ao baixar o JDK 8." >&2
    exit 1
fi

# Instalar Doxygen
DOXYGEN_VERSION="1.9.8"
echo "Instalando Doxygen versão $DOXYGEN_VERSION..."
wget https://github.com/doxygen/doxygen/releases/download/Release_${DOXYGEN_VERSION//./_}/doxygen-${DOXYGEN_VERSION}.linux.bin.tar.gz -O doxygen.tar.gz
if [[ -f "doxygen.tar.gz" ]]; then
    tar -xzf doxygen.tar.gz
    mv doxygen-${DOXYGEN_VERSION} "$HOME/doxygen"
    export PATH="$HOME/doxygen/bin:$PATH"
    if ! command -v doxygen &>/dev/null; then
        echo "Erro: Doxygen não foi instalado corretamente." >&2
        exit 1
    fi
    echo "Doxygen versão $(doxygen --version) instalado com sucesso."
else
    echo "Erro: Falha ao baixar o Doxygen." >&2
    exit 1
fi

# Instalar Gradle 4.4
GRADLE_VERSION="4.4"
echo "Instalando Gradle versão $GRADLE_VERSION..."
wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -O gradle.zip
if [[ -f "gradle.zip" ]]; then
    unzip -q gradle.zip
    mv gradle-${GRADLE_VERSION} "$HOME/gradle"
    export PATH="$HOME/gradle/bin:$PATH"
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

# Comando para iniciar o servidor Flask com Gunicorn
exec gunicorn app:app --bind 0.0.0.0:10000
