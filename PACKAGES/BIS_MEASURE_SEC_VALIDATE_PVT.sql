--------------------------------------------------------
--  DDL for Package BIS_MEASURE_SEC_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_MEASURE_SEC_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVMSVS.pls 115.4 99/09/19 11:20:33 porting ship  $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVTVLS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for validating items in the MEASUREs record
REM | NOTES                                                                 |
REM |                                                                       |
REM |
REM +=======================================================================+
*/
--
--
--
PROCEDURE Validate_Target_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_SEC_Rec  IN  BIS_MEASURE_SECURITY_PUB.MEASURE_Security_Rec_Type
, x_return_status    OUT VARCHAR2
, x_error_Tbl        OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_Responsibility_Id
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_SEC_Rec  IN  BIS_MEASURE_SECURITY_PUB.MEASURE_Security_Rec_Type
, x_return_status    OUT VARCHAR2
, x_error_Tbl        OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_Record
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_SEC_Rec  IN  BIS_MEASURE_SECURITY_PUB.MEASURE_Security_Rec_Type
, x_return_status    OUT VARCHAR2
, x_error_Tbl        OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
END BIS_MEASURE_SEC_VALIDATE_PVT;

 

/
