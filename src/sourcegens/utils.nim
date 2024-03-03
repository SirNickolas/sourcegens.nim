from std/strutils import dedent, replace

func dd*(s: string): string {.compileTime.} =
  ##[
    Dedent the input string and replace all occurrencies of `'\n'` in it with `"\p"`.

    **See also:**
    * std/strutils.`dedent <https://nim-lang.org/docs/strutils.html#dedent,string,Natural>`_
  ]##
  result = s.dedent
  when "\p" != "\n":
    result = result.replace("\n", "\p")
