--------------------------------------------------------
--  DDL for Package Body CCT_SERVICEROUTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_SERVICEROUTING_PUB" as
/* $Header: cctrwcsb.pls 115.12 2003/08/23 01:49:33 gvasvani ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CCT_ServiceRouting_PUB';

/*------------------------------------------------------------------------
   Service Routing Workflow Activities
*------------------------------------------------------------------------*/





/* -----------------------------------------------------------------------
   Activity Name : Set_Customer_Filter (filter node)
     To filter the agents by Customer ID
   Prerequisites : The Customer initialization phase must be completed
                           before using this filter
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    No output
   ITEM ATTRIBUTES REFERENCED
    CUSTID    - the customer ID
    CALLID    - the call ID

   Implementation : No Workflow output is expected from this function.
   The CS API returns the number of agents.
   The list of agents is  returned by the CS API as a PL/SQL table.
   Loop through the table  and insert each agent into the CCT_TEMPAGENTS table.
*-----------------------------------------------------------------------*/
procedure Set_Customer_Filter (
	itemtype     in varchar2
	, itemkey    in varchar2
	, actid      in number
	, funmode    in varchar2
	, resultout  in out nocopy varchar2)
  IS
    l_proc_name   VARCHAR2(30) := 'Set_Customer_Filter';
    l_num_agents  NUMBER := 0;
    l_customer_ID NUMBER;
    l_call_ID     VARCHAR2(32);
    l_agents_tbl  JTF_TERRITORY_PUB.WinningTerrMember_tbl_type;
    l_acct_rec    JTF_TERRITORY_PUB.JTF_Account_rec_type;
    l_msg_count   NUMBER;
    l_msg_data    VARCHAR2(2000);
    l_return_status varchar2(01);
    l_ret         BOOLEAN;
    l_resource_type VARCHAR2(60) := 'RS_EMPLOYEE';
    l_role          VARCHAR2(60) := NULL;
    l_counter       NUMBER;
    l_org_id        NUMBER := NULL;
  BEGIN
   -- set default result
   resultout := wf_engine.eng_completed ;

   if (funmode = 'RUN') then
      -- WF attribute TERRITORYORGID must be set to for this function to work
	 l_org_id := WF_ENGINE.GetItemAttrNumber(
				  itemtype, itemkey,  'TERRITORYORGID');

      IF l_org_id IS NULL THEN
        return;
	 END IF;

      fnd_client_info.set_org_context(l_org_id);

      l_acct_rec.party_id := WF_ENGINE.GetItemAttrNumber(
                              itemtype, itemkey,  CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID);

      l_call_ID     := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTMEDIAITEMID');

      IF ( (l_acct_rec.party_id  IS NULL) OR (l_call_ID IS NULL) ) THEN
         return;
      END IF;

      l_ret := JTF_TERRITORY_GLOBAL_PUB.RESET;
      --dbms_output.put_line ('IN CS FILTER BEFORE JTF ');

      -- Call JTF Territory
      JTF_TERR_SALES_PUB.Get_WinningTerrMembers(
         p_api_version_number => '1.0'
         , p_TerrAccount_Rec  =>  l_acct_rec
         , p_resource_type    =>  l_resource_type
         , p_role             =>  l_role
         , x_return_status    =>  l_return_status
         , x_msg_count        =>  l_msg_count
         , x_msg_data         =>  l_msg_data
         , x_terrresource_tbl  => l_agents_tbl);

      IF (l_agents_tbl.count = 0) THEN
         return;
      END IF;

      -- dbms_output.put_line ('IN CS FILTER AFTER JTF CALL');
      -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
	(l_call_ID, 'CS_CUSTOMER_FILTER' , l_agents_tbl);

   end if;

  EXCEPTION
    WHEN OTHERS THEN
      --dbms_output.put_line ('ERROR'|| sqlerrm);
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
                      itemtype, itemkey, to_char(actid), funmode);
      RAISE;

  END Set_Customer_Filter;






procedure Set_Product_Filter (
	itemtype    in varchar2
	, itemkey   in varchar2
	, actid     in number
	, funmode   in varchar2
	, resultout in out nocopy varchar2) IS

    l_proc_name   VARCHAR2(30) := 'Set_Product_Filter';
    l_num_agents  NUMBER := 0;
    l_product_ID NUMBER;
    l_call_ID     VARCHAR2(32);
    l_agents_tbl  JTF_TERRITORY_PUB.WinningTerrMember_tbl_type;
    l_acct_rec    JTF_TERRITORY_PUB.JTF_Oppor_rec_type;
    l_msg_count   NUMBER;
    l_msg_data    VARCHAR2(2000);
    l_return_status varchar2(01);
    l_ret         BOOLEAN;
    l_resource_type VARCHAR2(60) := 'RS_EMPLOYEE';
    l_role          VARCHAR2(60) := NULL;
    l_customer_pdt_ID  VARCHAR2(60) := NULL ;
    l_org_id        NUMBER := NULL;
  BEGIN
   -- set default result
   resultout := wf_engine.eng_completed ;

   if (funmode = 'RUN') then
      -- WF attribute TERRITORYORGID must be set to for this function to work
	 l_org_id := WF_ENGINE.GetItemAttrNumber(
				  itemtype, itemkey,  'TERRITORYORGID');

      IF l_org_id IS NULL THEN
        return;
	 END IF;

      fnd_client_info.set_org_context(l_org_id);

      l_acct_rec.INVENTORY_ITEM_ID  := WF_ENGINE.GetItemAttrNumber(
                       itemtype, itemkey,  'INVENTORYITEMID');

      l_call_ID     := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTMEDIAITEMID');

      IF l_acct_rec.INVENTORY_ITEM_ID IS NULL THEN
        l_customer_pdt_id := to_number(WF_ENGINE.GetItemAttrText(
                              itemtype, itemkey,  'CUSTOMERPRODUCTID'));
        BEGIN
          SELECT inventory_item_id
          INTO l_acct_rec.INVENTORY_ITEM_ID
          FROM csi_item_instances
          WHERE instance_id = l_customer_pdt_id ;
        EXCEPTION
           WHEN  others THEN
             l_acct_rec.INVENTORY_ITEM_ID := null;
        END;
      END IF;

      IF ( (l_acct_rec.INVENTORY_ITEM_ID  IS NULL) OR (l_call_ID IS NULL) ) THEN
         return;
      END IF;

     l_ret := JTF_TERRITORY_GLOBAL_PUB.RESET;

      -- Call JTF Territory
      JTF_TERR_SALES_PUB.Get_WinningTerrMembers(
         p_api_version_number => '1.0'
         , p_TerrOppor_Rec  =>  l_acct_rec
         , p_resource_type    =>  l_resource_type
         , p_role             =>  l_role
         , x_return_status    =>  l_return_status
         , x_msg_count        =>  l_msg_count
         , x_msg_data         =>  l_msg_data
         , x_terrresource_tbl  => l_agents_tbl);


      IF (l_agents_tbl.count = 0) THEN
         return;
      END IF;

      -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
	(l_call_ID, 'CS_PRODUCT_FILTER' , l_agents_tbl);

    end if;
  EXCEPTION
    WHEN OTHERS THEN
       WF_CORE.Context(G_PKG_NAME, l_proc_name,
                      itemtype, itemkey, to_char(actid), funmode);
      RAISE;

  END Set_Product_Filter ;



/* -----------------------------------------------------------------------
   Activity Name : Set_Request_Owner_Filter (filter node)
     To filter the agents by request number
   Prerequisites : The ?? initialization phase must be completed
                           before using this filter
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    No output
   ITEM ATTRIBUTES REFERENCED
    CUSTID           - the customer ID
    REQUEST_OWNER_ID - the call ID

   Implementation : No Workflow output is expected from this function.

*-----------------------------------------------------------------------*/
procedure Set_Request_Owner_Filter (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout in out nocopy varchar2) IS

    l_proc_name   VARCHAR2(30) := ' Set_Request_Owner_Filter' ;
    l_RequestNum  VARCHAR2(64);
    l_agent_ID     NUMBER;
    l_call_ID     VARCHAR2(32);
  BEGIN
  -- set default result
   resultout := wf_engine.eng_completed ;
   if (funmode = 'RUN') then
      l_RequestNum := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SERVICEREQUESTNUM' );
      l_call_ID := WF_ENGINE.GetItemAttrText(itemtype, itemkey,  'OCCTMEDIAITEMID');

      IF ( (l_RequestNum IS NULL) OR (l_call_ID IS NULL) ) THEN
         return;
      END IF;

      -- call CS API
      l_agent_ID := CS_ROUTING_UTL.Get_Owner_Of_Request (
                  p_Request_Number  => l_RequestNum ) ;
 	BEGIN
	  Select incident_owner_id into l_agent_ID
       from cs_incidents_all_b
       where incident_number=l_RequestNum;
      END;

     IF (l_agent_ID IS NULL) THEN
         return;
      END IF;

      -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
	(l_call_ID, 'CS_REQUEST_OWNER_FILTER' , l_agent_ID);

   end if;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name, itemtype,
                      itemkey, to_char(actid), funmode);
      RAISE;
  END Set_Request_Owner_Filter ;

END CCT_ServiceRouting_PUB;

/
