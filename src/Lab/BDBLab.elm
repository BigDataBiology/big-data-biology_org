module Lab.BDBLab exposing (members, membersAndAlumni, papers, projects)

import DataSource exposing (DataSource)
import DataSource.Glob as Glob
import DataSource.File
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
        |> Decode.hardcoded Lab.Published
        |> Decode.required "journal" Decode.string
        |> Decode.required "date" Decode.string
        |> Decode.required "year" Decode.int
        |> Decode.required "doi" Decode.string
        |> Decode.required "authors" (Decode.list Decode.string)

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
