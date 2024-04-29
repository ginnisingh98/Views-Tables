--------------------------------------------------------
--  DDL for Package Body PJI_VP_REP_DFLT_PARAMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_VP_REP_DFLT_PARAMS" AS
/* $Header: PJIRX11B.pls 120.2 2006/09/06 10:51:18 pschandr noship $ */


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
, x_msg_data IN OUT NOCOPY VARCHAR2)
IS
l_currency_type VARCHAR2(256);
l_period_name VARCHAR2(256);
l_report_date_julian NUMBER;
l_valid_version_id NUMBER;
l_version_type VARCHAR2(10);
l_fp_options_id NUMBER;
l_plan_version_ids	     SYSTEM.PA_NUM_TBL_TYPE;
l_context_version_type VARCHAR(10);
BEGIN
/*	x_rbs_element_id :=  3667;
	x_wbs_element_id := 2255;
	x_rbs_version_di :=714;
	x_wbs_version_id :=458;
	x_factor_by := 1;
	x_curr_budget_cost_version_id := 2383;
	x_prior_fcst_cost_version_id := 2398;
	x_orig_budget_cost_version_id := 2383;
	x_curr_budget_rev_version_id := 2392;
	x_prior_fcst_rev_version_id := 2399;
	x_orig_budget_rev_version_id := 2392;
 	x_curr_record_type_id :=8;
	x_currency_code :='USD';
	x_calendar_type :='A';
	x_calendar_id :=24;
	x_cost_version_no :=1;
	x_cost_version_name := 'Cost Forecast - I Version 1';
	x_cost_record_no :=1;
	x_rev_version_no :=1;
	x_rev_version_name := 'Revenue Forecast - I Version 1';
	x_rev_record_no :=1;
	x_plan_pref_code := 'COST_AND_REVENUE_SEP';
	x_budget_forecast_flag := 'F';
	x_context_report := 'COST';
	x_context_margin_mask := 'B';
	x_context_plan_type := 'Cost Forecast - I';
*/

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;


	x_actual_version_id :=  Pji_Rep_Util.get_fin_plan_actual_version(p_project_id);

	IF (p_cost_version_id IS NOT NULL) AND (p_cost_version_id <> -99) THEN
	   l_valid_version_id := p_cost_version_id;
	   l_context_version_type := 'COST';
	ELSE
	   l_valid_version_id := p_rev_version_id;
	   l_context_version_type := 'REVENUE';
	END IF;


	x_factor_by := Pji_Rep_Util.Derive_Factorby(
	p_project_id
	, l_valid_version_id -- bug 3793041
	, x_return_status
	, x_msg_count
	, x_msg_data);

	Pji_Rep_Util.Derive_Default_RBS_Parameters(p_project_id
	, l_valid_version_id
	, x_rbs_version_id
	, x_rbs_element_id
	, x_return_status
	, x_msg_count
	, x_msg_data);

	Pji_Rep_Util.Derive_Default_WBS_Parameters(p_project_id
	, l_valid_version_id
	, x_wbs_version_id
	, x_wbs_element_id
	, x_return_status
	, x_msg_count
	, x_msg_data);

	Pji_Rep_Util.Derive_Default_Currency_Info(
	p_project_id
	, x_curr_record_type_id
	, x_currency_code
	, l_currency_type
	, x_return_status
	, x_msg_count
	, x_msg_data);


	Pji_Rep_Util.Derive_Plan_Type_Parameters(
	p_project_id
	, p_fin_plan_type_id
	, x_plan_pref_code
	, x_budget_forecast_flag
	, x_context_plan_type
	, x_context_report
	, x_context_margin_mask
        , x_cost_app_flag
        , x_rev_app_flag
	, x_return_status
	, x_msg_count
	, x_msg_data);

	--Bug 5469672 Derive the default FBS expansion level
	x_fbs_expansion_lvl := pji_rep_util.GET_DEFAULT_EXPANSION_LEVEL(p_project_id, 'FT');

	IF x_plan_pref_code = 'COST_AND_REV_SAME' THEN
	   l_version_type := 'ALL';
	ELSE
	   l_version_type := 'COST';
	END IF;

	IF (p_cost_version_id IS NOT NULL) AND (p_cost_version_id <>-99) THEN
		Pji_Rep_Util.Derive_Version_Parameters(
		p_cost_version_id
		, x_cost_version_name
		, x_cost_version_no
		, x_cost_record_no
		, x_cost_budget_status
		, x_return_status
		, x_msg_count
		, x_msg_data);

		Pji_Rep_Util.Derive_Fin_Plan_Versions(p_project_id
		,p_cost_version_id
		, x_curr_budget_cost_version_id
		, x_orig_budget_cost_version_id
		, x_prior_fcst_cost_version_id
		, x_return_status
		, x_msg_count
		, x_msg_data);

		IF ((x_plan_pref_code = 'COST_AND_REV_SEP') AND ((p_rev_version_id IS NULL) OR (p_rev_version_id =-99))) THEN

		   IF (x_cost_budget_status <> 'B') THEN
	         Pa_Fin_Plan_Utils.Get_Curr_Working_Version_Info(
	         p_project_id           => p_project_id,
	         p_fin_plan_type_id     => p_fin_plan_type_id,
	         p_version_type         => 'REVENUE',
	         x_fp_options_id        => l_fp_options_id,
	         x_fin_plan_version_id  => p_rev_version_id,
	         x_return_status        => x_return_status,
	         x_msg_count            => x_msg_count,
	         x_msg_data             => x_msg_data);
		   ELSE
	         Pa_Fin_Plan_Utils.Get_Baselined_Version_Info(
	         p_project_id           => p_project_id,
	         p_fin_plan_type_id     => p_fin_plan_type_id,
	         p_version_type         => 'REVENUE',
	         x_fp_options_id        => l_fp_options_id,
	         x_fin_plan_version_id  => p_rev_version_id,
	         x_return_status        => x_return_status,
	         x_msg_count            => x_msg_count,
	         x_msg_data             => x_msg_data);
		   END IF;
		END IF;

	END IF;

	IF (p_rev_version_id IS NOT NULL) AND (p_rev_version_id <> -99) THEN

		Pji_Rep_Util.Derive_Version_Parameters(
		p_rev_version_id
		, x_rev_version_name
		, x_rev_version_no
		, x_rev_record_no
		, x_rev_budget_status
		, x_return_status
		, x_msg_count
		, x_msg_data);

		Pji_Rep_Util.Derive_Fin_Plan_Versions(p_project_id
		,p_rev_version_id
		, x_curr_budget_rev_version_id
		, x_orig_budget_rev_version_id
		, x_prior_fcst_rev_version_id
		, x_return_status
		, x_msg_count
		, x_msg_data);

		IF ((x_plan_pref_code = 'COST_AND_REV_SEP') AND ((p_cost_version_id IS NULL) OR (p_cost_version_id =-99))) THEN

		   IF (x_rev_budget_status <> 'B') THEN
	         Pa_Fin_Plan_Utils.Get_Curr_Working_Version_Info(
	         p_project_id           => p_project_id,
	         p_fin_plan_type_id     => p_fin_plan_type_id,
	         p_version_type         => l_version_type,
	         x_fp_options_id        => l_fp_options_id,
	         x_fin_plan_version_id  => p_cost_version_id,
	         x_return_status        => x_return_status,
	         x_msg_count            => x_msg_count,
	         x_msg_data             => x_msg_data);
		   ELSE
	         Pa_Fin_Plan_Utils.Get_Baselined_Version_Info(
	         p_project_id           => p_project_id,
	         p_fin_plan_type_id     => p_fin_plan_type_id,
	         p_version_type         => l_version_type,
	         x_fp_options_id        => l_fp_options_id,
	         x_fin_plan_version_id  => p_cost_version_id,
	         x_return_status        => x_return_status,
	         x_msg_count            => x_msg_count,
	         x_msg_data             => x_msg_data);
		   END IF;

			Pji_Rep_Util.Derive_Version_Parameters(
			p_cost_version_id
			, x_cost_version_name
			, x_cost_version_no
			, x_cost_record_no
			, x_cost_budget_status
			, x_return_status
			, x_msg_count
			, x_msg_data);

			Pji_Rep_Util.Derive_Fin_Plan_Versions(p_project_id
			,p_cost_version_id
			, x_curr_budget_cost_version_id
			, x_orig_budget_cost_version_id
			, x_prior_fcst_cost_version_id
			, x_return_status
			, x_msg_count
			, x_msg_data);
		 END IF;

	END IF;

	/* At this point, if the plan type is cost_and_rev_sep,
	 * the version has already be derived.
	 * It is important to call Deriv_Vp_Calendar_Info after calling
	 * derive_cur_working_ver_info because only after deriving the plan
	 * versions, we can compare whether the two plan versions have the same
	 * time phased code. Whatever the plan version is when we enter the page
	 * we always use the Cost version's calendar infor if both versions are
	 * time phased and they are not the same.
	 */
	Pji_Rep_Util.Derive_Vp_Calendar_Info(
	p_project_id
	, p_cost_version_id
	, p_rev_version_id
	, l_context_version_type
	, x_calendar_id
	, x_calendar_type
	, x_time_phase_valid_flag
	, x_return_status
	, x_msg_count
	, x_msg_data);


	Pji_Rep_Util.Derive_Slice_Name(
	p_project_id
	, x_calendar_id
	, x_slice_name
	, x_return_status
	, x_msg_count
	, x_msg_data);


	l_plan_version_ids := SYSTEM.PA_NUM_TBL_TYPE(
	 p_cost_version_id
	, p_rev_version_id
	, x_actual_version_id
	, x_curr_budget_cost_version_id
	, x_prior_fcst_cost_version_id
	, x_orig_budget_cost_version_id
	, x_curr_budget_rev_version_id
	, x_prior_fcst_rev_version_id
	, x_orig_budget_rev_version_id);

	Pji_Rep_Util.Derive_VP_Period(
	p_project_id
	, l_plan_version_ids
	, x_from_period
	, x_to_period
	, x_return_status
	, x_msg_count
	, x_msg_data);


	Pa_Fin_Plan_Utils.CHECK_IF_PLAN_TYPE_EDITABLE(
	P_PROJECT_ID
	,P_FIN_PLAN_TYPE_ID
	,l_version_type
	,X_COST_EDITABLE_FLAG
	, X_RETURN_STATUS
	, X_MSG_COUNT
	, X_MSG_DATA );

	Pa_Fin_Plan_Utils.CHECK_IF_PLAN_TYPE_EDITABLE(
	P_PROJECT_ID
	,P_FIN_PLAN_TYPE_ID
	,'REVENUE'
	,X_REV_EDITABLE_FLAG
	, X_RETURN_STATUS
	, X_MSG_COUNT
	, X_MSG_DATA );


	Pji_Rep_Util.Check_Cross_Org(
	P_PROJECT_ID
	,X_CROSS_ORG_FLAG
	, X_RETURN_STATUS
	, X_MSG_COUNT
	, X_MSG_DATA );

	IF x_cost_editable_flag = 'Y' THEN
	   x_cost_editable_flag := 'T';
	ELSE
	   x_cost_editable_flag := 'F';
	END IF;

	IF x_rev_editable_flag = 'Y' THEN
	   x_rev_editable_flag := 'T';
	ELSE
	   x_rev_editable_flag := 'F';
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	x_msg_count := 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Pji_Rep_Util.Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Vp_Rep_Dflt_Params.Derive_Default_Parameters');
	RAISE;
END Derive_Default_Parameters;

END Pji_Vp_Rep_Dflt_Params;

/
