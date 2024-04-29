--------------------------------------------------------
--  DDL for Package PJI_VP_REP_DFLT_PARAMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_VP_REP_DFLT_PARAMS" AUTHID CURRENT_USER AS
/* $Header: PJIRX11S.pls 120.2 2006/09/06 10:50:25 pschandr noship $ */

PROCEDURE Derive_Default_Parameters
(p_project_id NUMBER DEFAULT NULL
, p_fin_plan_type_id NUMBER
, p_cost_version_id IN OUT NOCOPY  NUMBER
, p_rev_version_id IN OUT NOCOPY  NUMBER
, x_rbs_version_id OUT NOCOPY NUMBER
, x_rbs_element_id OUT NOCOPY NUMBER
, x_wbs_version_id OUT NOCOPY NUMBER
, x_wbs_element_id OUT NOCOPY NUMBER
, x_curr_record_type_id OUT NOCOPY NUMBER
, x_currency_code OUT NOCOPY VARCHAR2
, x_calendar_type OUT NOCOPY VARCHAR2
, x_calendar_id OUT NOCOPY NUMBER
, x_factor_by OUT NOCOPY NUMBER
, x_actual_version_id OUT NOCOPY NUMBER
, x_curr_budget_cost_version_id OUT NOCOPY NUMBER
, x_prior_fcst_cost_version_id OUT NOCOPY NUMBER
, x_orig_budget_cost_version_id OUT NOCOPY NUMBER
, x_curr_budget_rev_version_id OUT NOCOPY NUMBER
, x_prior_fcst_rev_version_id OUT NOCOPY NUMBER
, x_orig_budget_rev_version_id OUT NOCOPY NUMBER
, x_context_plan_type OUT NOCOPY VARCHAR2
, x_plan_pref_code OUT NOCOPY VARCHAR2
, x_budget_forecast_flag OUT NOCOPY VARCHAR2
, x_context_report OUT NOCOPY VARCHAR2
, x_context_margin_mask OUT NOCOPY VARCHAR2
, x_cost_version_no OUT NOCOPY VARCHAR2
, x_cost_version_name OUT NOCOPY VARCHAR2
, x_cost_record_no OUT NOCOPY VARCHAR2
, x_rev_version_no OUT NOCOPY VARCHAR2
, x_rev_version_name OUT NOCOPY VARCHAR2
, x_rev_record_no OUT NOCOPY VARCHAR2
, x_slice_name OUT NOCOPY VARCHAR2
, x_from_period OUT NOCOPY NUMBER
, x_to_period OUT NOCOPY NUMBER
, x_cost_budget_status OUT NOCOPY VARCHAR2
, x_rev_budget_status OUT NOCOPY VARCHAR2
, x_cost_editable_flag OUT NOCOPY VARCHAR2
, x_rev_editable_flag OUT NOCOPY VARCHAR2
, x_cost_app_flag     OUT NOCOPY VARCHAR2
, x_rev_app_flag     OUT NOCOPY VARCHAR2
, x_time_phase_valid_flag OUT NOCOPY VARCHAR2
, x_cross_org_flag OUT NOCOPY VARCHAR2
, x_fbs_expansion_lvl OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

END Pji_Vp_Rep_Dflt_Params;

 

/
