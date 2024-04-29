--------------------------------------------------------
--  DDL for Package Body OE_SERVICE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SERVICE_WF" As
/* $Header: OEXSVWFB.pls 120.0 2005/06/01 01:30:46 appldev noship $ */


PROCEDURE Set_Line_Service_Credit(
	itemtype  in varchar2,
    	itemkey   in varchar2,
    	actid     in number,
    	funcmode  in varchar2,
    	resultout in out NOCOPY /* file.sql.39 change */ varchar2)
IS

l_line_id  		NUMBER;
l_return_status		VARCHAR2(30);
l_result_out		VARCHAR2(240);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);
l_credit_type        	VARCHAR2(30);
l_serviceable_flag      VARCHAR2(30);

BEGIN

  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

    OE_STANDARD_WF.Set_Msg_Context(actid);

    l_line_id  	:= to_number(itemkey);

  -- Get Workflow Activity Attribute Service Credit Type.
    l_credit_type := wf_engine.GetActivityAttrText(itemtype,itemkey, actid,'SERVICE_CREDIT_TYPE');

    SELECT NVL(m.serviceable_product_flag, 'N')
    INTO  l_serviceable_flag
    FROM   oe_order_lines l,
           mtl_system_items m
    WHERE  l.line_id = l_line_id
    AND	   l.inventory_item_id = m.inventory_item_id
    AND    m.organization_id = to_number(OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID'));

    If NVL(l_serviceable_flag, 'N')= 'Y' Then
      Update oe_order_lines_all
      Set service_credit_eligible_code = l_credit_type
      Where line_id=l_line_id;

    Else
      Update oe_order_lines_all
      Set service_credit_eligible_code = 'NONE'
      Where line_id=l_line_id;

    End If;

    resultout := 'COMPLETE';
    OE_STANDARD_WF.Clear_Msg_Context;
    return;

  end if; -- End for 'RUN' mode

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
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
    wf_core.context('OE_Service_WF', ' Set_Line_Service_Credit',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;
END Set_Line_Service_Credit;

END OE_SERVICE_WF;

/
