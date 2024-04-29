--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_QUERY_WCNT_CHG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_QUERY_WCNT_CHG" AUTHID CURRENT_USER AS
/* $Header: hriopqwc.pkh 120.0 2005/05/29 07:34:23 appldev noship $ */

FUNCTION get_sql
 (p_parameter_rec    IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab         IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_wcnt_chg_params  IN hri_bpl_fact_sup_wcnt_chg_sql.wcnt_chg_fact_param_type,
  p_calling_module   IN VARCHAR2)
     RETURN VARCHAR2;

END hri_oltp_pmv_query_wcnt_chg;

 

/
