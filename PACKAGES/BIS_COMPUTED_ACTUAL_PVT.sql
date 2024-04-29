--------------------------------------------------------
--  DDL for Package BIS_COMPUTED_ACTUAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_COMPUTED_ACTUAL_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVCPAS.pls 115.14 2003/04/18 14:50:37 sugopal ship $ */

SUBTYPE object_attribute_rec_type IS ak_region_items%ROWTYPE;

TYPE object_attribute_tbl_type IS TABLE OF object_attribute_rec_type
  INDEX BY BINARY_INTEGER;

SUBTYPE object_rec_type IS ak_regions%ROWTYPE;

TYPE object_tbl_type IS TABLE OF object_rec_type
  INDEX BY BINARY_INTEGER;

-- Derives the actual value for the specified set of dimension values
-- i.e. for a specific organization, time period, etc.
--
PROCEDURE Retrieve_Actual_from_PMV
( p_api_version           IN NUMBER
, p_all_info              IN VARCHAR2 Default FND_API.G_TRUE
, p_Measure_Instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_Actual_Rec            OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
, x_return_status         OUT NOCOPY VARCHAR2
, x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE Retrieve_Computed_Actual
( p_api_version           IN NUMBER
, p_all_info              IN VARCHAR2 Default FND_API.G_TRUE
, p_Measure_Instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_Actual_Rec            OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
, x_return_status         OUT NOCOPY VARCHAR2
, x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE Validate_Computed_Actual
(  p_api_version          IN NUMBER
 , p_validation_level     IN NUMBER Default FND_API.G_VALID_LEVEL_FULL
 , p_Actual_Rec           IN BIS_ACTUAL_PUB.Actual_Rec_Type
 , x_return_status        OUT NOCOPY VARCHAR2
 , x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE Validate_Required_Fields
( p_api_version          IN NUMBER
, p_validation_level     IN NUMBER Default FND_API.G_VALID_LEVEL_FULL
, p_Actual_Rec           IN BIS_ACTUAL_PUB.Actual_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE Value_ID_Conversion
( p_api_version     IN  NUMBER
, p_Actual_Rec IN   BIS_ACTUAL_PUB.Actual_Rec_Type
, x_Actual_Rec OUT NOCOPY  BIS_ACTUAL_PUB.Actual_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

Procedure Get_Related_Objects
( p_measure_short_name    IN VARCHAR2
, x_object_tbl            OUT NOCOPY object_tbl_type
, x_return_status         OUT NOCOPY VARCHAR2
);

FUNCTION IS_TIME_DIMENSION_LEVEL
( p_DimLevelId        IN NUMBER  := NULL
 ,p_DimShortName      OUT NOCOPY VARCHAR2
 ,p_DimLevelShortName OUT NOCOPY VARCHAR2
, x_return_status     OUT NOCOPY VARCHAR2
)
RETURN BOOLEAN;

PROCEDURE get_Region_Using_Function   -- 2841680
( p_Function_name           IN VARCHAR2
, x_Region_code             OUT NOCOPY VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_error_msg               OUT NOCOPY VARCHAR2
);


-- Procedure Update_Actual_Source; (PS bug 2165790)

Function get_dim_level_short_name(p_attribute IN VARCHAR2) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (get_dim_level_short_name, WNDS, WNPS);

END BIS_COMPUTED_ACTUAL_PVT;

 

/
