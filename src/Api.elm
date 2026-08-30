module Api exposing (routes)

import ApiRoute
import DataSource exposing (DataSource)
import Html exposing (Html)
import Path
import Route exposing (Route)
import NotFound
import Site
import Sitemap


routes :
    DataSource (List Route)
    -> (Html Never -> String)
    -> List (ApiRoute.ApiRoute ApiRoute.Response)
routes getStaticRoutes htmlToString =
    [ ApiRoute.succeed
        (getStaticRoutes
            |> DataSource.map
                (\allRoutes ->
                    { body =
                        Sitemap.build
                            { siteUrl = Site.config.canonicalUrl }
                            (List.map sitemapEntry allRoutes)
                    }
                )
        )
        |> ApiRoute.literal "sitemap.xml"
        |> ApiRoute.single
    , ApiRoute.succeed
        (DataSource.succeed { body = NotFound.document htmlToString })
        |> ApiRoute.literal "404.html"
        |> ApiRoute.single
    ]


sitemapEntry : Route -> { path : String, lastMod : Maybe String }
sitemapEntry route =
    { path = Path.toRelative (Route.toPath route)
    , lastMod = Nothing
    }
