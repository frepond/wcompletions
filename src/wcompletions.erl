-module(wcompletions).

%% API exports
-export([main/1]).

%%====================================================================
%% API functions
%%====================================================================

%% escript Entry point
main([Dir]) -> main([Dir, ".erl_workspace.json"]);
main([Dir, Output]) ->
    io:format("Args: ~p, ~p~n", [Dir, Output]),
    Mods = modules_exports(Dir),
    io:format("Args: ~p~n", [Mods]),
    file:write_file(Output, jsx:encode(Mods)),
    erlang:halt(0);
main(_) -> io:format("Usage: wcompletions <Dir> [Filename]~n"), halt(1).

%%====================================================================
%% Internal functions
%%====================================================================
modules_exports(Dir) ->
    PAs = filelib:wildcard(Dir ++ "/**/ebin"),
    io:format("PA: ~p~n", [PAs]),
    lists:foreach(fun (D) -> code:add_path(D) end, PAs),
    Beams = filelib:wildcard(Dir ++ "/**/ebin/*.beam"),
    lists:foldl(fun module_export/2, #{}, Beams).

module_export(Beam, Map) ->
    ModName = list_to_atom(filename:basename(Beam, ".beam")),
    Exports = ModName:module_info(exports),
    Map#{ModName => [<<(atom_to_binary(Fun, utf8))/binary, "/", (integer_to_binary(Arity))/binary>> || {Fun, Arity} <- Exports]}.
