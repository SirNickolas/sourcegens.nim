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
  wordSep = "";
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

  var midWord = true
  var needSep = true
  for i in i + 1 ..< n:
    let c = s[i]
    if c not_in 'a' .. 'z':
      midWord = false
      if c not_in style.alphabet:
        if needSep:
          result.add style.wordSep
          needSep = false
        continue

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
