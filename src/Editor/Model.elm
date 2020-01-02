module Editor.Model exposing (InternalState, Snapshot, lastLine, initialText, slider)

import Buffer exposing (Buffer)
import Editor.History exposing (History)
import Position exposing (Position)
import Window exposing (Window)
import Text
import RollingList exposing(RollingList)
import Editor.Config exposing (Config)
import SingleSlider as Slider exposing (..)



type alias Snapshot =
    { cursor : Position
    , selection : Maybe Position
    , buffer : Buffer
    }

type alias InternalState =
    { config : Config
    , scrolledLine : Int
    , window : Window
    , cursor : Position
    , selection : Maybe Position
    , selectedText : Maybe String 
    , dragging : Bool
    , history : History Snapshot
    , searchTerm : String
    , replacementText : String
    , searchResults : RollingList (Position, Position)
    , showHelp : Bool
    , showGoToLinePanel : Bool
    , showSearchPanel : Bool
    , savedBuffer : Buffer
    , slider : Slider.Model
    }

slider : Slider.Model
slider =
  let
    initialSlider =
      Slider.defaultModel
  in
    { initialSlider
        | min = 0
        , max = 100
        , step = 0.01
        , value = 0
    }

lastLine = 23

initialText = Text.jabberwocky
