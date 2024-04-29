--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_QUERY_WRKFC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_QUERY_WRKFC" AUTHID CURRENT_USER AS
/* $Header: hriopqwk.pkh 120.0 2005/05/29 07:34:44 appldev noship $ */

FUNCTION get_sql
 (p_parameter_rec   IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab        IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_wrkfc_params    IN hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type,
  p_calling_module  IN VARCHAR2)
     RETURN VARCHAR2;

END hri_oltp_pmv_query_wrkfc;

 

/
