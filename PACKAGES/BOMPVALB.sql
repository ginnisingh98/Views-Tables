--------------------------------------------------------
--  DDL for Package BOMPVALB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPVALB" AUTHID CURRENT_USER as
/* $Header: BOMVALBS.pls 115.2 99/07/16 05:16:46 porting ship $
+===========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMPVALB.pls                                               |
| DESCRIPTION  : This package contains functions used to validate bill      |
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
|    11/22/93   Shreyas Shah	creation date                               |
|    04/24/94   Julie Maeyama   modified code                               |
+==========================================================================*/
FUNCTION bmvbomh_validate_bom_header (
    org_id		NUMBER,
    all_org		NUMBER := 2,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    request_id		NUMBER,
    err_text  IN OUT 	VARCHAR2
)
    return INTEGER;

FUNCTION bmvassyid_verify_assembly_id(
    org_id              NUMBER,
    assy_id             NUMBER,
    err_text     OUT    VARCHAR2
)
    return INTEGER;

FUNCTION bmvrbom_verify_bom(
	bom_seq_id	NUMBER,
	mode_type	NUMBER,
	err_text  OUT	VARCHAR2
)
    return INTEGER;

FUNCTION bmvdupbom_verify_duplicate_bom(
	org_id		NUMBER,
	assy_id		NUMBER,
	alt_desg  	VARCHAR2,
        assy_type       NUMBER,
	err_text  OUT 	VARCHAR2
)
    return INTEGER;

FUNCTION bmvbitm_verify_assembly_type(
	org_id		NUMBER,
	assy_id		NUMBER,
	assy_type	NUMBER,
	err_text  OUT 	VARCHAR2
)
    return INTEGER;

FUNCTION bmvcmbom_verify_common_bom(
	bom_id		NUMBER,
	cmn_bom_id	NUMBER,
	bom_type	NUMBER,
	item_id		NUMBER,
	cmn_item_id	NUMBER,
	org_id		NUMBER,
	cmn_org_id	NUMBER,
	alt_desg	VARCHAR2,
	err_text  OUT	VARCHAR2
)
    return INTEGER;

FUNCTION bmvcomp_validate_components (
    org_id		NUMBER,
    all_org		NUMBER := 2,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    request_id		NUMBER,
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER;

FUNCTION bmvitmatt_verify_item_attr (
    org_id 		NUMBER,
    cmp_id		NUMBER,
    assy_id		NUMBER,
    eng_bill            NUMBER,
    err_text   OUT	VARCHAR2
)
    return INTEGER;

FUNCTION bmvopseqs_valid_op_seqs (
    org_id		NUMBER,
    assy_id		NUMBER,
    alt_desg		VARCHAR2,
    op_seq		NUMBER,
    err_text	   OUT  VARCHAR2
)
    return INTEGER;

FUNCTION bmvovlap_verify_overlaps (
    bom_id		NUMBER,
    op_num		NUMBER,
    cmp_id		NUMBER,
    eff_date		VARCHAR2,
    dis_date		VARCHAR2,
    err_text    OUT	VARCHAR2
)
    return INTEGER;

FUNCTION bmvuncmp_verify_unique_comp (
    cmp_seq_id 		NUMBER,
    exist_flag		NUMBER,
    err_text	OUT	VARCHAR2
)
    return INTEGER;

FUNCTION bmvdupcmp_verify_duplicate_cmp (
        bill_seq_id     NUMBER,
        eff_date        VARCHAR2,
        cmp_item_id     NUMBER,
        op_seq          NUMBER,
        err_text  OUT   VARCHAR2
)
    return INTEGER;

FUNCTION bmvref_validate_ref_desgs (
    org_id		NUMBER,
    all_org		NUMBER := 2,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    request_id		NUMBER,
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER;

FUNCTION bmvundesg_verify_unique_desg (
    trans_id            NUMBER,
    err_text    OUT     VARCHAR2
)
    return INTEGER;

FUNCTION bmvcdesg_cnt_ref_desgs (
    trans_id    NUMBER,
    cmp_seq_id  NUMBER,
    err_text    OUT VARCHAR2
)
    return INTEGER;

FUNCTION bmvsubs_validate_sub_comps (
    org_id		NUMBER,
    all_org		NUMBER := 2,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    request_id		NUMBER,
    err_text	IN OUT 	VARCHAR2
)
    return INTEGER;

FUNCTION bmvunsub_verify_unique_sub (
    trans_id            NUMBER,
    err_text    OUT     VARCHAR2
)
    return INTEGER;

FUNCTION bmvitmrev_validate_itm_rev (
    org_id              NUMBER,
    all_org             NUMBER,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT  VARCHAR2
)
    return INTEGER;

FUNCTION bmvalrev_validate_rev (
    org_id              NUMBER,
    assy_id             NUMBER,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT  VARCHAR2
)
    return INTEGER;

END BOMPVALB;

 

/
