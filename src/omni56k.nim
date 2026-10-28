# MIT License
# 
# Copyright (c) 2026 Elijah Shaw-Rutschman & Omni Contributors
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os, strutils, parseutils
import omni56k/[ast, emitter_asm, emitter_c]

export ast, emitter_asm, emitter_c

const
  Omni56kVersion* = "0.1.0"
  OmniDspVersion* = Omni56kVersion
  version_flag* =
    "omni56k - version " & Omni56kVersion &
    "\nMotorola DSP56000 / DSP56300 & C Compiler for the Omni DSL\n(c) 2026 Elijah Shaw-Rutschman"

when not defined(emscripten) and not defined(wasm32):
  import cligen, terminal

  template printError(msg: string): untyped =
    setForegroundColor(fgRed)
    writeStyled("ERROR: ", {styleBright})
    setForegroundColor(fgWhite, true)
    writeStyled(msg & "\n")

  template printDone(msg: string): untyped =
    setForegroundColor(fgGreen)
    writeStyled("SUCCESS: ", {styleBright})
    setForegroundColor(fgWhite, true)
    writeStyled(msg & "\n")

else:
  template printError(msg: string): untyped =
    echo "ERROR: " & msg

  template printDone(msg: string): untyped =
    echo "SUCCESS: " & msg

proc parseHexOrInt(s: string, defaultVal: uint32): uint32 =
  if s.isEmptyOrWhitespace:
    return defaultVal
  var clean = s.strip()
  if clean.startsWith("$"):
    clean = clean[1 ..^ 1]
  elif clean.startsWith("0x") or clean.startsWith("0X"):
    clean = clean[2 ..^ 1]
  var val: uint64 = 0
  if parseHex(clean, val) > 0:
    return uint32(val)
  try:
    return uint32(parseUInt(s))
  except:
    return defaultVal

proc compileFile(
    fileFullPath: string,
    outName: string = "",
    outDir: string = "",
    compileC: bool = false,
    snippet: bool = false,
    pOrg: string = "0x0100",
    paramBase: string = "0x0020",
    stateBase: string = "0x0000",
    delayBase: string = "0x0400",
    scratchBase: string = "0x0300",
): int =
  if not fileFullPath.fileExists():
    printError("File '" & fileFullPath & "' does not exist.")
    return 1

  let (dir, name, ext) = splitFile(fileFullPath)
  if ext != ".omni" and ext != ".oi":
    printError("File '" & fileFullPath & "' is not an Omni file (.omni / .oi).")
    return 1

  var targetDir = if outDir != "": outDir else: dir
  if targetDir == "":
    targetDir = getCurrentDir()
  targetDir = targetDir.normalizedPath().expandTilde().absolutePath()

  if not dirExists(targetDir):
    createDir(targetDir)

  var m: OmniModule
  try:
    m = parseOmniFile(fileFullPath)
  except Exception as e:
    printError("Failed parsing '" & fileFullPath & "': " & e.msg)
    return 1

  if compileC:
    let cCode = emitC(m)
    var cOutName =
      if outName != "":
        outName
      else:
        name & ".c"
    if not cOutName.endsWith(".c"):
      cOutName.add(".c")
    let targetPath = targetDir / cOutName
    writeFile(targetPath, cCode)
    printDone("'" & cOutName & "' generated to \"" & targetDir & "\".")
    return 0

  var addrs = defaultDsp56300Addresses()
  addrs.pOrg = parseHexOrInt(pOrg, 0x0100'u32)
  addrs.paramBase = parseHexOrInt(paramBase, 0x0020'u32)
  addrs.stateBase = parseHexOrInt(stateBase, 0x0000'u32)
  addrs.delayBase = parseHexOrInt(delayBase, 0x0400'u32)
  addrs.scratchBase = parseHexOrInt(scratchBase, 0x0300'u32)

  let asmCode =
    if snippet:
      compileOmniSnippet(m, addrs, m.name, stageAll)
    else:
      emitDsp56300Asm(m)

  var asmOutName =
    if outName != "":
      outName
    else:
      name & ".asm"
  if not asmOutName.endsWith(".asm"):
    asmOutName.add(".asm")
  let targetPath = targetDir / asmOutName
  writeFile(targetPath, asmCode)
  printDone("'" & asmOutName & "' generated to \"" & targetDir & "\".")
  return 0

proc omni56k_main*(
    files: seq[string],
    output: string = "",
    outDir: string = "",
    compileC: bool = false,
    snippet: bool = false,
    pOrg: string = "0x0100",
    paramBase: string = "0x0020",
    stateBase: string = "0x0000",
    delayBase: string = "0x0400",
    scratchBase: string = "0x0300",
): int =
  if files.len == 0:
    echo version_flag
    return 0

  var effOutName = output
  var effOutDir = outDir
  if effOutName != "":
    if effOutName.dirExists() or effOutName.endsWith("/") or effOutName.endsWith("\\"):
      effOutDir = effOutName
      effOutName = ""
    else:
      let (d, n, ext) = splitFile(effOutName)
      if d != "":
        effOutDir = d
        effOutName = n & ext

  for f in files:
    let full = f.normalizedPath().expandTilde().absolutePath()
    if fileExists(full):
      let res = compileFile(
        full, effOutName, effOutDir, compileC, snippet, pOrg, paramBase, stateBase,
        delayBase, scratchBase,
      )
      if res != 0:
        return res
    elif dirExists(full):
      for kind, entry in walkDir(full):
        if kind == pcFile:
          let ext = entry.splitFile.ext
          if ext == ".omni" or ext == ".oi":
            let res = compileFile(
              entry, "", effOutDir, compileC, snippet, pOrg, paramBase, stateBase,
              delayBase, scratchBase,
            )
            if res != 0:
              return res
    else:
      printError("Input '" & f & "' does not exist.")
      return 1

  return 0

template omnidsp_main*(
    files: seq[string],
    output: string = "",
    outDir: string = "",
    compileC: bool = false,
    snippet: bool = false,
    pOrg: string = "0x0100",
    paramBase: string = "0x0020",
    stateBase: string = "0x0000",
    delayBase: string = "0x0400",
    scratchBase: string = "0x0300",
): int =
  omni56k_main(
    files, output, outDir, compileC, snippet, pOrg, paramBase, stateBase, delayBase,
    scratchBase,
  )

when isMainModule and not defined(emscripten) and not defined(wasm32):
  clCfg.version = version_flag
  clCfg.helpSyntax = ""
  let arguments = "Arguments:\n  Omni file(s) or directory."
  clCfg.hTabCols = @[clOptKeys, clDflVal, clDescrip]

  dispatch(
    omni56k_main,
    cmdName = "omni56k",
    noHdr = true,
    usage = version_flag & "\n\n" & arguments & "\n\nOptions:\n$options",
    short = {"version": 'v', "output": 'o', "compileC": 'c', "snippet": 's'},
    help = {
      "help": "CLIGEN-NOHELP",
      "version": "CLIGEN-NOHELP",
      "output":
        "Output file path or name (defaults to input file with .asm or .c extension).",
      "outDir": "Output directory folder.",
      "compileC": "Emit self-contained C code (.c) instead of DSP56300 assembly.",
      "snippet":
        "Emit relocatable DSP56300 kernel snippet without ORG headers or symbol declarations.",
      "pOrg": "Program memory execution address in P: (default 0x0100).",
      "paramBase": "Parameter base address in X: (default 0x0020).",
      "stateBase": "State variables base address in Y: (default 0x0000).",
      "delayBase": "Circular delay buffer base address in Y: (default 0x0400).",
      "scratchBase": "Temporary scratch base address in Y: (default 0x0300).",
    },
  )
