--------------------------------------------------------
--  DDL for Package BIS_APPLICATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_APPLICATION_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVAPPS.pls 115.3 99/09/20 08:14:35 porting shi $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVAPPS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public record specifications for application
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 15-MAR-99 Ansingha Creation
REM |
REM +=======================================================================+
*/
--
G_NO_APPLICATION_ID CONSTANT NUMBER := -1;

TYPE Application_Rec_Type IS RECORD (
  Application_ID            NUMBER := FND_API.G_MISS_NUM
, Application_Short_Name    VARCHAR2(30) := FND_API.G_MISS_CHAR
, Application_Name          VARCHAR2(100) := FND_API.G_MISS_CHAR

);

TYPE Application_Tbl_Type IS TABLE of Application_Rec_Type
        INDEX BY BINARY_INTEGER;
--
PROCEDURE Retrieve_Applications
( p_api_version     IN  NUMBER
, x_Application_tbl OUT BIS_Application_PVT.Application_Tbl_Type
, x_return_status   OUT VARCHAR2
, x_error_Tbl       OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Validates measure
PROCEDURE Validate_Application
( p_api_version     IN  NUMBER
, p_Application_Rec IN  BIS_Application_PVT.Application_Rec_Type
, x_return_status   OUT VARCHAR2
, x_error_Tbl       OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- Value - ID conversion
PROCEDURE Value_ID_Conversion
( p_api_version     IN  NUMBER
, p_Application_Rec IN  BIS_Application_PVT.Application_Rec_Type
, x_Application_Rec OUT BIS_Application_PVT.Application_Rec_Type
, x_return_status   OUT VARCHAR2
, x_error_Tbl       OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Value_ID_Conversion
( p_api_version            IN  NUMBER
, p_Application_Short_Name IN  VARCHAR2
, p_Application_Name       IN  VARCHAR2
, x_Application_ID         OUT NUMBER
, x_return_status          OUT VARCHAR2
, x_error_Tbl              OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
END BIS_Application_PVT;

 

/
