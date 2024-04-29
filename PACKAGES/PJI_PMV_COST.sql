--------------------------------------------------------
--  DDL for Package PJI_PMV_COST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PMV_COST" AUTHID CURRENT_USER AS
/* $Header: PJIRF06S.pls 120.1 2005/05/31 08:17:56 appldev  $ */


PROCEDURE GET_SQL_PJI_REP_PC10 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
		 , x_PMV_Sql OUT NOCOPY  VARCHAR2
         , x_PMV_Output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE Get_SQL_PJI_REP_PC11(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
         , x_PMV_Sql OUT NOCOPY VARCHAR2
         , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_SQL_PJI_REP_PC13(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
	     , x_PMV_Sql OUT NOCOPY VARCHAR2
         , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE Get_SQL_PJI_REP_PC12(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
         , x_PMV_Sql    OUT NOCOPY VARCHAR2
         , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- -------------------------------------------------------------
-- PLSQL DRIVERS
-- -------------------------------------------------------------

FUNCTION  PLSQLDriver_PJI_REP_PC10(
           p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
         , p_Organization		IN VARCHAR2
         , p_Currency_Type		IN VARCHAR2
         , p_As_of_Date         IN NUMBER
         , p_Time_Comparison_Type       IN VARCHAR2
         , p_Period_Type 		IN VARCHAR2
         , p_View_BY 			IN VARCHAR2
         , p_Classifications	IN VARCHAR2 DEFAULT NULL
         , p_Class_Codes		IN VARCHAR2 DEFAULT NULL
         , p_Expenditure_Category   IN VARCHAR2 DEFAULT NULL
         , p_Expenditure_Type       IN VARCHAR2 DEFAULT NULL
         , p_Work_Type              IN VARCHAR2 DEFAULT NULL
         )  RETURN PJI_REP_PC10_TBL;

FUNCTION PLSQLDriver_PJI_REP_PC11(
  p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
, p_Organization			IN VARCHAR2
, p_Currency_Type			IN VARCHAR2
, p_As_Of_Date			IN NUMBER
, p_Period_Type 			IN VARCHAR2
, p_View_BY 			IN VARCHAR2
, p_Classifications		IN VARCHAR2 DEFAULT NULL
, p_Class_Codes			IN VARCHAR2 DEFAULT NULL
, p_Report_Type			IN VARCHAR2 DEFAULT NULL
         , p_Expenditure_Category   IN VARCHAR2 DEFAULT NULL
         , p_Expenditure_Type       IN VARCHAR2 DEFAULT NULL
         , p_Work_Type              IN VARCHAR2 DEFAULT NULL

)RETURN PJI_REP_PC11_TBL ;


FUNCTION  PLSQLDriver_PJI_REP_PC13(
           p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
         , p_Organization		IN VARCHAR2
         , p_Currency_Type		IN VARCHAR2
         , p_As_of_Date         IN NUMBER
         , p_Period_Type 		IN VARCHAR2
         , p_View_BY 			IN VARCHAR2
         , p_Classifications	IN VARCHAR2 DEFAULT NULL
         , p_Class_Codes		IN VARCHAR2 DEFAULT NULL
         , p_Project_IDS		IN VARCHAR2 DEFAULT NULL
         , p_Expenditure_Category   IN VARCHAR2 DEFAULT NULL
         , p_Expenditure_Type       IN VARCHAR2 DEFAULT NULL
         , p_Work_Type              IN VARCHAR2 DEFAULT NULL

         )  RETURN PJI_REP_PC13_TBL;

END PJI_PMV_COST;

 

/
