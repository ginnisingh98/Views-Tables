--------------------------------------------------------
--  DDL for Package HRI_BPL_FACT_SUP_WRKFC_SQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_FACT_SUP_WRKFC_SQL" AUTHID CURRENT_USER AS
/* $Header: hribfwrk.pkh 120.1 2006/08/18 06:22:08 rkonduru noship $ */

/******************************************************************************/
/* Column aliases returned:                                                   */
/* ------------------------                                                   */
/* The following columns are always returned whatever parameters are set:     */
/*   vby_id      (group by column corresponding to selected view by)          */
/*   direct_ind  (whether the row is the direct reports summary row)          */
/*                                                                            */
/* The column list below is returned if the include_hdc parameter is set:     */
/*   curr_hdc_end                                                             */
/*   curr_hdc_start     (if include_start parameter is set)                   */
/*   curr_hdc_<bucket>  (if bucket_dim parameter is set)                      */
/*   comp_hdc_end       (if include_comp parameter is set)                    */
/*   comp_hdc_start     (if include_comp and include_start are set)           */
/*   comp_hdc_<bucket>  (if include_comp and bucket_dim are set)              */
/*                                                                            */
/* In addition to the above list, a further list of columns is added to allow */
/* grand totals to be calculated.                                             */
/*   curr_total_hdc_start     (if include_start parameter is set)             */
/*   curr_total_hdc_<bucket>  (if bucket_dim parameter is set)                */
/*   comp_total_hdc_end       (if include_comp parameter is set)              */
/*   comp_total_hdc_start     (if include_comp and include_start are set)     */
/*   comp_total_hdc_<bucket>  (if include_comp and bucket_dim are set)        */
/*                                                                            */
/* An analagous column set is returned for every measure, except for the      */
/* _start columns which are only added on for the headcount measure.          */
/*                                                                            */
/* Example                                                                    */
/* -------                                                                    */
/* For example if:                                                            */
/*   include_comp = 'N'                                                       */
/*   include_start = 'Y'                                                      */
/*   bucket_dim = ''                                                          */
/*                                                                            */
/* and all other measure parameters are set then the following column list    */
/* will be returned:                                                          */
/*   curr_hdc_end                                                             */
/*   curr_hdc_start                                                           */
/*   curr_sal_end                                                             */
/*   curr_low_end                                                             */
/*   curr_total_hdc_start                                                     */
/*                                                                            */
/******************************************************************************/

TYPE wrkfc_fact_param_type IS RECORD
 (bind_format    VARCHAR2(30),
  include_comp   VARCHAR2(30)  DEFAULT 'N',
  include_start  VARCHAR2(30)  DEFAULT 'N',
  include_hdc    VARCHAR2(30)  DEFAULT 'N',
  include_sal    VARCHAR2(30)  DEFAULT 'N',
  include_low    VARCHAR2(30)  DEFAULT 'N',
  include_pasg_cnt VARCHAR2(30) DEFAULT 'N',
  kpi_mode       VARCHAR2(30)  DEFAULT 'N',
  bucket_dim     VARCHAR2(100) DEFAULT NULL);

PROCEDURE set_fact_table
 (p_parameter_rec   IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bucket_dim      IN VARCHAR2,
  p_include_sal     IN VARCHAR2,
  p_parameter_count IN PLS_INTEGER,
  p_single_param    IN VARCHAR2,
  p_use_snapshot    IN OUT NOCOPY BOOLEAN,
  p_fact_table      OUT NOCOPY VARCHAR2);

FUNCTION get_sql
 (p_parameter_rec  IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab       IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_wrkfc_params   IN wrkfc_fact_param_type)
     RETURN VARCHAR2;

FUNCTION get_sql
 (p_parameter_rec   IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab        IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_wrkfc_params    IN wrkfc_fact_param_type,
  p_calling_module  IN VARCHAR2)
     RETURN VARCHAR2;

END hri_bpl_fact_sup_wrkfc_sql;

 

/
