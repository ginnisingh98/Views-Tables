--------------------------------------------------------
--  DDL for Package CCT_JTFRESOURCEROUTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_JTFRESOURCEROUTING_PUB" AUTHID CURRENT_USER as
/* $Header: cctjtfrs.pls 120.0 2005/06/02 10:07:12 appldev noship $ */

------------------------------------------------------------------------------
--  Function	: Get_Agents_For_Competency
--  Usage	: Used by the Routing module to get the agents assigned to
--		  the language
--  Description	: This function retrieves a collection of agent IDs from
--		  the competency tables  given a competency.
--  Parameters	:
--      p_competency_type       IN      VARCHAR2        Required
--	p_competency_name	IN	VARCHAR2	Required
--	x_agent_tbl		OUT	CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
--
--  Return	: NUMBER
--		  This function returns the number of agents assigned to
--		  the given competency_name (0 if there is no agent assigned
--		  to the competency_name).
------------------------------------------------------------------------------

FUNCTION  Get_Agents_For_Competency (
	p_competency_type       IN      VARCHAR2
	, p_competency_name	IN	VARCHAR2
	, x_agent_tbl	 out nocopy 	CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
)
RETURN NUMBER;


 FUNCTION Get_agents_from_stat_grp_nam (
           p_group_name       IN VARCHAR2
           ,p_agent_tbl       out nocopy  CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
    )
 RETURN number;

 FUNCTION Get_agents_from_stat_grp_num (
          p_group_number     IN VARCHAR2
          ,p_agent_tbl       out nocopy  CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
    )
 RETURN number;

 FUNCTION Get_agents_from_dyn_grp_nam (
          p_group_name       IN VARCHAR2
          ,p_agent_tbl       out nocopy  CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
    )
 RETURN number;

 FUNCTION Get_agents_from_dyn_grp_num (
          p_group_number      IN VARCHAR2
          ,p_agent_tbl       out nocopy  CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
    )
 RETURN number;

 FUNCTION Get_agents_not_in_stat_grp_nam (
          p_group_name       IN VARCHAR2
          ,p_agent_tbl       out nocopy  CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
    )
 RETURN number;

 FUNCTION Get_agents_not_in_stat_grp_num (
           p_group_number     IN VARCHAR2
           ,p_agent_tbl       out nocopy  CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
    )
 RETURN number;

 FUNCTION Get_agents_not_in_dyn_grp_nam (
           p_group_name      IN VARCHAR2
           ,p_agent_tbl       out nocopy  CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
    )
 RETURN number;

 FUNCTION Get_agents_not_in_dyn_grp_num (
          p_group_number     IN  VARCHAR2
          ,p_agent_tbl       out nocopy  CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
    )
 RETURN number;

END CCT_JTFRESOURCEROUTING_PUB;

 

/
