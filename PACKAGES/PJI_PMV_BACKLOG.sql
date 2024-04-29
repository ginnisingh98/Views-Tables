--------------------------------------------------------
--  DDL for Package PJI_PMV_BACKLOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PMV_BACKLOG" AUTHID CURRENT_USER AS
/* $Header: PJIRF03S.pls 120.0 2005/06/12 21:02:00 appldev noship $ */

FUNCTION PLSQLDriver_PB1(
  p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
  , p_Organization		IN VARCHAR2
  , p_Currency_Type		IN VARCHAR2
  , p_As_Of_Date		IN NUMBER
  , p_Period_Type 		IN VARCHAR2
  , p_View_BY 			IN VARCHAR2
  , p_Classifications		IN VARCHAR2 DEFAULT NULL
  , p_Class_Codes		IN VARCHAR2 DEFAULT NULL
  )RETURN PJI_REP_PB1_TBL;

FUNCTION PLSQLDriver_PB2(
  p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
  , p_Organization		IN VARCHAR2
  , p_Currency_Type		IN VARCHAR2
  , p_As_Of_Date		IN NUMBER
  , p_Period_Type 		IN VARCHAR2
  , p_View_BY 			IN VARCHAR2
  , p_Classifications		IN VARCHAR2 DEFAULT NULL
  , p_Class_Codes		IN VARCHAR2 DEFAULT NULL
  )RETURN PJI_REP_PB2_TBL;

PROCEDURE Get_SQL_PJI_REP_PB1(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql OUT NOCOPY  VARCHAR2
                    , x_PMV_Output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE Get_SQL_PJI_REP_PB2(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql OUT NOCOPY  VARCHAR2
                    , x_PMV_Output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);

END;



 

/
