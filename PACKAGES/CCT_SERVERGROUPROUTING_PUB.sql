--------------------------------------------------------
--  DDL for Package CCT_SERVERGROUPROUTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_SERVERGROUPROUTING_PUB" AUTHID CURRENT_USER as
/* $Header: cctsvgrs.pls 120.0 2005/06/02 09:25:57 appldev noship $ */

------------------------------------------------------------------------------
--  Function	: Get_Srv_Group_from_MCMID
--  Usage	: Used by the Routing module to get the  Name of the Server Group
--		  Center to which the given MCM is associated
--  Parameters	:
--      p_MCMID       IN      NUMBER        Required
--
--  Return	: VARCHAR2
--		  This function returns the Name of the Server Group to
--		  which the given MCM is associated
------------------------------------------------------------------------------
FUNCTION Get_Srv_Group_from_MCMID (
	p_MCMID             IN NUMBER
	)
RETURN VARCHAR2;

FUNCTION  Get_Agents_logged_in (
	    p_mcm_id             IN   NUMBER
       ,p_agent_tbl		OUT nocopy	CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
   )
RETURN number ;

Procedure  Get_AppForClassification(
        p_classification IN VARCHAR2
        ,p_mediaTypeUUID IN VARCHAR2
        ,p_app_id out nocopy NUMBER
        ,p_app_name out nocopy VARCHAR2);

END CCT_SERVERGROUPROUTING_PUB;

 

/
