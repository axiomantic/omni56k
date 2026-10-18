# omnidsp56300

**Motorola DSP56300 & C Compiler for the [Omni Audio DSL](https://github.com/vitreo12/omni)**

[![ci](https://github.com/axiomantic/omnidsp56300/actions/workflows/ci.yml/badge.svg)](https://github.com/axiomantic/omnidsp56300/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

`omnidsp56300` compiles standalone `.omni` DSP algorithms into:
1. **Motorola DSP56300 / DSP56311 24-bit fixed-point Assembly (`.asm`)** for hardware synthesizers and emulators (Access Virus, Nord Modular G2, Waldorf microQ).
2. **Self-contained C99/C11 code (`.c`)** for native and WebAssembly (WASM) execution.

Just as [`omnicollider`](https://github.com/vitreo12/omnicollider) compiles Omni code for SuperCollider and [`omnimax`](https://github.com/vitreo12/omnimax) compiles for Max/MSP, `omnidsp56300` is the dedicated backend targeting Motorola DSP56300 hardware.

---

## Features

- **24-bit Harvard Architecture Memory Mapping**:
  - `X:` Data Memory: Audio inputs, outputs, and module parameters.
  - `Y:` Data Memory: Filter state variables, circular ring delay buffers, and scratchpad.
  - `P:` Program Memory: Assembly instructions starting at `ORG P:$0100`.
- **Q23 Fractional Arithmetic**:
  - Full support for audio fractional values in the range `[-1.0, +0.99999988]`.
  - Automatic accumulator limiters and 56-bit saturation arithmetic (`sat24`).
- **Bit-Accurate Arithmetic & Approximations**:
  - Real 24-bit variable division via restoring shift-subtract algorithm.
  - Hardware-optimized 5th-order polynomials for `pow(2.0, x)`, `tan(x)`, `tanh(x)`, `sin(x)`, and `cos(x)`.
  - 64-sample circular ring buffers with modulo pointer wrapping for single-sample and modulated delay lines.
  - 24-bit Galois LFSR pseudo-random noise generator.
- **Relocatable Firmware Snippets (`-s, --snippet`)**:
  - Emits kernel snippets without ORG headers or symbol declarations, designed for direct dynamic loading into synthesis engines and firmware runtimes.
- **Clean C Code Generation (`-c, --compileC`)**:
  - Emits standalone, readable C99/C11 modules with zero runtime library dependencies.

---

## Installation

Install using Nimble:

```bash
nimble install https://github.com/axiomantic/omnidsp56300 -y
```

Both `omnidsp56300` and its alias `omnidsp` will be installed to your `~/.nimble/bin` directory.

---

## Usage

### Compile Omni to Motorola DSP56300 Assembly

```bash
omnidsp56300 MyFilter.omni
# Generates MyFilter.asm
```

### Compile Omni to Clean C

```bash
omnidsp56300 MyFilter.omni -c
# Generates MyFilter.c
```

### Emit Relocatable Firmware Kernel Snippet

```bash
omnidsp56300 MyFilter.omni --snippet -o MyFilter_snippet.asm
```

### CLI Options

```
omnidsp56300 [options] <file(s) or directory>

Options:
  -o=, --output=     ""        Output file path or name (defaults to input file with .asm or .c extension).
  --outDir=          ""        Output directory folder.
  -c, --compileC     false     Emit self-contained C code (.c) instead of DSP56300 assembly.
  -s, --snippet      false     Emit relocatable DSP56300 kernel snippet without ORG headers or symbol declarations.
  -p=, --pOrg=       "0x0100"  Program memory execution address in P: (default 0x0100).
  --paramBase=       "0x0020"  Parameter base address in X: (default 0x0020).
  --stateBase=       "0x0000"  State variables base address in Y: (default 0x0000).
  -d=, --delayBase=  "0x0400"  Circular delay buffer base address in Y: (default 0x0400).
  --scratchBase=     "0x0300"  Temporary scratch base address in Y: (default 0x0300).
  -v, --version                Print version information.
```

---

## Verification & Testing

`omnidsp56300` includes a test suite with 50+ Nord Modular G2 DSP module fixtures tested directly against the [dsp56300-nim](https://github.com/elijahr/dsp56300-nim) hardware simulation core:

```bash
nimble test
```

Tested modules include:
- Oscillators: `OscA`, `OscB` (PWM), `OmniSine`, `OmniSaw`, `OscNoise`
- Filters: `FltLP`, `FltHP`, `FltMulti`, `FltNord`, `FltComb`, `OmniSVF`
- Envelopes & Dynamics: `EnvADSR`, `EnvAHD`, `EnvFollow`, `Compressor`
- Effects & Shapers: `Phaser`, `Reverb`, `RingMod`, `DelaySingle`, `ShaperClip`, `ShaperOverdrive`
- Logic & Routing: `LogicClkDiv`, `LogicFlipFlop`, `LogicCounter`, `SwSH`, `Mxr4_1`, `Pan`

---

## License

MIT License. Copyright (c) 2026 Axiomantic & Omni Contributors.
