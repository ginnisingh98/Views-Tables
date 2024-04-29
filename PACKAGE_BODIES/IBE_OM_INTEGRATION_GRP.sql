--------------------------------------------------------
--  DDL for Package Body IBE_OM_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_OM_INTEGRATION_GRP" AS
/*$Header: IBEGORDB.pls 120.1 2005/08/17 03:05:26 appldev ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBE_OM_INTEGRATION_GRP';
  g_ItemType	Varchar2(10) := 'IBEALERT';
  g_processName Varchar2(30)  := 'PROCESSMAP';


  -- =======================================================================

  -- PROCEDURE notify_rma_request_action

  PROCEDURE  notify_rma_request_action(
           P_Api_Version_Number   IN         NUMBER,
           P_Init_Msg_List        IN         VARCHAR2,
           P_order_header_id      IN         NUMBER,
           P_notif_context        IN         VARCHAR2,
           P_comments             IN         VARCHAR2,
           P_reject_reason_code   IN         VARCHAR2,
           X_Return_Status        OUT NOCOPY VARCHAR2,
           X_Msg_Count            OUT NOCOPY NUMBER,
           X_Msg_Data             OUT NOCOPY VARCHAR2)
  IS


  l_item_key                 WF_ITEMS.ITEM_KEY%TYPE;
  l_event_type               VARCHAR2(20):= 'RETURNORDERAPPROVED';
  l_party_id                 NUMBER;
  l_user_name                WF_USERS.NAME%TYPE;
  l_order_header_id          NUMBER;
  l_notifEnabled             VARCHAR2(3)  := 'Y';
  l_notifName                VARCHAR2(30) ;
  l_Orgid                    NUMBER       := null;
  l_messageName              WF_MESSAGES.NAME%TYPE;
  l_msgEnabled               VARCHAR2(3);
  l_item_owner               WF_USERS.NAME%TYPE := 'SYSADMIN';
  l_url                      VARCHAR2(30) :=null;
  l_order_number             OE_ORDER_HEADERS_ALL.ORDER_NUMBER%TYPE;
  l_org_id                   OE_ORDER_HEADERS_ALL.ORG_ID%TYPE;
  l_usertype                 VARCHAR2(30);
  l_reject_reason_desc       WF_LOOKUPS.MEANING%TYPE;
  l_reject_reason_code       WF_LOOKUPS.LOOKUP_CODE%TYPE;


  CURSOR c_get_ord_num(p_order_header_id NUMBER) IS
         SELECT order_number, org_id
         FROM oe_order_headers_all
         WHERE header_id = p_order_header_id;

  CURSOR c_get_party_id(p_order_header_id NUMBER) IS
         SELECT fnd.customer_id
         FROM fnd_user fnd,
              oe_order_headers_all oe
         WHERE oe.header_id = p_order_header_id
         AND   oe.created_by = fnd.user_id;

  CURSOR c_get_reject_reason_desc(p_reject_reason_code VARCHAR2) IS
         SELECT meaning
	    FROM wf_lookups
	    WHERE lookup_type = 'OE_RMA_REJECTION_REASON'
	    AND lookup_code = p_reject_reason_code;



  BEGIN




    IF P_notif_context = G_RETURN_APPROVAL THEN

    -- Assign notif name

       l_notifName   := 'IBE_RETURNORDERAPPROVED';

    -- Check whether this notification is enabled

     l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);

       IF l_notifEnabled = 'Y' THEN



	 -- get the order number and org_id for the given order_header_id

             FOR c_order_num_rec IN c_get_ord_num(p_order_header_id)
             LOOP
                 l_order_number  := c_order_num_rec.order_number;
                 l_org_id        := c_order_num_rec.org_id;
             END LOOP;

       -- get party_id

          FOR c_party_rec IN c_get_party_id(p_order_header_id)
          LOOP
              l_party_id := c_party_rec.customer_id;
              l_user_name:= 'HZ_PARTY:'||l_party_id;
          END LOOP;

       -- get the user type

        l_usertype:= NULL;

	   ibe_workflow_pvt.getUserType(l_party_id,l_usertype);


         IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping(
             p_org_id          => l_OrgId        ,
              p_msite_id      => NULL             ,
             p_user_type       => NULL,
             p_notif_name      => l_notifName    ,
             x_enabled_flag    => l_msgEnabled   ,
             x_wf_message_name => l_MessageName  ,
             x_return_status   => x_return_status,
             x_msg_data        => x_msg_data     ,
             x_msg_count       => X_Msg_Count);



	   IF l_msgEnabled = 'Y' Then

             l_item_key := l_event_type||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||p_order_header_id;

	        wf_engine.CreateProcess(
	          itemtype 	=> g_ItemType,
	          itemkey  	=> l_item_key,
	          process  	=> g_processName);

	       wf_engine.SetItemUserKey(
	          itemtype 	=> g_ItemType,
	          itemkey   => l_item_key,
	          userkey   => l_item_key);

	        wf_engine.SetItemAttrText(
	          itemtype 	=> g_ItemType,
	          itemkey  	=> l_item_key,
	          aname		=> 'MESSAGE',
	          avalue	=>  l_MessageName);

	        wf_engine.SetItemAttrText(
	          itemtype 	=> g_ItemType,
	          itemkey  	=> l_item_key,
	          aname		=> 'ITEMKEY',
	          avalue    => l_item_key);

	        wf_engine.SetItemAttrText(
	          itemtype 	=> g_ItemType,
	          itemkey  	=> l_item_key,
	          aname		=> 'EVENTTYPE',
	          avalue	=> l_event_type);


	        wf_engine.SetItemAttrText(
	          itemtype => g_ItemType,
	          itemkey  => l_item_key,
	          aname    => 'ORDERNUMBER',
	          avalue   => l_order_number);

	        wf_engine.SetItemAttrText(
	          itemtype => g_ItemType,
	          itemkey  => l_item_key,
	          aname    => 'URL',
	          avalue   => l_url);

	        wf_engine.SetItemAttrText(
	         itemtype => g_ItemType,
	         itemkey  => l_item_key,
	         aname    => 'SENDTO',
	         avalue   => l_user_name);

	       wf_engine.SetItemOwner(
	          itemtype 	=> g_ItemType,
	          itemkey	=> l_item_key,
	          owner	=> l_item_owner);

	        wf_engine.StartProcess(
	          itemtype 	=> g_ItemType,
	          itemkey  	=> l_item_key);


         END IF; --Msg Enabled


       END IF; --Notification Enabled

    ELSE

	  -- set event_type

       l_event_type := 'RETURNORDERREJECTED';

      -- Assign notif name

       l_notifName   := 'IBE_RETURNORDERREJECTED';

    -- Check whether this notification is enabled

     l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);

       IF l_notifEnabled = 'Y' THEN



	 -- get the order number and org_id for the given order_header_id

             FOR c_order_num_rec IN c_get_ord_num(p_order_header_id)
             LOOP
                 l_order_number  := c_order_num_rec.order_number;
                 l_org_id        := c_order_num_rec.org_id;
             END LOOP;

       -- get party_id

          FOR c_party_rec IN c_get_party_id(p_order_header_id)
          LOOP
              l_party_id := c_party_rec.customer_id;
              l_user_name:= 'HZ_PARTY:'||l_party_id;
          END LOOP;

         -- get the user type

        l_usertype:= NULL;

	   ibe_workflow_pvt.getUserType(l_party_id,l_usertype);

       -- get reject reason code meaning from wf_lookups

	     IF p_reject_reason_code is NULL THEN
		   l_reject_reason_code := 'NONE';
          ELSE
		   l_reject_reason_code := p_reject_reason_code;
          END IF;

          FOR c_reject_reason_desc_rec IN c_get_reject_reason_desc(l_reject_reason_code)
          LOOP
              l_reject_reason_desc  := c_reject_reason_desc_rec.meaning;
          END LOOP;



         IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping(
             p_org_id          => l_OrgId        ,
             p_msite_id        => NULL           ,
             p_user_type       => NULL,
             p_notif_name      => l_notifName    ,
             x_enabled_flag    => l_msgEnabled   ,
             x_wf_message_name => l_MessageName  ,
             x_return_status   => x_return_status,
             x_msg_data        => x_msg_data     ,
             x_msg_count       => X_Msg_Count);


	   IF l_msgEnabled = 'Y' Then

             l_item_key:= NULL;



             l_item_key := l_event_type||'REJECT'||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||p_order_header_id;




	        wf_engine.CreateProcess(
	          itemtype 	=> g_ItemType,
	          itemkey  	=> l_item_key,
	          process  	=> g_processName);

	       wf_engine.SetItemUserKey(
	          itemtype 	=> g_ItemType,
	          itemkey   => l_item_key,
	          userkey   => l_item_key);

	        wf_engine.SetItemAttrText(
	          itemtype 	=> g_ItemType,
	          itemkey  	=> l_item_key,
	          aname		=> 'MESSAGE',
	          avalue	=>  l_MessageName);


	        wf_engine.SetItemAttrText(
	          itemtype 	=> g_ItemType,
	          itemkey  	=> l_item_key,
	          aname		=> 'ITEMKEY',
	          avalue    => l_item_key);


	        wf_engine.SetItemAttrText(
	          itemtype 	=> g_ItemType,
	          itemkey  	=> l_item_key,
	          aname		=> 'EVENTTYPE',
	          avalue	=> l_event_type);


	        wf_engine.SetItemAttrText(
	          itemtype => g_ItemType,
	          itemkey  => l_item_key,
	          aname    => 'ORDERNUMBER',
	          avalue   => l_order_number);

	        wf_engine.SetItemAttrText(
	          itemtype => g_ItemType,
	          itemkey  => l_item_key,
	          aname    => 'URL',
	          avalue   => l_url);

	        wf_engine.SetItemAttrText(
	          itemtype => g_ItemType,
	          itemkey  => l_item_key,
	          aname    => 'REASON',
	          avalue   => l_reject_reason_desc);


	        wf_engine.SetItemAttrText(
	          itemtype => g_ItemType,
	          itemkey  => l_item_key,
	          aname    => 'COMMENTS',
	          avalue   => P_comments);


	        wf_engine.SetItemAttrText(
	         itemtype => g_ItemType,
	         itemkey  => l_item_key,
	         aname    => 'SENDTO',
	         avalue   => l_user_name);

	       wf_engine.SetItemOwner(
	          itemtype 	=> g_ItemType,
	          itemkey	=> l_item_key,
	          owner	=> l_item_owner);

	        wf_engine.StartProcess(
	          itemtype 	=> g_ItemType,
	          itemkey  	=> l_item_key);



         END IF; --Msg Enabled

       END IF; --Notification Enabled


    END IF; -- notif_context check


EXCEPTION

 WHEN OTHERS THEN
  x_return_status := FND_API.g_ret_sts_error;


  x_msg_count := 0;
  wf_core.context('IBE_WORKFLOW_PVT',l_notifname,l_messagename,p_order_header_id);
  RAISE;


  END notify_rma_request_action;


END IBE_OM_INTEGRATION_GRP;

/
