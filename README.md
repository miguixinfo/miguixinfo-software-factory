# miguixinfo Software Factory

Plantilla y quality gates para arrancar proyectos personales con IA sin perder el control.
Un proyecto nuevo sale con BMAD, arquitectura hexagonal, tests, cobertura mínima, contrato de API,
escaneo de seguridad, SonarQube y despliegue al VPS ya configurados.

## Cómo funciona

1. **Spec con BMAD.** Brief, PRD, arquitectura e historias en `docs/` del proyecto. Control humano 1: apruebas la spec.
2. **Construcción en paralelo.** Una historia, un worktree, una rama, una PR (Orca + Claude Code).
3. **Gates deterministas en CI.** El check `gate` agrupa todos los demás; si uno falla, la PR queda bloqueada.
4. **Merge.** Control humano 2: revisas y fusionas con squash. Release y despliegue son automáticos.

Los controles humanos se configuran por proyecto en `factory.yml` (`spec`, `story`, `merge`).

## Crear un proyecto

```bash
pipx install copier          # una vez
./scripts/new-project.sh ~/dev/mi-proyecto
```

El script pregunta tipo de proyecto (web full stack, solo API, solo web), paquete Java, cobertura mínima,
controles humanos y despliegue. Después crea el repo privado, las etiquetas y la protección de `main`.

## Traer un proyecto existente

```bash
cd ~/dev/proyecto-existente
/ruta/a/la/factory/scripts/adopt-project.sh
```

Añade las piezas de la factory en una rama sin tocar el código, para revisarlo en una PR.

## Versiones de la factory

- Cada merge a `main` actualiza una PR de release que abre release-please, con la próxima versión
  calculada a partir de los Conventional Commits (`fix` sube el parche, `feat` la menor, `feat!` la mayor) y su changelog.
- Al fusionar esa PR se crean el tag `vX.Y.Z` y la release, y el tag mayor (`v1`) se mueve a esa versión.
- Los proyectos apuntan a `@v1` (`factory_ref` en Copier): reciben arreglos y mejoras compatibles sin tocar nada.
  Un cambio incompatible sale como `v2`, y cada proyecto migra cuando quiera cambiando `@v1` por `@v2`.
- **Plantilla:** dentro de un proyecto, `copier update --trust` trae los cambios de la plantilla como diff para revisar.

## Qué hay dentro

| Ruta | Contenido |
| --- | --- |
| `copier.yml` | Preguntas de la plantilla |
| `template/` | El proyecto que se genera |
| `.github/workflows/backend-ci.yml` | Spotless, tests con Testcontainers, ArchUnit, JaCoCo y deriva del contrato |
| `.github/workflows/frontend-ci.yml` | ESLint, Prettier, TypeScript, Vitest con cobertura y build |
| `.github/workflows/api-contract.yml` | oasdiff (cambios incompatibles) y Spectral (estilo) |
| `.github/workflows/security.yml` | gitleaks, Semgrep CE y Trivy |
| `.github/workflows/sonar.yml` | SonarQube Cloud con espera al quality gate |
| `.github/workflows/deploy-vps.yml` | Imágenes en GHCR y Docker Compose en el VPS por SSH |
| `.github/workflows/template-ci.yml` | Genera los tres tipos de proyecto y comprueba que pasan sus gates |
| `scripts/` | Crear y adoptar proyectos |
| `docs/decisions.md` | Por qué la factory es como es |

## Stack de los proyectos

Java 25 + Spring Boot 4.1 + Maven, arquitectura hexagonal, PostgreSQL + Flyway, Spring Security propia,
springdoc. React + Vite + TypeScript estricto. Docker Compose + Caddy en Hetzner; Prometheus + Grafana.

## Configuración única de este repo

- **Settings → Actions → General → Access:** "Accessible from repositories owned by the user".
  Sin esto, los proyectos privados no pueden usar los workflows reutilizables de este repo privado.
- **Settings → Actions → General → Workflow permissions:** marca "Allow GitHub Actions to create and approve pull requests".
  Sin esto, release-please no puede abrir la PR de release.
- **Repos privados y protección de ramas:** en una cuenta personal Free, GitHub no aplica reglas de protección
  a repos privados. Con GitHub Pro (4 USD/mes) el check `gate` bloquea el merge de verdad; sin él solo lo marca en rojo.
