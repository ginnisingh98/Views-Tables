--------------------------------------------------------
--  DDL for Package AHL_PRD_LOV_SERVICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_LOV_SERVICE_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVLOVS.pls 120.0.12010000.1 2008/11/30 21:15:09 sikumar noship $ */
-----------------------------------------------------------
-- PACKAGE
-- AHL_PRD_LOV_SERVICE_PVT
--
-- PURPOSE
--    This package is a Private API for providing web services
--    to return LOV search results for LOVs on production UI

--    Call_LOV_Services (see below for specification)
--
--
-- NOTES
--
--
-- HISTORY
--
--  Created By Yan Zhou 15-Sept-2006
--
-----------------------------------------------------------

-------------------------------------
-- Input: Search Criteria Rec Type
-------------------------------------

TYPE LovCriteria_Rec_Type IS RECORD (
  AttributeName       VARCHAR2(80)                 := NULL,
  AttributeValue      VARCHAR2(2000)               := NULL
);

-- Declare Search Criteria table type for record
TYPE LovCriteria_Tbl_Type IS TABLE OF LovCriteria_Rec_Type
INDEX BY BINARY_INTEGER;

-------------------------------------
-- Input: LOV Input Rec Type
-------------------------------------
TYPE LOV_Input_Rec_Type IS RECORD (
  lovID               VARCHAR2(80)                 := NULL,
  getMetaData         VARCHAR2(1)                  := 'F',
  getResults          VARCHAR2(1)                  := 'F',
  StartRow            NUMBER                       := 1,
  NumberOfRows        NUMBER                       := 9999,   -- For dropdown list box, all rows should be retrieved
  LovCriteriaTbl      LovCriteria_Tbl_Type
);



-------------------------------------
-- Output: Meta Data Rec Type
-------------------------------------

TYPE LovMetaAttribute_Rec_Type IS RECORD (
  AttributeName       VARCHAR2(80)                 := NULL,
  Prompt              VARCHAR2(40)                 := NULL,
  IsDisplayed         VARCHAR2(1)                  := 'F',
  IsSearcheable       VARCHAR2(1)                  := 'F',
  DataType            VARCHAR2(30)                 := NULL
);

-- Declare Meta Data table type for record
TYPE LovMetaAttribute_Tbl_Type IS TABLE OF LovMetaAttribute_Rec_Type
INDEX BY BINARY_INTEGER;

-------------------------------------
-- Output: LOV Meta Data Output Rec Type
-------------------------------------
TYPE LovMetaData_Rec_Type IS RECORD (
  LovTitle               VARCHAR2(80)                      := NULL,
  LovMetaAttributeTbl    LovMetaAttribute_Tbl_Type
);

-------------------------------------
-- Output: Search Results Attribute Rec Type
-------------------------------------

TYPE LovResultAttribute_Rec_Type IS RECORD (
  AttributeName       VARCHAR2(80)                 := NULL,
  AttributeValue      VARCHAR2(2000)               := NULL
);

-- Declare Search Results Attribute table type for record
TYPE LovResultAttribute_Tbl_Type IS TABLE OF LovResultAttribute_Rec_Type
INDEX BY BINARY_INTEGER;

-------------------------------------
-- Output: Search Results Table Type
-------------------------------------

-- Declare Search Results table type for record
TYPE LovResult_Tbl_Type IS TABLE OF LovResultAttribute_Tbl_Type
INDEX BY BINARY_INTEGER;

-------------------------------------
-- Output: LOV Output Rec Type
-------------------------------------
TYPE LovOutput_Rec_Type IS RECORD (
  StartRow               NUMBER                            := NULL,
  NumberOfRows           NUMBER                            := NULL,
  LovResultTbl           LovResult_Tbl_Type
);


---------------------------------------------------------------------
-- PROCEDURE
-- Call_LOV_Services
--
-- PURPOSE
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------

PROCEDURE Call_LOV_Services (
   p_api_version              IN  NUMBER    :=1.0,
   p_init_msg_list            IN  VARCHAR2  :=Fnd_Api.g_false,
   p_commit                   IN  VARCHAR2  :=Fnd_Api.g_false,
   p_validation_level         IN  NUMBER    :=Fnd_Api.g_valid_level_full,
   p_module_type              IN  VARCHAR2  :=null,
   p_userid                   IN  VARCHAR2   := NULL,
   p_lov_input_rec            IN  LOV_Input_Rec_Type,
   x_lov_result_output_rec    OUT NOCOPY LovOutput_Rec_Type,
   x_lov_meta_output_rec      OUT NOCOPY LovMetaData_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2
);

END AHL_PRD_LOV_SERVICE_PVT;


/
