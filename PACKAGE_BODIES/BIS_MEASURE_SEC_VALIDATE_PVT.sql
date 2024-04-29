--------------------------------------------------------
--  DDL for Package Body BIS_MEASURE_SEC_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_MEASURE_SEC_VALIDATE_PVT" AS
/* $Header: BISVMSVB.pls 115.6 99/09/19 11:20:30 porting ship  $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVTVLS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for validating items in the MEASUREs record
REM | NOTES                                                                 |
REM |                                                                       |
REM |
REM +=======================================================================+
*/
--
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_MEASURE_SEC_VALIDATE_PVT';
--
--
PROCEDURE Validate_Target_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_SEC_Rec  IN  BIS_MEASURE_SECURITY_PUB.MEASURE_Security_Rec_Type
, x_return_status    OUT VARCHAR2
, x_error_Tbl        OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_dummy  number;

CURSOR chk_target_level is
  select 1
  from   bis_target_levels
  where  target_level_id = p_MEASURE_SEC_Rec.Target_Level_Id;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  if(BIS_UTILITIES_PUB.Value_Not_Missing(p_MEASURE_SEC_Rec.Target_Level_Id)
     = FND_API.G_TRUE
   AND BIS_UTILITIES_PUB.Value_Not_NULL(p_MEASURE_SEC_Rec.Target_Level_Id)
     = FND_API.G_TRUE) then
    open chk_target_level;
    fetch chk_target_level into l_dummy;
    if (chk_target_level%NOTFOUND) then
      close chk_target_level;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_MSR_SECURITY_VALUE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Target_Level_ID'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      );
      RAISE FND_API.G_EXC_ERROR;
    end if;
    close chk_target_level;
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
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Target_Level_ID'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Target_Level_ID;
--
PROCEDURE Validate_Responsibility_Id
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_SEC_Rec  IN  BIS_MEASURE_SECURITY_PUB.MEASURE_Security_Rec_Type
, x_return_status    OUT VARCHAR2
, x_error_Tbl        OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  -- needs to be filled in
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;

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
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Responsibility_Id'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Responsibility_Id;
--
PROCEDURE Validate_Record
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_MEASURE_SEC_Rec  IN  BIS_MEASURE_SECURITY_PUB.MEASURE_Security_Rec_Type
, x_return_status    OUT VARCHAR2
, x_error_Tbl        OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  -- Do not need to do anything
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;

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
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Record;
--
--
END BIS_MEASURE_SEC_VALIDATE_PVT;

/
