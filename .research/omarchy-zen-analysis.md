# Auditoría estática: Omarchy → Zen Browser

- **Fecha de auditoría:** 2026-09-02T12:31:26+02:00
- **Alcance:** snapshots Git fijados, fuentes primarias GitHub, Omarchy instalado localmente y fuente oficial Zen fijada. No se ejecutó ningún script de ninguno de los dos repositorios.
- **Repositorios auditados:**
  - `https://github.com/mehexi/omarchy-zen`
  - `https://github.com/aonatsky/omarchy-zen-sync`

## Resumen ejecutivo

`omarchy-zen-sync` es opción claramente superior para este equipo y objetivo. Usa la ruta de estado actual de Omarchy, el launcher local `zen-browser`, perfiles múltiples, Flatpak, plantillas con variables raíz de Zen, respaldo de `userChrome.css`, escritura atómica y validaciones contra symlinks/FIFO/dispositivos/path traversal. No observé exfiltración, descargas en runtime, `sudo`, systemd ni credenciales en el snapshot.

`omarchy-zen` es pequeño y fácil de entender, pero su snapshot actual tiene incompatibilidades funcionales graves: lee la ruta antigua `~/.config/omarchy/current/...`, limita la instalación al primer perfil y relanza `/opt/zen-browser/zen`, mientras que el launcher local apunta a `/opt/zen-browser-bin/zen-bin`. Además, inserta `ZEN_CHROME_DIR` sin escapar dentro de un script generado y no valida `Default=`; un `installs.ini` manipulado puede producir inyección de shell y escrituras fuera de la ruta esperada. También modifica `prefs.js` destructivamente y no ofrece desinstalador.

**Recomendación:** no instalar `omarchy-zen`; considerar `omarchy-zen-sync` solo fijando commit, revisando el checkout y corrigiendo/confirmando su documentación de personalización. Probar primero con copia/backup y un solo modo de integración.

## Snapshots, refs y actividad

### `mehexi/omarchy-zen`

- HEAD/master: `7a5717b1cef4760c7091e47793f70cf29ecd226a`
- Tree: `70f20cda306ba7a16f3109a4056cd4c2fb2b4847`
- HEAD: merge PR #3, firmado por GitHub según API (`verification.verified=true`); la verificación local no pudo comprobar la clave pública.
- Solo ref remota: `refs/heads/master`; **sin tags y sin releases**.
- 9 commits totales. Historial funcional: lanzamiento inicial `f988dda05600c87ad192b165d4bd3b55607505af` (2026-03-28), actualización de rutas `0936b0b30112898b7036d6d36236552fce2e869e` (2026-03-31), merge HEAD (2026-03-31). Los commits no merge aparecen sin firma verificada.
- GitHub API al auditar: 9 stars, 2 forks, 1 issue abierta, sin licencia declarada, no archivado. Sin releases.

### `aonatsky/omarchy-zen-sync`

- HEAD/master: `03c305526959d50e2f3bba40a1dd8dfcc1e925a1`
- Tree: `dc7487e5b9c75ca726ad7ff403deebd908e79038`
- HEAD sin firma verificada. Commit declara endurecimiento descriptor-bound, versión manifest `1.0.2`.
- Solo ref remota: `refs/heads/master`; **sin tags y sin releases**.
- 8 commits totales. Historial de seguridad relevante: inicial `150cf1c24a0ada7a13abd3c5981990f3230e351d`; plugin `ce03effbb34695cf637a85a4c382209c8a5ee290`; endurecimiento `9fbfc66648bb82511e40490268dacd080348501c`; I/O descriptor-bound HEAD `03c305526959d50e2f3bba40a1dd8dfcc1e925a1`. Actividad concentrada entre 2026-08-28 y 2026-08-31.
- GitHub API al auditar: 0 stars, 0 forks, 0 issues abiertas, MIT, no archivado. Sin releases.

### Archivos inspeccionados

- `omarchy-zen`: `README.md`, `install.sh`, 3 PNG, GIF y MP4. No hay manifest, workflow, hook versionado ni configuración adicional.
- `omarchy-zen-sync`: `LICENSE`, `README.md`, `Service.qml`, `hooks/50-restart-zen`, `install.sh`, `manifest.json`, `sync.sh`, `uninstall.sh`, `zen-userchrome.css.tpl`, 3 PNG. No hay `.github/workflows`, binarios ni dependencias vendorizadas.
- Los hooks bajo `.git/hooks/` son los samples estándar creados por Git, no archivos versionados de ninguno de los repos.
- Medios solo son imágenes/GIF/MP4; modos Git: scripts del segundo repo `100755`, todos los archivos del primero `100644` aunque `bash install.sh` no requiere bit ejecutable.

## Matriz de hallazgos

Severidades: **Crítica/Alta/Media/Baja/Info**. “Riesgo real” requiere una condición de explotación concreta; una señal de supply-chain o compatibilidad se marca por separado.

| Severidad | Repo | Hallazgo | Evidencia primaria | Evaluación |
|---|---|---|---|---|
| **Alta funcional** | `omarchy-zen` | Ruta de colores antigua | [`install.sh#L59`](https://github.com/mehexi/omarchy-zen/blob/7a5717b1cef4760c7091e47793f70cf29ecd226a/install.sh#L59) | Omarchy local actual usa `~/.local/state/omarchy/current/theme` (`/usr/share/omarchy/bin/omarchy-theme-set#L12-L13`, `#L292-L300`). El script no sincroniza sin compatibilidad adicional. |
| **Alta funcional** | `omarchy-zen` | Launcher incompatible con instalación local | [`install.sh#L140-L143`](https://github.com/mehexi/omarchy-zen/blob/7a5717b1cef4760c7091e47793f70cf29ecd226a/install.sh#L140-L143); `/usr/bin/zen-browser#L3` | Script mata procesos `zen` y lanza `/opt/zen-browser/zen`; launcher real inspeccionado ejecuta `/opt/zen-browser-bin/zen-bin`. El relanzamiento falla o puede dejar Zen cerrado. |
| **Media seguridad** | `omarchy-zen` | Inyección al generar script | [`install.sh#L29-L40`](https://github.com/mehexi/omarchy-zen/blob/7a5717b1cef4760c7091e47793f70cf29ecd226a/install.sh#L29-L40), [`#L54-L61`](https://github.com/mehexi/omarchy-zen/blob/7a5717b1cef4760c7091e47793f70cf29ecd226a/install.sh#L54-L61) | `Default=` se copia sin validación. `ZEN_CHROME_DIR` se interpola sin escapar en heredoc no citado. Un actor que controle `installs.ini` puede insertar sintaxis shell en el script instalado, ejecutada después por el hook. Requiere control local del perfil/config o checkout alterado; no es exfiltración observada. |
| **Media seguridad** | `omarchy-zen` | Path traversal/escritura fuera de ruta esperada | [`install.sh#L29-L39`](https://github.com/mehexi/omarchy-zen/blob/7a5717b1cef4760c7091e47793f70cf29ecd226a) | `ZEN_PROFILE=../../ruta` permite que `mkdir`, `prefs.js` y CSS apunten fuera de la raíz Zen. Misma precondición local que arriba; no se valida que sea perfil relativo, directorio real y descendiente. |
| **Media integridad** | `omarchy-zen` | Modificación destructiva/no reversible de `prefs.js` | [`install.sh#L43-L50`](https://github.com/mehexi/omarchy-zen/blob/7a5717b1cef4760c7091e47793f70cf29ecd226a/install.sh#L43-L50) | `sed -i` elimina toda línea que contenga el substring, sigue symlinks según comportamiento normal de `sed`, añade al final y no crea backup. No hay `uninstall.sh`. |
| **Media compatibilidad** | `omarchy-zen` | Solo primer perfil y detección ambigua | [`install.sh#L17-L30`](https://github.com/mehexi/omarchy-zen/blob/7a5717b1cef4760c7091e47793f70cf29ecd226a/install.sh#L17-L30) | Solo lee primera coincidencia `Default=`; si existen `.config/zen` y `.zen`, el último gana. No soporta la ruta Flatpak. |
| **Baja seguridad** | `omarchy-zen` | Escrituras no atómicas y ausencia de controles de tipo | [`install.sh#L38-L47`](https://github.com/mehexi/omarchy-zen/blob/7a5717b1cef4760c7091e47793f70cf29ecd226a/install.sh#L38-L47), [`#L78-L80`](https://github.com/mehexi/omarchy-zen/blob/7a5717b1cef4760c7091e47793f70cf29ecd226a/install.sh#L78-L80) | CSS se sobrescribe directamente; `colors.toml` se procesa con parser débil. Los valores no se validan como color, aunque no se reevalúan como shell en el heredoc del CSS. |
| **Baja funcional** | `omarchy-zen` | Reemplazo parcial/selector frágil | [`install.sh#L66-L99`](https://github.com/mehexi/omarchy-zen/blob/7a5717b1cef4760c7091e47793f70cf29ecd226a/install.sh#L66-L99) | Solo 7/8 colores y CSS por selectores individuales. En Zen oficial actual no aparecen `--zen-accent-color`, `--zen-border-color` ni `--zen-themed-toolbar-color`; sí aparecen las variables raíz modernas en [`zen-theme.css#L11-L42`](https://github.com/zen-browser/desktop/blob/3655afbe13dff96a00af4c789a1d3180ceecc79c/src/zen/common/styles/zen-theme.css#L11-L42). |
| **Info** | `omarchy-zen` | Sin red en runtime, sudo, systemd, credenciales o binarios | Archivos versionados completos; README [`#L61-L69`](https://github.com/mehexi/omarchy-zen/blob/7a5717b1cef4760c7091e47793f70cf29ecd226a/README.md#L61-L69) | No observados. El `git clone` recomendado usa rama mutable y supone confianza en GitHub/HEAD. |
| **Media supply-chain** | `omarchy-zen-sync` | Instalación recomendada desde URL mutable | [`README.md#L79-L88`](https://github.com/aonatsky/omarchy-zen-sync/blob/03c305526959d50e2f3bba40a1dd8dfcc1e925a1/README.md#L79-L88); `/usr/share/omarchy/bin/omarchy-plugin-add#L120-L125` | `omarchy plugin add URL` clona HEAD actual. Omarchy muestra advertencia de código arbitrario no sandboxed (`#L96-L113`), valida manifest/symlinks, pero no fija commit ni audita contenido. Riesgo de cambio upstream, no malware observado en snapshot. |
| **Media seguridad residual** | `omarchy-zen-sync` | `mktemp -u` para symlink temporal | [`sync.sh#L148-L151`](https://github.com/aonatsky/omarchy-zen-sync/blob/03c305526959d50e2f3bba40a1dd8dfcc1e925a1/sync.sh#L148-L151) | Tiene carrera TOCTOU. Un atacante local que pueda escribir simultáneamente en el directorio del perfil puede provocar fallo o alterar el symlink instalado; no ofrece una vía clara para escribir fuera del perfil porque `mv` reemplaza el enlace, no lo sigue. Debería usar `mktemp` real + `ln` sobre nombre reservado. |
| **Baja seguridad residual** | `omarchy-zen-sync` | Comprobación de `OUT_DIR` después de `mkdir/chmod` | [`sync.sh#L72-L76`](https://github.com/aonatsky/omarchy-zen-sync/blob/03c305526959d50e2f3bba40a1dd8dfcc1e925a1/sync.sh#L72-L76) | Si un atacante local planta un symlink en `~/.local/state/omarchy-zen-sync`, `chmod` puede seguirlo antes de que `! -L` haga abortar. Condición local privilegiada sobre HOME; no es ataque remoto. |
| **Baja supply-chain** | `omarchy-zen-sync` | Dependencias resueltas por `PATH` | [`sync.sh#L35-L36`](https://github.com/aonatsky/omarchy-zen-sync/blob/03c305526959d50e2f3bba40a1dd8dfcc1e925a1/sync.sh#L35-L36), [`#L100`](https://github.com/aonatsky/omarchy-zen-sync/blob/03c305526959d50e2f3bba40a1dd8dfcc1e925a1/sync.sh#L100) | Usa `omarchy-theme-color`, `python3`, `awk`, `head`, `realpath`, `mktemp`, `cmp`, `pgrep`, `pkill`, `hyprctl`, `setsid`, etc. sin rutas absolutas ni hashes. Normal en scripts de usuario; PATH comprometido implica ejecución arbitraria. |
| **Baja funcional** | `omarchy-zen-sync` | README contradice implementación de personalización | README [`#L111-L125`](https://github.com/aonatsky/omarchy-zen-sync/blob/03c305526959d50e2f3bba40a1dd8dfcc1e925a1/README.md#L111-L125); [`sync.sh#L22-L24`](https://github.com/aonatsky/omarchy-zen-sync/blob/03c305526959d50e2f3bba40a1dd8dfcc1e925a1/sync.sh#L22-L24) | README dice editar `~/.config/omarchy/themed/zen-userchrome.css.tpl`; `sync.sh` lee únicamente el template junto a sí mismo en `~/.local/share/...` en manual mode o directorio del plugin. El fichero indicado no controla el render actual. |
| **Baja funcional** | `omarchy-zen-sync` | No es exactamente el renderer nativo de Omarchy | [`sync.sh#L91-L103`](https://github.com/aonatsky/omarchy-zen-sync/blob/03c305526959d50e2f3bba40a1dd8dfcc1e925a1/sync.sh#L91-L103); `/usr/share/omarchy/bin/omarchy-theme-set-templates#L371-L401` | Reusa `omarchy-theme-color --all`, pero implementa sustitución propia. El renderer nativo admite `{{ key_rgb }}`, `{{ key_strip }}`, `{{ mix ... }}` y otras funciones; este script solo reemplaza `{{ key }}`. El README promete más tokens en `#L113-L115` de lo que este pipeline procesa. |
| **Baja funcional** | `omarchy-zen-sync` | Variantes de Space limitadas a 1–6 | [`zen-userchrome.css.tpl#L101-L153`](https://github.com/aonatsky/omarchy-zen-sync/blob/03c305526959d50e2f3bba40a1dd8dfcc1e925a1/zen-userchrome.css.tpl#L101-L153) | Zen oficial actual sí define `zen-workspace` y `[active]` en [`zen-workspaces.css#L317-L329`](https://github.com/zen-browser/desktop/blob/3655afbe13dff96a00af4c789a1d3180ceecc79c/src/zen/spaces/zen-workspaces.css#L317-L329), por lo que el mecanismo es plausible; Spaces 7+ no reciben tinte específico. |
| **Info positiva** | `omarchy-zen-sync` | Lecturas descriptor-bound y validación de inputs | [`sync.sh#L43-L69`](https://github.com/aonatsky/omarchy-zen-sync/blob/03c305526959d50e2f3bba40a1dd8dfcc1e925a1/sync.sh#L43-L69), [`#L126-L182`](https://github.com/aonatsky/omarchy-zen-sync/blob/03c305526959d50e2f3bba40a1dd8dfcc1e925a1/sync.sh#L126-L182) | `O_NOFOLLOW|O_NONBLOCK|O_CLOEXEC`, `fstat`, owner actual, regular-file, tamaño máximo, canonicalización bajo raíz y rechazo de symlinks/path traversal. Reduce riesgos reales de races y datos controlados. |
| **Info positiva** | `omarchy-zen-sync` | Sin red en runtime ni privilegios | README [`#L142-L160`](https://github.com/aonatsky/omarchy-zen-sync/blob/03c305526959d50e2f3bba40a1dd8dfcc1e925a1/README.md#L142-L160); inventario completo | No hay `curl`, `wget`, `sudo`, systemd, cron, credenciales, cookies, binarios ni URLs usadas por scripts en runtime. `Service.qml` solo llama al script local (`#L63-L66`). |

## Comportamiento e integración

### `omarchy-zen`

1. Busca `~/.config/zen` y `~/.zen`, lee el primer `Default=` y crea `chrome/` (`install.sh#L17-L40`).
2. Edita directamente `prefs.js` para activar userChrome (`#L43-L50`).
3. Genera `~/.local/share/omarchy/bin/omarchy-theme-set-zen` mediante heredoc (`#L54-L144`).
4. Añade una línea a `omarchy-theme-set-browser` (`#L149-L155`). Omarchy local ya ejecuta ese comando durante `theme set` (`/usr/share/omarchy/bin/omarchy-theme-set#L319-L339`) y además ejecuta hooks `theme-set`.
5. Renderiza CSS y mata/relanza Zen cada vez.

Ventajas: muy poco código, hook directo, fácil de leer. Desventajas: no desinstalador, no backup, no atomicidad, perfil único, ruta de colores vieja y launcher incorrecto. README requiere configurar `toolkit.legacyUserProfileCustomizations.stylesheets` manualmente (`README.md#L30-L43`), aunque el instalador ya intenta escribirlo en `prefs.js`.

### `omarchy-zen-sync`

- **Plugin:** `manifest.json#L1-L13` declara servicio `keepLoaded`; `Service.qml#L38-L74` vigila cambios, debounce 800 ms y ejecuta `bash sync.sh`.
- **Manual:** `install.sh#L19-L31` copia script/template a `~/.local/share/omarchy-zen-sync`, instala `~/.config/omarchy/hooks/theme-set.d/50-zen-sync` y ejecuta sync una vez. No combinar plugin y hook (`README.md#L94-L109`).
- **Profiles:** cubre `.config/zen`, `.zen` y Flatpak (`sync.sh#L169-L183`), procesa todos los perfiles relativos con `prefs.js`, respalda CSS regular previo y enlaza un CSS común (`#L139-L166`).
- **Estado:** CSS renderizado en `~/.local/state/omarchy-zen-sync/zen-userchrome.css` (`#L24-L26`).
- **Restart:** solo si el CSS cambia (`#L110-L118`, `#L185-L196`); usa `zen-bin` y lanza `zen-browser`, compatible con `/usr/bin/zen-browser#L3`. Puede reiniciar Zen por señales `TERM`, pero no toca el contenido web ni datos de navegación.
- **Reversibilidad:** `uninstall.sh#L17-L39` elimina artefactos conocidos, borra symlinks propios y restaura backup. El modo plugin se elimina primero con `omarchy plugin remove`, después el desinstalador del clone para artefactos. La preferencia añadida a `user.js` no se elimina explícitamente; queda en `user.js`, aunque sin CSS deja de tener efecto.

## Seguridad por repositorio

### `omarchy-zen`: **no recomendado; riesgo medio real y alta incompatibilidad**

No hay evidencia estática de malware, red, robo de credenciales, privilegios ni persistencia fuera del hook de tema que el propio instalador añade. Pero el instalador no es robusto frente a un `installs.ini` controlado, construye código con datos de ruta sin escapar, permite traversal y realiza cambios destructivos. Más importante para este objetivo: no funciona con las rutas y launcher observados en este equipo. “No observado” no significa limpio absoluto.

### `omarchy-zen-sync`: **riesgo bajo en snapshot fijado; no limpio absoluto**

La implementación actual muestra endurecimiento deliberado y no contiene conducta de exfiltración o elevación. Los riesgos restantes son carrera de `mktemp -u`, symlink de directorio antes de `chmod`, dependencias por PATH y confianza en servicio/plugin no sandboxed. El riesgo dominante de instalación es supply-chain: URL mutable, repo sin releases/tags y HEAD reciente sin firma verificada. Auditar/fijar el commit reduce ese riesgo, no lo elimina.

## Comparación final

| Criterio | `omarchy-zen` | `omarchy-zen-sync` |
|---|---|---|
| Mantenibilidad | Simple, pero hardcoded y sin uninstall | Más complejo, separado renderer/template/service; mejor estructura |
| Cambio de theme Omarchy | Hook en browser script; ruta antigua | Plugin watcher o hook `theme-set`; ruta actual |
| Zen actual | Mala: vars/selectores parciales y launcher incorrecto | Buena: vars raíz actuales y launcher local correcto |
| Perfiles/Flatpak | Uno; sin Flatpak | Todos los perfiles; incluye Flatpak |
| Multi-theme | Solo 7 colores, fallback simple | Paleta semántica completa vía `omarchy-theme-color` |
| Multi-Space | No | Spaces 1–6 con gradientes |
| Reversibilidad | Mala: sin backup/uninstall | Mejor: backup, symlinks propios, uninstall; pref `user.js` queda |
| Complejidad/riesgo | Menor superficie, pero fallos de seguridad e integración | Mayor superficie; controles de entrada notablemente mejores |

## Condiciones para instalación posterior

1. **No instalar `omarchy-zen`.** Solo tendría sentido tras corregir ruta `.local/state`, usar `zen-browser`, validar perfil, escapar heredoc, hacer backup/atomicidad y añadir uninstall.
2. Para `omarchy-zen-sync`, no usar URL mutable directamente. Obtener/verificar exactamente `03c305526959d50e2f3bba40a1dd8dfcc1e925a1` o una revisión posterior auditada; comprobar `git diff` y hashes antes de habilitar.
3. Elegir **un único modo**: plugin o hook manual. No habilitar ambos.
4. Revisar que `omarchy-theme-color`, `python3`, `zen-browser` y `zen-bin` sean los binarios esperados; usar PATH confiable.
5. Respaldar `prefs.js`, `user.js`, cualquier `chrome/userChrome.css` y estado Omarchy antes. Verificar que el backup sea regular y del perfil correcto.
6. Corregir la documentación/implementación del template: decidir si se usa el renderer del plugin o `~/.config/omarchy/themed/zen-userchrome.css.tpl`; actualmente no coinciden.
7. Probar en una copia/perfil no crítico: cambio dark↔light, varios perfiles, Flatpak si aplica, Spaces 1–6, Zen cerrado/abierto y rollback. Confirmar que no hay proceso `zen-bin` duplicado tras restart.
8. Tras instalar, revisar archivos modificados y hooks; comprobar que no haya symlinks inesperados. Para retirar plugin, deshabilitar/quitar plugin y ejecutar uninstall desde el mismo commit auditado.

## Límites de auditoría

- Inspección estática del contenido alcanzable en los HEAD indicados; no se ejecutaron scripts, instaladores, hooks, `Service.qml` ni comandos de los repos.
- No se auditó el servidor GitHub, cuentas de mantenedores, dependencias futuras, commits posteriores al snapshot, releases inexistentes ni contenido que pudiera descargar el gestor durante una instalación futura.
- Las imágenes/GIF/MP4 se identificaron como medios por tipo/hash; no se interpretó cada fotograma ni se hizo análisis forense de codecs.
- El comportamiento exacto de Zen puede cambiar después del commit oficial inspeccionado `3655afbe13dff96a00af4c789a1d3180ceecc79c`; los nombres CSS actuales se contrastaron solo contra `src/zen/common/styles/zen-theme.css` y archivos workspace/UI relevantes.
- La conclusión se limita a archivos, refs y fuentes citadas; no afirma ausencia absoluta de vulnerabilidades.
