module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row

import Browser.Navigation
import DataSource
import Html exposing (Html)
import Html.Attributes exposing (href)
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Path exposing (Path)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import View exposing (View)


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
        { path : Path
        , query : Maybe String
        , fragment : Maybe String
        }
    | SharedMsg SharedMsg


type alias Data =
    ()


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
                { path : Path
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
        OnPageChange _ ->
            ( { model | showMobileMenu = False }, Cmd.none )

        SharedMsg globalMsg ->
            ( model, Cmd.none )


subscriptions : Path -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : DataSource.DataSource Data
data =
    DataSource.succeed ()


view :
    Data
    ->
        { path : Path
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
        , Grid.container []
            [ Grid.simpleRow
                [ Grid.col []
                    [ Html.div [HtmlAttr.style "padding-top" "1em"] []
                    , header
                    , Html.hr [] []
                    , Html.div [] pageView.body
                    , Html.hr [] []
                    , footer
                    ]
                ]
            ]
        ]
    , title = pageView.title
    }

header =
    let
        link target name =
            Grid.col []
                [Html.a [href target] [Html.text name]]
    in Grid.simpleRow
            [ link "/index" "Home"
            , link "/people/" "Members"
            , link "/papers/" "Papers"
            , link "/blog/" "Blog"
            , link "/positions/" "Open Positions"
            , link "/faq/" "FAQ"
            ]
footer = Html.div []
            [Html.p []
                [Html.text "Copyright (c) 2018-2021. Luis Pedro Coelho and other group members. All rights reserved."]
            ]
