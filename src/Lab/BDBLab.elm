module Lab.BDBLab exposing (members, papers, memberLPC)

import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import DataSource.Glob as Glob
import DataSource.File
import OptimizedDecoder as Decode exposing (Decoder)
import OptimizedDecoder.Pipeline as Decode

import SiteMarkdown
import Lab.Lab as Lab

projectGMGC =
    { title = "Global Microbial Gene Catalog"
    , short_description = ""
    , long_description = ""
    }

paperSemiBin =
    { title = "SemiBin: Incorporating information from reference genomes with semi-supervised deep learning leads to better metagenomic assembled genomes (MAGs)"
    , short_description = "SemiBin is a better binner"
    , abstract = ""
    , status = Lab.Preprint
    , date = "2021"
    , year = 2021
    , doi = "https://doi.org/10.1101/2021.08.16.456517"
    , journal = "BioRxiv"
    , authors = [
            "Shaojun Pan",
            "Chengkai Zhu",
            "Xing-Ming Zhao",
            "Luis Pedro Coelho"]
    }

memberLPC =
    { name = "Luis Pedro Coelho"
    , title = "PI"
    , slug = "luispedrocoelho"
    , short_bio = """
Luis Pedro Coelho leads the Big Data Biology Lab. He has background in both
computer science and computational biology."""
    , long_bio = """
Luis Pedro Coelho leads the Big Data Biology Lab. He has background in both
computer science and computational biology.

Personal website: [http://luispedro.org](http://luispedro.org)
"""
    , github = Just "luispedro"
    , twitter = Just "luispedrocoelho"
    , gscholar = Just "qTYua0cAAAAJ"
    , orcid = Just "0000-0002-9280-7885"
    , projects = [projectGMGC]
    , papers = [paperSemiBin]
    }



papers : DataSource (List Lab.Publication)
papers =
    SiteMarkdown.mdFiles "papers/"
        |> DataSource.map
            (List.map
                (\mdpage ->
                    DataSource.File.bodyWithFrontmatter
                        readPaper
                        mdpage.path
                )
            )
        |> DataSource.resolve


readPaper : String -> Decoder Lab.Publication
readPaper abstract =
    Decode.decode Lab.Publication
        |> Decode.required "title" Decode.string
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
    SiteMarkdown.mdFiles "people/"
        |> DataSource.map
            (List.map
                (\mdpage ->
                    DataSource.File.bodyWithFrontmatter
                        (mdDecoder mdpage)
                        mdpage.path
                )
            )
        |> DataSource.resolve

mdDecoder : SiteMarkdown.MarkdownFile -> String -> Decoder Lab.Member
mdDecoder finfo body =
    Decode.map7 (\name
                title
                github
                twitter
                gscholar
                orcid
                short_bio
                ->
                    { name = name
                    , title = title
                    , slug = finfo.slug
                    , github = github
                    , twitter = twitter
                    , gscholar = gscholar
                    , orcid = orcid
                    , short_bio = short_bio
                    , long_bio = body
                    , projects = []
                    , papers = []
                    }
                )
                    (Decode.field "name" Decode.string)
                    (Decode.field "title" Decode.string)
                    (Decode.optionalField "github" Decode.string)
                    (Decode.optionalField "twitter" Decode.string)
                    (Decode.optionalField "gscholar" Decode.string)
                    (Decode.optionalField "orcid" Decode.string)
                    (Decode.field "short_bio" Decode.string)
