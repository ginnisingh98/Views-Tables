--------------------------------------------------------
--  DDL for Package Body BIS_TARGET_LEVEL_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_TARGET_LEVEL_VALIDATE_PVT" AS
/* $Header: BISVTLVB.pls 115.15 2003/01/27 13:30:12 arhegde ship $ */
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
REM | 27-JAN-03 arhegde For having different local variables for IN and OUT |
REM |                   parameters (bug#2758428)              	           |
REM +=======================================================================+
*/
--
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_TARGET_LEVEL_VALIDATE_PVT';
--
PROCEDURE Validate_Dimension_Level_Id
( p_api_version      IN  NUMBER
, p_level_id         IN  NUMBER
, p_level_short_name IN  VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_dummy  number;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

CURSOR chk_dimension is
  select 1
  from   bis_Levels
  where  level_id = p_level_id;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  if(   BIS_UTILITIES_PUB.Value_Not_Missing(p_level_id)=FND_API.G_TRUE
    AND BIS_UTILITIES_PUB.Value_Not_NULL(p_level_id)=FND_API.G_TRUE ) then
    open chk_dimension;
    fetch chk_dimension into l_dummy;
    if (chk_dimension%NOTFOUND) then
      close chk_dimension;
      -- POPULATE THE error table
      --added last two parameters
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_DIMENSION_LEVEL_ID'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension_Level_ID'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
    end if;
    close chk_dimension;
  end if;

--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      --added last two parameters
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension_Level_Id'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Validate_Dimension_Level_Id;

PROCEDURE Validate_org_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Validate_Dimension_Level_ID( p_api_version
                       , p_TARGET_LEVEL_Rec.org_Level_ID
                       , p_TARGET_LEVEL_Rec.org_level_Short_Name
                       , x_return_status
                       , x_error_tbl
                       );

--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two parameters
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_org_Level_ID'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_org_Level_ID;
--
PROCEDURE Validate_time_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Validate_Dimension_Level_ID( p_api_version
                       , p_TARGET_LEVEL_Rec.time_Level_ID
                       , p_TARGET_LEVEL_Rec.time_level_Short_Name
                       , x_return_status
                       , x_error_tbl
                       );

--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two parameters
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_time_Level_ID'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_time_Level_ID;
--
--
PROCEDURE Validate_Dimension1_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Validate_Dimension_Level_ID( p_api_version
                       , p_TARGET_LEVEL_Rec.Dimension1_Level_ID
                       , p_TARGET_LEVEL_Rec.Dimension1_level_Short_Name
                       , x_return_status
                       , x_error_tbl
                       );

--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      --added last two parameters
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension1_Level_ID'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Dimension1_Level_ID;
--
PROCEDURE Validate_Dimension2_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Validate_Dimension_Level_ID( p_api_version
                       , p_TARGET_LEVEL_Rec.Dimension2_Level_ID
                       , p_TARGET_LEVEL_Rec.Dimension2_Level_Short_Name
                       , x_return_status
                       , x_error_tbl
                       );


--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two parameters
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension2_Level_ID'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Dimension2_Level_ID;
--
PROCEDURE Validate_Dimension3_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Validate_Dimension_Level_ID( p_api_version
                       , p_TARGET_LEVEL_Rec.Dimension3_Level_ID
                       , p_TARGET_LEVEL_Rec.Dimension3_Level_Short_Name
                       , x_return_status
                       , x_error_tbl
                       );

--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two parameters
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension3_Level_ID'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Dimension3_Level_ID;
--
PROCEDURE Validate_Dimension4_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Validate_Dimension_Level_ID( p_api_version
                       , p_TARGET_LEVEL_Rec.Dimension4_Level_ID
                       , p_TARGET_LEVEL_Rec.Dimension4_Level_Short_Name
                       , x_return_status
                       , x_error_tbl
                       );

--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      --added last two parameters
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension4_Level_ID'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Dimension4_Level_ID;
--
PROCEDURE Validate_Dimension5_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Validate_Dimension_Level_ID( p_api_version
                       , p_TARGET_LEVEL_Rec.Dimension5_Level_ID
                       , p_TARGET_LEVEL_Rec.Dimension5_Level_Short_Name
                       , x_return_status
                       , x_error_tbl
                       );

--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      --added last two parameters
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension5_Level_ID'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Dimension5_Level_ID;
--

PROCEDURE Validate_Dimension6_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Validate_Dimension_Level_ID( p_api_version
                       , p_TARGET_LEVEL_Rec.Dimension6_Level_ID
                       , p_TARGET_LEVEL_Rec.Dimension6_Level_Short_Name
                       , x_return_status
                       , x_error_tbl
                       );

--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      --added last two parameters
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension6_Level_ID'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Dimension6_Level_ID;
--

PROCEDURE Validate_Dimension7_Level_ID
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Validate_Dimension_Level_ID( p_api_version
                       , p_TARGET_LEVEL_Rec.Dimension7_Level_ID
                       , p_TARGET_LEVEL_Rec.Dimension7_Level_Short_Name
                       , x_return_status
                       , x_error_tbl
                       );

--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      --added last two parameters
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension7_Level_ID'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Dimension7_Level_ID;
--

PROCEDURE Validate_WF_Process_Short_Name
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
is
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
begin

   BIS_WORKFLOW_PROCESS_PVT.Validate_WF_Process_Short_Name
   ( p_api_version
   , p_validation_level
   , p_TARGET_LEVEL_Rec.Workflow_Process_Short_Name
   , x_return_status
   , x_error_Tbl
   );

--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      --added last two parameters
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_WF_Process_Short_Name'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Validate_WF_Process_Short_Name;
--
PROCEDURE Validate_Def_Notify_Resp_Id
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

   BIS_RESPONSIBILITY_PVT.Validate_Notify_Resp_ID
   ( p_api_version
   , p_validation_level
   , p_TARGET_LEVEL_Rec.Default_Notify_Resp_ID
   , x_return_status
   , x_error_Tbl
   );


--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      --added last two parameters
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Def_Notify_Resp_Id'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Def_Notify_Resp_Id;
--
PROCEDURE Validate_Df_computed_target_Id
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_TARGET_LEVEL_Rec       IN  BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  BIS_COMPUTED_TARGET_PVT.Validate_Computed_Target_Id
   ( p_api_version
   , p_validation_level
   , p_TARGET_LEVEL_Rec.Computing_function_ID
   , x_return_status
   , x_error_Tbl
   );


--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      --added last two parameters
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Df_computed_target_Id'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Df_computed_target_Id;

--
--
END BIS_TARGET_LEVEL_VALIDATE_PVT;

/
