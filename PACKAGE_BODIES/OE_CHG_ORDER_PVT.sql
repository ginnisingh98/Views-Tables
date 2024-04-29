--------------------------------------------------------
--  DDL for Package Body OE_CHG_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CHG_ORDER_PVT" AS
/* $Header: OEXVCHGB.pls 120.7.12010000.3 2009/12/08 14:11:57 msundara ship $ */

--  Start of Comments
--  API name    OE_CHG_ORDER_PVT
--  Type        PRIVATE
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Start_ChangeOrderFlow
(  p_itemtype     in VARCHAR2
,  p_itemkey      in VARCHAR2
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE START_CHANGEORDER FLOW' ) ;
        oe_debug_pub.add(  'ITEM TYPE IS :'|| P_ITEMTYPE ) ;
        oe_debug_pub.add(  'ITEM KEY IS :' || P_ITEMKEY ) ;
    END IF;

    WF_ENGINE.StartProcess(p_itemtype, p_itemkey);
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER START_CHANGEORDER FLOW' ) ;
    END IF;
EXCEPTION
WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME
         , 'Start_ChangeOrderFlow'
         );
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
END Start_ChangeOrderFlow;

-- This procedure is called by the Notification Window
-- to create a Change Order Item Type and start a flow
-- for sending a FYI notification to the resolving
-- responsibility

-- This procedure uses Autonomous transaction to commit
-- the process of starting a flow for sending FYI. In this
-- way, the commit or rollback within this procedure will
-- not affect other forms like Error Message form.

Procedure Create_ChgOrderWorkItem
(     p_Workflow_Process        IN VARCHAR2
     ,p_resolving_role          IN VARCHAR2
     ,p_resolving_name          IN VARCHAR2
     ,p_user_text               IN VARCHAR2
)
IS
Pragma AUTONOMOUS_TRANSACTION;

   l_debug_file VARCHAR2(240);

   l_process_name VARCHAR2(30);
   l_chgord_item_type VARCHAR2(30) := 'OECHGORD';
   l_wf_item_key  NUMBER;
   l_document_body VARCHAR2(150);
   l_resolving_role_name VARCHAR2(150);
   l_order_number   NUMBER;
   l_user_name VARCHAR2(255);   -- Bug number 6633740

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
-- The following sql is not needed sind the value is being passed from
-- the form. See bug#3631508
--   cursor roles is  -- 3051285
--      select name
--      from wf_roles
--      where display_name = p_resolving_role;

BEGIN

--    oe_debug_pub.Debug_On;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN CREATE_CHGORDERWORKITEM' ) ;
        oe_debug_pub.add(  'P_RESOLVING_NAME->' || p_resolving_name);
    END IF;

    -- Generate a unique item key to create a flow
    select oe_wf_key_s.nextval into l_wf_item_key
    from dual;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'WF ITEM KEY IS :'|| L_WF_ITEM_KEY ) ;
    END IF;

    -- retrieve the NAME from DISPLAY_NAME
-- The following sql is not needed sind the value is being passed from
-- the form. See bug#3631508
--      open roles;  --  added for 3051285
--      fetch roles into l_resolving_role_name;
--      close roles;

    /*  commented and replaced with above FETCH for 3051285
    BEGIN  -- block and exception handler added for 2166974
      select name
      into l_resolving_role_name
      from wf_roles
      where display_name = p_resolving_role;
    EXCEPTION
      when too_many_rows then null;
    END;
    */

    l_process_name := p_Workflow_Process;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESS NAME IS : ' || L_PROCESS_NAME ) ;
        oe_debug_pub.add(  'RESOLVING ROLE IS : '|| L_RESOLVING_ROLE_NAME ) ;
        oe_debug_pub.add(  'USER TEXT IS :' || P_USER_TEXT ) ;
    END IF;

    -- Create the Change Order Item
    WF_ENGINE.CreateProcess(l_chgord_item_type,to_char(l_wf_item_key),l_process_name);

    -- Set the Change Order Item Attributes

/*     wf_engine.SetItemAttrText(l_chgord_item_type
                          , l_wf_item_key
                          , 'BOOKING_DOCUMENT'
                    , 'PLSQL:OE_CHG_ORDER_PVT.Generate_PLSQLDoc/' || l_wf_item_key);
*/
    wf_engine.SetItemAttrText(l_chgord_item_type
                          , l_wf_item_key
                          , 'USER_TEXT'
                          ,p_user_text);

   -- Set the resolving role for the constraint.

   WF_ENGINE.SetItemAttrText(l_chgord_item_type
                            ,l_wf_item_key
                            ,'RESOLVING_ROLE'
                            ,p_resolving_name);

   -- Retrieve the value of the order number from the global variable
   l_order_number := OE_CHG_ORDER_PVT.G_ORDER_NUMBER;
   oe_msg_pub.add('Order Number is: ' || l_order_number);

   -- Set the order number context for the message header

   WF_ENGINE.SetItemAttrNumber(l_chgord_item_type
                              ,l_wf_item_key
                              ,'ORDER_NUMBER'
                              , l_order_number);
/*
   l_document_body := wf_engine.GetItemAttrText(l_chgord_item_type
                                               , l_wf_item_key
                                               , 'BOOKING_DOCUMENT');

   oe_debug_pub.add('Value of document is :' || l_document_body);
*/

-- Bug number 6633740
 IF l_debug_level > 0 THEN
	oe_debug_pub.add(  'Assigning From user to workflow '|| FND_GLOBAL.USER_ID ) ;
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
				,l_wf_item_key
				,'NOTIFICATION_FROM_ROLE'
				,l_user_name);
  END IF;
-- Bug number 6633740

   WF_ENGINE.StartProcess(l_chgord_item_type, to_char(l_wf_item_key));

   -- Make a call to the StartChangeOrderFlow to start the change order process
   -- Start_ChangeOrderFlow(l_chgord_item_type, to_char(l_wf_item_key));

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING CREATE_CHGORDERWORKITEM' ) ;
  END IF;
commit;
EXCEPTION
WHEN OTHERS THEN
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
           OE_MSG_PUB.Add_Exc_Msg
           (   G_PKG_NAME
            , 'Create_ChgOrderWorkItem');
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

--oe_debug_pub.dumpdebug;
--oe_debug_pub.Debug_Off;

END Create_ChgOrderWorkItem;

-- This procedure is used to update the free form text entered by the
-- user in the Notification form and pass it to the PLSQL Document
-- buffer


PROCEDURE Update_User_Text(p_user_text in varchar2)

IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    -- Set The global variable to the user text entered in the UI
    OE_CHG_ORDER_PVT.G_USER_TEXT := p_user_text;

EXCEPTION
WHEN OTHERS THEN
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
           OE_MSG_PUB.Add_Exc_Msg
           (   G_PKG_NAME
            , 'Create_ChgOrderWorkItem');
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


END Update_User_Text;


PROCEDURE Update_Order_Number(p_order_number in NUMBER)

IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    -- Set The global variable to the user text entered in the UI
    OE_CHG_ORDER_PVT.G_ORDER_NUMBER := p_order_number;

EXCEPTION

WHEN OTHERS THEN
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
           OE_MSG_PUB.Add_Exc_Msg
           (   G_PKG_NAME
            , 'Create_ChgOrderWorkItem');
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

END Update_Order_Number;


-- This procedure is written to create a dynamic message
-- text for the notification sent to the resolving responsibility.
-- Based on the display type to be used by the end user for viewing
-- the notification, the message body will be formatted and displayed.

PROCEDURE Generate_PLSQLDoc(p_document_id in varchar2,
                            p_display_type in varchar2,
                            p_document in out NOCOPY /* file.sql.39 change */ varchar2,
                            p_document_type in out NOCOPY /* file.sql.39 change */ varchar2)
IS

   l_user_text  VARCHAR2(250);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INSIDE GENERATE PLSQL DOC' ) ;
   END IF;
   -- Set the document type based on the display type
   p_document_type := p_display_type;

   -- JPN: Replace this with p_document


  l_user_text := wf_engine.GetItemAttrText('OECHGORD'
                                               ,p_document_id
                                               , 'USER_TEXT');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'USER TEXT IS: ' || L_USER_TEXT ) ;
  END IF;

   -- p_document := OE_CHG_ORDER_PVT.G_USER_TEXT;
   p_document := l_user_text;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'VALUE OF THE P_DOCUMENT IS: '|| P_DOCUMENT ) ;
   END IF;

    -- p_document := 'Update of Line quantity';

   -- Create an HTML text buffer
   if (p_display_type = 'text/html') then

   -- Build the page body with the data
   p_document := htf.bold('Change Order Approval for: ') || p_document ;
   p_document_type := 'text/html';

   return;
   end if;

  -- Create a plain text buffer
  if (p_display_type = 'text/plain') then

  p_document := 'Change approval required for: ' || p_document;
  p_document_type := 'text/plain';

  return;
  end if;

EXCEPTION
     WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME
        , 'Generate_PLSQLDoc'
        );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

END Generate_PLSQLDoc;


Procedure RecordLineHist
  (p_line_id           In Number
  ,p_line_rec         In OE_ORDER_PUB.LINE_REC_TYPE
            := OE_Order_PUB.G_MISS_LINE_REC
  ,p_hist_type_code   In Varchar2
  ,p_reason_code      In varchar2
  ,p_comments         IN Varchar2
  ,p_audit_flag       IN Varchar2 := null
  ,p_version_flag     IN Varchar2 := null
  ,p_phase_change_flag       IN Varchar2 := null
  ,p_version_number IN NUMBER := null
  ,p_reason_id        IN NUMBER := NULL
  ,p_wf_activity_code IN Varchar2 := null
  ,p_wf_result_code   IN Varchar2 := null
  ,x_return_status    Out NOCOPY /* file.sql.39 change */ Varchar2
  ) IS
l_line_rec     OE_ORDER_PUB.LINE_REC_TYPE := OE_Order_PUB.G_MISS_LINE_REC;
l_err_text Varchar2(80);
l_line_id number := p_line_id;
l_index_id number;
l_result VARCHAR2(30);
l_new_ordered_quantity number;
l_latest_can_qty number ;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING RECORDLINEHIST' , 1 ) ;
   END IF;

   -- JPN: Added the G_MISS_NUM check before inserting the history record.
   if (p_line_rec.line_id is not null  AND
       p_line_rec.line_id <> FND_API.G_MISS_NUM) then
         l_line_id := p_line_rec.line_id;
         l_line_rec := p_line_rec;
   else
     -- query the line record
     OE_LINE_UTIL.Query_Row (p_line_id => l_line_id ,x_line_rec => l_line_rec);
   end if;
   IF p_line_rec.ordered_quantity <> FND_API.G_MISS_NUM AND
      p_line_rec.ordered_quantity IS NOT NULL THEN

         -- bug 3443676, derive new ordered quantity from global picture
         OE_Order_Util.Return_Glb_Ent_Index(p_entity_code => 'LINE', p_entity_id => l_line_id, x_index => l_index_id, x_result => l_result, x_return_status => x_return_status);

         IF l_result = FND_API.G_TRUE THEN
            l_new_ordered_quantity := OE_Order_Util.G_Line_Tbl(l_index_id).ordered_quantity;
         ELSE
            l_new_ordered_quantity := p_line_rec.ordered_quantity;
         END IF;

         IF l_new_ordered_quantity < l_line_rec.ordered_quantity THEN
            l_latest_can_qty := l_line_rec.ordered_quantity - l_new_ordered_quantity ;
         END IF;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INSERTING HISTORY FOR LINE ID : '|| TO_CHAR ( P_LINE_ID ) , 5 ) ;
   END IF;
   -- OPM 02/JUN/2000 add 3 process attributes
   BEGIN
      l_err_text := null;
      INSERT INTO OE_ORDER_LINES_HISTORY (
	    Line_Id
   ,        WF_ACTIVITY_CODE
   ,        WF_RESULT_CODE
   ,        REASON_CODE
   ,        HIST_COMMENTS
   ,        HIST_TYPE_CODE
   ,        HIST_CREATION_DATE
   ,        HIST_CREATED_BY
   ,        latest_cancelled_quantity
   ,        ACCOUNTING_RULE_ID
   ,        ACCOUNTING_RULE_DURATION
    ,       ACTUAL_ARRIVAL_DATE
    ,       ACTUAL_SHIPMENT_DATE
    ,       AGREEMENT_ID
    ,       ARRIVAL_SET_ID
    ,       ATO_LINE_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE16   --For bug 2184255
    ,       ATTRIBUTE17
    ,       ATTRIBUTE18
    ,       ATTRIBUTE19
    ,       ATTRIBUTE2
    ,       ATTRIBUTE20
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       AUTO_SELECTED_QUANTITY
    ,       AUTHORIZED_TO_SHIP_FLAG
    ,       BLANKET_NUMBER
    ,       BLANKET_LINE_NUMBER
    ,       BLANKET_VERSION_NUMBER
    ,       BOOKED_FLAG
    ,       CANCELLED_FLAG
    ,       CANCELLED_QUANTITY
    ,       COMPONENT_CODE
    ,       COMPONENT_NUMBER
    ,       COMPONENT_SEQUENCE_ID
    ,       CONFIG_HEADER_ID
    ,       CONFIG_REV_NBR
    ,       CONFIG_DISPLAY_SEQUENCE
    ,       CONFIGURATION_ID
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CREDIT_INVOICE_LINE_ID
    ,       CUSTOMER_LINE_NUMBER
    ,       CUSTOMER_SHIPMENT_NUMBER
    ,       CUSTOMER_ITEM_NET_PRICE
    ,       CUSTOMER_PAYMENT_TERM_ID
    ,       CUSTOMER_DOCK_CODE
    ,       CUSTOMER_JOB
    ,       CUSTOMER_PRODUCTION_LINE
    ,       CUST_PRODUCTION_SEQ_NUM
    ,       CUSTOMER_TRX_LINE_ID
    ,       CUST_MODEL_SERIAL_NUMBER
    ,       CUST_PO_NUMBER
    ,       DELIVERY_LEAD_TIME
    ,       DELIVER_TO_CONTACT_ID
    ,       DELIVER_TO_ORG_ID
    ,       DEMAND_BUCKET_TYPE_CODE
    ,       DEMAND_CLASS_CODE
    ,       DEP_PLAN_REQUIRED_FLAG
    ,       DROP_SHIP_FLAG
    ,       EARLIEST_ACCEPTABLE_DATE
    ,       END_ITEM_UNIT_NUMBER
    ,       EXPLOSION_DATE
    ,       FIRST_ACK_CODE
    ,       FIRST_ACK_DATE
    ,       FOB_POINT_CODE
    ,       FREIGHT_CARRIER_CODE
    ,       FREIGHT_TERMS_CODE
    ,       FULFILLED_QUANTITY
    ,       FULFILLED_FLAG
    ,       FULFILLMENT_METHOD_CODE
    ,       GLOBAL_ATTRIBUTE1
    ,       GLOBAL_ATTRIBUTE10
    ,       GLOBAL_ATTRIBUTE11
    ,       GLOBAL_ATTRIBUTE12
    ,       GLOBAL_ATTRIBUTE13
    ,       GLOBAL_ATTRIBUTE14
    ,       GLOBAL_ATTRIBUTE15
    ,       GLOBAL_ATTRIBUTE16
    ,       GLOBAL_ATTRIBUTE17
    ,       GLOBAL_ATTRIBUTE18
    ,       GLOBAL_ATTRIBUTE19
    ,       GLOBAL_ATTRIBUTE2
    ,       GLOBAL_ATTRIBUTE20
    ,       GLOBAL_ATTRIBUTE3
    ,       GLOBAL_ATTRIBUTE4
    ,       GLOBAL_ATTRIBUTE5
    ,       GLOBAL_ATTRIBUTE6
    ,       GLOBAL_ATTRIBUTE7
    ,       GLOBAL_ATTRIBUTE8
    ,       GLOBAL_ATTRIBUTE9
    ,       GLOBAL_ATTRIBUTE_CATEGORY
    ,       HEADER_ID
    ,       INDUSTRY_ATTRIBUTE1
    ,       INDUSTRY_ATTRIBUTE10
    ,       INDUSTRY_ATTRIBUTE11
    ,       INDUSTRY_ATTRIBUTE12
    ,       INDUSTRY_ATTRIBUTE13
    ,       INDUSTRY_ATTRIBUTE14
    ,       INDUSTRY_ATTRIBUTE15
    ,       INDUSTRY_ATTRIBUTE16
    ,       INDUSTRY_ATTRIBUTE17
    ,       INDUSTRY_ATTRIBUTE18
    ,       INDUSTRY_ATTRIBUTE19
    ,       INDUSTRY_ATTRIBUTE20
    ,       INDUSTRY_ATTRIBUTE21
    ,       INDUSTRY_ATTRIBUTE22
    ,       INDUSTRY_ATTRIBUTE23
    ,       INDUSTRY_ATTRIBUTE24
    ,       INDUSTRY_ATTRIBUTE25
    ,       INDUSTRY_ATTRIBUTE26
    ,       INDUSTRY_ATTRIBUTE27
    ,       INDUSTRY_ATTRIBUTE28
    ,       INDUSTRY_ATTRIBUTE29
    ,       INDUSTRY_ATTRIBUTE30
    ,       INDUSTRY_ATTRIBUTE2
    ,       INDUSTRY_ATTRIBUTE3
    ,       INDUSTRY_ATTRIBUTE4
    ,       INDUSTRY_ATTRIBUTE5
    ,       INDUSTRY_ATTRIBUTE6
    ,       INDUSTRY_ATTRIBUTE7
    ,       INDUSTRY_ATTRIBUTE8
    ,       INDUSTRY_ATTRIBUTE9
    ,       INDUSTRY_CONTEXT
    ,       INTMED_SHIP_TO_CONTACT_ID
    ,       INTMED_SHIP_TO_ORG_ID
    ,       INVENTORY_ITEM_ID
    ,       INVOICE_INTERFACE_STATUS_CODE
    ,       INVOICE_TO_CONTACT_ID
    ,       INVOICE_TO_ORG_ID
    ,       INVOICED_QUANTITY
    ,       INVOICING_RULE_ID
    ,       ORDERED_ITEM_ID
    ,       ITEM_IDENTIFIER_TYPE
    ,       ORDERED_ITEM
    ,       ITEM_REVISION
    ,       ITEM_TYPE_CODE
    ,       LAST_ACK_CODE
    ,       LAST_ACK_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LATEST_ACCEPTABLE_DATE
    ,       LINE_CATEGORY_CODE
    ,       LINE_NUMBER
    ,       LINE_TYPE_ID
    ,       LINK_TO_LINE_ID
    ,       MODEL_GROUP_NUMBER
    ,       MFG_COMPONENT_SEQUENCE_ID
    ,       OPEN_FLAG
    ,       OPTION_FLAG
    ,       OPTION_NUMBER
    ,       ORDERED_QUANTITY
    ,       ORDERED_QUANTITY2      -- OPM 02/JUN/00
    ,       ORDER_QUANTITY_UOM
    ,       ORDERED_QUANTITY_UOM2  -- OPM 02/JUN/00
    --,       ORG_ID
    ,       ORDER_SOURCE_ID
    ,       ORIG_SYS_DOCUMENT_REF
    ,       ORIG_SYS_LINE_REF
    ,       ORIG_SYS_SHIPMENT_REF
    ,       CHANGE_SEQUENCE
    ,       OVER_SHIP_REASON_CODE
    ,       OVER_SHIP_RESOLVED_FLAG
    ,       PAYMENT_TERM_ID
    ,       PLANNING_PRIORITY
    ,       PREFERRED_GRADE        -- OPM 02/JUN/00
    ,       PRICE_LIST_ID
    ,       PRICE_REQUEST_CODE     -- PROMOTIONS SEP/01
    ,       PRICING_ATTRIBUTE1
    ,       PRICING_ATTRIBUTE10
    ,       PRICING_ATTRIBUTE2
    ,       PRICING_ATTRIBUTE3
    ,       PRICING_ATTRIBUTE4
    ,       PRICING_ATTRIBUTE5
    ,       PRICING_ATTRIBUTE6
    ,       PRICING_ATTRIBUTE7
    ,       PRICING_ATTRIBUTE8
    ,       PRICING_ATTRIBUTE9
    ,       PRICING_CONTEXT
    ,       PRICING_DATE
    ,       PRICING_QUANTITY
    ,       PRICING_QUANTITY_UOM
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PROJECT_ID
    ,       PROMISE_DATE
    ,       RE_SOURCE_FLAG
    ,       REFERENCE_CUSTOMER_TRX_LINE_ID
    ,       REFERENCE_HEADER_ID
    ,       REFERENCE_LINE_ID
    ,       REFERENCE_TYPE
    ,       REQUEST_DATE
    ,       REQUEST_ID
    ,       RETURN_ATTRIBUTE1
    ,       RETURN_ATTRIBUTE10
    ,       RETURN_ATTRIBUTE11
    ,       RETURN_ATTRIBUTE12
    ,       RETURN_ATTRIBUTE13
    ,       RETURN_ATTRIBUTE14
    ,       RETURN_ATTRIBUTE15
    ,       RETURN_ATTRIBUTE2
    ,       RETURN_ATTRIBUTE3
    ,       RETURN_ATTRIBUTE4
    ,       RETURN_ATTRIBUTE5
    ,       RETURN_ATTRIBUTE6
    ,       RETURN_ATTRIBUTE7
    ,       RETURN_ATTRIBUTE8
    ,       RETURN_ATTRIBUTE9
    ,       RETURN_CONTEXT
    ,       RETURN_REASON_CODE
    ,       RLA_SCHEDULE_TYPE_CODE
    ,       SALESREP_ID
    ,       SCHEDULE_ARRIVAL_DATE
    ,       SCHEDULE_SHIP_DATE
    ,       SCHEDULE_STATUS_CODE
    ,       SHIPMENT_NUMBER
    ,       SHIPMENT_PRIORITY_CODE
    ,       SHIPPED_QUANTITY
    ,       SHIPPING_METHOD_CODE
    ,       SHIPPING_QUANTITY
    ,       SHIPPING_QUANTITY_UOM
    ,       SHIP_FROM_ORG_ID
    ,       SUBINVENTORY
    ,       SHIP_SET_ID
    ,       SHIP_TOLERANCE_ABOVE
    ,       SHIP_TOLERANCE_BELOW
    ,       SHIPPABLE_FLAG
    ,       SHIPPING_INTERFACED_FLAG
    ,       SHIP_TO_CONTACT_ID
    ,       SHIP_TO_ORG_ID
    ,       SHIP_MODEL_COMPLETE_FLAG
    ,       SOLD_TO_ORG_ID
    ,       SOLD_FROM_ORG_ID
    ,       SORT_ORDER
    ,       SOURCE_DOCUMENT_ID
    ,       SOURCE_DOCUMENT_LINE_ID
    ,       SOURCE_DOCUMENT_TYPE_ID
    ,       SOURCE_TYPE_CODE
    ,       SPLIT_FROM_LINE_ID
    ,       LINE_SET_ID
    ,       SPLIT_BY
    ,       model_remnant_flag
    ,       TASK_ID
    ,       TAX_CODE
    ,       TAX_DATE
    ,       TAX_EXEMPT_FLAG
    ,       TAX_EXEMPT_NUMBER
    ,       TAX_EXEMPT_REASON_CODE
    ,       TAX_POINT_CODE
    ,       TAX_RATE
    ,       TAX_VALUE
    ,       TOP_MODEL_LINE_ID
    ,       UNIT_LIST_PRICE
    ,       UNIT_SELLING_PRICE
    ,       VISIBLE_DEMAND_FLAG
    ,       VEH_CUS_ITEM_CUM_KEY_ID
    ,       SHIPPING_INSTRUCTIONS
    ,       PACKING_INSTRUCTIONS
    ,       SERVICE_TXN_REASON_CODE
    ,       SERVICE_TXN_COMMENTS
    ,       SERVICE_DURATION
    ,       SERVICE_PERIOD
    ,       SERVICE_START_DATE
    ,       SERVICE_END_DATE
    ,       SERVICE_COTERMINATE_FLAG
    ,       UNIT_LIST_PERCENT
    ,       UNIT_SELLING_PERCENT
    ,       UNIT_PERCENT_BASE_PRICE
    ,       SERVICE_NUMBER
    ,       SERVICE_REFERENCE_LINE_ID
    ,       TP_CONTEXT
    ,       TP_ATTRIBUTE1
    ,       TP_ATTRIBUTE2
    ,       TP_ATTRIBUTE3
    ,       TP_ATTRIBUTE4
    ,       TP_ATTRIBUTE5
    ,       TP_ATTRIBUTE6
    ,       TP_ATTRIBUTE7
    ,       TP_ATTRIBUTE8
    ,       TP_ATTRIBUTE9
    ,       TP_ATTRIBUTE10
    ,       TP_ATTRIBUTE11
    ,       TP_ATTRIBUTE12
    ,       TP_ATTRIBUTE13
    ,       TP_ATTRIBUTE14
    ,       TP_ATTRIBUTE15
    ,       FLOW_STATUS_CODE
    ,       RESPONSIBILITY_ID
    ,       ORIGINAL_INVENTORY_ITEM_ID
    ,       ORIGINAL_ITEM_IDENTIFIER_TYPE
    ,       ORIGINAL_ORDERED_ITEM_ID
    ,       ORIGINAL_ORDERED_ITEM
    ,       ITEM_RELATIONSHIP_TYPE
    ,       ITEM_SUBSTITUTION_TYPE_CODE
    ,       LATE_DEMAND_PENALTY_FACTOR
    ,       OVERRIDE_ATP_DATE_CODE
    ,       USER_ITEM_DESCRIPTION
    -- QUOTING changes
    ,       TRANSACTION_PHASE_CODE
    ,       SOURCE_DOCUMENT_VERSION_NUMBER
    -- QUOTING changes END
    -- VERSIONING changes
    ,       AUDIT_FLAG
    ,       VERSION_FLAG
    ,       PHASE_CHANGE_FLAG
    ,       VERSION_NUMBER
    ,       REASON_ID
    -- VERSIONING changes END
    ,       ORIGINAL_LIST_PRICE -- Override List Price
  --Key Transaction Dates
    ,      order_firmed_date
    ,      actual_fulfillment_date
    --recurring charges
    ,      charge_periodicity_code
    --Customer Acceptance
    ,      Contingency_id
    ,      Revrec_event_code
    ,      Revrec_Expiration_days
    ,      Accepted_By
    ,      Accepted_Quantity
    ,      Revrec_comments
    ,      Revrec_reference_document
    ,      Revrec_signature
    ,      Revrec_signature_date
    ,      Revrec_implicit_flag
    ,      calculate_price_flag    --8652094
    )
   VALUES
    (
            l_line_rec.line_id
    ,       p_wf_activity_code
    ,       P_WF_RESULT_CODE
    ,       P_REASON_CODE
    ,       P_COMMENTS
    ,       P_HIST_TYPE_CODE
    ,       sysdate
    ,       nvl(FND_GLOBAL.USER_ID, -1)
    ,       l_latest_can_qty
    ,       l_line_rec.accounting_rule_id
    ,       l_line_rec.accounting_rule_duration
    ,       l_line_rec.actual_arrival_date
    ,       l_line_rec.actual_shipment_date
    ,       l_line_rec.agreement_id
    ,       l_line_rec.arrival_set_id
    ,       l_line_rec.ato_line_id
    ,       l_line_rec.attribute1
    ,       l_line_rec.attribute10
    ,       l_line_rec.attribute11
    ,       l_line_rec.attribute12
    ,       l_line_rec.attribute13
    ,       l_line_rec.attribute14
    ,       l_line_rec.attribute15
    ,       l_line_rec.attribute16   --For bug 2184255
    ,       l_line_rec.attribute17
    ,       l_line_rec.attribute18
    ,       l_line_rec.attribute19
    ,       l_line_rec.attribute2
    ,       l_line_rec.attribute20
    ,       l_line_rec.attribute3
    ,       l_line_rec.attribute4
    ,       l_line_rec.attribute5
    ,       l_line_rec.attribute6
    ,       l_line_rec.attribute7
    ,       l_line_rec.attribute8
    ,       l_line_rec.attribute9
    ,       l_line_rec.auto_selected_quantity
    ,       l_line_rec.authorized_to_ship_flag
    ,       l_line_rec.blanket_number
    ,       l_line_rec.blanket_line_number
    ,       l_line_rec.blanket_version_number
    ,       l_line_rec.booked_flag
    ,       l_line_rec.cancelled_flag
    ,       l_line_rec.cancelled_quantity
    ,       l_line_rec.component_code
    ,       l_line_rec.component_number
    ,       l_line_rec.component_sequence_id
    ,       l_line_rec.config_header_id
    ,       l_line_rec.config_rev_nbr
    ,       l_line_rec.config_display_sequence
    ,       l_line_rec.configuration_id
    ,       l_line_rec.context
    ,       l_line_rec.created_by
    ,       l_line_rec.creation_date
    ,       l_line_rec.credit_invoice_line_id
    ,       l_line_rec.customer_line_number
    ,       l_line_rec.customer_shipment_number
    ,       l_line_rec.customer_item_net_price
    ,       l_line_rec.customer_payment_term_id
    ,       l_line_rec.customer_dock_code
    ,       l_line_rec.customer_job
    ,       l_line_rec.customer_production_line
    ,       l_line_rec.cust_production_seq_num
    ,       l_line_rec.customer_trx_line_id
    ,       l_line_rec.cust_model_serial_number
    ,       l_line_rec.cust_po_number
    ,       l_line_rec.delivery_lead_time
    ,       l_line_rec.deliver_to_contact_id
    ,       l_line_rec.deliver_to_org_id
    ,       l_line_rec.demand_bucket_type_code
    ,       l_line_rec.demand_class_code
    ,       l_line_rec.dep_plan_required_flag
    ,       l_line_rec.drop_ship_flag
    ,       l_line_rec.earliest_acceptable_date
    ,       l_line_rec.end_item_unit_number
    ,       l_line_rec.explosion_date
    ,       l_line_rec.first_ack_code
    ,       l_line_rec.first_ack_date
    ,       l_line_rec.fob_point_code
    ,       l_line_rec.freight_carrier_code
    ,       l_line_rec.freight_terms_code
    ,       l_line_rec.fulfilled_quantity
    ,       l_line_rec.fulfilled_flag
    ,       l_line_rec.fulfillment_method_code
    ,       l_line_rec.global_attribute1
    ,       l_line_rec.global_attribute10
    ,       l_line_rec.global_attribute11
    ,       l_line_rec.global_attribute12
    ,       l_line_rec.global_attribute13
    ,       l_line_rec.global_attribute14
    ,       l_line_rec.global_attribute15
    ,       l_line_rec.global_attribute16
    ,       l_line_rec.global_attribute17
    ,       l_line_rec.global_attribute18
    ,       l_line_rec.global_attribute19
    ,       l_line_rec.global_attribute2
    ,       l_line_rec.global_attribute20
    ,       l_line_rec.global_attribute3
    ,       l_line_rec.global_attribute4
    ,       l_line_rec.global_attribute5
    ,       l_line_rec.global_attribute6
    ,       l_line_rec.global_attribute7
    ,       l_line_rec.global_attribute8
    ,       l_line_rec.global_attribute9
    ,       l_line_rec.global_attribute_category
    ,       l_line_rec.header_id
    ,       l_line_rec.industry_attribute1
    ,       l_line_rec.industry_attribute10
    ,       l_line_rec.industry_attribute11
    ,       l_line_rec.industry_attribute12
    ,       l_line_rec.industry_attribute13
    ,       l_line_rec.industry_attribute14
    ,       l_line_rec.industry_attribute15
    ,       l_line_rec.industry_attribute16
    ,       l_line_rec.industry_attribute17
    ,       l_line_rec.industry_attribute18
    ,       l_line_rec.industry_attribute19
    ,       l_line_rec.industry_attribute20
    ,       l_line_rec.industry_attribute21
    ,       l_line_rec.industry_attribute22
    ,       l_line_rec.industry_attribute23
    ,       l_line_rec.industry_attribute24
    ,       l_line_rec.industry_attribute25
    ,       l_line_rec.industry_attribute26
    ,       l_line_rec.industry_attribute27
    ,       l_line_rec.industry_attribute28
    ,       l_line_rec.industry_attribute29
    ,       l_line_rec.industry_attribute30
    ,       l_line_rec.industry_attribute2
    ,       l_line_rec.industry_attribute3
    ,       l_line_rec.industry_attribute4
    ,       l_line_rec.industry_attribute5
    ,       l_line_rec.industry_attribute6
    ,       l_line_rec.industry_attribute7
    ,       l_line_rec.industry_attribute8
    ,       l_line_rec.industry_attribute9
    ,       l_line_rec.industry_context
    ,       l_line_rec.intermed_ship_to_contact_id
    ,       l_line_rec.intermed_ship_to_org_id
    ,       l_line_rec.inventory_item_id
    ,       l_line_rec.invoice_interface_status_code
    ,       l_line_rec.invoice_to_contact_id
    ,       l_line_rec.invoice_to_org_id
    ,       l_line_rec.invoiced_quantity
    ,       l_line_rec.invoicing_rule_id
    ,       l_line_rec.ordered_item_id
    ,       l_line_rec.item_identifier_type
    ,       l_line_rec.ordered_item
    ,       l_line_rec.item_revision
    ,       l_line_rec.item_type_code
    ,       l_line_rec.last_ack_code
    ,       l_line_rec.last_ack_date
    ,       l_line_rec.last_updated_by
    ,       l_line_rec.last_update_date
    ,       l_line_rec.last_update_login
    ,       l_line_rec.latest_acceptable_date
    ,       l_line_rec.line_category_code
    ,       l_line_rec.line_number
    ,       l_line_rec.line_type_id
    ,       l_line_rec.link_to_line_id
    ,       l_line_rec.model_group_number
    ,       l_line_rec.mfg_component_sequence_id
    ,       l_line_rec.open_flag
    ,       l_line_rec.option_flag
    ,       l_line_rec.option_number
    ,       l_line_rec.ordered_quantity
    ,       l_line_rec.ordered_quantity2            -- OPM 02/JUN/00
    ,       l_line_rec.order_quantity_uom
    ,       l_line_rec.ordered_quantity_uom2        -- OPM 02/JUN/00
    --,       l_line_rec.org_id
    ,       l_line_rec.order_source_id
     ,      l_line_rec.orig_sys_document_ref
    ,       l_line_rec.orig_sys_line_ref
    ,       l_line_rec.orig_sys_shipment_ref
    ,       l_line_rec.change_sequence
    ,       l_line_rec.over_ship_reason_code
    ,       l_line_rec.over_ship_resolved_flag
    ,       l_line_rec.payment_term_id
    ,       l_line_rec.planning_priority
    ,       l_line_rec.preferred_grade              -- OPM 02/JUN/00
    ,       l_line_rec.price_list_id
    ,       l_line_rec.price_request_code       -- PROMOTIONS SEP/01
    ,       l_line_rec.pricing_attribute1
    ,       l_line_rec.pricing_attribute10
    ,       l_line_rec.pricing_attribute2
    ,       l_line_rec.pricing_attribute3
    ,       l_line_rec.pricing_attribute4
    ,       l_line_rec.pricing_attribute5
    ,       l_line_rec.pricing_attribute6
    ,       l_line_rec.pricing_attribute7
    ,       l_line_rec.pricing_attribute8
    ,       l_line_rec.pricing_attribute9
    ,       l_line_rec.pricing_context
    ,       l_line_rec.pricing_date
    ,       l_line_rec.pricing_quantity
    ,       l_line_rec.pricing_quantity_uom
    ,       l_line_rec.program_application_id
    ,       l_line_rec.program_id
    ,       l_line_rec.program_update_date
    ,       l_line_rec.project_id
    ,       l_line_rec.promise_date
    ,       l_line_rec.re_source_flag
    ,       l_line_rec.reference_customer_trx_line_id
    ,       l_line_rec.reference_header_id
    ,       l_line_rec.reference_line_id
    ,       l_line_rec.reference_type
    ,       l_line_rec.request_date
    ,       l_line_rec.request_id
    ,       l_line_rec.return_attribute1
    ,       l_line_rec.return_attribute10
    ,       l_line_rec.return_attribute11
    ,       l_line_rec.return_attribute12
    ,       l_line_rec.return_attribute13
    ,       l_line_rec.return_attribute14
    ,       l_line_rec.return_attribute15
    ,       l_line_rec.return_attribute2
    ,       l_line_rec.return_attribute3
    ,       l_line_rec.return_attribute4
    ,       l_line_rec.return_attribute5
    ,       l_line_rec.return_attribute6
    ,       l_line_rec.return_attribute7
    ,       l_line_rec.return_attribute8
    ,       l_line_rec.return_attribute9
    ,       l_line_rec.return_context
    ,       l_line_rec.return_reason_code
    ,       l_line_rec.rla_schedule_type_code
    ,       l_line_rec.salesrep_id
    ,       l_line_rec.schedule_arrival_date
    ,       l_line_rec.schedule_ship_date
    ,       l_line_rec.schedule_status_code
    ,       l_line_rec.shipment_number
    ,       l_line_rec.shipment_priority_code
    ,       l_line_rec.shipped_quantity
    ,       l_line_rec.shipping_method_code
    ,       l_line_rec.shipping_quantity
    ,       l_line_rec.shipping_quantity_uom
    ,       l_line_rec.ship_from_org_id
    ,       l_line_rec.subinventory
    ,       l_line_rec.ship_set_id
    ,       l_line_rec.ship_tolerance_above
    ,       l_line_rec.ship_tolerance_below
    ,       l_line_rec.shippable_flag
    ,       l_line_rec.shipping_interfaced_flag
    ,       l_line_rec.ship_to_contact_id
    ,       l_line_rec.ship_to_org_id
    ,       l_line_rec.ship_model_complete_flag
    ,       l_line_rec.sold_to_org_id
    ,       l_line_rec.sold_from_org_id
    ,       l_line_rec.sort_order
    ,       l_line_rec.source_document_id
    ,       l_line_rec.source_document_line_id
    ,       l_line_rec.source_document_type_id
    ,       l_line_rec.source_type_code
    ,       l_line_rec.split_from_line_id
    ,       l_line_rec.line_set_id
    ,       l_line_rec.split_by
    ,       l_line_rec.model_remnant_flag
    ,       l_line_rec.task_id
    ,       l_line_rec.tax_code
    ,       l_line_rec.tax_date
    ,       l_line_rec.tax_exempt_flag
    ,       l_line_rec.tax_exempt_number
    ,       l_line_rec.tax_exempt_reason_code
    ,       l_line_rec.tax_point_code
    ,       l_line_rec.tax_rate
    ,       l_line_rec.tax_value
    ,       l_line_rec.top_model_line_id
    ,       l_line_rec.unit_list_price
    ,       l_line_rec.unit_selling_price
    ,       l_line_rec.visible_demand_flag
    ,       l_line_rec.veh_cus_item_cum_key_id
    ,       l_line_rec.shipping_instructions
    ,       l_line_rec.packing_instructions
    ,       l_line_rec.service_txn_reason_code
    ,       l_line_rec.service_txn_comments
    ,       l_line_rec.service_duration
    ,       l_line_rec.service_period
    ,       l_line_rec.service_start_date
    ,       l_line_rec.service_end_date
    ,       l_line_rec.service_coterminate_flag
    ,       l_line_rec.unit_list_percent
    ,       l_line_rec.unit_selling_percent
    ,       l_line_rec.unit_percent_base_price
     ,      l_line_rec.service_number
    ,       l_line_rec.service_reference_line_id
    ,       l_line_rec.tp_context
    ,       l_line_rec.tp_attribute1
    ,       l_line_rec.tp_attribute2
    ,       l_line_rec.tp_attribute3
    ,       l_line_rec.tp_attribute4
    ,       l_line_rec.tp_attribute5
    ,       l_line_rec.tp_attribute6
    ,       l_line_rec.tp_attribute7
    ,       l_line_rec.tp_attribute8
    ,       l_line_rec.tp_attribute9
    ,       l_line_rec.tp_attribute10
    ,       l_line_rec.tp_attribute11
    ,       l_line_rec.tp_attribute12
    ,       l_line_rec.tp_attribute13
    ,       l_line_rec.tp_attribute14
    ,       l_line_rec.tp_attribute15
    ,       l_line_rec.flow_status_code
    ,       nvl(FND_GLOBAL.RESP_ID, -1)
    ,       l_line_rec.original_inventory_item_id
    ,       l_line_rec.original_item_identifier_Type
    ,       l_line_rec.original_ordered_item_id
    ,       l_line_rec.original_ordered_item
    ,       l_line_rec.item_relationship_type
    ,       l_line_rec.item_substitution_type_code
    ,       l_line_rec.late_demand_penalty_factor
    ,       l_line_rec.Override_atp_date_code
    ,       l_line_rec.user_item_description
    -- QUOTING changes
    ,       l_line_rec.TRANSACTION_PHASE_CODE
    ,       l_line_rec.SOURCE_DOCUMENT_VERSION_NUMBER
    -- QUOTING changes END
    -- VERSIONING changes
    ,       p_AUDIT_FLAG
    ,       p_VERSION_FLAG
    ,       p_PHASE_CHANGE_FLAG
    ,       p_VERSION_NUMBER
    ,       p_reason_id
    -- VERSIONING changes END
    ,       l_line_rec.ORIGINAL_LIST_PRICE  -- Override List Price
  --key transaction dates
    ,       l_line_rec.order_firmed_date
    ,       l_line_rec.actual_fulfillment_date
    --recurring charges
    ,       l_line_rec.charge_periodicity_code
    --Customer Acceptance
    ,       l_line_rec.Contingency_id
    ,       l_line_rec.Revrec_event_code
    ,       l_line_rec.Revrec_Expiration_days
    ,       l_line_rec.Accepted_By
    ,       l_line_rec.Accepted_Quantity
    ,       l_line_rec.Revrec_comments
    ,       l_line_rec.Revrec_reference_document
    ,       l_line_rec.Revrec_signature
    ,       l_line_rec.Revrec_signature_date
    ,       l_line_rec.Revrec_implicit_flag
    ,       l_line_rec.calculate_price_flag     --8652094
    );

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'SUCCESSFULLY INSERTED LINE HISTORY RECORD' ) ;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'N';
   OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
   -- oe_sales_can_util.G_REQUIRE_REASON := FALSE;
   EXCEPTION WHEN OTHERS THEN
	     l_err_text := substr(SQLERRM,1,74);
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'ERROR:'||L_ERR_TEXT , 5 ) ;
                 oe_debug_pub.add(  'HIST_TYPE_CODE VALUE:' || P_HIST_TYPE_CODE , 5 ) ;
                 oe_debug_pub.add(  'IN INNER EXCEPTION' , 5 ) ;
             END IF;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR; -- nocopy analysis
   END;
EXCEPTION
    -- to fix bug 2295947
    WHEN NO_DATA_FOUND THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AUDIT HISTORY: DID NOT INSERT FOR LINE ID : '||P_LINE_ID , 1 ) ;
             oe_debug_pub.add(  'NO DATA FOUND ' , 1 ) ;
         END IF;
         NULL;
         x_return_status := FND_API.G_RET_STS_SUCCESS;
    WHEN OTHERS THEN
	l_err_text := substr(SQLERRM,1,74);
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ERROR:'||L_ERR_TEXT , 5 ) ;
            oe_debug_pub.add(  'IN OUTER EXCEPTION' , 5 ) ;
            oe_debug_pub.add(  'HIST_TYPE_CODE VALUE:' || P_HIST_TYPE_CODE , 5 ) ;
        END IF;
        IF FND_MSG_PUB.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,'RecordLineHist');
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ERROR WHILE INSERTING LINE HISTORY RECORD' ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END RecordLineHist;

Procedure RecordHeaderHist
  (p_header_id        In Number
  ,p_header_rec       In OE_ORDER_PUB.HEADER_REC_TYPE := OE_Order_PUB.G_MISS_HEADER_REC
  ,p_hist_type_code   In Varchar2
  ,p_reason_code      In varchar2
  ,p_comments         IN Varchar2
  ,p_audit_flag       IN Varchar2 := null
  ,p_version_flag     IN Varchar2 := null
  ,p_phase_change_flag       IN Varchar2 := null
  ,p_version_number IN NUMBER := null
  ,p_reason_id        IN NUMBER := NULL
  ,p_wf_activity_code IN Varchar2 := null
  ,p_wf_result_code   IN Varchar2 := null
  ,p_changed_attribute IN varchar2 := null
  ,x_return_status    Out NOCOPY /* file.sql.39 change */ Varchar2
  ) IS
l_header_rec     OE_ORDER_PUB.HEADER_REC_TYPE := OE_Order_PUB.G_MISS_HEADER_REC;
l_credit_card_number	varchar2(10);
l_credit_card_code	varchar2(10);
l_instrument_id		number;
l_credit_card_holder_name varchar2(10);
l_credit_card_expiration_date date;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   if (p_header_rec.header_id is not null  AND
          p_header_rec.header_id <> FND_API.G_MISS_NUM) then
      l_header_rec := p_header_rec;
   else
      -- query the header record
      l_header_rec := OE_HEADER_UTIL.Query_Row
        (p_header_id          => p_header_id
        );
   end if;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'RECORDHEADERHIST:INSERT A ROW FOR HEADER ID : ' || TO_CHAR ( P_HEADER_ID ) ) ;
   END IF;


   -- for credit card orders, only instrument id is stored for credit card number
   -- and credit card code, need to set these two values to indicate the column
   -- instrument_id stores actual instrument_id, otherwise it stores the
   -- card history change id if other card attributes are being changed.
   IF l_header_rec.cc_instrument_id IS NOT NULL THEN
       -- store the instrument_id in column instruemnt_id
       -- if credit_card_number or credit_card_code is updated.
       l_instrument_id := l_header_rec.cc_instrument_id;

     IF p_changed_attribute IS NOT NULL  THEN

       IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'p_changed_attr is : ' || p_changed_attribute) ;
       END IF;

       -- store the instrument_id in column instruemnt_id
       -- if credit_card_number or credit_card_code is updated.
       IF instr(p_changed_attribute, 'CREDIT_CARD_NUMBER') > 0 THEN
         l_credit_card_number := '****';
       END IF;

       IF instr(p_changed_attribute, 'CREDIT_CARD_CODE') > 0 THEN
         l_credit_card_code := '****';
       END IF;

       IF instr(p_changed_attribute, 'CREDIT_CARD_HOLDER_NAME') > 0 THEN
         l_credit_card_holder_name := '****';
       END IF;

       IF instr(p_changed_attribute, 'CREDIT_CARD_EXPIRATION_DATE') > 0 THEN
         l_credit_card_expiration_date := sysdate;
       END IF;

      -- need to store card_history_change_id in column instrument_id
      -- if credit_card_expiration_date or credit_card_holder_name is updated

       IF l_credit_card_code IS NULL AND  l_credit_card_number IS NULL THEN
         BEGIN
         SELECT max(card_history_change_id)
         INTO   l_instrument_id
         FROM   iby_creditcard_h
         WHERE  instrid = l_header_rec.cc_instrument_id;
         EXCEPTION WHEN NO_DATA_FOUND THEN
           NULL;
         END;

       END IF;
     ELSIF p_changed_attribute IS NULL THEN
        -- none of the credit card attributes has changed.
        l_credit_card_number := '****';
        l_credit_card_code := '****';
        l_credit_card_holder_name := '****';
        l_credit_card_expiration_date := sysdate;

     END IF;

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'RECORDHEADERHIST:l_instrument_id is : ' || l_instrument_id) ;
       --oe_debug_pub.add(  'RECORDHEADERHIST:l_credit_card_code is : ' || l_credit_card_code) ;
       --oe_debug_pub.add(  'RECORDHEADERHIST:l_credit_card_number is : ' || l_credit_card_number) ;
       --oe_debug_pub.add(  'RECORDHEADERHIST:l_credit_card_holder_name is : ' || l_credit_card_holder_name) ;
       --oe_debug_pub.add(  'RECORDHEADERHIST:l_credit_card_expiration_date is : ' || l_credit_card_expiration_date) ;
     END IF;
   END IF;


  INSERT INTO OE_ORDER_HEADER_HISTORY
  (
  HEADER_ID                  ,
  ORG_ID                     ,
  ORDER_TYPE_ID              ,
  ORDER_NUMBER               ,
  VERSION_NUMBER             ,
  EXPIRATION_DATE            ,
  ORDER_SOURCE_ID            ,
  SOURCE_DOCUMENT_TYPE_ID    ,
  ORIG_SYS_DOCUMENT_REF      ,
  SOURCE_DOCUMENT_ID         ,
  ORDERED_DATE               ,
  REQUEST_DATE               ,
  PRICING_DATE               ,
  PRICE_REQUEST_CODE         , -- PROMOTIONS SEP/01
  SHIPMENT_PRIORITY_CODE     ,
  DEMAND_CLASS_CODE          ,
  PRICE_LIST_ID              ,
  TAX_EXEMPT_FLAG            ,
  TAX_EXEMPT_NUMBER          ,
  TAX_EXEMPT_REASON_CODE     ,
  CONVERSION_RATE            ,
  CONVERSION_TYPE_CODE       ,
  CONVERSION_RATE_DATE       ,
  PARTIAL_SHIPMENTS_ALLOWED  ,
  SHIP_TOLERANCE_ABOVE       ,
  SHIP_TOLERANCE_BELOW       ,
  TRANSACTIONAL_CURR_CODE    ,
  AGREEMENT_ID               ,
  TAX_POINT_CODE             ,
  CUST_PO_NUMBER             ,
  INVOICING_RULE_ID          ,
  ACCOUNTING_RULE_ID         ,
  ACCOUNTING_RULE_DURATION   ,
  PAYMENT_TERM_ID            ,
  SHIPPING_METHOD_CODE       ,
  FREIGHT_CARRIER_CODE       ,
  FOB_POINT_CODE             ,
  FREIGHT_TERMS_CODE         ,
  SOLD_FROM_ORG_ID           ,
  SOLD_TO_ORG_ID             ,
  SHIP_FROM_ORG_ID           ,
  SHIP_TO_ORG_ID             ,
  INVOICE_TO_ORG_ID          ,
  DELIVER_TO_ORG_ID          ,
  SOLD_TO_CONTACT_ID         ,
  SHIP_TO_CONTACT_ID         ,
  INVOICE_TO_CONTACT_ID      ,
  DELIVER_TO_CONTACT_ID      ,
  CREATION_DATE              ,
  CREATED_BY                 ,
  LAST_UPDATED_BY            ,
  LAST_UPDATE_DATE           ,
  LAST_UPDATE_LOGIN          ,
  PROGRAM_APPLICATION_ID     ,
  PROGRAM_ID                 ,
  PROGRAM_UPDATE_DATE        ,
  REQUEST_ID                 ,
  CONTEXT                    ,
  ATTRIBUTE1                 ,
  ATTRIBUTE2                 ,
  ATTRIBUTE3                 ,
  ATTRIBUTE4                 ,
  ATTRIBUTE5                 ,
  ATTRIBUTE6                 ,
  ATTRIBUTE7                 ,
  ATTRIBUTE8                 ,
  ATTRIBUTE9                 ,
  ATTRIBUTE10                ,
  ATTRIBUTE11                ,
  ATTRIBUTE12                ,
  ATTRIBUTE13                ,
  ATTRIBUTE14                ,
  ATTRIBUTE15                ,
  ATTRIBUTE16                ,  -- for bug 2184255
  ATTRIBUTE17                ,
  ATTRIBUTE18                ,
  ATTRIBUTE19                ,
  ATTRIBUTE20                ,
  GLOBAL_ATTRIBUTE_CATEGORY  ,
  GLOBAL_ATTRIBUTE1          ,
  GLOBAL_ATTRIBUTE2          ,
  GLOBAL_ATTRIBUTE3          ,
  GLOBAL_ATTRIBUTE4          ,
  GLOBAL_ATTRIBUTE5          ,
  GLOBAL_ATTRIBUTE6          ,
  GLOBAL_ATTRIBUTE7          ,
  GLOBAL_ATTRIBUTE8          ,
  GLOBAL_ATTRIBUTE9          ,
  GLOBAL_ATTRIBUTE10         ,
  GLOBAL_ATTRIBUTE11         ,
  GLOBAL_ATTRIBUTE12         ,
  GLOBAL_ATTRIBUTE13         ,
  GLOBAL_ATTRIBUTE14         ,
  GLOBAL_ATTRIBUTE15         ,
  GLOBAL_ATTRIBUTE16         ,
  GLOBAL_ATTRIBUTE17         ,
  GLOBAL_ATTRIBUTE18         ,
  GLOBAL_ATTRIBUTE19         ,
  GLOBAL_ATTRIBUTE20         ,
  CANCELLED_FLAG             ,
  OPEN_FLAG                  ,
  BOOKED_FLAG                ,
  SALESREP_ID                ,
  RETURN_REASON_CODE         ,
  ORDER_DATE_TYPE_CODE       ,
  EARLIEST_SCHEDULE_LIMIT    ,
  LATEST_SCHEDULE_LIMIT      ,
  PAYMENT_TYPE_CODE          ,
  PAYMENT_AMOUNT             ,
  CHECK_NUMBER               ,
  CREDIT_CARD_NUMBER         ,
  CREDIT_CARD_CODE           ,
  CREDIT_CARD_HOLDER_NAME    ,
  CREDIT_CARD_EXPIRATION_DATE,
  /* R12 CC encryption
  CREDIT_CARD_CODE           ,
  CREDIT_CARD_HOLDER_NAME    ,
  CREDIT_CARD_NUMBER         ,
  CREDIT_CARD_EXPIRATION_DATE,
  CREDIT_CARD_APPROVAL_CODE  ,
  */
  SALES_CHANNEL_CODE         ,
  FIRST_ACK_CODE             ,
  FIRST_ACK_DATE             ,
  LAST_ACK_CODE              ,
  LAST_ACK_DATE              ,
  ORDER_CATEGORY_CODE        ,
  CHANGE_SEQUENCE            ,
  SHIPPING_INSTRUCTIONS      ,
  PACKING_INSTRUCTIONS       ,
  TP_CONTEXT                 ,
  TP_ATTRIBUTE1              ,
  TP_ATTRIBUTE2              ,
  TP_ATTRIBUTE3              ,
  TP_ATTRIBUTE4              ,
  TP_ATTRIBUTE5              ,
  TP_ATTRIBUTE6              ,
  TP_ATTRIBUTE7              ,
  TP_ATTRIBUTE8              ,
  TP_ATTRIBUTE9              ,
  TP_ATTRIBUTE10             ,
  TP_ATTRIBUTE11             ,
  TP_ATTRIBUTE12             ,
  TP_ATTRIBUTE13             ,
  TP_ATTRIBUTE14             ,
  TP_ATTRIBUTE15             ,
  FLOW_STATUS_CODE           ,
  MARKETING_SOURCE_CODE_ID   ,
  -- CREDIT_CARD_APPROVAL_DATE  ,
  UPGRADED_FLAG              ,
  CUSTOMER_PREFERENCE_SET_CODe,
  BOOKED_DATE                ,
  BLANKET_NUMBER             ,
  -- QUOTING changes
  quote_date,
  quote_number,
  sales_document_name,
  transaction_phase_code,
  user_status_code,
  draft_submitted_flag,
  source_document_version_number,
  sold_to_site_use_id,
  -- QUOTING changes END
  REASON_CODE           ,
  HIST_COMMENTS     ,
  HIST_TYPE_CODE        ,
  HIST_CREATION_DATE    ,
  HIST_CREATED_BY       ,
  RESPONSIBILITY_ID     ,
  --VERSIONING Changes
  AUDIT_FLAG ,
  VERSION_FLAG,
  PHASE_CHANGE_FLAG,
  REASON_ID             ,
  --VERSIONING Changes END
   order_firmed_date 	,     -- key transaction dates
   instrument_id    -- R12 CC Encryption
)
  VALUES
  (
  l_header_rec.header_id                  ,
  l_header_rec.org_id                     ,
  l_header_rec.order_type_id              ,
  l_header_rec.order_number               ,
  nvl(p_version_number,  l_header_rec.version_number)    ,
  l_header_rec.expiration_date            ,
  l_header_rec.order_source_id            ,
  l_header_rec.source_document_type_id    ,
  l_header_rec.orig_sys_document_ref      ,
  l_header_rec.source_document_id         ,
  l_header_rec.ordered_date               ,
  l_header_rec.request_date               ,
  l_header_rec.pricing_date               ,
  l_header_rec.price_request_code         , -- PROMOTIONS SEP/01
  l_header_rec.shipment_priority_code     ,
  l_header_rec.demand_class_code          ,
  l_header_rec.price_list_id              ,
  l_header_rec.tax_exempt_flag            ,
  l_header_rec.tax_exempt_number          ,
  l_header_rec.tax_exempt_reason_code     ,
  l_header_rec.conversion_rate            ,
  l_header_rec.conversion_type_code       ,
  l_header_rec.conversion_rate_date       ,
  l_header_rec.partial_shipments_allowed  ,
  l_header_rec.ship_tolerance_above       ,
  l_header_rec.ship_tolerance_below       ,
  l_header_rec.transactional_curr_code    ,
  l_header_rec.agreement_id               ,
  l_header_rec.tax_point_code             ,
  l_header_rec.cust_po_number             ,
  l_header_rec.invoicing_rule_id          ,
  l_header_rec.accounting_rule_id         ,
  l_header_rec.accounting_rule_duration   ,
  l_header_rec.payment_term_id            ,
  l_header_rec.shipping_method_code       ,
  l_header_rec.freight_carrier_code       ,
  l_header_rec.fob_point_code             ,
  l_header_rec.freight_terms_code         ,
  l_header_rec.sold_from_org_id           ,
  l_header_rec.sold_to_org_id             ,
  l_header_rec.ship_from_org_id           ,
  l_header_rec.ship_to_org_id             ,
  l_header_rec.invoice_to_org_id          ,
  l_header_rec.deliver_to_org_id          ,
  l_header_rec.sold_to_contact_id         ,
  l_header_rec.ship_to_contact_id         ,
  l_header_rec.invoice_to_contact_id      ,
  l_header_rec.deliver_to_contact_id      ,
  l_header_rec.creation_date              ,
  l_header_rec.created_by                 ,
  l_header_rec.last_updated_by            ,
  l_header_rec.last_update_date           ,
  l_header_rec.last_update_login          ,
  l_header_rec.program_application_id     ,
  l_header_rec.program_id                 ,
  l_header_rec.program_update_date        ,
  l_header_rec.request_id                 ,
  l_header_rec.context                    ,
  l_header_rec.attribute1                 ,
  l_header_rec.attribute2                 ,
  l_header_rec.attribute3                 ,
  l_header_rec.attribute4                 ,
  l_header_rec.attribute5                 ,
  l_header_rec.attribute6                 ,
  l_header_rec.attribute7                 ,
  l_header_rec.attribute8                 ,
  l_header_rec.attribute9                 ,
  l_header_rec.attribute10                ,
  l_header_rec.attribute11                ,
  l_header_rec.attribute12                ,
  l_header_rec.attribute13                ,
  l_header_rec.attribute14                ,
  l_header_rec.attribute15                ,
  l_header_rec.attribute16                ,  -- for bug 2184255
  l_header_rec.attribute17                ,
  l_header_rec.attribute18                ,
  l_header_rec.attribute19                ,
  l_header_rec.attribute20                ,
  l_header_rec.global_attribute_category  ,
  l_header_rec.global_attribute1          ,
  l_header_rec.global_attribute2          ,
  l_header_rec.global_attribute3          ,
  l_header_rec.global_attribute4          ,
  l_header_rec.global_attribute5          ,
  l_header_rec.global_attribute6          ,
  l_header_rec.global_attribute7          ,
  l_header_rec.global_attribute8          ,
  l_header_rec.global_attribute9          ,
  l_header_rec.global_attribute10         ,
  l_header_rec.global_attribute11         ,
  l_header_rec.global_attribute12         ,
  l_header_rec.global_attribute13         ,
  l_header_rec.global_attribute14         ,
  l_header_rec.global_attribute15         ,
  l_header_rec.global_attribute16         ,
  l_header_rec.global_attribute17         ,
  l_header_rec.global_attribute18         ,
  l_header_rec.global_attribute19         ,
  l_header_rec.global_attribute20         ,
  l_header_rec.cancelled_flag             ,
  l_header_rec.open_flag                  ,
  l_header_rec.booked_flag                ,
  l_header_rec.salesrep_id                ,
  l_header_rec.return_reason_code         ,
  l_header_rec.order_date_type_code       ,
  l_header_rec.earliest_schedule_limit    ,
  l_header_rec.latest_schedule_limit      ,
  l_header_rec.payment_type_code          ,
  l_header_rec.payment_amount             ,
  l_header_rec.check_number               ,
  l_credit_card_number         		  ,
  l_credit_card_code                      ,
  l_credit_card_holder_name		  ,
  l_credit_card_expiration_date		  ,
  /*
  l_header_rec.credit_card_code           ,
  l_header_rec.credit_card_holder_name    ,
  l_header_rec.credit_card_number         ,
  l_header_rec.credit_card_expiration_date,
  l_header_rec.credit_card_approval_code  ,
  */
  l_header_rec.sales_channel_code         ,
  l_header_rec.first_ack_code             ,
  l_header_rec.first_ack_date             ,
  l_header_rec.last_ack_code              ,
  l_header_rec.last_ack_date              ,
  l_header_rec.order_category_code        ,
  l_header_rec.change_sequence            ,
  l_header_rec.shipping_instructions      ,
  l_header_rec.packing_instructions       ,
  l_header_rec.tp_context                 ,
  l_header_rec.tp_attribute1              ,
  l_header_rec.tp_attribute2              ,
  l_header_rec.tp_attribute3              ,
  l_header_rec.tp_attribute4              ,
  l_header_rec.tp_attribute5              ,
  l_header_rec.tp_attribute6              ,
  l_header_rec.tp_attribute7              ,
  l_header_rec.tp_attribute8              ,
  l_header_rec.tp_attribute9              ,
  l_header_rec.tp_attribute10             ,
  l_header_rec.tp_attribute11             ,
  l_header_rec.tp_attribute12             ,
  l_header_rec.tp_attribute13             ,
  l_header_rec.tp_attribute14             ,
  l_header_rec.tp_attribute15             ,
  l_header_rec.flow_status_code           ,
  l_header_rec.marketing_source_code_id   ,
  -- l_header_rec.credit_card_approval_date  ,
  l_header_rec.upgraded_flag              ,
  l_header_rec.customer_preference_set_code,
  l_header_rec.booked_date                ,
  l_header_rec.blanket_number             ,
  -- QUOTING changes
  l_header_rec.quote_date,
  l_header_rec.quote_number,
  l_header_rec.sales_document_name,
  l_header_rec.transaction_phase_code,
  l_header_rec.user_status_code,
  l_header_rec.draft_submitted_flag,
  l_header_rec.source_document_version_number,
  l_header_rec.sold_to_site_use_id,
  -- QUOTING changes END
  p_reason_code,
  p_comments,
  P_HIST_TYPE_CODE,
  sysdate,
  nvl(FND_GLOBAL.USER_ID, -1),
  nvl(FND_GLOBAL.RESP_ID, -1),
  --VERSIONING Changes
  p_AUDIT_FLAG,
  p_version_flag,
  p_phase_change_flag,
  p_reason_id  ,
  --VERSIONING Changes END
 --key transaction dates
  l_header_rec.Order_firmed_date,
  l_instrument_id

);

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'N';
   OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING RECORDHEADERHIST' ) ;
   END IF;

EXCEPTION
    WHEN OTHERS THEN
       IF FND_MSG_PUB.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME
           ,'RecordHeaderHist');
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END RecordHeaderHist;

Procedure RecordHSCreditHist
  (p_header_scredit_id           In Number
  ,p_header_scredit_rec         In OE_ORDER_PUB.HEADER_SCREDIT_REC_TYPE
            := OE_Order_PUB.G_MISS_HEADER_SCREDIT_REC
  ,p_hist_type_code   In Varchar2
  ,p_reason_code      In varchar2
  ,p_comments         IN Varchar2
  ,p_audit_flag       IN Varchar2 := null
  ,p_version_flag     IN Varchar2 := null
  ,p_phase_change_flag       IN Varchar2 := null
  ,p_version_number IN NUMBER := null
  ,p_reason_id        IN NUMBER := NULL
  ,p_wf_activity_code IN Varchar2 := null
  ,p_wf_result_code   IN Varchar2 := null
  ,x_return_status    Out NOCOPY /* file.sql.39 change */ Varchar2
  ) IS
l_header_scredit_rec     OE_ORDER_PUB.HEADER_SCREDIT_REC_TYPE := OE_Order_PUB.G_MISS_HEADER_SCREDIT_REC;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING RECORDHSCREDITHIST' ) ;
   END IF;

   -- JPN: Added the G_MISS_NUM check before inserting the history record.
   if (p_header_scredit_rec.sales_credit_id is not null  AND
          p_header_scredit_rec.sales_credit_id <> FND_API.G_MISS_NUM) then
      l_header_scredit_rec := p_header_scredit_rec;
   else
      -- query the header record
     OE_HEADER_SCREDIT_UTIL.Query_Row
        (p_sales_credit_id  => p_header_scredit_id,
	    x_header_scredit_rec => l_header_scredit_rec
        );
   end if;
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'RECORDHSCREDITHIST:INSERT A ROW FOR P_HEADER_SCREDIT_ID :' || TO_CHAR ( P_HEADER_SCREDIT_ID ) ) ;
                    END IF;

  INSERT INTO OE_SALES_CREDIT_HISTORY
  (
  SALES_CREDIT_ID            ,
  CREATION_DATE              ,
  CREATED_BY                 ,
  LAST_UPDATE_DATE           ,
  LAST_UPDATED_BY            ,
  LAST_UPDATE_LOGIN          ,
  HEADER_ID                  ,
  SALESREP_ID                ,
  PERCENT                    ,
  LINE_ID                    ,
  CONTEXT                    ,
  ATTRIBUTE1                 ,
  ATTRIBUTE2                 ,
  ATTRIBUTE3                 ,
  ATTRIBUTE4                 ,
  ATTRIBUTE5                 ,
  ATTRIBUTE6                 ,
  ATTRIBUTE7                 ,
  ATTRIBUTE8                 ,
  ATTRIBUTE9                 ,
  ATTRIBUTE10                ,
  ATTRIBUTE11                ,
  ATTRIBUTE12                ,
  ATTRIBUTE13                ,
  ATTRIBUTE14                ,
  ATTRIBUTE15                ,
  DW_UPDATE_ADVICE_FLAG      ,
  WH_UPDATE_DATE             ,
  ORIG_SYS_CREDIT_REF        ,
  SALES_CREDIT_TYPE_ID       ,
  REASON_CODE                ,
  HIST_COMMENTS     ,
  HIST_TYPE_CODE        ,
  HIST_CREATION_DATE    ,
  HIST_CREATED_BY       ,
  RESPONSIBILITY_ID,
  --VERSIONING Changes
  AUDIT_FLAG,
  VERSION_FLAG,
  PHASE_CHANGE_FLAG,
  VERSION_NUMBER,
  REASON_ID
  --VERSIONING Changes END
  )
  VALUES
  (
  l_header_scredit_rec.SALES_CREDIT_ID            ,
  l_header_scredit_rec.CREATION_DATE              ,
  l_header_scredit_rec.CREATED_BY                 ,
  l_header_scredit_rec.LAST_UPDATE_DATE           ,
  l_header_scredit_rec.LAST_UPDATED_BY            ,
  l_header_scredit_rec.LAST_UPDATE_LOGIN          ,
  l_header_scredit_rec.HEADER_ID                  ,
  l_header_scredit_rec.SALESREP_ID                ,
  l_header_scredit_rec.PERCENT                    ,
  null,
  l_header_scredit_rec.CONTEXT                    ,
  l_header_scredit_rec.ATTRIBUTE1                 ,
  l_header_scredit_rec.ATTRIBUTE2                 ,
  l_header_scredit_rec.ATTRIBUTE3                 ,
  l_header_scredit_rec.ATTRIBUTE4                 ,
  l_header_scredit_rec.ATTRIBUTE5                 ,
  l_header_scredit_rec.ATTRIBUTE6                 ,
  l_header_scredit_rec.ATTRIBUTE7                 ,
  l_header_scredit_rec.ATTRIBUTE8                 ,
  l_header_scredit_rec.ATTRIBUTE9                 ,
  l_header_scredit_rec.ATTRIBUTE10                ,
  l_header_scredit_rec.ATTRIBUTE11                ,
  l_header_scredit_rec.ATTRIBUTE12                ,
  l_header_scredit_rec.ATTRIBUTE13                ,
  l_header_scredit_rec.ATTRIBUTE14                ,
  l_header_scredit_rec.ATTRIBUTE15                ,
  l_header_scredit_rec.DW_UPDATE_ADVICE_FLAG      ,
  l_header_scredit_rec.WH_UPDATE_DATE             ,
  l_header_scredit_rec.ORIG_SYS_CREDIT_REF        ,
  l_header_scredit_rec.SALES_CREDIT_TYPE_ID       ,
  p_reason_code,
  p_comments,
  P_HIST_TYPE_CODE,
  sysdate,
  nvl(FND_GLOBAL.USER_ID, -1),
  nvl(FND_GLOBAL.RESP_ID, -1),
  --VERSIONING Changes
  p_AUDIT_FLAG,
  p_version_flag,
  p_phase_change_flag,
  p_version_number,
  p_reason_id
  --VERSIONING Changes END
);
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'N';
   OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING RECORDHSCREDITHIST' ) ;
   END IF;

EXCEPTION
    WHEN OTHERS THEN
       IF FND_MSG_PUB.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME
           ,'RecordHSCreditHist');
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END RecordHSCreditHist;

Procedure RecordLSCreditHist
  (p_line_scredit_id           In Number
  ,p_line_scredit_rec         In OE_ORDER_PUB.LINE_SCREDIT_REC_TYPE
            := OE_Order_PUB.G_MISS_LINE_SCREDIT_REC
  ,p_hist_type_code   In Varchar2
  ,p_reason_code      In varchar2
  ,p_comments         IN Varchar2
  ,p_audit_flag       IN Varchar2 := null
  ,p_version_flag     IN Varchar2 := null
  ,p_phase_change_flag       IN Varchar2 := null
  ,p_version_number IN NUMBER := null
  ,p_reason_id        IN NUMBER := NULL
  ,p_wf_activity_code IN Varchar2 := null
  ,p_wf_result_code   IN Varchar2 := null
  ,x_return_status    Out NOCOPY /* file.sql.39 change */ Varchar2
  ) IS
l_line_scredit_rec     OE_ORDER_PUB.LINE_SCREDIT_REC_TYPE := OE_Order_PUB.G_MISS_LINE_SCREDIT_REC;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING RECORDLSCREDITHIST' ) ;
   END IF;

   -- JPN: Added the G_MISS_NUM check before inserting the history record.
   if (p_line_scredit_rec.sales_credit_id is not null  AND
          p_line_scredit_rec.sales_credit_id <> FND_API.G_MISS_NUM) then
      l_line_scredit_rec := p_line_scredit_rec;
   else
      -- query the header record
      OE_LINE_SCREDIT_UTIL.Query_Row
        (p_sales_credit_id          => p_line_scredit_id,
	    x_line_scredit_rec => l_line_scredit_rec
        );
   end if;
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'RECORDLSCREDITHIST:INSERT A ROW FOR P_LINE_SCREDIT_ID :' || TO_CHAR ( P_LINE_SCREDIT_ID ) ) ;
                    END IF;


  INSERT INTO OE_SALES_CREDIT_HISTORY
  (
  SALES_CREDIT_ID            ,
  CREATION_DATE              ,
  CREATED_BY                 ,
  LAST_UPDATE_DATE           ,
  LAST_UPDATED_BY            ,
  LAST_UPDATE_LOGIN          ,
  HEADER_ID                  ,
  SALESREP_ID                ,
  PERCENT                    ,
  LINE_ID                    ,
  CONTEXT                    ,
  ATTRIBUTE1                 ,
  ATTRIBUTE2                 ,
  ATTRIBUTE3                 ,
  ATTRIBUTE4                 ,
  ATTRIBUTE5                 ,
  ATTRIBUTE6                 ,
  ATTRIBUTE7                 ,
  ATTRIBUTE8                 ,
  ATTRIBUTE9                 ,
  ATTRIBUTE10                ,
  ATTRIBUTE11                ,
  ATTRIBUTE12                ,
  ATTRIBUTE13                ,
  ATTRIBUTE14                ,
  ATTRIBUTE15                ,
  DW_UPDATE_ADVICE_FLAG      ,
  WH_UPDATE_DATE             ,
  ORIG_SYS_CREDIT_REF        ,
  SALES_CREDIT_TYPE_ID       ,
  REASON_CODE                ,
  HIST_COMMENTS     ,
  HIST_TYPE_CODE        ,
  HIST_CREATION_DATE    ,
  HIST_CREATED_BY       ,
  RESPONSIBILITY_ID     ,
  --VERSIONING Changes
  AUDIT_FLAG        ,
  VERSION_FLAG      ,
  PHASE_CHANGE_FLAG ,
  VERSION_NUMBER,
  REASON_ID
  --VERSIONING Changes END
  )
  VALUES
  (
  l_line_scredit_rec.SALES_CREDIT_ID            ,
  l_line_scredit_rec.CREATION_DATE              ,
  l_line_scredit_rec.CREATED_BY                 ,
  l_line_scredit_rec.LAST_UPDATE_DATE           ,
  l_line_scredit_rec.LAST_UPDATED_BY            ,
  l_line_scredit_rec.LAST_UPDATE_LOGIN          ,
  l_line_scredit_rec.HEADER_ID                  ,
  l_line_scredit_rec.SALESREP_ID                ,
  l_line_scredit_rec.PERCENT                    ,
  l_line_scredit_rec.LINE_ID                    ,
  l_line_scredit_rec.CONTEXT                    ,
  l_line_scredit_rec.ATTRIBUTE1                 ,
  l_line_scredit_rec.ATTRIBUTE2                 ,
  l_line_scredit_rec.ATTRIBUTE3                 ,
  l_line_scredit_rec.ATTRIBUTE4                 ,
  l_line_scredit_rec.ATTRIBUTE5                 ,
  l_line_scredit_rec.ATTRIBUTE6                 ,
  l_line_scredit_rec.ATTRIBUTE7                 ,
  l_line_scredit_rec.ATTRIBUTE8                 ,
  l_line_scredit_rec.ATTRIBUTE9                 ,
  l_line_scredit_rec.ATTRIBUTE10                ,
  l_line_scredit_rec.ATTRIBUTE11                ,
  l_line_scredit_rec.ATTRIBUTE12                ,
  l_line_scredit_rec.ATTRIBUTE13                ,
  l_line_scredit_rec.ATTRIBUTE14                ,
  l_line_scredit_rec.ATTRIBUTE15                ,
  l_line_scredit_rec.DW_UPDATE_ADVICE_FLAG      ,
  l_line_scredit_rec.WH_UPDATE_DATE             ,
  l_line_scredit_rec.ORIG_SYS_CREDIT_REF        ,
  l_line_scredit_rec.SALES_CREDIT_TYPE_ID       ,
  p_reason_code,
  p_comments,
  P_HIST_TYPE_CODE      ,
  sysdate   ,
  nvl(FND_GLOBAL.USER_ID, -1)       ,
  nvl(FND_GLOBAL.RESP_ID, -1),
  --VERSIONING Changes
  p_AUDIT_FLAG,
  p_version_flag,
  p_phase_change_flag,
  p_version_number,
  p_reason_id
  --VERSIONING Changes END
  );

   OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'N';
   OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING RECORDLSCREDITHIST' ) ;
   END IF;

EXCEPTION
    WHEN OTHERS THEN
       IF FND_MSG_PUB.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME
           ,'RecordLSCreditHist');
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END RecordLSCreditHist;

Procedure RecordHPAdjHist
  (p_header_adj_id           In Number
  ,p_header_adj_rec         In OE_ORDER_PUB.HEADER_ADJ_REC_TYPE
            := OE_Order_PUB.G_MISS_HEADER_ADJ_REC
  ,p_hist_type_code   In Varchar2
  ,p_reason_code      In varchar2
  ,p_comments         IN Varchar2
  ,p_audit_flag       IN Varchar2 := null
  ,p_version_flag     IN Varchar2 := null
  ,p_phase_change_flag       IN Varchar2 := null
  ,p_version_number IN NUMBER := null
  ,p_reason_id        IN NUMBER := NULL
  ,p_wf_activity_code IN Varchar2 := null
  ,p_wf_result_code   IN Varchar2 := null
  ,x_return_status    Out NOCOPY /* file.sql.39 change */ Varchar2
  ) IS
l_header_adj_rec     OE_ORDER_PUB.HEADER_ADJ_REC_TYPE := OE_Order_PUB.G_MISS_HEADER_ADJ_REC;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING RECORDHPADJHIST' ) ;
   END IF;

   if (p_header_adj_rec.price_adjustment_id is not null  AND
          p_header_adj_rec.price_adjustment_id <> FND_API.G_MISS_NUM) then
      l_header_adj_rec := p_header_adj_rec;
   else
      -- query the header record
      OE_HEADER_ADJ_UTIL.Query_Row
        (p_price_adjustment_id          => p_header_adj_id,
	    x_header_adj_rec => l_header_adj_rec
        );
   end if;
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'RECORDHPADJHIST:INSERT A ROW FOR P_HEADER_ADJ_ID :' || TO_CHAR ( P_HEADER_ADJ_ID ) ) ;
                    END IF;

  INSERT INTO OE_PRICE_ADJS_HISTORY
  (
  PRICE_ADJUSTMENT_ID        ,
  CREATION_DATE              ,
  CREATED_BY                  ,
  LAST_UPDATE_DATE            ,
  LAST_UPDATED_BY             ,
  LAST_UPDATE_LOGIN          ,
  PROGRAM_APPLICATION_ID     ,
  PROGRAM_ID                 ,
  PROGRAM_UPDATE_DATE        ,
  REQUEST_ID                 ,
  HEADER_ID                   ,
  DISCOUNT_ID                ,
  DISCOUNT_LINE_ID           ,
  AUTOMATIC_FLAG             ,
  PERCENT                    ,
  LINE_ID                    ,
  CONTEXT                    ,
  ATTRIBUTE1                 ,
  ATTRIBUTE2                 ,
  ATTRIBUTE3                 ,
  ATTRIBUTE4                 ,
  ATTRIBUTE5                 ,
  ATTRIBUTE6                 ,
  ATTRIBUTE7                 ,
  ATTRIBUTE8                 ,
  ATTRIBUTE9                 ,
  ATTRIBUTE10                ,
  ATTRIBUTE11                ,
  ATTRIBUTE12                ,
  ATTRIBUTE13                ,
  ATTRIBUTE14                ,
  ATTRIBUTE15                ,
  ORIG_SYS_DISCOUNT_REF      ,
  LIST_HEADER_ID             ,
  LIST_LINE_ID               ,
  LIST_LINE_TYPE_CODE        ,
  MODIFIED_FROM              ,
  MODIFIED_TO                ,
  UPDATE_ALLOWED             ,
  CHANGE_REASON_CODE         ,
  CHANGE_REASON_TEXT         ,
  MODIFIER_MECHANISM_TYPE_CODE,
  UPDATED_FLAG               ,
  APPLIED_FLAG               ,
  OPERAND                    ,
  ARITHMETIC_OPERATOR        ,
  COST_ID                    ,
  TAX_CODE                   ,
  TAX_EXEMPT_FLAG            ,
  TAX_EXEMPT_NUMBER          ,
  TAX_EXEMPT_REASON_CODE     ,
  PARENT_ADJUSTMENT_ID       ,
  INVOICED_FLAG              ,
  ESTIMATED_FLAG             ,
  INC_IN_SALES_PERFORMANCE   ,
  SPLIT_ACTION_CODE          ,
  ADJUSTED_AMOUNT            ,
  PRICING_PHASE_ID           ,
  CHARGE_TYPE_CODE           ,
  CHARGE_SUBTYPE_CODE        ,
  RANGE_BREAK_QUANTITY       ,
  ACCRUAL_CONVERSION_RATE    ,
  PRICING_GROUP_SEQUENCE     ,
  ACCRUAL_FLAG               ,
  LIST_LINE_NO               ,
  SOURCE_SYSTEM_CODE         ,
  BENEFIT_QTY                ,
  BENEFIT_UOM_CODE           ,
  PRINT_ON_INVOICE_FLAG      ,
  EXPIRATION_DATE            ,
  REBATE_TRANSACTION_TYPE_CODE,
  REBATE_TRANSACTION_REFERENCE,
  REBATE_PAYMENT_SYSTEM_CODE  ,
  REDEEMED_DATE              ,
  REDEEMED_FLAG              ,
  MODIFIER_LEVEL_CODE        ,
  PRICE_BREAK_TYPE_CODE      ,
  SUBSTITUTION_ATTRIBUTE     ,
  PRORATION_TYPE_CODE        ,
  INCLUDE_ON_RETURNS_FLAG    ,
  CREDIT_OR_CHARGE_FLAG      ,
  AC_CONTEXT                 ,
  AC_ATTRIBUTE1              ,
  AC_ATTRIBUTE2              ,
  AC_ATTRIBUTE3              ,
  AC_ATTRIBUTE4              ,
  AC_ATTRIBUTE5              ,
  AC_ATTRIBUTE6              ,
  AC_ATTRIBUTE7              ,
  AC_ATTRIBUTE8              ,
  AC_ATTRIBUTE9              ,
  AC_ATTRIBUTE10             ,
  AC_ATTRIBUTE11             ,
  AC_ATTRIBUTE12             ,
  AC_ATTRIBUTE13             ,
  AC_ATTRIBUTE14             ,
  AC_ATTRIBUTE15             ,
  HIST_TYPE_CODE        ,
  HIST_CREATION_DATE    ,
  HIST_CREATED_BY       ,
  RESPONSIBILITY_ID     ,
  --VERSIONING Changes
  AUDIT_FLAG            ,
  VERSION_FLAG          ,
  PHASE_CHANGE_FLAG     ,
  VERSION_NUMBER        ,
  REASON_ID
  --VERSIONING Changes END
  )
   VALUES
   (
  l_header_adj_rec.PRICE_ADJUSTMENT_ID        ,
  l_header_adj_rec.CREATION_DATE              ,
  l_header_adj_rec.CREATED_BY                  ,
  l_header_adj_rec.LAST_UPDATE_DATE            ,
  l_header_adj_rec.LAST_UPDATED_BY             ,
  l_header_adj_rec.LAST_UPDATE_LOGIN          ,
  l_header_adj_rec.PROGRAM_APPLICATION_ID     ,
  l_header_adj_rec.PROGRAM_ID                 ,
  l_header_adj_rec.PROGRAM_UPDATE_DATE        ,
  l_header_adj_rec.REQUEST_ID                 ,
  l_header_adj_rec.HEADER_ID                   ,
  l_header_adj_rec.DISCOUNT_ID                ,
  l_header_adj_rec.DISCOUNT_LINE_ID           ,
  l_header_adj_rec.AUTOMATIC_FLAG             ,
  l_header_adj_rec.PERCENT                    ,
  null , --l_header_adj_rec.LINE_ID
  l_header_adj_rec.CONTEXT                    ,
  l_header_adj_rec.ATTRIBUTE1                 ,
  l_header_adj_rec.ATTRIBUTE2                 ,
  l_header_adj_rec.ATTRIBUTE3                 ,
  l_header_adj_rec.ATTRIBUTE4                 ,
  l_header_adj_rec.ATTRIBUTE5                 ,
  l_header_adj_rec.ATTRIBUTE6                 ,
  l_header_adj_rec.ATTRIBUTE7                 ,
  l_header_adj_rec.ATTRIBUTE8                 ,
  l_header_adj_rec.ATTRIBUTE9                 ,
  l_header_adj_rec.ATTRIBUTE10                ,
  l_header_adj_rec.ATTRIBUTE11                ,
  l_header_adj_rec.ATTRIBUTE12                ,
  l_header_adj_rec.ATTRIBUTE13                ,
  l_header_adj_rec.ATTRIBUTE14                ,
  l_header_adj_rec.ATTRIBUTE15                ,
  l_header_adj_rec.ORIG_SYS_DISCOUNT_REF      ,
  l_header_adj_rec.LIST_HEADER_ID             ,
  l_header_adj_rec.LIST_LINE_ID               ,
  l_header_adj_rec.LIST_LINE_TYPE_CODE        ,
  l_header_adj_rec.MODIFIED_FROM              ,
  l_header_adj_rec.MODIFIED_TO                ,
  l_header_adj_rec.UPDATE_ALLOWED             ,
  p_reason_code                               ,
  p_comments                                  ,
  l_header_adj_rec.MODIFIER_MECHANISM_TYPE_CODE,
  l_header_adj_rec.UPDATED_FLAG               ,
  l_header_adj_rec.APPLIED_FLAG               ,
  l_header_adj_rec.OPERAND                    ,
  l_header_adj_rec.ARITHMETIC_OPERATOR        ,
  l_header_adj_rec.COST_ID                    ,
  l_header_adj_rec.TAX_CODE                   ,
  l_header_adj_rec.TAX_EXEMPT_FLAG            ,
  l_header_adj_rec.TAX_EXEMPT_NUMBER          ,
  l_header_adj_rec.TAX_EXEMPT_REASON_CODE     ,
  l_header_adj_rec.PARENT_ADJUSTMENT_ID       ,
  l_header_adj_rec.INVOICED_FLAG              ,
  l_header_adj_rec.ESTIMATED_FLAG             ,
  l_header_adj_rec.INC_IN_SALES_PERFORMANCE   ,
  l_header_adj_rec.SPLIT_ACTION_CODE          ,
  l_header_adj_rec.ADJUSTED_AMOUNT            ,
  l_header_adj_rec.PRICING_PHASE_ID           ,
  l_header_adj_rec.CHARGE_TYPE_CODE           ,
  l_header_adj_rec.CHARGE_SUBTYPE_CODE        ,
  l_header_adj_rec.RANGE_BREAK_QUANTITY       ,
  l_header_adj_rec.ACCRUAL_CONVERSION_RATE    ,
  l_header_adj_rec.PRICING_GROUP_SEQUENCE     ,
  l_header_adj_rec.ACCRUAL_FLAG               ,
  l_header_adj_rec.LIST_LINE_NO               ,
  l_header_adj_rec.SOURCE_SYSTEM_CODE         ,
  l_header_adj_rec.BENEFIT_QTY                ,
  l_header_adj_rec.BENEFIT_UOM_CODE           ,
  l_header_adj_rec.PRINT_ON_INVOICE_FLAG      ,
  l_header_adj_rec.EXPIRATION_DATE            ,
  l_header_adj_rec.REBATE_TRANSACTION_TYPE_CODE,
  l_header_adj_rec.REBATE_TRANSACTION_REFERENCE,
  l_header_adj_rec.REBATE_PAYMENT_SYSTEM_CODE  ,
  l_header_adj_rec.REDEEMED_DATE              ,
  l_header_adj_rec.REDEEMED_FLAG              ,
  l_header_adj_rec.MODIFIER_LEVEL_CODE        ,
  l_header_adj_rec.PRICE_BREAK_TYPE_CODE      ,
  l_header_adj_rec.SUBSTITUTION_ATTRIBUTE     ,
  l_header_adj_rec.PRORATION_TYPE_CODE        ,
  l_header_adj_rec.INCLUDE_ON_RETURNS_FLAG    ,
  l_header_adj_rec.CREDIT_OR_CHARGE_FLAG      ,
  l_header_adj_rec.AC_CONTEXT                 ,
  l_header_adj_rec.AC_ATTRIBUTE1              ,
  l_header_adj_rec.AC_ATTRIBUTE2              ,
  l_header_adj_rec.AC_ATTRIBUTE3              ,
  l_header_adj_rec.AC_ATTRIBUTE4              ,
  l_header_adj_rec.AC_ATTRIBUTE5              ,
  l_header_adj_rec.AC_ATTRIBUTE6              ,
  l_header_adj_rec.AC_ATTRIBUTE7              ,
  l_header_adj_rec.AC_ATTRIBUTE8              ,
  l_header_adj_rec.AC_ATTRIBUTE9              ,
  l_header_adj_rec.AC_ATTRIBUTE10             ,
  l_header_adj_rec.AC_ATTRIBUTE11             ,
  l_header_adj_rec.AC_ATTRIBUTE12             ,
  l_header_adj_rec.AC_ATTRIBUTE13             ,
  l_header_adj_rec.AC_ATTRIBUTE14             ,
  l_header_adj_rec.AC_ATTRIBUTE15             ,
  P_HIST_TYPE_CODE,
  sysdate,
  nvl(FND_GLOBAL.USER_ID, -1)       ,
  nvl(FND_GLOBAL.RESP_ID, -1)       ,
  --VERSIONING Changes
  p_AUDIT_FLAG,
  p_version_flag,
  p_phase_change_flag,
  p_version_number,
  p_reason_id
  --VERSIONING Changes END
  );

   OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'N';
   OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING RECORD HEADER ADJUSTMENTS HISTORY ' , 5 ) ;
   END IF;

EXCEPTION
    WHEN OTHERS THEN
       IF FND_MSG_PUB.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME
           ,'RecordHPAdjHist');
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END RecordHPAdjHist;

Procedure RecordLPAdjHist
  (p_line_adj_id           In Number
  ,p_line_adj_rec         In OE_ORDER_PUB.LINE_ADJ_REC_TYPE
            := OE_Order_PUB.G_MISS_LINE_ADJ_REC
  ,p_hist_type_code   In Varchar2
  ,p_reason_code      In varchar2
  ,p_comments         IN Varchar2
  ,p_audit_flag       IN Varchar2 := null
  ,p_version_flag     IN Varchar2 := null
  ,p_phase_change_flag       IN Varchar2 := null
  ,p_version_number IN NUMBER := null
  ,p_reason_id        IN NUMBER := NULL
  ,p_wf_activity_code IN Varchar2 := null
  ,p_wf_result_code   IN Varchar2 := null
  ,x_return_status    Out NOCOPY /* file.sql.39 change */ Varchar2
  ) IS
l_line_adj_rec     OE_ORDER_PUB.LINE_ADJ_REC_TYPE := OE_Order_PUB.G_MISS_LINE_ADJ_REC;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING RECORDLPADJHIST' ) ;
   END IF;

   -- JPN: Added the G_MISS_NUM check before inserting the history record.
   if (p_line_adj_rec.price_adjustment_id is not null  AND
          p_line_adj_rec.price_adjustment_id <> FND_API.G_MISS_NUM) then
      l_line_adj_rec := p_line_adj_rec;
   else
      -- query the header record
      OE_LINE_ADJ_UTIL.Query_Row
      (p_price_adjustment_id          => p_line_adj_id,
	  x_line_adj_rec => l_line_adj_rec);
   end if;

                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'RECORDLPADJHIST:INSERT A ROW FOR P_LINE_ADJ_ID :' || TO_CHAR ( P_LINE_ADJ_ID ) ) ;
                    END IF;

  INSERT INTO OE_PRICE_ADJS_HISTORY
  (
  PRICE_ADJUSTMENT_ID        ,
  CREATION_DATE              ,
  CREATED_BY                  ,
  LAST_UPDATE_DATE            ,
  LAST_UPDATED_BY             ,
  LAST_UPDATE_LOGIN          ,
  PROGRAM_APPLICATION_ID     ,
  PROGRAM_ID                 ,
  PROGRAM_UPDATE_DATE        ,
  REQUEST_ID                 ,
  HEADER_ID                   ,
  DISCOUNT_ID                ,
  DISCOUNT_LINE_ID           ,
  AUTOMATIC_FLAG             ,
  PERCENT                    ,
  LINE_ID                    ,
  CONTEXT                    ,
  ATTRIBUTE1                 ,
  ATTRIBUTE2                 ,
  ATTRIBUTE3                 ,
  ATTRIBUTE4                 ,
  ATTRIBUTE5                 ,
  ATTRIBUTE6                 ,
  ATTRIBUTE7                 ,
  ATTRIBUTE8                 ,
  ATTRIBUTE9                 ,
  ATTRIBUTE10                ,
  ATTRIBUTE11                ,
  ATTRIBUTE12                ,
  ATTRIBUTE13                ,
  ATTRIBUTE14                ,
  ATTRIBUTE15                ,
  ORIG_SYS_DISCOUNT_REF      ,
  LIST_HEADER_ID             ,
  LIST_LINE_ID               ,
  LIST_LINE_TYPE_CODE        ,
  MODIFIED_FROM              ,
  MODIFIED_TO                ,
  UPDATE_ALLOWED             ,
  CHANGE_REASON_CODE         ,
  CHANGE_REASON_TEXT         ,
  MODIFIER_MECHANISM_TYPE_CODE,
  UPDATED_FLAG               ,
  APPLIED_FLAG               ,
  OPERAND                    ,
  ARITHMETIC_OPERATOR        ,
  COST_ID                    ,
  TAX_CODE                   ,
  TAX_EXEMPT_FLAG            ,
  TAX_EXEMPT_NUMBER          ,
  TAX_EXEMPT_REASON_CODE     ,
  PARENT_ADJUSTMENT_ID       ,
  INVOICED_FLAG              ,
  ESTIMATED_FLAG             ,
  INC_IN_SALES_PERFORMANCE   ,
  SPLIT_ACTION_CODE          ,
  ADJUSTED_AMOUNT            ,
  PRICING_PHASE_ID           ,
  CHARGE_TYPE_CODE           ,
  CHARGE_SUBTYPE_CODE        ,
  RANGE_BREAK_QUANTITY       ,
  ACCRUAL_CONVERSION_RATE    ,
  PRICING_GROUP_SEQUENCE     ,
  ACCRUAL_FLAG               ,
  LIST_LINE_NO               ,
  SOURCE_SYSTEM_CODE         ,
  BENEFIT_QTY                ,
  BENEFIT_UOM_CODE           ,
  PRINT_ON_INVOICE_FLAG      ,
  EXPIRATION_DATE            ,
  REBATE_TRANSACTION_TYPE_CODE,
  REBATE_TRANSACTION_REFERENCE,
  REBATE_PAYMENT_SYSTEM_CODE  ,
  REDEEMED_DATE              ,
  REDEEMED_FLAG              ,
  MODIFIER_LEVEL_CODE        ,
  PRICE_BREAK_TYPE_CODE      ,
  SUBSTITUTION_ATTRIBUTE     ,
  PRORATION_TYPE_CODE        ,
  INCLUDE_ON_RETURNS_FLAG    ,
  CREDIT_OR_CHARGE_FLAG      ,
  AC_CONTEXT                 ,
  AC_ATTRIBUTE1              ,
  AC_ATTRIBUTE2              ,
  AC_ATTRIBUTE3              ,
  AC_ATTRIBUTE4              ,
  AC_ATTRIBUTE5              ,
  AC_ATTRIBUTE6              ,
  AC_ATTRIBUTE7              ,
  AC_ATTRIBUTE8              ,
  AC_ATTRIBUTE9              ,
  AC_ATTRIBUTE10             ,
  AC_ATTRIBUTE11             ,
  AC_ATTRIBUTE12             ,
  AC_ATTRIBUTE13             ,
  AC_ATTRIBUTE14             ,
  AC_ATTRIBUTE15             ,
  HIST_TYPE_CODE        ,
  HIST_CREATION_DATE    ,
  HIST_CREATED_BY       ,
  RESPONSIBILITY_ID    ,
  --VERSIONING Changes
  AUDIT_FLAG         ,
  VERSION_FLAG       ,
  PHASE_CHANGE_FLAG  ,
  VERSION_NUMBER     ,
  REASON_ID          ,
  --VERSIONING Changes END
  -- eBTax Changes
  TAX_RATE_ID
   )
   VALUES
   (
  l_line_adj_rec.PRICE_ADJUSTMENT_ID        ,
  l_line_adj_rec.CREATION_DATE              ,
  l_line_adj_rec.CREATED_BY                  ,
  l_line_adj_rec.LAST_UPDATE_DATE            ,
  l_line_adj_rec.LAST_UPDATED_BY             ,
  l_line_adj_rec.LAST_UPDATE_LOGIN          ,
  l_line_adj_rec.PROGRAM_APPLICATION_ID     ,
  l_line_adj_rec.PROGRAM_ID                 ,
  l_line_adj_rec.PROGRAM_UPDATE_DATE        ,
  l_line_adj_rec.REQUEST_ID                 ,
  l_line_adj_rec.HEADER_ID                   ,
  l_line_adj_rec.DISCOUNT_ID                ,
  l_line_adj_rec.DISCOUNT_LINE_ID           ,
  l_line_adj_rec.AUTOMATIC_FLAG             ,
  l_line_adj_rec.PERCENT                    ,
  l_line_adj_rec.LINE_ID                    ,
  l_line_adj_rec.CONTEXT                    ,
  l_line_adj_rec.ATTRIBUTE1                 ,
  l_line_adj_rec.ATTRIBUTE2                 ,
  l_line_adj_rec.ATTRIBUTE3                 ,
  l_line_adj_rec.ATTRIBUTE4                 ,
  l_line_adj_rec.ATTRIBUTE5                 ,
  l_line_adj_rec.ATTRIBUTE6                 ,
  l_line_adj_rec.ATTRIBUTE7                 ,
  l_line_adj_rec.ATTRIBUTE8                 ,
  l_line_adj_rec.ATTRIBUTE9                 ,
  l_line_adj_rec.ATTRIBUTE10                ,
  l_line_adj_rec.ATTRIBUTE11                ,
  l_line_adj_rec.ATTRIBUTE12                ,
  l_line_adj_rec.ATTRIBUTE13                ,
  l_line_adj_rec.ATTRIBUTE14                ,
  l_line_adj_rec.ATTRIBUTE15                ,
  l_line_adj_rec.ORIG_SYS_DISCOUNT_REF      ,
  l_line_adj_rec.LIST_HEADER_ID             ,
  l_line_adj_rec.LIST_LINE_ID               ,
  l_line_adj_rec.LIST_LINE_TYPE_CODE        ,
  l_line_adj_rec.MODIFIED_FROM              ,
  l_line_adj_rec.MODIFIED_TO                ,
  l_line_adj_rec.UPDATE_ALLOWED             ,
  p_reason_code                             ,
  p_comments                                ,
  l_line_adj_rec.MODIFIER_MECHANISM_TYPE_CODE,
  l_line_adj_rec.UPDATED_FLAG               ,
  l_line_adj_rec.APPLIED_FLAG               ,
  l_line_adj_rec.OPERAND                    ,
  l_line_adj_rec.ARITHMETIC_OPERATOR        ,
  l_line_adj_rec.COST_ID                    ,
  l_line_adj_rec.TAX_CODE                   ,
  l_line_adj_rec.TAX_EXEMPT_FLAG            ,
  l_line_adj_rec.TAX_EXEMPT_NUMBER          ,
  l_line_adj_rec.TAX_EXEMPT_REASON_CODE     ,
  l_line_adj_rec.PARENT_ADJUSTMENT_ID       ,
  l_line_adj_rec.INVOICED_FLAG              ,
  l_line_adj_rec.ESTIMATED_FLAG             ,
  l_line_adj_rec.INC_IN_SALES_PERFORMANCE   ,
  l_line_adj_rec.SPLIT_ACTION_CODE          ,
  l_line_adj_rec.ADJUSTED_AMOUNT            ,
  l_line_adj_rec.PRICING_PHASE_ID           ,
  l_line_adj_rec.CHARGE_TYPE_CODE           ,
  l_line_adj_rec.CHARGE_SUBTYPE_CODE        ,
  l_line_adj_rec.RANGE_BREAK_QUANTITY       ,
  l_line_adj_rec.ACCRUAL_CONVERSION_RATE    ,
  l_line_adj_rec.PRICING_GROUP_SEQUENCE     ,
  l_line_adj_rec.ACCRUAL_FLAG               ,
  l_line_adj_rec.LIST_LINE_NO               ,
  l_line_adj_rec.SOURCE_SYSTEM_CODE         ,
  l_line_adj_rec.BENEFIT_QTY                ,
  l_line_adj_rec.BENEFIT_UOM_CODE           ,
  l_line_adj_rec.PRINT_ON_INVOICE_FLAG      ,
  l_line_adj_rec.EXPIRATION_DATE            ,
  l_line_adj_rec.REBATE_TRANSACTION_TYPE_CODE,
  l_line_adj_rec.REBATE_TRANSACTION_REFERENCE,
  l_line_adj_rec.REBATE_PAYMENT_SYSTEM_CODE  ,
  l_line_adj_rec.REDEEMED_DATE              ,
  l_line_adj_rec.REDEEMED_FLAG              ,
  l_line_adj_rec.MODIFIER_LEVEL_CODE        ,
  l_line_adj_rec.PRICE_BREAK_TYPE_CODE      ,
  l_line_adj_rec.SUBSTITUTION_ATTRIBUTE     ,
  l_line_adj_rec.PRORATION_TYPE_CODE        ,
  l_line_adj_rec.INCLUDE_ON_RETURNS_FLAG    ,
  l_line_adj_rec.CREDIT_OR_CHARGE_FLAG      ,
  l_line_adj_rec.AC_CONTEXT                 ,
  l_line_adj_rec.AC_ATTRIBUTE1              ,
  l_line_adj_rec.AC_ATTRIBUTE2              ,
  l_line_adj_rec.AC_ATTRIBUTE3              ,
  l_line_adj_rec.AC_ATTRIBUTE4              ,
  l_line_adj_rec.AC_ATTRIBUTE5              ,
  l_line_adj_rec.AC_ATTRIBUTE6              ,
  l_line_adj_rec.AC_ATTRIBUTE7              ,
  l_line_adj_rec.AC_ATTRIBUTE8              ,
  l_line_adj_rec.AC_ATTRIBUTE9              ,
  l_line_adj_rec.AC_ATTRIBUTE10             ,
  l_line_adj_rec.AC_ATTRIBUTE11             ,
  l_line_adj_rec.AC_ATTRIBUTE12             ,
  l_line_adj_rec.AC_ATTRIBUTE13             ,
  l_line_adj_rec.AC_ATTRIBUTE14             ,
  l_line_adj_rec.AC_ATTRIBUTE15             ,
  P_HIST_TYPE_CODE      ,
  sysdate   ,
  nvl(FND_GLOBAL.USER_ID, -1)       ,
  nvl(FND_GLOBAL.RESP_ID, -1)     ,
  --VERSIONING Changes
  p_AUDIT_FLAG,
  p_version_flag,
  p_phase_change_flag,
  p_version_number,
  p_reason_id,
  --VERSIONING Changes END
  -- eBTax Changes
  l_line_adj_rec.tax_rate_id
   );

   OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'N';
   OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING AFTER INSERTING LINE PRICE ADJUSTMENTS HISTORY' , 5 ) ;
   END IF;

EXCEPTION
    WHEN OTHERS THEN
       IF FND_MSG_PUB.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME
           ,'RecordLPAdjHist');
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END RecordLPAdjHist;

-- Added to fix 2964593
PROCEDURE Reset_Audit_History_Flags IS
BEGIN
OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG  := 'N';
OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
OE_GLOBALS.OE_AUDIT_HISTORY_TBL.delete;
OE_DEBUG_PUB.add('Reason Required Flag has been reset to N',1);
END Reset_Audit_History_Flags;

END OE_CHG_ORDER_PVT;

/
