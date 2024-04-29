--------------------------------------------------------
--  DDL for Package BIS_ACTUAL_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_ACTUAL_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVAVVS.pls 115.7 2002/12/16 10:24:46 rchandra ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVAVVS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for validating items in the ACTUALs record
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
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
/*PROCEDURE Validate_Time_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Validate_Org_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
*/
PROCEDURE Validate_Dim1_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Validate_Dim2_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Validate_Dim3_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Validate_Dim4_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Validate_Dim5_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Validate_Dim6_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Validate_Dim7_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Validate_ACTUAL_Value
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Validate_Record
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
END BIS_ACTUAL_VALIDATE_PVT;

 

/
