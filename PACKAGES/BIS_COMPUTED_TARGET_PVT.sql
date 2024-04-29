--------------------------------------------------------
--  DDL for Package BIS_COMPUTED_TARGET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_COMPUTED_TARGET_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVCTVS.pls 120.0 2005/05/31 18:08:32 appldev noship $ */

-- Data Types: Records

TYPE Computed_Target_Rec_Type IS RECORD (
  Computed_Target_ID             NUMBER ,
  Computed_Target_Short_Name     FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE,
  Computed_Target_Name           VARCHAR2(80) );


-- Data Types: Tables

TYPE Computed_Target_Tbl_Type IS TABLE of Computed_Target_Rec_Type
        INDEX BY BINARY_INTEGER;


G_MISS_COMPUTED_TAR_REC      Computed_Target_Rec_Type;

PROCEDURE Retrieve_Computed_Targets
( p_api_version          IN  number
, x_Computed_Target_Tbl  out NOCOPY Computed_Target_Tbl_Type
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_Computed_Target_Id
( p_api_version           IN  NUMBER
, p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Computed_Target_ID    IN  NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
, x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Value_ID_Conversion
( p_api_version                IN  NUMBER
, p_Computed_Target_Short_Name IN  VARCHAR2
, p_Computed_Target_Name       IN  VARCHAR2
, x_Computed_Target_ID         OUT NOCOPY NUMBER
, x_return_status              OUT NOCOPY VARCHAR2
, x_error_Tbl                  OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
END BIS_COMPUTED_TARGET_PVT;

 

/
