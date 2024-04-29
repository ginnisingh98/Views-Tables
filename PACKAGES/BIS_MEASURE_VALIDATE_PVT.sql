--------------------------------------------------------
--  DDL for Package BIS_MEASURE_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_MEASURE_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVMEVS.pls 120.0 2005/06/01 17:13:26 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVTVLS.pls                                                      |
REM |      MAHRAO		1850860	27/11/2001                                                                      |
REM | DESCRIPTION                                                           |
REM |     Private API for validating items in the MEASUREs record
REM | NOTES                                                                 |
REM |                                                                       |
REM |
REM | 26-JUL-2002 rchandra  Fixed for enh 2440739                           |
REM | 12-NOV-03 smargand    added the validation for the enable column      |
REM | 22-APR-2005 akoduri   Enhancement#3865711 -- Obsolete Seeded Objects  |
REM | 03-MAY-2005  akoduri  Enh #4268374 -- Weighted Average Measures       |
REM +=======================================================================+
*/
--
--
PROCEDURE Validate_Dimension1_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec       IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_Dimension2_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec       IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_Dimension3_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec       IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_Dimension4_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec       IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Validate_Dimension5_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec       IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--
PROCEDURE Validate_Dimension6_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec       IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Validate_Dimension7_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec       IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--added this in the spec
PROCEDURE Validate_Dimension_Id
( p_api_version          IN  NUMBER
, p_dimension_id         IN  NUMBER
, p_dimension_short_name IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Fix for 1850860 starts here
PROCEDURE Val_Actual_Data_Sour_Type
( p_api_version               IN  NUMBER
, p_actual_data_source_type   IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Val_Actual_Data_Sour_Type_wrap
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec      IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Val_Actual_Data_Sour
( p_api_version               IN  NUMBER
, p_actual_data_source        IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Val_Actual_Data_Sour_Wrap
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec      IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Val_Func_Name
( p_api_version               IN  NUMBER
, p_function_name       IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Val_Func_Name_Wrap
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec      IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Val_Comparison_Source
( p_api_version               IN  NUMBER
, p_Comparison_Source         IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Val_Comparison_Source_Wrap
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec      IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Val_Incr_In_Measure
( p_api_version               IN  NUMBER
, p_Increase_In_Measure       IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Val_Incr_In_Measure_Wrap
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec      IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- Fix for 1850860 ends here
--

-- 2440739
PROCEDURE Val_Enable_Link
( p_api_version               IN  NUMBER
, p_Enable_Link               IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Val_Enable_Link_Wrap
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec      IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

-- 2440739

-- 3031053

PROCEDURE Val_Enabled
( p_api_version               IN  NUMBER
, p_Enabled                   IN  VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_error_Tbl                 OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE Val_Enabled_Wrap
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec      IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
-- 3031053

PROCEDURE Val_Obsolete_Wrap --3865711
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec      IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE Val_Measure_Type_Wrap
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_Rec      IN  BIS_MEASURE_PUB.MEASURE_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);


END BIS_MEASURE_VALIDATE_PVT;

 

/
