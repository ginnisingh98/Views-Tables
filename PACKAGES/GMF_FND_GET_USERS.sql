--------------------------------------------------------
--  DDL for Package GMF_FND_GET_USERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_FND_GET_USERS" AUTHID CURRENT_USER as
/* $Header: gmfusrns.pls 115.0 99/07/16 04:25:55 porting shi $ */
    function FND_GET_USERS (userid   number)
	                    return   varchar2;
END GMF_FND_GET_USERS;

 

/
