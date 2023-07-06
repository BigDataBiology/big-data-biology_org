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

showrecentpaper : { title : String, doi : String, journal : String, firstauthorname : String, firstauthorslug : String } -> Html msg
showrecentpaper p =
    Html.p []
        [Html.a [HtmlAttr.href ("https://doi.org/" ++ p.doi)]
            [Html.text p.title]
        ,Html.text " by "
        ,Html.a [HtmlAttr.href ("/person/" ++p.firstauthorslug)]
            [Html.text p.firstauthorname]
        ,Html.i [] [Html.text " et al"]
        ,Html.text ". at "
        ,Html.i [] [Html.text <| " ("++ p.journal ++ ")"]
        ]

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
                                    [Html.h3 [] [Html.text "Coming up"]
                                    ,Html.div
                                        [HtmlAttr.style "border-left" "2px solid #333"
                                        ,HtmlAttr.style "padding-left" "0.5em"
                                        ,HtmlAttr.style "margin" "1em"
                                        ]
                                        [Html.p []
                                            [Html.strong [] [Html.text "9-13 Jul"]
                                            ,Html.text " "
                                            ,Html.a [HtmlAttr.href "person/anna_cusco/"] [Html.text "Anna"]
                                            ,Html.text " will be at "
                                            ,Html.a [HtmlAttr.href "https://www.fems2023.org/"] [Html.text "FEMS 2023"]
                                            ,Html.text " in Hamburg."
                                            ]
                                        ,Html.p []
                                            [Html.strong [] [Html.text "23-27 Jul"]
                                            ,Html.text " "
                                            ,Html.a [HtmlAttr.href "person/luis_pedro_coelho/"] [Html.text "Luis"]
                                            ,Html.text " will be at "
                                            ,Html.a [HtmlAttr.href "https://www.iscb.org/ismbeccb2023"] [Html.text "ISMB/ECCB 2023"]
                                            ,Html.text " in Lyon"
                                            ]
                                        ,Html.p []
                                            [Html.i [] [Html.text "Feel free to get in touch if you will be at any of these events"]
                                            ,Html.text " (actually, feel free to get in touch even if you will not)."]
                                        ]
                                    ,Html.h3 [] [Html.text "Most recent BDB-Lab papers"]
                                    ,Html.div
                                        [HtmlAttr.style "border-left" "2px solid #333"
                                        ,HtmlAttr.style "padding-left" "0.5em"
                                        ,HtmlAttr.style "margin" "1em"
                                        ]

                                        [showrecentpaper {
                                            title = "A global survey of eco-evolutionary pressures acting on horizontal gene transfer",
                                            doi = "10.21203/rs.3.rs-3062985/v1",
                                            journal = "Research Square preprint",
                                            firstauthorname = "Marija Dmitrijeva",
                                            firstauthorslug = "marija_dmitrijeva"
                                        }, showrecentpaper {
                                            title = "SemiBin2: self-supervised contrastive learning leads to better MAGs for short- and long-read sequencing",
                                            doi = "10.1093/bioinformatics/btad209",
                                            journal = "Bioinformatics",
                                            firstauthorname = "Shaojun Pan",
                                            firstauthorslug = "Shaojun_Pan"
                                        }
                                        ,Html.p []
                                            [Html.a [HtmlAttr.href "/papers/"] [Html.text "All papers (including collaboration papers)"]]
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
