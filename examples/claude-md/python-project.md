# Project Instructions

## Build & Test

- Package manager: `uv` (not pip)
- Run tests: `uv run pytest`
- Run single test: `uv run pytest tests/test_foo.py::test_bar -v`
- Lint: `uv run ruff check .`
- Format: `uv run ruff format .`
- Type check: `uv run pyright`

## Code Style

- Python 3.12+, use modern syntax (match statements, type unions with `|`)
- Use `pathlib.Path` over `os.path`
- Prefer dataclasses or Pydantic models over raw dicts
- Type annotations on all public functions
- No docstrings on obvious methods — only where the logic isn't self-evident

## Project Structure

- Source code in `src/<package>/`
- Tests mirror source: `tests/test_<module>.py`
- Config in `pyproject.toml` (not setup.py)

## Git

- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
- One logical change per commit
- Always run tests before committing
