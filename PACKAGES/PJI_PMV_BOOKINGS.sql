--------------------------------------------------------
--  DDL for Package PJI_PMV_BOOKINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_PMV_BOOKINGS" AUTHID CURRENT_USER AS
/* $Header: PJIRF01S.pls 120.1 2005/05/31 08:16:55 appldev  $ */
FUNCTION PLSQLDriver_Bookings(
				  p_Operating_Unit		IN VARCHAR2 DEFAULT NULL
				, p_Organization			IN VARCHAR2
				, p_Currency_Type			IN VARCHAR2
				, p_As_Of_Date			IN NUMBER
				, p_Period_Type 			IN VARCHAR2
				, p_View_BY 			IN VARCHAR2
				, p_Classifications		IN VARCHAR2 DEFAULT NULL
				, p_Class_Codes			IN VARCHAR2 DEFAULT NULL
				)RETURN PJI_AC_BOOKINGS_TBL;

PROCEDURE Get_SQL_PJI_REP_PBO1(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
					, x_PMV_Sql OUT NOCOPY  VARCHAR2
					, x_PMV_Output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE Get_SQL_PJI_REP_PBO2(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql OUT NOCOPY  VARCHAR2
                    , x_PMV_Output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);

PROCEDURE Get_SQL_PJI_REP_PBO3(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                    , x_PMV_Sql OUT NOCOPY  VARCHAR2
                    , x_PMV_Output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);

END PJI_PMV_BOOKINGS;

 

/
