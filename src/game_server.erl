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


-module(game_server).

%% API.
-export([start/0, stop/0]).

%% API.

start() ->
    io:format("Game Server Starting~n"),
    % ensure_started(crypto),
    % ok = lager:start(), %% Logger
    ensure_started(sync), %% Hot reload code
    % ensure_started(gproc), %% Process dictionary
    % ensure_started(emysql), %% Mysql
    % ok = life_cycle:before_start(),
    ok = application:start(game_server). %% Game Server
    % ok = life_cycle:after_start().

stop() ->
	io:format("Game Server Stopping~n"),
	% ok = life_cycle:before_stop(),
	application:stop(game_server),
	% ok = life_cycle:after_stop(),
	application:stop(crypto),
	application:stop(sync),
	application:stop(gproc),
	application:stop(emysql).

-spec ensure_started(module()) -> ok.
ensure_started(App) ->
    case application:start(App) of
        ok -> ok;
        {error, {already_started, App}} -> ok
    end.
