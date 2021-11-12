module Page.Project.Project_ exposing (..)

import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import List.Extra

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


import Html exposing (Html)
import Html.Attributes as HtmlAttr
import Html.Events

import SiteMarkdown exposing (mdToHtml)
import Lab.Utils exposing (showAuthors)
import Lab.Lab as Lab
import Lab.BDBLab as BDBLab

type alias Data = Lab.Project
type alias RouteParams = { project : String }
type alias Model = { }
type Msg =
        NoOp

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
    ( {}
    , Cmd.none
    )

page = Page.prerender
        { head = head
        , routes = routes
        , data = \routeParams ->
                BDBLab.projects
                    |> DataSource.andThen (\ms ->
                        case List.Extra.find (\p -> toRoute p == routeParams) ms of
                            Just p -> DataSource.succeed p
                            Nothing -> DataSource.fail "Unknown project??")
        }
        |> Page.buildWithLocalState
            { view = view
            , init = \_ _ staticPayload -> init ()
            , update = \_ _ _ _ -> update
            , subscriptions = \_ _ _ _-> Sub.none
            }

toRoute : Lab.Project -> RouteParams
toRoute p = { project = p.slug }

routes : DataSource (List RouteParams)
routes = DataSource.map (List.map toRoute) BDBLab.projects

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = (model, Cmd.none)

view :
    Maybe PageUrl
    -> Shared.Model
    -> Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl shared model data =
    { title = data.data.title
    , body = [showProject data.data model]
    }

showProject p model =
    Grid.simpleRow
        [Grid.col []
            [mdToHtml p.long_description]]
