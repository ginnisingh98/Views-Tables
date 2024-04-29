--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_WMV_SUP_BCKT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_WMV_SUP_BCKT" AUTHID CURRENT_USER AS
/* $Header: hriophrp.pkh 120.0 2005/05/29 07:33:17 appldev noship $ */

PROCEDURE get_sql_bckt_perf
     (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
      x_custom_sql         OUT NOCOPY VARCHAR2,
      x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_sql_bckt_low
     (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
      x_custom_sql         OUT NOCOPY VARCHAR2,
      x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_wmv_perf_kpi
      (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql          OUT NOCOPY VARCHAR2,
       x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END hri_oltp_pmv_wmv_sup_bckt;

 

/
