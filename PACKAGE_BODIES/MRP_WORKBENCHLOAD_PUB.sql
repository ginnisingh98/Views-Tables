--------------------------------------------------------
--  DDL for Package Body MRP_WORKBENCHLOAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_WORKBENCHLOAD_PUB" AS
/* $Header: MRPPWBLB.pls 120.1 2006/02/17 14:17:10 ahoque noship $ */

PROCEDURE planner_workbench_load(
                                arg_org_id IN NUMBER,
                                arg_compile_desig IN VARCHAR2,
                                arg_query_id IN NUMBER,
                                arg_user_id IN NUMBER,
                                arg_wip_load IN VARCHAR2,
                                arg_po_load IN VARCHAR2,
                                arg_wip_resched IN VARCHAR2,
                                arg_po_resched IN VARCHAR2,
                                arg_rep_load IN VARCHAR2,
                                arg_po_group_by IN NUMBER,
                                arg_wip_group_id IN NUMBER,
                                arg_launch_process OUT NOCOPY NUMBER)
IS
    REQ_GRP_ALL_ON_ONE      CONSTANT INTEGER := 1;  /* PO group by */
    REQ_GRP_ITEM            CONSTANT INTEGER := 2;
    REQ_GRP_BUYER           CONSTANT INTEGER := 3;
    REQ_GRP_PLANNER         CONSTANT INTEGER := 4;
    REQ_GRP_VENDOR          CONSTANT INTEGER := 5;
    REQ_GRP_ONE_EACH        CONSTANT INTEGER := 6;
    REQ_GRP_CATEGORY        CONSTANT INTEGER := 7;

    WIP_DIS_MASS_LOAD       CONSTANT INTEGER := 1;
    WIP_REP_MASS_LOAD       CONSTANT INTEGER := 2;
    WIP_DIS_MASS_RESCHEDULE CONSTANT INTEGER := 4;
    PO_MASS_LOAD            CONSTANT INTEGER := 8;
    PO_MASS_RESCHEDULE      CONSTANT INTEGER := 16;

    PURCHASE_ORDER      CONSTANT INTEGER := 1;   /* order type lookup        */
    PURCH_REQ           CONSTANT INTEGER := 2;
    WORK_ORDER          CONSTANT INTEGER := 3;
    REPETITVE_SCHEDULE  CONSTANT INTEGER := 4;
    PLANNED_ORDER       CONSTANT INTEGER := 5;
    MATERIAL_TRANSFER   CONSTANT INTEGER := 6;
    NONSTD_JOB          CONSTANT INTEGER := 7;
    RECEIPT_PURCH_ORDER CONSTANT INTEGER := 8;
    REQUIREMENT         CONSTANT INTEGER := 9;
    FPO_SUPPLY          CONSTANT INTEGER := 10;

    NOT_UNDER_REV_CONTROL  CONSTANT INTEGER := 1;
    UNDER_REV_CONTROL      CONSTANT INTEGER := 2;

    PURCHASING_BY_REV      CONSTANT INTEGER := 1;
    NOT_PURCHASING_BY_REV  CONSTANT INTEGER := 2;

    var_launch_process      INTEGER;
    var_calendar_code       VARCHAR2(10);
    var_exception_set_id    NUMBER;
    var_row_id          ROWID;
    var_quantity        NUMBER;
    var_purchasing_by_rev   NUMBER;

BEGIN
	/* Stubbed out the code, as not required in the new release */
	NULL;

END planner_workbench_load;

END;

/
