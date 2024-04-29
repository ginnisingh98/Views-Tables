--------------------------------------------------------
--  DDL for Package HRI_BPL_TREND_TRM_SQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_TREND_TRM_SQL" AUTHID CURRENT_USER AS
/* $Header: hribttrm.pkh 120.0 2005/05/29 07:05:15 appldev noship $ */

PROCEDURE get_sql
 (p_parameter_rec     IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab          IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_trend_sql_params  IN hri_oltp_pmv_query_trend.trend_sql_params_type,
  p_fact_sql          OUT NOCOPY VARCHAR2,
  p_measure_columns   OUT NOCOPY hri_oltp_pmv_query_trend.trend_measure_cols_type);

END hri_bpl_trend_trm_sql;

 

/
