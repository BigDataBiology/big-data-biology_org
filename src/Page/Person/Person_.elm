module Page.Person.Person_ exposing (..)
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

import Bootstrap.Alert as Alert
import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Form as Form
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Popover as Popover
import Bootstrap.Text as Text
import Bootstrap.Table as Table
import Bootstrap.Spinner as Spinner

import Html exposing (..)
import Html.Attributes exposing (class, for, href, placeholder)
import Html.Events exposing (..)

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
        , data = \_ -> DataSource.succeed BDBLab.memberLPC
        }
        |> Page.buildWithLocalState
            { view = view
            , init = \_ _ staticPayload -> init ()
            , update = \_ _ _ _ -> update
            , subscriptions = \_ _ _ _-> Sub.none
            }

toRoute : Lab.Member -> RouteParams
toRoute f = { person = f.name }

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
    { title = "BDB-Lab: "
    , body = [showPerson data.data model]
    }

showPerson : Data -> Model -> Html Msg
showPerson data model = Html.div []
    ([Html.h3 [] [ Html.text data.name  ]
    ,Html.text data.short_bio
    ,Html.p []
        [ Html.a [href ("https://github.com/"++data.github) ]
                [Html.text "GH"]
        , Html.a [href ("https://twitter.com/"++data.twitter) ]
                [Html.text "T"]
        , Html.a [href ("https://orcid.com/"++data.orcid) ]
                [Html.text "O"]
        , Html.a [href ("https://scholar.google.com/citations?hl=en&user="++data.gscholar) ]
                [Html.text "G"]
        ]
    ,Html.h2 [] [Html.text "Papers"]
    ] ++ (data.papers |> List.map (\p ->
            Html.text p.title)))

