--------------------------------------------------------
--  DDL for Package Body HRI_MTDT_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_MTDT_PARAM" AS
/* $Header: hrimpar.pkb 120.2 2005/12/20 06:09:53 jtitmas noship $ */

g_rtn   VARCHAR2(30) := '
';

/* Called during package initialization */
PROCEDURE set_pmv_metadata IS

  l_bind  VARCHAR2(80);

BEGIN

/* Time Dimension */
/******************/
  l_bind := 'TIME_CURR_START_DATE';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&BIS_CURRENT_EFFECTIVE_START_DATE';

  l_bind := 'TIME_CURR_END_DATE';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&BIS_CURRENT_EFFECTIVE_END_DATE';

  l_bind := 'TIME_CURR_ASOF_DATE';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&BIS_CURRENT_ASOF_DATE';

  l_bind := 'TIME_COMP_START_DATE';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&BIS_PREVIOUS_EFFECTIVE_START_DATE';

  l_bind := 'TIME_COMP_END_DATE';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&BIS_PREVIOUS_EFFECTIVE_END_DATE';

  l_bind := 'TIME_COMP_ASOF_DATE';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&BIS_PREVIOUS_ASOF_DATE';

  l_bind := 'TIME_COMPARISON_TYPE';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&TIME_COMPARISON_TYPE';

  l_bind := 'PERIOD_TYPE';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&PERIOD_TYPE';

/* Other Common Dimensions */
/***************************/
  l_bind := 'HRI_PERSON+HRI_PER_USRDR_H';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&HRI_PERSON+HRI_PER_USRDR_H';

  l_bind := 'GEOGRAPHY+AREA';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&GEOGRAPHY+AREA';

  l_bind := 'GEOGRAPHY+COUNTRY';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&GEOGRAPHY+COUNTRY';

  l_bind := 'CURRENCY';
  g_param_mtdt_tab(l_bind).pmv_bind_string := ':GLOBAL_CURRENCY';

  l_bind := 'RATE_TYPE';
  g_param_mtdt_tab(l_bind).pmv_bind_string := ':GLOBAL_RATE';

/* Other HR Dimensions */
/***********************/
  l_bind := 'JOB+JOB_FAMILY';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&JOB+JOB_FAMILY';

  l_bind := 'JOB+JOB_FUNCTION';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&JOB+JOB_FUNCTION';

  l_bind := 'HRI_LOW+HRI_LOW_BAND_X';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&HRI_LOW+HRI_LOW_BAND_X';

  l_bind := 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&HRI_PRFRMNC+HRI_PRFMNC_RTNG_X';

  l_bind := 'HRI_WRKACTVT+HRI_WAC_SEPCAT_X';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&HRI_WRKACTVT+HRI_WAC_SEPCAT_X';

  l_bind := 'HRI_REASON+HRI_RSN_SEP_X';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&HRI_REASON+HRI_RSN_SEP_X';

/* Absence Dimensions */
/**********************/
  l_bind := 'HRI_ABSNC_M+HRI_ABSNC_M_DRTN_UOM';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&HRI_ABSNC_M+HRI_ABSNC_M_DRTN_UOM';

  l_bind := 'HRI_ABSNC+HRI_ABSNC_CAT';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&HRI_ABSNC+HRI_ABSNC_CAT';

  l_bind := 'HRI_ABSNC+HRI_ABSNC_TYP';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&HRI_ABSNC+HRI_ABSNC_TYP';

  l_bind := 'HRI_ABSNC+HRI_ABSNC_RSN';
  g_param_mtdt_tab(l_bind).pmv_bind_string := '&HRI_ABSNC+HRI_ABSNC_RSN';

END set_pmv_metadata;

/* Initialization - set metadata for parameters */
BEGIN

  set_pmv_metadata;

END hri_mtdt_param;

/
