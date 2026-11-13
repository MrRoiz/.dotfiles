# Configuration and constants

**One source of truth per fact** — DRY applied to configuration (see
`PRINCIPLES.md`). A constant, default, path, URL, colour, limit, keybinding, or
config key lives in exactly one place and is imported by everything that needs
it.

- **Centralize per domain.** Keep related values in one module (`config`,
  `constants`, `settings`) per domain, not scattered through the code. Never
  duplicate a literal so two copies can drift; never redefine a path or default
  locally.
- **Name your values.** No magic numbers or strings inline. A named constant
  states intent and is changed in one place.
- **Defaults live with the config.** Ship defaults in the config module and let
  callers override them; do not repeat the same fallback at each call site.
- **One config entry point.** Read configuration in one module, in one place;
  the rest of the code receives values (via parameters) rather than re-reading
  files or environment.
- **Secrets and machine-specific values stay out of tracked files.** Use
  environment variables or untracked local config, not inline literals; never
  commit credentials, tokens, or private paths.
- **Derive, don't repeat.** Compute values that depend on each other
  (paths from a root, dimensions from a base) instead of copying the result.
