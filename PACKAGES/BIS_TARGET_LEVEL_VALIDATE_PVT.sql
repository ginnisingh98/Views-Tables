--------------------------------------------------------
--  DDL for Package BIS_TARGET_LEVEL_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_TARGET_LEVEL_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVTLVS.pls 115.12 2002/12/16 10:27:20 rchandra ship $ */
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
PROCEDURE Validate_org_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Validate_time_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Validate_Dimension1_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_Dimension2_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_Dimension3_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_Dimension4_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_Dimension5_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_Dimension6_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_Dimension7_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_WF_Process_Short_Name
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_Def_Notify_Resp_Id
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_Df_computed_target_Id
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
END BIS_TARGET_LEVEL_VALIDATE_PVT;

 

/
