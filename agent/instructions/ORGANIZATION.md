# Organization

- **Group by domain, not by type.** Files that change together live together;
  no `utils/` dumping grounds. A feature or job that needs more than one file in
  a folder gets a one-level sub-folder there (`<type>/<feature>/`,
  `<domain>/<job>/`), and its existing files move in. In a project split by
  type (`models/`, `services/`), keep that split: the sub-folder groups one
  feature's files inside one type folder, not every layer. Leave unrelated code
  where it is unless asked.
- **Flat, obvious layout.** New files sit next to what they belong with; no
  deep hierarchies. A directory should explain itself from its listing.
- **Files read top-down:** imports (grouped the project's way), constants,
  public entry points, then helpers in call order, related code together.
- **Extend before creating.** Reuse the module that owns a responsibility; add
  a file only for a new responsibility, in the directory owning that domain.
- **Nothing loose beside a file's responsibility.** A function with another job
  lives as a private part of the one unit that uses it; as a sibling file named
  for its job when one file uses it; or, when several places use it, in one
  shared home in the module owning its domain, below its consumers — never a
  `utils/` file. Never import a function from a file whose job is something
  else; move it to its shared home first.
- **One concept, one name** across files, symbols, config keys and docs; rename
  the outlier instead of adding an alias.
- **Mirror the project's conventions** (layout, naming, entry points) instead
  of adding a second style. When in doubt, the smaller, more obvious change
  wins.
