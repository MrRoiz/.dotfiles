# Modularity

Keep units small, focused, and loosely coupled. A module should be
understandable without reading its callers.

- **One responsibility per unit.** Every file, class, component and function
  addresses one thing. Split when one mixes unrelated concerns (UI + data +
  IO) or a file stops fitting on a screen or two. Use a one-line purpose
  statement for each; if it needs "and", split it. When new work is a
  different responsibility, give it its own file, class, component or
  function instead of growing an existing one; extend an existing unit only
  when the work is the same responsibility (see `ORGANIZATION.md`).
- **One job per function.** Split a function when its name needs "and", when it
  needs paragraphs of comments to explain, or when it nests more than a couple
  of levels. Prefer small named helpers over deep nesting.
- **Few, clear parameters.** A function takes at most two positional
  arguments, and only when the call reads clearly without them being named.
  Beyond that, or whenever an argument's meaning is not obvious at the call
  site, use named arguments or a single options object, so `fetch('test')`
  becomes `fetch(user_id=test_user_id)`. Never pass a bare literal whose
  meaning the reader has to guess (`retry(3, 500)`, `load('prod')`): pass it
  as a named argument or a named value (see `CONFIGURATION.md`).
  Do not add a boolean flag that switches what a function does; write two
  functions instead.
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
