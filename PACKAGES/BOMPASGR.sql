--------------------------------------------------------
--  DDL for Package BOMPASGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPASGR" AUTHID CURRENT_USER as
/* $Header: BOMASGRS.pls 115.2 99/07/16 05:09:02 porting ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMASGRS.pls                                               |
| DESCRIPTION  : This package contains functions used to assign routing     |
| 		 data in the interface tables                               |
| Parameters:	org_id		organization_id                             |
|		all_org		process all orgs or just current org        |
|				1 - all orgs                                |
|				2 - only org_id                             |
|    		prog_appid      program application_id                      |
|    		prog_id  	program id                                  |
|    		req_id          request_id                                  |
|    		user_id		user id                                     |
|    		login_id	login id                                    |
| History:	                                                            |
|    09/28/93   Shreyas Shah	creation date                               |
|    05/03/94   Julie Maeyama   modified logic                              |
|                                                                           |
+==========================================================================*/
FUNCTION bmartorg_assign_rtg_orgid (
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER;

FUNCTION bmasrrev_assign_rtg_revision (
    org_id		NUMBER,
    all_org		NUMBER,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    req_id		NUMBER,
    err_text  	IN OUT 	VARCHAR2
)
    return INTEGER;

FUNCTION bmprtgh_assign_rtg_header (
    org_id		NUMBER,
    all_org		NUMBER,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    req_id		NUMBER,
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER;

FUNCTION bmasopd_assign_operation_data (
    org_id		NUMBER,
    all_org		NUMBER,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    req_id		NUMBER,
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER;


FUNCTION bmasrsd_assign_resource_data (
    org_id		NUMBER,
    all_org		NUMBER,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    req_id		NUMBER,
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER;

FUNCTION bmgrtsq_get_routing_sequence (
    org_id 		NUMBER,
    item_id		NUMBER,
    alt_desg		VARCHAR2,
    routing_seq_id OUT	NUMBER,
    err_text	   OUT	VARCHAR2
)
    return INTEGER;

FUNCTION bmgopsq_get_op_sequence(
        rtg_seq_id      NUMBER,
        op_seq          NUMBER,
        eff_date        VARCHAR2,
        op_seq_id   OUT NUMBER,
        err_text    OUT VARCHAR2
)
    return INTEGER;

FUNCTION bmasopid_assign_op_seq_id(
	org_id		NUMBER,
	assy_id  	NUMBER,
	alt_desg	VARCHAR2,
	op_seq 		NUMBER,
	op_id		NUMBER,
	eff_date 	VARCHAR2,
	err_text    OUT VARCHAR2
)
    return INTEGER;

FUNCTION bmasrtgid_assign_rtg_seq_id(
	org_id		NUMBER,
	assy_id  	NUMBER,
	alt_desg	VARCHAR2,
	rtg_id		NUMBER,
	err_text    OUT VARCHAR2
)
    return INTEGER;

FUNCTION bmgrtin_get_rtg_info(
        org_id      OUT NUMBER,
        item_id     OUT NUMBER,
        alt_desg    OUT VARCHAR2,
        rtg_seq_id      NUMBER,
        err_text    OUT VARCHAR2
)
    return INTEGER;

FUNCTION bmgtdep_get_department(
	org_id		NUMBER,
	dept_code 	VARCHAR2,
	dept_id	  OUT 	NUMBER,
	err_text  OUT 	VARCHAR2
)
    return INTEGER;

FUNCTION bmgtstdop_get_stdop(
	org_id		NUMBER,
	stdop_code	VARCHAR2,
	stdop_id   OUT	NUMBER,
	err_text   OUT	VARCHAR2
)
    return INTEGER;

FUNCTION bmasritm_assign_rtg_item_id(
    org_id		NUMBER,
    item_num		VARCHAR2,
    item_id		NUMBER,
    err_text	 OUT 	VARCHAR2
)
    return INTEGER;

END BOMPASGR;

 

/
