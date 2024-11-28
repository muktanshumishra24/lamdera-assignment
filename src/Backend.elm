module Backend exposing (..)

import Lamdera exposing (ClientId, SessionId)
import Types exposing (..)
import Random

app =
    Lamdera.backend
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , updateFromFrontend = updateFromFrontend
        }

init : ( BackendModel, Cmd BackendMsg )
init =
    ( { circles = []
      , nextId = 0
      }
    , Cmd.none
    )

update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

generateRandomVelocity : Int -> Float
generateRandomVelocity seed =
    let
        speed = 2.0
        (randomValue, _) = Random.step (Random.float -1 1) (Random.initialSeed seed)
    in
    speed * randomValue

updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend _ _ msg model =
    case msg of
        NewCircleRequested color ->
            let
                -- Use different seeds for x and y positions
                (randomX, _) = 
                    Random.step (Random.float 100 700) (Random.initialSeed model.nextId)
                    
                (randomY, _) =
                    Random.step (Random.float 100 700) (Random.initialSeed (model.nextId + 1))

                newCircle =
                    { color = color
                    , x = randomX
                    , y = randomY
                    , dx = generateRandomVelocity model.nextId
                    , dy = generateRandomVelocity (model.nextId + 2)
                    , id = model.nextId
                    }
                
                newCircles =
                    newCircle :: model.circles
            in
            ( { model 
                | circles = newCircles
                , nextId = model.nextId + 1
              }
            , Lamdera.broadcast (NewCircleCreated newCircles)
            )