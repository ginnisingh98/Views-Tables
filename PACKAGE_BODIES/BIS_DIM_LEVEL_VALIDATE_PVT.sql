--------------------------------------------------------
--  DDL for Package Body BIS_DIM_LEVEL_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_DIM_LEVEL_VALIDATE_PVT" AS
/* $Header: BISVDLVB.pls 115.9 2003/11/19 09:50:43 rchandra noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVDLVS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for validating items in the Dimension Level record
REM | NOTES                                                                 |
REM |                                                                       |
REM |
REM +=======================================================================+
*/
--
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_DIM_LEVEL_VALIDATE_PVT';
--
PROCEDURE Validate_Record
( p_api_version         IN  NUMBER
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if( BIS_UTILITIES_PUB.Value_Missing
                       (p_Dimension_Level_Rec.dimension_short_name)
     = FND_API.G_TRUE
   OR BIS_UTILITIES_PUB.Value_NULL(p_Dimension_Level_Rec.dimension_short_name)
     = FND_API.G_TRUE)
  OR( BIS_UTILITIES_PUB.Value_Missing
                       (p_Dimension_Level_Rec.dimension_level_short_name)
     = FND_API.G_TRUE
   OR BIS_UTILITIES_PUB.Value_NULL
                       (p_Dimension_Level_Rec.dimension_level_short_name)
     = FND_API.G_TRUE) then

    --POPULATE THE ERROR TABLE
    --added last two parameters
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_DIMENSION_LEVEL_ID'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Validate_Record'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl

    );

    RAISE FND_API.G_EXC_ERROR;
  end if;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two parameters
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Record'
      , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END  Validate_Record;

--
--
END BIS_DIM_LEVEL_VALIDATE_PVT;

/