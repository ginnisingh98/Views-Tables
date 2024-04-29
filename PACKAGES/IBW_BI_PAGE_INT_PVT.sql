--------------------------------------------------------
--  DDL for Package IBW_BI_PAGE_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBW_BI_PAGE_INT_PVT" AUTHID CURRENT_USER AS
/* $Header: ibwbpags.pls 120.1 2005/09/25 07:55 narao noship $ */

--This is for the UI Query of Page Interest Non Trend report
PROCEDURE get_page_int_sql
(
  p_param           IN  BIS_PMV_PAGE_PARAMETER_TBL
  , x_custom_sql    OUT NOCOPY VARCHAR2
  , x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
);

--This is for the UI Query of Page Interest Trend report
PROCEDURE get_page_int_trend_sql
(
   p_param           IN  BIS_PMV_PAGE_PARAMETER_TBL
   , x_custom_sql    OUT NOCOPY VARCHAR2
   , x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
);

END IBW_BI_PAGE_INT_PVT;

 

/
