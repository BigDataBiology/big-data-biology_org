module Page.Papers exposing (..)

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

import Html
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
import Lab.Utils exposing (showAuthors)
import Lab.Lab as Lab
import Lab.BDBLab as BDBLab

type alias Data = (List Lab.Publication, List Lab.Member)
type alias RouteParams = {}

type alias Model =
    { activeYear : Maybe Int
    , activeMember : Maybe Lab.Member
    }

type Msg =
    NoOp
    | ActivateYear Int
    | DeactivateYear
    | ActivateMember Lab.Member
    | DeactivateMember
    | ResetFilters

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
        , data = \_ -> DataSource.map2 (\a b -> (a,b)) BDBLab.papers BDBLab.members
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
      , activeMember = Nothing
      }
    , Cmd.none
    )

-- UPDATE

years : List Lab.Publication -> List Int
years papers = papers
            |> List.map (\p -> p.year)
            |> List.sort
            |> List.Extra.unique
            |> List.reverse

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = case msg of
    DeactivateYear -> ( { model | activeYear = Nothing } , Cmd.none )
    ActivateYear y -> ( { model | activeYear = Just y } , Cmd.none )
    DeactivateMember -> ( { model | activeMember = Nothing } , Cmd.none )
    ActivateMember m -> ( { model | activeMember = Just m } , Cmd.none )
    ResetFilters -> init ()
    NoOp -> ( model , Cmd.none )

view :
    Maybe PageUrl
    -> Shared.Model
    -> Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel model static =
    { title = "BDB-Lab Papers"
    , body =
        [Grid.simpleRow
            [showPapers static.data model
            ,showSelection static.data model
            ]]
    }


intro = Html.p [] [Html.text """
This lists the publications from the group
"""]

outro = Html.p [] []

showSelection (papers, members) model =
    let
        activeButton act = [ Button.primary, Button.onClick act ]
        inactivateButton act = [ Button.outlineSecondary, Button.onClick act ]
    in Grid.col [Col.xs4]
        [Html.div
            [HtmlAttr.style "margin-top" "10em"
            ,HtmlAttr.style "padding-left" "2em"
            ,HtmlAttr.style "border-left" "2px black solid"
            ]
            <| List.concat
                [[Html.h4 [] [Html.text "Year"]]
                ,years papers |> List.map (\y ->
                    let
                        buttonStyle =
                            if Just y == model.activeYear
                                then activeButton DeactivateYear
                                else inactivateButton (ActivateYear y)
                    in Html.p []
                        [Button.button buttonStyle [Html.text <| String.fromInt y]]
                        )
                ,[Html.h4 [] [Html.text "Lab Member"]]
                ,members |> List.map (\m ->
                    let
                        buttonStyle =
                            if Just m == model.activeMember
                                then activeButton DeactivateMember
                                else inactivateButton (ActivateMember m)
                    in Html.p []
                        [Html.a
                            [HtmlAttr.href ("/person/"++m.slug)]
                            [Html.img [HtmlAttr.src ("/images/people/"++m.slug++".jpeg")
                                , HtmlAttr.style "max-width" "40px"
                                , HtmlAttr.style "border-radius" "50%"
                                , HtmlAttr.style "margin-right" "1em"
                                ]
                                []]
                        ,Button.button buttonStyle [Html.text m.name]
                        ])
                ]
            ]

showPapers : (List Lab.Publication, List Lab.Member) -> Model -> Grid.Column Msg
showPapers (papers, members) model =
    let
        papersA = case model.activeMember of
            Nothing -> papers
            Just m -> m.papers
        papersYA = case model.activeYear of
            Nothing -> papersA
            Just y -> List.filter (\p -> p.year == y) papersA
    in Grid.col []
        [Html.h3 [] [Html.text "Publications"]
        ,Html.div []
            <| if List.isEmpty papersYA
                then
                    [Alert.simpleWarning [] [ Html.text "No papers matching the filters" ]
                    ,Button.button [ Button.warning, Button.onClick ResetFilters ] [Html.text "Reset filters"]
                    ]
                else List.indexedMap (showPaper members) papersYA
        ]

showPaper members ix p =
    Grid.simpleRow [Grid.col
        []
        [Html.h4 [HtmlAttr.style "padding-top" "2em"]
            [Html.text (String.fromInt (1+ix) ++ ". ")
            ,Html.cite [] [Html.text p.title]]
        ,Grid.simpleRow
            [Grid.col []
                [Html.img [HtmlAttr.src ("/images/papers/"++p.slug++".png")
                ,HtmlAttr.style "max-width" "320px"
                ,HtmlAttr.style "max-height" "320px"
                ,HtmlAttr.style "border-radius" "20%"
                ] []]
            ,Grid.col []
                [Html.p []
                    ([Html.text "by "
                    ] ++ showAuthors p.authors members)
                ,Html.p [] [Html.text p.short_description]
                ]
            ]
        ]]
