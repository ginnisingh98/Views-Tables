--------------------------------------------------------
--  DDL for Package BOMPVALR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPVALR" AUTHID CURRENT_USER as
/* $Header: BOMVALRS.pls 120.2.12010000.2 2008/11/14 16:39:38 snandana ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMPVALR.pls                                               |
| DESCRIPTION  : This package contains functions used to validate routing
| 		 data in the interface tables
| Parameters:	org_id		organization_id
|		all_org		process all orgs or just current org
|				1 - all orgs
|				2 - only org_id
|    		prog_appid      program application_id
|    		prog_id  	program id
|    		request_id      request_id
|    		user_id		user id
|    		login_id	login id
| History:
|    10/05/93   Shreyas Shah	creation date
|                                                                           |
+==========================================================================*/
FUNCTION bmvrtgh_validate_rtg_header (
    org_id		NUMBER,
    all_org		NUMBER,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    request_id		NUMBER,
    err_text	 IN OUT NOCOPY 	VARCHAR2
)
    return INTEGER;

FUNCTION bmvopr_validate_operations (
    org_id		NUMBER,
    all_org		NUMBER := 2,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    request_id		NUMBER,
    err_text	 IN OUT NOCOPY 	VARCHAR2
)
    return INTEGER;

FUNCTION bmvres_validate_resources (
    org_id		NUMBER,
    all_org		NUMBER,
    user_id		NUMBER,
    login_id		NUMBER,
    prog_appid		NUMBER,
    prog_id		NUMBER,
    request_id		NUMBER,
    err_text	 IN OUT NOCOPY 	VARCHAR2
)
    return INTEGER;

FUNCTION bmvunres_verify_unique_res (
    trans_id            NUMBER,
    err_text    IN OUT NOCOPY     VARCHAR2
)
    return INTEGER;

FUNCTION bmvrtgrev_validate_rtg_rev (
    org_id              NUMBER,
    all_org             NUMBER,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2
)
    return INTEGER;

FUNCTION bmvrev_validate_rev (
    org_id              NUMBER,
    assy_id             NUMBER,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2
)
    return INTEGER;

FUNCTION bmvcmrtg_verify_common_routing (
	rtg_id		NUMBER,
	cmn_rtg_id	NUMBER,
	rtg_type	NUMBER,
	item_id		NUMBER,
	org_id		NUMBER,
	alt_desg	VARCHAR2,
	err_text  IN OUT NOCOPY   VARCHAR2
)
    return INTEGER;

FUNCTION bmvrtg_verify_rtg_type (
	org_id		NUMBER,
	assy_id		NUMBER,
	rtg_type	NUMBER,
	err_text  IN OUT NOCOPY   VARCHAR2
)
    return INTEGER;

FUNCTION bmvurtg_verify_routing (
	rtg_seq_id 	NUMBER,
	mode_type	NUMBER,
	err_text   IN OUT NOCOPY  VARCHAR2
)
    return INTEGER;

FUNCTION bmvduprt_verify_duplicate_rtg(
	org_id		NUMBER,
	assy_id		NUMBER,
	alt_desg  	VARCHAR2,
	rtg_type	NUMBER,
	err_text  IN OUT NOCOPY 	VARCHAR2
)
    return INTEGER;

FUNCTION bmvunop_verify_unique_op (
	op_seq_id	NUMBER,
	exist_flag	NUMBER,
	err_text   IN OUT NOCOPY  VARCHAR2
)
    return INTEGER;

FUNCTION bmvdupop_verify_duplicate_op(
        rtg_seq_id      NUMBER,
        eff_date        VARCHAR2,
        op_seq          NUMBER,
        err_text  IN OUT NOCOPY   VARCHAR2
)
    return INTEGER;

FUNCTION bmvovlap_verify_overlaps (
	rtg_id		NUMBER,
	op_num		NUMBER,
	eff_date	VARCHAR2,
	dis_date	VARCHAR2,
	err_text   IN OUT NOCOPY  VARCHAR2
)
    return INTEGER;

FUNCTION bmvdept_validate_department (
	org_id		NUMBER,
	dept_id	  	NUMBER,
	eff_date	VARCHAR2,
	err_text  IN OUT NOCOPY 	VARCHAR2
)
    return INTEGER;

FUNCTION bmvrsch_verify_resource_sched (
	op_seq		NUMBER,
	sched_type 	NUMBER,
	err_text  IN OUT NOCOPY VARCHAR2
)
    return INTEGER;

FUNCTION bmvauto_verify_autocharge (
	op_seq		NUMBER,
	dept_id		NUMBER,
	err_text   IN OUT NOCOPY  VARCHAR2
)
    return INTEGER;

G_round_off_val number :=NVL(FND_PROFILE.VALUE('BOM:ROUND_OFF_VALUE'),6); /* Bug 7322996 */

END BOMPVALR;

/
