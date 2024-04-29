--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_WMV_SAL_SUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_WMV_SAL_SUP_PVT" AUTHID CURRENT_USER AS
/* $Header: hriopwsp.pkh 120.0 2005/05/29 07:39:21 appldev noship $ */
--
--****************************************************************************
--* AK SQL For Headcount and Salary by Country Status                        *
--* AK Region : HRI_P_WMV_SAL_CTR_SUP_PVT                                    *
--****************************************************************************
--
--
  PROCEDURE GET_SQL_CTR2(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                        ,x_custom_sql  OUT NOCOPY VARCHAR2
                        ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

--
--****************************************************************************
--* AK SQL For Headcount and Salary by Regio                                 *
--* AK Region : HRI_P_WMV_SAL_RGN_SUP                                        *
--****************************************************************************
--
--
  PROCEDURE GET_SQL_RGN2(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                        ,x_custom_sql  OUT NOCOPY VARCHAR2
                        ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
--****************************************************************************
--* AK SQL For Headcount and Salary by City                                  *
--* AK Region :  HRI_P_WMV_SAL_CIT_SUP                                       *
--****************************************************************************
--

  PROCEDURE GET_SQL_CIT2(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                        ,x_custom_sql  OUT NOCOPY VARCHAR2
                        ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
   ) ;
--
--****************************************************************************
--* AK SQL for Headcount and Salary by Job Family                            *
--* AK Region :  HRI_P_WMV_SAL_JFM_SUP                                       *
--****************************************************************************
--
   PROCEDURE get_sql_jfm2(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                       x_custom_sql  OUT NOCOPY VARCHAR2,
                       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
--****************************************************************************
--* AK SQL for Headcount and Salary by Job Function                          *
--* AK Region :  HRI_P_WMV_SAL_JFMFN_SUP                                     *
--****************************************************************************
--
  PROCEDURE get_sql_jfmfn2(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                         x_custom_sql  OUT NOCOPY VARCHAR2,
                         x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);


END HRI_OLTP_PMV_WMV_SAL_SUP_PVT;

 

/
