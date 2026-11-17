# Architecture

## Goal
The page matches the visuals and behaviors of Coffee Clock while measuring source brevity. Unlike Rust/Wasm, the LiveScript program is compiled to ordinary JavaScript by `lsc`.

## Responsibilities
- `src/clock.ls`: time math, ring and particle Canvas rendering, browser event lifecycle
- `src/styles.css` and `index.html`: visual presentation
- `tests/clock.test.cjs`: deterministic pure-function tests
- `tests/browser-smoke.cjs`: run compiled JS in a simulated DOM and Canvas environment
- `package-lock.json`: pin the compiler's exact dependency tree
- `.github/workflows/`: validate develop / PRs; deploy both main and develop through one Pages artifact

## Behavior
- Use the browser's local time; Japanese date has no blank before the weekday.
- Hour/minute/second rings animate with milliseconds, based on the same geometry as Coffee Clock.
- Generate 60 random particles when the minute changes; never on the first frame.
- Cap each frame's elapsed duration at 50 ms; use devicePixelRatio no higher than 2.
- Stop animation while tab is hidden; on resume discard elapsed delta.
- With reduced-motion, remove particles and trails and advance seconds in whole steps.

## Build and publishing
`npm run check` compiles `src/clock.ls` into `dist/clock.js`, copies CSS, runs Node unit tests and a JavaScript/Canvas smoke test. `npm ci` uses the checked-in package-lock to keep builds reproducible.

GitHub Actions publishes production to `/livescript-clock-view/` and preview to `/livescript-clock-view/develop/`. When develop validation succeeds, the deploy workflow checks out the validated commit SHA; it ignores failed validation or pull_request runs. Pages source must be **GitHub Actions**.

## Fair source comparison
Count the lines in `src/clock.ls` and compare with `coffee-clock-view/src/clock.coffee`. Neither the generated JavaScript nor CSS should be counted. The implementation should preserve the same features, not delete functionality just to reduce line count.
