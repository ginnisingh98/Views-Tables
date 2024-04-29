--------------------------------------------------------
--  DDL for Package PJI_PMV_PROFITABILITY_TREND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PMV_PROFITABILITY_TREND" AUTHID CURRENT_USER AS
/* $Header: PJIRF05S.pls 115.4 2003/06/23 09:41:02 aljain noship $ */

FUNCTION PLSQLDriver_PJI_REP_PP5(
  p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
, p_Organization			IN VARCHAR2
, p_Currency_Type			IN VARCHAR2
, p_As_Of_Date			IN NUMBER
, p_Period_Type 			IN VARCHAR2
, p_View_BY 			IN VARCHAR2
, p_Classifications		IN VARCHAR2 DEFAULT NULL
, p_Class_Codes			IN VARCHAR2 DEFAULT NULL
, p_Report_Type			IN VARCHAR2 DEFAULT NULL
, p_Expenditure_Category        IN VARCHAR2 DEFAULT NULL
, p_Expenditure_Type            IN VARCHAR2 DEFAULT NULL
, p_Revenue_Category            IN VARCHAR2 DEFAULT NULL
, p_Revenue_Type                IN VARCHAR2 DEFAULT NULL
, p_Work_Type                   IN VARCHAR2 DEFAULT NULL
)RETURN PJI_REP_PP5_TBL ;

PROCEDURE Get_SQL_PJI_REP_PP5(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql OUT NOCOPY VARCHAR2
                    , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE Get_SQL_PJI_REP_PP6(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql OUT NOCOPY VARCHAR2
                    , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE Get_SQL_PJI_REP_PP7(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql OUT NOCOPY VARCHAR2
                    , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE Get_SQL_PJI_REP_PP8(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql OUT NOCOPY VARCHAR2
                    , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END PJI_PMV_PROFITABILITY_TREND;

 

/
