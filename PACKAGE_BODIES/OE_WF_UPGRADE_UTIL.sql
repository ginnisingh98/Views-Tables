--------------------------------------------------------
--  DDL for Package Body OE_WF_UPGRADE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_WF_UPGRADE_UTIL" as
/* $Header: OEXWUPGB.pls 120.1 2006/06/02 19:14:48 spagadal noship $ */

PROCEDURE UPGRADE_CUSTOM_ACTIVITY_BLOCK(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2 /* file.sql.39 change */
)
IS
l_status VARCHAR2(01);
l_Scolumn_name VARCHAR2(05);
l_Scolumn_value NUMBER;
BEGIN

  --
  -- RUN mode - normal process execution
  --

  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project

  if (funcmode = 'RUN') then

	 IF OE_STANDARD_WF.G_UPGRADE_MODE THEN  -- Upgrade in progress. Check if Order/Line is already
                                             -- past custom activity.

          -- Find out What S column the custom activity is based on ...

          l_Scolumn_name := WF_ENGINE.GetActivityAttrText(itemtype, itemkey, actid, 'S_COLUMN');

          l_Scolumn_value := OE_ORDER_UPGRADE_UTIL.Get_entity_Scolumn_value(itemtype, itemkey, l_Scolumn_name);

          IF (l_Scolumn_value IS NOT NULL) THEN
		    IF (l_Scolumn_value = 18) THEN -- As in eligible
		        -- we set result to NOTIFIED. So that it can be externally completed.
		        resultout := wf_engine.eng_notified||':'||wf_engine.eng_null||':'||wf_engine.eng_null;
              ELSE -- some other result, prepend with 'UPG_RC_' since that will be the internal name of the lookup.
                  resultout := 'COMPLETE:'||'UPG_RC_'||TO_CHAR(l_Scolumn_value);
              END IF;

          ELSE -- WE SHOULD NEVER COME HERE WHEN THE UPGRADE IS RUNNING. Will return NOTIFIED.
		  resultout := wf_engine.eng_notified||':'||wf_engine.eng_null||':'||wf_engine.eng_null;
          END IF;

          RETURN;
      ELSE  -- Not in upgrade mode, so return NOTIFIED. So that it can be externally completed.

		-- Return Notified
		resultout := wf_engine.eng_notified||':'||wf_engine.eng_null
                ||':'||wf_engine.eng_null;

		RETURN;  -- Order should go thru normal process flow.


      END IF;



  end if; -- End for 'RUN' mode

  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_WF_UPGRADE_UTIL', 'UPGRADE_CUSTOM_ACTIVITY_BLOCK',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END UPGRADE_CUSTOM_ACTIVITY_BLOCK;

-- This procedure is called by the pre-approval(notification) activity to check whether the Order/Line is already
-- past the approval.  If it is then we will transition past the notification activity. If the approval was eligible
-- then we will send out the notification during the upgrade. If the approval was in some pending state (non-passing)
-- then we will re-send out the notification during the upgrade.
PROCEDURE UPGRADE_PRE_APPROVAL(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2 /* file.sql.39 change */
)
IS
l_status VARCHAR2(01);
l_Scolumn_name VARCHAR2(05);
l_Scolumn_value NUMBER;
BEGIN

  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

	 IF OE_STANDARD_WF.G_UPGRADE_MODE THEN  -- Upgrade in progress. Check if Order/Line is already
                                             -- past approval

          -- Find out What S column the approval is based on ...

          l_Scolumn_name := WF_ENGINE.GetActivityAttrText(itemtype, itemkey, actid, 'S_COLUMN');

          l_Scolumn_value := OE_ORDER_UPGRADE_UTIL.Get_entity_Scolumn_value(itemtype, itemkey, l_Scolumn_name);

		-- This activity will have the same look-up as the notification activity with an additional code for
		-- 'NOT_PROCESSED' which will transition to the notification. Runtime, the transitions will be created
		-- appropriately.

          IF (l_Scolumn_value IS NOT NULL) THEN

		  IF (l_Scolumn_value = 18) THEN -- Entity is eligible for Approval, so send out notification.
		      resultout := 'COMPLETE:'||'NOT_PROCESSED';
		  ELSE -- Entity is past approval with some result.
                resultout := 'COMPLETE:'||'UPG_RC_'||TO_CHAR(l_Scolumn_value);
            END IF;

          ELSE -- WE SHOULD NEVER COME HERE WHEN THE UPGRADE IS RUNNING..
		  resultout := 'COMPLETE:'||'NOT_PROCESSED';
          END IF;

          RETURN;

      ELSE  -- Not in upgrade mode, so return 'NOT_PROCESSED', so that the notification goes out.

		resultout := 'COMPLETE:'||'NOT_PROCESSED';

		RETURN;  -- Order/Line should go thru normal process flow.


      END IF;



  end if; -- End for 'RUN' mode

  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_WF_UPGRADE_UTIL', 'UPGRADE_PRE_APPROVAL',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END UPGRADE_PRE_APPROVAL;

PROCEDURE IS_ORDER_PAST_BOOKING(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2 /* file.sql.39 change */
)
IS
l_booked_status VARCHAR2(01);
BEGIN

  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

	 IF OE_STANDARD_WF.G_UPGRADE_MODE THEN  -- Upgrade in progress. Check if Order is already booked.

          OE_HEADER_STATUS_PUB.GET_BOOKED_STATUS(to_number(itemkey), l_booked_status);

     	IF (l_booked_status = 'Y') THEN
              resultout := 'COMPLETE:Y';
          ELSE
              resultout := 'COMPLETE:N'; -- Order will get booked via WF
          END IF;

          RETURN;
      ELSE  -- Not in upgrade mode.

		resultout := 'COMPLETE:N'; -- Order will get booked via WF
		RETURN;  -- Order should go thru normal process flow.


      END IF;



  end if; -- End for 'RUN' mode

  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_WF_UPGRADE_UTIL', 'IS_ORDER_PAST_BOOKING',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END IS_ORDER_PAST_BOOKING;

PROCEDURE IS_LINE_PAST_SHIPPING(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2 /* file.sql.39 change */
)
IS
l_ship_status VARCHAR2(01);
BEGIN

  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

	 IF OE_STANDARD_WF.G_UPGRADE_MODE THEN  -- Upgrade in progress. Check if Order is already shipped.

          OE_Line_Status_Pub.Get_Ship_Status(to_number(itemkey), l_ship_status);

     	IF (l_ship_status = 'Y') THEN
              resultout := 'COMPLETE:Y';
		    update oe_order_lines_all
		    set flow_status_code = decode(source_type_code, 'EXTERNAL', 'SHIPPED', 'SHIPPED')
		    where line_id = to_number(itemkey);
          ELSE
              resultout := 'COMPLETE:N'; -- Order will get booked via WF
              update oe_order_lines_all
              set flow_status_code = decode(source_type_code, 'EXTERNAL', 'AWAITING_RECEIPT', 'AWAITING_SHIPPING')
              where line_id = to_number(itemkey);

          END IF;

          RETURN;
      ELSE  -- Not in upgrade mode.

		resultout := 'COMPLETE:N'; -- Order will get booked via WF
		RETURN;  -- Order should go thru normal process flow.


      END IF;



  end if; -- End for 'RUN' mode

  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_WF_UPGRADE_UTIL', 'IS_LINE_PAST_SHIPPING',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END IS_LINE_PAST_SHIPPING;

PROCEDURE IS_LINE_SHIP_ELIGIBLE(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2 /* file.sql.39 change */
)
IS

	l_source_type_code	varchar2(30);

BEGIN

  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

		select source_type_code
		into   l_source_type_code
		from   oe_order_lines_all
		where  line_id = to_number(itemkey);

	IF	nvl(l_source_type_code,'INTERNAL') = 'EXTERNAL' THEN
		resultout := 'NOTIFIED:#NULL';
          RETURN;
	ELSE
		resultout := 'COMPLETE:#NULL';
          RETURN;

	END IF;



  end if; -- End for 'RUN' mode

  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_WF_UPGRADE_UTIL', 'IS_LINE_PAST_SHIPPING',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END IS_LINE_SHIP_ELIGIBLE;

PROCEDURE IS_RETURN_RECEIVED(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2 /* file.sql.39 change */
)
IS
l_received_status VARCHAR2(1);
BEGIN

  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

	 IF OE_STANDARD_WF.G_UPGRADE_MODE THEN  -- Upgrade in progress. Check if return already shipped

          OE_LINE_STATUS_PUB.GET_RECEIVED_STATUS(to_number(itemkey), l_received_status);

     	IF (l_received_status = 'Y') THEN
              resultout := 'COMPLETE:Y';
		    update oe_order_lines_all
		    set flow_status_code = 'RETURNED'
		    where line_id = to_number(itemkey);
          ELSE
              resultout := 'COMPLETE:N';
              update oe_order_lines_all
              set flow_status_code = 'AWAITING_RETURN'
              where line_id = to_number(itemkey);

          END IF;

          RETURN;
      ELSE  -- Not in upgrade mode.

		resultout := 'COMPLETE:N';
		RETURN;  -- Order should go thru normal process flow.


      END IF;



  end if; -- End for 'RUN' mode

  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_WF_UPGRADE_UTIL', 'IS_RETURN_RECEIVED',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END IS_RETURN_RECEIVED;

PROCEDURE IS_RETURN_INSPECTED(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2 /* file.sql.39 change */
)
IS
l_fulfilled_quantity NUMBER;
l_shipped_quantity NUMBER;
BEGIN

  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

	 IF OE_STANDARD_WF.G_UPGRADE_MODE THEN  -- Upgrade in progress.

		-- Check if return already inspected
          Select shipped_quantity,fulfilled_quantity
		into l_shipped_quantity,l_fulfilled_quantity
		from oe_order_lines_all
		where line_id = to_number(itemkey);


     	IF  (l_shipped_quantity is not NULL and
			l_shipped_quantity = nvl(l_fulfilled_quantity,0))  THEN
              resultout := 'COMPLETE:Y';
          ELSE
              resultout := 'COMPLETE:N';
          END IF;

          RETURN;
      ELSE  -- Not in upgrade mode.

		resultout := 'COMPLETE:N';
		RETURN;  -- Order should go thru normal process flow.


      END IF;



  end if; -- End for 'RUN' mode

  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_WF_UPGRADE_UTIL', 'IS_RETURN_INSPECTED',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END IS_RETURN_INSPECTED;

PROCEDURE IS_LINE_PAST_INVOICING(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2 /* file.sql.39 change */
)
IS
l_invoice_interface_status VARCHAR2(30);
BEGIN

  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

	 IF OE_STANDARD_WF.G_UPGRADE_MODE THEN  -- Upgrade in progress. Check if Order Line is already Invoiced.

          OE_ORDER_UPGRADE_UTIL.Get_Invoice_Status_Code(to_number(itemkey), l_invoice_interface_status);

     	IF (l_invoice_interface_status = 'COMPLETE') THEN
              resultout := 'COMPLETE:COMPLETE';
		    update oe_order_lines_all
		    set flow_status_code = 'INVOICED'
		    where line_id = to_number(itemkey);
          ELSIF (l_invoice_interface_status = 'NOT_ELIGIBLE') THEN
              resultout := 'COMPLETE:NOT_ELIGIBLE';
          ELSIF (l_invoice_interface_status = 'RFR-PENDING' OR
			  l_invoice_interface_status = 'MANUAL-PENDING') THEN
              resultout := 'COMPLETE:PRTL_COMPLETE';
              update oe_order_lines_all
              set flow_status_code = 'INVOICED_PARTIAL'
              where line_id = to_number(itemkey);

          ELSE
              resultout := 'COMPLETE:INCOMPLETE'; -- Line will get Invoice Interfaced via WF
          END IF;

          RETURN;
      ELSE  -- Not in upgrade mode.

		resultout := 'COMPLETE:INCOMPLETE'; -- Order Line will get Invoiced via WF
		RETURN;  -- Order Line should go thru normal process flow.


      END IF;



  end if; -- End for 'RUN' mode

  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_WF_UPGRADE_UTIL', 'IS_LINE_PAST_INVOICING',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END IS_LINE_PAST_INVOICING;

PROCEDURE IS_ORDER_CLOSED(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2 /* file.sql.39 change */
)
IS
l_closed_status		VARCHAR2(1);
BEGIN

  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

	 IF OE_STANDARD_WF.G_UPGRADE_MODE THEN  -- Upgrade in progress. Check if Order is already closed.

          OE_HEADER_STATUS_PUB.GET_CLOSED_STATUS(to_number(itemkey), l_closed_status);

     	IF (l_closed_status = 'Y') THEN
              resultout := 'COMPLETE:Y';
          ELSE
              resultout := 'COMPLETE:N'; -- Order will be closed via WF
          END IF;

          RETURN;
      ELSE  -- Not in upgrade mode.

		resultout := 'COMPLETE:N'; -- Order will be closed via WF
		RETURN;  -- Order should go thru normal process flow.


      END IF;



  end if; -- End for 'RUN' mode

  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_WF_UPGRADE_UTIL', 'IS_ORDER_CLOSED',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END IS_ORDER_CLOSED;

PROCEDURE IS_LINE_CLOSED(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2 /* file.sql.39 change */
)
IS
l_closed_status		VARCHAR2(1);
BEGIN

  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

	 IF OE_STANDARD_WF.G_UPGRADE_MODE THEN  -- Upgrade in progress. Check if Order Line is already closed.

          OE_LINE_STATUS_PUB.GET_CLOSED_STATUS(to_number(itemkey), l_closed_status);

     	IF (l_closed_status = 'Y') THEN
              resultout := 'COMPLETE:Y';
          ELSE
              resultout := 'COMPLETE:N'; -- Order Line will be closed via WF
          END IF;

          RETURN;
      ELSE  -- Not in upgrade mode.

		resultout := 'COMPLETE:N'; -- Order Line will be closed via WF
		RETURN;  -- Order Line should go thru normal process flow.


      END IF;



  end if; -- End for 'RUN' mode

  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_WF_UPGRADE_UTIL', 'IS_LINE_CLOSED',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END IS_LINE_CLOSED;

/* --------------------------------------------------------------------
Procedure Name  : IS_LINE_PAST_DEMAND_IFACE
Description     : This procedure checks the demand interface cycle status
                  of the old line.If the status is eligible, it returns
                  "NO". If the status is interfaced, it returns "YES"

----------------------------------------------------------------------- */

PROCEDURE IS_LINE_PAST_DEMAND_IFACE(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2 /* file.sql.39 change */
)
IS
l_schedule_status  NUMBER;
BEGIN

   -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

      IF OE_STANDARD_WF.G_UPGRADE_MODE
      THEN
          -- Upgrade in progress. Check if Order Line is already closed.

          OE_ORDER_UPGRADE_UTIL.GET_DEMAND_INTERFACE_STATUS
              (to_number(itemkey), l_schedule_status);

          IF (l_schedule_status = RES_ELIGIBLE) THEN
             -- Order Line will be scheduled via WF
             resultout := 'COMPLETE:N';
          ELSE
             resultout := 'COMPLETE:Y';
             update oe_order_lines_all
		   set flow_status_code = 'SCHEDULED'
		   where line_id = to_number(itemkey);
          END IF;

          RETURN;
        ELSE  -- Not in upgrade mode.

          resultout := 'COMPLETE:N'; -- Order Line will be scheduled via WF
          RETURN;  -- Order Line should go thru normal process flow.

      END IF;


  end if; -- End for 'RUN' mode

  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_WF_UPGRADE_UTIL', 'IS_LINE_CLOSED',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END IS_LINE_PAST_DEMAND_IFACE;

/* --------------------------------------------------------------------
Procedure Name  : CHK_MFG_RELEASE_STS
Description     : This procedure checks the manufacturing release cycle status
                  of the old line. The way it returns results is as follows:
                  Only ATO Model line and ATO Item line would have reached
                  the workflow function where this API is called. And the only
                  status of manufacturing release we are supporing for these
                  two item types is ELIGIBLE and WORK_ORDER_COMPLETE (this
                  item types will never be NOT_APPLICABLE)


                  Cycle-Status             Resultout
                  ------------             ------------
                  Eligible                 ELIGIBLE
                  Work-Order Complete      WORK_ORDER_COMPLETE
----------------------------------------------------------------------- */

PROCEDURE CHK_MFG_RELEASE_STS(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2 /* file.sql.39 change */
)
IS
l_mfg_release_status  NUMBER;
l_item_type_code      VARCHAR2(30);
l_ato_line_id         NUMBER;
BEGIN

  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

      IF OE_STANDARD_WF.G_UPGRADE_MODE
      THEN
          -- Upgrade in progress. Check if Order Line is already closed.

          OE_ORDER_UPGRADE_UTIL.GET_MFG_RELEASE_STATUS
                             (to_number(itemkey), l_mfg_release_status);

          IF (l_mfg_release_status = RES_ELIGIBLE) THEN
             resultout := 'COMPLETE:ELIGIBLE';
             -- no change in flow status here

          ELSIF (l_mfg_release_status = RES_WORK_ORDER_COMPLETED) THEN
             resultout := 'COMPLETE:WORK_ORDER_COMPLETE';

              SELECT item_type_code, ato_line_id
              INTO   l_item_type_code, l_ato_line_id
              FROM   OE_ORDER_LINES_ALL
              WHERE  line_id = to_number(itemkey);

              IF l_ato_line_id = to_number(itemkey) AND
                 (l_item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
                  l_item_type_code = OE_GLOBALS.G_ITEM_CLASS)
              THEN
                update oe_order_lines_all
                set flow_status_code =  'BOOKED'
                where line_id = to_number(itemkey);
              ELSE
                update oe_order_lines_all
                set flow_status_code =  'PRODUCTION_COMPLETE'
                where line_id = to_number(itemkey);
              END IF;

          ELSE
             -- CODE SHOULD NEVER COME HERE
             resultout := 'COMPLETE:ELIGIBLE';
             -- no update of flow status code
          END IF;

          RETURN;
        ELSE  -- Not in upgrade mode.

          resultout := 'COMPLETE:ELIGIBLE';
          RETURN;

      END IF;

  end if; -- End for 'RUN' mode

  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_WF_UPGRADE_UTIL', 'IS_LINE_CLOSED',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END;


/* --------------------------------------------------------------------
Procedure Name  : IS_LINE_PAST_MFG_RELEASE
Description     : This procedure checks the manufacturing release cycle status
                  of the old line. The way it returns results is as follows:

                  Cycle-Status         Resultout
                  ------------         ------------
                  Not-Applicable       Yes
                  Eligible             Yes - But is actually not applicable
                                             (like service lines).
                                       Yes - is an ATO class or ATO option
                                       No  - is an ATO model or ATO Item
                  Work-Order Complete  Yes - For ATO model and ATO item
                                             which are shipped.
                                       No  - For ATO model and ATO item
                                             which are not shipped.

                  We do not need to update flow status here.
                  A check later will do it. ex: chk_mfg_release_status
                  will update the status.
----------------------------------------------------------------------- */

PROCEDURE IS_LINE_PAST_MFG_RELEASE(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2 /* file.sql.39 change */
)
IS
l_mfg_release_status NUMBER;
l_ato_line_id        NUMBER;
l_shipped_quantity   NUMBER;
BEGIN

  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

      IF OE_STANDARD_WF.G_UPGRADE_MODE
      THEN
          -- Upgrade in progress. Check if Order Line is already closed.

          OE_ORDER_UPGRADE_UTIL.GET_MFG_RELEASE_STATUS
                             (to_number(itemkey), l_mfg_release_status);

          IF (l_mfg_release_status = RES_NOT_APPLICABLE) THEN
             resultout := 'COMPLETE:Y';
          ELSE
             SELECT ato_line_id,shipped_quantity
             INTO   l_ato_line_id,l_shipped_quantity
             FROM oe_order_lines_all
             WHERE line_id = to_number(itemkey);

             IF l_ato_line_id = to_number(itemkey) THEN
                -- Only ATO Models and ATO Items will have case
                IF l_shipped_quantity is not null THEN
                    resultout := 'COMPLETE:Y';
                ELSE
                   -- The line is not shipped and it is and ATO model or ATO
                   -- item. This is the only case we will progress forward
                   -- in the ATO processing.
                    resultout := 'COMPLETE:N';
                END IF;
             ELSE
               resultout := 'COMPLETE:Y';
             END IF;
          END IF;

          RETURN;
        ELSE  -- Not in upgrade mode.

          -- Line which reach here, were upgraded but came to manufacturing
          -- release activity after the upgrade. We need to check if the item
          -- on the line is an ATO item or model. If it is, then complete
          -- the activity with 'N'.

          SELECT ato_line_id
          INTO   l_ato_line_id
          FROM   OE_ORDER_LINES_ALL
          WHERE  line_id = to_number(itemkey);

          IF l_ato_line_id = to_number(itemkey) THEN

             -- Only ATO Models and ATO Items will have this case
             resultout := 'COMPLETE:N';

          ELSE

             resultout := 'COMPLETE:Y';

          END IF;

          RETURN;

      END IF;

  end if; -- End for 'RUN' mode

  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_WF_UPGRADE_UTIL', 'IS_LINE_CLOSED',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END;


/* --------------------------------------------------------------------
Procedure Name  : IS_LINE_ATO_MODEL
Description     : This procedure returns the result of "YES", if the line
                  is an ATO Model and No if the line is an ATO Item.
                  This procedure will be called only for these 2 types of
                  items in the upgrade of manufacturing release process.

----------------------------------------------------------------------- */

PROCEDURE IS_LINE_ATO_MODEL(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2 /* file.sql.39 change */
)
IS
l_ato_line_id        NUMBER;
l_item_type_code     VARCHAR2(30);
BEGIN

  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

      -- Condition Removed for 2974151

          SELECT ato_line_id,item_type_code
          INTO l_ato_line_id,l_item_type_code
          FROM oe_order_lines_all
          WHERE line_id = to_number(itemkey);

          IF l_ato_line_id = to_number(itemkey) AND
             (l_item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
              l_item_type_code = OE_GLOBALS.G_ITEM_CLASS)
          THEN
             resultout := 'COMPLETE:Y';
          ELSE
             resultout := 'COMPLETE:N';
          END IF;

          RETURN;


  end if; -- End for 'RUN' mode

  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_WF_UPGRADE_UTIL', 'IS_LINE_CLOSED',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END;

/* --------------------------------------------------------------------
Procedure Name  : IS_MODE_UPGRADE
Description     : This procedure returns the result of "YES", if the
			   global OE_STANDARD_WF.G_UPGRADE_MODE is set to TRUE.
                  We use this for the config item flow.

----------------------------------------------------------------------- */

PROCEDURE IS_MODE_UPGRADE(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2 /* file.sql.39 change */
)
IS
l_ato_line_id        NUMBER;
l_item_type_code     NUMBER;
BEGIN

  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

      IF OE_STANDARD_WF.G_UPGRADE_MODE
      THEN
          resultout := 'COMPLETE:Y';
          RETURN;
      ELSE
          resultout := 'COMPLETE:N';
          RETURN;
      END IF;

  end if; -- End for 'RUN' mode

  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_WF_UPGRADE_UTIL', 'IS_LINE_CLOSED',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END;

/* --------------------------------------------------------------------
Procedure Name  : CHECK_PUR_REL_STATUS
Description     : This procedure checks the purchase release cycle status
                  of the old line.It returns results as following:
                  Cycle Status     Resultout
                  ------------     ---------
                  Eligible          Eligible
                  Interfaced        Interfaced
                  Confirmed         Confirmed
                  Partial           For the unshipped line: Interfaced
                                    For the shipped line : Confirmed.
                  When the result is partial, the line was split into 2 lines
                  in the new system.

                  Not Applicable    NOTIFIED
                  NULL              NOTIFIED. The activity calling this
                                    API will stay in the notified status

----------------------------------------------------------------------- */

PROCEDURE CHECK_PUR_REL_STATUS(
	itemtype  in varchar2,
	itemkey   in varchar2,
	actid     in number,
	funcmode  in varchar2,
	resultout in out nocopy varchar2 /* file.sql.39 change */
)
IS
l_pur_release_status NUMBER;
l_source_type VARCHAR2(30); ---5247444
BEGIN

  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

      IF OE_STANDARD_WF.G_UPGRADE_MODE
      THEN
          -- Upgrade in progress. Check if Order Line is already closed.

          OE_ORDER_UPGRADE_UTIL.Get_Pur_Rel_Status
                             (to_number(itemkey), l_pur_release_status);

          IF (l_pur_release_status = RES_ELIGIBLE) THEN
             resultout := 'COMPLETE:ELIGIBLE';
          ELSIF (l_pur_release_status = RES_CONFIRMED) THEN
             resultout := 'COMPLETE:CONFIRMED';
          ELSIF (l_pur_release_status = RES_INTERFACED) THEN
             resultout := 'COMPLETE:INTERFACED';
       --Bug2432009
          /*ELSIF (l_pur_release_status = RES_FAIL_NOT_APPLICABLE) THEN
	     resultout := 'COMPLETE:CONFIRMED';
             Commented for the bug#5247444 */
          ELSIF (l_pur_release_status is null) THEN
           /* added for bug fix 5247444 */
             select source_type_code
             into l_source_type
             from oe_order_lines_all
             where line_id = to_number(itemkey);
             IF l_source_type = 'INTERNAL' THEN
               resultout := wf_engine.eng_notified||':'||wf_engine.eng_null||':'||wf_engine.eng_null;  -- block workflow
             ELSE
               resultout := 'COMPLETE:ELIGIBLE';
             END IF;
             /* end 5247444 */

             /* resultout := 'COMPLETE:ELIGIBLE'; This was replaced by the code just above for bug fix 5247444 */
          ELSE
             resultout := wf_engine.eng_notified||':'||wf_engine.eng_null||':'||wf_engine.eng_null;
          END IF;

          RETURN;
        ELSE  -- Not in upgrade mode.

          resultout := 'COMPLETE:ELIGIBLE';
          RETURN;

      END IF;


  end if; -- End for 'RUN' mode

  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_WF_UPGRADE_UTIL', 'IS_LINE_CLOSED',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END CHECK_PUR_REL_STATUS;

END OE_WF_UPGRADE_UTIL;

/
