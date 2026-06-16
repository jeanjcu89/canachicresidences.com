# Cana Chic Residences — Website

Static one-page site. No build step required.

## Files
- `index.html` — the site (entry point)
- `styles.css` — styles
- `assets/` — images and video referenced by the site
- `CNAME` — custom domain for GitHub Pages (`canachicresidences.com`)

## Deploy on GitHub Pages
1. Create the repo and push these files to the `main` branch (repo root).
2. In **Settings → Pages**, set **Source** to `Deploy from a branch`, branch `main`, folder `/ (root)`.
3. Under **Custom domain**, `canachicresidences.com` will be picked up from the `CNAME` file.
4. Point your domain's DNS at GitHub Pages:
   - `A` records for the apex domain → `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
   - or a `CNAME` record for `www` → `jeanjcu89.github.io`
5. Enable **Enforce HTTPS** once the certificate is issued.

The site uses Google Fonts via CDN (needs internet); everything else is local.
