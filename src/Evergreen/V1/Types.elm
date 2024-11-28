module Evergreen.V1.Types exposing (..)


type alias Circle =
    { color : String
    , x : Float
    , y : Float
    , dx : Float
    , dy : Float
    , id : Int
    }


type alias FrontendModel =
    { circles : List Circle
    , windowWidth : Int
    , windowHeight : Int
    }


type alias BackendModel =
    { circles : List Circle
    , nextId : Int
    }


type FrontendMsg
    = ClickedColor String
    | Tick Float
    | GotWindowSize Int Int


type ToBackend
    = NewCircleRequested String


type BackendMsg
    = NoOp


type ToFrontend
    = NewCircleCreated (List Circle)
