--------------------------------------------------------
--  DDL for Package CCT_CUSTOM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_CUSTOM_PUB" AUTHID CURRENT_USER AS
/* $Header: cctrcsts.pls 120.1 2005/06/26 23:50:51 appldev ship $ */

--  PROC accepts ANI and returns ANI as the AGENT ID
PROCEDURE ANI_TO_AGENT (p_ani IN NUMBER,
			p_agent_id OUT nocopy NUMBER); -- replaced IS with ;

--  PROC accepts AGENTNAME and returns the AGENT ID
PROCEDURE AGENT_TO_AGENTID (p_agentname IN VARCHAR2,
			    p_agent_id OUT nocopy NUMBER);
END CCT_CUSTOM_PUB;

 

/
