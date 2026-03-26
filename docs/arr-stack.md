# Arr Stack — Guía de uso

## Arquitectura

```
Internet
   ↓
FlareSolverr (bypass Cloudflare)
   ↓
Prowlarr (indexers)
   ↓           ↓
Sonarr       Radarr
(series)    (películas)
   ↓           ↓
Transmission (descargas)
   ↓
/home/fernando-carbajal/media/
   ├── downloads/
   │   ├── complete/
   │   └── incomplete/
   ├── movies/
   └── series/

Jellyfin ←── /home/fernando-carbajal/media/movies + /home/fernando-carbajal/media/series
Bazarr   ←── lee subtítulos de Sonarr y Radarr
```

---

## Endpoints

| Servicio       | URL                                  | Puerto |
|----------------|--------------------------------------|--------|
| Sonarr         | http://sonarr.f3rock.local           | 8989   |
| Radarr         | http://radarr.f3rock.local           | 7878   |
| Prowlarr       | http://prowlarr.f3rock.local         | 9696   |
| Bazarr         | http://bazarr.f3rock.local           | 6767   |
| Jellyfin       | http://jellyfin.f3rock.local         | 8096   |
| Transmission   | http://transmission.f3rock.local     | 9091   |
| FlareSolverr   | http://localhost:8191 (solo interno) | 8191   |

> Los dominios `*.f3rock.local` requieren que el dispositivo use AdGuard Home como DNS (`192.168.10.149`).

---

## Orden de configuración inicial

```
1. Transmission → 2. FlareSolverr → 3. Prowlarr → 4. Sonarr → 5. Radarr → 6. Bazarr → 7. Jellyfin
```

---

## 1. Transmission

**URL:** http://transmission.f3rock.local

Sin configuración adicional necesaria. Los directorios ya están definidos:

- Completos: `/home/fernando-carbajal/media/downloads/complete`
- Incompletos: `/home/fernando-carbajal/media/downloads/incomplete`

---

## 2. FlareSolverr

No requiere configuración. Se configura desde Prowlarr.

Verificar que esté corriendo:
```bash
systemctl status flaresolverr
curl http://localhost:8191/health
```

---

## 3. Prowlarr

**URL:** http://prowlarr.f3rock.local

### Agregar FlareSolverr

1. `Settings` → `Indexers` → `+ Add`
2. Busca **FlareSolverr** y agrégalo:
   - URL: `http://localhost:8191`
   - Tag: `flaresolverr`

### Agregar indexers

1. `Indexers` → `Add Indexer`
2. Para indexers con Cloudflare (ej: 1337x), asignarles el tag `flaresolverr`
3. Click en `Test` → `Save`

### Conectar con Sonarr y Radarr

1. `Settings` → `Apps`
2. Agrega **Sonarr**:
   - URL: `http://localhost:8989`
   - API Key: (desde Sonarr → Settings → General)
3. Agrega **Radarr**:
   - URL: `http://localhost:7878`
   - API Key: (desde Radarr → Settings → General)
4. `Sync App Indexers` para empujar los indexers a ambas apps

---

## 4. Sonarr

**URL:** http://sonarr.f3rock.local

### Cliente de descarga

1. `Settings` → `Download Clients` → `+`
2. Selecciona **Transmission**
3. Host: `localhost`, Port: `9091`
4. `Test` → `Save`

### Carpeta raíz

1. `Settings` → `Media Management` → `Root Folders` → `+`
2. Ruta: `/home/fernando-carbajal/media/series`

### Agregar una serie

1. `Series` → `Add New`
2. Busca el nombre, elige perfil de calidad y carpeta raíz
3. Click en `Add Series`

---

## 5. Radarr

**URL:** http://radarr.f3rock.local

### Cliente de descarga

1. `Settings` → `Download Clients` → `+`
2. Selecciona **Transmission**
3. Host: `localhost`, Port: `9091`
4. `Test` → `Save`

### Carpeta raíz

1. `Settings` → `Media Management` → `Root Folders` → `+`
2. Ruta: `/home/fernando-carbajal/media/movies`

### Agregar una película

1. `Movies` → `Add New`
2. Busca el nombre, elige calidad y carpeta raíz
3. Click en `Add Movie`

---

## 6. Bazarr

**URL:** http://bazarr.f3rock.local

### Conectar con Sonarr y Radarr

1. `Settings` → `Sonarr`:
   - Host: `localhost`, Port: `8989`
   - API Key: (desde Sonarr → Settings → General)
2. `Settings` → `Radarr`:
   - Host: `localhost`, Port: `7878`
   - API Key: (desde Radarr → Settings → General)

### Proveedores de subtítulos recomendados

1. `Settings` → `Subtitles` → `Subtitles Providers` → `+`
2. Recomendados: **OpenSubtitles.com**, **Subdivx** (español latino)
3. Idiomas preferidos: `es`, `en`

---

## 7. Jellyfin

**URL:** http://jellyfin.f3rock.local

**Usuario:** `admin` / `admin`

### Bibliotecas

Agregar desde `Dashboard` → `Libraries` → `+ Add Media Library`:

| Tipo      | Ruta                  |
|-----------|-----------------------|
| Películas | `/home/fernando-carbajal/media/movies`   |
| Series    | `/home/fernando-carbajal/media/series`   |

### Acceso desde otros dispositivos

- App Jellyfin en Smart TV, móvil, etc.
- Servidor: `http://jellyfin.f3rock.local` o `http://192.168.10.149:8096`

---

## Comandos útiles

```bash
# Estado de todos los servicios
systemctl status sonarr radarr prowlarr bazarr jellyfin transmission flaresolverr

# Logs en tiempo real
journalctl -fu sonarr
journalctl -fu radarr
journalctl -fu transmission
journalctl -fu flaresolverr

# Reiniciar un servicio
sudo systemctl restart sonarr

# Espacio en disco
du -sh /home/fernando-carbajal/media/*
```

---

## Permisos

Todos los servicios corren bajo el grupo `media` con acceso a `/home/fernando-carbajal/media` (permisos `0775`).

| Usuario del sistema | Servicio     |
|--------------------|--------------|
| `sonarr`           | Sonarr       |
| `radarr`           | Radarr       |
| `bazarr`           | Bazarr       |
| `jellyfin`         | Jellyfin     |
| `transmission`     | Transmission |
| `fernando-carbajal`| Usuario principal |
