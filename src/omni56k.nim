# omni56k - Motorola DSP56000 / DSP56300 24-bit fixed-point assembly and C code generator for the Omni DSL

const projectVersion* = "0.0.1"

const greetingMsg* = "hello from omni56k"

proc hello*(): string =
  ## Returns standard project greeting string.
  greetingMsg

proc add*(a, b: int): int =
  ## Adds two integers.
  a + b
