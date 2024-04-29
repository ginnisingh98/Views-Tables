--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_WMV_TRN_SUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_WMV_TRN_SUP" AUTHID CURRENT_USER AS
/* $Header: hriopwts.pkh 120.0 2005/05/29 07:40:25 appldev noship $ */

PROCEDURE get_sql2(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                   x_custom_sql          OUT NOCOPY VARCHAR2,
                   x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_actual_detail_sql2
    (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
     x_custom_sql      OUT NOCOPY VARCHAR2,
     x_custom_output   OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_SQL_TRN_PVT
    (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
     x_custom_sql          OUT NOCOPY VARCHAR2,
     x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_trn_los_kpi
    (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
     x_custom_sql         OUT NOCOPY VARCHAR2,
     x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_wmv_trn_kpi
    (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
     x_custom_sql             OUT NOCOPY VARCHAR2,
     x_custom_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END hri_oltp_pmv_wmv_trn_sup;

 

/
