module Site exposing (config)

import DataSource
import Head
import Pages.Manifest as Manifest
import Route
import SiteConfig exposing (SiteConfig)


type alias Data =
    ()


config : SiteConfig Data
config =
    { data = data
    , canonicalUrl = "https://big-data-biology.org"
    , manifest = manifest
    , head = head
    }


data : DataSource.DataSource Data
data =
    DataSource.succeed ()


head : Data -> List Head.Tag
head static =
    [ Head.sitemapLink "/sitemap.xml"
    ]


manifest : Data -> Manifest.Config
manifest static =
    Manifest.init
        { name = "Big Data Biology Lab (BDB-Lab)"
        , description = "BDB-Lab is a computational biology group at Fudan University, "
                        ++"working on the global microbiome."
        , startUrl = Route.Index |> Route.toPath
        , icons = []
        }
