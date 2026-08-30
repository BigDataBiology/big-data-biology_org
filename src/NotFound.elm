module NotFound exposing (document)

{-| The site's not-found page, generated as a plain `404.html` by `Api.routes`.

Netlify serves `404.html` for any URL that does not match a file in the deploy,
so this page is displayed under whatever address the visitor typed. That rules
out writing it as a normal elm-pages route: every prerendered page boots the Elm
app against `window.location`, and for an unknown path the router finds no page
data and replaces the page with the elm-pages error screen. Hence a static file
with no elm-pages runtime.

It is generated rather than hand-written so that the top bar and the footer come
from `Shared` and cannot drift from the rest of the site.

-}

import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Html exposing (Html)
import Html.Attributes as HtmlAttr

import Shared


{-| The complete file. `htmlToString` is the renderer elm-pages hands to
`Api.routes`.
-}
document : (Html Never -> String) -> String
document htmlToString =
    header ++ htmlToString page ++ footer


header : String
header =
    """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="robots" content="noindex">
<title>Page not found &mdash; BDB-Lab</title>
<link rel="stylesheet" href="/style.css">
<link rel="icon" href="/favicon.ico">
</head>
<body>
"""


footer : String
footer =
    """
<script>
// The page is served under the address the visitor asked for, so we can tell
// them which one that was.
document.getElementById('requested-path').textContent = window.location.pathname;
</script>
</body>
</html>
"""


page : Html Never
page =
    Html.div []
        [ CDN.stylesheet
        , CDN.fontAwesome
        , Shared.header
        , Grid.containerFluid []
            [ Grid.simpleRow
                [ Grid.col []
                    [ Html.h1 [] [Html.text "Page not found"]
                    , Html.p []
                        [Html.text "Sorry, there is no page at "
                        ,Html.code [HtmlAttr.id "requested-path"] []
                        ,Html.text ". It may have been moved or renamed, or the link that brought you here may have a typo in it."
                        ]
                    , whereToGo
                    , Html.hr [] []
                    , Shared.footer
                    ]
                ]
            ]
        ]


whereToGo : Html Never
whereToGo =
    -- Written out as Html rather than Markdown: `SiteMarkdown.mdToHtml` is
    -- rendered by the Elm runtime in the browser, so it comes out empty in a
    -- statically generated file.
    Html.div []
        [ Html.h4 [] [Html.text "Where to go from here"]
        , Html.div [HtmlAttr.class "sidebar-group"]
            [ Html.p [] [link "/index" "Lab home page"]
            , Html.p [] [link "/people/" "Team", Html.text " — current members and alumni"]
            , Html.p [] [link "/papers/" "Papers", Html.text " — all our publications and preprints"]
            , Html.p [] [link "/software/" "Software", Html.text " and ", link "/webservers/" "webservers"]
            , Html.p [] [link "/blog/" "Blog"]
            , Html.p [] [link "/positions/" "Open positions", Html.text " and the ", link "/faq/" "FAQ"]
            ]
        , Html.p []
            [Html.text "If you followed a link on this site and ended up here, we would like to fix it: please "
            ,link "https://github.com/BigDataBiology/big-data-biology_org/issues" "report it as an issue"
            ,Html.text "."
            ]
        ]


link : String -> String -> Html Never
link target name =
    Html.a [HtmlAttr.href target] [Html.text name]
