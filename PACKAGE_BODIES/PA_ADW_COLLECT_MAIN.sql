--------------------------------------------------------
--  DDL for Package Body PA_ADW_COLLECT_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ADW_COLLECT_MAIN" AS
/* $Header: PAADWCMB.pls 115.5 99/07/16 13:22:01 porting ship $ */

   FUNCTION Initialize RETURN NUMBER IS
   BEGIN
       pa_debug.debug('Getting the License Status');

       -- By Default the Oracle Project Collection Pack is not Licensed

       license_status := NVL(fnd_profile.value('PA_ADW_LICENSED'),'N');

       pa_debug.debug('Getting the Install Status');

       -- By Default the Oracle Project Collection Pack is not Installed

       install_status := NVL(fnd_profile.value('PA_ADW_INSTALLED'),'N');

       pa_debug.debug('Getting the Tasks Profile Option Values');

       -- By Default we will not collect lowest/top level tasks
       -- If we are collecting lowest tasks, we will always collect top tasks

       pa_debug.debug('Getting the Lowest Task Profile Option Values');

       collect_lowest_tasks_flag := NVL(fnd_profile.value('PA_ADW_COLLECT_LOWEST_TASKS'),'N');

       IF (collect_lowest_tasks_flag = 'Y') THEN
	   -- Always collect top tasks
	   collect_top_tasks_flag := 'Y';
       ELSE
           pa_debug.debug('Getting the Top Task Profile Option Values');
           collect_top_tasks_flag := NVL(fnd_profile.value('PA_ADW_COLLECT_TOP_TASKS'),'N');
       END IF;

        RETURN (0);

   EXCEPTION
      WHEN OTHERS THEN
        RAISE;
   END Initialize;
   -- Procedure to get dimension statuses

   PROCEDURE get_dimension_status
                        ( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS
     x_old_err_stack	VARCHAR2(1024);
   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Getting Dimension Status';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_dimension_status';

     pa_debug.debug(x_err_stage);

     -- Call the initialize procedure

     x_err_code := pa_adw_collect_main.initialize;

     -- get the dimension statuses

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

   -- Prepare the source data for refresh
   -- We will mark all source table ADW_NOTIFY_FLAG = 'Y'

   PROCEDURE prepare_src_table_for_refresh
                        ( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS
     x_old_err_stack	VARCHAR2(1024);
   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Preparing Source Table for Collection';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> prepare_src_table_for_refresh';

     pa_debug.debug(x_err_stage);

     UPDATE PA_TASKS SET ADW_NOTIFY_FLAG='Y'
     WHERE ADW_NOTIFY_FLAG = 'N';

     UPDATE PA_PROJECTS SET ADW_NOTIFY_FLAG='Y'
     WHERE ADW_NOTIFY_FLAG = 'N';

     UPDATE PA_PROJECT_TYPES SET ADW_NOTIFY_FLAG='Y'
     WHERE ADW_NOTIFY_FLAG = 'N';

     UPDATE PA_EXPENDITURE_TYPES SET ADW_NOTIFY_FLAG='Y'
     WHERE ADW_NOTIFY_FLAG = 'N';

     UPDATE PA_CLASS_CATEGORIES SET ADW_NOTIFY_FLAG='Y'
     WHERE ADW_NOTIFY_FLAG = 'N';

     UPDATE PA_CLASS_CODES SET ADW_NOTIFY_FLAG='Y'
     WHERE ADW_NOTIFY_FLAG = 'N';

     UPDATE PA_PROJECT_CLASSES SET ADW_NOTIFY_FLAG='Y'
     WHERE ADW_NOTIFY_FLAG = 'N';

     UPDATE PA_BUDGET_TYPES SET ADW_NOTIFY_FLAG='Y'
     WHERE ADW_NOTIFY_FLAG = 'N';

     UPDATE PA_RESOURCE_LIST_MEMBERS SET ADW_NOTIFY_FLAG='Y'
     WHERE ADW_NOTIFY_FLAG = 'N';

     UPDATE PA_RESOURCE_LISTS SET ADW_NOTIFY_FLAG='Y'
     WHERE ADW_NOTIFY_FLAG = 'N';

     UPDATE PA_TXN_ACCUM SET ADW_NOTIFY_FLAG='Y'
     WHERE ADW_NOTIFY_FLAG = 'N';

     UPDATE PA_RESOURCE_ACCUM_DETAILS SET ADW_NOTIFY_FLAG='Y'
     WHERE ADW_NOTIFY_FLAG = 'N';

     UPDATE PA_BUDGET_VERSIONS SET ADW_NOTIFY_FLAG='Y'
     WHERE ADW_NOTIFY_FLAG = 'N';

     x_err_stack := x_old_err_stack;

   EXCEPTION
      WHEN OTHERS THEN
	   x_err_code := SQLCODE;
	   RAISE;
   END prepare_src_table_for_refresh;

   -- Clear interface tables
   -- Delete all rows from interface table

   PROCEDURE clear_interface_tables
                        ( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS
     x_old_err_stack	VARCHAR2(1024);
   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Clearing Interface Tables';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> clear_interface_tables';

     pa_debug.debug(x_err_stage);

     DELETE FROM PA_TOP_TASKS_IT;
     DELETE FROM PA_PROJECTS_IT;
     DELETE FROM PA_PRJ_TYPES_IT;
     DELETE FROM PA_EXP_TYPES_IT;
     DELETE FROM PA_PRJ_CLASSES_IT;
     DELETE FROM PA_CLASS_CATGS_IT;
     DELETE FROM PA_CLASS_CODES_IT;
     DELETE FROM PA_LOWEST_RLMEM_IT;
     DELETE FROM PA_TOP_RLMEM_IT;
     DELETE FROM PA_RES_LISTS_IT;
     DELETE FROM PA_SRVC_TYPES_IT;
     DELETE FROM PA_PERIODS_IT;
     DELETE FROM PA_ORGS_IT;
     DELETE FROM PA_BGT_TYPES_IT;
     DELETE FROM PA_TSK_ACT_CMT_IT;
     DELETE FROM PA_PRJ_ACT_CMT_IT;
     DELETE FROM PA_TSK_BGT_LINES_IT;
     DELETE FROM PA_PRJ_BGT_LINES_IT;
     DELETE FROM PA_OLD_RES_ACCUM_DTLS;
     DELETE FROM PA_OPER_UNITS_IT;
     DELETE FROM PA_GL_PERIODS_IT;
     DELETE FROM PA_FINANCIAL_QTRS_IT;
     DELETE FROM PA_FINANCIAL_YRS_IT;
     DELETE FROM PA_ALL_FINANCIAL_YRS_IT;
     DELETE FROM PA_ALL_EXP_TYPES_IT;
     DELETE FROM PA_ALL_SRVC_TYPES_IT;
     DELETE FROM PA_ALL_PRJ_TYPES_IT;
     DELETE FROM PA_PRJ_ORGS_IT;
     DELETE FROM PA_PRJ_BUSINESS_GRPS_IT;
     DELETE FROM PA_EXP_ORGS_IT;
     DELETE FROM PA_EXP_BUSINESS_GRPS_IT;
     DELETE FROM PA_SET_OF_BOOKS_IT;
     DELETE FROM PA_LEGAL_ENTITY_IT;

     x_err_stack := x_old_err_stack;

   EXCEPTION
      WHEN OTHERS THEN
	   x_err_code := SQLCODE;
	   RAISE;
   END clear_interface_tables;

   -- Purge interface table using dynamic SQL
   -- for rows of information already integrated with OADW system
   -- If the WH_UPDATE_DATE column has the value less than the
   -- Date when the warehouse was updated last, then these rows
   -- can be deleted from the interface table.

   PROCEDURE purge_it_OADW
                        ( x_table_name           IN VARCHAR2,
                          x_wh_update_date       IN DATE)
   IS
     sql_command   VARCHAR2(1024);
     source_cursor integer;
     rows_deleted  integer;
   BEGIN

     pa_debug.debug('Purging Interface Tables For OADW ' || x_table_name);

     -- prepare a cursor to delete from the source table
     source_cursor := dbms_sql.open_cursor;
     sql_command :=
                    'DELETE FROM '|| x_table_name
                     || ' WHERE WH_UPDATE_DATE <= :x_wh_update_date';
     dbms_sql.parse(source_cursor,sql_command,dbms_sql.native);
     dbms_sql.bind_variable(source_cursor, 'x_wh_update_date', x_wh_update_date);
     rows_deleted := dbms_sql.execute(source_cursor);
     pa_debug.debug('Rows deleted:= ' || to_char(rows_deleted));
     dbms_sql.close_cursor(source_cursor);
   EXCEPTION
      WHEN OTHERS THEN
           IF dbms_sql.is_open(source_cursor) THEN
             dbms_sql.close_cursor(source_cursor);
           END IF;
	   RAISE;
   END purge_it_OADW;

   -- Purge interface table using dynamic SQL
   -- for rows of information already integrated with OADW system
   -- If the WH_UPDATE_DATE column has the value less than the
   -- Date when the warehouse was updated last, then these rows
   -- can be deleted from the interface table.

   PROCEDURE purge_interface_tables_OADW
                        ( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS
     x_old_err_stack	   VARCHAR2(1024);
     oadw_wh_cursor        integer;
     earliest_collect_time Date;/*Earliest collection time from OADW Warehouse*/
     rows_processed        integer;
   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Purging Interface Tables For OADW';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> purge_interface_tables_OADW';
     earliest_collect_time := NULL;

     pa_debug.debug(x_err_stage);

     IF (install_status = 'Y') THEN

         /* Get the Warehouse Update DATE */
	 /* Get the warehouse update date using a dynamic SQL, since
	    WH_RT_VERSIONS_V2 is available in the OADW Warehouse Database */

         oadw_wh_cursor := dbms_sql.open_cursor;
         dbms_sql.parse(oadw_wh_cursor,
         'SELECT earliest_collect_time FROM wh_rt_versions_v2@PA_TO_WH',dbms_sql.native);
         dbms_sql.define_column(oadw_wh_cursor, 1, earliest_collect_time);
         rows_processed := dbms_sql.execute(oadw_wh_cursor);

         if ( dbms_sql.fetch_rows(oadw_wh_cursor) > 0 ) then
           dbms_sql.column_value(oadw_wh_cursor, 1, earliest_collect_time);
         end if;
         dbms_sql.close_cursor(oadw_wh_cursor);

         IF (earliest_collect_time IS NOT NULL) THEN
            /* Purge Interface table */
	    /* Project Dimension */
	    IF (collect_top_tasks_flag = 'Y') THEN
              purge_it_OADW('PA_TOP_TASKS_IT',earliest_collect_time);
	    END IF;
	    IF (collect_lowest_tasks_flag = 'Y') THEN
              purge_it_OADW('PA_LOWEST_TASKS_IT',earliest_collect_time);
	    END IF;
            purge_it_OADW('PA_PROJECTS_IT_ALL',earliest_collect_time);
            purge_it_OADW('PA_PRJ_TYPES_IT_ALL',earliest_collect_time);
            purge_it_OADW('PA_ALL_PRJ_TYPES_IT',earliest_collect_time);
	    /* Resource Dimension */
            purge_it_OADW('PA_LOWEST_RLMEM_IT',earliest_collect_time);
            purge_it_OADW('PA_TOP_RLMEM_IT',earliest_collect_time);
            purge_it_OADW('PA_RES_LISTS_IT_ALL_BG',earliest_collect_time);
	    /* Budget Type Dimension */
            purge_it_OADW('PA_BGT_TYPES_IT',earliest_collect_time);
	    /* Time Dimension */
            purge_it_OADW('PA_PERIODS_IT',earliest_collect_time);
            purge_it_OADW('PA_GL_PERIODS_IT',earliest_collect_time);
            purge_it_OADW('PA_FINANCIAL_QTRS_IT',earliest_collect_time);
            purge_it_OADW('PA_FINANCIAL_YRS_IT',earliest_collect_time);
            purge_it_OADW('PA_ALL_FINANCIAL_YRS_IT',earliest_collect_time);
            /* Fact Tables */
	    IF (collect_top_tasks_flag = 'Y' OR collect_lowest_tasks_flag = 'Y') THEN
              purge_it_OADW('PA_TSK_ACT_CMT_IT_ALL',earliest_collect_time);
	    END IF;
            purge_it_OADW('PA_PRJ_ACT_CMT_IT_ALL',earliest_collect_time);
	    IF (collect_top_tasks_flag = 'Y' OR collect_lowest_tasks_flag = 'Y') THEN
              purge_it_OADW('PA_TSK_BGT_LINES_IT_ALL',earliest_collect_time);
	    END IF;
            purge_it_OADW('PA_PRJ_BGT_LINES_IT_ALL',earliest_collect_time);
	    /* Expenditure Type Dimension */
	    IF (dim_exp_type = 'E') THEN
              purge_it_OADW('PA_EXP_TYPES_IT',earliest_collect_time);
              purge_it_OADW('PA_ALL_EXP_TYPES_IT',earliest_collect_time);
	    END IF;
	    /* Service Type Dimension */
	    IF (dim_srvc_type = 'E') THEN
              purge_it_OADW('PA_SRVC_TYPES_IT',earliest_collect_time);
              purge_it_OADW('PA_ALL_SRVC_TYPES_IT',earliest_collect_time);
	    END IF;
	    /* Project Organization Dimension */
	    IF (dim_project_org = 'E') THEN
              purge_it_OADW('PA_PRJ_ORGS_IT',earliest_collect_time);
              purge_it_OADW('PA_PRJ_BUSINESS_GRPS_IT',earliest_collect_time);
	    END IF;
	    /* Expenditure Organization Dimension */
	    IF (dim_exp_org = 'E') THEN
              purge_it_OADW('PA_EXP_ORGS_IT',earliest_collect_time);
              purge_it_OADW('PA_EXP_BUSINESS_GRPS_IT',earliest_collect_time);
	    END IF;
	    /* Operating Unit Dimension */
	    IF (dim_operating_unit = 'E') THEN
              purge_it_OADW('PA_SET_OF_BOOKS_IT',earliest_collect_time);
              purge_it_OADW('PA_LEGAL_ENTITY_IT',earliest_collect_time);
              purge_it_OADW('PA_OPER_UNITS_IT',earliest_collect_time);
	    END IF;
         END IF; -- IF (earliest_collect_time IS NOT NULL) THEN

     END IF ; -- IF (install_status = 'Y')

     x_err_stack := x_old_err_stack;

   EXCEPTION
      WHEN OTHERS THEN
           IF dbms_sql.is_open(oadw_wh_cursor) THEN
             dbms_sql.close_cursor(oadw_wh_cursor);
           END IF;
	   x_err_code := SQLCODE;
	   RAISE;
   END purge_interface_tables_OADW;

   -- Purge interface tables for information that is integrated
   -- with external system
   -- The STATUS_CODE for all such rows will have a value of 'T'

   PROCEDURE purge_interface_tables
                        ( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS
     x_old_err_stack	VARCHAR2(1024);
   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Purging Interface Tables';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> purge_interface_tables';

     pa_debug.debug(x_err_stage);

     DELETE FROM PA_TOP_TASKS_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_PROJECTS_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_PRJ_TYPES_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_EXP_TYPES_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_PRJ_CLASSES_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_CLASS_CATGS_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_CLASS_CODES_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_LOWEST_RLMEM_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_TOP_RLMEM_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_RES_LISTS_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_SRVC_TYPES_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_PERIODS_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_ORGS_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_BGT_TYPES_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_TSK_ACT_CMT_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_PRJ_ACT_CMT_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_TSK_BGT_LINES_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_PRJ_BGT_LINES_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_OPER_UNITS_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_GL_PERIODS_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_FINANCIAL_QTRS_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_FINANCIAL_YRS_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_ALL_FINANCIAL_YRS_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_ALL_EXP_TYPES_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_ALL_SRVC_TYPES_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_ALL_PRJ_TYPES_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_PRJ_ORGS_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_PRJ_BUSINESS_GRPS_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_EXP_ORGS_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_EXP_BUSINESS_GRPS_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_SET_OF_BOOKS_IT
     WHERE STATUS_CODE = 'T';

     DELETE FROM PA_LEGAL_ENTITY_IT
     WHERE STATUS_CODE = 'T';

     pa_adw_collect_main.purge_interface_tables_OADW
                        ( x_err_stage,
                          x_err_stack,
                          x_err_code);

     x_err_stack := x_old_err_stack;

   EXCEPTION
      WHEN OTHERS THEN
	   x_err_code := SQLCODE;
	   RAISE;
   END purge_interface_tables;

   -- Main Procedure to collect dimension and fact tables

   PROCEDURE get_dim_and_fact_main
                        ( x_collect_dim_tables   IN     VARCHAR2,
			  x_dimension_table      IN     VARCHAR2,
                          x_collect_fact_tables  IN     VARCHAR2,
			  x_fact_table           IN     VARCHAR2,
			  x_project_num_from     IN     VARCHAR2,
			  x_project_num_to       IN     VARCHAR2,
                          x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS
     x_old_err_stack	VARCHAR2(1024);
   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Collecting Dimensions and Fact Tables';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> get_dim_and_fact_main';

     pa_debug.debug(x_err_stage);

     -- Call the initialize procedure

     x_err_code := pa_adw_collect_main.initialize;

     -- Check the license status

     IF ( license_status <> 'Y' ) THEN
	 pa_debug.debug('Oracle Project Analysis Collection Pack Not Licensed',
			 pa_debug.DEBUG_LEVEL_EXCEPTION);
	 x_err_stage  := 'Oracle Project Analysis Collection Pack Not Licensed';
	 x_err_code   := 2;
	 ROLLBACK WORK;
	 return;
     END IF; -- IF ( license_status <> 'Y' )

     IF ( x_collect_dim_tables = 'Y') THEN

       -- Collect dimension tables
       -- First get the dimension statuses

       pa_adw_collect_main.get_dimension_status
                        ( x_err_stage,
                          x_err_stack,
                          x_err_code);

       IF ( x_dimension_table = 'TASKS'
         OR x_dimension_table IS NULL ) THEN

	 IF (dim_project = 'E') THEN
           -- Collect Tasks
           pa_adw_collect_dimensions.get_dim_tasks (x_err_stage, x_err_stack, x_err_code);
	 END IF;

       END IF;
       IF ( x_dimension_table = 'PROJECTS'
         OR x_dimension_table IS NULL ) THEN

	 IF (dim_project = 'E') THEN
           -- Collect Projects
           pa_adw_collect_dimensions.get_dim_projects (x_err_stage, x_err_stack, x_err_code);
	 END IF;

       END IF;
       IF ( x_dimension_table = 'PROJECT_TYPES'
         OR x_dimension_table IS NULL ) THEN

	 IF (dim_project = 'E') THEN
           -- Collect Project Types
           pa_adw_collect_dimensions.get_dim_project_types (x_err_stage, x_err_stack, x_err_code);
	 END IF;

       END IF;
       IF ( x_dimension_table = 'EXPENDITURE_TYPES'
         OR x_dimension_table IS NULL ) THEN

	 IF (dim_exp_type = 'E') THEN
           -- Collect Project Types
           pa_adw_collect_dimensions.get_dim_expenditure_types (x_err_stage, x_err_stack, x_err_code);
	 END IF;

       END IF;
       IF ( x_dimension_table = 'PROJECT_CLASSES'
         OR x_dimension_table IS NULL ) THEN

	 IF (dim_project = 'E') THEN
           -- Collect Project Classes
           pa_adw_collect_dimensions.get_dim_project_classes (x_err_stage, x_err_stack, x_err_code);
	 END IF;

       END IF;
       IF ( x_dimension_table = 'CLASS_CATEGORIES'
         OR x_dimension_table IS NULL ) THEN

	 IF (dim_project = 'E') THEN
           -- Collect Class Categories
           pa_adw_collect_dimensions.get_dim_class_categories (x_err_stage, x_err_stack, x_err_code);
	 END IF;

       END IF;
       IF ( x_dimension_table = 'CLASS_CODES'
         OR x_dimension_table IS NULL ) THEN

	 IF (dim_project = 'E') THEN
           -- Collect Class Codes
           pa_adw_collect_dimensions.get_dim_class_codes (x_err_stage, x_err_stack, x_err_code);
	 END IF;

       END IF;
       IF ( x_dimension_table = 'RESOURCES'
         OR x_dimension_table IS NULL ) THEN

	 IF (dim_resource = 'E') THEN
           -- Collect Resources
           pa_adw_collect_dimensions.get_dim_resources (x_err_stage, x_err_stack, x_err_code);
	 END IF;

       END IF;
       IF ( x_dimension_table = 'RESOURCE_LISTS'
         OR x_dimension_table IS NULL ) THEN

	 IF (dim_resource = 'E') THEN
           -- Collect Resource Lists
           pa_adw_collect_dimensions.get_dim_resource_lists (x_err_stage, x_err_stack, x_err_code);
	 END IF;

       END IF;
       IF ( x_dimension_table = 'BUDGET_TYPES'
         OR x_dimension_table IS NULL ) THEN

	 IF (dim_bgt_type = 'E') THEN
           -- Collect Budget Types
           pa_adw_collect_dimensions.get_dim_budget_types (x_err_stage, x_err_stack, x_err_code);
	 END IF;

       END IF;
       IF ( x_dimension_table = 'PERIODS'
         OR x_dimension_table IS NULL ) THEN

	 IF (dim_time = 'E') THEN
           -- Collect Periods
           pa_adw_collect_dimensions.get_dim_periods (x_err_stage, x_err_stack, x_err_code);
	 END IF;

       END IF;
       IF ( x_dimension_table = 'SERVICE_TYPES'
         OR x_dimension_table IS NULL ) THEN

	 IF (dim_srvc_type = 'E') THEN
           -- Collect Service Types
           pa_adw_collect_dimensions.get_dim_service_types (x_err_stage, x_err_stack, x_err_code);
	 END IF;

       END IF;
       IF ( x_dimension_table = 'ORGANIZATIONS'
         OR x_dimension_table IS NULL ) THEN

	 IF (dim_project_org = 'E' OR dim_exp_org = 'E'
	     OR dim_operating_unit = 'E' ) THEN
           -- Collect Organizations
           pa_adw_collect_dimensions.get_dim_organizations (x_err_stage, x_err_stack, x_err_code);
	 END IF;

       END IF;

       -- Collect Custom Dimensions

       IF ( x_dimension_table = 'CUSTOM_DIMENSIONS_TABLES'
         OR x_dimension_table IS NULL ) THEN

         pa_adw_custom_collect.get_dimension_tables
			(x_err_stage,
			 x_err_stack,
			 x_err_code,
			 'I');  -- Incremental Collection
       END IF;

       -- Commit Collected Dimensions
       COMMIT;
     END IF; -- IF ( x_collect_dim_tables = 'Y')

     IF ( x_collect_fact_tables = 'Y') THEN

       -- Collect fact tables

       IF ( x_fact_table = 'ACTUALS_COST_AND_COMMITMENTS'
         OR x_fact_table IS NULL ) THEN

             -- Collect Actuals and commitments
             pa_adw_collect_facts.get_fact_act_cmts
                    (x_project_num_from,
                     x_project_num_to,
		     x_err_stage,
                     x_err_stack,
                     x_err_code);
       END IF;

       IF ( x_fact_table = 'BUDGETS'
         OR x_fact_table IS NULL ) THEN

             -- Collect Budgets
             pa_adw_collect_facts.get_fact_budgets
                    (x_project_num_from,
                     x_project_num_to,
		     x_err_stage,
                     x_err_stack,
                     x_err_code);

       END IF;

       -- Collect Custom fact Tables

       IF ( x_fact_table = 'CUSTOM_FACT_TABLES'
         OR x_fact_table IS NULL ) THEN

          -- Collect Custom Fact Tables
          pa_adw_custom_collect.get_fact_tables
                    (x_project_num_from,
                     x_project_num_to,
		     x_err_stage,
                     x_err_stack,
                     x_err_code,
                     'I');  -- Incremental Collection
       END IF;

       -- Commit Collected Fact Tables
       COMMIT;
     END IF; -- IF ( x_collect_fact_tables = 'Y')

     -- purge interface tables

     pa_adw_collect_main.purge_interface_tables
                        ( x_err_stage,
                          x_err_stack,
                          x_err_code);

     x_err_stack := x_old_err_stack;

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        pa_debug.debug('Exception Generated By Oracle Error: ' || SQLERRM(SQLCODE),
                        pa_debug.DEBUG_LEVEL_EXCEPTION);
        ROLLBACK WORK;
        return;
   END get_dim_and_fact_main;

   -- Procedure to refresh the dimension tables/fact tables from scratch
   -- This procedure need to followed when the user changes
   -- dimension after initial collection.
   -- If integrating with OADW then the entire warehouse need to be
   -- built again.

   PROCEDURE ref_dim_and_fact_main
                        ( x_err_stage            IN OUT VARCHAR2,
                          x_err_stack            IN OUT VARCHAR2,
                          x_err_code             IN OUT NUMBER)
   IS
     x_old_err_stack	VARCHAR2(1024);
   BEGIN
     x_err_code      := 0;
     x_err_stage     := 'Refreshing Dimensions and Fact Tables';
     x_old_err_stack := x_err_stack;
     x_err_stack     := x_err_stack || '-> ref_dim_and_fact_main';

     pa_debug.debug(x_err_stage);

     -- Call the initialize procedure

     x_err_code := pa_adw_collect_main.initialize;

     -- Check the license status

     IF ( license_status <> 'Y' ) THEN
	 pa_debug.debug('Oracle Project Analysis Collection Pack Not Licensed',
			 pa_debug.DEBUG_LEVEL_EXCEPTION);
	 x_err_stage  := 'Oracle Project Analysis Collection Pack Not Licensed';
	 x_err_code   := 2;
	 ROLLBACK WORK;
	 return;
     END IF; -- IF ( license_status <> 'Y' )

     -- Prepare source table for refresh

     pa_adw_collect_main.prepare_src_table_for_refresh
                        ( x_err_stage,
                          x_err_stack,
                          x_err_code);

     -- Clear interface tables

     pa_adw_collect_main.clear_interface_tables
                        ( x_err_stage,
                          x_err_stack,
                          x_err_code);

     -- Collect dimension tables
     -- get the dimension statuses

     pa_adw_collect_main.get_dimension_status
                        ( x_err_stage,
                          x_err_stack,
                          x_err_code);

     IF (dim_project = 'E') THEN
           -- Collect Tasks
           pa_adw_collect_dimensions.get_dim_tasks (x_err_stage, x_err_stack, x_err_code);
     END IF;

     IF (dim_project = 'E') THEN
           -- Collect Projects
           pa_adw_collect_dimensions.get_dim_projects (x_err_stage, x_err_stack, x_err_code);
     END IF;

     IF (dim_project = 'E') THEN
           -- Collect Project Types
           pa_adw_collect_dimensions.get_dim_project_types (x_err_stage, x_err_stack, x_err_code);
     END IF;

     IF (dim_exp_type = 'E') THEN
           -- Collect Project Types
           pa_adw_collect_dimensions.get_dim_expenditure_types (x_err_stage, x_err_stack, x_err_code);
     END IF;

     IF (dim_project = 'E') THEN
           -- Collect Project Classes
           pa_adw_collect_dimensions.get_dim_project_classes (x_err_stage, x_err_stack, x_err_code);
     END IF;

     IF (dim_project = 'E') THEN
           -- Collect Class Categories
           pa_adw_collect_dimensions.get_dim_class_categories (x_err_stage, x_err_stack, x_err_code);
     END IF;

     IF (dim_project = 'E') THEN
           -- Collect Class Codes
           pa_adw_collect_dimensions.get_dim_class_codes (x_err_stage, x_err_stack, x_err_code);
     END IF;

     IF (dim_resource = 'E') THEN
           -- Collect Resources
           pa_adw_collect_dimensions.get_dim_resources (x_err_stage, x_err_stack, x_err_code);
     END IF;

     IF (dim_resource = 'E') THEN
           -- Collect Resource Lists
           pa_adw_collect_dimensions.get_dim_resource_lists (x_err_stage, x_err_stack, x_err_code);
     END IF;

     IF (dim_bgt_type = 'E') THEN
           -- Collect Budget Types
           pa_adw_collect_dimensions.get_dim_budget_types (x_err_stage, x_err_stack, x_err_code);
     END IF;

     IF (dim_time = 'E') THEN
           -- Collect Periods
           pa_adw_collect_dimensions.get_dim_periods (x_err_stage, x_err_stack, x_err_code);
     END IF;

     IF (dim_srvc_type = 'E') THEN
           -- Collect Service Types
           pa_adw_collect_dimensions.get_dim_service_types (x_err_stage, x_err_stack, x_err_code);
     END IF;

     IF (dim_project_org = 'E' OR dim_exp_org = 'E'
	     OR dim_operating_unit = 'E' ) THEN
           -- Collect Organizations
           pa_adw_collect_dimensions.get_dim_organizations (x_err_stage, x_err_stack, x_err_code);
     END IF;

     -- Collect Custom Dimensions

     pa_adw_custom_collect.get_dimension_tables
		    (x_err_stage,
		     x_err_stack,
		     x_err_code,
                     'R'); -- refresh process
     -- Commit Collected Dimensions
     COMMIT;

     -- Collect fact tables

     -- Collect Actuals and commitments
     pa_adw_collect_facts.get_fact_act_cmts
                    (NULL,   -- x_project_num_from
                     NULL,   -- x_project_num_to
		     x_err_stage,
                     x_err_stack,
                     x_err_code);

     -- Collect Budgets
     pa_adw_collect_facts.get_fact_budgets
                    (NULL,   -- x_project_num_from
                     NULL,   -- x_project_num_to
		     x_err_stage,
                     x_err_stack,
                     x_err_code);

     -- Collect Custom Fact Tables
     pa_adw_custom_collect.get_fact_tables
                    (NULL,   -- x_project_num_from
                     NULL,   -- x_project_num_to
		     x_err_stage,
                     x_err_stack,
                     x_err_code,
                     'R'); -- refresh process
     -- Commit Collected Fact Tables
     COMMIT;

     x_err_stack := x_old_err_stack;

   EXCEPTION
      WHEN OTHERS THEN
        x_err_code := SQLCODE;
        pa_debug.debug('Exception Generated By Oracle Error: ' || SQLERRM(SQLCODE),
                        pa_debug.DEBUG_LEVEL_EXCEPTION);
        ROLLBACK WORK;
        return;
   END ref_dim_and_fact_main;

END PA_ADW_COLLECT_MAIN;

/
