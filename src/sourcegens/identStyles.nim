from std/sequtils import anyIt
from std/strutils import toLowerAscii, toUpperAscii

type
  LetterCase* = enum lcLower, lcUpper

  IdentStyle* = object
    initial*, wordInitial*, rest*: LetterCase
    wordSep*: string
    alphabet*: set[char]

func initIdentStyle*(
  initial = lcLower;
  wordInitial = lcLower;
  rest = lcLower;
  wordSep: sink string = "";
  alphabet = {'A' .. 'Z', 'a' .. 'z', '0' .. '9'};
): IdentStyle {.inline.} =
  IdentStyle(
    initial: initial, wordInitial: wordInitial, rest: rest, wordSep: wordSep, alphabet: alphabet,
  )

func changeCase(c: char; lc: LetterCase): char =
  if lc == lcLower: c.toLowerAscii else: c.toUpperAscii

func convertStyle*(s: openArray[char]; style: IdentStyle): string =
  let n = s.len
  if n == 0: return

  result = newStringOfCap n # Can reallocate later.
  var i = ord s[0] not_in style.alphabet
  if i != 0:
    if style.wordSep.len != 0:
      result.add style.wordSep
    else:
      result.add '_'
    while (if i == n: return; s[i] not_in style.alphabet):
      i += 1
  result.add s[i].changeCase style.initial

  let regularLetters =
    if s.toOpenArray(i, n - 1).anyIt it in 'a' .. 'z': 'a' .. 'z' else: 'A' .. 'Z'
    # If there are no lowercase letters, treat uppercase as lowercase.
  var
    midNum = false
    midWord = true
    needSep = true
  for i in i + 1 ..< n:
    let c = s[i]
    if c not_in '0' .. '9':
      if midNum:
        midNum = false
        midWord = false
      if c not_in regularLetters:
        midWord = false
        if c not_in style.alphabet:
          if needSep:
            result.add style.wordSep
            needSep = false
          continue
    else:
      midNum = true

    result.add s[i].changeCase do:
      if midWord:
        style.rest
      else:
        midWord = true
        if needSep:
          result.add style.wordSep
        else:
          needSep = true
        style.wordInitial
