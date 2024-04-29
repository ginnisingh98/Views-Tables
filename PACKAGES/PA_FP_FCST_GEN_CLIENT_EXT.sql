--------------------------------------------------------
--  DDL for Package PA_FP_FCST_GEN_CLIENT_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_FCST_GEN_CLIENT_EXT" AUTHID CURRENT_USER as
/* $Header: PAFPFGCS.pls 120.2 2007/02/06 09:53:06 dthakker ship $ */
/*#
 * This package enables you to control the calculation of estimate to complete (ETC) quantities and amounts in forecasts.
 * You can use this extension to calculate quantities and amounts for raw cost, burdened cost, and revenue.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Estimate to Complete Generation Method
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_FORECAST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
type l_pds_rate_dtls_rec_type is RECORD
(	PERIOD_NAME		pa_budget_lines.period_name%TYPE,
	RAW_COST_RATE		pa_budget_lines.txn_standard_cost_rate%TYPE,
	BURDENED_COST_RATE	pa_budget_lines.burden_cost_rate%TYPE,
	REVENUE_BILL_RATE	pa_budget_lines.txn_standard_bill_rate%TYPE);

type l_pds_rate_dtls_tab is
    TABLE of l_pds_rate_dtls_rec_type INDEX BY BINARY_INTEGER;

/*
type tab_period_name is
    TABLE of pa_budget_lines.period_name%TYPE;

type tab_raw_cost_rate is
    TABLE of pa_budget_lines.txn_standard_cost_rate%TYPE;

type tab_burden_cost_rate is
    TABLE of pa_budget_lines.burden_cost_rate%TYPE;

type tab_bill_rate is
    TABLE of pa_budget_lines.txn_standard_bill_rate%TYPE;
*/

 -- Start Bug 5726785

 	 TYPE l_plan_txn_prd_amt_rec IS RECORD
 	 (   period_name         pa_budget_lines.period_name%TYPE,
 	     etc_quantity        pa_budget_lines.quantity%TYPE,
 	     txn_raw_cost        pa_budget_lines.txn_raw_cost%TYPE,
 	     txn_burdened_cost   pa_budget_lines.txn_burdened_cost%TYPE,
 	     txn_revenue         pa_budget_lines.txn_revenue%TYPE,
 	     init_quantity       pa_budget_lines.init_quantity%TYPE,
 	     init_raw_cost       pa_budget_lines.init_raw_cost%TYPE,
 	     init_burdened_cost  pa_budget_lines.init_burdened_cost%TYPE,
 	     init_revenue        pa_budget_lines.init_revenue%TYPE,
 	     periodic_line_editable  VARCHAR2(1),   -- Identifier which specifies whether the ETC figures are editable for a period or not
 	     description         VARCHAR2(30) );        -- Description of the period. Values would be stamped using a new lookup type, PA_FP_FCST_GEN_CLNT_EXTN_LU.

 	 TYPE l_plan_txn_prd_amt_tbl IS
 	     TABLE of l_plan_txn_prd_amt_rec INDEX BY BINARY_INTEGER;

 -- End Bug 5726785

/*#
 * This API is used to to define calculations for ETC quantities and amounts for raw cost, burdened cost, and revenue.
 * @param P_PROJECT_ID Project identifier
 * @rep:paraminfo {@rep:required}
 * @param P_BUDGET_VERSION_ID Forecast version identifier
 * @rep:paraminfo {@rep:required}
 * @param P_RESOURCE_ASSIGNMENT_ID Resource assignment identifier
 * @rep:paraminfo {@rep:required}
 * @param P_TASK_ID Task identifier. Set to zero if forecasting at the project level.
 * @rep:paraminfo {@rep:required}
 * @param P_TASK_PERCENT_COMPLETE Task percentage complete
 * @rep:paraminfo {@rep:required}
 * @param P_PROJECT_PERCENT_COMPLETE Project percentage complete
 * @rep:paraminfo {@rep:required}
 * @param P_RESOURCE_LIST_MEMBER_ID Resource list member identifier
 * @rep:paraminfo {@rep:required}
 * @param P_UNIT_OF_MEASURE Unit of measure
 * @rep:paraminfo {@rep:required}
 * @param P_TXN_CURRENCY_CODE Transaction currency code
 * @rep:paraminfo {@rep:required}
 * @param P_ETC_QTY Estimate to complete quantity
 * @rep:paraminfo {@rep:required}
 * @param P_ETC_RAW_COST Estimate to complete raw cost
 * @rep:paraminfo {@rep:required}
 * @param P_ETC_BURDENED_COST Estimate to complete burdened cost
 * @rep:paraminfo {@rep:required}
 * @param P_ETC_REVENUE Estimate to complete revenue
 * @rep:paraminfo {@rep:required}
 * @param P_ETC_SOURCE Estimate to complete source
 * @rep:paraminfo {@rep:required}
 * @param P_ETC_GEN_METHOD Estimate to complete generation method
 * @rep:paraminfo {@rep:required}
 * @param P_ACTUAL_THRU_DATE Actual amounts through date
 * @rep:paraminfo {@rep:required}
 * @param P_ETC_START_DATE Estimate to complete start date
 * @rep:paraminfo {@rep:required}
 * @param P_ETC_END_DATE Estimate to complete end date
 * @rep:paraminfo {@rep:required}
 * @param P_PLANNED_WORK_QTY Planned work quantity
 * @rep:paraminfo {@rep:required}
 * @param P_ACTUAL_WORK_QTY Actual work quantity
 * @rep:paraminfo {@rep:required}
 * @param P_ACTUAL_QTY Actual quantity
 * @rep:paraminfo {@rep:required}
 * @param P_ACTUAL_RAW_COST Actual raw cost
 * @rep:paraminfo {@rep:required}
 * @param P_ACTUAL_BURDENED_COST Actual burdened cost
 * @rep:paraminfo {@rep:required}
 * @param P_ACTUAL_REVENUE Actual revenue
 * @rep:paraminfo {@rep:required}
 * @param P_PERIOD_RATES_TBL Period rates table (l_pds_rate_dtls_tab) - period rates from the source plan
 * @rep:paraminfo {@rep:required}
 * @param X_ETC_QTY Estimate to complete quantity
 * @param X_ETC_RAW_COST Estimate to complete raw cost
 * @param X_ETC_BURDENED_COST Estimate to complete burdened cost
 * @param X_ETC_REVENUE Estimate to complete revenue
 * @param X_PERIOD_RATES_TBL Period rates table (l_pds_rate_dtls_tab)
 * @param X_RETURN_STATUS Standard out parameter for error handling
 * @param X_MSG_DATA Standard out parameter for error handling
 * @param X_MSG_COUNT Standard out parameter for error handling
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Estimate to Complete Generation Method
 * @rep:compatibility S
*/
PROCEDURE FCST_GEN_CLIENT_EXTN
  (P_PROJECT_ID    		IN NUMBER
   ,P_BUDGET_VERSION_ID 		IN NUMBER
   ,P_RESOURCE_ASSIGNMENT_ID	IN NUMBER
   ,P_TASK_ID			IN NUMBER
   ,P_TASK_PERCENT_COMPLETE      IN NUMBER
   ,P_PROJECT_PERCENT_COMPLETE	IN NUMBER
   ,P_RESOURCE_LIST_MEMBER_ID	IN NUMBER
   ,P_UNIT_OF_MEASURE           IN PA_RESOURCE_ASSIGNMENTS.UNIT_OF_MEASURE%TYPE
   ,P_TXN_CURRENCY_CODE		IN VARCHAR2
   ,P_ETC_QTY			IN NUMBER
   ,P_ETC_RAW_COST		IN NUMBER
   ,P_ETC_BURDENED_COST	        IN NUMBER
   ,P_ETC_REVENUE		IN NUMBER
   ,P_ETC_SOURCE		        IN VARCHAR2
   ,P_ETC_GEN_METHOD  		IN VARCHAR2
   ,P_ACTUAL_THRU_DATE		IN DATE
   ,P_ETC_START_DATE		IN DATE
   ,P_ETC_END_DATE		IN DATE
   ,P_PLANNED_WORK_QTY		IN  NUMBER
   ,P_ACTUAL_WORK_QTY		IN NUMBER
   ,P_ACTUAL_QTY			IN NUMBER
   ,P_ACTUAL_RAW_COST		IN NUMBER
   ,P_ACTUAL_BURDENED_COST	IN NUMBER
   ,P_ACTUAL_REVENUE		IN NUMBER
   ,P_PERIOD_RATES_TBL		IN l_pds_rate_dtls_tab
   -- Start Bug 5726785
   ,p_override_raw_cost_rate       IN  pa_resource_asgn_curr.txn_raw_cost_rate_override%TYPE    DEFAULT NULL
   ,p_override_burd_cost_rate      IN  pa_resource_asgn_curr.txn_burden_cost_rate_override%TYPE DEFAULT NULL
   ,p_override_bill_rate           IN  pa_resource_asgn_curr.txn_bill_rate_override%TYPE        DEFAULT NULL
   ,p_avg_raw_cost_rate            IN  pa_resource_asgn_curr.txn_average_raw_cost_rate%TYPE     DEFAULT NULL
   ,p_avg_burd_cost_rate           IN  pa_resource_asgn_curr.txn_average_burden_cost_rate%TYPE  DEFAULT NULL
   ,p_avg_bill_rate                IN  pa_resource_asgn_curr.txn_average_bill_rate%TYPE         DEFAULT NULL
   ,px_period_amts_tbl             IN  OUT NOCOPY l_plan_txn_prd_amt_tbl
   ,px_period_data_modified        IN  OUT NOCOPY VARCHAR2
   -- End Bug 5726785
   ,X_ETC_QTY			OUT NOCOPY NUMBER
   ,X_ETC_RAW_COST		OUT NOCOPY NUMBER
   ,X_ETC_BURDENED_COST		OUT NOCOPY NUMBER
   ,X_ETC_REVENUE		OUT NOCOPY NUMBER
   ,X_PERIOD_RATES_TBL		OUT NOCOPY l_pds_rate_dtls_tab
   ,X_RETURN_STATUS		OUT NOCOPY VARCHAR2
   ,X_MSG_DATA			OUT NOCOPY VARCHAR2
   ,X_MSG_COUNT			OUT NOCOPY NUMBER);

END PA_FP_FCST_GEN_CLIENT_EXT;

/
