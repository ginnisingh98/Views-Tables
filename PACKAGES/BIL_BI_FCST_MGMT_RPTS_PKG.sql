--------------------------------------------------------
--  DDL for Package BIL_BI_FCST_MGMT_RPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIL_BI_FCST_MGMT_RPTS_PKG" AUTHID CURRENT_USER AS
 /* $Header: bilbfss.pls 120.0 2005/05/30 13:21:22 appldev noship $ */
    PROCEDURE BIL_BI_FRCST_OVERVIEW ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
	                                ,x_custom_sql         OUT NOCOPY VARCHAR2
	                                ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL );

    PROCEDURE BIL_BI_FRCST_PRODCAT ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                      ,x_custom_sql         OUT NOCOPY VARCHAR2
                                      ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL );

END BIL_BI_FCST_MGMT_RPTS_PKG;

 

/
