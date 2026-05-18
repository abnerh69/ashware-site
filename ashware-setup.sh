#!/usr/bin/env bash
# ashware-setup.sh
# ---------------------------------------------------------------------------
# Automatiza el setup del sitio ashware.org en GitHub Pages.
#
# Qué hace:
#   1. Verifica prerequisitos (gh autenticado, git limpio).
#   2. Crea _config.yml (Jekyll + just-the-docs + SEO + sitemap).
#   3. Crea Gemfile (para preview local opcional).
#   4. Crea .gitignore (Jekyll artifacts).
#   5. Crea CNAME (ashware.org).
#   6. Crea about.md (plantilla — la edita Abner después).
#   7. Añade frontmatter (title + permalink + nav_order) a los 5 docs.
#   8. Excluye docs/README.md del sitio (published: false).
#   9. Commitea y pushea.
#  10. Habilita GitHub Pages vía API (idempotente).
#  11. Imprime los pasos manuales restantes (DNS, verificación, HTTPS).
#
# Idempotente: archivos existentes no se sobreescriben. Frontmatter no se
# duplica. Pages enable se actualiza si ya existe.
#
# Asume:
#   - estás en la raíz del repo `ashware-site`
#   - gh y git instalados y autenticados (macOS, login funcional)
#   - el repo ya está pusheado al menos una vez a GitHub
# ---------------------------------------------------------------------------

set -euo pipefail

# ─── Config ────────────────────────────────────────────────────────────────
DOMAIN="ashware.org"
REPO_NAME="ashware-site"
REMOTE_THEME="just-the-docs/just-the-docs"

# ─── Sanity checks ──────────────────────────────────────────────────────────
echo "▸ Verificando prerequisitos..."

command -v gh >/dev/null 2>&1 || { echo "✗ gh CLI no encontrado"; exit 1; }
command -v git >/dev/null 2>&1 || { echo "✗ git no encontrado"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "✗ gh no autenticado. Corre: gh auth login"; exit 1; }

git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || { echo "✗ no estás dentro de un repo git"; exit 1; }

# Working tree limpio (recomendado, no obligatorio)
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠ working tree no está limpio:"
    git status --short
    echo
    read -p "¿Continuar de todos modos? [y/N] " yn
    case "$yn" in [Yy]*) ;; *) echo "Abortado."; exit 1;; esac
fi

OWNER=$(gh api user --jq .login)
echo "▸ Owner: $OWNER"
echo "▸ Repo:  $REPO_NAME"
echo "▸ Dom:   $DOMAIN"
echo

# ─── 1. _config.yml ────────────────────────────────────────────────────────
if [ ! -f _config.yml ]; then
    echo "▸ Creando _config.yml..."
    cat > _config.yml <<EOF
title: ashware
description: Metodología operacional para arquitectos de software que orquestan enjambres de LLMs.
url: "https://$DOMAIN"
baseurl: ""
lang: es

remote_theme: $REMOTE_THEME

plugins:
  - jekyll-remote-theme
  - jekyll-seo-tag
  - jekyll-sitemap

# Just the Docs settings
color_scheme: light
search_enabled: true
heading_anchors: true

aux_links:
  "GitHub":
    - "https://github.com/$OWNER/$REPO_NAME"

footer_content: "© 2026 Abner — ashware.org"

# Archivos del repo que no son páginas del sitio
exclude:
  - Gemfile
  - Gemfile.lock
  - vendor/
  - node_modules/
  - README.md
  - .gitignore
  - ashware-setup.sh
EOF
    echo "  ✓ _config.yml creado."
else
    echo "▸ _config.yml ya existe, no se toca."
fi

# ─── 2. .gitignore ─────────────────────────────────────────────────────────
if [ ! -f .gitignore ]; then
    echo "▸ Creando .gitignore..."
    cat > .gitignore <<'EOF'
_site/
.sass-cache/
.jekyll-cache/
.jekyll-metadata
vendor/
Gemfile.lock
.DS_Store
EOF
    echo "  ✓ .gitignore creado."
else
    echo "▸ .gitignore ya existe, no se toca."
fi

# ─── 3. Gemfile (para preview local opcional) ──────────────────────────────
if [ ! -f Gemfile ]; then
    echo "▸ Creando Gemfile..."
    cat > Gemfile <<'EOF'
source "https://rubygems.org"

gem "jekyll", "~> 4.3"
gem "just-the-docs"

group :jekyll_plugins do
  gem "jekyll-remote-theme"
  gem "jekyll-seo-tag"
  gem "jekyll-sitemap"
end
EOF
    echo "  ✓ Gemfile creado."
else
    echo "▸ Gemfile ya existe, no se toca."
fi

# ─── 4. CNAME ───────────────────────────────────────────────────────────────
if [ ! -f CNAME ]; then
    echo "▸ Creando CNAME..."
    echo "$DOMAIN" > CNAME
    echo "  ✓ CNAME creado: $DOMAIN"
else
    echo "▸ CNAME ya existe, no se toca."
fi

# ─── 5. about.md (plantilla) ────────────────────────────────────────────────
if [ ! -f about.md ]; then
    echo "▸ Creando about.md (plantilla — editar después)..."
    cat > about.md <<'EOF'
---
title: About
permalink: /about/
nav_order: 99
---

# Sobre Abner

> Plantilla — reemplaza este texto con tu bio.

Arquitecto de software con cuarenta años operando proyectos. Comenzó
en la computación a los dieciséis años. Ha visto crecer cada generación
de tecnología desde DOS y BASIC hasta los enjambres de LLMs que hoy
opera.

Escribe desde Barinas, Venezuela.

## Contacto

`tu-email@ashware.org`

## Por qué este sitio

[Una o dos frases sobre por qué publicas esto y para quién.]
EOF
    echo "  ✓ about.md creado (plantilla — edítalo cuando quieras)."
else
    echo "▸ about.md ya existe, no se toca."
fi

# ─── 6. Frontmatter en los docs ────────────────────────────────────────────
prepend_frontmatter() {
    local file="$1"
    local title="$2"
    local permalink="$3"
    local nav_order="$4"

    if [ ! -f "$file" ]; then
        echo "  ⚠ $file no existe, saltando."
        return
    fi

    if head -n 1 "$file" | grep -q '^---$'; then
        echo "  → $file ya tiene frontmatter, saltando."
        return
    fi

    local tmp
    tmp=$(mktemp)
    cat > "$tmp" <<EOF
---
title: $title
permalink: $permalink
nav_order: $nav_order
---

EOF
    cat "$file" >> "$tmp"
    mv "$tmp" "$file"
    echo "  ✓ frontmatter añadido a $file"
}

echo "▸ Añadiendo frontmatter a los documentos..."
prepend_frontmatter "docs/Proyecto_de_Proyectos_v1_6.md"        "Proyecto de Proyectos"                "/docs/proyecto/"          2
prepend_frontmatter "docs/General_Starter_Kit_v1_2.md"          "General Starter Kit"                  "/docs/starter-kit/"       3
prepend_frontmatter "docs/DeepSeek_Auditor_Integration_v1_2.md" "DeepSeek Auditor Integration"         "/docs/deepseek-auditor/"  4
prepend_frontmatter "docs/Prompt_Auditoria_Documentos_D_y_G.md" "Prompt — Auditoría de Documentos D+G" "/docs/auditoria-docs/"    5
prepend_frontmatter "docs/Prompt_Revision_de_Epica_con_O.md"    "Prompt — Revisión de Épica con O"     "/docs/revision-epica/"    6

# ─── 7. Excluir docs/README.md del sitio ───────────────────────────────────
if [ -f docs/README.md ]; then
    if ! head -n 1 docs/README.md | grep -q '^---$'; then
        echo "▸ Marcando docs/README.md como published: false..."
        tmp=$(mktemp)
        cat > "$tmp" <<'EOF'
---
published: false
---

EOF
        cat docs/README.md >> "$tmp"
        mv "$tmp" docs/README.md
        echo "  ✓ docs/README.md no aparecerá como página del sitio."
    else
        echo "▸ docs/README.md ya tiene frontmatter, no se toca."
    fi
fi

# ─── 8. Commit y push ──────────────────────────────────────────────────────
echo
echo "▸ Commiteando cambios..."
git add -A
if git diff --cached --quiet; then
    echo "  → nada que commitear (todo ya estaba como debía)."
else
    git commit -m "chore(site): scaffold Jekyll site (just-the-docs + SEO + CNAME)"
    echo "  ✓ commit creado."

    echo "▸ Pusheando a origin..."
    git push
    echo "  ✓ pusheado."
fi

# ─── 9. Habilitar GitHub Pages ──────────────────────────────────────────────
echo
echo "▸ Habilitando GitHub Pages..."
if gh api "repos/$OWNER/$REPO_NAME/pages" >/dev/null 2>&1; then
    echo "  → Pages ya estaba habilitado. Actualizando settings..."
    gh api -X PUT "repos/$OWNER/$REPO_NAME/pages" \
        -f "source[branch]=main" \
        -f "source[path]=/" >/dev/null
    echo "  ✓ Pages: rama main, raíz."
else
    gh api -X POST "repos/$OWNER/$REPO_NAME/pages" \
        -f "source[branch]=main" \
        -f "source[path]=/" >/dev/null
    echo "  ✓ Pages habilitado: rama main, raíz."
fi

# ─── 10. Resumen y siguientes pasos ────────────────────────────────────────
cat <<EOF

═══════════════════════════════════════════════════════════════════════
  Setup automatizado: completo.
═══════════════════════════════════════════════════════════════════════

Sitio temporal (mientras configuras DNS):
  https://$OWNER.github.io/$REPO_NAME

Lo que sigue es manual (fuera del alcance de gh):

1. CONFIGURAR DNS en tu registrar del dominio $DOMAIN.

   Apex ($DOMAIN) → 4 registros tipo A:
     185.199.108.153
     185.199.109.153
     185.199.110.153
     185.199.111.153

   Opcional, IPv6 → 4 registros tipo AAAA:
     2606:50c0:8000::153
     2606:50c0:8001::153
     2606:50c0:8002::153
     2606:50c0:8003::153

   Subdominio www → CNAME:
     www  →  $OWNER.github.io

2. (RECOMENDADO) VERIFICAR EL DOMINIO en GitHub para prevenir takeover:
     https://github.com/settings/pages
   Add a verified domain → $DOMAIN. Te dará un TXT que añades a tu DNS.

3. ESPERAR PROPAGACIÓN (15 min a 4 horas, hasta 24h en raros casos):
     dig $DOMAIN +noall +answer -t A
   Deben aparecer las 4 IPs de GitHub Pages.

4. ACTIVAR HTTPS cuando GitHub haya provisionado el cert
   (1-24h después de que DNS resuelva):
     gh api -X PUT "repos/$OWNER/$REPO_NAME/pages" -F https_enforced=true
   O en la UI: Settings → Pages → Enforce HTTPS.

5. (OPCIONAL) Preview local antes de pushear cambios futuros:
     bundle install
     bundle exec jekyll serve
   Sirve en http://localhost:4000.

═══════════════════════════════════════════════════════════════════════
EOF
