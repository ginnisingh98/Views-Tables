--------------------------------------------------------
--  DDL for Package BIS_MEASURE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_MEASURE_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVMEAS.pls 120.0 2005/06/01 16:19:49 appldev noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVMEAS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for creating and managing Performance Measurements
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 28-NOV-98 irchen Creation
REM | 16-JAN-2002 rchandra added new procedure for updating ownership of the given performance measure
REM | 30-JAN-03 sugopal FND_API.G_MISS_xxx should not be used in            |
REM |                   initialization or declaration (bug#2774644)         |
REM | 25-SEP-2003 mdamle Bug#3160325 - Sync up measures for all installed   |
REM |                    languages                      |
REM | 29-SEP-2003 adrao  Bug#3160325 - Sync up measures for all installed   |
REM |                    source languages                                   |
REM | 12-NOV-2003 smargand  Added new function to determine whether the     |
REM |                       given indicator is customized                   |
REM | 27-JUL-2004 sawu   Modified create/update applicaiton measure and     |
REM |                    indicator dimensions api to take p_owner           |
REM | 22-APR-2005 akoduri   Enhancement#3865711 -- Obsolete Seeded Objects  |
REM | 16-MAY-2005 jxyu   Expose Function Get_Measure_Id_From_Short_Name     |
REM +=======================================================================+
*/
--
--
-- creates one Measure, with the dimensions sequenced in the order
-- they are passed in
--- redundant because of defaults in next overloaded signature
--  Procedure Create_Measure
--( p_api_version      IN  NUMBER
--, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
--, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
--, p_Measure_Rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
--, x_return_status    OUT NOCOPY VARCHAR2
--, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
--);
----
---- creates one Measure for the given owner,
-- with the dimensions sequenced in the order they are passed in
Procedure Create_Measure
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner            IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
--Overload Create_Measure so that old data model ldts can be uploaded using
--The latest lct file. The lct file can call Load_Measure which calls this
--by passing in Org and Time dimension short_names also
Procedure Create_Measure
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec       IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, p_Org_Dimension_ID  IN  NUMBER
, p_Time_Dimension_ID IN  NUMBER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Gets All Performance Measures
-- If information about the dimensions are not required, set all_info to
-- FALSE
Procedure Retrieve_Measures
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
Procedure Retrieve_Measure
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
Procedure Update_Measure
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Update_Measures one Measure for the give owner if
--   1) no Measure levels or targets exist
--   2) no users have selected to see actuals for the Measure
Procedure Update_Measure
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner            IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
--Overload Update_Measure so that old data model ldts can be uploaded using
--The latest lct file. The lct file can call Load_Measure which calls this
--by passing in Org and Time dimension short_names also
Procedure Update_Measure
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec       IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, p_Org_Dimension_ID  IN  NUMBER
, p_Time_Dimension_ID IN  NUMBER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
-- PLEASE VERIFY COMMENT BELOW
-- deletes one Measure if
-- 1) no Measure levels, targets exist and
-- 2) the Measure access has not been granted to a resonsibility
-- 3) no users have selected to see actuals for the Measure
Procedure Delete_Measure
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_Rec   IN  BIS_MEASURE_PUB.Measure_Rec_Type
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
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Translate_Measure
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec       IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Validates measure
PROCEDURE Validate_Measure
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Measure_Rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner            IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Value - ID conversion
PROCEDURE Value_ID_Conversion
( p_api_version     IN  NUMBER
, p_Measure_Rec IN  BIS_Measure_PUB.Measure_Rec_Type
, x_Measure_Rec IN OUT NOCOPY BIS_Measure_PUB.Measure_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Value_ID_Conversion
( p_api_version        IN  NUMBER
, p_Measure_Short_Name IN  VARCHAR2
, p_Measure_Name       IN  VARCHAR2
, x_Measure_ID         OUT NOCOPY NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
, x_error_Tbl          OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Measure_Value_ID_Conversion
( p_api_version     IN  NUMBER
, p_Measure_Rec IN  BIS_Measure_PUB.Measure_Rec_Type
, x_Measure_Rec OUT NOCOPY BIS_Measure_PUB.Measure_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Dimension_Value_ID_Conversion
( p_api_version     IN  NUMBER
, p_Measure_Rec IN  BIS_Measure_PUB.Measure_Rec_Type
, x_Measure_Rec IN OUT NOCOPY BIS_Measure_PUB.Measure_Rec_Type
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
PROCEDURE Lock_Record
( p_api_version   IN  NUMBER
, p_Measure_Rec   IN  BIS_Measure_PUB.Measure_Rec_Type
, p_timestamp     IN  VARCHAR  := NULL
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Retrieve_Last_Update_Date
( p_api_version      IN  NUMBER
, p_Measure_Rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_last_update_date OUT NOCOPY DATE
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- creates one Measure, with the dimensions sequenced in the order
PROCEDURE Create_Application_Measure
( p_api_version             IN  NUMBER
, p_commit                  IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_rec             IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_application_rec         IN  BIS_Application_PVT.Application_Rec_Type
, p_owning_application      IN  VARCHAR2
, p_owner                   IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status           OUT NOCOPY VARCHAR2
, x_error_Tbl               OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Retrieve_Application_Measures
( p_api_version     IN  NUMBER
, p_Measure_Rec     IN  BIS_Measure_PUB.Measure_Rec_Type
, p_all_info        IN  VARCHAR2
, x_owning_application_rec  OUT NOCOPY BIS_Application_PVT.Application_Rec_Type
, x_Application_tbl OUT NOCOPY BIS_Application_PVT.Application_Tbl_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Update_Application_Measure
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_application_rec  IN  BIS_Application_PVT.Application_Rec_Type
, p_owning_application      IN  VARCHAR2
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Delete_Application_Measure
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_application_rec  IN  BIS_Application_PVT.Application_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Delete_Application_Measures
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Measure_rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Lock_Record
( p_api_version      IN  NUMBER
, p_Measure_rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_application_rec  IN  BIS_Application_PVT.Application_Rec_Type
, p_timestamp        IN  VARCHAR  := NULL
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Retrieve_Last_Update_Date
( p_api_version      IN  NUMBER
, p_Measure_rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_application_rec  IN  BIS_Application_PVT.Application_Rec_Type
, x_last_update_date OUT NOCOPY DATE
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Create_Indicator_Dimension
( p_Measure_id    number
, p_dimension_id  number
, p_sequence_no   number
, p_owner         IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER --2465354
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Create_Indicator_Dimensions
( p_Measure_Rec      IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner            IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--Overload Create_Indicator_Dimensions so that old data model ldts can be uploaded using
--The latest lct file. The lct file can indirectly call this overloaded procedure
--by passing in Org and Time  also
PROCEDURE Create_Indicator_Dimensions
( p_Measure_Rec       IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_Org_Dimension_ID  IN   NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
, p_Time_Dimension_ID IN   NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--added new function to determine whether the data model is new or old while loading measures
FUNCTION IS_OLD_DATA_MODEL
(p_Measure_rec    IN BIS_MEASURE_PUB.MEASURE_REC_TYPE
 ,p_Org_Dimension_Id IN NUMBER
 ,p_Time_Dimension_Id IN NUMBER
)
RETURN BOOLEAN;

--OverLoad Dimension Count so that when loader tries to update a measure
--with an old ldt file, it will not fail
FUNCTION Dimension_Count
(p_Measure_Rec IN  BIS_MEASURE_PUB.Measure_Rec_Type
,p_Org_Dimension_Id IN NUMBER
,p_Time_Dimension_Id IN NUMBER
)
return NUMBER;

-- Given a performance measure short name update the
--  bis_indicators, bis_indicators_tl and  bis_indicator_dimensions
-- for last_updated_by , created_by as 1
PROCEDURE updt_pm_owner(p_pm_short_name  IN VARCHAR2
                       ,x_return_status OUT NOCOPY VARCHAR2);

-- mdamle 09/25/2003 - Sync up measures for all installed languages
Procedure Translate_Measure_by_lang
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2 := FND_API.G_FALSE
, p_Measure_Rec       IN  BIS_MEASURE_PUB.Measure_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, p_lang              IN  VARCHAR2
, p_source_lang       IN  VARCHAR2
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--added new function to determine whether the given indicator is customized

FUNCTION GET_CUSTOMIZED_ENABLED
( p_indicator_id IN NUMBER
)
RETURN VARCHAR2;

--Procedure to update the obsolete flag of an indicator
PROCEDURE Update_Measure_Obsolete_Flag(
   p_commit                      IN VARCHAR2 := FND_API.G_FALSE,
   p_measure_short_name          IN VARCHAR2,
   p_obsolete                    IN VARCHAR2,
   x_return_status               OUT nocopy VARCHAR2,
   x_Msg_Count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT nocopy VARCHAR2
);

FUNCTION Get_Measure_Id_From_Short_Name
( p_measure_rec IN  BIS_MEASURE_PUB.Measure_Rec_Type
) RETURN NUMBER;

END BIS_MEASURE_PVT;



 

/
