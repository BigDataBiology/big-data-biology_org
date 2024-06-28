module Page.Software.Macrel exposing (..)

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
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Popover as Popover
import Bootstrap.Text as Text
import Bootstrap.Table as Table
import Bootstrap.Spinner as Spinner

import Html exposing (..)
import Html.Attributes exposing (class, for, href, placeholder)
import Html.Attributes as HtmlAttr
import Html.Events exposing (..)

import Http

import File.Download as Download

import Json.Decode as D
import Browser
import Browser.Navigation as Nav

type alias RouteParams = {}
type alias Data = ()
type OperationType = Contigs | Peptides

type AMPSphereResult = AMPSphereHit String | AMPSphereMiss | AMPSphereWaiting | AMPSphereNotTested

type alias SequenceResult =
    { amp_family : String
    , amp_probability : Float
    , access : String
    , hemolytic : String
    , hemolyticP : Float
    , sequence : String
    , ampsphere : AMPSphereResult
    }

type alias AMPSphereHitResult =
    { query : String
    , result : Maybe String
    }

type alias QueryModel =
    { optype : Maybe OperationType
    , facontent : String
    , helpPopoverState : Popover.State
    }


type Model =
        Query QueryModel
        | Loading
        | Results APIResult Bool

type Msg
    = NoMsg
    | SelectOp OperationType
    | UpdateFacontent String
    | HelpPopover Popover.State
    | SetExample
    | SubmitData
    | ResultsData (Result Http.Error APIResult)
    | AMPSphereData (Result Http.Error AMPSphereHitResult)
    | DownloadResults
    | ReloadPage
    | SetShowAll Bool


type APIResult =
        APIResultOK { message : String
        , macrelVersion : String
        , rawdata : String
        , data : List SequenceResult
        }
        | APIError String

decodeSequenceResult : D.Decoder SequenceResult
decodeSequenceResult = D.map7 SequenceResult
    (D.field "AMP_family" D.string)
    (D.field "AMP_probability" D.float)
    (D.field "Access" D.string)
    (D.field "Hemolytic" D.string)
    (D.field "Hemolytic_probability" D.float)
    (D.field "Sequence" D.string)
    (D.field "AMP_probability" D.float
        |> D.map (\p ->
            if p >= 0.5
                then AMPSphereWaiting
                else AMPSphereNotTested)
        )


decodeAPIResult : D.Decoder APIResult
decodeAPIResult =
    let
        bAPIResultOK m v r d = APIResultOK { message = m, macrelVersion = v, rawdata = r, data = d }
    in D.field "code" D.int
        |> D.andThen (\c ->
            if c == 0
                then D.map  APIError (D.field "message" D.string)
                else D.map4 bAPIResultOK
                        (D.field "message" D.string)
                        (D.field "macrel_version" D.string)
                        (D.field "rawdata" D.string)
                        (D.field "data" (D.field "objects" (D.list decodeSequenceResult))))

decodeAMPSphereHitResult : D.Decoder AMPSphereHitResult
decodeAMPSphereHitResult = D.map2 AMPSphereHitResult
    (D.field "query" D.string)
    (D.field "result" (D.maybe D.string))

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
        , description = "Macrel is a tool for finding AMPs in (meta)genomes"
        , locale = Nothing
        , title = "AMP prediction using Macrel"
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
    ( Query { optype = Nothing
      , facontent = ""
      , helpPopoverState = Popover.initialState
      }
    , Cmd.none
    )

-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ifQuery f = case model of
            Query qm ->
                let
                    (qmpost, c) = f qm
                in (Query qmpost, c)
            _ -> (model, Cmd.none)
    in case msg of
        NoMsg ->
            ( model, Cmd.none )

        SelectOp p -> ifQuery <| \qmodel ->
                -- Iff the example input is selected, switch it
                if qmodel.optype == Just Contigs && qmodel.facontent == contigExampleData && p == Peptides then
                    ( { qmodel | optype = Just Peptides, facontent = peptidesExampleData }, Cmd.none )

                else if qmodel.optype == Just Peptides && qmodel.facontent == peptidesExampleData && p == Contigs then
                    ( { qmodel | optype = Just Contigs, facontent = contigExampleData }, Cmd.none )

                else
                    ( { qmodel | optype = Just p }, Cmd.none )

        UpdateFacontent c -> ifQuery <| \qmodel -> ( { qmodel | facontent = c }, Cmd.none )

        HelpPopover state -> ifQuery <| \qmodel -> ( { qmodel | helpPopoverState = state }, Cmd.none )

        SetExample -> ifQuery <| \qmodel ->
            let
                nc =
                    case qmodel.optype of
                        Nothing ->
                            "?"

                        -- should never happen
                        Just Contigs ->
                            contigExampleData

                        Just Peptides ->
                            peptidesExampleData
            in
            ( { qmodel | facontent = nc }, Cmd.none )

        SubmitData -> case model of -- We cannot using ifQuery because we want to return Loading
            Loading -> ( model, Cmd.none )
            Query qmodel -> (Loading , submitData qmodel )
            Results _ _ -> ( model, Cmd.none )
        ResultsData r -> case r of
            Ok v -> ( Results v True, queryAMPSphere v )
            Err err -> case err of
                Http.BadUrl s -> (Results (APIError ("Bad URL: "++ s)) True, Cmd.none)
                Http.Timeout  -> (Results (APIError "Timeout") True, Cmd.none)
                Http.NetworkError -> (Results (APIError "Network error") True, Cmd.none)
                Http.BadStatus s -> (Results (APIError ("Bad status: " ++ String.fromInt s)) True, Cmd.none)
                Http.BadBody s -> (Results (APIError ("Bad body: " ++ s)) True, Cmd.none)
        AMPSphereData r -> case r of
            Ok rh -> case model of
                Results (APIResultOK rok) _ ->
                        let
                            decorate e = if e.sequence == rh.query then { e | ampsphere = case rh.result of
                                Just a -> AMPSphereHit a
                                Nothing -> AMPSphereMiss
                                } else e
                        in ( Results (APIResultOK { rok | data = List.map decorate rok.data } ) True, Cmd.none )
                _ -> ( model, Cmd.none )
            _ -> ( model, Cmd.none )

        DownloadResults -> case model of
            Results (APIResultOK r) _ -> ( model, Download.string "macrel.out.tsv" "application/x-gzip" r.rawdata)
            _ -> ( model, Cmd.none )
        ReloadPage -> ( model, Nav.reload )
        SetShowAll f -> case model of
            Results r _ -> ( Results r f, Cmd.none )
            _ -> ( model, Cmd.none )

queryAMPSphere : APIResult -> Cmd Msg
queryAMPSphere api = case api of
    APIError _ -> Cmd.none
    APIResultOK r ->
        r.data
            |> List.filter (\e -> e.amp_probability >= 0.5)
            |> List.map (\e -> e.sequence)
            |> List.map submitAMPSphereQuery
            |> Cmd.batch

submitAMPSphereQuery : String -> Cmd Msg
submitAMPSphereQuery seq = Http.get
    { url = "https://ampsphere-api.big-data-biology.org/v1/search/sequence-match?query=" ++ seq
    , expect = Http.expectJson AMPSphereData decodeAMPSphereHitResult
    }

submitData : QueryModel -> Cmd Msg
submitData model = Http.post
    { url = "https://aws.big-data-biology.org:1188/predict"
    , body = Http.multipartBody
                [ Http.stringPart "dataType" (if model.optype == Just Peptides then "peptides" else "contigs")
                , Http.stringPart "textData" model.facontent
                ]
    , expect = Http.expectJson ResultsData decodeAPIResult
    }

validateFasta : OperationType -> String -> Maybe (Html Msg)
validateFasta p fa =
    if
        String.length fa > 50200
        -- 200 is a little margin
    then
        Just <| Html.p [] [ Html.strong [] [ Html.text "Input is too large! " ]
                          , Html.text "Only the first 50,000 characters will be analyzed. Run the tool locally to remove any limitations"]

    else if
        nrSeqs fa > 1004
        -- 4 is a little margin
    then
        Just <| Html.p [] [ Html.strong [] [ Html.text "Too many sequences! " ]
                          , Html.text "Only the first 1,000 sequences will will be analyzed. Run the tool locally to remove any limitations" ]

    else
        let
            lines = List.filter (\ell -> not (String.startsWith ">" ell)) <| String.split "\n" fa
            totalLen = List.sum <| List.map String.length lines
            isOnlyNucleotides = List.all (\ell -> String.all isNuc ell) lines
            isNuc c = (c == 'A' || c == 'C' || c == 'T' || c == 'G'
                        || c == 'a' || c == 'c' || c == 'g' || c == 'g'
                        || c == 'n' || c == 'N')
        in case p of
            Peptides ->
                if isOnlyNucleotides && totalLen > 100
                    then Just <| Html.div []
                                    [Html.p [] [Html.text "These sequences look suspiciously like DNA. "]
                                    ,Html.p [] [Html.text "Are you sure you want to run macrel in peptides mode?" ]]
                    else Nothing

            Contigs ->
                if (not isOnlyNucleotides) && totalLen > 100
                    then Just <| Html.div []
                                    [Html.p [] [Html.text "These sequences do not look like DNA." ]
                                    ,Html.p [] [Html.text "Are you sure you want to run macrel in contigs mode?"]]
                    else Nothing


nrSeqs : String -> Int
nrSeqs fa =
    String.filter (\c -> c == '>') fa |> String.length


view :
    Maybe PageUrl
    -> Shared.Model
    -> Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel model static =
    { title = "AMP prediction using Macrel"
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
            [ Html.h1 [] [ Html.text "Macrel webservice" ]
            , Html.p []
                [ Html.text "This webserver allows you to use Macrel for short jobs. For larger jobs, you can download and use the "
                , Html.a [ href "https://macrel.rtfd.io/" ] [ Html.text "command line version of the tool." ]
                ]
            , Alert.simpleInfo []
                [ Html.p [] [ Html.text "If you use macrel in your published work, please cite:" ]
                , Html.blockquote []
                    [ Html.p []
                        [ Html.em []

                            [ Html.text """ Santos-Júnior CD, Pan S, Zhao X, Coelho LP. 2020. Macrel: antimicrobial peptide screening in genomes and metagenomes.
                                            PeerJ 8:e10555. doi: """
                            , Html.a [href "https://doi.org/10.7717/peerj.10555"] [Html.text "10.7717/peerj.10555"]
                            ]
                        ]
                    ]
                ]
            ]
        ]


outro : Html Msg
outro =
    Html.div []
        [ Html.p [] [ Html.text """Note that when finding matches in the AMPSphere database, only exact matches are reported. If you want to find similar sequences, you can use the """
                    , Html.a [ HtmlAttr.href "https://ampsphere.big-data-biology.org/" ] [ Html.text "AMPSphere webserver" ]
                    , Html.text " or download the database and use the command line version of the tool."
                    ]
        , Html.p [] [ Html.text """Macrel uses machine learning to select peptides
    with high probability of being an AMP. Macrel is optimized for higher
    specificity (low rate of false positives).""" ]
        , Html.p [] [ Html.text """Macrel will also classify AMPs into hemolytic and
    non-hemolytic peptides.""" ]
        ]


viewModel : Model -> Html Msg
viewModel model = case model of
    Loading -> Html.div []
                    [Html.div []
                        [Spinner.spinner [ Spinner.color Text.primary, Spinner.grow ] [ ]
                        ,Html.p [] [ Html.text "Waiting for results..." ]
                        ,Html.p [] [ Html.text "Normally, it should not take too long, but, for large inputs, you can also run the local version." ]
                        ]
                    ]
    Query qm -> viewQueryModel qm
    Results r showAll -> viewResults r showAll

viewResults r showAll = case r of
    APIError err ->
        Alert.simpleDanger []
            [ Html.p [] [ Html.text "Call to the macrel server failed" ]
            , Html.blockquote []
                [ Html.p [] [ Html.text err ] ]
            ]
    APIResultOK ok -> Html.div []
            [ Html.h2 [] [ Html.text "Results" ]
            , Checkbox.advancedCheckbox [ Checkbox.checked showAll, Checkbox.onCheck SetShowAll ] <| Checkbox.label [] [ Html.text "Show all results (not only AMPs)" ]
            , Table.table
                    { options = [ Table.striped, Table.hover ]
                    , thead =  Table.simpleThead
                        [ Table.th [] [ Html.text "Sequence name" ]
                        , Table.th [] [ Html.text "Sequence" ]
                        , Table.th [] [ Html.text "AMP probability" ]
                        , Table.th [] [ Html.text "Hemolytic class" ]
                        , Table.th [] [ Html.a [ HtmlAttr.href "https://ampsphere.big-data-biology.org/" ]
                                            [ Html.text "AMPSphere" ]]
                        ]
                    , tbody = Table.tbody []
                            (List.map (\e ->
                                Table.tr []
                                    [ Table.td [] [ Html.text e.access ]
                                    , Table.td [] [ Html.text e.sequence ]
                                    , Table.td [] [ Html.text <| String.fromFloat e.amp_probability ]
                                    , Table.td [] [ Html.text (if e.amp_probability >= 0.5
                                                                    then e.hemolytic
                                                                    else "-") ]
                                    , Table.td [] [ viewAMPSphere e.ampsphere ]
                                    ]) <| if showAll
                                            then ok.data
                                            else List.filter (\e -> (e.amp_probability >= 0.5)) ok.data)
                    }
            , Html.p [] [ Html.text "Prediction with ", Html.em [] [Html.text <| "macrel v"++ok.macrelVersion], Html.text "." ]
            , Grid.simpleRow
                [ Grid.col []
                    [ Button.button [ Button.primary, Button.onClick DownloadResults ] [ Html.text "Download results table" ] ]
                , Grid.col [ Col.textAlign Text.alignXsRight ]
                    [ Button.button [ Button.warning, Button.onClick ReloadPage ] [ Html.text "Restart prediction (discards results)" ] ]
                ]
            ]

viewAMPSphere : AMPSphereResult -> Html Msg
viewAMPSphere r = case r of
    AMPSphereWaiting -> Html.text "Waiting..."
    AMPSphereHit a -> Html.a [ HtmlAttr.href ("https://ampsphere.big-data-biology.org/amp?accession=" ++ a)] [Html.text a]
    AMPSphereMiss -> Html.text "No match"
    AMPSphereNotTested -> Html.text "-"


viewQueryModel : QueryModel -> Html Msg
viewQueryModel model =
    let
        buttonStyle who active =
            case active of
                Nothing ->
                    [ Button.primary, Button.onClick (SelectOp who) ]

                Just p ->
                    if who == p then
                        [ Button.info, Button.onClick (SelectOp who) ]

                    else
                        [ Button.outlineSecondary, Button.onClick (SelectOp who) ]

        placeholderText =
            case model.optype of
                Nothing ->
                    "Select input type above..."

                Just Contigs ->
                    ">ContigID\nAATACTACTATCTCTCTCTACTATCTACATCATCA...\n"

                Just Peptides ->
                    ">PeptideID\nMEPEPAGAD....\n"

        faerror =
            case model.optype of
                Nothing ->
                    Nothing

                Just p ->
                    validateFasta p model.facontent
    in
    Grid.simpleRow
        [ Grid.col [] <|
            [ Html.h2 [] [ Html.text "Online AMP prediction" ]
            , Html.p []
                [ Html.strong [] [ Html.text "Step 1." ]
                , Html.text " Select mode:"
                ]
            , Grid.simpleRow
                [ Grid.col [] [ Button.button (buttonStyle Contigs model.optype) [ Html.text "Predict from contigs (DNA sequences)" ] ]
                , Grid.col [] [ Button.button (buttonStyle Peptides model.optype) [ Html.text "Predict from peptides (amino acid sequences)" ] ]
                ]
            , Html.p []
                [ Html.text
                    "(The command line tool also supports prediction from short-reads, but this is not available on the webserver)."
                ]
            , case faerror of
                Nothing ->
                    Html.text ""

                Just err ->
                    Alert.simpleWarning [] [ err ]
            , case model.optype of
                Nothing ->
                    Html.text ""

                Just p ->
                    Form.group []
                        [ Html.label [ for "fasta" ]
                            [ Html.strong [] [ Html.text "Step 2." ]
                            , Html.text <|
                                if p == Contigs then
                                    " Input DNA FASTA "

                                else
                                    " Input Peptides FASTA "
                            , Popover.config
                                (Button.button
                                    [ Button.small
                                    , Button.primary
                                    , Button.attrs <|
                                        Popover.onHover model.helpPopoverState HelpPopover
                                    , Button.attrs <|
                                        Popover.onClick model.helpPopoverState HelpPopover
                                    ]
                                    [ Html.span [ class "fa fa-question-circle" ] [] ]
                                )
                                |> Popover.right
                                |> Popover.titleH4 [] [ Html.text "FASTA format" ]
                                |> Popover.content []
                                    [ Html.text
                                        (case model.optype of
                                            Nothing ->
                                                ""

                                            Just Contigs ->
                                                """
                                                Please provide nucleotides (or change to peptides mode above).
                                                Please avoid contigs containing non-canonical bases, such as N, R or Y."""

                                            Just Peptides ->
                                                """
Peptides submitted to the Macrel prediction should consist of 20 canonical
amino acids and their length should range from 10 to 100 amino acids."""
                                        )
                                    ]
                                |> Popover.view model.helpPopoverState
                            ]
                        , Textarea.textarea <|
                            [ Textarea.id "fasta"
                            , Textarea.rows 10
                            , Textarea.onInput UpdateFacontent
                            , Textarea.attrs [ placeholder placeholderText ]
                            , Textarea.value model.facontent
                            ]
                                ++ (case faerror of
                                        Nothing ->
                                            []

                                        Just _ ->
                                            [ Textarea.danger ]
                                   )
                        , Grid.row [ Row.rightXl ]
                            [ Grid.col [] [ Html.text "" ]
                            , Grid.col [ Col.textAlign Text.alignXsRight ]
                                [ Button.button [ Button.small, Button.outlineSecondary, Button.onClick SetExample ] [ Html.text "Example" ] ]
                            ]
                        , Button.button [ Button.primary, Button.onClick SubmitData ] [ Html.text "Submit" ]
                        ]
            ]
        ]


contigExampleData : String
contigExampleData = """>scaffold2530_2_MH0058
CTTCTGATCTTTACGCAGCATTGTGTGTTTCCACCTTTCAAAAAATTCTCCGTGAACTGC
GCCCTGGGAGTGGTGAAATCCTCCGCGGAACGAAGTCCCGGAATTGCGCACAAATTCACG
TGCTGAACAATTTTACCATAGGAATGTGCGGTTGTAAAGAGAAAAATGCAAAAAATTCCT
TATTTTTATAAAAGGAGCGGGGAAAAGAGGCGGAAAATATTTTTTTGAAAGGGGATTGAC
AGAGAGAAACGGCCGTGTTATCCTAACTGTACTAACACACATAGTACAGTTGGTACAGTT
CGGAGGAACGTTATGAAGGTCATCAAGAAGGTAGTAGCCGCCCTGATGGTGCTGGGAGCA
CTGGCGGCGCTGACGGTAGGCGTGGTTTTGAAGCCGGGCCGGAAAGGAGACGAAACATGA
TGCTGTTTGGTTTTGCGGGGATCGCCGCCATCGTGGGTCTGATTTTTGCCGCTGTTGTTC
TGGTGTCCGTGGCCTTGCAGCCCTGAGAACGGGGCAGATGCAATGAGTACGCTGTTTTTG
CTTGGTATCGCAGGCGCGGTACTGCTGGTTATTTTGCTGACAGCGGTGATCCTGCACCGC
TGATCGAACATTCCTCAGAAAGGAGAGGCACACGTTCTGACATTGAATTACCGGGATTCC
CGTCCCATTTATGAACAGATCAAGGACGGCCTGCGGCGGATGATCGTCACCGGGGCC
>scaffold75334_1_MH0058
ACAGCTTCCTCACCATCAACAGCCACTGCTACGATACCGGCAGGAACAGAGATTGTAGCG
TTATCGGAAGTAAGAACGGTCTCAGCGATTACCTTACCCAAGATATTCGTGATAACTACA
GACTTACCAGCTGCGCCTTGAACGGTTACGGTACCGTTACCGGCTACTACAGAGATACCT
TCTACAGCATCGATTGTTTCGTTATCTGTTGCGATATCATCACCTTGCTCCACATTAAAG
ATCAAAGCATCGTCACCACCTGTATTCATCTCATCGAAATTAGAAGAACGATCATCAGAC
AGAACTAAACAACCATTCTGCATTCTCAACCAAGCCGCATATGTAGGAGCGATGTCACCC
ATAGCAGAATTATTGTAACCAGGAACATGTTTACTCTTCATAGACTCGAACAAGAATGCT
CTATCAGCTTCTACCTCATTAGCGGCAACTTCCTTGTTTACGAAACGCATAGACCAAGTC
ACATACTTATGGTTATCACCAGATAAGATATATTTGTGTGAAACAAATTCATCTTCAGAT
ACTCCAGCCTTCTTAGCCGCAGTCCAAGCATCCTCCTCAGCCTTGTTCAAATCAGCGAAG
TTGATCTTCTCGTTCGGTAAGTTCTTGAACTCATCTCTCAAGATATACAAAGTATCAGCT
ACACGGATAGCTTCCACGAAACCTGCACGATCATATTTCTTCCACATGTAGTCAGCATCT
TGCTCCCCATTTGATAATGTTGACCAACCACATTTATTAGCGAAATCATGGAAATTGATC
AAATATTTACCTCTTTCAAAGCCCGGAACAGCCGGTTTTGCGTGAACGCAATGCCATTTA
TCTGTCGGTTTACCTTCTGCGGTAAAGTGATGGTCATCTTCCGTACAAGGTACGCCTTCA
ACTCCTTCGAAATCGTTACGATCAATAGAGATCAAATATTGAGGCTTGATATTACCAGAA
CCACGGTTTACCCATGCGGTATCAACGATGAATGACAAACCATCCTCAGTCTTATCCGGA
GTATAAATACCTAAGAAGTCAATACCTTCTTTCATGAAGTTCTTATTATTCTCAACCTGC
AAGTATTCTTTACGGTATTTCTCGATAAAACGTAAAGTATCGGCCTTGTCACCTTCATTA
CCTTCAAGTTCAAGAGAACTGAAACGACGGTAAAGCGGAGTGTTGTCCGGTTCGATAGCG
AAAGCAGAAGTACGAGTCTCGCCTAATACTTGATTCTTCAATGTAGCGGCACCGTCATAA
TCGGATACTCCAGCTTTCTGATAACCTAATACATATTTTGTAGCATTAGAATAATTATCA
TATGCAGCATTAACAATCGCATAATAGTGCTTTCCACTGATATAGTTGTTTTCTTTGAAG
AATGCATAATAAGTCGTATAAGATTGCTGATGACCAGTAGCACTAGAACCTACATTAAAC
TTATCTTCCTTATTAACTTTCCATTCATTAAGTTCACCTTTACCATCTTTATAAGAAACC
TCATAAGCAGTTCTCACTAGAGTCTTCAAGCCTTTAATACGATTCTTAGCCACATCATCG
CTAACCTTATAACCGTAAGGGATATCTACAGTCGCAAATATCTTTGAGTTATTATTCCAA
CGCTCAGTCAATGTATCAATTACGAAAGCATCTTTTCCATCCAACACAGTCAACGTAGAG
TCTGTAGATTTAGCGATGTATTTATCCGTAGCATAAGGATGCCAATAGTTAAACGTATAT
TTGTTAACCAACAAAGAATCTTTCTCCAACTTTCTGTAACCTAAATACGGATCAGAAATA
GAAGCTGCCGGAACTTTCTCGAAGAACAAAGAATCTATACCGACAGAGCCATACTCCGCT
GTAAGTTTATCTCCATATACAAACATATAAGAACCACCCTCTGCCTTTCTTAACTGAACA
GTAGAATAAACAGCAGTCTTATATGACTCCATCTGGCCATCACCATCAAAATCCGCATTT
ATAACTTTATCTGCGAATTCACGGTTAGAGATAGTAACCGGAGACACAGCCTTCACTTTA
TCATTACTTGTATTTTTCTTCAATACAACCCATTGATAAGCTGGCATATGAGCAACACTC
TGCTCATCCTCATTCACGGTTGTCCAACGGATAGTACCATTCTCATAGATAGGAGAAGCT
AAATACTGTCCTTGTTTATTCTTGATGAAATAAACACCATCATCAACGGAAGTCTTGGAA
GAACCCTTTTCCTCACATCCGCTAAGACCCAAAGAAATATGAGTGTTCTGGTCCTCCGGA
TCAACTGTCAAAATACAAGTTTCATCTTTAATCAAGTCTTGCAAAGAGACACGCCAGAAC
TCATGCTCGTTAACTGGAGTAGCCGTAACGTGCGTATTCCAATACTTGCCATCATTATTC
CAAGTAACTTTTTTTACATAGATGTATAAGCTATCGCCACTCGGAGAATAGATGAATTTG
AACTGATGTTGAGCACGTAATTCAGAGCTAATAGAACTGTAAGCATCAGCTTTATCCTTT
GCTTTCTCTGTCCAACCGTAAGCTAAGAACTTTGTACCTGTCTCATTCGTATAAGCCGTA
TCAACTTTCAAATAAGCGTCTTTATCCTTTTGCTTGATGAAAAGCCATTTGTTATTATCT
TTATCCTCTGCGATAAACTTCTGCTCATTGAACGGATTCTTTAAGCTAGTACCTTTCACG
TCCGGAGTGAAAGTCAATTGTACTCCAGCCTTGTTATCTTGAAGAAGACCCAACTTCGTA
TTTACTTGATCTTCGCTCAATGCGATTTGTGCTGCGCCAACCAAAGCAAAGTTAGTCACA
TCAGCGGCGTTTGAAGTGGCATCTATTTGATTAGCACCCCACTTGGCAACCTTAACAGCT
CCGGTAGTAGGATCCGCTTTCAAACCAACAATTGAGTCCGTTGAGAAATAAGAATACAAA
GGTCTCTTTTCTTCCAAATCCTTGTATGAGCGAGAGAATGCCCAACCTGCGATCTCACCA
CCTAAAACAGGTTTCCAAGCACCATTCGTACCATTCTCAGTCTTCTCATGGCCAGCCATT
GTCAAATCCAACATAGTTCCAGACAATTTATTCTGGAAGTCATAAATAGGAGCTTGACCT
TGATTATAATTAGAGACAGAAACACACCACAATGTAGCCTCTAAGTTATTTTTAGCTTCG
CTTGCACTATAAACACGTAGTTCATAATCACCTGTTCCACGATTTAGCTCCATCGCAAGA
TAAGCAGGAGTAGTGCCATCCATGACCTTCAACTGATAAAGACCAGAATTAGCTCCCTCC
TTCAAACCGCCTAAACGCCATTCTTGACCCAATACAGTTTCTGGGTCTACTCGACTTGGT
GTAGTCTGTGCATTAACAGACATAACACTTAACAGTGCCATACCTGCCAAAAGAGTAGAA
AACT"""

peptidesExampleData : String
peptidesExampleData = """>AP00002|AMP
YVPLPNVPQPGRRPFPTFPGQGPFNPKIKWPQGY
>AP00007|AMP
GNNRPVYIPQPRPPHPRL
>P20491|NAMP
MISAVILFLLLLVEQAAALGEPQLCYILDAVLFLYGIVLTLLYCRLKIQVRKAAIASREKADAVYTGLNTRSQETYETLKHEKPPQ
>CattleAMP|AMP
WKVWYRMMPAMSSTMVAAVAVPKKMTKKFPTKGLNSHIAA
>P35109|NAMP
MVDDPNKVWPTGLTIAESEELHKHVIDGSRIFVAIAIVAHFLAYVYSPWLH
>P19962|NAMP
DSDSAQNLIG"""
