module Page.Blog.Year_.Month_.Day_.Slug_ exposing (Model, Msg, Data, page)
import List.Extra exposing (find)

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

import SiteMarkdown


type alias Model =
    ()


type alias Msg =
    Never

type alias RouteParams =
    { year : String, month : String, day : String, slug : String }

postFiles :
    DataSource
        (List
            { filePath : String
            , slug : String
            }
        )
postFiles =
    let
        mdf2bp mdf =
            if List.head mdf.spath == Just "blog"
            then Just <| { filePath = mdf.path, slug = mdf.slug }
            else Nothing
    in SiteMarkdown.mdFiles
        |> DataSource.map
            (List.filterMap mdf2bp)

type alias BlogPost =
    { title : String
    , year : String
    , month : String
    , day : String
    , slug : String
    , body : String
    }

type alias Data = BlogPost

posts : DataSource (List BlogPost)
posts =
    postFiles
        |> DataSource.map
            (List.map
                (\blogPost ->
                    DataSource.File.bodyWithFrontmatter
                        (blogFrontmatterDecoder blogPost.slug)
                        blogPost.filePath
                )
            )
        |> DataSource.resolve


blogFrontmatterDecoder : String -> String -> Decoder BlogPost
blogFrontmatterDecoder slug body =
        Decode.map (\title ->
                    { year = String.slice 0 4 slug
                    , month = String.slice 5 7 slug
                    , day = String.slice 8 10 slug
                    , slug = String.dropLeft 11 slug
                    , title = title
                    , body = body })
            (Decode.field "title" Decode.string)

page : Page RouteParams Data
page =
    Page.prerender
        { head = head
        , routes = routes
        , data = data
        }
        |> Page.buildNoState { view = view }


toRoute p = { year = p.year, month = p.month, day = p.day, slug = p.slug }

routes : DataSource (List RouteParams)
routes =
    DataSource.map (List.map toRoute) posts



data : RouteParams -> DataSource Data
data routeParams =
    let
        findPage ms = case find (\p -> toRoute p == routeParams) ms of
            Just p -> p
            Nothing ->
                    { body = ""
                    , title = "Inner bug!"
                    , slug = ""
                    , year = "1000"
                    , month = "10"
                    , day = "10"
                    }
    in DataSource.map findPage posts

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
            { title = static.data.title, body = [SiteMarkdown.mdToHtml static.data.body] }

