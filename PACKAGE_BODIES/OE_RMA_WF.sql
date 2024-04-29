--------------------------------------------------------
--  DDL for Package Body OE_RMA_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_RMA_WF" as
/* $Header: OEXWRMAB.pls 120.0.12010000.3 2010/02/24 12:30:42 nshah ship $ */

-- PROCEDURE Create_Outbound_Shipment
--
-- <describe the activity here>
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_RMA_WF';
procedure Create_Outbound_Shipment(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2 /* file.sql.39 change */
)
is
l_line_id		number;
l_workflow_status varchar2(30);
l_result_out      number; --varchar2(30);
l_msg_count       NUMBER := 0;
l_msg_data        VARCHAR2(240);
x_return_status               VARCHAR2(30);
x_msg_count                   NUMBER;
x_msg_data                    VARCHAR2(240);
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_old_line_tbl                OE_Order_PUB.Line_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_rec        OE_Order_PUB.Header_Scredit_Rec_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_rec                  OE_Order_PUB.Line_Rec_Type;
l_x_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_rec          OE_Order_PUB.Line_Scredit_Rec_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_Lot_Serial_tbl	          OE_Order_PUB.Lot_Serial_Tbl_Type;
l_x_Header_price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_x_Line_price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
l_x_Action_Request_tbl        OE_Order_PUB.Request_Tbl_Type;
--serla begin
l_x_Header_Payment_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
l_x_Line_Payment_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
--serla end
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_RMA_WF.CREATE_OUTBOUND_SHIPMENT' , 1 ) ;
    END IF;

    -- your run code goes here

    --  l_result_out := 'COMPLETE:NULL';
    l_result_out := 0;
    l_line_id := to_number(itemkey);

    OE_Line_Util.Query_Rows
    (  p_line_id 		=> l_line_id
    ,  x_line_tbl		=> l_old_line_tbl
    );
   l_line_tbl(1).line_id := FND_API.G_MISS_NUM;
   l_line_tbl(1).line_type_id := FND_API.G_MISS_NUM;
   l_line_tbl(1).shipment_number := FND_API.G_MISS_NUM;
   l_old_line_tbl(1).db_flag := FND_API.G_TRUE;
   l_line_tbl(1).db_flag := FND_API.G_FALSE;

   --  Set Operation.
   l_line_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;

   --  Set control flags.

   l_control_rec.controlled_operation := TRUE;
   l_control_rec.validate_entity      := TRUE;
   l_control_rec.write_to_DB          := TRUE;

   l_control_rec.default_attributes   := TRUE;
   l_control_rec.change_attributes    := TRUE;
   l_control_rec.clear_dependents     := TRUE;

   --  Instruct API to retain its caches

   l_control_rec.clear_api_cache      := FALSE;
   l_control_rec.clear_api_requests   := FALSE;

   --  Call OE_Order_PVT.Process_order

   OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_line_tbl                  => l_line_tbl
    ,   p_old_line_tbl                => l_old_line_tbl
    ,   p_x_header_rec                => l_x_header_rec
    ,   p_x_Header_Adj_tbl            => l_x_Header_Adj_tbl
    ,   p_x_header_price_att_tbl      => l_x_header_price_att_tbl
    ,   p_x_Header_Adj_att_tbl        => l_x_Header_Adj_att_tbl
    ,   p_x_Header_Adj_Assoc_tbl      => l_x_Header_Adj_Assoc_tbl
    ,   p_x_Header_Scredit_tbl        => l_x_Header_Scredit_tbl
--serla begin
    ,   p_x_Header_Payment_tbl          => l_x_Header_Payment_tbl
--serla end
    ,   p_x_Line_Adj_tbl              => l_x_Line_Adj_tbl
    ,   p_x_Line_Price_att_tbl        => l_x_Line_Price_att_tbl
    ,   p_x_Line_Adj_att_tbl          => l_x_Line_Adj_att_tbl
    ,   p_x_Line_Adj_Assoc_tbl        => l_x_Line_Adj_Assoc_tbl
    ,   p_x_Line_Scredit_tbl          => l_x_Line_Scredit_tbl
--serla begin
    ,   p_x_Line_Payment_tbl            => l_x_Line_Payment_tbl
--serla end
    ,   p_x_Lot_Serial_tbl            => l_x_Lot_Serial_tbl
    ,   p_x_action_request_tbl        => l_x_Action_Request_tbl
    );

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --  Load OUT parameters.

    l_x_line_rec := l_line_tbl(1);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING CALCULATE TAX' , 2 ) ;
    END IF;
   -- Calculate Tax

   -- Commented out the call as the line tax is now calculated as a delayed
   -- request in process_order API.
    /*
    If OE_GLOBALS.G_TAX_FLAG = 'Y' THEN
        OE_Delayed_Requests_UTIL.Tax_Line (x_return_status
                                        ,  l_x_line_rec
                                        ,  l_x_line_rec
                                        );
    oe_debug_pub.add('Calling Update Row', 2);
        OE_Line_Util.Update_Row (l_x_line_rec);
        OE_GLOBALS.G_TAX_FLAG := 'N';
    END IF;
    */

    -- example completion
    --    resultout := l_result_out;
    IF (x_return_status = FND_API.G_RET_STS_SUCCESS)
    THEN
      resultout := 'COMPLETE:PASS';
    ELSE
      resultout := 'COMPLETE:FAIL';
    END IF;
    return;
  end if;


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
  resultout := '';
  return;
EXCEPTION
  WHEN OTHERS THEN
    -- in the case of an exception.
    wf_core.context('OE_RMA_WF', 'CREATE_OUTBOUND_SHIPMENT',
		    itemtype, itemkey, to_char(actid), funcmode);
    raise;
end Create_Outbound_Shipment;

procedure Is_Return_Line(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2 /* file.sql.39 change */
)
is
l_category_code VARCHAR2(30);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
	IF itemtype = OE_GLOBALS.G_WFI_LIN THEN
         l_category_code := wf_engine.GetItemAttrText(OE_GLOBALS.G_WFI_LIN,
					   itemkey, 'LINE_CATEGORY');
          IF l_category_code = 'RETURN' THEN
		resultout := 'COMPLETE:Y';
          ELSE
		resultout := 'COMPLETE:N';
	  END IF;
        ELSE
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          -- item type is not a line
	END IF;
Exception
  when others then
   wf_core.context('OE_RMA_WF', 'Is_Return_Line',
                    itemtype, itemkey, to_char(actid), funcmode);
   raise;
END Is_Return_Line;

procedure Is_Line_Receivable(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2 /* file.sql.39 change */
)
is
l_shippable_flag VARCHAR2(1);
l_transactable_flag VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


  if (funcmode = 'RUN') then

 -- Check if the item is shippable or transactable

	IF itemtype = OE_GLOBALS.G_WFI_LIN THEN

  		SELECT DECODE(l.shippable_flag,NULL,m.shippable_item_flag ,
				    l.shippable_flag),
			  mtl_transactions_enabled_flag
		INTO l_shippable_flag,l_transactable_flag
  		FROM mtl_system_items m, oe_order_lines_all l
  		WHERE m.inventory_item_id = l.inventory_item_id
  		AND l.line_id = to_number(itemkey)
  		AND m.organization_id = l.ship_from_org_id;

          IF nvl(l_shippable_flag,'N') = 'Y' AND
				nvl(l_transactable_flag,'N') = 'Y' THEN
			resultout := 'COMPLETE:Y';
          ELSE
			resultout := 'COMPLETE:N';
	  	END IF;
     ELSE
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          -- item type is not a line
	END IF;

     return;

   END IF; -- End for 'RUN' mode


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


Exception
  when others then
   wf_core.context('OE_RMA_WF', 'Is_Line_Receivable',
                    itemtype, itemkey, to_char(actid), funcmode);
   raise;
END Is_Line_Receivable;


procedure Wait_For_Receiving(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2 /* file.sql.39 change */
)
is
l_category_code 	VARCHAR2(30);
l_return_status     VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING OE_RMA_WF.WAIT_FOR_RECEIVING '||ITEMTYPE||'/' ||ITEMKEY , 1 ) ;
END IF;


  IF (funcmode = 'RUN') then

	IF itemtype = OE_GLOBALS.G_WFI_LIN THEN

          Is_Line_Receivable(itemtype,
						itemkey,
						actid,
						funcmode,
						resultout);

          IF resultout = 'COMPLETE:Y' THEN
			resultout := 'NOTIFIED';

			OE_STANDARD_WF.Set_Msg_Context(actid);

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'CALLING FLOW STATUS API ' , 1 ) ;
			END IF;

			IF OE_STANDARD_WF.G_UPGRADE_MODE <> TRUE THEN

          	    OE_Order_WF_Util.Update_Flow_Status_Code
                    (p_line_id               =>   to_number(itemkey),
                     p_flow_status_code      =>   'AWAITING_RETURN',
                     x_return_status         =>   l_return_status
                     );
				                IF l_debug_level  > 0 THEN
				                    oe_debug_pub.add(  'RETURN STATUS FROM FLOW STATUS API '|| L_RETURN_STATUS , 1 ) ;
				                END IF;
                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          		    -- start data fix project
                            -- OE_STANDARD_WF.Save_Messages;
          		    -- OE_STANDARD_WF.Clear_Msg_Context;
          		    -- end data fix project
          		    app_exception.raise_exception;
     		    END IF;
               ELSE
                   UPDATE OE_ORDER_LINES_ALL
			    SET flow_status_code = 'AWAITING_RETURN'
			    WHERE line_id = to_number(itemkey);

			END IF;

                OE_STANDARD_WF.Clear_Msg_Context;

          ELSE
			resultout := 'COMPLETE:NOT_ELIGIBLE';
	  	END IF;
     ELSE
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          -- item type is not a line
	END IF;

     return;

  END IF; -- End for 'RUN' mode


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

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXITING OE_RMA_WF.WAIT_FOR_RECEIVING ' , 1 ) ;
END IF;

Exception
  when others then
   wf_core.context('OE_RMA_WF', 'Wait_For_Receiving',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
   raise;
END Wait_For_Receiving;

/* 6629220: Start
 * Following procedures added to update flow status codes
 * 1. UPD_FLOW_STATUS_CODE_REJ
 * 2. UPD_FLOW_STATUS_CODE_MIX_REJ
 * Changes in one procedure may be needed in the other procedure also.
 * Because both procedures performs same action of updating flow status
 * code.
 */
PROCEDURE UPD_FLOW_STATUS_CODE_REJ(
 itemtype 	IN 	VARCHAR2
,itemkey 	IN 	VARCHAR2
,actid 	IN 	NUMBER
,funcmode 	IN 	VARCHAR2
,resultout 	IN OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
) AS
  l_return_status VARCHAR2(1);
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

  CURSOR return_lines IS
  SELECT line_id,wias.item_type,wias.item_key
  FROM oe_order_lines l
      ,WF_ITEM_ACTIVITY_STATUSES WIAS
      ,WF_PROCESS_ACTIVITIES WPA
  WHERE l.header_id = To_Number(itemkey)
  AND l.line_category_code = 'RETURN'
  AND l.open_flag = 'Y'
  AND WIAS.item_type = 'OEOL'
  AND WIAS.item_key = To_Char(l.line_id)
  AND WPA.instance_id = WIAS.process_activity
  AND WIAS.activity_status = 'NOTIFIED'
  AND WPA.activity_name = 'APPROVE_WAIT_FOR_H';
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OEXWRMAB: ENTERING UPD_FLOW_STATUS_CODE_REJ, '
                    ||'ITEM TYPE/KEY: '||itemtype||'/'||itemkey);
  END IF;
  oe_order_wf_util.update_flow_status_code (
      P_HEADER_ID => To_Number(itemkey)
     ,P_FLOW_STATUS_CODE => 'REJECTED_PENDING_CANC'
     ,X_RETURN_STATUS => l_return_status);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Update flow status code: '||L_RETURN_STATUS
                       ||' - '||itemtype||'/'||itemkey,1);
    END IF;
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  FOR lines IN return_lines LOOP
    OE_Order_WF_Util.Update_Flow_Status_Code (
        p_line_id => lines.line_id
       ,p_flow_status_code => 'REJECTED_PENDING_CANC'
       ,x_return_status => l_return_status
       );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Update flow status code: '||L_RETURN_STATUS
                         ||' - '||lines.item_type||'/'||lines.item_key,1);
      END IF;
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END LOOP;
  RESULTOUT := 'COMPLETE';
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OEXWRMAB: EXITING UPD_FLOW_STATUS_CODE_REJ');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_RMA_WF', 'UPD_FLOW_STATUS_CODE_REJ',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    RAISE;
END UPD_FLOW_STATUS_CODE_REJ;

/* 6629220: Start
 * Following procedures added to update flow status codes
 * 1. UPD_FLOW_STATUS_CODE_REJ
 * 2. UPD_FLOW_STATUS_CODE_MIX_REJ
 * Changes in one procedure may be needed in the other procedure also.
 * Because both procedures performs same action of updating flow status
 * code.
 */
PROCEDURE UPD_FLOW_STATUS_CODE_MIX_REJ(
 itemtype 	IN 	VARCHAR2
,itemkey 	IN 	VARCHAR2
,actid 	IN 	NUMBER
,funcmode 	IN 	VARCHAR2
,resultout 	IN OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
) AS
  l_return_status VARCHAR2(1);
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

  CURSOR return_lines IS
  SELECT line_id,wias.item_type,wias.item_key
  FROM oe_order_lines l
      ,WF_ITEM_ACTIVITY_STATUSES WIAS
      ,WF_PROCESS_ACTIVITIES WPA
  WHERE l.header_id = To_Number(itemkey)
  AND l.line_category_code = 'RETURN'
  AND l.open_flag = 'Y'
  AND WIAS.item_type = 'OEOL'
  AND WIAS.item_key = To_Char(l.line_id)
  AND WPA.instance_id = WIAS.process_activity
  AND WIAS.activity_status = 'NOTIFIED'
  AND WPA.activity_name = 'APPROVE_WAIT_FOR_H';
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OEXWRMAB: ENTERING UPD_FLOW_STATUS_CODE_MIX_REJ, '
                    ||'ITEM TYPE/KEY: '||itemtype||'/'||itemkey);
  END IF;
  oe_order_wf_util.update_flow_status_code (
      P_HEADER_ID => To_Number(itemkey)
     ,P_FLOW_STATUS_CODE => 'RETURN_REJECTED'
     ,X_RETURN_STATUS => l_return_status);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Update flow status code: '||L_RETURN_STATUS
                       ||' - '||itemtype||'/'||itemkey,1);
    END IF;
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  FOR lines IN return_lines LOOP
    OE_Order_WF_Util.Update_Flow_Status_Code (
        p_line_id => lines.line_id
       ,p_flow_status_code => 'REJECTED_PENDING_CANC'
       ,x_return_status => l_return_status
       );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Update flow status code: '||L_RETURN_STATUS
                         ||' - '||lines.item_type||'/'||lines.item_key,1);
      END IF;
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END LOOP;
  RESULTOUT := 'COMPLETE';
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OEXWRMAB: EXITING UPD_FLOW_STATUS_CODE_MIX_REJ');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_RMA_WF', 'UPD_FLOW_STATUS_CODE_MIX_REJ',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    RAISE;
END UPD_FLOW_STATUS_CODE_MIX_REJ;

end  OE_RMA_WF;

/
