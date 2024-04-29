--------------------------------------------------------
--  DDL for Package BIS_MEASURE_SECURITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_MEASURE_SECURITY_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPMSES.pls 115.27 2003/12/01 08:34:38 gramasam noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPMSES.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for creating and managing Performance Measurements
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 28-NOV-98 irchen Creation
REM |
REM +=======================================================================+
*/
--
-- Data Types: Records
--
TYPE Measure_Security_Rec_Type IS RECORD (
  Target_Level_ID           NUMBER ,
  Target_Level_Short_Name   VARCHAR2(80) ,
  Target_Level_Name         VARCHAR2(80) ,
  Responsibility_ID            NUMBER ,
  Responsibility_Short_Name    VARCHAR2(30) ,
  Responsibility_Name          VARCHAR2(100) );


-- Data Types: Tables

TYPE Measure_Security_Tbl_Type is TABLE of Measure_Security_Rec_Type
        INDEX BY BINARY_INTEGER;

-- Global Missing Composite Types

G_MISS_MEAS_SECURITY_REC  Measure_Security_Rec_Type;
G_MISS_MEAS_SECURITY_TBL  Measure_Security_Tbl_Type;

-- PROCEDUREs
--
-- creates one Measure, with the dimensions sequenced in the order
-- they are passed in
PROCEDURE Create_Measure_Security
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
,p_Measure_Security_Rec IN BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
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
--
-- PLEASE VERIFY COMMENT BELOW
-- Update_Measure_Securitys one Measure if
--   1) no Measure levels or targets exist
--   2) no users have selected to see actuals for the Measure
PROCEDURE Update_Measure_Security
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
,p_Measure_Security_Rec IN BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- PLEASE VERIFY COMMENT BELOW
-- deletes one Measure if
-- 1) no Measure levels, targets exist and
-- 2) the Measure access has not been granted to a resonsibility
-- 3) no users have selected to see actuals for the Measure
PROCEDURE Delete_Measure_Security
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2   := FND_API.G_FALSE
,p_Measure_Security_Rec IN BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Validates measure
PROCEDURE Validate_Measure_Security
( p_api_version     IN  NUMBER
,p_Measure_Security_Rec IN BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--

-- new API to validate Measure Security for bug 1716213
-- Validates measure securtity
PROCEDURE Validate_Measure_Security
( p_api_version     IN  NUMBER
, p_user_id         IN  NUMBER
, p_Measure_Security_Rec IN BIS_MEASURE_SECURITY_PUB.Measure_Security_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- new API to delete the responsibilities attached to the target levels
-- pertaining to the measure specified by the measure short name
PROCEDURE Delete_TargetLevel_Resp
( p_commit 				IN  VARCHAR2 	:= FND_API.G_FALSE
, p_measure_short_name	IN  VARCHAR2
, x_return_status   	OUT NOCOPY VARCHAR2
, x_error_Tbl			OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


END BIS_MEASURE_SECURITY_PUB;

 

/
