module Lab.BDBLab exposing (..)

import Lab.Lab

projectGMGC =
    { title = "Global Microbial Gene Catalog"
    , short_description = ""
    , long_description = ""
    }


paperMACREL =
    { title = "MACREL: antimicrobial peptide screening in genomes and metagenomes"
    , short_description = "Macrel is a tool for finding AMPs in (meta)genomes"
    , abstract = ""
    , status = Lab.Lab.Published
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
    , status = Lab.Lab.Preprint
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
    , photo = "LuisPedroCoelho.jpeg"
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


members =
    [ memberLPC
    ]

papers =
    [ paperMACREL
    , paperSemiBin
    ]

