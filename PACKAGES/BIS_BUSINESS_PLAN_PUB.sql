--------------------------------------------------------
--  DDL for Package BIS_BUSINESS_PLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_BUSINESS_PLAN_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPBPS.pls 120.0 2005/06/01 15:25:37 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPBPS.pls                                                       |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for managing business plans for the
REM |     Key Performance Framework.
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 14-JUL-1999  irchen   Creation
REM +=======================================================================+
*/
--
-- Data Types: Records
--
TYPE Business_Plan_Rec_Type IS RECORD
( Business_Plan_ID         NUMBER        := BIS_UTILITIES_PUB.G_NULL_NUM
, Business_Plan_Short_Name VARCHAR2(30)  := BIS_UTILITIES_PUB.G_NULL_CHAR
, Business_Plan_Name       VARCHAR2(80)  := BIS_UTILITIES_PUB.G_NULL_CHAR
, Description              VARCHAR2(240) := BIS_UTILITIES_PUB.G_NULL_CHAR
, Version_number           NUMBER        := BIS_UTILITIES_PUB.G_NULL_NUM
, Current_Plan_Flag        VARCHAR2(1)   := BIS_UTILITIES_PUB.G_NULL_CHAR
);
--
-- Data Types: Tables
--
TYPE Business_Plan_Tbl_Type IS TABLE OF Business_Plan_Rec_Type
INDEX BY BINARY_INTEGER;
--
--
Procedure Retrieve_Business_Plans
( p_api_version       IN  NUMBER
, x_Business_Plan_Tbl OUT NOCOPY BIS_BUSINESS_PLAN_PUB.Business_Plan_Tbl_Type
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Retrieve_Business_Plan
( p_api_version       IN  NUMBER
, p_Business_Plan_Rec IN  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, x_Business_Plan_Rec OUT NOCOPY BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Translate_Business_Plan
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Business_Plan_Rec IN  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, p_OWNER             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Load_Business_Plan
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Business_Plan_Rec IN  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, p_OWNER             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
END BIS_BUSINESS_PLAN_PUB;

 

/
