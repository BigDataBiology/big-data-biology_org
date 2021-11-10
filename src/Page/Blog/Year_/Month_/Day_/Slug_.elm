module Page.Blog.Year_.Month_.Day_.Slug_ exposing (Model, Msg, Data, page)

import Markdown
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
    Glob.succeed
        (\filePath slug ->
            { filePath = filePath
            , slug = slug
            }
        )
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "content/blog/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource

type alias BlogPost =
    { title : String
    , year : String
    , month : String
    , day : String
    , slug : String
    , body : String
    }

type alias Data = List BlogPost

posts : DataSource (List BlogPost)
posts =
    postFiles
        |> DataSource.map
            (List.map
                (\blogPost ->
                    DataSource.File.bodyWithFrontmatter
                        (blogFrontmatterDecoder blogPost.filePath)
                        blogPost.filePath
                )
            )
        |> DataSource.resolve


decodePath path =
    let
        fname = String.dropLeft (String.length "content/blog/") path
    in
        { year = String.slice 0 4 fname
        , month = String.slice 5 7 fname
        , day = String.slice 8 10 fname
        , slug = String.slice 11 -3 fname -- "Remove .md"
        , title = ""
        , body = "" }

blogFrontmatterDecoder : String -> String -> Decoder BlogPost
blogFrontmatterDecoder fpath body =
    let
        post = decodePath fpath
    in
        Decode.map (\title -> { post | title = title, body = body })
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
    DataSource.map (List.map (\p -> { year = p.year, month = p.month, day = p.day, slug = p.slug })) posts


data : RouteParams -> DataSource Data
data routeParams = posts



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


markdownOptions : Markdown.Options
markdownOptions =
    { githubFlavored = Just { tables = True, breaks = False }
    , defaultHighlighting = Nothing
    , sanitize = False
    , smartypants = False
    }


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    case List.head static.data of
        Just post -> { title = post.title, body = [Markdown.toHtmlWith markdownOptions [] post.body] }
        Nothing -> { title = "404", body = [] }

