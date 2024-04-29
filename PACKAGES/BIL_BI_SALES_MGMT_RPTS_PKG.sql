--------------------------------------------------------
--  DDL for Package BIL_BI_SALES_MGMT_RPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIL_BI_SALES_MGMT_RPTS_PKG" AUTHID CURRENT_USER AS
/* $Header: bilbsss.pls 120.1 2005/08/10 04:09:30 hrpandey noship $ */

	PROCEDURE BIL_BI_SALES_MGMT_SUMRY  (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                   ,x_custom_sql         OUT NOCOPY VARCHAR2
                                   ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);



    PROCEDURE BIL_BI_OPPTY_OVERVIEW(  p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                  ,x_custom_sql         OUT NOCOPY VARCHAR2
                                  ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL );

    PROCEDURE BIL_BI_OPPTY_WIN_LOSS_COUNTS(  p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                  ,x_custom_sql         OUT NOCOPY VARCHAR2
                                  ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL );


	PROCEDURE BIL_BI_GRP_FRCST ( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                ,x_custom_sql         OUT NOCOPY VARCHAR2
                                ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL );
	PROCEDURE BIL_BI_OPEN_LDOPBKLOG (
			  				p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                           ,x_custom_sql         OUT NOCOPY VARCHAR2
                           ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


    PROCEDURE BIL_LDOPP_CAMP( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                               ,x_custom_sql         OUT NOCOPY VARCHAR2
                               ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL );


 PROCEDURE BIL_BI_SLS_PERF(
              p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
              ,x_custom_sql        OUT NOCOPY VARCHAR2
              ,x_custom_attr       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);



END BIL_BI_SALES_MGMT_RPTS_PKG;

 

/
