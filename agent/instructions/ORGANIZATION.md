# Organization

**Centralized, but modular.** Every fact has one obvious home; every module has
one job. Keep facts in one place (see `CONFIGURATION.md`) and units small and
loosely coupled (see `MODULARITY.md`).

- **Group by domain, not by type.** Files that change together live together.
  Do not create `utils/` dumping grounds. When the project already splits code
  by type (`models/`, `services/`, `handlers/`), keep that structure: when a
  new feature or module (or a change the developer asks for) needs more than
  one file in a type folder, give it its own one-level sub-folder inside that
  folder (`services/reports/`) instead of loose files beside the rest. The
  sub-folder only groups the feature's files; it is not a new top-level domain
  and it does not hold every layer. Leave existing code where it is unless
  asked to move it.
- **Flat, obvious layout.** Put new files next to the things they belong with.
  Do not invent deep folder hierarchies or extra indirection layers; a
  directory should be understandable from its listing.
- **A file reads top-down.** Group imports the way the project does
  (standard library, third-party, local), then constants, then public entry
  points, then their helpers in the order they are called. Keep related code
  next to each other so a reader never jumps around the file.
- **Prefer extending over creating.** Reuse the existing module for an existing
  responsibility. Add a new file only for a genuinely new responsibility, in
  the directory that already owns that domain.
- **No loose functions beside a file's responsibility.** A file holds only
  what its one responsibility is; a function that does a different job goes
  where it belongs, never loose beside it:
  - used only by one unit: a private part of that unit;
  - used only by one file, with a job of its own: a sibling file next to it,
    named for that job;
  - used from more than one place: one shared home in the module that owns
    its domain, imported by every caller (see "Shared helpers live below their
    consumers" in `MODULARITY.md`), never a `utils/` file.
  Never import a function out of a file whose responsibility is something
  else: move it to its shared home first.
- **One concept, one name.** Use the same term for the same thing everywhere
  (files, symbols, config keys, docs). Rename the stray outlier rather than
  adding an alias.
- **Mirror the project's existing conventions.** Match its layout, naming, and
  entry points instead of introducing a second style; a feature's sub-folder
  inside a type folder (above) follows that structure, it does not replace it.
  When in doubt, the smaller, more obvious change wins.
- **No speculative structure.** Do not create empty layers, base classes, or
  "framework" folders for a single use. Structure follows real duplication and
  real growth (see YAGNI in `PRINCIPLES.md`).
