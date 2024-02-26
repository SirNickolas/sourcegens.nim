when not declared assert:
  import std/assertions

  export assertions

const haveAssertions* = compileOption"assertions"

template declareRaiser*(name: untyped; E: type Exception) =
  func name(msg: string) {.noReturn, noInline.} =
    raise newException(E, msg)

template onFailedAssertDo*(handler: typed) =
  when haveAssertions:
    template failedAssertImpl(msg: string) =
      handler msg
