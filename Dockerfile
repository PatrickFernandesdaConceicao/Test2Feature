# Use uma imagem base com Ubuntu 20.04
FROM ubuntu:20.04

# Definir variáveis de ambiente e diretório de trabalho
WORKDIR /opt/render/project/src

# Atualizar o sistema e instalar dependências essenciais, incluindo o FLEX
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    flex \
    bison \
    wget \
    unzip \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Atualizar o pip para a versão mais recente
RUN pip install --upgrade pip

# Instalar OpenJDK 8
RUN echo "Baixando e instalando OpenJDK 8..." \
    && wget https://download.java.net/openjdk/jdk8u41/ri/openjdk-8u41-b04-linux-x64-14_jan_2020.tar.gz -O openjdk.tar.gz \
    && tar -xzf openjdk.tar.gz \
    && mv java-se-8u41-ri /opt/render/openjdk8 \
    && export JAVA_HOME="/opt/render/openjdk8/java-se-8u41-ri" \
    && export PATH="$JAVA_HOME/bin:$PATH" \
    && rm openjdk.tar.gz

# Validar a instalação do OpenJDK 8
RUN java -version

# Instalar Doxygen
RUN echo "Instalando Doxygen..." \
    && wget https://github.com/doxygen/doxygen/releases/download/Release_1_9_8/doxygen-1.9.8-linux.tar.gz -O doxygen.tar.gz \
    && tar -xzf doxygen.tar.gz \
    && mv doxygen-1.9.8 /opt/doxygen \
    && export PATH="/opt/doxygen/bin:$PATH" \
    && rm doxygen.tar.gz

# Instalar Gradle
RUN echo "Instalando Gradle..." \
    && wget https://services.gradle.org/distributions/gradle-4.4-bin.zip -O gradle.zip \
    && unzip gradle.zip -d /opt \
    && rm gradle.zip \
    && mv /opt/gradle-4.4 /opt/gradle \
    && export PATH="/opt/gradle/bin:$PATH"

# Copiar arquivos do repositório para o container
COPY . .

# Instalar dependências Python do arquivo requirements.txt
COPY requirements.txt .
RUN pip install -r requirements.txt

# Definir o comando para iniciar o servidor Flask com gunicorn
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:10000"]
