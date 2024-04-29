--------------------------------------------------------
--  DDL for Package IEC_AGT_ASSN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_AGT_ASSN_PUB" AUTHID CURRENT_USER AS
/* $Header: IECASNS.pls 115.4 2003/11/10 20:23:57 anayak noship $ */

TYPE ASSIGNMENT_CURSOR 	is REF CURSOR;

-- Used by AO Plugin to get agent to campaign and schedule assignments
-- Returns all agents' assignments (assigned directly or to group)
PROCEDURE GET_ALL_AGENT_CPN_SCH_ASSNS
  ( X_ASSIGNMENTS 	OUT NOCOPY ASSIGNMENT_CURSOR  );

-- Used by Blending to get agent to campaign assignments
-- Returns all agents' assignments (assigned directly or to group)
PROCEDURE GET_WB_ALL_AGENT_CPN_ASSNS
  ( X_ASSIGNMENTS 	OUT NOCOPY ASSIGNMENT_CURSOR  );

-- Used by Blending to get agent to campaign assignments
-- Returns a specified agent's assignments (assigned directly or to group)
PROCEDURE GET_WB_AGENT_CPN_ASSNS
  ( P_RESOURCE_ID		IN  NUMBER
  , X_ASSIGNMENTS 	OUT NOCOPY ASSIGNMENT_CURSOR  );

-- Used by Blending to get the campaign queue counts
-- Campaigns/Schedules not assigned to agents are excluded from the counts
PROCEDURE GET_WB_ASSIGNED_CPN_COUNTS
  ( X_CPN_COUNTS 	OUT NOCOPY ASSIGNMENT_CURSOR);

END IEC_AGT_ASSN_PUB;

 

/
