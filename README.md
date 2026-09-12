# Hope Blog

Blog de tecnología: IA y deep learning, LLMs y RAG, ciencia de datos, desarrollo web y
sistemas/infraestructura. Construido con Astro y desplegado en Cloudflare Workers.

## Stack

| Herramienta | Versión | Uso |
|---|---|---|
| [Astro](https://astro.build) | 7.3.1 | Framework del sitio (output estático) |
| [Tailwind CSS](https://tailwindcss.com) | 4.3.3 | Estilos (vía `@tailwindcss/vite`) |
| [pnpm](https://pnpm.io) | 10.11.1 | Gestor de paquetes |
| [Node.js](https://nodejs.org) | 24.18.0 | Runtime de build |
| [Wrangler](https://developers.cloudflare.com/workers/wrangler/) | 4.129.0 | CLI de Cloudflare (dev local y deploy) |
| Sharp | — | Optimización de imágenes de `astro:assets` (requerido con pnpm) |
| Cloudflare Workers | — | Hosting (capa gratuita), build/deploy automático en cada push |

## Estructura del proyecto

```
hope-blog/
├── astro.config.mjs        # Configuración de Astro + integración Tailwind
├── wrangler.jsonc           # Configuración de Cloudflare Workers (sirve dist/ como static assets)
├── tsconfig.json
├── public/                  # Archivos estáticos servidos tal cual (favicons, etc.)
└── src/
    ├── content.config.ts    # Definición del content collection "posts" (schema con Zod)
    ├── layouts/
    │   └── Layout.astro     # Layout base: <head>, favicon, meta SEO (title/description por página)
    ├── pages/
    │   ├── index.astro      # Home: bienvenida, temas del blog, lista de posts
    │   ├── about.astro      # Página "sobre mí"
    │   └── posts/
    │       └── [...slug].astro   # Plantilla única que renderiza cualquier post del collection
    ├── content/
    │   └── posts/
    │       └── <slug-del-post>/
    │           ├── index.md         # Contenido del post (frontmatter + markdown)
    │           └── *.png            # Imágenes del post, referenciadas con rutas relativas
    ├── styles/
    │   └── global.css       # Import de Tailwind
    ├── components/           # Componentes reutilizables (vacío por ahora)
    └── assets/                # Assets procesados por Vite (vacío por ahora)
```

### Identidad visual

El sitio usa una estética de terminal/panel de sistema, coherente en todas las páginas:

- **Paleta:** fondo `slate-950`/`slate-900`, texto `slate-100`/`slate-300`, acento
  `teal-400` (enlaces, prompts), `amber-400` como acento puntual (cursor).
- **Tipografías:** `Space Grotesk` para títulos, `Inter` para cuerpo de texto,
  `JetBrains Mono` para todo lo funcional (comandos, rutas, nombres de categoría).
- Los bloques de comandos y el listado de "Temas"/"posts" en la home imitan una
  terminal (`whoami`, `ls`, directorios) en vez de tarjetas genéricas.

## Comandos

```bash
pnpm install          # instalar dependencias
pnpm dev               # servidor de desarrollo de Astro
pnpm build             # build de producción a dist/
pnpm wrangler dev      # servir dist/ simulando el entorno de Cloudflare
pnpm wrangler deploy   # desplegar manualmente a Cloudflare Workers
```

## Despliegue

El repositorio está conectado a Cloudflare Workers & Pages: cada `git push` a la rama
principal dispara un build (`pnpm build`) y despliegue automáticos. No hace falta correr
`wrangler deploy` a mano salvo para pruebas puntuales.

## Cómo agregar un post nuevo

1. Crea una carpeta con el slug del post dentro de `src/content/posts/`:

   ```bash
   mkdir src/content/posts/mi-nuevo-post
   ```

2. Dentro, crea `index.md` con el frontmatter requerido por el schema
   (`src/content.config.ts`):

   ```markdown
   ---
   title: "Título del post"
   description: "Descripción para SEO, 150-160 caracteres."
   pubDate: 2026-09-10
   category: "desarrollo-web"
   draft: false
   ---

   Contenido en markdown normal.
   ```

   `category` debe coincidir con uno de los slugs ya usados en la home
   (`ia-deep-learning`, `llms-rag`, `data-science`, `desarrollo-web`,
   `sistemas-infraestructura`) para mantener consistencia.

3. Si el post lleva imágenes, ponlas en la misma carpeta y referéncialas con ruta
   relativa: `![alt](./captura.png)`. Astro las optimiza automáticamente.

4. Usa `draft: true` para trabajar en un post sin publicarlo — no aparece en la home
   ni genera su página hasta que lo cambies a `false`.

No es necesario tocar `index.astro` ni `[...slug].astro`: ambos leen el collection
automáticamente, así que un post nuevo aparece en la lista de la home y genera su
propia URL (`/posts/<slug>`) solo con crear el archivo.

## OG images

Las imágenes OG (Open Graph) se generan automáticamente para cada post. Se crean en la carpeta `public/og/` y tienen el nombre del ID del post seguido de `.webp`.