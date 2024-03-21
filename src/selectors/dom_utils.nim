import std/sugar
import pkg/[chame/minidom]

func escapeText(s: string, attribute_mode = false): string =
  var nbsp_mode = false
  var nbsp_prev: char
  for c in s:
    if nbsp_mode:
      if c == char(0xA0):
        result &= "&nbsp;"
      else:
        result &= nbsp_prev & c
      nbsp_mode = false
    elif c == '&':
      result &= "&amp;"
    elif c == char(0xC2):
      nbsp_mode = true
      nbsp_prev = c
    elif attribute_mode and c == '"':
      result &= "&quot;"
    elif not attribute_mode and c == '<':
      result &= "&lt;"
    elif not attribute_mode and c == '>':
      result &= "&gt;"
    else:
      result &= c

func `$`*(node: Node): string =
  if node of Element:
    let element = Element(node)
    var x = ""
    if element.namespace == Namespace.SVG:
      x = "svg "
    elif element.namespace == Namespace.MATHML:
      x = "math "
    result = "<" & x & element.localNameStr
    for k, v in element.attrsStr:
      result &= ' ' & k & "=\"" & v.escapeText(true) & "\""
    result &= ">"
    for node in element.childList:
      result &= $node
    result &= "</" & x & element.localNameStr & ">"
  elif node of Text:
    let text = Text(node)
    result = text.data.escapeText()
  elif node of Comment:
    result = "<!-- " & Comment(node).data & "-->"
  elif node of DocumentType:
    result = "<!DOCTYPE" & ' ' & DocumentType(node).name & ">"
  elif node of Document:
    result = "Node of Document"
  else:
    assert false

proc makeElemRoot*(list: seq[Node]): Element =
    result = Element()
    for node in list:
        if node of Element:
            result.childList.add(node)

func getAttr*(e: Element; key: string): string {.inline} =
    let factory = e.document.factory
    for attr in e.attrs:
        if factory.atomToStr(attr.name) == key: return attr.value
    return ""

func getAttrs*(e: Element): seq[string] {.inline.} =
    let factory = e.document.factory
    result = collect(for attr in e.attrs: factory.atomToStr(attr.name))
