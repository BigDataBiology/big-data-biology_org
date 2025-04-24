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

type alias FirstAuthor = {
    name : String
    ,slug: String
    }

displayFirstAuthorInCitation: FirstAuthor -> Html msg
displayFirstAuthorInCitation firstAuthor =
    Html.a [HtmlAttr.href ("/person/" ++ firstAuthor.slug)] [Html.text (firstAuthor.name ++ ", ")]

showrecentpaper : { title : String, doi : String, journal : String, firstauthors: List FirstAuthor } -> Html msg
showrecentpaper p =
    Html.p []
        [Html.a [HtmlAttr.href ("https://doi.org/" ++ p.doi)]
            [Html.text p.title]
        ,Html.text " by "
        ,Html.a [] (List.map displayFirstAuthorInCitation p.firstauthors)
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
        , header
        , Grid.containerFluid []
            [ Grid.simpleRow
                [ Grid.col []
                    [
                    Grid.simpleRow
                        [ Grid.col [Col.sm3, Col.attrs [HtmlAttr.id "leftbar"]]
                            (case pageView.sidebar of
                                Just p -> [p]
                                Nothing ->
                                    [{-Html.h4 [] [Html.text "Coming up"]
                                    ,Html.div
                                        [HtmlAttr.class "sidebar-group"]
                                        [Html.p [] -- [HtmlAttr.style "padding-top" "1em"]
                                            [Html.strong [] [Html.text "6 Nov"]
                                            ,Html.text " "
                                            ,Html.a [HtmlAttr.href "/tutorials/2023-11-06-Jug/"] [Html.text "Jug Tutorial"]
                                            ,Html.text "."
                                            ,Html.br [] []
                                            ,Html.i [] [Html.text "Registration is free, but "]
                                            ,Html.a [HtmlAttr.href "https://bit.ly/2023-11-06_Jug_Tutorial"] [Html.text "required"]

                                            ,Html.text "."
                                            ]
                                        ]
                                        ,-}Html.h4 [] [Html.text "Most recent BDB-Lab papers"]
                                    ,Html.div
                                        [HtmlAttr.class "sidebar-group"]

                                        [showrecentpaper {
                                            title = "argNorm: Normalization of Antibiotic Resistance Gene Annotations to the Antibiotic Resistance Ontology (ARO)",
                                            doi = "10.1093/bioinformatics/btaf173",
                                            journal = "Bioinformatics",
                                            firstauthors = [
                                                {
                                                    name = "Svetlana Ugarcina Perovic",
                                                    slug = "svetlana_ugarcina_perovic"
                                                },
                                                {
                                                    name = "Vedanth Ramji",
                                                    slug = "vedanth_ramji"
                                                }
                                            ]
                                        },showrecentpaper {
                                            title = "A catalogue of small proteins from the global microbiome",
                                            doi = "10.1038/s41467-024-51894-6",
                                            journal = "Nature Communications",
                                            firstauthors = [{
                                                name = "Yiqian Duan",
                                                slug = "Yiqian_Duan"
                                            }]
                                        },showrecentpaper {
                                            title = "Discovery of antimicrobial peptides in the global microbiome with machine learning",
                                            doi = "10.1016/j.cell.2024.05.013",
                                            journal = "Cell",
                                            firstauthors = [{
                                                name = "Célio Dias Santos Júnior",
                                                slug = "celio_dias_santos_junior"
                                            }]
                                        },showrecentpaper {
                                            title = "For long-term sustainable software in bioinformatics",
                                            doi = "10.1371/journal.pcbi.1011920",
                                            journal = "Plos CompBio",
                                            firstauthors = [{
                                                name = "Luis Pedro Coelho",
                                                slug = "luis_pedro_coelho"
                                            }]
                                        },showrecentpaper {
                                            title = "Challenges in computational discovery of bioactive peptides in ’omics data",
                                            doi = "10.1002/pmic.202300105",
                                            journal = "PROTEOMICS",
                                            firstauthors = [{
                                                name = "Luis Pedro Coelho",
                                                slug = "luis_pedro_coelho"
                                            }]
                                        }
                                        ,Html.p []
                                            [Html.a [HtmlAttr.href "/papers/"] [Html.text "All papers (including collaboration papers)"]]
                                        ]

                                    ,Html.h4 [HtmlAttr.style "padding-top" "1em"] [Html.text "BDB-Lab Links"]
                                    ,Html.div [HtmlAttr.class "sidebar-group"]
                                        [Html.p []
                                            [Html.a [HtmlAttr.href "https://bigdatabiology.substack.com/"]
                                                [Html.text "Quarterly newsletter"]
                                            ,Html.br [] []
                                            ,Html.text "("
                                            ,Html.a [HtmlAttr.href "https://bigdatabiology.substack.com/p/bdb-lab-march-2025-updates"]
                                                [Html.text "March 2025 edition"]
                                            ,Html.text ")"
                                            ]

                                        ,Html.p []
                                            [Html.a [HtmlAttr.href "/blog/"] [Html.text "Big Data Biology Lab's Blog"]]
                                        ,Html.p []
                                            [Html.a [HtmlAttr.href "https://twitter.com/BigDataBiology"] [Html.text "@BigDataBiology on Twitter"]]
                                        ,Html.p []
                                            [Html.a [HtmlAttr.href "https://youtube.com/@BigDataBiology"] [Html.text "@BigDataBiology on YouTube"]]
                                        ,Html.p []
                                            [Html.a [HtmlAttr.href "/mailing-lists"] [Html.text "Mailing lists"]]
                                        ]
                                    ,Html.h4 [HtmlAttr.style "padding-top" "1em"] [Html.text "Major Projects"]
                                    ,Html.div [HtmlAttr.class "sidebar-group"]
                                        [Html.p [] [Html.a [HtmlAttr.href "/project/gmgc"] [Html.text "GMGC"]]
                                        ,Html.p [] [Html.a [HtmlAttr.href "/project/embark"] [Html.text "EMBARK"]]
                                        ,Html.p [] [Html.a [HtmlAttr.href "/project/small_orfs"] [Html.text "Small proteins/smORFs"]]
                                        ,Html.p [] [Html.a [HtmlAttr.href "/project/searcher"] [Html.text "SEARCHER"]]
                                        ]

                                    ,Html.h4 [HtmlAttr.style "padding-top" "1em"] [Html.text "Other Links"]
                                    ,Html.div [HtmlAttr.class "sidebar-group"]
                                        [Html.p [] [Html.a [HtmlAttr.href "/faq/"] [Html.text "FAQ"]]
                                        ,Html.p [] [Html.a [HtmlAttr.href "/positions/"] [Html.text "Open Positions"]]
                                        ,Html.p [] [Html.a [HtmlAttr.href "/software/commitments"] [Html.text "Software Commitments"]]
                                        ]

                                    ,Html.h4 [HtmlAttr.style "padding-top" "1em"] [Html.text "Lab Members"]
                                    ,Html.div [HtmlAttr.class "sidebar-group"]
                                        [showMembers sharedData]
                                    ,Html.div [HtmlAttr.style "padding-top" "1em"]
                                        [Html.h4 [] [Html.text "Twitter feed"]
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
        [
            {--
            Html.div [HtmlAttr.id "topbar-top"] [Html.p []
                    [
                        {-Html.a [HtmlAttr.href "/positions"] [Html.text "We are looking for PhD students!"]]-}
                        {-- Html.a [HtmlAttr.href "/open-office-hours"] [Html.text "Open office hours: 24 April & 9 May"] --}
                    ]]
        ,--}Grid.simpleRow
            [ link "/index" "Home"
            , link "/people/" "Team"
            , link "/papers/" "Papers"
            , link "/software/" "Software"
            , link "/blog/" "Blog"
            ]]
footer = Html.div []
            [Html.p []
                [Html.text "Copyright (c) 2018–2024. Luis Pedro Coelho and other group members. All rights reserved."]
            ,Html.div [HtmlAttr.id "google-injection-site"] []
            ]
