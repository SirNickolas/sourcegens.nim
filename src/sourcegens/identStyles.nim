from std/strutils import toLowerAscii, toUpperAscii

type
  LetterCase* = enum lcLower, lcUpper

  IdentStyle* = object
    initial*, wordInitial*, rest*: LetterCase
    wordSep*: string

func changeCase(c: char; lc: LetterCase): char =
  if lc == lcLower: c.toLowerAscii else: c.toUpperAscii

func convertStyle*(s: openArray[char]; style: IdentStyle): string =
  var i = 0
  let n = s.len
  result = newStringOfCap n # Can reallocate later.

  let leadingSep = if style.wordSep != "-": '_' else: '-'
  while i != n and s[i] in {'_', '-'}:
    result.add leadingSep

  if i != n:
    result.add s[i].changeCase style.initial

    var midWord = true
    var needSep = true
    for i in i + 1 ..< n:
      let c = s[i]
      if c in {'A' .. 'Z', '_', '-'}:
        midWord = false
        if c not_in {'A' .. 'Z'}:
          needSep = false
          result.add style.wordSep
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
