# General

Cross-project lessons, reusable workflows, tool preferences, and broadly applicable knowledge.

## Learned 2026-07-07T12:26:33.498Z

Reason: La skill de email corporativo es transversal a todos los proyectos de Better, no pertenece a ASC

## Email Reader Skill (Better Consultants — transversal)

Skill para leer correo O365 corporativo vía IMAP + OAuth2, aplica a cualquier proyecto.
Script en `.pith/skills/email-reader/scripts/o365-mail.py`.

### Config
- **Email:** daniel.munoz@betterconsultants.com
- **IMAP host:** outlook.office365.com:993
- **Client ID Thunderbird público:** `9e5f94bc-e8a4-4e73-b8be-63364c29d753`
- **Auth:** device code flow (no necesita redirect URI)
- **Tokens:** `~/.config/better-email/tokens.json` (fuera del proyecto, permisos 600)

### Autorización (device code flow)
Cuando no hay token o ha expirado el refresh, ejecutar `auth`:
```bash
python3 .pith/skills/email-reader/scripts/o365-mail.py auth --email daniel.munoz@betterconsultants.com
```
Flujo:
1. El comando muestra código + URL.
2. El agente abre in-app browser con `browser_open(url)` apuntando a la URL.
3. Usuario introduce el código y autoriza la app Thunderbird.
4. Al decir "listo", el agente completa polling y guarda tokens.

### Operaciones
```bash
# --json SIEMPRE antes del subcomando
python3 .pith/skills/email-reader/scripts/o365-mail.py --json status
python3 .pith/skills/email-reader/scripts/o365-mail.py --json ls --limit 10
python3 .pith/skills/email-reader/scripts/o365-mail.py --json read 42
python3 .pith/skills/email-reader/scripts/o365-mail.py --json search "texto"
python3 .pith/skills/email-reader/scripts/o365-mail.py folders
python3 .pith/skills/email-reader/scripts/o365-mail.py mark <id> --read
python3 .pith/skills/email-reader/scripts/o365-mail.py archive <id>
python3 .pith/skills/email-reader/scripts/o365-mail.py move <id> --dest "Archivo"
python3 .pith/skills/email-reader/scripts/o365-mail.py delete <id>
```

### Device code flow para O365 IMAP con client_id público
El client_id de Thunderbird (`9e5f94bc-e8a4-4e73-b8be-63364c29d753`) no tiene registrado `http://localhost:9090` como redirect URI, por lo que Himalaya no puede usarlo con su flujo OAuth2 nativo.

**Solución**: usar device authorization grant (device code flow) que no necesita redirect URI:
1. POST a `/oauth2/v2.0/devicecode` con client_id + scope
2. Mostrar `user_code` + `verification_uri` al usuario
3. Usuario abre URL, introduce código, autoriza
4. Polling a `/oauth2/v2.0/token` hasta obtener tokens
5. Usar access_token con IMAP XOAUTH2

Esto permite usar clientes públicos (Thunderbird, etc.) desde CLI sin registrar una app en Azure AD.

### UIDs persistentes en o365-mail.py
El script original usaba números de secuencia IMAP en vez de UIDs, causando que los IDs cambiaran al archivar/borrar emails.

**Fix**: cambiar todas las operaciones IMAP a `imap.uid()`:
- `imap.uid('SEARCH', ...)` en lugar de `imap.search(...)`
- `imap.uid('FETCH', ...)` en lugar de `imap.fetch(...)`
- `imap.uid('STORE', ...)` en lugar de `imap.store(...)`
- `imap.uid('MOVE', ...)` en lugar de `imap._simple_command('MOVE', ...)`

### _imap_folder() — Quote automático de nombres de carpeta IMAP
El script fallaba con `BAD [b'Command Argument Error. 12']` al usar `--folder "Elementos eliminados"`. IMAP exige que los nombres de carpeta con espacios se pasen entrecomillados con dobles comillas.

**Fix**: helper `_imap_folder(name)` que añade `"..."` alrededor del nombre si contiene espacios o caracteres especiales. Usado en todos los `imap.select()` y `imap.uid("MOVE", ..., destino)`.

## Learned 2026-07-08T09:39:43.586Z

Reason: Herramienta sshpass instalada localmente para automatizar sudo en VMs remotas

## sshpass instalado (2026-07-08)

`sshpass` disponible en local para pasar passwords a SSH/sudo en conexiones a VMs remotas (ASC DES, otras). Instalado vía pacman.
