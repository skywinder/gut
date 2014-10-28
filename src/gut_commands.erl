-module(gut_commands).
-export([
         new/1,
         find/1,
         erlang_mk/1,
         escriptize/1,
         version/1,
         update/1,
         update_generators/1
        ]).

%% Commands
version(_) ->
    io:format("0.2~n"),
    ok.

new([ProvidedName, Name | _]) ->
    FullGeneratorName = gut_suffix:full_name(ProvidedName),
    Values = [{<<"{{NAME}}">>, Name}],
    Generator = gut_generators:find_by_name(FullGeneratorName),
    case Generator of
        not_found ->
            io:format("Generator ~s not found ~n", [ProvidedName]);
        #{name := GenName,
          url := GenUrl} ->
            gut_generators:clone(GenName, GenUrl),
            gut_generators:copy(GenName, Name),
            os:cmd("rm -rf " ++ Name ++ "/.git"),

            gut_compile:compile(Name, Values),
            io:format("Generated ~p on ~p~n", [FullGeneratorName, Name])
    end,
    ok;
new(_) ->
    throw({error, "Missing generator/template name"}).

find([]) ->
    io:format("Find generators...~n"),
    Generators = gut_generators:find_all(),
    lists:foreach(fun print_generator/1, Generators),
    ok;
find([Name | _]) ->
    Generators = gut_generators:find_all_by_name(Name),
    lists:foreach(fun print_generator/1, Generators),
    ok.

print_generator(#{name := GenName, description := Desc}) ->
    ShortName = gut_suffix:short_name(GenName),
    io:format("~s ~s~n", [color:green(ShortName), Desc]).

erlang_mk(_) ->
    Url = "https://raw.githubusercontent.com/"
        "ninenines/erlang.mk/master/erlang.mk",
    {ok, "200", _, Content} = ibrowse:send_req(Url, [], get),
    file:write_file("erlang.mk", Content).

escriptize([]) ->
    gut_escriptize:run(),
    ok;
escriptize([Name | _]) ->
    gut_escriptize:run(Name),
    ok.

update(_) ->
    Url = "https://raw.githubusercontent.com/"
        "unbalancedparentheses/gut/master/bin/gut",
    case os:find_executable("gut") of
        false ->
            io:format("Could not find gut in your system");
        Path ->
            {ok, "200", _, Content} = ibrowse:send_req(Url, [], get),
            file:write_file(Path, Content)
    end,
    ok.

update_generators(_) ->
    gut_generators:update(),
    ok.
