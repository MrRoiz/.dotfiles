# Configuration and constants

Each constant, default, path, URL, colour, limit, keybinding or config key has
one home, imported by everything that needs it.

- **Centralize per domain** in one module (`config`, `constants`, `settings`);
  never duplicate a literal or redefine a path or default locally.
- **Name values:** no magic numbers or strings inline.
- **Defaults live with the config;** callers override them instead of
  repeating a fallback at each call site.
- **One entry point** reads files and environment; the rest of the code
  receives values as parameters.
- **Secrets and machine-specific values stay untracked** (environment
  variables, untracked local config): never commit credentials, tokens or
  private paths.
- **Derive dependent values** (paths from a root, sizes from a base) instead of
  copying results.
