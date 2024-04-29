--------------------------------------------------------
--  DDL for Package Body BIS_TARGET_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_TARGET_VALIDATE_PVT" AS
/* $Header: BISVTAVB.pls 115.18 2003/12/02 22:22:54 gbhaloti ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVTVLB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for validating items in the targets record
REM | NOTES                                                                 |
REM |                                                                       |
REM |
REM |    07-OCT-2002 rchandra changed the message name from                 |
REM |                            BIS_MISSING_TARGET_VALUE to                |
REM |                            BIS_MISSING_TARGET_VALUES for  bug 2578948 |
REM | 23-JAN-03 sugopal For having different local variables for IN and OUT |
REM |                   parameters (bug#2758428)              	            |
REM + 01-DEC-2003	gbhaloti	Fix for #3273767      	            |
REM +=======================================================================+
*/
--
--
PROCEDURE Validate_Target_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_Target_Level_ID NUMBER;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  IF( BIS_UTILITIES_PUB.Value_Missing(p_Target_Rec.TARGET_LEVEL_ID)
      = FND_API.G_TRUE
    ) THEN
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name  => 'BIS_MISSING_TAR_LEVEL_ID'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name => 'BIS_TARGET_VALIDATE_PVT.Validate_Target_Level_ID'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    SELECT bisbv_target_levels.TARGET_LEVEL_ID
    INTO l_Target_Level_ID
    FROM bisbv_target_levels bisbv_target_levels
    WHERE bisbv_target_levels.TARGET_LEVEL_ID
          = p_Target_Rec.TARGET_LEVEL_ID;
  END IF;
  --

--commented RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --added more params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name  => 'BIS_INVALID_TAR_LEVEL_ID'
     , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name => 'BIS_TARGET_VALIDATE_PVT.Validate_Target_Level_ID'
     , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Target_Level_ID'
     , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Target_Level_ID;
--
--
PROCEDURE Validate_Plan_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_Plan_ID NUMBER;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  IF( BIS_UTILITIES_PUB.Value_Missing(p_Target_Rec.PLAN_ID)
      = FND_API.G_TRUE
    ) THEN
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name  => 'BIS_MISSING_PLAN_ID'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name => 'BIS_TARGET_VALIDATE_PVT.Validate_Plan_ID'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- Gaurav fix for #3273767 - changed bisbv_business_plans to bis_business_plans
    SELECT bis_business_plans.PLAN_ID
    INTO l_Plan_ID
    FROM bis_business_plans bis_business_plans
    WHERE bis_business_plans.PLAN_ID
          = p_Target_Rec.PLAN_ID;
  END IF;
  --

--commented RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name  => 'BIS_INVALID_PLAN_ID'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name => 'BIS_TARGET_VALIDATE_PVT.Validate_Plan_ID'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Plan_ID'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
  --  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Plan_ID;
--
--
--
PROCEDURE Validate_Org_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_bisbv_target_levels BISBV_TARGET_LEVELS%ROWTYPE;
l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_Dim_Level_Value_Rec_p BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  SELECT *
  INTO l_bisbv_target_levels
  FROM BISBV_TARGET_LEVELS bisbv_target_levels
  WHERE bisbv_target_levels.TARGET_LEVEL_ID = p_Target_Rec.Target_Level_ID;
  --


  IF(l_bisbv_target_levels.ORG_LEVEL_ID IS NOT NULL) THEN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_bisbv_target_levels.ORG_LEVEL_ID;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
      := p_Target_Rec.Org_Level_Value_ID;
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

--commented RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
  --  RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Org_Level_Value_ID'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Org_Level_Value_ID;
--
--
PROCEDURE Validate_Time_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_bisbv_target_levels BISBV_TARGET_LEVELS%ROWTYPE;
l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_Dim_Level_Value_Rec_p BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  SELECT *
  INTO l_bisbv_target_levels
  FROM BISBV_TARGET_LEVELS bisbv_target_levels
  WHERE bisbv_target_levels.TARGET_LEVEL_ID = p_Target_Rec.Target_Level_ID;
  --


  IF(l_bisbv_target_levels.TIME_LEVEL_ID IS NOT NULL) THEN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_bisbv_target_levels.TIME_LEVEL_ID;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
      := p_Target_Rec.Time_Level_Value_ID;
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

--commented RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
  --  RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Time_Level_Value_ID'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Time_Level_Value_ID;
--
--
PROCEDURE Validate_Dim1_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_bisbv_target_levels BISBV_TARGET_LEVELS%ROWTYPE;
l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_Dim_Level_Value_Rec_p BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  SELECT *
  INTO l_bisbv_target_levels
  FROM BISBV_TARGET_LEVELS bisbv_target_levels
  WHERE bisbv_target_levels.TARGET_LEVEL_ID = p_Target_Rec.Target_Level_ID;
  --


  IF(l_bisbv_target_levels.DIMENSION1_LEVEL_ID IS NOT NULL) THEN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_bisbv_target_levels.DIMENSION1_LEVEL_ID;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
      := p_Target_Rec.Dim1_Level_Value_ID;
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

--commented RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
  --  RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Dim1_Level_Value_ID'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Dim1_Level_Value_ID;
--
--
PROCEDURE Validate_Dim2_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_bisbv_target_levels BISBV_TARGET_LEVELS%ROWTYPE;
l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_Dim_Level_Value_Rec_p BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  SELECT *
  INTO l_bisbv_target_levels
  FROM BISBV_TARGET_LEVELS bisbv_target_levels
  WHERE bisbv_target_levels.TARGET_LEVEL_ID = p_Target_Rec.Target_Level_ID;
  --
  IF(l_bisbv_target_levels.DIMENSION2_LEVEL_ID IS NOT NULL) THEN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_bisbv_target_levels.DIMENSION2_LEVEL_ID;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
      := p_Target_Rec.Dim2_Level_Value_ID;
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

--commented RAISE
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
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Dim2_Level_Value_ID'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Dim2_Level_Value_ID;
--
--
PROCEDURE Validate_Dim3_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_bisbv_target_levels BISBV_TARGET_LEVELS%ROWTYPE;
l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_Dim_Level_Value_Rec_p BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  SELECT *
  INTO l_bisbv_target_levels
  FROM BISBV_TARGET_LEVELS bisbv_target_levels
  WHERE bisbv_target_levels.TARGET_LEVEL_ID = p_Target_Rec.Target_Level_ID;
  --
  IF(l_bisbv_target_levels.DIMENSION3_LEVEL_ID IS NOT NULL) THEN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_bisbv_target_levels.DIMENSION3_LEVEL_ID;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
      := p_Target_Rec.Dim3_Level_Value_ID;
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

--commented RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
  --  RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
  --  RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Dim3_Level_Value_ID'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Dim3_Level_Value_ID;
--
--
PROCEDURE Validate_Dim4_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_bisbv_target_levels BISBV_TARGET_LEVELS%ROWTYPE;
l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_Dim_Level_Value_Rec_p BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  SELECT *
  INTO l_bisbv_target_levels
  FROM BISBV_TARGET_LEVELS bisbv_target_levels
  WHERE bisbv_target_levels.TARGET_LEVEL_ID = p_Target_Rec.Target_Level_ID;
  --
  IF(l_bisbv_target_levels.DIMENSION4_LEVEL_ID IS NOT NULL) THEN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_bisbv_target_levels.DIMENSION4_LEVEL_ID;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
      := p_Target_Rec.Dim4_Level_Value_ID;
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

--commented RAISE
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
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Dim4_Level_Value_ID'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Dim4_Level_Value_ID;
--
--
PROCEDURE Validate_Dim5_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_bisbv_target_levels BISBV_TARGET_LEVELS%ROWTYPE;
l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_Dim_Level_Value_Rec_p BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  SELECT *
  INTO l_bisbv_target_levels
  FROM BISBV_TARGET_LEVELS bisbv_target_levels
  WHERE bisbv_target_levels.TARGET_LEVEL_ID = p_Target_Rec.Target_Level_ID;
  --
  IF(l_bisbv_target_levels.DIMENSION5_LEVEL_ID IS NOT NULL) THEN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_bisbv_target_levels.DIMENSION5_LEVEL_ID;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
      := p_Target_Rec.Dim5_Level_Value_ID;
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

--commented RAISE
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
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Dim5_Level_Value_ID'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Dim5_Level_Value_ID;
--
--
PROCEDURE Validate_Dim6_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_bisbv_target_levels BISBV_TARGET_LEVELS%ROWTYPE;
l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_Dim_Level_Value_Rec_p BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  SELECT *
  INTO l_bisbv_target_levels
  FROM BISBV_TARGET_LEVELS bisbv_target_levels
  WHERE bisbv_target_levels.TARGET_LEVEL_ID = p_Target_Rec.Target_Level_ID;
  --
  IF(l_bisbv_target_levels.DIMENSION6_LEVEL_ID IS NOT NULL) THEN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_bisbv_target_levels.DIMENSION6_LEVEL_ID;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
      := p_Target_Rec.Dim6_Level_Value_ID;
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
--commented RAISE
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
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Dim6_Level_Value_ID'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Dim6_Level_Value_ID;
--
--
PROCEDURE Validate_Dim7_Level_Value_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_bisbv_target_levels BISBV_TARGET_LEVELS%ROWTYPE;
l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_Dim_Level_Value_Rec_p BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  SELECT *
  INTO l_bisbv_target_levels
  FROM BISBV_TARGET_LEVELS bisbv_target_levels
  WHERE bisbv_target_levels.TARGET_LEVEL_ID = p_Target_Rec.Target_Level_ID;
  --
  IF(l_bisbv_target_levels.DIMENSION7_LEVEL_ID IS NOT NULL) THEN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_bisbv_target_levels.DIMENSION7_LEVEL_ID;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
      := p_Target_Rec.Dim7_Level_Value_ID;
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
--commented RAISE
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
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Dim7_Level_Value_ID'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Dim7_Level_Value_ID;
--
--
PROCEDURE Validate_Target_Value
( p_api_version      IN  NUMBER
, p_is_dbimeasure    IN  NUMBER := 0 --added by gbhaloti #3148615
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_bisbv_target_levels BISBV_TARGET_LEVELS%ROWTYPE;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  SELECT *
  INTO l_bisbv_target_levels
  FROM BISBV_TARGET_LEVELS bisbv_target_levels
  WHERE bisbv_target_levels.TARGET_LEVEL_ID = p_Target_Rec.Target_Level_ID;
  --
  -- check if computing target function exists
  IF( ( BIS_UTILITIES_PUB.Value_Missing(p_Target_Rec.TARGET) = FND_API.G_TRUE
        OR p_Target_Rec.TARGET IS NULL
      )
      AND l_bisbv_target_levels.COMPUTING_FUNCTION_ID IS NULL
      AND p_is_dbimeasure = 0 --added by gbhaloti #3148615
    ) THEN
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name  => 'BIS_MISSING_TARGET_VALUES'
     , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name => 'BIS_TARGET_VALIDATE_PVT.Validate_Target_Value'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added more params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Target_Value'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Target_Value;
--
--
PROCEDURE Validate_Range1_Low
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Range1_Low'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Range1_Low;
--
--
PROCEDURE Validate_Range1_High
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Range1_High'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Range1_High;
--
--
PROCEDURE Validate_Range2_Low
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Range2_Low'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Range2_Low;
--
--
PROCEDURE Validate_Range2_High
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Range2_High'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Range2_High;
--
--
PROCEDURE Validate_Range3_Low
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Range3_Low'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Range3_Low;
--
--
PROCEDURE Validate_Range3_High
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added more parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Range3_High'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );

   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Range3_High;
--
--
PROCEDURE Validate_Notify_Resp1_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added more params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Notify_Resp1_ID'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Notify_Resp1_ID;
--
--
PROCEDURE Validate_Notify_Resp1
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added more params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Notify_Resp1'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Notify_Resp1;
--
--
PROCEDURE Validate_Notify_Resp2_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added more params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Notify_Resp2_ID'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Notify_Resp2_ID;
--
--
PROCEDURE Validate_Notify_Resp2
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added more params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Notify_Resp2'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Notify_Resp2;
--
--
PROCEDURE Validate_Notify_Resp3_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added more params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Notify_Resp3_ID'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Notify_Resp3_ID;
--
--
PROCEDURE Validate_Notify_Resp3
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added more params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'BIS_TARGET_VALIDATE_PVT.Validate_Notify_Resp3'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Notify_Resp3;
--
--
END BIS_TARGET_VALIDATE_PVT;

/
