# Package

version = "0.1.0"
author = "Elijah Shaw-Rutschman"
description =
  "Motorola DSP56000 / DSP56300 24-bit fixed-point assembly and C code generator for the Omni DSL"
license = "MIT"
srcDir = "src"
bin = @["omni56k", "omnidsp"]

# Dependencies

requires "nim >= 1.6.0"
requires "cligen >= 1.5.0"

task test, "Run the test suite":
  exec "nim c -r tests/test_pipeline.nim"
