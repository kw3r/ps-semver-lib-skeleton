# Versioned PS Library Skeleton

Template for building PS libraries with tag-based versioning. Master branch always has the latest code. Versions are managed through git tags and assembled automatically by a GitHub Action.

## Structure

```
src/init.lua          -- your lib code (edit this)
header.lua            -- PS library manifest
main.lua              -- version router, exposes _G.YourLib(ver)
.github/workflows/    -- action that assembles versions on tag push
```

## How it works

During development, `main.lua` loads your code directly from `src/init.lua` (dev mode). When you push a git tag, the GitHub Action checks out every tag, copies each version's `src/init.lua` into a `versions/` folder, generates an index, zips everything up, and uploads it to Sylvanas. Consumers then pick which version they want at runtime.

## Setup

1. Fork/copy this repo
2. Replace `src/init.lua` with your lib code (must return a table)
3. Update `header.lua` with your lib name, author, description
4. Update `LIB_NAME` in `main.lua` to match your lib name
5. Add these secrets to your GitHub repo (Settings > Secrets > Actions):

| Secret | Description |
|--------|-------------|
| `SYLVANAS_USERNAME` | Your Sylvanas username |
| `SYLVANAS_PASSWORD` | Your Sylvanas password |
| `SYLVANAS_PLUGIN_ID` | Your plugin ID (from plugin editor URL) |

## Releasing a version

```bash
git tag 1.0.0
git push --tags
```

That's it. The action picks up the tag, assembles all versions, and uploads to Sylvanas. No need to maintain version folders or branches.

## Consumer usage

```lua
-- caller name is required as first argument
local lib = ExampleLib("MyCoolPlugin", "1.0.0")   -- exact version
local lib = ExampleLib("MyCoolPlugin", "1")        -- latest within major 1 (e.g. 1.2.0)
local lib = ExampleLib("MyCoolPlugin")             -- latest overall (logs a warning)

lib:hello()
-- logs: [MyCoolPlugin > ExampleLib] Hello from version: 1.0.0
```

The caller name is required so that all log messages from the library include the name of the plugin/CR that uses it. This makes it easy to trace errors back to the consumer.

Different plugins can use different versions simultaneously -- each call returns its own instance with the caller identity attached.

## Versioning

This library uses [semver](https://semver.org/) (`MAJOR.MINOR.PATCH`):

- **PATCH** (`1.0.x`) — bug fixes, no API changes
- **MINOR** (`1.x.0`) — new features, backwards compatible
- **MAJOR** (`x.0.0`) — breaking changes

Since minor and patch updates are backwards compatible, consumers can request just a major version (e.g. `"1"`) to always get the latest compatible release. Only bump major when you introduce breaking changes.

## Tag format

Use semver without `v` prefix: `1.0.0`, `1.1.0`, `2.0.0`. If you use a `v` prefix (`v1.0.0`), the action strips it automatically.
