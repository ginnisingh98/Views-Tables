--------------------------------------------------------
--  DDL for Package Body CCT_BANKROUTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_BANKROUTING_PUB" as
/* $Header: cctrbnkb.pls 115.6 2003/08/23 01:43:32 gvasvani ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CCT_BANKROUTING_PUB';

procedure Get_Group_from_Profitability (
     itemtype       in varchar2
     , itemkey      in varchar2
     , actid        in number
     , funmode      in varchar2
     , resultout    in out nocopy  varchar2) IS

    l_proc_name   VARCHAR2(30) := 'Get_Group_from_Profitability';
    l_customer_id NUMBER;
--    l_group_tbl   FPT_ROUTING_UTIL.resource_tbl_type;
    l_agents_tbl  CCT_RoutingWorkflow_UTL.agent_tbl_type;
    l_num_agents  NUMBER := 0;
    l_call_ID     VARCHAR2(32);
    l_num_groups  NUMBER :=0;
  BEGIN
    -- set default result
    resultout := wf_engine.eng_completed ;

    IF (funmode = 'RUN') THEN
      l_customer_id  := WF_ENGINE.GetItemAttrNumber(itemtype,itemkey,CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID );
      l_call_ID     := WF_ENGINE.GetItemAttrText(
                         itemtype, itemkey,  'OCCTMEDIAITEMID');

	 IF ( (l_customer_ID IS NULL) OR (l_call_ID IS NULL) ) THEN
         return;
      END IF;
	 /* commented to remove dependency
      -- call FPT API
      l_num_groups :=
         FPT_ROUTING_UTIL.CustID_profitability_GroupID
                    ( p_customer_id  => l_customer_id
				, x_resource_tbl => l_group_tbl) ;
      -- If group_id is null do nothing
      IF (l_num_groups = 0) THEN
         return;
      END IF;

      l_num_agents := CCT_RoutingWorkflow_UTL.Get_Agents_From_Group_Id(
                      l_group_tbl, l_agents_tbl);

      */
      IF (l_num_agents = 0) THEN
         return;
      END IF;

      -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
     (l_call_ID, 'BNK_AGENT_FROM_PROFITABILITY' , l_agents_tbl);

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
      	      itemtype, itemkey, to_char(actid), funmode);
      RAISE;
  END  Get_Group_from_Profitability;

procedure Get_Group_from_Bank_Id (
     itemtype       in varchar2
     , itemkey      in varchar2
     , actid        in number
     , funmode      in varchar2
     , resultout    in out nocopy  varchar2) IS

    l_proc_name   VARCHAR2(30) := 'Get_Group_from_Bank_Id';
    l_customer_id NUMBER;
    --l_group_tbl   FPT_ROUTING_UTIL.resource_tbl_type;
    l_agents_tbl  CCT_RoutingWorkflow_UTL.agent_tbl_type;
    l_num_agents  NUMBER := 0;
    l_call_ID     VARCHAR2(32);
    l_num_groups  NUMBER :=0;

  BEGIN
    -- set default result
    resultout := wf_engine.eng_completed ;

    IF (funmode = 'RUN') THEN
      l_customer_id  := WF_ENGINE.GetItemAttrNumber(itemtype,itemkey,CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID );
      l_call_ID     := WF_ENGINE.GetItemAttrText(
                         itemtype, itemkey,  'OCCTMEDIAITEMID');

	 IF ( (l_customer_ID IS NULL) OR (l_call_ID IS NULL) ) THEN
         return;
      END IF;
      -- call FPT API
	 /*
      l_num_groups :=
         FPT_ROUTING_UTIL.CustID_bank_GroupID
                    ( p_customer_id  => l_customer_id
				, x_resource_tbl => l_group_tbl) ;

      -- If group_id is null do nothing
      IF (l_num_groups =  0) THEN
         return;
      END IF;

      l_num_agents := CCT_RoutingWorkflow_UTL.Get_Agents_From_Group_Id(
                      l_group_tbl, l_agents_tbl);
	 */

      IF (l_num_agents = 0) THEN
         return;
      END IF;

      -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
     (l_call_ID, 'BNK_AGENT_FROM_BANK_ID' , l_agents_tbl);

    END IF;


  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
      	      itemtype, itemkey, to_char(actid), funmode);
      RAISE;
  END  Get_Group_from_Bank_Id;

procedure Get_Group_from_Bank_Branch (
     itemtype       in varchar2
     , itemkey      in varchar2
     , actid        in number
     , funmode      in varchar2
     , resultout    in out nocopy  varchar2) IS

    l_proc_name   VARCHAR2(30) := 'Get_Group_from_Bank_Branch';
    l_customer_id NUMBER;
    --l_group_tbl   FPT_ROUTING_UTIL.resource_tbl_type;
    l_agents_tbl  CCT_RoutingWorkflow_UTL.agent_tbl_type;
    l_num_agents  NUMBER := 0;
    l_call_ID     VARCHAR2(32);
    l_num_groups  NUMBER :=0;

  BEGIN

    -- set default result
    resultout := wf_engine.eng_completed ;

    IF (funmode = 'RUN') THEN
      l_customer_id  := WF_ENGINE.GetItemAttrNumber(itemtype,itemkey,CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID );
      l_call_ID     := WF_ENGINE.GetItemAttrText(
                         itemtype, itemkey,  'OCCTMEDIAITEMID');

	 IF ( (l_customer_ID IS NULL) OR (l_call_ID IS NULL) ) THEN
         return;
      END IF;
	 /*
      -- call FPT API
      l_num_groups :=
         FPT_ROUTING_UTIL.CustID_branch_GroupID
                    ( p_customer_id  => l_customer_id
                    , x_resource_tbl => l_group_tbl) ;

      -- If group_id is null do nothing
      IF (l_num_groups = 0) THEN
         return;
      END IF;

      l_num_agents := CCT_RoutingWorkflow_UTL.Get_Agents_From_Group_Id(
                      l_group_tbl, l_agents_tbl);
      */
      IF (l_num_agents = 0) THEN
         return;
      END IF;

      -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
     (l_call_ID, 'BNK_AGENT_FROM_BANK_BRANCH' , l_agents_tbl);

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
      	      itemtype, itemkey, to_char(actid), funmode);
      RAISE;
  END  Get_Group_from_Bank_Branch;


END CCT_BANKROUTING_PUB;

/
