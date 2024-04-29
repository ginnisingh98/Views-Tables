--------------------------------------------------------
--  DDL for Package Body CCT_TELESALESROUTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_TELESALESROUTING_PUB" as
/* $Header: ccttswfb.pls 120.0 2005/06/02 09:34:49 appldev noship $ */


G_PKG_NAME CONSTANT VARCHAR2(30) := 'CCT_TeleSales_Routing_PUB';

/*------------------------------------------------------------------------
   TeleSales Routing Workflow Activities
*------------------------------------------------------------------------*/


/* -----------------------------------------------------------------------
  Activity Name : WF_TeleSalesAgentForParty_FIL
  To filter the agents by Party ID
	Prerequisites : The Customer initialization phase(CCT_CUSTOMER_INIT)
    must be completed before using this filter
	IN
    	 itemtype  - item type
	 itemkey   - item key
      actid     - process activity instance id
	 funmode   - execution mode
	OUT
	 No output
	ITEM ATTRIBUTES REFERENCED
	  PARTYID    - the customer ID
	  MEDIAITEMID    - the MediaItem ID
*-----------------------------------------------------------------------*/

procedure WF_TeleSalesAgentForParty_FIL (
	 itemtype       in varchar2
      , itemkey      in varchar2
	 , actid        in number
	 , funmode      in varchar2
      , resultout    in out nocopy varchar2) IS

    l_proc_name   VARCHAR2(64) := 'WF_TeleSalesAgentForParty_FIL';
    l_agents_tbl  AST_Routing_PUB.resource_access_tbl_type;
    l_num_agents  NUMBER := 0;
    l_partyID    NUMBER;
    l_mediaItemID     VARCHAR2(32);
  BEGIN
  -- set default result
  resultout := wf_engine.eng_completed||':N';

   if (funmode = 'RUN') then
     l_partyID     := WF_ENGINE.GetItemAttrNumber(
 			   itemtype, itemkey,  upper(CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID));
     l_mediaItemID     := WF_ENGINE.GetItemAttrText(
					    itemtype, itemkey,  upper(CCT_INTERACTIONKEYS_PUB.KEY_MEDIA_ITEM_ID));


     IF ( (l_partyID IS NULL) OR (l_mediaItemID IS NULL) ) THEN
 	   return;
     END IF;
       --call ASO API
     AST_Routing_PUB.GetResourcesForParty(
     		    l_partyID, l_agents_tbl);
     IF (l_agents_tbl.count = 0) THEN
       return;
     END IF;

     resultout := wf_engine.eng_completed||':Y';
      CCT_RoutingWorkflow_UTL.InsertResults
	  (l_mediaItemID, l_proc_name , l_agents_tbl);

   end if;
  EXCEPTION
     WHEN OTHERS THEN
	  --dbms_output.put_line('Exception in Party2Agent'||sqlerrm);
       WF_CORE.Context(G_PKG_NAME, l_proc_name,
				    itemtype, itemkey, to_char(actid), funmode);
	  RAISE;

END WF_TeleSalesAgentForParty_FIL;

/* -----------------------------------------------------------------------
  Activity Name : WF_SalesAgentForSourceCode_FIL
  To filter the agents by Source Code
	Prerequisite : Source Code must exist
	IN
     itemtype  - item type
	 itemkey   - item key
      actid     - process activity instance id
	 funmode   - execution mode
	OUT
	 No output
	ITEM ATTRIBUTES REFERENCED
	  SOURCECODE    - the Source Code
	  MEDIAITEMID    - the MediaItem ID
*-----------------------------------------------------------------------*/

procedure WF_SalesAgentForSourceCode_FIL (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) IS
    l_proc_name   VARCHAR2(64) := 'WF_SalesAgentForSourceCode_FIL';
    l_agents_tbl  AST_Routing_PUB.resource_access_tbl_type;
    l_num_agents  NUMBER := 0;
    l_SourceCode  Varchar2(255);
    l_mediaItemID     VARCHAR2(32);
  BEGIN
  -- set default result
  resultout := wf_engine.eng_completed||':N';

   if (funmode = 'RUN') then
     l_SourceCode     := WF_ENGINE.GetItemAttrText(
 			   itemtype, itemkey,  upper(CCT_INTERACTIONKEYS_PUB.KEY_SOURCE_CODE));
     l_mediaItemID     := WF_ENGINE.GetItemAttrText(
					    itemtype, itemkey,  upper(CCT_INTERACTIONKEYS_PUB.KEY_MEDIA_ITEM_ID));
     --dbms_output.put_line('SourceCode='||l_sourcecode);

     IF ( (l_SourceCode IS NULL) OR (l_mediaItemID IS NULL) ) THEN
 	   return;
     END IF;
       --call ASO API
     AST_Routing_PUB.GetResourcesForSourceCode(
     		    l_SourceCode, l_agents_tbl);
     IF (l_agents_tbl.count = 0) THEN
       --dbms_output.put_line('result = null');
       return;
     END IF;
     resultout := wf_engine.eng_completed||':Y';
     --dbms_output.put_line('agents returned for result='||to_char(l_agents_tbl.count));

      CCT_RoutingWorkflow_UTL.InsertResults
	  (l_mediaItemID, l_proc_name , l_agents_tbl);

   end if;
  EXCEPTION
     WHEN OTHERS THEN
       WF_CORE.Context(G_PKG_NAME, l_proc_name,
				    itemtype, itemkey, to_char(actid), funmode);
	  RAISE;

END;

END CCT_TeleSalesRouting_PUB;

/
