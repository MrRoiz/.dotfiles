# Modularity

Units are small, focused and loosely coupled; a module is understandable
without reading its callers.

- **Size.** Split a file, class, component or function that mixes concerns
  (UI + data + IO), outgrows a screen or two, needs paragraphs of comments, or
  nests more than a couple of levels; prefer small named helpers. New work with
  a different responsibility gets its own unit.
- **Parameters.** At most two positional arguments, and only when the call
  reads clearly without names; otherwise named arguments or an options object
  (`fetch(user_id=test_user_id)`, not `fetch('test')`). No bare literal the
  reader must guess (`retry(3, 500)`, `load('prod')`) — name it. No boolean
  flag that switches behaviour: write two functions.
- **One object per shared context.** Functions sharing state, arguments or a
  domain become one object scoped to what they serve (a session, a request, a
  connection), not a global, following the project's pattern. Only methods
  that make sense for that context are public. Unrelated functions stay plain;
  split an object whose public methods stop belonging together.
- **Dependencies point down.** Lower-level modules never import higher-level
  ones; no cycles.
- **Narrow seams.** Export only what consumers need; depend on the smallest
  interface that works, never on shared mutable state or another module's
  internals. Barrel/index files only to simplify imports, never to hide a
  tangled layout.
- **Explicit inputs and outputs.** Pass dependencies in instead of using
  globals or singletons; keep side effects at the unit's edges.
