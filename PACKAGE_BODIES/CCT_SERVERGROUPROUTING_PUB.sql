--------------------------------------------------------
--  DDL for Package Body CCT_SERVERGROUPROUTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_SERVERGROUPROUTING_PUB" as
/* $Header: cctsvgrb.pls 120.0 2005/06/02 09:38:27 appldev noship $ */

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
	p_MCMID			IN NUMBER
)
RETURN VARCHAR2 IS
    l_servergroup_name VARCHAR2(32);
BEGIN
    select GRP.GROUP_NAME into l_servergroup_name
    from   IEO_SVR_GROUPS GRP, IEO_SVR_SERVERS svr
    where  grp.server_group_id=svr.member_svr_group_id
    and    svr.server_id=p_MCMID;

    return l_servergroup_name;

EXCEPTION
   WHEN OTHERS THEN
	return null;

END  Get_Srv_Group_from_MCMID;

FUNCTION  Get_Agents_logged_in (
         p_mcm_id             IN   NUMBER
         ,p_agent_tbl		OUT nocopy CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
   )
 RETURN number IS
    l_total_num_of_agents    NUMBER:=0;
    l_agent_id           cct_agent_rt_stats.agent_id%TYPE;


    CURSOR csr_agents IS
       SELECT a.agent_id
       FROM cct_agent_rt_stats a
	  WHERE mcm_id = p_mcm_id;


BEGIN
     --dbms_output.put_line ('IN GET LOGGED IN AGENTS');
    OPEN csr_agents;
    LOOP
      FETCH csr_agents into l_agent_id;
      IF csr_agents%NOTFOUND THEN
         CLOSE csr_agents;
         RETURN l_total_num_of_agents;
      ELSE
      p_agent_tbl(l_total_num_of_agents) :=  l_agent_id;
      END IF;

      l_total_num_of_agents := l_total_num_of_agents + 1;
    END LOOP;

 EXCEPTION
	WHEN OTHERS THEN
    CLOSE csr_agents;
    --dbms_output.put_line(' ERROR in Get_logged In Agents '||sqlerrm );

 END Get_Agents_logged_in;

 Procedure  Get_AppForClassification(
        p_classification IN VARCHAR2
        ,p_mediaTypeUUID IN VARCHAR2
        ,p_app_id out nocopy NUMBER
        ,p_app_name out nocopy VARCHAR2) IS
 Begin
    Begin
	   --dbms_output.put_line('1:GetAPPforClass='||p_classification);
        Select def.application_id,decode(def.application_id,511,'TELESERVICE',
                                                            521,'TELESALES','OTHER')
        into p_app_id,p_app_name
        from ieu_uwq_media_actions act,ieu_uwq_media_types_b type,ieu_uwq_maction_defs_b def
        where act.maction_def_id=def.maction_def_id
	   and type.media_type_uuid=p_mediaTypeUUID
        and type.media_type_id=act.media_type_id
        and upper(act.classification)=upper(p_classification);
	  -- dbms_output.put_line('1:GetAPPforClass app_name='||p_app_name||':'||to_char(p_app_id));
    Exception
        When NO_DATA_FOUND THEN
           Begin
	        Select act.application_id,decode(act.application_id,511,'TELESERVICE',
	                                                            521,'TELESALES','OTHER')
	        into p_app_id,p_app_name
             from ieu_uwq_media_actions act,ieu_uwq_media_types_b type,ieu_uwq_maction_defs_b def
             where act.maction_def_id=def.maction_def_id
	        and type.media_type_uuid=p_mediaTypeUUID
             and type.media_type_id=act.media_type_id
	        and upper(act.classification)=upper('unClassified');
	       -- dbms_output.put_line('2:GetAPPforClass app_name='||p_app_name||':'||to_char(p_app_id));
	       Exception
	          When no_data_found then
			        Select act.application_id,decode(act.application_id,511,'TELESERVICE',
			                                                            521,'TELESALES','OTHER')
			        into p_app_id,p_app_name
                       from ieu_uwq_media_actions act,ieu_uwq_media_types_b type,ieu_uwq_maction_defs_b def
                       where act.maction_def_id=def.maction_def_id
	                  and type.media_type_uuid=p_mediaTypeUUID
                       and type.media_type_id=act.media_type_id
			        and act.classification is null;
	                 -- dbms_output.put_line('3:GetAPPforClass app_name='||p_app_name||':'||to_char(p_app_id));
		   END;
	End;
 Exception
    When Others then
		null;
	    -- dbms_output.put_line('Error in GetAPPforClass');
 End;


 END CCT_SERVERGROUPROUTING_PUB;

/
