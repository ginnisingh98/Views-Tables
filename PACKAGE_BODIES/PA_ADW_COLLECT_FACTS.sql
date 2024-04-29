--------------------------------------------------------
--  DDL for Package Body PA_ADW_COLLECT_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ADW_COLLECT_FACTS" AS
/* $Header: PAADWCFB.pls 120.2 2005/08/19 16:15:22 mwasowic ship $ */

   FUNCTION Initialize RETURN NUMBER IS
   BEGIN
        NULL;
   END Initialize;

   -- Procedure to collect actual cost and commitment costs

   PROCEDURE get_fact_act_cmts
                         (x_project_num_from     IN     VARCHAR2,
                          x_project_num_to       IN     VARCHAR2,
			  x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_stack            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code             IN OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
   IS

     -- Define Cursor for sending $0 measure values for
     -- the resources which were refreshed at the lowest task level

     CURSOR sel_ref_lowest_act_cmts(x_project_id NUMBER) IS
     SELECT
        PTXN.TASK_ID,
        PTXN.PA_PERIOD_KEY,
        PTXN.EXPENSE_ORGANIZATION_ID,
        PTXN.OWNER_ORGANIZATION_ID,
        PTXN.RESOURCE_LIST_MEMBER_ID,
        PTXN.SERVICE_TYPE_CODE,
        PTXN.EXPENDITURE_TYPE,
        PTXN.USER_COL1,
        PTXN.USER_COL2,
        PTXN.USER_COL3,
        PTXN.USER_COL4,
        PTXN.USER_COL5,
        SUM(PTXN.USER_COL6) USER_COL6,
        SUM(PTXN.USER_COL7) USER_COL7,
        SUM(PTXN.USER_COL8) USER_COL8,
        SUM(PTXN.USER_COL9) USER_COL9,
        SUM(PTXN.USER_COL10) USER_COL10,
        SUM(PTXN.ACCUME_REVENUE) ACCUME_REVENUE,
        SUM(PTXN.ACCUME_RAW_COST) ACCUME_RAW_COST,
        SUM(PTXN.ACCUME_BURDENED_COST) ACCUME_BURDENED_COST,
        SUM(PTXN.ACCUME_QUANTITY) ACCUME_QUANTITY,
        SUM(PTXN.ACCUME_LABOR_HOURS) ACCUME_LABOR_HOURS,
        SUM(PTXN.ACCUME_BILLABLE_RAW_COST) ACCUME_BILLABLE_RAW_COST,
        SUM(PTXN.ACCUME_BILLABLE_BURDENED_COST) ACCUME_BILLABLE_BURDENED_COST,
        SUM(PTXN.ACCUME_BILLABLE_QUANTITY) ACCUME_BILLABLE_QUANTITY,
        SUM(PTXN.ACCUME_BILLABLE_LABOR_HOURS) ACCUME_BILLABLE_LABOR_HOURS,
        SUM(PTXN.ACCUME_CMT_RAW_COST) ACCUME_CMT_RAW_COST,
        SUM(PTXN.ACCUME_CMT_BURDENED_COST) ACCUME_CMT_BURDENED_COST,
        SUM(PTXN.ACCUME_CMT_QUANTITY) ACCUME_CMT_QUANTITY,
        PTXN.UNIT_OF_MEASURE
     FROM
        PA_ADW_R_ACT_CMT_V PTXN,
        PA_ADW_LOWEST_TASKS_V PT
     WHERE
        PTXN.TASK_ID = PT.TASK_ID
     AND PTXN.PROJECT_ID = x_project_id
     -- Exclude top tasks
     AND PT.TASK_ID <> PT.TOP_TASK_ID
     AND PTXN.RES_ADW_NOTIFY_FLAG = 'S'
     GROUP BY
        PTXN.TASK_ID,
        PTXN.PA_PERIOD_KEY,
        PTXN.EXPENSE_ORGANIZATION_ID,
        PTXN.OWNER_ORGANIZATION_ID,
        PTXN.RESOURCE_LIST_MEMBER_ID,
        PTXN.SERVICE_TYPE_CODE,
        PTXN.EXPENDITURE_TYPE,
        PTXN.USER_COL1,
        PTXN.USER_COL2,
        PTXN.USER_COL3,
        PTXN.USER_COL4,
        PTXN.USER_COL5,
        PTXN.UNIT_OF_MEASURE;

     -- Define Cursor for sending $0 measure values for
     -- the resources which were refreshed at the top task level

     CURSOR sel_ref_top_act_cmts(x_project_id NUMBER) IS
     SELECT
        PTXN.TOP_TASK_ID,
        PTXN.PA_PERIOD_KEY,
        PTXN.EXPENSE_ORGANIZATION_ID,
        PTXN.OWNER_ORGANIZATION_ID,
        PTXN.RESOURCE_LIST_MEMBER_ID,
        PTXN.SERVICE_TYPE_CODE,
        PTXN.EXPENDITURE_TYPE,
        PTXN.USER_COL1,
        PTXN.USER_COL2,
        PTXN.USER_COL3,
        PTXN.USER_COL4,
        PTXN.USER_COL5,
        SUM(PTXN.USER_COL6) USER_COL6,
        SUM(PTXN.USER_COL7) USER_COL7,
        SUM(PTXN.USER_COL8) USER_COL8,
        SUM(PTXN.USER_COL9) USER_COL9,
        SUM(PTXN.USER_COL10) USER_COL10,
        SUM(PTXN.ACCUME_REVENUE) ACCUME_REVENUE,
        SUM(PTXN.ACCUME_RAW_COST) ACCUME_RAW_COST,
        SUM(PTXN.ACCUME_BURDENED_COST) ACCUME_BURDENED_COST,
        SUM(PTXN.ACCUME_QUANTITY) ACCUME_QUANTITY,
        SUM(PTXN.ACCUME_LABOR_HOURS) ACCUME_LABOR_HOURS,
        SUM(PTXN.ACCUME_BILLABLE_RAW_COST) ACCUME_BILLABLE_RAW_COST,
        SUM(PTXN.ACCUME_BILLABLE_BURDENED_COST) ACCUME_BILLABLE_BURDENED_COST,
        SUM(PTXN.ACCUME_BILLABLE_QUANTITY) ACCUME_BILLABLE_QUANTITY,
        SUM(PTXN.ACCUME_BILLABLE_LABOR_HOURS) ACCUME_BILLABLE_LABOR_HOURS,
        SUM(PTXN.ACCUME_CMT_RAW_COST) ACCUME_CMT_RAW_COST,
        SUM(PTXN.ACCUME_CMT_BURDENED_COST) ACCUME_CMT_BURDENED_COST,
        SUM(PTXN.ACCUME_CMT_QUANTITY) ACCUME_CMT_QUANTITY,
        PTXN.UNIT_OF_MEASURE
     FROM
        PA_ADW_R_ACT_CMT_V PTXN,
        PA_ADW_TOP_TASKS_V PT
     WHERE
        PTXN.TOP_TASK_ID = PT.TOP_TASK_ID
     AND PTXN.PROJECT_ID = x_project_id
     AND PTXN.RES_ADW_NOTIFY_FLAG = 'S'
     GROUP BY
        PTXN.TOP_TASK_ID,
        PTXN.PA_PERIOD_KEY,
        PTXN.EXPENSE_ORGANIZATION_ID,
        PTXN.OWNER_ORGANIZATION_ID,
        PTXN.RESOURCE_LIST_MEMBER_ID,
        PTXN.SERVICE_TYPE_CODE,
        PTXN.EXPENDITURE_TYPE,
        PTXN.USER_COL1,
        PTXN.USER_COL2,
        PTXN.USER_COL3,
        PTXN.USER_COL4,
        PTXN.USER_COL5,
        PTXN.UNIT_OF_MEASURE;

     -- Define Cursor for sending $0 measure values for
     -- the resources which were refreshed at the project Level

     CURSOR sel_ref_prj_act_cmts(x_project_id NUMBER) IS
     SELECT
        PROJECT_ID,
        PA_PERIOD_KEY,
        EXPENSE_ORGANIZATION_ID,
        OWNER_ORGANIZATION_ID,
        RESOURCE_LIST_MEMBER_ID,
        SERVICE_TYPE_CODE,
        EXPENDITURE_TYPE,
        USER_COL1,
        USER_COL2,
        USER_COL3,
        USER_COL4,
        USER_COL5,
        SUM(USER_COL6) USER_COL6,
        SUM(USER_COL7) USER_COL7,
        SUM(USER_COL8) USER_COL8,
        SUM(USER_COL9) USER_COL9,
        SUM(USER_COL10) USER_COL10,
        SUM(ACCUME_REVENUE) ACCUME_REVENUE,
        SUM(ACCUME_RAW_COST) ACCUME_RAW_COST,
        SUM(ACCUME_BURDENED_COST) ACCUME_BURDENED_COST,
        SUM(ACCUME_QUANTITY) ACCUME_QUANTITY,
        SUM(ACCUME_LABOR_HOURS) ACCUME_LABOR_HOURS,
        SUM(ACCUME_BILLABLE_RAW_COST) ACCUME_BILLABLE_RAW_COST,
        SUM(ACCUME_BILLABLE_BURDENED_COST) ACCUME_BILLABLE_BURDENED_COST,
        SUM(ACCUME_BILLABLE_QUANTITY) ACCUME_BILLABLE_QUANTITY,
        SUM(ACCUME_BILLABLE_LABOR_HOURS) ACCUME_BILLABLE_LABOR_HOURS,
        SUM(ACCUME_CMT_RAW_COST) ACCUME_CMT_RAW_COST,
        SUM(ACCUME_CMT_BURDENED_COST) ACCUME_CMT_BURDENED_COST,
        SUM(ACCUME_CMT_QUANTITY) ACCUME_CMT_QUANTITY,
        UNIT_OF_MEASURE
     FROM
        PA_ADW_R_ACT_CMT_V
     WHERE
        RES_ADW_NOTIFY_FLAG = 'S'
     AND PROJECT_ID = x_project_id
     GROUP BY
        PROJECT_ID,
        PA_PERIOD_KEY,
        EXPENSE_ORGANIZATION_ID,
        OWNER_ORGANIZATION_ID,
        RESOURCE_LIST_MEMBER_ID,
        SERVICE_TYPE_CODE,
        EXPENDITURE_TYPE,
        USER_COL1,
        USER_COL2,
        USER_COL3,
        USER_COL4,
        USER_COL5,
        UNIT_OF_MEASURE;

     -- Define Cursor for sending $0 measure values for
     -- the lowest level tasks for which service type was changed

     CURSOR sel_ref_lowest_stype_act_cmts(x_project_id NUMBER) IS
     SELECT
        PTXN.TASK_ID,
        PTXN.PA_PERIOD_KEY,
        PTXN.EXPENSE_ORGANIZATION_ID,
        PTXN.OWNER_ORGANIZATION_ID,
        PTXN.RESOURCE_LIST_MEMBER_ID,
        PTXN.SERVICE_TYPE_CODE,
        PTXN.EXPENDITURE_TYPE,
        PTXN.USER_COL1,
        PTXN.USER_COL2,
        PTXN.USER_COL3,
        PTXN.USER_COL4,
        PTXN.USER_COL5,
        SUM(PTXN.USER_COL6) USER_COL6,
        SUM(PTXN.USER_COL7) USER_COL7,
        SUM(PTXN.USER_COL8) USER_COL8,
        SUM(PTXN.USER_COL9) USER_COL9,
        SUM(PTXN.USER_COL10) USER_COL10,
        SUM(PTXN.ACCUME_REVENUE) ACCUME_REVENUE,
        SUM(PTXN.ACCUME_RAW_COST) ACCUME_RAW_COST,
        SUM(PTXN.ACCUME_BURDENED_COST) ACCUME_BURDENED_COST,
        SUM(PTXN.ACCUME_QUANTITY) ACCUME_QUANTITY,
        SUM(PTXN.ACCUME_LABOR_HOURS) ACCUME_LABOR_HOURS,
        SUM(PTXN.ACCUME_BILLABLE_RAW_COST) ACCUME_BILLABLE_RAW_COST,
        SUM(PTXN.ACCUME_BILLABLE_BURDENED_COST) ACCUME_BILLABLE_BURDENED_COST,
        SUM(PTXN.ACCUME_BILLABLE_QUANTITY) ACCUME_BILLABLE_QUANTITY,
        SUM(PTXN.ACCUME_BILLABLE_LABOR_HOURS) ACCUME_BILLABLE_LABOR_HOURS,
        SUM(PTXN.ACCUME_CMT_RAW_COST) ACCUME_CMT_RAW_COST,
        SUM(PTXN.ACCUME_CMT_BURDENED_COST) ACCUME_CMT_BURDENED_COST,
        SUM(PTXN.ACCUME_CMT_QUANTITY) ACCUME_CMT_QUANTITY,
        PTXN.UNIT_OF_MEASURE
     FROM
        PA_ADW_R_ST_ACT_CMT_V PTXN,
        PA_ADW_LOWEST_TASKS_V PT
     WHERE
        PTXN.TASK_ID = PT.TASK_ID
     AND PTXN.PROJECT_ID = x_project_id
     -- Exclude top tasks
     AND PT.TASK_ID <> PT.TOP_TASK_ID
     AND (PTXN.TSK_ADW_NOTIFY_FLAG = 'S' OR PTXN.TSK_ADW_NOTIFY_FLAG = 'P')
     GROUP BY
        PTXN.TASK_ID,
        PTXN.PA_PERIOD_KEY,
        PTXN.EXPENSE_ORGANIZATION_ID,
        PTXN.OWNER_ORGANIZATION_ID,
        PTXN.RESOURCE_LIST_MEMBER_ID,
        PTXN.SERVICE_TYPE_CODE,
        PTXN.EXPENDITURE_TYPE,
        PTXN.USER_COL1,
        PTXN.USER_COL2,
        PTXN.USER_COL3,
        PTXN.USER_COL4,
        PTXN.USER_COL5,
        PTXN.UNIT_OF_MEASURE;

     -- Define Cursor for sending $0 measure values for
     -- the top level tasks for which service type was changed

     CURSOR sel_ref_top_ser_type_act_cmts(x_project_id NUMBER) IS
     SELECT
        PTXN.TOP_TASK_ID,
        PTXN.PA_PERIOD_KEY,
        PTXN.EXPENSE_ORGANIZATION_ID,
        PTXN.OWNER_ORGANIZATION_ID,
        PTXN.RESOURCE_LIST_MEMBER_ID,
        PTXN.SERVICE_TYPE_CODE,
        PTXN.EXPENDITURE_TYPE,
        PTXN.USER_COL1,
        PTXN.USER_COL2,
        PTXN.USER_COL3,
        PTXN.USER_COL4,
        PTXN.USER_COL5,
        SUM(PTXN.USER_COL6) USER_COL6,
        SUM(PTXN.USER_COL7) USER_COL7,
        SUM(PTXN.USER_COL8) USER_COL8,
        SUM(PTXN.USER_COL9) USER_COL9,
        SUM(PTXN.USER_COL10) USER_COL10,
        SUM(PTXN.ACCUME_REVENUE) ACCUME_REVENUE,
        SUM(PTXN.ACCUME_RAW_COST) ACCUME_RAW_COST,
        SUM(PTXN.ACCUME_BURDENED_COST) ACCUME_BURDENED_COST,
        SUM(PTXN.ACCUME_QUANTITY) ACCUME_QUANTITY,
        SUM(PTXN.ACCUME_LABOR_HOURS) ACCUME_LABOR_HOURS,
        SUM(PTXN.ACCUME_BILLABLE_RAW_COST) ACCUME_BILLABLE_RAW_COST,
        SUM(PTXN.ACCUME_BILLABLE_BURDENED_COST) ACCUME_BILLABLE_BURDENED_COST,
        SUM(PTXN.ACCUME_BILLABLE_QUANTITY) ACCUME_BILLABLE_QUANTITY,
        SUM(PTXN.ACCUME_BILLABLE_LABOR_HOURS) ACCUME_BILLABLE_LABOR_HOURS,
        SUM(PTXN.ACCUME_CMT_RAW_COST) ACCUME_CMT_RAW_COST,
        SUM(PTXN.ACCUME_CMT_BURDENED_COST) ACCUME_CMT_BURDENED_COST,
        SUM(PTXN.ACCUME_CMT_QUANTITY) ACCUME_CMT_QUANTITY,
        PTXN.UNIT_OF_MEASURE
     FROM
        PA_ADW_R_ST_ACT_CMT_V PTXN,
        PA_ADW_TOP_TASKS_V PT
     WHERE
        PTXN.TOP_TASK_ID = PT.TOP_TASK_ID
     AND PTXN.PROJECT_ID = x_project_id
     AND (PTXN.TSK_ADW_NOTIFY_FLAG = 'S' OR PTXN.TSK_ADW_NOTIFY_FLAG = 'P')
     GROUP BY
        PTXN.TOP_TASK_ID,
        PTXN.PA_PERIOD_KEY,
        PTXN.EXPENSE_ORGANIZATION_ID,
        PTXN.OWNER_ORGANIZATION_ID,
        PTXN.RESOURCE_LIST_MEMBER_ID,
        PTXN.SERVICE_TYPE_CODE,
        PTXN.EXPENDITURE_TYPE,
        PTXN.USER_COL1,
        PTXN.USER_COL2,
        PTXN.USER_COL3,
        PTXN.USER_COL4,
        PTXN.USER_COL5,
        PTXN.UNIT_OF_MEASURE;

     -- Define Cursor for sending $0 measure values at
     -- the project level for the service type changed at task level

     CURSOR sel_ref_prj_ser_type_act_cmts(x_project_id NUMBER) IS
     SELECT
        PROJECT_ID,
        PA_PERIOD_KEY,
        EXPENSE_ORGANIZATION_ID,
        OWNER_ORGANIZATION_ID,
        RESOURCE_LIST_MEMBER_ID,
        SERVICE_TYPE_CODE,
        EXPENDITURE_TYPE,
        USER_COL1,
        USER_COL2,
        USER_COL3,
        USER_COL4,
        USER_COL5,
        SUM(USER_COL6) USER_COL6,
        SUM(USER_COL7) USER_COL7,
        SUM(USER_COL8) USER_COL8,
        SUM(USER_COL9) USER_COL9,
        SUM(USER_COL10) USER_COL10,
        SUM(ACCUME_REVENUE) ACCUME_REVENUE,
        SUM(ACCUME_RAW_COST) ACCUME_RAW_COST,
        SUM(ACCUME_BURDENED_COST) ACCUME_BURDENED_COST,
        SUM(ACCUME_QUANTITY) ACCUME_QUANTITY,
        SUM(ACCUME_LABOR_HOURS) ACCUME_LABOR_HOURS,
        SUM(ACCUME_BILLABLE_RAW_COST) ACCUME_BILLABLE_RAW_COST,
        SUM(ACCUME_BILLABLE_BURDENED_COST) ACCUME_BILLABLE_BURDENED_COST,
        SUM(ACCUME_BILLABLE_QUANTITY) ACCUME_BILLABLE_QUANTITY,
        SUM(ACCUME_BILLABLE_LABOR_HOURS) ACCUME_BILLABLE_LABOR_HOURS,
        SUM(ACCUME_CMT_RAW_COST) ACCUME_CMT_RAW_COST,
        SUM(ACCUME_CMT_BURDENED_COST) ACCUME_CMT_BURDENED_COST,
        SUM(ACCUME_CMT_QUANTITY) ACCUME_CMT_QUANTITY,
        UNIT_OF_MEASURE
     FROM
        PA_ADW_R_ST_ACT_CMT_V
     WHERE
        (TSK_ADW_NOTIFY_FLAG = 'S' OR TSK_ADW_NOTIFY_FLAG = 'P')
     AND PROJECT_ID = x_project_id
     GROUP BY
        PROJECT_ID,
        PA_PERIOD_KEY,
        EXPENSE_ORGANIZATION_ID,
        OWNER_ORGANIZATION_ID,
        RESOURCE_LIST_MEMBER_ID,
        SERVICE_TYPE_CODE,
        EXPENDITURE_TYPE,
        USER_COL1,
        USER_COL2,
        USER_COL3,
        USER_COL4,
        USER_COL5,
        UNIT_OF_MEASURE;

     -- Define Cursor for selecting Actuals and Commitments
     -- at lowest level of task.

     CURSOR sel_lowest_act_cmts(x_project_id NUMBER) IS
     SELECT
        TASK_ID,
        PA_PERIOD_KEY,
        EXPENSE_ORGANIZATION_ID,
        OWNER_ORGANIZATION_ID,
        RESOURCE_LIST_MEMBER_ID,
        SERVICE_TYPE_CODE,
        EXPENDITURE_TYPE,
        USER_COL1,
        USER_COL2,
        USER_COL3,
        USER_COL4,
        USER_COL5,
        SUM(USER_COL6) USER_COL6,
        SUM(USER_COL7) USER_COL7,
        SUM(USER_COL8) USER_COL8,
        SUM(USER_COL9) USER_COL9,
        SUM(USER_COL10) USER_COL10,
        SUM(ACCUME_REVENUE) ACCUME_REVENUE,
        SUM(ACCUME_RAW_COST) ACCUME_RAW_COST,
        SUM(ACCUME_BURDENED_COST) ACCUME_BURDENED_COST,
        SUM(ACCUME_QUANTITY) ACCUME_QUANTITY,
        SUM(ACCUME_LABOR_HOURS) ACCUME_LABOR_HOURS,
        SUM(ACCUME_BILLABLE_RAW_COST) ACCUME_BILLABLE_RAW_COST,
        SUM(ACCUME_BILLABLE_BURDENED_COST) ACCUME_BILLABLE_BURDENED_COST,
        SUM(ACCUME_BILLABLE_QUANTITY) ACCUME_BILLABLE_QUANTITY,
        SUM(ACCUME_BILLABLE_LABOR_HOURS) ACCUME_BILLABLE_LABOR_HOURS,
        SUM(ACCUME_CMT_RAW_COST) ACCUME_CMT_RAW_COST,
        SUM(ACCUME_CMT_BURDENED_COST) ACCUME_CMT_BURDENED_COST,
        SUM(ACCUME_CMT_QUANTITY) ACCUME_CMT_QUANTITY,
        UNIT_OF_MEASURE
     FROM
        PA_ADW_ACT_CMT_V
     WHERE
     PROJECT_ID = x_project_id
     AND (TASK_ID,
        PA_PERIOD_KEY,
        NVL(EXPENSE_ORGANIZATION_ID,-99),
        NVL(OWNER_ORGANIZATION_ID,-99),
        NVL(RESOURCE_LIST_MEMBER_ID,-99),
        NVL(SERVICE_TYPE_CODE,'X'),
        NVL(EXPENDITURE_TYPE,'X'),
        NVL(USER_COL1,'X'),
        NVL(USER_COL2,'X'),
        NVL(USER_COL3,'X'),
        NVL(USER_COL4,'X'),
        NVL(USER_COL5,'X'),
        NVL(UNIT_OF_MEASURE,'X'))
        IN
       (SELECT
          PTXN.TASK_ID,
          PTXN.PA_PERIOD_KEY,
          NVL(PTXN.EXPENSE_ORGANIZATION_ID,-99),
          NVL(PTXN.OWNER_ORGANIZATION_ID,-99),
          NVL(PTXN.RESOURCE_LIST_MEMBER_ID,-99),
          NVL(PTXN.SERVICE_TYPE_CODE,'X'),
          NVL(PTXN.EXPENDITURE_TYPE,'X'),
          NVL(PTXN.USER_COL1,'X'),
          NVL(PTXN.USER_COL2,'X'),
          NVL(PTXN.USER_COL3,'X'),
          NVL(PTXN.USER_COL4,'X'),
          NVL(PTXN.USER_COL5,'X'),
          NVL(PTXN.UNIT_OF_MEASURE,'X')
        FROM
          PA_ADW_ACT_CMT_V PTXN,
          PA_ADW_LOWEST_TASKS_V PT
        WHERE
          PTXN.TASK_ID = PT.TASK_ID
        AND PTXN.PROJECT_ID = x_project_id
        -- Exclude the tasks which are top tasks
        AND PT.TASK_ID <> PT.TOP_TASK_ID
        AND (PTXN.RES_ADW_NOTIFY_FLAG = 'S' OR PTXN.TXN_ADW_NOTIFY_FLAG = 'S')
        GROUP BY
          PTXN.TASK_ID,
          PTXN.PA_PERIOD_KEY,
          NVL(PTXN.EXPENSE_ORGANIZATION_ID,-99),
          NVL(PTXN.OWNER_ORGANIZATION_ID,-99),
          NVL(PTXN.RESOURCE_LIST_MEMBER_ID,-99),
          NVL(PTXN.SERVICE_TYPE_CODE,'X'),
          NVL(PTXN.EXPENDITURE_TYPE,'X'),
          NVL(PTXN.USER_COL1,'X'),
          NVL(PTXN.USER_COL2,'X'),
          NVL(PTXN.USER_COL3,'X'),
          NVL(PTXN.USER_COL4,'X'),
          NVL(PTXN.USER_COL5,'X'),
          NVL(PTXN.UNIT_OF_MEASURE,'X'))
     GROUP BY
        TASK_ID,
        PA_PERIOD_KEY,
        EXPENSE_ORGANIZATION_ID,
        OWNER_ORGANIZATION_ID,
        RESOURCE_LIST_MEMBER_ID,
        SERVICE_TYPE_CODE,
        EXPENDITURE_TYPE,
        USER_COL1,
        USER_COL2,
        USER_COL3,
        USER_COL4,
        USER_COL5,
        UNIT_OF_MEASURE;

     -- Define Cursor for selecting Actuals and Commitments
     -- at top level of task.

     CURSOR sel_top_act_cmts(x_project_id NUMBER) IS
     SELECT
        TOP_TASK_ID,
        PA_PERIOD_KEY,
        EXPENSE_ORGANIZATION_ID,
        OWNER_ORGANIZATION_ID,
        RESOURCE_LIST_MEMBER_ID,
        SERVICE_TYPE_CODE,
        EXPENDITURE_TYPE,
        USER_COL1,
        USER_COL2,
        USER_COL3,
        USER_COL4,
        USER_COL5,
        SUM(USER_COL6) USER_COL6,
        SUM(USER_COL7) USER_COL7,
        SUM(USER_COL8) USER_COL8,
        SUM(USER_COL9) USER_COL9,
        SUM(USER_COL10) USER_COL10,
        SUM(ACCUME_REVENUE) ACCUME_REVENUE,
        SUM(ACCUME_RAW_COST) ACCUME_RAW_COST,
        SUM(ACCUME_BURDENED_COST) ACCUME_BURDENED_COST,
        SUM(ACCUME_QUANTITY) ACCUME_QUANTITY,
        SUM(ACCUME_LABOR_HOURS) ACCUME_LABOR_HOURS,
        SUM(ACCUME_BILLABLE_RAW_COST) ACCUME_BILLABLE_RAW_COST,
        SUM(ACCUME_BILLABLE_BURDENED_COST) ACCUME_BILLABLE_BURDENED_COST,
        SUM(ACCUME_BILLABLE_QUANTITY) ACCUME_BILLABLE_QUANTITY,
        SUM(ACCUME_BILLABLE_LABOR_HOURS) ACCUME_BILLABLE_LABOR_HOURS,
        SUM(ACCUME_CMT_RAW_COST) ACCUME_CMT_RAW_COST,
        SUM(ACCUME_CMT_BURDENED_COST) ACCUME_CMT_BURDENED_COST,
        SUM(ACCUME_CMT_QUANTITY) ACCUME_CMT_QUANTITY,
        UNIT_OF_MEASURE
     FROM
        PA_ADW_ACT_CMT_V
     WHERE
     PROJECT_ID = x_project_id
     AND (TOP_TASK_ID,
        PA_PERIOD_KEY,
        NVL(EXPENSE_ORGANIZATION_ID,-99),
        NVL(OWNER_ORGANIZATION_ID,-99),
        NVL(RESOURCE_LIST_MEMBER_ID,-99),
        NVL(SERVICE_TYPE_CODE,'X'),
        NVL(EXPENDITURE_TYPE,'X'),
        NVL(USER_COL1,'X'),
        NVL(USER_COL2,'X'),
        NVL(USER_COL3,'X'),
        NVL(USER_COL4,'X'),
        NVL(USER_COL5,'X'),
        NVL(UNIT_OF_MEASURE,'X'))
        IN
       (SELECT
          PTXN.TOP_TASK_ID,
          PTXN.PA_PERIOD_KEY,
          NVL(PTXN.EXPENSE_ORGANIZATION_ID,-99),
          NVL(PTXN.OWNER_ORGANIZATION_ID,-99),
          NVL(PTXN.RESOURCE_LIST_MEMBER_ID,-99),
          NVL(PTXN.SERVICE_TYPE_CODE,'X'),
          NVL(PTXN.EXPENDITURE_TYPE,'X'),
          NVL(PTXN.USER_COL1,'X'),
          NVL(PTXN.USER_COL2,'X'),
          NVL(PTXN.USER_COL3,'X'),
          NVL(PTXN.USER_COL4,'X'),
          NVL(PTXN.USER_COL5,'X'),
          NVL(PTXN.UNIT_OF_MEASURE,'X')
        FROM
          PA_ADW_ACT_CMT_V PTXN,
          PA_ADW_TOP_TASKS_V PT
        WHERE
          PTXN.TOP_TASK_ID = PT.TOP_TASK_ID
        AND PTXN.PROJECT_ID = x_project_id
        AND (PTXN.RES_ADW_NOTIFY_FLAG = 'S' OR PTXN.TXN_ADW_NOTIFY_FLAG = 'S')
        GROUP BY
          PTXN.TOP_TASK_ID,
          PTXN.PA_PERIOD_KEY,
          NVL(PTXN.EXPENSE_ORGANIZATION_ID,-99),
          NVL(PTXN.OWNER_ORGANIZATION_ID,-99),
          NVL(PTXN.RESOURCE_LIST_MEMBER_ID,-99),
          NVL(PTXN.SERVICE_TYPE_CODE,'X'),
          NVL(PTXN.EXPENDITURE_TYPE,'X'),
          NVL(PTXN.USER_COL1,'X'),
          NVL(PTXN.USER_COL2,'X'),
          NVL(PTXN.USER_COL3,'X'),
          NVL(PTXN.USER_COL4,'X'),
          NVL(PTXN.USER_COL5,'X'),
          NVL(PTXN.UNIT_OF_MEASURE,'X'))
     GROUP BY
        TOP_TASK_ID,
        PA_PERIOD_KEY,
        EXPENSE_ORGANIZATION_ID,
        OWNER_ORGANIZATION_ID,
        RESOURCE_LIST_MEMBER_ID,
        SERVICE_TYPE_CODE,
        EXPENDITURE_TYPE,
        USER_COL1,
        USER_COL2,
        USER_COL3,
        USER_COL4,
        USER_COL5,
        UNIT_OF_MEASURE;

     -- Define Cursor for selecting Actuals and Commitments
     -- at project level.

     CURSOR sel_prj_act_cmts(x_project_id NUMBER) IS
     SELECT
        PROJECT_ID,
        PA_PERIOD_KEY,
        EXPENSE_ORGANIZATION_ID,
        OWNER_ORGANIZATION_ID,
        RESOURCE_LIST_MEMBER_ID,
        SERVICE_TYPE_CODE,
        EXPENDITURE_TYPE,
        USER_COL1,
        USER_COL2,
        USER_COL3,
        USER_COL4,
        USER_COL5,
        SUM(USER_COL6) USER_COL6,
        SUM(USER_COL7) USER_COL7,
        SUM(USER_COL8) USER_COL8,
        SUM(USER_COL9) USER_COL9,
        SUM(USER_COL10) USER_COL10,
        SUM(ACCUME_REVENUE) ACCUME_REVENUE,
        SUM(ACCUME_RAW_COST) ACCUME_RAW_COST,
        SUM(ACCUME_BURDENED_COST) ACCUME_BURDENED_COST,
        SUM(ACCUME_QUANTITY) ACCUME_QUANTITY,
        SUM(ACCUME_LABOR_HOURS) ACCUME_LABOR_HOURS,
        SUM(ACCUME_BILLABLE_RAW_COST) ACCUME_BILLABLE_RAW_COST,
        SUM(ACCUME_BILLABLE_BURDENED_COST) ACCUME_BILLABLE_BURDENED_COST,
        SUM(ACCUME_BILLABLE_QUANTITY) ACCUME_BILLABLE_QUANTITY,
        SUM(ACCUME_BILLABLE_LABOR_HOURS) ACCUME_BILLABLE_LABOR_HOURS,
        SUM(ACCUME_CMT_RAW_COST) ACCUME_CMT_RAW_COST,
        SUM(ACCUME_CMT_BURDENED_COST) ACCUME_CMT_BURDENED_COST,
        SUM(ACCUME_CMT_QUANTITY) ACCUME_CMT_QUANTITY,
        UNIT_OF_MEASURE
     FROM
        PA_ADW_ACT_CMT_V
     WHERE
     PROJECT_ID = x_project_id
     AND (PROJECT_ID,
        PA_PERIOD_KEY,
        NVL(EXPENSE_ORGANIZATION_ID,-99),
        NVL(OWNER_ORGANIZATION_ID,-99),
        NVL(RESOURCE_LIST_MEMBER_ID,-99),
        NVL(SERVICE_TYPE_CODE,'X'),
        NVL(EXPENDITURE_TYPE,'X'),
        NVL(USER_COL1,'X'),
        NVL(USER_COL2,'X'),
        NVL(USER_COL3,'X'),
        NVL(USER_COL4,'X'),
        NVL(USER_COL5,'X'),
        NVL(UNIT_OF_MEASURE,'X'))
        IN
       (SELECT
          PTXN.PROJECT_ID,
          PTXN.PA_PERIOD_KEY,
          NVL(PTXN.EXPENSE_ORGANIZATION_ID,-99),
          NVL(PTXN.OWNER_ORGANIZATION_ID,-99),
          NVL(PTXN.RESOURCE_LIST_MEMBER_ID,-99),
          NVL(PTXN.SERVICE_TYPE_CODE,'X'),
          NVL(PTXN.EXPENDITURE_TYPE,'X'),
          NVL(PTXN.USER_COL1,'X'),
          NVL(PTXN.USER_COL2,'X'),
          NVL(PTXN.USER_COL3,'X'),
          NVL(PTXN.USER_COL4,'X'),
          NVL(PTXN.USER_COL5,'X'),
          NVL(PTXN.UNIT_OF_MEASURE,'X')
        FROM
          PA_ADW_ACT_CMT_V PTXN
        WHERE
        PTXN.PROJECT_ID = x_project_id
        AND (PTXN.RES_ADW_NOTIFY_FLAG = 'S' OR PTXN.TXN_ADW_NOTIFY_FLAG = 'S')
        GROUP BY
          PTXN.PROJECT_ID,
          PTXN.PA_PERIOD_KEY,
          NVL(PTXN.EXPENSE_ORGANIZATION_ID,-99),
          NVL(PTXN.OWNER_ORGANIZATION_ID,-99),
          NVL(PTXN.RESOURCE_LIST_MEMBER_ID,-99),
          NVL(PTXN.SERVICE_TYPE_CODE,'X'),
          NVL(PTXN.EXPENDITURE_TYPE,'X'),
          NVL(PTXN.USER_COL1,'X'),
          NVL(PTXN.USER_COL2,'X'),
          NVL(PTXN.USER_COL3,'X'),
          NVL(PTXN.USER_COL4,'X'),
          NVL(PTXN.USER_COL5,'X'),
          NVL(PTXN.UNIT_OF_MEASURE,'X'))
     GROUP BY
        PROJECT_ID,
        PA_PERIOD_KEY,
        EXPENSE_ORGANIZATION_ID,
        OWNER_ORGANIZATION_ID,
        RESOURCE_LIST_MEMBER_ID,
        SERVICE_TYPE_CODE,
        EXPENDITURE_TYPE,
        USER_COL1,
        USER_COL2,
        USER_COL3,
        USER_COL4,
        USER_COL5,
        UNIT_OF_MEASURE;

     -- Cursor for selecting projects for processing

     CURSOR sel_prjs IS
     SELECT
	PROJECT_ID,
        SEGMENT1
     FROM
	PA_ADW_PROJECTS_V
     WHERE segment1 BETWEEN NVL(x_project_num_from,segment1)
                          AND NVL(x_project_num_to,segment1);

     -- define procedure variables

     ref_lowest_act_cmts_r     	     sel_ref_lowest_act_cmts%ROWTYPE;
     ref_top_act_cmts_r     	     sel_ref_top_act_cmts%ROWTYPE;
     ref_prj_act_cmts_r     	     sel_ref_prj_act_cmts%ROWTYPE;
     ref_lowest_ser_type_act_cmts_r  sel_ref_lowest_stype_act_cmts%ROWTYPE;
     ref_top_ser_type_act_cmts_r     sel_ref_top_ser_type_act_cmts%ROWTYPE;
     ref_prj_ser_type_act_cmts_r     sel_ref_prj_ser_type_act_cmts%ROWTYPE;

     lowest_act_cmts_r      sel_lowest_act_cmts%ROWTYPE;
     top_act_cmts_r         sel_top_act_cmts%ROWTYPE;
     prj_act_cmts_r         sel_prj_act_cmts%ROWTYPE;

     sel_prjs_r             sel_prjs%ROWTYPE;

     x_old_err_stack	    VARCHAR2(1024);
     txn_count		    NUMBER;
     res_count		    NUMBER;
     ref_res_count          NUMBER;  -- The resources to be refreshed because
				     -- the resources were refreshed
     ref_ser_type_count     NUMBER;  -- The number of tasks to be refreshed for
  				     -- service type change


   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Collecting Actuals/Commitments';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_fact_act_cmts';

     pa_debug.debug(x_err_stage);

     -- Process all projects one one by one

     FOR sel_prjs_r IN sel_prjs LOOP

      -- Mark the PA_TASK_HISTORY rows for latest service_type
      -- These are the task for which the service type is latest

      pa_debug.debug('Processing project_id ' || to_char(sel_prjs_r.project_id) || ' Project Number' || sel_prjs_r.segment1 );

      UPDATE
        PA_TASK_HISTORY PTH
      SET
        ADW_NOTIFY_FLAG = 'Y'
      WHERE
        PROJECT_ID = sel_prjs_r.project_id
      AND TASK_HISTORY_ID IN
          ( SELECT MAX(TASK_HISTORY_ID)
            FROM   PA_TASK_HISTORY PTHL
            WHERE  PTHL.TASK_ID = PTH.TASK_ID
          );

      pa_debug.debug('Marked ' || TO_CHAR(SQL%ROWCOUNT) || ' Task Rows for Transfer');

      -- Update the task where the service type has changed from
      -- the last time the tasks were interfaced to the interface table
      -- and the task which are not refreshed earlier by the project refresh
      -- cursor


      UPDATE PA_ADW_INTERFACED_TASKS PTH
      SET
          ADW_NOTIFY_FLAG = 'S'
      WHERE
          ADW_INTERFACE_FLAG = 'Y'
      AND PROJECT_ID = sel_prjs_r.project_id
      AND EXISTS
          ( SELECT 'Yes'
            FROM   PA_TASK_HISTORY PTHL
            WHERE  PTHL.TASK_ID = PTH.TASK_ID
            AND    (
                     PTHL.SERVICE_TYPE_CODE <> PTH.SERVICE_TYPE_CODE or
                     PTHL.CARRYING_OUT_ORGANIZATION_ID <> PTH.CARRYING_OUT_ORGANIZATION_ID -- fix for bug 1233570, created by DMPOTAPO
                   )
            AND    PTHL.TASK_HISTORY_ID > PTH.TASK_HISTORY_ID
          )
      AND NOT EXISTS
          ( SELECT 'Yes'
            FROM   PA_OLD_RES_ACCUM_DTLS
            WHERE  PROJECT_ID = sel_prjs_r.project_id
            AND    TASK_ID = PTH.TASK_ID
            AND    ADW_NOTIFY_FLAG = 'Y'
          );

      ref_ser_type_count := SQL%ROWCOUNT;
      pa_debug.debug('Marked ' || TO_CHAR(SQL%ROWCOUNT) || ' Task Rows for Service Type Change');

      -- Mark the other tasks with this service type for refresh too

      UPDATE PA_ADW_INTERFACED_TASKS PTH
      SET
          ADW_NOTIFY_FLAG = 'P'
      WHERE
          ADW_INTERFACE_FLAG = 'Y'
      AND ADW_NOTIFY_FLAG <> 'S'
      AND PROJECT_ID = sel_prjs_r.project_id
      AND EXISTS
          ( SELECT 'Yes'
            FROM   PA_ADW_INTERFACED_TASKS PTHL
            WHERE  PTHL.TASK_ID <> PTH.TASK_ID
            AND    (
                     PTHL.SERVICE_TYPE_CODE = PTH.SERVICE_TYPE_CODE or
                     PTHL.CARRYING_OUT_ORGANIZATION_ID = PTH.CARRYING_OUT_ORGANIZATION_ID -- fix for bug 1233570, created by DMPOTAPO
                   )
            AND    PTHL.PROJECT_ID = sel_prjs_r.project_id
            AND    PTHL.ADW_NOTIFY_FLAG = 'S'
          )
      AND NOT EXISTS
          ( SELECT 'Yes'
            FROM   PA_OLD_RES_ACCUM_DTLS
            WHERE  PROJECT_ID = sel_prjs_r.project_id
            AND    TASK_ID = PTH.TASK_ID
            AND    ADW_NOTIFY_FLAG = 'Y'
          );
      pa_debug.debug('Marked ' || TO_CHAR(SQL%ROWCOUNT) || ' Task Rows for Service Type Change at other tasks');

      -- Update all lowest level tasks if any top task got changed

      UPDATE PA_ADW_INTERFACED_TASKS PTH
      SET
          ADW_NOTIFY_FLAG = 'P'
      WHERE
          ADW_INTERFACE_FLAG = 'Y'
      AND ADW_NOTIFY_FLAG <> 'S'
      AND PROJECT_ID = sel_prjs_r.project_id
      AND EXISTS
          ( SELECT 'Yes'
            FROM   PA_TASK_HISTORY PTHL
            WHERE  PTHL.TASK_ID = PTH.TOP_TASK_ID
            AND    PTHL.ADW_NOTIFY_FLAG = 'S'
          )
      AND NOT EXISTS
          ( SELECT 'Yes'
            FROM   PA_OLD_RES_ACCUM_DTLS
            WHERE  PROJECT_ID = sel_prjs_r.project_id
            AND    TASK_ID = PTH.TASK_ID
            AND    ADW_NOTIFY_FLAG = 'Y'
          );
      pa_debug.debug('Marked ' || TO_CHAR(SQL%ROWCOUNT) || ' Task Rows due to the service type change at top task level');

      -- Mark all the resource accum rows need to be refreshed

      UPDATE
        PA_OLD_RES_ACCUM_DTLS
      SET
        ADW_NOTIFY_FLAG = 'S'
      WHERE
        PROJECT_ID = sel_prjs_r.project_id
      AND ADW_NOTIFY_FLAG = 'Y';

      ref_res_count := SQL%ROWCOUNT;

      pa_debug.debug('Marked ' || TO_CHAR(SQL%ROWCOUNT) || ' Old Resource accum details');

      -- Check if the service type was changed for any task interfaced earlier
      -- For all of these tasks we need to send adjustments. We will send $0
      -- for the old service type and full amount to the new service type

      IF ( ref_res_count <> 0 ) THEN

       -- Check the profile option value for collecting lowest tasks

       IF ( pa_adw_collect_main.collect_lowest_tasks_flag = 'Y') THEN

        -- Refresh the lowest tasks numbers

        x_err_stage     := 'Refreshing txns at lowest task level';

        pa_debug.debug(x_err_stage);

        FOR ref_lowest_act_cmts_r IN sel_ref_lowest_act_cmts(sel_prjs_r.project_id) LOOP

	 pa_debug.debug('Sending $0** for lowest task_id ' || to_char(ref_lowest_act_cmts_r.task_id) || ' For Service Type ' || ref_lowest_act_cmts_r.service_type_code);

   	 update_tasks_act_cmt
		 (ref_lowest_act_cmts_r.task_id,
		  ref_lowest_act_cmts_r.pa_period_key,
		  ref_lowest_act_cmts_r.expense_organization_id,
		  ref_lowest_act_cmts_r.owner_organization_id,
		  ref_lowest_act_cmts_r.resource_list_member_id,
		  ref_lowest_act_cmts_r.service_type_code,
		  ref_lowest_act_cmts_r.expenditure_type,
		  ref_lowest_act_cmts_r.user_col1,
		  ref_lowest_act_cmts_r.user_col2,
		  ref_lowest_act_cmts_r.user_col3,
		  ref_lowest_act_cmts_r.user_col4,
		  ref_lowest_act_cmts_r.user_col5,
		  ref_lowest_act_cmts_r.user_col6,
		  ref_lowest_act_cmts_r.user_col7,
		  ref_lowest_act_cmts_r.user_col8,
		  ref_lowest_act_cmts_r.user_col9,
		  ref_lowest_act_cmts_r.user_col10,
		  ref_lowest_act_cmts_r.accume_revenue,
		  ref_lowest_act_cmts_r.accume_raw_cost,
		  ref_lowest_act_cmts_r.accume_burdened_cost,
		  ref_lowest_act_cmts_r.accume_quantity,
		  ref_lowest_act_cmts_r.accume_labor_hours,
		  ref_lowest_act_cmts_r.accume_billable_raw_cost,
		  ref_lowest_act_cmts_r.accume_billable_burdened_cost,
		  ref_lowest_act_cmts_r.accume_billable_quantity,
		  ref_lowest_act_cmts_r.accume_billable_labor_hours,
		  ref_lowest_act_cmts_r.accume_cmt_raw_cost,
		  ref_lowest_act_cmts_r.accume_cmt_burdened_cost,
		  ref_lowest_act_cmts_r.accume_cmt_quantity,
		  ref_lowest_act_cmts_r.unit_of_measure,
                  x_err_stage,
                  x_err_stack,
                  x_err_code);

        END LOOP; -- FOR ref_lowest_act_cmts_r IN sel_ref_lowest_act_cmts

       END IF; -- IF ( pa_adw_collect_main.collect_lowest_tasks_flag = 'Y')

       -- Check the profile option value for collecting top tasks

       IF ( pa_adw_collect_main.collect_top_tasks_flag = 'Y') THEN

        -- Refresh the top tasks numbers

        x_err_stage     := 'Refreshing txns at top task level';

        pa_debug.debug(x_err_stage);

        FOR ref_top_act_cmts_r IN sel_ref_top_act_cmts(sel_prjs_r.project_id) LOOP

	 pa_debug.debug('Sending $0** for top task_id ' || to_char(ref_top_act_cmts_r.top_task_id) || ' For Service Type ' || ref_top_act_cmts_r.service_type_code);

   	 update_tasks_act_cmt
		 (ref_top_act_cmts_r.top_task_id,
		  ref_top_act_cmts_r.pa_period_key,
		  ref_top_act_cmts_r.expense_organization_id,
		  ref_top_act_cmts_r.owner_organization_id,
		  ref_top_act_cmts_r.resource_list_member_id,
		  ref_top_act_cmts_r.service_type_code,
		  ref_top_act_cmts_r.expenditure_type,
		  ref_top_act_cmts_r.user_col1,
		  ref_top_act_cmts_r.user_col2,
		  ref_top_act_cmts_r.user_col3,
		  ref_top_act_cmts_r.user_col4,
		  ref_top_act_cmts_r.user_col5,
		  ref_top_act_cmts_r.user_col6,
		  ref_top_act_cmts_r.user_col7,
		  ref_top_act_cmts_r.user_col8,
		  ref_top_act_cmts_r.user_col9,
		  ref_top_act_cmts_r.user_col10,
		  ref_top_act_cmts_r.accume_revenue,
		  ref_top_act_cmts_r.accume_raw_cost,
		  ref_top_act_cmts_r.accume_burdened_cost,
		  ref_top_act_cmts_r.accume_quantity,
		  ref_top_act_cmts_r.accume_labor_hours,
		  ref_top_act_cmts_r.accume_billable_raw_cost,
		  ref_top_act_cmts_r.accume_billable_burdened_cost,
		  ref_top_act_cmts_r.accume_billable_quantity,
		  ref_top_act_cmts_r.accume_billable_labor_hours,
		  ref_top_act_cmts_r.accume_cmt_raw_cost,
		  ref_top_act_cmts_r.accume_cmt_burdened_cost,
		  ref_top_act_cmts_r.accume_cmt_quantity,
		  ref_top_act_cmts_r.unit_of_measure,
                  x_err_stage,
                  x_err_stack,
                  x_err_code);

        END LOOP; -- FOR ref_top_act_cmts_r IN sel_ref_top_act_cmts

       END IF; -- IF ( pa_adw_collect_main.collect_top_tasks_flag = 'Y')

       -- Refresh the project level Numbers

       x_err_stage     := 'Refreshing txns at Project level';

       pa_debug.debug(x_err_stage);

       FOR ref_prj_act_cmts_r IN sel_ref_prj_act_cmts(sel_prjs_r.project_id) LOOP

	 pa_debug.debug('Sending $0*** for project_id ' || to_char(ref_prj_act_cmts_r.project_id) || ' For Service Type ' || ref_prj_act_cmts_r.service_type_code);

   	 update_prj_act_cmt
		 (ref_prj_act_cmts_r.project_id,
		  ref_prj_act_cmts_r.pa_period_key,
		  ref_prj_act_cmts_r.expense_organization_id,
		  ref_prj_act_cmts_r.owner_organization_id,
		  ref_prj_act_cmts_r.resource_list_member_id,
		  ref_prj_act_cmts_r.service_type_code,
		  ref_prj_act_cmts_r.expenditure_type,
		  ref_prj_act_cmts_r.user_col1,
		  ref_prj_act_cmts_r.user_col2,
		  ref_prj_act_cmts_r.user_col3,
		  ref_prj_act_cmts_r.user_col4,
		  ref_prj_act_cmts_r.user_col5,
		  ref_prj_act_cmts_r.user_col6,
		  ref_prj_act_cmts_r.user_col7,
		  ref_prj_act_cmts_r.user_col8,
		  ref_prj_act_cmts_r.user_col9,
		  ref_prj_act_cmts_r.user_col10,
		  ref_prj_act_cmts_r.accume_revenue,
		  ref_prj_act_cmts_r.accume_raw_cost,
		  ref_prj_act_cmts_r.accume_burdened_cost,
		  ref_prj_act_cmts_r.accume_quantity,
		  ref_prj_act_cmts_r.accume_labor_hours,
		  ref_prj_act_cmts_r.accume_billable_raw_cost,
		  ref_prj_act_cmts_r.accume_billable_burdened_cost,
		  ref_prj_act_cmts_r.accume_billable_quantity,
		  ref_prj_act_cmts_r.accume_billable_labor_hours,
		  ref_prj_act_cmts_r.accume_cmt_raw_cost,
		  ref_prj_act_cmts_r.accume_cmt_burdened_cost,
		  ref_prj_act_cmts_r.accume_cmt_quantity,
		  ref_prj_act_cmts_r.unit_of_measure,
                  x_err_stage,
                  x_err_stack,
                  x_err_code);

       END LOOP; -- FOR ref_prj_act_cmts_r IN sel_ref_prj_act_cmts

       -- Mark the project types as transferred to Interface table

       -- PLEASE NOTE THAT WE ARE UPDATING THE BASE TABLE SINCE THE
       -- PA_ADW_R_ACT_CMT_V IS DEFINED ON MULTIPLE TABLES

       UPDATE
        PA_OLD_RES_ACCUM_DTLS
       SET
        ADW_NOTIFY_FLAG = 'N'
       WHERE
        ADW_NOTIFY_FLAG = 'S';

      END IF; -- IF ( ref_res_count <> 0 )

      IF ( ref_ser_type_count <> 0 ) THEN

       -- Check the profile option value for collecting lowest tasks

       IF ( pa_adw_collect_main.collect_lowest_tasks_flag = 'Y') THEN

        -- Refresh the lowest tasks numbers

        x_err_stage := 'Refreshing txns at lowest task level for service type change';

        pa_debug.debug(x_err_stage);

        FOR ref_lowest_ser_type_act_cmts_r IN sel_ref_lowest_stype_act_cmts(sel_prjs_r.project_id) LOOP

	 pa_debug.debug('Sending $0**** for lowest task_id ' || to_char(ref_lowest_ser_type_act_cmts_r.task_id) || ' For Service Type ' || ref_lowest_ser_type_act_cmts_r.service_type_code);

   	 update_tasks_act_cmt
		 (ref_lowest_ser_type_act_cmts_r.task_id,
		  ref_lowest_ser_type_act_cmts_r.pa_period_key,
		  ref_lowest_ser_type_act_cmts_r.expense_organization_id,
		  ref_lowest_ser_type_act_cmts_r.owner_organization_id,
		  ref_lowest_ser_type_act_cmts_r.resource_list_member_id,
		  ref_lowest_ser_type_act_cmts_r.service_type_code,
		  ref_lowest_ser_type_act_cmts_r.expenditure_type,
		  ref_lowest_ser_type_act_cmts_r.user_col1,
		  ref_lowest_ser_type_act_cmts_r.user_col2,
		  ref_lowest_ser_type_act_cmts_r.user_col3,
		  ref_lowest_ser_type_act_cmts_r.user_col4,
		  ref_lowest_ser_type_act_cmts_r.user_col5,
		  ref_lowest_ser_type_act_cmts_r.user_col6,
		  ref_lowest_ser_type_act_cmts_r.user_col7,
		  ref_lowest_ser_type_act_cmts_r.user_col8,
		  ref_lowest_ser_type_act_cmts_r.user_col9,
		  ref_lowest_ser_type_act_cmts_r.user_col10,
		  ref_lowest_ser_type_act_cmts_r.accume_revenue,
		  ref_lowest_ser_type_act_cmts_r.accume_raw_cost,
		  ref_lowest_ser_type_act_cmts_r.accume_burdened_cost,
		  ref_lowest_ser_type_act_cmts_r.accume_quantity,
		  ref_lowest_ser_type_act_cmts_r.accume_labor_hours,
		  ref_lowest_ser_type_act_cmts_r.accume_billable_raw_cost,
		  ref_lowest_ser_type_act_cmts_r.accume_billable_burdened_cost,
		  ref_lowest_ser_type_act_cmts_r.accume_billable_quantity,
		  ref_lowest_ser_type_act_cmts_r.accume_billable_labor_hours,
		  ref_lowest_ser_type_act_cmts_r.accume_cmt_raw_cost,
		  ref_lowest_ser_type_act_cmts_r.accume_cmt_burdened_cost,
		  ref_lowest_ser_type_act_cmts_r.accume_cmt_quantity,
		  ref_lowest_ser_type_act_cmts_r.unit_of_measure,
                  x_err_stage,
                  x_err_stack,
                  x_err_code);

        END LOOP; -- FOR ref_lowest_ser_type_act_cmts_r IN sel_ref_lowest_stype_act_cmts

       END IF; -- IF ( pa_adw_collect_main.collect_lowest_tasks_flag = 'Y')

       -- Check the profile option value for collecting top tasks

       IF ( pa_adw_collect_main.collect_top_tasks_flag = 'Y') THEN

        -- Refresh the top tasks numbers

        x_err_stage := 'Refreshing txns at top task level for service type change';

        pa_debug.debug(x_err_stage);

        FOR ref_top_ser_type_act_cmts_r IN sel_ref_top_ser_type_act_cmts(sel_prjs_r.project_id) LOOP

	 pa_debug.debug('Sending $0**** for top task_id ' || to_char(ref_top_ser_type_act_cmts_r.top_task_id) || ' For Service Type ' || ref_top_ser_type_act_cmts_r.service_type_code);

   	 update_tasks_act_cmt
		 (ref_top_ser_type_act_cmts_r.top_task_id,
		  ref_top_ser_type_act_cmts_r.pa_period_key,
		  ref_top_ser_type_act_cmts_r.expense_organization_id,
		  ref_top_ser_type_act_cmts_r.owner_organization_id,
		  ref_top_ser_type_act_cmts_r.resource_list_member_id,
		  ref_top_ser_type_act_cmts_r.service_type_code,
		  ref_top_ser_type_act_cmts_r.expenditure_type,
		  ref_top_ser_type_act_cmts_r.user_col1,
		  ref_top_ser_type_act_cmts_r.user_col2,
		  ref_top_ser_type_act_cmts_r.user_col3,
		  ref_top_ser_type_act_cmts_r.user_col4,
		  ref_top_ser_type_act_cmts_r.user_col5,
		  ref_top_ser_type_act_cmts_r.user_col6,
		  ref_top_ser_type_act_cmts_r.user_col7,
		  ref_top_ser_type_act_cmts_r.user_col8,
		  ref_top_ser_type_act_cmts_r.user_col9,
		  ref_top_ser_type_act_cmts_r.user_col10,
		  ref_top_ser_type_act_cmts_r.accume_revenue,
		  ref_top_ser_type_act_cmts_r.accume_raw_cost,
		  ref_top_ser_type_act_cmts_r.accume_burdened_cost,
		  ref_top_ser_type_act_cmts_r.accume_quantity,
		  ref_top_ser_type_act_cmts_r.accume_labor_hours,
		  ref_top_ser_type_act_cmts_r.accume_billable_raw_cost,
		  ref_top_ser_type_act_cmts_r.accume_billable_burdened_cost,
		  ref_top_ser_type_act_cmts_r.accume_billable_quantity,
		  ref_top_ser_type_act_cmts_r.accume_billable_labor_hours,
		  ref_top_ser_type_act_cmts_r.accume_cmt_raw_cost,
		  ref_top_ser_type_act_cmts_r.accume_cmt_burdened_cost,
		  ref_top_ser_type_act_cmts_r.accume_cmt_quantity,
		  ref_top_ser_type_act_cmts_r.unit_of_measure,
                  x_err_stage,
                  x_err_stack,
                  x_err_code);

        END LOOP; -- FOR ref_top_ser_type_act_cmts_r IN sel_ref_top_ser_type_act_cmts

       END IF; -- IF ( pa_adw_collect_main.collect_top_tasks_flag = 'Y')

       -- Refresh the project level Numbers

       x_err_stage     := 'Refreshing txns at Project level';

       pa_debug.debug(x_err_stage);

       FOR ref_prj_ser_type_act_cmts_r IN sel_ref_prj_ser_type_act_cmts(sel_prjs_r.project_id) LOOP

	 pa_debug.debug('Sending $0***** for project_id ' || to_char(ref_prj_ser_type_act_cmts_r.project_id) || ' For Service Type ' || ref_prj_ser_type_act_cmts_r.service_type_code);

   	 update_prj_act_cmt
		 (ref_prj_ser_type_act_cmts_r.project_id,
		  ref_prj_ser_type_act_cmts_r.pa_period_key,
		  ref_prj_ser_type_act_cmts_r.expense_organization_id,
		  ref_prj_ser_type_act_cmts_r.owner_organization_id,
		  ref_prj_ser_type_act_cmts_r.resource_list_member_id,
		  ref_prj_ser_type_act_cmts_r.service_type_code,
		  ref_prj_ser_type_act_cmts_r.expenditure_type,
		  ref_prj_ser_type_act_cmts_r.user_col1,
		  ref_prj_ser_type_act_cmts_r.user_col2,
		  ref_prj_ser_type_act_cmts_r.user_col3,
		  ref_prj_ser_type_act_cmts_r.user_col4,
		  ref_prj_ser_type_act_cmts_r.user_col5,
		  ref_prj_ser_type_act_cmts_r.user_col6,
		  ref_prj_ser_type_act_cmts_r.user_col7,
		  ref_prj_ser_type_act_cmts_r.user_col8,
		  ref_prj_ser_type_act_cmts_r.user_col9,
		  ref_prj_ser_type_act_cmts_r.user_col10,
		  ref_prj_ser_type_act_cmts_r.accume_revenue,
		  ref_prj_ser_type_act_cmts_r.accume_raw_cost,
		  ref_prj_ser_type_act_cmts_r.accume_burdened_cost,
		  ref_prj_ser_type_act_cmts_r.accume_quantity,
		  ref_prj_ser_type_act_cmts_r.accume_labor_hours,
		  ref_prj_ser_type_act_cmts_r.accume_billable_raw_cost,
		  ref_prj_ser_type_act_cmts_r.accume_billable_burdened_cost,
		  ref_prj_ser_type_act_cmts_r.accume_billable_quantity,
		  ref_prj_ser_type_act_cmts_r.accume_billable_labor_hours,
		  ref_prj_ser_type_act_cmts_r.accume_cmt_raw_cost,
		  ref_prj_ser_type_act_cmts_r.accume_cmt_burdened_cost,
		  ref_prj_ser_type_act_cmts_r.accume_cmt_quantity,
		  ref_prj_ser_type_act_cmts_r.unit_of_measure,
                  x_err_stage,
                  x_err_stack,
                  x_err_code);

       END LOOP; -- FOR ref_prj_ser_type_act_cmts_r IN sel_ref_prj_ser_type_act_cmts

       -- Mark the rows in PA_TXN_ACCUM table for re-transfer

       UPDATE PA_TXN_ACCUM PTA
          SET ADW_NOTIFY_FLAG = 'Y'
       WHERE
          TASK_ID IN
          (SELECT TASK_ID
           FROM PA_TASK_HISTORY PTH
           WHERE PTH.TASK_ID = PTA.TASK_ID
           AND PTH.ADW_NOTIFY_FLAG IN ('S','P')
          );

       pa_debug.debug('Marked '||TO_CHAR(SQL%ROWCOUNT)||' Txn Accum rows for re-transfer due to service type change alone');

       UPDATE
        PA_TASK_HISTORY
       SET
        ADW_NOTIFY_FLAG = 'N'
       WHERE
        ADW_NOTIFY_FLAG = 'S';

       UPDATE
        PA_TASK_HISTORY
       SET
        ADW_NOTIFY_FLAG = 'Y'
       WHERE
        ADW_NOTIFY_FLAG = 'P';

      END IF; -- IF ( ref_ser_type_count <> 0 )


      /* Txns refresh completed */

      -- First mark all the rows need to be transferred

      UPDATE
        PA_RESOURCE_ACCUM_DETAILS PRAD
      SET
        PRAD.ADW_NOTIFY_FLAG = 'S'
      WHERE
        PRAD.PROJECT_ID = SEL_PRJS_R.PROJECT_ID
      AND PRAD.ADW_NOTIFY_FLAG = 'Y'
      AND EXISTS
          ( SELECT 'Yes'
            FROM
                 PA_ADW_RES_LISTS_V PRL
            WHERE PRAD.RESOURCE_LIST_ID = PRL.RESOURCE_LIST_ID
          );

      txn_count := SQL%ROWCOUNT;

      UPDATE
        PA_TXN_ACCUM
      SET
        ADW_NOTIFY_FLAG = 'S'
      WHERE
        PROJECT_ID = sel_prjs_r.project_id
      AND ADW_NOTIFY_FLAG = 'Y';

      res_count := SQL%ROWCOUNT;

      IF ( txn_count <> 0 OR res_count <> 0 ) THEN

       -- Check the profile option value for collecting lowest tasks

       IF ( pa_adw_collect_main.collect_lowest_tasks_flag = 'Y') THEN

        -- collect Actuals/Cmts at lowest tasks level

        x_err_stage     := 'Collecting Actuals/Cmts txns at lowest task level';

        pa_debug.debug(x_err_stage);

        FOR lowest_act_cmts_r IN sel_lowest_act_cmts(sel_prjs_r.project_id) LOOP

	 pa_debug.debug('Sending for lowest task_id ' || to_char(lowest_act_cmts_r.task_id) || ' For Service Type ' || lowest_act_cmts_r.service_type_code);


   	 update_tasks_act_cmt
		 (lowest_act_cmts_r.task_id,
		  lowest_act_cmts_r.pa_period_key,
		  lowest_act_cmts_r.expense_organization_id,
		  lowest_act_cmts_r.owner_organization_id,
		  lowest_act_cmts_r.resource_list_member_id,
		  lowest_act_cmts_r.service_type_code,
		  lowest_act_cmts_r.expenditure_type,
		  lowest_act_cmts_r.user_col1,
		  lowest_act_cmts_r.user_col2,
		  lowest_act_cmts_r.user_col3,
		  lowest_act_cmts_r.user_col4,
		  lowest_act_cmts_r.user_col5,
		  lowest_act_cmts_r.user_col6,
		  lowest_act_cmts_r.user_col7,
		  lowest_act_cmts_r.user_col8,
		  lowest_act_cmts_r.user_col9,
		  lowest_act_cmts_r.user_col10,
		  lowest_act_cmts_r.accume_revenue,
		  lowest_act_cmts_r.accume_raw_cost,
		  lowest_act_cmts_r.accume_burdened_cost,
		  lowest_act_cmts_r.accume_quantity,
		  lowest_act_cmts_r.accume_labor_hours,
		  lowest_act_cmts_r.accume_billable_raw_cost,
		  lowest_act_cmts_r.accume_billable_burdened_cost,
		  lowest_act_cmts_r.accume_billable_quantity,
		  lowest_act_cmts_r.accume_billable_labor_hours,
		  lowest_act_cmts_r.accume_cmt_raw_cost,
		  lowest_act_cmts_r.accume_cmt_burdened_cost,
		  lowest_act_cmts_r.accume_cmt_quantity,
		  lowest_act_cmts_r.unit_of_measure,
                  x_err_stage,
                  x_err_stack,
                  x_err_code);

        END LOOP; -- FOR lowest_act_cmts_r IN sel_lowest_act_cmts

       END IF; -- IF ( pa_adw_collect_main.collect_lowest_tasks_flag = 'Y')

       -- Check the profile option value for collecting top tasks

       IF ( pa_adw_collect_main.collect_top_tasks_flag = 'Y') THEN

        -- collect Actuals/Cmts at top tasks level

        x_err_stage     := 'Collecting Actuals/Cmts txns at top task level';

        pa_debug.debug(x_err_stage);

        FOR top_act_cmts_r IN sel_top_act_cmts(sel_prjs_r.project_id) LOOP

	 pa_debug.debug('Sending for top task_id ' || to_char(top_act_cmts_r.top_task_id) || ' For Service Type ' || top_act_cmts_r.service_type_code);

   	 update_tasks_act_cmt
		 (top_act_cmts_r.top_task_id,
		  top_act_cmts_r.pa_period_key,
		  top_act_cmts_r.expense_organization_id,
		  top_act_cmts_r.owner_organization_id,
		  top_act_cmts_r.resource_list_member_id,
		  top_act_cmts_r.service_type_code,
		  top_act_cmts_r.expenditure_type,
		  top_act_cmts_r.user_col1,
		  top_act_cmts_r.user_col2,
		  top_act_cmts_r.user_col3,
		  top_act_cmts_r.user_col4,
		  top_act_cmts_r.user_col5,
		  top_act_cmts_r.user_col6,
		  top_act_cmts_r.user_col7,
		  top_act_cmts_r.user_col8,
		  top_act_cmts_r.user_col9,
		  top_act_cmts_r.user_col10,
		  top_act_cmts_r.accume_revenue,
		  top_act_cmts_r.accume_raw_cost,
		  top_act_cmts_r.accume_burdened_cost,
		  top_act_cmts_r.accume_quantity,
		  top_act_cmts_r.accume_labor_hours,
		  top_act_cmts_r.accume_billable_raw_cost,
		  top_act_cmts_r.accume_billable_burdened_cost,
		  top_act_cmts_r.accume_billable_quantity,
		  top_act_cmts_r.accume_billable_labor_hours,
		  top_act_cmts_r.accume_cmt_raw_cost,
		  top_act_cmts_r.accume_cmt_burdened_cost,
		  top_act_cmts_r.accume_cmt_quantity,
		  top_act_cmts_r.unit_of_measure,
                  x_err_stage,
                  x_err_stack,
                  x_err_code);

        END LOOP; -- FOR top_act_cmts_r IN sel_top_act_cmts

       END IF; -- IF ( pa_adw_collect_main.collect_top_tasks_flag = 'Y')

       -- collect Actuals/Cmts at Project level

       x_err_stage     := 'Collecting Actuals/Cmts  txns at Project level';

       pa_debug.debug(x_err_stage);

       FOR prj_act_cmts_r IN sel_prj_act_cmts(sel_prjs_r.project_id) LOOP
	 pa_debug.debug('Sending for project_id ' || to_char(prj_act_cmts_r.project_id) || ' For Service Type ' || prj_act_cmts_r.service_type_code);


   	 update_prj_act_cmt
		 (prj_act_cmts_r.project_id,
		  prj_act_cmts_r.pa_period_key,
		  prj_act_cmts_r.expense_organization_id,
		  prj_act_cmts_r.owner_organization_id,
		  prj_act_cmts_r.resource_list_member_id,
		  prj_act_cmts_r.service_type_code,
		  prj_act_cmts_r.expenditure_type,
		  prj_act_cmts_r.user_col1,
		  prj_act_cmts_r.user_col2,
		  prj_act_cmts_r.user_col3,
		  prj_act_cmts_r.user_col4,
		  prj_act_cmts_r.user_col5,
		  prj_act_cmts_r.user_col6,
		  prj_act_cmts_r.user_col7,
		  prj_act_cmts_r.user_col8,
		  prj_act_cmts_r.user_col9,
		  prj_act_cmts_r.user_col10,
		  prj_act_cmts_r.accume_revenue,
		  prj_act_cmts_r.accume_raw_cost,
		  prj_act_cmts_r.accume_burdened_cost,
		  prj_act_cmts_r.accume_quantity,
		  prj_act_cmts_r.accume_labor_hours,
		  prj_act_cmts_r.accume_billable_raw_cost,
		  prj_act_cmts_r.accume_billable_burdened_cost,
		  prj_act_cmts_r.accume_billable_quantity,
		  prj_act_cmts_r.accume_billable_labor_hours,
		  prj_act_cmts_r.accume_cmt_raw_cost,
		  prj_act_cmts_r.accume_cmt_burdened_cost,
		  prj_act_cmts_r.accume_cmt_quantity,
		  prj_act_cmts_r.unit_of_measure,
                  x_err_stage,
                  x_err_stack,
                  x_err_code);

       END LOOP; -- FOR prj_act_cmts_r IN sel_prj_act_cmts

       -- Mark the PA_TASK_HISTORY rows which were transferred
       -- Both for Low level task as well as top level tasks

       UPDATE
           PA_TASK_HISTORY PTH
       SET
           ADW_INTERFACE_FLAG = 'Y'
       WHERE
           ADW_NOTIFY_FLAG = 'Y'
       AND PTH.TASK_ID IN
            (SELECT TASK_ID
             FROM PA_RESOURCE_ACCUM_DETAILS
             WHERE ADW_NOTIFY_FLAG = 'S'
             UNION
             SELECT TASK_ID
             FROM PA_TXN_ACCUM
             WHERE ADW_NOTIFY_FLAG = 'S'
             );
       pa_debug.debug('Marked '||TO_CHAR(SQL%ROWCOUNT)||' task rows transferred to interface table');

       UPDATE
           PA_TASK_HISTORY PTH
       SET
           ADW_INTERFACE_FLAG = 'Y'
       WHERE
           ADW_NOTIFY_FLAG = 'Y'
       AND PTH.TASK_ID IN
           (SELECT TOP_TASK_ID FROM PA_TASK_HISTORY PTHT
            WHERE
            PTHT.ADW_NOTIFY_FLAG = 'Y'
            AND PTHT.TASK_ID IN
              (SELECT TASK_ID
               FROM PA_RESOURCE_ACCUM_DETAILS
               WHERE ADW_NOTIFY_FLAG = 'S'
               UNION
               SELECT TASK_ID
               FROM PA_TXN_ACCUM
               WHERE ADW_NOTIFY_FLAG = 'S'
               )
           );
       pa_debug.debug('Marked '||TO_CHAR(SQL%ROWCOUNT)||' top task rows transferred to interface table');

       -- PLEASE NOTE THAT WE ARE UPDATING THE BASE TABLE SINCE THE
       -- PA_ADW_R_ACT_CMT_V IS DEFINED ON MULTIPLE TABLES

       UPDATE
        PA_RESOURCE_ACCUM_DETAILS
       SET
        ADW_NOTIFY_FLAG = 'N'
       WHERE
        ADW_NOTIFY_FLAG = 'S';

       UPDATE
        PA_TXN_ACCUM
       SET
        ADW_NOTIFY_FLAG = 'N'
       WHERE
        ADW_NOTIFY_FLAG = 'S';

      END IF; -- IF (txn_count <> 0 OR res_count <> 0)

      UPDATE PA_TASK_HISTORY PTH
         SET ADW_NOTIFY_FLAG = 'N'
      WHERE
         ADW_NOTIFY_FLAG = 'Y';

      pa_debug.debug('Marked ' || TO_CHAR(SQL%ROWCOUNT) || ' task rows Not transferred to interface table');
      -- Commit the project
      COMMIT;
     END LOOP; -- FOR sel_prjs_r IN sel_prjs

     x_err_stack := x_old_err_stack;

     pa_debug.debug('Completed ' || x_err_stage);

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END get_fact_act_cmts;

   PROCEDURE update_tasks_act_cmt
			 (x_task_id			IN NUMBER,
			  x_pa_period_key		IN VARCHAR2,
			  x_expense_organization_id	IN NUMBER,
			  x_owner_organization_id	IN NUMBER,
			  x_resource_list_member_id	IN NUMBER,
			  x_service_type_code		IN VARCHAR2,
			  x_expenditure_type		IN VARCHAR2,
			  x_user_col1			IN VARCHAR2,
			  x_user_col2			IN VARCHAR2,
			  x_user_col3			IN VARCHAR2,
			  x_user_col4			IN VARCHAR2,
			  x_user_col5			IN VARCHAR2,
			  x_user_col6			IN VARCHAR2,
			  x_user_col7			IN VARCHAR2,
			  x_user_col8			IN VARCHAR2,
			  x_user_col9			IN VARCHAR2,
			  x_user_col10			IN VARCHAR2,
			  x_accume_revenue		IN NUMBER,
			  x_accume_raw_cost		IN NUMBER,
			  x_accume_burdened_cost	IN NUMBER,
			  x_accume_quantity		IN NUMBER,
			  x_accume_labor_hours		IN NUMBER,
			  x_accume_billable_raw_cost	IN NUMBER,
			  x_acc_billable_burdened_cost	IN NUMBER,
			  x_accume_billable_quantity	IN NUMBER,
			  x_accume_billable_labor_hours	IN NUMBER,
			  x_accume_cmt_raw_cost		IN NUMBER,
			  x_accume_cmt_burdened_cost	IN NUMBER,
			  x_accume_cmt_quantity		IN NUMBER,
			  x_unit_of_measure		IN VARCHAR2,
                          x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_stack                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code                    IN OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
   IS
        x_old_err_stack	VARCHAR2(1024);
   BEGIN
        x_err_code      := 0;
        x_err_stage     := 'Creating Task Level Actuals and Commitments Table';
        x_old_err_stack := x_err_stack;
        x_err_stack     := x_err_stack || '-> update_tasks_act_cmt';

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_TSK_ACT_CMT_IT
        SET
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  USER_COL6 = X_USER_COL6,
	  USER_COL7 = X_USER_COL7,
	  USER_COL8 = X_USER_COL8,
	  USER_COL9 = X_USER_COL9,
	  USER_COL10 = X_USER_COL10,
	  ACCUME_REVENUE = X_ACCUME_REVENUE,
	  ACCUME_RAW_COST = X_ACCUME_RAW_COST,
	  ACCUME_BURDENED_COST = X_ACCUME_BURDENED_COST,
	  ACCUME_QUANTITY = X_ACCUME_QUANTITY,
	  ACCUME_LABOR_HOURS = X_ACCUME_LABOR_HOURS,
	  ACCUME_BILLABLE_RAW_COST = X_ACCUME_BILLABLE_RAW_COST,
	  ACCUME_BILLABLE_BURDENED_COST = X_ACC_BILLABLE_BURDENED_COST,
	  ACCUME_BILLABLE_QUANTITY = X_ACCUME_BILLABLE_QUANTITY,
	  ACCUME_BILLABLE_LABOR_HOURS = X_ACCUME_BILLABLE_LABOR_HOURS,
	  ACCUME_CMT_RAW_COST = X_ACCUME_CMT_RAW_COST,
	  ACCUME_CMT_BURDENED_COST = X_ACCUME_CMT_BURDENED_COST,
	  ACCUME_CMT_QUANTITY = X_ACCUME_CMT_QUANTITY,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
	  TASK_ID = X_TASK_ID
	AND PA_PERIOD_KEY = X_PA_PERIOD_KEY
	AND NVL(EXPENSE_ORGANIZATION_ID,-99) = NVL(X_EXPENSE_ORGANIZATION_ID,-99)
	AND NVL(OWNER_ORGANIZATION_ID,-99) = NVL(X_OWNER_ORGANIZATION_ID,-99)
	AND NVL(RESOURCE_LIST_MEMBER_ID,-99) = NVL(X_RESOURCE_LIST_MEMBER_ID,-99)
	AND NVL(SERVICE_TYPE_CODE,'X') = NVL(X_SERVICE_TYPE_CODE,'X')
	AND NVL(EXPENDITURE_TYPE,'X') = NVL(X_EXPENDITURE_TYPE,'X')
	AND NVL(USER_COL1,'X') = NVL(X_USER_COL1,'X')
	AND NVL(USER_COL2,'X') = NVL(X_USER_COL2,'X')
	AND NVL(USER_COL3,'X') = NVL(X_USER_COL3,'X')
	AND NVL(USER_COL4,'X') = NVL(X_USER_COL4,'X')
	AND NVL(USER_COL5,'X') = NVL(X_USER_COL5,'X')
	AND NVL(UNIT_OF_MEASURE,'X') = NVL(X_UNIT_OF_MEASURE,'X');

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN

	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_TSK_ACT_CMT_IT
          (
	    TASK_ACT_CMT_KEY,
	    TASK_ID,
	    PA_PERIOD_KEY,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    EXPENSE_ORGANIZATION_ID,
	    OWNER_ORGANIZATION_ID,
	    RESOURCE_LIST_MEMBER_ID,
	    SERVICE_TYPE_CODE,
	    EXPENDITURE_TYPE,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    ACCUME_REVENUE,
	    ACCUME_RAW_COST,
	    ACCUME_BURDENED_COST,
	    ACCUME_QUANTITY,
	    ACCUME_LABOR_HOURS,
	    ACCUME_BILLABLE_RAW_COST,
	    ACCUME_BILLABLE_BURDENED_COST,
	    ACCUME_BILLABLE_QUANTITY,
	    ACCUME_BILLABLE_LABOR_HOURS,
	    ACCUME_CMT_RAW_COST,
	    ACCUME_CMT_BURDENED_COST,
	    ACCUME_CMT_QUANTITY,
	    UNIT_OF_MEASURE,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    X_TASK_ID || '-' || X_PA_PERIOD_KEY || '-' ||        --
	    NVL(X_EXPENSE_ORGANIZATION_ID,-99) || '-' ||     --|
	    NVL(X_OWNER_ORGANIZATION_ID,-99)||  '-' ||       --|
	    NVL(X_RESOURCE_LIST_MEMBER_ID,-99)||  '-' ||     --|
	    NVL(X_SERVICE_TYPE_CODE,'X')||  '-' ||           --| Dimension Keys
	    NVL(X_EXPENDITURE_TYPE,'X')||  '-' ||            --|
	    NVL(X_USER_COL1,'X')||  '-' ||                   --|
	    NVL(X_USER_COL2,'X')||  '-' ||                   --|
	    NVL(X_USER_COL3,'X')||  '-' ||                   --|
	    NVL(X_USER_COL4,'X')||  '-' ||                   --|
	    NVL(X_USER_COL5,'X'),                            --
	    X_TASK_ID,
	    X_PA_PERIOD_KEY,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    X_EXPENSE_ORGANIZATION_ID,
	    X_OWNER_ORGANIZATION_ID,
	    X_RESOURCE_LIST_MEMBER_ID,
	    X_SERVICE_TYPE_CODE,
	    X_EXPENDITURE_TYPE,
	    X_USER_COL1,
	    X_USER_COL2,
	    X_USER_COL3,
	    X_USER_COL4,
	    X_USER_COL5,
	    X_USER_COL6,
	    X_USER_COL7,
	    X_USER_COL8,
	    X_USER_COL9,
	    X_USER_COL10,
	    X_ACCUME_REVENUE,
	    X_ACCUME_RAW_COST,
	    X_ACCUME_BURDENED_COST,
	    X_ACCUME_QUANTITY,
	    X_ACCUME_LABOR_HOURS,
	    X_ACCUME_BILLABLE_RAW_COST,
	    X_ACC_BILLABLE_BURDENED_COST,
	    X_ACCUME_BILLABLE_QUANTITY,
	    X_ACCUME_BILLABLE_LABOR_HOURS,
	    X_ACCUME_CMT_RAW_COST,
	    X_ACCUME_CMT_BURDENED_COST,
	    X_ACCUME_CMT_QUANTITY,
	    X_UNIT_OF_MEASURE,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

        x_err_stack := x_old_err_stack;

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END update_tasks_act_cmt;

   -- Update the project level numbers

   PROCEDURE update_prj_act_cmt
			 (x_project_id			IN NUMBER,
			  x_pa_period_key		IN VARCHAR2,
			  x_expense_organization_id	IN NUMBER,
			  x_owner_organization_id	IN NUMBER,
			  x_resource_list_member_id	IN NUMBER,
			  x_service_type_code		IN VARCHAR2,
			  x_expenditure_type		IN VARCHAR2,
			  x_user_col1			IN VARCHAR2,
			  x_user_col2			IN VARCHAR2,
			  x_user_col3			IN VARCHAR2,
			  x_user_col4			IN VARCHAR2,
			  x_user_col5			IN VARCHAR2,
			  x_user_col6			IN VARCHAR2,
			  x_user_col7			IN VARCHAR2,
			  x_user_col8			IN VARCHAR2,
			  x_user_col9			IN VARCHAR2,
			  x_user_col10			IN VARCHAR2,
			  x_accume_revenue		IN NUMBER,
			  x_accume_raw_cost		IN NUMBER,
			  x_accume_burdened_cost	IN NUMBER,
			  x_accume_quantity		IN NUMBER,
			  x_accume_labor_hours		IN NUMBER,
			  x_accume_billable_raw_cost	IN NUMBER,
			  x_acc_billable_burdened_cost	IN NUMBER,
			  x_accume_billable_quantity	IN NUMBER,
			  x_accume_billable_labor_hours	IN NUMBER,
			  x_accume_cmt_raw_cost		IN NUMBER,
			  x_accume_cmt_burdened_cost	IN NUMBER,
			  x_accume_cmt_quantity		IN NUMBER,
			  x_unit_of_measure		IN VARCHAR2,
                          x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_stack                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code                    IN OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
   IS
        x_old_err_stack	VARCHAR2(1024);
   BEGIN
        x_err_code      := 0;
        x_err_stage     := 'Creating Project Level Actuals and Commitments Table';
        x_old_err_stack := x_err_stack;
        x_err_stack     := x_err_stack || '-> update_prj_act_cmt';

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_PRJ_ACT_CMT_IT
        SET
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  USER_COL6 = X_USER_COL6,
	  USER_COL7 = X_USER_COL7,
	  USER_COL8 = X_USER_COL8,
	  USER_COL9 = X_USER_COL9,
	  USER_COL10 = X_USER_COL10,
	  ACCUME_REVENUE = X_ACCUME_REVENUE,
	  ACCUME_RAW_COST = X_ACCUME_RAW_COST,
	  ACCUME_BURDENED_COST = X_ACCUME_BURDENED_COST,
	  ACCUME_QUANTITY = X_ACCUME_QUANTITY,
	  ACCUME_LABOR_HOURS = X_ACCUME_LABOR_HOURS,
	  ACCUME_BILLABLE_RAW_COST = X_ACCUME_BILLABLE_RAW_COST,
	  ACCUME_BILLABLE_BURDENED_COST = X_ACC_BILLABLE_BURDENED_COST,
	  ACCUME_BILLABLE_QUANTITY = X_ACCUME_BILLABLE_QUANTITY,
	  ACCUME_BILLABLE_LABOR_HOURS = X_ACCUME_BILLABLE_LABOR_HOURS,
	  ACCUME_CMT_RAW_COST = X_ACCUME_CMT_RAW_COST,
	  ACCUME_CMT_BURDENED_COST = X_ACCUME_CMT_BURDENED_COST,
	  ACCUME_CMT_QUANTITY = X_ACCUME_CMT_QUANTITY,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
	  PROJECT_ID = X_PROJECT_ID
	AND PA_PERIOD_KEY = X_PA_PERIOD_KEY
	AND NVL(EXPENSE_ORGANIZATION_ID,-99) = NVL(X_EXPENSE_ORGANIZATION_ID,-99)
	AND NVL(OWNER_ORGANIZATION_ID,-99) = NVL(X_OWNER_ORGANIZATION_ID,-99)
	AND NVL(RESOURCE_LIST_MEMBER_ID,-99) = NVL(X_RESOURCE_LIST_MEMBER_ID,-99)
	AND NVL(SERVICE_TYPE_CODE,'X') = NVL(X_SERVICE_TYPE_CODE,'X')
	AND NVL(EXPENDITURE_TYPE,'X') = NVL(X_EXPENDITURE_TYPE,'X')
	AND NVL(USER_COL1,'X') = NVL(X_USER_COL1,'X')
	AND NVL(USER_COL2,'X') = NVL(X_USER_COL2,'X')
	AND NVL(USER_COL3,'X') = NVL(X_USER_COL3,'X')
	AND NVL(USER_COL4,'X') = NVL(X_USER_COL4,'X')
	AND NVL(USER_COL5,'X') = NVL(X_USER_COL5,'X')
	AND NVL(UNIT_OF_MEASURE,'X') = NVL(X_UNIT_OF_MEASURE,'X');

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN
	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_PRJ_ACT_CMT_IT
          (
	    PRJ_ACT_CMT_KEY,
	    PROJECT_ID,
	    PA_PERIOD_KEY,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    EXPENSE_ORGANIZATION_ID,
	    OWNER_ORGANIZATION_ID,
	    RESOURCE_LIST_MEMBER_ID,
	    SERVICE_TYPE_CODE,
	    EXPENDITURE_TYPE,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    ACCUME_REVENUE,
	    ACCUME_RAW_COST,
	    ACCUME_BURDENED_COST,
	    ACCUME_QUANTITY,
	    ACCUME_LABOR_HOURS,
	    ACCUME_BILLABLE_RAW_COST,
	    ACCUME_BILLABLE_BURDENED_COST,
	    ACCUME_BILLABLE_QUANTITY,
	    ACCUME_BILLABLE_LABOR_HOURS,
	    ACCUME_CMT_RAW_COST,
	    ACCUME_CMT_BURDENED_COST,
	    ACCUME_CMT_QUANTITY,
	    UNIT_OF_MEASURE,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    X_PROJECT_ID || '-' || X_PA_PERIOD_KEY || '-' ||     --
	    NVL(X_EXPENSE_ORGANIZATION_ID,-99) || '-' ||     --|
	    NVL(X_OWNER_ORGANIZATION_ID,-99)||  '-' ||       --|
	    NVL(X_RESOURCE_LIST_MEMBER_ID,-99)||  '-' ||     --|
	    NVL(X_SERVICE_TYPE_CODE,'X')||  '-' ||           --| Dimension Keys
	    NVL(X_EXPENDITURE_TYPE,'X')||  '-' ||            --|
	    NVL(X_USER_COL1,'X')||  '-' ||                   --|
	    NVL(X_USER_COL2,'X')||  '-' ||                   --|
	    NVL(X_USER_COL3,'X')||  '-' ||                   --|
	    NVL(X_USER_COL4,'X')||  '-' ||                   --|
	    NVL(X_USER_COL5,'X'),                            --
	    X_PROJECT_ID,
	    X_PA_PERIOD_KEY,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    X_EXPENSE_ORGANIZATION_ID,
	    X_OWNER_ORGANIZATION_ID,
	    X_RESOURCE_LIST_MEMBER_ID,
	    X_SERVICE_TYPE_CODE,
	    X_EXPENDITURE_TYPE,
	    X_USER_COL1,
	    X_USER_COL2,
	    X_USER_COL3,
	    X_USER_COL4,
	    X_USER_COL5,
	    X_USER_COL6,
	    X_USER_COL7,
	    X_USER_COL8,
	    X_USER_COL9,
	    X_USER_COL10,
	    X_ACCUME_REVENUE,
	    X_ACCUME_RAW_COST,
	    X_ACCUME_BURDENED_COST,
	    X_ACCUME_QUANTITY,
	    X_ACCUME_LABOR_HOURS,
	    X_ACCUME_BILLABLE_RAW_COST,
	    X_ACC_BILLABLE_BURDENED_COST,
	    X_ACCUME_BILLABLE_QUANTITY,
	    X_ACCUME_BILLABLE_LABOR_HOURS,
	    X_ACCUME_CMT_RAW_COST,
	    X_ACCUME_CMT_BURDENED_COST,
	    X_ACCUME_CMT_QUANTITY,
	    X_UNIT_OF_MEASURE,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

        x_err_stack := x_old_err_stack;

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END update_prj_act_cmt;

   -- Procedure to collect budgets

   PROCEDURE get_fact_budgets
			( x_project_num_from     IN     VARCHAR2,
			  x_project_num_to       IN     VARCHAR2,
			  x_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_stack            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code             IN OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
   IS

     -- Cursor for refreshing budgets at lowest level of task

     CURSOR sel_ref_lowest_budgets(x_project_id NUMBER) IS
     SELECT
        PBGT.TASK_ID,
        PBGT.PA_PERIOD_KEY,
        PBGT.BUDGET_TYPE_CODE,
        PBGT.RESOURCE_LIST_MEMBER_ID,
        PBGT.SERVICE_TYPE_CODE,
        PBGT.OWNER_ORGANIZATION_ID,
        PBGT.EXPENDITURE_TYPE,
        PBGT.USER_COL1,
        PBGT.USER_COL2,
        PBGT.USER_COL3,
        PBGT.USER_COL4,
        PBGT.USER_COL5,
        SUM(PBGT.USER_COL6) USER_COL6,
        SUM(PBGT.USER_COL7) USER_COL7,
        SUM(PBGT.USER_COL8) USER_COL8,
        SUM(PBGT.USER_COL9) USER_COL9,
        SUM(PBGT.USER_COL10) USER_COL10,
        SUM(PBGT.BGT_RAW_COST) BGT_RAW_COST,
        SUM(PBGT.BGT_BURDENED_COST) BGT_BURDENED_COST,
        SUM(PBGT.BGT_REVENUE) BGT_REVENUE,
        SUM(PBGT.BGT_QUANTITY) BGT_QUANTITY,
        SUM(PBGT.BGT_LABOR_QUANTITY) BGT_LABOR_QUANTITY,
        PBGT.BGT_UNIT_OF_MEASURE
     FROM
        PA_ADW_R_BGT_LINES_V PBGT,
	PA_ADW_LOWEST_TASKS_V PT
     WHERE
        PBGT.TASK_ID = PT.TASK_ID
     AND PBGT.PROJECT_ID = x_project_id
     -- Exclude the tasks which are top tasks
     AND PT.TASK_ID <> PT.TOP_TASK_ID
     AND PBGT.ADW_NOTIFY_FLAG = 'R'
     GROUP BY
        PBGT.TASK_ID,
        PBGT.PA_PERIOD_KEY,
        PBGT.BUDGET_TYPE_CODE,
        PBGT.RESOURCE_LIST_MEMBER_ID,
        PBGT.SERVICE_TYPE_CODE,
        PBGT.OWNER_ORGANIZATION_ID,
        PBGT.EXPENDITURE_TYPE,
        PBGT.USER_COL1,
        PBGT.USER_COL2,
        PBGT.USER_COL3,
        PBGT.USER_COL4,
        PBGT.USER_COL5,
        PBGT.BGT_UNIT_OF_MEASURE;

     -- Cursor for refreshing budgets at top level of task

     CURSOR sel_ref_top_budgets(x_project_id NUMBER) IS
     SELECT
        PBGT.TOP_TASK_ID,
        PBGT.PA_PERIOD_KEY,
        PBGT.BUDGET_TYPE_CODE,
        PBGT.RESOURCE_LIST_MEMBER_ID,
        PBGT.SERVICE_TYPE_CODE,
        PBGT.OWNER_ORGANIZATION_ID,
        PBGT.EXPENDITURE_TYPE,
        PBGT.USER_COL1,
        PBGT.USER_COL2,
        PBGT.USER_COL3,
        PBGT.USER_COL4,
        PBGT.USER_COL5,
        SUM(PBGT.USER_COL6) USER_COL6,
        SUM(PBGT.USER_COL7) USER_COL7,
        SUM(PBGT.USER_COL8) USER_COL8,
        SUM(PBGT.USER_COL9) USER_COL9,
        SUM(PBGT.USER_COL10) USER_COL10,
        SUM(PBGT.BGT_RAW_COST) BGT_RAW_COST,
        SUM(PBGT.BGT_BURDENED_COST) BGT_BURDENED_COST,
        SUM(PBGT.BGT_REVENUE) BGT_REVENUE,
        SUM(PBGT.BGT_QUANTITY) BGT_QUANTITY,
        SUM(PBGT.BGT_LABOR_QUANTITY) BGT_LABOR_QUANTITY,
        PBGT.BGT_UNIT_OF_MEASURE
     FROM
        PA_ADW_R_BGT_LINES_V PBGT,
	PA_ADW_TOP_TASKS_V PT
     WHERE
        PBGT.TOP_TASK_ID = PT.TOP_TASK_ID
     AND PBGT.PROJECT_ID = x_project_id
     AND PBGT.ADW_NOTIFY_FLAG = 'R'
     GROUP BY
        PBGT.TOP_TASK_ID,
        PBGT.PA_PERIOD_KEY,
        PBGT.BUDGET_TYPE_CODE,
        PBGT.RESOURCE_LIST_MEMBER_ID,
        PBGT.SERVICE_TYPE_CODE,
        PBGT.OWNER_ORGANIZATION_ID,
        PBGT.EXPENDITURE_TYPE,
        PBGT.USER_COL1,
        PBGT.USER_COL2,
        PBGT.USER_COL3,
        PBGT.USER_COL4,
        PBGT.USER_COL5,
        PBGT.BGT_UNIT_OF_MEASURE;

     -- Cursor for refreshing budgets at project level

     CURSOR sel_ref_prj_budgets(x_project_id NUMBER) IS
     SELECT
        PBGT.PROJECT_ID,
        PBGT.PA_PERIOD_KEY,
        PBGT.BUDGET_TYPE_CODE,
        PBGT.RESOURCE_LIST_MEMBER_ID,
        PBGT.SERVICE_TYPE_CODE,
        PBGT.OWNER_ORGANIZATION_ID,
        PBGT.EXPENDITURE_TYPE,
        PBGT.USER_COL1,
        PBGT.USER_COL2,
        PBGT.USER_COL3,
        PBGT.USER_COL4,
        PBGT.USER_COL5,
        SUM(PBGT.USER_COL6) USER_COL6,
        SUM(PBGT.USER_COL7) USER_COL7,
        SUM(PBGT.USER_COL8) USER_COL8,
        SUM(PBGT.USER_COL9) USER_COL9,
        SUM(PBGT.USER_COL10) USER_COL10,
        SUM(PBGT.BGT_RAW_COST) BGT_RAW_COST,
        SUM(PBGT.BGT_BURDENED_COST) BGT_BURDENED_COST,
        SUM(PBGT.BGT_REVENUE) BGT_REVENUE,
        SUM(PBGT.BGT_QUANTITY) BGT_QUANTITY,
        SUM(PBGT.BGT_LABOR_QUANTITY) BGT_LABOR_QUANTITY,
        PBGT.BGT_UNIT_OF_MEASURE
     FROM
        PA_ADW_R_BGT_LINES_V PBGT,
	PA_ADW_PROJECTS_V PP
     WHERE
        PBGT.PROJECT_ID = PP.PROJECT_ID
     AND PBGT.PROJECT_ID = x_project_id
     AND PBGT.ADW_NOTIFY_FLAG = 'R'
     GROUP BY
        PBGT.PROJECT_ID,
        PBGT.PA_PERIOD_KEY,
        PBGT.BUDGET_TYPE_CODE,
        PBGT.RESOURCE_LIST_MEMBER_ID,
        PBGT.SERVICE_TYPE_CODE,
        PBGT.OWNER_ORGANIZATION_ID,
        PBGT.EXPENDITURE_TYPE,
        PBGT.USER_COL1,
        PBGT.USER_COL2,
        PBGT.USER_COL3,
        PBGT.USER_COL4,
        PBGT.USER_COL5,
        PBGT.BGT_UNIT_OF_MEASURE;

     -- Define Cursor for selecting budgets at lowest level of task.

     CURSOR sel_lowest_budgets(x_project_id NUMBER) IS
     SELECT
        PBGT.TASK_ID,
        PBGT.PA_PERIOD_KEY,
        PBGT.BUDGET_TYPE_CODE,
        PBGT.RESOURCE_LIST_MEMBER_ID,
        PBGT.SERVICE_TYPE_CODE,
        PBGT.OWNER_ORGANIZATION_ID,
        PBGT.EXPENDITURE_TYPE,
        PBGT.USER_COL1,
        PBGT.USER_COL2,
        PBGT.USER_COL3,
        PBGT.USER_COL4,
        PBGT.USER_COL5,
        SUM(PBGT.USER_COL6) USER_COL6,
        SUM(PBGT.USER_COL7) USER_COL7,
        SUM(PBGT.USER_COL8) USER_COL8,
        SUM(PBGT.USER_COL9) USER_COL9,
        SUM(PBGT.USER_COL10) USER_COL10,
        SUM(PBGT.BGT_RAW_COST) BGT_RAW_COST,
        SUM(PBGT.BGT_BURDENED_COST) BGT_BURDENED_COST,
        SUM(PBGT.BGT_REVENUE) BGT_REVENUE,
        SUM(PBGT.BGT_QUANTITY) BGT_QUANTITY,
        SUM(PBGT.BGT_LABOR_QUANTITY) BGT_LABOR_QUANTITY,
        PBGT.BGT_UNIT_OF_MEASURE
     FROM
        PA_ADW_BGT_LINES_V PBGT,
	PA_ADW_LOWEST_TASKS_V PT
     WHERE
        PBGT.TASK_ID = PT.TASK_ID
     -- Exclude the tasks which are top tasks
     AND PT.TASK_ID <> PT.TOP_TASK_ID
     AND PBGT.PROJECT_ID = x_project_id
     AND PBGT.ADW_NOTIFY_FLAG = 'S'
     GROUP BY
        PBGT.TASK_ID,
        PBGT.PA_PERIOD_KEY,
        PBGT.BUDGET_TYPE_CODE,
        PBGT.RESOURCE_LIST_MEMBER_ID,
        PBGT.SERVICE_TYPE_CODE,
        PBGT.OWNER_ORGANIZATION_ID,
        PBGT.EXPENDITURE_TYPE,
        PBGT.USER_COL1,
        PBGT.USER_COL2,
        PBGT.USER_COL3,
        PBGT.USER_COL4,
        PBGT.USER_COL5,
        PBGT.BGT_UNIT_OF_MEASURE;

     -- Define Cursor for selecting budgets at top level of task.

     CURSOR sel_top_budgets(x_project_id NUMBER) IS
     SELECT
        PBGT.TOP_TASK_ID,
        PBGT.PA_PERIOD_KEY,
        PBGT.BUDGET_TYPE_CODE,
        PBGT.RESOURCE_LIST_MEMBER_ID,
        PBGT.SERVICE_TYPE_CODE,
        PBGT.OWNER_ORGANIZATION_ID,
        PBGT.EXPENDITURE_TYPE,
        PBGT.USER_COL1,
        PBGT.USER_COL2,
        PBGT.USER_COL3,
        PBGT.USER_COL4,
        PBGT.USER_COL5,
        SUM(PBGT.USER_COL6) USER_COL6,
        SUM(PBGT.USER_COL7) USER_COL7,
        SUM(PBGT.USER_COL8) USER_COL8,
        SUM(PBGT.USER_COL9) USER_COL9,
        SUM(PBGT.USER_COL10) USER_COL10,
        SUM(PBGT.BGT_RAW_COST) BGT_RAW_COST,
        SUM(PBGT.BGT_BURDENED_COST) BGT_BURDENED_COST,
        SUM(PBGT.BGT_REVENUE) BGT_REVENUE,
        SUM(PBGT.BGT_QUANTITY) BGT_QUANTITY,
        SUM(PBGT.BGT_LABOR_QUANTITY) BGT_LABOR_QUANTITY,
        PBGT.BGT_UNIT_OF_MEASURE
     FROM
        PA_ADW_BGT_LINES_V PBGT,
	PA_ADW_TOP_TASKS_V PT
     WHERE
        PBGT.TOP_TASK_ID = PT.TOP_TASK_ID
     AND PBGT.PROJECT_ID = x_project_id
     AND PBGT.ADW_NOTIFY_FLAG = 'S'
     GROUP BY
        PBGT.TOP_TASK_ID,
        PBGT.PA_PERIOD_KEY,
        PBGT.BUDGET_TYPE_CODE,
        PBGT.RESOURCE_LIST_MEMBER_ID,
        PBGT.SERVICE_TYPE_CODE,
        PBGT.OWNER_ORGANIZATION_ID,
        PBGT.EXPENDITURE_TYPE,
        PBGT.USER_COL1,
        PBGT.USER_COL2,
        PBGT.USER_COL3,
        PBGT.USER_COL4,
        PBGT.USER_COL5,
        PBGT.BGT_UNIT_OF_MEASURE;

     -- Define Cursor for selecting budgets at project level.

     CURSOR sel_prj_budgets(x_project_id NUMBER) IS
     SELECT
        PBGT.PROJECT_ID,
        PBGT.PA_PERIOD_KEY,
        PBGT.BUDGET_TYPE_CODE,
        PBGT.RESOURCE_LIST_MEMBER_ID,
        PBGT.SERVICE_TYPE_CODE,
        PBGT.OWNER_ORGANIZATION_ID,
        PBGT.EXPENDITURE_TYPE,
        PBGT.USER_COL1,
        PBGT.USER_COL2,
        PBGT.USER_COL3,
        PBGT.USER_COL4,
        PBGT.USER_COL5,
        SUM(PBGT.USER_COL6) USER_COL6,
        SUM(PBGT.USER_COL7) USER_COL7,
        SUM(PBGT.USER_COL8) USER_COL8,
        SUM(PBGT.USER_COL9) USER_COL9,
        SUM(PBGT.USER_COL10) USER_COL10,
        SUM(PBGT.BGT_RAW_COST) BGT_RAW_COST,
        SUM(PBGT.BGT_BURDENED_COST) BGT_BURDENED_COST,
        SUM(PBGT.BGT_REVENUE) BGT_REVENUE,
        SUM(PBGT.BGT_QUANTITY) BGT_QUANTITY,
        SUM(PBGT.BGT_LABOR_QUANTITY) BGT_LABOR_QUANTITY,
        PBGT.BGT_UNIT_OF_MEASURE
     FROM
        PA_ADW_BGT_LINES_V PBGT,
	PA_ADW_PROJECTS_V PP
     WHERE
        PBGT.PROJECT_ID = PP.PROJECT_ID
     AND PBGT.PROJECT_ID = x_project_id
     AND PBGT.ADW_NOTIFY_FLAG = 'S'
     GROUP BY
        PBGT.PROJECT_ID,
        PBGT.PA_PERIOD_KEY,
        PBGT.BUDGET_TYPE_CODE,
        PBGT.RESOURCE_LIST_MEMBER_ID,
        PBGT.SERVICE_TYPE_CODE,
        PBGT.OWNER_ORGANIZATION_ID,
        PBGT.EXPENDITURE_TYPE,
        PBGT.USER_COL1,
        PBGT.USER_COL2,
        PBGT.USER_COL3,
        PBGT.USER_COL4,
        PBGT.USER_COL5,
        PBGT.BGT_UNIT_OF_MEASURE;

     -- Cursor for selecting projects for processing

     CURSOR sel_prjs IS
     SELECT
	PROJECT_ID,
        SEGMENT1
     FROM
	PA_ADW_PROJECTS_V
     WHERE segment1 BETWEEN NVL(x_project_num_from,segment1)
                          AND NVL(x_project_num_to,segment1);

     -- define procedure variables

     ref_lowest_budgets_r  sel_ref_lowest_budgets%ROWTYPE;
     ref_top_budgets_r     sel_ref_top_budgets%ROWTYPE;
     ref_prj_budgets_r     sel_ref_prj_budgets%ROWTYPE;

     lowest_budgets_r      sel_lowest_budgets%ROWTYPE;
     top_budgets_r         sel_top_budgets%ROWTYPE;
     prj_budgets_r         sel_prj_budgets%ROWTYPE;

     sel_prjs_r             sel_prjs%ROWTYPE;

     x_old_err_stack	    VARCHAR2(1024);


   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Collecting Budgets';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_fact_budgets';

     pa_debug.debug(x_err_stage);

     -- Process all projects one one by one

     FOR sel_prjs_r IN sel_prjs LOOP

      pa_debug.debug('Processing Budgets For Project ' || sel_prjs_r.segment1);

      -- First mark all the budgets need to be transferred
      -- We will transfer the latest baselined budget only

      UPDATE
        PA_BUDGET_VERSIONS PBV
      SET
        ADW_NOTIFY_FLAG = 'S'
      WHERE
        PROJECT_ID = SEL_PRJS_R.PROJECT_ID
      AND CURRENT_FLAG = 'Y'
      AND ADW_NOTIFY_FLAG = 'Y'
      AND EXISTS
          ( SELECT 'Yes'
            FROM
                 PA_ADW_BGT_TYPES_V PBT
            WHERE PBT.BUDGET_TYPE_CODE = PBV.BUDGET_TYPE_CODE
          );

      IF ( SQL%ROWCOUNT <> 0 ) THEN

       -- Mark those budgets for refresh for which new version of the budgets
       -- were created. Only those budgets will be refreshed which were sent
       -- earlier

       UPDATE
        PA_BUDGET_VERSIONS
       SET
        ADW_NOTIFY_FLAG = 'R'
       WHERE
        PROJECT_ID = sel_prjs_r.project_id
       AND (BUDGET_TYPE_CODE,VERSION_NUMBER) IN
          ( SELECT
                BUDGET_TYPE_CODE,
                MAX(VERSION_NUMBER)
            FROM
                PA_BUDGET_VERSIONS OB
            WHERE
                OB.PROJECT_ID = sel_prjs_r.project_id
            AND BUDGET_TYPE_CODE IN
                ( SELECT
                       BUDGET_TYPE_CODE
                  FROM
                       PA_ADW_BGT_TYPES_V
                )
            AND OB.ADW_NOTIFY_FLAG = 'N'
            AND EXISTS
            -- Check if a new budget was baselined, since the time the this budget was sent
                ( SELECT
                      'YES'
                  FROM
                      PA_BUDGET_VERSIONS NB
 		  WHERE
		      NB.PROJECT_ID = sel_prjs_r.project_id
		  AND NB.BUDGET_TYPE_CODE = OB.BUDGET_TYPE_CODE
		  AND NB.ADW_NOTIFY_FLAG = 'S'
                )
            GROUP BY
                OB.BUDGET_TYPE_CODE
          );

       -- Check the profile option value for collecting lowest tasks

       IF ( pa_adw_collect_main.collect_lowest_tasks_flag = 'Y') THEN

        -- refreshing Budgets at lowest tasks level

        x_err_stage     := 'Collecting Budgets at lowest task level';

        FOR ref_lowest_budgets_r IN sel_ref_lowest_budgets(sel_prjs_r.project_id) LOOP

   	 update_tasks_budgets
		 (ref_lowest_budgets_r.task_id,
		  ref_lowest_budgets_r.pa_period_key,
		  ref_lowest_budgets_r.budget_type_code,
		  ref_lowest_budgets_r.resource_list_member_id,
		  ref_lowest_budgets_r.service_type_code,
		  ref_lowest_budgets_r.owner_organization_id,
		  ref_lowest_budgets_r.expenditure_type,
		  ref_lowest_budgets_r.user_col1,
		  ref_lowest_budgets_r.user_col2,
		  ref_lowest_budgets_r.user_col3,
		  ref_lowest_budgets_r.user_col4,
		  ref_lowest_budgets_r.user_col5,
		  ref_lowest_budgets_r.user_col6,
		  ref_lowest_budgets_r.user_col7,
		  ref_lowest_budgets_r.user_col8,
		  ref_lowest_budgets_r.user_col9,
		  ref_lowest_budgets_r.user_col10,
		  ref_lowest_budgets_r.bgt_revenue,
		  ref_lowest_budgets_r.bgt_raw_cost,
		  ref_lowest_budgets_r.bgt_burdened_cost,
		  ref_lowest_budgets_r.bgt_quantity,
		  ref_lowest_budgets_r.bgt_labor_quantity,
		  ref_lowest_budgets_r.bgt_unit_of_measure,
                  x_err_stage,
                  x_err_stack,
                  x_err_code);

        END LOOP; -- FOR ref_lowest_budgets_r IN sel_ref_lowest_budgets

       END IF; -- IF ( pa_adw_collect_main.collect_lowest_tasks_flag = 'Y')

       -- Check the profile option value for collecting top tasks
       IF ( pa_adw_collect_main.collect_top_tasks_flag = 'Y') THEN

        -- refreshing Budgets at top tasks level

        x_err_stage     := 'Collecting Budgets at top task level';

        FOR ref_top_budgets_r IN sel_ref_top_budgets(sel_prjs_r.project_id) LOOP

   	 update_tasks_budgets
		 (ref_top_budgets_r.top_task_id,
		  ref_top_budgets_r.pa_period_key,
		  ref_top_budgets_r.budget_type_code,
		  ref_top_budgets_r.resource_list_member_id,
		  ref_top_budgets_r.service_type_code,
		  ref_top_budgets_r.owner_organization_id,
		  ref_top_budgets_r.expenditure_type,
		  ref_top_budgets_r.user_col1,
		  ref_top_budgets_r.user_col2,
		  ref_top_budgets_r.user_col3,
		  ref_top_budgets_r.user_col4,
		  ref_top_budgets_r.user_col5,
		  ref_top_budgets_r.user_col6,
		  ref_top_budgets_r.user_col7,
		  ref_top_budgets_r.user_col8,
		  ref_top_budgets_r.user_col9,
		  ref_top_budgets_r.user_col10,
		  ref_top_budgets_r.bgt_revenue,
		  ref_top_budgets_r.bgt_raw_cost,
		  ref_top_budgets_r.bgt_burdened_cost,
		  ref_top_budgets_r.bgt_quantity,
		  ref_top_budgets_r.bgt_labor_quantity,
		  ref_top_budgets_r.bgt_unit_of_measure,
                  x_err_stage,
                  x_err_stack,
                  x_err_code);

        END LOOP; -- FOR ref_top_budgets_r IN sel_ref_top_budgets

       END IF; -- IF ( pa_adw_collect_main.collect_top_tasks_flag = 'Y')

       -- Refreshing Budgets at Project level

       x_err_stage     := 'Refreshing Budgets txns at Project level';

       FOR ref_prj_budgets_r IN sel_ref_prj_budgets(sel_prjs_r.project_id) LOOP

   	 update_prj_budgets
		 (ref_prj_budgets_r.project_id,
		  ref_prj_budgets_r.pa_period_key,
		  ref_prj_budgets_r.budget_type_code,
		  ref_prj_budgets_r.resource_list_member_id,
		  ref_prj_budgets_r.service_type_code,
		  ref_prj_budgets_r.owner_organization_id,
		  ref_prj_budgets_r.expenditure_type,
		  ref_prj_budgets_r.user_col1,
		  ref_prj_budgets_r.user_col2,
		  ref_prj_budgets_r.user_col3,
		  ref_prj_budgets_r.user_col4,
		  ref_prj_budgets_r.user_col5,
		  ref_prj_budgets_r.user_col6,
		  ref_prj_budgets_r.user_col7,
		  ref_prj_budgets_r.user_col8,
		  ref_prj_budgets_r.user_col9,
		  ref_prj_budgets_r.user_col10,
		  ref_prj_budgets_r.bgt_revenue,
		  ref_prj_budgets_r.bgt_raw_cost,
		  ref_prj_budgets_r.bgt_burdened_cost,
		  ref_prj_budgets_r.bgt_quantity,
		  ref_prj_budgets_r.bgt_labor_quantity,
		  ref_prj_budgets_r.bgt_unit_of_measure,
                  x_err_stage,
                  x_err_stack,
                  x_err_code);

       END LOOP; -- FOR ref_prj_budgets_r IN sel_ref_prj_budgets

       -- Budget refresh is complete

       -- Check the profile option value for collecting lowest tasks
       IF ( pa_adw_collect_main.collect_lowest_tasks_flag = 'Y') THEN

        -- Collect Budgets at lowest tasks level

        x_err_stage     := 'Collecting Budgets at lowest task level';

        FOR lowest_budgets_r IN sel_lowest_budgets(sel_prjs_r.project_id) LOOP

   	 update_tasks_budgets
		 (lowest_budgets_r.task_id,
		  lowest_budgets_r.pa_period_key,
		  lowest_budgets_r.budget_type_code,
		  lowest_budgets_r.resource_list_member_id,
		  lowest_budgets_r.service_type_code,
		  lowest_budgets_r.owner_organization_id,
		  lowest_budgets_r.expenditure_type,
		  lowest_budgets_r.user_col1,
		  lowest_budgets_r.user_col2,
		  lowest_budgets_r.user_col3,
		  lowest_budgets_r.user_col4,
		  lowest_budgets_r.user_col5,
		  lowest_budgets_r.user_col6,
		  lowest_budgets_r.user_col7,
		  lowest_budgets_r.user_col8,
		  lowest_budgets_r.user_col9,
		  lowest_budgets_r.user_col10,
		  lowest_budgets_r.bgt_revenue,
		  lowest_budgets_r.bgt_raw_cost,
		  lowest_budgets_r.bgt_burdened_cost,
		  lowest_budgets_r.bgt_quantity,
		  lowest_budgets_r.bgt_labor_quantity,
		  lowest_budgets_r.bgt_unit_of_measure,
                  x_err_stage,
                  x_err_stack,
                  x_err_code);

        END LOOP; -- FOR lowest_budgets_r IN sel_lowest_budgets

       END IF; -- IF ( pa_adw_collect_main.collect_lowest_tasks_flag = 'Y')

       -- Check the profile option value for collecting top tasks
       IF ( pa_adw_collect_main.collect_top_tasks_flag = 'Y') THEN

        -- Collect Budgets at top tasks level

        x_err_stage     := 'Collecting Budgets at top task level';

        FOR top_budgets_r IN sel_top_budgets(sel_prjs_r.project_id) LOOP

   	 update_tasks_budgets
		 (top_budgets_r.top_task_id,
		  top_budgets_r.pa_period_key,
		  top_budgets_r.budget_type_code,
		  top_budgets_r.resource_list_member_id,
		  top_budgets_r.service_type_code,
		  top_budgets_r.owner_organization_id,
		  top_budgets_r.expenditure_type,
		  top_budgets_r.user_col1,
		  top_budgets_r.user_col2,
		  top_budgets_r.user_col3,
		  top_budgets_r.user_col4,
		  top_budgets_r.user_col5,
		  top_budgets_r.user_col6,
		  top_budgets_r.user_col7,
		  top_budgets_r.user_col8,
		  top_budgets_r.user_col9,
		  top_budgets_r.user_col10,
		  top_budgets_r.bgt_revenue,
		  top_budgets_r.bgt_raw_cost,
		  top_budgets_r.bgt_burdened_cost,
		  top_budgets_r.bgt_quantity,
		  top_budgets_r.bgt_labor_quantity,
		  top_budgets_r.bgt_unit_of_measure,
                  x_err_stage,
                  x_err_stack,
                  x_err_code);

        END LOOP; -- FOR top_budgets_r IN sel_top_budgets

       END IF; -- IF ( pa_adw_collect_main.collect_top_tasks_flag = 'Y')

       -- Collect Budgets at Project level

       x_err_stage     := 'Collecting Budgets txns at Project level';

       FOR prj_budgets_r IN sel_prj_budgets(sel_prjs_r.project_id) LOOP

   	update_prj_budgets
		 (prj_budgets_r.project_id,
		  prj_budgets_r.pa_period_key,
		  prj_budgets_r.budget_type_code,
		  prj_budgets_r.resource_list_member_id,
		  prj_budgets_r.service_type_code,
		  prj_budgets_r.owner_organization_id,
		  prj_budgets_r.expenditure_type,
		  prj_budgets_r.user_col1,
		  prj_budgets_r.user_col2,
		  prj_budgets_r.user_col3,
		  prj_budgets_r.user_col4,
		  prj_budgets_r.user_col5,
		  prj_budgets_r.user_col6,
		  prj_budgets_r.user_col7,
		  prj_budgets_r.user_col8,
		  prj_budgets_r.user_col9,
		  prj_budgets_r.user_col10,
		  prj_budgets_r.bgt_revenue,
		  prj_budgets_r.bgt_raw_cost,
		  prj_budgets_r.bgt_burdened_cost,
		  prj_budgets_r.bgt_quantity,
		  prj_budgets_r.bgt_labor_quantity,
		  prj_budgets_r.bgt_unit_of_measure,
                  x_err_stage,
                  x_err_stack,
                  x_err_code);

       END LOOP; -- FOR prj_budgets_r IN sel_prj_budgets

       -- Mark the project types as transferred to Interface table

       -- PLEASE NOTE THAT WE ARE UPDATING THE BASE TABLE SINCE THE
       -- PA_ADW_BUDGETS_V IS DEFINED ON MULTIPLE TABLES

       UPDATE
         PA_BUDGET_VERSIONS
       SET
         ADW_NOTIFY_FLAG = 'N'
       WHERE
         ADW_NOTIFY_FLAG IN ('S','R');

      END IF; --IF (SQL%ROWCOUNT <> 0)
      -- Commit the project
      COMMIT;
     END LOOP; -- FOR sel_prjs_r IN sel_prjs

     x_err_stack := x_old_err_stack;

     pa_debug.debug('Completed ' || x_err_stage);

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END get_fact_budgets;

   PROCEDURE update_tasks_budgets
			 (x_task_id			IN NUMBER,
			  x_pa_period_key		IN VARCHAR2,
			  x_budget_type_code       	IN VARCHAR2,
			  x_resource_list_member_id	IN NUMBER,
			  x_service_type_code		IN VARCHAR2,
			  x_owner_organization_id	IN NUMBER,
			  x_expenditure_type		IN VARCHAR2,
			  x_user_col1			IN VARCHAR2,
			  x_user_col2			IN VARCHAR2,
			  x_user_col3			IN VARCHAR2,
			  x_user_col4			IN VARCHAR2,
			  x_user_col5			IN VARCHAR2,
			  x_user_col6			IN VARCHAR2,
			  x_user_col7			IN VARCHAR2,
			  x_user_col8			IN VARCHAR2,
			  x_user_col9			IN VARCHAR2,
			  x_user_col10			IN VARCHAR2,
			  x_bgt_revenue		        IN NUMBER,
			  x_bgt_raw_cost		IN NUMBER,
			  x_bgt_burdened_cost	        IN NUMBER,
			  x_bgt_quantity		IN NUMBER,
			  x_bgt_labor_quantity		IN NUMBER,
			  x_bgt_unit_of_measure		IN VARCHAR2,
                          x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_stack                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code                    IN OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
   IS
        x_old_err_stack	VARCHAR2(1024);
   BEGIN
        x_err_code      := 0;
        x_err_stage     := 'Creating Task Level Budgets';
        x_old_err_stack := x_err_stack;
        x_err_stack     := x_err_stack || '-> update_tasks_budgets';

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_TSK_BGT_LINES_IT
        SET
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  USER_COL6 = X_USER_COL6,
	  USER_COL7 = X_USER_COL7,
	  USER_COL8 = X_USER_COL8,
	  USER_COL9 = X_USER_COL9,
	  USER_COL10 = X_USER_COL10,
	  BGT_REVENUE = X_BGT_REVENUE,
	  BGT_RAW_COST = X_BGT_RAW_COST,
	  BGT_BURDENED_COST = X_BGT_BURDENED_COST,
	  BGT_QUANTITY = X_BGT_QUANTITY,
	  BGT_LABOR_QUANTITY = X_BGT_LABOR_QUANTITY,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
	  TASK_ID = X_TASK_ID
	AND PA_PERIOD_KEY = X_PA_PERIOD_KEY
	AND BUDGET_TYPE_CODE = X_BUDGET_TYPE_CODE
	AND NVL(RESOURCE_LIST_MEMBER_ID,-99) = NVL(X_RESOURCE_LIST_MEMBER_ID,-99)
	AND NVL(SERVICE_TYPE_CODE,'X') = NVL(X_SERVICE_TYPE_CODE,'X')
	AND NVL(OWNER_ORGANIZATION_ID,-99) = NVL(X_OWNER_ORGANIZATION_ID,-99)
	AND NVL(EXPENDITURE_TYPE,'X') = NVL(X_EXPENDITURE_TYPE,'X')
	AND NVL(USER_COL1,'X') = NVL(X_USER_COL1,'X')
	AND NVL(USER_COL2,'X') = NVL(X_USER_COL2,'X')
	AND NVL(USER_COL3,'X') = NVL(X_USER_COL3,'X')
	AND NVL(USER_COL4,'X') = NVL(X_USER_COL4,'X')
	AND NVL(USER_COL5,'X') = NVL(X_USER_COL5,'X')
	AND NVL(BGT_UNIT_OF_MEASURE,'X') = NVL(X_BGT_UNIT_OF_MEASURE,'X');

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN

	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_TSK_BGT_LINES_IT
          (
	    TASK_BUDGET_LINE_KEY,
	    TASK_ID,
	    PA_PERIOD_KEY,
	    BUDGET_TYPE_CODE,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    RESOURCE_LIST_MEMBER_ID,
	    SERVICE_TYPE_CODE,
	    OWNER_ORGANIZATION_ID,
	    EXPENDITURE_TYPE,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    BGT_REVENUE,
	    BGT_RAW_COST,
	    BGT_BURDENED_COST,
	    BGT_QUANTITY,
	    BGT_LABOR_QUANTITY,
	    BGT_UNIT_OF_MEASURE,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    X_TASK_ID || '-' || X_PA_PERIOD_KEY || '-' ||        --
	    NVL(X_BUDGET_TYPE_CODE,'X') || '-' ||            --|
	    NVL(X_OWNER_ORGANIZATION_ID,-99)||  '-' ||       --|
	    NVL(X_RESOURCE_LIST_MEMBER_ID,-99)||  '-' ||     --|
	    NVL(X_SERVICE_TYPE_CODE,'X')||  '-' ||           --| Dimension Keys
	    NVL(X_EXPENDITURE_TYPE,'X')||  '-' ||            --|
	    NVL(X_USER_COL1,'X')||  '-' ||                   --|
	    NVL(X_USER_COL2,'X')||  '-' ||                   --|
	    NVL(X_USER_COL3,'X')||  '-' ||                   --|
	    NVL(X_USER_COL4,'X')||  '-' ||                   --|
	    NVL(X_USER_COL5,'X'),                            --
	    X_TASK_ID,
	    X_PA_PERIOD_KEY,
	    X_BUDGET_TYPE_CODE,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    X_RESOURCE_LIST_MEMBER_ID,
	    X_SERVICE_TYPE_CODE,
	    X_OWNER_ORGANIZATION_ID,
	    X_EXPENDITURE_TYPE,
	    X_USER_COL1,
	    X_USER_COL2,
	    X_USER_COL3,
	    X_USER_COL4,
	    X_USER_COL5,
	    X_USER_COL6,
	    X_USER_COL7,
	    X_USER_COL8,
	    X_USER_COL9,
	    X_USER_COL10,
	    X_BGT_REVENUE,
	    X_BGT_RAW_COST,
	    X_BGT_BURDENED_COST,
	    X_BGT_QUANTITY,
	    X_BGT_LABOR_QUANTITY,
	    X_BGT_UNIT_OF_MEASURE,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

        x_err_stack := x_old_err_stack;

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END update_tasks_budgets;

   -- Update the project level numbers

   PROCEDURE update_prj_budgets
			 (x_project_id			IN NUMBER,
			  x_pa_period_key		IN VARCHAR2,
			  x_budget_type_code       	IN VARCHAR2,
			  x_resource_list_member_id	IN NUMBER,
			  x_service_type_code		IN VARCHAR2,
			  x_owner_organization_id	IN NUMBER,
			  x_expenditure_type		IN VARCHAR2,
			  x_user_col1			IN VARCHAR2,
			  x_user_col2			IN VARCHAR2,
			  x_user_col3			IN VARCHAR2,
			  x_user_col4			IN VARCHAR2,
			  x_user_col5			IN VARCHAR2,
			  x_user_col6			IN VARCHAR2,
			  x_user_col7			IN VARCHAR2,
			  x_user_col8			IN VARCHAR2,
			  x_user_col9			IN VARCHAR2,
			  x_user_col10			IN VARCHAR2,
			  x_bgt_revenue		        IN NUMBER,
			  x_bgt_raw_cost		IN NUMBER,
			  x_bgt_burdened_cost	        IN NUMBER,
			  x_bgt_quantity		IN NUMBER,
			  x_bgt_labor_quantity		IN NUMBER,
			  x_bgt_unit_of_measure		IN VARCHAR2,
                          x_err_stage                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_stack                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_err_code                    IN OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
   IS
        x_old_err_stack	VARCHAR2(1024);
   BEGIN
        x_err_code      := 0;
        x_err_stage     := 'Creating Project Level Budgets';
        x_old_err_stack := x_err_stack;
        x_err_stack     := x_err_stack || '-> update_prj_budgets';

        -- First Try to Update the Row in the Interface Table

	UPDATE
	  PA_PRJ_BGT_LINES_IT
        SET
	  LAST_UPDATE_DATE = TRUNC(SYSDATE),
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  CREATION_DATE = TRUNC(SYSDATE),
	  CREATED_BY = X_CREATED_BY,
	  USER_COL6 = X_USER_COL6,
	  USER_COL7 = X_USER_COL7,
	  USER_COL8 = X_USER_COL8,
	  USER_COL9 = X_USER_COL9,
	  USER_COL10 = X_USER_COL10,
	  BGT_REVENUE = X_BGT_REVENUE,
	  BGT_RAW_COST = X_BGT_RAW_COST,
	  BGT_BURDENED_COST = X_BGT_BURDENED_COST,
	  BGT_QUANTITY = X_BGT_QUANTITY,
	  BGT_LABOR_QUANTITY = X_BGT_LABOR_QUANTITY,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	  REQUEST_ID = X_REQUEST_ID,
	  PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
	  PROGRAM_ID = X_PROGRAM_ID,
	  PROGRAM_UPDATE_DATE = TRUNC(SYSDATE),
	  STATUS_CODE = 'P'
	WHERE
	  PROJECT_ID = X_PROJECT_ID
	AND PA_PERIOD_KEY = X_PA_PERIOD_KEY
	AND BUDGET_TYPE_CODE = X_BUDGET_TYPE_CODE
	AND NVL(RESOURCE_LIST_MEMBER_ID,-99) = NVL(X_RESOURCE_LIST_MEMBER_ID,-99)
	AND NVL(SERVICE_TYPE_CODE,'X') = NVL(X_SERVICE_TYPE_CODE,'X')
	AND NVL(OWNER_ORGANIZATION_ID,-99) = NVL(X_OWNER_ORGANIZATION_ID,-99)
	AND NVL(EXPENDITURE_TYPE,'X') = NVL(X_EXPENDITURE_TYPE,'X')
	AND NVL(USER_COL1,'X') = NVL(X_USER_COL1,'X')
	AND NVL(USER_COL2,'X') = NVL(X_USER_COL2,'X')
	AND NVL(USER_COL3,'X') = NVL(X_USER_COL3,'X')
	AND NVL(USER_COL4,'X') = NVL(X_USER_COL4,'X')
	AND NVL(USER_COL5,'X') = NVL(X_USER_COL5,'X')
	AND NVL(BGT_UNIT_OF_MEASURE,'X') = NVL(X_BGT_UNIT_OF_MEASURE,'X');

	-- Check If Any row was updated

	IF (SQL%ROWCOUNT = 0) THEN

	  -- No row was updated, So Insert a new row into the interface table
          INSERT INTO PA_PRJ_BGT_LINES_IT
          (
	    PRJ_BUDGET_LINE_KEY,
	    PROJECT_ID,
	    PA_PERIOD_KEY,
	    BUDGET_TYPE_CODE,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    CREATION_DATE,
	    CREATED_BY,
	    RESOURCE_LIST_MEMBER_ID,
	    SERVICE_TYPE_CODE,
	    OWNER_ORGANIZATION_ID,
	    EXPENDITURE_TYPE,
	    USER_COL1,
	    USER_COL2,
	    USER_COL3,
	    USER_COL4,
	    USER_COL5,
	    USER_COL6,
	    USER_COL7,
	    USER_COL8,
	    USER_COL9,
	    USER_COL10,
	    BGT_REVENUE,
	    BGT_RAW_COST,
	    BGT_BURDENED_COST,
	    BGT_QUANTITY,
	    BGT_LABOR_QUANTITY,
	    BGT_UNIT_OF_MEASURE,
	    LAST_UPDATE_LOGIN,
	    REQUEST_ID,
	    PROGRAM_APPLICATION_ID,
	    PROGRAM_ID,
	    PROGRAM_UPDATE_DATE,
	    STATUS_CODE
          )
          VALUES
          (
	    X_PROJECT_ID || '-' || X_PA_PERIOD_KEY || '-' ||     --
	    NVL(X_BUDGET_TYPE_CODE,'X') || '-' ||            --|
	    NVL(X_OWNER_ORGANIZATION_ID,-99)||  '-' ||       --|
	    NVL(X_RESOURCE_LIST_MEMBER_ID,-99)||  '-' ||     --|
	    NVL(X_SERVICE_TYPE_CODE,'X')||  '-' ||           --| Dimension Keys
	    NVL(X_EXPENDITURE_TYPE,'X')||  '-' ||            --|
	    NVL(X_USER_COL1,'X')||  '-' ||                   --|
	    NVL(X_USER_COL2,'X')||  '-' ||                   --|
	    NVL(X_USER_COL3,'X')||  '-' ||                   --|
	    NVL(X_USER_COL4,'X')||  '-' ||                   --|
	    NVL(X_USER_COL5,'X'),                            --
	    X_PROJECT_ID,
	    X_PA_PERIOD_KEY,
	    X_BUDGET_TYPE_CODE,
	    TRUNC(SYSDATE),
	    X_LAST_UPDATED_BY,
	    TRUNC(SYSDATE),
	    X_CREATED_BY,
	    X_RESOURCE_LIST_MEMBER_ID,
	    X_SERVICE_TYPE_CODE,
	    X_OWNER_ORGANIZATION_ID,
	    X_EXPENDITURE_TYPE,
	    X_USER_COL1,
	    X_USER_COL2,
	    X_USER_COL3,
	    X_USER_COL4,
	    X_USER_COL5,
	    X_USER_COL6,
	    X_USER_COL7,
	    X_USER_COL8,
	    X_USER_COL9,
	    X_USER_COL10,
	    X_BGT_REVENUE,
	    X_BGT_RAW_COST,
	    X_BGT_BURDENED_COST,
	    X_BGT_QUANTITY,
	    X_BGT_LABOR_QUANTITY,
	    X_BGT_UNIT_OF_MEASURE,
	    X_LAST_UPDATE_LOGIN,
	    X_REQUEST_ID,
	    X_PROGRAM_APPLICATION_ID,
	    X_PROGRAM_ID,
	    TRUNC(SYSDATE),
	    'P'
	  );

	END IF; -- IF ( SQL%ROWCOUNT = 0 )

        x_err_stack := x_old_err_stack;

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
   END update_prj_budgets;

END PA_ADW_COLLECT_FACTS;

/
