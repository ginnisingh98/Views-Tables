--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_DYNAMIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_DYNAMIC" AS
/* $Header: hriopdyn.pkb 115.3 2002/12/23 10:18:14 cbridge noship $ */

/******************************************************************************/
/* Vacancy Ageing */
/******************/
FUNCTION vacancy_ageing_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_AGEING_SUPH');

  RETURN l_sql_text;

END vacancy_ageing_suph;

FUNCTION vacancy_ageing_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_AGEING_ORGH');

  RETURN l_sql_text;

END vacancy_ageing_orgh;


/******************************************************************************/
/* Time to Fill */
/****************/
FUNCTION vac_time_to_fill_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_TIME_FILL_ORGH');

  RETURN l_sql_text;

END vac_time_to_fill_orgh;

FUNCTION vac_time_to_fill_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_TIME_FILL_SUPH');

  RETURN l_sql_text;

END vac_time_to_fill_suph;

FUNCTION apl_time_to_fill_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_APL_TIME_FILL_ORGH');

  RETURN l_sql_text;

END apl_time_to_fill_orgh;

FUNCTION apl_time_to_fill_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_APL_TIME_FILL_SUPH');

  RETURN l_sql_text;

END apl_time_to_fill_suph;


/******************************************************************************/
/* Time to Hire */
/****************/
FUNCTION apl_time_hire_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_APL_TIME_HIRE_ORGH');

  RETURN l_sql_text;

END apl_time_hire_orgh;

FUNCTION apl_time_hire_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_APL_TIME_HIRE_SUPH');

  RETURN l_sql_text;

END apl_time_hire_suph;

FUNCTION vac_time_hire_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_TIME_HIRE_ORGH');

  RETURN l_sql_text;

END vac_time_hire_orgh;

FUNCTION vac_time_hire_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_TIME_HIRE_SUPH');

  RETURN l_sql_text;

END vac_time_hire_suph;

FUNCTION time_to_hire_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_TIME_TO_HIRE_ORGH');

  RETURN l_sql_text;

END time_to_hire_orgh;

FUNCTION time_to_hire_orgh_1(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_TIME_TO_HIRE_ORGH_1');

  RETURN l_sql_text;

END time_to_hire_orgh_1;

FUNCTION time_to_hire_orgh_2(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_TIME_TO_HIRE_ORGH_2');

  RETURN l_sql_text;

END time_to_hire_orgh_2;

FUNCTION time_to_hire_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_TIME_TO_HIRE_SUPH');

  RETURN l_sql_text;

END time_to_hire_suph;


/******************************************************************************/
/* Time from Accept to Hire */
/****************************/
FUNCTION apl_accpt_hire_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_APL_ACCPT_HIRE_ORGH');

  RETURN l_sql_text;

END apl_accpt_hire_orgh;

FUNCTION apl_accpt_hire_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_APL_ACCPT_HIRE_SUPH');

  RETURN l_sql_text;

END apl_accpt_hire_suph;

FUNCTION vac_accpt_hire_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_ACCPT_HIRE_ORGH');

  RETURN l_sql_text;

END vac_accpt_hire_orgh;

FUNCTION vac_accpt_hire_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_ACCPT_HIRE_SUPH');

  RETURN l_sql_text;

END vac_accpt_hire_suph;

FUNCTION time_accpt_hire_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_TIME_ACCPT_HIRE_ORGH');

  RETURN l_sql_text;

END time_accpt_hire_orgh;

FUNCTION time_accpt_hire_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_TIME_ACCPT_HIRE_SUPH');

  RETURN l_sql_text;

END time_accpt_hire_suph;


/******************************************************************************/
/* Recruitment Efficiency */
/**************************/
FUNCTION time_efficiency_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_TIME_EFFICIENCY_ORGH');

  RETURN l_sql_text;

END time_efficiency_orgh;

FUNCTION time_efficiency_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_TIME_EFFICIENCY_SUPH');

  RETURN l_sql_text;

END time_efficiency_suph;


/******************************************************************************/
/* Recruitment Success */
/***********************/
FUNCTION rec_success_dyn(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_SUCCESS_DYN');

  RETURN l_sql_text;

END rec_success_dyn;


/******************************************************************************/
/* Vacancy Status */
/******************/
FUNCTION vacancy_system_status_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_SYS_STATUS_ORGH');

  RETURN l_sql_text;

END vacancy_system_status_orgh;

FUNCTION vacancy_system_status_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_SYS_STATUS_SUPH');

  RETURN l_sql_text;

END vacancy_system_status_suph;


/******************************************************************************/
/* Applicant Detail */
/********************/
FUNCTION applicant_detail(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2

 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_no_viewby_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_APPLICANT_DETAIL');

  RETURN l_sql_text;

END applicant_detail;


/******************************************************************************/
/* Recuitment Source Effectiveness */
/****************/
FUNCTION recruitment_source_effective(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_APL_SRC');

  RETURN l_sql_text;

END recruitment_source_effective;


/******************************************************************************/
/* Drill to Detail Reports */
/***************************/
FUNCTION apl_detail_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_APL_DETAIL_ORGH');

  RETURN l_sql_text;

END apl_detail_orgh;

FUNCTION apl_detail_ttf_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_APL_DET_TTF_ORGH');

  RETURN l_sql_text;

END apl_detail_ttf_orgh;


FUNCTION apl_detail_ttf_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_APL_DET_TTF_SUPH');

  RETURN l_sql_text;

END apl_detail_ttf_suph;


FUNCTION apl_detail_tth_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_APL_DET_TTH_ORGH');

  RETURN l_sql_text;

END apl_detail_tth_orgh;


FUNCTION apl_detail_tth_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_APL_DET_TTH_SUPH');

  RETURN l_sql_text;

END apl_detail_tth_suph;


FUNCTION apl_detail_tah_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_APL_DET_TAH_ORGH');

  RETURN l_sql_text;

END apl_detail_tah_orgh;


FUNCTION apl_detail_tah_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_APL_DET_TAH_SUPH');

  RETURN l_sql_text;

END apl_detail_tah_suph;

-- vacancy drills

FUNCTION vac_detail_ttf_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_DET_TTF_ORGH');

  RETURN l_sql_text;

END vac_detail_ttf_orgh;


FUNCTION vac_detail_ttf_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_DET_TTF_SUPH');

  RETURN l_sql_text;

END vac_detail_ttf_suph;


FUNCTION vac_detail_tth_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_DET_TTH_ORGH');

  RETURN l_sql_text;

END vac_detail_tth_orgh;


FUNCTION vac_detail_tth_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_DET_TTH_SUPH');

  RETURN l_sql_text;

END vac_detail_tth_suph;


FUNCTION vac_detail_tah_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_DET_TAH_ORGH');

  RETURN l_sql_text;

END vac_detail_tah_orgh;


FUNCTION vac_detail_tah_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_DET_TAH_SUPH');

  RETURN l_sql_text;

END vac_detail_tah_suph;


FUNCTION apl_detail_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_APL_DETAIL_SUPH');

  RETURN l_sql_text;

END apl_detail_suph;

FUNCTION vac_detail_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_DETAIL_ORGH');

  RETURN l_sql_text;

END vac_detail_orgh;

FUNCTION vac_detail_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_DETAIL_SUPH');

  RETURN l_sql_text;

END vac_detail_suph;

FUNCTION vac_detail_vag_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_DET_VAG_ORGH');

  RETURN l_sql_text;

END vac_detail_vag_orgh;

FUNCTION vac_detail_vag_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_DET_VAG_SUPH');

  RETURN l_sql_text;

END vac_detail_vag_suph;

FUNCTION vac_detail_vst_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_DET_VST_ORGH');

  RETURN l_sql_text;

END vac_detail_vst_orgh;

FUNCTION vac_detail_vst_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2 IS

  l_sql_text    VARCHAR2(4000);

BEGIN

  l_sql_text := hri_oltp_pmv_dynsqlgen.get_drill_into_query
                  (p_params_tbl => p_params_tbl,
                   p_ak_region_code => 'HRI_P_REC_VAC_DET_VST_SUPH');

  RETURN l_sql_text;

END vac_detail_vst_suph;


END hri_oltp_pmv_dynamic;

/
