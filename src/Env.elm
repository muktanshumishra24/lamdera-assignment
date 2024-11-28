module Env exposing (Mode(..), mode)


type Mode
    = Production
    | Development


mode : Mode
mode =
    Development