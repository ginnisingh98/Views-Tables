--------------------------------------------------------
--  DDL for Package Body BIS_ACTUAL_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_ACTUAL_VALIDATE_PVT" AS
/* $Header: BISVAVVB.pls 115.8 2003/01/27 13:35:04 mahrao ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVAVVB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for validating items in the ACTUALs record
REM | NOTES                                                                 |
REM | 23-JAN-03 mahrao For having different local variables for IN and OUT
REM |                  parameters.
REM |                                                                       |
REM |
REM +=======================================================================+
*/
--
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_ACTUAL_VALIDATE_PVT';
--
PROCEDURE Validate_Target_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_Target_Level_ID NUMBER;
l_Target_Level_Rec   BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Actual_Rec         BIS_ACTUAL_PUB.Actual_Rec_Type;
l_Target_Level_Rec_p BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_error_tbl          BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

--  dbms_output.put_line( 'p_ACTUAL_Rec.TARGET_LEVEL_ID = '
--                        || p_ACTUAL_Rec.TARGET_LEVEL_ID
--                      );

  l_Actual_Rec     := p_Actual_Rec;
  --
  IF( BIS_UTILITIES_PUB.Value_Missing(l_ACTUAL_Rec.TARGET_LEVEL_ID)
      = FND_API.G_TRUE
    ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    l_target_level_rec.Target_Level_ID := l_actual_rec.Target_Level_ID;
    l_Target_Level_rec_p := l_Target_Level_rec;
    BIS_Target_Level_PVT.Retrieve_Target_Level
    ( p_api_version             => p_api_version
    , p_Target_Level_rec        => l_Target_Level_rec_p
    , p_all_info                => FND_API.G_FALSE
    , x_Target_Level_rec        => l_Target_Level_rec
    , x_return_status           => x_return_status
    , x_error_Tbl               => x_error_Tbl
    );

/*
    SELECT bisbv_target_levels.TARGET_LEVEL_ID
    INTO l_Target_Level_ID
    FROM bisbv_target_levels bisbv_target_levels
    WHERE bisbv_target_levels.TARGET_LEVEL_ID = p_ACTUAL_Rec.TARGET_LEVEL_ID;
*/
  END IF;
  --

--commented out NOCOPY RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Target_Level_ID;
--
--
/*
PROCEDURE Validate_Time_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
--l_bisbv_target_levels BISBV_TARGET_LEVELS%ROWTYPE;
l_bisbv_target_levels     BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Org_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  IF( BIS_UTILITIES_PUB.Value_Missing(p_ACTUAL_Rec.Time_Level_Value_ID)
      = FND_API.G_TRUE
    ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- do validation here
    l_bisbv_target_levels.Target_Level_ID := p_actual_rec.Target_Level_ID;

    BIS_Target_Level_PVT.Retrieve_Target_Level
    ( p_api_version             => p_api_version
    , p_Target_Level_rec        => l_bisbv_target_levels
    , p_all_info                => FND_API.G_FALSE
    , x_Target_Level_rec        => l_bisbv_target_levels
    , x_return_status           => x_return_status
    , x_error_Tbl               => x_error_Tbl
    );


    SELECT *
    INTO l_bisbv_TARGET_levels
    FROM BISBV_TARGET_LEVELS bisbv_TARGET_levels
    WHERE bisbv_TARGET_levels.TARGET_LEVEL_ID = p_ACTUAL_Rec.TARGET_Level_ID;

    --
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_bisbv_TARGET_levels.TIME_LEVEL_ID;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
      := p_ACTUAL_Rec.Time_Level_Value_ID;
    l_Org_Level_Value_Rec.Dimension_Level_Value_ID
      := p_ACTUAL_Rec.Org_Level_Value_ID;
    --
    BIS_DIM_LEVEL_VALUE_PVT.Time_ID_to_Value
    ( p_api_version         => 1.0
    , p_Org_Level_Value_Rec => l_Org_Level_Value_Rec
    , p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec
    , x_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => x_error_Tbl
    );
  END IF;
  --
--commented out NOCOPY RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => x_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Time_Level_Value_ID;
--
--
PROCEDURE Validate_Org_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
--l_bisbv_TARGET_levels BISBV_TARGET_LEVELS%ROWTYPE;
l_bisbv_target_levels     BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  IF( BIS_UTILITIES_PUB.Value_Missing(p_ACTUAL_Rec.ORG_LEVEL_VALUE_ID)
      = FND_API.G_TRUE
    ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    l_bisbv_target_levels.Target_Level_ID := p_actual_rec.Target_Level_ID;

    BIS_Target_Level_PVT.Retrieve_Target_Level
    ( p_api_version             => p_api_version
    , p_Target_Level_rec        => l_bisbv_target_levels
    , p_all_info                => FND_API.G_FALSE
    , x_Target_Level_rec        => l_bisbv_target_levels
    , x_return_status           => x_return_status
    , x_error_Tbl               => x_error_Tbl
    );



    SELECT *
    INTO l_bisbv_TARGET_levels
    FROM BISBV_TARGET_LEVELS bisbv_TARGET_levels
    WHERE bisbv_TARGET_levels.TARGET_LEVEL_ID = p_ACTUAL_Rec.TARGET_Level_ID;

    --
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_bisbv_TARGET_levels.ORG_LEVEL_ID;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
      := p_ACTUAL_Rec.Org_Level_Value_ID;
    --
    BIS_DIM_LEVEL_VALUE_PVT.Org_ID_to_Value
    ( p_api_version         => 1.0
    , p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec
    , x_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => x_error_Tbl
    );
  END IF;
  --

--commented out NOCOPY RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => x_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Org_Level_Value_ID;
*/
--
--
PROCEDURE Validate_Dim1_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
--l_bisbv_TARGET_levels BISBV_TARGET_LEVELS%ROWTYPE;
l_bisbv_target_levels     BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Dim_Level_Value_Rec     BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_bisbv_target_levels_p   BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Dim_Level_Value_Rec_p   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_error_tbl               BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
    l_bisbv_target_levels.Target_Level_ID := p_actual_rec.Target_Level_ID;
    l_bisbv_target_levels_p := l_bisbv_target_levels;
    BIS_Target_Level_PVT.Retrieve_Target_Level
    ( p_api_version             => p_api_version
    , p_Target_Level_rec        => l_bisbv_target_levels_p
    , p_all_info                => FND_API.G_FALSE
    , x_Target_Level_rec        => l_bisbv_target_levels
    , x_return_status           => x_return_status
    , x_error_Tbl               => x_error_Tbl
    );

/*
  SELECT *
  INTO l_bisbv_TARGET_levels
  FROM BISBV_TARGET_LEVELS bisbv_TARGET_levels
  WHERE bisbv_TARGET_levels.TARGET_LEVEL_ID = p_ACTUAL_Rec.TARGET_Level_ID;
*/
  --
  IF(l_bisbv_TARGET_levels.DIMENSION1_LEVEL_ID IS NOT NULL) THEN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_bisbv_TARGET_levels.DIMENSION1_LEVEL_ID;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
      := p_ACTUAL_Rec.Dim1_Level_Value_ID;
    --
    l_Dim_Level_Value_Rec_p := l_Dim_Level_Value_Rec;
		BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
    ( p_api_version         => 1.0
    , p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
    , x_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => x_error_Tbl
    );
  END IF;
  --
--commented out NOCOPY RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Dim1_Level_Value_ID;
--
--
PROCEDURE Validate_Dim2_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
--l_bisbv_TARGET_levels BISBV_TARGET_LEVELS%ROWTYPE;
l_bisbv_target_levels     BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_bisbv_target_levels_p   BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Dim_Level_Value_Rec_p   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_error_tbl               BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
    l_bisbv_target_levels.Target_Level_ID := p_actual_rec.Target_Level_ID;

    l_bisbv_target_levels_p := l_bisbv_target_levels;
    BIS_Target_Level_PVT.Retrieve_Target_Level
    ( p_api_version             => p_api_version
    , p_Target_Level_rec        => l_bisbv_target_levels_p
    , p_all_info                => FND_API.G_FALSE
    , x_Target_Level_rec        => l_bisbv_target_levels
    , x_return_status           => x_return_status
    , x_error_Tbl               => x_error_Tbl
    );

/*

  SELECT *
  INTO l_bisbv_TARGET_levels
  FROM BISBV_TARGET_LEVELS bisbv_TARGET_levels
  WHERE bisbv_TARGET_levels.TARGET_LEVEL_ID = p_ACTUAL_Rec.TARGET_Level_ID;
*/
  --
  IF(l_bisbv_TARGET_levels.DIMENSION2_LEVEL_ID IS NOT NULL) THEN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_bisbv_TARGET_levels.DIMENSION2_LEVEL_ID;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
      := p_ACTUAL_Rec.Dim2_Level_Value_ID;
    --
    l_Dim_Level_Value_Rec_p := l_Dim_Level_Value_Rec;
    BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
    ( p_api_version         => 1.0
    , p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
    , x_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => x_error_Tbl
    );
  END IF;
  --

--commented out NOCOPY RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Dim2_Level_Value_ID;
--
--
PROCEDURE Validate_Dim3_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
--l_bisbv_TARGET_levels bisbv_TARGET_LEVELS%ROWTYPE;
l_bisbv_target_levels     BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_bisbv_target_levels_p   BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Dim_Level_Value_Rec_p   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_error_tbl               BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
    l_bisbv_target_levels.Target_Level_ID := p_actual_rec.Target_Level_ID;

    l_bisbv_target_levels_p := l_bisbv_target_levels;
    BIS_Target_Level_PVT.Retrieve_Target_Level
    ( p_api_version             => p_api_version
    , p_Target_Level_rec        => l_bisbv_target_levels_p
    , p_all_info                => FND_API.G_FALSE
    , x_Target_Level_rec        => l_bisbv_target_levels
    , x_return_status           => x_return_status
    , x_error_Tbl               => x_error_Tbl
    );

/*
  SELECT *
  INTO l_bisbv_TARGET_levels
  FROM bisbv_TARGET_LEVELS bisbv_TARGET_levels
  WHERE bisbv_TARGET_levels.TARGET_level_ID = p_ACTUAL_Rec.TARGET_level_ID;
*/
  --
  IF(l_bisbv_TARGET_levels.DIMENSION3_LEVEL_ID IS NOT NULL) THEN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_bisbv_TARGET_levels.DIMENSION3_LEVEL_ID;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
      := p_ACTUAL_Rec.Dim3_Level_Value_ID;
    --
    l_Dim_Level_Value_Rec_p := l_Dim_Level_Value_Rec;
    BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
    ( p_api_version         => 1.0
    , p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
    , x_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => x_error_Tbl
    );
  END IF;
  --

--commented out NOCOPY RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Dim3_Level_Value_ID;
--
--
PROCEDURE Validate_Dim4_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
--l_bisbv_TARGET_levels bisbv_TARGET_LEVELS%ROWTYPE;
l_bisbv_target_levels     BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_bisbv_target_levels_p   BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Dim_Level_Value_Rec_p   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_error_tbl               BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
    l_bisbv_target_levels.Target_Level_ID := p_actual_rec.Target_Level_ID;

    l_bisbv_target_levels_p := l_bisbv_target_levels;
    BIS_Target_Level_PVT.Retrieve_Target_Level
    ( p_api_version             => p_api_version
    , p_Target_Level_rec        => l_bisbv_target_levels_p
    , p_all_info                => FND_API.G_FALSE
    , x_Target_Level_rec        => l_bisbv_target_levels
    , x_return_status           => x_return_status
    , x_error_Tbl               => x_error_Tbl
    );

/*
  SELECT *
  INTO l_bisbv_TARGET_levels
  FROM bisbv_TARGET_LEVELS bisbv_TARGET_levels
  WHERE bisbv_TARGET_levels.TARGET_level_ID = p_ACTUAL_Rec.TARGET_level_ID;
*/
  --
  IF(l_bisbv_TARGET_levels.DIMENSION4_LEVEL_ID IS NOT NULL) THEN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_bisbv_TARGET_levels.DIMENSION4_LEVEL_ID;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
      := p_ACTUAL_Rec.Dim4_Level_Value_ID;
    --
    l_Dim_Level_Value_Rec_p := l_Dim_Level_Value_Rec;
    BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
    ( p_api_version         => 1.0
    , p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
    , x_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => x_error_Tbl
    );
  END IF;
  --
--commented out NOCOPY RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Dim4_Level_Value_ID;
--
--
PROCEDURE Validate_Dim5_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
--l_bisbv_TARGET_levels bisbv_TARGET_LEVELS%ROWTYPE;
l_bisbv_target_levels     BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_bisbv_target_levels_p   BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Dim_Level_Value_Rec_p   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_error_tbl               BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
    l_bisbv_target_levels.Target_Level_ID := p_actual_rec.Target_Level_ID;

    l_bisbv_target_levels_p := l_bisbv_target_levels;
    BIS_Target_Level_PVT.Retrieve_Target_Level
    ( p_api_version             => p_api_version
    , p_Target_Level_rec        => l_bisbv_target_levels_p
    , p_all_info                => FND_API.G_FALSE
    , x_Target_Level_rec        => l_bisbv_target_levels
    , x_return_status           => x_return_status
    , x_error_Tbl               => x_error_Tbl
    );

/*
  SELECT *
  INTO l_bisbv_TARGET_levels
  FROM bisbv_TARGET_LEVELS bisbv_TARGET_levels
  WHERE bisbv_TARGET_levels.TARGET_level_ID = p_ACTUAL_Rec.TARGET_level_ID;
*/
  --
  IF(l_bisbv_TARGET_levels.DIMENSION5_LEVEL_ID IS NOT NULL) THEN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_bisbv_TARGET_levels.DIMENSION5_LEVEL_ID;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
      := p_ACTUAL_Rec.Dim5_Level_Value_ID;
    --
    l_Dim_Level_Value_Rec_p := l_Dim_Level_Value_Rec;
    BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
    ( p_api_version         => 1.0
    , p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
    , x_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => x_error_Tbl
    );
  END IF;
  --

--commented out NOCOPY RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Dim5_Level_Value_ID;
--
--
PROCEDURE Validate_Dim6_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
--l_bisbv_TARGET_levels bisbv_TARGET_LEVELS%ROWTYPE;
l_bisbv_target_levels     BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_bisbv_target_levels_p   BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Dim_Level_Value_Rec_p   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_error_tbl               BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
    l_bisbv_target_levels.Target_Level_ID := p_actual_rec.Target_Level_ID;

    l_bisbv_target_levels_p := l_bisbv_target_levels;
    BIS_Target_Level_PVT.Retrieve_Target_Level
    ( p_api_version             => p_api_version
    , p_Target_Level_rec        => l_bisbv_target_levels_p
    , p_all_info                => FND_API.G_FALSE
    , x_Target_Level_rec        => l_bisbv_target_levels
    , x_return_status           => x_return_status
    , x_error_Tbl               => x_error_Tbl
    );

/*
  SELECT *
  INTO l_bisbv_TARGET_levels
  FROM bisbv_TARGET_LEVELS bisbv_TARGET_levels
  WHERE bisbv_TARGET_levels.TARGET_level_ID = p_ACTUAL_Rec.TARGET_level_ID;
*/
  --
  IF(l_bisbv_TARGET_levels.DIMENSION6_LEVEL_ID IS NOT NULL) THEN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_bisbv_TARGET_levels.DIMENSION6_LEVEL_ID;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
      := p_ACTUAL_Rec.Dim6_Level_Value_ID;
    --
    l_Dim_Level_Value_Rec_p := l_Dim_Level_Value_Rec;
    BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
    ( p_api_version         => 1.0
    , p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
    , x_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => x_error_Tbl
    );
  END IF;
  --

--commented out NOCOPY RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Dim6_Level_Value_ID;
--
--
PROCEDURE Validate_Dim7_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
--l_bisbv_TARGET_levels bisbv_TARGET_LEVELS%ROWTYPE;
l_bisbv_target_levels     BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_bisbv_target_levels_p   BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Dim_Level_Value_Rec_p   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_error_tbl               BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
    l_bisbv_target_levels.Target_Level_ID := p_actual_rec.Target_Level_ID;

    l_bisbv_target_levels_p := l_bisbv_target_levels;
    BIS_Target_Level_PVT.Retrieve_Target_Level
    ( p_api_version             => p_api_version
    , p_Target_Level_rec        => l_bisbv_target_levels_p
    , p_all_info                => FND_API.G_FALSE
    , x_Target_Level_rec        => l_bisbv_target_levels
    , x_return_status           => x_return_status
    , x_error_Tbl               => x_error_Tbl
    );

/*
  SELECT *
  INTO l_bisbv_TARGET_levels
  FROM bisbv_TARGET_LEVELS bisbv_TARGET_levels
  WHERE bisbv_TARGET_levels.TARGET_level_ID = p_ACTUAL_Rec.TARGET_level_ID;
*/
  --
  IF(l_bisbv_TARGET_levels.DIMENSION7_LEVEL_ID IS NOT NULL) THEN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_bisbv_TARGET_levels.DIMENSION7_LEVEL_ID;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
      := p_ACTUAL_Rec.Dim7_Level_Value_ID;
    --
    l_Dim_Level_Value_Rec_p := l_Dim_Level_Value_Rec;
    BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
    ( p_api_version         => 1.0
    , p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
    , x_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => x_error_Tbl
    );
  END IF;
  --

--commented out NOCOPY RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Dim7_Level_Value_ID;
--
--
PROCEDURE Validate_ACTUAL_Value
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  IF( BIS_UTILITIES_PUB.Value_Missing(p_ACTUAL_Rec.ACTUAL)
      = FND_API.G_TRUE
    ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    NULL;
  END IF;
  --
--commented out NOCOPY RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_ACTUAL_Value;
--
--
PROCEDURE Validate_Record
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_ACTUAL_Rec       IN  BIS_ACTUAL_PUB.ACTUAL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  -- commented out NOCOPY as they are changed now with the ranges being %
  -- dont know exact validations yet
/*
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_ACTUAL_Rec.RANGE1_LOW)
      = FND_API.G_TRUE
      AND BIS_UTILITIES_PUB.Value_Not_Missing(p_ACTUAL_Rec.RANGE1_HIGH)
      = FND_API.G_TRUE
      AND p_ACTUAL_Rec.RANGE1_LOW > p_ACTUAL_Rec.RANGE1_HIGH
    ) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_ACTUAL_Rec.RANGE2_LOW)
      = FND_API.G_TRUE
      AND BIS_UTILITIES_PUB.Value_Not_Missing(p_ACTUAL_Rec.RANGE2_HIGH)
      = FND_API.G_TRUE
      AND p_ACTUAL_Rec.RANGE2_LOW > p_ACTUAL_Rec.RANGE2_HIGH
    ) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_ACTUAL_Rec.RANGE3_LOW)
      = FND_API.G_TRUE
      AND BIS_UTILITIES_PUB.Value_Not_Missing(p_ACTUAL_Rec.RANGE3_HIGH)
      = FND_API.G_TRUE
      AND p_ACTUAL_Rec.RANGE3_LOW > p_ACTUAL_Rec.RANGE3_HIGH
    ) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
*/
  --
--commented out NOCOPY RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Record;
--
--
END BIS_ACTUAL_VALIDATE_PVT;

/
