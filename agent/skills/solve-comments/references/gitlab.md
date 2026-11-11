# GitLab commands

Use these when the remote is GitLab and `glab` is installed and authenticated.
Flags differ between `glab` versions: if a command rejects `--output json`, check
`glab <command> --help` and adapt rather than guessing.

The API takes the URL-encoded project path and the merge request's `iid`:

```bash
PROJECT_PATH=$(glab repo view --output json | jq -r .path_with_namespace)
PROJECT=$(printf '%s' "$PROJECT_PATH" | jq -sRr @uri)
IID=$(glab mr view --output json | jq -r .iid)
```

## Read the open discussions

An unresolved discussion is one that has a resolvable note and no resolved one,
the GitLab equivalent of a review thread:

```bash
glab api "projects/$PROJECT/merge_requests/$IID/discussions?per_page=100" \
  | jq '[.[]
         | select(any(.notes[]; .resolvable and (.resolved | not)))
         | {id, notes: [.notes[] | select(.system | not)
                        | {id, author: .author.username, body,
                           path: .position.new_path,
                           line: .position.new_line}]}]'
```

`id` is the discussion id to reply to and resolve. `system` notes are events
("changed this line"), not comments, and the filter drops them. `path` and
`line` are null on a discussion that is not attached to a diff line. Comments
outside any discussion come from `projects/$PROJECT/merge_requests/$IID/notes`
and have nothing to resolve.

## Reply and resolve

```bash
glab api --method POST \
  "projects/$PROJECT/merge_requests/$IID/discussions/$DISCUSSION/notes" \
  -f body='Fixed in src/parse.ts: the guard now rejects an empty list.'

glab api --method PUT \
  "projects/$PROJECT/merge_requests/$IID/discussions/$DISCUSSION?resolved=true"
```

Re-running the read command is the check that the threads you touched no longer
appear; `?resolved=false` undoes a wrong resolve.
