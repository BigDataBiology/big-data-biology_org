module Page.Blog exposing (Model, Msg, Data, page, BlogPost, posts)
import List.Extra exposing (find)
import String.Extra exposing (softEllipsis, stripTags)

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

import Html
import Html.Events
import Html.Attributes as HtmlAttr

import SiteMarkdown


type alias Model =
    ()


type alias Msg =
    Never

type alias RouteParams = { }

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
    in SiteMarkdown.mdFiles "content/"
        |> DataSource.map
            (List.filterMap mdf2bp)

type alias BlogPost =
    { title : String
    , authors : Maybe String
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
                        (blogFrontmatterDecoder blogPost.slug)
                        blogPost.filePath
                )
            )
        |> DataSource.resolve
        |> DataSource.map (List.sortBy (\bp -> (bp.year, bp.month, bp.day)))
        |> DataSource.map List.reverse


blogFrontmatterDecoder : String -> String -> Decoder BlogPost
blogFrontmatterDecoder slug body =
        Decode.map2 (\title authors ->
                    { year = String.slice 0 4 slug
                    , month = String.slice 5 7 slug
                    , day = String.slice 8 10 slug
                    , slug = String.dropLeft 11 slug
                    , title = title
                    , authors = authors
                    , body = body })
            (Decode.field "title" Decode.string)
            (Decode.optionalField "authors" Decode.string)

page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = posts
        }
        |> Page.buildNoState { view = view }


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "BDB-Lab Blog"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Blog of the BDB-Lab"
        , locale = Nothing
        , title = "BDB-Lab Blog"
        }
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
            { title = "BDB-Lab Blog"
            , body =
                (Html.h1 [] [Html.text "BDB-Lab Blog"]) :: (List.map showPost static.data)
            , sidebar = Nothing
            }

showPost : BlogPost -> Html.Html Msg
showPost p = Html.div []
    [Html.h3 []
        [Html.a [HtmlAttr.href ("/blog/"++p.year++"/"++p.month++"/"++p.day++"/"++p.slug)
                ]
                [Html.text p.title]]
    ,Html.p []
        [Html.text ("Published on "++p.year++"."++p.month++"."++p.day)
        ,case p.authors of
            Nothing -> Html.text ""
            Just ax -> Html.i [] [Html.text (" by " ++ax++".")]]
    ,SiteMarkdown.mdToHtml (p.body |> stripTags |> String.replace "\n" " " |> softEllipsis 620)
    ,Html.hr [HtmlAttr.style "padding-bottom" "2em"] []
    ]
