module Page.Software exposing (..)

import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import View exposing (View)
import DataSource.File

import List.Extra
import String

import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Button as Button

import Html
import Html.Attributes as HtmlAttr
import Pages.Url

import SiteMarkdown
import Shared

type alias Software =
    { name: String
    , slug: String
    , description: String
    , image: Maybe String
    }
type alias RouteParams = {}
type alias Data = List Software
type alias Model =
    ()

type alias Msg =
    Never

bdbLabTools : DataSource Data
bdbLabTools = DataSource.succeed
    [semibin
    , macrel
    , ngless
    , jug
    , mahotas
    ]

semibin : Software
semibin =
    { name = "Semibin"
    , slug = "semibin"
    , description = """
SemiBin is a metagenomic binning tool (MAG builder). It is based on deep
contrastive learning to incorporate background information (from reference
genomes).

It achieves better results than other tools across a range of microbial
habitats (both host-associated and environmental habitats).
"""
    , image = Just "semibin_logo.svg"
    }

macrel : Software
macrel =
    { name = "Macrel"
    , slug = "macrel"
    , description = """
[Macrel](/software/macrel/) (for metagenomic AMP classification and retrieval)
is an end-to-end pipeline for the prospection of high-quality AMP candidates
from (meta)genomes.

Its classifiers perform similarly to the state-of-the-art in the prediction of
both antimicrobial and hemolytic activity of peptides.  However, Macrel has a
enhanced precision, recovering high-quality AMP candidates using real data.
"""
    , image = Nothing
    }

ngless : Software
ngless =
    { name = "NGLess"
    , slug = "ngless"
    , description = """
NGLess is a domain-specific language for NGS (next-generation sequencing
data) processing.
"""
    , image = Nothing
    }

jug : Software
jug =
    { name = "Jug"
    , slug = "jug"
    , description = """
Jug is a *light-weight, Python only, distributed computing framework.*

Jug allows you to write code that is broken up into tasks and run
different tasks on different processors. You can also think of it as a
lightweight map-reduce type of system, although it's a bit more
flexible (and less scalable).

It has two storage backends: One uses the filesystem to communicate
between processes and works correctly over NFS, so you can coordinate
processes on different machines. The other uses a redis database and all
it needs is for different processes to be able to communicate with a
common redis server.
"""
    , image = Nothing
    }

mahotas : Software
mahotas =
    { name = "Mahotas"
    , slug = "mahotas"
    , description = """
Mahotas is a Python computer vision and image processing library. It includes
many standard functions for image processing and feature computation and can be
used to implement the approaches described in [Coelho et al.,
2013](https://academic.oup.com/bioinformatics/article/29/18/2343/240179).

[mahotas-imread](https://imread.readthedocs.io/) is spin-off project which includes code to read/write images to files
"""
    , image = Nothing
    }


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Software published by the BDB-Lab"
        , locale = Nothing
        , title = "Software tools by the BDB-Lab"
        }
        |> Seo.website


page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = bdbLabTools
        }
        |> Page.buildNoState { view = view }

init : () -> ( Model, Cmd Msg )
init () =
    ( ()
    , Cmd.none
    )


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Never
view maybeUrl sharedModel static =
    { title = "BDB-Lab Tools"
    , body =
        [intro
        , showTools static.data
        ]
    , sidebar = Nothing
    }


intro = SiteMarkdown.mdToHtml """
All our tools come with our [commitment to high quality scientific
software](/software/commitments).
"""

showTools : Data -> Html.Html Msg
showTools tools =
    Html.div [HtmlAttr.class "container"]
        [ showToolDecks tools
        ]

-- Decks are not responsive, so we have to manually break it up into rows
showToolDecks : Data -> Html.Html Msg
showToolDecks tools =
    tools |> chunksOf 3 |> List.map showToolDeck |> Html.div []

chunksOf : Int -> List a -> List (List a)
chunksOf n list =
    case list of
        [] -> []
        _ -> List.take n list :: chunksOf n (List.drop n list)

showToolDeck : List Software -> Html.Html Msg
showToolDeck tools =
    Html.div [HtmlAttr.class "card-deck"
            ,HtmlAttr.style "margin-bottom" "3em"]
        (tools |> List.map
            (\tool ->
                Html.div [HtmlAttr.class "card"
                         ]
                        [ case tool.image of
                                Just image ->
                                    Html.img
                                        [HtmlAttr.class "card-img-top"
                                        ,HtmlAttr.alt (tool.name ++ " logo")
                                        , HtmlAttr.src ("/images/" ++ image)
                                        ] []
                                Nothing -> Html.text ""
                          , Html.div [HtmlAttr.class "card-body"]
                            [ Html.h5 [HtmlAttr.class "card-title"] [Html.text tool.name]
                            , Html.p [HtmlAttr.class "card-text"] [SiteMarkdown.mdToHtml tool.description]
                            , Html.a [HtmlAttr.class "btn btn-primary", HtmlAttr.href ("/software/" ++ tool.slug)] [Html.text <| "Learn more about " ++ tool.name]
                            ]
                        ]
            ))

outro = Html.p [] []

