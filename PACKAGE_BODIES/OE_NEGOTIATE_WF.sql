--------------------------------------------------------
--  DDL for Package Body OE_NEGOTIATE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_NEGOTIATE_WF" as
/* $Header: OEXWNEGB.pls 120.2.12010000.4 2009/12/21 05:53:28 nitagarw ship $ */


PROCEDURE Update_Status_Lost(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_return_status VARCHAR2(30);
--

BEGIN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_Negotiate_WF.Update_Status_Lost:'||ITEMTYPE||'/'||ITEMKEY ,1 ) ;
    END IF;
    OE_STANDARD_WF.Set_Msg_Context(actid);
    IF (funcmode = 'RUN') then

        OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'HEADER'
          ,p_entity_id                  => to_number(itemkey)
          ,p_header_id                    => to_number(itemkey));

      OE_ORDER_WF_UTIL.Update_Quote_Blanket( p_item_type => OE_GLOBALS.G_WFI_NGO,
                                        p_item_key => itemkey,
                                        p_flow_status_code => 'LOST',
                                        p_open_flag => 'N',
                                        x_return_status => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      resultout := 'COMPLETE';

    END IF;
EXCEPTION
    when others then
       wf_core.context('OE_Negotiate_WF', 'Update_Status_Lost', itemtype, itemkey, to_char(actid), funcmode);
       -- start data fix project
       OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                             p_itemtype => itemtype,
                                             p_itemkey => itemkey);
       -- end data fix project
       oe_standard_wf.save_messages;
       oe_standard_wf.clear_msg_context;
       raise;

END Update_Status_Lost;


PROCEDURE Negotiation_Complete(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
IS
--
l_sales_document_type_code VARCHAR2(1);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_return_status VARCHAR2(30);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
--

BEGIN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_Negotiate_WF.Negotiation_Complete:'||ITEMTYPE||'/'||ITEMKEY ,1 ) ;
    END IF;
    OE_STANDARD_WF.Set_Msg_Context(actid);
    IF (funcmode = 'RUN') then

       OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'HEADER'
          ,p_entity_id                  => to_number(itemkey)
          ,p_header_id                    => to_number(itemkey));

      l_sales_document_type_code := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'SALES_DOCUMENT_TYPE_CODE');
      IF l_sales_document_type_code = 'O' THEN
           -- Quote Complete_Negotiation
           OE_QUOTE_UTIL.Complete_Negotiation(p_header_id => to_number(itemkey), x_return_status => l_return_status,
                                              x_msg_count => l_msg_Count, x_msg_data => l_msg_data);

      ELSIF l_sales_document_type_code = 'B' THEN
         -- Blanket Complete_Negotiation
           OE_BLANKET_WF_UTIL.Complete_Negotiation(p_header_id => to_number(itemkey),
                                                   x_return_status => l_return_status);
      ELSE
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF l_return_status =  FND_API.G_RET_STS_SUCCESS THEN
         resultout := 'COMPLETE:COMPLETE';
      ELSE
	 resultout := 'COMPLETE:INCOMPLETE';
	 oe_standard_wf.save_messages;
         oe_standard_wf.clear_msg_context;
      END IF;
    END IF;
EXCEPTION
    when others then
       wf_core.context('OE_Negotiate_WF', 'Negotiation_Complete', itemtype, itemkey, to_char(actid), funcmode);
       -- start data fix project
       OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                             p_itemtype => itemtype,
                                             p_itemkey => itemkey);
       -- end data fix project
       oe_standard_wf.save_messages;
       oe_standard_wf.clear_msg_context;
       raise;

END Negotiation_Complete;


PROCEDURE Submit_Draft_Internal(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
IS
--
l_sales_document_type_code VARCHAR2(1);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_return_status VARCHAR2(30);
l_validate_cfg BOOLEAN;
Cursor Query_Lines IS
   SELECT item_type_code, ordered_quantity
   FROM oe_order_lines_all
   WHERE header_id = to_number(itemkey);

l_item_type_code VARCHAR2(30);
l_qa_return_status VARCHAR2(30);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_ordered_quantity NUMBER;
l_sales_document_type VARCHAR2(30);
--

BEGIN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_Negotiate_WF.Submit_Draft_Internal:'||ITEMTYPE||'/'||ITEMKEY ,1 ) ;
    END IF;
    OE_STANDARD_WF.Set_Msg_Context(actid);

    IF (funcmode = 'RUN') then

       OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'HEADER'
          ,p_entity_id                  => to_number(itemkey)
          ,p_header_id                    => to_number(itemkey));

      l_sales_document_type_code := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'SALES_DOCUMENT_TYPE_CODE');
       --OE_BLANKET_WF_UTIL.Blanket_QA_Articles(p_header_id => to_number(itemkey),
       --                                       x_return_status => l_return_status);

      OE_CONTRACTS_UTIL.qa_articles ( p_api_version => 1.0,
                                   p_doc_type    => l_sales_document_type_code,
                                   p_doc_id      => to_number(itemkey),
                                   x_qa_return_status  => l_qa_return_status,
                                   x_return_status     => l_return_status,
                                   x_msg_count         => l_msg_count,
                                   x_msg_data          => l_msg_data);

      IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'Contract returns: x_return_status:' || l_return_status || ' x_qa_return_status:' || l_qa_return_status, 1);
      END IF;
-- If API call is successful, but the check failed, return incomplete

      IF l_return_status = FND_API.G_RET_STS_SUCCESS
	AND  l_qa_return_status <> FND_API.G_RET_STS_SUCCESS
	AND  l_qa_return_status <> 'W' THEN
        resultout := 'COMPLETE:INCOMPLETE';
        OE_STANDARD_WF.Save_Messages;
        OE_STANDARD_WF.Clear_Msg_Context;
        return;
      ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
-- API call failed completely, fail the activity
        app_exception.raise_exception;
      END IF;


      -- Quotes need to check configs
      IF l_sales_document_type_code = 'O' THEN
        l_validate_cfg := FALSE;
        Open Query_Lines;
        Loop
           FETCH Query_Lines INTO l_item_type_code, l_ordered_quantity;
           EXIT WHEN Query_Lines%NOTFOUND;
           IF l_item_type_code = 'MODEL' THEN
              l_validate_cfg := TRUE;
           END IF;

	   IF nvl(l_ordered_quantity, 0) = 0 THEN
               IF l_sales_document_type_code = 'O' THEN
                  fnd_message.set_name('ONT', 'OE_NTF_QUOTE');
               ELSE -- assume blanket
                  fnd_message.set_name('ONT', 'OE_NTF_BSA');
               END IF;
               l_sales_document_type := fnd_message.get;

	       FND_MESSAGE.SET_NAME('ONT', 'OE_ZERO_QUANTITY');
               FND_MESSAGE.SET_TOKEN('SALES_DOCUMENT_TYPE', l_sales_document_type);
               oe_msg_pub.add;
               resultout := 'COMPLETE:INCOMPLETE';
               OE_STANDARD_WF.Save_Messages;
               OE_STANDARD_WF.Clear_Msg_Context;
               return;
           END IF;
        End Loop;
        Close Query_Lines;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Submit_Draft_Internal: Finish looking for Configs', 1);
        END IF;

        IF l_validate_cfg THEN
          l_return_status := OE_Config_Util.Validate_Cfgs_In_Order(p_header_id    => to_number(itemkey));
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN STATUS AFTER VALIDATE CFGS:'||L_RETURN_STATUS );
          END IF;

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           resultout := 'COMPLETE:INCOMPLETE';
           OE_STANDARD_WF.Save_Messages;
           OE_STANDARD_WF.Clear_Msg_Context;
           return;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           app_exception.raise_exception;
          END IF;

        END IF;

      END IF; -- blanket or quote

      OE_ORDER_WF_UTIL.Update_Quote_Blanket(p_item_type => OE_GLOBALS.G_WFI_NGO,
                                        p_item_key => itemkey,
                                        p_flow_status_code => 'DRAFT_SUBMITTED',
                                        p_draft_submitted_flag => 'Y',
                                        x_return_status => l_return_status);
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Submit_Draft_Internal: Finish calling Update Draft Submitted status: ' || l_return_status, 1);
      END IF;

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        resultout := 'COMPLETE:INCOMPLETE';
        OE_STANDARD_WF.Save_Messages;
        OE_STANDARD_WF.Clear_Msg_Context;
        return;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        app_exception.raise_exception;
      END IF;

      resultout := 'COMPLETE:COMPLETE';

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Exiting OE_NEGOTIATE_WF.Submit_Draft_Internal Normally', 1);
      END IF;


    END IF;
EXCEPTION
    when others then
       wf_core.context('OE_Negotiate_WF', 'Submit_Draft_Internal', itemtype, itemkey, to_char(actid), funcmode);
       -- start data fix project
       OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                             p_itemtype => itemtype,
                                             p_itemkey => itemkey);
       -- end data fix project
       oe_standard_wf.save_messages;
       oe_standard_wf.clear_msg_context;
       raise;

END Submit_Draft_Internal;


PROCEDURE Customer_Acceptance(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_return_status VARCHAR2(30);
--

BEGIN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_Negotiate_WF.Customer_Acceptance:'||ITEMTYPE||'/'||ITEMKEY ,1 ) ;
    END IF;
    OE_STANDARD_WF.Set_Msg_Context(actid);
    IF (funcmode = 'RUN') then
       OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'HEADER'
          ,p_entity_id                  => to_number(itemkey)
          ,p_header_id                    => to_number(itemkey));

      OE_ORDER_WF_UTIL.Update_Quote_Blanket(p_item_type => OE_GLOBALS.G_WFI_NGO,
                                        p_item_key => itemkey,
                                        p_flow_status_code => 'PENDING_CUSTOMER_ACCEPTANCE',
                                        x_return_status => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      resultout := 'NOTIFIED:#NULL';

    END IF;
EXCEPTION
    when others then
       wf_core.context('OE_Negotiate_WF', 'Customer_Acceptance', itemtype, itemkey, to_char(actid), funcmode);
       -- start data fix project
       OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                             p_itemtype => itemtype,
                                             p_itemkey => itemkey);
       -- end data fix project
       oe_standard_wf.save_messages;
       oe_standard_wf.clear_msg_context;
       raise;

END Customer_Acceptance;


PROCEDURE Update_Customer_Accepted(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_return_status VARCHAR2(30);
--

BEGIN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_Negotiate_WF.Update_Customer_Accepted:'||ITEMTYPE||'/'||ITEMKEY ,1 ) ;
    END IF;
    OE_STANDARD_WF.Set_Msg_Context(actid);
    IF (funcmode = 'RUN') then
       OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'HEADER'
          ,p_entity_id                  => to_number(itemkey)
          ,p_header_id                    => to_number(itemkey));

      OE_ORDER_WF_UTIL.Update_Quote_Blanket(p_item_type => OE_GLOBALS.G_WFI_NGO,
                                        p_item_key => itemkey,
                                        p_flow_status_code => 'CUSTOMER_ACCEPTED',
                                        x_return_status => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;


      resultout := 'COMPLETE';

    END IF;
EXCEPTION
    when others then
       wf_core.context('OE_Negotiate_WF', 'Update_Customer_Accepted', itemtype, itemkey, to_char(actid), funcmode);
       -- start data fix project
       OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                             p_itemtype => itemtype,
                                             p_itemkey => itemkey);
       -- end data fix project
       oe_standard_wf.save_messages;
       oe_standard_wf.clear_msg_context;
       raise;

END Update_Customer_Accepted;


PROCEDURE Update_Customer_Rejected(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_return_status VARCHAR2(30);
--

BEGIN

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_Negotiate_WF.Update_Customer_Rejected:'||ITEMTYPE||'/'||ITEMKEY ,1 ) ;
    END IF;
    OE_STANDARD_WF.Set_Msg_Context(actid);
    IF (funcmode = 'RUN') then
       OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'HEADER'
          ,p_entity_id                  => to_number(itemkey)
          ,p_header_id                    => to_number(itemkey));

      OE_ORDER_WF_UTIL.Update_Quote_Blanket(p_item_type => OE_GLOBALS.G_WFI_NGO,
                                        p_item_key => itemkey,
                                        p_flow_status_code => 'DRAFT_CUSTOMER_REJECTED',
                                        p_draft_submitted_flag => 'N',
                                        x_return_status => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      resultout := 'COMPLETE';

    END IF;
EXCEPTION
    when others then
       wf_core.context('OE_Negotiate_WF', 'Update_Customer_Rejected', itemtype, itemkey, to_char(actid), funcmode);
       -- start data fix project
       OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                             p_itemtype => itemtype,
                                             p_itemkey => itemkey);
       -- end data fix project
       oe_standard_wf.save_messages;
       oe_standard_wf.clear_msg_context;
       raise;

END Update_Customer_Rejected;

PROCEDURE Check_Expiration_Date(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_expiration_date DATE;
l_pre_notification_percent NUMBER;
l_aname         wf_engine.nametabtyp;
l_avalue        wf_engine.numtabtyp;
l_final_timer   NUMBER;
l_sales_document_type_code VARCHAR2(1);
--

BEGIN

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_Negotiate_WF.Check_Expiration_Date:'||ITEMTYPE||'/'||ITEMKEY ,1 ) ;
    END IF;
    OE_STANDARD_WF.Set_Msg_Context(actid);
    IF (funcmode = 'RUN') then
       OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'HEADER'
          ,p_entity_id                  => to_number(itemkey)
          ,p_header_id                    => to_number(itemkey));

     l_sales_document_type_code := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'SALES_DOCUMENT_TYPE_CODE');
     IF l_sales_document_type_code = 'O' THEN
      select expiration_date
      into   l_expiration_date
      from   oe_order_headers_all
      where  header_id = to_number(itemkey);
     ELSE
	-- even though there is no offer expiration date for blanket for now
	-- we will still fetch it for the future
      select expiration_date
      into   l_expiration_date
      from   oe_blanket_headers_all
      where  header_id = to_number(itemkey);
     END IF;


      IF l_expiration_date is null THEN
      -- no expiration date, set both timer to null
              l_aname(1) := 'OFFER_PRE_EXPIRE_TIMER';
              l_avalue(1) := null;
              l_aname(2) := 'OFFER_FINAL_EXPIRE_TIMER';
              l_avalue(2) := null;

               wf_engine.SetItemAttrNumberArray(itemtype=>itemtype
                              , itemkey=>itemkey
                              , aname=>l_aname
                              , avalue=>l_avalue
                              );
               resultout := 'COMPLETE:COMPLETE';
               IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Leaving OE_Negotiate_WF.Check_Expiration_Date: NO TIMER TO SET', 1);
               END IF;
               return;
      END IF;

      -- expiration date does exist but expired
      IF l_expiration_date < sysdate THEN
            resultout := 'COMPLETE:EXPIRED';
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Leaving OE_Negotiate_WF.Check_Expiration_Date: EXPIRED', 1);
            END IF;
            return;
      END IF;

      --if you are here, that means expiration date exists and is in the future

      l_pre_notification_percent := wf_engine.GetItemAttrNumber(itemtype, itemkey, 'PRE_EXPIRE_TIME_PERCENT');

      IF l_pre_notification_percent = 0 THEN
         -- set the FINAL timer only is enough
         -- this assumes expiration_date is already set to 23:59:59
         l_final_timer := (l_expiration_date - sysdate) * 1440;
         wf_engine.setitemattrnumber(itemtype=>itemtype,
				     itemkey=>itemkey,
				     aname=>'OFFER_FINAL_EXPIRE_TIMER',
				     avalue=>l_final_timer);
         resultout := 'COMPLETE:NO_REMINDER';
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add('Leaving OE_Negotiate_WF.Check_Expiration_Date: NO REMINDER', 1);
         END IF;
      ELSIF to_char(sysdate, 'DD-MON-RRRR') = to_char(l_expiration_date, 'DD-MON-RRRR') THEN
         -- pre notification percentage is non-zero
         -- expiration_date is today midnight, we should send the reminder

              wf_engine.SetItemAttrNumber(itemtype=>itemtype
                              , itemkey=>itemkey
                              , aname=>'OFFER_FINAL_EXPIRE_TIMER'
                              , avalue=>(l_expiration_date - sysdate) * 1440
                              );
              resultout := 'COMPLETE:EXPIRE_TODAY';
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('OE_Negotiate_WF.Check_Expiration_Date: EXPIRE TODAY', 1);
              END IF;
      ELSE --expiration is not today, i.e. it is in the future
           --again expiration_date should already be in 23:59:59
              l_aname(1) := 'OFFER_FINAL_EXPIRE_TIMER';
              l_avalue(1) := Ceil((l_expiration_date - sysdate) * l_pre_notification_percent/100) * 1440;
              l_aname(2) := 'OFFER_PRE_EXPIRE_TIMER';
              l_avalue(2) := ((l_expiration_date - sysdate) * 1440) - l_avalue(1);

              wf_engine.SetItemAttrNumberArray(itemtype=>itemtype
                              , itemkey=>itemkey
                              , aname=>l_aname
                              , avalue=>l_avalue
                              );
              resultout := 'COMPLETE:COMPLETE';
      END IF; -- end if of expiration date is today or future

      IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Leaving OE_Negotiate_WF.Check_Expiration_Date: TIMER(S) SET', 1);
      END IF;
    END IF;  --funcmode = run

EXCEPTION
    when others then
       wf_core.context('OE_Negotiate_WF', 'Check_Expiration_Date', itemtype, itemkey, to_char(actid), funcmode);
       -- start data fix project
       OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                             p_itemtype => itemtype,
                                             p_itemkey => itemkey);
       -- end data fix project
       oe_standard_wf.save_messages;
       oe_standard_wf.clear_msg_context;
       raise;

END Check_Expiration_Date;

PROCEDURE Offer_Expired(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_return_status VARCHAR2(30);
l_sales_document_type_code VARCHAR2(1);
l_sold_to_org_id NUMBER;
l_salesrep_id    NUMBER;
l_salesrep       VARCHAR2(240);
l_sold_to        VARCHAR2(240);
l_customer_number  VARCHAR2(30);
l_expiration_date  DATE;
l_aname      wf_engine.nametabtyp;
l_avaluetext wf_engine.texttabtyp;

--

BEGIN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_Negotiate_WF.Offer_Expired:'||ITEMTYPE||'/'||ITEMKEY ,1 ) ;
    END IF;
    OE_STANDARD_WF.Set_Msg_Context(actid);
    IF (funcmode = 'RUN') then
       OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'HEADER'
          ,p_entity_id                  => to_number(itemkey)
          ,p_header_id                    => to_number(itemkey));

      OE_ORDER_WF_UTIL.Update_Quote_Blanket(p_item_type => OE_GLOBALS.G_WFI_NGO,
                                        p_item_key => itemkey,
                                        p_flow_status_code => 'OFFER_EXPIRED',
                                        p_open_flag => 'N',
                                        x_return_status => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_sales_document_type_code := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'SALES_DOCUMENT_TYPE_CODE');
     IF l_sales_document_type_code = 'O' THEN
-- ***DATE_CALCULATION***
      select sold_to_org_id, expiration_date, salesrep_id
      into   l_sold_to_org_id, l_expiration_date, l_salesrep_id
      from   oe_order_headers_all
      where  header_id = to_number(itemkey);
     ELSE
      select sold_to_org_id, expiration_date, salesrep_id
      into   l_sold_to_org_id, l_expiration_date, l_salesrep_id
      from   oe_blanket_headers_all
      where  header_id = to_number(itemkey);
     END IF;

       l_salesrep := OE_Id_To_Value.Salesrep(p_salesrep_id=>l_salesrep_id);
       OE_Id_To_Value.Sold_To_Org(p_sold_to_org_id=>l_sold_to_org_id, x_org=> l_sold_to, x_customer_number=>l_customer_number);


       l_aname(1) := 'SALESPERSON';
       l_avaluetext(1) := l_salesrep;
       l_aname(2) := 'SOLD_TO';
       l_avaluetext(2) := l_sold_to;
       l_aname(3) := 'EXPIRATION_DATE';
       l_avaluetext(3) := l_expiration_date;

       wf_engine.SetItemAttrTextArray(itemtype=>itemtype,
				      itemkey=>itemkey,
				      aname=>l_aname,
				      avalue=>l_avaluetext);

       resultout := 'COMPLETE';

    END IF;
EXCEPTION
    when others then
       wf_core.context('OE_Negotiate_WF', 'Offer_Expired', itemtype, itemkey, to_char(actid), funcmode);
       -- start data fix project
       OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                             p_itemtype => itemtype,
                                             p_itemkey => itemkey);
       -- end data fix project
       oe_standard_wf.save_messages;
       oe_standard_wf.clear_msg_context;
       raise;

END Offer_Expired;



PROCEDURE Set_Negotiate_Hdr_Descriptor(
                 document_id  IN VARCHAR2,
                 display_type IN VARCHAR2,
                 document      IN OUT NOCOPY VARCHAR2,
                 document_type IN OUT NOCOPY VARCHAR2)
IS
--
l_sales_document_type_code  VARCHAR2(1);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_header_id NUMBER;
l_order_type_id NUMBER;
l_transaction_type_name VARCHAR2(300);
l_transaction_type_id NUMBER;
l_blanket_number NUMBER;
l_header_txt   VARCHAR2(2000);
l_transaction_type_txt VARCHAR2(300);
l_quote_number NUMBER;
--
BEGIN

   document_type := display_type;
  BEGIN
   -- if viewing method is through URL
   -- fix bug 1332384
   SELECT item_key
   INTO l_header_id
   FROM wf_item_activity_statuses
   where notification_id = to_number(document_id);
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     /* 9047023: Check details in wf history tables */
     BEGIN
       SELECT item_key
       INTO l_header_id
       FROM wf_item_activity_statuses_h
       where notification_id = to_number(document_id);
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         -- if viewing method is email
         l_header_id := to_number(wf_engine.setctx_itemkey);
     END;
     /* 9047023: End */
  END;

  l_sales_document_type_code := WF_ENGINE.GetItemAttrText(OE_GLOBALS.G_WFI_NGO, l_header_id, 'SALES_DOCUMENT_TYPE_CODE');
      IF l_sales_document_type_code = 'B' THEN
           SELECT order_number
           INTO   l_blanket_number
           FROM   oe_blanket_headers_all
           WHERE  header_id = l_header_id;

           fnd_message.set_name('ONT', 'OE_WF_BLANKET_ORDER');
           fnd_message.set_token('BLANKET_NUMBER', to_char(l_blanket_number));
           l_header_txt := fnd_message.get;
           document := substrb(l_header_txt, 1, 240);
      ELSIF l_sales_document_type_code = 'O' THEN
           SELECT oh.order_number, oh.order_type_id, t.name
           INTO l_quote_number, l_transaction_type_id, l_transaction_type_name
           FROM oe_order_headers_all oh, oe_transaction_types_tl t
           WHERE header_id = l_header_id
           AND t.language = userenv('LANG')
           AND t.transaction_type_id = oh.order_type_id;

           fnd_message.set_name('ONT', 'OE_WF_TRANSACTION_TYPE');
           fnd_message.set_token('TRANSACTION_TYPE', l_transaction_type_name);
           l_transaction_type_txt := fnd_message.get;

           fnd_message.set_name('ONT', 'OE_WF_QUOTE_ORDER');
           fnd_message.set_token('QUOTE_NUMBER', to_char(l_quote_number));
           l_header_txt := fnd_message.get;

           document := substrb(l_transaction_type_txt || ', ' || l_header_txt, 1, 240);

      ELSE
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR; -- unrecognized code
      END IF;

EXCEPTION
     WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME
        , 'Set_Negotiate_Hdr_Descriptor'
        );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

END Set_Negotiate_Hdr_Descriptor;



PROCEDURE Lost(p_header_id IN NUMBER,
               p_entity_code IN VARCHAR2,
               p_version_number IN NUMBER,
               p_reason_type IN VARCHAR2,
               p_reason_code IN VARCHAR2,
               p_reason_comments IN VARCHAR2,
               x_return_status OUT NOCOPY VARCHAR2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_activity_name VARCHAR2(30);
l_sales_document_type VARCHAR2(30);
l_reason_id NUMBER;
l_return_status VARCHAR2(240);

--
BEGIN
    OE_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('ENTERING OE_Negotiate_WF.Lost: '|| TO_CHAR (p_header_id) ,1) ;
    END IF;
       OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'HEADER'
          ,p_entity_id                  => p_header_id
          ,p_header_id                    => p_header_id);

    BEGIN
      select wpa.activity_name
      into l_activity_name
      from wf_item_activity_statuses wias, wf_process_activities wpa
      where item_type = OE_GLOBALS.G_WFI_NGO
      and item_key = to_char(p_header_id)
      and activity_status = wf_engine.eng_notified
      and wpa.activity_name in ('SUBMIT_DRAFT_ELIGIBLE', 'NEGOTIATION_COMPLETE_ELIGIBLE')
      and wias.process_activity = wpa.instance_id;

    EXCEPTION
      WHEN OTHERS THEN

          IF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER THEN
               fnd_message.set_name('ONT', 'OE_NTF_QUOTE');
          ELSE -- assume blanket
               fnd_message.set_name('ONT', 'OE_NTF_BSA');
          END IF;
          l_sales_document_type := fnd_message.get;

          fnd_message.set_name('ONT', 'OE_WF_NO_LOST'); --flow not at notified state
          fnd_message.set_token('SALES_DOCUMENT_TYPE', l_sales_document_type);
          oe_msg_pub.add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add('EXITING OE_Negotiate_WF.Lost WITH STATUS: '||X_RETURN_STATUS ,1);
          END IF;
          return;
    END;
    -- ok to go Lost
    -- call reason API to capture the reason

    OE_REASONS_UTIL.Apply_Reason(p_entity_code => p_entity_code,
                                p_entity_id => p_header_id,
                                p_version_number => p_version_number,
                                p_reason_type => p_reason_type,
                                p_reason_code => p_reason_code,
                                p_reason_comments => p_reason_comments,
                                x_reason_id => l_reason_id,
                                x_return_status => l_return_status);

    WF_ENGINE.CompleteActivityInternalName(OE_GLOBALS.G_WFI_NGO, to_char(p_header_id), l_activity_name, 'LOST');

    IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Negotiate_WF.Lost normally', 1);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Negotiate_WF.Lost WITH STATUS: '||X_RETURN_STATUS ,1);
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
                 OE_MSG_PUB.Add_Exc_Msg
                       (   G_PKG_NAME,
                          'Lost'
                       );
        END IF;


END Lost;


PROCEDURE Customer_Accepted(p_header_id IN NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_activity_name VARCHAR2(30);
l_sales_document_type_code VARCHAR2(1);
l_sales_document_type VARCHAR2(30);
l_response VARCHAR2(30);
l_entity_code VARCHAR2(30);
l_wf_item_count NUMBER;
l_so_count NUMBER;
l_bsa_count NUMBER;
--
 l_customer_acceptance VARCHAR2(30) := 'CUSTOMER_ACCEPTANCE';
BEGIN
    OE_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('ENTERING OE_Negotiate_WF.Customer_Accepted: '|| TO_CHAR (p_header_id) ,1) ;
    END IF;

       OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'HEADER'
          ,p_entity_id                  => p_header_id
          ,p_header_id                    => p_header_id);


    BEGIN
      -- Bug3435165
      select count(1)
      into l_wf_item_count
      from wf_items
      where item_type = 'OENH'
      and item_key = p_header_id;

      IF l_wf_item_count = 0 THEN  --we are in fulfillment phase and it has no nego phase
       select count(1)
       into l_so_count
       from oe_order_headers_all
       where header_id = p_header_id;

       IF l_so_count > 0 THEN
          l_sales_document_type_code := 'O';
          raise FND_API.G_EXC_ERROR;
       ELSE
          select count(1)
          into l_bsa_count
          from oe_blanket_headers_all
          where header_id = p_header_id;

          IF l_bsa_count > 0 THEN
             l_sales_document_type_code := 'B';
             raise FND_API.G_EXC_ERROR;
          END IF;
       END IF;
      END IF;
      -- END Bug3435165

    l_sales_document_type_code := WF_ENGINE.GetItemAttrText(OE_GLOBALS.G_WFI_NGO, p_header_id, 'SALES_DOCUMENT_TYPE_CODE');
      select wpa.activity_name
      into l_activity_name
      from wf_item_activity_statuses wias, wf_process_activities wpa
      where item_type = OE_GLOBALS.G_WFI_NGO
      and item_key = to_char(p_header_id)
      and activity_status = wf_engine.eng_notified
      and wpa.activity_name = l_customer_acceptance
      and wias.process_activity = wpa.instance_id;

    EXCEPTION
      WHEN OTHERS THEN
          IF l_sales_document_type_code = 'O' THEN
               fnd_message.set_name('ONT', 'OE_NTF_QUOTE');
          ELSE -- assume blanket
               fnd_message.set_name('ONT', 'OE_NTF_BSA');
          END IF;
          l_sales_document_type := fnd_message.get;

          fnd_message.set_name('ONT', 'OE_WF_NO_CUST_ACCEPTED'); --flow not at right state
          fnd_message.set_token('SALES_DOCUMENT_TYPE', l_sales_document_type);
          oe_msg_pub.add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add('EXITING OE_Negotiate_WF.Customer_Accepted WITH STATUS: '||X_RETURN_STATUS ,1);
          END IF;
          return;
    END;
    -- ok to go Accept
    IF l_sales_document_type_code = 'O' THEN
       l_entity_code := 'HEADER';
    ELSE
       l_entity_code := 'BLANKET_HEADER';
    END IF;

    OE_MSG_PUB.set_msg_context(
         p_entity_code                  => l_entity_code
        ,p_entity_id                    => p_header_id
        ,p_header_id                    => p_header_id
        ,p_line_id                      => null
        ,p_orig_sys_document_ref        => null
        ,p_orig_sys_document_line_ref   => null
        ,p_change_sequence              => null
        ,p_source_document_id           => null
        ,p_source_document_line_id      => null
        ,p_order_source_id            => null
        ,p_source_document_type_id    => null);


    WF_ENGINE.CompleteActivityInternalName(itemtype => OE_GLOBALS.G_WFI_NGO,
                                           itemkey => to_char(p_header_id),
                                           activity => l_activity_name,
                                           result => 'ACCEPT');
    IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Negotiate_WF.Customer_Accepted normally', 1);
    END IF;
EXCEPTION

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Negotiate_WF.Customer_Accepted WITH STATUS: '||X_RETURN_STATUS ,1);
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
                 OE_MSG_PUB.Add_Exc_Msg
                       (   G_PKG_NAME,
                          'Customer_Accepted'
                       );
        END IF;



END Customer_Accepted;

PROCEDURE Customer_Rejected(p_header_id IN NUMBER,
                            p_entity_code IN VARCHAR2,
                            p_version_number IN NUMBER,
                            p_reason_type IN VARCHAR2,
                            p_reason_code IN VARCHAR2,
                            p_reason_comments IN VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_activity_name VARCHAR2(30);
l_sales_document_type VARCHAR2(30);
l_response VARCHAR2(30);
l_reason_id NUMBER;
l_return_status VARCHAR2(240);

--
l_customer_acceptance VARCHAR2(30) := 'CUSTOMER_ACCEPTANCE';
--
BEGIN
 OE_MSG_PUB.initialize;
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 IF l_debug_level  > 0 THEN
       oe_debug_pub.add('ENTERING OE_Negotiate_WF.Customer_Rejected: '|| TO_CHAR (p_header_id) ,1) ;
    END IF;
       OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'HEADER'
          ,p_entity_id                  => p_header_id
          ,p_header_id                    => p_header_id);

    BEGIN
      select wpa.activity_name
      into l_activity_name
      from wf_item_activity_statuses wias, wf_process_activities wpa
      where item_type = OE_GLOBALS.G_WFI_NGO
      and item_key = to_char(p_header_id)
      and activity_status = wf_engine.eng_notified
      and wpa.activity_name = l_customer_acceptance
      and wias.process_activity = wpa.instance_id;

    EXCEPTION
      WHEN OTHERS THEN

          IF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER THEN
               fnd_message.set_name('ONT', 'OE_NTF_QUOTE');
          ELSE -- assume blanket
               fnd_message.set_name('ONT', 'OE_NTF_BSA');
          END IF;
          l_sales_document_type := fnd_message.get;

          fnd_message.set_name('ONT', 'OE_WF_NO_CUST_REJECTED'); --flow not at right state
          fnd_message.set_token('SALES_DOCUMENT_TYPE', l_sales_document_type);
          oe_msg_pub.add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add('EXITING OE_Negotiate_WF.Customer_Rejected WITH STATUS: '||X_RETURN_STATUS ,1);
          END IF;
          return;
    END;
    -- ok to go Reject

    OE_REASONS_UTIL.Apply_Reason(p_entity_code => p_entity_code,
                                p_entity_id => p_header_id,
                                p_version_number => p_version_number,
                                p_reason_type => p_reason_type,
                                p_reason_code => p_reason_code,
                                p_reason_comments => p_reason_comments,
                                x_reason_id => l_reason_id,
                                x_return_status => l_return_status);


    WF_ENGINE.CompleteActivityInternalName(OE_GLOBALS.G_WFI_NGO, to_char(p_header_id), l_activity_name, 'REJECT');
    IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Negotiate_WF.Customer_Rejected normally', 1);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Negotiate_WF.Customer_Rejected WITH STATUS: '||X_RETURN_STATUS ,1);
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
                 OE_MSG_PUB.Add_Exc_Msg
                       (   G_PKG_NAME,
                          'Customer_Rejected'
                       );
        END IF;

END Customer_Rejected;



PROCEDURE Offer_Date_Changed(p_header_id NUMBER,
                             x_return_status OUT NOCOPY VARCHAR2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_activity_name VARCHAR2(30);
l_sales_document_type_code VARCHAR2(1);
l_sales_document_type VARCHAR2(30);
--
BEGIN
 OE_MSG_PUB.initialize;
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 IF l_debug_level  > 0 THEN
       oe_debug_pub.add('ENTERING OE_Negotiate_WF.Offer_Date_Changed: '|| TO_CHAR (p_header_id) ,1) ;
    END IF;
       OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'HEADER'
          ,p_entity_id                  => p_header_id
          ,p_header_id                    => p_header_id);

    BEGIN
      select wpa.activity_name
      into l_activity_name
      from wf_item_activity_statuses wias, wf_process_activities wpa
      where item_type = OE_GLOBALS.G_WFI_NGO
      and item_key = to_char(p_header_id)
      and activity_status = wf_engine.eng_notified
      and wpa.activity_name in ('WAIT_FOR_EXPIRATION', 'WAIT_FOR_FINAL_EXPIRATION')
      and wias.process_activity = wpa.instance_id;

    EXCEPTION
      WHEN OTHERS THEN
          l_sales_document_type_code := WF_ENGINE.GetItemAttrText(OE_GLOBALS.G_WFI_NGO, p_header_id, 'SALES_DOCUMENT_TYPE_CODE');
          IF l_sales_document_type_code = 'O' THEN
               fnd_message.set_name('ONT', 'OE_NTF_QUOTE');
          ELSE -- assume blanket
               fnd_message.set_name('ONT', 'OE_NTF_BSA');
          END IF;
          l_sales_document_type := fnd_message.get;
          fnd_message.set_name('ONT', 'OE_WF_NO_OFFER_DATE_CHANGE'); --flow not at right state
          fnd_message.set_token('SALES_DOCUMENT_TYPE', l_sales_document_type);
          oe_msg_pub.add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add('EXITING OE_Negotiate_WF.Offer_Date_Changed WITH STATUS: '||X_RETURN_STATUS ,1);
          END IF;
          return;
    END;
    -- ok to go date changed
    IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Calling WF_ENGINE to completeactivity' ,3);
    END IF;
    WF_ENGINE.CompleteActivityInternalName(OE_GLOBALS.G_WFI_NGO, to_char(p_header_id), l_activity_name, 'DATE_CHANGED');
    IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Negotiate_WF.Offer_Date_Changed normally', 1);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Negotiate_WF.Offer_Date_Changed WITH STATUS: '||X_RETURN_STATUS ,1);
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
                 OE_MSG_PUB.Add_Exc_Msg
                       (   G_PKG_NAME,
                          'Offer_Date_Changed'
                       );
        END IF;

END Offer_Date_Changed;


PROCEDURE Submit_Draft(p_header_id NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_activity_name VARCHAR2(30);
l_sales_document_type_code VARCHAR2(1);
l_sales_document_type VARCHAR2(30);
l_entity_code VARCHAR2(30);
l_wf_item_count NUMBER;
l_so_count NUMBER;
l_bsa_count NUMBER;
--
l_submit_draft_eligible VARCHAR2(30) := 'SUBMIT_DRAFT_ELIGIBLE';

--
BEGIN
    -- OE_MSG_PUB.initialize; commented out for 4671489
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('ENTERING OE_Negotiate_WF.Submit_Draft: '|| TO_CHAR (p_header_id) ,1) ;
    END IF;

    BEGIN
      --Bug3435165
      select count(1)
      into l_wf_item_count
      from wf_items
      where item_type = 'OENH'
      and item_key = to_char(p_header_id);         -- Bug 9209740, p_header_id conversion to char.

      IF l_wf_item_count = 0 THEN  --we are in fulfillment phase and it has no nego phase
       -- should be a sales order, as BSA UI won't call this API in fulfillment phase, but
       -- double check to confirm
       select count(1)
       into l_so_count
       from oe_order_headers_all
       where header_id = p_header_id;

       IF l_so_count > 0 THEN
          l_sales_document_type_code := 'O';
          raise FND_API.G_EXC_ERROR;
       ELSE --should never come here, given how BSA is coded now
          select count(1)
          into l_bsa_count
          from oe_blanket_headers_all
          where header_id = p_header_id;

          IF l_bsa_count > 0 THEN
             l_sales_document_type_code := 'B';
             raise FND_API.G_EXC_ERROR;
          END IF;
       END IF;
      END IF;
      -- END Bug3435165

      l_sales_document_type_code := WF_ENGINE.GetItemAttrText(OE_GLOBALS.G_WFI_NGO, p_header_id, 'SALES_DOCUMENT_TYPE_CODE');
      IF l_sales_document_type_code = 'O' THEN
       l_entity_code := 'HEADER';
      ELSE
       l_entity_code := 'BLANKET_HEADER';
      END IF;

      OE_MSG_PUB.set_msg_context(
         p_entity_code                  => l_entity_code
        ,p_entity_id                    => p_header_id
        ,p_header_id                    => p_header_id
        ,p_line_id                      => null
        ,p_orig_sys_document_ref        => null
        ,p_orig_sys_document_line_ref   => null
        ,p_change_sequence              => null
        ,p_source_document_id           => null
        ,p_source_document_line_id      => null
        ,p_order_source_id            => null
        ,p_source_document_type_id    => null);

      select wpa.activity_name
      into l_activity_name
      from wf_item_activity_statuses wias, wf_process_activities wpa
      where item_type = OE_GLOBALS.G_WFI_NGO
      and item_key = to_char(p_header_id)
      and activity_status = wf_engine.eng_notified
      and wpa.activity_name = l_submit_draft_eligible
      and wias.process_activity = wpa.instance_id;

    EXCEPTION
      WHEN OTHERS THEN
          IF l_sales_document_type_code = 'O' THEN
               fnd_message.set_name('ONT', 'OE_NTF_QUOTE');
          ELSE -- assume blanket
               fnd_message.set_name('ONT', 'OE_NTF_BSA');
          END IF;
          l_sales_document_type := fnd_message.get;

          fnd_message.set_name('ONT', 'OE_WF_NO_SUBMIT_DRAFT'); --flow not at right state
          fnd_message.set_token('SALES_DOCUMENT_TYPE', l_sales_document_type);
          oe_msg_pub.add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add('EXITING OE_Negotiate_WF.Submit_Draft WITH STATUS: '||X_RETURN_STATUS ,1);
          END IF;
          return;
    END;
    -- ok to go Submit Draft
    WF_ENGINE.CompleteActivityInternalName(itemtype => OE_GLOBALS.G_WFI_NGO,
                                           itemkey => to_char(p_header_id),
                                           activity => l_activity_name,
                                           result => 'COMPLETE');
    IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Negotiate_WF.Submit_Draft normally', 1);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Negotiate_WF.Submit_Draft WITH STATUS: '||X_RETURN_STATUS ,1);
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
                 OE_MSG_PUB.Add_Exc_Msg
                       (   G_PKG_NAME,
                          'Submit_Draft'
                       );
        END IF;



END Submit_Draft;

PROCEDURE set_header_attributes_internal(p_header_id IN NUMBER)
IS
--
l_sales_document_type_code VARCHAR2(1);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_sold_to_org_id NUMBER;
l_salesrep_id    NUMBER;
l_salesrep       VARCHAR2(240);
l_sold_to        VARCHAR2(240);
l_customer_number  VARCHAR2(30);
l_expiration_date DATE;
l_aname      wf_engine.nametabtyp;
l_avaluetext wf_engine.texttabtyp;
--
BEGIN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_Negotiate_WF.Set_Header_Attributes_Internal:'||To_char(p_header_id) ,1 ) ;
    END IF;

     l_sales_document_type_code := WF_ENGINE.GetItemAttrText(OE_GLOBALS.G_WFI_NGO, To_char(p_header_id), 'SALES_DOCUMENT_TYPE_CODE');
     IF l_sales_document_type_code = 'O' THEN

      select sold_to_org_id, expiration_date, salesrep_id
      into   l_sold_to_org_id, l_expiration_date, l_salesrep_id
      from   oe_order_headers_all
      where  header_id = p_header_id;
     ELSE
      select sold_to_org_id, expiration_date, salesrep_id
      into   l_sold_to_org_id, l_expiration_date, l_salesrep_id
      from   oe_blanket_headers_all
      where  header_id = p_header_id;
     END IF;

       l_salesrep := OE_Id_To_Value.Salesrep(p_salesrep_id=>l_salesrep_id);
       OE_Id_To_Value.Sold_To_Org(p_sold_to_org_id=>l_sold_to_org_id, x_org=> l_sold_to, x_customer_number=>l_customer_number);
       l_aname(1) := 'SALESPERSON';
       l_avaluetext(1) := l_salesrep;
       l_aname(2) := 'SOLD_TO';
       l_avaluetext(2) := l_sold_to;
       l_aname(3) := 'EXPIRATION_DATE';
       l_avaluetext(3) := l_expiration_date;

       wf_engine.SetItemAttrTextArray(itemtype=>OE_GLOBALS.G_WFI_NGO,
				      itemkey=>To_char(p_header_id),
				      aname=>l_aname,
				      avalue=>l_avaluetext);

       -- end setting item attribute for WF header attributes
EXCEPTION
     WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME
        , 'Set_Header_Attributes_Internal'
        );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

END Set_Header_Attributes_Internal;

PROCEDURE Set_Header_Attributes(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
IS
--
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_Negotiate_WF.Set_Header_Attributes:'||ITEMTYPE||'/'||ITEMKEY ,1 ) ;
    END IF;
    OE_STANDARD_WF.Set_Msg_Context(actid);
    IF (funcmode = 'RUN') THEN
       set_header_attributes_internal(To_number(itemkey));
       resultout := 'COMPLETE';
    END IF;
EXCEPTION
    when others then
       wf_core.context('OE_Negotiate_WF', 'Set_Header_Attributes', itemtype, itemkey, to_char(actid), funcmode);
       -- start data fix project
       OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                             p_itemtype => itemtype,
                                             p_itemkey => itemkey);
       -- end data fix project
       oe_standard_wf.save_messages;
       oe_standard_wf.clear_msg_context;
       raise;

END Set_Header_Attributes;

PROCEDURE set_final_expiration_date(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
IS
--
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   l_final_timer NUMBER;
   l_sales_document_type_code VARCHAR2(1);
   l_expiration_date DATE;
   l_from_role VARCHAR2(200);
--

BEGIN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_Negotiate_WF.Set_Final_Expiration_Date:'||ITEMTYPE||'/'||ITEMKEY ,1 ) ;
    END IF;
    OE_STANDARD_WF.Set_Msg_Context(actid);
    IF (funcmode = 'RUN') then
       OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'HEADER'
          ,p_entity_id                  => to_number(itemkey)
          ,p_header_id                    => to_number(itemkey));

       set_header_attributes_internal(To_number(itemkey));
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Done setting header attributes',1);
       END IF;

       l_sales_document_type_code := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'SALES_DOCUMENT_TYPE_CODE');
       IF l_sales_document_type_code = 'O' THEN
        select expiration_date
        into   l_expiration_date
        from   oe_order_headers_all
        where  header_id = to_number(itemkey);
       ELSE
	-- even though there is no offer expiration date for blanket for now
	-- we will still fetch it for the future
        select expiration_date
        into   l_expiration_date
        from   oe_blanket_headers_all
        where  header_id = to_number(itemkey);
       END IF;

       IF l_expiration_date IS NULL THEN
	  -- should not be coming here
	  RETURN;
       END IF;

       l_final_timer := (l_expiration_date - Sysdate) * 1440;
       IF l_final_timer > 0 THEN
	  wf_engine.setitemattrnumber(itemtype=>itemtype,
				      itemkey=>itemkey,
				      aname=>'OFFER_FINAL_EXPIRE_TIMER',
				      avalue=>l_final_timer);
	   /*starting the fix for bug 9069528 */
       l_from_role:=wf_engine.GetItemAttrText(itemtype,itemkey,'NOTIFICATION_FROM_ROLE');
         IF NOT WF_DIRECTORY.UserActive(l_from_role) THEN
              l_from_role := fnd_profile.Value('OE_NOTIFICATION_APPROVER');
           IF l_from_role IS null or NOT WF_DIRECTORY.UserActive(l_from_role) then
              l_from_role := 'SYSADMIN';
           END IF;
         END IF;
      wf_engine.setItemAttrText(itemtype,itemkey,'NOTIFICATION_FROM_ROLE',l_from_role);
     /*ending the fix for bug 9069528 */
         resultout := 'COMPLETE';
       ELSE
          resultout := 'COMPLETE:EXPIRED';
       END IF;

       IF l_debug_level  > 0 THEN
             oe_debug_pub.add('Leaving OE_Negotiate_WF.Set_Final_Expiration_Date', 1);
       END IF;
    END IF;
EXCEPTION
    when others then
       wf_core.context('OE_Negotiate_WF', 'Set_Final_Expiration_Date', itemtype, itemkey, to_char(actid), funcmode);
       -- start data fix project
       OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                             p_itemtype => itemtype,
                                             p_itemkey => itemkey);
       -- end data fix project
       oe_standard_wf.save_messages;
       oe_standard_wf.clear_msg_context;
       raise;

END set_final_expiration_date;


FUNCTION At_Customer_Acceptance(p_header_id NUMBER)
RETURN Boolean
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_activity_name VARCHAR2(30);
--
 l_customer_acceptance VARCHAR2(30) := 'CUSTOMER_ACCEPTANCE';
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTER OE_Negotiate_WF.At_Customer_Acceptance');
  END IF;

  select wpa.activity_name
  into l_activity_name
  from wf_item_activity_statuses wias, wf_process_activities wpa
  where item_type = OE_GLOBALS.G_WFI_NGO
  and item_key = to_char(p_header_id)
  and activity_status = wf_engine.eng_notified
  and wpa.activity_name = l_customer_acceptance
  and wias.process_activity = wpa.instance_id;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
     -- not at customer_accpetance
     RETURN FALSE;

END At_Customer_Acceptance;


END OE_Negotiate_WF;

/
