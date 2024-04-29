--------------------------------------------------------
--  DDL for Package BIS_APPLICATION_MEASURE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_APPLICATION_MEASURE_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVAPMS.pls 120.0 2005/06/01 17:32:43 appldev noship $ */
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
REM | 20-JAN-2003 rchandra fixed gscc warnings for Incorrect beginning
REM |                       and ending of the file
REM | 26-JUN-2003 rchandra  added dataset_id to Application_Measure_Rec_Type|
REM |                       record for bug 3004651                          |
REM | 29-SEP-2004 ankgoel   Added WHO columns in Rec for Bug#3891748        |
REM | 01-JUN-2005 akoduri   Modified for Bug #4397786                       |
REM +=======================================================================+
*/
--
-- Data Types: Records
--
TYPE Application_Measure_Rec_Type IS RECORD (
  Application_ID           NUMBER ,
  Application_Short_Name   VARCHAR2(30) ,
  Application_Name         VARCHAR2(80) ,
  Measure_ID               NUMBER ,
  Measure_Short_Name       VARCHAR2(30) ,
  Measure_Name             VARCHAR2(100) ,
  Owning_Application       VARCHAR2(1)   ,
  Dataset_ID               bis_indicators.dataset_id%TYPE
  -- ankgoel: bug#3891748
, Created_By               BIS_APPLICATION_MEASURES.CREATED_BY%TYPE
, Creation_Date            BIS_APPLICATION_MEASURES.CREATION_DATE%TYPE
, Last_Updated_By          BIS_APPLICATION_MEASURES.LAST_UPDATED_BY%TYPE
, Last_Update_Date         BIS_APPLICATION_MEASURES.LAST_UPDATE_DATE%TYPE
, Last_Update_Login        BIS_APPLICATION_MEASURES.LAST_UPDATE_LOGIN%TYPE
);

-- Data Types: Tables

TYPE Application_Measure_Tbl_Type is TABLE of Application_Measure_Rec_Type
        INDEX BY BINARY_INTEGER;

-- Global Missing Composite Types

G_MISS_MEAS_SECURITY_REC  Application_Measure_Rec_Type;
G_MISS_MEAS_SECURITY_TBL  Application_Measure_Tbl_Type;

-- PROCEDUREs

--
-- creates one Measure, with the dimensions sequenced in the order
--
PROCEDURE Create_Application_Measure
( p_api_version             IN  NUMBER
, p_commit                  IN  VARCHAR2   := FND_API.G_FALSE
, p_Application_Measure_Rec IN
                      BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, x_return_status           OUT NOCOPY VARCHAR2
, x_error_Tbl               OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- creates one Measure for the given owner,
--
PROCEDURE Create_Application_Measure
( p_api_version             IN  NUMBER
, p_commit                  IN  VARCHAR2   DEFAULT FND_API.G_FALSE
, p_Application_Measure_Rec IN
                      BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, p_owner                   IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_error_Tbl               OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Retrieve_Application_Measures
( p_api_version             IN  NUMBER
, p_Measure_Rec            IN BIS_Measure_PUB.Measure_Rec_Type
, p_all_info                IN VARCHAR2
, x_Application_Measure_tbl OUT NOCOPY
                      BIS_Application_Measure_PVT.Application_Measure_Tbl_Type
, x_return_status           OUT NOCOPY VARCHAR2
, x_error_Tbl               OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Update_Application_Measure
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Application_Measure_Rec IN
                       BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Update_Application_Measure
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_Short_Name IN   BIS_INDICATORS.SHORT_NAME%TYPE
, p_Application_Id   IN  BIS_APPLICATION_MEASURES.APPLICATION_ID%TYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
);
--
--
PROCEDURE Update_Application_Measure
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Application_Measure_Rec IN
                       BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, p_owner            IN  VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Delete_Application_Measure
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2   := FND_API.G_FALSE
, p_Application_Measure_Rec IN
                       BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Validates measure
PROCEDURE Validate_Application_Measure
( p_api_version     IN  NUMBER
,p_Application_Measure_Rec IN
                       BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- Value - ID conversion
PROCEDURE Value_ID_Conversion
( p_api_version     IN  NUMBER
, p_Application_Measure_Rec IN
                       BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, x_Application_Measure_Rec IN OUT NOCOPY
                       BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Retrieve_Last_Update_Date
( p_api_version      IN  NUMBER
, p_Application_Measure_Rec IN
                       BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, x_last_update_date OUT NOCOPY DATE
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Lock_Record
( p_api_version   IN  NUMBER
, p_Application_Measure_Rec IN
                       BIS_Application_Measure_PVT.Application_Measure_Rec_Type
, p_timestamp     IN  VARCHAR  := NULL
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
END BIS_Application_Measure_PVT;

 

/
