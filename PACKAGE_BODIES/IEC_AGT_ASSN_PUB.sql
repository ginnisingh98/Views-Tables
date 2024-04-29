--------------------------------------------------------
--  DDL for Package Body IEC_AGT_ASSN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_AGT_ASSN_PUB" AS
/* $Header: IECASNB.pls 115.6 2004/04/29 22:47:00 anayak noship $ */

-- Used by AO Plugin to get agent to campaign and schedule assignments
-- Returns all agents' assignments (assigned directly or to group)
PROCEDURE GET_ALL_AGENT_CPN_SCH_ASSNS
  ( X_ASSIGNMENTS 	OUT NOCOPY ASSIGNMENT_CURSOR )
AS
   	l_assignment_cursor ASSIGNMENT_CURSOR;
   	l_assignment_stmt   VARCHAR2(1000);

BEGIN

   	l_assignment_stmt := 	' SELECT ' ||
													'	astcamp.resource_id RESOURCE_ID, ' ||
													'	amssched.campaign_id CAMPAIGN_ID, ' ||
													'	astcamp.campaign_id SCHEDULE_ID ' ||
													' FROM ' ||
													'	AMS_CAMPAIGN_SCHEDULES_B amssched, ' ||
													'	AST_RS_CAMPAIGNS astcamp ' ||
													' WHERE ' ||
													'	astcamp.campaign_id = amssched.schedule_id ' ||
													' UNION ' ||
													' SELECT ' ||
													'	grpmem.resource_id RESOURCE_ID, ' ||
													'	amssched.campaign_id CAMPAIGN_ID, ' ||
													'	grpcamp.campaign_id SCHEDULE_ID ' ||
													' FROM ' ||
													'	AMS_CAMPAIGN_SCHEDULES_B amssched, ' ||
													'	AST_GRP_CAMPAIGNS grpcamp, ' ||
													'	JTF_RS_GROUP_MEMBERS grpmem, ' ||
													'	JTF_RS_GROUPS_DENORM grpdenorm ' ||
													' WHERE ' ||
													'	grpmem.group_id = grpdenorm.group_id ' ||
													'	and grpcamp.group_id = grpdenorm.parent_group_id ' ||
													'	and grpcamp.campaign_id = amssched.schedule_id ';

	OPEN l_assignment_cursor for l_assignment_stmt;

	X_ASSIGNMENTS := l_assignment_cursor;

	return;

END GET_ALL_AGENT_CPN_SCH_ASSNS;


-- Used by Blending to get agent to campaign assignments and counts
-- Returns all agents' assignments (assigned directly or to group)
PROCEDURE GET_WB_ALL_AGENT_CPN_ASSNS
  ( X_ASSIGNMENTS 	OUT NOCOPY ASSIGNMENT_CURSOR  )
AS
   	l_assignment_cursor ASSIGNMENT_CURSOR;
   	l_assignment_stmt   VARCHAR2(350);

BEGIN

   	l_assignment_stmt := ' SELECT RESOURCE_ID, IEU_PARAM_PK_VALUE CAMPAIGN_ID, QUEUE_COUNT ' ||
   						 ' FROM IEC_ADV_OUTB_WORKNODE_UWQ_V ';

	OPEN l_assignment_cursor for l_assignment_stmt;

	X_ASSIGNMENTS := l_assignment_cursor;

	return;

END GET_WB_ALL_AGENT_CPN_ASSNS;


-- Used by Blending to get agent to campaign assignments and counts
-- Returns a specified agent's assignments (assigned directly or to group)
PROCEDURE GET_WB_AGENT_CPN_ASSNS
  ( P_RESOURCE_ID		IN  NUMBER
  , X_ASSIGNMENTS 	OUT NOCOPY ASSIGNMENT_CURSOR  )
AS
   	l_assignment_cursor ASSIGNMENT_CURSOR;
   	l_assignment_stmt   VARCHAR2(350);

BEGIN

   	l_assignment_stmt := ' SELECT RESOURCE_ID, IEU_PARAM_PK_VALUE CAMPAIGN_ID, QUEUE_COUNT ' ||
   						 ' FROM IEC_ADV_OUTB_WORKNODE_UWQ_V ' ||
   						 ' WHERE RESOURCE_ID = :1 ';

	OPEN l_assignment_cursor for l_assignment_stmt using P_RESOURCE_ID;

	X_ASSIGNMENTS := l_assignment_cursor;

	return;

END GET_WB_AGENT_CPN_ASSNS;


-- Used by Blending to get the campaign queue counts
-- Campaigns/Schedules not assigned to agents are excluded from the counts
PROCEDURE GET_WB_ASSIGNED_CPN_COUNTS
  ( X_CPN_COUNTS 	OUT NOCOPY ASSIGNMENT_CURSOR )
 AS
   	l_cpn_count_cursor ASSIGNMENT_CURSOR;
   	l_cpn_count_stmt   VARCHAR2(350);

BEGIN

   	l_cpn_count_stmt := 'SELECT	CAMPAIGN_ID, CAMPAIGN_NAME, SUM(QUEUE_COUNT) ' ||
   						' FROM ( ' ||
   						' 		 SELECT CAMPAIGN_ID, CAMPAIGN_NAME, SCHEDULE_ID, QUEUE_COUNT ' ||
   						' 		 FROM IEC_AGENT_WORK_ASSIGNMENTS_V ' ||
   						' 		 UNION	' ||
   						' 		 SELECT CAMPAIGN_ID, CAMPAIGN_NAME, SCHEDULE_ID, QUEUE_COUNT ' ||
   						'		 FROM IEC_GROUP_WORK_ASSIGNMENTS_V ) ' ||
   						' GROUP BY CAMPAIGN_ID, CAMPAIGN_NAME';

	OPEN l_cpn_count_cursor for l_cpn_count_stmt;

	X_CPN_COUNTS := l_cpn_count_cursor;

	return;

END GET_WB_ASSIGNED_CPN_COUNTS;


END IEC_AGT_ASSN_PUB;

/
