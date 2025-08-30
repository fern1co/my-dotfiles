#!/usr/bin/env bash

# Demostración práctica de SOPS con dotfiles
# Este script muestra cómo usar SOPS en el día a día

set -euo pipefail

echo "🔐 Demostración Práctica de SOPS"
echo "================================"
echo ""

# Configuración de SOPS
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SECRETS_FILE="$DOTFILES_DIR/secrets/secrets.yaml"

echo "📂 Archivos de configuración:"
echo "   • Secretos: $SECRETS_FILE"
echo "   • Clave Age: $SOPS_AGE_KEY_FILE"
echo "   • Config SOPS: $DOTFILES_DIR/.sops.yaml"
echo ""

# Verificar que SOPS esté disponible
if ! command -v sops &> /dev/null; then
    echo "❌ SOPS no encontrado. Instala con:"
    echo "   nix shell nixpkgs#sops"
    exit 1
fi

echo "🔑 Tu clave pública Age:"
if [[ -f "$SOPS_AGE_KEY_FILE" ]]; then
    age-keygen -y "$SOPS_AGE_KEY_FILE"
else
    echo "❌ Clave Age no encontrada"
    exit 1
fi
echo ""

echo "📖 Ejemplos de uso de SOPS:"
echo ""

echo "1️⃣ Ver TODOS los secretos desencriptados:"
echo "   sops -d secrets/secrets.yaml"
echo ""

echo "2️⃣ Ver un secret específico:"
echo "   sops -d --extract '[\"api_keys\"][\"github_token\"]' secrets/secrets.yaml"
echo "   Resultado:"
if sops -d --extract '["api_keys"]["github_token"]' "$SECRETS_FILE" 2>/dev/null; then
    echo "   ✅ Desencriptación exitosa"
else
    echo "   ❌ Error en desencriptación"
fi
echo ""

echo "3️⃣ Editar secretos de forma segura:"
echo "   sops secrets/secrets.yaml"
echo "   (Se abre tu editor con el contenido desencriptado)"
echo ""

echo "4️⃣ Agregar un nuevo secret:"
echo "   sops --set '[\"new_service\"][\"api_key\"] \"mi_nueva_api_key\"' secrets/secrets.yaml"
echo ""

echo "5️⃣ Mostrar estructura del archivo cifrado:"
echo "   Notarás que las CLAVES están visibles pero los VALORES cifrados:"
head -10 "$SECRETS_FILE"
echo ""

echo "6️⃣ Rotar claves (cambiar cifrado):"
echo "   sops updatekeys secrets/secrets.yaml"
echo ""

echo "🔧 Cómo se integra con NixOS/Darwin:"
echo ""
echo "En tu configuración Nix, los secretos se desencriptan automáticamente:"
echo ""
echo "NixOS:"
echo '   config.sops.secrets."vpn/n1co-dev".path'
echo "   → /home/fernando-carbajal/vpn_configs/vpnconfig.ovpn"
echo ""
echo "Darwin:"  
echo '   config.sops.secrets."example/api-key".path'
echo "   → /Users/fernando.carbajal/.config/secrets/api-key"
echo ""

echo "🛡️ Seguridad:"
echo "   • Los valores están cifrados con AES256-GCM"
echo "   • Solo tu clave Age puede desencriptarlos"
echo "   • Los archivos en /nix/store son de solo lectura"
echo "   • Permisos 600 (solo tu usuario puede leer)"
echo ""

echo "🔄 Flujo en el sistema:"
echo "   1. NixOS/Darwin arranca"
echo "   2. sops-nix lee secrets.yaml cifrado"
echo "   3. Usa tu clave Age para desencriptar"
echo "   4. Coloca secretos en rutas especificadas"
echo "   5. Los servicios acceden a los archivos desencriptados"
echo ""

echo "💡 Tips prácticos:"
echo "   • Siempre haz backup de tu clave Age"
echo "   • Nunca commits la clave privada al repo"
echo "   • Usa diferentes claves para diferentes entornos"
echo "   • Valida regularmente que puedes desencriptar"