--------------------------------------------------------
--  DDL for Package BOMPAVBM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPAVBM" AUTHID CURRENT_USER as
/* $Header: BOMAVBMS.pls 115.1 99/07/16 05:09:40 porting ship $ */
-- =========================================================================
--    Copyright (c) 1993 Oracle Corporation Belmont, California, USA
--                           All rights reserved.
-- =========================================================================
--
--  File Name    : BOMAVBMS.pls
--  DESCRIPTION  : This is the main package used to assign bill data.
--  Parameters:	org_id		organization_id
-- 		all_org		process all orgs or just current org
-- 				1 - all orgs
-- 				2 - only org_id
--     		prog_appid      program application_id
--     		prog_id  	program id
--     		request_id      request_id
--     		user_id		user id
--    		login_id	login id
--  Return:	1 if success
-- 		SQLCODE if failure
--  History:
--     04/08/94   Julie Maeyama	creation date
--
-- =========================================================================
FUNCTION bmasbill_assign_bill_data (
    org_id		NUMBER,
    all_org		NUMBER		:= 1,
    prog_appid		NUMBER		:= -1,
    prog_id		NUMBER		:= -1,
    request_id		NUMBER		:= -1,
    user_id		NUMBER		:= -1,
    login_id		NUMBER		:= -1,
    err_text	 OUT 	VARCHAR2
)
    return INTEGER;

FUNCTION bmvrbill_verify_bill_data (
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

END BOMPAVBM;

 

/
