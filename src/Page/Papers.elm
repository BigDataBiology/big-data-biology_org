module Page.Papers exposing (..)

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

import Html exposing (..)
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
import Lab.BDBLab as BDBLab

type alias Data = ()
type alias RouteParams = {}

type alias Model =
    { activeYear : Maybe Int
    }

type Msg =
    NoOp
    | ActivateYear Int
    | DeactivateYear

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


page = Page.prerender
        { head = head
        , routes = DataSource.succeed [{}]
        , data = \_ -> DataSource.succeed ()
        }
        |> Page.buildWithLocalState
            { view = view
            , init = \_ _ staticPayload -> init ()
            , update = \_ _ _ _ -> update
            , subscriptions = \_ _ _ _-> Sub.none
            }

init : () -> ( Model, Cmd Msg )
init () =
    ( { activeYear = Nothing
      }
    , Cmd.none
    )

-- UPDATE

years : List Int
years = BDBLab.papers
            |> List.map (\p -> p.year)
            |> List.sort
            |> List.Extra.unique

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = case msg of
    DeactivateYear -> ( {activeYear = Nothing } , Cmd.none )
    ActivateYear y -> ( {activeYear = Just y } , Cmd.none )
    NoOp -> ( model , Cmd.none )

view :
    Maybe PageUrl
    -> Shared.Model
    -> Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel model static =
    { title = "BDB-Lab Papers"
    , body = [viewModel model]
    }

viewModel model = Grid.simpleRow
    [showSelection model
    ,showPapers model
    ]

intro = Html.p [] [Html.text """
This lists the publications from the group
"""]

outro = Html.p [] []

showSelection model =
    Grid.col [Col.xs4]
        ([Html.h3 [] [Html.text "Filters"]
        ,Html.h4 [] [Html.text "Year of publication"]
        ] ++ (years |> List.map (\y ->
                let
                    (action, pre) =if Just y == model.activeYear
                            then (DeactivateYear, "* ")
                            else (ActivateYear y, "")
                in (Html.p []
                    [Html.a [onClick action, href "#"] [Html.text (pre ++ String.fromInt y)]
                    ]))))

showPapers : Model -> Grid.Column Msg
showPapers model =
    let papers = case model.activeYear of
            Nothing -> BDBLab.papers
            Just y -> List.filter (\p -> p.year == y) BDBLab.papers
    in Grid.col []
        ([Html.h3 [] [Html.text "Publications"]
        ] ++ (papers |> List.indexedMap showPaper |> List.concat))

showPaper ix p =
        [Html.p []
            [Html.text (String.fromInt (1+ix) ++ ". ")
            ,Html.cite [] [Html.text p.title]]
        ,Html.p []
            ([Html.text "by "
            ] ++ showAuthors p.authors)
        ,Html.p [] [Html.text p.short_description]
        ]

showAuthors ax = List.intersperse (Html.text ", ") (List.map (\a ->
       (if isBDBLab a then Html.strong else Html.span)
       [] [Html.text a]) ax)

isBDBLab a = List.member a (List.map (\m -> m.name) BDBLab.members)
