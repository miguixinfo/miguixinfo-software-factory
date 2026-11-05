# Decisiones de la factory

Registro corto de por qué la factory es como es. Una decisión nueva va arriba.

| Fecha | Decisión | Motivo |
| --- | --- | --- |
| 2026-11-05 | Factory "iluminada": controles humanos en spec y merge, configurables en `factory.yml` | Dar a los agentes solo la autonomía que se puede verificar barato. Se amplía bucle a bucle. |
| 2026-11-05 | Copier en vez de template repo de GitHub | `copier update` lleva las mejoras de la plantilla a proyectos ya creados. |
| 2026-11-05 | Workflows reutilizables en este repo; los proyectos solo los llaman | Un ajuste en un gate llega a todos los proyectos. Una sola fuente de verdad. |
| 2026-11-05 | Un único check requerido, `gate`, que agrupa al resto | La protección de ramas no cambia al añadir o quitar gates. |
| 2026-11-05 | Monorepo por producto (`backend/`, `frontend/`, `infra/`, `docs/`) | Una historia full stack es un worktree y una PR; el agente ve contrato y ambos lados. |
| 2026-11-05 | Hexagonal por módulo, comprobada con ArchUnit | Las reglas de arquitectura las hace cumplir el build, no la memoria del agente. |
| 2026-11-05 | Contrato code-first con springdoc, versionado en `docs/api/openapi.json` | Contract-first frenaba el flujo. Versionarlo hace visible el cambio en cada PR y permite oasdiff. |
| 2026-11-05 | Cobertura mínima 80% en líneas y ramas, exigida por JaCoCo y Vitest | No depende solo de Sonar, que en el plan gratuito no permite personalizar el quality gate. |
| 2026-11-05 | Seguridad con gitleaks, Semgrep CE y Trivy | Gratuitas en repos privados. CodeQL y el secret scanning de GitHub cuestan 30 y 19 USD al mes por committer. |
| 2026-11-05 | SonarQube Cloud gratuito, opcional por proyecto (`SONAR_TOKEN`) | Gratis en privado hasta 50.000 líneas por organización, con AI Code Assurance. |
| 2026-11-05 | Despliegue con GHCR + Docker Compose + Caddy en el VPS de Hetzner | Infraestructura que ya existe, HTTPS automático, sin coste extra. |
| 2026-11-05 | Prometheus + Grafana en el VPS, Grafana solo por túnel SSH | Observabilidad sin coste ni exposición pública. |
