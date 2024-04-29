--------------------------------------------------------
--  DDL for Package BOMPAVRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPAVRT" AUTHID CURRENT_USER as
/* $Header: BOMAVRTS.pls 115.1 99/07/16 05:09:46 porting ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMAVRTS.pls                                               |
| DESCRIPTION  : This package contains functions used to validate routing   |
| 		 data in the interface tables                               |
| Parameters:	org_id		organization_id                             |
|		all_org		process all orgs or just current org        |
|				1 - all orgs                                |
|				2 - only org_id                             |
|    		prog_appid      program application_id                      |
|    		prog_id  	program id                                  |
|    		request_id      request_id                                  |
|    		user_id		user id                                     |
|    		login_id	login id                                    |
| History:	                                                            |
|    09/28/93   Shreyas Shah	creation date                               |
|                                                                           |
+==========================================================================*/
FUNCTION bmasrtg_assign_rtg_data (
    org_id		NUMBER,
    all_org		NUMBER		:= 1,
    prog_appid		NUMBER		:= -1,
    prog_id		NUMBER		:= -1,
    request_id		NUMBER		:= -1,
    user_id		NUMBER		:= -1,
    login_id		NUMBER		:= -1,
    err_text     OUT 	VARCHAR2
)
    return INTEGER;

FUNCTION bmvrrtg_verify_rtg_data (
    org_id              NUMBER,
    all_org             NUMBER          := 1,
    prog_appid          NUMBER          := -1,
    prog_id             NUMBER          := -1,
    request_id          NUMBER          := -1,
    user_id             NUMBER          := -1,
    login_id            NUMBER          := -1,
    err_text     OUT    VARCHAR2
)
    return INTEGER;

END BOMPAVRT;

 

/
