--------------------------------------------------------
--  DDL for Package Body BIS_BUSINESS_PLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_BUSINESS_PLAN_PUB" AS
/* $Header: BISPBPB.pls 120.0 2005/06/01 16:21:27 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPBPB.pls                                                       |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for managing business plan for the
REM |     Key Performance Framework.
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 14-JUL-1999  irchen   Creation                                        |
REM | 19-May-2004  rpenneru Modified for bug#3593361                        |
REM +=======================================================================+
*/
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_BUSINESS_PLAN_PUB';
--
--
Procedure Retrieve_Business_Plans
( p_api_version       IN  NUMBER
, x_Business_Plan_Tbl OUT NOCOPY BIS_BUSINESS_PLAN_PUB.Business_Plan_Tbl_Type
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  BIS_BUSINESS_PLAN_PVT.Retrieve_Business_Plans
  ( p_api_version       => p_api_version
  , x_Business_Plan_Tbl => x_Business_Plan_Tbl
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Business_Plans'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );

END Retrieve_Business_Plans;
--
Procedure Retrieve_Business_Plan
( p_api_version       IN  NUMBER
, p_Business_Plan_Rec IN  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, x_Business_Plan_Rec OUT NOCOPY BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_Business_Plan_Rec BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type;
BEGIN

  BIS_BUSINESS_PLAN_PVT.Value_ID_Conversion
  ( p_api_version       => 1.0
  , p_Business_Plan_Rec => p_Business_Plan_Rec
  , x_Business_Plan_Rec => l_Business_Plan_Rec
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_tbl
  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_PLAN_ID'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Business_Plan'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    );
    RAISE FND_API.G_EXC_ERROR;
  end if;

  BIS_BUSINESS_PLAN_PVT.Retrieve_Business_Plan
  ( p_api_version       => 1.0
  , p_Business_Plan_Rec => l_Business_Plan_Rec
  , x_Business_Plan_Rec => x_Business_Plan_Rec
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );


EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Business_Plan'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );

END Retrieve_Business_Plan;
--
Procedure Translate_Business_Plan
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
, p_Business_Plan_Rec IN  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_Business_Plan_Rec BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type;
BEGIN

  BIS_BUSINESS_PLAN_PVT.Value_ID_Conversion
  ( p_api_version       => p_api_version
  , p_Business_Plan_Rec => p_Business_Plan_Rec
  , x_Business_Plan_Rec => l_Business_Plan_Rec
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_tbl
  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_PLAN_ID'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Translate_Business_Plan'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    );
    RAISE FND_API.G_EXC_ERROR;
  end if;

  BIS_BUSINESS_PLAN_PVT.Translate_Business_Plan
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Business_Plan_Rec => l_Business_Plan_Rec
  , p_owner             => p_owner
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Translate_Business_Plan'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );

END Translate_Business_Plan ;
--
Procedure Load_Business_Plan
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Business_Plan_Rec IN  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_Business_Plan_Rec BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type;
BEGIN

  l_Business_Plan_Rec := p_Business_Plan_Rec;

  BEGIN

  BIS_BUSINESS_PLAN_PVT.Value_ID_Conversion
  ( p_api_version       => p_api_version
  , p_Business_Plan_Rec => p_Business_Plan_Rec
  , x_Business_Plan_Rec => l_Business_Plan_Rec
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_tbl
  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_PLAN_ID'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Load_Business_Plan'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;

    BIS_BUSINESS_PLAN_PVT.Update_Business_Plan
    ( p_api_version       => p_api_version
    , p_commit            => p_commit
    , p_validation_level  => p_validation_level
    , p_Business_Plan_Rec => l_Business_Plan_Rec
    , p_owner             => p_owner
    , x_return_status     => x_return_status
    , x_error_Tbl         => x_error_Tbl
    );

  EXCEPTION
   WHEN NO_DATA_FOUND OR FND_API.G_EXC_ERROR THEN

     BIS_BUSINESS_PLAN_PVT.Create_Business_Plan
     ( p_api_version       => p_api_version
     , p_commit            => p_commit
     , p_validation_level  => p_validation_level
     , p_Business_Plan_Rec => l_Business_Plan_Rec
     , p_owner             => p_owner
     , x_return_status     => x_return_status
     , x_error_Tbl         => x_error_Tbl
     );

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Update_Business_Plan'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END;

EXCEPTION
   WHEN NO_DATA_FOUND OR FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Load_Business_Plan'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );

END Load_Business_Plan ;
--
END BIS_BUSINESS_PLAN_PUB;

/
