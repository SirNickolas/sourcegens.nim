import ./private/assertions

type
  EmitterProc* = proc (chunk: openArray[char]) {.gcSafe.}

  Location = enum locAtBof, locInSection, locAfterSection

  Emitter* = object
    action: EmitterProc
    curIndent, indentSize: int
    indentBuffer: string
    binary, bol: bool
    loc: Location
    stack: seq[int] # Stack of active indentation depths in the original source text.

  EmitterError* = object of CatchableError
  EmitterDefect* = object of Defect

using self: var Emitter

func raiseIndentError {.noReturn, noInline.} =
  raise newException(EmitterError, "Invalid indentation")

declareRaiser raiseEmitterDefect, EmitterDefect

func initEmitter*(binary: bool; indent: sink string; action: sink EmitterProc): Emitter =
  Emitter(
    action: action,
    indentSize: indent.len,
    indentBuffer: indent,
    binary: binary,
    bol: true,
    stack: @[0],
  )

proc endSection*(self) =
  if self.bol and self.loc == locInSection:
    self.loc = locAfterSection

proc continueSection*(self) =
  if self.loc == locAfterSection:
    self.loc = locInSection

proc indentImpl(self; n: Natural) =
  self.curIndent += n
  while self.curIndent > self.indentBuffer.len:
    self.indentBuffer &= self.indentBuffer # Double its length.

proc dedentImpl(self; n: Natural) =
  onFailedAssertDo raiseEmitterDefect
  assert n <= self.curIndent
  self.curIndent -= n
  self.continueSection # `endSection` followed by `dedent` should not add a blank line.

proc indent*(self; n: Natural = 1) {.inline.} =
  self.indentImpl self.indentSize * n

proc dedent*(self; n: Natural = 1) {.inline.} =
  self.dedentImpl self.indentSize * n

iterator byLine(chunk: openArray[char]): (int, int, int, int) {.noSideEffect.} =
  var i = 0
  while i != chunk.len:
    let lineStart = i
    while i != chunk.len and chunk[i] in {' ', '\t'}:
      i += 1
    let textStart = i
    while i != chunk.len and chunk[i] != '\n': # We do not support `"\p" == "\r"`.
      i += 1
    let textEnd = i
    i += ord i != chunk.len
    yield (lineStart, textStart, textEnd, i)

proc separateSections(self) =
  if self.loc != locInSection:
    if self.loc == locAfterSection:
      when "\p" == "\n":
        self.action "\n"
      else:
        self.action "\p".toOpenArray(self.binary.ord, 1)
    self.loc = locInSection

proc autoIndent(self; indentSize: Natural) =
  let last = self.stack.len - 1
  if indentSize != self.stack[last]: # Fast path.
    if indentSize > self.stack[last]:
      self.stack &= indentSize
      self.indent
    else:
      var i = last
      while (i -= 1; indentSize < self.stack[i]): # This always terminates since `stack[0] == 0`.
        discard
      if indentSize != self.stack[i]:
        raiseIndentError()
      self.stack.setLen i + 1
      self.dedent last - i

proc emit*(self; chunk: openArray[char]) =
  var bol = self.bol
  for (lineStart, textStart, textEnd, lineEnd) in chunk.byLine:
    let textStart =
      if bol:
        if textStart != textEnd: # Unless the line is blank.
          self.separateSections
          self.autoIndent textStart - lineStart
          self.action self.indentBuffer.toOpenArray(0, self.curIndent - 1)
          self.bol = textEnd != lineEnd # Can only become `false` on the last iteration.
        textStart
      else:
        bol = true
        self.bol = textEnd != lineEnd # Can only remain `false` if this is the only iteration.
        lineStart # Treat the leading whitespace as literal text.
    self.action chunk.toOpenArray(textStart, lineEnd - 1)
