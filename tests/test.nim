import std/[unittest, streams]
import pkg/chame/minidom
import css3selectors

const html = """
<!DOCTYPE html>
<html>
    <head>
        <title> foobar </title>
    </head>
    <body>
        
        <p id="test1"></p>

        <div class="test2" id="test2"></div>
    
        <div data-custom="test3" id="test3"></div>

        <div data-custom="test4" id="test4"></div>
    
        <div data-custom="test5 space" id="test5"></div>
    
        <div data-custom="[test6]" id="test6"></div>
    
        <article id="test7"></article>
    
        <div class="test8">
            <div class="test8-direct-child" id="test8">
                <div class="test-8-indirect-child"></div>
            </div>
        </div>
    
        <div data-test9="foobar" id="test9"></div>

        <div data-custom="foo1 foo2 foo3" id="test10"></div>

        <div data-custom="test11-bar" id="test11"></div>

        <div class="test12-outer">
            <div>
                <div class="test12-inner" id="test12"></div>
            </div>
        </div>

        <div class="test13 test13-extra" id="test13"></div>

        <div id="test14"></div>

        <div class="test15-A"></div>
        <div class="test15-B"></div>
        <div class="test15-C"></div>

        <div>
            <div class="test16-A"></div>
            <div class="test16-B"></div>
            <div class="test16-C"></div>
        </div>

        <div class="test18 fake"></div>
        <div class="test18" id="test18"></div>
        <div class="test18 fake"></div>

        <div data-custom="test19-start"></div>

        <div data-custom="end-test20"></div>

        <div data-custom="sub-test21-string"></div>

        <div class="test22-content">Content</div>
        <div class="test22-empty"></div>

        <div>
            <div class="test23-many-siblings"></div>
            <div></div>
            <div></div>
        </div>
        <div><div class="test23-one-child"></div></div>

        <div>
            <div class="test24-case1"></div>
            <div></div>
        </div>
        <div>
            <p></p>
            <div class="test24-case2"></div>
        </div>
        <div>
            <div class="test24-case3"></div>
        </div>

        <div>
            <div class="test25" id="test25"></div>
            <div class="test25"></div>
            <div class="test25"></div>
        </div>

        <div>
            <div class="test26"></div>
            <div class="test26"></div>
            <div class="test26" id="test26"></div>
        </div>

        <div>
            <p></p>
            <div class="test27" id="test27"></div>
            <div class="test27"></div>
            <div class="test27"></div>
        </div>

        <div>
            <div class="test28"></div>
            <div class="test28"></div>
            <div class="test28" id="test28"></div>
            <p></p>
        </div>

        <div class="test29">
            <div class="fake"></div>
            <div id="test29"></div>
            <div class="fake"></div>
        </div>

        <div class="test31"></div>
        <div class="test31"></div>

        <div class="test32">
            <div>
                <div class="test32-wrap">
                    <p></p>
                </div>
            </div>
            <div class="test32-wrap">
                <p></p>
            </div>
        </div>

        <div class="test33">
            <div>
                <div></div>
            </div>
            <div></div>
        </div>

        <div>
            <div class="test34" id="test34-1"></div>
            <div class="test34" id="test34-2"></div>
            <div class="test34" id="test34-3"></div>
            <div class="test34" id="test34-4"></div>
        </div>

        <div>
            <div class="test35"></div>
            <div id="test35" class="test35"></div>
        </div>

        <div>
            <div class="test36"></div>
            <div class="test36"></div>
            <div class="test36"></div>
        </div>

        <div id="test37-'"></div>
        <div id="test37-ö"></div>

        <div>
            <div id="test38-first"></div>
            <div id="test38-second"></div>
        </div>

        <div id="test39">
            <div id="exämple"></div>
        </div>

        <div id="test40">
            <div>
                <span></span>
            </div>
        </div>

        <div id="test41">
            <div>1</div>
            <div class="maybe-skip">2</div>
            <div class="maybe-skip">3</div>
            <div>4</div>
        </div>

        <div id="test42">
            <blockquote><div></div></blockquote>
            <div></div>
            <div></div>
            <p></p>
        </div>

        <div id="test43">
            <div class="a">
                <div class="b"></div>
                <div class="c a">
                    <div class="b"></div>
                    <div class="c">
                        <div class="e"></div>
                    </div>
                </div>
            </div>
        </div>

        <div id="test44">
            <div id="a"></div>
            <div id="a"></div>
        </div>

        <div id="issue1">
            <p>1</p>
            <p>2</p>
            <p>3</p>
            <p>4</p>
        </div>
    </body>
</html>
"""

let
    document: Document = parseHtml(newStringStream(html))
    node: Node = Node(document)

# Must be template so tests happen at the right place
template checkAttr(el: Element, attrName, attrValue: string) =
    if not el.isNil:
        check(el.getAttr(attrName) == attrValue)
    else:
        checkpoint("el was nil")
        fail()

test "id selector":
    let el = node.querySelector("#test1")
    check(not el.isNil)
    check(el.tagType() == TagType.TAG_P)

test "class selector":
    let el = node.querySelector(".test2")
    el.checkAttr("id", "test2")

test "attribute (value)":
    let queries = @[
        "[data-custom=test3]",
        "[  data-custom  =  test3  ]"
    ]

    for query in queries:
        let el = node.querySelector(query)
        el.checkAttr("id", "test3")

test "attribute (quoted value)":
    let el = node.querySelector("[data-custom=\"test4\"]")
    el.checkAttr("id", "test4")

test "attribute (spaced value)":
    let el = node.querySelector("[data-custom=\"test5 space\"]")
    el.checkAttr("id", "test5")

test "attribute (bracketed value)":
    let el = node.querySelector("[data-custom=\"[test6]\"]")
    el.checkAttr("id", "test6")

test "element selector":
    let el = node.querySelector("article")
    el.checkAttr("id", "test7")

test "direct child combinator":
    let failQueries = @[
        ".test8 > .test8-indirect-child",
        ".test8    >     .test8-indirect-child",
        ".test8>.test8-indirect-child",
    ]

    for query in failQueries:
        var el = node.querySelector(query)
        check(el.isNil)

    let queries = @[
        ".test8 > .test8-direct-child",
        ".test8    >    .test8-direct-child",
        ".test8>.test8-direct-child"
    ]

    for query in queries:
        var el = node.querySelector(query)
        el.checkAttr("id", "test8")

test "attribute":
    var el = node.querySelector("[data-test9]")
    el.checkAttr("id", "test9")

test "attribute (item match)":
    var el = node.querySelector("[data-custom~=foo2]")
    el.checkAttr("id", "test10")

test "attribute (pipe match)":
    var el = node.querySelector("[data-custom|=test11]")
    el.checkAttr("id", "test11")

test "descendants combinator":
    let queries = @[
        ".test12-outer .test12-inner",
        ".test12-outer     .test12-inner"
    ]
    for query in queries:
        var el = node.querySelector(query)
        el.checkAttr("id", "test12")

test "class selector on element with multiple classes":
    var el = node.querySelector(".test13")
    el.checkAttr("id", "test13")

test "leading and trailing whitespace":
    var el = node.querySelector("   #test14   ")
    el.checkAttr("id", "test14")

test "next sibling combinator":
    var el = node.querySelector(".test15-A + .test15-B")
    check(not el.isNil)
    el = node.querySelector(".test15-A + .test15-C")
    check(el.isNil)
    el = node.querySelector(".test15-B + .test15-A")
    check(el.isNil)

test "any next sibling combinator":
    var els = node.querySelectorAll(".test16-B ~ *")
    check(els.len == 1)

test "root match":
    var fragment = parseHTMLFragment("<span id=\"test17\"></span>", Element())
    var el = fragment.querySelector("#test17")
    check(not el.isNil)

test "pseudo :not":
    var el = node.querySelector(".test18:not(.fake)")
    check(not el.isNil)

test "attribute start match":
    var el = node.querySelector("[data-custom^=\"test19\"]")
    check(not el.isNil)

test "attribute end match":
    var el = node.querySelector("[data-custom$=\"test20\"]")
    check(not el.isNil)

test "attribute substring match":
    var el = node.querySelector("[data-custom*=\"test21\"]")
    check(not el.isNil)

test "pseudo :empty":
    var el = node.querySelector(".test22-content:empty")
    check(el.isNil)
    el = node.querySelector(".test22-empty:empty")
    check(not el.isNil)

test "pseudo :only-child":
    var el = node.querySelector(".test23-many-siblings:only-child")
    check(el.isNil)
    el = node.querySelector(".test23-one-child:only-child")
    check(not el.isNil)

test "pseudo :only-of-type":
    var el = node.querySelector(".test24-case1:only-of-type")
    check(el.isNil)
    el = node.querySelector(".test24-case2:only-of-type")
    check(not el.isNil)
    el = node.querySelector(".test24-case2:ONLY-OF-TYPE")
    check(not el.isNil)
    el = node.querySelector(".test24-case3:only-of-type")
    check(not el.isNil)

test "pseudo :first-child":
    let el = node.querySelector(".test25:first-child")
    el.checkAttr("id", "test25")

test "pseudo :last-child":
    let el = node.querySelector(".test26:last-child")
    el.checkAttr("id", "test26")

test "pseudo :first-of-type":
    let el = node.querySelector(".test27:first-of-type")
    el.checkAttr("id", "test27")

test "pseudo :last-of-type":
    let el = node.querySelector(".test28:last-of-type")
    el.checkAttr("id", "test28")

test "pseudo :not + combinator":
    let el = node.querySelector(".test29 :not(.fake)")
    el.checkAttr("id", "test29")

test "pseudo as only selector":
    var fragment = parseHTMLFragment("<span></span>", Element())
    let el = fragment.querySelector(":empty")
    check(not el.isNil)

test "find multiple matches":
    let els = node.querySelectorAll(".test31")
    check(els.len == 2)
    let el = node.querySelector(".test31")
    check(not el.isNil)

test "find multiple advanced tree":
    let els = node.querySelectorAll(".test32 .test32-wrap p")
    check(els.len == 2)

test "universal selector":
    let els = node.querySelectorAll(".test33 *")
    check(els.len == 3)

test "pseudo :nth-child odd":
    let oddQueries = [
        ".test34:nth-child(odd)",
        ".test34:nth-child(   odd  )",
        ".test34:nth-child(2n+1)",
        ".test34:nth-child(  2n  +  1  )"
    ]

    for query in oddQueries:
        let els = node.querySelectorAll(query)
        check(els.len == 2)
        let ids = @[els[0].getAttr("id"), els[1].getAttr("id")]
        check("test34-1" in ids)
        check("test34-3" in ids)

test "pseudo :nth-child even":
    let evenQueries = [
        ".test34:nth-child(even)",
        ".test34:nth-child(  even  )",
        ".test34:nth-child(2n+0)",
        ".test34:nth-child( 2n  +  0)",
        ".test34:nth-child(2n)"
    ]

    for query in evenQueries:
        let els = node.querySelectorAll(query)
        check(els.len == 2)
        let ids = @[els[0].getAttr("id"), els[1].getAttr("id")]
        check("test34-2" in ids)
        check("test34-4" in ids)

test "pseudo :nth-last-child":
    var els = node.querySelectorAll(".test34:nth-last-child(odd)")
    check(els.len == 2)
    var ids = @[els[0].getAttr("id"), els[1].getAttr("id")]
    check("test34-2" in ids)
    check("test34-4" in ids)

    els = node.querySelectorAll(".test34:nth-last-child(even)")
    check(els.len == 2)
    ids = @[els[0].getAttr("id"), els[1].getAttr("id")]
    check("test34-1" in ids)
    check("test34-3" in ids)

test "pseudo :nth-child no a":
    let queries = [
        ".test35:nth-child(0n + 2)",
        ".test35:nth-child(2)",
        ".test35:nth-child(+2)",
        ".test35:nth-child(+0n + 2)",
        ".test35:nth-child(-0n + 2)"
    ]

    for query in queries: 
        let els = node.querySelectorAll(query)
        check(els.len == 1)
        els[0].checkAttr("id", "test35")

test "pseudo :nth-child a = 1, no b":
    let queries = [
        ".test36:nth-child(1n + 0)",
        ".test36:nth-child(n + 0)",
        ".test36:nth-child(n)",
        ".test36:nth-child(+n)",
        ".test36"
    ]

    for query in queries:
        let els = node.querySelectorAll(query)
        check(els.len == 3)

test "pseudo :nth-child negative a":
    var els = node.querySelectorAll(".test36:nth-child(-n + 1)")
    check(els.len == 1)
    els = node.querySelectorAll(".test36:nth-child(-2n + 7)")
    check(els.len == 2)

test "escaping strings":
    var queries = [
        r"[id = 'test37-\'']",
        r"[id = 'test37-\0027']",
        r"[id = 'test37-\27']",
        r"[id = '\000074est37-\'']",
        r"[id = '\000074 est37-\'']",
        r"[id = '\74 est37-\'']",
        r"[id = '\test37-\'']",
        r"[id = 'test37-\ö']"
    ]

    for query in queries:
        var el = node.querySelector(query)
        check(not el.isNil)
    
    # Escapes are allowed in identifiers as well
    var el = node.querySelector(r"#\74 est37-\'")
    check(not el.isNil)

test "identifier parsing":
    let disallowedIdentifiers = [
        "--foo", "-23", "_23"
    ]

    for ident in disallowedIdentifiers:
        expect ParseError:
            discard parseHtmlQuery(ident)

test "comma operator":
    var els = node.querySelectorAll("#test38-first, #test38-second")
    check(els.len == 2)

test "comma operator optimizeable":
    # Use an identical first selector for both comma cases so we trigger optimizations
    var els = node.querySelectorAll("div #test38-first, div #test38-second")
    check(els.len == 2)

test "Query $":
    var qStr = $(parseHtmlQuery("div#foobar"))
    check(qStr == "div#foobar")

    qStr = $(parseHtmlQuery("div > a, div > p"))
    check(qStr == "div > a, div > p")

test "Non-ascii identifier":
    var els = node.querySelectorAll("#test39 #exämple")
    check(els.len == 1)

test "Issue with optimization of roots with different combinators":
    var els = node.querySelectorAll("#test40 > div, #test40 span")
    check(els.len == 2)

test "Nested pseudos with complex :not(...)":
    let options = DefaultQueryOptions - { optSimpleNot }
    var els = node.querySelectorAll("#test41 div:not(.maybe-skip:nth-child(even))", options)
    check(els.len == 3)

test "`+` and `~` combinators":
    let els = node.querySelectorAll("#test42 blockquote ~ div + p");
    check(els.len == 1)

test "numeric class name":
    expect ParseError:
        discard parseHtmlQuery(".43")

test "overlapping path":
    let els = node.querySelectorAll("#test43 .a .b + .c > .e");
    check($els == """@[<div class="e"></div>]""")

test "duplicate id":
    var els = node.querySelectorAll("#test44 #a")
    check(els.len == 1)
    els = node.querySelectorAll("#test44 #a", DefaultQueryOptions - { optUniqueIds })
    check(els.len == 2)

test "issue1":
    let els = node.querySelectorAll("#issue1 p")
    check($els == "@[<p>1</p>, <p>2</p>, <p>3</p>, <p>4</p>]")

test "issue11":
    let fragment = parseHTMLFragment("""
        <div class="key">A</div><div class="value">x</div>
        <div class="key">B</div><div class="value">y</div>
    """, Element())
    let els = fragment.querySelectorAll(".key, .value")
    check($els == """@[<div class="key">A</div>, <div class="value">x</div>, <div class="key">B</div>, <div class="value">y</div>]""")

test "issue13":
    let fragment = parseHTMLFragment("""
        <td class="some">
            <a href="">
                <span><b>text1</b></span>
                <b>text2</b>
            </a>
        </td>
    """, Element())
    let els = fragment.querySelectorAll("b")
    check($els == "@[<b>text1</b>, <b>text2</b>]")

block checkIfGcSafe:
    proc foo =
        let
            document: Document = parseHtml(newStringStream(html))
            node = Node(document)
        discard node.querySelector("p")
    let bar: proc() {.gcsafe.} = foo
    bar()
