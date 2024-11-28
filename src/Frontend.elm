module Frontend exposing (..)

import Browser exposing (Document)
import Browser.Events exposing (onAnimationFrameDelta, onResize)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (style)
import Lamdera
import Types exposing (..)
import Url

type alias Model =
    FrontendModel

app =
    Lamdera.frontend
        { init = init
        , update = update
        , updateFromBackend = updateFromBackend
        , view = view
        , subscriptions = subscriptions
        , onUrlRequest = \_ -> ClickedColor ""
        , onUrlChange = \_ -> ClickedColor ""
        }

init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { circles = []
      , windowWidth = 1400
      , windowHeight = 800
      }
    , Cmd.none
    )

subscriptions : Model -> Sub FrontendMsg
subscriptions model =
    Sub.batch
        [ onAnimationFrameDelta Tick
        , onResize GotWindowSize
        ]

update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        ClickedColor color ->
            ( model
            , Lamdera.sendToBackend (NewCircleRequested color)
            )
            
        Tick delta ->
            ( { model | circles = List.map (updateCirclePosition model) model.circles }
            , Cmd.none
            )
            
        GotWindowSize width height ->
            ( { model | windowWidth = width, windowHeight = height }
            , Cmd.none
            )

updateCirclePosition : Model -> Circle -> Circle
updateCirclePosition model circle =
    let
        newX = circle.x + circle.dx
        newY = circle.y + circle.dy
        
        (bounceX, newDx) =
            if newX <= 0 || newX >= toFloat (model.windowWidth - 50) then
                (if newX <= 0 then 0 else toFloat (model.windowWidth - 50), -circle.dx)
            else
                (newX, circle.dx)
                
        (bounceY, newDy) =
            if newY <= 0 || newY >= toFloat (model.windowHeight - 50) then
                (if newY <= 0 then 0 else toFloat (model.windowHeight - 50), -circle.dy)
            else
                (newY, circle.dy)
    in
    { circle 
        | x = bounceX
        , y = bounceY
        , dx = newDx
        , dy = newDy 
    }

updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NewCircleCreated newCircles ->
            ( { model | circles = newCircles }
            , Cmd.none
            )

colors : List String
colors =
    [ "#FF0000"  -- Red
    , "#00FF00"  -- Green
    , "#0000FF"  -- Blue
    , "#FFFF00"  -- Yellow
    , "#FF00FF"  -- Purple
    ]

view : Model -> Document FrontendMsg
view model =
    { title = "Color Circles"
    , body =
        [ div 
            [ style "padding" "20px"
            , style "height" (String.fromInt model.windowHeight ++ "px")
            , style "width" (String.fromInt model.windowWidth ++ "px")
            , style "overflow" "hidden"
            , style "position" "relative"
            ]
            [ viewColorPalette
            , viewCircles model.circles
            ]
        ]
    }

viewColorPalette : Html FrontendMsg
viewColorPalette =
    div 
        [ style "display" "flex"
        , style "gap" "10px"
        , style "margin-bottom" "20px"
        , style "position" "fixed"
        , style "z-index" "1"
        , style "background" "white"
        , style "padding" "10px"
        , style "border-radius" "10px"
        , style "box-shadow" "0 2px 10px rgba(0,0,0,0.1)"
        ]
        (List.map viewColorButton colors)

viewColorButton : String -> Html FrontendMsg
viewColorButton color =
    div
        [ style "width" "50px"
        , style "height" "50px"
        , style "background-color" color
        , style "cursor" "pointer"
        , style "border-radius" "5px"
        , style "transition" "transform 0.2s"
        , style "hover" "transform: scale(1.1)"
        , onClick (ClickedColor color)
        ]
        []

viewCircles : List Circle -> Html FrontendMsg
viewCircles circles =
    div
        [ style "position" "relative"
        , style "height" "100%"
        ]
        (List.map viewCircle circles)

viewCircle : Circle -> Html FrontendMsg
viewCircle circle =
    div
        [ style "position" "absolute"
        , style "width" "50px"
        , style "height" "50px"
        , style "border-radius" "50%"
        , style "background-color" circle.color
        , style "left" (String.fromFloat circle.x ++ "px")
        , style "top" (String.fromFloat circle.y ++ "px")
        , style "transition" "transform 0.2s"
        , style "transform" "translate(-50%, -50%)"
        ]
        []