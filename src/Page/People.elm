module Page.People exposing (Model, Msg, Data, page)

import List.Extra exposing (find)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import View exposing (View)
import DataSource.File
import OptimizedDecoder as Decode exposing (Decoder)

import Html
import Html.Attributes exposing (class, src, href, style)
import Html.Events exposing (..)

import SiteMarkdown
import Lab.Lab as Lab
import Lab.BDBLab as BDBLab

type alias Model = ()
type alias Msg = Never

type alias RouteParams =
    { }

type alias Data = List Lab.Member

page : Page RouteParams Data
page =
    Page.prerender
        { head = head
        , routes = DataSource.succeed [{}]
        , data = data
        }
        |> Page.buildNoState { view = view }



data : RouteParams -> DataSource Data
data routeParams = BDBLab.membersAndAlumni

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
        , description = "TODO"
        , locale = Nothing
        , title = "TODO title" -- metadata.title -- TODO
        }
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    let
        active = static.data |> List.filter (\m -> m.left == Nothing)
        alumni = static.data |> List.filter (\m -> m.left /= Nothing)
    in { title = "BDB-Lab Members"
        , body =
                [Html.h1 [] [Html.text "BDB-Lab Members"]
                ,Html.div []
                    [Html.h3 [] [Html.text "Principal Investigator"]
                    ,Html.div [] (List.map showMember (List.filter (\m -> m.title == "PI") active))]
                ,Html.div [style "padding-top" "2em"]
                    [Html.h3 [] [Html.text "Postdoctoral researchers"]
                    ,Html.div [] (List.map showMember (List.filter (\m -> m.title == "Postdoctoral researcher") active))]
                ,Html.div [style "padding-top" "2em"]
                    [Html.h3 [] [Html.text "Graduate students"]
                    ,Html.div [] (List.map showMember (List.filter (\m -> m.title == "Graduate student") active))]
                ,Html.div [style "padding-top" "2em"]
                    [Html.h3 [] [Html.text "Visitors"]
                    ,Html.div [] (List.map showMember (List.filter (\m -> m.title == "Visitor") active))]
                ,Html.div [style "padding-top" "4em"]
                    [Html.h2 [] [Html.text "Alumni"]
                    ,Html.div [] (List.map showMember alumni)]
                ]
        , sidebar = Nothing
        }

showMember m =
    Grid.simpleRow
        [Grid.col []
            [Html.h4 [] [Html.text m.name]
            ,case m.left of
                Just ell_date ->
                    Html.p []
                        [Html.i []
                            [Html.text "Member from "
                            ,Html.text m.joined
                            ,Html.text " to "
                            ,Html.text ell_date
                            ,Html.text " ("
                            ,Html.text m.title
                            ,Html.text ")."
                            ]
                        ]
                Nothing -> Html.div [] []
            ,Html.p [] [Html.text m.short_bio]
            ,Html.p [] [Html.text "More about "
                       ,Html.a [href <| "/person/"++m.slug] [Html.text m.name]
                       ,Html.text "..."]
            ]
        ,Grid.col
            [Col.xs4]
            [Html.img [src ("/images/people/"++m.slug++".jpeg")
                    , style "max-height" "120px"
                    , style "border-radius" "50%"
                    ]
                []]
        ]

