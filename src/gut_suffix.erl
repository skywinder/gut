-module(gut_suffix).
-export([
         suffix/0,
         has_suffix/1,
         full_name/1
        ]).

-spec suffix() -> string().
suffix() ->
    "-gutenberg-generator".

has_suffix(String) ->
    case re:run(String, suffix()) of
        nomatch ->
            false;
        _ ->
            true
    end.

full_name(ProvidedName) ->
    case has_suffix(ProvidedName) of
        false ->
            ProvidedName ++ suffix();
        true ->
            ProvidedName
    end.
