
▸ Verificando prerequisitos...
▸ Owner: abnerh69
▸ Repo:  ashware-site
▸ Dom:   ashware.org

▸ Creando _config.yml...
✓ _config.yml creado.
▸ .gitignore ya existe, no se toca.
▸ Creando Gemfile...
✓ Gemfile creado.
▸ Creando CNAME...
✓ CNAME creado: ashware.org
▸ Creando about.md (plantilla — editar después)...
✓ about.md creado (plantilla — edítalo cuando quieras).
▸ Añadiendo frontmatter a los documentos...
✓ frontmatter añadido a docs/Proyecto_de_Proyectos_v1_6.md
✓ frontmatter añadido a docs/General_Starter_Kit_v1_2.md
✓ frontmatter añadido a docs/DeepSeek_Auditor_Integration_v1_2.md
✓ frontmatter añadido a docs/Prompt_Auditoria_Documentos_D_y_G.md
✓ frontmatter añadido a docs/Prompt_Revision_de_Epica_con_O.md
▸ Marcando docs/README.md como published: false...
✓ docs/README.md no aparecerá como página del sitio.

▸ Commiteando cambios...
[main 831b446] chore(site): scaffold Jekyll site (just-the-docs + SEO + CNAME)
10 files changed, 102 insertions(+)
create mode 100644 CNAME
create mode 100644 Gemfile
create mode 100644 _config.yml
create mode 100644 about.md
✓ commit creado.
▸ Pusheando a origin...
Enumerating objects: 21, done.
Counting objects: 100% (21/21), done.
Delta compression using up to 8 threads
Compressing objects: 100% (12/12), done.
Writing objects: 100% (13/13), 2.31 KiB | 2.31 MiB/s, done.
Total 13 (delta 6), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (6/6), completed with 6 local objects.
To https://github.com/abnerh69/ashware-site.git
260f90a..831b446  main -> main
✓ pusheado.

▸ Habilitando GitHub Pages...
✓ Pages habilitado: rama main, raíz.

═══════════════════════════════════════════════════════════════════════
Setup automatizado: completo.
═══════════════════════════════════════════════════════════════════════

Sitio temporal (mientras configuras DNS):
https://abnerh69.github.io/ashware-site

Lo que sigue es manual (fuera del alcance de gh):

1. CONFIGURAR DNS en tu registrar del dominio ashware.org.

   Apex (ashware.org) → 4 registros tipo A:
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
   www  →  abnerh69.github.io

2. (RECOMENDADO) VERIFICAR EL DOMINIO en GitHub para prevenir takeover:
   https://github.com/settings/pages
   Add a verified domain → ashware.org. Te dará un TXT que añades a tu DNS.

3. ESPERAR PROPAGACIÓN (15 min a 4 horas, hasta 24h en raros casos):
   dig ashware.org +noall +answer -t A
   Deben aparecer las 4 IPs de GitHub Pages.

4. ACTIVAR HTTPS cuando GitHub haya provisionado el cert
   (1-24h después de que DNS resuelva):
   gh api -X PUT "repos/abnerh69/ashware-site/pages" -F https_enforced=true
   O en la UI: Settings → Pages → Enforce HTTPS.

5. (OPCIONAL) Preview local antes de pushear cambios futuros:
   bundle install
   bundle exec jekyll serve
   Sirve en http://localhost:4000.

═══════════════════════════════════════════════════════════════════════
