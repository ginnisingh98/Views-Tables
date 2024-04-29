--------------------------------------------------------
--  DDL for Package Body OE_BLANKET_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BLANKET_WF" as
/* $Header: OEXWBSOB.pls 120.3.12010000.6 2015/09/18 07:22:34 suthumma ship $ */


PROCEDURE Submit_Draft_Internal (
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_return_status VARCHAR2(30);
l_qa_return_status VARCHAR2(30);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_count NUMBER;
--
BEGIN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_BLanket_WF.Submit_Draft_Internal:'||ITEMTYPE||'/'||ITEMKEY ,1 ) ;
    END IF;
    OE_STANDARD_WF.Set_Msg_Context(actid);
    IF (funcmode = 'RUN') then

     select count(1)
     into l_count
     from wf_items
     where item_type  = OE_GLOBALS.G_WFI_NGO
     and item_key     = itemkey;

     IF l_count = 0 THEN
      /* only if it has not gone through negotiation QA check
         Blanket_QA_Check API call */

        OE_CONTRACTS_UTIL.qa_articles ( p_api_version => 1.0,
                                   p_doc_type    => 'B',
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

     END IF;
     -- negotiation flow exists, no need to QA check

-- UI will always display any msg

      OE_ORDER_WF_UTIL.Update_Quote_Blanket(p_item_type => OE_GLOBALS.G_WFI_BKT,
                                            p_item_key => itemkey,
                                            p_flow_status_code => 'DRAFT_SUBMITTED',
                                            p_draft_submitted_flag => 'Y',
                                            x_return_status => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        resultout := 'COMPLETE:INCOMPLETE';
        OE_STANDARD_WF.Save_Messages;
        OE_STANDARD_WF.Clear_Msg_Context;
        return;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        app_exception.raise_exception;
      END IF;

      resultout := 'COMPLETE:COMPLETE';


    END IF;
EXCEPTION
    when others then
       wf_core.context('OE_Blanket_WF', 'Submit_Draft_Internal', itemtype, itemkey, to_char(actid), funcmode);
       -- start data fix project
       OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
       -- end data fix project
       OE_STANDARD_WF.Save_Messages;
       OE_STANDARD_WF.Clear_Msg_Context;
       raise;

END Submit_Draft_Internal;


PROCEDURE Check_Negotiation_Exists(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_count NUMBER;
--
BEGIN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_Blanket_WF.Check_Negotiation_Exists:'||ITEMTYPE||'/'||ITEMKEY ,1 ) ;
    END IF;
    OE_STANDARD_WF.Set_Msg_Context(actid);
    IF (funcmode = 'RUN') THEN
       select count(1)
       into l_count
       from wf_items
       where item_type = OE_GLOBALS.G_WFI_NGO
       and item_key = itemkey;

       IF l_count > 0 THEN
          resultout := 'COMPLETE:Y';
       ELSE
          resultout := 'COMPLETE:N';
       END IF;

    END IF;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING OE_BLanket_WF.Check_Negotiation_Exists:' || resultout);
    END IF;

EXCEPTION
    when others then
       wf_core.context('OE_Blanket_WF', 'Check_Negotiation_Exists', itemtype, itemkey, to_char(actid), funcmode);
       -- start data fix project
       OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
       -- end data fix project
       OE_STANDARD_WF.Save_Messages;
       OE_STANDARD_WF.Clear_Msg_Context;
       raise;

END Check_Negotiation_Exists;


PROCEDURE Calculate_Effective_Dates(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_start_date DATE;
l_end_date   DATE;
l_pre_notification_percent NUMBER;
l_aname         wf_engine.nametabtyp;
l_avalue        wf_engine.numtabtyp;
l_final_timer   NUMBER;
l_start_timer   NUMBER;
l_return_status VARCHAR2(30);
--

BEGIN

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_Blanket_WF.Calculate_Effective_Dates:'||ITEMTYPE||'/'||ITEMKEY ,1 ) ;
    END IF;
    OE_STANDARD_WF.Set_Msg_Context(actid);
    IF (funcmode = 'RUN') then
      SELECT obhe.Start_Date_Active, obhe.End_Date_Active
      INTO   l_start_date, l_end_date
      FROM   oe_blanket_headers_all obha, oe_blanket_headers_ext obhe
      WHERE  obha.header_id = to_number(itemkey)
      AND    obha.order_number = obhe.order_number;

      -- start date has not been reached
      IF l_start_date > sysdate THEN
         l_start_timer := (l_start_date - sysdate) * 1440;
         wf_engine.setitemattrnumber(itemtype=>itemtype,
				     itemkey=>itemkey,
				     aname=>'BLANKET_START_TIMER',
				     avalue=>l_start_timer);
         oe_order_wf_util.update_flow_status_code(p_header_id => to_number(itemkey),
                                                  p_flow_status_code => 'AWAITING_START_DATE',
                                                  p_item_type => OE_GLOBALS.G_WFI_BKT,
                                                  x_return_status => l_return_status);

         resultout := 'COMPLETE:AWAITING_START_DATE';
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Leaving OE_Blanket_WF.Calculate_Effective_Dates: Start date not reached', 1);
         END IF;
         return;
      ELSIF l_end_date is null THEN --start date reached, but no end date
           oe_order_wf_util.update_flow_status_code(p_header_id => to_number(itemkey),
                                                  p_flow_status_code => 'ACTIVE',
                                                  p_item_type => OE_GLOBALS.G_WFI_BKT,
                                                  x_return_status => l_return_status);
           resultout := 'COMPLETE:NO_END_DATE';
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Leaving OE_Blanket_WF.Calculate_Effective_Date: No end date', 1);
           END IF;
           return;
      ELSIF l_end_date < sysdate THEN --start date reached, end date also reached
            resultout := 'COMPLETE:EXPIRED';
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Leaving OE_Blanket_WF.Calculate_Effective_Dates: EXPIRED', 1);
            END IF;
            -- status update will be handled in the Expired activity
            return;
      END IF;

      --if you are here, that means expiration date exists and is in the future

      l_pre_notification_percent := wf_engine.GetItemAttrNumber(itemtype, itemkey, 'PRE_EXPIRE_TIME_PERCENT');

      oe_debug_pub.add('sysdate:' || to_char(sysdate, 'DD-MON-RRRR') || ' and end date:' || to_char(l_end_date, 'DD-MON-RRRR'),1);

      IF l_pre_notification_percent = 0 THEN
         -- set the FINAL timer only is enough
         -- this assumes expiration_date is already set to 23:59:59
         l_final_timer := (l_end_date - sysdate) * 1440;
         wf_engine.setitemattrnumber(itemtype=>itemtype,
				     itemkey=>itemkey,
				     aname=>'BLANKET_FINAL_EXPIRE_TIMER',
				     avalue=>l_final_timer);
         oe_order_wf_util.update_flow_status_code(p_header_id => to_number(itemkey),
                                                  p_flow_status_code => 'ACTIVE',
                                                  p_item_type => OE_GLOBALS.G_WFI_BKT,
                                                  x_return_status => l_return_status);
         resultout := 'COMPLETE:NO_REMINDER';
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add('Leaving OE_Blanket_WF.Calculate_Effective_Dates: NO REMINDER', 1);
         END IF;
         return;
      ELSIF to_char(sysdate, 'DD-MON-RRRR') = to_char(l_end_date, 'DD-MON-RRRR') THEN
         -- pre notification percentage is non-zero
         -- end_date is today midnight, we should send the reminder

	 wf_engine.SetItemAttrNumber(itemtype=>itemtype,
				     itemkey=>itemkey,
                                     aname=> 'BLANKET_FINAL_EXPIRE_TIMER',
                                     avalue=> (l_end_date - sysdate) * 1440);
              oe_order_wf_util.update_flow_status_code(p_header_id => to_number(itemkey),
                                                  p_flow_status_code => 'ACTIVE',
                                                  p_item_type => OE_GLOBALS.G_WFI_BKT,
                                                  x_return_status => l_return_status);
              resultout := 'COMPLETE:EXPIRE_TODAY';
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('OE_Blanket_WF.Calculate_Effective_Dates: EXPIRE TODAY', 1);
              END IF;
      ELSE --expiration is not today, i.e. it is in the future
           --again end_date should already be in 23:59:59
              l_aname(1) := 'BLANKET_FINAL_EXPIRE_TIMER';
              l_avalue(1) := Ceil((l_end_date - sysdate) * l_pre_notification_percent/100) * 1440;
              l_aname(2) := 'BLANKET_PRE_EXPIRE_TIMER';
              l_avalue(2) := ((l_end_date - sysdate) * 1440) - l_avalue(1);

              wf_engine.SetItemAttrNumberArray(itemtype=>itemtype
                              , itemkey=>itemkey
                              , aname=>l_aname
                              , avalue=>l_avalue
                              );
              oe_order_wf_util.update_flow_status_code(p_header_id => to_number(itemkey),
                                                  p_flow_status_code => 'ACTIVE',
                                                  p_item_type => OE_GLOBALS.G_WFI_BKT,
                                                  x_return_status => l_return_status);
              resultout := 'COMPLETE:START_DATE_REACHED';
      END IF; -- end if of expiration date is today or future

      IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Leaving OE_Blanket_WF.Calculate_Effective_Dates: TIMER(S) SET', 1);
      END IF;
    END IF;  --funcmode = run

EXCEPTION
    when others then
       wf_core.context('OE_Blanket_WF', 'Calculate_Effective_Dates', itemtype, itemkey, to_char(actid), funcmode);
       -- start data fix project
       OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
       -- end data fix project
       OE_STANDARD_WF.Save_Messages;
       OE_STANDARD_WF.Clear_Msg_Context;
       raise;

END Calculate_Effective_Dates;


PROCEDURE Set_Blanket_Hdr_Descriptor
   (document_id   in VARCHAR2,
    display_type  in VARCHAR2,
    document      in out nocopy VARCHAR2,
    document_type in out nocopy VARCHAR2)
IS
--
l_header_id NUMBER;
l_blanket_number NUMBER;
l_header_txt VARCHAR2(2000);
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
     -- if viewing method is email
     l_header_id := to_number(wf_engine.setctx_itemkey);
  END;

  SELECT order_number
  INTO   l_blanket_number
  FROM   oe_blanket_headers_all
  WHERE  header_id = l_header_id;

  fnd_message.set_name('ONT', 'OE_WF_BLANKET_ORDER');
  fnd_message.set_token('BLANKET_NUMBER', to_char(l_blanket_number));
  l_header_txt := fnd_message.get;
  document := substrb(l_header_txt, 1, 240);

EXCEPTION
     WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME
        , 'Set_Blanket_Hdr_Descriptor'
        );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
END Set_Blanket_Hdr_Descriptor;


PROCEDURE Get_Expire_Date
   (document_id   in VARCHAR2,
    display_type  in VARCHAR2,
    document      in out nocopy VARCHAR2,
    document_type in out nocopy VARCHAR2)
IS
--
l_header_id NUMBER;
l_end_date  DATE;
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
     -- if viewing method is email
     l_header_id := to_number(wf_engine.setctx_itemkey);
  END;

  SELECT obhe.end_date_active
  INTO   l_end_date
  FROM   oe_blanket_headers_all obha, oe_blanket_headers_ext obhe
  WHERE  obha.header_id = l_header_id
  AND    obha.order_number = obhe.order_number;

  document := to_char(l_end_date, 'DD-MON-RRRR');

EXCEPTION
     WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME
        , 'Get_Expire_Date'
        );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

END Get_Expire_Date;


PROCEDURE Expired(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_return_status VARCHAR2(30);
l_sold_to_org_id NUMBER;
l_salesrep_id    NUMBER;
l_salesrep       VARCHAR2(240);
l_sold_to        VARCHAR2(240);
l_customer_number  VARCHAR2(30);--bug5562980
l_end_date   DATE;
l_aname      wf_engine.nametabtyp;
l_avaluetext wf_engine.texttabtyp;
--
BEGIN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_BLanket_WF.Expired:'||ITEMTYPE||'/'||ITEMKEY ,1 ) ;
    END IF;
    OE_STANDARD_WF.Set_Msg_Context(actid);
    IF (funcmode = 'RUN') then
      OE_ORDER_WF_UTIL.Update_Quote_Blanket( p_item_type => OE_GLOBALS.G_WFI_BKT,
                                        p_item_key => itemkey,
                                        p_flow_status_code => 'EXPIRED',
                                        x_return_status => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- set WF header attributes, values may have been changed during the wait period
      select bh.sold_to_org_id, bhx.end_date_active, bh.salesrep_id
      into   l_sold_to_org_id, l_end_date, l_salesrep_id
      from   oe_blanket_headers_all bh, oe_blanket_headers_ext bhx
      where  bh.header_id = to_number(itemkey)
      and    bh.order_number = bhx.order_number;

      l_salesrep := OE_Id_To_Value.Salesrep(p_salesrep_id=>l_salesrep_id);
      OE_Id_To_Value.Sold_To_Org(p_sold_to_org_id=>l_sold_to_org_id, x_org=> l_sold_to,
                                 x_customer_number=>l_customer_number);
       l_aname(1) := 'SALESPERSON';
       l_avaluetext(1) := l_salesrep;
       l_aname(2) := 'SOLD_TO';
       l_avaluetext(2) := l_sold_to;
       l_aname(3) := 'BLANKET_EXPIRE_DATE';
       l_avaluetext(3) := l_end_date;

       wf_engine.SetItemAttrTextArray(itemtype=>itemtype,
				      itemkey=>itemkey,
				      aname=>l_aname,
				      avalue=>l_avaluetext);


      resultout := 'COMPLETE:COMPLETE';

    END IF;
EXCEPTION
    when others then
       wf_core.context('OE_Blanket_WF', 'Expired', itemtype, itemkey, to_char(actid), funcmode);
       -- start data fix project
       OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
       -- end data fix project
       OE_STANDARD_WF.Save_Messages;
       OE_STANDARD_WF.Clear_Msg_Context;
       raise;
END Expired;



PROCEDURE Terminate_Internal(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)

IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_return_status VARCHAR2(30);
l_from_role VARCHAR2(200);  --for bug 21681370
--
BEGIN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_BLanket_WF.Terminate_Internal:'||ITEMTYPE||'/'||ITEMKEY ,1 ) ;
    END IF;
    OE_STANDARD_WF.Set_Msg_Context(actid);
    IF (funcmode = 'RUN') then
      OE_ORDER_WF_UTIL.Update_Quote_Blanket( p_item_type => OE_GLOBALS.G_WFI_BKT,
                                        p_item_key => itemkey,
                                        p_flow_status_code => 'TERMINATED',
                                        x_return_status => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
       /*starting the fix for bug 21681370  */
       l_from_role:=wf_engine.GetItemAttrText(itemtype,itemkey,'NOTIFICATION_FROM_ROLE');
         IF NOT WF_DIRECTORY.UserActive(l_from_role) THEN
            --l_from_role := fnd_profile.Value('OE_NOTIFICATION_APPROVER') --21850631
            l_from_role := fnd_profile.Value('OE_NOTIFICATION_APPROVER'); --21850631
            IF l_from_role IS null or NOT WF_DIRECTORY.RoleActive(l_from_role) then
               l_from_role := 'SYSADMIN';
            END IF;
         END IF;
     wf_engine.setItemAttrText(itemtype,itemkey,'NOTIFICATION_FROM_ROLE',l_from_role);
     /*ending the fix for bug 21681370  */
      resultout := 'COMPLETE';

    END IF;
EXCEPTION
    when others then
       wf_core.context('OE_Blanket_WF', 'Terminate_Internal', itemtype, itemkey, to_char(actid), funcmode);
       -- start data fix project
       OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
       -- end data fix project
       OE_STANDARD_WF.Save_Messages;
       OE_STANDARD_WF.Clear_Msg_Context;
       raise;

END Terminate_Internal;

PROCEDURE Close_Internal(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_return_status VARCHAR2(30);
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER;
l_blanket_number NUMBER;
--
BEGIN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_BLanket_WF.Close_Internal:'||ITEMTYPE||'/'||ITEMKEY ,1 ) ;
    END IF;
    OE_STANDARD_WF.Set_Msg_Context(actid);
    IF (funcmode = 'RUN') then
      -- check for releases of blanket
      l_blanket_number := wf_engine.GetItemAttrNumber(itemtype, itemkey, 'TRANSACTION_NUMBER');
      OE_BLANKET_WF_UTIL.Check_Release(p_blanket_number => l_blanket_number, x_return_status => l_return_status);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        --Blanket release check failed, return incomplete
        --UI will display the message
        resultout := 'COMPLETE:INCOMPLETE';
        OE_STANDARD_WF.Save_Messages;
        OE_STANDARD_WF.Clear_Msg_Context;
        return;
      END IF;
      -- update open_flag to N
      OE_ORDER_WF_UTIL.Update_Quote_Blanket( p_item_type => OE_GLOBALS.G_WFI_BKT,
                                        p_item_key => itemkey,
                                        p_flow_status_code => 'CLOSED',--bug#5589336
                                        p_open_flag => 'N',
                                        x_return_status => l_return_status);
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      resultout := 'COMPLETE:COMPLETE';

    END IF;
EXCEPTION
    when others then
       wf_core.context('OE_Blanket_WF', 'Close_Internal', itemtype, itemkey, to_char(actid), funcmode);
       -- start data fix project
       OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
       -- end data fix project
       OE_STANDARD_WF.Save_Messages;
       OE_STANDARD_WF.Clear_Msg_Context;
       raise;

END Close_Internal;



PROCEDURE Blanket_Date_Changed(p_header_id IN NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_activity_name VARCHAR2(30);
l_transaction_phase_code VARCHAR2(30);
--
BEGIN
    OE_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('ENTERING OE_Blanket_WF.Blanket_Date_Changed: '|| TO_CHAR (p_header_id) ,1);
    END IF;

    SELECT transaction_phase_code
    INTO   l_transaction_phase_code
    FROM   oe_blanket_headers_all
    WHERE  header_id = p_header_id;

    IF nvl(l_transaction_phase_code, 'F') = 'N' THEN
       -- currently during negotiation phase, there is no impact
       -- on changing the dates on a blanket
       RETURN;
    END IF;


    BEGIN
      select wpa.activity_name
      into l_activity_name
      from wf_item_activity_statuses wias, wf_process_activities wpa
      where item_type = OE_GLOBALS.G_WFI_BKT
      and item_key = to_char(p_header_id)
      and activity_status = 'NOTIFIED'
      and wpa.activity_name in ('WAIT_FOR_START_DATE', 'BLANKET_NO_END_DATE', 'WAIT_FOR_EXPIRATION', 'WAIT_FOR_FINAL_EXPIRATION', 'BLANKET_SUBMIT_DRAFT_ELIGIBLE')
      and wias.process_activity = wpa.instance_id;

    EXCEPTION
      WHEN OTHERS THEN
           fnd_message.set_name('ONT', 'OE_BKT_NO_DATE_CHANGE');
           oe_msg_pub.add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add('EXITING OE_Blanket_WF.Blanket_Date_Changed WITH STATUS: '||X_RETURN_STATUS ,1);
           END IF;
           return;

    END;

    -- ok to go date change
    -- if it is at blanket_submit_draft_eligible, no need to go date change, calculate effective date later will figure out the right timers
    IF l_activity_name <> 'BLANKET_SUBMIT_DRAFT_ELIGIBLE' THEN
        WF_ENGINE.CompleteActivityInternalName(OE_GLOBALS.G_WFI_BKT, to_char(p_header_id), l_activity_name, 'DATE_CHANGED');
    END IF;

    IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Blanket_WF.Blanket_Date_Changed normally', 1);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Blanket_WF.Blanket_Date_Changed WITH STATUS: '||X_RETURN_STATUS ,1);
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
                 OE_MSG_PUB.Add_Exc_Msg
                       (   G_PKG_NAME,
                          'Blanket_Date_Changed'
                       );
        END IF;


END Blanket_Date_Changed;


PROCEDURE Submit_Draft(p_header_id IN NUMBER,
                       p_transaction_phase_code IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_activity_name VARCHAR2(30);
l_sales_document_type VARCHAR2(30);
--
BEGIN
    -- OE_MSG_PUB.initialize; commented out due to 4671489
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('ENTERING OE_Blanket_WF.Submit_Draft: '|| TO_CHAR (p_header_id) ,1);
    END IF;
    BEGIN
      select wpa.activity_name
      into l_activity_name
      from wf_item_activity_statuses wias, wf_process_activities wpa
      where item_type = OE_GLOBALS.G_WFI_BKT
      and item_key = to_char(p_header_id)
      and activity_status = 'NOTIFIED'
      and wpa.activity_name = 'BLANKET_SUBMIT_DRAFT_ELIGIBLE'
      and wias.process_activity = wpa.instance_id;

    EXCEPTION
      WHEN OTHERS THEN
           fnd_message.set_name('ONT', 'OE_WF_BLANKET');
           l_sales_document_type := fnd_message.get;
           fnd_message.set_name('ONT', 'OE_WF_NO_SUBMIT_DRAFT');
           -- FND message activity name should match WF activity name for Submit Draft in blanket
           fnd_message.set_token('SALES_DOCUMENT_TYPE', l_sales_document_type);
           oe_msg_pub.add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add('EXITING OE_Blanket_WF.Submit_Draft WITH STATUS: '||X_RETURN_STATUS ,1);
           END IF;
           return;
    END;

    -- ok to go submit draft
    WF_ENGINE.CompleteActivityInternalName(OE_GLOBALS.G_WFI_BKT, to_char(p_header_id), l_activity_name, 'COMPLETE');

    IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Blanket_WF.Submit_Draft', 1);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Blanket_WF.Submit_Draft WITH STATUS: '||X_RETURN_STATUS ,1);
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
                 OE_MSG_PUB.Add_Exc_Msg
                       (   G_PKG_NAME,
                          'Submit_Draft'
                       );
        END IF;


END Submit_Draft;


PROCEDURE Close(p_header_id IN NUMBER,
                x_return_status OUT NOCOPY VARCHAR2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_activity_name VARCHAR2(30);
l_sales_document_type VARCHAR2(30);
--
BEGIN
    OE_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('ENTERING OE_Blanket_WF.Close: '|| TO_CHAR (p_header_id) ,1);
    END IF;
    BEGIN
      select wpa.activity_name
      into l_activity_name
      from wf_item_activity_statuses wias, wf_process_activities wpa
      where item_type = OE_GLOBALS.G_WFI_BKT
      and item_key = to_char(p_header_id)
      and activity_status = 'NOTIFIED'
      and wpa.activity_name = 'CLOSE_BLANKET_ELIGIBLE'
      and wias.process_activity = wpa.instance_id;

    EXCEPTION
      WHEN OTHERS THEN
           fnd_message.set_name('ONT', 'OE_BKT_NO_CLOSE');
           oe_msg_pub.add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add('EXITING OE_Blanket_WF.Close WITH STATUS: '||X_RETURN_STATUS ,1);
           END IF;
           return;

    END;

    -- ok to go submit draft
    WF_ENGINE.CompleteActivityInternalName(OE_GLOBALS.G_WFI_BKT, to_char(p_header_id), l_activity_name, 'COMPLETE');

    IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Blanket_WF.Close', 1);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Blanket_WF.Close WITH STATUS: '||X_RETURN_STATUS ,1);
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
                 OE_MSG_PUB.Add_Exc_Msg
                       (   G_PKG_NAME,
                          'Close'
                       );
        END IF;


END Close;


PROCEDURE Terminate(p_header_id IN NUMBER,
                    p_terminated_by IN NUMBER,
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
l_sold_to_org_id NUMBER;
l_salesrep_id    NUMBER;
l_salesrep       VARCHAR2(240);
l_sold_to        VARCHAR2(240);
l_customer_number VARCHAR2(30);--bug5562980
l_end_date   DATE;
l_aname      wf_engine.nametabtyp;
l_avaluetext wf_engine.texttabtyp;
l_terminator VARCHAR2(100);
l_return_status VARCHAR2(240);
l_reason_id  NUMBER;
--
BEGIN
    OE_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('ENTERING OE_Blanket_WF.Terminate: '|| TO_CHAR (p_header_id) ,1);
    END IF;
    BEGIN
      select wpa.activity_name
      into l_activity_name
      from wf_item_activity_statuses wias, wf_process_activities wpa
      where item_type = OE_GLOBALS.G_WFI_BKT
      and item_key = to_char(p_header_id)
      and activity_status = 'NOTIFIED'
      and wpa.activity_name in ('WAIT_FOR_START_DATE', 'BLANKET_NO_END_DATE', 'WAIT_FOR_EXPIRATION', 'WAIT_FOR_FINAL_EXPIRATION')
      and wias.process_activity = wpa.instance_id;

    EXCEPTION
      WHEN OTHERS THEN
           fnd_message.set_name('ONT', 'OE_BKT_NO_TERMINATE');
           oe_msg_pub.add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add('EXITING OE_Blanket_WF.Terminate WITH STATUS: '||X_RETURN_STATUS ,1);
           END IF;
           return;
    END;

    -- ok to go terminate
    -- call reason API to capture the reason

    OE_REASONS_UTIL.Apply_Reason(p_entity_code => OE_BLANKET_PUB.G_ENTITY_BLANKET_HEADER,
                                p_entity_id => p_header_id,
                                p_version_number => p_version_number,
                                p_reason_type => p_reason_type,
                                p_reason_code => p_reason_code,
                                p_reason_comments => p_reason_comments,
                                x_reason_id => l_reason_id,
                                x_return_status => l_return_status);

    SELECT USER_NAME
    INTO   l_terminator
    FROM FND_USER
    WHERE USER_ID = p_terminated_by;

    WF_ENGINE.SetItemAttrText(itemtype=>OE_GLOBALS.G_WFI_BKT,
			      itemkey=>to_char(p_header_id),
			      aname=>'TERMINATOR',
			      avalue=>l_terminator);

    -- set WF header attributes, values may have been changed during the wait period
    select bh.sold_to_org_id, bhx.end_date_active, bh.salesrep_id
    into   l_sold_to_org_id, l_end_date, l_salesrep_id
    from   oe_blanket_headers_all bh, oe_blanket_headers_ext bhx
    where  bh.header_id = p_header_id
    and    bh.order_number = bhx.order_number;

    l_salesrep := OE_Id_To_Value.Salesrep(p_salesrep_id=>l_salesrep_id);
    OE_Id_To_Value.Sold_To_Org(p_sold_to_org_id=>l_sold_to_org_id, x_org=> l_sold_to,
                                 x_customer_number=>l_customer_number);
    l_aname(1) := 'SALESPERSON';
    l_avaluetext(1) := l_salesrep;
    l_aname(2) := 'SOLD_TO';
    l_avaluetext(2) := l_sold_to;
    l_aname(3) := 'BLANKET_EXPIRE_DATE';
    l_avaluetext(3) := l_end_date;

    wf_engine.SetItemAttrTextArray(itemtype=>OE_GLOBALS.G_WFI_BKT,
				   itemkey=>to_char(p_header_id),
				   aname=>l_aname,
				   avalue=>l_avaluetext);

    -- end header attributes

    WF_ENGINE.CompleteActivityInternalName(OE_GLOBALS.G_WFI_BKT, to_char(p_header_id), l_activity_name, 'TERMINATE');

    IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Blanket_WF.Terminate', 1);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Blanket_WF.Terminate WITH STATUS: '||X_RETURN_STATUS ,1);
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
                 OE_MSG_PUB.Add_Exc_Msg
                       (   G_PKG_NAME,
                          'Terminate'
                       );
        END IF;

END Terminate;


PROCEDURE Extend(p_header_id IN NUMBER,
                 x_return_status OUT NOCOPY VARCHAR2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_activity_name VARCHAR2(30);
--
BEGIN
    OE_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('ENTERING OE_Blanket_WF.Extend: '|| TO_CHAR (p_header_id) ,1);
    END IF;
    BEGIN
      select wpa.activity_name
      into l_activity_name
      from wf_item_activity_statuses wias, wf_process_activities wpa
      where item_type = OE_GLOBALS.G_WFI_BKT
      and item_key = to_char(p_header_id)
      and activity_status = 'NOTIFIED'
      and wpa.activity_name = 'CLOSE_BLANKET_ELIGIBLE'
      and wias.process_activity = wpa.instance_id;

    EXCEPTION
      WHEN OTHERS THEN
           fnd_message.set_name('ONT', 'OE_BKT_NO_EXTEND');
           oe_msg_pub.add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add('EXITING OE_Blanket_WF.Extend WITH STATUS: '||X_RETURN_STATUS ,1);
           END IF;
           return;
    END;

    -- ok to go extend
    WF_ENGINE.CompleteActivityInternalName(OE_GLOBALS.G_WFI_BKT, to_char(p_header_id), l_activity_name, 'EXTEND');

    IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Blanket_WF.Extend', 1);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXITING OE_Blanket_WF.Extend WITH STATUS: '||X_RETURN_STATUS ,1);
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
                 OE_MSG_PUB.Add_Exc_Msg
                       (   G_PKG_NAME,
                          'Extend'
                       );
        END IF;

END Extend;

PROCEDURE Set_Header_Attributes_Internal(p_header_id IN NUMBER)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_sold_to_org_id NUMBER;
l_salesrep_id    NUMBER;
l_salesrep       VARCHAR2(240);
l_sold_to        VARCHAR2(240);
l_customer_number VARCHAR2(30);--bug5562980
l_end_date   DATE;
l_aname      wf_engine.nametabtyp;
l_avaluetext wf_engine.texttabtyp;
--
BEGIN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_Blanket_WF.Set_Header_Attributes_Internal:'||To_char(p_header_id),1);
    END IF;

      select bh.sold_to_org_id, bhx.end_date_active, bh.salesrep_id
      into   l_sold_to_org_id, l_end_date, l_salesrep_id
      from   oe_blanket_headers_all bh, oe_blanket_headers_ext bhx
      where  bh.header_id = p_header_id
      and    bh.order_number = bhx.order_number;

       l_salesrep := OE_Id_To_Value.Salesrep(p_salesrep_id=>l_salesrep_id);
       OE_Id_To_Value.Sold_To_Org(p_sold_to_org_id=>l_sold_to_org_id, x_org=> l_sold_to, x_customer_number=>l_customer_number);
       l_aname(1) := 'SALESPERSON';
       l_avaluetext(1) := l_salesrep;
       l_aname(2) := 'SOLD_TO';
       l_avaluetext(2) := l_sold_to;
       l_aname(3) := 'BLANKET_EXPIRE_DATE';
       l_avaluetext(3) := l_end_date;

       wf_engine.SetItemAttrTextArray(itemtype=>OE_GLOBALS.G_WFI_BKT,
				      itemkey=>To_char(p_header_id),
				      aname=>l_aname,
				      avalue=>l_avaluetext);

       -- end setting item attribute for WF header attributes
EXCEPTION
    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
                 OE_MSG_PUB.Add_Exc_Msg
                       (   G_PKG_NAME,
                          'Set_Header_Attributes_Internal'
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
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_Blanket_WF.Set_Header_Attributes:'||ITEMTYPE||'/'||ITEMKEY ,1 ) ;
   END IF;
   OE_STANDARD_WF.Set_Msg_Context(actid);
   IF (funcmode = 'RUN') THEN
       set_header_attributes_internal(To_number(itemkey));
       resultout := 'COMPLETE';
   END IF;
EXCEPTION
    when others then
       wf_core.context('OE_Blanket_WF', 'Set_Header_Attributes', itemtype, itemkey, to_char(actid), funcmode);
       -- start data fix project
       OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
       -- end data fix project
       OE_STANDARD_WF.Save_Messages;
       OE_STANDARD_WF.Clear_Msg_Context;
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
   l_end_date DATE;
   l_from_role VARCHAR2(200);  --for bug 9897971

--

BEGIN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_Blanket_WF.Set_Final_Expiration_Date:'||ITEMTYPE||'/'||ITEMKEY ,1 ) ;
    END IF;
    OE_STANDARD_WF.Set_Msg_Context(actid);
    IF (funcmode = 'RUN') THEN
       set_header_attributes_internal(To_number(itemkey));
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Done setting header attributes',1);
       END IF;

      SELECT obhe.End_Date_Active
      INTO   l_end_date
      FROM   oe_blanket_headers_all obha, oe_blanket_headers_ext obhe
      WHERE  obha.header_id = to_number(itemkey)
      AND    obha.order_number = obhe.order_number;


       l_final_timer := (l_end_date - Sysdate) * 1440;
       IF l_final_timer > 0 THEN
	  wf_engine.setitemattrnumber(itemtype=>itemtype,
				      itemkey=>itemkey,
				      aname=>'BLANKET_FINAL_EXPIRE_TIMER',
				      avalue=>l_final_timer);

       /*starting the fix for bug 9897971 */
       l_from_role:=wf_engine.GetItemAttrText(itemtype,itemkey,'NOTIFICATION_FROM_ROLE');
         IF NOT WF_DIRECTORY.UserActive(l_from_role) THEN
            l_from_role := fnd_profile.Value('OE_NOTIFICATION_APPROVER');
            --IF l_from_role IS null or NOT WF_DIRECTORY.UserActive(l_from_role) then
			IF l_from_role IS null or NOT WF_DIRECTORY.RoleActive(l_from_role) then --bug21213937 since the value of the profile is from wf_roles, it should check if it is active role, not user
            l_from_role := 'SYSADMIN';
            END IF;
         END IF;
     wf_engine.setItemAttrText(itemtype,itemkey,'NOTIFICATION_FROM_ROLE',l_from_role);
     /*ending the fix for bug 9897971 */

	  resultout := 'COMPLETE';
       ELSE
          resultout := 'COMPLETE:EXPIRED';
       END IF;

       IF l_debug_level  > 0 THEN
             oe_debug_pub.add('Leaving OE_Blanket_WF.Set_Final_Expiration_Date', 1);
       END IF;
    END IF;
EXCEPTION
    when others then
       wf_core.context('OE_Blanket_WF', 'Set_Final_Expiration_Date', itemtype, itemkey, to_char(actid), funcmode);
       -- start data fix project
       OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
       -- end data fix project
       OE_STANDARD_WF.Save_Messages;
       OE_STANDARD_WF.Clear_Msg_Context;
       raise;
END set_final_expiration_date;

END OE_Blanket_WF;

/
