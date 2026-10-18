# MIT License
# Copyright (c) 2026 Elijah Shaw-Rutschman
# Alias launcher for omni56k

import cligen
import omni56k

when isMainModule:
  clCfg.version = version_flag
  clCfg.helpSyntax = ""
  let arguments = "Arguments:\n  Omni file(s) or directory."
  clCfg.hTabCols = @[clOptKeys, clDflVal, clDescrip]

  dispatch(
    omnidsp_main,
    cmdName = "omnidsp",
    noHdr = true,
    usage = version_flag & "\n\n" & arguments & "\n\nOptions:\n$options",
    short = {
      "version": 'v',
      "output": 'o',
      "compileC": 'c',
      "snippet": 's'
    },
    help = {
      "help": "CLIGEN-NOHELP",
      "version": "CLIGEN-NOHELP",
      "output": "Output file path or name (defaults to input file with .asm or .c extension).",
      "outDir": "Output directory folder.",
      "compileC": "Emit self-contained C code (.c) instead of DSP56300 assembly.",
      "snippet": "Emit relocatable DSP56300 kernel snippet without ORG headers or symbol declarations.",
      "pOrg": "Program memory execution address in P: (default 0x0100).",
      "paramBase": "Parameter base address in X: (default 0x0020).",
      "stateBase": "State variables base address in Y: (default 0x0000).",
      "delayBase": "Circular delay buffer base address in Y: (default 0x0400).",
      "scratchBase": "Temporary scratch base address in Y: (default 0x0300)."
    }
  )
