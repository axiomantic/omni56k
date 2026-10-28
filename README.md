# omni56k

[![CI](https://github.com/axiomantic/omni56k/actions/workflows/ci.yml/badge.svg)](https://github.com/axiomantic/omni56k/actions/workflows/ci.yml)

[![Release](https://img.shields.io/github/v/release/axiomantic/omni56k)](https://github.com/axiomantic/omni56k/releases/latest)
[![License](https://img.shields.io/github/license/axiomantic/omni56k)](LICENSE)
[![Nim](https://img.shields.io/badge/Nim-2.2%2B-yellow.svg)](https://nim-lang.org)

Motorola DSP56000 / DSP56300 24-bit fixed-point assembly and C code generator for the Omni DSL

## Quick Start

```nim
import omni56k

echo hello()
```

## Development

The `justfile` is the canonical command surface for common tasks:

```bash
just setup        # Install dependencies
just test         # Run test suite
just lint         # Check formatting (nph) and nimble check
just fmt          # Auto-format codebase with nph

just build        # Build release artifacts
```

## Upstream Updates

This project was initialized via [Polyform](https://github.com/axiomantic/polyform). To update boilerplate, CI workflows, and tooling from upstream:

```bash
uvx copier update --trust
```
