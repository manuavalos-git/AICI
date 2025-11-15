# 🏭 Simulador Industrial 3D - Deployment

Este proyecto se despliega automáticamente en GitHub Pages usando GitHub Actions.

## 🚀 Proceso de Deployment

1. Haz cambios en tu rama
2. Crea un Pull Request a `master`
3. Una vez aprobado y mergeado:
   - GitHub Actions exporta el proyecto Godot a Web automáticamente
   - Se despliega en GitHub Pages
   - URL disponible en: `https://manuavalos-git.github.io/3DAIRE/`

## 📋 Configuración de GitHub Pages

Para activar GitHub Pages en tu repositorio:

1. Ve a: **Settings** → **Pages**
2. En **Source**, selecciona: **GitHub Actions**
3. Guarda los cambios

## 🔧 Variables de Entorno (Opcional)

Para proteger tu API key de Gemini, puedes usar GitHub Secrets:

1. Ve a: **Settings** → **Secrets and variables** → **Actions**
2. Agrega un nuevo secret: `GEMINI_API_KEY`
3. El workflow lo usará automáticamente

## 📝 Archivos Importantes

- `.github/workflows/deploy-godot.yml` - Workflow de CI/CD
- `export_presets.cfg` - Configuración de exportación de Godot
- `project.godot` - Configuración del proyecto

## ⚡ Triggers del Workflow

El deployment se ejecuta cuando:
- Se hace push a la rama `master`
- Se mergea un Pull Request a `master`
- Manualmente desde la pestaña "Actions" en GitHub

## 🐛 Troubleshooting

Si el deployment falla:
1. Revisa los logs en la pestaña **Actions**
2. Verifica que `export_presets.cfg` existe
3. Asegúrate de que no hay errores en el proyecto Godot
4. Confirma que GitHub Pages está habilitado en Settings

## 📊 Estado del Deployment

[![Deploy Status](https://github.com/manuavalos-git/3DAIRE/actions/workflows/deploy-godot.yml/badge.svg)](https://github.com/manuavalos-git/3DAIRE/actions/workflows/deploy-godot.yml)

## 🔗 Enlaces Útiles

- **Sitio Web**: https://manuavalos-git.github.io/3DAIRE/
- **Repositorio**: https://github.com/manuavalos-git/3DAIRE
- **Actions**: https://github.com/manuavalos-git/3DAIRE/actions
