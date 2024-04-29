--------------------------------------------------------
--  DDL for Package PJI_REP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_REP_UTIL" AUTHID CURRENT_USER AS
/* $Header: PJIRX07S.pls 120.17.12010000.3 2009/05/21 18:51:04 rbruno ship $ */
G_RET_STS_WARNING		VARCHAR2(1):='W';
G_RET_STS_ERROR		VARCHAR2(1):='E';

PROCEDURE Add_Message (p_app_short_name VARCHAR2
                , p_msg_name VARCHAR2
                , p_msg_type VARCHAR2
				, p_token1 VARCHAR2 DEFAULT NULL
				, p_token1_value VARCHAR2 DEFAULT NULL
				, p_token2 VARCHAR2 DEFAULT NULL
				, p_token2_value VARCHAR2 DEFAULT NULL
				, p_token3 VARCHAR2 DEFAULT NULL
				, p_token3_value VARCHAR2 DEFAULT NULL
				, p_token4 VARCHAR2 DEFAULT NULL
				, p_token4_value VARCHAR2 DEFAULT NULL
				, p_token5 VARCHAR2 DEFAULT NULL
				, p_token5_value VARCHAR2 DEFAULT NULL
				);

PROCEDURE Log_Struct_Change_Event(p_wbs_version_id_tbl SYSTEM.PA_NUM_TBL_TYPE);

PROCEDURE Populate_WBS_Hierarchy_Cache(p_project_id NUMBER
, p_element_version_id NUMBER
, p_prg_flag VARCHAR2 DEFAULT 'N'
, p_page_type VARCHAR2 DEFAULT 'WORKPLAN'
, p_report_date_julian NUMBER DEFAULT NULL
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Populate_WP_Plan_Vers_Cache(p_project_id NUMBER
, p_prg_flag VARCHAR2 DEFAULT 'N'
, p_current_version_id NUMBER DEFAULT NULL
, p_latest_version_id NUMBER DEFAULT NULL
, p_baselined_version_id NUMBER DEFAULT NULL
, p_plan1_version_id NUMBER DEFAULT NULL
, p_plan2_version_id NUMBER DEFAULT NULL
, p_curr_wbs_vers_id NUMBER DEFAULT NULL
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

FUNCTION Derive_Prg_Rollup_Flag(
p_project_id NUMBER) RETURN VARCHAR2 ;

FUNCTION Derive_Perf_Prg_Rollup_Flag(
p_project_id NUMBER) RETURN VARCHAR2 ;

FUNCTION get_default_period_name (
p_project_id NUMBER) return VARCHAR2;

FUNCTION get_default_calendar_type
return VARCHAR2;

function Get_Task_Baseline_Cost (
p_project_id NUMBER, p_task_id NUMBER) return NUMBER;

function Get_Task_Latest_Published_Cost(
p_project_id NUMBER, p_task_id NUMBER) return NUMBER;

PROCEDURE Derive_Default_Calendar_Info(
p_project_id NUMBER
, x_calendar_type OUT NOCOPY VARCHAR2
, x_calendar_id  OUT NOCOPY NUMBER
, x_period_name  OUT NOCOPY VARCHAR2
, x_report_date_julian  OUT NOCOPY NUMBER
, x_slice_name OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

FUNCTION Get_Version_Type(
p_project_id NUMBER
, p_fin_plan_type_id NUMBER
, p_version_type VARCHAR2
) RETURN VARCHAR2 ;

PROCEDURE Derive_Default_Plan_Versions(
p_project_id NUMBER
, x_actual_version_id OUT NOCOPY NUMBER
, x_cstforecast_version_id OUT NOCOPY NUMBER
, x_cstbudget_version_id OUT NOCOPY NUMBER
, x_cstbudget2_version_id OUT NOCOPY NUMBER
, x_revforecast_version_id OUT NOCOPY NUMBER
, x_revbudget_version_id OUT NOCOPY NUMBER
, x_revbudget2_version_id OUT NOCOPY NUMBER
, x_orig_cstforecast_version_id OUT NOCOPY NUMBER
, x_orig_cstbudget_version_id OUT NOCOPY NUMBER
, x_orig_cstbudget2_version_id OUT NOCOPY NUMBER
, x_orig_revforecast_version_id OUT NOCOPY NUMBER
, x_orig_revbudget_version_id OUT NOCOPY NUMBER
, x_orig_revbudget2_version_id OUT NOCOPY NUMBER
, x_prior_cstfcst_version_id OUT NOCOPY NUMBER
, x_prior_revfcst_version_id OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Derive_Default_Currency_Info(
p_project_id NUMBER
, x_currency_record_type OUT NOCOPY NUMBER
, x_currency_code OUT NOCOPY VARCHAR2
, x_currency_type OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Derive_Perf_Currency_Info(
p_project_id NUMBER
, x_currency_record_type OUT NOCOPY NUMBER
, x_currency_code OUT NOCOPY VARCHAR2
, x_currency_type OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

FUNCTION Derive_FactorBy(
p_project_id NUMBER
, p_fin_plan_version_id NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2) RETURN VARCHAR2 ;

PROCEDURE Derive_Project_Attributes(
p_project_id NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Derive_Default_RBS_Parameters(
p_project_id NUMBER
,p_plan_version_id NUMBER
, x_rbs_version_id OUT NOCOPY NUMBER
, x_rbs_element_id OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Derive_Perf_RBS_Parameters(
p_project_id NUMBER
,p_plan_version_id NUMBER
,p_prg_flag VARCHAR DEFAULT 'N'
, x_rbs_version_id OUT NOCOPY NUMBER
, x_rbs_element_id OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Derive_Default_WBS_Parameters(
p_project_id NUMBER
,p_plan_version_id NUMBER
, x_wbs_version_id OUT NOCOPY NUMBER
, x_wbs_element_id OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Derive_WP_WBS_Parameters(
p_project_id NUMBER
, x_wbs_version_id OUT NOCOPY NUMBER
, x_wbs_element_id OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Derive_Slice_Name(
p_project_id NUMBER
, p_calendar_id NUMBER
, x_slice_name OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

FUNCTION Get_Slice_Name(
p_project_id NUMBER
,p_calendar_id NUMBER) RETURN VARCHAR2;

PROCEDURE Derive_Plan_Type_Parameters(
p_project_id NUMBER
, p_fin_plan_type_id NUMBER
, x_plan_pref_code OUT NOCOPY VARCHAR2
, x_budget_forecast_flag OUT NOCOPY VARCHAR2
, x_plan_type_name OUT NOCOPY VARCHAR2
, x_plan_report_mask OUT NOCOPY VARCHAR2
, x_plan_margin_mask OUT NOCOPY VARCHAR2
, x_cost_app_flag IN OUT NOCOPY VARCHAR2
, x_rev_app_flag IN OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Derive_Version_Parameters(
p_version_id NUMBER
, x_version_name OUT NOCOPY VARCHAR2
, x_version_no OUT NOCOPY VARCHAR2
, x_version_record_no OUT NOCOPY VARCHAR2
, x_budget_status_code OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Derive_Fin_Plan_Versions(p_project_id NUMBER
,p_version_id NUMBER
, x_curr_budget_version_id OUT NOCOPY NUMBER
, x_orig_budget_version_id OUT NOCOPY NUMBER
, x_prior_fcst_version_id OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2
);

PROCEDURE Derive_Work_Plan_Versions(p_project_id NUMBER
,p_structure_version_id NUMBER
, x_current_version_id OUT NOCOPY NUMBER
, x_baselined_version_id OUT NOCOPY NUMBER
, x_published_version_id OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2
);

/*
FUNCTION get_report_date_julian(p_calendar_type VARCHAR2
, p_calendar_id NUMBER
, p_org_id NUMBER) RETURN NUMBER;

FUNCTION get_period_name(p_calendar_type VARCHAR2
, p_calendar_id NUMBER
, p_org_id NUMBER) RETURN VARCHAR2;
*/

PROCEDURE Derive_Pa_Calendar_Info(p_project_id NUMBER
, p_calendar_type VARCHAR2
, x_calendar_id OUT NOCOPY NUMBER
, x_report_date_julian OUT NOCOPY NUMBER
, x_period_name OUT NOCOPY VARCHAR2
, x_slice_name OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2
);

PROCEDURE Derive_Project_Type(p_project_id NUMBER
, x_project_type OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2
);

--7602538
PROCEDURE drv_prf_prd(
p_from_date IN VARCHAR2,
p_to_date IN VARCHAR2,
x_from_period OUT NOCOPY NUMBER,
x_to_period OUT NOCOPY NUMBER);

FUNCTION get_work_plan_actual_version(p_project_id NUMBER
) RETURN NUMBER;

FUNCTION get_fin_plan_actual_version(p_project_id NUMBER
) RETURN NUMBER;

FUNCTION get_effort_uom(p_project_id NUMBER
) RETURN NUMBER;


-- -----------------------------------------------------------------

-- -----------------------------------------------------------------
-- Setup Current Reporting Periods
-- -----------------------------------------------------------------

PROCEDURE update_curr_rep_periods(
	p_pa_curr_rep_period 	VARCHAR2,
	p_gl_curr_rep_period 	VARCHAR2,
	p_ent_curr_rep_period	VARCHAR2
);


-- -----------------------------------------------------------------

PROCEDURE get_project_home_default_param
                                  ( p_project_id        IN      NUMBER,
                                    p_page_Type         IN      VARCHAR2,
                                    x_fin_plan_type_id  IN OUT NOCOPY   NUMBER,
                                    x_cost_version_id   IN OUT NOCOPY   NUMBER,
                                    x_rev_version_id    IN OUT NOCOPY   NUMBER,
                                    x_struct_version_id IN OUT NOCOPY   NUMBER,
                                    x_return_status     IN OUT NOCOPY   VARCHAR2,
                                    x_msg_count         IN OUT NOCOPY   NUMBER,
                                    x_msg_data          IN OUT NOCOPY   VARCHAR2);

PROCEDURE Derive_Default_RBS_Element_Id(
p_rbs_version_id NUMBER
, x_rbs_element_id OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);


PROCEDURE Derive_VP_Calendar_Info(
p_project_id NUMBER
, p_cst_version_id NUMBER
, p_rev_version_id NUMBER
, p_context_version_type VARCHAR2
, x_calendar_id  OUT NOCOPY NUMBER
, x_calendar_type OUT NOCOPY VARCHAR2
, x_time_phase_valid_flag OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Derive_WP_Calendar_Info(
p_project_id NUMBER
, p_plan_version_id NUMBER
, x_calendar_id  OUT NOCOPY NUMBER
, x_calendar_type OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Derive_WP_Period(
p_project_id NUMBER
, p_published_version_id NUMBER
, p_working_version_id NUMBER
, x_from_period OUT NOCOPY  NUMBER
, x_to_period OUT NOCOPY  NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Derive_VP_Period(
p_project_id NUMBER
, p_plan_version_id_tbl  SYSTEM.pa_num_tbl_type
, x_from_period OUT NOCOPY  NUMBER
, x_to_period OUT NOCOPY  NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Derive_Perf_Period(
p_project_id NUMBER
, p_plan_version_id_tbl  SYSTEM.pa_num_tbl_type
, x_from_period OUT NOCOPY  NUMBER
, x_to_period OUT NOCOPY  NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

/*
 * Added this procedure for bug 3842347. This procedure will give max and min date for a given plan version
 * id and proejct_id. It is being used in get default api
 */
PROCEDURE Get_Default_Period_Dates (
    p_plan_version_ids   IN  SYSTEM.pa_num_tbl_type         := SYSTEM.pa_num_tbl_type()
  , p_project_id         IN  NUMBER
  , x_min_julian_date    OUT NOCOPY  NUMBER
  , x_max_julian_date    OUT NOCOPY  NUMBER);


PROCEDURE Derive_Version_Margin_Mask(
p_project_id NUMBER
, p_plan_version_id NUMBER
, x_plan_margin_mask OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);


PROCEDURE Derive_Percent_Complete
( p_project_id NUMBER
, p_wbs_version_id NUMBER
, p_wbs_element_id NUMBER
, p_rollup_flag VARCHAR2
, p_report_date_julian NUMBER
, p_structure_type VARCHAR2
, p_calendar_type VARCHAR2 DEFAULT 'E'
, p_calendar_id NUMBER DEFAULT -1
, p_prg_flag VARCHAR2
, x_percent_complete  OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2
)
;

PROCEDURE Check_Cross_Org
( p_project_id NUMBER
, x_cross_org_flag OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2
);

/*
	This is a wrapper API which does the consistency check
	for program in workplan context.
*/
PROCEDURE CHECK_WP_PARAM_CONSISTENCY
  ( p_project_id		IN	pa_projects_all.project_id%TYPE
   ,p_wbs_version_id	IN  pji_xbs_denorm.sup_project_id%TYPE
   ,p_margin_code		IN  pa_proj_fp_options.margin_derived_from_code%TYPE
   ,p_published_flag	IN  VARCHAR2
   ,p_calendar_type		IN  pji_fp_xbs_accum_f.calendar_type%TYPE
   ,p_calendar_id		IN  pa_projects_all.calendar_id%TYPE
   ,p_rbs_version_id	IN  pa_proj_fp_options.rbs_version_id%TYPE
   ,x_pc_flag			OUT NOCOPY VARCHAR2
   ,x_pfc_flag			OUT NOCOPY VARCHAR2
   ,x_margin_flag		OUT NOCOPY VARCHAR2
   ,x_workpub_flag		OUT NOCOPY VARCHAR2
   ,x_time_phase_flag	OUT NOCOPY VARCHAR2
   ,x_rbs_flag			OUT NOCOPY VARCHAR2
   ,x_return_status		OUT NOCOPY VARCHAR2
   ,x_msg_count			OUT NOCOPY NUMBER
   ,x_msg_data			OUT NOCOPY VARCHAR2);

/*
	check if all the projects in the program hierarchy contain
	the same project and project functional currency.
*/
PROCEDURE CHECK_WP_CURRENCY_CONSISTENCY
  ( p_project_id		IN	pa_projects_all.project_id%TYPE
   ,p_wbs_version_id	IN  pji_xbs_denorm.sup_project_id%TYPE
   ,x_pc_flag			OUT NOCOPY VARCHAR2
   ,x_pfc_flag			OUT NOCOPY VARCHAR2
   ,x_return_status		OUT NOCOPY VARCHAR2
   ,x_msg_count			OUT NOCOPY NUMBER
   ,x_msg_data			OUT NOCOPY VARCHAR2);

/*
	check if all the linked structure versions in the
	program hierarchy have the same margin mask.
*/
   PROCEDURE CHECK_WP_MARGIN_CONSISTENCY
  ( p_project_id		IN	pa_projects_all.project_id%TYPE
   ,p_wbs_version_id	IN  pji_xbs_denorm.sup_project_id%TYPE
   ,p_margin_code		IN  pa_proj_fp_options.margin_derived_from_code%TYPE
   ,x_margin_flag		OUT NOCOPY VARCHAR2
   ,x_return_status		OUT NOCOPY VARCHAR2
   ,x_msg_count			OUT NOCOPY NUMBER
   ,x_msg_data			OUT NOCOPY VARCHAR2);

/*
	check if all the structure versions in the program hierarchy
	have the same status. ie published/not published.
*/
   PROCEDURE CHECK_WP_STATUS_CONSISTENCY
  ( p_project_id		IN	pa_projects_all.project_id%TYPE
   ,p_wbs_version_id	IN  pji_xbs_denorm.sup_project_id%TYPE
   ,p_published_flag	IN  VARCHAR2
   ,x_workpub_flag		OUT NOCOPY VARCHAR2
   ,x_return_status		OUT NOCOPY VARCHAR2
   ,x_msg_count			OUT NOCOPY NUMBER
   ,x_msg_data			OUT NOCOPY VARCHAR2);

/*
	check if all the structure versions in the program hierarchy have
	same time phasing.
*/
   PROCEDURE CHECK_WP_TIME_CONSISTENCY
  ( p_project_id		IN	pa_projects_all.project_id%TYPE
   ,p_wbs_version_id	IN  pji_xbs_denorm.sup_project_id%TYPE
   ,p_calendar_type		IN  pji_fp_xbs_accum_f.calendar_type%TYPE
   ,p_calendar_id		IN  pa_projects_all.calendar_id%TYPE
   ,x_time_phase_flag	OUT NOCOPY VARCHAR2
   ,x_return_status		OUT NOCOPY VARCHAR2
   ,x_msg_count			OUT NOCOPY NUMBER
   ,x_msg_data			OUT NOCOPY VARCHAR2);

/*
	check if all the structure versions  in the program hierarchy have
	the same RBS.
*/
   PROCEDURE CHECK_WP_RBS_CONSISTENCY
  ( p_project_id		IN	pa_projects_all.project_id%TYPE
   ,p_wbs_version_id	IN  pji_xbs_denorm.sup_project_id%TYPE
   ,p_rbs_version_id	IN  pa_proj_fp_options.rbs_version_id%TYPE
   ,x_rbs_flag			OUT NOCOPY VARCHAR2
   ,x_return_status		OUT NOCOPY VARCHAR2
   ,x_msg_count			OUT NOCOPY NUMBER
   ,x_msg_data			OUT NOCOPY VARCHAR2);

	FUNCTION GET_WP_BASELINED_PLAN_VERSION
	( p_project_id IN pa_projects_all.project_id%TYPE)
	RETURN NUMBER;

	FUNCTION GET_WP_LATEST_VERSION
       ( p_project_id IN pa_projects_all.project_id%TYPE)
	RETURN NUMBER;

	FUNCTION GET_DEFAULT_EXPANSION_LEVEL
	( p_project_id IN pa_projects_all.project_id%TYPE
	 ,p_object_type  IN VARCHAR2)   -- Task/Resource indicated by 'T' or 'R'
	RETURN NUMBER;

/* Gets all the default plan type ids for a give project */
PROCEDURE Derive_Default_Plan_Type_Ids(
  p_project_id NUMBER
, x_cost_fcst_plan_type_id      OUT NOCOPY NUMBER
, x_cost_bgt_plan_type_id       OUT NOCOPY NUMBER
, x_cost_bgt2_plan_type_id      OUT NOCOPY NUMBER
, x_rev_fcst_plan_type_id       OUT NOCOPY NUMBER
, x_rev_bgt_plan_type_id        OUT NOCOPY NUMBER
, x_rev_bgt2_plan_type_id       OUT NOCOPY NUMBER
, x_return_status               IN OUT NOCOPY VARCHAR2
, x_msg_count                   IN OUT NOCOPY NUMBER
, x_msg_data                    IN OUT NOCOPY VARCHAR2);


/*
** Get all plan versions for a given project and plan type id
*/
PROCEDURE Derive_Plan_Version_Ids(
                 p_project_id                      IN NUMBER
               , p_cost_fcst_plan_type_id          IN NUMBER
               , p_cost_bgt_plan_type_id           IN NUMBER
               , p_cost_bgt2_plan_type_id          IN NUMBER
               , p_rev_fcst_plan_type_id           IN NUMBER
               , p_rev_bgt_plan_type_id            IN NUMBER
               , p_rev_bgt2_plan_type_id           IN NUMBER
               , x_cstforecast_version_id          OUT NOCOPY NUMBER
               , x_cstbudget_version_id            OUT NOCOPY NUMBER
               , x_cstbudget2_version_id           OUT NOCOPY NUMBER
               , x_revforecast_version_id          OUT NOCOPY NUMBER
               , x_revbudget_version_id            OUT NOCOPY NUMBER
               , x_revbudget2_version_id           OUT NOCOPY NUMBER
               , x_orig_cstbudget_version_id       OUT NOCOPY NUMBER
               , x_orig_cstbudget2_version_id      OUT NOCOPY NUMBER
               , x_orig_revbudget_version_id       OUT NOCOPY NUMBER
               , x_orig_revbudget2_version_id      OUT NOCOPY NUMBER
               , x_prior_cstfcst_version_id        OUT NOCOPY NUMBER
               , x_prior_revfcst_version_id        OUT NOCOPY NUMBER
               , x_return_status                   IN OUT NOCOPY VARCHAR2
               , x_msg_count                       IN OUT NOCOPY NUMBER
               , x_msg_data                        IN OUT NOCOPY VARCHAR2);


/*
 * This api checks for each project in this passed program whether they
 * have the same GL or same PA calendar or not. If GL calendar is same then x_gl_flag
 * will return 'T' else 'F'. This logic is true for PA calendar also.
 */
PROCEDURE Check_Perf_Cal_Consistency(
                        p_project_id        IN  pa_projects_all.project_id%TYPE
                       ,p_wbs_version_id    IN  pji_xbs_denorm.sup_project_id%TYPE
                       ,x_gl_flag           OUT NOCOPY VARCHAR2
                       ,x_pa_flag           OUT NOCOPY VARCHAR2
                       ,x_return_status     OUT NOCOPY VARCHAR2
                       ,x_msg_count         OUT NOCOPY NUMBER
                       ,x_msg_data          OUT NOCOPY VARCHAR2);

/*
 * This api checks for each project in this passed program whether they
 * have the same Project Functional Currency (PFC) or not. If PFC is same then x_pfc_flag
 * will return 'T' else 'F'.
 */
PROCEDURE Check_Perf_Curr_Consistency(
                        p_project_id        IN  pa_projects_all.project_id%TYPE
                       ,p_wbs_version_id    IN  pji_xbs_denorm.sup_project_id%TYPE
                       ,x_pfc_flag          OUT NOCOPY VARCHAR2
                       ,x_return_status     OUT NOCOPY VARCHAR2
                       ,x_msg_count         OUT NOCOPY NUMBER
                       ,x_msg_data          OUT NOCOPY VARCHAR2);

/* Adding this procedure to do addition calculation with Null rules
 * for bug 4194804. Please do not add out parameters because this
 * function is also used as select function in VO.xml also
 */
FUNCTION Measures_Total(
                     p_measure1        IN         NUMBER
                   , p_measure2        IN         NUMBER   DEFAULT NULL
                   , p_measure3        IN         NUMBER   DEFAULT NULL
                   , p_measure4        IN         NUMBER   DEFAULT NULL
                   , p_measure5        IN         NUMBER   DEFAULT NULL
                   , p_measure6        IN         NUMBER   DEFAULT NULL
                   , p_measure7        IN         NUMBER   DEFAULT NULL
                  ) RETURN NUMBER;

/* Checks if the smart slice api has been called or not.
   If it is called then no need to call processing page,
   but if it is not called then call the api and launch
   the processing page. But if the processing is Deferred
   then launch concurrent program   */
PROCEDURE Is_Smart_Slice_Created(
                  p_rbs_version_id      IN  NUMBER,
                  p_plan_version_id_tbl IN  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
                  p_wbs_element_id      IN  NUMBER,
                  p_rbs_element_id      IN  NUMBER,
                  p_prg_rollup_flag     IN  VARCHAR2,
                  p_curr_record_type_id IN  NUMBER,
                  p_calendar_type       IN  VARCHAR2,
                  p_wbs_version_id      IN  NUMBER,
                  p_commit              IN  VARCHAR2 := 'Y',
                  p_project_id          IN  NUMBER, -- Added for bug 4419342
                  x_Smart_Slice_Flag    OUT NOCOPY  VARCHAR2,
                  x_msg_count           OUT NOCOPY  NUMBER,
                  x_msg_data            OUT NOCOPY  VARCHAR2,
                  x_return_status       OUT NOCOPY  VARCHAR2);
/*
   This procedure checks if the passed plan versions
   are having same RBS or not. It returns two valid
   values:
   'Y':- The passed Plan versions having same RBS
   'N':- The passed Plan version do not have same RBS
   Assumptions:
       + RBS is attached with context plan version
       + Additional Plan versions are selected
 */
PROCEDURE Chk_plan_vers_have_same_RBS(
                  p_fin_plan_version_id_tbl        IN  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(),
                  x_R_PlanVers_HavSame_RBS_Flag    OUT NOCOPY  VARCHAR2,
                  x_msg_count                      OUT NOCOPY  NUMBER,
                  x_msg_data                       OUT NOCOPY  VARCHAR2,
                  x_return_status                  OUT NOCOPY  VARCHAR2);


PROCEDURE GET_PROCESS_STATUS_MSG(
      p_project_id            IN  pa_projects_all.project_id%TYPE
    , p_structure_type        IN  pa_structure_types.structure_type%TYPE := NULL
    , p_structure_version_id  IN  pa_proj_element_versions.element_version_id%TYPE := NULL
    , p_prg_flag              IN  VARCHAR2 := NULL
    , x_message_name          OUT NOCOPY VARCHAR2
    , x_message_type          OUT NOCOPY VARCHAR2
	, x_structure_version_id  OUT NOCOPY NUMBER
	, x_conc_request_id       OUT NOCOPY NUMBER
	, x_return_status 		  IN OUT NOCOPY VARCHAR2
	, x_msg_count 			  IN OUT NOCOPY NUMBER
	, x_msg_data 			  IN OUT NOCOPY VARCHAR2);


PROCEDURE CHECK_PROJ_TYPE_CONSISTENCY
  ( p_project_id		IN	NUMBER
   ,p_wbs_version_id	IN  NUMBER
   ,p_structure_type	IN VARCHAR2 DEFAULT 'FINANCIAL'
   ,x_ptc_flag			OUT NOCOPY VARCHAR2 -- project type consistency flag
   ,x_return_status		OUT NOCOPY VARCHAR2
   ,x_msg_count			OUT NOCOPY NUMBER
   ,x_msg_data			OUT NOCOPY VARCHAR2);

PROCEDURE Derive_Pji_Calendar_Info(
p_project_id IN	NUMBER
, p_period_type IN VARCHAR2
, p_as_of_date IN NUMBER
, x_calendar_type IN OUT NOCOPY VARCHAR2
, x_calendar_id  OUT NOCOPY NUMBER
, x_period_name  OUT NOCOPY VARCHAR2
, x_report_date_julian  OUT NOCOPY NUMBER
, x_slice_name OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Derive_Pji_Currency_Info(
p_project_id NUMBER
, p_currency_record_type IN VARCHAR2
, x_currency_record_type OUT NOCOPY NUMBER
, x_currency_code OUT NOCOPY VARCHAR2
, x_currency_type OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

PROCEDURE Validate_Plan_Type(p_project_id NUMBER
, p_plan_type_id NUMBER
, x_plan_type_id IN OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2);

FUNCTION is_str_linked_to_working_ver
(p_project_id NUMBER
 , p_structure_version_id NUMBER
 , p_relationship_type VARCHAR2 := 'LW') return VARCHAR2;

FUNCTION Get_Page_Pers_Function_Name
(p_project_type             VARCHAR2
,p_page_type            VARCHAR2) return VARCHAR2;

END Pji_Rep_Util;

/
