module Lab.Utils exposing (showAuthors, showAuthorsShort)

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

import Browser
import Browser.Navigation as Nav

import Html exposing (Html)
import Html.Attributes as HtmlAttr
import Html.Attributes exposing (class, for, href, placeholder)
import Html.Events exposing (..)

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

showAuthorsShort :
    List String
    -> List Lab.Member
    -> List (Html msg)
showAuthorsShort ax members =
    if List.length ax <= 10
    then showAuthors ax members
    else showAuthors (compressAuthors ax members) members


compressAuthors :
    List String
    -> List Lab.Member
    -> List String
compressAuthors ax members =
    let
        first3 = List.take 3 ax
        rest3 = List.drop 3 ax

        n = List.length rest3
        rest3dots = List.indexedMap (\ix a ->
            if ix >= n - 2 || isMember a members
            then a
            else "...") rest3
        removePairs xs = case xs of
            (x0 :: x1 :: rest) ->
                if x0 == "..." && x1 == "..."
                then removePairs (x1 :: rest)
                else x0 :: removePairs (x1 :: rest)
            _ -> xs
    in first3 ++ removePairs rest3dots

findMember a = find (\m -> m.name == a)

isMember : String -> List Lab.Member -> Bool
isMember a members = case findMember a members of
    Just _ -> True
    _ -> False
