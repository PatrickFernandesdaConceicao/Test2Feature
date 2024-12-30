#!/bin/bash

# Instalar Doxygen 1.9.10
wget https://github.com/doxygen/doxygen/releases/download/Release_1_9_10/doxygen-1.9.10.linux.bin.tar.gz
tar -xvf doxygen-1.9.10.linux.bin.tar.gz
mv doxygen-1.9.10 /opt/doxygen

# Adicionar Doxygen ao PATH
export PATH="/opt/doxygen/bin:$PATH"

# Verificar a versão instalada
doxygen --version

# Continuar com o restante da construção
