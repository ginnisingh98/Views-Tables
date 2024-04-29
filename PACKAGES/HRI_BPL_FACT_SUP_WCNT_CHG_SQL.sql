--------------------------------------------------------
--  DDL for Package HRI_BPL_FACT_SUP_WCNT_CHG_SQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_FACT_SUP_WCNT_CHG_SQL" AUTHID CURRENT_USER AS
/* $Header: hribfwch.pkh 120.0 2005/05/29 07:03:05 appldev noship $ */

/******************************************************************************/
/* Column aliases returned:                                                   */
/* ------------------------                                                   */
/* The following columns are always returned whatever parameters are set:     */
/*   vby_id      (group by column corresponding to selected view by)          */
/*   direct_ind  (whether the row is the direct reports summary row)          */
/*                                                                            */
/* The column list below is returned if the include_hire parameter is set:    */
/*                                                                            */
/*   curr_hire_hdc                                                            */
/*   curr_hire_hdc_<bucket>  (if bucket_dim parameter is set)                 */
/*   comp_hire_hdc           (if include_comp parameter is set)               */
/*   comp_hire_hdc_<bucket>  (if include_comp and bucket_dim are set)         */
/*                                                                            */
/* An analagous column set is returned for every measure, except for the      */
/* length of service parameter include_low. If this is set then there are     */
/* two sets of columns added for the length of service in months and days.    */
/*                                                                            */
/* Example                                                                    */
/* -------                                                                    */
/* For example if:                                                            */
/*   include_comp = 'N'                                                       */
/*   bucket_dim = ''                                                          */
/*                                                                            */
/* and all other measure parameters are set then the following column list    */
/* will be returned:                                                          */
/*   curr_hire_hdc                                                            */
/*   curr_transfer_in_hdc                                                     */
/*   curr_transfer_out_hdc                                                    */
/*   curr_termination_hdc                                                     */
/*   curr_term_vol_hdc                                                        */
/*   curr_term_inv_hdc                                                        */
/*   curr_low_months                                                          */
/*   curr_low_days                                                            */
/*                                                                            */
/******************************************************************************/

TYPE wcnt_chg_fact_param_type IS RECORD
 (bind_format        VARCHAR2(30),
  include_comp       VARCHAR2(30) DEFAULT 'N',
  include_hire       VARCHAR2(30) DEFAULT 'N',
  include_trin       VARCHAR2(30) DEFAULT 'N',
  include_trout      VARCHAR2(30) DEFAULT 'N',
  include_term       VARCHAR2(30) DEFAULT 'N',
  include_sep        VARCHAR2(30) DEFAULT 'N',
  include_sep_inv    VARCHAR2(30) DEFAULT 'N',
  include_sep_vol    VARCHAR2(30) DEFAULT 'N',
  include_low        VARCHAR2(30) DEFAULT 'N',
  kpi_mode           VARCHAR2(30) DEFAULT 'N',
  bucket_dim         VARCHAR2(100) DEFAULT NULL);

PROCEDURE set_fact_table
 (p_parameter_rec   IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bucket_dim      IN VARCHAR2,
  p_include_hire    IN VARCHAR2,
  p_include_trin    IN VARCHAR2,
  p_include_trout   IN VARCHAR2,
  p_include_term    IN VARCHAR2,
  p_include_low     IN VARCHAR2,
  p_parameter_count IN PLS_INTEGER,
  p_single_param    IN VARCHAR2,
  p_use_snapshot    IN OUT NOCOPY BOOLEAN,
  p_fact_table      OUT NOCOPY VARCHAR2);

FUNCTION get_sql
 (p_parameter_rec    IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab         IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_wcnt_chg_params  IN wcnt_chg_fact_param_type)
     RETURN VARCHAR2;

FUNCTION get_sql
 (p_parameter_rec    IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab         IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_wcnt_chg_params  IN wcnt_chg_fact_param_type,
  p_calling_module   IN VARCHAR2)
     RETURN VARCHAR2;

END hri_bpl_fact_sup_wcnt_chg_sql;

 

/
