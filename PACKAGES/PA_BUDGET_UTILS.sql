--------------------------------------------------------
--  DDL for Package PA_BUDGET_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGET_UTILS" AUTHID CURRENT_USER AS
-- $Header: PAXBUBUS.pls 120.4 2007/02/06 10:14:20 dthakker ship $


  ---------------------------------------------------------
  ---  GLOBAL VARIABLES
  ---------------------------------------------------------

  g_entry_level_code             varchar2(1);


  -- Verify_Budget_Rules API ------------------------------
  --   Added this global, which is populated by the Budgets form via a function call to this package.

  G_Bgt_Intg_Flag               VARCHAR2(1) :=NULL;


  -- Get_Project_Currency_Info API ------------------------
  -- These globals will be populated by the API when the p_project_id IN-parameter varies from the
  -- G_Project_Id global.

  G_Project_id   		pa_projects_all.project_id%TYPE := -1;

  G_Projfunc_Currency_Code	pa_projects_all.projfunc_currency_code%TYPE := NULL;

  G_Project_Currency_Code	pa_projects_all.project_currency_code%TYPE := NULL;

  G_Txn_Currency_Code	        pa_projects_all.projfunc_currency_code%TYPE := NULL;











  ---------------------------------------------------------
  ---  FUNCTIONS AND PROCEDURES
  ---------------------------------------------------------


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
                                  x_budget_type_code  in     varchar2,
                                  x_budget_version_id in out NOCOPY number, --File.Sql.39 bug 4440895
                                  x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                                  x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                  x_err_stack         in out NOCOPY varchar2); --File.Sql.39 bug 4440895

  procedure get_baselined_version_id (x_project_id    in     number,
                                  x_budget_type_code  in     varchar2,
                                  x_budget_version_id in out NOCOPY number, --File.Sql.39 bug 4440895
                                  x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                                  x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                  x_err_stack         in out NOCOPY varchar2); --File.Sql.39 bug 4440895

  procedure get_original_version_id (x_project_id    in     number,
                                  x_budget_type_code  in     varchar2,
                                  x_budget_version_id in out NOCOPY number, --File.Sql.39 bug 4440895
                                  x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                                  x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                  x_err_stack         in out NOCOPY varchar2); --File.Sql.39 bug 4440895

  procedure get_default_resource_list_id (x_project_id    in     number,
                                  x_budget_type_code  in     varchar2,
                                  x_resource_list_id  in out NOCOPY number, --File.Sql.39 bug 4440895
                                  x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                                  x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                  x_err_stack         in out NOCOPY varchar2); --File.Sql.39 bug 4440895

  procedure get_default_entry_method_code (x_project_id       in     number,
                                  x_budget_type_code          in     varchar2,
                                  x_budget_entry_method_code  in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                  x_err_code                  in out NOCOPY number, --File.Sql.39 bug 4440895
                                  x_err_stage                 in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                  x_err_stack                 in out NOCOPY varchar2); --File.Sql.39 bug 4440895

  function get_budget_type_code (x_budget_type in varchar2) return varchar2;

  function get_budget_entry_method_code (x_budget_entry_method in varchar2)
						return varchar2;

  function get_change_reason_code (x_meaning in varchar2) return varchar2;

  function check_proj_budget_exists (x_project_id             in number,
                                     x_budget_status_code     IN varchar2,
				     x_budget_type_code       IN varchar2 default NULL,
                                     x_fin_plan_type_id       IN NUMBER   default NULL,
                                     x_version_type           IN VARCHAR2 default NULL
                                    ) return number;

  function check_task_budget_exists (x_task_id                in number,
				     x_budget_status_code     IN varchar2,
				     x_budget_type_code       IN varchar2 default NULL,
                                     x_fin_plan_type_id       IN NUMBER   default NULL,
                                     x_version_type           IN VARCHAR2 default NULL
				    ) return number;

  function check_resource_member_level(x_resource_list_member_id in number,
				       x_parent_member_id in number,
				       x_budget_version_id in number,
				       x_task_id in number)
						return number;

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
			      x_budget_type	in	varchar2,
			      x_which_version	in	varchar2,
                              x_revenue_amount 	out 	NOCOPY real, --File.Sql.39 bug 4440895
                              x_raw_cost  	out 	NOCOPY real, --File.Sql.39 bug 4440895
                              x_burdened_cost  	out 	NOCOPY real, --File.Sql.39 bug 4440895
                              x_labor_quantity 	out 	NOCOPY real); --File.Sql.39 bug 4440895

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
			      x_budget_type	in	varchar2,
			      x_which_version	in	varchar2,
                              x_revenue_amount 	out 	NOCOPY real, --File.Sql.39 bug 4440895
                              x_raw_cost  	out 	NOCOPY real, --File.Sql.39 bug 4440895
                              x_burdened_cost  	out 	NOCOPY real, --File.Sql.39 bug 4440895
                              x_labor_quantity 	out 	NOCOPY real); --File.Sql.39 bug 4440895

  procedure delete_draft (x_budget_version_id   in     number,
                          x_err_code            in out NOCOPY number, --File.Sql.39 bug 4440895
                          x_err_stage           in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                          x_err_stack           in out NOCOPY varchar2); --File.Sql.39 bug 4440895

  procedure create_draft (x_project_id                in      number,
                          x_budget_type_code          in      varchar2,
                          x_version_name              in      varchar2,
                          x_description               in      varchar2,
                          x_resource_list_id          in      number,
                          x_change_reason_code        in      varchar2,
                          x_budget_entry_method_code  in      varchar2,
                          x_attribute_category        in      varchar2,
                          x_attribute1                in      varchar2,
                          x_attribute2                in      varchar2,
                          x_attribute3                in      varchar2,
                          x_attribute4                in      varchar2,
                          x_attribute5                in      varchar2,
                          x_attribute6                in      varchar2,
                          x_attribute7                in      varchar2,
                          x_attribute8                in      varchar2,
                          x_attribute9                in      varchar2,
                          x_attribute10               in      varchar2,
                          x_attribute11               in      varchar2,
                          x_attribute12               in      varchar2,
                          x_attribute13               in      varchar2,
                          x_attribute14               in      varchar2,
                          x_attribute15               in      varchar2,
                          x_budget_version_id         in out  NOCOPY number, --File.Sql.39 bug 4440895
                          x_err_code                  in out  NOCOPY number, --File.Sql.39 bug 4440895
                          x_err_stage                 in out  NOCOPY varchar2, --File.Sql.39 bug 4440895
                          x_err_stack                 in out  NOCOPY varchar2, --File.Sql.39 bug 4440895
			  x_pm_product_code           in      varchar2 default null,
			  x_pm_budget_reference       in      varchar2 default null
 				);

  procedure create_line (x_budget_version_id   in     number,
                         x_project_id          in     number,
                         x_task_id             in     number,
                         x_resource_list_member_id in number,
                         x_description         in     varchar2,
                         x_start_date          in     date,
                         x_end_date            in     date,
                         x_period_name         in     varchar2,
                         x_quantity            in out NOCOPY number, --File.Sql.39 bug 4440895
                         x_unit_of_measure     in     varchar2,
                         x_track_as_labor_flag in     varchar2,
                         x_raw_cost            in out NOCOPY number, --File.Sql.39 bug 4440895
                         x_burdened_cost       in out NOCOPY number, --File.Sql.39 bug 4440895
                         x_revenue             in out NOCOPY number, --File.Sql.39 bug 4440895
                         x_change_reason_code  in     varchar2,
                         x_attribute_category  in     varchar2,
                         x_attribute1          in     varchar2,
                         x_attribute2          in     varchar2,
                         x_attribute3          in     varchar2,
                         x_attribute4          in     varchar2,
                         x_attribute5          in     varchar2,
                         x_attribute6          in     varchar2,
                         x_attribute7          in     varchar2,
                         x_attribute8          in     varchar2,
                         x_attribute9          in     varchar2,
                         x_attribute10         in     varchar2,
                         x_attribute11         in     varchar2,
                         x_attribute12         in     varchar2,
                         x_attribute13         in     varchar2,
                         x_attribute14         in     varchar2,
                         x_attribute15         in     varchar2,
                         -- Bug Fix: 4569365. Removed MRC code.
                         -- x_mrc_flag            in     varchar2, /* FPB2: MRC */
			 x_pm_product_code     in      varchar2 default null,
			 x_pm_budget_line_reference in varchar2 default null,
			 x_quantity_source             varchar2 default 'M',
			 x_raw_cost_source             varchar2 default 'M',
			 x_burdened_cost_source        varchar2 default 'M',
			 x_revenue_source              varchar2 default 'M',
			 x_resource_assignment_id   in out NOCOPY number, --File.Sql.39 bug 4440895
		    	 x_err_code                 in out NOCOPY number, --File.Sql.39 bug 4440895
		    	 x_err_stage	            in out NOCOPY varchar2, --File.Sql.39 bug 4440895
		    	 x_err_stack                in out NOCOPY varchar2 --File.Sql.39 bug 4440895
                         );

  procedure summerize_project_totals (x_budget_version_id   in     number,
                                      x_err_code            in out NOCOPY number, --File.Sql.39 bug 4440895
                                      x_err_stage           in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                      x_err_stack           in out NOCOPY varchar2); --File.Sql.39 bug 4440895

PROCEDURE Verify_Budget_Rules
 (p_draft_version_id		IN 	NUMBER
  , p_mark_as_original  	IN	VARCHAR2
  , p_event			IN	VARCHAR2
  , p_project_id		IN	NUMBER
  , p_budget_type_code		IN	VARCHAR2
  , p_resource_list_id		IN	NUMBER
  , p_project_type_class_code	IN 	VARCHAR2
  , p_created_by 		IN	NUMBER
  , p_calling_module		IN	VARCHAR2
  , p_fin_plan_type_id          IN      NUMBER   DEFAULT NULL
  , p_version_type              IN      VARCHAR2 DEFAULT NULL
  , p_warnings_only_flag	OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , p_err_msg_count		OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
  , p_err_code             	IN OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
  , p_err_stage			IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , p_err_stack			IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);




PROCEDURE Baseline_Budget
(p_draft_version_id	         IN	NUMBER
, p_project_id 		         IN 	NUMBER
, p_mark_as_original	         IN 	VARCHAR2
, p_fck_req_flag                 IN     VARCHAR2  DEFAULT NULL
, p_verify_budget_rules	         IN     VARCHAR2  DEFAULT 'N'
, x_msg_count                   OUT     NOCOPY NUMBER  --File.Sql.39 bug 4440895
, x_msg_data                    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, x_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
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
                            x_quantity_total      in out NOCOPY number, --File.Sql.39 bug 4440895
                            x_raw_cost_total      in out NOCOPY number, --File.Sql.39 bug 4440895
                            x_burdened_cost_total in out NOCOPY number, --File.Sql.39 bug 4440895
                            x_revenue_total       in out NOCOPY number, --File.Sql.39 bug 4440895
                            x_err_code            in out NOCOPY number, --File.Sql.39 bug 4440895
                            x_err_stage           in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                            x_err_stack           in out NOCOPY varchar2) ; --File.Sql.39 bug 4440895



  Procedure set_entry_level_code(x_entry_level_code in varchar2);

  Function get_entry_level_code return varchar2;
--        pragma RESTRICT_REFERENCES  ( get_entry_level_code, WNDS, WNPS );


  Procedure Get_Version_Approved_Code
             (
               p_budget_version_id	IN      NUMBER
               , x_approved_code	OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
               , x_msg_count		OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
               , x_msg_data		OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
               , x_return_status	OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              );


  Procedure Get_Project_Currency_Info
             (
              p_project_id			IN      NUMBER
              , x_projfunc_currency_code	OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              , x_project_currency_code         OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              , x_txn_currency_code		OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              , x_msg_count			OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
              , x_msg_data			OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              , x_return_status                 OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             );


  Procedure Get_Approved_FP_Info
             (
              p_project_id			IN      NUMBER
              , x_ac_plan_type_id               OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
              , x_ar_plan_type_id               OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
              , x_ac_version_type               OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              , x_ar_version_type               OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              , x_msg_count			OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
              , x_msg_data			OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
              , x_return_status                 OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             );

  FUNCTION check_baseline_funding( x_project_id   IN  NUMBER )
             RETURN NUMBER;


  -- R12 MOAC, 19-JUL-05, jwhite
  -- Added the procedure to set single project/OU context.
  -- Had to add x_err_code to list to accomodate historical procedure standard
  -- used by the Budget Approval workflow.

  Procedure Set_Prj_Policy_Context
             (
              p_project_id			IN            NUMBER
              , x_msg_count			OUT NOCOPY    NUMBER
              , x_msg_data			OUT NOCOPY    VARCHAR2
              , x_return_status                 OUT NOCOPY    VARCHAR2
              , x_err_code                      OUT NOCOPY    NUMBER
             );




END pa_budget_utils ;

/
