import std/lists
import std/tables
from   letUtils import scope
import ./private/assertions

type
  OverridableTable*[T] = object
    table: Table[string, T]
    when haveAssertions:
      qual: char

  OverridableOrderedTable*[T] = object
    ring: DoublyLinkedRing[T]
    table: Table[string, DoublyLinkedNode[T]]
    when haveAssertions:
      qual: char

  OverridableTableDefect* = object of Defect

func raiseNotFound(key: string) {.noReturn, noInline.} =
  raise newException(KeyError, "Key was not found: " & key)

func raiseDuplicate(key: string) {.noReturn, noInline.} =
  raise newException(KeyError, "Duplicate key: " & key)

when haveAssertions:
  func assertQualified(key: string; qual: char) =
    declareRaiser failedAssertImpl, OverridableTableDefect
    assert qual in key:
      "When patching tables, you must use `moduleName" & qual &
      "key` syntax to avoid name collisions"
else:
  template assertQualified(key: string; qual: untyped) = discard

func addUnique(t: var (OverridableTable | OverridableOrderedTable); key: string; val: sink auto) =
  if t.table.hasKeyOrPut(key, val):
    raiseDuplicate key

func initOverridableTable*[T](qual: char): OverridableTable[T] =
  when haveAssertions:
    result.qual = qual

func initOverridableOrderedTable*[T](qual: char): OverridableOrderedTable[T] =
  when haveAssertions:
    result.qual = qual

func toOverridableTable*[T](pairs: sink openArray[(string, T)]; qual: char): OverridableTable[T] =
  when haveAssertions:
    result.qual = qual
  for (key, val) in pairs:
    result.addUnique key, val

func toOverridableOrderedTable*[T](pairs: sink openArray[(string, T)]; qual: char):
    OverridableOrderedTable[T] =
  when haveAssertions:
    result.qual = qual
  for (key, val) in pairs:
    let node = DoublyLinkedNode[T](value: val)
    result.addUnique key, node
    {.cast(noSideEffect).}:
      result.ring.add node

func `[]`*[T](t: OverridableTable[T]; key: string): T =
  t.table[key]

func `[]`*[T](ot: OverridableOrderedTable[T]; key: string): T =
  ot.table[key].value

func `[]=`*[T](t: var OverridableTable[T]; key: string; val: sink T) =
  assertQualified key, t.qual
  t.addUnique key, val

proc addAfterImpl[T](
  ot: var OverridableOrderedTable[T];
  preceding: DoublyLinkedNode[T];
  pairs: sink openArray[(string, T)];
) =
  let following = preceding.next
  var preceding = preceding
  for (key, val) in pairs:
    assertQualified key, ot.qual
    let node = DoublyLinkedNode[T](
      next: following, # Will be overwritten on the next iteration unless an exception occurs.
      prev: preceding,
      value: val,
    )
    ot.addUnique key, node
    following.prev = node # Will be overwritten on the next iteration unless an exception occurs.
    preceding.next = node
    preceding = node

proc addAfter*[T](
  ot: var OverridableOrderedTable[T];
  which: string;
  pairs: sink openArray[(string, T)];
) =
  ot.addAfterImpl ot.table[which], pairs

proc addBefore*[T](
  ot: var OverridableOrderedTable[T];
  which: string;
  pairs: sink openArray[(string, T)];
) =
  let following = ot.table[which]
  let preceding = following.prev
  if following != ot.ring.head:
    ot.addAfterImpl preceding, pairs
  elif pairs.len != 0:
    ot.addAfterImpl preceding, [pairs[0]]
    ot.ring.head = preceding.next
    ot.addAfterImpl ot.ring.head, pairs.toOpenArray(1, pairs.high)

template override*(t: OverridableTable; key: string; oldVal, newVal: untyped) =
  let key1 = key
  when false:
    let found: void
  t.table.withValue key1, found:
    let oldVal = found[]
    found[] = newVal
  do:
    raiseNotFound key1

template override*(ot: OverridableOrderedTable; key: string; oldVal, newVal: untyped) =
  scope:
    let node = ot.table[key]
    let oldVal = node.value
    node.value = newVal

func pop*[T](t: var OverridableTable[T]; key: string; val: var T): bool =
  t.table.pop(key, val)

iterator values*[T](t: OverridableTable[T]): T {.noSideEffect.} =
  for val in t.table.values:
    yield val

iterator values*[T](ot: OverridableOrderedTable[T]): T {.noSideEffect.} =
  for val in ot.ring.items:
    yield val
