# Comandos de Deployment para DigitalOcean

## Desplegar a DigitalOcean
```bash
# Usando el flake
nix run .#deploy -- .#digitalocean

# Con deploy-rs instalado
deploy .#digitalocean

# Con rollback automático en caso de error
deploy .#digitalocean --auto-rollback
```

## Verificar la configuración antes de desplegar
```bash
# Construir solo la configuración de digitalocean
nix build .#nixosConfigurations.digitalocean.config.system.build.toplevel

# Verificar los checks de deploy-rs
nix flake check --all-systems
```

## Generar imagen de DigitalOcean
```bash
# En sistema x86_64-linux
nix build .#digitalOceanImage

# La imagen estará en: result/nixos.qcow2.gz
```

## Verificar configuraciones individuales (opcional)
```bash
# Solo home_laptop
nix build .#nixosConfigurations.home_laptop.config.system.build.toplevel

# Solo digitalocean
nix build .#nixosConfigurations.digitalocean.config.system.build.toplevel

# Solo n1co
nix build .#nixosConfigurations.n1co.config.system.build.toplevel
```

## Troubleshooting

### Si el deployment falla
```bash
# Ver logs detallados
deploy .#digitalocean --debug-logs

# Conectarse al servidor para verificar
ssh ferock@64.225.51.178
```

### Si necesitas hacer rollback manual
```bash
ssh ferock@64.225.51.178
sudo nixos-rebuild --rollback switch
```
