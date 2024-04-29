--------------------------------------------------------
--  DDL for Package PA_FP_CALC_PLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_CALC_PLAN_PUB" AUTHID CURRENT_USER AS
/* $Header: PAFPCPUS.pls 120.2 2006/07/20 09:20:34 psingara noship $*/
/*#
 * This package contains the APIs that are used for refreshing conversion/cost rates for workplan and financial plan.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Refresh Rates
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_BUDGET
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_FORECAST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*
  Procedure: Refresh_Rates
  ------------------------
  Description:
  ------------
  This public AMG API refreshes the cost rates or conversion rates (depending
  on the IN parameters) of either all the planning resources in the entire
  budget version or specific planning resources in the budget version.
  It supports both Workplan and Financial structures, and it performs all
  validation and security checks before refreshing rates.
*/

/*#
 * This API is used to refresh the cost rates and conversion rates (depending on the IN parameters) of either
 * all the planning resources in the entire budget version or specific planning resources in the budget version.
 * It supports both the workplan and financial plan structures, and it performs all validation and security checks before
 * refreshing rates.
 * @param p_api_version_number API standard: version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = F): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if the transaction will be committed
 * @param p_pm_product_code Code identifying the external system
 * @rep:paraminfo {@rep:required}
 * @param p_project_id Identifier of the project
 * @param p_pm_project_reference The reference code that uniquely identifies the project in the external system
 * @param p_update_plan_type The type of plan to be updated. Accepted values are WORKPLAN or FINPLAN
 * @rep:paraminfo {@rep:required}
 * @param p_structure_version_id Identifier of the workplan structure version. A value must be supplied if the value of P_UPDATE_PLAN_TYPE is WORKPLAN
 * @param p_budget_version_number The version number for the budget
 * @param p_version_type The budget version type. The valid values are COST, REVENUE, and ALL
 * @param p_finplan_type_id The identifier of the financial plan type
 * @param p_finplan_type_name The name of the financial plan type
 * @param p_resource_class_code_tab The resource class codes. If this parameter has a value, only the planning resource assignments in the specified resource classes are refreshed.
 * @param p_resource_asgn_id_tab The planning resource assignments. If this parameter ihas a value, only the specified planning resource assignments are refreshed.
 * @param p_txn_curr_code_tab The transaction currency code. If this parameter has a value, only amounts in the specified transaction currencies are refreshed.
 * @param p_refresh_cost_bill_rates_flag Flag indicating if cost and bill rates are refreshed. Accepted values are Y and N.
 * @param p_refresh_conv_rates_flag Flag indicating if conversion rates are refreshed. Accepted values are Y and N.
 * @param p_budget_version_id Identifier of the budget version
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @param x_msg_count API standard: number of error messages
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:precision 2000}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Refresh Rates
 * @rep:compatibility S
*/
PROCEDURE REFRESH_RATES
    (
       p_api_version_number    IN   NUMBER   := 1.0
     , p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE
     , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
     , p_pm_product_code       IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     , p_project_id            IN   NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     , p_pm_project_reference  IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     , p_update_plan_type      IN   VARCHAR2
     , p_structure_version_id  IN   NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     , p_budget_version_number IN   PA_BUDGET_VERSIONS.version_number%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     , p_version_type          IN   PA_BUDGET_VERSIONS.version_type%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     , p_finplan_type_id       IN   PA_BUDGET_VERSIONS.fin_plan_type_id%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     , p_finplan_type_name     IN   PA_FIN_PLAN_TYPES_VL.name%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     , p_resource_class_code_tab IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
     , p_resource_asgn_id_tab    IN SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE()
     , p_txn_curr_code_tab       IN SYSTEM.PA_VARCHAR2_15_TBL_TYPE := SYSTEM.PA_VARCHAR2_15_TBL_TYPE()
     , p_refresh_cost_bill_rates_flag IN VARCHAR2 := 'N'
     , p_refresh_conv_rates_flag      IN VARCHAR2 := 'N'
     , p_budget_version_id     IN  NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     , x_return_status     OUT   VARCHAR2
     , x_msg_count         OUT   NUMBER
     , x_msg_data          OUT   VARCHAR2
   );
END PA_FP_CALC_PLAN_PUB;

 

/
