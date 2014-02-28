%%%===================================================================
%%% Generated by generate_api.rb 2014-02-28 13:50:04 +0800
%%%===================================================================
-module(response_encoder).
-export([encode/2]).
  
encode(town, Value) ->
    Type = 1,
    {Name, PositionX, PositionY, UserId} = Value,
    DataList = [
        utils_protocol:encode_integer(Type),
        utils_protocol:encode_string(Name),
        utils_protocol:encode_integer(PositionX),
        utils_protocol:encode_integer(PositionY),
        utils_protocol:encode_string(UserId)
    ],
    list_to_binary(DataList);
encode(user, Value) ->
    Type = 2,
    {Uuid, Udid, Name, Gem, Paid} = Value,
    DataList = [
        utils_protocol:encode_integer(Type),
        utils_protocol:encode_string(Uuid),
        utils_protocol:encode_string(Udid),
        utils_protocol:encode_string(Name),
        utils_protocol:encode_integer(Gem),
        utils_protocol:encode_float(Paid)
    ],
    list_to_binary(DataList).