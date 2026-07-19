module Page.Papers exposing (..)

{-| Papers listing page.

Citation counts come from the Dimensions API (one request per DOI). To avoid
firing ~80 requests on page load, each paper's badge is fetched lazily: the
badge is wrapped in a `<lazy-visible>` custom element (defined in
`public/index.js`) that emits a `visible` event via IntersectionObserver the
first time the badge nears the viewport. That event triggers `FetchDimensions`,
which fetches the DOI once and records it in `model.requested` so scroll-back
and virtual-DOM re-renders never refetch. `init` therefore fires no requests.
-}

import Dict
import Set

import Http
import Json.Decode as D

import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import View exposing (View)
import DataSource.File

import Maybe
import List.Extra
import String

import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Alert as Alert
import Bootstrap.Button as Button

import Html
import Html.Events
import Html.Attributes as HtmlAttr
import Pages.Url

import SiteMarkdown
import Shared
import Lab.Utils exposing (showAuthorsShort)
import Lab.Lab as Lab
import Lab.BDBLab as BDBLab

type alias Data = (List Lab.Publication, List Lab.Member)
type alias RouteParams = {}

type alias DimensionsCitations =
        { doi : String
        , times_cited : Int
        , recent_citations : Int
        , relative_citation_ratio : Maybe Float
        , field_citation_ratio : Maybe Float
        }

type alias Model =
    { activeYear : Maybe Int
    , activeMember : Maybe Lab.Member
    , expandAllDetails : Bool
    , dimensionsData : Dict.Dict String DimensionsCitations
    , requested : Set.Set String
    }

type Msg =
    NoOp
    | ActivateYear Int
    | DeactivateYear
    | ActivateMember Lab.Member
    | DeactivateMember
    | SetExpandAllDetails Bool
    | FetchDimensions String
    | DimensionsDataReceived (Result Http.Error DimensionsCitations)
    | ResetFilters

decodeDimensionsCitations : D.Decoder DimensionsCitations
decodeDimensionsCitations =
    D.map5 DimensionsCitations
        (D.field "doi" D.string)
        (D.field "times_cited" D.int)
        (D.field "recent_citations" D.int)
        (D.field "relative_citation_ratio" (D.nullable D.float))
        (D.field "field_citation_ratio" (D.nullable D.float))

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
        , description = "Interactive list of all the papers published by the BDB-Lab"
        , locale = Nothing
        , title = "Papers published by the BDB-Lab"
        }
        |> Seo.website


page = Page.prerender
        { head = head
        , routes = DataSource.succeed [{}]
        , data = \_ -> DataSource.map2 (\a b -> (a,b)) BDBLab.papers BDBLab.membersAndAlumni
        }
        |> Page.buildWithLocalState
            { view = view
            , init = \_ _ staticPayload -> init staticPayload.data
            , update = \_ _ _ _ -> update
            , subscriptions = \_ _ _ _-> Sub.none
            }

init : Data -> ( Model, Cmd Msg )
init (papers, _) =
    ( { activeYear = Nothing
      , activeMember = Nothing
      , expandAllDetails = False
      , dimensionsData = Dict.empty
      , requested = Set.empty
      }
    , Cmd.none
    )

queryDimensions : String -> Cmd Msg
queryDimensions doi =
    Http.get
        { url = "https://metrics-api.dimensions.ai/doi/" ++ doi
        , expect = Http.expectJson DimensionsDataReceived decodeDimensionsCitations
        }

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
    SetExpandAllDetails b -> ( { model | expandAllDetails = b } , Cmd.none )
    FetchDimensions doi ->
        let key = String.toLower doi
        in if Set.member key model.requested
            then ( model, Cmd.none )
            else ( { model | requested = Set.insert key model.requested }
                 , queryDimensions doi
                 )
    DimensionsDataReceived dt -> case dt of
        Ok d -> ( { model | dimensionsData = Dict.insert (String.toLower d.doi) d model.dimensionsData }, Cmd.none )
        Err _ -> ( model, Cmd.none )
    ResetFilters -> ( { model | activeYear = Nothing, activeMember = Nothing } , Cmd.none )
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
    , sidebar = Nothing
    }


intro = Html.p [] [Html.text """
This lists the publications from the group
"""]

outro = Html.p [] []

-- | Returns the latest year and the total number of papers for a given lab member
-- | If the member has no papers, returns (2000, 0) so they are sorted at the end
latestAndTotalPapers : Lab.Member -> (Int, Int)
latestAndTotalPapers m =
    let
        npapers = List.length m.papers
        recent = List.maximum <| List.map .year m.papers
    in (Maybe.withDefault 2000 recent, npapers)


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
                [[Html.h4 [] [Html.text "Citations"]
                 ,Html.p []
                    [let
                        buttonStyle = if model.expandAllDetails
                                        then activeButton (SetExpandAllDetails False)
                                        else inactivateButton (SetExpandAllDetails True)
                     in Button.button buttonStyle [Html.text "Show citation details"]
                    ]
                 ,Html.p [HtmlAttr.style "color" "#666666"]
                    [Html.small []
                        [Html.text "Citation data from "
                        ,Html.a [HtmlAttr.href "https://www.dimensions.ai/"] [Html.text "Dimensions.ai"]
                        ,Html.text "."
                        ]
                    ]
                 ]
                ,[Html.h4 [] [Html.text "Year"]]
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
                ,members
                    |> List.filter (\m -> not (List.isEmpty m.papers))
                    |> List.sortBy latestAndTotalPapers
                    |> List.reverse
                    |> List.map (\m ->
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
        [Html.h1 [] [Html.text "Publications"]
        ,Html.div []
            <| if List.isEmpty papersYA
                then
                    [Alert.simpleWarning []
                        [Html.p []
                            [Html.text "No papers matching the filters"
                            ,Html.span [HtmlAttr.style "padding-left" "4em"]
                                [Button.button [ Button.warning, Button.onClick ResetFilters ] [Html.text "Reset filters"]]
                            ]
                        ]
                    ]
                else List.indexedMap (showPaper model (List.length papersYA) members) papersYA
        ]

showPaper model n members ix p =
    Grid.simpleRow [Grid.col
        []
        [Html.h4 [HtmlAttr.style "padding-top" "2em"]
            [Html.text (String.fromInt (n-ix) ++ ". ")
            ,Html.cite [] [Html.text p.title]]
        ,Grid.simpleRow
            [Grid.col []
                [Html.a
                    [HtmlAttr.href ("/paper/"++p.slug)
                    ]
                    [Html.p []
                        [Html.img
                            [HtmlAttr.src ("/images/papers/"++p.slug++".png")
                            ,HtmlAttr.style "max-width" "320px"
                            ,HtmlAttr.style "max-height" "320px"
                            ,HtmlAttr.style "border-radius" "20%"]
                            []
                        ,Html.br [] []
                        ,Html.text "[More about "
                        ,Html.cite [] [Html.text p.title]
                        ,Html.text "]"
                        ]
                    ]
                    ]
            ,Grid.col []
                [Html.p [HtmlAttr.style "color" "#666666"]
                    [Html.i []
                        ([Html.text "by "
                        ] ++ showAuthorsShort p.authors members)
                    ,Html.text " in "
                    ,Html.cite [HtmlAttr.class "journal-title"] [Html.text p.journal]]
                ,Html.div
                    [HtmlAttr.style "padding-left" "0.5em"
                    ,HtmlAttr.style "margin-left" "0.5em"
                    ,HtmlAttr.style "border-top" "1px solid black"
                    ,HtmlAttr.style "padding-bottom" "0.0em"
                    ,HtmlAttr.style "margin-bottom" "0.9em"]
                    [SiteMarkdown.mdToHtml p.short_description]
                ,Html.p []
                    [Html.strong [] [Html.text "DOI: "]
                    ,Html.a [HtmlAttr.href ("https://doi.org/"++p.doi)]
                        [Html.text p.doi]]
                ,Html.node "lazy-visible"
                    [ Html.Events.on "visible" (D.succeed (FetchDimensions p.doi)) ]
                    [ addDimensionsBadge model p.doi ]
                ]
            ]
        ]]

addDimensionsBadge : Model -> String -> Html.Html Msg
addDimensionsBadge model doi = case Dict.get (String.toLower doi) model.dimensionsData of
    Nothing -> Html.span [] []
    Just citinfo -> Html.span
                [ HtmlAttr.class "__dimensions_badge_embed__ " ]
            [Html.a [HtmlAttr.href <| "https://badge.dimensions.ai/details/doi/" ++ doi ++ "?domain=https://big-data-biology.org"
                    ,HtmlAttr.class "__dimensions_Link"
                    ]
                [Html.div
                    [HtmlAttr.class "__dimensions_Badge __dimensions_Badge_style_rectangle"]
                    [Html.div [HtmlAttr.class "__dimensions_Badge_Image"]
                    [Html.img [HtmlAttr.src <|"https://badge.dimensions.ai/badge?style=rectangle&count=" ++ String.fromInt citinfo.times_cited
                            , HtmlAttr.alt <| String.fromInt citinfo.times_cited ++ " total citations on Dimensions."]
                            []
                    ]]]
            ,if model.expandAllDetails
              then dimensionsPopup citinfo
              else Html.span [] []
            ]

dimensionsPopup : DimensionsCitations -> Html.Html Msg
dimensionsPopup cit =
    Html.div
        [ HtmlAttr.class "__dimensions_Badge_Legend_padding __dimensions_Badge_Legend_hover-right  __dimensions_Badge_Legend_style_small_rectangle __dimensions_Badge_Legend_always"
        ]
        [ Html.div
            [ HtmlAttr.class "__dimensions_Badge_Legend __dimensions_Badge_Legend_hover-right"]
            [ Html.div
                [ HtmlAttr.class "__dimensions_Badge_stat_group __dimensions_Badge_stat_group_citations" ]
                [ Html.div
                    [ HtmlAttr.class "__dimensions_Badge_stat __dimensions_Badge_stat_total_citations" ]
                    [ Html.span [ HtmlAttr.class "__dimensions_Badge_stat_icon" ] []
                    , Html.span [ HtmlAttr.class "__dimensions_Badge_stat_count" ]
                        [ Html.text <| String.fromInt cit.times_cited ]
                    , Html.span [ HtmlAttr.class "__dimensions_Badge_stat_text" ]
                        [ Html.text "Total citations" ]
                    ]
                , Html.div [ HtmlAttr.class "__dimensions_Badge_stat __dimensions_Badge_stat_recent_citations" ]
                    [ Html.span [ HtmlAttr.class "__dimensions_Badge_stat_icon" ] []
                    , Html.span [ HtmlAttr.class "__dimensions_Badge_stat_count" ]
                        [ Html.text <| String.fromInt cit.recent_citations ]
                    , Html.span [ HtmlAttr.class "__dimensions_Badge_stat_text" ]
                        [ Html.text "Recent citations" ]
                    ]
                ]
            , Html.div [ HtmlAttr.class "__dimensions_Badge_stat_group __dimensions_Badge_stat_group_cr" ]
                [ Html.div [ HtmlAttr.class "__dimensions_Badge_stat __dimensions_Badge_stat_fcr" ]
                    [ Html.span [ HtmlAttr.class "__dimensions_Badge_stat_icon" ] []
                    , Html.span [ HtmlAttr.class "__dimensions_Badge_stat_count" ]
                        [ Html.text <| Maybe.withDefault "??" <| Maybe.map String.fromFloat cit.field_citation_ratio ]
                    , Html.span [ HtmlAttr.class "__dimensions_Badge_stat_text" ]
                        [ Html.text "Field Citation Ratio" ] ]
                , Html.div
                    [ HtmlAttr.class "__dimensions_Badge_stat __dimensions_Badge_stat_rcr" ]
                    [ Html.span [ HtmlAttr.class "__dimensions_Badge_stat_icon" ] []
                    , Html.span [ HtmlAttr.class "__dimensions_Badge_stat_count" ]
                        [ Html.text <| Maybe.withDefault "??" <| Maybe.map String.fromFloat cit.relative_citation_ratio ]
                    , Html.span [ HtmlAttr.class "__dimensions_Badge_stat_text" ]
                        [ Html.text "Relative Citation Ratio" ]
                    ]
                ]
            ]
        ]
