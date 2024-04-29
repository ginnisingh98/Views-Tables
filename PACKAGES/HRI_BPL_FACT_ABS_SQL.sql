--------------------------------------------------------
--  DDL for Package HRI_BPL_FACT_ABS_SQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_FACT_ABS_SQL" AUTHID CURRENT_USER AS
/* $Header: hribfabs.pkh 120.0 2005/09/22 07:28 cbridge noship $ */
TYPE abs_fact_param_type IS RECORD
 (bind_format               VARCHAR2(30),
  include_abs_drtn_days     VARCHAR2(30) DEFAULT 'N',
  include_abs_drtn_hrs      VARCHAR2(30) DEFAULT 'N',
  include_abs_in_period     VARCHAR2(30) DEFAULT 'N',
  include_abs_ntfctn_period VARCHAR2(30) DEFAULT 'N',
  include_comp              VARCHAR2(30) DEFAULT 'N',
  kpi_mode                  VARCHAR2(30) DEFAULT 'N',
  bucket_dim                VARCHAR2(100) DEFAULT NULL);

PROCEDURE set_fact_table
 (p_parameter_rec        IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bucket_dim           IN VARCHAR2,
  p_abs_drtn_days        IN VARCHAR2,
  p_abs_drtn_hrs         IN VARCHAR2,
  p_abs_in_period        IN VARCHAR2,
  p_abs_ntfctn_period    IN VARCHAR2,
  p_parameter_count      IN PLS_INTEGER,
  p_single_param         IN VARCHAR2,
  p_use_snapshot         IN OUT NOCOPY BOOLEAN,
  p_fact_table           OUT NOCOPY VARCHAR2);

FUNCTION get_sql
 (p_parameter_rec    IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab         IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_abs_params  IN abs_fact_param_type)
     RETURN VARCHAR2;

FUNCTION get_sql
 (p_parameter_rec    IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab         IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_abs_params  IN abs_fact_param_type,
  p_calling_module   IN VARCHAR2)
     RETURN VARCHAR2;

END HRI_BPL_FACT_ABS_SQL;

 

/
