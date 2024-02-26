import std/macros
from   ./emission import Emitter
import ./overridableTables

type
  CodegenProc* = proc (emitter: var Emitter) {.gcSafe.}

  Codegen* = OverridableOrderedTable[CodegenProc]

  GenFileSpec* = object
    path*: string
    binary*: bool
    indent*: string
    codegen*: Codegen

  GenFilesetSpec* = OverridableTable[GenFileSpec]

proc run*(self: Codegen; emitter: var Emitter) =
  for cgp in self.values:
    cgp emitter

macro declareCodegen*(qual: char; emitter, spec: untyped): Codegen =
  spec.expectKind nnkStmtList
  let table = nnkTableConstr.newNimNode
  for stmt in spec:
    stmt.expectKind CallNodes
    stmt.expectLen 2
    let body = stmt[1]
    table.add newColonExpr(stmt[0]) do:
      quote: CodegenProc proc (`emitter`: var Emitter) = `body`
  bindSym"toOverridableOrderedTable".newCall(table, qual)
