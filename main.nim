import std/streams
import pkg/chame/minidom
import src/selectors

let html = """
    <!DOCTYPE html>
    <html id='test'>
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
    document: Document = parseHtml(newStringStream(html)) # for an HTML document
    rootElement: Element = Element(document.childList[1])

# let elements = rootElement.querySelectorAll("p:nth-child(odd)")
# echo elements # @[<p>1</p>, <p>3</p>]


let test = @[Node(document)].querySelector("html")
echo test.isNil()
echo rootElement.childList.len
echo rootElement.tagType()
# TODO: FIGURE OUT WHY THE HTML TAG ISN'T BEING RECOGNIZED

# let htmlFragment = parseHTMLFragment("<h1 id='test'>Hello World</h1><h2>Test Test</h2>", Element())
# let element = htmlFragment.querySelector("#test")
# echo element # <h1 id="test">Hello World</h1>