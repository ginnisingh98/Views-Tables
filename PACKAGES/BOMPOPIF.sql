--------------------------------------------------------
--  DDL for Package BOMPOPIF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPOPIF" AUTHID CURRENT_USER as
/*  $Header: BOMOPIFS.pls 120.1 2005/06/20 01:20:01 appldev ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMPOPIF.pls                                               |
| DESCRIPTION  : This is the main package used to validate and process
| 		 open interface item/bil.routing/eco data.
| Parameters:	org_id		organization_id
|		all_org		process all orgs or just current org
|				1 - all orgs
|				2 - only org_id
|		val_rtg_flag	validate routings
|		val_bom_flag	validate boms
|		pro_rtg_flag	process routings
|		pro_bom_flag	process boms
|		del_rec_flag	delete processed rows
|    		prog_appid      program application_id
|    		prog_id  	program id
|    		request_id      request_id
|    		user_id		user id
|    		login_id	login id
| Return:	1 if success
|		SQLCODE if failure
| History:
|    09/26/93   Shreyas Shah	creation date
|    01/15/05   Bhavnesh Patel  Added Batch Id
|                                                                           |
+==========================================================================*/

--Open Interface Import for null batch id
FUNCTION bmopinp_open_interface_process (
    org_id		NUMBER,
    all_org		NUMBER		:= 1,
    val_rtg_flag	NUMBER		:= 1,
    val_bom_flag	NUMBER		:= 1,
    pro_rtg_flag	NUMBER		:= 1,
    pro_bom_flag	NUMBER		:= 1,
    del_rec_flag	NUMBER		:= 1,
    prog_appid		NUMBER		:= -1,
    prog_id		NUMBER		:= -1,
    request_id		NUMBER		:= -1,
    user_id		NUMBER		:= -1,
    login_id		NUMBER		:= -1,
    err_text	 IN OUT NOCOPY 	VARCHAR2
)
    return INTEGER;

--Open Interface Import for given batch id
FUNCTION bmopinp_open_interface_process (
    org_id		NUMBER,
    all_org		NUMBER		:= 1,
    val_rtg_flag	NUMBER		:= 1,
    val_bom_flag	NUMBER		:= 1,
    pro_rtg_flag	NUMBER		:= 1,
    pro_bom_flag	NUMBER		:= 1,
    del_rec_flag	NUMBER		:= 1,
    prog_appid		NUMBER		:= -1,
    prog_id		NUMBER		:= -1,
    request_id		NUMBER		:= -1,
    user_id		NUMBER		:= -1,
    login_id		NUMBER		:= -1,
    err_text	 IN OUT NOCOPY 	VARCHAR2,
    p_batch_id  IN  NUMBER
)
    return INTEGER;

/*
FUNCTION bmdelbom_delete_bom_oi (
	err_text    OUT	VARCHAR2
)
    return INTEGER;

FUNCTION bmdelrtg_delete_rtg_oi (
	err_text    OUT	VARCHAR2
)
    return INTEGER;
*/

END BOMPOPIF;

 

/
