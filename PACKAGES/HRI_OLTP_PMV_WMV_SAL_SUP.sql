--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_WMV_SAL_SUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_WMV_SAL_SUP" AUTHID CURRENT_USER AS
/* $Header: hriopsbm.pkh 120.0 2005/05/29 07:35:25 appldev noship $ */

PROCEDURE get_sql2(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                   x_custom_sql          OUT NOCOPY VARCHAR2,
                   x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_sal_kpi(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql         OUT NOCOPY VARCHAR2,
                      x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END hri_oltp_pmv_wmv_sal_sup;

 

/
