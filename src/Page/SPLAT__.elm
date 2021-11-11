module Page.SPLAT__ exposing (Model, Msg, Data, page)

import DataSource exposing (DataSource)
import DataSource.Glob as Glob
import Head
import Head.Seo as Seo
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import View exposing (View)
import DataSource.File
import OptimizedDecoder as Decode exposing (Decoder)

import SiteMarkdown


type alias Model = ()
type alias Msg = Never

type alias RouteParams =
    { splat : List String }

type alias MDPage =
    { body : String
    , title : String
    , path : String
    }

type alias Data = List MDPage

mdpages : DataSource (List MDPage)
mdpages =
    SiteMarkdown.mdFiles
        |> DataSource.map
            (List.map
                (\mdpage ->
                    DataSource.File.bodyWithFrontmatter
                        (mdDecoder mdpage.path)
                        mdpage.path
                )
            )
        |> DataSource.resolve



mdDecoder : String -> String -> Decoder MDPage
mdDecoder fpath body =
    Decode.map (\title -> { path = fpath, title = title, body = body })
        (Decode.field "title" Decode.string)

page : Page RouteParams Data
page =
    Page.prerender
        { head = head
        , routes = routes
        , data = data
        }
        |> Page.buildNoState { view = view }


routes : DataSource (List RouteParams)
routes =
    let
        parseSlug : String -> RouteParams
        parseSlug p =
            String.slice 0 -3 p -- "Remove .md"
            |> String.split "/"
            |> List.drop 1
            |> RouteParams
    in DataSource.map (List.map (\p -> parseSlug p.path )) mdpages


data : RouteParams -> DataSource Data
data routeParams = mdpages



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


findPage maybeUrl sdata = List.head sdata

view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    case findPage maybeUrl static.data of
        Just content -> { title = content.title, body = [SiteMarkdown.mdToHtml content.body] }
        Nothing -> { title = "404", body = [] }

