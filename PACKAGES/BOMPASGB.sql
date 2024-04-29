--------------------------------------------------------
--  DDL for Package BOMPASGB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPASGB" AUTHID CURRENT_USER as
/* $Header: BOMASGBS.pls 115.2 99/07/16 05:08:55 porting ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMPASGB.pls                                               |
| DESCRIPTION  : This package contains functions used to assign bill        |
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
|    11/11/93   Shreyas Shah	creation date                               |
|    04/24/94   Julie Maeyama   modifications                               |
+==========================================================================*/
FUNCTION bmablorg_assign_bill_orgid (
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER;

FUNCTION bmasrev_assign_revision (
    org_id              NUMBER,
    all_org             NUMBER := 2,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text  IN OUT    VARCHAR2
)
    return INTEGER;

FUNCTION bmasbilh_assign_bill_header (
    org_id		NUMBER,
    all_org		NUMBER := 2,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    req_id		NUMBER,
    err_text  IN OUT 	VARCHAR2
)
    return INTEGER;

FUNCTION bmascomp_assign_comp (
    org_id		NUMBER,
    all_org		NUMBER := 2,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    req_id		NUMBER,
    err_text  IN OUT 	VARCHAR2
)
    return INTEGER;

FUNCTION bmgblsq_get_bill_sequence(
	org_id		NUMBER,
	item_id		NUMBER,
	alt_desg	VARCHAR2,
	bill_seq_id OUT NUMBER,
	err_text    OUT VARCHAR2
)
    return INTEGER;

FUNCTION bmgcpsq_get_comp_sequence(
        bill_seq_id     NUMBER,
        op_seq          NUMBER,
        cmp_id          NUMBER,
        eff_date        VARCHAR2,
        cmp_seq_id  OUT NUMBER,
        err_text    OUT VARCHAR2
)
    return INTEGER;

FUNCTION bmgblin_get_bill_info(
        org_id      OUT NUMBER,
        item_id     OUT NUMBER,
        alt_desg    OUT VARCHAR2,
        bill_seq_id     NUMBER,
        err_text    OUT VARCHAR2
)
    return INTEGER;

FUNCTION bmasbitm_assign_bom_item_id(
    org_id		NUMBER,
    item_number		VARCHAR2,
    item_id		NUMBER,
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER;

FUNCTION bmasbomid_assign_bom_seq_id(
	org_id		NUMBER,
	assy_id  	NUMBER,
	alt_desg	VARCHAR2,
	bom_id		NUMBER,
	err_text IN OUT VARCHAR2
)
    return INTEGER;

FUNCTION bmascmpid_assign_cmp_seq_id(
	org_id		NUMBER,
	assy_id  	NUMBER,
	alt_desg	VARCHAR2,
	op_seq 		NUMBER,
	cmp_id		NUMBER,
	cmp_seq_id	NUMBER,
	eff_date 	VARCHAR2,
	err_text IN OUT VARCHAR2
)
    return INTEGER;

FUNCTION bmgcpqy_get_comp_quantity(
        comp_seq_id     NUMBER,
        comp_qty    OUT NUMBER,
        err_text    OUT VARCHAR2
)
    return INTEGER;

FUNCTION bmasrefd_assign_ref_desg_data (
    org_id		NUMBER,
    all_org		NUMBER := 2,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    req_id		NUMBER,
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER;

FUNCTION bmassubd_assign_sub_comp_data (
    org_id		NUMBER,
    all_org		NUMBER := 2,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    req_id		NUMBER,
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER;


END BOMPASGB;

 

/
