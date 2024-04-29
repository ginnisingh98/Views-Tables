--------------------------------------------------------
--  DDL for Package HRI_OLTP_PMV_ABS_WMV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_PMV_ABS_WMV_PVT" AUTHID CURRENT_USER AS
/* $Header: hriopabswmvpvt.pkh 120.0 2005/09/22 07:30 cbridge noship $ */
--
--****************************************************************************
--* AK SQL For Absence Summary by Manager                                    *
--* AK Region : HRI_P_ABS_PVT                                                *
--****************************************************************************
--
--
  PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql  OUT NOCOPY VARCHAR2
                   ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

--
--****************************************************************************
--* AK SQL For Absence  (Employee) KPI's
--* AK Region : HRI_K_ABS_WMV
--****************************************************************************
--
--
  PROCEDURE GET_SQL_KPI(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql  OUT NOCOPY VARCHAR2
                   ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
--****************************************************************************
--* AK SQL For
--* AK Region :
--****************************************************************************
--

END HRI_OLTP_PMV_ABS_WMV_PVT;

 

/
