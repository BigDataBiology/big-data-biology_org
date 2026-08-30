module SocialCard exposing (default, forPaper, forPerson)

{-| The images used in the Open Graph / Twitter card of every page.

`Pages.Url.fromPath` (rather than `Pages.Url.external`) makes elm-pages prepend
the canonical site URL from `Site.config`, which is what social networks need:
they will not resolve a site-relative `og:image`.

`default` is a PNG rather than `images/bdb-lab-logo.svg` because none of the
major networks (Facebook, Twitter/X, LinkedIn, Slack) render SVG cards.

-}

import Head.Seo as Seo
import Pages.Url
import Path
import Set exposing (Set)


{-| The lab logo: used as-is by most pages, and as the fallback for the pages
below that have something better to show.
-}
default : Seo.Image
default =
    { url = image "images/bdb-lab-social-card.png"
    , alt = "Big Data Biology Lab logo"
    , dimensions = Just { width = 1200, height = 1200 }
    , mimeType = Just "image/png"
    }


{-| The paper's own thumbnail, when it has one, so that a shared link to a
paper shows that paper.

`available` is `Lab.BDBLab.paperImages`: not every paper has a thumbnail, and a
card pointing at a 404 is worse than the generic one.

-}
forPaper : Set String -> { a | slug : String, title : String } -> Seo.Image
forPaper available paper =
    if Set.member paper.slug available then
        { url = image ("images/papers/" ++ paper.slug ++ ".png")
        , alt = "Thumbnail for " ++ paper.title
        , dimensions = Nothing
        , mimeType = Just "image/png"
        }

    else
        default


{-| The member's own photo, when they have one. `available` is
`Lab.BDBLab.personImages`; see `forPaper`.
-}
forPerson : Set String -> { a | slug : String, name : String } -> Seo.Image
forPerson available member =
    if Set.member member.slug available then
        { url = image ("images/people/" ++ member.slug ++ ".jpeg")
        , alt = "Photo of " ++ member.name
        , dimensions = Nothing
        , mimeType = Just "image/jpeg"
        }

    else
        default


image : String -> Pages.Url.Url
image path =
    Pages.Url.fromPath (Path.fromString path)
