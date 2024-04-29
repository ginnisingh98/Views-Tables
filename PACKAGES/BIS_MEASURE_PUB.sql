--------------------------------------------------------
--  DDL for Package BIS_MEASURE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_MEASURE_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPMEAS.pls 120.0 2005/06/01 18:24:19 appldev noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPMEAS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for creating and managing Performance Measurements
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 28-NOV-98 irchen Creation
REM | 15-NOV-2001     Fix for 1850860     MAHRAO
REM | 26-JUL-2002 rchandra  Fixed for enh 2440739                           |
REM | 23-APR-2003 mdamle    PMD - Measure Definer Support               |
REM | 24-JUN-2003 rchandra  leap frog PMD Changes  to verssion 115.25       |
REM | 24-JUN-2003 rchandra  leap frog to verssion 115.26 which has the      |
REM |                         attribute for dataset_id in Measure_Rec_Type  |
REM |                         for bug 3004651                               |
REM | 26-JUN-03 RCHANDRA  do away with hard coded length for name and       |
REM |                      description for bug 2910316                      |
REM |                      for dimension and dimension levels               |
REM | 25-JUL-03 mahrao    As following procedures are referred from BSCPBMSB.pls,|
REM |                     they are removed from BISPMEASB.pls.              |
REM | 25-SEP-03 mdamle    Bug#3160325 - Sync up measures for all installed  |
REM |                     languages                     |
REM | 29-SEP-2003 adrao  Bug#3160325 - Sync up measures for all installed   |
REM |                    source languages                                   |
REM | 05-NOV-2003 smargand Adding a new column enabled to the record type   |
REM | 08-APR-2004 ankgoel  Modified for bug#3557236			    |
REM | 27-JUL-2004 sawu    Modified create/update measure api to take a      |
REM |                     default p_owner parameter                         |
REM | 01-SEP-2004 sawu    Added region, source/compare column app id to     |
REM |                     Measure_Rec_Type                                  |
REM | 29-SEP-2004 ankgoel Added WHO columns in Rec for Bug#3891748          |
REM | 27-Dec-2004 rpenneru  Added Func_Area_Short_Name field to Measure_Rec |
REM |                       for enh#4080204                                 |
REM | 29-Jan-2005 vtulasi   Enh#4102897- Increasing buffer size for         |
REM |                       function_name related variables                 |
REM | 21-FEB-2005 ankagarw  modified measure name  and description	    |
REM |			     column length for enh. 3862703                 |
REM | 22-APR-2005 akoduri   Enhancement#3865711 -- Obsolete Seeded Objects  |
REM | 03-MAY-2005  akoduri  Enh #4268374 -- Weighted Average Measures       |
REM +=======================================================================+
*/
--
-- Data Types: Records
--
TYPE Measure_Instance_type IS RECORD
( Measure_ID                    NUMBER
, Measure_Short_Name            VARCHAR2(32000)
, Measure_Name                  VARCHAR2(32000)
, Target_Level_ID               NUMBER
, Target_Level_Short_Name       VARCHAR2(32000)
, Target_Level_Name             VARCHAR2(32000)
, Plan_ID                       NUMBER
, Plan_Short_Name               VARCHAR2(32000)
, Plan_Name                     VARCHAR2(32000)
, Actual_ID                     NUMBER
, Actual                        NUMBER
, Target_ID                     NUMBER
, Target                        NUMBER
, Range1_low                    NUMBER
, Range1_high                   NUMBER
, Range2_low                    NUMBER
, Range2_high                   NUMBER
, Range3_low                    NUMBER
, Range3_high                   NUMBER
, Range1_Owner_ID               NUMBER
, Range1_Owner_Short_Name       VARCHAR2(32000)
, Range1_Owner_Name             VARCHAR2(32000)
, Range2_Owner_ID               NUMBER
, Range2_Owner_Short_Name       VARCHAR2(32000)
, Range2_Owner_Name             VARCHAR2(32000)
, Range3_Owner_ID               NUMBER
, Range3_Owner_Short_Name       VARCHAR2(32000)
, Range3_Owner_Name             VARCHAR2(32000)
);

TYPE Measure_Rec_Type IS RECORD
( Measure_ID                   NUMBER
, Measure_Short_Name           VARCHAR2(30)
, Measure_Name                 bis_indicators_tl.name%TYPE
, Description                  bis_indicators_tl.DESCRIPTION%TYPE
------fix for bug#3859267 -------------
, Region_App_Id                Ak_Region_Items.REGION_APPLICATION_ID%Type
, Source_Column_App_Id         Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type
, Compare_Column_App_Id        Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type
------fix for 1850860 starts here------
, Actual_Data_Source_Type      VARCHAR2(30)
, Actual_Data_Source           VARCHAR2(240)
, Function_Name                FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE
, Comparison_Source            VARCHAR2(240)
, Increase_In_Measure          VARCHAR2(1)
------fix for 1850860 ends here--------
, Enable_Link                  VARCHAR2(1)   -- 2440739
------enhancement #3031053 start --------
, Enabled                      VARCHAR2(1)  := FND_API.G_TRUE  -- 2440739
------enhancement #3031053 end --------
------Enhancement 3865711--------------
, Obsolete                     VARCHAR2(1)  := FND_API.G_FALSE
------Enhancement 4268374--------------
, Measure_Type                 VARCHAR2(30)
, Dimension1_ID                NUMBER
, Dimension1_Short_Name        VARCHAR2(30)
, Dimension1_Name              bis_dimensions_tl.name%TYPE
, Dimension2_ID                NUMBER
, Dimension2_Short_Name        VARCHAR2(30)
, Dimension2_Name              bis_dimensions_tl.name%TYPE
, Dimension3_ID                NUMBER
, Dimension3_Short_Name        VARCHAR2(30)
, Dimension3_Name              bis_dimensions_tl.name%TYPE
, Dimension4_ID                NUMBER
, Dimension4_Short_Name        VARCHAR2(30)
, Dimension4_Name              bis_dimensions_tl.name%TYPE
, Dimension5_ID                NUMBER
, Dimension5_Short_Name        VARCHAR2(30)
, Dimension5_Name              bis_dimensions_tl.name%TYPE
, Dimension6_ID                NUMBER
, Dimension6_Short_Name        VARCHAR2(30)
, Dimension6_Name              bis_dimensions_tl.name%TYPE
, Dimension7_ID                NUMBER
, Dimension7_Short_Name        VARCHAR2(30)
, Dimension7_Name              bis_dimensions_tl.name%TYPE
, Unit_Of_Measure_Class        VARCHAR2(10)
, Application_Id               NUMBER       := -1                  --2465354
-- mdamle 04/23/2003 - PMD - Measure Definer - link to BSC tables
, dataset_id                   NUMBER
-- ankgoel: bug#3557236 - Required to be FALSE for ldt file upload
, is_validate 		       VARCHAR2(1) := FND_API.G_TRUE
-- rpenneru bug#4073262 -
, Func_Area_Short_Name         VARCHAR2(30)
-- ankgoel: bug#3891748
, Created_By                    BIS_INDICATORS.CREATED_BY%TYPE
, Creation_Date                 BIS_INDICATORS.CREATION_DATE%TYPE
, Last_Updated_By               BIS_INDICATORS.LAST_UPDATED_BY%TYPE
, Last_Update_Date              BIS_INDICATORS.LAST_UPDATE_DATE%TYPE
, Last_Update_Login             BIS_INDICATORS.LAST_UPDATE_LOGIN%TYPE
);
--
TYPE UOM_Class_Rec_Type IS RECORD (
  UOM_Class               VARCHAR2(10));
--
--
TYPE Rule_Set_Rec_Type is RECORD (
  Rule    VARCHAR2(2000) );
--
--
-- Data Types: Tables
--
TYPE Measure_Tbl_Type IS TABLE of Measure_Rec_Type
        INDEX BY BINARY_INTEGER;
--
TYPE UOM_Class_Tbl_Type IS TABLE of UOM_Class_Rec_Type
        INDEX BY BINARY_INTEGER;
--
TYPE Rule_Set_Tbl_Type is TABLE of Rule_Set_Rec_Type
        INDEX BY BINARY_INTEGER;
--
--
-- Global Missing Composite Types
--
G_MISS_MEASURE_REC       Measure_Rec_Type;
G_MISS_UOM_CLASS_REC     UOM_Class_Rec_Type;
--
G_MISS_MEASURE_TBL       Measure_Tbl_Type;
G_MISS_UOM_CLASS_Tbl     UOM_Class_Tbl_Type;
--
--
-- PROCEDUREs
--
-- creates one Measure, with the dimensions sequenced in the order
-- they are passed in
PROCEDURE Create_Measure
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_Rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner            IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- Gets All Performance Measures
-- If information about the dimensions are not required, set all_info to
-- FALSE
PROCEDURE Retrieve_Measures
( p_api_version   IN  NUMBER
, p_all_info      IN  VARCHAR2   := FND_API.G_TRUE
, x_Measure_tbl   OUT NOCOPY BIS_MEASURE_PUB.Measure_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- Gets Information for One Performance Measure
-- If information about the dimension are not required, set all_info to FALSE.
PROCEDURE Retrieve_Measure
( p_api_version   IN  NUMBER
, p_Measure_Rec   IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_all_info      IN  VARCHAR2   := FND_API.G_TRUE
, x_Measure_Rec   IN OUT NOCOPY BIS_MEASURE_PUB.Measure_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- PLEASE VERIFY COMMENT BELOW
-- Update_Measures one Measure if
--   1) no Measure levels or targets exist
--   2) no users have selected to see actuals for the Measure
PROCEDURE Update_Measure
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_Rec   IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner            IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- PLEASE VERIFY COMMENT BELOW
-- deletes one Measure if
-- 1) no Measure levels, targets exist and
-- 2) the Measure access has not been granted to a resonsibility
-- 3) no users have selected to see actuals for the Measure
PROCEDURE Delete_Measure
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_Rec   IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Validates measure
PROCEDURE Validate_Measure
( p_api_version     IN  NUMBER
, p_Measure_Rec     IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Retrieve_Measure_Dimensions
( p_api_version   IN  NUMBER
, p_Measure_Rec   IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_dimension_Tbl OUT NOCOPY BIS_DIMENSION_PUB.Dimension_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
Procedure Translate_Measure
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec       IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_OWNER             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Load_Measure
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec       IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_OWNER             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--
--Overload Load_Measure so that old data model ldts can be uploaded using
--The latest lct file. The lct file can call this overloaded procedure
--by passing in Org and Time dimension short_names also
Procedure Load_Measure
( p_api_version               IN  NUMBER
, p_commit                    IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level          IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec               IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_OWNER                     IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, p_Org_Dimension_Short_Name  IN  VARCHAR2
, p_Time_Dimension_Short_Name IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--

-- Given a performance measure short name update the
--  bis_indicators, bis_indicators_tl and  bis_indicator_dimensions
-- for last_updated_by , created_by as 1
PROCEDURE updt_pm_owner(p_pm_short_name  IN VARCHAR2
                       ,x_return_status OUT NOCOPY VARCHAR2);


-- mdamle 09/25/2003 - Sync up measures for all installed languages
Procedure Translate_Measure_By_lang
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2 := FND_API.G_FALSE
, p_Measure_Rec       IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, p_lang              IN  VARCHAR2
, p_source_lang       IN  VARCHAR2
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--=============================================================================
--added new function to determine whether the given indicator is customized

FUNCTION GET_CUSTOMIZED_ENABLED
( p_indicator_id IN NUMBER
)
RETURN VARCHAR2;




END BIS_MEASURE_PUB;

 

/
