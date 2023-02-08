module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row

import Browser.Navigation
import DataSource
import Html exposing (Html)
import Html.Attributes as HtmlAttr
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Path
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import View exposing (View)

import Analytics
import Lab.Lab as Lab
import Lab.BDBLab as BDBLab

template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Just OnPageChange
    }


type Msg
    = OnPageChange
        { path : Path.Path
        , query : Maybe String
        , fragment : Maybe String
        }
    | SharedMsg SharedMsg


type alias Data = List Lab.Member


type SharedMsg
    = NoOp


type alias Model =
    { showMobileMenu : Bool
    }


init :
    Maybe Browser.Navigation.Key
    -> Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : Path.Path
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Cmd Msg )
init navigationKey flags maybePagePath =
    ( { showMobileMenu = False }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnPageChange p ->
            ( { model | showMobileMenu = False }, Path.toRelative p.path |> Analytics.updatePath )

        SharedMsg globalMsg ->
            ( model, Cmd.none )


subscriptions : Path.Path -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : DataSource.DataSource Data
data = BDBLab.members


view :
    Data
    ->
        { path : Path.Path
        , route : Maybe Route
        }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : Html msg, title : String }
view sharedData page model toMsg pageView =
    { body = Html.div []
        [ CDN.stylesheet
        , CDN.fontAwesome
        , Grid.containerFluid []
            [ Grid.simpleRow
                [ Grid.col []
                    [ Html.div [HtmlAttr.style "padding-top" "1em"] []
                    , header
                    , Grid.simpleRow
                        [ Grid.col [Col.sm3, Col.attrs [HtmlAttr.id "leftbar"]]
                            (case pageView.sidebar of
                                Just p -> [p]
                                Nothing ->
                                    [{-Html.h3 [] [Html.text "Coming up"]
                                    ,Html.div
                                        [HtmlAttr.style "border-left" "2px solid #333"
                                        ,HtmlAttr.style "padding-left" "0.5em"
                                        ,HtmlAttr.style "margin" "1em"
                                        ]
                                        [Html.p []
                                            [Html.strong []
                                                [Html.text "05 Feb 2023"]
                                                {-,Html.a [HtmlAttr.href "https://everytimezone.com/s/b89229d1"]
                                                [Html.text "(check timezone)"]-}
                                                ]
                                            ,Html.a [HtmlAttr.href "/positions/remote-internships"]
                                                [Html.text "Deadline for remote internship applications. "]
                                            ]
                                    ,-}Html.h3 [] [Html.text "Most recent paper"]
                                    ,Html.div
                                        [HtmlAttr.style "border-left" "2px solid #333"
                                        ,HtmlAttr.style "padding-left" "0.5em"
                                        ,HtmlAttr.style "margin" "1em"
                                        ]

                                        [Html.p []
                                            [Html.a [HtmlAttr.href "https://doi.org/10.1101/2023.01.09.523201"]
                                                [Html.text "SemiBin2: self-supervised contrastive learning leads to better MAGs for short- and long-read sequencing"]
                                            ,Html.text " by "
                                            ,Html.a [HtmlAttr.href "/person/shaojun_pan"]
                                                [Html.text "Shaojun Pan"]
                                            ,Html.i [] [Html.text " et al"]
                                            ,Html.text ". at "
                                            ,Html.i [] [Html.text " BioRxiv (PREPRINT)"]
                                            ]
                                        ]
                                    ,Html.h3 [HtmlAttr.style "padding-top" "2em"] [Html.text "BDB-Lab Links"]
                                    ,Html.p []
                                        [Html.a [HtmlAttr.href "https://bigdatabiology.substack.com/"] [Html.text "Quarterly update newsletter"]]
                                    ,Html.p []
                                        [Html.a [HtmlAttr.href "/blog/"] [Html.text "Big Data Biology Lab's Blog"]]
                                    ,Html.p []
                                        [Html.a [HtmlAttr.href "https://twitter.com/BigDataBiology"] [Html.text "@BigDataBiology on Twitter"]]
                                    ,Html.p []
                                        [Html.a [HtmlAttr.href "https://youtube.com/@BigDataBiology"] [Html.text "@BigDataBiology on YouTube"]]
                                    ,Html.h3 [HtmlAttr.style "padding-top" "2em"] [Html.text "Major Projects"]
                                    ,Html.p [] [Html.a [HtmlAttr.href "/project/gmgc"] [Html.text "GMGC"]]
                                    ,Html.p [] [Html.a [HtmlAttr.href "/project/embark"] [Html.text "EMBARK"]]
                                    ,Html.p [] [Html.a [HtmlAttr.href "/project/small_orfs"] [Html.text "Small proteins/smORFs"]]
                                    ,Html.h3 [HtmlAttr.style "padding-top" "2em"] [Html.text "Other Links"]
                                    ,Html.p [] [Html.a [HtmlAttr.href "/faq/"] [Html.text "FAQ"]]
                                    ,Html.p [] [Html.a [HtmlAttr.href "/positions/"] [Html.text "Open Positions"]]
                                    ,Html.p [] [Html.a [HtmlAttr.href "/software/commitments"] [Html.text "Software Commitments"]]
                                    ,Html.h3 [HtmlAttr.style "padding-top" "2em"] [Html.text "Lab Members"]
                                    ,showMembers sharedData
                                    ,Html.div [HtmlAttr.style "padding-top" "2em"]
                                        [Html.h3 [] [Html.text "Twitter feed"]
                                        ,Html.a
                                            [HtmlAttr.class "twitter-timeline"
                                            ,HtmlAttr.id "twitter-timeline-a"
                                            ,HtmlAttr.attribute "data-width" "240"
                                            ,HtmlAttr.attribute "data-height" "480"
                                            ,HtmlAttr.href "https://twitter.com/BigDataBiology?ref_src=twsrc%5Etfw"

                                            ]
                                            [Html.text "Tweets by BigDataBiology"]
                                        ,Html.div [HtmlAttr.id "twitter-injection-site"]
                                            []
                                        ]
                                    ])
                        , Grid.col [Col.xs9]
                            [Html.div [] pageView.body]
                        ]
                    , Html.hr [] []
                    , footer
                    ]
                ]
            ]
        ]
    , title = pageView.title
    }

showMembers members =
    Html.div []
        (List.map (\m
                    -> Html.p []
                        [Html.a [HtmlAttr.href ("/person/"++m.slug)] [Html.text m.name]])
            members)

header =
    let
        link target name =
            Grid.col []
                [Html.a [HtmlAttr.href target] [Html.text name]]
    in Html.div
        [HtmlAttr.id "topbar"]
        [Grid.simpleRow
            [ link "/index" "Home"
            , link "/people/" "Team"
            , link "/papers/" "Papers"
            , link "/software/" "Software"
            , link "/blog/" "Blog"
            ]]
footer = Html.div []
            [Html.p []
                [Html.text "Copyright (c) 2018–2023. Luis Pedro Coelho and other group members. All rights reserved."]
            ,Html.div [HtmlAttr.id "google-injection-site"] []
            ]
