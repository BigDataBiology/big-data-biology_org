module Lab.BDBLab exposing (members, papers, memberLPC)

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

import SiteMarkdown
import Lab.Lab as Lab

projectGMGC =
    { title = "Global Microbial Gene Catalog"
    , short_description = ""
    , long_description = ""
    }


paperMACREL =
    { title = "MACREL: antimicrobial peptide screening in genomes and metagenomes"
    , short_description = "Macrel is a tool for finding AMPs in (meta)genomes"
    , abstract = ""
    , status = Lab.Published
    , date = "2020"
    , year = 2020
    , url = "https://peerj.com/articles/10555"
    , journal = "PeerJ"
    , authors = [
            "Célio Dias Santos-Junior",
            "Shaojun Pan",
            "Xing-Ming Zhao",
            "Luis Pedro Coelho"]
    }
paperSemiBin =
    { title = "SemiBin: Incorporating information from reference genomes with semi-supervised deep learning leads to better metagenomic assembled genomes (MAGs)"
    , short_description = "SemiBin is a better binner"
    , abstract = ""
    , status = Lab.Preprint
    , date = "2021"
    , year = 2021
    , url = "https://doi.org/10.1101/2021.08.16.456517"
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
    , github = "luispedro"
    , twitter = "luispedrocoelho"
    , gscholar = "qTYua0cAAAAJ"
    , orcid = "0000-0002-9280-7885"
    , projects = [projectGMGC]
    , papers = [paperMACREL]
    }



papers =
    [ paperMACREL
    , paperSemiBin
    ]

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
                    (Decode.field "github" Decode.string)
                    (Decode.field "twitter" Decode.string)
                    (Decode.field "gscholar" Decode.string)
                    (Decode.field "orcid" Decode.string)
                    (Decode.field "short_bio" Decode.string)
