--------------------------------------------------------
--  DDL for Package GMS_BUDGET_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_BUDGET_UTILS" AUTHID CURRENT_USER AS
/* $Header: gmsbubus.pls 120.4 2006/04/11 22:59:58 cmishra noship $ */

  g_entry_level_code             varchar2(1);
  g_task_id                      pa_tasks.task_id%TYPE;
  g_task_number                  pa_tasks.task_name%TYPE;

  --
   /****************************************************************
   This function returns a value 'Y' if the UOM passed is a currency
   UOM. Otherwise it returns 'N'.
   ******************************************************************/
  Function Check_Currency_Uom (x_uom_code in varchar2) return varchar2 ;
--	pragma RESTRICT_REFERENCES  (Check_Currency_Uom, WNDS, WNPS );

   /****************************************************************
   This function returns the value of budget amount code associated
   with the budget type. Budget Amount Code determines whether its a
   cost or a revenue budget.
   ******************************************************************/
  Function get_budget_amount_code(x_budget_type_code in varchar2) return varchar2 ;
--	pragma RESTRICT_REFERENCES  ( get_budget_amount_code, WNDS, WNPS );

  procedure get_draft_version_id (x_project_id        in     number,
                                  x_award_id          in     number,
                                  x_budget_type_code  in     varchar2,
                                  x_budget_version_id in out NOCOPY number,
                                  x_err_code          in out NOCOPY number,
                                  x_err_stage         in out NOCOPY varchar2,
                                  x_err_stack         in out NOCOPY varchar2);

  procedure get_baselined_version_id (x_project_id    in     number,
                                  x_award_id          in     number,
                                  x_budget_type_code  in     varchar2,
                                  x_budget_version_id in out NOCOPY number,
                                  x_err_code          in out NOCOPY number,
                                  x_err_stage         in out NOCOPY varchar2,
                                  x_err_stack         in out NOCOPY varchar2);

  procedure get_original_version_id (x_project_id    in     number,
                                  x_award_id          in     number,
                                  x_budget_type_code  in     varchar2,
                                  x_budget_version_id in out NOCOPY number,
                                  x_err_code          in out NOCOPY number,
                                  x_err_stage         in out NOCOPY varchar2,
                                  x_err_stack         in out NOCOPY varchar2);

  procedure get_default_resource_list_id (x_project_id    in     number,
                                  x_award_id          in     number,
                                  x_budget_type_code  in     varchar2,
                                  x_resource_list_id  in out NOCOPY number,
                                  x_err_code          in out NOCOPY number,
                                  x_err_stage         in out NOCOPY varchar2,
                                  x_err_stack         in out NOCOPY varchar2);

  procedure get_default_entry_method_code (x_project_id       in     number,
                                  x_budget_type_code          in     varchar2,
                                  x_budget_entry_method_code  in out NOCOPY varchar2,
                                  x_err_code                  in out NOCOPY number,
                                  x_err_stage                 in out NOCOPY varchar2,
                                  x_err_stack                 in out NOCOPY varchar2);

  function get_budget_type_code (x_budget_type in varchar2) return varchar2;

  function get_budget_entry_method_code (x_budget_entry_method in varchar2)
						return varchar2;

  function get_change_reason_code (x_meaning in varchar2) return varchar2;

  function check_proj_budget_exists (x_project_id in number,
                                     x_award_id number,
                                     x_budget_status_code varchar2,
				     x_budget_type_code varchar2 default NULL)
						return number;

  function check_task_budget_exists (x_task_id in number,
                                     x_award_id number,
                                     x_budget_status_code varchar2,
				     x_budget_type_code varchar2 default NULL)
						return number;

  function check_resource_member_level(x_resource_list_member_id in number,
				       x_parent_member_id in number,
				       x_budget_version_id in number,
				       x_task_id in number)
						return number;

  Procedure check_overlapping_dates ( x_budget_version_id in number,
                                       x_resource_name    in out NOCOPY varchar2,
                                       x_err_code         in out NOCOPY number);

  /*-------------------------------------------------------------------+
   | The get_proj_budget_amount is to get proper budget amount for the |
   | given project, budget type, and budget version type.	       |
   |								       |
   | Parameters:						       |
   |								       |
   |	1. x_project_id		project id			       |
   |	2. x_budget_type	budget type code		       |
   |	3. x_which_version  	'DRAFT', 'ORIGINAL', or 'CURRENT'.     |
   |	4. x_revenue_amount	budget revenue			       |
   |	5. x_raw_cost		budget raw cost			       |
   |	6. x_burdened_cost	budget burdened cost		       |
   |	7. x_labor_quantity	budget labor quantity		       |
   |								       |
   | The (x_project_id, x_budget_type, x_which_version) input values   |
   | must be given. The x_which_version value must be one of the       |
   | above three values (DRAFT/ORIGINAL/CURRENT).		       |
   |								       |
   | If there is no budget for the given project or you pass in bad    |
   | values, the procedure will return $0 budget amount back to the    |
   | caller. The calling module should handle the error handling.      |
   +-------------------------------------------------------------------*/
  procedure get_proj_budget_amount(
			      x_project_id 	in	number,
			      x_award_id        in      number,
			      x_budget_type	in	varchar2,
			      x_which_version	in	varchar2,
                              x_revenue_amount 	out NOCOPY 	real,
                              x_raw_cost  	out NOCOPY 	real,
                              x_burdened_cost  	out NOCOPY 	real,
                              x_labor_quantity 	out NOCOPY 	real);

  /*-------------------------------------------------------------------+
   | The get_task_budget_amount is to get proper budget amount for the |
   | given project, budget type, and budget version type.              |
   |                                                                   |
   | Parameters:                                                       |
   |                                                                   |
   |    1. x_project_id         project id                             |
   |    2. x_task_id         	top task id or lowest level task id    |
   |    3. x_budget_type        budget type code                       |
   |	4. x_which_version  	'DRAFT', 'ORIGINAL', or 'CURRENT'.     |
   |    5. x_revenue_amount     budget revenue                         |
   |    6. x_raw_cost           budget raw cost                        |
   |    7. x_burdened_cost      budget burdened cost                   |
   |    8. x_labor_quantity     budget labor quantity                  |
   |                                                                   |
   | The (x_project_id, x_budget_type, x_which_version) input values   |
   | must be given. The x_which_version value must be one of the       |
   | above three values (DRAFT/ORIGINAL/CURRENT).                      |
   |                                                                   |
   | If a mid-level task id is given, it will return $0 budget amount. |
   | The calling module should handle the error handling.              |
   | If there is no budget for the given project or you pass in bad    |
   | values, the procedure will return $0 budget amount back to the    |
   | caller. The calling module should handle the error handling.      |
   +-------------------------------------------------------------------*/
  procedure get_task_budget_amount(
			      x_project_id 	in	number,
			      x_task_id 	in	number,
                              x_award_id        in      number,
			      x_budget_type	in	varchar2,
			      x_which_version	in	varchar2,
                              x_revenue_amount 	out NOCOPY 	real,
                              x_raw_cost  	out NOCOPY 	real,
                              x_burdened_cost  	out NOCOPY 	real,
                              x_labor_quantity 	out NOCOPY 	real);


PROCEDURE Verify_Budget_Rules
 (p_draft_version_id		IN 	NUMBER
  , p_mark_as_original  	IN	VARCHAR2
  , p_event			IN	VARCHAR2
  , p_project_id		IN	NUMBER
  , p_award_id  		IN	NUMBER
  , p_budget_type_code		IN	VARCHAR2
  , p_resource_list_id		IN	NUMBER
  , p_project_type_class_code	IN 	VARCHAR2
  , p_created_by 		IN	NUMBER
  , p_calling_module		IN	VARCHAR2
  , p_warnings_only_flag	OUT NOCOPY	VARCHAR2
  , p_err_msg_count		OUT NOCOPY	NUMBER
  , p_err_code             	IN OUT NOCOPY	NUMBER
  , p_err_stage			IN OUT NOCOPY	VARCHAR2
  , p_err_stack			IN OUT NOCOPY	VARCHAR2
);

  /****************************************************************
   How to use API - get_project_task_totals:
   This API can be used to get the totals at the Project Level
   or at the task level. If x_task_id is passed as a null value then
   project level totals are fetched. Otherwise task level totals are
   fetched. For task level totals, first the task level is determined.
   If the task level is top or intermediate level , then the amounts
   are rolled from the child tasks.
  ******************************************************************/
  procedure get_project_task_totals(x_budget_version_id   in     number,
                            x_task_id             in     number,
                            x_quantity_total      in out NOCOPY number,
                            x_raw_cost_total      in out NOCOPY number,
                            x_burdened_cost_total in out NOCOPY number,
                            x_revenue_total       in out NOCOPY number,
                            x_err_code            in out NOCOPY number,
                            x_err_stage           in out NOCOPY varchar2,
                            x_err_stack           in out NOCOPY varchar2) ;



  Procedure set_entry_level_code(x_entry_level_code in varchar2);

 PROCEDURE get_valid_period_dates
			( x_err_code			OUT NOCOPY	NUMBER
 			,x_err_stage			OUT NOCOPY	VARCHAR2
 			,p_project_id			IN	NUMBER
			,p_task_id			IN	NUMBER
			,p_award_id			IN	NUMBER	-- Added For bug 2200867
			,p_time_phased_type_code	IN	VARCHAR2
			,p_entry_level_code		IN	VARCHAR2
			,p_period_name_in		IN	VARCHAR2
			,p_budget_start_date_in	IN	DATE
			,p_budget_end_date_in		IN	DATE
			,p_period_name_out		OUT NOCOPY	VARCHAR2
			,p_budget_start_date_out	OUT NOCOPY	DATE
			,p_budget_end_date_out		OUT NOCOPY	DATE	);

PROCEDURE check_entry_method_flags
			( x_err_code			OUT NOCOPY	NUMBER
			,x_err_stage			OUT NOCOPY	VARCHAR2
			,p_budget_amount_code		IN	VARCHAR2
			,p_budget_entry_method_code	IN	VARCHAR2
			,p_quantity			IN	VARCHAR2
			,p_raw_cost			IN	VARCHAR2
			,p_burdened_cost		IN 	VARCHAR2);


  Function get_entry_level_code return varchar2;
--        pragma RESTRICT_REFERENCES  ( get_entry_level_code, WNDS, WNPS );

  Procedure set_cross_bg_profile;

-- Added the following procedure
-- R12 MOAC
  -- Added the procedure to set single project/OU context.
  -- Had to add x_err_code to list to accomodate historical procedure standard
  -- used by the Budget Approval workflow.

  Procedure Set_Award_Policy_Context
             (
              p_award_id                      IN            NUMBER
              , x_msg_count                     OUT NOCOPY    NUMBER
              , x_msg_data                      OUT NOCOPY    VARCHAR2
              , x_return_status                 OUT NOCOPY    VARCHAR2
              , x_err_code                      OUT NOCOPY    NUMBER
             );

-- Bug 5045636 : Created the procedure get_task_number to fetch the task_name for a particular task_id.
FUNCTION get_task_number(P_task_Id  IN NUMBER) RETURN VARCHAR2;

END gms_budget_utils ;

 

/
