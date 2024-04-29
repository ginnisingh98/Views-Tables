--------------------------------------------------------
--  DDL for Package Body BIS_APPLICATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_APPLICATION_PVT" AS
/* $Header: BISVAPPB.pls 115.6 99/09/17 19:17:15 porting ship  $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVAPPS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public record specifications for application
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 15-MAR-99 Ansingha Creation
REM |
REM +=======================================================================+
*/
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_APPLICATION_PVT';
--
PROCEDURE Retrieve_Applications
( p_api_version     IN  NUMBER
, x_Application_tbl OUT BIS_Application_PVT.Application_Tbl_Type
, x_return_status   OUT VARCHAR2
, x_error_Tbl       OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

cursor app_cursor is
select application_id, APPLICATION_SHORT_NAME, APPLICATION_NAME
from fnd_application_vl
ORDER by UPPER(APPLICATION_NAME);

l_rec Application_Rec_Type;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  for cr in app_cursor LOOP

    l_rec.Application_ID         := cr.Application_ID;
    l_rec.Application_Short_Name := cr.Application_Short_Name;
    l_rec.Application_Name       := cr.Application_Name;
    x_Application_tbl(x_Application_tbl.COUNT + 1) := l_rec;

  END LOOP;

  IF app_cursor%ISOPEN THEN CLOSE app_cursor; END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF app_cursor%ISOPEN THEN CLOSE app_cursor; END IF;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF app_cursor%ISOPEN THEN CLOSE app_cursor; END IF;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF app_cursor%ISOPEN THEN CLOSE app_cursor; END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF app_cursor%ISOPEN THEN CLOSE app_cursor; END IF;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Applications'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_Applications;
--
-- Validates measure
PROCEDURE Validate_Application
( p_api_version     IN  NUMBER
, p_Application_Rec IN  BIS_Application_PVT.Application_Rec_Type
, x_return_status   OUT VARCHAR2
, x_error_Tbl       OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_dummy  number;

CURSOR chk_application is
  select 1
  from   fnd_application_vl
  where  Application_id = p_Application_Rec.Application_id;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if (p_Application_Rec.Application_id <>
      BIS_Application_PVT.G_NO_APPLICATION_ID) then
    if(BIS_UTILITIES_PUB.Value_Not_Missing(p_Application_Rec.Application_id)
                                                         =FND_API.G_TRUE) then
      open chk_application;
      fetch chk_application into l_dummy;
      if (chk_application%NOTFOUND) then
  	close chk_application;
  	-- POPULATE THE error table
    	BIS_UTILITIES_PVT.Add_Error_Message
    	( p_error_msg_name    => 'BIS_INVALID_APPLICAIOTN_ID'
    	, p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    	, p_error_proc_name   => G_PKG_NAME||'.Validate_Application'
    	, p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        );

  	RAISE FND_API.G_EXC_ERROR;
      end if;
      close chk_application;
    end if;
  end if;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF chk_application%ISOPEN THEN CLOSE chk_application; END IF;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF chk_application%ISOPEN THEN CLOSE chk_application; END IF;
      RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF chk_application%ISOPEN THEN CLOSE chk_application; END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF chk_application%ISOPEN THEN CLOSE chk_application; END IF;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Applications'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Application;
--
--
-- Value - ID conversion
PROCEDURE Value_ID_Conversion
( p_api_version     IN  NUMBER
, p_Application_Rec IN  BIS_Application_PVT.Application_Rec_Type
, x_Application_Rec OUT BIS_Application_PVT.Application_Rec_Type
, x_return_status   OUT VARCHAR2
, x_error_Tbl       OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_Application_Rec := p_Application_Rec;

  BIS_Application_PVT.Value_ID_Conversion
  ( p_api_version
  , p_Application_Rec.Application_Short_Name
  , p_Application_Rec.Application_Name
  , x_Application_Rec.Application_ID
  , x_return_status
  , x_error_Tbl
  );

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
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Applications'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_ID_Conversion;
--
PROCEDURE Value_ID_Conversion
( p_api_version        IN  NUMBER
, p_Application_Short_Name IN  VARCHAR2
, p_Application_Name       IN  VARCHAR2
, x_Application_ID         OUT NUMBER
, x_return_status      OUT VARCHAR2
, x_error_Tbl          OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

BEGIN
  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  if (BIS_UTILITIES_PUB.Value_Not_Missing(p_Application_Short_Name)
                       = FND_API.G_TRUE) then
    SELECT Application_id into x_Application_ID
    FROM fnd_application_vl
    WHERE Application_short_name = p_Application_Short_Name;
  elsif (BIS_UTILITIES_PUB.Value_Not_Missing(p_Application_Name)
                       = FND_API.G_TRUE) then
    SELECT Application_id into x_Application_ID
    FROM fnd_application_vl
    WHERE Application_name = p_Application_Name;
  else
    -- POLPULATE ERROR TABLE
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
      , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_ID_Conversion;
--
END BIS_Application_PVT;

/
