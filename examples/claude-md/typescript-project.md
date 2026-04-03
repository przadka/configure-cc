# Project Instructions

## Build & Test

- Package manager: `pnpm`
- Build: `pnpm build`
- Run tests: `pnpm test`
- Run single test: `pnpm test -- --grep "test name"`
- Lint: `pnpm lint`
- Type check: `pnpm tsc --noEmit`

## Code Style

- TypeScript strict mode, no `any` types
- Prefer `const` over `let`, never use `var`
- Use early returns over nested conditionals
- Named exports over default exports
- Prefer interfaces over type aliases for object shapes
- Error handling: throw typed errors, catch at boundaries

## Project Structure

- Source in `src/`, tests in `src/__tests__/` or colocated `*.test.ts`
- Shared types in `src/types/`
- API handlers in `src/api/`

## Git

- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
- One logical change per commit
- Run `pnpm lint && pnpm tsc --noEmit` before committing
