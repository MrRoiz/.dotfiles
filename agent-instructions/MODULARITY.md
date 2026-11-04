# Modularity

Keep units small, focused, and loosely coupled. A module should be
understandable without reading its callers.

- **One responsibility per file.** Split when a file mixes unrelated concerns
  (UI + data + IO) or stops fitting on a screen or two. Use a one-line purpose
  statement for each module; if it needs "and", split it.
- **One job per function.** Split a function when its name needs "and", when it
  needs paragraphs of comments to explain, or when it nests more than a couple
  of levels. Prefer small named helpers over deep nesting.
- **Group related functions into one context.** When a lot of standalone
  functions share the same state, arguments, or domain, prefer a single object
  that holds them over a flat list of loose functions. Expose only the public
  methods that make sense for that context; keep the rest private so the object
  encapsulates its own state. Follow the project's existing pattern for such
  objects and scope them to what they serve (a session, a request, an open
  connection) rather than making them global. Functions that share nothing stay
  plain functions, and one object holds one context: split it when its public
  methods stop belonging together.
- **Clear dependency direction.** Lower-level modules do not import
  higher-level ones; no cycles. Shared helpers live below their consumers.
- **Narrow public surface.** Export only what consumers need; keep helpers
  private. Barrel/index files are fine when they simplify imports, never to
  hide a tangled layout.
- **Explicit inputs and outputs.** Pass dependencies in rather than reaching
  for globals or singletons; keep side effects at the edges of the unit.
- **Stable seams.** Depend on the smallest interface that does the job. Do not
  couple modules through shared mutable state or by reaching into internals.
- **No premature abstraction.** Create an interface, base class, or generic
  when a second real caller needs it, not before (see YAGNI in
  `PRINCIPLES.md`).
