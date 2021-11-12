module View exposing (View, map)

import Html exposing (Html)

type alias View msg =
    { title : String
    , body : List (Html msg)
    , sidebar : Maybe (Html msg)
    }


map : (msg1 -> msg2) -> View msg1 -> View msg2
map fn doc =
    { title = doc.title
    , body = List.map (Html.map fn) doc.body
    , sidebar = case doc.sidebar of
        Nothing -> Nothing
        Just s -> Just <| Html.map fn s
    }

