# CSS3Selectors

A Nim CSS Selectors library for the WHATWG standard compliant Chame HTML parser. Query HTML using CSS selectors with Nim just like you can with JavaScript's `document.querySelector`/`document.querySelectorAll`.

> **CSS3Selectors** was created largely off the back of GULPF's [Nimquery](https://github.com/GULPF/nimquery/) library. Rather than using Nim's `htmlparser`, which is currently unreliable to scrape wild HTML, we leverage the [Chame HTML parser](https://git.sr.ht/~bptato/chame).

**CSS3Selectors** is almost fully compliant with the [CSS3 Selectors standard](https://www.w3.org/TR/selectors-3/). The exceptions:

- :root, :lang(...), :enabled, :disabled
- :link, ::first-line, ::first-letter, :visited
- :active, ::before, ::after, :hover,
- :focus, :target, :checked,

Those selectors were not implemented because they didn't make much sense in the situations where `Nimquery` was useful.

While this library has been rigorously stress-tested there still may be bugs. Please report any you encounter in the wild :)

## Installation

Install from nimble: `nimble install css3selectors`

Alternatively clone via git: `git clone https://github.com/Niminem/CSS3Selectors`

## Usage

```nim
import std/streams
import pkg/chame/minidom
import css3selectors

let html = """
    <!DOCTYPE html>
    <html>
    <head><title>Example</title></head>
    <body>
        <p>1</p>
        <p>2</p>
        <p>3</p>
        <p>4</p>
    </body>
    </html>
    """
let document = Node(parseHtml(newStringStream(html)))
let elements = document.querySelectorAll("p:nth-child(odd)")
echo elements # @[<p>1</p>, <p>3</p>]

let htmlFragment = parseHTMLFragment("<h1 id='test'>Hello World</h1><h2>Test Test</h2>", Element())
let element = htmlFragment.querySelector("#test")
echo element # <h1 id="test">Hello World</h1>
```

## API
```nim
proc querySelectorAll*(root: Node | seq[Node],
                       queryString: string,
                       options: set[QueryOption] = DefaultQueryOptions): seq[Element]
```
Get all elements matching `queryString`.
Raises `ParseError` if parsing of `queryString` fails.
See [Options](https://github.com/Niminem/CSS3Selectors?tab=readme-ov-file#options) for information about the `options` parameter.

`root` parameter is either a `Node` (for HTML documents via `parseHtml`) or a `seq[Node]` (for HTML fragments via `parseHTMLFragment`).

---

```nim
proc querySelector*(root: Node | seq[Node],
                    queryString: string,
                    options: set[QueryOption] = DefaultQueryOptions): Element
```
Get the first element matching `queryString`, or `nil` if no such element exists.
Raises `ParseError` if parsing of `queryString` fails.
See [Options](https://github.com/Niminem/CSS3Selectors?tab=readme-ov-file#options) for information about the options parameter.

`root` parameter is either a `Node` (for HTML documents via `parseHtml`) or a `seq[Node]` (for HTML fragments via `parseHTMLFragment`).

---

```nim
proc parseHtmlQuery*(queryString: string,
                     options: set[QueryOption] = DefaultQueryOptions): Query
```
Parses a query for later use.
Raises `ParseError` if parsing of `queryString` fails.
See [Options](https://github.com/Niminem/CSS3Selectors?tab=readme-ov-file#options) for information about the `options` parameter.

---

```nim
proc exec*(query: Query,
           root: Node,
           single: bool): seq[Element]
```
Execute an already parsed query. If `single = true`, it will never return more than one element.

**Note:** The `root` parameter accepts a `Node`. If you would like to execute on an HTML Fragment via `parseHTMLFragment` (which returns a `seq[Node]`) you will need to make a root element for it using:

```nim
# dom_utils.nim
func makeElemRoot*(list: seq[Node]): Element
```
---

### Options

The `QueryOption` enum contains flags for configuring the behavior when parsing/searching:

- `optUniqueIds`: Indicates if id attributes should be assumed to be unique.
- `optSimpleNot`: Indicates if only simple selectors are allowed as an argument to the `:not(...)` psuedo-class. Note that combinators are not allowed in the argument even if this flag is excluded.
- `optUnicodeIdentifiers`: Indicates if unicode characters are allowed inside identifiers. Doesn't affect strings where unicode is always allowed.

The default options is defined as `const DefaultQueryOptions* = { optUniqueIds, optUnicodeIdentifiers, optSimpleNot }`.

Below is an example of using the options parameter to allow a complex `:not(...)` selector.

```nim
import std/streams
import pkg/chame/minidom
import css3selectors

let html = """
<!DOCTYPE html>
  <html>
    <head><title>Example</title></head>
    <body>
      <p>1</p>
      <p class="maybe-skip">2</p>
      <p class="maybe-skip">3</p>
      <p>4</p>
    </body>
  </html>
"""
let document = Node(parseHtml(newStringStream(html)))
let options = DefaultQueryOptions - { optSimpleNot }
let elements = document.querySelectorAll("p:not(.maybe-skip:nth-child(even))", options)
echo elements
# @[<p>1</p>, <p class="maybe-skip">3</p>, <p>4</p>]
```

## TODO
- Add more helper procs like those we see in [`std/xmltree`](https://nim-lang.org/docs/xmltree.html) for easier DOM parsing (ex: [`innerText()`](https://nim-lang.org/docs/xmltree.html#innerText%2CXmlNode)). We may want to move these into another library over time.
