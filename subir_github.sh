#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sin color

# Banner
echo -e "${CYAN}"
echo "======================================="
echo "     🚀 SUBIDOR AUTOMÁTICO A GITHUB    "
echo "======================================="
echo -e "${NC}"

# Verificar si estamos en un repositorio Git
if [ ! -d .git ]; then
  echo -e "${YELLOW}⚠️ No estás en un repositorio Git.${NC}"
  read -p "🔗 Ingresa la URL del repositorio para clonarlo aquí: " repo_url
  git clone "$repo_url" repo_temp
  cd repo_temp || exit
fi

# Preguntas
read -p "👤 Usuario de GitHub: " usuario
read -p "🔑 Token de acceso personal: " token
read -p "📧 Email de GitHub: " email
git config --global user.name "$usuario"
git config --global user.email "$email"

read -p "📝 Mensaje de commit: " mensaje

# Añadir todos los archivos modificados
git add .

# Commit
git commit -m "$mensaje"

# Guardar credenciales (opcional)
read -p "¿Deseas guardar el token para futuros push? (s/n): " guardar
if [[ "$guardar" == "s" ]]; then
  git config --global credential.helper store
  echo "https://$usuario:$token@github.com" > ~/.git-credentials
fi

# Push
echo -e "${GREEN}📤 Subiendo archivos...${NC}"
git push

echo -e "${GREEN}✅ Archivos subidos correctamente.${NC}"

