import unittest
import sourcegens

suite "`identStyle`":
  test "Converts to camel case":
    const st = initIdentStyle(wordInitial = lcUpper)
    check convertStyle("", st) == ""
    check convertStyle("abc", st) == "abc"
    check convertStyle("A_b_c", st) == "aBC"
    check convertStyle("-a-b-c", st) == "_aBC"
    check convertStyle("abCDef", st) == "abCDef"
    check convertStyle("ab-cd-ef", st) == "abCdEf"
    check convertStyle("$_ab_$cd", st) == "_abCd"
    check convertStyle("r2d2", st) == "r2d2"
    check convertStyle("a.1/b.2", st) == "a1B2"
    check convertStyle("0a", st) == "0a"
    check convertStyle("0A", st) == "0a"
    check convertStyle("0Ab", st) == "0Ab"
    check convertStyle("__PRETTY_FUNCTION__", st) == "_prettyFunction"
    check convertStyle("OS_ERROR", st) == "osError"
    check convertStyle("OSError", st) == "oSError"

  test "Converts to Pascal case":
    const st = initIdentStyle(initial = lcUpper, wordInitial = lcUpper)
    check convertStyle("", st) == ""
    check convertStyle("abc", st) == "Abc"
    check convertStyle("A_b_c", st) == "ABC"
    check convertStyle("-a-b-c", st) == "_ABC"
    check convertStyle("abCDef", st) == "AbCDef"
    check convertStyle("ab-cd-ef", st) == "AbCdEf"
    check convertStyle("$_ab_$cd", st) == "_AbCd"
    check convertStyle("r2d2", st) == "R2d2"
    check convertStyle("a.1/b.2", st) == "A1B2"
    check convertStyle("0a", st) == "0a"
    check convertStyle("0A", st) == "0a"
    check convertStyle("0Ab", st) == "0Ab"
    check convertStyle("__PRETTY_FUNCTION__", st) == "_PrettyFunction"
    check convertStyle("OS_ERROR", st) == "OsError"
    check convertStyle("OSError", st) == "OSError"

  test "Converts to snake case":
    const st = initIdentStyle(wordSep = "_")
    check convertStyle("", st) == ""
    check convertStyle("abc", st) == "abc"
    check convertStyle("A_b_c", st) == "a_b_c"
    check convertStyle("-a-b-c", st) == "_a_b_c"
    check convertStyle("abCDef", st) == "ab_c_def"
    check convertStyle("ab-cd-ef", st) == "ab_cd_ef"
    check convertStyle("$_ab_$cd", st) == "_ab_cd"
    check convertStyle("r2d2", st) == "r_2d_2"
    check convertStyle("a.1/b.2", st) == "a_1_b_2"
    check convertStyle("0a", st) == "0a"
    check convertStyle("0A", st) == "0a"
    check convertStyle("0Ab", st) == "0_ab"
    check convertStyle("__PRETTY_FUNCTION__", st) == "_pretty_function_"
    check convertStyle("OS_ERROR", st) == "os_error"
    check convertStyle("OSError", st) == "o_s_error"

  test "Converts to camel case with dollars":
    const st =
      initIdentStyle(wordInitial = lcUpper, alphabet = {'A' .. 'Z', 'a' .. 'z', '0' .. '9', '$'})
    check convertStyle("", st) == ""
    check convertStyle("abc", st) == "abc"
    check convertStyle("A_b_c", st) == "aBC"
    check convertStyle("-a-b-c", st) == "_aBC"
    check convertStyle("abCDef", st) == "abCDef"
    check convertStyle("ab-cd-ef", st) == "abCdEf"
    check convertStyle("$_ab_$cd", st) == "$Ab$cd"
    check convertStyle("r2d2", st) == "r2d2"
    check convertStyle("a.1/b.2", st) == "a1B2"
    check convertStyle("0a", st) == "0a"
    check convertStyle("0A", st) == "0a"
    check convertStyle("0Ab", st) == "0Ab"
    check convertStyle("__PRETTY_FUNCTION__", st) == "_prettyFunction"
    check convertStyle("OS_ERROR", st) == "osError"
    check convertStyle("OSError", st) == "oSError"
