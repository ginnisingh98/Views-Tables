--------------------------------------------------------
--  DDL for Package BIS_MEASURE_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_MEASURE_SECURITY_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVMSES.pls 115.26 2003/12/01 08:39:25 gramasam ship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVMSES.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for creating and managing Performance Measurements
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 28-NOV-98 irchen Creation    											|
REM | Sep-2000  JPRABHUD Added new procedure Retrieve_Measure_Sec_Sorted    |
REM | 25-NOV-03 gramasam Included a new procedure for deleting 				|
REM |			responsibilities at target level							|
REM +=======================================================================+
*/
--
--
-- creates one Measure_Security, with the dimensions sequenced in the order
-- they are passed in
Procedure Create_Measure_Security
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,p_Measure_Security_Rec IN BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type
, p_owner            IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER --2465354
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- Gets All Performance Measure_Securitys
-- If information about the dimensions are not required, set all_info to
-- FALSE
--
PROCEDURE Retrieve_Measure_Securities
( p_api_version   IN  NUMBER
, p_Target_Level_Rec IN BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_Measure_Security_tbl OUT NOCOPY BIS_MEASURE_SECURITY_PUB.Measure_Security_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- added this procedure
-- Gets All Performance Measure_Securities in a sorted order
-- If information about the dimensions are not required, set all_info to
-- FALSE
--
PROCEDURE Retrieve_Measure_Sec_Sorted
( p_api_version   IN  NUMBER
, p_Target_Level_Rec IN BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_Measure_Security_tbl OUT NOCOPY BIS_MEASURE_SECURITY_PUB.Measure_Security_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
-- Gets Information for One Performance Measure_Security
-- If information about the dimension are not required, set all_info to FALSE.
--
--
PROCEDURE Retrieve_Measure_Security
( p_api_version   IN  NUMBER
, p_Measure_Security_Rec   IN  BIS_Measure_SECURITY_PUB.Measure_Security_Rec_Type
, x_Measure_Security_Rec   OUT NOCOPY  BIS_Measure_SECURITY_PUB.Measure_Security_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Update_Measure_Security
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Security_Rec IN BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- PLEASE VERIFY COMMENT BELOW
-- Deletes ALL responsibilities associated with a target level
Procedure Delete_Measure_Security
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Delete_Measure_Security
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2   := FND_API.G_FALSE
,p_Measure_Security_Rec IN BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Validates Measure_Security
PROCEDURE Validate_Measure_Security
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,p_Measure_Security_Rec IN BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Value - ID conversion
PROCEDURE Value_ID_Conversion
( p_api_version     IN  NUMBER
, p_Measure_Security_Rec IN BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type
, x_Measure_Security_Rec OUT NOCOPY BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- This procedure retrieves the responsibility which the user has AND
-- has access to this indicator level
Procedure Retrieve_Tar_Level_User_Resps
( p_api_version           IN NUMBER
, p_user_id               IN NUMBER
, p_Target_Level_Rec      IN BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_Measure_security_Tbl OUT NOCOPY BIS_MEASURE_SECURITY_PUB.Measure_Security_Tbl_Type
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

-- new API to validate Measure Security for bug 1716213
-- Validates Measure_Security
PROCEDURE Validate_Measure_Security
( p_api_version      IN  NUMBER
, p_user_id         IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Security_Rec IN BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

-- new API to delete the responsibilities attached to the target levels
-- pertaining to the measure specified by the measure short name
PROCEDURE Delete_TargetLevel_Resp
( p_commit 				IN VARCHAR2		:= FND_API.G_FALSE
, p_measure_short_name	IN VARCHAR2
, x_return_status		OUT NOCOPY VARCHAR2
, x_error_Tbl			OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

END BIS_MEASURE_SECURITY_PVT;

 

/
