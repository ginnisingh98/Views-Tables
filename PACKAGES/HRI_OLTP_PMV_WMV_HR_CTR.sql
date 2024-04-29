--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_WMV_HR_CTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_WMV_HR_CTR" AUTHID CURRENT_USER AS
/* $Header: hriopwhc.pkh 120.0 2005/05/29 07:38:29 appldev noship $ */

/* Default Number of Top Countries to display in the portlet*/
g_no_countries_to_show   PLS_INTEGER := 10;

PROCEDURE get_kpi
   (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql          OUT NOCOPY VARCHAR2,
    x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_sql2
   (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
    x_custom_sql          OUT NOCOPY VARCHAR2,
    x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END hri_oltp_pmv_wmv_hr_ctr;

 

/
