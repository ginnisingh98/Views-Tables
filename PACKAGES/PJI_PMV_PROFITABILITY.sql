--------------------------------------------------------
--  DDL for Package PJI_PMV_PROFITABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PMV_PROFITABILITY" AUTHID CURRENT_USER AS
/* $Header: PJIRF04S.pls 115.5 2003/06/23 09:31:08 aljain noship $*/


PROCEDURE GET_SQL_PJI_REP_PP1 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
		, x_PMV_Sql OUT NOCOPY VARCHAR2
                , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_SQL_PJI_REP_PP2 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
 		, x_PMV_Sql OUT NOCOPY VARCHAR2
                , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE GET_SQL_PJI_REP_PP3 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
		, x_PMV_Sql OUT NOCOPY VARCHAR2
                , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_SQL_PJI_REP_PP4 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
		, x_PMV_Sql OUT NOCOPY VARCHAR2
                , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_SQL_PJI_REP_PP9 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
		, x_PMV_Sql OUT NOCOPY VARCHAR2
                , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
PROCEDURE GET_SQL_PJI_REP_PP10 (p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
		, x_PMV_Sql OUT NOCOPY VARCHAR2
                , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

-- -------------------------------------------------------------
-- PLSQL DRIVERS
-- -------------------------------------------------------------

FUNCTION PLSQLDriver_PJI_REP_PP3(
                        p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
                        , p_Organization		IN VARCHAR2
                        , p_Currency_Type		IN VARCHAR2
                        , p_As_Of_Date                  IN NUMBER
                        , p_Period_Type 		IN VARCHAR2
                        , p_View_BY 			IN VARCHAR2
                        , p_Classifications		IN VARCHAR2 DEFAULT NULL
                        , p_Class_Codes			IN VARCHAR2 DEFAULT NULL
			, p_Expenditure_Category        IN VARCHAR2 DEFAULT NULL
			, p_Expenditure_Type            IN VARCHAR2 DEFAULT NULL
			, p_Revenue_Category            IN VARCHAR2 DEFAULT NULL
			, p_Revenue_Type                IN VARCHAR2 DEFAULT NULL
			, p_Work_Type                   IN VARCHAR2 DEFAULT NULL

		)  RETURN PJI_REP_PP3_TBL;


FUNCTION PLSQLDriver_PJI_REP_PPDTL(
                        p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
                        , p_Organization		IN VARCHAR2
                        , p_Currency_Type		IN VARCHAR2
                        , p_As_Of_Date                  IN NUMBER
                        , p_Period_Type 		IN VARCHAR2
                        , p_View_BY 			IN VARCHAR2
                        , p_Classifications		IN VARCHAR2 DEFAULT NULL
                        , p_Class_Codes			IN VARCHAR2 DEFAULT NULL
                        , p_Project_IDs			IN VARCHAR2 DEFAULT NULL
			, p_Expenditure_Category        IN VARCHAR2 DEFAULT NULL
			, p_Expenditure_Type            IN VARCHAR2 DEFAULT NULL
			, p_Revenue_Category            IN VARCHAR2 DEFAULT NULL
			, p_Revenue_Type                IN VARCHAR2 DEFAULT NULL
			, p_Work_Type                   IN VARCHAR2 DEFAULT NULL
		)  RETURN PJI_REP_PPDTL_TBL;


FUNCTION PLSQLDriver_PJI_REP_PPSUM(
                        p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
                        , p_Organization		IN VARCHAR2
                        , p_Currency_Type		IN VARCHAR2
                        , p_As_Of_Date                  IN NUMBER
                        , p_Time_Comparison_Type        IN VARCHAR2
                        , p_Period_Type 		IN VARCHAR2
                        , p_View_BY 			IN VARCHAR2
                        , p_Classifications		IN VARCHAR2 DEFAULT NULL
                        , p_Class_Codes			IN VARCHAR2 DEFAULT NULL
                        , p_Expenditure_Category        IN VARCHAR2 DEFAULT NULL
                        , p_Expenditure_Type            IN VARCHAR2 DEFAULT NULL
                        , p_Revenue_Category            IN VARCHAR2 DEFAULT NULL
                        , p_Revenue_Type                IN VARCHAR2 DEFAULT NULL
                        , p_Work_Type                   IN VARCHAR2 DEFAULT NULL

		)  RETURN PJI_REP_PPSUM_TBL;


END PJI_PMV_PROFITABILITY;

 

/
