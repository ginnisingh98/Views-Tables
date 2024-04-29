--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_DYNAMIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_DYNAMIC" AUTHID CURRENT_USER AS
/* $Header: hriopdyn.pkh 115.3 2002/12/23 10:17:45 cbridge noship $ */

/* Vacancy Ageing */
FUNCTION vacancy_ageing_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION vacancy_ageing_orgh(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

/* Time to Fill */
FUNCTION vac_time_to_fill_orgh(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION vac_time_to_fill_suph(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION apl_time_to_fill_orgh(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION apl_time_to_fill_suph(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

/* Time to Hire */
FUNCTION apl_time_hire_orgh(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION vac_time_hire_orgh(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION apl_time_hire_suph(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION vac_time_hire_suph(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION time_to_hire_orgh(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION time_to_hire_orgh_1(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION time_to_hire_orgh_2(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION time_to_hire_suph(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

/* Time from Accept to Hire */
FUNCTION apl_accpt_hire_orgh(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION apl_accpt_hire_suph(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION vac_accpt_hire_orgh(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION vac_accpt_hire_suph(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION time_accpt_hire_orgh(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION time_accpt_hire_suph(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

/* Recruitment Efficiency */
FUNCTION time_efficiency_orgh(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION time_efficiency_suph(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

/* Recruitment Success */
FUNCTION rec_success_dyn(p_params_tbl          IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

/* Vacancy Status */
FUNCTION vacancy_system_status_orgh(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION vacancy_system_status_suph(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

/* Applicant Detail */
FUNCTION applicant_detail(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

/* Recuitment Source Effectiveness */
FUNCTION recruitment_source_effective(p_params_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;


/******************************************************************************/
/* Drill to Detail Reports */
/***************************/
FUNCTION apl_detail_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION apl_detail_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION vac_detail_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION vac_detail_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION apl_detail_ttf_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION apl_detail_ttf_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION apl_detail_tth_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION apl_detail_tth_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION apl_detail_tah_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION apl_detail_tah_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

-- vacancy drills.

FUNCTION vac_detail_ttf_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION vac_detail_ttf_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION vac_detail_tth_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION vac_detail_tth_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION vac_detail_tah_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION vac_detail_tah_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION vac_detail_vag_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION vac_detail_vag_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION vac_detail_vst_orgh(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

FUNCTION vac_detail_vst_suph(p_params_tbl       IN BIS_PMV_PAGE_PARAMETER_TBL)
               RETURN VARCHAR2;

END hri_oltp_pmv_dynamic;

 

/
