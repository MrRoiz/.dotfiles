# GitHub commands

Run these with `gh` authenticated for the remote. If a write is refused — a
permission or GraphQL error — report which threads are left rather than retrying.

## Identify the pull request

```bash
gh repo view --json nameWithOwner -q .nameWithOwner   # OWNER/REPO
gh pr view --json number,title,url                    # current branch's PR
```

Use the explicit number from the user when they give one: `gh pr view 123 …`.

## Read the open review threads

```bash
gh api graphql -f query='
  query ($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviewThreads(first: 100) {
          pageInfo { hasNextPage endCursor }
          nodes {
            id
            isResolved
            isOutdated
            path
            line
            comments(first: 50) {
              nodes { databaseId author { login } body createdAt }
            }
          }
        }
      }
    }
  }' -F owner=OWNER -F repo=REPO -F number=123 \
  --jq '.data.repository.pullRequest.reviewThreads.nodes
        | map(select(.isResolved == false))'
```

Each node's `id` is the thread to resolve and the last `databaseId` in
`comments` is the one to reply on. `line` is null when the comment sits on a
line the current diff no longer shows, so locate those by `path` and the comment
body. On `pageInfo.hasNextPage`, re-run with a `$cursor` argument and
`reviewThreads(first: 100, after: $cursor)`.

Conversation comments and review bodies carry requests too, and have no thread
to resolve:

```bash
gh pr view 123 --json comments --jq '.comments[]
  | {author: .author.login, body, createdAt}'
gh pr view 123 --json reviews --jq '.reviews[]
  | select(.body != "") | {author: .author.login, state, body}'
```

## Reply

Inline thread, on its newest comment:

```bash
gh api --method POST repos/OWNER/REPO/pulls/123/comments/COMMENT_ID/replies \
  -f body='Fixed in src/parse.ts: the guard now rejects an empty list.'
```

Conversation level, when there is no thread to resolve:

```bash
gh pr comment 123 --body='...'
```

## Resolve

```bash
gh api graphql -f query='
  mutation ($threadId: ID!) {
    resolveReviewThread(input: { threadId: $threadId }) {
      thread { id isResolved }
    }
  }' -F threadId=THREAD_ID
```

Re-running the read query is the check that every thread you touched now reports
`isResolved: true`. A wrong resolve is undone with `unresolveReviewThread` in
the same mutation shape.
