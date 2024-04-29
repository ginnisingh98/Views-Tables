--------------------------------------------------------
--  DDL for Package Body PA_FP_WP_GEN_AMT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_WP_GEN_AMT_UTILS" AS
/* $Header: PAFPWPUB.pls 120.0 2005/05/29 21:52:29 appldev noship $ */

    function get_wp_ptype_id(p_project_id in number)
    return number is
      l_pt_id number := null;
    begin
       select opt.fin_plan_type_id  into l_pt_id
       from pa_proj_fp_options opt,
            pa_fin_plan_types_b pt
       where
       opt.FIN_PLAN_OPTION_LEVEL_CODE = 'PLAN_TYPE' and
       opt.FIN_PLAN_TYPE_ID = pt.FIN_PLAN_TYPE_ID and
       nvl(pt.USE_FOR_WORKPLAN_FLAG,'N') = 'Y' and
       opt.project_id = p_project_id;

       return l_pt_id;
    exception
    when others then
         return l_pt_id;
    end get_wp_ptype_id;

    /* p_plan_type_id is not used in this function.
       Any dummy value can be passed from the calling API. */

    function get_wp_version_id(p_project_id in number,
                               p_plan_type_id in number,
			       p_proj_str_ver_id in number)
	return number is
    l_ver_id number:=null;
    begin
       select budget_version_id into l_ver_id
       from pa_budget_versions where
       project_id = p_project_id  and
	   project_structure_version_id = p_proj_str_ver_id and
           nvl(wp_version_flag,'N') = 'Y';
         return l_ver_id;
    exception
    when no_data_found then
         return l_ver_id;
    end get_wp_version_id;

/**Returns 'Y' if tracking workplan cost amts is enabled.
  *Returns 'N' if tracking workplan cost amts is disabled.
  *Returns Null if no workplan usage is enabled. **/
FUNCTION get_wp_track_cost_amt_flag (p_project_id IN NUMBER)
RETURN VARCHAR2
IS
    l_flag VARCHAR2(5) := NULL;
BEGIN
    SELECT NVL(TRACK_WORKPLAN_COSTS_FLAG,'N') INTO l_flag
    FROM pa_proj_fp_options opt, pa_fin_plan_types_b pt
    WHERE opt.project_id = P_PROJECT_ID
	  AND opt.FIN_PLAN_OPTION_LEVEL_CODE = 'PLAN_TYPE'
	  AND pt.fin_plan_type_id = opt.fin_plan_type_id
  	  AND NVL(pt.USE_FOR_WORKPLAN_FLAG,'N') = 'Y';
    RETURN l_flag;

EXCEPTION
    WHEN OTHERS THEN
	RETURN l_flag;
END get_wp_track_cost_amt_flag;

FUNCTION get_wp_pt_time_phase_code(p_project_id IN NUMBER)
    RETURN VARCHAR2  IS
     l_time_phase_code pa_proj_fp_options.cost_time_phased_code%type;
BEGIN
    SELECT opt.cost_time_phased_code INTO l_time_phase_code
    FROM pa_proj_fp_options opt, pa_fin_plan_types_b pt
    WHERE opt.project_id = P_PROJECT_ID
          AND opt.FIN_PLAN_OPTION_LEVEL_CODE = 'PLAN_TYPE'
          AND pt.fin_plan_type_id = opt.fin_plan_type_id
          AND NVL(pt.USE_FOR_WORKPLAN_FLAG,'N') = 'Y';
    RETURN l_time_phase_code;

EXCEPTION
    WHEN OTHERS THEN
        RETURN l_time_phase_code;
END get_wp_pt_time_phase_code;

END Pa_Fp_wp_gen_amt_utils;

/
