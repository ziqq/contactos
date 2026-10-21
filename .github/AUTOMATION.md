# Repository automation

This repository uses reusable actions pinned to
`ziqq/actions@ccd1a799683cd461a45d9303ac6fcb2792f8f5d2`.

## CI

`.github/workflows/checkout.yml` runs on pushes to `main`, pull requests to
`main` and manual dispatch. The toolchain comes from `mise.toml` through
`jdx/mise-action`, so CI uses the same Flutter and Java as local development.

| Job | What it checks |
|---|---|
| `Package (<name>)` | For each package: format (`make format-check`), analyzer with fatal infos for the package and its example, `dependency_validator`, `pub publish --dry-run`, unit tests with a test report and Codecov upload (flag = package name) |
| `Android build` | Builds the `contactos_android` example APK and runs the JVM tests with JaCoCo coverage (flag `android`) |
| `iOS build (CocoaPods)` / `iOS build (SPM)` | Builds the `contactos_foundation` example for the simulator with each dependency manager and runs XCTest with Swift coverage (flag `ios`) |
| `Notify CI result` | Sends the result to Discord and Telegram (see below) |

Codecov flags and their paths are defined in `codecov.yml`.

## Publishing

`.github/workflows/publish.yml` runs when a package tag is pushed:
`contactos-v<version>`, `contactos-android-v<version>`,
`contactos-foundation-v<version>` or `contactos-platform-interface-v<version>`.

1. `prepare` maps the tag to the package directory and requires the tag, the
   pubspec version and the first `CHANGELOG.md` entry to match.
2. `publish` validates format, analyzer, tests and a pana score of at least
   `MIN_PANA_SCORE` (150), then publishes with pub.dev automated publishing.
   Authentication uses the GitHub OIDC token from `dart-lang/setup-dart`; no
   pub credentials are stored in the repository secrets.
3. `release` creates a GitHub release named `<package> <version>` with the
   CHANGELOG entry as notes.
4. `complete-issues` applies the `release-completed` label transition, because
   releases created with `GITHUB_TOKEN` do not trigger the labels workflow.
5. `notify` reports the result with `.github/notify/templates/release.md`.

One-time setup on pub.dev for every package: **Admin → Automated publishing →
Enable publishing from GitHub Actions**, repository `ziqq/contactos`, tag
pattern `<tag prefix>{{version}}` (for example `contactos-android-v{{version}}`).
The old `PUB_CREDENTIAL_JSON` secret is no longer used and can be deleted.

## Semantic labels

`.github/labels.json` is the repository-owned source of truth. Automation uses
stable semantic IDs while GitHub displays configurable names:

| Semantic ID | Visible label |
|---|---|
| `bug` | `bug` |
| `documentation` | `documentation` |
| `completed` | `done` |
| `duplicate` | `duplicate` |
| `help_wanted` | `help wanted` |
| `improvement` | `improvement` |
| `needs_testing` | `need test's` |
| `new_feature` | `new feature` |
| `waiting_for_release` | `waiting for publish` |
| `waiting_for_pull_request` | `waiting for pull request` |
| `waiting_for_response` | `waiting for response` |
| `in_progress` | `working in progress` |

The initial names, colors, and descriptions come from
`flutter_in_store_app_version_checker`. Existing repository-specific labels
are preserved because `sync.orphanPolicy` is `keep`.

Lifecycle transitions:

- a `github-<number>` branch starts work and links the branch to the issue;
- opening a linked pull request keeps the issue in progress;
- merging into `main` moves linked issues to `waiting for publish`;
- publishing a GitHub release moves matching issues to `done`;
- an author or assignee response resumes only an issue already marked
  `waiting for response`;
- manually assigning lifecycle labels normalizes mutually exclusive states;
- Markdown and test changes add their configured path labels to pull requests.

## Manual plan and apply

Run the `Semantic labels` workflow from the Actions tab. Manual runs default to
`sync-labels` with `dry_run: true`. Review the `plan` output before rerunning
with dry-run disabled. `apply` additionally requires a transition, target kind,
and comma-separated target numbers.

Pattern removal and label deletion are separate explicit inputs. The current
configuration never deletes unmanaged labels. Do not enable deletion without a
reviewed dry-run: deleting a GitHub label removes it from every issue and pull
request.

## Trust and concurrency

Pull request automation runs on `pull_request_target`, but the action reads the
configuration from the trusted base SHA through the GitHub API. No pull request
head code is checked out with a write token. The workflow serializes label
operations and does not cancel an in-progress transition.

The first pull request introducing this workflow cannot execute its own new
write-capable configuration. After merge, run one manual label sync; following
events will use the trusted default-branch file.
## Notifications

`.github/workflows/notifications.yml` calls
`ziqq/actions/.github/workflows/notify-events.yml@7737ce8c4d87c656b7ccf5f78138d8d7e53a1b62`
to send required Discord and Telegram notifications for newly opened issues
and pull requests (including drafts and forks)
opened by anyone other than the repository owner.

Both events are explicitly enabled here with `notify-issues: true` and
`notify-pull-requests: true`. Set either input to `false` to disable that event;
the reusable workflow defaults both inputs to `false`. Edits, reopened items,
and draft-to-ready changes do not send another notification.

Templates belong to this repository: `.github/notify/templates/issue.md` and
`.github/notify/templates/pull-request.md`. Pull request notifications use
`pull_request_target` and check out only the trusted base SHA, never PR-head
code with repository secrets.

The final `notify` job in `.github/workflows/checkout.yml` runs after every CI
result on pushes, manual runs, and same-repository pull requests. Fork and
Dependabot pull requests are skipped because GitHub does not expose repository
secrets to them. CI delivery is best-effort and cannot change the result of the
actual checks. A whole workflow canceled by concurrency may stop before the
notification job starts.

Configure these repository Actions secrets:

| Secret | Value |
|---|---|
| `DISCORD_WEBHOOKS` | JSON object with a target list, for example `{"targets":[{"url":"https://discord.com/api/webhooks/..."}]}` |
| `TELEGRAM_BOT_TOKEN` | Token issued by BotFather |
| `TELEGRAM_TARGETS` | JSON object with a target list, for example `{"targets":[{"chatId":"123456789"}]}` |

To obtain a Telegram `chatId`, send the bot a message and call the official Bot
API `getUpdates` method. Read `message.chat.id`; channel updates use
`channel_post.chat.id`. A forum topic can add `"threadId":"42"` to the target.
`getUpdates` is unavailable while the bot has an outgoing webhook configured.
Never commit or paste the bot token, webhook URL, or target list into workflow
files.

All templates live in `.github/notify/templates/`. Dynamic issue titles are
escaped by the action. Delivery uses a 10-second per-request timeout and at
most five attempts for retryable failures. Logs and outputs contain neither
credentials, target identifiers, nor rendered message bodies.
