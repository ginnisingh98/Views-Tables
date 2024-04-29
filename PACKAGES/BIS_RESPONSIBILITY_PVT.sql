--------------------------------------------------------
--  DDL for Package BIS_RESPONSIBILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_RESPONSIBILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVRSPS.pls 120.0 2005/06/01 15:36:19 appldev noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVRSPS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for managing Responsibilities for PMF
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 15-MAR-99 Ansingha Creation
REM | 19-MAY-2005  visuri   GSCC Issues bug 4363854                         |
REM +=======================================================================+
*/
--
G_WF_ROLE_AK_REGION     CONSTANT VARCHAR2(200) := 'BIS_WF_ROLE';
G_WF_ROLE_SHORT_NAME_AK CONSTANT VARCHAR2(200) := 'P_ROLE_SHORT_NAME';
G_WF_ROLE_NAME_AK       CONSTANT VARCHAR2(200) := 'P_ROLE_DISPLAY_NAME';

--
TYPE Responsibility_Rec_Type IS RECORD (
  Responsibility_ID            NUMBER := BIS_COMMON_UTILS.G_DEF_NUM
, Responsibility_Short_Name    VARCHAR2(30) := BIS_COMMON_UTILS.G_DEF_CHAR
, Responsibility_Name          VARCHAR2(100) := BIS_COMMON_UTILS.G_DEF_CHAR

);

TYPE Responsibility_Tbl_Type IS TABLE of Responsibility_Rec_Type
        INDEX BY BINARY_INTEGER;
--
TYPE Notify_Responsibility_Rec_Type IS RECORD (
  Notify_Responsibility_ID  NUMBER := BIS_COMMON_UTILS.G_DEF_NUM
, Notify_Resp_Short_Name    VARCHAR2(100) := BIS_COMMON_UTILS.G_DEF_CHAR
, Notify_Resp_Name          VARCHAR2(240) := BIS_COMMON_UTILS.G_DEF_CHAR
);
--
--
TYPE Notify_Responsibility_Tbl_Type IS TABLE of Notify_Responsibility_Rec_Type

        INDEX BY BINARY_INTEGER;
--
-- PROCEDUREs
-- Will retrieve web responsibilities only
Procedure Retrieve_User_Responsibilities
( p_api_version         IN NUMBER
, p_user_id             IN NUMBER Default BIS_COMMON_UTILS.G_DEF_NUM
, x_Responsibility_Tbl  OUT NOCOPY BIS_Responsibility_PVT.Responsibility_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_tbl_Type
);
--
-- PROCEDUREs
-- Will retrieve responsibilities of the given version
Procedure Retrieve_User_Responsibilities
( p_api_version            IN NUMBER
, p_user_id                IN NUMBER Default BIS_COMMON_UTILS.G_DEF_NUM
, p_Responsibility_version IN VARCHAR
, x_Responsibility_Tbl     OUT NOCOPY BIS_Responsibility_PVT.Responsibility_Tbl_Type
, x_return_status          OUT NOCOPY VARCHAR2
, x_error_tbl              OUT NOCOPY BIS_UTILITIES_PUB.Error_tbl_Type
);
--
--
-- PROCEDUREs
-- Will retrieve web responsibilities only
Procedure Retrieve_All_Responsibilities
( p_api_version         IN NUMBER
, x_Responsibility_Tbl  OUT NOCOPY BIS_Responsibility_PVT.Responsibility_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_tbl_Type
);
--
-- PROCEDUREs
-- Will retrieve web responsibilities only
Procedure Retrieve_Responsibility
( p_api_version         IN NUMBER
, p_Responsibility_Rec  IN  BIS_Responsibility_PVT.Responsibility_rec_Type
, x_Responsibility_Rec  OUT NOCOPY BIS_Responsibility_PVT.Responsibility_rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_tbl_Type
);
--
-- WE NEED TO PASS IN THE ID ISTEAD OF TARGET_LEVEL_REC SO THAT WE
-- DO NOT HAVE CROSSREFRENCES. THAT HANGS THE DATABASE
PROCEDURE Validate_Def_Notify_Resp_Id
( p_api_version        IN  NUMBER
, p_validation_level   IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Def_Notify_Resp_Id IN  NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
, x_error_Tbl          OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Retrieve_Notify_Resp_Name
( p_api_version            IN  NUMBER
, p_Notify_resp_short_name IN  VARCHAR2
, x_Notify_resp_name       OUT NOCOPY VARCHAR2
, x_return_status          OUT NOCOPY VARCHAR2
, x_error_Tbl              OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type

);
--
PROCEDURE Validate_Notify_Resp_ID
( p_api_version           IN  NUMBER
, p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Notify_Resp_ID        IN  NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
, x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Value_ID_Conversion
( p_api_version                IN  NUMBER
, p_Responsibility_Short_Name IN  VARCHAR2

, p_Responsibility_Name       IN  VARCHAR2
, x_Responsibility_ID         OUT NOCOPY NUMBER
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE DFR_Value_ID_Conversion
( p_api_version                  IN  NUMBER
, p_DF_Responsibility_Short_Name IN  VARCHAR2
, p_DF_Responsibility_Name       IN  VARCHAR2
, x_DF_Responsibility_ID         OUT NOCOPY NUMBER
, x_return_status                OUT NOCOPY VARCHAR2
, x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type

);
--
-- removes the responsibilities from p_all_security
-- which are in p_security
PROCEDURE RemoveDuplicates
( p_security     in  BIS_Responsibility_PVT.Responsibility_Tbl_type
, p_all_security in  BIS_Responsibility_PVT.Responsibility_Tbl_type
, x_all_security out NOCOPY BIS_Responsibility_PVT.Responsibility_Tbl_type
);
--
--
Procedure Get_Notify_Resp_AK_Info
( p_notify_responsibility_rec
    IN BIS_Responsibility_PVT.Notify_Responsibility_Rec_type
, x_attribute_app_id    OUT NOCOPY NUMBER
, x_attribute_code      OUT NOCOPY VARCHAR2
, x_attribute_name      OUT NOCOPY VARCHAR2
, x_region_app_id       OUT NOCOPY NUMBER
, x_region_code         OUT NOCOPY VARCHAR2
);
--
--
END BIS_RESPONSIBILITY_PVT;

 

/
