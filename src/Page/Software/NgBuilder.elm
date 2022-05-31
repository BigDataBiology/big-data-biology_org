module Page.Software.NgBuilder exposing (..)

import Set as Set

import Head
import Head.Seo as Seo
import Page exposing (Page, PageWithState, StaticPayload)
import View exposing (View)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import Pages.PageUrl exposing (PageUrl)
import DataSource

import Bootstrap.Alert as Alert
import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Form as Form
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Select as Select
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Popover as Popover
import Bootstrap.Text as Text
import Bootstrap.Table as Table
import Bootstrap.Spinner as Spinner

import Html exposing (..)
import Html.Attributes as HtmlAttr
import Html.Attributes exposing (class, for, href, placeholder)
import Html.Events exposing (..)

import SyntaxHighlight as SyntaxHighlight

import File.Download as Download

import Json.Decode as D
import Browser
import Browser.Navigation as Nav


type alias Header = ()
type alias Host = String
type alias Environment = String

type alias NGLessScriptModel =
    { header : Header
    , dataDirectory : Maybe String
    , host : Maybe String
    , env : Maybe Environment
    , useLowMemMode : Bool
    , outputs : Set.Set String
    }

type alias RouteParams = {}
type alias Data = ()

type alias Model = NGLessScriptModel

type Msg
    = NoMsg
    | SetInputDirectory String
    | SelectHost String
    | SelectEnv String
    | ToggleLowMemMode Bool
    | ToggleOutput String Bool
    | DownloadScript


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "Big Data Biology Lab"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "NGLess"
        , locale = Nothing
        , title = "NGLess Script Builder"
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
    ( { header = ()
        , dataDirectory = Nothing
        , host = Nothing
        , env = Nothing
        , useLowMemMode = False
        , outputs = Set.empty }
    , Cmd.none
    )

-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = case msg of
    NoMsg -> (model, Cmd.none)
    SetInputDirectory d -> ({ model | dataDirectory = Just d}, Cmd.none)
    SelectHost h ->
        if h == ""
        then ({model | host = Nothing }, Cmd.none)
        else ({model | host = Just h }, Cmd.none)
    SelectEnv e -> ({model | env = Just e }, Cmd.none)
    ToggleLowMemMode lm -> ({ model | useLowMemMode = lm}, Cmd.none)
    ToggleOutput n s ->
        let
            nOutputs =
                if s
                then Set.insert n model.outputs
                else Set.remove n model.outputs
        in ({ model | outputs = nOutputs }, Cmd.none)
    DownloadScript -> (model,
        Download.string "script.ngl" "application/text" (modelToScript model))



view :
    Maybe PageUrl
    -> Shared.Model
    -> Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel model static =
    { title = "NGLess Script Builder"
    , body =
        [ Grid.simpleRow
            [ Grid.col []
                [ intro
                , Html.hr [] []
                , viewModel model
                , Html.hr [] []
                , outro
                ]
            ]
        ]
    , sidebar = Nothing
    }



intro : Html Msg
intro =
    Grid.simpleRow
        [ Grid.col []
            [ Html.h1 [] [ Html.text "NGLess Script Builder" ]
            , Html.p []
                [ Html.text "You can build standard NGLess scripts using this wizard. See "
                , Html.a [ href "https://ngless.embl.de/" ] [ Html.text "https://ngless.embl.de" ]
                , Html.text " for more information."
                ]
            , Alert.simpleInfo []
                [ Html.p [] [ Html.text "If you use NGLess in your published work, please cite:" ]
                , Html.blockquote []
                    [ Html.p []
                        [ Html.em []

                            [ Html.text """NG-meta-profiler: fast processing of metagenomes using NGLess, a domain-specific language by Luis Pedro Coelho, Renato Alves, Paulo Monteiro, Jaime Huerta-Cepas, Ana Teresa Freitas, Peer Bork - Microbiome 2019 7:84; """
                            , Html.a [href "https://doi.org/10.1186/s40168-019-0684-8"]
                            [Html.text "https://doi.org/10.1186/s40168-019-0684-8"]
                            ]
                        ]
                    ]
                ]
            ]
        ]


outro : Html Msg
outro =
    Html.div []
        [ Html.p [] [ Html.text """ """ ]
        ]


viewModel : Model -> Html Msg
viewModel model =
    Grid.simpleRow
        [ Grid.col []
            [showOptions model]
        , Grid.col [ Col.textAlign Text.alignXsLeft ]
            [showScript model]
        ]


modelToScript : Model -> String
modelToScript model = String.concat <|
    ["ngless \"1.4\"\n"
    ,"import \"gmgc\" version \"1.0\"\n"
    ,"\n"
    ] ++ loadData model
    ++ hostFilter model
    ++ mapGeneCatalog model
    ++ writeOutputs model


loadData model = case model.dataDirectory of
    Nothing -> []
    Just dir ->
            ["\n## (1) LOAD DATA\n"
            ,"input = load_fastq_directory(\""++dir++"\")\n"
            ,"\n"
            ,"# Preprocess the data\n"
            ,"input = preprocess(input) using |r|:\n"
            ,"    r = substrim(r, min_quality=25)\n"
            ,"    if len(r) < 45:\n"
            ,"        discard\n"
            ]

hostFilter model = case model.host of
    Nothing -> []
    Just ref ->
        ["\n## (2) HOST FILTERING\n"
        ,"# Host filtering 1: map against the builtin reference '"++ref++"'\n"
        ,"mapped_host = map(input, ref=\""++ref++"\")\n"
        ,"# Host filtering 2: select only the reads that DID NOT map\n"
        ,"mapped_host = select(mapped_host) using |mr|:\n"
        ,"    mr = mr.filter(min_match_size=45, \n"
        ,"                   min_identity_pc=90, \n"
        ,"                   action={unmatch})\n"
        ,"    if mr.flag({mapped}):\n"
        ,"        discard\n"
        ,"# Host filtering 3: convert back to reads for next steps\n"
        ,"input = as_reads(mapped_host)\n"
        ]

mapGeneCatalog model = case model.env of
    Nothing -> []
    Just h ->
        let
            lowMem =
                if model.useLowMemMode
                then ", block_size_megabases=8000"
                else ""
        in
            ["\n## (3) MAP AGAINST GENE CATALOG\n"
            ,"mapped = map(input, ref=\"gmgc:"++h++":no-rare\"\n"
            ,"             mode_all=True"++lowMem++")\n"
            ]

writeOutputs model =
    let
        maybeWrite1 : (String, String) -> List String
        maybeWrite1 (nglName, humanName) =
            if Set.member nglName model.outputs
            then
                ["\n\n## (4) Count for '" ++ humanName ++ "'\n"
                ,"counts_"++nglName++" = count(mapped,\n"
                ,"                             features = [\""++nglName ++"\"],\n"
                ,"                             multiple={dist1})\n"
                ,"write(counts_"++nglName++",\n"
                ,"      ofile=\"ngless.out.dist1."++nglName++".tsv.gz\")\n"
                ]
            else []
    in if Set.isEmpty model.outputs
        then []
        else List.concat (List.map maybeWrite1 knownOutputs)

showScript : Model -> Html Msg
showScript model = Html.div []
    [SyntaxHighlight.useTheme SyntaxHighlight.gitHub
    ,Html.h3 [] [Html.text "Your generated NGLess script"]
    ,Html.div
        [HtmlAttr.style "border-left" "2px solid #005a32"
        ,HtmlAttr.style "padding-left" "1em"
        ]
        [case SyntaxHighlight.python (modelToScript model) of
            Ok c -> SyntaxHighlight.toBlockHtml (Just 1) c
            Err _ -> Html.pre [] [Html.text ("failed\n"++modelToScript model)]]
        , Button.button [ Button.primary, Button.onClick DownloadScript ] [ Html.text "Download script" ]
    ]


isJust : Maybe a -> Bool
isJust m = case m of
    Nothing -> False
    Just _ -> True


showOptions : Model -> Html Msg
showOptions model =
    Html.div []
        ([introOptions ,showDataOptions model]
        ++ if isJust model.dataDirectory
        then [showHostOption model
            ,showEnvOption model
            ] ++ if isJust model.env
            then if Set.isEmpty model.outputs
                then [showOutputsOption model]
                else [showOutputsOption model, showDownloadOption model]
            else []
        else [])

circleStep s =
    Html.div
        [HtmlAttr.style "background" "#005a32"
        ,HtmlAttr.style "color" "white"
        ,HtmlAttr.style "font-size" "36px"
        ,HtmlAttr.style "text-align" "center"
        ,HtmlAttr.style "margin-left" "-60px"
        ,HtmlAttr.style "margin-bottom" "-30px"
        ,HtmlAttr.style "width" "52px"
        ,HtmlAttr.style "height" "52px"
        ,HtmlAttr.style "line-height" "52px"
        ,HtmlAttr.style "border-radius" "50%"
        ]
        [Html.p [HtmlAttr.style "vertical-align" "middle"] [Html.text s]]

introOptions =
    Html.div []
        [Html.h3 [] [Html.text "Choose options to generate the script"]
        ,circleStep "0"
        ,Html.h4 [HtmlAttr.style "padding-top" "0em"] [Html.text "Declare versions"]
        ,Html.p []
            [Html.text "Every NGLess script starts by declaring which versions of the language it wants to use"]
        ]

stepHeader n h =
    Html.div
        [HtmlAttr.style "padding-top" "2em"]
        [circleStep (String.fromInt n)
        ,Html.h4 [] [Html.text h]]

showDataOptions : Model -> Html Msg
showDataOptions model =
    Html.div []
        [stepHeader 1 "Load data"
        ,Html.p []
            [Html.text "This script will process a single metagenome. "]
        ,Html.p []
            [Html.text "FastQ files should all be in the same directory with names matching the pattern "
            ,Html.code [] [Html.text "*.[12].fq.gz"]
            ,Html.text " (for example, "
            ,Html.code [] [Html.text "sampleX.1.fq.gz"]
            ,Html.text " and "
            ,Html.code [] [Html.text "sampleX.2.fq.gz"]
            ,Html.text " for a paired end sample)."
            ]
        ,Input.text
            [Input.id "input-data"
            ,Input.onInput SetInputDirectory
            ,Input.value (Maybe.withDefault "-" model.dataDirectory)
            ]
        ]

showHostOption : Model -> Html Msg
showHostOption model =
    let
        item1 : (String, String) -> Select.Item Msg
        item1 (h,v) =
            let
                disp : String
                disp = if v == "" then h else h ++ " ("++v++")"
            in Select.item [HtmlAttr.value v] [Html.text disp]
    in Html.div []
        [stepHeader 2 "Filter out host reads (optional)"
        ,Html.p []
            [Html.text "If your metagenome is host-associated, you have the option of filtering out host-associated reads"]
        ,Select.select
            [Select.onChange SelectHost]
            (List.map item1 knownHosts)
        ]

showEnvOption : Model -> Html Msg
showEnvOption model =
    let
        item1 : String -> Select.Item Msg
        item1 e = Select.item [HtmlAttr.value e] [Html.text e]
        envs = case model.env of
                Nothing -> "" :: knownEnvs
                Just _ -> knownEnvs
    in Html.div []
        [stepHeader 3 "Map against gene catalog"
        ,Select.select
            [Select.onChange SelectEnv]
            (List.map item1 envs)
        ,Checkbox.advancedCheckbox
                [ Checkbox.checked model.useLowMemMode
                , Checkbox.onCheck ToggleLowMemMode
                ]
                (Checkbox.label [] [Html.text "Use low memory mode (slower but uses less RAM)"])
        ]

showOutputsOption : Model -> Html Msg
showOutputsOption model =
    let
        opt1 : (String, String) -> Html Msg
        opt1 (nglName, name) =
            Checkbox.advancedCheckbox
                [ Checkbox.checked (Set.member nglName model.outputs)
                , Checkbox.onCheck (ToggleOutput nglName)
                ]
                (Checkbox.label [] [Html.text name])
    in Html.div []
        ([stepHeader 4 "Select outputs"
        ,Html.p [] [Html.text "Select outputs"]
        ] ++ (List.map opt1 knownOutputs))

showDownloadOption : Model -> Html Msg
showDownloadOption _ =
    Html.div []
        [stepHeader 5 "Download and run this script"
        , Button.button [ Button.primary, Button.onClick DownloadScript ] [ Html.text "Download script" ]
        ,Html.p []
            [Html.text "To run this script, you need to download NGLess and then run (adapt the number of threads as needed)"]
        ,Html.pre
            [HtmlAttr.style "padding-left" "1em"
            ,HtmlAttr.style "padding-top" "0.5em"
            ,HtmlAttr.style "padding-bottom" "0.5em"
            ,HtmlAttr.style "background" "#eeeeee"
            ,HtmlAttr.style "font-size" "16px"
            ]
            [Html.text "ngless --threads=4 script.ngl"]
        ]

knownHosts : List (String, String)
knownHosts =
    [("No host filtering", "")
    ,("Human", "hg19")
    ]

knownEnvs : List String
knownEnvs =
    ["human-gut"
    ,"mouse-gut"
    ,"dog-gut"
    ,"pig-gut"
    ,"cat-gut"
    ,"human-vagina"
    ,"human-oral"
    ,"human-skin"
    ,"human-nose"
    ,"soil"
    ,"marine"
    ,"built-environment"
    ,"freshwater"
    ,"wastewater"
    ]

knownOutputs : List (String, String)
knownOutputs =
    [("eggNOG_OGs", "eggNOG Orthologous group")
    ,("Gene_Ontology_terms", "Gene ontology terms")
    ,("KEGG_ko", "KEGG KO")
    ,("Predicted_protein_name", "Protein names")
    ,("EC_number", "EC number")
    ,("CAZy", "CAZy")
    ,("BiGG_Reaction", "BiGG Reaction")
    ,("bestOGCOG_Functional_Category", "OG functional category")
    ]

