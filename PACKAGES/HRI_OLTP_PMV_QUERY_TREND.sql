--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_QUERY_TREND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_QUERY_TREND" AUTHID CURRENT_USER AS
/* $Header: hriopqtd.pkh 120.2 2005/09/20 05:02:45 cbridge noship $ */

TYPE trend_sql_params_type IS RECORD
 (bind_format      VARCHAR2(30) := 'PMV',
  include_hdc      VARCHAR2(30) := 'N',
  include_hdc_trn  VARCHAR2(30) := 'N',
  include_pasg_cnt VARCHAR2(30) := 'N',
  include_pasg_pow VARCHAR2(30) := 'N',
  include_extn_cnt VARCHAR2(30) := 'N',
  include_extn_pow VARCHAR2(30) := 'N',
  include_sal      VARCHAR2(30) := 'N',
  include_sep      VARCHAR2(30) := 'N',
  include_sep_vol  VARCHAR2(30) := 'N',
  include_sep_inv  VARCHAR2(30) := 'N',
  include_abs_drtn_days    VARCHAR2(30) := 'N',
  include_abs_drtn_hrs     VARCHAR2(30) := 'N',
  include_abs_in_period    VARCHAR2(30) := 'N',
  include_abs_ntfctn_period VARCHAR2(30) := 'N',
  bucket_dim       VARCHAR2(30) := '',
  past_trend       VARCHAR2(30) := 'Y',
  future_trend     VARCHAR2(30) := 'N');

TYPE trend_measure_cols_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

FUNCTION get_sql
 (p_parameter_rec     IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab          IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_trend_sql_params  IN trend_sql_params_type,
  p_calling_module    IN VARCHAR2)
RETURN VARCHAR2;

END hri_oltp_pmv_query_trend;

 

/
