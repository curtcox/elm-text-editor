module Editor.Keymap exposing (decoder)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Editor.Update exposing (Msg(..))


type Modifier
    = None
    | Control
    | Shift
    | ControlAndShift


type alias Keydown =
    { char : Maybe String
    , key : String
    , ctrl : Bool
    , shift : Bool
    }


modifier : Bool -> Bool -> Modifier
modifier ctrl shift =
    case ( ctrl, shift ) of
        ( True, True ) ->
            ControlAndShift

        ( False, True ) ->
            Shift

        ( True, False ) ->
            Control

        ( False, False ) ->
            None


keydownDecoder : Decoder Keydown
keydownDecoder =
    Decode.map5 Keydown
        (Decode.field "key" Decode.string
            |> Decode.map
                (\key ->
                    case String.uncons key of
                        Just ( char, "" ) ->
                            Just (String.fromChar char)

                        _ ->
                            Nothing
                )
        )
        (Decode.field "key" Decode.string)
        (Decode.field "ctrlKey" Decode.bool)
        (Decode.field "shiftKey" Decode.bool)


decoder : Decoder Msg
decoder =
    keydownDecoder |> Decode.andThen keyToMsg


type alias Keymap =
    Dict String Msg


keymaps :
    { noModifier : Keymap
    , shift : Keymap
    , control : Keymap
    , controlAndShift : Keymap
    }
keymaps =
    { noModifier =
        Dict.fromList
            [ ( "ArrowUp", CursorUp )
            , ( "ArrowDown", CursorDown )
            , ( "ArrowLeft", CursorLeft )
            , ( "ArrowRight", CursorRight )
            , ( "Backspace", RemoveCharBefore )
            , ( "Delete", RemoveCharAfter )
            , ( "Enter", Insert "\n" )
            , ( "Home", CursorToStartOfLine )
            , ( "End", CursorToEndOfLine )
            , ( "Tab", IncreaseIndent )
            ]
    , shift =
        Dict.fromList
            [ ( "ArrowUp", SelectUp )
            , ( "ArrowDown", SelectDown )
            , ( "ArrowLeft", SelectLeft )
            , ( "ArrowRight", SelectRight )
            ]
    , control = Dict.empty
    , controlAndShift = Dict.empty
    }


keyToMsg : Keydown -> Decoder Msg
keyToMsg event =
    let
        keyFrom keymap =
            Dict.get event.key keymap
                |> Maybe.map Decode.succeed
                |> Maybe.withDefault (Decode.fail "This key does nothing")

        keyOrCharFrom keymap =
            Decode.oneOf
                [ keyFrom keymap
                , event.char
                    |> Maybe.map (Insert >> Decode.succeed)
                    |> Maybe.withDefault
                        (Decode.fail "This key does nothing")
                ]
    in
        case modifier event.ctrl event.shift of
            None ->
                keyOrCharFrom keymaps.noModifier

            Control ->
                keyFrom keymaps.control

            Shift ->
                keyOrCharFrom keymaps.noModifier

            ControlAndShift ->
                keyFrom keymaps.controlAndShift
