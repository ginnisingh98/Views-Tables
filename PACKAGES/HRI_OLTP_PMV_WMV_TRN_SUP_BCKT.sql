--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_WMV_TRN_SUP_BCKT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_WMV_TRN_SUP_BCKT" AUTHID CURRENT_USER AS
/* $Header: hrioptrp.pkh 120.0 2005/05/29 07:36:46 appldev noship $ */

PROCEDURE GET_SQL_BKCT_PERF(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                  x_custom_sql          OUT NOCOPY VARCHAR2,
                  x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_TRN_POW_SQL(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql         OUT NOCOPY VARCHAR2,
                      x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE get_trn_perf_kpi
      (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql          OUT NOCOPY VARCHAR2,
       x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
END hri_oltp_pmv_wmv_trn_sup_bckt;

 

/
