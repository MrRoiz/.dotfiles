# Organization

**Centralized, but modular.** Every fact has one obvious home; every module has
one job. Keep facts in one place (see `CONFIGURATION.md`) and units small and
loosely coupled (see `MODULARITY.md`).

- **Group by domain, not by type.** Files that change together live together.
  Do not create `utils/` dumping grounds, and do not split one feature across
  `models/`, `services/`, and `handlers/` folders unless the project already
  works that way.
- **Flat, obvious layout.** Put new files next to the things they belong with.
  Do not invent deep folder hierarchies or extra indirection layers; a
  directory should be understandable from its listing.
- **Prefer extending over creating.** Reuse the existing module for an existing
  responsibility. Add a new file only for a genuinely new responsibility, in
  the directory that already owns that domain.
- **One concept, one name.** Use the same term for the same thing everywhere
  (files, symbols, config keys, docs). Rename the stray outlier rather than
  adding an alias.
- **Mirror the project's existing conventions.** Match its layout, naming, and
  entry points instead of introducing a second style. When in doubt, the
  smaller, more obvious change wins.
- **No speculative structure.** Do not create empty layers, base classes, or
  "framework" folders for a single use. Structure follows real duplication and
  real growth (see YAGNI in `PRINCIPLES.md`).
