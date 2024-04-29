--------------------------------------------------------
--  DDL for Package Body BIS_RESPONSIBILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_RESPONSIBILITY_PVT" AS
/* $Header: BISVRSPB.pls 120.1 2006/04/10 07:57:30 psomesul noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVRSPB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for managing Responsibilities for PMF
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 15-MAR-99 Ansingha Creation
REM | 19-MAY-2005  visuri   GSCC Issues bug 4363854                         |
REM | 10-APR-05 psomesul Bug#5140269 - PERFORMANCE ISSUE WITH TARGET OWNER  |
REM |              LOV IN PMF PAGES - replaced WF_ROLES with WF_ROLE_LOV_VL |
REM +=======================================================================+
*/
--
-- PROCEDUREs
--
G_PKG_NAME CONSTANT varchar2(30) := 'BIS_RESPONSIBILITY_PVT';


Procedure Retrieve_User_Responsibilities
( p_api_version         IN NUMBER
, p_user_id             IN NUMBER Default BIS_COMMON_UTILS.G_DEF_NUM
, x_Responsibility_Tbl  OUT NOCOPY BIS_RESPONSIBILITY_PVT.Responsibility_Tbl_Type
, x_return_status       OUT NOCOPY  VARCHAR2
, x_error_tbl           OUT NOCOPY  BIS_UTILITIES_PUB.Error_tbl_Type
)
IS
cursor rsp_cur is
 select a.responsibility_id,
        a.responsibility_key,
        a.responsibility_name
 from fnd_responsibility_vl a,
      fnd_user_resp_groups b
 where b.user_id = p_user_id
 and   b.responsibility_id = a.responsibility_id
 and   b.start_date <= sysdate
 and   (b.end_date is null or b.end_date >= sysdate)
 and   a.start_date <= sysdate
 and   (a.end_date is null or a.end_date >= sysdate)
 and   a.version = 'W'
 order by responsibility_name;

l_rec             BIS_RESPONSIBILITY_PVT.Responsibility_Rec_Type;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR cr in rsp_cur LOOP
    l_rec.Responsibility_ID         := cr.RESPONSIBILITY_ID;
    l_rec.Responsibility_Short_Name := cr.RESPONSIBILITY_KEY;
    l_rec.Responsibility_Name       := cr.RESPONSIBILITY_NAME;
    x_Responsibility_Tbl(x_Responsibility_Tbl.COUNT+1) := l_rec;
  END LOOP;


EXCEPTION
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
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_User_Responsibilities'
      );

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_User_Responsibilities;
--
Procedure Retrieve_User_Responsibilities
( p_api_version            IN NUMBER
, p_user_id                IN NUMBER Default BIS_COMMON_UTILS.G_DEF_NUM
, p_Responsibility_version IN VARCHAR
, x_Responsibility_Tbl     OUT NOCOPY  BIS_Responsibility_PVT.Responsibility_Tbl_Type
, x_return_status          OUT NOCOPY  VARCHAR2
, x_error_tbl              OUT NOCOPY  BIS_UTILITIES_PUB.Error_tbl_Type
)
IS
cursor rsp_cur(p_version VARCHAR2) is
 select a.responsibility_id,
        a.responsibility_key,
        a.responsibility_name
 from fnd_responsibility_vl a,
      fnd_user_resp_groups b
 where b.user_id = p_user_id
 and   b.responsibility_id = a.responsibility_id
 and   b.start_date <= sysdate
 and   (b.end_date is null or b.end_date >= sysdate)
 and   a.start_date <= sysdate
 and   (a.end_date is null or a.end_date >= sysdate)
 and   a.version like p_version
 order by responsibility_name;

l_rec             BIS_RESPONSIBILITY_PVT.Responsibility_Rec_Type;
l_version         VARCHAR2(1);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_version := p_Responsibility_version;

  IF BIS_UTILITIES_PUB.Value_Missing(l_version) = FND_API.G_TRUE
  OR BIS_UTILITIES_PUB.Value_Null(l_version) = FND_API.G_TRUE
  THEN l_version := '%';
  END IF;

  FOR cr in rsp_cur(l_version) LOOP
    l_rec.Responsibility_ID         := cr.RESPONSIBILITY_ID;
    l_rec.Responsibility_Short_Name := cr.RESPONSIBILITY_KEY;
    l_rec.Responsibility_Name       := cr.RESPONSIBILITY_NAME;
    x_Responsibility_Tbl(x_Responsibility_Tbl.COUNT+1) := l_rec;
  END LOOP;

EXCEPTION
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
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_User_Responsibilities'
      );

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_User_Responsibilities;
--
Procedure Retrieve_All_Responsibilities
( p_api_version         IN NUMBER
, x_Responsibility_Tbl  OUT NOCOPY  BIS_RESPONSIBILITY_PVT.Responsibility_Tbl_Type
, x_return_status       OUT NOCOPY  VARCHAR2
, x_error_tbl           OUT NOCOPY  BIS_UTILITIES_PUB.Error_tbl_Type
)
IS
cursor resp_cur is
select RESPONSIBILITY_ID
     , RESPONSIBILITY_KEY
     , RESPONSIBILITY_NAME
from fnd_responsibility_vl
where VERSION='W'
and start_date <= sysdate
 and nvl(end_date, sysdate) >= sysdate
order by RESPONSIBILITY_NAME;
l_rec BIS_RESPONSIBILITY_PVT.Responsibility_Rec_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  for cr in resp_cur LOOP
    l_rec.Responsibility_ID         := cr.RESPONSIBILITY_ID;
    l_rec.Responsibility_Short_Name := cr.RESPONSIBILITY_KEY;
    l_rec.Responsibility_Name       := cr.RESPONSIBILITY_NAME;
    x_Responsibility_Tbl(x_Responsibility_Tbl.COUNT+1) := l_rec;
  END LOOP;

EXCEPTION
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
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_All_Responsibilities'
      );

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_All_Responsibilities;
--
Procedure Retrieve_Responsibility
( p_api_version         IN NUMBER
, p_Responsibility_Rec  IN  BIS_Responsibility_PVT.Responsibility_rec_Type
, x_Responsibility_Rec  OUT NOCOPY  BIS_Responsibility_PVT.Responsibility_rec_Type
, x_return_status       OUT NOCOPY  VARCHAR2
, x_error_tbl           OUT NOCOPY  BIS_UTILITIES_PUB.Error_tbl_Type
)
IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    select RESPONSIBILITY_ID
         , RESPONSIBILITY_KEY
         , RESPONSIBILITY_NAME
    into x_Responsibility_Rec.RESPONSIBILITY_ID
       , x_Responsibility_Rec.RESPONSIBILITY_SHORT_NAME
       , x_Responsibility_Rec.RESPONSIBILITY_NAME
    from fnd_responsibility_vl
    where VERSION='W'
    and start_date <= sysdate
    and nvl(end_date, sysdate) >= sysdate
    and RESPONSIBILITY_ID=p_Responsibility_Rec.RESPONSIBILITY_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --Added last two params
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Responsibility'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );
  END;

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
       --Added last two params
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Responsibility'
      , p_error_table       => x_error_tbl
      , x_error_table       => x_error_tbl
      );

      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_Responsibility;

PROCEDURE Validate_Def_Notify_Resp_Id
( p_api_version      IN  NUMBER
  , p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
  , p_Def_Notify_Resp_Id IN  NUMBER
, x_return_status    OUT NOCOPY  VARCHAR2
, x_error_Tbl        OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;
EXCEPTION
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
      , p_error_proc_name   => G_PKG_NAME||'.DFR_Value_ID_Conversion'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Def_Notify_Resp_Id;
--
PROCEDURE Retrieve_Notify_Resp_Name
( p_api_version            IN  NUMBER
, p_Notify_resp_short_name IN  VARCHAR2
, x_Notify_resp_name       OUT NOCOPY  VARCHAR2
, x_return_status          OUT NOCOPY  VARCHAR2
, x_error_Tbl              OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

CURSOR cr_wf_role IS
  SELECT DISPLAY_NAME
  FROM wf_role_lov_vl
  WHERE NAME =  p_Notify_resp_short_name;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN cr_wf_role;
  FETCH cr_wf_role INTO x_notify_resp_name;
  CLOSE cr_wf_role;

EXCEPTION
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
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Notify_Resp_Name'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_Notify_Resp_Name;
--
PROCEDURE Validate_Notify_Resp_ID

( p_api_version           IN  NUMBER
, p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Notify_Resp_ID        IN  NUMBER
, x_return_status         OUT NOCOPY  VARCHAR2
, x_error_Tbl             OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  --added the status
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;
EXCEPTION
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
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Notify_Resp_ID'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Validate_Notify_Resp_ID;
--
PROCEDURE Value_ID_Conversion
( p_api_version               IN  NUMBER
, p_Responsibility_Short_Name IN  VARCHAR2
, p_Responsibility_Name       IN  VARCHAR2
, x_Responsibility_ID         OUT NOCOPY  NUMBER
, x_return_status             OUT NOCOPY  VARCHAR2
, x_error_Tbl                 OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;
EXCEPTION
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
PROCEDURE DFR_Value_ID_Conversion
( p_api_version                  IN  NUMBER
, p_DF_Responsibility_Short_Name IN  VARCHAR2
, p_DF_Responsibility_Name       IN  VARCHAR2
, x_DF_Responsibility_ID         OUT NOCOPY  NUMBER

, x_return_status                OUT NOCOPY  VARCHAR2
, x_error_Tbl                    OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  NULL;
EXCEPTION
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
      , p_error_proc_name   => G_PKG_NAME||'.DFR_Value_ID_Conversion'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END DFR_Value_ID_Conversion;
--
-- removes the responsibilities from p_all_security
-- which are in p_security
PROCEDURE RemoveDuplicates
( p_security     in  BIS_RESPONSIBILITY_PVT.Responsibility_Tbl_type
, p_all_security in  BIS_RESPONSIBILITY_PVT.Responsibility_Tbl_type
, x_all_security out NOCOPY  BIS_RESPONSIBILITY_PVT.Responsibility_Tbl_type
)
is
l_unique BOOLEAN;
l_rec    BIS_RESPONSIBILITY_PVT.Responsibility_Rec_Type;
begin
--
  for i in 1 .. p_all_security.count loop
    l_rec := p_all_security(i);
    l_unique := true;
--
    for j in 1 .. p_security.count loop
      if (p_security(j).Responsibility_ID = l_rec.Responsibility_ID) then
        l_unique := false;
        exit;
      end if;
    end loop;
--
    if (l_unique) then
      x_all_security(x_all_security.count + 1) := l_rec;
    end if;
--
  end loop;
--
end RemoveDuplicates;
--
Procedure Get_Notify_Resp_AK_Info
( p_notify_responsibility_rec
    IN BIS_Responsibility_PVT.Notify_Responsibility_Rec_type
, x_attribute_app_id    OUT NOCOPY  NUMBER
, x_attribute_code      OUT NOCOPY  VARCHAR2
, x_attribute_name      OUT NOCOPY  VARCHAR2
, x_region_app_id       OUT NOCOPY  NUMBER
, x_region_code         OUT NOCOPY  VARCHAR2
)
IS

  l_notify_responsibility_rec
     BIS_Responsibility_PVT.Notify_Responsibility_Rec_type;
  l_attribute_app_id    NUMBER := BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID;
  l_attribute_code      VARCHAR2(32000);
  l_attribute_name      VARCHAR2(32000);
  l_region_app_id       NUMBER := BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID;
  l_region_code         VARCHAR2(32000);

  CURSOR cr_ak_data IS
    SELECT
          attribute_code
    FROM ak_region_items_vl
    WHERE region_code = l_region_code
    AND   region_application_id = l_region_app_id
    AND   attribute_application_id = l_attribute_app_id;

BEGIN

  --  htp.p('Get_Notify_resp_AK_Info'||g_br);

  l_region_code := G_WF_ROLE_AK_REGION;

  FOR cr IN cr_ak_data LOOP
    -- htp.p('cr.attribute_code: '||cr.attribute_code||g_br);
    IF UPPER(cr.attribute_code) = G_WF_ROLE_SHORT_NAME_AK
    THEN
      l_attribute_code := cr.attribute_code;
    ELSE
      l_attribute_name := cr.attribute_code;
    END IF;
  END LOOP;

  x_attribute_app_id := l_attribute_app_id;
  x_attribute_code   :=	l_attribute_code;
  x_attribute_name   :=	l_attribute_name;
  x_region_app_id    :=	l_region_app_id;
  x_region_code      :=	l_region_code;

/*
  htp.p('notify role: '||
  l_notify_responsibility_rec.notify_resp_short_name||
  ' - region code: '||l_region_code||
  ' - attribute code: '||l_attribute_code||
  ' - attribute_name: '||l_attribute_name||g_br);
*/

EXCEPTION
  WHEN OTHERS THEN
    htp.p('Error in Get_Notify_Resp_AK_Info: '||SQLERRM);

END Get_Notify_Resp_AK_Info;

--
END BIS_RESPONSIBILITY_PVT;

/
