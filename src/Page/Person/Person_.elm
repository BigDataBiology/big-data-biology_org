module Page.Person.Person_ exposing (..)

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


import Html exposing (..)
import Html.Attributes as Html
import Html.Events exposing (..)

import SiteMarkdown exposing (mdToHtml)
import Lab.Lab as Lab
import Lab.BDBLab as BDBLab

type alias Data = Lab.Member
type alias RouteParams = { person : String }
type alias Model =
    { activePub : Maybe Int
    , activeProject : Maybe Int
    }
type Msg = Msg ()

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

init : () -> ( Model, Cmd Msg )
init () =
    ( { activePub = Nothing
      , activeProject = Nothing
      }
    , Cmd.none
    )

page = Page.prerender
        { head = head
        , routes = routes
        , data = \routeParams ->
                DataSource.map (\ms -> case find (\m -> toRoute m == routeParams) ms of
                        Just p -> p
                        Nothing -> BDBLab.memberLPC
                    ) BDBLab.members
        }
        |> Page.buildWithLocalState
            { view = view
            , init = \_ _ staticPayload -> init ()
            , update = \_ _ _ _ -> update
            , subscriptions = \_ _ _ _-> Sub.none
            }

toRoute : Lab.Member -> RouteParams
toRoute m = { person = m.slug }

routes : DataSource (List RouteParams)
routes = DataSource.map (List.map toRoute) BDBLab.members

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = ( model, Cmd.none )

view :
    Maybe PageUrl
    -> Shared.Model
    -> Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl shared model data =
    { title = data.data.name
    , body = [showMember data.data model]
    }

maybeLink base ell t = case ell of
        Just u -> [Html.a [Html.href ("https://github.com/"++u) ] [Html.text t]]
        Nothing -> []

showPerson : Data -> Model -> Html Msg
showPerson data model = Html.div []
    ([Html.h3 [] [ Html.text data.name  ]
    ,Html.text data.short_bio
    ,Html.p [] (List.concat
            [ maybeLink "https://github.com/" data.github "GH"
            , maybeLink "https://twitter.com/" data.twitter "T"
            , maybeLink "https://orcid.com/" data.orcid "O"
            , maybeLink "https://scholar.google.com/citations?hl=en&user=" data.gscholar "G"
            ])
    ,Html.h2 [] [Html.text "Papers"]
    ] ++ (data.papers |> List.map (\p ->
            Html.text p.title)))

showMember m model =
    Grid.simpleRow
        [Grid.col []
            [Html.h4 [] [Html.text m.name]
            ,mdToHtml m.long_bio
            ]
        ,Grid.col
            [Col.xs4]
            [Html.img [Html.src ("/images/people/"++m.slug++".jpeg")
                    , Html.style "max-height" "240px"
                    , Html.style "border-radius" "50%"
                    ]
                []]
        ]

