module Lab.BDBLab exposing (members, membersAndAlumni, paperImages, papers, personImages, projects)

import Set exposing (Set)

import DataSource exposing (DataSource)
import DataSource.File
import DataSource.Glob as Glob
import OptimizedDecoder as Decode exposing (Decoder)
import OptimizedDecoder.Pipeline as Decode

import SiteMarkdown
import Lab.Lab as Lab

papers : DataSource (List Lab.Publication)
papers =
    SiteMarkdown.mdFiles "papers/"
        |> DataSource.map
            (List.map
                (\mdpage ->
                    DataSource.File.bodyWithFrontmatter
                        (readPaper mdpage.slug)
                        mdpage.path
                )
            )
        |> DataSource.resolve
        |> DataSource.map (List.sortBy .date)
        |> DataSource.map List.reverse

-- | Slugs of the papers that have a thumbnail at
-- | `public/images/papers/<slug>.png`. Not every paper has one, so anything
-- | that points at the thumbnail (in particular the social card, which would
-- | otherwise advertise a 404) has to check first.
paperImages : DataSource (Set String)
paperImages = imageSlugs "papers" ".png"

-- | Slugs of the members that have a photo at
-- | `public/images/people/<slug>.jpeg`. See `paperImages`.
personImages : DataSource (Set String)
personImages = imageSlugs "people" ".jpeg"

imageSlugs : String -> String -> DataSource (Set String)
imageSlugs dir extension =
    Glob.succeed identity
        |> Glob.match (Glob.literal ("public/images/" ++ dir ++ "/"))
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal extension)
        |> Glob.toDataSource
        |> DataSource.map Set.fromList

projects : DataSource (List Lab.Project)
projects =
    SiteMarkdown.mdFiles "projects/"
        |> DataSource.map
            (List.map
                (\mdpage ->
                    DataSource.File.bodyWithFrontmatter
                        (readProject mdpage)
                        mdpage.path
                )
            )
        |> DataSource.resolve


readPaper : String -> String -> Decoder Lab.Publication
readPaper slug abstract =
    Decode.decode Lab.Publication
        |> Decode.required "title" Decode.string
        |> Decode.hardcoded slug
        |> Decode.required "short_description" Decode.string
        |> Decode.hardcoded abstract
        |> Decode.optional "status" readStatus Lab.Published
        |> Decode.required "journal" Decode.string
        |> Decode.required "date" Decode.string
        |> Decode.required "year" Decode.int
        |> Decode.required "doi" Decode.string
        |> Decode.required "authors" (Decode.list Decode.string)
        |> Decode.optional "aliases" (Decode.list Decode.string) []

-- | Papers are `published` unless the front matter says otherwise. Preprints
-- | are marked with `status: preprint` (see papers/README.md).
readStatus : Decoder Lab.PublicationStatus
readStatus =
    Decode.string
        |> Decode.andThen (\s -> case String.toLower s of
            "published" -> Decode.succeed Lab.Published
            "preprint" -> Decode.succeed Lab.Preprint
            "in press" -> Decode.succeed Lab.InPress
            "in-press" -> Decode.succeed Lab.InPress
            _ -> Decode.fail ("Unknown publication status: '" ++ s ++ "'"))

members : DataSource (List Lab.Member)
members =
    membersAndAlumni
        |> DataSource.map
            (List.filter (\m -> m.left == Nothing))

membersAndAlumni : DataSource (List Lab.Member)
membersAndAlumni =
    let
        enrich : List Lab.Member -> List Lab.Project -> List Lab.Publication -> List Lab.Member
        enrich ms projs pubs = List.map (enrich1 projs pubs) ms

        enrich1 : List Lab.Project -> List Lab.Publication -> Lab.Member -> Lab.Member
        enrich1 projs pubs m = { m
                    | papers = List.filter (\p -> List.member m.name p.authors) pubs
                    , projects = List.filter (\p -> List.member m.slug p.author_slugs) projs
                    }
    in
    DataSource.map3 enrich
            membersNoPapers
            projects
            papers
membersNoPapers : DataSource (List Lab.Member)
membersNoPapers =
    SiteMarkdown.mdFiles "people/"
        |> DataSource.map
            (List.map
                (\mdpage ->
                    DataSource.File.bodyWithFrontmatter
                        (readMember mdpage)
                        mdpage.path
                )
            )
        |> DataSource.resolve
        |> DataSource.map (List.sortBy .joined)


decodeOptional name
    = Decode.optional name (Decode.map Maybe.Just Decode.string) Nothing

readMember : SiteMarkdown.MarkdownFile -> String -> Decoder Lab.Member
readMember finfo body =
    Decode.decode Lab.Member
        |> Decode.required "name" Decode.string
        |> Decode.required "title" Decode.string
        |> Decode.required "joined" Decode.string
        |> decodeOptional "left"
        |> Decode.hardcoded finfo.slug
        |> Decode.required "short_bio" Decode.string
        |> Decode.hardcoded body
        |> decodeOptional "email"
        |> decodeOptional "github"
        |> decodeOptional "twitter"
        |> decodeOptional "gscholar"
        |> decodeOptional "orcid"
        |> Decode.hardcoded []
        |> Decode.hardcoded []

readProject :
    SiteMarkdown.MarkdownFile
    -> String
    -> Decoder Lab.Project
readProject finfo body =
    Decode.decode Lab.Project
        |> Decode.required "title" Decode.string
        |> Decode.hardcoded finfo.slug
        |> Decode.required "author_slugs" (Decode.list Decode.string)
        |> Decode.hardcoded []
        |> Decode.required "short_description" Decode.string
        |> Decode.hardcoded body
