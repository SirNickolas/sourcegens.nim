from std/strutils import dedent

func dd*(s: string): string {.compileTime.} =
  ##[
    This function simply invokes `strutils.dedent`_ at compile time. That’s it.

    .. _strutils.dedent: https://nim-lang.org/docs/strutils.html#dedent,string,Natural
  ]##
  s.dedent
