--------------------------------------------------------
--  DDL for Package Body OE_ORDER_IMPORT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_IMPORT_WF" AS
/* $Header: OEXWFOIB.pls 120.7 2005/12/09 05:02:20 kmuruges ship $ */

PROCEDURE OEOI_SELECTOR
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
)
IS
  l_user_id             NUMBER;
  l_resp_id             NUMBER;
  l_resp_appl_id        NUMBER;
  l_org_id              NUMBER;
  l_current_org_id      NUMBER;
  l_client_org_id       NUMBER;
  l_parameter1          NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OEOI_SELECTOR PROCEDURE' ) ;

      oe_debug_pub.add(  'THE WORKFLOW FUNCTION MODE IS: FUNCMODE='||P_FUNCMODE ) ;
  END IF;

  -- {
  IF (p_funcmode = 'RUN') THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'P_FUNCMODE IS RUN' ) ;
    END IF;
    p_x_result := G_WFR_COMPLETE;

  -- Engine calls SET_CTX just before activity execution

  ELSIF(p_funcmode = 'SET_CTX') THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'P_FUNCMODE IS SET_CTX' ) ;
    END IF;

    l_org_id :=  wf_engine.GetItemAttrNumber( G_WFI_ORDER_IMPORT
                             , p_itemkey
                             , 'ORG_ID'
                             );

    IF l_debug_level  > 0 THEN
     oe_debug_pub.add(' l_org_id =>' || l_org_id);
    END IF;

    mo_global.set_policy_context(p_access_mode => 'S', p_org_id=>l_Org_Id);
    p_x_result := G_WFR_COMPLETE;

  ELSIF (p_funcmode = 'TEST_CTX') THEN

  /* Delete Following before check
    l_org_id := wf_engine.GetItemAttrNumber
                          (itemtype => p_itemtype,
                           itemkey  => p_itemkey,
                           aname    => 'ORG_ID');
     If l_org_id is Null Then
      Begin
        Select  org_id
        Into    l_org_id
        From    oe_headers_interface
        Where   orig_sys_document_ref = p_itemkey
        And     order_source_id       = '20';
     Exception
       When Others Then
          Null;
      End;
     End If;

  */



  If p_itemtype = G_WFI_ORDER_IMPORT Then
    l_parameter1 := wf_engine.GetItemAttrNumber
                               (itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER1');
  End If;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'WF_PARA1 = '||L_PARAMETER1 ) ;
  END IF;
     wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                                itemkey    => p_itemkey,
                                aname      => 'ORG_ID',
                                avalue     => l_parameter1);

     l_org_id := l_parameter1;

     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'l_org_id (from workflow)=>'|| l_org_id ) ;
     END IF;

     IF (NVL(mo_global.get_current_org_id,-99) <> l_Org_Id)
     THEN
         p_x_result := 'FALSE';
     ELSE
         p_x_result := 'TRUE';
     END IF;


   END IF;
   -- p_funcmode }

EXCEPTION
   WHEN OTHERS THEN NULL;
   WF_CORE.Context('OE_ORDER_IMPORT_WF', 'OEOI_SELECTOR',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
   RAISE;

END OEOI_SELECTOR;

PROCEDURE OESO_SELECTOR
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
)
IS
  l_user_id             NUMBER;
  l_resp_id             NUMBER;
  l_resp_appl_id        NUMBER;
  l_org_id              NUMBER;
  l_current_org_id      NUMBER;
  l_client_org_id       NUMBER;
  l_parameter1          NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OESO_SELECTOR PROCEDURE' ) ;

      oe_debug_pub.add(  'THE WORKFLOW FUNCTION MODE IS: FUNCMODE='||P_FUNCMODE ) ;
  END IF;

  -- {
  IF (p_funcmode = 'RUN') THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'P_FUNCMODE IS RUN' ) ;
    END IF;
    p_x_result := G_WFR_COMPLETE;

  -- Engine calls SET_CTX just before activity execution

  ELSIF(p_funcmode = 'SET_CTX') THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'P_FUNCMODE IS SET_CTX' ) ;
    END IF;
    l_org_id :=  wf_engine.GetItemAttrNumber( G_WFI_SHOW_SO
                             , p_itemkey
                             , 'ORG_ID'
                             );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(' l_org_id =>' || l_org_id);
    END IF;

    mo_global.set_policy_context(p_access_mode => 'S', p_org_id=>l_Org_Id);
    p_x_result := G_WFR_COMPLETE;

  ELSIF (p_funcmode = 'TEST_CTX') THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'WF_PARA1 = '||L_PARAMETER1 ) ;
    END IF;

    l_org_id :=  wf_engine.GetItemAttrNumber( G_WFI_SHOW_SO
					    , p_itemkey
					    , 'ORG_ID'
					    );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'l_org_id (from workflow)=>'|| l_org_id ) ;
    END IF;

    IF (NVL(mo_global.get_current_org_id,-99) <> l_Org_Id)    THEN
        p_x_result := 'FALSE';
    ELSE
        p_x_result := 'TRUE';
    END IF;

 END IF;
   -- p_funcmode }

EXCEPTION
   WHEN OTHERS THEN NULL;
   WF_CORE.Context('OE_ORDER_SHOW_SO', 'OESO_SELECTOR',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
   RAISE;

END OESO_SELECTOR;


PROCEDURE OEOA_SELECTOR
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
)
IS
  l_user_id             NUMBER;
  l_resp_id             NUMBER;
  l_resp_appl_id        NUMBER;
  l_org_id              NUMBER;
  l_current_org_id      NUMBER;
  l_client_org_id       NUMBER;
  l_parameter1          NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OEOA_SELECTOR PROCEDURE' ) ;

      oe_debug_pub.add(  'THE WORKFLOW FUNCTION MODE IS: FUNCMODE='||P_FUNCMODE ) ;
  END IF;

  -- {
  IF (p_funcmode = 'RUN') THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'P_FUNCMODE IS RUN' ) ;
    END IF;
    p_x_result := G_WFR_COMPLETE;

  -- Engine calls SET_CTX just before activity execution

  ELSIF(p_funcmode = 'SET_CTX') THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'P_FUNCMODE IS SET_CTX' ) ;
    END IF;

    l_org_id :=  wf_engine.GetItemAttrNumber( G_WFI_ORDER_ACK
                             , p_itemkey
                             , 'ORG_ID'
                             );

    IF l_debug_level  > 0 THEN
     oe_debug_pub.add(' l_org_id =>' || l_org_id);
    END IF;

    mo_global.set_policy_context(p_access_mode => 'S', p_org_id=>l_Org_Id);

    p_x_result := G_WFR_COMPLETE;

  ELSIF (p_funcmode = 'TEST_CTX') THEN
  -- don't need this code because the org id is either passed from the
  -- OEOI flow or set directly in the function call
  /*If p_itemtype = G_WFI_ORDER_ACK Then
    l_parameter1 := wf_engine.GetItemAttrNumber
                               (itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'ORG_ID');
  End If;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'WF_PARA1 = '||L_PARAMETER1 ) ;
  END IF;
     wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                                itemkey    => p_itemkey,
                                aname      => 'ORG_ID',
                                avalue     => l_parameter1);
*/
     l_org_id :=  wf_engine.GetItemAttrNumber( G_WFI_ORDER_ACK
					    , p_itemkey
					    , 'ORG_ID'
					    );
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'l_org_id (from workflow)=>'|| l_org_id ) ;
     END IF;

     IF (NVL(mo_global.get_current_org_id,-99) <> l_Org_Id)
     THEN
        p_x_result := 'FALSE';
     ELSE
        p_x_result := 'TRUE';
     END IF;

   END IF;
   -- p_funcmode }

EXCEPTION
   WHEN OTHERS THEN NULL;
   WF_CORE.Context('OE_ORDER_IMPORT_WF', 'OEOA_SELECTOR',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
   RAISE;

END OEOA_SELECTOR;


PROCEDURE CALL_WF_PURGE
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  Update WF_ITEMS
  Set    END_DATE = sysdate - .01
  Where  ITEM_TYPE = p_itemtype
  And    ITEM_KEY  = p_itemkey;

  if sql%rowcount > 0 then
     WF_PURGE.ITEMS(p_itemtype, p_itemkey, sysdate, TRUE);
  end if;

EXCEPTION
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'CALL_WF_PURGE');
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS IN CALL_WF_PURGE MESSAGE : '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
    END IF;
END CALL_WF_PURGE;

PROCEDURE START_ORDER_IMPORT
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
)
IS
  l_errbuf          VARCHAR2(2000);
  l_retcode         NUMBER;
  l_order_source    VARCHAR2(240) := '20';
  l_operation_code  VARCHAR2(30);
--  l_debug_level     NUMBER :=
--                     to_number(nvl(fnd_profile.value('ONT_DEBUG_LEVEL'),'0'));
  l_request_id      NUMBER;
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
  l_return_status   VARCHAR2(1);

  new_request_id    NUMBER;

  l_sync            VARCHAR2(30) :=
                     fnd_profile.value('ONT_TRANSACTION_PROCESSING');

  l_phase           VARCHAR2(30);
  l_status          VARCHAR2(30);
  l_dev_phase       VARCHAR2(30);
  l_dev_status      VARCHAR2(30);
  l_message         VARCHAR2(240);
  l_exists          VARCHAR2(30);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF p_funcmode = 'RUN' THEN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING START_ORDER_IMPORT' ) ;

      oe_debug_pub.add(  'START_ORDER_IMPORT ACTIVITY ID = '||P_ACTID ) ;
  END IF;

  -- { If the Profile option ONT_TRANSACTION_PROCESSING is not set or not
  -- SYNCHRONOUS then no need to start the concurrent process as this will
  -- be done by user, in BATCH/ASYNCHRONOUS

  OE_STANDARD_WF.Set_Msg_Context(p_actid);
  If nvl(l_sync, 'SYNCHRONOUS') = 'ASYNCHRONOUS' Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'NO NEED TO START THE CONC. PROGRAM AS PROFILE IS NOT SET' ) ;
     END IF;
     p_x_result := G_WFR_NOT_ELIGIBLE;
     return;
  End If;

  p_x_result := G_WFR_COMPLETE;

  wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                             itemkey    => p_itemkey,
                             aname      => 'OM_DEBUG_LEVEL',
                             avalue     => l_debug_level);
  -- }
  OE_STANDARD_WF.Save_Messages;
  OE_STANDARD_WF.Clear_Msg_Context;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING START_ORDER_IMPORT' ) ;
  END IF;

END IF;
  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    p_x_result := 'COMPLETE';
    return;
  end if;
EXCEPTION

  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'start_order_import');
    END IF;
    WF_CORE.Context('OE_ORDER_IMPORT_WF', 'START_ORDER_IMPORT',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => p_actid,
                                          p_itemtype => p_itemtype,
                                          p_itemkey => p_itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN EXCEPTION ' || SQLERRM ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING START_ORDER_IMPORT WITH OTHERS EXCEPTION' ) ;
    END IF;
    RAISE;
END;


PROCEDURE IS_OI_COMPLETE
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
)
IS
  l_orig_sys_document_ref VARCHAR2(50);
  l_errbuf            VARCHAR2(2000);
  l_retcode           NUMBER;
  l_request_id        NUMBER;
  l_exists            VARCHAR2(30);
  l_result            VARCHAR2(1);
  l_activity_result   VARCHAR2(30);
  l_activity_status   VARCHAR2(8);
  l_activity_id       NUMBER;
  l_xml_transaction_type_code VARCHAR2(30);
  l_sold_to_org_id    NUMBER;
  l_change_sequence   VARCHAR2(50);
  l_customer_key_profile VARCHAR2(1)  :=  'N';

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF p_funcmode = 'RUN' THEN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING IS_OI_COMPLETE' ) ;
  END IF;
  OE_STANDARD_WF.Set_Msg_Context(p_actid);

  get_activity_result( p_itemtype             => p_itemtype
                     , p_itemkey              => p_itemkey
                     , p_activity_name         => 'RUN_ORDER_IMPORT'
                     , x_return_status         => l_result
                     , x_activity_result       => l_activity_result
                     , x_activity_status_code  => l_activity_status
                     , x_activity_id           => l_activity_id
                     );


 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
  fnd_profile.get('ONT_INCLUDE_CUST_IN_OI_KEY', l_customer_key_profile);
  l_customer_key_profile := nvl(l_customer_key_profile, 'N');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CUSTOMER KEY PROFILE SETTING = '||l_customer_key_profile ) ;
  END IF;
 End If;


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_ACTIVITY_ID IS ' || L_ACTIVITY_ID ) ;

      oe_debug_pub.add(  'L_REQUEST_ID IS ' || L_REQUEST_ID ) ;
  END IF;
  l_request_id := wf_engine.GetItemAttrNumber( itemtype => p_itemtype
                                                 , itemkey  => p_itemkey
                                                 , aname    => 'REQ_ID'
                                                 );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_REQUEST_ID IS ' || L_REQUEST_ID ) ;
  END IF;
  Begin
    Select request_id
    Into   l_request_id
    From   fnd_concurrent_requests
    Where  parent_request_id = l_request_id;

    wf_engine.SetItemAttrNumber (itemtype   => p_itemtype,
                                 itemkey    => p_itemkey,
                                 aname      => 'REQ_ID',
                                 avalue     => l_request_id);
  Exception
   When Others Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OTHERS EXCEPTION: SETTING L_REQUEST_ID TO NULL' ) ;
     END IF;
     l_request_id := Null;
  End;

  l_orig_sys_document_ref := wf_engine.GetItemAttrText( itemtype => p_itemtype,
                                               	      	itemkey  => p_itemkey,
                                                      	aname    => 'PARAMETER2'
						      	);
  l_xml_transaction_type_code := wf_engine.GetItemAttrText( itemtype => p_itemtype,
                                               	      	itemkey  => p_itemkey,
                                                      	aname    => 'PARAMETER3'
						      	);

 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
  l_sold_to_org_id := wf_engine.GetItemAttrNumber( itemtype => p_itemtype,
                                               	      	      itemkey  => p_itemkey,
                                                      	      aname    => 'PARAMETER4'
						      	     );

  l_change_sequence := wf_engine.GetItemAttrText( itemtype => p_itemtype,
                                               	      	      itemkey  => p_itemkey,
aname    => 'PARAMETER7'
						      	     );
 End If;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_ORIG_SYS_DOCUMENT_REF IS ' || L_ORIG_SYS_DOCUMENT_REF ) ;
       oe_debug_pub.add(  'L_SOLD_TO_ORG_ID IS ' || L_SOLD_TO_ORG_ID ) ;
       oe_debug_pub.add(  'L_CHANGE_SEQUENCE IS ' || L_CHANGE_SEQUENCE ) ;
   END IF;

   -- start exception management
   OE_MSG_PUB.set_msg_context(
           p_entity_code                => 'ELECMSG_'||p_itemtype
          ,p_entity_id                  => p_itemkey
          ,p_header_id                  => null
          ,p_line_id                    => null
          ,p_order_source_id            => OE_ACKNOWLEDGMENT_PUB.G_XML_ORDER_SOURCE_ID
          ,p_orig_sys_document_ref      => l_orig_sys_document_ref
          ,p_orig_sys_document_line_ref => null
          ,p_orig_sys_shipment_ref      => null
          ,p_change_sequence            => l_change_sequence
          ,p_source_document_type_id    => null
          ,p_source_document_id         => null
          ,p_source_document_line_id    => null );
   -- end exception management

   Begin
    Select  request_id
    Into    l_request_id
    From    oe_headers_interface
    Where   order_source_id       =  20
    And     orig_sys_document_ref = l_orig_sys_document_ref
    And     request_id            = nvl(l_request_id, request_id)
    And     decode(l_customer_key_profile, 'Y',
	    nvl(sold_to_org_id,                  -999), 1)
            = decode(l_customer_key_profile, 'Y',
	    nvl(l_sold_to_org_id,                -999), 1)
    And nvl(  change_sequence,		' ')
      = nvl(l_change_sequence,		' ')
    And     xml_transaction_type_code = l_xml_transaction_type_code
    And     error_flag            = 'Y';
    p_x_result := G_WFR_INCOMPLETE;
  Exception
    When NO_DATA_FOUND Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'G_WFR_COMPLETE , L_REQUEST_ID = '|| L_REQUEST_ID ) ;
     END IF;
      p_x_result := G_WFR_COMPLETE;
    When OTHERS Then
      p_x_result := G_WFR_NOT_ELIGIBLE;
  End;

  wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                             itemkey    => p_itemkey,
                             aname      => 'ORDER_IMPORTED',
                             avalue     => p_x_result);

  If p_x_result = G_WFR_INCOMPLETE Then
     wf_engine.SetItemAttrNumber (itemtype   => p_itemtype,
                                  itemkey    => p_itemkey,
                                  aname      => 'REQ_ID',
                                  avalue     => l_request_id);
  End If;

  OE_STANDARD_WF.Save_Messages;
  OE_STANDARD_WF.Clear_Msg_Context;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING IS_OI_COMPLETE' ) ;
  END IF;
END IF;

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    p_x_result := 'COMPLETE';
    return;
  end if;


EXCEPTION

  WHEN OTHERS THEN
    p_x_result := G_WFR_NOT_ELIGIBLE;
    wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                               itemkey    => p_itemkey,
                               aname      => 'ORDER_IMPORTED',
                               avalue     => p_x_result);
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'is_oi_complete');
    END IF;
    WF_CORE.Context('OE_ORDER_IMPORT_WF', 'IS_OI_COMPLETE',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => p_actid,
                                          p_itemtype => p_itemtype,
                                          p_itemkey => p_itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN EXCEPTION ' || SQLERRM ) ;

        oe_debug_pub.add(  'EXITING IS_OI_COMPLETE WITH OTHERS EXCEPTION' ) ;
    END IF;
    RAISE;
END IS_OI_COMPLETE;

PROCEDURE set_delivery_data
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
)
IS

  l_cust_acct_site_id NUMBER;
  l_party_id          NUMBER;
  l_party_site_id     NUMBER;
  l_header_id         NUMBER;
  l_document_id       NUMBER;
  l_order_imported    VARCHAR2(10);
  l_start_from_flow   Varchar2(6);
  l_parameter2        NUMBER;
  l_transaction_type    Varchar2(3);
  l_transaction_subtype Varchar2(6);
  l_orig_sys_document_ref VARCHAR2(50);
  l_original_transaction_type VARCHAR2(6);
  l_xml_transaction_type_code VARCHAR2(30);
  l_request_id        NUMBER;
  l_sold_to_org_id    NUMBER;
  l_change_sequence   VARCHAR2(50);
  l_org_id            NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF p_funcmode = 'RUN' THEN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING SET_DELIVERY_DATA' ) ;

      oe_debug_pub.add(  'P_ITEMTYPE => ' || P_ITEMTYPE ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'P_ITEMKEY => ' || P_ITEMKEY ) ;
  END IF;
  --ecx_debug.g_debug_level := 3;
  OE_STANDARD_WF.Set_Msg_Context(p_actid);
  l_start_from_flow := wf_engine.GetItemAttrText( p_itemtype
                                                , p_itemkey
                                                , 'START_FROM_FLOW'
                                                );

  l_orig_sys_document_ref := wf_engine.GetItemAttrText( p_itemtype
                                                , p_itemkey
                                                , 'ORIG_SYS_DOCUMENT_REF'
                                                );
  l_original_transaction_type := wf_engine.GetItemAttrText( p_itemtype
                                                , p_itemkey
                                                , 'PARAMETER3'
                                                );
  -- bug 3561088
  -- Note: for OESO, the document id is the item key and this
  -- assignment is done directly in the workflow
  If p_itemtype = G_WFI_ORDER_ACK Then
     l_document_id := wf_engine.GetItemAttrNumber( p_itemtype
                                                , p_itemkey
                                                , 'PARAMETER5'
                                                , TRUE);
  End If;
  -- end bug 3561088

 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
  l_sold_to_org_id := wf_engine.GetItemAttrNumber( p_itemtype
                                                , p_itemkey
                                                , 'PARAMETER4'
                                                );
  /* added for the message context setting */
  l_change_sequence := wf_engine.GetItemAttrText( p_itemtype
                                                , p_itemkey
                                                , 'PARAMETER7'
                                                , TRUE
                                                );
 End If;

   -- start bug 3688227
   OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'ELECMSG_'||p_itemtype
        ,p_entity_ref                 => null
        ,p_entity_id                  => p_itemkey
        ,p_header_id                  => null
        ,p_line_id                    => null
        ,p_order_source_id            => OE_ACKNOWLEDGMENT_PUB.G_XML_ORDER_SOURCE_ID
        ,p_orig_sys_document_ref      => l_orig_sys_document_ref
        ,p_change_sequence            => l_change_sequence
        ,p_orig_sys_document_line_ref => null
        ,p_orig_sys_shipment_ref      => null
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );
   -- end bug 3688227

  If (l_start_from_flow = G_WFI_IMPORT_PGM) Then
      l_request_id := wf_engine.GetItemAttrNumber( p_itemtype
                                                 , p_itemkey
                                                 , 'REQ_ID'
                                                 );
  Elsif (l_start_from_flow = G_WFI_ORDER_IMPORT) Then
      l_request_id := wf_engine.GetItemAttrNumber( G_WFI_ORDER_IMPORT
                                                 , p_itemkey
                                                 , 'REQ_ID'
                                                 );
  End If;

  -- reassign to a meaningful variable name for clarity in SQL statements
  l_xml_transaction_type_code := l_original_transaction_type;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_ORIG_SYS_DOCUMENT_REF = ' || L_ORIG_SYS_DOCUMENT_REF ) ;
      oe_debug_pub.add(  'L_ORIGINAL_TRANSACTION_TYPE = ' || L_ORIGINAL_TRANSACTION_TYPE ) ;
      oe_debug_pub.add ( 'L_XML_TRANSACTION_TYPE_CODE = ' || L_XML_TRANSACTION_TYPE_CODE);
      oe_debug_pub.add(  'L_SOLD_TO_ORG_ID IS ' || L_SOLD_TO_ORG_ID ) ;
      oe_debug_pub.add(  'L_DOCUMENT_ID IS ' || L_DOCUMENT_ID ) ;
      oe_debug_pub.add(  'L_REQUEST_ID = ' || L_REQUEST_ID ) ;
  END IF;

  If p_itemtype = G_WFI_ORDER_ACK and
     l_start_from_flow = Oe_Globals.G_WFI_LIN Then
     p_x_result := G_WFR_NOT_ELIGIBLE;
     Return;
  End If;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'START FROM FLOW = '||L_START_FROM_FLOW ) ;
  END IF;
  If l_start_from_flow = G_WFI_ORDER_IMPORT Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'START FROM FLOW = '|| L_START_FROM_FLOW ) ;
     END IF;
     l_order_imported := wf_engine.GetItemAttrText( G_WFI_ORDER_IMPORT
                                                  , p_itemkey
                                                  , 'ORDER_IMPORTED'
                                                  );
   If l_start_from_flow = G_WFI_ORDER_IMPORT And
      l_order_imported = G_WFR_COMPLETE Then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'START FROM FLOW IS OEOI AND IMPORT COMPLETE' ) ;
      END IF;
      l_header_id := Oe_Acknowledgment_Pub.get_header_id
                            ( p_orig_sys_document_ref => l_orig_sys_document_ref,
                              p_line_id               => Null,
                              p_sold_to_org_id        => l_sold_to_org_id);
   End If;

  Elsif p_itemtype = G_WFI_SHOW_SO Then
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ELSIF P_ITEMTYPE = '|| P_ITEMTYPE ) ;
   END IF;
   If l_start_from_flow = Oe_Globals.G_WFI_LIN Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ELSIF L_START_FROM_FLOW = '|| L_START_FROM_FLOW ) ;
     END IF;
      l_header_id := Oe_Acknowledgment_Pub.get_header_id
                            ( p_orig_sys_document_ref => Null,
                              p_line_id               => p_itemkey,
			      p_sold_to_org_id        => l_sold_to_org_id);
   Elsif l_start_from_flow IN (G_WFI_PROC, G_WFI_CONC_PGM) Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ELSIF L_START_FROM_FLOW = '|| L_START_FROM_FLOW ) ;
     END IF;
     l_header_id := wf_engine.GetItemAttrNumber( G_WFI_SHOW_SO
                                                , p_itemkey
                                                , 'HEADER_ID'
                                                );
   Elsif l_start_from_flow = Oe_Globals.G_WFI_HDR Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ELSIF L_START_FROM_FLOW = '|| L_START_FROM_FLOW ) ;
     END IF;
     l_header_id := p_itemkey; -- Item Key is the header id when started from header flow
   End If;
    l_order_imported := G_WFR_COMPLETE;

  Elsif p_itemtype = G_WFI_ORDER_ACK Then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ELSIF P_ITEMTYPE = '|| P_ITEMTYPE ) ;
    END IF;
   If l_start_from_flow = Oe_Globals.G_WFI_HDR Then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ELSIF L_START_FROM_FLOW = '|| L_START_FROM_FLOW ) ;
    END IF;
    l_header_id := p_itemkey;
   Elsif l_start_from_flow in (G_WFI_IMPORT_PGM, G_WFI_PROC) Then
    --check if the order is imported.
    l_order_imported := wf_engine.GetItemAttrText( p_itemtype
                                                 , p_itemkey
                                                 , 'ORDER_IMPORTED'
                                                 );
    If l_order_imported = 'Y' Then
      l_order_imported := G_WFR_COMPLETE;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'START FROM FLOW IS OEXVIMPB.PLS' ) ;
      END IF;
      l_header_id := Oe_Acknowledgment_Pub.get_header_id
                     ( p_orig_sys_document_ref => l_orig_sys_document_ref,
                       p_line_id               => Null,
		       p_sold_to_org_id        => l_sold_to_org_id);
    Else
      l_order_imported := G_WFR_INCOMPLETE;
    End If;
   Else
     p_x_result := G_WFR_NOT_ELIGIBLE;
     Return;
   End If;
    --l_order_imported := G_WFR_COMPLETE;
  End If;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_ORDER_IMPORTED = '||L_ORDER_IMPORTED ) ;
  END IF;

  -- bug 3688227
  IF l_header_id IS NOT NULL AND l_header_id <> FND_API.G_MISS_NUM THEN
     OE_MSG_PUB.update_msg_context(
        p_header_id            => l_header_id
     );
  END IF;
  -- end bug 3688227

  Begin
  If l_order_imported = G_WFR_INCOMPLETE Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'IN IF L_ORDER_IMPORT => ' || L_ORDER_IMPORTED ) ;
     END IF;
     -- check the usage of the ship_to_org_id
     Select sold_to_org_id, ship_to_org_id
     into   l_party_id, l_party_site_id
     from   oe_headers_interface
     where  orig_sys_document_ref = l_orig_sys_document_ref
     And    xml_transaction_type_code = l_xml_transaction_type_code
     And    request_id            = l_request_id
     And    order_source_id       = Oe_Acknowledgment_Pub.G_XML_ORDER_SOURCE_ID;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SOLD_TO_ORG_ID IN IF => ' || L_PARTY_ID ) ;
     END IF;
  Else
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'IN ELSIF L_ORDER_IMPORT => ' || L_ORDER_IMPORTED ) ;
     END IF;
     Select header_id, sold_to_org_id
     Into   l_header_id, l_party_id
     From   oe_order_headers
     Where  header_id = l_header_id
     And    order_source_id = Oe_Acknowledgment_Pub.G_XML_ORDER_SOURCE_ID;
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'HEADER_ID IN ELSIF =>' || L_HEADER_ID ) ;

        oe_debug_pub.add(  'XML_MESSAGE_ID IN ELSIF =>' || L_DOCUMENT_ID ) ;

        oe_debug_pub.add(  'SOLD_TO_ORG_ID IN ELSIF => ' || L_PARTY_ID ) ;
    END IF;

  End If;
  Exception
/*   When no_data_found then
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN WHEN NO DATA FOUND!!!!!') ;
        oe_debug_pub.add(  'L_PARTY_ID in when no data found => ' || L_PARTY_ID ) ;
      END IF;*/
    When Others Then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SELECT OF THE DATA FAILED FOR THE DOCUMENT' ) ;
          oe_debug_pub.add(  'L_PARTY_ID in when no data found => ' || L_PARTY_ID ) ;
      END IF;
      if  l_order_imported = G_WFR_INCOMPLETE Then
          fnd_message.set_name ('ONT', 'OE_OI_CUST_NOT_FOUND');
          fnd_message.set_token ('OPT_TABLE', 'in oe_headers_interface');
          fnd_message.set_token ('DOC_ID', l_orig_sys_document_ref);
          oe_msg_pub.add;
      else
          fnd_message.set_name ('ONT', 'OE_OI_CUST_NOT_FOUND');
          fnd_message.set_token ('OPT_TABLE', 'in oe_order_headers');
          fnd_message.set_token ('DOC_ID', l_header_id);
          oe_msg_pub.add;
      end if;
      null;
  End;


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE SELECT FOR THE ACCOUNT SITE AND PARTY ID' ) ;
  END IF;
  l_org_id := MO_GLOBAL.Get_Current_Org_Id;
  SELECT /* MOAC_SQL_CHANGE */ a.cust_acct_site_id, a.party_site_id, c.party_id
  Into   l_cust_acct_site_id, l_party_site_id,  l_party_id
  From   hz_cust_acct_sites_all a, hz_cust_site_uses_all b, hz_cust_accounts c
  Where  a.cust_acct_site_id = b.cust_acct_site_id
  And    a.cust_account_id   = l_party_id
  And    a.cust_account_id   = c.cust_account_id
/*  And     NVL(a.org_id,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),
           1,1),' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
           NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),
           ' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99) */
  And    a.org_id = l_org_id
  And    b.site_use_code = 'SOLD_TO'
  And    b.primary_flag = 'Y'
  And    b.status = 'A'
  And    a.status ='A';  --bug 2752321

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER SELECT FOR THE ACCOUNT SITE AND PARTY ID AND PARTY_SITE_ID' || L_CUST_ACCT_SITE_ID || ' & ' || L_PARTY_ID || ' & ' || L_PARTY_SITE_ID ) ;
  END IF;
  l_transaction_type := Oe_Acknowledgment_Pub.G_TRANSACTION_TYPE;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_TRANSACTION_TYPE = '||L_TRANSACTION_TYPE ) ;
  END IF;

  If p_itemtype = G_WFI_SHOW_SO Then
   l_transaction_subtype := l_original_transaction_type;  --Oe_Acknowledgment_Pub.G_TRANSACTION_SSO;
  Elsif p_itemtype = G_WFI_ORDER_ACK Then
   l_transaction_subtype := Oe_Acknowledgment_Pub.G_TRANSACTION_POA;
  End If;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_TRANSACTION_SUBTYPE = '||L_TRANSACTION_SUBTYPE ) ;
  END IF;

  wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                             itemkey    => p_itemkey,
                             aname      => 'ECX_TRANSACTION_TYPE',
                             avalue     =>  l_transaction_type);

  wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                             itemkey    => p_itemkey,
                             aname      => 'ECX_TRANSACTION_SUBTYPE',
                             avalue     =>  l_transaction_subtype);

  wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                             itemkey    => p_itemkey,
                             aname      => 'ECX_PARTY_ID',
                             avalue     =>  to_char(l_party_id));

  wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                             itemkey    => p_itemkey,
                             aname      => 'ECX_PARTY_SITE_ID',
                             avalue     => to_char(l_party_site_id));


  wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                             itemkey    => p_itemkey,
                             aname      => 'ECX_DOCUMENT_ID',
                             avalue     => to_char(l_document_id));

  wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                             itemkey    => p_itemkey,
                             aname      => 'ECX_PARAMETER1',
                             avalue     =>  l_orig_sys_document_ref);

  wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                             itemkey    => p_itemkey,
                             aname      => 'ECX_PARAMETER3',
                             avalue     =>  l_original_transaction_type);


 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
  wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                             itemkey    => p_itemkey,
                             aname      => 'ECX_PARAMETER4',
                             avalue     =>  to_char(l_sold_to_org_id));

--setting putting sequence value in workflow for 3a6/3a7
  If p_itemtype = G_WFI_SHOW_SO then
   wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                             itemkey    => p_itemkey,
                             aname      => 'ECX_PARAMETER5',
                             avalue     =>  p_itemkey);
  End If;
 Else

--setting putting sequence value in workflow for 3a6/3a7
  If p_itemtype = G_WFI_SHOW_SO then
   wf_engine.SetItemAttrText (itemtype   => p_itemtype,
                             itemkey    => p_itemkey,
                             aname      => 'ECX_PARAMETER4',
                             avalue     =>  p_itemkey);
  End If;
 End If;

  If p_itemtype = G_WFI_ORDER_ACK Then
    If (l_start_from_flow = G_WFI_ORDER_IMPORT) Then
      l_parameter2 := wf_engine.GetItemAttrNumber
                             (itemtype => OE_ORDER_IMPORT_WF.G_WFI_ORDER_IMPORT,
                              itemkey  => p_itemkey,
                              aname    => 'REQ_ID');
    Elsif (l_start_from_flow = G_WFI_IMPORT_PGM) Then
      l_parameter2 := wf_engine.GetItemAttrNumber
                             (itemtype => OE_ORDER_IMPORT_WF.G_WFI_ORDER_ACK,
                              itemkey  => p_itemkey,
                              aname    => 'REQ_ID');
    End If;

    wf_engine.SetItemAttrText(itemtype   => p_itemtype,
                              itemkey    => p_itemkey,
                              aname      => 'ECX_PARAMETER2',
                              avalue     =>  l_parameter2);

  End If;

    p_x_result := 'COMPLETE:COMPLETE';
 OE_STANDARD_WF.Save_Messages;
 OE_STANDARD_WF.Clear_Msg_Context;
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'EXITING SET_DELIVERY_DATA' ) ;
 END IF;

END IF;
  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    p_x_result := 'COMPLETE';
    return;
  end if;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_x_result := 'COMPLETE:ERROR';
    p_x_result := FND_API.G_RET_STS_ERROR;
    fnd_message.set_name ('ONT', 'OE_OI_CUST_SITE_NOT_FOUND');
    fnd_message.set_token ('CUST_ID', l_party_id);
    oe_msg_pub.add;
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
  WHEN OTHERS THEN
    p_x_result := 'COMPLETE:ERROR';
    p_x_result := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'set_delivery_data');
    END IF;
    WF_CORE.Context('OE_ORDER_IMPORT_WF', 'SET_DELIVERY_DATA',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => p_actid,
                                          p_itemtype => p_itemtype,
                                          p_itemkey => p_itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
    END IF;
    RAISE;
END set_delivery_data;

PROCEDURE is_partner_setup
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
)
IS

  l_party_id            NUMBER;
  l_party_site_id       NUMBER;
  l_header_id           NUMBER;
  l_document_id         NUMBER;
  l_order_imported      VARCHAR2(10);
  l_cust_acct_site_id   NUMBER;
  l_transaction_type    VARCHAR2(25) := 'ONT';
  l_transaction_subtype VARCHAR2(25) := 'POA';
  l_is_delivery_reqd    Varchar2(1);
  l_return_status       Varchar2(30);
  l_orig_sys_document_ref VARCHAR2(50);
  l_request_id          NUMBER;
  l_xml_transaction_type_code VARCHAR2(30);
  l_sold_to_org_id      NUMBER;
  l_change_sequence     VARCHAR2(50);
  l_customer_key_profile VARCHAR2(1)  :=  'N';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF p_funcmode = 'RUN' THEN
/*
  insert into alok values('222');
  insert into alok values(fnd_profile.value('CONC_REQUEST_ID'));
  oe_debug_pub.G_DEBUG_MODE := 'FILE';
   oe_debug_pub.Debug_ON;
*/
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING IS_PARTNER_SETUP PROCEDURE' ) ;
  END IF;

 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
  fnd_profile.get('ONT_INCLUDE_CUST_IN_OI_KEY', l_customer_key_profile);
  l_customer_key_profile := nvl(l_customer_key_profile, 'N');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CUSTOMER KEY PROFILE SETTING = '||l_customer_key_profile ) ;
  END IF;
 End If;

  OE_STANDARD_WF.Set_Msg_Context(p_actid);
  If p_itemtype = G_WFI_ORDER_IMPORT Then
    l_order_imported := wf_engine.GetItemAttrText
                                  (itemtype => p_itemtype,
                                   itemkey  => p_itemkey,
                                   aname    => 'ORDER_IMPORTED');

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_ORDER_IMPORTED ' || L_ORDER_IMPORTED ) ;
  END IF;

  l_orig_sys_document_ref := wf_engine.GetItemAttrText
                                  (itemtype => p_itemtype,
                                   itemkey  => p_itemkey,
                                   aname    => 'PARAMETER2');

  l_xml_transaction_type_code := wf_engine.GetItemAttrText
                                  (itemtype => p_itemtype,
                                   itemkey  => p_itemkey,
                                   aname    => 'PARAMETER3');

 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
  l_sold_to_org_id            :=  wf_engine.GetItemAttrNumber
                                  (itemtype => p_itemtype,
                                   itemkey  => p_itemkey,
                                   aname    => 'PARAMETER4');

  l_change_sequence := wf_engine.GetItemAttrText
                                  (itemtype => p_itemtype,
                                   itemkey  => p_itemkey,
                                   aname    => 'PARAMETER7');
 End If;

 -- start bug 3688227
 OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'ELECMSG_'||p_itemtype
        ,p_entity_ref                 => null
        ,p_entity_id                  => p_itemkey
        ,p_header_id                  => null
        ,p_line_id                    => null
        ,p_order_source_id            => OE_ACKNOWLEDGMENT_PUB.G_XML_ORDER_SOURCE_ID
        ,p_orig_sys_document_ref      => l_orig_sys_document_ref
        ,p_change_sequence            => l_change_sequence
        ,p_orig_sys_document_line_ref => null
        ,p_orig_sys_shipment_ref      => null
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );
 -- end bug 3688227

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_ORIG_SYS_DOCUMENT_REF ' || L_ORIG_SYS_DOCUMENT_REF ) ;
      oe_debug_pub.add(  'L_XML_TRANSACTION_TYPE_CODE ' || L_XML_TRANSACTION_TYPE_CODE ) ;
      oe_debug_pub.add(  'L_SOLD_TO_ORG_ID ' || L_SOLD_TO_ORG_ID ) ;
      oe_debug_pub.add(  'L_CHANGE_SEQUENCE ' || L_CHANGE_SEQUENCE ) ;
  END IF;
  l_request_id := wf_engine.GetItemAttrNumber( itemtype => p_itemtype
                                                 , itemkey  => p_itemkey
                                                 , aname    => 'REQ_ID'
                                                 );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_REQUEST_ID ' || L_REQUEST_ID ) ;
  END IF;
    If l_order_imported = G_WFR_COMPLETE Then

       Select header_id, xml_message_id, sold_to_org_id, ship_to_org_id
       Into   l_header_id, l_document_id, l_party_id, l_party_site_id
       From   oe_order_headers
       Where  order_source_id = Oe_Acknowledgment_Pub.G_XML_ORDER_SOURCE_ID
       And    orig_sys_document_ref = l_orig_sys_document_ref
       And decode(l_customer_key_profile, 'Y',
	   nvl(sold_to_org_id,                  -999), 1)
         = decode(l_customer_key_profile, 'Y',
	   nvl(l_sold_to_org_id,                -999), 1);

    Else
       -- check the usage of the ship_to_org_id
       Select xml_message_id, sold_to_org_id, ship_to_org_id
       into   l_document_id, l_party_id, l_party_site_id
       from   oe_headers_interface
       where  order_source_id = Oe_Acknowledgment_Pub.G_XML_ORDER_SOURCE_ID
       And    orig_sys_document_ref = l_orig_sys_document_ref
       And    decode(l_customer_key_profile, 'Y',
	      nvl(sold_to_org_id,                  -999), 1)
              = decode(l_customer_key_profile, 'Y',
              nvl(l_sold_to_org_id,                -999), 1)
       And    nvl(change_sequence,                    ' ')
              = nvl(l_change_sequence,               ' ')
       And    xml_transaction_type_code = l_xml_transaction_type_code
       And    request_id = l_request_id;

    End If;

  Else
    Select header_id, xml_message_id, sold_to_org_id, ship_to_org_id
    Into   l_header_id, l_document_id, l_party_id, l_party_site_id
    From   oe_order_headers
    Where  header_id = p_itemkey
    And    order_source_id = Oe_Acknowledgment_Pub.G_XML_ORDER_SOURCE_ID;
  End If;

  -- start exception management
  If l_header_id is not null then
     OE_MSG_PUB.update_msg_context(
        p_header_id            => l_header_id
        );
  End If;
  -- end exception management

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_PARTY_ID ' || L_PARTY_ID ) ;
      oe_debug_pub.add(  'L_PARTY_SITE_ID ' || L_PARTY_SITE_ID ) ;
      oe_debug_pub.add(  'BEFORE CALL TO ISDELIVERY REQ' ) ;
  END IF;
  OE_Acknowledgment_Pub.Is_Delivery_Required
                        (
                         p_customer_id          => l_party_id,
                         p_transaction_type     => l_transaction_type,
                         p_transaction_subtype  => l_transaction_subtype,
                         x_party_id             => l_party_id,
                         x_party_site_id        => l_party_site_id,
                         x_is_delivery_required => l_is_delivery_reqd,
                         x_return_status        => l_return_status
                        );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER CALL TO ISDELIVERY REQ' ) ;
  END IF;
  IF OE_Code_Control.Get_Code_Release_Level >= '110510' THEN
     wf_engine.SetItemAttrText (p_itemtype,
                                p_itemkey,
                                'ECX_PARTY_ID',
                                l_party_id);
     wf_engine.SetItemAttrText (p_itemtype,
                                p_itemkey,
                                'ECX_PARTY_SITE_ID',
                                l_party_site_id);
  END IF;
  p_x_result := l_is_delivery_reqd;
  OE_STANDARD_WF.Save_Messages;
  OE_STANDARD_WF.Clear_Msg_Context;

END IF;
  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    p_x_result := 'COMPLETE';
    return;
  end if;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF OE_Code_Control.Get_Code_Release_Level < '110510' THEN
       p_x_result := FND_API.G_RET_STS_ERROR;
    ELSE
       p_x_result := 'N';
    END IF;
    fnd_message.set_name ('ONT', 'OE_OI_CUST_NOT_FOUND');
    fnd_message.set_token ('OPT_TABLE', '');
    fnd_message.set_token ('DOC_ID', nvl(l_orig_sys_document_ref,p_itemkey));
    oe_msg_pub.add;
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
  WHEN OTHERS THEN
    IF OE_Code_Control.Get_Code_Release_Level < '110510' THEN
       p_x_result := FND_API.G_RET_STS_UNEXP_ERROR ;
    ELSE
       p_x_result := 'N';
    END IF;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'IS_Partner_Setup');
    END IF;
    WF_CORE.Context('OE_ORDER_IMPORT_WF', 'IS_PARTNER_SETUP',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => p_actid,
                                          p_itemtype => p_itemtype,
                                          p_itemkey => p_itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
    END IF;
    RAISE;

END is_partner_setup;

PROCEDURE Process_Xml_Acknowledgment_Wf
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
)
IS
  l_errbuf          VARCHAR2(2000);
  l_return_status   VARCHAR2(30);
  l_start_from_flow Varchar2(30);
  l_line_id         Number;
  l_orig_sys_document_ref VARCHAR2(50);
  l_transaction_type      Varchar2(30);
  l_header_id       Number;
  l_request_id      Number;
  l_sold_to_org_id  Number;
  l_change_sequence Varchar2(50);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

IF p_funcmode = 'RUN' THEN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OEXWFOI.PROCESS_XML_ACKNOWLEDGMENT_WF' ) ;
  END IF;
  OE_STANDARD_WF.Set_Msg_Context(p_actid);

  l_start_from_flow := wf_engine.GetItemAttrText( p_itemtype
                                                , p_itemkey
                                                , 'START_FROM_FLOW'
                                                );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE PARAMETER3' ) ;
  END IF;
  l_transaction_type := wf_engine.GetItemAttrText( p_itemtype
                                                 , p_itemkey
                                                 , 'PARAMETER3'
                                                );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'PARAMETER3 ='||L_TRANSACTION_TYPE ) ;
  END IF;


 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
  l_sold_to_org_id := wf_engine.GetItemAttrNumber( p_itemtype
                                             , p_itemkey
                                             , 'PARAMETER4'
                                             );


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SOLD_TO_ORG_ID ='|| L_SOLD_TO_ORG_ID ) ;
  END IF;


  l_change_sequence := wf_engine.GetItemAttrText( p_itemtype
                                             , p_itemkey
                                             , 'PARAMETER7'
                                             );


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CHANGE_SEQUENCE ='|| L_CHANGE_SEQUENCE ) ;
  END IF;
 End If;


  If p_itemtype = G_WFI_SHOW_SO Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXWFOI: P_ITEMTYPE IS '||P_ITEMTYPE ) ;

         oe_debug_pub.add(  'OEXWFOI: P_ITEMKEY IS '||P_ITEMKEY ) ;
     END IF;

     l_line_id := wf_engine.GetItemAttrNumber( p_itemtype
                                             , p_itemkey
                                             , 'LINE_ID'
                                             );
     l_header_id := wf_engine.GetItemAttrNumber( p_itemtype
                                             , p_itemkey
                                             , 'HEADER_ID'
                                             );

     -- exception management
     l_orig_sys_document_ref := wf_engine.GetItemAttrText( p_itemtype
                                             , p_itemkey
                                             , 'ORIG_SYS_DOCUMENT_REF'
                                             );
     -- end exception management
     -- start bug 3688227
     OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'ELECMSG_'||p_itemtype
        ,p_entity_ref                 => null
        ,p_entity_id                  => p_itemkey
        ,p_header_id                  => l_header_id
        ,p_line_id                    => null
        ,p_order_source_id            => OE_ACKNOWLEDGMENT_PUB.G_XML_ORDER_SOURCE_ID
        ,p_orig_sys_document_ref      => l_orig_sys_document_ref
        ,p_change_sequence            => l_change_sequence
        ,p_orig_sys_document_line_ref => null
        ,p_orig_sys_shipment_ref      => null
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );
     -- end bug 3688227


     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXWFOIB: RETRIEVING HEADER_ID....HEADER_ID IS '||L_HEADER_ID ) ;
     END IF;


     OE_Acknowledgment_Pub.Process_Xml_Acknowledgment(
                           p_orig_sys_document_ref  => p_itemkey,
                           p_itemtype               => p_itemtype,
                           p_start_from_flow        => l_start_from_flow,
                           p_transaction_type       => l_transaction_type,
                           p_line_id                => l_line_id,
			   p_header_id              => l_header_id,
                           p_request_id             => to_number(p_itemkey),
                           p_sold_to_org_id         => l_sold_to_org_id,
                           p_change_sequence        => l_change_sequence,
                           x_return_status          => l_return_status);
  Else

     If l_start_from_flow = OE_ORDER_IMPORT_WF.G_WFI_ORDER_IMPORT then
       	  l_request_id := wf_engine.GetItemAttrNumber
                             (itemtype => OE_ORDER_IMPORT_WF.G_WFI_ORDER_IMPORT,
                              itemkey  => p_itemkey,
                              aname    => 'REQ_ID');
     Elsif l_start_from_flow = OE_ORDER_IMPORT_WF.G_WFI_IMPORT_PGM then
       	  l_request_id := wf_engine.GetItemAttrNumber
                             (itemtype => p_itemtype,
                              itemkey  => p_itemkey,
                              aname    => 'REQ_ID');
     End if;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'REQUEST_ID IN ELSE ='||L_REQUEST_ID ) ;

         oe_debug_pub.add(  'OEXWFOI: P_ITEMTYPE IS '||P_ITEMTYPE ) ;
     END IF;
     l_orig_sys_document_ref := wf_engine.GetItemAttrText( p_itemtype
                                                         , p_itemkey
                                                         , 'ORIG_SYS_DOCUMENT_REF'
                                                         );
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXWFOI: REF ='||L_ORIG_SYS_DOCUMENT_REF ) ;
     END IF;

     -- start bug 3688227
     OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'ELECMSG_'||p_itemtype
        ,p_entity_ref                 => null
        ,p_entity_id                  => p_itemkey
        ,p_header_id                  => null
        ,p_line_id                    => null
        ,p_order_source_id            => OE_ACKNOWLEDGMENT_PUB.G_XML_ORDER_SOURCE_ID
        ,p_orig_sys_document_ref      => l_orig_sys_document_ref
        ,p_change_sequence            => l_change_sequence
        ,p_orig_sys_document_line_ref => null
        ,p_orig_sys_shipment_ref      => null
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );
     -- end bug 3688227

     OE_Acknowledgment_Pub.Process_Xml_Acknowledgment(
                           p_orig_sys_document_ref  => l_orig_sys_document_ref,
                           p_itemtype               => p_itemtype,
                           p_start_from_flow        => l_start_from_flow,
                           p_transaction_type       => l_transaction_type,
			   p_header_id              => l_header_id,
			   p_request_id		    => l_request_id,
                           p_sold_to_org_id         => l_sold_to_org_id,
                           p_change_sequence        => l_change_sequence,
                           x_return_status          => l_return_status);
  End If;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OEXWFOI.PROCESS_XML_ACKNOWLEDGMENT_WF' ) ;
  END IF;

  IF OE_Code_Control.Get_Code_Release_Level < '110510' THEN
     p_x_result := 'COMPLETE:COMPLETE';
  ELSE
     p_x_result := G_WFR_COMPLETE;
  END IF;
  OE_STANDARD_WF.Save_Messages;
  OE_STANDARD_WF.Clear_Msg_Context;

END IF;
  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    p_x_result := 'COMPLETE';
    return;
  end if;
exception
  when others then
    IF OE_Code_Control.Get_Code_Release_Level < '110510' THEN
       p_x_result := 'COMPLETE:ERROR';
    ELSE
       p_x_result := G_WFR_INCOMPLETE;
    END IF;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'process_xml_acknowledgment_wf');
    END IF;
    WF_CORE.Context('OE_ORDER_IMPORT_WF', 'PROCESS_XML_ACKNOWLEDGMENT_WF',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => p_actid,
                                          p_itemtype => p_itemtype,
                                          p_itemkey => p_itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING WITH WHEN OTHERS EXCEPTION' ) ;
    END IF;
    RAISE;
End Process_Xml_Acknowledgment_Wf;

PROCEDURE Get_Activity_Result
( p_itemtype              IN      VARCHAR2
, p_itemkey               IN      VARCHAR2
, p_activity_name         IN      VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2

, x_activity_result OUT NOCOPY VARCHAR2

, x_activity_status_code OUT NOCOPY VARCHAR2

, x_activity_id OUT NOCOPY NUMBER

)
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_OI_WF.GET_ACTIVITY_RESULT '|| P_ITEMTYPE||'/'||P_ITEMKEY||'/'||P_ACTIVITY_NAME , 1 ) ;
  END IF;

  SELECT  wias.ACTIVITY_STATUS, wias.ACTIVITY_RESULT_CODE, wias.PROCESS_ACTIVITY
  INTO    x_activity_status_code, x_activity_result, x_activity_id
  FROM    WF_ITEM_ACTIVITY_STATUSES wias, WF_PROCESS_ACTIVITIES wpa
  WHERE   wias.ITEM_KEY         = p_itemkey
  AND     wias.ITEM_TYPE        = p_itemtype
  AND     wpa.ACTIVITY_NAME     = p_activity_name
  AND     wias.PROCESS_ACTIVITY = wpa.INSTANCE_ID;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_OI_WF.GET_ACTIVITY_RESULT '||X_ACTIVITY_RESULT||'/'||X_RETURN_STATUS , 1 ) ;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'Get_Activity_Result');
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
    END IF;

END Get_Activity_Result;

Procedure Raise_Event_Showso_Wf
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
)
Is
  --l_return_status      varchar2(1);
 l_sold_to_org_id     number;
 l_orig_sys_document_ref varchar2(50);
 l_order_source_id    Number;
 l_change_sequence    varchar2(50);
 l_is_delivery_reqd   varchar2(1) := 'N';
 l_return_status       Varchar2(30);
 l_party_id           Number;
 l_party_site_id      Number;
 l_order_number       Number;
 l_order_type_id      Number;
 l_org_id             Number;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
Begin

IF p_funcmode = 'RUN' THEN
  OE_STANDARD_WF.Set_Msg_Context(p_actid);
  If p_itemtype = Oe_Globals.G_WFI_HDR Then
    SELECT order_source_id, orig_sys_document_ref, sold_to_org_id, change_sequence, order_number, order_type_id, org_id
      INTO l_order_source_id, l_orig_sys_document_ref, l_sold_to_org_id, l_change_sequence, l_order_number, l_order_type_id, l_org_id
      FROM oe_order_headers
     WHERE header_id = p_itemkey;

   -- start bug 3688227
   -- this message context should be header, since this activity will
   -- be called from the order workflow
   OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'HEADER'
        ,p_entity_ref                 => null
        ,p_entity_id                  => null
        ,p_header_id                  => to_number(p_itemkey)
        ,p_line_id                    => null
        ,p_order_source_id            => l_order_source_id -- CANNOT hardcode 20 here
        ,p_orig_sys_document_ref      => l_orig_sys_document_ref
        ,p_change_sequence            => l_change_sequence
        ,p_orig_sys_document_line_ref => null
        ,p_orig_sys_shipment_ref      => null
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );
   -- end bug 3688227

    OE_Acknowledgment_Pub.Raise_Event_XMLInt (
             p_order_source_id        =>  l_order_source_id,
             p_partner_document_num   =>  l_orig_sys_document_ref,
             p_sold_to_org_id         =>  l_sold_to_org_id,
	     p_itemtype               =>  NULL,
             p_itemkey                =>  NULL,
	     p_transaction_type       =>  NULL,
             p_message_text           =>  NULL,
             p_document_num           =>  l_order_number,
             p_order_type_id          =>  l_order_type_id,
             p_change_sequence        =>  l_change_sequence,
             p_org_id                 =>  l_org_id,
             p_header_id              =>  p_itemkey,
             p_subscriber_list        =>  'DEFAULT',
             p_line_ids               =>  'ALL',
             x_return_status          =>  l_return_status);

    IF l_order_source_id = OE_Acknowledgment_Pub.G_XML_ORDER_SOURCE_ID THEN
          OE_Acknowledgment_Pub.Is_Delivery_Required
                        (
                         p_customer_id          => l_sold_to_org_id,
                         p_transaction_type     => OE_Acknowledgment_Pub.G_TRANSACTION_TYPE,
                         p_transaction_subtype  => OE_Acknowledgment_Pub.G_TRANSACTION_SSO,
                         x_party_id             => l_party_id,
                         x_party_site_id        => l_party_site_id,
                         x_is_delivery_required => l_is_delivery_reqd,
                         x_return_status        => l_return_status
                        );
       IF l_is_delivery_reqd = 'Y' THEN

        Oe_Acknowledgment_Pub.Raise_Event_Showso
          (p_header_id     => p_itemkey,
           p_line_id       => Null,
           p_customer_id   => l_sold_to_org_id,
           p_orig_sys_document_ref => l_orig_sys_document_ref,
           p_change_sequence => l_change_sequence,
           p_itemtype      => G_WFI_CONC_PGM,
           p_party_id      => l_party_id,
           p_party_site_id => l_party_site_id,
           p_commit_flag   => 'N',
           x_return_status => l_return_status);
      ELSE
        l_return_status := fnd_api.g_ret_sts_success;
      END IF;
   ELSE
     l_return_status := fnd_api.g_ret_sts_success;
   END IF;
  Elsif p_itemtype = Oe_Globals.G_WFI_LIN Then
    Oe_Acknowledgment_Pub.Raise_Event_Showso
       (p_header_id     => Null,
        p_line_id       => p_itemkey,
        p_customer_id   => Null,
        p_orig_sys_document_ref => Null,
        p_itemtype              => p_itemtype,
        x_return_status         => l_return_status);
  End If;

  if l_return_status = fnd_api.g_ret_sts_success then
     p_x_result := 'COMPLETE:COMPLETE';
  else
     p_x_result := 'COMPLETE:ERROR';
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'Raise_Event_Showso_Wf');
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
     END IF;
  end if;
  OE_STANDARD_WF.Save_Messages;
  OE_STANDARD_WF.Clear_Msg_Context;

END IF;
  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    p_x_result := 'COMPLETE';
    return;
  end if;
Exception
 When Others Then
    p_x_result := 'COMPLETE:ERROR';
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'Raise_Event_Showso_Wf');
    END IF;
    WF_CORE.Context('OE_ORDER_IMPORT_WF', 'RAISE_EVENT_SHOWSO_WF',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => p_actid,
                                          p_itemtype => p_itemtype,
                                          p_itemkey => p_itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
    END IF;
    RAISE;
End Raise_Event_Showso_Wf;

Procedure Set_User_Key
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
)
Is

  l_user_key          Varchar2(240);
  l_transaction_type  Varchar2(10);
  l_orig_sys_document_ref Varchar2(50)   := NULL;
  l_customer_number   Number;
  l_header_id	      Number;
  l_change_sequence   Varchar2(50);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

IF p_funcmode = 'RUN' THEN
  OE_STANDARD_WF.Set_Msg_Context(p_actid);
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING SET_USER_KEY' ) ;
  END IF;

  if (p_itemtype = OE_ORDER_IMPORT_WF.G_WFI_SHOW_SO) then
      l_header_id := wf_engine.GetItemAttrNumber(p_itemtype,
                                               p_itemkey,
                                               'HEADER_ID'
                                                );
      l_transaction_type := wf_engine.GetItemAttrText(p_itemtype,
                                                      p_itemkey,
                                                      'PARAMETER3'
                                                      );
      begin
         select orig_sys_document_ref, sold_to_org_id, change_sequence
         into   l_orig_sys_document_ref, l_customer_number, l_change_sequence
         from oe_order_headers
         where header_id = l_header_id;
      exception
         when others then
         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'set_user_key');
         END IF;
	 -- in this case, we do the best we can, and just use the customer and transaction type for the user key
      end;

      -- start exception management
      OE_MSG_PUB.set_msg_context(
           p_entity_code                => 'ELECMSG_'||p_itemtype
          ,p_entity_id                  => to_number(p_itemkey)
          ,p_header_id                  => l_header_id
          ,p_line_id                    => null
          ,p_order_source_id            => OE_ACKNOWLEDGMENT_PUB.G_XML_ORDER_SOURCE_ID
          ,p_orig_sys_document_ref      => l_orig_sys_document_ref
          ,p_orig_sys_document_line_ref => null
          ,p_orig_sys_shipment_ref      => null
          ,p_change_sequence            => l_change_sequence
          ,p_source_document_type_id    => null
          ,p_source_document_id         => null
          ,p_source_document_line_id    => null );
      -- end exception management

      If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
       l_user_key := l_orig_sys_document_ref || ',' || to_char(l_customer_number) || ',' || l_change_sequence || ',' || l_transaction_type; --OE_ACKNOWLEDGMENT_PUB.G_TRANSACTION_SSO;
      Else
       l_user_key := l_orig_sys_document_ref || ',' || to_char(l_customer_number) || ',' || l_transaction_type; --OE_ACKNOWLEDGMENT_PUB.G_TRANSACTION_SSO;
      End If;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'USER_KEY = '||L_USER_KEY ) ;
      END IF;
  elsif (p_itemtype = OE_ORDER_IMPORT_WF.G_WFI_ORDER_IMPORT) then
      l_orig_sys_document_ref := wf_engine.GetItemAttrText(p_itemtype,
                                                           p_itemkey,
                                                           'PARAMETER2'
                                                           );
      l_customer_number :=  wf_engine.GetItemAttrNumber(p_itemtype,
                                                      p_itemkey,
                                                      'PARAMETER4'
                                                      );
      l_transaction_type :=  wf_engine.GetItemAttrText(p_itemtype,
                                                       p_itemkey,
                                                       'PARAMETER3'
                                                       );

      If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
       l_change_sequence :=  wf_engine.GetItemAttrText(p_itemtype,
                                                       p_itemkey,
                                                       'PARAMETER7'
                                                       );
      -- start exception management
      OE_MSG_PUB.set_msg_context(
           p_entity_code                => 'ELECMSG_'||p_itemtype
          ,p_entity_id                  => p_itemkey
          ,p_header_id                  => null
          ,p_line_id                    => null
          ,p_order_source_id            => OE_ACKNOWLEDGMENT_PUB.G_XML_ORDER_SOURCE_ID
          ,p_orig_sys_document_ref      => l_orig_sys_document_ref
          ,p_orig_sys_document_line_ref => null
          ,p_orig_sys_shipment_ref      => null
          ,p_change_sequence            => l_change_sequence
          ,p_source_document_type_id    => null
          ,p_source_document_id         => null
          ,p_source_document_line_id    => null );
      -- end exception management

       l_user_key := l_orig_sys_document_ref || ',' || to_char(l_customer_number) || ',' || l_change_sequence || ',' || l_transaction_type;
      Else
       l_user_key := l_orig_sys_document_ref || ',' || to_char(l_customer_number) || ',' || l_transaction_type;
      End If;


      wf_engine.SetItemAttrText   (itemtype   => p_itemtype,
                                   itemkey    => p_itemkey,
                                   aname      => 'USER_KEY',
	          		        avalue     => l_user_key);

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'USER_KEY = '||L_USER_KEY ) ;
      END IF;
  else  -- now we will just assume that it is always passed in at this point
	-- TODO: we may need another else if to handle the ack being called from the conc_pgm or other workflow.
      l_user_key :=  wf_engine.GetItemAttrText(p_itemtype,
                                               p_itemkey,
                                               'USER_KEY'
                                               );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'USER_KEY = '||L_USER_KEY ) ;
      END IF;

  end if;
  wf_engine.SetItemUserKey(itemtype     => p_itemtype,
                           itemkey      => p_itemkey,
                           userkey      => l_user_key);


   p_x_result := 'COMPLETE:COMPLETE';
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING SET_USER_KEY' ) ;
  END IF;

  OE_STANDARD_WF.Save_Messages;
  OE_STANDARD_WF.Clear_Msg_Context;

END IF;
  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    p_x_result := 'COMPLETE';
    return;
  end if;
Exception
  When Others Then
    p_x_result := 'COMPLETE:ERROR';
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'set_user_key');
    END IF;
    WF_CORE.Context('OE_ORDER_IMPORT_WF', 'SET_USER_KEY',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => p_actid,
                                          p_itemtype => p_itemtype,
                                          p_itemkey => p_itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    RAISE;
End Set_User_Key;

Procedure Is_CBOD_Out_Reqd
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
) is

  l_confirmation        	VARCHAR2(2000);
  l_message_id                  NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
Begin

IF p_funcmode = 'RUN' THEN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING IS_CBOD_OUT_REQD' ) ;
  END IF;
  OE_STANDARD_WF.Set_Msg_Context(p_actid);
  l_message_id := wf_engine.GetItemAttrNumber (itemtype   => p_itemtype,
                                               itemkey    => p_itemkey,
                                               aname      => 'PARAMETER5');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_MESSAGE_ID : '|| L_MESSAGE_ID ) ;
  END IF;
  Begin
    select confirmation
    into l_confirmation
    from ecx_oag_cbod_v
    where document_id = l_message_id;
  Exception
    When NO_DATA_FOUND then
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'NO DATA FOUND IN IS_CBOD_OUT_REQD , RETURNING FALSE I.E. DO NOT SEND CBOD' ) ;
       END IF;
       p_x_result := 'F';
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'is_cbod_out_reqd');
       END IF;
    When OTHERS then
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'OTHERS IN IS_CBOD_OUT_REQD , RETURNING FALSE I.E. DO NOT SEND CBOD' ) ;
       END IF;
       p_x_result := 'F';
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'is_cbod_out_reqd');
       END IF;
  End;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_CONFIRMATION : '|| L_CONFIRMATION ) ;
  END IF;
  -- since we are only dealing with successes in our implementation,
  -- we only issue the cbod when l_confirmation is set to 2
  If l_confirmation = '2' then
    p_x_result := 'T';
  Else p_x_result := 'F';
  End If;

  --p_x_result := 'F';
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RETURN VALUE FOR IS_CBOD_OUT_REQD: ' || P_X_RESULT ) ;
  END IF;
  OE_STANDARD_WF.Save_Messages;
  OE_STANDARD_WF.Clear_Msg_Context;

END IF;
  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    p_x_result := 'COMPLETE';
    return;
  end if;
Exception
  When Others Then
    WF_CORE.Context('OE_ORDER_IMPORT_WF', 'IS_CBOD_OUT_REQD',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => p_actid,
                                          p_itemtype => p_itemtype,
                                          p_itemkey => p_itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    RAISE;
End Is_CBOD_Out_Reqd;

/* This function is no longer used but we might use it in the future */
Procedure  Populate_CBOD_Out_Globals
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
) Is

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
Begin
  OE_STANDARD_WF.Set_Msg_Context(p_actid);

  p_x_result := 'COMPLETE:COMPLETE'; --need this to avoid runtime error
  OE_STANDARD_WF.Save_Messages;
  OE_STANDARD_WF.Clear_Msg_Context;
End Populate_CBOD_Out_Globals;

Procedure  Set_CBOD_EVENT_KEY
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
) Is
l_event_key_num		number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

IF p_funcmode = 'RUN' THEN
/*  l_event_key_num := wf_engine.GetItemAttrNumber (itemtype   => p_itemtype,
                                               itemkey    => p_itemkey,
                                               aname      => 'PARAMETER5');
*/
  OE_STANDARD_WF.Set_Msg_Context(p_actid);
  select oe_xml_message_seq_s.nextval
  into l_event_key_num
  from dual;

   wf_engine.SetItemAttrText   (itemtype   => p_itemtype,
                                itemkey    => p_itemkey,
                                aname      => 'CBOD_EVENT_KEY',
			        avalue     => to_char(l_event_key_num));
   p_x_result := to_char(l_event_key_num);
   OE_STANDARD_WF.Save_Messages;
   OE_STANDARD_WF.Clear_Msg_Context;

END IF;
  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    p_x_result := 'COMPLETE';
    return;
  end if;
Exception
  WHEN OTHERS then
       p_x_result := NULL;
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'set_cbod_event_key');
       END IF;
       WF_CORE.Context('OE_ORDER_IMPORT_WF', 'SET_CBOD_EVENT_KEY',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
       OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => p_actid,
                                          p_itemtype => p_itemtype,
                                          p_itemkey => p_itemkey);
       OE_STANDARD_WF.Save_Messages;
       OE_STANDARD_WF.Clear_Msg_Context;
       RAISE;
End Set_cbod_event_key;




Procedure Raise_Event_Xmlint_Wf
( p_itemtype   IN     Varchar2,
  p_itemkey    IN     Varchar2,
  p_actid      in     number,
  p_funcmode   IN     Varchar2,
  p_x_result   IN OUT NOCOPY /* file.sql.39 change */ Varchar2
)
Is
  l_transaction_type        Varchar2(30);
  l_transaction_type_test1  Varchar2(30);
  l_transaction_type_test2  Varchar2(30);
  l_header_id               Number;
  l_document_num            Number;
  l_order_type_id           Number;
  l_orig_sys_document_ref   Varchar2(50);
  l_message_text            Varchar2(500);
  l_return_status           varchar2(1);
  l_processing_stage        varchar2(30);
  l_doc_status              varchar2(240);
  l_import_mode             varchar2(15);
  l_setup_status            varchar2(15);
  l_org_id                  NUMBER;
  l_document_id             NUMBER;
  l_document_direction      VARCHAR2(6);
  l_party_id                NUMBER;
  l_party_site_id           NUMBER;
  l_change_sequence         VARCHAR2(50);
  l_sold_to_org_id          NUMBER;
  l_conc_request_id         NUMBER;
  l_xml_message_id          Varchar2(240);
  l_internal_control_number Number;
  l_txn_token               Varchar2(50);
  l_document_disposition    VARCHAR2(20);
  l_customer_key_profile    VARCHAR2(1)  :=  'N';
  l_response_flag           VARCHAR2(1);
  l_standard_desc           VARCHAR2(80);
  l_failure_ack_flag        VARCHAR2(10) := 'N';
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
Begin

IF p_funcmode = 'RUN' THEN
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'ENTERING RAISE_EVENT_XMLINT_WF' ) ;
     oe_debug_pub.add(  'P_ITEMKEY => ' || P_ITEMKEY ) ;
     oe_debug_pub.add(  'P_ITEMTYPE => ' || P_ITEMTYPE ) ;
  END IF;

  OE_STANDARD_WF.Set_Msg_Context(p_actid);

  -- bug 3688227
  -- start bug 3688227
  -- this is all the info we have at this point
  OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'ELECMSG_'||p_itemtype
        ,p_entity_id                  => p_itemkey
        ,p_order_source_id            => OE_ACKNOWLEDGMENT_PUB.G_XML_ORDER_SOURCE_ID
        );
   -- end bug 3688227

  If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
     fnd_profile.get('ONT_INCLUDE_CUST_IN_OI_KEY', l_customer_key_profile);
     l_customer_key_profile := nvl(l_customer_key_profile, 'N');
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CUSTOMER KEY PROFILE SETTING = '||l_customer_key_profile ) ;
     END IF;
  End If;


  l_transaction_type_test1 := wf_engine.GetItemAttrText( p_itemtype
                                                 , p_itemkey
                                                 , 'ECX_TRANSACTION_SUBTYPE'
                                                );

  l_transaction_type_test2 := wf_engine.GetItemAttrText( p_itemtype
                                                 , p_itemkey
                                                 , 'PARAMETER3'
                                                );

  If l_transaction_type_test1 = Oe_Acknowledgment_Pub.G_TRANSACTION_POA
     OR l_transaction_type_test1 = Oe_Acknowledgment_Pub.G_TRANSACTION_CBODO Then
   --POA
   l_transaction_type := l_transaction_type_test1;
  Else
  --POI, CPO, or SSO
     l_transaction_type := l_transaction_type_test2;
  End If;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'L_TRANSACTION_TYPE => ' || L_TRANSACTION_TYPE ) ;
    oe_debug_pub.add(  'L_TRANSACTION_TYPE_TEST1 => ' || L_TRANSACTION_TYPE_TEST1 ) ;
    oe_debug_pub.add(  'L_TRANSACTION_TYPE_TEST2 => ' || L_TRANSACTION_TYPE_TEST2 ) ;
  END IF;

  l_processing_stage := wf_engine.GetActivityAttrText (p_itemtype,
                                                        p_itemkey,
                                                        p_actid,
                                                        'PROCESSING_STAGE',
                                                        TRUE);

   --setting Orig Sys Document Ref (Partner Document Number) for SSO
   If l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_SSO
      Or l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_CSO
   Then
      l_header_id := wf_engine.GetItemAttrNumber( p_itemtype
                                                 , p_itemkey
                                                 , 'HEADER_ID'
                                                );
      -- start bug 3688227
      OE_MSG_PUB.update_msg_context(
        p_header_id            => l_header_id
        );
      -- end bug 3688227

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'L_HEADER_ID => ' || L_HEADER_ID ) ;
      END IF;

      Begin
         Select orig_sys_document_ref
         Into l_orig_sys_document_ref
         From oe_order_headers
         Where header_id = l_header_id;
      -- start bug 3688227
      OE_MSG_PUB.update_msg_context(
        p_orig_sys_document_ref            => l_orig_sys_document_ref
        );
      -- end bug 3688227
      Exception
         When Others Then
           p_x_result := 'COMPLETE:ERROR';
           p_x_result := FND_API.G_RET_STS_UNEXP_ERROR ;
           IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'Raise_Event_Xmlint_Wf');
           END IF;
           -- start data fix project
           -- OE_STANDARD_WF.Save_Messages;
           -- OE_STANDARD_WF.Clear_Msg_Context;
           -- end data fix project
      End;

      l_xml_message_id := wf_engine.GetItemAttrText( p_itemtype
	       			        	  , p_itemkey
                                                  , 'ECX_MSGID_ATTR'
                                                  , TRUE
                                                  );

      IF OE_Code_Control.Get_Code_Release_Level >= '110510' THEN
         -- also get the request id for 3A6 Conc Pgm,
         -- don't check for Start From Flow Item Attr because it is
         -- unnecessary, request id will be null for non-conc pgm cases
         IF l_transaction_type = OE_Acknowledgment_Pub.G_TRANSACTION_SSO THEN
            l_conc_request_id := wf_engine.GetItemAttrNumber(p_itemtype
	                			            , p_itemkey
                                                            , 'REQ_ID'
                                                            , TRUE);
         END IF;
      END IF;

      IF OE_Code_Control.Get_Code_Release_Level < '110510' THEN
         l_processing_stage := 'OUTBOUND_SENT';
      END IF;
   Elsif ((l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_POI) OR
      (l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_CPO) OR
      (l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_CHO)) Then
      --setting Orig Sys Document Ref for POI or CPO

      l_orig_sys_document_ref :=  wf_engine.GetItemAttrText(p_itemtype
						, p_itemkey
                                                , 'PARAMETER2'
                                                );
      -- start bug 3688227
      OE_MSG_PUB.update_msg_context(
        p_orig_sys_document_ref           => l_orig_sys_document_ref
        );
      -- end bug 3688227

      l_internal_control_number := wf_engine.GetItemAttrNumber( p_itemtype
	                					, p_itemkey
                                                                , 'PARAMETER5'
                                                              );

      --also get the request id for OI
      IF OE_Code_Control.Get_Code_Release_Level >= '110510' THEN
         l_conc_request_id := wf_engine.GetItemAttrNumber(p_itemtype
                           			        , p_itemkey
                                                        , 'REQ_ID'
                                                        , TRUE);
         IF l_transaction_type = OE_Acknowledgment_Pub.G_TRANSACTION_CHO THEN
            l_response_flag := wf_engine.GetItemAttrText(p_itemtype
                           			        , p_itemkey
                                                        , 'PARAMETER10'
                                                        , TRUE);
         END IF;
      END IF;

      IF OE_Code_Control.Get_Code_Release_Level < '110510' THEN
         l_processing_stage := 'IMPORT_SUCCESS';
      END IF;
   Else

   --setting Orig Sys Document Ref for POA and CBODO
    l_orig_sys_document_ref :=  wf_engine.GetItemAttrText(p_itemtype
						, p_itemkey
                                                , 'ORIG_SYS_DOCUMENT_REF'
                                                );
    -- start bug 3688227
    OE_MSG_PUB.update_msg_context(
       p_orig_sys_document_ref           => l_orig_sys_document_ref
        );
    -- end bug 3688227

    l_xml_message_id := wf_engine.GetItemAttrText( p_itemtype
	       			        	  , p_itemkey
                                                  , 'ECX_MSGID_ATTR'
                                                  , TRUE
                                                  );
      IF OE_Code_Control.Get_Code_Release_Level < '110510' THEN
         l_processing_stage := 'OUTBOUND_SENT';
      END IF;
   End If;
   --Done Setting Orig Sys Document Ref (Partner Document Number)



   IF OE_Code_Control.Get_Code_Release_Level >= '110510' THEN
      l_org_id :=  wf_engine.GetItemAttrNumber ( p_itemtype
                                             , p_itemkey
                                             , 'ORG_ID'
                                             , TRUE
                                            );
      l_sold_to_org_id :=  wf_engine.GetItemAttrNumber( p_itemtype
                                             , p_itemkey
                                             , 'PARAMETER4'
                                             , TRUE);
      l_change_sequence :=  wf_engine.GetItemAttrText( p_itemtype
                                             , p_itemkey
                                             , 'PARAMETER7'
                                             , TRUE);
      -- start bug 3688227
      OE_MSG_PUB.update_msg_context(
        p_change_sequence           => l_change_sequence
        );
      -- end bug 3688227
   END IF;

   --Setting Document Number (Sales Order Number)
   -- we fetch it from the base table, only in the case when order import succeeded for an Inbound
   -- or if it is an SSO/CSO
   -- POA is handled separately

   If (l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_SSO OR
      l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_CSO OR
      ((l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_POI OR
        l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_CPO OR
        l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_CHO)
                       AND l_processing_stage IN ('IMPORT_SUCCESS')))  Then


      Begin
       Select order_number, order_type_id, header_id
       Into l_document_num, l_order_type_id, l_header_id
       From oe_order_headers
       Where orig_sys_document_ref = l_orig_sys_document_ref
       And decode(l_customer_key_profile, 'Y',
	   nvl(sold_to_org_id,                  -999), 1)
         = decode(l_customer_key_profile, 'Y',
	   nvl(l_sold_to_org_id,                -999), 1)
       And order_source_id = Oe_Acknowledgment_Pub.G_XML_ORDER_SOURCE_ID;


      -- start bug 4195533
      OE_MSG_PUB.update_msg_context(
        p_header_id            => l_header_id
        );
      -- end bug 4195533

      Exception
        When Others Then
          p_x_result := 'COMPLETE:ERROR';
          p_x_result := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'Raise_Event_Xmlint_Wf');
           END IF;
           -- start data fix project
           -- OE_STANDARD_WF.Save_Messages;
           -- OE_STANDARD_WF.Clear_Msg_Context;
           -- end data fix project
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EXCEPTION IN RAISE_EVENT_XMLINT...SELECTING DOCUMENT NUMBER FOR ' || P_ITEMTYPE ) ;
             END IF;
      End;

   Elsif l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_CBODO THEN --do nothing, just trap
      null;

   Elsif l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_POA THEN

      l_failure_ack_flag := wf_engine.GetItemAttrText( p_itemtype
                                                  , p_itemkey
                                                  , 'ORDER_IMPORTED'
                                                  );

     -- Bug 4179657
     -- Failure acknowledgments were also resolving to an Order Number
     -- if there was an existing order in the system
     -- Therefore, use a parameter to indicate whether or not order
     -- import succeeded

     If l_failure_ack_flag IN (G_WFR_COMPLETE,'Y') Then
        l_failure_ack_flag := 'N';
     Else
        l_failure_ack_flag := 'Y';
     End If;
     -- end bug 4179657

     Begin
      -- try to get document num for "success" POA

       Select order_number, order_type_id, header_id
       Into l_document_num, l_order_type_id, l_header_id
       From oe_order_headers
       Where orig_sys_document_ref = l_orig_sys_document_ref
       And decode(l_customer_key_profile, 'Y',
	   nvl(sold_to_org_id,                  -999), 1)
         = decode(l_customer_key_profile, 'Y',
           nvl(l_sold_to_org_id,                -999), 1)
       And order_source_id = Oe_Acknowledgment_Pub.G_XML_ORDER_SOURCE_ID;

        -- start bug 4195533
        IF l_failure_ack_flag = 'N' THEN
           OE_MSG_PUB.update_msg_context(
              p_header_id            => l_header_id
           );
        END IF;
        -- end bug 4195533

     Exception
       When NO_DATA_FOUND then
         -- otherwise set null document num for "failure" POA
         l_document_num := NULL;

       When Others Then
          p_x_result := 'COMPLETE:ERROR';
          p_x_result := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'Raise_Event_Xmlint_Wf');
          END IF;
          OE_STANDARD_WF.Save_Messages;
          OE_STANDARD_WF.Clear_Msg_Context;
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'EXCEPTION IN RAISE_EVENT_XMLINT...SELECTING DOCUMENT NUMBER' ) ;
          END IF;
       Return;
     End;

   End If;

   --Done Setting Document Number

   IF OE_Code_Control.Get_Code_Release_Level >= '110510' THEN
      --Setting Document Id for outbound transactions
      If l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_SSO
         Or l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_CSO Then
         l_document_id :=  p_itemkey;
         l_document_direction := 'OUT';
      Elsif l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_CBODO
         Or l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_POA Then
         l_document_id := wf_engine.GetItemAttrNumber (p_itemtype,
                                                       p_itemkey,
                                                      'PARAMETER5');
         l_document_direction := 'OUT';
      End If;
      If l_document_direction = 'OUT' Then
         l_party_id := to_number(wf_engine.GetItemAttrText (p_itemtype,
                                                 p_itemkey,
                                                 'ECX_PARTY_ID'));
         l_party_site_id := to_number(wf_engine.GetItemAttrText (p_itemtype,
                                                  p_itemkey,
                                                 'ECX_PARTY_SITE_ID'));
      End If;
   END IF;

    --Setting Message Text based on what stage of the inbound/outbound processing we are

   l_import_mode  := wf_engine.GetActivityAttrText (p_itemtype,
                                                     p_itemkey,
                                                     p_actid,
                                                     'IMPORT_MODE',
                                                     TRUE);
   -- by setting the last argument to TRUE, we ensure that no error is thrown if the attr is not found

   IF l_processing_stage = 'INBOUND_IFACE' THEN
     fnd_message.set_name('ONT', 'OE_OI_IFACE');

     fnd_message.set_token ('TRANSACTION', Oe_Acknowledgment_Pub.EM_Transaction_Type (p_txn_code => l_transaction_type)|| ' -');
     l_message_text := fnd_message.get;
     l_doc_status := 'ACTIVE';
   ELSIF l_processing_stage = 'PRE_IMPORT' THEN

     If l_import_mode = 'ASYNCHRONOUS' Then
        fnd_message.set_name('ONT', 'OE_OI_IMPORT_MODE_ASYNC');
     Elsif  l_import_mode = 'SYNCHRONOUS' Then
        fnd_message.set_name('ONT', 'OE_OI_IMPORT_MODE_SYNC');
     End If;

     fnd_message.set_token ('TRANSACTION', Oe_Acknowledgment_Pub.EM_Transaction_Type (p_txn_code => l_transaction_type)|| ' -');

     l_message_text := fnd_message.get;
     l_doc_status := 'ACTIVE';

   ELSIF l_processing_stage = 'IMPORT_SUCCESS' THEN
     If (l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_POI) Then
        l_message_text := fnd_message.get_string('ONT', 'OE_OI_IMPORT_SUCCESSFUL');

     Elsif (l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_CPO) Then
        l_message_text := fnd_message.get_string('ONT', 'OE_OI_IMPORT_SUCCESSFUL_CPO');

     Elsif (l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_CHO) Then
        l_message_text := fnd_message.get_string('ONT', 'OE_OI_IMPORT_SUCCESSFUL_CHO');
     End if;
     l_doc_status := 'SUCCESS';
   ELSIF  l_processing_stage = 'IMPORT_FAILURE' THEN
     fnd_message.set_name('ONT', 'OE_OI_IMPORT_FAILURE');
     fnd_message.set_token ('TRANSACTION', Oe_Acknowledgment_Pub.EM_Transaction_Type (p_txn_code => l_transaction_type)|| ' -');

     l_message_text := fnd_message.get;
     l_doc_status := 'ERROR';
   ELSIF l_processing_stage = 'OUTBOUND_SENT' THEN

     l_setup_status := wf_engine.GetActivityAttrText (p_itemtype,
                                                      p_itemkey,
                                                      p_actid,
                                                      'PROCESSING_STATUS',
                                                      TRUE);
     IF l_setup_status = 'ROSETTANET_SENT' Then
        Begin
         SELECT standard_desc
         INTO l_standard_desc
         FROM ecx_standards_vl
         WHERE standard_code = 'ROSETTANET';
        Exception
         When Others Then
          null;
        End;
        fnd_message.set_name('ONT', 'OE_OA_ACKNOWLEDGMENT_SENT');
        fnd_message.set_token ('TRANSACTION', l_standard_desc);
        l_message_text := fnd_message.get;
     Else
       IF (l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_POA) Then
          fnd_message.set_name('ONT', 'OE_OA_ACKNOWLEDGMENT_SENT');
          fnd_message.set_token ('TRANSACTION', Oe_Acknowledgment_Pub.EM_Transaction_Type (p_txn_code => l_transaction_type));

          l_message_text := fnd_message.get;
       Elsif (l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_SSO) Then  --SSO

          l_message_text := fnd_message.get_string('ONT', 'OE_SO_SHOW_SO_SENT');
       Elsif (l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_CSO) Then --CSO
          fnd_message.set_name('ONT', 'OE_OA_ACKNOWLEDGMENT_SENT');
          fnd_message.set_token ('TRANSACTION', Oe_Acknowledgment_Pub.EM_Transaction_Type (p_txn_code => l_transaction_type));

          l_message_text := fnd_message.get;
       Elsif (l_transaction_type = Oe_Acknowledgment_Pub.G_TRANSACTION_CBODO) Then --CBODO
          fnd_message.set_name ('ONT', 'OE_OA_ACKNOWLEDGMENT_SENT');
          fnd_message.set_token ('TRANSACTION', Oe_Acknowledgment_Pub.EM_Transaction_Type (p_txn_code => l_transaction_type));

          l_message_text := fnd_message.get;
       End If;
     End If;
     l_doc_status := 'SUCCESS';
   ELSIF  l_processing_stage = 'OUTBOUND_SETUP' THEN

     l_setup_status := wf_engine.GetActivityAttrText (p_itemtype,
                                                     p_itemkey,
                                                     p_actid,
                                                     'PROCESSING_STATUS',
                                                     TRUE);
     IF l_setup_status = 'SUCCESS' THEN
        fnd_message.set_name('ONT', 'OE_OI_OUTBOUND_SETUP');
        l_doc_status := 'ACTIVE';
     ELSIF l_setup_status = 'ERROR' THEN
        fnd_message.set_name('ONT', 'OE_OI_OUTBOUND_SETUP_ERR');
        l_doc_status := 'ERROR';
     END IF;
     fnd_message.set_token ('TRANSACTION', Oe_Acknowledgment_Pub.EM_Transaction_Type (p_txn_code => l_transaction_type)|| ' -');

     l_message_text := fnd_message.get;

   ELSIF l_processing_stage = 'OUTBOUND_TRIGGERED' THEN
     fnd_message.set_name('ONT', 'OE_OI_OUTBOUND_TRIGGERED');
     fnd_message.set_token ('TRANSACTION', Oe_Acknowledgment_Pub.EM_Transaction_Type (p_txn_code => l_transaction_type));

     l_message_text := fnd_message.get;

     l_doc_status := 'ACTIVE';
   END IF;

   --Done Setting Message Text


   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('L_ORIG_SYS_DOCUMENT_REF:' || l_orig_sys_document_ref) ;
      oe_debug_pub.add('L_DOCUMENT_NUM:' || l_document_num) ;
      oe_debug_pub.add('L_MESSAGE_TEXT:' || l_message_text) ;
      oe_debug_pub.add('L_TRANSACTION_TYPE:' || l_transaction_type);
      oe_debug_pub.add('L_ORG_ID:' || l_org_id);
      oe_debug_pub.add('L_CHANGE_SEQUENCE:' || l_change_sequence);
   END IF;


   -- Orig Sys Document Ref is passed in for Partner Document Number

   Oe_Acknowledgment_Pub.Raise_Event_Xmlint
      (p_order_source_id          => OE_Acknowledgment_Pub.G_XML_ORDER_SOURCE_ID,
       p_partner_document_num     => l_orig_sys_document_ref,
       p_message_text             => l_message_text,
       p_document_num             => l_document_num,
       p_order_type_id            => l_order_type_id,
       p_itemtype                 => p_itemtype,
       p_itemkey                  => p_itemkey,
       p_transaction_type         =>  OE_Acknowledgment_Pub.G_TRANSACTION_TYPE, --'ONT'
       p_transaction_subtype      => l_transaction_type,
       p_doc_status               => l_doc_status,
       p_org_id                   => l_org_id,
       p_sold_to_org_id           => l_sold_to_org_id,
       p_change_sequence          => l_change_sequence,
       p_document_direction       => l_document_direction,
       p_xmlg_document_id         => l_document_id,
       p_xmlg_partner_type        => 'C',
       p_xmlg_party_id            => l_party_id,
       p_xmlg_party_site_id       => l_party_site_id,
       p_xmlg_icn                 => l_internal_control_number,
       p_xmlg_msgid               => l_xml_message_id,
       p_document_disposition     => l_document_disposition,
       p_processing_stage         => l_processing_stage,
       p_conc_request_id          => l_conc_request_id,
       p_response_flag            => l_response_flag,
       p_header_id                => l_header_id,
       p_failure_ack_flag         => l_failure_ack_flag,
       x_return_status            => l_return_status);

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING RAISE_EVENT_XMLINT_WF' ) ;
   END IF;
   p_x_result := 'COMPLETE:COMPLETE';


   -- start data fix project
   OE_STANDARD_WF.Save_Messages;
   OE_STANDARD_WF.Clear_Msg_Context;
   -- end data fix project
END IF;
  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    p_x_result := 'COMPLETE';
    return;
  end if;
Exception
   When Others Then
     p_x_result := 'COMPLETE:ERROR';
     p_x_result := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'Raise_Event_Xmlint_Wf');
     END IF;
     WF_CORE.Context('OE_ORDER_IMPORT_WF', 'RAISE_EVENT_XMLINT_WF',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
     OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => p_actid,
                                          p_itemtype => p_itemtype,
                                          p_itemkey => p_itemkey);
     OE_STANDARD_WF.Save_Messages;
     OE_STANDARD_WF.Clear_Msg_Context;
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'WHEN OTHERS EXCEPTION IN RAISE_EVENT_XMLINT_WF'||SQLERRM ) ;
     END IF;
     RAISE;
End Raise_Event_Xmlint_Wf;


Procedure Is_OAG_or_RosettaNet
( p_itemtype   IN     Varchar2,
  p_itemkey    IN     Varchar2,
  p_actid      in     number,
  p_funcmode   IN     Varchar2,
  p_x_result   IN OUT NOCOPY  Varchar2
)
Is
  l_standard_code        Varchar2(30);
  l_party_id             Number;
  l_party_site_id        Number;
  l_error_code           Number;
  l_error_msg            Varchar2(1000);
  l_debug_level     CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_debug_level_cln CONSTANT NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

Begin

IF (l_debug_level > 0) THEN
         oe_debug_pub.Add('ENTERING OE_ORDER_IMPORT_WF.IS_OAG_OR_ROSETTANET');
         oe_debug_pub.Add('With the following parameters:');
         oe_debug_pub.Add('itemtype:'   || p_itemtype);
         oe_debug_pub.Add('itemkey:'    || p_itemkey);
         oe_debug_pub.Add('actid:'      || p_actid);
         oe_debug_pub.Add('funcmode:'   || p_funcmode);
END IF;
-- Start of CLN debugs
IF (l_debug_level_cln <= 1) THEN
         cln_debug_pub.Add('ENTERING OE_ORDER_IMPORT_WF.IS_OAG_OR_ROSETTANET',1);
         cln_debug_pub.Add('With the following parameters:', 1);
         cln_debug_pub.Add('itemtype:'   || p_itemtype, 1);
         cln_debug_pub.Add('itemkey:'    || p_itemkey, 1);
         cln_debug_pub.Add('actid:'      || p_actid, 1);
         cln_debug_pub.Add('funcmode:'   || p_funcmode, 1);
END IF;
-- End of CLN debugs



   l_party_id := to_number(wf_engine.GetItemAttrText (p_itemtype,
                                                 p_itemkey,
                                                 'ECX_PARTY_ID'));
   l_party_site_id := to_number(wf_engine.GetItemAttrText (p_itemtype,
                                                  p_itemkey,
                                                 'ECX_PARTY_SITE_ID'));

  SELECT standard_code
  INTO l_standard_code
  FROM ecx_tp_details_v
  WHERE tp_header_id = (SELECT tp_header_id FROM ecx_tp_headers
                        WHERE party_id = l_party_id
                        AND party_site_id = l_party_site_id
                        AND party_type = 'C')
  AND transaction_type ='ONT'
  AND transaction_subtype = 'POA';

  if (l_standard_code = 'ROSETTANET')
  then
  -- Reached Here. Successful execution.
    p_x_result:= 'ROSETTANET';
  else  -- default will be OAG
    p_x_result := 'OAG';
  end if;

  IF (l_debug_level > 0) THEN
           oe_debug_pub.Add('EXITING IS_OAG_OR_ROSETTANET Successfully');
  END IF;
  -- Start of CLN debugs
  IF (l_debug_level_cln <= 2) THEN
           cln_debug_pub.Add('EXITING IS_OAG_OR_ROSETTANET Successfully', 2);
  END IF;
  -- End of CLN debugs

Exception
  When Others Then
    l_error_code := SQLCODE;
    l_error_msg  := SQLERRM;
    p_x_result := 'COMPLETE:ERROR';
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'Is_OAG_or_RosettaNet');
    END IF;
    WF_CORE.Context('OE_ORDER_IMPORT_WF', 'IS_OAG_OR_ROSETTANET',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => p_actid,
                                          p_itemtype => p_itemtype,
                                          p_itemkey => p_itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ERROR CODE : ' || l_error_code || ', ERROR MESSAGE : '||SUBSTR ( l_error_msg , 1 , 200 ) , 1 ) ;
    END IF;
    -- Start of CLN debugs
    IF (l_debug_level_cln <= 1) THEN
      cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_error_msg, 1);
      cln_debug_pub.Add('Result out '|| p_x_result, 1);
      cln_debug_pub.Add('Exiting IS_OAG_OR_ROSETTANET with Error', 1);
    END IF;
    -- End of CLN debugs

    RAISE;
End Is_OAG_or_RosettaNet;

END OE_ORDER_IMPORT_WF;

/
