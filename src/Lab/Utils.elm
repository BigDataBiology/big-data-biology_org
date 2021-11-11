module Lab.Utils exposing (showAuthors)

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

import List.Extra
import String

import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
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

import Browser
import Browser.Navigation as Nav

import Html exposing (Html)
import Html.Attributes as HtmlAttr
import Html.Attributes exposing (class, for, href, placeholder)
import Html.Events exposing (..)
import List.Extra exposing (find)
import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import View exposing (View)
import DataSource.File
import OptimizedDecoder as Decode exposing (Decoder)

import Shared
import Lab.Lab as Lab

showAuthors :
    List String
    -> List Lab.Member
    -> List (Html msg)
showAuthors ax members = List.intersperse (Html.text ", ") (List.map
        (\a -> case findMember a members of
                Just ba -> Html.a [HtmlAttr.href ("/person/"++ba.slug)] [Html.text a]
                Nothing -> Html.text a)
        ax)

findMember a = find (\m -> m.name == a)

