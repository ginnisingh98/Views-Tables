--------------------------------------------------------
--  DDL for Package Body PJI_REP_PRF_DFLT_PARAMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_REP_PRF_DFLT_PARAMS" AS
/* $Header: PJIRX08B.pls 120.9 2006/10/20 13:19:33 ajdas noship $ */

--
-- This api will derive default values for the listed parameters
--
PROCEDURE derive_dflt_params(
  p_project_id                   NUMBER
, x_WBS_Version_ID               OUT NOCOPY NUMBER
, x_WBS_Element_Id               OUT NOCOPY NUMBER
, x_RBS_Version_ID               OUT NOCOPY NUMBER
, x_RBS_Element_Id               OUT NOCOPY NUMBER
, x_calendar_id                  OUT NOCOPY NUMBER
, x_calendar_type                OUT NOCOPY VARCHAR2
, x_report_date_julian           OUT NOCOPY NUMBER
, x_period_name                  OUT NOCOPY VARCHAR2
, x_actual_version_id            OUT NOCOPY NUMBER
, x_cstforecast_version_id       OUT NOCOPY NUMBER
, x_cstbudget_version_id         OUT NOCOPY NUMBER
, x_cstbudget2_version_id        OUT NOCOPY NUMBER
, x_revforecast_version_id       OUT NOCOPY NUMBER
, x_revbudget_version_id         OUT NOCOPY NUMBER
, x_revbudget2_version_id        OUT NOCOPY NUMBER
, x_orig_cstbudget_version_id    OUT NOCOPY NUMBER
, x_orig_cstbudget2_version_id   OUT NOCOPY NUMBER
, x_orig_revbudget_version_id    OUT NOCOPY NUMBER
, x_orig_revbudget2_version_id   OUT NOCOPY NUMBER
, x_prior_cstforecast_version_id OUT NOCOPY NUMBER
, x_prior_revforecast_version_id OUT NOCOPY NUMBER
, x_cstforecast_plan_type_id	 OUT NOCOPY NUMBER
, x_cstbudget_plan_type_id		 OUT NOCOPY NUMBER
, x_cstbudget2_plan_type_id		 OUT NOCOPY NUMBER
, x_revforecast_plan_type_id	 OUT NOCOPY NUMBER
, x_revbudget_plan_type_id		 OUT NOCOPY NUMBER
, x_revbudget2_plan_type_id		 OUT NOCOPY NUMBER
, x_currency_record_type         OUT NOCOPY NUMBER
, x_Currency_Code                OUT NOCOPY VARCHAR2
, x_currency_type                OUT NOCOPY VARCHAR2
, x_Factor_By                    OUT NOCOPY NUMBER
, x_prg_display                   OUT NOCOPY VARCHAR2
, x_Effort_UOM                   OUT NOCOPY NUMBER
, x_slice_name                   OUT NOCOPY VARCHAR2
, x_task_ref_flag                OUT NOCOPY VARCHAR2
, x_time_slice                   OUT NOCOPY INTEGER
, x_page_links_selection         OUT NOCOPY VARCHAR2
, x_from_period                  OUT NOCOPY NUMBER
, x_to_period                    OUT NOCOPY NUMBER
, x_project_type				 OUT NOCOPY VARCHAR2
, x_ptc_flag					 OUT NOCOPY VARCHAR2
, p_prg_rollup					 IN OUT NOCOPY VARCHAR2
, x_Return_Status                OUT NOCOPY VARCHAR2
, x_Msg_Count                    OUT NOCOPY NUMBER
, x_Msg_Data                     OUT NOCOPY VARCHAR2
, p_currency_record_type				 VARCHAR2 DEFAULT NULL
, p_period_type					 VARCHAR2 DEFAULT NULL
, p_as_of_date					 NUMBER DEFAULT NULL
, p_cstbudget_plan_type_id		 NUMBER DEFAULT NULL
, p_cstforecast_plan_type_id	 NUMBER DEFAULT NULL
, p_revbudget_plan_type_id		 NUMBER DEFAULT NULL
, p_revforecast_plan_type_id	 NUMBER DEFAULT NULL
, p_calling_type				 VARCHAR DEFAULT NULL
, x_fbs_expansion_lvl                    OUT NOCOPY NUMBER
) IS

l_context_plan_version NUMBER;
l_plan_version_ids	     SYSTEM.PA_NUM_TBL_TYPE;
l_i						 NUMBER;
BEGIN


	/* This call has to appear as the first one because we do a fnd_initialize
	 * at the end to avoid error from PA api
	 */

	Pji_Rep_Util.Derive_Default_Plan_Type_Ids(p_project_id
		, x_cstforecast_plan_type_id
		, x_cstbudget_plan_type_id
		, x_cstbudget2_plan_type_id
		, x_revforecast_plan_type_id
		, x_revbudget_plan_type_id
		, x_revbudget2_plan_type_id
		, x_return_status, x_msg_count, x_msg_data);

	IF  p_calling_type = 'PJI' THEN
		Pji_Rep_Util.Validate_Plan_Type(p_project_id
		, p_cstbudget_plan_type_id
		, x_cstbudget_plan_type_id
		, x_return_status, x_msg_count, x_msg_data);
		Pji_Rep_Util.Validate_Plan_Type(p_project_id
		, p_revbudget_plan_type_id
		, x_revbudget_plan_type_id
		, x_return_status, x_msg_count, x_msg_data);
		Pji_Rep_Util.Validate_Plan_Type(p_project_id
		, p_cstforecast_plan_type_id
		, x_cstforecast_plan_type_id
		, x_return_status, x_msg_count, x_msg_data);
		Pji_Rep_Util.Validate_Plan_Type(p_project_id
		, p_revforecast_plan_type_id
		, x_revforecast_plan_type_id
		, x_return_status, x_msg_count, x_msg_data);
	END IF;

    Pji_Rep_Util.Derive_Plan_Version_Ids(p_project_id
		, x_cstforecast_plan_type_id
		, x_cstbudget_plan_type_id
		, x_cstbudget2_plan_type_id
		, x_revforecast_plan_type_id
		, x_revbudget_plan_type_id
		, x_revbudget2_plan_type_id
		, x_cstforecast_version_id
		, x_cstbudget_version_id
		, x_cstbudget2_version_id
		, x_revforecast_version_id
		, x_revbudget_version_id
		, x_revbudget2_version_id
		, x_orig_cstbudget_version_id
		, x_orig_cstbudget2_version_id
		, x_orig_revbudget_version_id
		, x_orig_revbudget2_version_id
		, x_prior_cstforecast_version_id
		, x_prior_revforecast_version_id
		, x_return_status, x_msg_count, x_msg_data);

	x_actual_version_id := Pji_Rep_Util.Get_Fin_Plan_Actual_Version(p_project_id);


	IF p_calling_type = 'PJI' THEN
--Bug 5593229

	   x_calendar_type := NVL(Fnd_Profile.value('PJI_DEF_RPT_CAL_TYPE'), 'E');

	    Pji_Rep_Util.Derive_Pji_Calendar_Info(p_project_id
		  , p_period_type
		  , p_as_of_date
	      , x_calendar_type
	      , x_calendar_id
	      , x_period_name
	      , x_report_date_julian
		  , x_slice_name
	      , x_return_status
	      , x_msg_count
	      , x_msg_data);

	ELSE
    Pji_Rep_Util.Derive_Default_Calendar_Info(p_project_id
      , x_calendar_type
      , x_calendar_id
      , x_period_name
      , x_report_date_julian
	  , x_slice_name
      , x_return_status
      , x_msg_count
      , x_msg_data);
    END IF;

	IF p_calling_type = 'PJI' THEN
	    Pji_Rep_Util.Derive_Pji_Currency_Info(p_project_id
		  , p_currency_record_type
	      , x_currency_record_type, x_currency_code, x_currency_type
	      , x_return_status, x_msg_count, x_msg_data);
	ELSE
	    Pji_Rep_Util.Derive_Perf_Currency_Info(p_project_id
	      , x_currency_record_type, x_currency_code, x_currency_type
	      , x_return_status, x_msg_count, x_msg_data);
	END IF;

    x_prg_display := Pji_Rep_Util.Derive_Prg_rollup_flag(p_project_id);

	IF (x_prg_display = 'N') OR (p_prg_rollup = 'N') THEN
		p_prg_rollup := 'N';
	ELSE
		p_prg_rollup := 'Y';
	END IF;

    Pji_Rep_Util.Derive_Perf_RBS_Parameters(p_project_id
      , x_cstbudget_version_id
	  , p_prg_rollup
      , x_RBS_Version_ID, x_RBS_Element_Id
      , x_return_status, x_msg_count, x_msg_data);

    IF x_cstbudget_version_id IS NOT NULL THEN
      l_context_plan_version := x_cstbudget_version_id;
    ELSIF x_cstforecast_version_id IS NOT NULL THEN
      l_context_plan_version := x_cstforecast_version_id;
    ELSIF x_revbudget_version_id IS NOT NULL THEN
      l_context_plan_version := x_revbudget_version_id;
    ELSIF x_revforecast_version_id IS NOT NULL THEN
      l_context_plan_version := x_revforecast_version_id;
    ELSIF x_cstbudget2_version_id IS NOT NULL THEN
      l_context_plan_version := x_cstbudget2_version_id;
    ELSIF x_revbudget2_version_id IS NOT NULL THEN
      l_context_plan_version := x_revbudget2_version_id;
    ELSE
      l_context_plan_version := x_actual_version_id;
    END IF;

    x_Factor_By := Pji_Rep_Util.Derive_Factorby(p_project_id
      , NULL -- bug 3793041
	  , x_return_status, x_msg_count, x_Msg_Data);

    x_Effort_UOM := Pji_Rep_Util.get_effort_uom(p_project_id);
    x_task_ref_flag := 'TS';
    x_time_slice  := 1376;
    x_page_links_selection := 'PROJ_OVERVIEW';

	l_plan_version_ids := SYSTEM.PA_NUM_TBL_TYPE(
       x_actual_version_id
      , x_cstforecast_version_id
      , x_cstbudget_version_id
      , x_cstbudget2_version_id
      , x_revforecast_version_id
      , x_revbudget_version_id
      , x_revbudget2_version_id
      , x_orig_cstbudget_version_id
      , x_orig_cstbudget2_version_id
      , x_orig_revbudget_version_id
      , x_orig_revbudget2_version_id
      , x_prior_cstforecast_version_id
      , x_prior_revforecast_version_id);

	IF p_prg_rollup = 'Y' THEN
		l_plan_version_ids.extend(2);
		l_plan_version_ids(14) := -3;
		l_plan_version_ids(15) := -4;
	END IF;

    Pji_Rep_Util.Derive_Perf_Period(p_project_id, l_plan_version_ids
        , x_from_period, x_to_period, x_return_status, x_msg_count, x_Msg_Data);

	BEGIN
		x_wbs_version_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_FIN_STRUC_VER_ID(p_project_id);

		SELECT elm.proj_element_id
		INTO x_wbs_element_id
		FROM pa_proj_element_versions elm
		WHERE elm.element_version_id = x_wbs_version_id;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		IF (x_wbs_version_id IS NOT NULL) THEN
			x_msg_count := x_msg_count + 1;
			x_return_status := Pji_Rep_Util.G_RET_STS_WARNING;
			Pji_Rep_Util.Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'TOKEN_NAME',p_token1_value=>'WBS ELEMENT');
		END IF;
	END;

	-- in case there is valid version retrieved and there is no actual.
	IF x_wbs_version_id IS NULL THEN
	   Pji_Rep_Util.Derive_WP_WBS_Parameters(p_project_id
		      , x_WBS_Version_ID, x_WBS_Element_Id
		      , x_return_status, x_msg_count, x_msg_data);
	END IF;

	Pji_Rep_Util.Derive_Project_Type(p_project_id
	, x_project_type
	, x_return_status
	, x_msg_count
	, x_msg_data);

	Pji_Rep_Util.Check_Proj_Type_Consistency(p_project_id
	, x_wbs_version_id
	, 'FINANCIAL'
	, x_ptc_flag
	, x_return_status
	, x_msg_count
	, x_msg_data);

	--Bug 5469672 Derive the default FBS expansion level
	x_fbs_expansion_lvl := pji_rep_util.GET_DEFAULT_EXPANSION_LEVEL(p_project_id, 'FT');

END derive_dflt_params;

END Pji_Rep_Prf_Dflt_Params;

/
