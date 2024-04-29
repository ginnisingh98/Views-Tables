--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_WMV_WF_SUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_WMV_WF_SUP" AUTHID CURRENT_USER AS
/* $Header: hriopwfs.pkh 120.0 2005/06/24 07:33:15 appldev noship $ */

PROCEDURE get_kpi(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                  x_custom_sql          OUT NOCOPY VARCHAR2,
                  x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE get_sql(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                  x_custom_sql          OUT NOCOPY VARCHAR2,
                  x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END HRI_OLTP_PMV_WMV_WF_SUP;

 

/
