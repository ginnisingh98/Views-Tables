--------------------------------------------------------
--  DDL for Package PA_COST1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COST1" AUTHID CURRENT_USER as
-- $Header: PAXCSR1S.pls 120.0 2005/06/03 14:18:07 appldev noship $

	/* Bug fix:4230258 cache the project type and project id variables */
	G_project_type      pa_projects_all.project_type%type;
	G_project_id        pa_projects_all.project_id%type;
	G_burden_costFlag   Varchar2(10);
 	FUNCTION check_proj_burdened
	 (p_project_type 		IN 	VARCHAR2
	 ,p_project_id			IN      NUMBER ) RETURN VARCHAR2;

/* This API derives transaction raw cost, burden costs in transaction currency. ie. the currency associated
 * with the rate schedule.
 * This API will derive the costs based on ACTUALs or PLANNING rates
 * The following are the rules to derive cost rates for the planning resource
 * 1. By default the rate engine will derive the raw and burden costs based on the transaction currency.
 *     I.e. The currency associated with the rate schedule. If the transaction override currency is passed then costs will be
 *     converted from transaction currency to override currency.
 * 2. If the override cost rate is passed then rate engine will derive the actual raw cost and raw cost rates
 *   based on the override cost rate
 * 3. If the override burden multiplier is passed, the rate engine will derive the burden costs
 *   based on the override burden multiplier.
 * 4. If the parameter rate based flag is 'N' then rate engine will not derive raw cost instead,
 *  the burden costs will be derived based on the passed value transaction raw cost and transaction currency.
 * 5. Rates will be derived based on the in parameter p_exp_item_date
 * This API returns x_return_status as 'S' for successful rate 'E' if no rate found 'U' in case of unexpected errors
 *
 * NOTE: For BOM related transactions the following params needs to be passed
 * p_mfc_cost_source      Required possible values be
 *                        1 - Return item cost from valuation cost type.
 *                        2 - Return item cost from user-provided cost type.
 *                        3 - Return item cost as the list price per unit from item definition.
 *                        4 - Return item cost as average of the last 5 PO receipts of this item.
 *                            PO price includes non-recoverable tax.
 * p_mfd_cost_type_id     Optional param default is 0
 * p_exp_organization_id  Required
 * p_BOM_resource_id      Required
 * p_inventory_item_id    Required
 *
 * 6. The following parameters should be passed in order to get the planning rates
 *    p_calling_mode = 'PLAN_RATES' for planning rate schedules
 *                     'ACTUAL_RATES' for actuals
 *    p_plan_cost_job_rate_sch_id
 *    p_plan_cost_emp_rate_sch_id
 *    p_plan_cost_non_labor_rate_sch_id
 *    p_plan_burden_cost_sch_id
 *
 */
PROCEDURE Get_Plan_Actual_Cost_Rates
        (p_calling_mode                 IN              VARCHAR2 DEFAULT 'ACTUAL_RATES'
        ,p_project_type                 IN              VARCHAR2
        ,p_project_id                   IN              NUMBER
        ,p_task_id                      IN              NUMBER
        ,p_top_task_id                  IN              NUMBER
        ,p_Exp_item_date                IN              DATE
        ,p_expenditure_type             IN              VARCHAR2
        ,p_expenditure_OU               IN              NUMBER
        ,p_project_OU                   IN              NUMBER
        ,p_Quantity                     IN              NUMBER
        ,p_resource_class               IN              VARCHAR2
        ,p_person_id                    IN              NUMBER     DEFAULT NULL
        ,p_non_labor_resource           IN              VARCHAR2   DEFAULT NULL
        ,p_NLR_organization_id          IN              NUMBER     DEFAULT NULL
        ,p_override_organization_id     IN              NUMBER     DEFAULT NULL
        ,p_incurred_by_organization_id  IN              NUMBER     DEFAULT NULL
        ,p_inventory_item_id            IN              NUMBER     DEFAULT NULL
        ,p_BOM_resource_id              IN              NUMBER     DEFAULT NULL
        ,p_override_trxn_curr_code      IN              VARCHAR2   DEFAULT NULL
        ,p_override_burden_cost_rate    IN              NUMBER     DEFAULT NULL
        ,p_override_trxn_cost_rate      IN              NUMBER     DEFAULT NULL
        ,p_override_trxn_raw_cost       IN              NUMBER     DEFAULT NULL
        ,p_override_trxn_burden_cost    IN              NUMBER     DEFAULT NULL
        ,p_mfc_cost_type_id             IN              NUMBER     DEFAULT 0
        ,p_mfc_cost_source              IN              NUMBER     DEFAULT 2
        ,p_item_category_id             IN              NUMBER     DEFAULT NULL
        ,p_job_id                       IN              NUMBER     DEFAULT NULL
	,p_plan_cost_job_rate_sch_id    IN              NUMBER     DEFAULT NULL
        ,p_plan_cost_emp_rate_sch_id    IN              NUMBER     DEFAULT NULL
        ,p_plan_cost_nlr_rate_sch_id    IN              NUMBER     DEFAULT NULL
        ,p_plan_cost_burden_sch_id      IN              NUMBER     DEFAULT NULL
        ,x_trxn_curr_code               OUT NOCOPY      VARCHAR2
        ,x_trxn_raw_cost                OUT NOCOPY      NUMBER
        ,x_trxn_raw_cost_rate           OUT NOCOPY      NUMBER
        ,x_trxn_burden_cost             OUT NOCOPY      NUMBER
        ,x_trxn_burden_cost_rate        OUT NOCOPY      NUMBER
        ,x_burden_multiplier            OUT NOCOPY      NUMBER
        ,x_cost_ind_compiled_set_id     OUT NOCOPY      NUMBER
        ,x_raw_cost_rejection_code      OUT NOCOPY      VARCHAR2
        ,x_burden_cost_rejection_code   OUT NOCOPY      VARCHAR2
        ,x_return_status                OUT NOCOPY      VARCHAR2
        ,x_error_msg_code               OUT NOCOPY      VARCHAR2 );

PROCEDURE  Get_Non_Labor_raw_cost
        (p_project_id                   IN           NUMBER
        ,p_task_id                      IN           NUMBER
        ,p_non_labor_resource           IN           VARCHAR2
        ,p_nlr_organization_id          IN           NUMBER
        ,p_expenditure_type             IN           VARCHAR2
        ,p_exp_item_date                IN           DATE
        ,p_override_organization_id     IN           NUMBER
        ,p_quantity                     IN           NUMBER
        ,p_org_id                       IN           NUMBER
        ,p_nlr_schedule_id              IN           NUMBER
        ,p_nlr_trxn_cost_rate           IN           NUMBER DEFAULT NULL
        ,p_nlr_trxn_raw_cost            IN           NUMBER DEFAULT NULL
        ,p_nlr_trxn_currency_code       IN           VARCHAR2 DEFAULT NULL
        ,x_trxn_raw_cost_rate           OUT  NOCOPY  NUMBER
        ,x_trxn_raw_cost                OUT  NOCOPY  NUMBER
        ,x_txn_currency_code            OUT  NOCOPY  VARCHAR2
        ,x_return_status                OUT  NOCOPY  VARCHAR2
        ,x_error_msg_code               OUT  NOCOPY  VARCHAR2
        );

/* This is a wrapper api to derive compiled set id and burden multiplier
 * Which in turn makes calls to pa_cost_plus package
 */
PROCEDURE Get_burden_sch_details
                (p_calling_mode                 IN              VARCHAR2 DEFAULT 'ACTUAL_RATES'
		,p_exp_item_id                  IN              NUMBER
                ,p_trxn_type                    IN              VARCHAR2
                ,p_project_type                 IN              VARCHAR2
                ,p_project_id                   IN              NUMBER
                ,p_task_id                      IN              NUMBER
                ,p_exp_organization_id          IN              NUMBER
		/* bug fix:4232181 Derive organization override for burden calculate */
                ,p_overide_organization_id      IN              NUMBER   DEFAULT NULL
                ,p_person_id                    IN              NUMBER   DEFAULT NULL
		/* end of bug fix:4232181 */
                ,p_expenditure_type             IN              VARCHAR2
                ,p_schedule_type                IN              VARCHAR2 DEFAULT 'C'
                ,p_exp_item_date                IN              DATE
                ,p_trxn_curr_code               IN              VARCHAR2
		,p_burden_schedule_id		IN              NUMBER DEFAULT NULL
                ,x_schedule_id                  OUT NOCOPY      NUMBER
                ,x_sch_revision_id              OUT NOCOPY      NUMBER
                ,x_sch_fixed_date               OUT NOCOPY      DATE
                ,x_cost_base                    OUT NOCOPY      VARCHAR2
                ,x_cost_plus_structure          OUT NOCOPY      VARCHAR2
                ,x_compiled_set_id              OUT NOCOPY      NUMBER
                ,x_burden_multiplier            OUT NOCOPY      NUMBER
                ,x_return_status                OUT NOCOPY      VARCHAR2
                ,x_error_msg_code               OUT NOCOPY      VARCHAR2 );

/* This API derives the cost rates based on the bill rate schedules
* The possible values for the params
* p_schedule_type 'EMPLOYEE' / 'JOB' / 'NON-LABOR'
* p_rate_sch_id  based on the schedule type the corresponding rate schedule id must be passed
*/
PROCEDURE get_RateSchDetails
                (p_schedule_type      IN Varchar2
                ,p_rate_sch_id        IN Number
                ,p_person_id          IN Number
                ,p_job_id             IN Number
                ,p_non_labor_resource IN Varchar2
                ,p_expenditure_type   IN Varchar2
		,p_rate_organization_id IN Number
                ,p_exp_item_date      IN Date
                ,p_org_id             IN Number
                ,x_currency_code      OUT NOCOPY Varchar2
                ,x_cost_rate          OUT NOCOPY Number
                ,x_markup_percent     OUT NOCOPY Number
                ,x_return_status      OUT NOCOPY Varchar2
                ,x_error_msg_code     OUT NOCOPY Varchar2 );

/* This API converts the cost amount from transaction currency to
 * project and project functional currency based on the
 * planning transaction currency conversion attributes
 * NOTE: Please donot use this API for actual cost conversion
 */
PROCEDURE Convert_COST_TO_PC_PFC
   (p_txn_raw_cost                      IN  NUMBER
   ,p_txn_burden_cost                   IN  NUMBER
   ,p_txn_quantity                      IN  NUMBER
   ,p_txn_curr_code                     IN  VARCHAR2
   ,p_txn_date                          IN  DATE
   ,p_project_id                        IN  NUMBER
   ,p_budget_Version_id                 IN  NUMBER
   ,p_budget_line_id                    IN  NUMBER
   ,x_project_curr_code                 OUT NOCOPY VARCHAR2
   ,x_projfunc_curr_code                OUT NOCOPY VARCHAR2
   ,x_proj_raw_cost                     OUT NOCOPY NUMBER
   ,x_proj_raw_cost_rate                OUT NOCOPY NUMBER
   ,x_proj_burdened_cost                OUT NOCOPY NUMBER
   ,x_proj_burdened_cost_rate           OUT NOCOPY NUMBER
   ,x_projfunc_raw_cost                 OUT NOCOPY NUMBER
   ,x_projfunc_raw_cost_rate            OUT NOCOPY NUMBER
   ,x_projfunc_burdened_cost            OUT NOCOPY NUMBER
   ,x_projfunc_burdened_cost_rate       OUT NOCOPY NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2
   ,x_error_msg_code                    OUT NOCOPY VARCHAR2
   );

/* This is an internal API which will be called from Convert_COSTto PC and PFC api
 * this api does the calculation fo amount conversion based on the planning conversion
 * attributes
 */
PROCEDURE Convert_amounts
   (p_calling_mode                      IN  VARCHAR2 DEFAULT 'PC'
   ,p_txn_raw_cost                      IN  NUMBER
   ,p_txn_burden_cost                   IN  NUMBER
   ,p_txn_quantity                      IN  NUMBER
   ,p_Conversion_Date                   IN  DATE
   ,p_From_curr_code                    IN  VARCHAR2
   ,p_To_curr_code                      IN  VARCHAR2
   ,p_To_Curr_Rate_Type                 IN  VARCHAR2
   ,p_To_Curr_Exchange_Rate             IN  NUMBER
   ,x_To_Curr_raw_cost                  OUT NOCOPY NUMBER
   ,x_To_Curr_raw_cost_rate             OUT NOCOPY NUMBER
   ,x_To_Curr_burden_cost               OUT NOCOPY NUMBER
   ,x_To_Curr_burden_cost_rate          OUT NOCOPY NUMBER
   ,x_To_Curr_Exchange_Rate             OUT NOCOPY NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2
   ,x_error_msg_code                    OUT NOCOPY VARCHAR2
   );


end PA_COST1;

 

/
