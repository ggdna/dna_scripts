# Changelog

## 0.2.0 - 2026-08-19

### Fixed

- `getRepoUrls` no longer hardcodes an unrelated organization. It takes
  the organization or user as a required argument instead of silently
  listing `rljson`'s repos regardless of the caller.
- The auth-failure check in `getRepoUrls` no longer throws a `TypeError`
  on any error other than "not logged in" — `String.match(...).length`
  crashes when the pattern does not match; replaced with `.includes(...)`.

## 0.1.0 - 2026-08-19

- First release. The node scripts a repo automates its workflow with,
  and the functions they share.
