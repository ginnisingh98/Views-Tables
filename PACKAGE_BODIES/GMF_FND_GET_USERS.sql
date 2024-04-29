--------------------------------------------------------
--  DDL for Package Body GMF_FND_GET_USERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_FND_GET_USERS" as
/* $Header: gmfusrnb.pls 115.0 99/07/16 04:25:50 porting shi $ */
    function FND_GET_USERS (userid   number) return varchar2 is

        username   varchar2(100);

        begin
             select USR.USER_NAME
             into   username
             from   FND_USER USR
             where  USR.user_id = userid;

             return(username);

	exception
		when NO_DATA_FOUND THEN
			return('ORAF');

        end;

END GMF_FND_GET_USERS;

/
