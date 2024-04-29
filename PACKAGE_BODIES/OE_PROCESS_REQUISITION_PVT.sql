--------------------------------------------------------
--  DDL for Package Body OE_PROCESS_REQUISITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PROCESS_REQUISITION_PVT" AS
/* $Header: OEXVPIRB.pls 120.0.12010000.9 2012/09/14 08:09:46 rahujain noship $ */

--  Global constant holding the package name
G_PKG_Name          CONSTANT VARCHAR2(30) := 'OE_PROCESS_REQUISITION_PVT';

g_requisition_number        VARCHAR2(20);
g_requisition_line_number   NUMBER;
g_need_by_date              DATE;
g_requested_quantity        NUMBER;
g_sales_order_number        NUMBER;
g_order_cancellation_date   DATE;
g_sales_ord_line_num        NUMBER;
g_line_cancellation_date    DATE;
g_ISO_cancelled_quantity    NUMBER;
g_inventory_item_name       VARCHAR2(2000); --bug10631734
g_updated_quantity          NUMBER;
g_line_updated_date         DATE;
g_schedule_ship_date        DATE;
g_schedule_arrival_date     DATE;
g_reason                    VARCHAR2(400);
g_requested_quantity2       NUMBER; --Bug 14211120
g_updated_quantity2         NUMBER; --Bug 14211120


PROCEDURE SET_ORG_CONTEXT -- Body details
( p_org_id   IN   NUMBER
) IS

l_progress      VARCHAR2(3) := NULL;
l_current_org_id  hr_all_organization_units_tl.organization_id%TYPE;
l_access_mode VARCHAR2(1);
l_ou_count NUMBER;
l_is_mo_init_done VARCHAR2(1);
--
l_debug_level         CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN
  l_progress := '00';
  l_is_mo_init_done := MO_GLOBAL.is_mo_init_done;
  l_progress := '10';
  IF (l_is_mo_init_done <> 'Y') THEN
    MO_GLOBAL.INIT('ONT');
  END IF;
  l_progress := '20';
  IF (p_org_id IS NOT NULL) THEN
    l_access_mode    := MO_GLOBAL.get_access_mode;
    l_progress := '30';
    IF l_access_mode = 'S' THEN
      l_current_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
      l_progress := '40';
      IF ( l_current_org_id IS NULL OR
           l_current_org_id <> p_org_id) THEN
        MO_GLOBAL.SET_POLICY_CONTEXT('S', p_org_id);
        l_progress := '50';
      END IF;
    ELSE
      l_progress := '60';
      MO_GLOBAL.SET_POLICY_CONTEXT('S', p_org_id);
      l_progress := '70';
    END IF;
  ELSE
    l_progress := '80';
    l_ou_count := MO_GLOBAL.GET_OU_COUNT();
    l_progress := '90';
    IF (l_ou_count > 1) THEN
      MO_GLOBAL.SET_POLICY_CONTEXT('M', NULL);
      l_progress := '99';
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add(' Set_org_context '||l_progress||' : '||sqlerrm);
    END IF;
    RAISE;
END Set_Org_Context;

Procedure Prepare_Notification -- Body definition
( p_header_id     IN NUMBER
, p_Line_Id_tbl   IN Line_id_tbl
, p_performer     IN VARCHAR2
, p_cancel_order  IN BOOLEAN
, p_notify_for    IN VARCHAR2
, p_req_header_id IN NUMBER
, p_req_line_id   IN NUMBER
, x_return_status OUT NOCOPY VARCHAR2
) IS
--
l_line_ids_tbl        Line_id_tbl;
l_chgord_item_type VARCHAR2(30) := 'OECHGORD'; -- OM Change Order Item Type
--
l_return_status       VARCHAR2(1);

l_wf_item_key         VARCHAR2(240);
l_process_name        VARCHAR2(30);
l_user_name           VARCHAR2(255);
l_flow_created        BOOLEAN := FALSE;

--
l_debug_level         CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

Begin

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  ' ENTERING OE_Process_Requisition_Pvt.Prepare_Notification', 1 ) ;
    oe_debug_pub.add(  ' P_Header_id :'||P_Header_id , 5 ) ;
    oe_debug_pub.add(  ' P_Line_id_tbl Count :'||P_Line_id_tbl.count , 5 ) ;
    oe_debug_pub.add(  ' P_performer :'||p_performer,5);
    oe_debug_pub.add(  ' p_notify_for :'||p_notify_for,5);
    oe_debug_pub.add(  ' P_Req_Header_id :'||P_Req_Header_id , 5 ) ;
    oe_debug_pub.add(  ' P_Req_Line_id :'||P_Req_Line_id , 5 ) ;
    IF P_Cancel_Order THEN
      IF l_debug_level > 0 THEN
        oe_debug_pub.add(  ' Header Level cancellation', 5 ) ;
      END IF;
    ELSE
      IF l_debug_level > 0 THEN
        oe_debug_pub.add(  ' Not a header Level cancellation', 5 ) ;
      END IF;
    END IF;
  END IF;

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_notify_for is NULL AND NOT P_cancel_order THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add( ' RETURN. No notification will be send as nothing has updated on the requisition', 5);
    END IF;
    RETURN;
  END IF;

  -- Generate a unique item key to create a flow
  select to_char(oe_wf_key_s.nextval) into l_wf_item_key
  from dual;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  ' WF ITEM KEY IS :'|| L_WF_ITEM_KEY ) ;
  END IF;

  IF P_cancel_order THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add( 'Sending notification for requisition header cancellation', 5);
    END IF;

    l_process_name := 'ISO_CANCEL';

    -- Create the Notification flow for Header Cancellation
    WF_ENGINE.CreateProcess(l_chgord_item_type, l_wf_item_key, l_process_name);
    l_flow_created := TRUE;

    -- Set the resolving role for the notification.
    WF_Engine.SetItemAttrText( l_chgord_item_type
                             , l_wf_item_key
                             , 'RESOLVING_ROLE'
                             , p_performer);

    -- Set the Sales Order Number
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'ORDER_NUMBER'
                               , g_sales_order_number);

    -- Set the Requisition Header Number
    WF_ENGINE.SetItemAttrText( l_chgord_item_type
                               , l_wf_item_key
                               , 'REQ_HDR_NUMBER'
                               , g_requisition_number);

    -- Set the Sales Order Cancellation Date
    WF_Engine.SetItemAttrDate( l_chgord_item_type
                             , l_wf_item_key
                             , 'ORDER_CANCEL_DATE'
                             , g_order_cancellation_date);

/*    -- Set the Sales Order cancellation Reason
    WF_Engine.SetItemAttrText( l_chgord_item_type
                             , l_wf_item_key
                             , 'REASON'
                             , g_reason);
*/
  ELSIF p_notify_for = 'Q' THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add( 'Sending notification for requisition line quantity update', 5);
    END IF;

    l_process_name := 'ISO_QTY_UPDATE';

    -- Create the Notification flow for Line Quantity update
    WF_ENGINE.CreateProcess(l_chgord_item_type, l_wf_item_key, l_process_name);
    l_flow_created := TRUE;

    -- Set the resolving role for the notification.
    WF_Engine.SetItemAttrText( l_chgord_item_type
                             , l_wf_item_key
                             , 'RESOLVING_ROLE'
                             , p_performer);

    -- Set the Sales Order Number
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'ORDER_NUMBER'
                               , g_sales_order_number);

    -- Set the Sales Line Number
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'LINE_NUMBER'
                               , g_sales_ord_line_num);

    -- Set the Requisition Header Number
    WF_ENGINE.SetItemAttrText( l_chgord_item_type
                               , l_wf_item_key
                               , 'REQ_HDR_NUMBER'
                               , g_requisition_number);

    -- Set the Requisition Line Number
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'REQ_LINE_NUMBER'
                               , g_requisition_line_number);

    -- Set the Sales Order Line Inventory Item Name
    WF_Engine.SetItemAttrText( l_chgord_item_type
                             , l_wf_item_key
                             , 'INVENTORY_ITEM'
                             , g_inventory_item_name);

    -- Set the Requisition Line Requested Quantity
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'REQUESTED_QTY'
                               , g_requested_quantity);

    -- Set the Sales Order Line updated Quantity
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'UPDATED_QTY'
                               , g_updated_quantity);

    -- Set the Sales Order Line update Date
    WF_Engine.SetItemAttrDate( l_chgord_item_type
                             , l_wf_item_key
                             , 'LINE_UPDATE_DATE'
                             , g_line_updated_date);

    --Bug 14211120 Start
    -- Set the Requisition Line Secondary Requested Quantity
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'REQUESTED_QTY2'
                               , g_requested_quantity2);

    -- Set the Sales Order Line Secondary updated Quantity
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'UPDATED_QTY2'
                               , g_updated_quantity2);
    --Bug 14211120 End

/*    -- Set the Sales Order cancellation Reason
    WF_Engine.SetItemAttrText( l_chgord_item_type
                             , l_wf_item_key
                             , 'REASON'
                             , g_reason);
*/
  ELSIF p_notify_for = 'D' THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add( 'Sending notification for requisition line date update', 5);
    END IF;

    l_process_name := 'ISO_SCH_DATE_UPDATE';

    -- Create the Notification flow for Line Schedule Ship Date update
    WF_ENGINE.CreateProcess(l_chgord_item_type, l_wf_item_key, l_process_name);
    l_flow_created := TRUE;

    -- Set the resolving role for the notification.
    WF_Engine.SetItemAttrText( l_chgord_item_type
                             , l_wf_item_key
                             , 'RESOLVING_ROLE'
                             , p_performer);

    -- Set the Sales Order Number
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'ORDER_NUMBER'
                               , g_sales_order_number);

    -- Set the Sales Line Number
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'LINE_NUMBER'
                               , g_sales_ord_line_num);

    -- Set the Requisition Header Number
    WF_ENGINE.SetItemAttrText( l_chgord_item_type
                               , l_wf_item_key
                               , 'REQ_HDR_NUMBER'
                               , g_requisition_number);

    -- Set the Requisition Line Number
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'REQ_LINE_NUMBER'
                               , g_requisition_line_number);

    -- Set the Sales Order Line Inventory Item Name
    WF_Engine.SetItemAttrText( l_chgord_item_type
                             , l_wf_item_key
                             , 'INVENTORY_ITEM'
                             , g_inventory_item_name);

    -- Set the Requisition Line Requested Quantity
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'REQUESTED_QTY'
                               , g_requested_quantity);

    -- Set the Requisition Line Need By Date
    WF_Engine.SetItemAttrDate( l_chgord_item_type
                             , l_wf_item_key
                             , 'REQ_LIN_NEED_BY_DATE'
                             , g_need_by_date);

    -- Set the Sales Order Line Schedule Ship Date
    WF_Engine.SetItemAttrDate( l_chgord_item_type
                             , l_wf_item_key
                             , 'LINE_SCH_ARRIVAL_DATE'
                             , g_schedule_arrival_date);

    -- Set the Sales Order Line update Date
    WF_Engine.SetItemAttrDate( l_chgord_item_type
                             , l_wf_item_key
                             , 'LINE_UPDATE_DATE'
                             , g_line_updated_date);

/*    -- Set the Sales Order cancellation Reason
    WF_Engine.SetItemAttrText( l_chgord_item_type
                             , l_wf_item_key
                             , 'REASON'
                             , g_reason);
*/
  ELSIF p_notify_for = 'B' THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add( 'Sending notification for requisition line quantity and date update', 5);
    END IF;

    l_process_name := 'ISO_QTY_SCH_DATE_UPDATE';

    -- Create the Notification flow for Line Quantity and Schedule Ship Date update
    WF_ENGINE.CreateProcess(l_chgord_item_type, l_wf_item_key, l_process_name);
    l_flow_created := TRUE;

    -- Set the resolving role for the notification.
    WF_Engine.SetItemAttrText( l_chgord_item_type
                             , l_wf_item_key
                             , 'RESOLVING_ROLE'
                             , p_performer);

    -- Set the Sales Order Number
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'ORDER_NUMBER'
                               , g_sales_order_number);

    -- Set the Sales Line Number
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'LINE_NUMBER'
                               , g_sales_ord_line_num);

    -- Set the Requisition Header Number
    WF_ENGINE.SetItemAttrText( l_chgord_item_type
                               , l_wf_item_key
                               , 'REQ_HDR_NUMBER'
                               , g_requisition_number);

    -- Set the Requisition Line Number
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'REQ_LINE_NUMBER'
                               , g_requisition_line_number);

    -- Set the Sales Order Line Inventory Item Name
    WF_Engine.SetItemAttrText( l_chgord_item_type
                             , l_wf_item_key
                             , 'INVENTORY_ITEM'
                             , g_inventory_item_name);

    -- Set the Requisition Line Requested Quantity
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'REQUESTED_QTY'
                               , g_requested_quantity);

    -- Set the Sales Order Line updated Quantity
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'UPDATED_QTY'
                               , g_updated_quantity);

    -- Set the Requisition Line Need By Date
    WF_Engine.SetItemAttrDate( l_chgord_item_type
                             , l_wf_item_key
                             , 'REQ_LIN_NEED_BY_DATE'
                             , g_need_by_date);

    -- Set the Sales Order Line Schedule Ship Date
    WF_Engine.SetItemAttrDate( l_chgord_item_type
                             , l_wf_item_key
                             , 'LINE_SCH_ARRIVAL_DATE'
                             , g_schedule_arrival_date);

    -- Set the Sales Order Line update Date
    WF_Engine.SetItemAttrDate( l_chgord_item_type
                             , l_wf_item_key
                             , 'LINE_UPDATE_DATE'
                             , g_line_updated_date);

    --Bug 14211120 Start
    -- Set the Requisition Line Secondary Requested Quantity
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'REQUESTED_QTY2'
                               , g_requested_quantity2);

    -- Set the Sales Order Line Secondary updated Quantity
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'UPDATED_QTY2'
                               , g_updated_quantity2);
    --Bug 14211120 End

/*    -- Set the Sales Order cancellation Reason
    WF_Engine.SetItemAttrText( l_chgord_item_type
                             , l_wf_item_key
                             , 'REASON'
                             , g_reason);
*/
  ELSIF p_notify_for = 'C' THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add( 'Sending notification for requisition line cancellation', 5);
    END IF;

    l_process_name := 'ISO_LINE_CANCEL';

    -- Create the Notification flow for Line Cancellation
    WF_ENGINE.CreateProcess(l_chgord_item_type, l_wf_item_key, l_process_name);
    l_flow_created := TRUE;

    -- Set the resolving role for the notification.
    WF_Engine.SetItemAttrText( l_chgord_item_type
                             , l_wf_item_key
                             , 'RESOLVING_ROLE'
                             , p_performer);

    -- Set the Sales Order Number
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'ORDER_NUMBER'
                               , g_sales_order_number);

    -- Set the Sales Line Number
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'LINE_NUMBER'
                               , g_sales_ord_line_num);

    -- Set the Requisition Header Number
    WF_ENGINE.SetItemAttrText( l_chgord_item_type
                               , l_wf_item_key
                               , 'REQ_HDR_NUMBER'
                               , g_requisition_number);

    -- Set the Requisition Line Number
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'REQ_LINE_NUMBER'
                               , g_requisition_line_number);

    -- Set the Sales Order Line Inventory Item Name
    WF_Engine.SetItemAttrText( l_chgord_item_type
                             , l_wf_item_key
                             , 'INVENTORY_ITEM'
                             , g_inventory_item_name);

    -- Set the Requisition Line Requested Quantity
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'REQUESTED_QTY'
                               , g_requested_quantity);

    -- Set the Sales Order Line Cancelled Quantity
    WF_ENGINE.SetItemAttrNumber( l_chgord_item_type
                               , l_wf_item_key
                               , 'CANCELLED_QTY'
                               , g_ISO_cancelled_quantity);

    -- Set the Sales Order Line Cancel Date
    WF_Engine.SetItemAttrDate( l_chgord_item_type
                             , l_wf_item_key
                             , 'LINE_CANCEL_DATE'
                             , g_line_cancellation_date);

/*    -- Set the Sales Order cancellation Reason
    WF_Engine.SetItemAttrText( l_chgord_item_type
                             , l_wf_item_key
                             , 'REASON'
                             , g_reason);
*/
  END IF;

  IF l_flow_created THEN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(' Starting the workflow process for sending the notification', 5);
    END IF;
    BEGIN
      select user_name
      into l_user_name
      from fnd_user
      where user_id = FND_GLOBAL.USER_ID;
    EXCEPTION
      WHEN OTHERS THEN
        l_user_name := null; -- do not set FROM_ROLE then
    END;

    IF (l_user_name is not NULL) THEN
      WF_ENGINE.SetItemAttrText( l_chgord_item_type
                               , l_wf_item_key
                               , 'NOTIFICATION_FROM_ROLE'
                               , l_user_name);
    END IF;

    WF_ENGINE.StartProcess(l_chgord_item_type, l_wf_item_key);
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(' Workflow process is successfully started',5);
    END IF;
  END IF;

  x_return_status := l_return_status;

--  OE_MSG_PUB.Count_And_Get (P_Count => x_msg_Count,
--                            P_Data  => x_msg_Data);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXITING OE_Process_Requisition_Pvt.Prepare_Notification', 1 ) ;
  END IF;

Exception
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
--    OE_MSG_PUB.Count_And_Get (P_Count => x_msg_Count,
--                              P_Data  => x_msg_Data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    OE_MSG_PUB.Count_And_Get (P_Count => x_msg_Count,
--                              P_Data  => x_msg_Data);

  WHEN OTHERS THEN
    oe_debug_pub.add(  ' When Others of OE_Process_Requisition_Pvt.Prepare_Notification '||sqlerrm,1);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Prepare_Notification');
      -- Pkg Body global variable = OE_Process_Requisition_Pvt
    END IF;
--    OE_MSG_PUB.Count_And_Get (P_Count => x_msg_Count,
--                              P_Data  => x_msg_Data);

End Prepare_Notification;

Procedure Update_Internal_Requisition -- Body definition
(  P_Header_id              IN  NUMBER
,  P_Line_id                IN  NUMBER
,  P_Line_ids               IN  VARCHAR2
,  p_num_records            IN  NUMBER
,  P_Req_Header_id          IN   NUMBER
,  P_Req_Line_id            IN   NUMBER
,  P_Quantity_Change        IN  NUMBER
,  P_Quantity2_Change       IN  NUMBER --Bug 14211120
,  P_New_Schedule_Ship_Date IN  DATE
,  P_Cancel_Order           IN  BOOLEAN
,  P_Cancel_Line            IN  BOOLEAN
,  X_msg_count              OUT NOCOPY NUMBER
,  X_msg_data               OUT NOCOPY VARCHAR2
,  X_return_status	       OUT NOCOPY VARCHAR2
) IS
--
-- TYPE Line_id_tbl_TYPE is TABLE OF NUMBER;
l_line_ids_tbl        Line_id_tbl := Line_id_tbl();
--
l_return_status       VARCHAR2(1);
l_create_notification BOOLEAN := FALSE;
l_access_mode         VARCHAR2(1) := mo_global.Get_access_mode();
l_original_org_id     NUMBER := MO_GLOBAL.GET_CURRENT_ORG_ID();
                -- hr_all_organization_units_tl.organization_id%TYPE
                -- If context is SINGLE, returns current session ORG_ID
                -- If context is MULTI, returns NULL
l_target_org_id       hr_all_organization_units_tl.organization_id%TYPE;

l_Req_Line_NeedByDate    DATE;
l_New_Schedule_Ship_Date DATE;
l_New_Schedule_Arrival_Date DATE;
l_preparer_name          VARCHAR2(150);
l_call_po_api_for_update BOOLEAN := FALSE;
l_line_id             NUMBER;
L_change              VARCHAR2(1) := NULL;
l_index               NUMBER := 0;
l_line_exists         BOOLEAN := FALSE;
l_nxt_position        integer;
l_initial             integer;
J                     integer;
--l_separator           VARCHAR2(1); -- Added for bug 8920840
-- Commented for bug 8974535
--

l_req_line_id_tbl     Dbms_Sql.number_table;
l_req_can_qty_tbl     Dbms_Sql.number_table; -- Bug12970870
l_req_can_qty2_tbl    Dbms_Sql.number_table; --Bug 14211120 Secondary cancel qty

CURSOR Cancel_Lines IS
select source_document_line_id
from   oe_order_lines_all
where  header_id = p_header_id
and    open_flag = 'N'
and    nvl(cancelled_flag, 'N') = 'Y'; -- Cursor added for 8583903
--

l_debug_level         CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

Begin

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING OE_Process_Requisition_Pvt.Update_Internal_Requisition', 1 ) ;
    oe_debug_pub.add(  ' P_Header_id :'||P_Header_id , 5 ) ;
    oe_debug_pub.add(  ' P_Line_id :'||P_Line_id , 5 ) ;
    oe_debug_pub.add(  ' P_Num_Records :'||p_num_records,5);
    oe_debug_pub.add(  ' P_Req_Header_id :'||P_Req_Header_id , 5 ) ;
    oe_debug_pub.add(  ' P_Req_Line_id :'||P_Req_Line_id , 5 ) ;
    oe_debug_pub.add(  ' P_Quantity_Change :'||P_Quantity_Change, 5 );
    oe_debug_pub.add(  ' P_Quantity2_Change :'||P_Quantity2_Change, 5 );
    oe_debug_pub.add(  ' P_New_Schedule_Ship_Date :'||P_New_Schedule_Ship_Date, 5 ) ;
    IF P_Cancel_Order THEN
      oe_debug_pub.add(  ' Header level cancellation',5);
    ELSE
      oe_debug_pub.add(  ' Not a header level cancellation',5);
    END IF;
    IF P_Cancel_Line THEN
      oe_debug_pub.add(  ' Line level cancellation',5);
    ELSE
      oe_debug_pub.add(  ' Not a line level cancellation',5);
    END IF;
  END IF;

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT P_Cancel_Line and NOT P_Cancel_Order
   AND (P_Quantity_Change is null OR P_Quantity_Change = 0)
   AND (P_Quantity2_Change is null OR P_Quantity2_Change = 0) --Bug 14211120
   AND P_New_Schedule_Ship_Date is null THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' Nothing to update on Requisition', 5 ) ;
    END IF;
    -- RAISE FND_API.G_EXC_ERROR;
    x_return_status := l_return_status;
    RETURN;
  END IF;

  -- Retrieve the calling application operating unit.
  SELECT org_id, segment1
  INTO   l_target_org_id, g_requisition_number
  FROM   po_requisition_Headers_all
  WHERE  requisition_header_id = p_req_Header_id;

  IF l_debug_level > 0 THEN
    oe_debug_pub.add( ' OE_GLOBALS.G_REASON_CODE for this change is '||OE_GLOBALS.G_REASON_CODE,5);
  END IF;

  IF P_Cancel_Order THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add( ' Calling PO_RCO_Validation_GRP.Update_ReqCancel_from_SO', 1 ) ;
      oe_debug_pub.add( ' Cancelling Requisition Header', 1 ) ;
    END IF;

    select order_number, last_update_date
    into   g_sales_order_number, g_order_cancellation_date
    from   oe_order_headers_all
    where  header_id = p_header_id;

    g_reason := OE_GLOBALS.G_REASON_CODE;
    -- 'OE_GLOBALS.G_REASON_COMMENTS'

      -- Added for 8583903
    open Cancel_Lines;
      loop
        EXIT WHEN Cancel_Lines%NOTFOUND;
        FETCH Cancel_Lines BULK COLLECT INTO l_req_line_id_tbl;
    end loop;
    close Cancel_Lines;

    SET_ORG_CONTEXT(l_target_org_id);

    PO_RCO_Validation_GRP.Update_ReqCancel_from_SO
    ( p_api_version      => 4.0 -- Bug12970870, 14211120
    , p_req_line_id_tbl  => l_req_line_id_tbl
    --, p_req_can_qty_tbl  => l_req_can_qty_tbl -- Bug12970870
    , p_req_can_prim_qty_tbl => l_req_can_qty_tbl -- Bug 14211120
    , p_req_can_sec_qty_tbl  => l_req_can_qty2_tbl -- Bug 14211120
    , p_req_can_all      => TRUE              -- Bug 12970870
--    , p_req_line_id      => NULL -- Header Level Cancellation -- Api Modified for 8583903
--    , p_req_hdr_id       => P_Req_Header_id
    , x_return_status    => l_return_status
    );

    SET_ORG_CONTEXT(l_original_org_id);

    IF l_debug_level > 0 THEN
      oe_debug_pub.add( ' After PO_RCO_Validation_GRP.Update_ReqCancel_from_SO '||l_return_status, 1 ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
      -- Sales order and corresponding internal requisition has been cancelled
      FND_Message.Set_Name('ONT', 'OE_IRCMS_REQ_CANCEL');
      OE_MSG_PUB.Add;
    ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- Unable to save the changes as the corresponding Internal Requisition can not be updated
      FND_Message.Set_Name('ONT', 'OE_IRCMS_REQ_FAIL');
      OE_MSG_PUB.Add;
      IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

    l_create_notification := TRUE;

  ELSIF P_Cancel_Line THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add( ' Calling PO_RCO_Validation_GRP.Update_ReqCancel_from_SO', 1 ) ;
      oe_debug_pub.add( ' Cancelling Requisition Line', 1 ) ;
    END IF;

    select order_number
    into   g_sales_order_number
    from   oe_order_headers_all
    where  header_id = p_header_id;

    -- Added for bug #8920840
    -- select SubStr(Value,-1,1) into l_separator from v$parameter
    -- where name = 'nls_numeric_characters'; -- Commented for bug 8974535

 -- select line_number||'.'||shipment_number
 -- select line_number||l_separator||shipment_number -- Commented for bug 8974535
    -- Modified for bug #8920840
    select line_number+(shipment_number/power(10,length(shipment_number))) as line_num
    -- Added for bug #8974535
         , nvl(cancelled_quantity,0)
         , last_update_date
    into   g_sales_ord_line_num
         , g_ISO_cancelled_quantity
         , g_line_cancellation_date
    from   oe_order_lines_all
    where  line_id = p_line_id;

    select items.concatenated_segments
         , prl.line_num
         , prl.quantity
         , prl.secondary_quantity --Bug 14211120
    into   g_inventory_item_name
         , g_requisition_line_number
         , g_requested_quantity
         , g_requested_quantity2 --Bug 14211120
    from   mtl_system_items_b_kfv items
         , po_requisition_lines_all prl
         , financials_system_params_all fsp
    where  fsp.org_id = prl.org_id
    and    fsp.inventory_organization_id = items.organization_id
    and    prl.item_id = items.inventory_item_id
    and    prl.requisition_line_id = P_Req_Line_id;

    g_reason := OE_GLOBALS.G_REASON_CODE;
    -- 'OE_GLOBALS.G_REASON_COMMENTS'

    -- Added for 8583903
    l_req_line_id_tbl(1) := p_req_line_id;
    l_req_can_qty_tbl(1) := -P_Quantity_Change ; --Bug12970870
    l_req_can_qty2_tbl(1) := -P_Quantity2_Change ; --Bug 14211120

    SET_ORG_CONTEXT(l_target_org_id);

    PO_RCO_Validation_GRP.Update_ReqCancel_from_SO
    ( p_api_version      => 4.0 --Bug12970870 14211120
    , p_req_line_id_tbl  => l_req_line_id_tbl
    --, p_req_can_qty_tbl  => l_req_can_qty_tbl -- Bug12970870
    , p_req_can_prim_qty_tbl  => l_req_can_qty_tbl -- Bug 14211120
    , p_req_can_sec_qty_tbl   => l_req_can_qty2_tbl -- Bug 14211120
    , p_req_can_all      => FALSE --Bug12970870
--    , p_req_line_id      => P_Req_Line_id
--    , p_req_hdr_id       => P_Req_Header_id -- Api modified for 8583903
    , x_return_status    => l_return_status
    );

    SET_ORG_CONTEXT(l_original_org_id);

    IF l_debug_level > 0 THEN
      oe_debug_pub.add( ' After PO_RCO_Validation_GRP.Update_ReqCancel_from_SO '||l_return_status, 5 ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
      -- Sales order and corresponding internal requisition line has been cancelled
      FND_Message.Set_Name('ONT', 'OE_IRCMS_REQ_LIN_CANCEL');
      OE_MSG_PUB.Add;
    ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- Unable to save the changes as the corresponding Internal Requisition can not be updated
      FND_Message.Set_Name('ONT', 'OE_IRCMS_REQ_FAIL');
      OE_MSG_PUB.Add;
      IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    L_change := 'C'; -- Line cancellation
    l_create_notification := TRUE;

  ELSIF (P_Quantity_Change IS NOT NULL AND P_Quantity_Change <> 0)
    OR (P_Quantity2_Change IS NOT NULL AND P_Quantity2_Change <> 0) --Bug 14211120
    OR (P_New_Schedule_Ship_Date IS NOT NULL) THEN

    IF l_debug_level > 0 THEN
      oe_debug_pub.add( ' Quantity OR Date changed. Req Line has to be updated', 5 ) ;
    END IF;

    select order_number
    into   g_sales_order_number
    from   oe_order_headers_all
    where  header_id = p_header_id;

    -- Added for bug #8920840
    -- select SubStr(Value,-1,1) into l_separator from v$parameter
    -- where name = 'nls_numeric_characters';  -- Commented for bug 8974535

 -- select line_number||'.'||shipment_number
 -- select line_number||l_separator||shipment_number  -- Commented for bug 8974535
    -- Modified for bug #8920840
    select line_number+(shipment_number/power(10,length(shipment_number))) as line_num
    -- Added for bug 8974535
--         , ordered_quantity
         , schedule_ship_date
         , schedule_arrival_date
         , last_update_date
    into   g_sales_ord_line_num
--         , g_updated_quantity
         , g_schedule_ship_date
         , g_schedule_arrival_date
         , g_line_updated_date
    from   oe_order_lines_all
    where  line_id = p_line_id;


    select items.concatenated_segments
         , prl.line_num
         , prl.quantity
         , prl.secondary_quantity --Bug 14211120
         , prl.need_by_date
         , prl.need_by_date
    into   g_inventory_item_name
         , g_requisition_line_number
         , g_requested_quantity
         , g_requested_quantity2 --Bug 14211120
         , g_need_by_date
         , l_Req_Line_NeedByDate
    from   mtl_system_items_b_kfv items
         , po_requisition_lines_all prl
         , financials_system_params_all fsp
    where  fsp.org_id = prl.org_id
    and    fsp.inventory_organization_id = items.organization_id
    and    prl.item_id = items.inventory_item_id
    and    prl.requisition_line_id = P_Req_Line_id;

    g_updated_quantity := g_requested_quantity + NVL(P_Quantity_Change,0);
    g_updated_quantity2 := g_requested_quantity2 + NVL(P_Quantity2_Change,0); --Bug 14211120
    -- Added NVL for bug 8920840

    IF l_debug_level > 0 THEN
      oe_debug_pub.add( ' Need By Date on Req Line is '||l_Req_Line_NeedByDate, 5 ) ;
    END IF;

    --IF (P_Quantity_Change IS NOT NULL AND P_Quantity_Change <> 0)
    --AND (P_New_Schedule_Ship_Date IS NOT NULL) THEN
    --Bug 14211120
    IF ((P_Quantity_Change IS NOT NULL AND P_Quantity_Change <> 0)
        OR (P_Quantity2_Change IS NOT NULL AND P_Quantity2_Change <> 0))
    AND (P_New_Schedule_Ship_Date IS NOT NULL) THEN


     --  IF oe_globals.equal(P_New_Schedule_Ship_Date , l_Req_Line_NeedByDate) THEN
      IF oe_globals.equal(g_schedule_arrival_date, l_Req_Line_NeedByDate) THEN
        l_New_Schedule_Ship_Date := NULL;
        g_schedule_ship_date := NULL;
        g_schedule_arrival_date := NULL;
        IF l_debug_level > 0 THEN
          oe_debug_pub.add( ' Ordered Quantity is changed. Update Req', 5 ) ;
        END IF;
        L_change := 'Q'; -- Quantity change
        l_call_po_api_for_update := TRUE;
      ELSE
        l_New_Schedule_Arrival_Date := g_schedule_arrival_date;
        -- l_New_Schedule_Ship_Date := P_New_Schedule_Ship_Date;
        IF l_debug_level > 0 THEN
          oe_debug_pub.add( ' Ordered Quantity and Schedule Ship/Arrival Date are changed. Update Req', 5 ) ;
        END IF;
        L_change := 'B'; -- Both Date and Quantity change
        l_call_po_api_for_update := TRUE;
      END IF;

    --Bug 14211120
    --ELSIF P_Quantity_Change IS NOT NULL AND P_Quantity_Change <> 0 THEN
    ELSIF (P_Quantity_Change IS NOT NULL AND P_Quantity_Change <> 0) OR
          (P_Quantity2_Change IS NOT NULL AND P_Quantity2_Change <> 0) THEN
      IF l_debug_level > 0 THEN
        oe_debug_pub.add( ' Ordered Quantity is changed. Update Req', 5 ) ;
      END IF;
      L_change := 'Q'; -- Quantity change
      g_schedule_ship_date := NULL;
      g_schedule_arrival_date := NULL;
      l_call_po_api_for_update := TRUE;

    ELSIF P_New_Schedule_Ship_Date IS NOT NULL THEN
      -- IF oe_globals.equal(P_New_Schedule_Ship_Date , l_Req_Line_NeedByDate) THEN
      IF oe_globals.equal(g_schedule_arrival_date, l_Req_Line_NeedByDate) THEN
        l_New_Schedule_Ship_Date := NULL;
        g_schedule_ship_date := NULL;
        g_schedule_arrival_date := NULL;
        g_updated_quantity := NULL;
        l_call_po_api_for_update := FALSE;
        l_change := NULL; -- No date or quantity change

        IF l_debug_level > 0 THEN
          oe_debug_pub.add( ' Neither Quantity nor date has changed', 5 ) ;
        END IF;
      ELSE
        -- l_New_Schedule_Ship_Date := P_New_Schedule_Ship_Date;
        l_New_Schedule_Arrival_Date := g_schedule_arrival_date;
        IF l_debug_level > 0 THEN
          oe_debug_pub.add( ' Schedule Ship/Arrival Date is changed. Update Req', 5 ) ;
        END IF;
        g_updated_quantity := NULL;
        L_change := 'D'; -- Date Change
        l_call_po_api_for_update := TRUE;
      END IF;

    END IF; -- Quantity or Date change

    IF l_call_po_api_for_update THEN

      IF l_debug_level > 0 THEN
        oe_debug_pub.add( ' Calling PO_RCO_Validation_GRP.Update_ReqChange_from_SO', 1 ) ;
      END IF;

      SET_ORG_CONTEXT(l_target_org_id);

      PO_RCO_Validation_GRP.Update_ReqChange_from_SO
      ( p_api_version      => 3.0 --Bug 14211120
      , p_req_line_id      => P_Req_Line_id
      --, p_delta_quantity   => P_Quantity_Change --Bug 14211120
      , p_delta_quantity_prim => P_Quantity_Change --Bug 14211120
      , p_delta_quantity_sec  => P_Quantity2_Change --Bug 14211120
      , p_new_need_by_date => l_New_Schedule_Arrival_Date -- l_New_Schedule_Ship_Date
      , x_return_status    => l_return_status
      );

      SET_ORG_CONTEXT(l_original_org_id);

      IF l_debug_level > 0 THEN
        oe_debug_pub.add( ' After PO_RCO_Validation_GRP.Update_ReqChange_from_SO '||l_return_status, 1);
      END IF;

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF L_change = 'Q' THEN -- Q => Quantity
          -- Ordered quantity, Supply picture, and corresponding internal
          -- requisition line have been updated
          g_reason := OE_GLOBALS.G_REASON_CODE;
          -- 'OE_GLOBALS.G_REASON_COMMENTS'
          FND_Message.Set_Name('ONT', 'OE_IRCMS_QTY_UDPATE');
          OE_MSG_PUB.Add;
        ELSIF L_change = 'D' THEN -- D => Date
          -- Schedule Ship/Arrival date and corresponding internal
          -- requisition line have been updated
          g_reason := OE_GLOBALS.G_REASON_CODE;
          -- 'OE_GLOBALS.G_REASON_COMMENTS'
          FND_Message.Set_Name('ONT', 'OE_IRCMS_DATE_UDPATE');
          OE_MSG_PUB.Add;
        ELSIF L_change = 'B' THEN -- B => Both Date and Quantity
          -- Schedule Ship/Arrival date, Ordered quantity, Supply picture,
          -- and corresponding internal requisition line have been updated
          g_reason := OE_GLOBALS.G_REASON_CODE;
          -- 'OE_GLOBALS.G_REASON_COMMENTS'
          FND_Message.Set_Name('ONT', 'OE_IRCMS_QTY_DATE_UDPATE');
          OE_MSG_PUB.Add;
        END IF;
    ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- Unable to save the changes as the corresponding Internal Requisition can not be updated
      FND_Message.Set_Name('ONT', 'OE_IRCMS_REQ_FAIL');
      OE_MSG_PUB.Add;
      IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

      l_create_notification := TRUE;
    ELSE
      IF l_debug_level > 0 THEN
        oe_debug_pub.add( ' Update_ReqChange_from_SO is not called as there is no valid change to process', 1);
      END IF;
    END IF;
  END IF; -- p_cancel_order

  IF OE_Schedule_GRP.G_ISO_Planning_Update THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add(' The caller for this change is Planning. Hence notification will not be send',5);
    END IF;
    l_create_notification := FALSE;
  END IF;

  IF l_create_notification THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add( ' Preparing Notification ', 1 ) ;
    END IF;

    IF P_Cancel_Order THEN
      IF p_num_records > 0 THEN
        J := 1;
        l_initial := 1;
        l_nxt_position := INSTR(p_line_ids,',',1,J);

        FOR I IN 1 .. p_num_records LOOP
          l_line_id := to_number(substr(p_line_ids,l_initial, l_nxt_position - l_initial));
          IF l_line_ids_tbl.COUNT > 0 THEN
            l_line_exists := FALSE;
            FOR k IN l_line_ids_tbl.FIRST .. l_line_ids_tbl.LAST LOOP
              IF l_line_ids_tbl(k) = l_line_id THEN
                l_line_exists := TRUE;
                EXIT;
              END IF;
            END LOOP;
          END IF;
          IF NOT l_line_exists THEN
            l_line_ids_tbl.Extend(1);
            l_index := l_index + 1;
            l_line_ids_tbl(l_index) := l_line_id;
          END IF;

          l_initial := l_nxt_position + 1;
          j := j + 1;
          l_nxt_position := INSTR(p_line_ids,',',1,J);
        END LOOP;
      END IF;
    ELSE
      l_line_ids_tbl.Extend(1);
      l_line_ids_tbl(1) := p_line_id;
      IF l_debug_level >0 THEN
        oe_debug_pub.add(' Not a header cancellation. Line is : '||l_line_ids_tbl(1));
      END IF;
    END IF;

    SET_ORG_CONTEXT(l_target_org_id);

    PO_RCO_Validation_GRP.Get_Preparer_Name
    ( P_API_Version   => 1.0
    , P_Req_Hdr_id    => p_req_header_id
    , x_return_status => l_return_status
    , x_preparer_name => l_preparer_name  -- Notification performer
    );

    SET_ORG_CONTEXT(l_original_org_id);

    IF l_debug_level > 0 THEN
      oe_debug_pub.add( ' After PO_RCO_Validation_GRP.Get_Preparer_Name '||l_return_status, 1 ) ;
    END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- Unable to save the changes as the corresponding Internal Requisition can not be updated
      FND_Message.Set_Name('ONT', 'OE_IRCMS_REQ_FAIL');
      OE_MSG_PUB.Add;
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    IF l_preparer_name IS NULL THEN
      IF l_debug_level > 0 THEN
        oe_debug_pub.add( ' The preparer name is null. Setting it to SYSADMIN ',1);
      END IF;
      l_preparer_name := 'SYSADMIN';
    ELSE
      IF l_debug_level > 0 THEN
        oe_debug_pub.add( ' The preparer name is '||l_preparer_name);
      END IF;
    END IF;

    Prepare_Notification
    ( p_Line_Id_tbl   => l_line_ids_tbl
    , p_performer     => l_preparer_name
    , p_cancel_order  => p_cancel_order
    , p_notify_for    => l_change -- (C for Line cancellation, D for Date change, Q for quantity change,
                                  --  B for both Quantity and Date change, NULL for nothing updated. No
                                  --  notification)
    , p_header_id     => p_header_id
    , p_req_header_id => p_req_header_id
    , p_req_line_id   => p_req_line_id
    , x_return_status => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;

  -- Setting all package body level globals to NULL;
  g_requisition_number := NULL;
  g_requisition_line_number := NULL;
  g_need_by_date := NULL;
  g_requested_quantity := NULL;
  g_sales_order_number := NULL;
  g_order_cancellation_date := NULL;
  g_sales_ord_line_num := NULL;
  g_line_cancellation_date := NULL;
  g_ISO_cancelled_quantity := NULL;
  g_inventory_item_name := NULL;
  g_updated_quantity := NULL;
  g_line_updated_date := NULL;
  g_schedule_ship_date := NULL;
  g_schedule_arrival_date := NULL;
  g_reason := NULL;
  g_requested_quantity2 := NULL; --Bug 14211120
  g_updated_quantity2 := NULL; --Bug 14211120

  x_return_status := l_return_status;

  OE_MSG_PUB.Count_And_Get (P_Count => x_msg_Count,
                            P_Data  => x_msg_Data);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXITING OE_Process_Requisition_Pvt.Update_Internal_Requisition', 1 ) ;
  END IF;

Exception
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    OE_MSG_PUB.Count_And_Get (P_Count => x_msg_Count,
                              P_Data  => x_msg_Data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    OE_MSG_PUB.Count_And_Get (P_Count => x_msg_Count,
                              P_Data  => x_msg_Data);

  WHEN OTHERS THEN
    oe_debug_pub.add(  ' When Others of OE_Process_Requisition_Pvt.Update_Internal_Requisition '||sqlerrm,1);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Update_Internal_Requisition');
      -- Pkg Body global variable = OE_Process_Requisition_Pvt
    END IF;
    OE_MSG_PUB.Count_And_Get (P_Count => x_msg_Count,
                              P_Data  => x_msg_Data);

End Update_Internal_Requisition;

END OE_PROCESS_REQUISITION_PVT;

/
