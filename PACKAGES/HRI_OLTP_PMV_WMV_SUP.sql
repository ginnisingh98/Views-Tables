--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_WMV_SUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_WMV_SUP" AUTHID CURRENT_USER AS
/* $Header: hriopwmv.pkh 120.1 2005/06/03 07:08:16 jrstewar noship $ */

PROCEDURE get_sql2(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                   x_custom_sql          OUT NOCOPY VARCHAR2,
                   x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_wmv_low_kpi(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql             OUT NOCOPY VARCHAR2,
                          x_custom_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_wmv_c_low_kpi(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                   x_custom_sql          OUT NOCOPY VARCHAR2,
                   x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_wmv_c_atvty_kpi(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                   x_custom_sql          OUT NOCOPY VARCHAR2,
                   x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END HRI_OLTP_PMV_WMV_SUP;

 

/
