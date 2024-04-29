--------------------------------------------------------
--  DDL for Package PJI_PMV_BOOKINGS_BACKLOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PMV_BOOKINGS_BACKLOG" AUTHID CURRENT_USER AS
/* $Header: PJIRF02S.pls 120.1 2005/06/16 05:16:03 appldev  $ */
FUNCTION PLSQLDriver_PJI_REP_PBB1(
  p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
, p_Organization			IN VARCHAR2
, p_Currency_Type			IN VARCHAR2
, p_As_Of_Date			IN NUMBER
, p_Period_Type 			IN VARCHAR2
, p_View_BY 			IN VARCHAR2
, p_Classifications		IN VARCHAR2 DEFAULT NULL
, p_Class_Codes			IN VARCHAR2 DEFAULT NULL
, p_Comparator_Type		IN VARCHAR2 DEFAULT NULL
)RETURN PJI_REP_PBB1_TBL ;

FUNCTION PLSQLDriver_PBB3(
  p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
  , p_Organization		IN VARCHAR2
  , p_Currency_Type		IN VARCHAR2
  , p_As_Of_Date            	IN NUMBER
  , p_Period_Type 		IN VARCHAR2
  , p_View_BY 			IN VARCHAR2
  , p_Classifications		IN VARCHAR2 DEFAULT NULL
  , p_Class_Codes			IN VARCHAR2 DEFAULT NULL
  )RETURN PJI_REP_PBB3_TBL;

FUNCTION PLSQLDriver_PJI_REP_PBB2(
  p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
, p_Organization			IN VARCHAR2
, p_Currency_Type			IN VARCHAR2
, p_As_Of_Date			IN NUMBER
, p_Period_Type 			IN VARCHAR2
, p_View_BY 			IN VARCHAR2
, p_Classifications		IN VARCHAR2 DEFAULT NULL
, p_Class_Codes			IN VARCHAR2 DEFAULT NULL
, p_Run_Revenue_At_Risk		IN VARCHAR2 DEFAULT 'N'
)RETURN PJI_REP_PBB2_TBL;

PROCEDURE Get_SQL_PJI_REP_PBB1(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql OUT NOCOPY VARCHAR2
                    , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE Get_SQL_PJI_REP_PBB2(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql OUT NOCOPY VARCHAR2
                    , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE Get_SQL_PJI_REP_PBB3(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql OUT NOCOPY VARCHAR2
                    , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE Get_SQL_PJI_REP_PBB4(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql OUT NOCOPY VARCHAR2
                    , x_PMV_Output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);

END PJI_PMV_BOOKINGS_BACKLOG;

 

/
