%%%-------------------------------------------------------------------
%% The MIT License (MIT)
%%
%% Copyright (c) 2014-2024
%% Savin Max <mafei.198@gmail.com>
%%
%% Permission is hereby granted, free of charge, to any person obtaining a copy
%% of this software and associated documentation files (the "Software"), to deal
%% in the Software without restriction, including without limitation the rights
%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the Software is
%% furnished to do so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included in all
%% copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
%% SOFTWARE.

%%% @doc
%%%        Load Game Config data from YAML files to ets table for later using.
%%% @end
%%% Created :  一 10 07 23:50:49 2013 by Savin-Max
%%%-------------------------------------------------------------------

-module(game_numerical).

-behaviour(gen_server).

%% API
-export([start_link/0, find/2, find_element/3, all/1, load_data/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
    terminate/2, code_change/3]).

-define(SERVER, ?MODULE).
-define(DATA_DIR, "config/game_data/").
-include("include/config_names.hrl").

-record(state, {table}).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

all(TableName) ->
    ets:match_object(TableName, '$1').

find(TableName, Key) ->
    case ets:lookup(TableName, Key) of
        [Object] ->
            Object;
        [] ->
            undefined
    end.

find_element(TableName, Key, Pos) ->
    ets:lookup_element(TableName, Key, Pos).

load_data() ->
    gen_server:call(?SERVER, load_data).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    {ok, #state{}}.

handle_call(load_data, _From, State) ->
    load_config_data(),
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(Info, State) ->
    io:format("Info:~p~n", [Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

load_config_data() ->
    ModelNames = ?CONFIG_MODELS,
    lists:foreach(fun(ModelName) -> load_config_model(ModelName) end, ModelNames).

load_config_model(ModelName) ->
    ets:new(ModelName,
            [set, protected, named_table, {keypos, 2}, {read_concurrency, true}]),
    {ok, Records} = db:all(ModelName),
    ets:insert(ModelName, Records).
