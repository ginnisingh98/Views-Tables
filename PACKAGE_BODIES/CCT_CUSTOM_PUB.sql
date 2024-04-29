--------------------------------------------------------
--  DDL for Package Body CCT_CUSTOM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_CUSTOM_PUB" AS
/* $Header: cctrcstb.pls 120.0 2005/06/02 10:08:22 appldev noship $ */

--  PROC accepts ANI and returns ANI as the AGENT ID
PROCEDURE ANI_TO_AGENT (p_ani IN NUMBER,
				    p_agent_id OUT nocopy NUMBER) IS


BEGIN

   p_agent_id := p_ani;


END ANI_TO_AGENT;


-- PROC accepts AGENT and returns the AGENT ID
PROCEDURE AGENT_TO_AGENTID (p_agentname IN VARCHAR2,
    p_agent_id OUT nocopy NUMBER) IS

BEGIN

  select b.resource_ID into p_agent_id
  from fnd_user a, JTF_RS_RESOURCE_EXTNS b
  where a.user_name = p_agentname
  and   a.user_id   = b.user_id;


END AGENT_TO_AGENTID;

END CCT_CUSTOM_PUB;

/
