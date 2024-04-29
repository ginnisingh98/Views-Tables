--------------------------------------------------------
--  DDL for Package PA_FIN_PLAN_UTILS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FIN_PLAN_UTILS2" AUTHID CURRENT_USER AS
/* $Header: PAFPUT2S.pls 120.5 2007/02/06 10:13:58 dthakker ship $ */

/* Added these variables for Billable Task API */
  TYPE BillableRec IS RECORD (Billable_Flag  Pa_tasks.billable_flag%TYPE);
  TYPE BillableTab IS TABLE OF BillableRec INDEX BY BINARY_INTEGER;

/* The following start date and end date variabes and APIs will be used in the
 * view pa_fp_budget_line_rejections_v to derive the rejection flags based on
 * given start and end dates
 */
g_bdgt_start_date  Date;
g_bdgt_end_date    Date;
period_mask_display  Varchar2(100);
FUNCTION get_bdgt_start_date Return DATE ;
FUNCTION get_bdgt_end_date Return DATE ;

/* This API will derive the rate based flag and UOM for the planning transaction
 * This should be called while updating the planning resource transaction
 * Based on the IN params the new rate based flag and UOM will be derived
 * If old and new rate base flag values are different then x_rate_based_flag_changed_tab will be set to 'Y'
 * If old and new UOM values are different then x_uom_changed_flag_tab will be set to 'Y'
 * NOTE: Since this is PLSQL table LOOPING , this api should be called in batch of 100 records only
 */
PROCEDURE Get_UOM_RateBasedFlag (
		p_resource_class_code_tab        IN      	 SYSTEM.PA_VARCHAR2_30_TBL_TYPE
		,p_inventory_item_id_tab         IN      	 SYSTEM.PA_NUM_TBL_TYPE
		,p_rate_organization_id_tab      IN      	 SYSTEM.PA_NUM_TBL_TYPE
		,p_expenditure_type_tab          IN      	 SYSTEM.PA_VARCHAR2_30_TBL_TYPE
		,p_rate_expenditure_type_tab     IN      	 SYSTEM.PA_VARCHAR2_30_TBL_TYPE
		,p_old_UOM_tab           	 IN              SYSTEM.PA_VARCHAR2_30_TBL_TYPE
		,p_old_rate_based_flag_tab       IN              SYSTEM.PA_VARCHAR2_1_TBL_TYPE
		,x_New_UOM_tab           	 OUT NOCOPY      SYSTEM.PA_VARCHAR2_30_TBL_TYPE
		,x_uom_changed_flag_tab          OUT NOCOPY      SYSTEM.PA_VARCHAR2_1_TBL_TYPE
		,x_new_rate_based_flag_tab       OUT NOCOPY      SYSTEM.PA_VARCHAR2_1_TBL_TYPE
		,x_rate_based_flag_changed_tab   OUT NOCOPY      SYSTEM.PA_VARCHAR2_1_TBL_TYPE
		,x_return_status                 OUT NOCOPY      VARCHAR2
		) ;

/* This API derives the rejection code flags from budget lines for the given
 * resource_assignment_id and txn_currency_code
 * The out variables will be set to 'Y' if there is any rejection else it is 'N'
 * If p_start_date and p_end_date is passed then out rejection flags will be based on the Periods
 */
PROCEDURE Get_BdgtLineRejFlags
                (p_resource_assignment_id   IN  Number
                ,p_txn_currency_code        IN  Varchar2
                ,p_budget_version_id        IN  Number
		,p_start_date               IN  Date    default Null
		,p_end_date                 IN  Date    default Null
                ,x_cost_rejection_flag      OUT NOCOPY  Varchar2
                ,x_burden_rejection_flag    OUT NOCOPY  Varchar2
                ,x_revenue_rejection_flag   OUT NOCOPY  Varchar2
                ,x_pc_conv_rejection_flag   OUT NOCOPY  Varchar2
                ,x_pfc_conv_rejection_flag  OUT NOCOPY  Varchar2
                ,x_other_rejection_flag     OUT NOCOPY  Varchar2
		,x_return_status            OUT NOCOPY  Varchar2
                );


/* This API derives the rejection reason from budget lines for the given
 * resource_assignment_id and txn_currency_code,Start_date, end_date
 * The out variable will be an array of messages corresponding to the
 * budget line rejection codes
 */
PROCEDURE Get_BdgtLineRejctions
                (p_resource_assignment_id   IN  Number
                ,p_txn_currency_code        IN  Varchar2
                ,p_budget_version_id        IN  Number
                ,p_start_date               IN  Date
                ,p_end_date                 IN  Date
                ,x_period_name_tab              OUT NOCOPY  SYSTEM.PA_VARCHAR2_80_TBL_TYPE
                ,x_cost_rejection_data_tab      OUT NOCOPY  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
                ,x_burden_rejection_data_tab    OUT NOCOPY  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
                ,x_revenue_rejection_data_tab   OUT NOCOPY  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
                ,x_pc_conv_rejection_data_tab   OUT NOCOPY  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
                ,x_pfc_conv_rejection_data_tab  OUT NOCOPY  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
                ,x_other_rejection_data_tab     OUT NOCOPY  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
                ,x_return_status                OUT NOCOPY  Varchar2
                );


/* This API returns the default resource list for the given project and Plan type
 * based on the finplan option level code = 'PLAN_TYPE'
 * By Default it gives the Cost resource list attached at the plan type
 * if not found then it returns the Revenue resource list
 */
PROCEDURE Get_Default_FP_Reslist
		(p_project_id  		IN  Number
		,p_fin_plan_type_id  	IN Number   DEFAULT NULL
		,x_res_list_id          OUT NOCOPY  NUMBER
		,x_res_list_name        OUT NOCOPY  Varchar2);

/* This API derives the default Resource list used in the WorkPlan structure
 * for the given project Id
 */
PROCEDURE Get_Default_WP_ResList
        (p_project_id           IN Number
        ,p_wps_version_id       IN Number default NULL
        ,x_res_list_id          OUT NOCOPY  NUMBER
        ,x_res_list_name        OUT NOCOPY  Varchar2);

/* This cursor derives the default resource list associated with the project
 * Logic: get the ResList from project fp options based on the approved cost Plan type
          for the given project. If no rows found or resList is null then Get the reslist
          from the current budget versions for the approved cost budget version, if no rows found
          then get the Resource List from the project_types
*/
PROCEDURE Get_Default_Project_ResList
                (p_project_id           IN  Number
                ,x_res_list_id          OUT NOCOPY  NUMBER
                ,x_res_list_name        OUT NOCOPY  Varchar2);


/* This API derives the rejection reason from budget lines for the given
 * budget version id.The out variable will be an array of messages corresponding to the
 * budget line rejection codes.
 * This procedure is called from AMG apis.
 */
PROCEDURE Get_AMG_BdgtLineRejctions
                (p_budget_version_id        	IN  Number
		,x_budget_line_id_tab           OUT NOCOPY  PA_PLSQL_DATATYPES.IdTabTyp
                ,x_cost_rejection_data_tab      OUT NOCOPY  PA_PLSQL_DATATYPES.Char2000TabTyp
                ,x_burden_rejection_data_tab    OUT NOCOPY  PA_PLSQL_DATATYPES.Char2000TabTyp
                ,x_revenue_rejection_data_tab   OUT NOCOPY  PA_PLSQL_DATATYPES.Char2000TabTyp
                ,x_pc_conv_rejection_data_tab   OUT NOCOPY  PA_PLSQL_DATATYPES.Char2000TabTyp
                ,x_pfc_conv_rejection_data_tab  OUT NOCOPY  PA_PLSQL_DATATYPES.Char2000TabTyp
                ,x_other_rejection_data_tab     OUT NOCOPY  PA_PLSQL_DATATYPES.Char2000TabTyp
                ,x_return_status                OUT NOCOPY  Varchar2
                ) ;

/* THIS API is called from EditBudgetLineDetails.java page
 * This api validates the currency conversion parameters and updates the pa_budget_lines table
 * if there is any changes in the currency conversion attributes, it calls calculate api ()
 */
PROCEDURE validateAndUpdateBdgtLine(
			p_budget_line_id			IN Number
                       ,p_BDGT_VERSION_ID                       IN Number
                       ,p_RES_ASSIGNMENT_ID                     IN Number
                       ,p_TXN_CURRENCY_CODE                     IN Varchar2
                       ,p_START_DATE                            IN Date
                       ,p_END_DATE                              IN Date
                       ,P_CALLING_CONTEXT                       IN Varchar2
                       ,P_ORG_ID                                IN Number
                       ,p_PLAN_VERSION_TYPE                     IN Varchar2
                       ,p_PROJFUNC_CURRENCY_CODE                IN Varchar2
                       ,p_PROJFUNC_COST_RATE_TYPE               IN Varchar2
                       ,p_PROJFUNC_COST_EXCHANGE_RATE           IN Number
                       ,p_PROJFUNC_COST_RATE_DATE_TYPE          IN Varchar2
                       ,p_PROJFUNC_COST_RATE_DATE               IN Date
                       ,p_PROJFUNC_REV_RATE_TYPE                IN Varchar2
                       ,p_PROJFUNC_REV_EXCHANGE_RATE            IN Number
                       ,p_PROJFUNC_REV_RATE_DATE_TYPE           IN Varchar2
                       ,p_PROJFUNC_REV_RATE_DATE                IN Date
                       ,p_PROJECT_CURRENCY_CODE                 IN Varchar2
                       ,p_PROJECT_COST_RATE_TYPE                IN Varchar2
                       ,p_PROJECT_COST_EXCHANGE_RATE            IN Number
                       ,p_PROJECT_COST_RATE_DATE_TYPE           IN Varchar2
                       ,p_PROJECT_COST_RATE_DATE                IN Date
                       ,p_PROJECT_REV_RATE_TYPE                 IN Varchar2
                       ,p_PROJECT_REV_EXCHANGE_RATE             IN Number
                       ,p_PROJECT_REV_RATE_DATE_TYPE            IN Varchar2
                       ,p_PROJECT_REV_RATE_DATE                 IN Date
                       ,p_CHANGE_REASON_CODE                    IN Varchar2
                       ,p_DESCRIPTION                           IN Varchar2
                       ,p_ATTRIBUTE_CATEGORY                    IN Varchar2
                       ,p_ATTRIBUTE1                            IN Varchar2
                       ,p_ATTRIBUTE2                            IN Varchar2
                       ,p_ATTRIBUTE3                            IN Varchar2
                       ,p_ATTRIBUTE4                            IN Varchar2
                       ,p_ATTRIBUTE5                            IN Varchar2
                       ,p_ATTRIBUTE6                            IN Varchar2
                       ,p_ATTRIBUTE7                            IN Varchar2
                       ,p_ATTRIBUTE8                            IN Varchar2
                       ,p_ATTRIBUTE9                            IN Varchar2
                       ,p_ATTRIBUTE10                           IN Varchar2
                       ,p_ATTRIBUTE11                           IN Varchar2
                       ,p_ATTRIBUTE12                           IN Varchar2
                       ,p_ATTRIBUTE13                           IN Varchar2
                       ,p_ATTRIBUTE14                           IN Varchar2
                       ,p_ATTRIBUTE15                           IN Varchar2
                       ,p_CI_ID                                 IN Number
                       ,x_return_status                         OUT NOCOPY Varchar2
                       ,x_msg_data                              OUT NOCOPY Varchar2
                       ,x_msg_count                             OUT NOCOPY Number
                        ) ;

FUNCTION getMaskName Return Varchar2;
PROCEDURE setMaskName(p_period_Mask  IN Varchar2) ;

/*
 * This API provides the budget line rejections for the given Project STructure
 * Version Id and Task Str Version Id
 * IN Params:
 * p_project_id    IN Number  Required
 * p_calling_mode  IN Varchar2 Default 'PROJ_STR_VER'
 *                 the possible values are 'PROJ_STR_LEVEL' or 'TASK_STR_LEVEL'
 * p_proj_str_version_id   IN Number Required
 * p_Task_str_version_id   IN Number If calling mode is TASK_STR_LEVEL then it is reqd
 * p_start_date            IN Date
 *    If calling mode is TASK_STR_LEVEL then it is reqd.
 *    value should be periodmask or task start date
 * p_end_date              IN Date
 *    If calling mode is TASK_STR_LEVEL then it is reqd.
 *    value should be periodmask or task end date
 * OUT Params:
 * x_return_status  will be 'U' - in case of unexpected error
 *                          'E' - in case of expected error - invalid params
 *                          'S' - in case of success
 * If calling mode 'PROJ_STR_VER' then
 *   x_projstrlvl_rejn_flag will populated
 * ElsIf calling mode 'TASK_STR_VER'
 *   the following out variables will be populated
 *   x_cost_rejn_flag
 *   x_burden_rejn_flag
 *   x_revenue_rejn_flag
 *   x_pc_conv_rejn_flag
 *   x_pfc_conv_rejn_flag
 * End If;
 *
 */
PROCEDURE Get_WbsBdgtLineRejns
        (p_project_id                   IN Number
        ,p_calling_mode                 IN Varchar2 Default 'PROJ_STR_VER'
        ,p_proj_str_version_id          IN Number
        ,p_Task_str_version_id          IN Number   Default Null
        ,p_start_date                   IN Date     Default Null
        ,p_end_date                     IN Date     Default Null
        ,x_cost_rejn_flag               OUT NOCOPY  Varchar2
        ,x_burden_rejn_flag             OUT NOCOPY  Varchar2
        ,x_revenue_rejn_flag            OUT NOCOPY  Varchar2
        ,x_pc_conv_rejn_flag            OUT NOCOPY  Varchar2
        ,x_pfc_conv_rejn_flag           OUT NOCOPY  Varchar2
        ,x_projstrlvl_rejn_flag         OUT NOCOPY  Varchar2
        ,x_return_status                OUT NOCOPY  Varchar2
        ,p_budget_version_id            IN Number   Default Null    --Bug 5611909
        );

/* This API provides the budget line Actual Start Date and End Date
 * for the given budget version and resource assignment id
 * Logic: Derive Actual SDate as derive the MIN(budget_line.Start_date) where
 *        actuals on the budget lines are populated.
 *        similarly for EDate derive the ETC start date from budget versions for the given resource assignment
 *        if etc start date is null then derive the MAX(budget_line.end_date) where
 *        actuals on the budget lines are populated.
 * The PARAMS :
 * p_budget_version_id       IN Number   Required
 * p_resource_assignment_id  IN Number   Required
 * x_bl_actual_start_date    OUT DATE
 * x_bl_actual_end_date      OUT DATE
 * x_return_status           OUT Varchar2
 * Note : if ETC start date and actual values donot exists then the out params
 *  x_bl_actual_start_date and x_bl_actual_end_date will be passed as NULL
 * Rule:
 * 1. If x_bl_actual_start_date is NULL and x_bl_actual_end_date is NULL
 *     then planning trx start date and end date can be shifted.
 * 2. if x_bl_actual_end_date is NOT NULL then planning trx end date can't be shifted earlier than x_bl_actual_end_date
 * 3. if x_bl_actual_start_date is NOT NULL then planning trx start date can't be shifted later than x_bl_actual_start_date
 */
PROCEDURE get_blactual_Dates
        (p_budget_version_id  IN Number
        ,p_resource_assignment_id IN Number
        ,x_bl_actual_start_date OUT NOCOPY date
        ,x_bl_actual_end_date   OUT NOCOPY date
        ,x_return_status        OUT NOCOPY varchar2
        ,x_error_msg_code       OUT NOCOPY varchar2
        );
/* This API provides the agreement related details
 * Bug fix: 3679142 Change order versions which have revenue impact should also be in agreement
 * currency. This means all change order versions with version type as ALL or REVENUE
 * should ultimately have the planning txns and budget lines in AGR CURRENCY.
*/
PROCEDURE Get_Agreement_Details
        (p_budget_version_id  IN Number
        ,p_calling_mode       IN Varchar2  DEFAULT 'CALCULATE_API'
        ,x_agr_curr_code      OUT NOCOPY Varchar2
	,x_AGR_CONV_REQD_FLAG OUT NOCOPY Varchar2
        ,x_return_status      OUT NOCOPY Varchar2 );

/* This API returns the Agreement currency for the given change order budget version
 * If the currency is null Or budget version is not part of the change order then
 * the api returns the NULL
 */
FUNCTION get_Agreement_Currency(p_budget_version_id  IN Number)
        RETURN varchar2;

/* This API rounds off the given quantity to 5 decimal places.  This API should be called for rounding the quantity
 * for rate based planning transaction only.
 * This API accepts the following parameters
 */
FUNCTION round_quantity
	(P_quantity  	IN Number
	) RETURN NUMBER ;

/* This API checks the given financial Task is billable or not
 * If task is billable, it returns 'Y' else 'N'
 */
FUNCTION IsFpTaskBillable(p_project_id   NUMBER
                         ,p_task_id   NUMBER) RETURN varchar2;


PROCEDURE Get_Resource_Rates
	( p_calling_module          	IN VARCHAR2 := 'MSP'
	,p_source_context               IN VARCHAR2 := 'RLMI'
	,p_project_id			IN NUMBER
	,p_budget_version_id		IN NUMBER
	,p_resource_assignment_id_tab   IN SYSTEM.PA_NUM_TBL_TYPE 	  DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
	,p_resource_list_member_Id_tab  IN SYSTEM.PA_NUM_TBL_TYPE 	  DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
	,p_ra_date_tab                  IN SYSTEM.PA_DATE_TBL_TYPE        DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
	,p_task_id_tab                  IN SYSTEM.PA_NUM_TBL_TYPE         DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
	,p_quantity_tab			IN SYSTEM.PA_NUM_TBL_TYPE 	  DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
	,p_txn_currency_code_ovr_tab	IN SYSTEM.PA_VARCHAR2_15_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_15_TBL_TYPE()
	,p_cost_rate_override_tab       IN SYSTEM.PA_NUM_TBL_TYPE 	  DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
	,p_burden_rate_override_tab     IN SYSTEM.PA_NUM_TBL_TYPE 	  DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
	,p_bill_rate_override_tab       IN SYSTEM.PA_NUM_TBL_TYPE 	  DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
	,x_resource_assignment_id_tab   OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
	,x_resource_list_member_Id_tab  OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
	,x_expenditure_ou_tab           OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
	,x_raw_cost_rate_tab		OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
	,x_burden_cost_rate_tab         OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
	,x_burden_multiplier_tab        OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
	,x_ind_compiled_set_id_tab      OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
	,x_bill_rate_tab                OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
	,x_markup_percent_tab           OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
	,x_txn_currency_code_tab        OUT NOCOPY SYSTEM.PA_VARCHAR2_15_TBL_TYPE
	,x_cost_txn_curr_code_tab        OUT NOCOPY SYSTEM.PA_VARCHAR2_15_TBL_TYPE
	,x_rev_txn_curr_code_tab        OUT NOCOPY SYSTEM.PA_VARCHAR2_15_TBL_TYPE
	,x_cost_rejection_code_tab      OUT NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE
	,x_burden_rejection_code_tab    OUT NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE
	,x_revenue_rejection_code_tab   OUT NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE
	,x_return_status                OUT NOCOPY VARCHAR2
	,x_msg_data			OUT NOCOPY VARCHAR2
	,x_msg_count			OUT NOCOPY NUMBER
	) ;

/** MRC Elimination: Moved this procedure from pa_mrc_finplan pkg to utils as
 *  package itself is dropped
 */
PROCEDURE POPULATE_BL_MAP_TMP
          (p_source_fin_plan_version_id  IN PA_BUDGET_LINES.budget_version_id%TYPE
          ,x_return_status   OUT NOCOPY VARCHAR2
          ,x_msg_count       OUT NOCOPY NUMBER
          ,x_msg_data        OUT NOCOPY VARCHAR2
         );
END PA_FIN_PLAN_UTILS2 ;

/
