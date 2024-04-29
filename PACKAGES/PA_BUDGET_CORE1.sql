--------------------------------------------------------
--  DDL for Package PA_BUDGET_CORE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGET_CORE1" AUTHID CURRENT_USER as
-- $Header: PAXBUBDS.pls 120.3.12010000.3 2008/09/29 14:21:49 bifernan ship $

  procedure copy_actual (x_project_id		     in     number,
			 x_version_id                in     number,
			 x_budget_entry_method_code  in     varchar2,
			 x_resource_list_id          in     number,
			 x_start_period		     in     varchar2,
			 x_end_period		     in     varchar2,
		         x_err_code                  in out NOCOPY number, --File.Sql.39 bug 4440895
		         x_err_stage	  	     in out NOCOPY varchar2, --File.Sql.39 bug 4440895
		         x_err_stack         	     in out NOCOPY varchar2); --File.Sql.39 bug 4440895

 procedure copy_draft_lines  (x_src_version_id           in     number,
                               x_time_phased_type_code    in     varchar2,
                               x_entry_level_code         in     varchar2,
                               x_dest_version_id          in     number,
                               x_err_code                 in out NOCOPY number, --File.Sql.39 bug 4440895
                               x_err_stage                in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                               x_err_stack                in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                               x_pm_flag                  in     varchar2 );

-- added for bug 4390421
-- This function is wrapper over pa_accum_utils.get_first_accum_period
-- It will be used in the value set to get the first accumulation period
-- for a project
 function get_first_accum_period ( x_project_id       in number,
                                   x_budget_type_code in varchar2)
          return date;

-- Global variables addded to tackle performance issue at the time of
-- calling function get_first_accum_period from value set.
  g_project_id          pa_projects_all.project_id%type;
  g_budget_type_code    pa_budget_versions.budget_type_code%type;
  g_start_period_date   pa_periods_all.start_date%type;
  g_calling_mode        varchar2(100) default 'FORM';

-- Wrapper procedure for copy_actual called from concurrent request
  procedure copy_actuals1 (errbuf                      IN OUT NOCOPY varchar2, --File.Sql.39 bug 4440895
                          retcode                     IN OUT NOCOPY varchar2, --File.Sql.39 bug 4440895
                          x_project_id                in     number,
                          x_budget_type_code          in     varchar2,
                          x_start_period              in     varchar2,
                          x_end_period                in     varchar2);

-- added for bug 4390421

  -- Record Type added for Bug 4889056
   TYPE CopyActualRecord  IS RECORD  (period_name                pa_periods_all.period_name%type,
                                      Start_Date                 DATE,
                                      End_Date                   DATE,
                                      task_id                    NUMBER,
                                      resource_list_member_id    NUMBER,
                                      resource_id                NUMBER,
                                      track_as_labor_flag        pa_resources.track_as_labor_flag%type,
                                      Revenue                    NUMBER,
                                      Raw_Cost                   NUMBER,
                                      Burdened_Cost              NUMBER,
                                      Quantity                   NUMBER,
                                      labor_hours                NUMBER,
                                      billable_raw_cost          NUMBER,
                                      billable_burdened_cost     NUMBER,
                                      billable_quantity          NUMBER,
                                      billable_labor_hours       NUMBER,
                                      cmt_raw_cost               NUMBER,
                                      cmt_burdened_cost          NUMBER,
                                      unit_of_measure            pa_resources.unit_of_measure%type);


   TYPE CopyActualTabTyp IS TABLE OF CopyActualRecord INDEX BY BINARY_INTEGER;
   -- End Record Type added for Bug 4889056

-- Start for bug 6509313
PROCEDURE rollup_amounts_rg(
                       X_Resource_Assignment_Id  IN OUT NOCOPY NUMBER,
                       X_Budget_Version_Id              NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Resource_List_Member_Id IN OUT NOCOPY NUMBER,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Period_Name                    VARCHAR2,
                       X_Quantity                       NUMBER,
                       X_Unit_Of_Measure                VARCHAR2,
                       X_Track_As_Labor_Flag            VARCHAR2,
                       X_Raw_Cost                       NUMBER,
                       X_Burdened_Cost                  NUMBER,
                       X_Revenue                        NUMBER
                       );
-- End for bug 6509313

end pa_budget_core1 ;

/
