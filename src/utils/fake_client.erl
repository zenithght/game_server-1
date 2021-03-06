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

-module(fake_client).
-compile(export_all).

-include("../app/include/secure.hrl").


login() ->
    SomeHostInNet = "localhost", % to make it runnable on one machine
    {ok, Sock} = gen_tcp:connect(SomeHostInNet, 5555,
                                 [{active, false}, {packet, 2}]),
    send_request(login_params, Sock, {<<"test_udid">>}),
    _Response = recv_response(Sock),
    ok = gen_tcp:close(Sock).

request(Udid, Protocol, Params) ->
    SomeHostInNet = "localhost", % to make it runnable on one machine
    {ok, Sock} = gen_tcp:connect(SomeHostInNet, 5555,
                                 [{active, false}, {packet, 2}]),
    send_request(login_params, Sock, {Udid}),
    LoginResponse = recv_response(Sock),
    error_logger:info_msg("LoginResponse: ~p~n", [LoginResponse]),
    send_request(Protocol, Sock, Params),
    Response = recv_response(Sock),
    error_logger:info_msg("Response: ~p~n", [Response]),
    ok = gen_tcp:close(Sock),
    Response.

send_request(Path, Sock, Value) ->
    Data = api_encoder:encode(Path, Value),
    gen_tcp:send(Sock, secure:encrypt(Data)).

recv_response(Sock) ->
    {ok, Packet} = gen_tcp:recv(Sock, 0),
    Data = secure:decrypt(Packet),
    {Response, _LeftData} = api_decoder:decode(Data),
    error_logger:info_msg("Response: ~p~n", [Response]),
    Response.
