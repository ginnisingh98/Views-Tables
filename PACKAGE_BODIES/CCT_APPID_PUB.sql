--------------------------------------------------------
--  DDL for Package Body CCT_APPID_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_APPID_PUB" as
/* $Header: cctrespb.pls 120.1 2005/11/14 13:49:06 ibyon noship $ */

/*------------------------------------------------------------------------
REM
REM-----------------------------------------------------------------------*/

Function GetApplicationID(
     p_Classification   IN VARCHAR2,
     p_MediaType        IN VARCHAR2,
     p_AgentID          IN NUMBER
  )
Return NUMBER
IS
    l_respID      NUMBER(15);
    l_appID       NUMBER(15);
    CURSOR l_resp_csr IS
    select resp_id from cct_agent_rt_stats
    where attribute1 is not null and attribute1='T' and agent_id=p_AgentID;
Begin
    l_respID:=-1;
    l_appID:=-1;
    OPEN l_resp_csr;
    FETCH l_resp_csr INTO l_respID;
    IF l_resp_csr%NOTFOUND THEN
       l_respID:=-1;
    END IF;
    CLOSE l_resp_csr;
    IEU_UWQ_UTIL_PUB.DETERMINE_SOURCE_APP (l_respID, p_Classification,p_MediaType, l_appID);
    return l_appID;

EXCEPTION
  WHEN OTHERS THEN
     IF l_resp_csr%ISOPEN THEN
      CLOSE l_resp_csr;
     END IF;
     return -1;
END;
END CCT_AppID_Pub;

/
