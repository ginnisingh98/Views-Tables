--------------------------------------------------------
--  DDL for Package Body PA_ADW_CREATE_VIEWS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ADW_CREATE_VIEWS" AS
/* $Header: PAADWVWB.pls 115.1 99/07/16 13:22:31 porting shi $ */

   FUNCTION Initialize RETURN NUMBER IS
   BEGIN

        RETURN (0);

   EXCEPTION
      WHEN OTHERS THEN
        RAISE;
   END Initialize;

   -- Procedure to get dimension status

   PROCEDURE get_dimension_status
                         (x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS
     x_old_err_stack	VARCHAR2(1024);
   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Getting Dimensions Statuses';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_dimension_status';

     pa_debug.debug(x_err_stage);

       -- First get the dimension statuses

     pa_adw_collect_dimensions.get_dim_status
                         ('DM_PROJECT',
                          dim_project,
                          x_err_stage,
                          x_err_stack,
                          x_err_code);

     pa_adw_collect_dimensions.get_dim_status
                         ('DM_RESOURCE',
                          dim_resource,
                          x_err_stage,
                          x_err_stack,
                          x_err_code);

     pa_adw_collect_dimensions.get_dim_status
                         ('DM_PROJECT_ORG',
                          dim_project_org,
                          x_err_stage,
                          x_err_stack,
                          x_err_code);

     pa_adw_collect_dimensions.get_dim_status
                         ('DM_EXP_ORG',
                          dim_exp_org,
                          x_err_stage,
                          x_err_stack,
                          x_err_code);

     pa_adw_collect_dimensions.get_dim_status
                         ('DM_SRVC_TYPE',
                          dim_srvc_type,
                          x_err_stage,
                          x_err_stack,
                          x_err_code);

     pa_adw_collect_dimensions.get_dim_status
                         ('DM_TIME',
                          dim_time,
                          x_err_stage,
                          x_err_stack,
                          x_err_code);

     pa_adw_collect_dimensions.get_dim_status
                         ('DM_BGT_TYPE',
                          dim_bgt_type,
                          x_err_stage,
                          x_err_stack,
                          x_err_code);

     pa_adw_collect_dimensions.get_dim_status
                         ('DM_EXP_TYPE',
                          dim_exp_type,
                          x_err_stage,
                          x_err_stack,
                          x_err_code);

     pa_adw_collect_dimensions.get_dim_status
                         ('DM_OPERATING_UNIT',
                          dim_operating_unit,
                          x_err_stage,
                          x_err_stack,
                          x_err_code);

     x_err_stack := x_old_err_stack;

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
	RAISE;
   END get_dimension_status;

   PROCEDURE generate_collection_views
                         (x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS
     x_old_err_stack	VARCHAR2(1024);
     idx		BINARY_INTEGER;
   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Generating Collection Views';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> generate_collection_views';

     pa_debug.debug(x_err_stage);

     get_dimension_status (x_err_stage, x_err_stack, x_err_code);

     -- Build the view in a PL/SQL array

     -- Actual and commitments main view

     idx := 1;

     view_act_cmt(idx) := 'CREATE OR REPLACE FORCE VIEW PA_ADW_ACT_CMT_V';
     idx:=idx+1;
     view_act_cmt(idx) := '(';
     idx:=idx+1;
     view_act_cmt(idx) := '  PROJECT_ID,';
     idx:=idx+1;
     view_act_cmt(idx) := '  TOP_TASK_ID,';
     idx:=idx+1;
     view_act_cmt(idx) := '  TASK_ID,';
     idx:=idx+1;
     view_act_cmt(idx) := '  PA_PERIOD_KEY,';
     idx:=idx+1;
     view_act_cmt(idx) := '  EXPENSE_ORGANIZATION_ID,';
     idx:=idx+1;
     view_act_cmt(idx) := '  OWNER_ORGANIZATION_ID,';
     idx:=idx+1;
     view_act_cmt(idx) := '  RESOURCE_LIST_MEMBER_ID,';
     idx:=idx+1;
     view_act_cmt(idx) := '  SERVICE_TYPE_CODE,';
     idx:=idx+1;
     view_act_cmt(idx) := '  EXPENDITURE_TYPE,';
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL1,';
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL2,';
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL3,';
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL4,';
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL5,';
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL6,';
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL7,';
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL8,';
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL9,';
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL10,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_REVENUE,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_RAW_COST,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_BURDENED_COST,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_QUANTITY,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_LABOR_HOURS,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_BILLABLE_RAW_COST,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_BILLABLE_BURDENED_COST,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_BILLABLE_QUANTITY,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_BILLABLE_LABOR_HOURS,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_CMT_RAW_COST,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_CMT_BURDENED_COST,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_CMT_QUANTITY,';
     idx:=idx+1;
     view_act_cmt(idx) := '  UNIT_OF_MEASURE,';
     idx:=idx+1;
     view_act_cmt(idx) := '  RES_ADW_NOTIFY_FLAG,';
     idx:=idx+1;
     view_act_cmt(idx) := '  TXN_ADW_NOTIFY_FLAG';
     idx:=idx+1;
     view_act_cmt(idx) := ') AS';
     idx:=idx+1;
     view_act_cmt(idx) := 'SELECT';
     idx:=idx+1;
     view_act_cmt(idx) := '  PROJECT_ID,';
     idx:=idx+1;
     view_act_cmt(idx) := '  TOP_TASK_ID,';
     idx:=idx+1;
     view_act_cmt(idx) := '  TASK_ID,';
     idx:=idx+1;
     view_act_cmt(idx) := '  PA_PERIOD_KEY,';
     idx:=idx+1;
     IF ( dim_exp_org = 'E' ) THEN
       view_act_cmt(idx) := '  EXPENSE_ORGANIZATION_ID,';
     ELSE
       view_act_cmt(idx) := TO_CHAR(disabled_dim_value_number) || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     IF ( dim_project_org = 'E' ) THEN
       view_act_cmt(idx) := '  OWNER_ORGANIZATION_ID,';
     ELSE
       view_act_cmt(idx) := TO_CHAR(disabled_dim_value_number) || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     view_act_cmt(idx) := '  RESOURCE_LIST_MEMBER_ID,';
     idx:=idx+1;
     IF ( dim_srvc_type = 'E' ) THEN
       view_act_cmt(idx) := '  SERVICE_TYPE_CODE,';
     ELSE
       view_act_cmt(idx) := disabled_dim_value_char || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     IF ( dim_exp_type = 'E' ) THEN
       view_act_cmt(idx) := '  EXPENDITURE_TYPE,';
     ELSE
       view_act_cmt(idx) := disabled_dim_value_char || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL1,';
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL2,';
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL3,';
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL4,';
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL5,';
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL6,';
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL7,';
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL8,';
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL9,';
     idx:=idx+1;
     view_act_cmt(idx) := '  USER_COL10,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_REVENUE,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_RAW_COST,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_BURDENED_COST,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_QUANTITY,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_LABOR_HOURS,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_BILLABLE_RAW_COST,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_BILLABLE_BURDENED_COST,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_BILLABLE_QUANTITY,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_BILLABLE_LABOR_HOURS,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_CMT_RAW_COST,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_CMT_BURDENED_COST,';
     idx:=idx+1;
     view_act_cmt(idx) := '  ACCUME_CMT_QUANTITY,';
     idx:=idx+1;
     IF ( dim_exp_type = 'E' ) THEN
       view_act_cmt(idx) := '  UNIT_OF_MEASURE,';
     ELSE
       view_act_cmt(idx) := disabled_dim_value_char || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     view_act_cmt(idx) := '  RES_ADW_NOTIFY_FLAG,';
     idx:=idx+1;
     view_act_cmt(idx) := '  TXN_ADW_NOTIFY_FLAG';
     idx:=idx+1;
     view_act_cmt(idx) := 'FROM';
     idx:=idx+1;
     view_act_cmt(idx) := '  PA_ADW_ACT_CMT_B_V';

     view_idx_act_cmt    := idx;

     idx := 1;

     view_ref_act_cmt(idx) := 'CREATE OR REPLACE FORCE VIEW PA_ADW_R_ACT_CMT_V';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '(';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  PROJECT_ID,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  TOP_TASK_ID,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  TASK_ID,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  PA_PERIOD_KEY,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  EXPENSE_ORGANIZATION_ID,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  OWNER_ORGANIZATION_ID,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  RESOURCE_LIST_MEMBER_ID,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  SERVICE_TYPE_CODE,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  EXPENDITURE_TYPE,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL1,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL2,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL3,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL4,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL5,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL6,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL7,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL8,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL9,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL10,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_REVENUE,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_RAW_COST,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_BURDENED_COST,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_QUANTITY,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_LABOR_HOURS,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_BILLABLE_RAW_COST,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_BILLABLE_BURDENED_COST,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_BILLABLE_QUANTITY,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_BILLABLE_LABOR_HOURS,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_CMT_RAW_COST,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_CMT_BURDENED_COST,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_CMT_QUANTITY,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  UNIT_OF_MEASURE,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  RES_ADW_NOTIFY_FLAG,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  TXN_ADW_NOTIFY_FLAG,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  TSK_ADW_NOTIFY_FLAG';
     idx:=idx+1;
     view_ref_act_cmt(idx) := ') AS';
     idx:=idx+1;
     view_ref_act_cmt(idx) := 'SELECT';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  PROJECT_ID,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  TOP_TASK_ID,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  TASK_ID,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  PA_PERIOD_KEY,';
     idx:=idx+1;
     IF ( dim_exp_org = 'E' ) THEN
       view_ref_act_cmt(idx) := '  EXPENSE_ORGANIZATION_ID,';
     ELSE
       view_ref_act_cmt(idx) := TO_CHAR(disabled_dim_value_number) || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     IF ( dim_project_org = 'E' ) THEN
       view_ref_act_cmt(idx) := '  OWNER_ORGANIZATION_ID,';
     ELSE
       view_ref_act_cmt(idx) := TO_CHAR(disabled_dim_value_number) || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  RESOURCE_LIST_MEMBER_ID,';
     idx:=idx+1;
     IF ( dim_srvc_type = 'E' ) THEN
       view_ref_act_cmt(idx) := '  SERVICE_TYPE_CODE,';
     ELSE
       view_ref_act_cmt(idx) := disabled_dim_value_char || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     IF ( dim_exp_type = 'E' ) THEN
       view_ref_act_cmt(idx) := '  EXPENDITURE_TYPE,';
     ELSE
       view_ref_act_cmt(idx) := disabled_dim_value_char || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL1,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL2,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL3,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL4,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL5,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL6,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL7,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL8,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL9,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  USER_COL10,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_REVENUE,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_RAW_COST,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_BURDENED_COST,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_QUANTITY,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_LABOR_HOURS,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_BILLABLE_RAW_COST,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_BILLABLE_BURDENED_COST,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_BILLABLE_QUANTITY,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_BILLABLE_LABOR_HOURS,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_CMT_RAW_COST,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_CMT_BURDENED_COST,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  ACCUME_CMT_QUANTITY,';
     idx:=idx+1;
     IF ( dim_exp_type = 'E' ) THEN
       view_ref_act_cmt(idx) := '  UNIT_OF_MEASURE,';
     ELSE
       view_ref_act_cmt(idx) := disabled_dim_value_char || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  RES_ADW_NOTIFY_FLAG,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  TXN_ADW_NOTIFY_FLAG,';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  TSK_ADW_NOTIFY_FLAG';
     idx:=idx+1;
     view_ref_act_cmt(idx) := 'FROM';
     idx:=idx+1;
     view_ref_act_cmt(idx) := '  PA_ADW_R_ACT_CMT_B_V';

     view_idx_ref_act_cmt    := idx;

     idx := 1;

     view_ref_ser_type_act_cmt(idx) := 'CREATE OR REPLACE FORCE VIEW PA_ADW_R_ST_ACT_CMT_V';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '(';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  PROJECT_ID,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  TOP_TASK_ID,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  TASK_ID,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  PA_PERIOD_KEY,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  EXPENSE_ORGANIZATION_ID,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  OWNER_ORGANIZATION_ID,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  RESOURCE_LIST_MEMBER_ID,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  SERVICE_TYPE_CODE,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  EXPENDITURE_TYPE,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL1,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL2,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL3,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL4,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL5,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL6,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL7,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL8,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL9,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL10,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_REVENUE,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_RAW_COST,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_BURDENED_COST,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_QUANTITY,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_LABOR_HOURS,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_BILLABLE_RAW_COST,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_BILLABLE_BURDENED_COST,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_BILLABLE_QUANTITY,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_BILLABLE_LABOR_HOURS,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_CMT_RAW_COST,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_CMT_BURDENED_COST,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_CMT_QUANTITY,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  UNIT_OF_MEASURE,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  RES_ADW_NOTIFY_FLAG,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  TXN_ADW_NOTIFY_FLAG,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  TSK_ADW_NOTIFY_FLAG';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := ') AS';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := 'SELECT';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  PROJECT_ID,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  TOP_TASK_ID,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  TASK_ID,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  PA_PERIOD_KEY,';
     idx:=idx+1;
     IF ( dim_exp_org = 'E' ) THEN
       view_ref_ser_type_act_cmt(idx) := '  EXPENSE_ORGANIZATION_ID,';
     ELSE
       view_ref_ser_type_act_cmt(idx) := TO_CHAR(disabled_dim_value_number) || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     IF ( dim_project_org = 'E' ) THEN
       view_ref_ser_type_act_cmt(idx) := '  OWNER_ORGANIZATION_ID,';
     ELSE
       view_ref_ser_type_act_cmt(idx) := TO_CHAR(disabled_dim_value_number) || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  RESOURCE_LIST_MEMBER_ID,';
     idx:=idx+1;
     IF ( dim_srvc_type = 'E' ) THEN
       view_ref_ser_type_act_cmt(idx) := '  SERVICE_TYPE_CODE,';
     ELSE
       view_ref_ser_type_act_cmt(idx) := disabled_dim_value_char || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     IF ( dim_exp_type = 'E' ) THEN
       view_ref_ser_type_act_cmt(idx) := '  EXPENDITURE_TYPE,';
     ELSE
       view_ref_ser_type_act_cmt(idx) := disabled_dim_value_char || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL1,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL2,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL3,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL4,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL5,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL6,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL7,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL8,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL9,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  USER_COL10,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_REVENUE,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_RAW_COST,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_BURDENED_COST,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_QUANTITY,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_LABOR_HOURS,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_BILLABLE_RAW_COST,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_BILLABLE_BURDENED_COST,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_BILLABLE_QUANTITY,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_BILLABLE_LABOR_HOURS,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_CMT_RAW_COST,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_CMT_BURDENED_COST,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  ACCUME_CMT_QUANTITY,';
     idx:=idx+1;
     IF ( dim_exp_type = 'E' ) THEN
       view_ref_ser_type_act_cmt(idx) := '  UNIT_OF_MEASURE,';
     ELSE
       view_ref_ser_type_act_cmt(idx) := disabled_dim_value_char || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  RES_ADW_NOTIFY_FLAG,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  TXN_ADW_NOTIFY_FLAG,';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  TSK_ADW_NOTIFY_FLAG';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := 'FROM';
     idx:=idx+1;
     view_ref_ser_type_act_cmt(idx) := '  PA_ADW_R_ST_ACT_CMT_B_V';

     view_idx_ref_ser_type_act_cmt    := idx;

     -- Budget Views

     idx := 1;

     view_budget_lines(idx) := 'CREATE OR REPLACE FORCE VIEW PA_ADW_BGT_LINES_V';
     idx:=idx+1;
     view_budget_lines(idx) := '(';
     idx:=idx+1;
     view_budget_lines(idx) := '  PROJECT_ID,';
     idx:=idx+1;
     view_budget_lines(idx) := '  TOP_TASK_ID,';
     idx:=idx+1;
     view_budget_lines(idx) := '  TASK_ID,';
     idx:=idx+1;
     view_budget_lines(idx) := '  PA_PERIOD_KEY,';
     idx:=idx+1;
     view_budget_lines(idx) := '  BUDGET_TYPE_CODE,';
     idx:=idx+1;
     view_budget_lines(idx) := '  RESOURCE_LIST_MEMBER_ID,';
     idx:=idx+1;
     view_budget_lines(idx) := '  SERVICE_TYPE_CODE,';
     idx:=idx+1;
     view_budget_lines(idx) := '  OWNER_ORGANIZATION_ID,';
     idx:=idx+1;
     view_budget_lines(idx) := '  EXPENDITURE_TYPE,';
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL1,';
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL2,';
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL3,';
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL4,';
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL5,';
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL6,';
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL7,';
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL8,';
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL9,';
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL10,';
     idx:=idx+1;
     view_budget_lines(idx) := '  BGT_RAW_COST,';
     idx:=idx+1;
     view_budget_lines(idx) := '  BGT_BURDENED_COST,';
     idx:=idx+1;
     view_budget_lines(idx) := '  BGT_REVENUE,';
     idx:=idx+1;
     view_budget_lines(idx) := '  BGT_QUANTITY,';
     idx:=idx+1;
     view_budget_lines(idx) := '  BGT_LABOR_QUANTITY,';
     idx:=idx+1;
     view_budget_lines(idx) := '  BGT_UNIT_OF_MEASURE,';
     idx:=idx+1;
     view_budget_lines(idx) := '  ADW_NOTIFY_FLAG';
     idx:=idx+1;
     view_budget_lines(idx) := ') AS';
     idx:=idx+1;
     view_budget_lines(idx) := 'SELECT';
     idx:=idx+1;
     view_budget_lines(idx) := '  PROJECT_ID,';
     idx:=idx+1;
     view_budget_lines(idx) := '  TOP_TASK_ID,';
     idx:=idx+1;
     view_budget_lines(idx) := '  TASK_ID,';
     idx:=idx+1;
     view_budget_lines(idx) := '  PA_PERIOD_KEY,';
     idx:=idx+1;
     view_budget_lines(idx) := '  BUDGET_TYPE_CODE,';
     idx:=idx+1;
     view_budget_lines(idx) := '  RESOURCE_LIST_MEMBER_ID,';
     idx:=idx+1;
     IF ( dim_srvc_type = 'E' ) THEN
       view_budget_lines(idx) := '  SERVICE_TYPE_CODE,';
     ELSE
       view_budget_lines(idx) := disabled_dim_value_char || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     IF ( dim_project_org = 'E' ) THEN
       view_budget_lines(idx) := '  OWNER_ORGANIZATION_ID,';
     ELSE
       view_budget_lines(idx) := TO_CHAR(disabled_dim_value_number) || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     IF ( dim_exp_type = 'E' ) THEN
       view_budget_lines(idx) := '  EXPENDITURE_TYPE,';
     ELSE
       view_budget_lines(idx) := disabled_dim_value_char || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL1,';
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL2,';
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL3,';
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL4,';
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL5,';
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL6,';
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL7,';
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL8,';
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL9,';
     idx:=idx+1;
     view_budget_lines(idx) := '  USER_COL10,';
     idx:=idx+1;
     view_budget_lines(idx) := '  BGT_RAW_COST,';
     idx:=idx+1;
     view_budget_lines(idx) := '  BGT_BURDENED_COST,';
     idx:=idx+1;
     view_budget_lines(idx) := '  BGT_REVENUE,';
     idx:=idx+1;
     view_budget_lines(idx) := '  BGT_QUANTITY,';
     idx:=idx+1;
     view_budget_lines(idx) := '  BGT_LABOR_QUANTITY,';
     idx:=idx+1;
     IF ( dim_exp_type = 'E' ) THEN
       view_budget_lines(idx) := '  BGT_UNIT_OF_MEASURE,';
     ELSE
       view_budget_lines(idx) := disabled_dim_value_char || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     view_budget_lines(idx) := '  ADW_NOTIFY_FLAG';
     idx:=idx+1;
     view_budget_lines(idx) := 'FROM';
     idx:=idx+1;
     view_budget_lines(idx) := '  PA_ADW_BGT_LINES_B_V';

     view_idx_budget_lines    := idx;

     idx := 1;

     view_ref_budget_lines(idx) := 'CREATE OR REPLACE FORCE VIEW PA_ADW_R_BGT_LINES_V';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '(';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  PROJECT_ID,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  TOP_TASK_ID,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  TASK_ID,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  PA_PERIOD_KEY,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  BUDGET_TYPE_CODE,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  RESOURCE_LIST_MEMBER_ID,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  SERVICE_TYPE_CODE,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  OWNER_ORGANIZATION_ID,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  EXPENDITURE_TYPE,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL1,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL2,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL3,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL4,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL5,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL6,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL7,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL8,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL9,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL10,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  BGT_RAW_COST,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  BGT_BURDENED_COST,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  BGT_REVENUE,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  BGT_QUANTITY,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  BGT_LABOR_QUANTITY,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  BGT_UNIT_OF_MEASURE,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  ADW_NOTIFY_FLAG';
     idx:=idx+1;
     view_ref_budget_lines(idx) := ') AS';
     idx:=idx+1;
     view_ref_budget_lines(idx) := 'SELECT';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  PROJECT_ID,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  TOP_TASK_ID,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  TASK_ID,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  PA_PERIOD_KEY,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  BUDGET_TYPE_CODE,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  RESOURCE_LIST_MEMBER_ID,';
     idx:=idx+1;
     IF ( dim_srvc_type = 'E' ) THEN
       view_ref_budget_lines(idx) := '  SERVICE_TYPE_CODE,';
     ELSE
       view_ref_budget_lines(idx) := disabled_dim_value_char || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     IF ( dim_project_org = 'E' ) THEN
       view_ref_budget_lines(idx) := '  OWNER_ORGANIZATION_ID,';
     ELSE
       view_ref_budget_lines(idx) := TO_CHAR(disabled_dim_value_number) || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     IF ( dim_exp_type = 'E' ) THEN
       view_ref_budget_lines(idx) := '  EXPENDITURE_TYPE,';
     ELSE
       view_ref_budget_lines(idx) := disabled_dim_value_char || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL1,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL2,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL3,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL4,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL5,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL6,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL7,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL8,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL9,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  USER_COL10,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  BGT_RAW_COST,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  BGT_BURDENED_COST,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  BGT_REVENUE,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  BGT_QUANTITY,';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  BGT_LABOR_QUANTITY,';
     idx:=idx+1;
     IF ( dim_exp_type = 'E' ) THEN
       view_ref_budget_lines(idx) := '  BGT_UNIT_OF_MEASURE,';
     ELSE
       view_ref_budget_lines(idx) := disabled_dim_value_char || ', /* Disabled */';
     END IF;
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  ADW_NOTIFY_FLAG';
     idx:=idx+1;
     view_ref_budget_lines(idx) := 'FROM';
     idx:=idx+1;
     view_ref_budget_lines(idx) := '  PA_ADW_R_BGT_LINES_B_V';

     view_idx_ref_budget_lines    := idx;

     x_err_stack := x_old_err_stack;

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
	RAISE;
   END generate_collection_views;

   PROCEDURE create_collection_views
                         (x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS
     x_old_err_stack	VARCHAR2(1024);
     source_cursor      INTEGER;
     retcode            NUMBER;
   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Creating Collection Views Definition in the DB';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> create_collection_views';

     pa_debug.debug(x_err_stage);

     source_cursor := dbms_sql.open_cursor;
     dbms_sql.parse(source_cursor,view_act_cmt,1,view_idx_act_cmt,TRUE,dbms_sql.v7);
     retcode := dbms_sql.execute(source_cursor);
     dbms_sql.parse(source_cursor,view_ref_act_cmt,1,view_idx_ref_act_cmt,TRUE,dbms_sql.v7);
     retcode := dbms_sql.execute(source_cursor);
     dbms_sql.parse(source_cursor,view_ref_ser_type_act_cmt,1,view_idx_ref_ser_type_act_cmt,TRUE,dbms_sql.v7);
     retcode := dbms_sql.execute(source_cursor);
     dbms_sql.parse(source_cursor,view_budget_lines,1,view_idx_budget_lines,TRUE,dbms_sql.v7);
     retcode := dbms_sql.execute(source_cursor);
     dbms_sql.parse(source_cursor,view_ref_budget_lines,1,view_idx_ref_budget_lines,TRUE,dbms_sql.v7);
     retcode := dbms_sql.execute(source_cursor);

     dbms_sql.close_cursor(source_cursor);

     x_err_stack := x_old_err_stack;

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
	RAISE;
   END create_collection_views;

   PROCEDURE output_collection_views
                         (x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS
     x_old_err_stack	VARCHAR2(1024);
   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Creating Collection Views Definition';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> output_collection_views';

     pa_debug.debug(x_err_stage);

     pa_debug.debug('********START OF VIEWS DEFINITION*******', PA_DEBUG.DEBUG_LEVEL_EXCEPTION);
     FOR i IN 1..view_idx_act_cmt LOOP
       pa_debug.debug(view_act_cmt(i), PA_DEBUG.DEBUG_LEVEL_EXCEPTION);
     END LOOP;
     pa_debug.debug('/', PA_DEBUG.DEBUG_LEVEL_EXCEPTION);
     FOR i IN 1..view_idx_ref_act_cmt LOOP
       pa_debug.debug(view_ref_act_cmt(i), PA_DEBUG.DEBUG_LEVEL_EXCEPTION);
     END LOOP;
     pa_debug.debug('/', PA_DEBUG.DEBUG_LEVEL_EXCEPTION);
     FOR i IN 1..view_idx_ref_ser_type_act_cmt LOOP
       pa_debug.debug(view_ref_ser_type_act_cmt(i), PA_DEBUG.DEBUG_LEVEL_EXCEPTION);
     END LOOP;
     pa_debug.debug('/', PA_DEBUG.DEBUG_LEVEL_EXCEPTION);
     FOR i IN 1..view_idx_budget_lines LOOP
       pa_debug.debug(view_budget_lines(i), PA_DEBUG.DEBUG_LEVEL_EXCEPTION);
     END LOOP;
     pa_debug.debug('/', PA_DEBUG.DEBUG_LEVEL_EXCEPTION);
     FOR i IN 1..view_idx_ref_budget_lines LOOP
       pa_debug.debug(view_ref_budget_lines(i), PA_DEBUG.DEBUG_LEVEL_EXCEPTION);
     END LOOP;
     pa_debug.debug('/', PA_DEBUG.DEBUG_LEVEL_EXCEPTION);
     pa_debug.debug('********END OF VIEWS DEFINITION*******', PA_DEBUG.DEBUG_LEVEL_EXCEPTION);

     x_err_stack := x_old_err_stack;

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
	RAISE;
   END output_collection_views;

END PA_ADW_CREATE_VIEWS;

/
