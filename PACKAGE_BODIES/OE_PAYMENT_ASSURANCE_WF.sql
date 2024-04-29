--------------------------------------------------------
--  DDL for Package Body OE_PAYMENT_ASSURANCE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PAYMENT_ASSURANCE_WF" as
/* $Header: OEXWMPMB.pls 120.1 2005/07/15 03:59:56 pviprana noship $ */

PROCEDURE Start_Payment_Assurance(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
IS
l_line_id  		NUMBER;
l_exists_prepay		VARCHAR2(1) := 'N';
l_return_status	VARCHAR2(30);
l_result_out		VARCHAR2(240);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

        --Exception Management begin
        l_header_id NUMBER;
        l_order_source_id 	         NUMBER;
        l_orig_sys_document_ref          VARCHAR2(50);
        l_orig_sys_line_ref              VARCHAR2(50);
        l_orig_sys_shipment_ref          VARCHAR2(50);
        l_change_sequence                VARCHAR2(50);
        l_source_document_type_id        NUMBER;
        l_source_document_id             NUMBER;
        l_source_document_line_id        NUMBER;
        --Exception Management end

BEGIN

  --
  -- RUN mode - normal process execution
  --

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING OE_Payment_Assurance_WF.Start_Payment_Assurance '||ITEMTYPE||'/'||ITEMKEY , 1 ) ;
  END IF;

  IF NOT OE_PREPAYMENT_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OEXWMPMB: multiple payments is not enabled. ', 3 ) ;
    END IF;
    resultout := 'COMPLETE:NOT_ELIGIBLE';
    return;
  END IF;

  IF (funcmode = 'RUN') then
    OE_STANDARD_WF.Set_Msg_Context(actid);
    l_line_id  	:= to_number(itemkey);



    BEGIN
      SELECT 'Y',
             ool.header_id,
             ool.ORDER_SOURCE_ID,
             ool.ORIG_SYS_DOCUMENT_REF,
             ool.ORIG_SYS_LINE_REF,
             ool.ORIG_SYS_SHIPMENT_REF,
             ool.CHANGE_SEQUENCE,
             ool.SOURCE_DOCUMENT_TYPE_ID,
             ool.SOURCE_DOCUMENT_ID,
             ool.SOURCE_DOCUMENT_LINE_ID
      INTO   l_exists_prepay,
             l_header_id,
             l_order_source_id,
             l_orig_sys_document_ref,
             l_orig_sys_line_ref,
             l_orig_sys_shipment_ref,
             l_change_sequence,
             l_source_document_type_id,
             l_source_document_id,
             l_source_document_line_id
      FROM   oe_payments op
            ,oe_order_lines_all ool
      WHERE  op.payment_collection_event = 'PREPAY'
      AND    op.header_id = ool.header_id
      AND    ool.line_id = l_line_id
      AND    rownum = 1;

          -- Exception Management begin Set message context
           OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'LINE'
          ,p_entity_id                  => l_line_id
          ,p_header_id                  => l_header_id
          ,p_line_id                    => l_line_id
          ,p_order_source_id            => l_order_source_id
          ,p_orig_sys_document_ref      => l_orig_sys_document_ref
          ,p_orig_sys_document_line_ref => l_orig_sys_line_ref
          ,p_orig_sys_shipment_ref      => l_orig_sys_shipment_ref
          ,p_change_sequence            => l_change_sequence
          ,p_source_document_type_id    => l_source_document_type_id
          ,p_source_document_id         => l_source_document_id
          ,p_source_document_line_id    => l_source_document_line_id );
          --Exception Management end

    EXCEPTION WHEN NO_DATA_FOUND THEN

         SELECT
             ool.header_id,
             ool.ORDER_SOURCE_ID,
             ool.ORIG_SYS_DOCUMENT_REF,
             ool.ORIG_SYS_LINE_REF,
             ool.ORIG_SYS_SHIPMENT_REF,
             ool.CHANGE_SEQUENCE,
             ool.SOURCE_DOCUMENT_TYPE_ID,
             ool.SOURCE_DOCUMENT_ID,
             ool.SOURCE_DOCUMENT_LINE_ID
      INTO
             l_header_id,
             l_order_source_id,
             l_orig_sys_document_ref,
             l_orig_sys_line_ref,
             l_orig_sys_shipment_ref,
             l_change_sequence,
             l_source_document_type_id,
             l_source_document_id,
             l_source_document_line_id
      FROM OE_ORDER_LINES_ALL ool
      where ool.line_id = l_line_id;

                -- Exception Management begin Set message context
           OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'LINE'
          ,p_entity_id                  => l_line_id
          ,p_header_id                  => l_header_id
          ,p_line_id                    => l_line_id
          ,p_order_source_id            => l_order_source_id
          ,p_orig_sys_document_ref      => l_orig_sys_document_ref
          ,p_orig_sys_document_line_ref => l_orig_sys_line_ref
          ,p_orig_sys_shipment_ref      => l_orig_sys_shipment_ref
          ,p_change_sequence            => l_change_sequence
          ,p_source_document_type_id    => l_source_document_type_id
          ,p_source_document_id         => l_source_document_id
          ,p_source_document_line_id    => l_source_document_line_id );
          --Exception Management end


    END;

    --pnpl should not exit if Installment Options is 'ENABLE_PAY_NOW'
    IF l_exists_prepay = 'N' AND
       OE_PREPAYMENT_UTIL.Get_Installment_Options <> 'ENABLE_PAY_NOW' THEN
      OE_STANDARD_WF.Clear_Msg_Context;
      resultout := 'COMPLETE:NOT_ELIGIBLE';
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('OEXWMPMB: there is no prepayment on this order. ', 3 ) ;
      END IF;
      RETURN;
    END IF;

    -- check for generic and payment assurance activity specific hold
    OE_HOLDS_PUB.CHECK_HOLDS(p_api_version => 1.0,
                     p_line_id => l_line_id,
                     p_wf_item => OE_GLOBALS.G_WFI_LIN,
                     p_wf_activity => 'PAYMENT_ASSURANCE_ACT',
                     x_result_out => l_result_out,
                     x_return_status => l_return_status,
                     x_msg_count => l_msg_count,
                     x_msg_data => l_msg_data);

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXWMPMB: return_status after calling Check_Holds is: '||l_return_status, 3 ) ;
      oe_debug_pub.add(  'OEXWMPMB, result_out after calling Check_Holds is: '||l_result_out, 3 ) ;
    END IF;

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       OE_STANDARD_WF.Save_Messages;
       OE_STANDARD_WF.Clear_Msg_Context;
       resultout := 'INCOMPLETE';
       RETURN;
    ELSIF (l_result_out = FND_API.G_TRUE ) THEN
       resultout := 'ON_HOLD';
       OE_Order_WF_Util.Update_Flow_Status_Code
		(p_line_id  		=> l_line_id,
		 p_flow_status_code  	=> 'PAYMENT_ASSURANCE_HOLD',
	 	 x_return_status  	=> l_return_status);

       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('OEXWMPMB: return status from update_flow_status_code '||l_return_status , 3 ) ;
       END IF;
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       OE_STANDARD_WF.Clear_Msg_Context;
       RETURN;
    END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'Start_Payment_Assurance , line_id is: '||l_line_id, 1 ) ;
  END IF;

    OE_PrePayment_Pvt.Process_Payment_Assurance
			( p_api_version_number	=> 1.0
			, p_line_id  		=> l_line_id
			, p_activity_id		=> actid
			, p_exists_prepay       => l_exists_prepay
			, x_result_out		=> resultout
			, x_return_status	=> l_return_status
			, x_msg_count		=> l_msg_count
			, x_msg_data		=> l_msg_data
			);

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
      OE_STANDARD_WF.Clear_Msg_Context;
      return;
    ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- start data fix project
      -- OE_STANDARD_WF.Save_Messages;
      -- OE_STANDARD_WF.Clear_Msg_Context;
      -- end data fix project
      app_exception.raise_exception;
    END IF;


  END IF; -- End for 'RUN' mode

  -- CANCEL mode - activity 'compensation'
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  IF (funcmode = 'CANCEL') THEN
     -- your cancel code goes here
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null

Exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_Payment_Assurance_WF', 'Payment_Assurance_Act',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END Start_Payment_Assurance;


Procedure Payment_Receipt(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
IS

  l_header_id  Number;
l_return_status VARCHAR2(30);
l_result_out            VARCHAR2(240);

l_msg_count             NUMBER;

l_msg_data              VARCHAR2(2000);

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
  If l_debug_level > 0 Then
   oe_debug_pub.add('Entering OE_Payment_Assurance_WF.Payment_Receipt');
  End If;
  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') then
    OE_STANDARD_WF.Set_Msg_Context(actid);
    l_header_id   := to_number(itemkey);
    OE_PrePayment_PVT.Print_Payment_Receipt(l_header_id,l_result_out,l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- start data fix project
      -- OE_STANDARD_WF.Save_Messages;
      -- OE_STANDARD_WF.Clear_Msg_Context;
      -- end data fix project
      -- COMMIT;
      app_exception.raise_exception;
    ELSE
      OE_STANDARD_WF.Save_Messages(p_instance_id => actid);
    END IF;

    resultout := l_result_out;
    OE_STANDARD_WF.Clear_Msg_Context;
    return;

  END IF; -- End for 'RUN' mode

-- start data fix project
Exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_Payment_Assurance_WF', 'Payment_Receipt',
                    itemtype, itemkey, to_char(actid), funcmode);
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    raise;
    -- end data fix project

end Payment_Receipt;

END OE_Payment_Assurance_WF;


/
