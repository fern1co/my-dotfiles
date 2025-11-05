# Deploy-RS desde macOS a DigitalOcean

## 🚀 Comandos de Despliegue

### Deploy con Remote Build (Recomendado)
```bash
# Construye en el servidor remoto
nix run .#deploy -- --remote-build .#digitalocean

# Con dry-run para verificar
nix run .#deploy -- --remote-build --dry-activate .#digitalocean

# Con auto-rollback por seguridad
nix run .#deploy -- --remote-build --auto-rollback true .#digitalocean

# Con logs de debug
nix run .#deploy -- --remote-build --debug-logs .#digitalocean
```

### Prerequisitos

1. **Acceso SSH al servidor**
   ```bash
   # Verificar conexión SSH
   ssh ferock@64.225.51.178 "echo 'Connected successfully'"
   ```

2. **Usuario en trusted-users (en el servidor)**
   ```nix
   # Ya configurado en lib/nixos/digitalocean/configuration.nix
   nix.settings.trusted-users = [ "root" "ferock" ];
   ```

3. **NixOS instalado en el servidor**
   - Opción A: Instalar NixOS desde ISO
   - Opción B: Usar imagen personalizada (ver abajo)

## 📦 Generar Imagen de DigitalOcean

Si necesitas crear un droplet desde cero con tu configuración:

```bash
# Generar imagen (requiere builder Linux o emulación)
nix build .#digitalOceanImage

# La imagen estará en: result/nixos.qcow2.gz
```

**Nota:** Este comando también requiere Linux. Alternativas:
- Usar GitHub Actions para generar la imagen
- Usar un builder remoto
- Instalar NixOS manualmente en el droplet

## ⚙️ Configurar Builder Remoto (Opcional)

Para compilar localmente con builder remoto:

### 1. Agregar configuración a nix.conf

```bash
# Editar ~/.config/nix/nix.conf
mkdir -p ~/.config/nix
cat >> ~/.config/nix/nix.conf << 'EOF'

# Remote builders
builders = ssh://ferock@64.225.51.178 x86_64-linux - 4 1 big-parallel,benchmark
builders-use-substitutes = true
EOF
```

### 2. Configurar SSH sin password

```bash
# Verificar que tu clave SSH está agregada
ssh-add -l

# Si no, agregar tu clave
ssh-add ~/.ssh/id_rsa  # o la ruta de tu clave
```

### 3. Probar el builder

```bash
# Reiniciar el daemon de nix
sudo launchctl kickstart -k system/org.nixos.nix-daemon

# Verificar que funciona
nix build .#nixosConfigurations.digitalocean.config.system.build.toplevel
```

## 🔐 Configuración de Secretos

Antes del primer deploy, configura los secretos SOPS en el servidor:

```bash
# 1. SSH al servidor
ssh ferock@64.225.51.178

# 2. Crear directorio para sops
sudo mkdir -p /var/lib/sops-nix

# 3. Crear archivo de clave AGE
sudo nano /var/lib/sops-nix/key.txt
# Pega tu clave privada AGE aquí

# 4. Ajustar permisos
sudo chmod 600 /var/lib/sops-nix/key.txt
sudo chown root:root /var/lib/sops-nix/key.txt
```

## 🎯 Workflow Completo

### Primera vez

1. **Instalar NixOS en el droplet**
   - Usar imagen de DigitalOcean con NixOS
   - O instalar manualmente desde ISO

2. **Configurar acceso SSH inicial**
   ```bash
   # Agregar tu clave SSH al servidor
   ssh-copy-id ferock@64.225.51.178
   ```

3. **Deploy inicial con remote build**
   ```bash
   nix run .#deploy -- --remote-build --debug-logs .#digitalocean
   ```

4. **Configurar secretos SOPS** (si es necesario)

5. **Re-deploy con secretos**
   ```bash
   nix run .#deploy -- --remote-build .#digitalocean
   ```

### Updates subsecuentes

```bash
# Deploy con auto-rollback
nix run .#deploy -- --remote-build --auto-rollback true .#digitalocean
```

## 🐛 Troubleshooting

### Error: Permission denied (publickey)

```bash
# Verificar que tu clave SSH está configurada
cat ~/.ssh/id_rsa.pub

# Verificar conexión SSH
ssh -v ferock@64.225.51.178
```

**Solución:**
- Agregar clave SSH mediante la consola de DigitalOcean
- O usar la API de DigitalOcean para agregar la clave

### Error: Cannot build for x86_64-linux

**Solución:** Usar el flag `--remote-build`:
```bash
nix run .#deploy -- --remote-build .#digitalocean
```

### Error: Connection refused

**Verificar:**
1. IP correcta: `64.225.51.178`
2. Puerto SSH abierto: `22`
3. Firewall configurado

```bash
# Verificar puerto SSH
nc -zv 64.225.51.178 22
```

### Error: SOPS validation failed

**Solución:**
1. Configurar clave AGE en `/var/lib/sops-nix/key.txt`
2. O deshabilitar temporalmente: `validateSopsFiles = false;`

## 📋 Checklist Pre-Deploy

- [ ] NixOS instalado en `64.225.51.178`
- [ ] Acceso SSH funcionando
- [ ] Usuario `ferock` existe y tiene permisos sudo
- [ ] Usuario en `trusted-users` de nix
- [ ] Firewall permite SSH (puerto 22)
- [ ] Secretos SOPS configurados (si se usan)

## 🔗 Referencias

- [Deploy-rs Documentation](https://github.com/serokell/deploy-rs)
- [NixOS on DigitalOcean](https://nixos.org/manual/nixos/stable/index.html#sec-installation-digitalocean)
- [SOPS-nix Documentation](https://github.com/Mic92/sops-nix)
