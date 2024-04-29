--------------------------------------------------------
--  DDL for Package Body CCT_ROUTINGWORKFLOW_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_ROUTINGWORKFLOW_UTL" as
/* $Header: cctucrob.pls 120.0 2005/06/02 09:06:31 appldev noship $ */

------------------------------------------------------------------------------
--  Function	: Get_Result_Code
--  Usage	: Used by the Routing module to get the internal result code
--		  for a given result lookup type and display name
--  Parameters	:
--      p_result_lookup_type       IN      VARCHAR2        Required
--      p_result_display_name      IN      VARCHAR2        Required
--  Return	: VARCHAR2
------------------------------------------------------------------------------
FUNCTION Get_Result_Code (
      p_result_lookup_type       IN      VARCHAR2
    ,  p_result_display_name      IN      VARCHAR2
)
RETURN VARCHAR2 IS
   l_result_code	VARCHAR2(30);
BEGIN
   select lookup_code into l_result_code
   from   wf_lookups
   where  lookup_type = p_result_lookup_type
   and    meaning     = p_result_display_name;

   return l_result_code;

  EXCEPTION
    when OTHERS then
    return NULL;
END Get_Result_Code;

------------------------------------------------------------------------------
--  PROCEDURE	: InsertResults
--  Usage	: Used by all the filter functions to insert agent results
--		  into the CCT_TEMPAGENTS tables
--  Parameters	:
--      p_call_ID       IN      VARCHAR2        Required
--      p_filter_type   IN      VARCHAR2        Required
--      p_agent_ID     IN out nocopy VARCHAR2        Required
------------------------------------------------------------------------------
PROCEDURE InsertResults (
      p_call_ID       IN      VARCHAR2
      , p_filter_type   IN      VARCHAR2
      , p_agent_ID     IN  out nocopy   VARCHAR2
)  IS

  l_dummyAgent  VARCHAR2(32) := '-1';
  i             INTEGER;
BEGIN

   insert into CCT_TEMPAGENTS (call_id, agent_id, filter_type,
	tempagnet_id,last_update_date,last_updated_by,creation_date,
	created_by)
       values (p_call_id, l_dummyAgent, p_filter_type,
	   1001,sysdate,1,sysdate,1);

   -- insert
           INSERT INTO CCT_TEMPAGENTS (call_id, agent_id, filter_type,
	       tempagnet_id,last_update_date,last_updated_by,creation_date,
		  created_by)
           VALUES ( p_call_ID, p_agent_ID, p_filter_type,
	            1002,sysdate,1,sysdate,1);

EXCEPTION
   when OTHERS then
     return;
END INSERTRESULTS;



------------------------------------------------------------------------------
--  PROCEDURE	: InsertResults
--  Usage	: Used by all the filter functions to insert agent results
--		  into the CCT_TEMPAGENTS tables
--  Parameters	:
--      p_call_ID       IN      VARCHAR2        Required
--      p_filter_type   IN      VARCHAR2        Required
--      p_agents_tbl     IN out nocopy     agent_tbl_type  Required
------------------------------------------------------------------------------
PROCEDURE InsertResults (
      p_call_ID       IN      VARCHAR2
      , p_filter_type   IN      VARCHAR2
      , p_agents_tbl     IN out nocopy     agent_tbl_type
) IS

  l_dummyAgent  VARCHAR2(32) := '-1';
  i             INTEGER;
BEGIN

   insert into CCT_TEMPAGENTS (call_id, agent_id, filter_type,
	tempagnet_id,last_update_date,last_updated_by,creation_date,
	created_by)
       values (p_call_id, l_dummyAgent, p_filter_type,
	   1001,sysdate,1,sysdate,1);

   -- convert from employee_id to agent_id
   FOR i in p_agents_tbl.FIRST..p_agents_tbl.LAST LOOP

           INSERT INTO CCT_TEMPAGENTS (call_id, agent_id, filter_type,
	       tempagnet_id,last_update_date,last_updated_by,creation_date,
		  created_by)
           VALUES ( p_call_ID, p_agents_tbl(i), p_filter_type,
	            1002,sysdate,1,sysdate,1);

   end loop;

EXCEPTION
   when OTHERS then
     return;
END INSERTRESULTS;


------------------------------------------------------------------------------
--  PROCEDURE	: InsertResults
--  Usage	: Used by all the CS filter functions to insert agent results
--		  into the CCT_TEMPAGENTS tables
--  Parameters	:
--      p_call_ID       IN      VARCHAR2        Required
--      p_filter_type   IN      VARCHAR2        Required
--      p_agents_tbl     IN out nocopy      CS_ROUTING_UTL.emp_tbl_type  Required
------------------------------------------------------------------------------
PROCEDURE InsertResults (
      p_call_ID       IN      VARCHAR2
      , p_filter_type   IN      VARCHAR2
      , p_agents_tbl     IN out nocopy      CS_ROUTING_UTL.emp_tbl_type
) IS
  l_dummyAgent  VARCHAR2(32) := '-1';
  i             INTEGER;
BEGIN

   insert into CCT_TEMPAGENTS (call_id, agent_id, filter_type,
	tempagnet_id,last_update_date,last_updated_by,creation_date,
	created_by)
       values (p_call_id, l_dummyAgent, p_filter_type,
	   1001,sysdate,1,sysdate,1);

   -- convert from employee_id to agent_id
   FOR i in p_agents_tbl.FIRST..p_agents_tbl.LAST LOOP
       if (p_agents_tbl(i) IS NOT NULL) then
           INSERT INTO CCT_TEMPAGENTS (call_id, agent_id, filter_type,
	       tempagnet_id,last_update_date,last_updated_by,creation_date,
		  created_by)
           VALUES ( p_call_ID, p_agents_tbl(i), p_filter_type,
	            1002,sysdate,1,sysdate,1);
       end if;
   end loop;

EXCEPTION
   when OTHERS then
     return;
END INSERTResults;


------------------------------------------------------------------------------
--  PROCEDURE	: InsertResults
--  Usage	: Used by all the JTF filter functions to insert agent results
--		  into the CCT_TEMPAGENTS tables
--  Parameters	:
--      p_call_ID       IN      VARCHAR2        Required
--      p_filter_type   IN      VARCHAR2        Required
--      p_agents_tbl     IN out nocopy     JTF_TERRITORY_PUB.WinningTerrMember_tbl_type
------------------------------------------------------------------------------
PROCEDURE InsertResults (
      p_call_ID       IN      VARCHAR2
      , p_filter_type   IN      VARCHAR2
      , p_agents_tbl     IN out nocopy JTF_TERRITORY_PUB.WinningTerrMember_tbl_type
) IS
  l_dummyAgent  VARCHAR2(32) := '-1';
  i             INTEGER;
BEGIN

   insert into CCT_TEMPAGENTS (call_id, agent_id, filter_type,
	tempagnet_id,last_update_date,last_updated_by,creation_date,
	created_by)
       values (p_call_id, l_dummyAgent, p_filter_type,
	   1001,sysdate,1,sysdate,1);

   -- convert from employee_id to agent_id
   FOR i in p_agents_tbl.FIRST..p_agents_tbl.LAST LOOP
       if (p_agents_tbl(i).RESOURCE_ID IS NOT NULL) then
           INSERT INTO CCT_TEMPAGENTS (call_id, agent_id, filter_type,
	       tempagnet_id,last_update_date,last_updated_by,creation_date,
		  created_by)
           VALUES ( p_call_ID, p_agents_tbl(i).RESOURCE_ID, p_filter_type,
	            1002,sysdate,1,sysdate,1);
       end if;
   end loop;

EXCEPTION
   when OTHERS then
     return;
END INSERTResults;

------------------------------------------------------------------------------
--  PROCEDURE	: InsertResults
--  Usage	: Used by all the telesales filter functions to insert agent results
--		  into the CCT_TEMPAGENTS tables
--  Parameters	:
--      p_call_ID       IN      VARCHAR2        Required
--      p_filter_type   IN      VARCHAR2        Required
--      p_agents_tbl     IN out nocopy AST_Routing_PUB.resource_access_tbl_type  Required
------------------------------------------------------------------------------
PROCEDURE InsertResults (
      p_call_ID          IN      VARCHAR2
      , p_filter_type    IN      VARCHAR2
      , p_agents_tbl     IN out nocopy  AST_Routing_PUB.resource_access_tbl_type
) IS
  l_dummyAgent  VARCHAR2(32) := '-1';
  i             INTEGER;
BEGIN

   insert into CCT_TEMPAGENTS (call_id, agent_id, filter_type,
	tempagnet_id,last_update_date,last_updated_by,creation_date,
	created_by)
       values (p_call_id, l_dummyAgent, p_filter_type,
	   1001,sysdate,1,sysdate,1);

   FOR i in p_agents_tbl.FIRST..p_agents_tbl.LAST LOOP
       if (p_agents_tbl(i).resource_id IS NOT NULL) then
           INSERT INTO CCT_TEMPAGENTS (call_id, agent_id, filter_type,
	       tempagnet_id,last_update_date,last_updated_by,creation_date,
		  created_by)
           VALUES ( p_call_ID, p_agents_tbl(i).resource_id, p_filter_type,
	            1002,sysdate,1,sysdate,1);
       end if;
   end loop;

EXCEPTION
   when OTHERS then
     return;
END INSERTResults;

END CCT_RoutingWorkflow_UTL;

/
