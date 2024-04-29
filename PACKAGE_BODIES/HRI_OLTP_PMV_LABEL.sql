--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_LABEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_LABEL" AS
/* $Header: hriopdlv.pkb 120.2 2005/09/20 05:41:03 cbridge noship $ */

/* Table of dimension short name lookups */
TYPE g_dim_short_name_tab_type IS TABLE OF VARCHAR2(80) INDEX BY VARCHAR2(30);
g_dim_short_name_tab  g_dim_short_name_tab_type;

g_not_used_msg   VARCHAR2(240);

PROCEDURE initialize_globals IS

BEGIN

  g_dim_short_name_tab('HRI_PERF_BAND') := 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X';
  g_dim_short_name_tab('HRI_LOW_BAND')  := 'HRI_LOW+HRI_LOW_BAND_EMP';
  g_dim_short_name_tab('HRI_LOP_BAND')  := 'HRI_LOW+HRI_LOW_BAND_CWK';
  g_dim_short_name_tab('ABS_DRTN')  := 'HRI_ABSNC_M+HRI_ABSNC_M_DRTN_UOM';
  g_not_used_msg := hri_oltp_view_message.get_not_used_msg;

END initialize_globals;

/* Returns the label for the dimension level value */
FUNCTION get_label(p_dim_lvl_name  VARCHAR2,
                   p_dim_lvl_pk    VARCHAR2,
                   p_name_type     VARCHAR2)
       RETURN VARCHAR2 IS

  l_dimension_name VARCHAR2(100);
  l_return_label   VARCHAR2(240);
  l_dim_lvl_pk     VARCHAR2(100);

BEGIN

  BEGIN
    l_dimension_name := g_dim_short_name_tab(p_dim_lvl_name);
  EXCEPTION WHEN OTHERS THEN
    l_dimension_name := p_dim_lvl_name;
  END;


  l_dim_lvl_pk := p_dim_lvl_pk;

  IF p_dim_lvl_name = 'ABS_DRTN' THEN
       l_dim_lvl_pk := hri_bpl_utilization.get_abs_durtn_profile_vl;
  END IF;

/* Return the value from the base layer function */
  l_return_label:= NVL(hri_bpl_dim_lvl.get_value_label
                         (p_dim_lvl_name => l_dimension_name,
                          p_dim_lvl_pk => l_dim_lvl_pk,
                          p_name_type => p_name_type),
                      g_not_used_msg);

  RETURN l_return_label;

EXCEPTION WHEN OTHERS THEN

/* Exception most likely to be caused by no data found in metadata */
/* Return the metadata table key */
  RETURN p_dim_lvl_name;

END get_label;

/* Initialization */
BEGIN

  initialize_globals;

END hri_oltp_pmv_label;

/
