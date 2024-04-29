--------------------------------------------------------
--  DDL for Package IBW_BI_PROD_REF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBW_BI_PROD_REF_PVT" AUTHID CURRENT_USER AS
/* $Header: ibwbreps.pls 120.1 2005/09/25 08:01 narao noship $ */

--This is for the UI Query of Web Referral Analysis report
PROCEDURE GET_WEB_REF_SQL
(
  p_param           IN  BIS_PMV_PAGE_PARAMETER_TBL
  , x_custom_sql    OUT NOCOPY VARCHAR2
  , x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
);

--This is for the UI Query of Web Product Interest report
PROCEDURE GET_PROD_INT_SQL
(
   p_param           IN  BIS_PMV_PAGE_PARAMETER_TBL
   , x_custom_sql    OUT NOCOPY VARCHAR2
   , x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
);

END IBW_BI_PROD_REF_PVT;

 

/
