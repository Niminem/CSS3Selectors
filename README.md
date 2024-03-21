# Selectors

*** CURRENTLY IN PROGRESS. ETA: 3/23/24 ***

A Nim CSS Selectors library for the WHATWG standard compliant Chame HTML parser. Query HTML using CSS selectors just like you can with JavaScript's `document.querySelector`/`document.querySelectorAll`.

> **Selectors** was created largely off the back of GULPF's [Nimquery](https://github.com/GULPF/nimquery/) library. Rather than using Nim's `htmlparser`, which is currently unreliable to scrape wild HTML, we leverage the [Chame HTML parser](https://git.sr.ht/~bptato/chame).

Selectors is almost fully compliant with the [CSS3 Selectors standard](https://www.w3.org/TR/selectors-3/). The exceptions:

- :root, :lang(...), :enabled, :disabled
- :link, ::first-line, ::first-letter, :visited
- :active, ::before, ::after, :hover,
- :focus, :target, :checked,

Those selectors were not implemented because they didn't make much sense in the situations where `Nimquery` was useful.

## Installation

Install from nimble: `nimble install selectors`

Alternatively clone via git: `git clone https://github.com/Niminem/Selectors`

## Usage

```nim
import std/streams
import pkg/chame/minidom
import src/selectors

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
let
    document: Document = parseHtml(newStringStream(html))
    rootElement: Element = Element(document.childList[1]) # child 0 is always `DocType` for `Document`

let elements = rootElement.querySelectorAll("p:nth-child(odd)")
echo elements # @[<p>1</p>, <p>3</p>]

let htmlFragment = parseHTMLFragment("<h1 id='test'>Hello World</h1><h2>Test Test</h2>", Element()) # make sure you pass in a new `Element` instance
let element = htmlFragment.querySelector("#test")
echo element # <h1 id="test">Hello World</h1>
```

## API
```nim
proc querySelectorAll*(root: Element | seq[Node],
                       queryString: string,
                       options: set[QueryOption] = DefaultQueryOptions): seq[Element]
```
Get all elements matching `queryString`.
Raises ParseError if parsing of `queryString` fails.
See [Options](#) for information about the `options` parameter.

`root` parameter is either an `Element` (for HTML documents via `parseHtml`) or a `seq[Node]` (for HTML fragments via `parseHTMLFragment`).

---
