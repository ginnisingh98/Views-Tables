--------------------------------------------------------
--  DDL for Package PJI_REP_MEASURE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_REP_MEASURE_UTIL" AUTHID CURRENT_USER AS
/* $Header: PJIRX15S.pls 120.4.12010000.2 2009/07/23 08:58:12 atshukla ship $ */

PROCEDURE Compute_Proj_Perf_Exceptions
(
    p_commit_flag               IN VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , x_msg_data                OUT NOCOPY VARCHAR2
    , x_return_status           OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Measure_Labels
(
    p_measure_codes_tbl         IN SYSTEM.PA_VARCHAR2_80_TBL_TYPE
    , p_measure_labels_tbl      OUT NOCOPY SYSTEM.PA_VARCHAR2_240_TBL_TYPE
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , x_msg_data                OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Measure_Attributes
(
  p_measure_codes_tbl          IN SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_measure_set_codes_tbl    OUT NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE
  , x_timeslices_tbl   		OUT NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE
  , x_measure_id_tbl		OUT NOCOPY  SYSTEM.PA_NUM_TBL_TYPE
  , x_return_status              OUT NOCOPY VARCHAR2
  , x_msg_count                  OUT NOCOPY NUMBER
  , x_msg_data                   OUT NOCOPY VARCHAR2 -- not used
);

PROCEDURE Get_Financial_Measures
(
    p_project_id NUMBER
    , p_measure_codes_tbl       IN SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , p_measure_set_codes_tbl          IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT NULL
  , p_timeslices_tbl   				 IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT NULL
  , p_measure_id_tbl		 		 IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT NULL
    , x_measure_values_tbl      OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
	, x_exception_indicator_tbl OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
    --, x_exception_labels_tbl    OUT NOCOPY SYSTEM.PA_VARCHAR2_240_TBL_TYPE -- remove
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , x_msg_data                OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Activity_Measures
(
    p_project_id NUMBER
    , p_measure_codes_tbl       IN SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , p_measure_set_codes_tbl          IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT NULL
  , p_timeslices_tbl   				 IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT NULL
  , p_measure_id_tbl		 		 IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT NULL
    , x_measure_values_tbl      OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
	, x_exception_indicator_tbl OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
--    , x_exception_labels_tbl    OUT NOCOPY SYSTEM.PA_VARCHAR2_240_TBL_TYPE -- remove
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , x_msg_data                OUT NOCOPY VARCHAR2
);


g_ptd_record_type NUMBER := 256; --Record type for Period to Date
g_qtd_record_type NUMBER := 288; --Record type for Quarter to Date
g_ytd_record_type NUMBER := 352; --Record type for Year to Date
g_itd_record_type NUMBER := 1376; --Record type for Inception to Date

TYPE prf_over_time_amounts_rec IS RECORD(
     ptd NUMBER
    ,qtd NUMBER
    ,ytd NUMBER
    ,itd NUMBER
    ,ac  NUMBER
    ,prp NUMBER
);


TYPE pji_ac_proj_f_rec IS RECORD (
      ptd_active_backlog NUMBER
    , ptd_additional_funding_amount NUMBER
    , ptd_ar_cash_applied_amount NUMBER
    , ptd_ar_credit_memo_amount NUMBER
    , ptd_ar_invoice_amount NUMBER
    , ptd_ar_invoice_writeoff_amount NUMBER
    , ptd_ar_invoice_count NUMBER
    , ptd_ar_amount_due NUMBER
    , ptd_ar_amount_overdue NUMBER
    , ptd_cancelled_funding_amount NUMBER
    , ptd_dormant_backlog_inactiv NUMBER
    , ptd_dormant_backlog_start NUMBER
    , ptd_funding_adjustment_amount NUMBER
    , ptd_initial_funding_amount NUMBER
    , ptd_lost_backlog NUMBER
    , ptd_revenue NUMBER
    , ptd_revenue_at_risk NUMBER
    , ptd_revenue_writeoff NUMBER
    , ptd_unbilled_receivables NUMBER
    , ptd_unearned_revenue NUMBER
    , qtd_active_backlog NUMBER
    , qtd_additional_funding_amount NUMBER
    , qtd_ar_cash_applied_amount NUMBER
    , qtd_ar_credit_memo_amount NUMBER
    , qtd_ar_invoice_amount NUMBER
    , qtd_ar_invoice_writeoff_amount NUMBER
    , qtd_ar_invoice_count NUMBER
    , qtd_ar_amount_due NUMBER
    , qtd_ar_amount_overdue NUMBER
    , qtd_cancelled_funding_amount NUMBER
    , qtd_dormant_backlog_inactiv NUMBER
    , qtd_dormant_backlog_start NUMBER
    , qtd_funding_adjustment_amount NUMBER
    , qtd_initial_funding_amount NUMBER
    , qtd_lost_backlog NUMBER
    , qtd_revenue NUMBER
    , qtd_revenue_at_risk NUMBER
    , qtd_revenue_writeoff NUMBER
    , qtd_unbilled_receivables NUMBER
    , qtd_unearned_revenue NUMBER
    , ytd_active_backlog NUMBER
    , ytd_additional_funding_amount NUMBER
    , ytd_ar_cash_applied_amount NUMBER
    , ytd_ar_credit_memo_amount NUMBER
    , ytd_ar_invoice_amount NUMBER
    , ytd_ar_invoice_writeoff_amount NUMBER
    , ytd_ar_invoice_count NUMBER
    , ytd_ar_amount_due NUMBER
    , ytd_ar_amount_overdue NUMBER
    , ytd_cancelled_funding_amount NUMBER
    , ytd_dormant_backlog_inactiv NUMBER
    , ytd_dormant_backlog_start NUMBER
    , ytd_funding_adjustment_amount NUMBER
    , ytd_initial_funding_amount NUMBER
    , ytd_lost_backlog NUMBER
    , ytd_revenue NUMBER
    , ytd_revenue_at_risk NUMBER
    , ytd_revenue_writeoff NUMBER
    , ytd_unbilled_receivables NUMBER
    , ytd_unearned_revenue NUMBER
    , itd_active_backlog NUMBER
    , itd_additional_funding_amount NUMBER
    , itd_ar_cash_applied_amount NUMBER
    , itd_ar_credit_memo_amount NUMBER
    , itd_ar_invoice_amount NUMBER
    , itd_ar_invoice_writeoff_amount NUMBER
    , itd_ar_invoice_count NUMBER
    , itd_ar_amount_due NUMBER
    , itd_ar_amount_overdue NUMBER
    , itd_cancelled_funding_amount NUMBER
    , itd_dormant_backlog_inactiv NUMBER
    , itd_dormant_backlog_start NUMBER
    , itd_funding_adjustment_amount NUMBER
    , itd_initial_funding_amount NUMBER
    , itd_lost_backlog NUMBER
    , itd_revenue NUMBER
    , itd_revenue_at_risk NUMBER
    , itd_revenue_writeoff NUMBER
    , itd_unbilled_receivables NUMBER
    , itd_unearned_revenue NUMBER
    , ac_active_backlog NUMBER
    , ac_additional_funding_amount NUMBER
    , ac_ar_cash_applied_amount NUMBER
    , ac_ar_credit_memo_amount NUMBER
    , ac_ar_invoice_amount NUMBER
    , ac_ar_invoice_writeoff_amount NUMBER
    , ac_ar_invoice_count NUMBER
    , ac_ar_amount_due NUMBER
    , ac_ar_amount_overdue NUMBER
    , ac_cancelled_funding_amount NUMBER
    , ac_dormant_backlog_inactiv NUMBER
    , ac_dormant_backlog_start NUMBER
    , ac_funding_adjustment_amount NUMBER
    , ac_initial_funding_amount NUMBER
    , ac_lost_backlog NUMBER
    , ac_revenue NUMBER
    , ac_revenue_at_risk NUMBER
    , ac_revenue_writeoff NUMBER
    , ac_unbilled_receivables NUMBER
    , ac_unearned_revenue NUMBER
    , prp_active_backlog NUMBER
    , prp_additional_funding_amount NUMBER
    , prp_ar_cash_applied_amount NUMBER
    , prp_ar_credit_memo_amount NUMBER
    , prp_ar_invoice_amount NUMBER
    , prp_ar_invoice_writeoff_amount NUMBER
    , prp_ar_invoice_count NUMBER
    , prp_ar_amount_due NUMBER
    , prp_ar_amount_overdue NUMBER
    , prp_cancelled_funding_amount NUMBER
    , prp_dormant_backlog_inactiv NUMBER
    , prp_dormant_backlog_start NUMBER
    , prp_funding_adjustment_amount NUMBER
    , prp_initial_funding_amount NUMBER
    , prp_lost_backlog NUMBER
    , prp_revenue NUMBER
    , prp_revenue_at_risk NUMBER
    , prp_revenue_writeoff NUMBER
    , prp_unbilled_receivables NUMBER
    , prp_unearned_revenue NUMBER
    , ptd_custom_1 NUMBER
    , ptd_custom_2 NUMBER
    , ptd_custom_3 NUMBER
    , ptd_custom_4 NUMBER
    , ptd_custom_5 NUMBER
    , ptd_custom_6 NUMBER
    , ptd_custom_7 NUMBER
    , ptd_custom_8 NUMBER
    , ptd_custom_9 NUMBER
    , ptd_custom_10 NUMBER
    , ptd_custom_11 NUMBER
    , ptd_custom_12 NUMBER
    , ptd_custom_13 NUMBER
    , ptd_custom_14 NUMBER
    , ptd_custom_15 NUMBER
    , ptd_custom_16 NUMBER
    , ptd_custom_17 NUMBER
    , ptd_custom_18 NUMBER
    , ptd_custom_19 NUMBER
    , ptd_custom_20 NUMBER
    , ptd_custom_21 NUMBER
    , ptd_custom_22 NUMBER
    , ptd_custom_23 NUMBER
    , ptd_custom_24 NUMBER
    , ptd_custom_25 NUMBER
    , ptd_custom_26 NUMBER
    , ptd_custom_27 NUMBER
    , ptd_custom_28 NUMBER
    , ptd_custom_29 NUMBER
    , ptd_custom_30 NUMBER
    , qtd_custom_1 NUMBER
    , qtd_custom_2 NUMBER
    , qtd_custom_3 NUMBER
    , qtd_custom_4 NUMBER
    , qtd_custom_5 NUMBER
    , qtd_custom_6 NUMBER
    , qtd_custom_7 NUMBER
    , qtd_custom_8 NUMBER
    , qtd_custom_9 NUMBER
    , qtd_custom_10 NUMBER
    , qtd_custom_11 NUMBER
    , qtd_custom_12 NUMBER
    , qtd_custom_13 NUMBER
    , qtd_custom_14 NUMBER
    , qtd_custom_15 NUMBER
    , qtd_custom_16 NUMBER
    , qtd_custom_17 NUMBER
    , qtd_custom_18 NUMBER
    , qtd_custom_19 NUMBER
    , qtd_custom_20 NUMBER
    , qtd_custom_21 NUMBER
    , qtd_custom_22 NUMBER
    , qtd_custom_23 NUMBER
    , qtd_custom_24 NUMBER
    , qtd_custom_25 NUMBER
    , qtd_custom_26 NUMBER
    , qtd_custom_27 NUMBER
    , qtd_custom_28 NUMBER
    , qtd_custom_29 NUMBER
    , qtd_custom_30 NUMBER
    , ytd_custom_1 NUMBER
    , ytd_custom_2 NUMBER
    , ytd_custom_3 NUMBER
    , ytd_custom_4 NUMBER
    , ytd_custom_5 NUMBER
    , ytd_custom_6 NUMBER
    , ytd_custom_7 NUMBER
    , ytd_custom_8 NUMBER
    , ytd_custom_9 NUMBER
    , ytd_custom_10 NUMBER
    , ytd_custom_11 NUMBER
    , ytd_custom_12 NUMBER
    , ytd_custom_13 NUMBER
    , ytd_custom_14 NUMBER
    , ytd_custom_15 NUMBER
    , ytd_custom_16 NUMBER
    , ytd_custom_17 NUMBER
    , ytd_custom_18 NUMBER
    , ytd_custom_19 NUMBER
    , ytd_custom_20 NUMBER
    , ytd_custom_21 NUMBER
    , ytd_custom_22 NUMBER
    , ytd_custom_23 NUMBER
    , ytd_custom_24 NUMBER
    , ytd_custom_25 NUMBER
    , ytd_custom_26 NUMBER
    , ytd_custom_27 NUMBER
    , ytd_custom_28 NUMBER
    , ytd_custom_29 NUMBER
    , ytd_custom_30 NUMBER
    , itd_custom_1 NUMBER
    , itd_custom_2 NUMBER
    , itd_custom_3 NUMBER
    , itd_custom_4 NUMBER
    , itd_custom_5 NUMBER
    , itd_custom_6 NUMBER
    , itd_custom_7 NUMBER
    , itd_custom_8 NUMBER
    , itd_custom_9 NUMBER
    , itd_custom_10 NUMBER
    , itd_custom_11 NUMBER
    , itd_custom_12 NUMBER
    , itd_custom_13 NUMBER
    , itd_custom_14 NUMBER
    , itd_custom_15 NUMBER
    , itd_custom_16 NUMBER
    , itd_custom_17 NUMBER
    , itd_custom_18 NUMBER
    , itd_custom_19 NUMBER
    , itd_custom_20 NUMBER
    , itd_custom_21 NUMBER
    , itd_custom_22 NUMBER
    , itd_custom_23 NUMBER
    , itd_custom_24 NUMBER
    , itd_custom_25 NUMBER
    , itd_custom_26 NUMBER
    , itd_custom_27 NUMBER
    , itd_custom_28 NUMBER
    , itd_custom_29 NUMBER
    , itd_custom_30 NUMBER
    , ac_custom_1 NUMBER
    , ac_custom_2 NUMBER
    , ac_custom_3 NUMBER
    , ac_custom_4 NUMBER
    , ac_custom_5 NUMBER
    , ac_custom_6 NUMBER
    , ac_custom_7 NUMBER
    , ac_custom_8 NUMBER
    , ac_custom_9 NUMBER
    , ac_custom_10 NUMBER
    , ac_custom_11 NUMBER
    , ac_custom_12 NUMBER
    , ac_custom_13 NUMBER
    , ac_custom_14 NUMBER
    , ac_custom_15 NUMBER
    , ac_custom_16 NUMBER
    , ac_custom_17 NUMBER
    , ac_custom_18 NUMBER
    , ac_custom_19 NUMBER
    , ac_custom_20 NUMBER
    , ac_custom_21 NUMBER
    , ac_custom_22 NUMBER
    , ac_custom_23 NUMBER
    , ac_custom_24 NUMBER
    , ac_custom_25 NUMBER
    , ac_custom_26 NUMBER
    , ac_custom_27 NUMBER
    , ac_custom_28 NUMBER
    , ac_custom_29 NUMBER
    , ac_custom_30 NUMBER
    , prp_custom_1 NUMBER
    , prp_custom_2 NUMBER
    , prp_custom_3 NUMBER
    , prp_custom_4 NUMBER
    , prp_custom_5 NUMBER
    , prp_custom_6 NUMBER
    , prp_custom_7 NUMBER
    , prp_custom_8 NUMBER
    , prp_custom_9 NUMBER
    , prp_custom_10 NUMBER
    , prp_custom_11 NUMBER
    , prp_custom_12 NUMBER
    , prp_custom_13 NUMBER
    , prp_custom_14 NUMBER
    , prp_custom_15 NUMBER
    , prp_custom_16 NUMBER
    , prp_custom_17 NUMBER
    , prp_custom_18 NUMBER
    , prp_custom_19 NUMBER
    , prp_custom_20 NUMBER
    , prp_custom_21 NUMBER
    , prp_custom_22 NUMBER
    , prp_custom_23 NUMBER
    , prp_custom_24 NUMBER
    , prp_custom_25 NUMBER
    , prp_custom_26 NUMBER
    , prp_custom_27 NUMBER
    , prp_custom_28 NUMBER
    , prp_custom_29 NUMBER
    , prp_custom_30 NUMBER
);

/**
 ** For a given Project_id and a set of Currenct plan versions,
 ** this API extracts their relative
 ** Original baseline plan versions IDs,
 ** Current baseline plan types IDs,
 ** and Original baseline plan types IDs.
 **
 ** History
 **   21-APR-2004   EPASQUIN    Created
 **/
PROCEDURE get_plan_type_info
(
    p_project_id               NUMBER
  , pActualVersionId           NUMBER
  , pCstForecastVersionId      NUMBER
  , pCstBudgetVersionId        NUMBER
  , pCstBudget2VersionId       NUMBER
  , pRevForecastVersionId      NUMBER
  , pRevBudgetVersionId        NUMBER
  , pRevBudget2VersionId       NUMBER
  , xOrigCstForecastVersionId  OUT NOCOPY NUMBER
  , xOrigCstBudgetVersionId    OUT NOCOPY NUMBER
  , xOrigCstBudget2VersionId   OUT NOCOPY NUMBER
  , xOrigRevForecastVersionId  OUT NOCOPY NUMBER
  , xOrigRevBudgetVersionId    OUT NOCOPY NUMBER
  , xOrigRevBudget2VersionId   OUT NOCOPY NUMBER
  , xActualPlanTypeId          OUT NOCOPY NUMBER
  , xCstForecastPlanTypeId     OUT NOCOPY NUMBER
  , xCstBudgetPlanTypeId       OUT NOCOPY NUMBER
  , xCstBudget2PlanTypeId      OUT NOCOPY NUMBER
  , xRevForecastPlanTypeId     OUT NOCOPY NUMBER
  , xRevBudgetPlanTypeId       OUT NOCOPY NUMBER
  , xRevBudget2PlanTypeId      OUT NOCOPY NUMBER
  , x_return_status            OUT NOCOPY VARCHAR2
  , x_msg_count                OUT NOCOPY NUMBER
  , x_msg_data                 OUT NOCOPY VARCHAR2
);


/**
 ** This API prepares, calculates and retrieves the measures to be used by
 ** Overview Page and breakdown pages.
 **
 ** History
 **   16-MAR-2004   EPASQUIN    Created
 **   21-APR-2004   EPASQUIN    Introduced Plan_types parameters
 **
 **/
PROCEDURE prepareData
(
    pProjectId                  NUMBER
  , pWBSVersionId               NUMBER
  , pWBSElementId               NUMBER
  , pRBSVersionId               NUMBER
  , pRBSElementId               NUMBER
  , pCalendarId                 NUMBER
  , pCalendarType               VARCHAR2
  , pPeriodDateJulian           NUMBER
  , pActualVersionId            NUMBER
  , pCstForecastVersionId       NUMBER
  , pCstBudgetVersionId         NUMBER
  , pCstBudget2VersionId        NUMBER
  , pRevForecastVersionId       NUMBER
  , pRevBudgetVersionId         NUMBER
  , pRevBudget2VersionId        NUMBER
  , pOrigCstForecastVersionId   NUMBER
  , pOrigCstBudgetVersionId     NUMBER
  , pOrigCstBudget2VersionId    NUMBER
  , pOrigRevForecastVersionId   NUMBER
  , pOrigRevBudgetVersionId     NUMBER
  , pOrigRevBudget2VersionId    NUMBER
  , pPriorCstForecastVersionId  NUMBER
  , pPriorRevForecastVersionId  NUMBER
  , pActualPlanTypeId           NUMBER
  , pCstForecastPlanTypeId      NUMBER
  , pCstBudgetPlanTypeId        NUMBER
  , pCstBudget2PlanTypeId       NUMBER
  , pRevForecastPlanTypeId      NUMBER
  , pRevBudgetPlanTypeId        NUMBER
  , pRevBudget2PlanTypeId       NUMBER
  , pCurrencyRecordType         NUMBER
  , pCurrencyCode               VARCHAR2
  , pFactorBy                   NUMBER   -- to be applied to every CURRENCY measure
  , pEffortUOM                  NUMBER   -- to be applied to every HOURS measure
  , pCurrencyType               VARCHAR2
  , pTimeSlice                  NUMBER
  , pPrgRollup                  VARCHAR2
  , pReportType                 VARCHAR2
  , pWBSRollupFlag				VARCHAR2 DEFAULT 'Y'
  , pRBSRollupFlag				VARCHAR2 DEFAULT 'Y'
  , pPeriodName					VARCHAR2
  , xDaysSinceITD               OUT NOCOPY NUMBER
  , xDaysInPeriod               OUT NOCOPY NUMBER
  , x_return_status             OUT NOCOPY VARCHAR2
  , x_msg_count                 OUT NOCOPY NUMBER
  , x_msg_data                  OUT NOCOPY VARCHAR2
);


/**
 ** Given a list of wanted measures, this API retrieves them in arrays
 ** executing all necessary calculations.
 **
 ** History
 **   16-MAR-2004   EPASQUIN    Created
 **   21-APR-2004   EPASQUIN    Introduced Plan_types parameters
 **
 **/
PROCEDURE retrieveData
(
  pProjectId                    NUMBER
  , pWBSVersionId               NUMBER
  , pWBSElementId               NUMBER
  , pRBSVersionId               NUMBER
  , pRBSElementId               NUMBER
  , pCalendarId                 NUMBER
  , pCalendarType               VARCHAR2
  , pPeriodDateJulian           NUMBER
  , pActualVersionId            NUMBER
  , pCstForecastVersionId       NUMBER
  , pCstBudgetVersionId         NUMBER
  , pCstBudget2VersionId        NUMBER
  , pRevForecastVersionId       NUMBER
  , pRevBudgetVersionId         NUMBER
  , pRevBudget2VersionId        NUMBER
  , pOrigCstForecastVersionId   NUMBER
  , pOrigCstBudgetVersionId     NUMBER
  , pOrigCstBudget2VersionId    NUMBER
  , pOrigRevForecastVersionId   NUMBER
  , pOrigRevBudgetVersionId     NUMBER
  , pOrigRevBudget2VersionId    NUMBER
  , pPriorCstForecastVersionId  NUMBER
  , pPriorRevForecastVersionId  NUMBER
  , pActualPlanTypeId           NUMBER
  , pCstForecastPlanTypeId      NUMBER
  , pCstBudgetPlanTypeId        NUMBER
  , pCstBudget2PlanTypeId       NUMBER
  , pRevForecastPlanTypeId      NUMBER
  , pRevBudgetPlanTypeId        NUMBER
  , pRevBudget2PlanTypeId       NUMBER
  , pCurrencyRecordType         NUMBER
  , pCurrencyCode               VARCHAR2
  , pFactorBy                   NUMBER   -- to be applied to every CURRENCY measure
  , pEffortUOM                  NUMBER   -- to be applied to every HOURS measure
  , pCurrencyType               VARCHAR2
  , pTimeSlice                  NUMBER
  , pPrgRollup                  VARCHAR2
  , pReportType                 VARCHAR2
  , pPeriodName					VARCHAR2
  , p_measure_set_code          IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
  , p_raw_text_flag				VARCHAR2 DEFAULT 'Y'
  , pWBSRollupFlag				VARCHAR2 DEFAULT 'Y'
  , pRBSRollupFlag				VARCHAR2 DEFAULT 'Y'
  , pCallingType				VARCHAR2
  , p_measure_id_tbl			IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT NULL
  , x_exception_indicator_tbl	OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
  , x_measure_type              OUT NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE
  , x_ptd_value                 OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_qtd_value                 OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_ytd_value                 OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_itd_value                 OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_ac_value                  OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_prp_value                 OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_ptd_html                  OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
  , x_qtd_html                  OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
  , x_ytd_html                  OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
  , x_itd_html                  OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
  , x_ac_html                   OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
  , x_prp_html                  OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
  , x_ptd_trans_id	     		OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
  , x_ytd_trans_id	     		OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
  , x_qtd_trans_id	     		OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
  , x_itd_trans_id	     		OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
  , x_ac_trans_id	     	 	OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
  , x_prp_trans_id	     	 	OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
  , x_ptd_meaning      OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_ytd_meaning      OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_qtd_meaning      OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_itd_meaning      OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_ac_meaning       OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_prp_meaning      OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , xDaysSinceITD               OUT NOCOPY NUMBER
  , xDaysInPeriod               OUT NOCOPY NUMBER
  , x_return_status             IN OUT NOCOPY VARCHAR2
  , x_msg_count                 IN OUT NOCOPY NUMBER
  , x_msg_data                  IN OUT NOCOPY VARCHAR2
);


PROCEDURE Merge_Overview_Type
(
 p_source_index IN NUMBER
 ,p_source_table IN pji_rep_overview_type_tbl
 ,p_target_index IN NUMBER
 ,p_target_table IN OUT NOCOPY pji_rep_overview_type_tbl
);


/* Added new procedure for Bug 7533980
 * which takes in a table of project_ids
 * and returns back 2 tables of records
 */
PROCEDURE Get_Financial_Measures_wrp
(
    p_project_id_tbl             IN SYSTEM.pa_num_tbl_type
  , p_measure_codes_tbl          IN SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , p_measure_set_codes_tbl      IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT NULL
  , p_timeslices_tbl   		 IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT NULL
  , p_measure_id_tbl		 IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT NULL
  , x_measure_values_tbl         OUT NOCOPY SYSTEM.PJI_FIN_MEAS_REC_TBL_TYPE
  , x_exception_indicator_tbl    OUT NOCOPY SYSTEM.PJI_EXCP_IND_REC_TBL_TYPE
  --, x_exception_labels_tbl       OUT NOCOPY SYSTEM.PA_VARCHAR2_240_TBL_TYPE
  , x_return_status              OUT NOCOPY VARCHAR2
  , x_msg_count                  OUT NOCOPY NUMBER
  , x_msg_data                   OUT NOCOPY VARCHAR2 -- not used
);


END Pji_Rep_Measure_Util;

/
