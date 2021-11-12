module Lab.Lab exposing (..)

type PublicationStatus =
    Published
    | Preprint
    | InPress


type alias Publication =
    { title : String
    , slug : String
    , short_description : String
    , abstract : String
    , status : PublicationStatus
    , journal : String
    , date : String
    , year : Int
    , doi : String
    , authors : List String
    }

type alias Project =
    { title : String
    , slug : String
    , author_slugs : List String
    , papers : List Publication
    , short_description : String
    , long_description : String
    }

type alias Member =
    { name : String
    , title : String
    , joined : String
    , left : Maybe String
    , slug : String
    , short_bio : String
    , long_bio : String
    , email : Maybe String
    , github : Maybe String
    , twitter : Maybe String
    , gscholar : Maybe String
    , orcid : Maybe String
    , projects : List Project
    , papers : List Publication
    }


