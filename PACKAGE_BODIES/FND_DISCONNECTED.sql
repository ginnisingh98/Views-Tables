--------------------------------------------------------
--  DDL for Package Body FND_DISCONNECTED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DISCONNECTED" as
/* $Header: AFSCDCNB.pls 115.0.1150.1 1999/12/22 19:44:28 pkm ship $ */

    x_disconnected_mode boolean := FALSE;

function GET_DISCONNECTED return boolean is
begin
    return(x_disconnected_mode);
end GET_DISCONNECTED;

function DISCONNECTED_PARAM return boolean is
    profile_val varchar2(240);
begin
    begin
        select V.PROFILE_OPTION_VALUE
        into profile_val
        from FND_PROFILE_OPTIONS P, FND_PROFILE_OPTION_VALUES V
        where P.PROFILE_OPTION_NAME = 'DISCONNECTED_DATABASE'
        and P.APPLICATION_ID = 0
        and P.PROFILE_OPTION_ID = V.PROFILE_OPTION_ID
        and P.APPLICATION_ID = V.APPLICATION_ID
        and V.LEVEL_ID = 10001;
    exception
    when no_data_found then
        profile_val := 'N';
    end;

    if (profile_val = 'Y') then
        x_disconnected_mode := TRUE;
    end if;

    return(x_disconnected_mode);
end DISCONNECTED_PARAM;

end FND_DISCONNECTED;

/

  GRANT EXECUTE ON "APPS"."FND_DISCONNECTED" TO "APPLSYSPUB";
