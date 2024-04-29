--------------------------------------------------------
--  DDL for Package Body BIS_WORKFLOW_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_WORKFLOW_PROCESS_PVT" AS
/* $Header: BISVWFPB.pls 115.7 99/09/19 11:20:50 porting ship  $ */

G_PKG_NAME CONSTANT varchar2(30) := 'BIS_WORKFLOW_PROCESS_PVT';

PROCEDURE Retrieve_WorkFlows
( p_api_version   IN  number
, x_WORKFLOW_Tbl  out WORKFLOW_Tbl_Type
, x_return_status OUT VARCHAR2
, x_error_tbl     OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
i NUMBER;
cursor wf is
         select wf.name,
                wf.display_name
         from wf_item_types_vl wf
         where wf.name like '%BISW%'
         order by wf.name;
l_rec    WORKFLOW_Rec_Type;
BEGIN

  i := 0;
  for cr in wf loop
    i := i+1;
    x_WORKFLOW_Tbl(i).Item_Type          := cr.name;
    x_WORKFLOW_Tbl(i).display_name       := cr.display_name;
  end loop;

END Retrieve_WorkFlows;

PROCEDURE Retrieve_WorkFlow_Processes
( p_api_version          IN  number
, x_WORKFLOW_PROCESS_Tbl out WORKFLOW_PROCESS_Tbl_Type
, x_return_status        OUT VARCHAR2
, x_error_tbl            OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

i NUMBER;
cursor wf_process is
         select wf.item_type,
                wf.name ,
                wf.display_name
         from wf_activities_vl wf
         where wf.item_type like '%BISW%'
         and type = 'PROCESS'
         and wf.begin_date <= sysdate
         and NVL(wf.end_date,sysdate) >= sysdate
         order by wf.item_type;
l_rec WORKFLOW_PROCESS_Rec_Type;
BEGIN

  i := 0;
  for cr in wf_process loop
    i := i+1;
    x_WORKFLOW_PROCESS_Tbl(i).Item_Type          := cr.item_type;
    x_WORKFLOW_PROCESS_Tbl(i).process_short_name := cr.name;
    x_WORKFLOW_PROCESS_Tbl(i).process_name       := cr.display_name;
  end loop;

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
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_WorkFlow_Processes'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_WorkFlow_Processes;

-- This procedure is not used anymore
PROCEDURE Retrieve_WF_Process_Name
( p_api_version          IN  number
, p_wf_process_short_name IN  VARCHAR2
, x_wf_process_name       OUT VARCHAR2
, x_return_status         OUT VARCHAR2
, x_error_tbl             OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if BIS_UTILITIES_PUB.Value_Not_Missing(p_wf_process_short_name)
     = FND_API.G_TRUE
   AND  BIS_UTILITIES_PUB.Value_Not_NULL(p_wf_process_short_name)
     = FND_API.G_TRUE then

    select wf.display_name
    into x_wf_process_name
    from wf_activities_vl wf
    where wf.item_type = 'BISKPIWF'
    and type = 'PROCESS'
    and wf.name = p_wf_process_short_name
    and wf.begin_date <= sysdate
    and NVL(wf.end_date,sysdate) >= sysdate;

  else
    -- POPULATE THE ERROR TABLE
    RAISE FND_API.G_EXC_ERROR;
  end if;


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
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_WF_Process_Name'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_WF_Process_Name;
--
PROCEDURE Validate_WF_Process_Short_Name
( p_api_version           IN  NUMBER
, p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_wf_process_short_name IN  VARCHAR2
, x_return_status         OUT VARCHAR2
, x_error_Tbl             OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

CURSOR val_cur is
  select 1
  from wf_activities_vl wf
  where wf.item_type like '%BISW%'
  and type = 'PROCESS'
  and wf.name = p_wf_process_short_name
  and wf.begin_date <= sysdate
  and NVL(wf.end_date,sysdate) >= sysdate;

l_dummy number;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  if(   BIS_UTILITIES_PUB.Value_Not_Missing(p_wf_process_short_name)
        =FND_API.G_TRUE
    AND BIS_UTILITIES_PUB.Value_Not_NULL(p_wf_process_short_name)
        =FND_API.G_TRUE ) then
    open val_cur;
    fetch val_cur into l_dummy;
    if (val_cur%NOTFOUND) then
      close val_cur;
      -- POPULATE THE TABLE
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_WORKFLOW_PROCESS'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Validate_WF_Process_Short_Name'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      );
      RAISE FND_API.G_EXC_ERROR;
    end if;
    close val_cur;
  end if;

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
      , p_error_proc_name   => G_PKG_NAME||'.Validate_WF_Process_Short_Name'
      );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_WF_Process_Short_Name;
--
PROCEDURE Value_ID_Conversion
( p_api_version                IN NUMBER
, p_wf_process_Name            IN VARCHAR2
, x_wf_process_short_name      OUT VARCHAR2
, x_return_status              OUT VARCHAR2
, x_error_Tbl                  OUT BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if BIS_UTILITIES_PUB.Value_Not_Missing(p_wf_process_name)=FND_API.G_TRUE
  AND BIS_UTILITIES_PUB.Value_Not_NULL(p_wf_process_name)=FND_API.G_TRUE then
    select wf.name
      into x_wf_process_short_name
      from wf_activities_vl wf
      where wf.item_type = 'BISKPIWF'
      and type = 'PROCESS'
      and wf.display_name = p_wf_process_name
      and wf.begin_date <= sysdate
      and NVL(wf.end_date,sysdate) >= sysdate;
  else
    -- populate the table
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_WF_PROCESS_NAME_IS_NULL'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      );
    RAISE FND_API.G_EXC_ERROR;
  end if;

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
END BIS_WORKFLOW_PROCESS_PVT;

/
