--------------------------------------------------------
--  DDL for Package Body BIS_BUSINESS_PLAN_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_BUSINESS_PLAN_VALIDATE_PVT" AS
/* $Header: BISVBPVB.pls 115.5 99/09/17 19:48:38 porting ship  $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVBPVB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for validating items in the Business Plans record
REM | NOTES                                                                 |
REM |     07/14/99    irchen   Creation                                     |
REM |
REM +=======================================================================+
*/
--
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_BUSINESS_PLAN_VALIDATE_PVT';
--
PROCEDURE Validate_Record
( p_api_version       IN  NUMBER
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Business_Plan_Rec IN  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, x_return_status     OUT VARCHAR2
, x_error_Tbl         OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if( BIS_UTILITIES_PUB.Value_Missing
      (p_Business_Plan_Rec.business_plan_short_name)
      = FND_API.G_TRUE
    OR BIS_UTILITIES_PUB.Value_NULL
       (p_Business_Plan_Rec.business_plan_short_name)
      = FND_API.G_TRUE) then

    --POPULATE THE ERROR TABLE
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_BUSINESS_PLAN_ID'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Validate_Record'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    );

    RAISE FND_API.G_EXC_ERROR;
  end if;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Record'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Record;
--
--
END BIS_BUSINESS_PLAN_VALIDATE_PVT;

/
