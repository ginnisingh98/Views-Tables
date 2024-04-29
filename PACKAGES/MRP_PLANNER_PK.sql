--------------------------------------------------------
--  DDL for Package MRP_PLANNER_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_PLANNER_PK" AUTHID CURRENT_USER AS
/* $Header: MRPPPLNS.pls 115.2 1999/11/15 18:25:04 pkm ship   $ */
    PROCEDURE   mb_delete_ms_outside_tf(
                arg_compile_desig   VARCHAR2,
                arg_org_id          NUMBER,
                arg_jcurr_date      NUMBER);
    PROCEDURE   mb_delete_ms_outside_tf(
                arg_compile_desig   VARCHAR2,
                arg_org_id          NUMBER,
                arg_jcurr_date      NUMBER,
                arg_query_id        NUMBER);
    PROCEDURE   create_new_planner_mps_entries(
                arg_compile_desig   VARCHAR2,
                arg_sched_desig     VARCHAR2,
                arg_org_id          NUMBER);
    PROCEDURE   create_orig_mps_entries(
                arg_sched_desig     VARCHAR2,
                arg_org_id          NUMBER);
    PROCEDURE   create_mbp_orig_mps_entries(
                arg_sched_desig     VARCHAR2,
				arg_org_id          NUMBER);
    /*-------------------------------------------------------------------------+
    |   Defined constants                                                      |
    +-------------------------------------------------------------------------*/
    SYS_YES             CONSTANT INTEGER := 1;      /* sys yes no */
    SYS_NO              CONSTANT INTEGER := 2;

    ORIG_SCHEDULE       CONSTANT INTEGER := 1;      /* schedule level */
    UPDATED_SCHEDULE    CONSTANT INTEGER := 2;
    MRP_SCHEDULE        CONSTANT INTEGER := 3;

    REORDER_POINT_PLANNING CONSTANT INTEGER := 1;/* Inventory Planning Codes */
    MIN_MAX_PLANNING    CONSTANT INTEGER := 2;
    MRP_PLANNING        CONSTANT INTEGER := 3;
    MPS_PLANNING        CONSTANT INTEGER := 4;
    MMS_PLANNING        CONSTANT INTEGER := 5;
    NO_PLANNING         CONSTANT INTEGER := 6;

    DISCRETE_DEMAND     CONSTANT INTEGER := 1;   /* MRP_REPETITIVE_DEMAND_TYPE*/
    REPET_DEMAND        CONSTANT INTEGER := 2;

    SCHED_MANUAL        CONSTANT INTEGER := 1;      /* origination types    */
    SCHED_ITEM_FORECAST CONSTANT INTEGER := 2;
    SCHED_SALES_ORDER   CONSTANT INTEGER := 3;
    SCHED_COPY          CONSTANT INTEGER := 4;
    SCHED_MPS_PLAN      CONSTANT INTEGER := 6;
    SCHED_OUTSIDE       CONSTANT INTEGER := 7;

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

    SCHEDULE_DEMAND     CONSTANT INTEGER := 1;   /* DEMAND_SUPPLY_TYPE     */
    SCHEDULE_SUPPLY     CONSTANT INTEGER := 2;

    STATUS_INITIALIZING CONSTANT INTEGER := 1;
    STATUS_PROCESSING   CONSTANT INTEGER := 2;
    STATUS_IDLE         CONSTANT INTEGER := 3;
    STATUS_COMPLETE     CONSTANT INTEGER := 4;

    NULL_VALUE          CONSTANT INTEGER := -23453;

    PHANTOM_ASSY        CONSTANT INTEGER := 6;

    CUM_TOTAL_LT        CONSTANT INTEGER := 1;
    CUM_MFG_LT          CONSTANT INTEGER := 2;
    TOTAL_LT            CONSTANT INTEGER := 3;
    USER_TF             CONSTANT INTEGER := 4;


END mrp_planner_pk;

 

/
