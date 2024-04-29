--------------------------------------------------------
--  DDL for Package Body CCT_PERFTEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_PERFTEST_PKG" AS
/* $Header: cctpftb.pls 120.1 2005/07/13 17:00:50 appldev noship $ */

procedure DNIS_STATICGROUP_FILTER (
     itemtype       in varchar2
     , itemkey      in varchar2
     , actid        in number
     , funmode      in varchar2
     , resultout    in out nocopy varchar2
   ) IS
    l_proc_name VARCHAR2(30) :='DNIS_STATICGROUP_FILTER';
    l_agents_tbl CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type;
    l_num_agents Number:=0;
    l_dnis VARCHAR2(32);
    l_call_ID VARCHAR2(32);
    l_static_group VARCHAR2(64);
  BEGIN
   resultout := wf_engine.eng_completed ;
   if (funmode = 'RUN') then
      l_dnis := WF_ENGINE.GetItemAttrText(
                         itemtype, itemkey,  'OCCTDNIS');
      l_call_ID     := WF_ENGINE.GetItemAttrText(
                        itemtype, itemkey,  'OCCTMEDIAITEMID');
      if ((l_dnis is null) or (l_call_id is null) ) THEN
        return;
      end if;
      l_agents_tbl.delete;

      l_num_agents :=CCT_Perftest_pkg.get_sgagents_for_dnis(l_dnis,l_agents_tbl);
      --dbms_output.put_line('perftest:'||l_num_agents);
      --dbms_output.put_line('perftest:'||l_agents_tbl.count);
      If (l_num_agents=0) THEN
         return;
      END IF;

      -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
           (l_call_ID, 'CCT_DNIS_SG_FILTER' , l_agents_tbl);

   end if;

  EXCEPTION
      WHEN OTHERS THEN
       WF_CORE.Context('CCT_PERFTEST_PKG', l_proc_name,
                   itemtype, itemkey, to_char(actid), funmode);
       RAISE;

  END DNIS_STATICGROUP_FILTER;
  Function Get_SGAgents_for_DNIS(
	 p_dnis IN VARCHAR2,
		x_agent_tbl IN OUT nocopy CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
	)
  RETURN NUMBER is
		 l_total_num_of_agents    NUMBER:=0;
		 l_group_name VARCHAR2(64);
                 i number;

   Begin
       if (p_dnis='7710') then
	      l_group_name:='60DNISGroup';
       elsif (p_dnis='7720') then
	      l_group_name:='60DNISGroup';
       elsif (p_dnis='7730') then
	      l_group_name:='25DNISGroup';
       elsif (p_dnis='7740') then
	      l_group_name:='15DNISGroup';
       else
		 l_group_name:='60DNISGroup';
       end if;
       x_agent_tbl.delete;
--	  l_total_num_of_agents:=CCT_ROUTINGWORKFLOW_UTL.get_agents_from_stat_grp_nam(l_group_name,x_agent_tbl);
	  l_total_num_of_agents:=0;
	  return l_total_num_of_agents;

    Exception
	  when others then
		return l_total_num_of_agents;
   End get_SGAgents_for_DNIS;

END CCT_PERFTEST_PKG;

/
