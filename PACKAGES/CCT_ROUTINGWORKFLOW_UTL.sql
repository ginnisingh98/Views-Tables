--------------------------------------------------------
--  DDL for Package CCT_ROUTINGWORKFLOW_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_ROUTINGWORKFLOW_UTL" AUTHID CURRENT_USER as
/* $Header: cctucros.pls 115.18 2003/01/21 01:03:51 rajayara ship $ */


------------------------------------------------------------------------------
--  Type	: agent_tbl_type
--  Usage	: Used by the Competency Routing functions to return a group
--		  of agent IDs
--  Description	: This pre-defined table type stores a collection of agent
--		  IDs.
------------------------------------------------------------------------------

TYPE agent_tbl_type IS TABLE OF PER_ALL_PEOPLE_F.PERSON_ID%TYPE
  INDEX BY BINARY_INTEGER;
-----------------------------------------------------------------------------

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
RETURN VARCHAR2;

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
) ;


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
      , p_agents_tbl     IN  out nocopy    agent_tbl_type
) ;


------------------------------------------------------------------------------
--  PROCEDURE	: InsertResults
--  Usage	: Used by all the CS filter functions to insert agent results
--		  into the CCT_TEMPAGENTS tables
--  Parameters	:
--      p_call_ID       IN      VARCHAR2        Required
--      p_filter_type   IN      VARCHAR2        Required
--      p_agents_tbl     IN out nocopy     CS_ROUTING_UTL.emp_tbl_type  Required
------------------------------------------------------------------------------
PROCEDURE InsertResults (
      p_call_ID       IN      VARCHAR2
      , p_filter_type   IN      VARCHAR2
      , p_agents_tbl     IN out nocopy     CS_ROUTING_UTL.emp_tbl_type
) ;

------------------------------------------------------------------------------
--  PROCEDURE	: InsertResults
--  Usage	: Used by all the CS filter functions to insert agent results
--		  into the CCT_TEMPAGENTS tables
--  Parameters	:
--      p_call_ID       IN      VARCHAR2        Required
--      p_filter_type   IN      VARCHAR2        Required
--      p_agents_tbl     IN  out nocopy    AS_ROUTING_UTIL.emp_tbl_type  Required
------------------------------------------------------------------------------
--PROCEDURE InsertResults (
--      p_call_ID       IN      VARCHAR2
--     , p_filter_type   IN      VARCHAR2
--      , p_agents_tbl     IN out nocopy     AS_ROUTING_UTIL.emp_tbl_type
--) ;

------------------------------------------------------------------------------
--  PROCEDURE	: InsertResults
--  Usage	: Used by all the AST filter functions to insert agent results
--		  into the CCT_TEMPAGENTS tables
--  Parameters	:
--      p_call_ID       IN      VARCHAR2        Required
--      p_filter_type   IN      VARCHAR2        Required
--      p_agents_tbl    IN  out nocopy AST_Routing_PUB.resource_id_tbl_type  Required
------------------------------------------------------------------------------
PROCEDURE InsertResults (
      p_call_ID       IN        VARCHAR2
      , p_filter_type   IN      VARCHAR2
      , p_agents_tbl     IN out nocopy AST_Routing_PUB.resource_access_tbl_type) ;
------------------------------------------------------------------------------
------------------------------------------------------------------------------

--  PROCEDURE	: InsertResults
--  Usage	: Used by all the JTF filter functions to insert agent results
--		  into the CCT_TEMPAGENTS tables
--  Parameters	:
--      p_call_ID       IN      VARCHAR2        Required
--      p_filter_type   IN      VARCHAR2        Required
--      p_agents_tbl    IN  out nocopy JTF_TERRITORY_PUB.WinningTerrMember_tbl_type;

PROCEDURE InsertResults (
      p_call_ID       IN      VARCHAR2
      , p_filter_type   IN      VARCHAR2
      , p_agents_tbl     IN out nocopy    JTF_TERRITORY_PUB.WinningTerrMember_tbl_type
) ;

END CCT_RoutingWorkflow_UTL;

 

/
