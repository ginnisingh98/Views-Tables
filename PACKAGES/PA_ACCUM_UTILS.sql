--------------------------------------------------------
--  DDL for Package PA_ACCUM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ACCUM_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAACUTIS.pls 120.1 2005/08/19 16:15:06 mwasowic noship $ */
-- This package contains the following procedures

-- Proj_level_record -  This verifies for the existence of the Project level
--                      record (Task id = 0 and Resource list member id = 0)
--                      If available, returns the Project_Accum_id else
--                      creates a record in PA_PROJECT_ACCUM_HEADERS and
--                      returns the Project_Accum_Id

-- Get_Impl_Option   -  This returns the Accumulation option as specified
--                      in PA_IMPLEMENTATIONS table . Returns whether
--                      accumulation is maintained by PA_PERIOD or GL_PERIOD

-- Get_Current_period_Info - This returns all relevant details pertaining
--                           to the current pa period

-- Get_pa_period_info      - This returns all details pertaining to the
--                           following
--                           Current Pa period,Previous pa period, current
--                           gl period , previous gl period, year pertaining
--                           to the previously accumulated period

-- Check_Actuals_Details   - For the given Project,Task and Resource
--                           combination in the PA_PROJECT_ACCUM_HEADERS table,
--                           checks for detail records in
--                           PA_PROJECT_ACCUM_ACTUALS table. It is possible
--                           that the Headers table might have a record
--                           but no corresponding detail record. This procedure
--                           creates the detail records for all the tasks in
--                           the hierarchy

-- Check_Cmt_Details       - For the given Project,Task and Resource
--                           combination in the PA_PROJECT_ACCUM_HEADERS table,
--                           checks for detail records in
--                           PA_PROJECT_ACCUM_COMMITMENTS table. It is possible
--                           that the Headers table might have a record
--                           but no corresponding detail record. This procedure
--                           creates the detail records for all the tasks in
--                           the hierarchy


-- Check_Budget_Details    - For the given Project,Task and Resource
--                           combination in the PA_PROJECT_ACCUM_HEADERS table,
--                           checks for detail records in
--                           PA_PROJECT_ACCUM_COMMITMENTS table. It is possible
--                           that the Headers table might have a record
--                           but no corresponding detail record. This procedure
--                           creates the detail records for all the tasks in
--                           the hierarchy

-- Get_Config_Option      -  For the given Accumulation Category
--                           checks whether the given column is configured
--                           for Accumulation. The Accum_flag 'Y' or 'N'
--                           determines whether the said column is to be
--                           accumulated or not

-- Get_existing_higher_tasks - For the given task, returns all the higher level
--                             tasks which are available in
--                             PA_PROJECT_ACCUM_HEADERS .

-- set_check_reporting_end_Date This sets the global variable to the end date of the reporting
--				period for which the user wants to check
--				project summarization information.
--
-- get_check_reporting_end_date This returns the end date of the currently set reporting period
--				for which the user wants to check project
--				summarization information.  If the global
--				variable has not been set, this returns the
--				current reporting period

-- Set_current_period_info      This procedure sets the global variables
--                              g_current_pa_period and g_current_gl_period

-- Get_current_pa_period        This function returns the value of the global
--                              variable g_current_pa_period, if set, else it
--                              fetches pa period from database

-- Get_current_gl_period        This function returns the value of the global
--                              variable g_current_gl_period, if set, else it
--                              fetches gl period from database

-- Get_Project_Info		This function returns the value of the global
--				variables G_start_proj or G_end_proj
--				conditionally (depending on the value of
--				the parameter passed)

-- Get_Context_Info		This function returns the value of the global
--				variable G_context

-- Get_Grouping_Id		This function returns the value of the global
--				variable G_grouping_id


-- Package global variable to hold reporting period name used for summarization
-- checks
g_check_reporting_end_date	date;

-- Package global variables for current PA and GL Periods

g_current_pa_period             varchar2(20);  -- current PA period
g_current_gl_period             varchar2(15);  -- current GL period

-- Global variables defined as part of Project Allocation Enhancements
G_context		        VARCHAR2(25);
G_start_proj		        VARCHAR2(25);
G_end_proj		        VARCHAR2(25);
G_grouping_id	     	        NUMBER;

PROCEDURE set_current_period_info ;

FUNCTION Get_current_pa_period RETURN Varchar2;
PRAGMA RESTRICT_REFERENCES( Get_current_pa_period, WNDS,WNPS );

FUNCTION Get_current_gl_period RETURN Varchar2;
PRAGMA RESTRICT_REFERENCES( Get_current_gl_period, WNDS,WNPS );

TYPE task_id_tabtype IS TABLE OF PA_TASKS.TASK_ID%TYPE INDEX BY BINARY_INTEGER;
Procedure  Proj_level_record (X_project_id In Number,
                              X_current_pa_period In Varchar2,
                              X_current_gl_period In Varchar2,
                              X_impl_Option  In Varchar2,
                              X_accum_id Out NOCOPY Number, --File.Sql.39 bug 4440895
                              X_Prev_Accum_period Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

Procedure    Get_Impl_Option (X_Impl_Option Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895


Procedure Get_Current_period_Info (X_Current_Pa_Period  Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                   X_Current_gl_period Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                   x_current_pa_start_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                                   x_current_pa_end_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                                   x_current_gl_start_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                                   x_current_gl_end_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                                   x_current_year      Out NOCOPY Number, --File.Sql.39 bug 4440895
                                   x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                   x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                   x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895


Procedure Get_pa_period_Info
                     (X_impl_opt  In Varchar2,
                      X_Prev_Accum_period in Varchar2,
                      X_Current_Pa_Period In Varchar2,
                      X_Current_gl_period In Varchar2,
                      x_current_pa_start_date In Date,
                      x_current_pa_end_date In Date,
                      x_current_gl_start_date In Date,
                      x_current_gl_end_date In Date,
                      X_Prev_pa_period    Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                      X_prev_gl_period    Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                      x_prev_pa_year      Out NOCOPY Number, --File.Sql.39 bug 4440895
                      x_prev_gl_year      Out NOCOPY Number, --File.Sql.39 bug 4440895
                      x_prev_accum_year   Out NOCOPY number, --File.Sql.39 bug 4440895
                      x_prev_pa_start_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                      x_prev_pa_end_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                      x_prev_gl_start_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                      x_prev_gl_end_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                      x_prev_accum_start_date In Out NOCOPY Date, --File.Sql.39 bug 4440895
                      x_prev_accum_end_date Out NOCOPY Date, --File.Sql.39 bug 4440895
		      x_prev_prev_accum_period Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                      x_accum_period_type_changed IN OUT NOCOPY BOOLEAN, --File.Sql.39 bug 4440895
                      x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                      x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                      x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895


Procedure Check_Actuals_Details    ( x_project_id In Number,
                                     x_task_id    In Number,
                                     x_resource_list_member_id In Number,
                                     x_recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                     x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                     x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                     x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

Procedure Check_Cmt_Details        ( x_project_id In Number,
                                     x_task_id    In Number,
                                     x_resource_list_member_id In Number,
                                     x_recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                     x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                     x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                     x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

Procedure Check_Budget_Details    (  x_project_id In Number,
                                     x_task_id    In Number,
                                     x_resource_list_member_id In Number,
                                     x_Budget_type_code     In Varchar2,
                                     x_recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                     x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                     x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                     x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895


Procedure Get_Config_Option  (X_project_id In Number,
                              x_Accum_category_code In Varchar2,
                              x_Accum_column_code In Varchar2,
                              x_Accum_Flag        Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_code In Out NOCOPY Number, --File.Sql.39 bug 4440895
                              x_err_stage In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_stack In Out NOCOPY Varchar2 ) ; --File.Sql.39 bug 4440895

Procedure   Get_existing_higher_tasks (x_project_id in Number,
                                       X_task_id in Number,
                                       X_resource_list_member_id In Number,
                                       x_task_array  Out NOCOPY task_id_tabtype, --File.Sql.39 bug 4440895
                                       x_noof_tasks Out NOCOPY number, --File.Sql.39 bug 4440895
                                       x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

Procedure   update_proj_accum_header (x_project_accum_id  IN  Number,
                                      x_accum_period      IN  Varchar2,
                                    x_err_stack         IN OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_stage         IN OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_code          IN OUT NOCOPY Number ); --File.Sql.39 bug 4440895

Procedure   update_tasks_restructured_flag (x_project_accum_id  IN  Number,
                                           x_tasks_restructured_flag IN  Varchar2,
                                           x_err_stack         IN OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                           x_err_stage         IN OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                           x_err_code          IN OUT NOCOPY Number ); --File.Sql.39 bug 4440895

Procedure   check_tasks_restructured_flag (x_project_accum_id  IN  Number,
                                           x_tasks_restructured_flag IN OUT  NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                           x_err_stack         IN OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                           x_err_stage         IN OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                           x_err_code          IN OUT NOCOPY Number ); --File.Sql.39 bug 4440895

PROCEDURE   get_first_accum_period
		 (x_project_id                IN         NUMBER,
		  x_resource_list_id          IN         NUMBER   DEFAULT NULL,
		  x_amount_type               IN         VARCHAR2 DEFAULT 'C',
		  x_period_type               IN         VARCHAR2 DEFAULT 'P',
		  x_period_name            IN OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_period_start_date      IN OUT        NOCOPY DATE, --File.Sql.39 bug 4440895
                  x_err_code               IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
                  x_err_stage              IN OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_stack              IN OUT        NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE   set_check_reporting_end_date
		( x_period_name			IN 	VARCHAR2);
 PRAGMA RESTRICT_REFERENCES( set_check_reporting_end_date, WNDS );

FUNCTION   get_check_reporting_end_date
		return date;
-- PRAGMA RESTRICT_REFERENCES( get_check_reporting_end_date, WNDS );

PROCEDURE  Get_period_year_Info
		(x_current_gl_period	  In Varchar2,
                 x_period_yr_start_date   Out NOCOPY Date, --File.Sql.39 bug 4440895
                 x_err_stack              In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                 x_err_stage              In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                 x_err_code               In Out NOCOPY Number ); --File.Sql.39 bug 4440895

FUNCTION Get_spread_amount_val
		(x_from_date	 	IN DATE,
	         x_to_date	 	IN DATE,
	         x_amt_to_be_spread	IN NUMBER,
	         x_which_date_flag	IN VARCHAR2)
		 RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(Get_spread_amount_val, WNDS,WNPS );

Function Get_Project_Info
		(x_From_Or_To 		IN Varchar2)
		Return Varchar2;
PRAGMA RESTRICT_REFERENCES(Get_Project_Info, WNDS,WNPS );

Function Get_Context_Info
		Return Varchar2;
PRAGMA RESTRICT_REFERENCES(Get_Context_Info, WNDS,WNPS );

Function Get_Grouping_Id
		Return Number;
PRAGMA RESTRICT_REFERENCES(Get_Grouping_Id, WNDS,WNPS );


/*********************************************************************************
   New procedures added for the performance issue 3653978
*********************************************************************************/

Procedure Get_pa_period_Info1
                     (X_impl_opt  In Varchar2,
                      x_current_pa_start_date In Date,
                      x_current_gl_start_date In Date,
                      X_Prev_pa_period    Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                      X_prev_gl_period    Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                      x_prev_pa_year      Out NOCOPY Number, --File.Sql.39 bug 4440895
                      x_prev_gl_year      Out NOCOPY Number, --File.Sql.39 bug 4440895
                      x_prev_pa_start_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                      x_prev_pa_end_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                      x_prev_gl_start_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                      x_prev_gl_end_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                      x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                      x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                      x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

Procedure Get_pa_period_Info2
                     (X_impl_opt  In Varchar2,
                      X_Prev_Accum_period in Varchar2,
                      x_prev_accum_year   Out NOCOPY number, --File.Sql.39 bug 4440895
                      x_prev_accum_start_date In Out NOCOPY Date, --File.Sql.39 bug 4440895
                      x_prev_accum_end_date Out NOCOPY Date, --File.Sql.39 bug 4440895
              		      x_prev_prev_accum_period Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                      x_accum_period_type_changed IN OUT NOCOPY BOOLEAN, --File.Sql.39 bug 4440895
                      x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                      x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                      x_err_code      In Out NOCOPY Number ); --File.Sql.39 bug 4440895

/*********************************************************************************
   End. New procedures added for the performance issue 3653978
*********************************************************************************/

End PA_ACCUM_UTILS;

 

/
