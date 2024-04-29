--------------------------------------------------------
--  DDL for Package CRP_PLANNER_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CRP_PLANNER_PK" AUTHID CURRENT_USER AS
/* $Header: CRPPPLNS.pls 115.1 99/07/16 10:31:12 porting ship $ */
    PROCEDURE   start_plan(
                arg_compile_desig   VARCHAR2,
                arg_org_id          NUMBER,
                arg_user_id         NUMBER);
    PROCEDURE   complete_plan(
                arg_compile_desig   VARCHAR2,
                arg_org_id          NUMBER,
                arg_user_id         NUMBER);
    PROCEDURE   plan_jobs(
                arg_compile_desig   VARCHAR2,
                arg_org_id          NUMBER,
                arg_user_id         NUMBER,
                arg_cutoff_date    	DATE,
				arg_request_id		NUMBER,
				arg_calendar_code 	VARCHAR2,
				arg_exception_set_id NUMBER);
    PROCEDURE   plan_discrete(
                arg_compile_desig   VARCHAR2,
                arg_org_id          NUMBER,
                arg_user_id         NUMBER,
                arg_cutoff_date    	DATE,
				arg_request_id		NUMBER,
				arg_calendar_code 	VARCHAR2,
				arg_exception_set_id NUMBER);
    PROCEDURE   plan_repetitive(
                arg_compile_desig   VARCHAR2,
                arg_org_id          NUMBER,
                arg_user_id         NUMBER,
                arg_cutoff_date    	DATE,
				arg_request_id		NUMBER,
				arg_calendar_code 	VARCHAR2,
				arg_exception_set_id NUMBER);
    /*-------------------------------------------------------------------------+
    |   Defined constants                                                      |
    +-------------------------------------------------------------------------*/
    OPEN_ORDER              CONSTANT INTEGER := 1; /* disposition status    */
    CANCEL_ORDER            CONSTANT INTEGER := 2;

    BASIS_PER_ITEM          CONSTANT INTEGER := 1;       /* CST_BASIS */
    BASIS_PER_ORDER         CONSTANT INTEGER := 2;       /* CST_BASIS */
    BASIS_RESOURCE_UNITS    CONSTANT INTEGER := 3;       /* CST_BASIS */
    BASIS_RESOURCE_VALUE    CONSTANT INTEGER := 4;       /* CST_BASIS */
    BASIS_TOTAL_VALUE       CONSTANT INTEGER := 5;       /* CST_BASIS */
    BASIS_ACTIVITY_UNITS    CONSTANT INTEGER := 6;       /* CST_BASIS */

    NOT_REPETITIVE_PLANNED  CONSTANT INTEGER := 1; /*repetitive manufacturing */
    REPETITIVELY_PLANNED    CONSTANT INTEGER := 2;

    PURCHASE_ORDER          CONSTANT INTEGER := 1; /* order type lookup     */
    PURCH_REQ               CONSTANT INTEGER := 2;
    WORK_ORDER              CONSTANT INTEGER := 3;
    REPETITVE_SCHEDULE      CONSTANT INTEGER := 4;
    PLANNED_ORDER           CONSTANT INTEGER := 5;
    MATERIAL_TRANSFER       CONSTANT INTEGER := 6;
    NONSTD_JOB              CONSTANT INTEGER := 7;
    RECEIPT_PURCH_ORDER     CONSTANT INTEGER := 8;
    REQUIREMENT             CONSTANT INTEGER := 9;
    FPO_SUPPLY              CONSTANT INTEGER := 10;

    SYS_YES                 CONSTANT INTEGER := 1;
    SYS_NO                  CONSTANT INTEGER := 2;

    MAKE                    CONSTANT INTEGER := 1;
    BUY                     CONSTANT INTEGER := 2;

END crp_planner_pk;

 

/
