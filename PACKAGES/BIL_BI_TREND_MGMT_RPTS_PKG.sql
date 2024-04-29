--------------------------------------------------------
--  DDL for Package BIL_BI_TREND_MGMT_RPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIL_BI_TREND_MGMT_RPTS_PKG" AUTHID CURRENT_USER AS
  /* $Header: bilbtrs.pls 115.13 2004/02/06 09:17:05 rathirum ship $ */



 PROCEDURE BIL_BI_FST_WON_QTA_TREND(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                                  ,x_custom_sql        OUT NOCOPY VARCHAR2
                                  ,x_custom_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


  PROCEDURE BIL_BI_FRCST_PIPE_TREND(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                                  ,x_custom_sql        OUT NOCOPY VARCHAR2
                                  ,x_custom_attr     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

  PROCEDURE BIL_BI_PIPELINE_MOMENTUM_TREND( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                    ,x_custom_sql         OUT NOCOPY VARCHAR2
                                  ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL );

  PROCEDURE BIL_BI_WIN_LOSS_CONV_TREND( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                    ,x_custom_sql         OUT NOCOPY VARCHAR2
                                  ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL );

  PROCEDURE BIL_BI_FRCST_PIPE_WON_TREND( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                    ,x_custom_sql         OUT NOCOPY VARCHAR2
                                  ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL );

 PROCEDURE BIL_BI_FRCST_WON_TREND( p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                                    ,x_custom_sql         OUT NOCOPY VARCHAR2
                                  ,x_custom_attr        OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL );
END;

 

/
