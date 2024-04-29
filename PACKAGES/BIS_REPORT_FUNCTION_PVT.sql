--------------------------------------------------------
--  DDL for Package BIS_REPORT_FUNCTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_REPORT_FUNCTION_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVRPFS.pls 115.2 99/09/19 11:20:41 porting ship  $ */

-- Data Types: Records

TYPE Report_Function_Rec_Type IS RECORD (
  Report_Function_ID            NUMBER := FND_API.G_MISS_NUM,
  Report_Function_Name          VARCHAR2(30) := FND_API.G_MISS_CHAR,
  Report_USER_Function_Name     VARCHAR2(80) := FND_API.G_MISS_CHAR);


-- Data Types: Tables

TYPE Report_Function_Tbl_Type IS TABLE of Report_Function_Rec_Type
        INDEX BY BINARY_INTEGER;


G_MISS_COMPUTED_TAR_REC      Report_Function_Rec_Type;

PROCEDURE Retrieve_Report_Functions
( p_api_version          IN  number
, x_Report_Function_Tbl  out Report_Function_Tbl_Type
, x_return_status        OUT VARCHAR2
, x_error_tbl            OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_Report_Function_Id
( p_api_version           IN  NUMBER
, p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Report_Function_ID    IN  NUMBER
, x_return_status         OUT VARCHAR2
, x_error_Tbl             OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Value_ID_Conversion
( p_api_version                IN  NUMBER
, p_Report_Function_Name       IN  VARCHAR2
, p_Report_User_Function_Name  IN  VARCHAR2
, x_Report_Function_ID         OUT NUMBER
, x_return_status              OUT VARCHAR2
, x_error_Tbl                  OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
END BIS_Report_Function_PVT;

 

/
