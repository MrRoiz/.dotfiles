# Design patterns

Use a known design pattern when the problem already has its shape, and declare
it so the next agent extends the design instead of working around it.

- **Pick by the problem, not by habit,** and only for a problem the code has
  today: the YAGNI and open/closed thresholds in `PRINCIPLES.md` decide when.
  Use the catalog's names
  (<https://refactoring.guru/design-patterns/catalog>) so every agent means
  the same thing. If no pattern fits the problem, don't force one; SOLID
  (`PRINCIPLES.md`) and the object rules in `MODULARITY.md` still shape the
  code.
  Flyweight only once memory is measured as the problem.
  Outside the catalog, Repository sits between domain logic and storage.
- **Prefer the language's idiom** for the pattern: a function value over a
  one-method Strategy or Command class, a dict of handlers over a Factory
  hierarchy, a generator over an Iterator class, language decorators or
  wrappers over Decorator classes.
- **Follow what is already there.** Before changing a file, read its pattern
  header and the project's instructions, and extend the declared pattern
  (add a strategy, register a handler) rather than bypass it. Do not introduce
  a second pattern for a job one already does.
- **Declare it in a top-of-file comment** on the file that owns the pattern
  (the interface, base, registry or entry point), right below any shebang or
  license header. Declare the patterns your change introduces or reshapes;
  don't add headers to files the change does not otherwise touch
  (`CHANGES.md`):
  ```python
  # Pattern: Strategy — each exporter implements `Exporter.export()`.
  # Extend: add a module in `exporters/` and register it in `REGISTRY` below.
  ```
  Name the pattern, this file's role in it, and how to extend it. A
  participant file (one strategy, one adapter) gets one line pointing to the
  owner: `# Pattern: Strategy (see exporters/base.py).`
- **Keep the header true.** When a change replaces, drops or reshapes the
  pattern, update or remove its header in the same change; a pattern used
  across the whole project goes once in its `AGENTS.md`/`CLAUDE.md` instead of
  in every file.
