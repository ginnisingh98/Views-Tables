--------------------------------------------------------
--  DDL for Package Body OE_RETROBILL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_RETROBILL_PVT" AS
/* $Header: OEXVRTOB.pls 120.18.12010000.11 2010/02/10 12:18:38 aambasth ship $ */


/*
If p_retrobill_request_rec.mode = PREVIEW or user has directly EXECUTE without previous preview Then
1.  Insert original lines_id and retrobill qty, original_ulp, original_usp  to temp table.
2a. Use SQL and Cursor, Group lines by sold_to_org, currency and conversion
 b. Select original essential line_attributes like price_list_id, nvl (line.bill_to,header.bill_to) into a cursor.

3. For each group (group can be detected when changes by sold_to_org, currency and conversion), process header attributes.
4. For each line in the group, process lines attributes.
 a.Set pricing date to be sysdate.
 b.Set the line_id to missing.
 c.Set return_reason_code.
 d.Let the original ulp and usp remain in the line tbl.
 e.Copy price list id from old line and set validation_level =  G_VALID_PARTIAL_WITH_DEF (which means to redefault is invalid)

5. For each group, call process_order. Process_order api will be called in batch mode. (which eventually call pricing integration price_line).
 a. Log copy adjustment in OEXULINB if is a retrobill line
 b. In OEXULADB.pls copy adjustment lines to set the retrobill_info_flag
 c. Log retrobill event in OEXULINB if it is a retrobill line (retrobill_request_id is not null)
 d. Price_line recognizes it is a retrobilling call because of the event and retrobill_request_id
 e. Process_adjustment (within the price_line call) will perform post processing for lines and adjustments.
 f. If the line has retrobilled before, get the difference by sum  ULP, USP, ULPPQTY, USPPQTY.
 g. Updated applied_flag = N on any adjustment has
 h. If price negative then change line category RETURN, pricing recursion Y oe_order_pvt.lines to redefault the lines.

2. Log this retrobill request into OE_RETROBILL_REQUESTS table.
     Elsif EXECUTE previous preview Then
For each retrobill_header_id in p_rectobill_line_tbl call OE_ORDER_BOOK_UTIL.Book_Order.
    Elsif PREVIEW AGAIN Then

 If;
*/
Cursor Group_Lines IS
Select  /*+ ORDERED USE_NL(t,l,h) */
  LINE_ID
, nvl(l.ORG_ID,h.ORG_ID) org_id
, l.HEADER_ID
, LINE_TYPE_ID
, LINE_NUMBER
, ORDERED_ITEM
, nvl(l.REQUEST_DATE,h.request_date) request_date
, PROMISE_DATE
, SCHEDULE_SHIP_DATE
, ORDER_QUANTITY_UOM
, PRICING_QUANTITY
, PRICING_QUANTITY_UOM
, CANCELLED_QUANTITY
--, SHIPPED_QUANTITY
, ORDERED_QUANTITY
, FULFILLED_QUANTITY
--, SHIPPING_QUANTITY
--, SHIPPING_QUANTITY_UOM
, DELIVERY_LEAD_TIME
, nvl(l.TAX_EXEMPT_FLAG,h.TAX_EXEMPT_FLAG)      TAX_EXEMPT_FLAG
, nvl(l.TAX_EXEMPT_NUMBER,h.TAX_EXEMPT_NUMBER)  TAX_EXEMPT_NUMBER
, nvl(l.TAX_EXEMPT_REASON_CODE,h.TAX_EXEMPT_REASON_CODE)   TAX_EXEMPT_REASON_CODE
, nvl(l.SHIP_FROM_ORG_ID,h.SHIP_FROM_ORG_ID)   SHIP_FROM_ORG_ID
, nvl(l.SHIP_TO_ORG_ID,h.SHIP_TO_ORG_ID)     SHIP_TO_ORG_ID
, nvl(l.INVOICE_TO_ORG_ID,h.INVOICE_TO_ORG_ID)INVOICE_TO_ORG_ID
, nvl(l.DELIVER_TO_ORG_ID,h.DELIVER_TO_ORG_ID) DELIVER_TO_ORG_ID
, nvl(l.SHIP_TO_CONTACT_ID,h.SHIP_TO_CONTACT_ID) SHIP_TO_CONTACT_ID
, nvl(l.DELIVER_TO_CONTACT_ID,h.DELIVER_TO_CONTACT_ID) DELIVER_TO_CONTACT_ID
, nvl(l.INVOICE_TO_CONTACT_ID,h.INVOICE_TO_CONTACT_ID) INVOICE_TO_CONTACT_ID
, INTMED_SHIP_TO_ORG_ID
, INTMED_SHIP_TO_CONTACT_ID
, nvl(l.SOLD_FROM_ORG_ID,h.SOLD_FROM_ORG_ID) SOLD_FROM_ORG_ID
, nvl(l.SOLD_TO_ORG_ID,h.SOLD_TO_ORG_ID) sold_to_org_id1
, nvl(l.CUST_PO_NUMBER,h.CUST_PO_NUMBER) CUST_PO_NUMBER
, nvl(l.SHIP_TOLERANCE_ABOVE,h.SHIP_TOLERANCE_ABOVE) SHIP_TOLERANCE_ABOVE
, nvl(l.SHIP_TOLERANCE_BELOW,h.SHIP_TOLERANCE_BELOW) SHIP_TOLERANCE_BELOW
--, nvl(l.DEMAND_BUCKET_TYPE_CODE,h.DEMAND_BUCKET_TYPE_CODE)
, VEH_CUS_ITEM_CUM_KEY_ID
, RLA_SCHEDULE_TYPE_CODE
, CUSTOMER_DOCK_CODE
, CUSTOMER_JOB
, CUSTOMER_PRODUCTION_LINE
, CUST_MODEL_SERIAL_NUMBER
, PROJECT_ID
, TASK_ID
, INVENTORY_ITEM_ID
, TAX_DATE
, TAX_CODE
, TAX_RATE
, nvl(l.DEMAND_CLASS_CODE,h.DEMAND_CLASS_CODE) DEMAND_CLASS_CODE
, l.PRICE_LIST_ID
, nvl(l.PRICING_DATE,h.pricing_date) pricing_date
, SHIPMENT_NUMBER
, nvl(l.AGREEMENT_ID,h.agreement_id) agreement_id
, nvl(l.SHIPMENT_PRIORITY_CODE,h.SHIPMENT_PRIORITY_CODE) SHIPMENT_PRIORITY_CODE
, nvl(l.SHIPPING_METHOD_CODE,h.SHIPPING_METHOD_CODE) SHIPPING_METHOD_CODE
, nvl(l.FREIGHT_CARRIER_CODE,h.FREIGHT_CARRIER_CODE) FREIGHT_CARRIER_CODE
, nvl(l.FREIGHT_TERMS_CODE,h.FREIGHT_TERMS_CODE)  FREIGHT_TERMS_CODE
, nvl(l.FOB_POINT_CODE,h.FOB_POINT_CODE)  FOB_POINT_CODE                                              , nvl(l.TAX_POINT_CODE,h.TAX_POINT_CODE) TAX_POINT_CODE
, nvl(l.PAYMENT_TERM_ID,h.PAYMENT_TERM_ID) PAYMENT_TERM_ID
, nvl(l.INVOICING_RULE_ID,h.INVOICING_RULE_ID)  INVOICING_RULE_ID
, nvl(l.ACCOUNTING_RULE_ID,h.ACCOUNTING_RULE_ID)  ACCOUNTING_RULE_ID
, nvl(l.SOURCE_DOCUMENT_TYPE_ID,h.SOURCE_DOCUMENT_TYPE_ID) SOURCE_DOCUMENT_TYPE_ID
, l.ORIG_SYS_DOCUMENT_REF
, nvl(l.SOURCE_DOCUMENT_ID,h.SOURCE_DOCUMENT_ID) SOURCE_DOCUMENT_ID
, l.ORIG_SYS_LINE_REF
, l.SOURCE_DOCUMENT_LINE_ID
, ITEM_REVISION
, UNIT_SELLING_PRICE
, UNIT_LIST_PRICE
, TAX_VALUE
, TOP_MODEL_LINE_ID
, LINK_TO_LINE_ID
, COMPONENT_SEQUENCE_ID
, COMPONENT_CODE
, CONFIG_DISPLAY_SEQUENCE
, SORT_ORDER
, ITEM_TYPE_CODE
--, OPTION_NUMBER
, OPTION_FLAG
, DEP_PLAN_REQUIRED_FLAG
, VISIBLE_DEMAND_FLAG
, LINE_CATEGORY_CODE
--, ACTUAL_SHIPMENT_DATE
, CUSTOMER_TRX_LINE_ID
, ACTUAL_ARRIVAL_DATE
, ATO_LINE_ID
, AUTO_SELECTED_QUANTITY
, COMPONENT_NUMBER
, EARLIEST_ACCEPTABLE_DATE
, EXPLOSION_DATE
, LATEST_ACCEPTABLE_DATE
, MODEL_GROUP_NUMBER
, SCHEDULE_ARRIVAL_DATE
, SHIP_MODEL_COMPLETE_FLAG
, SCHEDULE_STATUS_CODE
, SOURCE_TYPE_CODE
, l.CANCELLED_FLAG
, l.OPEN_FLAG
, l.BOOKED_FLAG
, nvl(l.SALESREP_ID,h.SALESREP_ID)SALESREP_ID
, ARRIVAL_SET_ID
, SHIP_SET_ID
, SPLIT_FROM_LINE_ID
, CUST_PRODUCTION_SEQ_NUM
, AUTHORIZED_TO_SHIP_FLAG
--, OVER_SHIP_REASON_CODE
--, OVER_SHIP_RESOLVED_FLAG
, ORDERED_ITEM_ID
, ITEM_IDENTIFIER_TYPE
, CONFIGURATION_ID
, COMMITMENT_ID
--, SHIPPING_INTERFACED_FLAG
, CREDIT_INVOICE_LINE_ID
, l.FIRST_ACK_CODE
, l.FIRST_ACK_DATE
, l.LAST_ACK_CODE
, l.LAST_ACK_DATE
--, PLANNING_PRIORITY
, l.ORDER_SOURCE_ID   --Order source id at the line ??
, ORIG_SYS_SHIPMENT_REF
, nvl(l.CHANGE_SEQUENCE,h.CHANGE_SEQUENCE)CHANGE_SEQUENCE
, nvl(l.DROP_SHIP_FLAG,h.DROP_SHIP_FLAG) DROP_SHIP_FLAG
, CUSTOMER_LINE_NUMBER
, CUSTOMER_SHIPMENT_NUMBER
, CUSTOMER_ITEM_NET_PRICE
, nvl(l.CUSTOMER_PAYMENT_TERM_ID,h.CUSTOMER_PAYMENT_TERM_ID) CUSTOMER_PAYMENT_TERM_ID
-- , nvl(l.BLANKET_NUMBER,h.BLANKET_NUMBER) BLANKET_NUMBER --bug8341909         --- bug# 8682469 : Reverted the fix done earlier
, FULFILLED_FLAG
, END_ITEM_UNIT_NUMBER
, CONFIG_HEADER_ID
, CONFIG_REV_NBR
, MFG_COMPONENT_SEQUENCE_ID
--, nvl(l.SHIPPING_INSTRUCTIONS,h.SHIPPING_INSTRUCTIONS) SHIPPING_INSTRUCTIONS
--, nvl(l.PACKING_INSTRUCTIONS,h.PACKING_INSTRUCTIONS) PACKING_INSTRUCTIONS
, INVOICED_QUANTITY
, REFERENCE_CUSTOMER_TRX_LINE_ID
, SPLIT_BY
, LINE_SET_ID
, SERVICE_TXN_REASON_CODE
, SERVICE_TXN_COMMENTS
, SERVICE_DURATION
, SERVICE_START_DATE
, SERVICE_END_DATE
, SERVICE_COTERMINATE_FLAG
, UNIT_LIST_PERCENT
, UNIT_SELLING_PERCENT
, UNIT_PERCENT_BASE_PRICE
, SERVICE_NUMBER
, SERVICE_PERIOD
, SHIPPABLE_FLAG
, MODEL_REMNANT_FLAG
, RE_SOURCE_FLAG
--, FLOW_STATUS_CODE
, FULFILLMENT_METHOD_CODE
, nvl(l.MARKETING_SOURCE_CODE_ID,h.MARKETING_SOURCE_CODE_ID)MARKETING_SOURCE_CODE_ID
, SERVICE_REFERENCE_TYPE_CODE
, SERVICE_REFERENCE_LINE_ID
, SERVICE_REFERENCE_SYSTEM_ID
, CALCULATE_PRICE_FLAG
, l.UPGRADED_FLAG
, REVENUE_AMOUNT
, FULFILLMENT_DATE
, PREFERRED_GRADE
, ORDERED_QUANTITY2
, ORDERED_QUANTITY_UOM2
--,SHIPPING_QUANTITY2
, CANCELLED_QUANTITY2
, SHIPPED_QUANTITY2
--, SHIPPING_QUANTITY_UOM2
, FULFILLED_QUANTITY2
, MFG_LEAD_TIME
--,LOCK_CONTROL
, SUBINVENTORY
, UNIT_LIST_PRICE_PER_PQTY
, UNIT_SELLING_PRICE_PER_PQTY
, nvl(l.PRICE_REQUEST_CODE,h.PRICE_REQUEST_CODE) PRICE_REQUEST_CODE
, ORIGINAL_INVENTORY_ITEM_ID
, ORIGINAL_ORDERED_ITEM_ID
, ORIGINAL_ORDERED_ITEM
, ORIGINAL_ITEM_IDENTIFIER_TYPE
, ITEM_SUBSTITUTION_TYPE_CODE
, OVERRIDE_ATP_DATE_CODE
, LATE_DEMAND_PENALTY_FACTOR
, nvl(l.ACCOUNTING_RULE_DURATION,h.ACCOUNTING_RULE_DURATION)ACCOUNTING_RULE_DURATION
, USER_ITEM_DESCRIPTION
, UNIT_COST
, RETROBILL_REQUEST_ID
--,h.SOLD_TO_ORG_ID
, h.TRANSACTIONAL_CURR_CODE
, h.CONVERSION_TYPE_CODE
, h.Order_Number
, h.Order_Type_Id
, t.value PLSQL_TBL_INDEX
FROM OM_ID_LIST_TMP        t,
     OE_ORDER_LINES_ALL    l,
     OE_ORDER_HEADERS_ALL  h
WHERE l.line_id = t.key_id
AND   l.header_id = h.header_id
ORDER BY sold_to_org_id1,h.transactional_curr_code,h.conversion_type_code;


G_CURRENT_RETROBILL_REQUEST_ID NUMBER;
G_LINES_NOT_RETRO_DISPLAYED VARCHAR2(1);
G_PKG_NAME VARCHAR2(30):='OE_RETROBILL_PVT';
--bug3738043
G_RETRO_PRICING_PHASE_COUNT NUMBER := 0;

-- 3661895
-- This for caching the retrobill bill only lines returned by interface_retrobilled_rma
TYPE  Retro_Bill_Only_Line_Type IS RECORD
(   header_id             NUMBER          := NULL
  , line_id               NUMBER          := NULL
);

TYPE Retro_Bill_Only_Line_Tbl_Type IS TABLE OF Retro_Bill_Only_Line_Type index by binary_integer;
G_Retro_Bill_Only_Line_Tbl       Retro_Bill_Only_Line_Tbl_Type;
/*******************************************************************
This procedure display message in message stack for debuggin purpose
*******************************************************************/
Procedure display_message(p_msg_count IN NUMBER,
                           p_msg_data  IN VARCHAR2) AS
l_msg_data VARCHAR2(5000);
l_msg_count NUMBER;
Begin
oe_debug_pub.add('no. of OE messages :'||p_msg_count);
for k in 1 .. p_msg_count loop
        l_msg_data := oe_msg_pub.get( p_msg_index => k,
                        p_encoded => 'F'
                        );
        oe_debug_pub.add(substr(l_msg_data,1,255));
        oe_debug_pub.add('Error msg: '||substr(l_msg_data,1,200));
end loop;

fnd_msg_pub.count_and_get( p_encoded    => 'F'
                          ,p_count      => l_msg_count
                          ,p_data       => l_msg_data);

--oe_debug_pub.add('no. of FND messages :'||l_msg_count,1);
oe_debug_pub.add('no. of FND messages :'||l_msg_count);

for k in 1 .. l_msg_count loop
       l_msg_data := fnd_msg_pub.get( p_msg_index => k,
                                      p_encoded => 'F'
                                    );
        oe_debug_pub.add('Error msg: '||substr(l_msg_data,1,200));
        oe_debug_pub.add(substr(l_msg_data,1,255));
end loop;

End;

PROCEDURE Get_Last_Retro_HdrID(p_header_id IN NUMBER,
                                x_header_id OUT NOCOPY NUMBER) AS
Cursor last_retrobill_line IS
Select max(header_id)
From   OE_ORDER_LINES_ALL l
Where  l.order_source_id = 27
And    l.orig_sys_document_ref = to_char(p_header_id) -- p_header_id --commented for bug#7665009
And    retrobill_request_id <> G_CURRENT_RETROBILL_REQUEST_ID;

l_retro_line_id   Number;
l_retro_header_id Number;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_query_line_id Number;
l_query_header_id Number;

Begin

If l_debug_level > 0 Then
  oe_debug_pub.add('Entering oe_retrobill_pvt.get_last_retro...input header_id:'||p_header_id);
End If;

--!!!Need to check system param, if no retrobill should return the same header_id immediately
--to save processing time!!!
OPEN last_retrobill_line;
Fetch last_retrobill_line Into l_retro_header_id;
Close last_retrobill_line;

IF l_retro_header_id IS NULL THEN
 --null header id, has not been retrobilled
 x_header_id:=p_header_id;
ELSE
 x_header_id:=l_retro_header_id;
END IF;

If l_debug_level > 0 Then
  oe_debug_pub.add('Exiting oe_retrobill_pvt.get_last_retro...output header_id:'||x_header_id);
End If;

Exception
When Others then
 oe_debug_pub.add('Retro:get_last_retro_HdrID:'||SQLERRM);
 x_header_id:=p_header_id;

End;


PROCEDURE Get_Last_Retro_LinID(p_line_id IN NUMBER,
                                x_line_id OUT NOCOPY NUMBER) AS
Cursor last_retrobill_line IS
Select max(l.line_id)
From   OE_ORDER_LINES_ALL l,
       OE_ORDER_LINES_ALL b
Where  l.order_source_id = 27
And    l.orig_sys_document_ref = b.header_id
And    l.orig_sys_line_ref = to_char(p_line_id) -- p_line_id --commented for bug#7665009
And    l.retrobill_request_id <> G_CURRENT_RETROBILL_REQUEST_ID
AND    b.line_id = p_line_id;
l_retro_line_id   Number;
l_retro_header_id Number;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_query_line_id Number;
l_query_header_id Number;
Begin

If l_debug_level > 0 Then
  oe_debug_pub.add('Entering oe_retrobill_pvt.get_last_retro...input Line_id:'||p_line_id);
End If;

--!!!Need to check system param, if no retrobill should return the same header_id immediately
--to save processing time!!!

OPEN last_retrobill_line;
Fetch last_retrobill_line Into l_retro_line_id;
Close last_retrobill_line;

IF l_retro_line_id IS NULL THEN
 --null line id, has not been retrobilled
 x_line_id:=p_line_id;
ELSE
 x_line_id:=l_retro_line_id;
END IF;

If l_debug_level > 0 Then
  oe_debug_pub.add('Exiting oe_retrobill_pvt.get_last_retro...output line_id:'||x_line_id);
End If;

Exception
When Others then
 oe_debug_pub.add('Retro:get_last_retro_linID:'||SQLERRM);
 x_line_id:=p_line_id;
End;


FUNCTION Get_First_Line_Price_List_Id RETURN NUMBER AS
Begin
   G_FIRST_LINE_PL_ASSIGNED:='Y';
Return G_FIRST_LINE_PRICE_LIST_ID;
End;

--bug3738043 This function returns the number of pricing phases other than List Line Base Price Phase where the RETROBILL event is attached.
--The global variable G_RETRO_PRICING_PHASE_COUNT is initialized by calling this function in the procedure Perform_Operations if it is preview again
FUNCTION Get_Retro_Pricing_Phase_Count RETURN NUMBER AS
   l_retro_pricing_phase_count NUMBER := 0;
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

      SELECT count(*) INTO l_retro_pricing_phase_count
      FROM  qp_pricing_phases p,
	    qp_event_phases e
      WHERE p.pricing_phase_id=e.pricing_phase_id
      AND   p.pricing_phase_id <> 1
      AND   e.pricing_event_code='RETROBILL'
      AND   trunc(sysdate) BETWEEN  trunc(nvl(e.end_date_active,sysdate))
                           AND trunc(nvl(e.end_date_active,sysdate));
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add('IN Get_Retro_Pricing_Phase_count: The number of phases for RETROBILL event other than 1 is ' || l_retro_pricing_phase_count);
      END IF;

      RETURN l_retro_pricing_phase_count;
EXCEPTION
      WHEN OTHERS THEN
	 RETURN 0;
END;

/******************************************************************
This function returns total sum amount a line has been retrobilled.
For example if someone returns a $10 item and the line has been
retrobilled twice, one time $4 and another time $3. The retrobilled
sum amount will be $7. We should return a credit of 10 - 7 to the
buyer instead of $10
******************************************************************/
Procedure Get_Retrobilled_Sum(p_header_id     IN  NUMBER,
                              p_line_id       IN  NUMBER,
                              p_curr_retro_id IN  NUMBER DEFAULT -999,
                              x_usp_sum       OUT NOCOPY NUMBER,
                              x_ulp_sum       OUT NOCOPY NUMBER) AS
l_usp_sum NUMBER:=0;
l_ulp_sum NUMBER:=0;

cursor retro_sum IS
select sum(oeol1.unit_selling_price * decode(oeol1.line_category_code,'RETURN',-1,1)),
       sum(oeol1.unit_list_price    * decode(oeol1.line_category_code,'RETURN',-1,1))
From   oe_order_lines_all oeol1
Where oeol1.order_source_id = G_RETROBILL_ORDER_SOURCE_ID
and   oeol1.orig_sys_document_ref = to_char(p_header_id) --p_header_id --commented for bug#7665009
and   oeol1.orig_sys_line_ref = to_char(p_line_id) --p_line_id --commented for bug#7665009
and   nvl(oeol1.retrobill_request_id,-1) <> p_curr_retro_id; --exclude current retrobill line

Begin
 OPEN retro_sum;
 FETCH retro_sum INTO x_usp_sum,x_ulp_sum;
 CLOSE retro_sum;

 x_usp_sum:=nvl(x_usp_sum,0);
 x_ulp_sum:=nvl(x_ulp_sum,0);

Exception
When Others Then
oe_debug_pub.add('Retro:Get_Retrobilled_Sum:'||SQLERRM);
Raise;
End;

Procedure Get_Return_Price(p_header_id IN NUMBER,
                           p_line_id   IN NUMBER,
			   p_ordered_qty IN NUMBER,--bug3540728
			   p_pricing_qty IN NUMBER,--bug3540728
                           p_usp       IN NUMBER,
                           p_ulp       IN NUMBER,
                           x_usp       OUT NOCOPY NUMBER,
                           x_ulp       OUT NOCOPY NUMBER,
			   x_ulp_ppqty OUT NOCOPY NUMBER,--bug3540728
			   x_usp_ppqty OUT NOCOPY NUMBER) AS --bug3540728
l_usp_sum NUMBER;
l_ulp_sum NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
Begin
Get_Retrobilled_Sum(p_header_id=>p_header_id,
                    p_line_id  =>p_line_id,
                    x_usp_sum  =>l_usp_sum,
                    x_ulp_sum  =>l_ulp_sum);

IF l_debug_level > 0 THEN
 oe_debug_pub.add('Retro:Input header_id:'||p_header_id);
 oe_debug_pub.add('Retro:Input line_id:'||p_line_id);
 oe_debug_pub.add('Retro:Input USP:'||p_usp);
 oe_debug_pub.add('Retro:Input ULP:'||p_ulp);
END IF;

x_usp:=p_usp + l_usp_sum;
x_ulp:=p_ulp + l_ulp_sum;
--bug3540728 added the IF condition so that the _per_pqty fields will be populated with l_ref_line_id's values in OEXDLINB.pls if there are no retrobill lines.
IF (l_usp_sum <> 0 OR l_ulp_sum <>0) THEN
x_ulp_ppqty := (p_ulp + l_ulp_sum) * (nvl(p_ordered_qty,nvl(p_pricing_qty,1))/nvl(p_pricing_qty,1));
x_usp_ppqty := (p_usp + l_usp_sum) * (nvl(p_ordered_qty,nvl(p_pricing_qty,1))/nvl(p_pricing_qty,1));
END IF;
--bug3540728 end

IF l_debug_level > 0 THEN
 oe_debug_pub.add('Retro:Return usp_sum:'||l_usp_sum);
 oe_debug_pub.add('Retro:Return ulp_sum:'||l_ulp_sum);
 oe_debug_pub.add('Retro:Return USP:'||x_usp);
 oe_debug_pub.add('Retro:Return ULP:'||x_ulp);
 oe_debug_pub.add('Retro:Return ULP_PER_PQTY:'||x_ulp_ppqty);
 oe_debug_pub.add('Retro:Return USP_PER_PQTY:'||x_usp_ppqty);
END IF;

End;

/*****************************************************************
Validate Tax_Code and Tax_Date
******************************************************************/
Function Is_Tax_Code_Valid(p_header_id IN NUMBER,
			   p_line_id IN NUMBER,
			   p_tax_code IN VARCHAR2,
                           p_tax_date IN DATE,
                           p_org_id IN NUMBER) RETURN BOOLEAN AS
l_dummy Varchar2(5);
l_order_number NUMBER;
l_line_no VARCHAR2(30);

Begin
-- EBTax Changes
            SELECT 'VALID'
              INTO l_dummy
              FROM ZX_OUTPUT_CLASSIFICATIONS_V
             WHERE LOOKUP_CODE = p_tax_code
               AND ORG_ID IN (p_org_id, -99)
	       AND TRUNC(p_tax_date)
	   BETWEEN TRUNC(START_DATE_ACTIVE) AND
	           TRUNC(NVL(END_DATE_ACTIVE, p_tax_date))
               AND ROWNUM = 1;

   RETURN TRUE;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
    BEGIN
       SELECT order_number INTO l_order_number
       FROM oe_order_headers_all
       WHERE header_id=p_header_id;

       l_line_no := OE_ORDER_MISC_PUB.GET_CONCAT_LINE_NUMBER(p_line_id);
    EXCEPTION
       WHEN no_data_found THEN
	  null;
       WHEN too_many_rows THEN
	  null;
    END;


    oe_debug_pub.add('Retro:Tax code invalid');
    FND_MESSAGE.SET_NAME('ONT','ONT_RETROBILL_TAX_INVALID');
    FND_MESSAGE.SET_TOKEN('TAX_CODE',p_tax_code);
    FND_MESSAGE.SET_TOKEN('ORDER',l_order_number);
    FND_MESSAGE.SET_TOKEN('LINE',l_line_no);
    OE_MSG_PUB.Add;
    RETURN FALSE;
   WHEN OTHERS THEN
    oe_debug_pub.add('Retro:IS_TAX_CODE_VALID:'||SQLERRM);
    RETURN FALSE;
End;

--key header and line is to facilate an index search to oe_order_lines_all
--p_adjustment_level value is either 'HEADER' or 'LINE'. 'HEADER' means
--query order level adjustment and 'LINE' means query line level adjustment
PROCEDURE Get_Most_Recent_Retro_Adj
(p_key_header_id IN NUMBER,
 p_key_line_id   IN NUMBER,
 p_adjustment_level IN VARCHAR2,
 x_retro_exists OUT NOCOPY BOOLEAN, --bug3738043
 x_line_adj_tbl OUT NOCOPY OE_ORDER_PUB.LINE_ADJ_TBL_TYPE) AS

Cursor last_retrobill_line IS
Select max(line_id),
       max(header_id)
From   OE_ORDER_LINES_ALL l
Where  l.order_source_id = 27
And    l.orig_sys_document_ref = to_char(p_key_header_id) --p_key_header_id --commented for bug#7665009
And    l.orig_sys_line_ref = to_char(p_key_line_id) --p_key_line_id --commented for bug#7665009
And    retrobill_request_id <> G_CURRENT_RETROBILL_REQUEST_ID;
l_retro_line_id   Number;
l_retro_header_id Number;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_query_line_id Number;
l_query_header_id Number;

Begin
OPEN last_retrobill_line;
Fetch last_retrobill_line Into l_retro_line_id,l_retro_header_id;
Close last_retrobill_line;

IF l_retro_line_id IS NULL THEN
  --No previous retrobill line perform a reqular query_
  --IF l_debug_level > 0 THEN
    oe_debug_pub.add('Retro: no previous retrobill line');
  --END IF;
  l_query_line_id   := p_key_line_id;
  l_query_header_id := p_key_header_id;
  x_retro_exists := FALSE; --bug3738043
ELSIF l_retro_line_id IS NOT NULL THEN
  l_query_line_id   := l_retro_line_id;
  l_query_header_id := l_retro_header_id;
  x_retro_exists := TRUE; --bug3738043
  --IF l_debug_level > 0 THEN
   oe_debug_pub.add('Retro:Previoulsy Retrobilled, Get Most Recent Adj:retro line id:'||l_retro_line_id);
  --END IF;
End IF;


IF p_adjustment_level = 'HEADER' THEN
   oe_debug_pub.add('RETRO:QUERY Order level adjustment');
   OE_Line_Adj_Util.Query_Rows(p_header_Id => l_query_header_id
                               ,x_Line_Adj_Tbl => x_Line_Adj_Tbl);
ELSE
   oe_debug_pub.add('RETRO:QUERY line level adjustment');
   OE_Line_Adj_Util.Query_Rows(p_line_Id => l_query_line_id
			      ,x_Line_Adj_Tbl => x_Line_Adj_Tbl);
END IF;

Exception
 When Others Then
 oe_debug_pub.add('Retro:'||SQLERRM);
END;

/******************************************************************
 To get a invoice id of the original line
*******************************************************************/
Function Get_Credit_Invoice_Line_Id(p_order_number  IN NUMBER,
                                    p_order_type_id IN NUMBER,
                                    p_line_id       IN NUMBER)
Return Number As

Cursor Get_CI_Line_Id Is
Select customer_trx_line_id  --customer_trx_line_id is the invoice_id
From   ra_customer_trx_lines_all a,
       oe_transaction_types_tl b
Where  INTERFACE_LINE_CONTEXT= 'ORDER ENTRY'
and    INTERFACE_LINE_ATTRIBUTE1=to_char(p_order_number) ----bug5138249
and    INTERFACE_LINE_ATTRIBUTE2=b.name
and    INTERFACE_LINE_ATTRIBUTE6=to_char(p_line_id) --bug5138249
and    INTERFACE_LINE_ATTRIBUTE11 = '0'
and    a.org_id = (select org_id from oe_order_lines_all where line_id = p_line_id) --bug# 8448816
and    b.transaction_type_id = p_order_type_id
and    b.language = (select language_code from fnd_languages where  installed_flag = 'B');

--CONTEXT,ATTRIBUTE1,ATTRIBUTE2 and ATTRIBUTE6 will hit a concatenate index in AR table
l_ci_id NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
Begin
 --should not be multiple, just in case
 For i IN  Get_CI_Line_Id Loop
   l_ci_id:=i.customer_trx_line_id;
 End Loop;

  If l_debug_level > 0 Then
   oe_debug_pub.add('Retro:Leaving get credit invoice id:'||l_ci_id);
  End If;

 Return l_ci_id;

End;

/******************************************************************
--This is mainly for preview again or reprice of retrobill lines scenario.
--Before calling pricing engine this procedure will be called from
--OEXVOPRB.pls oe_order_price_pvt.
--First delete the offset adjustments and then update the current
--adjustment with the most recent retrobill adjustment if the
--line has been retrobilled (either previewed or executed) before.
--After calling pricing engine, a new offset adj will be created
--this offset will be most_recent_retrobill_adj - adj_returned_by_pricing engine.
--And the we will again update the original adjustment
******************************************************************/

Procedure Preprocess_Adjustments(p_orig_sys_document_ref IN NUMBER
                                 ,p_orig_sys_line_ref IN NUMBER
				 ,p_header_id IN NUMBER --bug3738043
                                 ,p_line_id IN NUMBER) As
--bug3738043 start
CURSOR retro_list_line_ids IS
SELECT price_adjustment_id, list_line_id
FROM  oe_price_adjustments
WHERE line_id = p_line_id
AND retrobill_request_id IS NOT NULL
AND list_line_type_code IN ('DIS', 'SUR', 'PBH');

cursor retro_inv_list_line_id(p_list_line_id in number, p_line_id in number) is
SELECT list_line_id
FROM  oe_price_adjustments
WHERE line_id = p_line_id
AND retrobill_request_id IS NOT NULL
AND list_line_type_code IN ('DIS', 'SUR', 'PBH')
AND list_line_id = p_list_line_id
AND line_id      = p_line_id;
--bug3738043 end

l_line_adj_tbl OE_ORDER_PUB.LINE_ADJ_TBL_TYPE;
i PLS_INTEGER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--bug3738043 start
l_new_price_adj_id_tbl OE_GLOBALS.NUMBER_TBL_TYPE;
k PLS_INTEGER := 1 ;
l_found BOOLEAN := FALSE;
l_dummy NUMBER;
l_retro_exists BOOLEAN;
--bug3738043 end
Begin

if l_debug_level > 0 then
oe_debug_pub.add('Entering oe_retro_pvt.preprocess_adjustments');
end if;

--bug3738043 start
IF l_debug_level > 0 THEN
     oe_debug_pub.add('PVIPRANA: retrobill header_id: ' || p_header_id);
     oe_debug_pub.add('PVIPRANA: retrobill line_id: ' || p_line_id);
END IF;
--bug3738043 end

DELETE From OE_PRICE_ADJUSTMENTS
WHERE  line_id = p_line_id
AND    retrobill_request_id IS NULL
AND    list_line_type_code <> 'TAX';

Get_Most_Recent_Retro_Adj
(p_key_header_id =>p_orig_sys_document_ref,
 p_key_line_id   =>p_orig_sys_line_ref,
 p_adjustment_level =>'LINE',
 x_retro_exists => l_retro_exists, --bug3738043
 x_line_adj_tbl=>l_line_adj_tbl);

i:=l_line_adj_tbl.first;
WHILE I IS NOT NULL LOOP

 if l_debug_level > 0 then
   oe_debug_pub.add(' list_line_no: ' || l_line_adj_tbl(i).list_line_no || ' list_line_id: ' || l_line_adj_tbl(i).list_line_id);
   oe_debug_pub.add(' operand queried:'||l_line_adj_tbl(i).operand||' operand_perpqty:'||l_line_adj_tbl(i).operand_per_pqty);
   oe_debug_pub.add(' list_line_type_code:'||l_line_adj_tbl(i).list_line_type_code||'applied_flag:'||l_line_adj_tbl(i).applied_flag);   oe_debug_pub.add(' adjusted amount:'||l_line_adj_tbl(i).adjusted_amount);
   oe_debug_pub.add(' adj_amt_pqty:'||l_line_adj_tbl(i).adjusted_amount_per_pqty);
   oe_debug_pub.add(' retrobill_request_id: '||l_line_adj_tbl(i).retrobill_request_id);
 end if;
 --bug3738043 adding the following condition
 IF (l_retro_exists AND l_line_adj_tbl(i).retrobill_request_id IS NOT NULL) OR
      NOT l_retro_exists THEN
    UPDATE OE_PRICE_ADJUSTMENTS
       SET operand = l_line_adj_tbl(i).operand,
           operand_per_pqty = l_line_adj_tbl(i).operand_per_pqty,
           adjusted_amount = l_line_adj_tbl(i).adjusted_amount,
           adjusted_amount_per_pqty = l_line_adj_tbl(i).adjusted_amount_per_pqty,
           applied_flag = 'Y'
       WHERE  line_id = p_line_id
       AND    retrobill_request_id IS NOT NULL
       AND    list_line_id = l_line_adj_tbl(i).list_line_id;

   --bug3738043 begin
   --narrowing down the scope to avoid regression, only phase_count > 0 will activate this code
   -- This is to insert to adjustments which are present in original line or previous retrobill line but currently invalid in the pricing set up
  IF nvl(G_RETRO_PRICING_PHASE_COUNT,0) > 0 THEN
    OPEN retro_inv_list_line_id(l_line_adj_tbl(i).list_line_id,p_line_id);
    FETCH  retro_inv_list_line_id into l_dummy;
    IF  retro_inv_list_line_id%NOTFOUND THEN
     IF l_line_adj_tbl(i).LIST_LINE_TYPE_CODE IN ('DIS', 'SUR', 'PBH') THEN
	IF l_debug_level > 0 THEN
	   oe_debug_pub.add('PVIPRANA: Inserting Invalid list_line_id ' || l_line_adj_tbl(i).list_line_id);
	END IF;

	l_line_adj_tbl(i).line_id := p_line_id;
	l_line_adj_tbl(i).header_id := p_header_id;
	l_line_adj_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;

	SELECT Oe_Price_Adjustments_S.Nextval
	INTO   l_line_adj_tbl(i).price_adjustment_id
	FROM   dual;

	OE_LINE_ADJ_UTIL.Insert_Row(l_line_adj_tbl(i));
     END IF; --end check for 'DIS', 'PBH' and 'SUR'
    END IF;

    close retro_inv_list_line_id;
  End If;
 END IF; --check for retrobill_request_id NOT NULL
  --bug3738043 end
 i:= l_line_adj_tbl.next(i);
END LOOP;

--bug3738043 start
IF l_debug_level > 0 THEN
   oe_debug_pub.add('PVIPRANA: G_RETRO_PRICING_PHASE_COUNT is  ' || G_RETRO_PRICING_PHASE_COUNT);
END IF;

IF nvl(G_RETRO_PRICING_PHASE_COUNT,0) > 0 THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('PVIPRANA: deleting the new adjustments with retrobill_request_id NOT null');
   END IF;


   FOR retro_list_line_id IN retro_list_line_ids LOOP
      I:=l_line_adj_tbl.first;
      l_found := FALSE;
      WHILE I IS NOT NULL LOOP
          IF retro_list_line_id.list_line_id = l_line_adj_tbl(i).list_line_id AND
	    --bug3749627 added the following condition
	    ((l_retro_exists AND l_line_adj_tbl(i).retrobill_request_id IS NOT NULL) OR
            NOT l_retro_exists )THEN
              l_found := TRUE;
              EXIT;
          ELSE
              i:= l_line_adj_tbl.next(i);
          END IF;
      END LOOP;

      IF NOT l_found THEN
	 l_new_price_adj_id_tbl(k) := retro_list_line_id.price_adjustment_id;
	 k := k+1;
	 IF l_debug_level > 0 THEN
	    oe_debug_pub.add('PVIPRANA: new list_line_id ' || retro_list_line_id.list_line_id);
	 END IF;
      END IF;

   END LOOP;


   IF l_debug_level > 0 THEN
      oe_debug_pub.add('PVIPRANA: Deleting ' || (k-1) || ' new adjustments');
   END IF;

   IF l_new_price_adj_id_tbl.FIRST IS NOT NULL THEN

      FORALL i IN  l_new_price_adj_id_tbl.FIRST..l_new_price_adj_id_tbl.LAST
      DELETE FROM oe_price_adjustments
      WHERE price_adjustment_id=l_new_price_adj_id_tbl(i);

   END IF;

END IF;
--bug3738043 end

if l_debug_level > 0 then
oe_debug_pub.add('Leaving oe_retro_pvt.preprocess_adjustments');
end if;
--bug3738043
Exception
   when others then
      oe_debug_pub.add('Exception in Preprocess Adjustments ' || SQLERRM);

End;

/***************************************************************
This function returns quantity which is still eligible for the
purpose of retrobilling.
Input: Line Id to be retrobilled.
       Curr Ordered Qty, current ordered quantity for the line to be retrobilled.
Output: Quantity that are eligible for retrobilling.
****************************************************************/
Function Get_Retrobillable_Qty(p_line_id Number,
                               p_curr_ordered_qty Number) Return Number As
Cursor Return_Lines Is
Select sum(ordered_quantity)
From   Oe_Order_Lines_All
Where  reference_line_id = p_line_id
And    line_category_code = 'RETURN';


l_qty Number:=0;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

Begin

Open Return_Lines;
Fetch Return_Lines Into l_qty;
Close Return_Lines;

If nvl(l_qty,0) = 0 Then
  --all curr qty are eligible for returns
  Return  p_curr_ordered_qty;
Else
  If l_debug_level > 0 Then
   oe_debug_pub.add('Retro:Returned Qty:'||l_qty);
   oe_debug_pub.add('Retro:Retrobillable Qty:'|| p_curr_ordered_qty - l_qty);
  End If;
  Return p_curr_ordered_qty - l_qty;
End If;

Exception
When NO_DATA_FOUND Then
  oe_debug_pub.add('Retro:No returns against line_id:'||p_line_id);
  Return  p_curr_ordered_qty;
End;

/*************************************************************
This  procdures update oe_retrobill_requests table
*************************************************************/
Procedure Update_Row(p_retrobill_request_rec IN OE_RETROBILL_REQUESTS%ROWTYPE) AS
Begin
oe_debug_pub.add('Retro:Entering Update retrobill request,request_id:'||p_retrobill_request_rec.retrobill_request_id);
UPDATE OE_RETROBILL_REQUESTS
SET
  NAME =                  p_retrobill_request_rec.name
, DESCRIPTION =           p_retrobill_request_rec.description
, EXECUTION_MODE=         p_retrobill_request_rec.execution_mode
, ORDER_TYPE_ID =         p_retrobill_request_rec.order_type_id
, RETROBILL_REASON_CODE=  p_retrobill_request_rec.retrobill_reason_code
, EXECUTION_DATE=         nvl(p_retrobill_request_rec.execution_date,SYSDATE)
, INVENTORY_ITEM_ID=      p_retrobill_request_rec.inventory_item_id
, SOLD_TO_ORG_ID   =      p_retrobill_request_rec.sold_to_org_id
, CREATION_DATE    =      nvl(p_retrobill_request_rec.creation_date,SYSDATE)
, CREATED_BY       =      nvl(p_retrobill_request_rec.created_by,fnd_global.user_id)
, LAST_UPDATE_DATE =      nvl(p_retrobill_request_rec.last_update_date,SYSDATE)
, LAST_UPDATED_BY  =      nvl(p_retrobill_request_rec.last_updated_by,fnd_global.user_id)
, LAST_UPDATE_LOGIN=      nvl(p_retrobill_request_rec.last_update_login,fnd_global.login_id)
, REQUEST_ID       =      p_retrobill_request_rec.request_id
, PROGRAM_APPLICATION_ID= nvl(p_retrobill_request_rec.program_application_id,fnd_global.prog_appl_id)
, PROGRAM_ID       =      p_retrobill_request_rec.program_id
, PROGRAM_UPDATED_DATE=	 p_retrobill_request_rec.program_updated_date
Where retrobill_request_id = p_retrobill_request_rec.retrobill_request_id;

oe_debug_pub.add('Retro:Leaving Update retrobill request:'||SQL%ROWCOUNT||' updated');
Exception
When Others Then
oe_debug_pub.add('Retro:Update_Row:'||SQLERRM);
End;

/**************************************************************
This procedure calls process order api to create headers and lines
***************************************************************/
Procedure Call_Process_Order(p_header_rec In Oe_Order_Pub.Header_Rec_Type,
                             p_line_tbl   In Oe_Order_Pub.Line_Tbl_Type,
                             p_Line_price_Att_tbl IN Oe_Order_Pub.Line_Price_Att_Tbl_Type, -- 8736629
                             x_created_header_id Out NOCOPY Number,
                             x_return_status Out NOCOPY Varchar2) As

l_Header_price_Att_tbl		OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_Header_Adj_Att_tbl		OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_Header_Adj_Assoc_tbl		OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
--l_Line_price_Att_tbl		OE_Order_PUB.Line_Price_Att_Tbl_Type; -- 8736629
l_Line_Adj_Att_tbl			OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_Line_Adj_Assoc_tbl		OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
l_x_header_rec                     OE_Order_PUB.Header_Rec_Type;
l_line_rec                    OE_Order_PUB.Line_Rec_Type;
l_line_adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_line_adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_Line_Scredit_out_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_action_request_out_tbl        OE_Order_PUB.request_tbl_type;
l_lot_serial_tbl	      OE_Order_PUB.lot_serial_tbl_type;
l_x_Line_price_Att_tbl         Oe_Order_Pub.Line_Price_Att_Tbl_Type; -- 8736629
l_return_status               Varchar2(30);
l_file_val				Varchar2(30);
x_msg_count                   number;
x_msg_data                    Varchar2(2000);
x_msg_index                     number;
v						Varchar2(30);
Begin

l_x_line_tbl := p_line_tbl;
l_x_header_rec:=p_header_rec;
l_x_Line_price_Att_tbl := p_Line_price_Att_tbl; --8736629
OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_FALSE
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_validation_level		=> OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF
--    ,   p_validation_level		=> FND_API.G_VALID_LEVEL_NONE
    ,   p_x_header_rec                  => l_x_header_rec
    ,   p_x_Header_Adj_tbl              => l_x_Header_Adj_tbl
    ,   p_x_Header_Scredit_tbl          => l_x_Header_Scredit_tbl
    ,   p_x_line_tbl                    => l_x_line_tbl
    ,   p_x_Line_Adj_tbl                => l_Line_Adj_tbl
    ,   p_x_Line_Scredit_tbl            => l_Line_Scredit_out_tbl
    ,   p_x_Action_Request_tbl          => l_Action_Request_out_Tbl
    ,   p_x_lot_serial_tbl              => l_lot_serial_tbl
    ,p_x_Header_price_Att_tbl  => l_Header_price_Att_tbl
    ,p_x_Header_Adj_Att_tbl    => l_Header_Adj_Att_tbl
    ,p_x_Header_Adj_Assoc_tbl  => l_Header_Adj_Assoc_tbl
    --,p_x_Line_price_Att_tbl    => l_Line_price_Att_tbl -- 8736629
    ,p_x_Line_price_Att_tbl    => l_x_Line_price_Att_tbl -- 8736629
    ,p_x_Line_Adj_Att_tbl => l_Line_Adj_Att_tbl
    ,p_x_Line_Adj_Assoc_tbl    => l_Line_Adj_Assoc_tbl
    );

x_created_header_id:=l_x_header_rec.header_id;

oe_debug_pub.add('no. of OE messages :'||x_msg_count);
for k in 1 .. x_msg_count loop
        x_msg_data := oe_msg_pub.get( p_msg_index => k,
                        p_encoded => 'F'
                        );
oe_debug_pub.add(substr(x_msg_data,1,255));
        oe_debug_pub.add('Error msg: '||substr(x_msg_data,1,200));
end loop;

fnd_msg_pub.count_and_get( p_encoded    => 'F'
                         , p_count      => x_msg_count
                        , p_data        => x_msg_data);
--oe_debug_pub.add('no. of FND messages :'||x_msg_count,1);
oe_debug_pub.add('no. of FND messages :'||x_msg_count);
for k in 1 .. x_msg_count loop
       x_msg_data := fnd_msg_pub.get( p_msg_index => k,
                        p_encoded => 'F'
                        );
        oe_debug_pub.add('Error msg: '||substr(x_msg_data,1,200));
        oe_debug_pub.add(substr(x_msg_data,1,255));
end loop;

oe_debug_pub.add('header id created:'||l_x_header_rec.header_id);

End;


/**************************************************************
This procedure preprocess a retrobill line before passing it to
process order.
***************************************************************/
Procedure Prepare_Line(p_oline_rec             In  GROUP_LINES%ROWTYPE,
                       p_retrobill_tbl         In  RETROBILL_TBL_TYPE,
                       p_retrobill_request_rec In  OE_RETROBILL_REQUESTS%ROWTYPE,
                       x_line_rec              Out NOCOPY OE_ORDER_PUB.LINE_REC_TYPE) AS
l_retrobillable_qty NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
stmt NUMBER:=7.1;
Begin
 --Copy Original Attributes to retrobill line
x_line_rec.org_id                          :=p_oline_rec.org_id                        ;
x_line_rec.ORDERED_ITEM                    :=p_oline_rec.ORDERED_ITEM                  ;
--x_line_rec.request_date                    :=p_oline_rec.request_date                ;
x_line_rec.ORDER_QUANTITY_UOM              :=p_oline_rec.ORDER_QUANTITY_UOM            ;
--x_line_rec.DELIVERY_LEAD_TIME              :=p_oline_rec.DELIVERY_LEAD_TIME          ;
stmt:=7.2;
x_line_rec.TAX_EXEMPT_FLAG                 :=p_oline_rec.TAX_EXEMPT_FLAG                     ;
x_line_rec.TAX_EXEMPT_NUMBER               :=p_oline_rec.TAX_EXEMPT_NUMBER                   ;
x_line_rec.TAX_EXEMPT_REASON_CODE          :=p_oline_rec.TAX_EXEMPT_REASON_CODE              ;
x_line_rec.TAX_DATE                        :=p_oline_rec.TAX_DATE                            ;
x_line_rec.TAX_CODE                        :=p_oline_rec.TAX_CODE                            ;
x_line_rec.TAX_RATE                        :=p_oline_rec.TAX_RATE                            ;
stmt:=7.3;
x_line_rec.SHIP_FROM_ORG_ID                :=p_oline_rec.SHIP_FROM_ORG_ID                    ;
x_line_rec.SHIP_TO_ORG_ID                  :=p_oline_rec.SHIP_TO_ORG_ID                      ;
x_line_rec.INVOICE_TO_ORG_ID                 :=p_oline_rec.INVOICE_TO_ORG_ID                   ;
x_line_rec.DELIVER_TO_ORG_ID               :=p_oline_rec.DELIVER_TO_ORG_ID                   ;
x_line_rec.SHIP_TO_CONTACT_ID              :=p_oline_rec.SHIP_TO_CONTACT_ID                  ;
x_line_rec.DELIVER_TO_CONTACT_ID           :=p_oline_rec.DELIVER_TO_CONTACT_ID               ;
x_line_rec.INVOICE_TO_CONTACT_ID           :=p_oline_rec.INVOICE_TO_CONTACT_ID               ;
--x_line_rec.INTMED_SHIP_TO_ORG_ID           :=p_oline_rec.INTMED_SHIP_TO_ORG_ID               ;
--x_line_rec.INTMED_SHIP_TO_CONTACT_ID       :=p_oline_rec.INTMED_SHIP_TO_CONTACT_ID           ;
x_line_rec.SOLD_FROM_ORG_ID                :=p_oline_rec.SOLD_FROM_ORG_ID                    ;
x_line_rec.sold_to_org_id                  :=p_oline_rec.sold_to_org_id1                     ;
x_line_rec.CUST_PO_NUMBER                  :=p_oline_rec.CUST_PO_NUMBER                      ;
--x_line_rec.VEH_CUS_ITEM_CUM_KEY_ID         :=p_oline_rec.VEH_CUS_ITEM_CUM_KEY_ID             ;
--x_line_rec.RLA_SCHEDULE_TYPE_CODE          :=p_oline_rec.RLA_SCHEDULE_TYPE_CODE              ;
--x_line_rec.CUSTOMER_DOCK_CODE              :=p_oline_rec.CUSTOMER_DOCK_CODE                  ;
--x_line_rec.CUSTOMER_JOB                    :=p_oline_rec.CUSTOMER_JOB                        ;
--x_line_rec.CUSTOMER_PRODUCTION_LINE        :=p_oline_rec.CUSTOMER_PRODUCTION_LINE            ;
--x_line_rec.CUST_MODEL_SERIAL_NUMBER        :=p_oline_rec.CUST_MODEL_SERIAL_NUMBER            ;
x_line_rec.PROJECT_ID                      :=p_oline_rec.PROJECT_ID                          ;
x_line_rec.TASK_ID                         :=p_oline_rec.TASK_ID                             ;
x_line_rec.INVENTORY_ITEM_ID               :=p_oline_rec.INVENTORY_ITEM_ID                   ;
--x_line_rec.DEMAND_CLASS_CODE               :=p_oline_rec.DEMAND_CLASS_CODE                   ;
x_line_rec.PRICE_LIST_ID                   :=p_oline_rec.PRICE_LIST_ID                       ;
x_line_rec.agreement_id                    :=p_oline_rec.agreement_id                        ;
x_line_rec.PAYMENT_TERM_ID                 :=p_oline_rec.PAYMENT_TERM_ID                     ;
x_line_rec.INVOICING_RULE_ID               :=p_oline_rec.INVOICING_RULE_ID                   ;
x_line_rec.ACCOUNTING_RULE_ID              :=p_oline_rec.ACCOUNTING_RULE_ID                  ;
--x_line_rec.SOURCE_DOCUMENT_TYPE_ID     	   :=p_oline_rec.SOURCE_DOCUMENT_TYPE_ID             ;
x_line_rec.ORIG_SYS_DOCUMENT_REF           :=p_oline_rec.ORIG_SYS_DOCUMENT_REF               ;
x_line_rec.SOURCE_DOCUMENT_ID              :=p_oline_rec.SOURCE_DOCUMENT_ID                  ;
x_line_rec.ORIG_SYS_LINE_REF               :=p_oline_rec.ORIG_SYS_LINE_REF                   ;
x_line_rec.SOURCE_DOCUMENT_LINE_ID         :=p_oline_rec.SOURCE_DOCUMENT_LINE_ID             ;
x_line_rec.ITEM_REVISION                   :=p_oline_rec.ITEM_REVISION                       ;
x_line_rec.TAX_VALUE                       :=p_oline_rec.TAX_VALUE                           ;
--x_line_rec.TOP_MODEL_LINE_ID               :=p_oline_rec.TOP_MODEL_LINE_ID                   ;
--x_line_rec.LINK_TO_LINE_ID                 :=p_oline_rec.LINK_TO_LINE_ID                     ;
--x_line_rec.COMPONENT_SEQUENCE_ID           :=p_oline_rec.COMPONENT_SEQUENCE_ID               ;
--x_line_rec.COMPONENT_CODE                  :=p_oline_rec.COMPONENT_CODE                      ;
--x_line_rec.CONFIG_DISPLAY_SEQUENCE         :=p_oline_rec.CONFIG_DISPLAY_SEQUENCE             ;
--x_line_rec.SORT_ORDER                      :=p_oline_rec.SORT_ORDER                          ;
x_line_rec.ITEM_TYPE_CODE                  :=p_oline_rec.ITEM_TYPE_CODE                      ;
--x_line_rec.OPTION_FLAG                     :=p_oline_rec.OPTION_FLAG                         ;
--x_line_rec.ACTUAL_ARRIVAL_DATE             :=p_oline_rec.ACTUAL_ARRIVAL_DATE                 ;
--x_line_rec.ATO_LINE_ID                     :=p_oline_rec.ATO_LINE_ID                         ;
--x_line_rec.AUTO_SELECTED_QUANTITY          :=p_oline_rec.AUTO_SELECTED_QUANTITY              ;
--x_line_rec.COMPONENT_NUMBER                :=p_oline_rec.COMPONENT_NUMBER                    ;
--x_line_rec.EARLIEST_ACCEPTABLE_DATE        :=p_oline_rec.EARLIEST_ACCEPTABLE_DATE            ;
x_line_rec.EXPLOSION_DATE                  :=p_oline_rec.EXPLOSION_DATE                      ;
x_line_rec.LATEST_ACCEPTABLE_DATE          :=p_oline_rec.LATEST_ACCEPTABLE_DATE              ;
x_line_rec.MODEL_GROUP_NUMBER              :=p_oline_rec.MODEL_GROUP_NUMBER                  ;
x_line_rec.SHIP_MODEL_COMPLETE_FLAG        :=p_oline_rec.SHIP_MODEL_COMPLETE_FLAG            ;
--bug5114210 commenting the following
--x_line_rec.SCHEDULE_STATUS_CODE            :=p_oline_rec.SCHEDULE_STATUS_CODE                ;
x_line_rec.SOURCE_TYPE_CODE                :=p_oline_rec.SOURCE_TYPE_CODE                    ;
x_line_rec.SALESREP_ID                     :=p_oline_rec.SALESREP_ID                         ;
--x_line_rec.ARRIVAL_SET_ID                  :=p_oline_rec.ARRIVAL_SET_ID                      ;
--x_line_rec.SHIP_SET_ID                     :=p_oline_rec.SHIP_SET_ID                         ;
--x_line_rec.SPLIT_FROM_LINE_ID              :=p_oline_rec.SPLIT_FROM_LINE_ID                  ;
x_line_rec.CUST_PRODUCTION_SEQ_NUM         :=p_oline_rec.CUST_PRODUCTION_SEQ_NUM             ;
x_line_rec.ORDERED_ITEM_ID                 :=p_oline_rec.ORDERED_ITEM_ID                     ;
x_line_rec.ITEM_IDENTIFIER_TYPE            :=p_oline_rec.ITEM_IDENTIFIER_TYPE                ;
x_line_rec.CONFIGURATION_ID                :=p_oline_rec.CONFIGURATION_ID                    ;
--x_line_rec.COMMITMENT_ID                   :=p_oline_rec.COMMITMENT_ID                       ;
x_line_rec.CREDIT_INVOICE_LINE_ID          :=p_oline_rec.CREDIT_INVOICE_LINE_ID              ;
--x_line_rec.FIRST_ACK_CODE                  :=p_oline_rec.FIRST_ACK_CODE                      ;
--x_line_rec.FIRST_ACK_DATE                  :=p_oline_rec.FIRST_ACK_DATE                      ;
--x_line_rec.LAST_ACK_CODE                   :=p_oline_rec.LAST_ACK_CODE                       ;
--x_line_rec.LAST_ACK_DATE                   :=p_oline_rec.LAST_ACK_DATE                       ;
x_line_rec.ORDER_SOURCE_ID   		   :=p_oline_rec.ORDER_SOURCE_ID                     ;
x_line_rec.ORIG_SYS_SHIPMENT_REF           :=p_oline_rec.ORIG_SYS_SHIPMENT_REF               ;
x_line_rec.CHANGE_SEQUENCE                 :=p_oline_rec.CHANGE_SEQUENCE                     ;
x_line_rec.DROP_SHIP_FLAG                  :=p_oline_rec.DROP_SHIP_FLAG                      ;
x_line_rec.CUSTOMER_LINE_NUMBER            :=p_oline_rec.CUSTOMER_LINE_NUMBER                ;
x_line_rec.CUSTOMER_SHIPMENT_NUMBER        :=p_oline_rec.CUSTOMER_SHIPMENT_NUMBER            ;
x_line_rec.CUSTOMER_ITEM_NET_PRICE         :=p_oline_rec.CUSTOMER_ITEM_NET_PRICE             ;
x_line_rec.CUSTOMER_PAYMENT_TERM_ID  	   :=p_oline_rec.CUSTOMER_PAYMENT_TERM_ID            ;
x_line_rec.FULFILLED_FLAG                  :=p_oline_rec.FULFILLED_FLAG                      ;
x_line_rec.END_ITEM_UNIT_NUMBER            :=p_oline_rec.END_ITEM_UNIT_NUMBER                ;
x_line_rec.CONFIG_HEADER_ID                :=p_oline_rec.CONFIG_HEADER_ID                    ;
x_line_rec.CONFIG_REV_NBR                  :=p_oline_rec.CONFIG_REV_NBR                      ;
x_line_rec.MFG_COMPONENT_SEQUENCE_ID       :=p_oline_rec.MFG_COMPONENT_SEQUENCE_ID           ;
x_line_rec.REFERENCE_CUSTOMER_TRX_LINE_ID  :=p_oline_rec.REFERENCE_CUSTOMER_TRX_LINE_ID      ;
--x_line_rec.SPLIT_BY                        :=p_oline_rec.SPLIT_BY                      ;
--x_line_rec.LINE_SET_ID                     :=p_oline_rec.LINE_SET_ID                     ;
x_line_rec.SERVICE_TXN_REASON_CODE         :=p_oline_rec.SERVICE_TXN_REASON_CODE         ;
x_line_rec.SERVICE_TXN_COMMENTS            :=p_oline_rec.SERVICE_TXN_COMMENTS                ;
x_line_rec.SERVICE_DURATION                :=p_oline_rec.SERVICE_DURATION                    ;
x_line_rec.SERVICE_START_DATE              :=p_oline_rec.SERVICE_START_DATE                  ;
x_line_rec.SERVICE_END_DATE                :=p_oline_rec.SERVICE_END_DATE                    ;
x_line_rec.SERVICE_COTERMINATE_FLAG        :=p_oline_rec.SERVICE_COTERMINATE_FLAG            ;
x_line_rec.UNIT_LIST_PERCENT               :=p_oline_rec.UNIT_LIST_PERCENT                   ;
x_line_rec.UNIT_SELLING_PERCENT            :=p_oline_rec.UNIT_SELLING_PERCENT                ;
x_line_rec.REVENUE_AMOUNT                  :=p_oline_rec.REVENUE_AMOUNT 		     ;
x_line_rec.UNIT_PERCENT_BASE_PRICE         :=p_oline_rec.UNIT_PERCENT_BASE_PRICE             ;
x_line_rec.SERVICE_NUMBER                  :=p_oline_rec.SERVICE_NUMBER                      ;
x_line_rec.SERVICE_PERIOD                  :=p_oline_rec.SERVICE_PERIOD                      ;       stmt:=7.4;
x_line_rec.SHIPPABLE_FLAG                  :=p_oline_rec.SHIPPABLE_FLAG                      ;
x_line_rec.MODEL_REMNANT_FLAG              :=p_oline_rec.MODEL_REMNANT_FLAG                  ;
x_line_rec.RE_SOURCE_FLAG                  :=p_oline_rec.RE_SOURCE_FLAG                      ;
x_line_rec.FULFILLMENT_METHOD_CODE         :=p_oline_rec.FULFILLMENT_METHOD_CODE             ;
x_line_rec.MARKETING_SOURCE_CODE_ID   	   :=p_oline_rec.MARKETING_SOURCE_CODE_ID            ;
x_line_rec.SERVICE_REFERENCE_TYPE_CODE     :=p_oline_rec.SERVICE_REFERENCE_TYPE_CODE         ;
x_line_rec.SERVICE_REFERENCE_LINE_ID       :=p_oline_rec.SERVICE_REFERENCE_LINE_ID           ;
x_line_rec.SERVICE_REFERENCE_SYSTEM_ID     :=p_oline_rec.SERVICE_REFERENCE_SYSTEM_ID         ;
--x_line_rec.FULFILLMENT_DATE                :=p_oline_rec.FULFILLMENT_DATE                  ;
x_line_rec.PREFERRED_GRADE                 :=p_oline_rec.PREFERRED_GRADE                     ;
x_line_rec.ORDERED_QUANTITY2               :=p_oline_rec.ORDERED_QUANTITY2                   ;
x_line_rec.ORDERED_QUANTITY_UOM2           :=p_oline_rec.ORDERED_QUANTITY_UOM2               ;
--x_line_rec.CANCELLED_QUANTITY2             :=p_oline_rec.CANCELLED_QUANTITY2                 ;
--x_line_rec.FULFILLED_QUANTITY2             :=p_oline_rec.FULFILLED_QUANTITY2                 ;
x_line_rec.MFG_LEAD_TIME                   :=p_oline_rec.MFG_LEAD_TIME                       ;
x_line_rec.SUBINVENTORY                    :=p_oline_rec.SUBINVENTORY                        ;
x_line_rec.UNIT_LIST_PRICE_PER_PQTY        :=p_oline_rec.UNIT_LIST_PRICE_PER_PQTY            ;
x_line_rec.UNIT_SELLING_PRICE_PER_PQTY     :=p_oline_rec.UNIT_SELLING_PRICE_PER_PQTY         ;
x_line_rec.UNIT_SELLING_PRICE              :=p_oline_rec.UNIT_SELLING_PRICE;
x_line_rec.UNIT_LIST_PRICE                 :=p_oline_rec.UNIT_LIST_PRICE;
x_line_rec.PRICE_REQUEST_CODE              :=p_oline_rec.PRICE_REQUEST_CODE                  ;
x_line_rec.ORIGINAL_INVENTORY_ITEM_ID      :=p_oline_rec.ORIGINAL_INVENTORY_ITEM_ID          ;
x_line_rec.ORIGINAL_ORDERED_ITEM_ID        :=p_oline_rec.ORIGINAL_ORDERED_ITEM_ID            ;
x_line_rec.ORIGINAL_ORDERED_ITEM           :=p_oline_rec.ORIGINAL_ORDERED_ITEM               ;
x_line_rec.ORIGINAL_ITEM_IDENTIFIER_TYPE   :=p_oline_rec.ORIGINAL_ITEM_IDENTIFIER_TYPE       ;
x_line_rec.ITEM_SUBSTITUTION_TYPE_CODE     :=p_oline_rec.ITEM_SUBSTITUTION_TYPE_CODE         ;
--Shipment number need to be redefault?
x_line_rec.SHIPMENT_NUMBER                 :=p_oline_rec.SHIPMENT_NUMBER;
--x_line_rec.OVERRIDE_ATP_DATE_CODE          :=p_oline_rec.OVERRIDE_ATP_DATE_CODE              ;
--x_line_rec.LATE_DEMAND_PENALTY_FACTOR      :=p_oline_rec.LATE_DEMAND_PENALTY_FACTOR          ;
x_line_rec.ACCOUNTING_RULE_DURATION   	   :=p_oline_rec.ACCOUNTING_RULE_DURATION            ;
x_line_rec.USER_ITEM_DESCRIPTION           :=p_oline_rec.USER_ITEM_DESCRIPTION               ;
--x_line_rec.UNIT_COST                       :=p_oline_rec.UNIT_COST                           ;
stmt:=7.5;
 /*******************************
 --Explicitly Set Null Attributes
 ********************************/
 x_line_rec.shipped_quantity:=NULL;
 --x_line_rec.reserve this col is not in line tablex
 x_line_rec.shipping_quantity:=NULL;
 x_line_rec.shipping_quantity_uom:=NULL;
 x_line_rec.actual_shipment_date:=NULL;
 x_line_rec.over_ship_reason_code:=NULL;
 x_line_rec.over_ship_resolved_flag:=NULL;
 x_line_rec.shipping_interfaced_flag:=NULL;
 x_line_rec.option_number:=NULL;

-- x_line_rec.Blanket_Number                        := p_oline_rec.Blanket_Number;--bug8341909     --- bug# 8682469 : Reverted the fix done earlier

 /******************************************************
 --change values to retrobilling related/specific fields
 *******************************************************/
 x_line_rec.cancelled_flag:='N';
 x_line_rec.item_type_code:='STANDARD';
 x_line_rec.pricing_date:=SYSDATE;
 x_line_rec.request_date:=SYSDATE;
 x_line_rec.pricing_quantity:=NULL;
 x_line_rec.orig_sys_document_ref:= to_char(p_oline_rec.header_id); -- p_oline_rec.header_id; --commented for bug#7665009
 x_line_rec.orig_sys_line_ref:= to_char(p_oline_rec.line_id); -- p_oline_rec.line_id; --commented for bug#7665009
 x_line_rec.calculate_price_flag:='Y';
 x_line_rec.operation:= OE_Globals.G_OPR_CREATE;
 x_line_rec.flow_status_code:='ENTERED';
 --SET line category code as 'RETURN' first because this is the most common case
 --line category code will be reset to 'ORDER' by OEXVOPRB.pls if it ends up to be
 --not a 'RETURN' line.
stmt:=7.51;
x_line_rec.LINE_CATEGORY_CODE:='RETURN';

 --Get quantity that are eligible for retrobill.
 --l_retrobillable_qty:=Get_Retrobillable_Qty(p_oline_rec.line_id,p_oline_rec.ordered_quantity);

 --If user trying to retrobill more than he is eligible to, set the quantity to eligible qty
 /* If p_retrobill_tbl(p_oline_rec.plsql_tbl_index).retrobill_qty > l_retrobillable_qty Then
  x_line_rec.ordered_quantity:=l_retrobillable_qty;
   If l_debug_level > 0 Then
     oe_debug_pub.add('Retro:User tries to retrobill more than eligible. Retrobill Qty:'|| p_retrobill_tbl(p_oline_rec.plsql_tbl_index).retrobill_qty);
   End If;
 Else*/
 oe_debug_pub.add('Retro:plsql index'||p_oline_rec.plsql_tbl_index);
  x_line_rec.ordered_quantity:=p_retrobill_tbl(p_oline_rec.plsql_tbl_index).retrobill_qty;
 --End If;

 x_line_rec.retrobill_request_id:=p_retrobill_request_rec.retrobill_request_id;
 --need to do, if reason code is null get it from sys parameter!!!
 x_line_rec.Return_Reason_Code:=p_retrobill_request_rec.retrobill_reason_code;

 x_line_rec.order_source_id:=G_RETROBILL_ORDER_SOURCE_ID;
 --x_line_rec.Source_Document_shipment_ref:=p_retrobill_request_rec.retrobill_request_id;
 x_line_rec. ORIG_SYS_SHIPMENT_REF:=p_retrobill_request_rec.retrobill_request_id;
stmt:=7.52;
 If l_debug_level > 0 Then
  oe_debug_pub.add('Retro:invoiced_quantity:'|| p_oline_rec.invoiced_quantity);
 End If;

 If p_oline_rec.invoiced_quantity > 0 Then
   x_line_rec.credit_invoice_line_id:=Get_Credit_Invoice_Line_Id(p_oline_rec.order_number
                                                                 ,p_oline_rec.order_type_id
                                                                 ,p_oline_rec.line_id);
 End If;

 x_line_rec.Shippable_Flag:='N';
stmt:=7.6;
/******************************************************
Line info need to be validated
*******************************************************/
--We try to copy over the tax code and date, but if it fails
--in validation, we will need to ask the system to default the tax code and date
--if we default, we will to tell users about this.
IF NOT IS_TAX_CODE_VALID(p_header_id=>x_line_rec.header_id,p_line_id=>x_line_rec.line_id,p_tax_code=>x_line_rec.tax_code,p_tax_date=>x_line_rec.tax_date, p_org_id=>x_line_rec.org_id) THEN
 oe_debug_pub.add('Retro:Old tax code is no longer valid, redaulting a new one');
 x_line_rec.tax_code:=FND_API.G_MISS_CHAR;
 stmt:=7.61;
 x_line_rec.tax_rate:=FND_API.G_MISS_NUM;
 stmt:=7.62;
 x_line_rec.tax_date:=FND_API.G_MISS_DATE;
END IF;

/******************************************************
--Line info need to be defaulted
*******************************************************/
x_line_rec.LINE_TYPE_ID:=FND_API.G_MISS_NUM;
stmt:=7.63;
x_line_rec.line_id:=FND_API.G_MISS_NUM;
stmt:=7.64;
x_line_rec.line_number:=FND_API.G_MISS_NUM;
stmt:=7.65;
x_line_rec.open_flag:=FND_API.G_MISS_CHAR;
stmt:=7.66;
x_line_rec.booked_flag:=FND_API.G_MISS_CHAR;
stmt:=7.67;

-- x_line_rec.ship_to_org_id:=FND_API.G_MISS_NUM; -- Commented for bug 5612169

 If l_debug_level > 0 Then
   oe_debug_pub.add('Retro: leaving prepare line');
 End If;

Exception
  When Others then
  oe_debug_pub.add('Exception occured at statement:'||stmt||':'||SQLERRM);
  raise;
End;

PROCEDURE Prepare_Header(p_cust_po_number      IN VARCHAR2,  -- Bug# 6603714
                       p_sold_to_org_id        IN NUMBER,
                       p_transaction_curr_code IN VARCHAR2,
                       p_conversion_type_code  IN VARCHAR2,
                       p_retrobill_request_rec IN OUT NOCOPY OE_RETROBILL_REQUESTS%ROWTYPE,
                       x_header_rec OUT NOCOPY OE_ORDER_PUB.HEADER_REC_TYPE) AS
l_order_type_id Number;
l_pl_tbl        QP_UTIL_PUB.price_list_tbl;
l_valid_price_list_id Number;
--internal private profile for debugging only.
G_INT_USE_ANY_VALID_PL Varchar2(3);
Begin
--GSCC (not initializing during declaration)
 G_INT_USE_ANY_VALID_PL := nvl(FND_PROFILE.VALUE('ONT_USE_ANY_VALID_PL'),'N');
 x_header_rec.sold_to_org_id       := p_sold_to_org_id;
 x_header_rec.transactional_curr_code:=p_transaction_curr_code;
 x_header_rec.conversion_type_code:=p_conversion_type_code;
 x_header_rec.operation            :=OE_Globals.G_OPR_CREATE;
 x_header_rec.ordered_date         :=SYSDATE;
 --Should pric list get defaulted? Or just plain copy?
 x_header_rec.price_list_id         :=FND_API.G_MISS_NUM;
 x_header_rec.header_id             :=FND_API.G_MISS_NUM;
 x_header_rec.version_number        :=1;
 x_header_rec.invoice_to_org_id     :=FND_API.G_MISS_NUM;
 x_header_rec.open_flag             :='Y';
 x_header_rec.booked_flag           :='N';
 x_header_rec.ship_to_org_id        :=FND_API.G_MISS_NUM;
 x_header_rec.tax_exempt_flag       :=FND_API.G_MISS_CHAR;
 x_header_rec.tax_exempt_number	    :=FND_API.G_MISS_CHAR;
 x_header_rec.tax_exempt_reason_code:=FND_API.G_MISS_CHAR;
 x_header_rec.payment_term_id       :=FND_API.G_MISS_NUM;
 x_header_rec.salesrep_id           :=FND_API.G_MISS_NUM;
 x_header_rec.flow_status_code      :='ENTERED';
 x_header_rec.order_source_id       :=G_RETROBILL_ORDER_SOURCE_ID;
 x_header_rec.orig_sys_document_ref :=p_retrobill_request_rec.retrobill_request_id;
 x_header_rec.cust_po_number        :=p_cust_po_number; -- Bug# 6603714
 oe_debug_pub.add('x_header_rec.cust_po_number'||x_header_rec.cust_po_number);

 If p_retrobill_request_rec.order_type_id IS NULL Then
   null;
   --get order type id from sys parameter
   --....need to code !!! to populare l_order_type_id based on sys param.
   --p_retrobill_request_rec.order_type_id :=l_order_type_id;
 Else
   l_order_type_id:= p_retrobill_request_rec.order_type_id;
 End If;
 x_header_rec.order_type_id        :=l_order_type_id;

IF G_INT_USE_ANY_VALID_PL = 'Y' THEN
 --although price at header doesn't matter for retrobilling because each line
 --might have their own price list, however, it will fail in header validation if
 --the price list does not valid. We need to assign a valid price list for the header
 QP_UTIL_PUB.Get_Price_List(l_currency_code=>p_transaction_curr_code,
                            l_pricing_effective_date=>SYSDATE,
                            l_agreement_id=>NULL,
                            l_price_list_tbl=>l_pl_tbl,
                            l_sold_to_org_id=>p_sold_to_org_id
);

 IF l_pl_tbl.First IS NOT NULL THEN
   l_valid_price_list_id := l_pl_tbl(l_pl_tbl.First).price_list_id;
   oe_debug_pub.add('RETRO:Valid Price List to be defaulted is:'||l_pl_tbl(l_pl_tbl.First).price_list_id);
 ELSE
   oe_debug_pub.add('RETRO:ERROR:UNABLE TO DEFAULT A VALID HEADER PRICE LIST');
 END IF;
 x_header_rec.price_list_id:=l_valid_price_list_id;
END IF; --end if for g_int_use_any_valid_pl

 oe_debug_pub.add('Retro:Order Type id:'||x_header_rec.order_type_id);
 oe_debug_pub.add('Retro:sold to org id:'||x_header_rec.sold_to_org_id);
 oe_debug_pub.add('Retro:currency:'||x_header_rec.transactional_curr_code);
End;

PROCEDURE Insert_Id(p_retrobill_tbl IN RETROBILL_TBL_TYPE) As
l_id_tbl OE_GLOBALS.NUMBER_TBL_TYPE;
l_value_tbl  OE_GLOBALS.NUMBER_TBL_TYPE; --store the index of p_retrobill_tbl for line_id
i NUMBER;
j NUMBER:=1;
Begin

i:=p_retrobill_tbl.first;

WHILE i IS NOT NULL LOOP
 l_id_tbl(j):=p_retrobill_tbl(i).original_line_id;
 l_value_tbl(j):=i;
 i:=p_retrobill_tbl.next(i);
 j:=j+1;
END LOOP;

DELETE FROM OM_ID_LIST_TMP;

--USE BULK INSERT TO MAXIMIZE PERFORMANCE
IF l_id_tbl.FIRST IS NOT NULL THEN
 FORALL j IN  l_id_tbl.FIRST..l_id_tbl.LAST
 INSERT INTO OM_ID_LIST_TMP(KEY_ID,VALUE)
 VALUES (l_id_tbl(j),l_value_tbl(j));
END IF;

Exception
When Others Then
  oe_debug_pub.add('Execption occured in Oe_Retrobill_Pvt.Insert_Id:'||SQLERRM);
  Raise;
End;

/**************************************************************
This procedure was added for bug 8736629. This procedure prepares
the pricing attributes table for the line level
***************************************************************/
Procedure Prepare_Line_Pricing_Attribs(p_line_id    In  NUMBER,
                                          x_Line_price_Att_rec    Out NOCOPY Oe_Order_Pub.Line_Price_Att_Rec_Type,
                                          x_row_count OUT NOCOPY NUMBER) AS

l_row_count NUMBER := 0;
Begin

	-- query the attributes table OE_ORDER_PRICE_ATTRIBS and assign it to the record structure
	oe_debug_pub.add('Enter procedure Oe_Retrobill_Pvt.Prepare_Line_Pricing_Attribs:');

	SELECT
		pricing_context,
		pricing_attribute1,
		pricing_attribute2,
		pricing_attribute3,
		pricing_attribute4,
		pricing_attribute5,
		pricing_attribute6,
		pricing_attribute7,
		pricing_attribute8,
		pricing_attribute9,
		pricing_attribute10,
		pricing_attribute11,
		pricing_attribute12,
		pricing_attribute13,
		pricing_attribute14,
		pricing_attribute15,
		pricing_attribute16,
		pricing_attribute17,
		pricing_attribute18,
		pricing_attribute19,
		pricing_attribute20,
		pricing_attribute21,
		pricing_attribute22,
		pricing_attribute23,
		pricing_attribute24,
		pricing_attribute25,
		pricing_attribute26,
		pricing_attribute27,
		pricing_attribute28,
		pricing_attribute29,
		pricing_attribute30,
		pricing_attribute31,
		pricing_attribute32,
		pricing_attribute33,
		pricing_attribute34,
		pricing_attribute35,
		pricing_attribute36,
		pricing_attribute37,
		pricing_attribute38,
		pricing_attribute39,
		pricing_attribute40,
		pricing_attribute41,
		pricing_attribute42,
		pricing_attribute43,
		pricing_attribute44,
		pricing_attribute45,
		pricing_attribute46,
		pricing_attribute47,
		pricing_attribute48,
		pricing_attribute49,
		pricing_attribute50,
		pricing_attribute51,
		pricing_attribute52,
		pricing_attribute53,
		pricing_attribute54,
		pricing_attribute55,
		pricing_attribute56,
		pricing_attribute57,
		pricing_attribute58,
		pricing_attribute59,
		pricing_attribute60,
		pricing_attribute61,
		pricing_attribute62,
		pricing_attribute63,
		pricing_attribute64,
		pricing_attribute65,
		pricing_attribute66,
		pricing_attribute67,
		pricing_attribute68,
		pricing_attribute69,
		pricing_attribute70,
		pricing_attribute71,
		pricing_attribute72,
		pricing_attribute73,
		pricing_attribute74,
		pricing_attribute75,
		pricing_attribute76,
		pricing_attribute77,
		pricing_attribute78,
		pricing_attribute79,
		pricing_attribute80,
		pricing_attribute81,
		pricing_attribute82,
		pricing_attribute83,
		pricing_attribute84,
		pricing_attribute85,
		pricing_attribute86,
		pricing_attribute87,
		pricing_attribute88,
		pricing_attribute89,
		pricing_attribute90,
		pricing_attribute91,
		pricing_attribute92,
		pricing_attribute93,
		pricing_attribute94,
		pricing_attribute95,
		pricing_attribute96,
		pricing_attribute97,
		pricing_attribute98,
		pricing_attribute99,
		pricing_attribute100,
		context,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		attribute10,
		attribute11,
		attribute12,
		attribute13,
		attribute14,
		attribute15,
		flex_title ,
		override_flag,
		lock_control,
		orig_sys_atts_ref
	INTO
		x_Line_price_Att_rec.pricing_context,
		x_Line_price_Att_rec.pricing_attribute1,
		x_Line_price_Att_rec.pricing_attribute2,
		x_Line_price_Att_rec.pricing_attribute3,
		x_Line_price_Att_rec.pricing_attribute4,
		x_Line_price_Att_rec.pricing_attribute5,
		x_Line_price_Att_rec.pricing_attribute6,
		x_Line_price_Att_rec.pricing_attribute7,
		x_Line_price_Att_rec.pricing_attribute8,
		x_Line_price_Att_rec.pricing_attribute9,
		x_Line_price_Att_rec.pricing_attribute10,
		x_Line_price_Att_rec.pricing_attribute11,
		x_Line_price_Att_rec.pricing_attribute12,
		x_Line_price_Att_rec.pricing_attribute13,
		x_Line_price_Att_rec.pricing_attribute14,
		x_Line_price_Att_rec.pricing_attribute15,
		x_Line_price_Att_rec.pricing_attribute16,
		x_Line_price_Att_rec.pricing_attribute17,
		x_Line_price_Att_rec.pricing_attribute18,
		x_Line_price_Att_rec.pricing_attribute19,
		x_Line_price_Att_rec.pricing_attribute20,
		x_Line_price_Att_rec.pricing_attribute21,
		x_Line_price_Att_rec.pricing_attribute22,
		x_Line_price_Att_rec.pricing_attribute23,
		x_Line_price_Att_rec.pricing_attribute24,
		x_Line_price_Att_rec.pricing_attribute25,
		x_Line_price_Att_rec.pricing_attribute26,
		x_Line_price_Att_rec.pricing_attribute27,
		x_Line_price_Att_rec.pricing_attribute28,
		x_Line_price_Att_rec.pricing_attribute29,
		x_Line_price_Att_rec.pricing_attribute30,
		x_Line_price_Att_rec.pricing_attribute31,
		x_Line_price_Att_rec.pricing_attribute32,
		x_Line_price_Att_rec.pricing_attribute33,
		x_Line_price_Att_rec.pricing_attribute34,
		x_Line_price_Att_rec.pricing_attribute35,
		x_Line_price_Att_rec.pricing_attribute36,
		x_Line_price_Att_rec.pricing_attribute37,
		x_Line_price_Att_rec.pricing_attribute38,
		x_Line_price_Att_rec.pricing_attribute39,
		x_Line_price_Att_rec.pricing_attribute40,
		x_Line_price_Att_rec.pricing_attribute41,
		x_Line_price_Att_rec.pricing_attribute42,
		x_Line_price_Att_rec.pricing_attribute43,
		x_Line_price_Att_rec.pricing_attribute44,
		x_Line_price_Att_rec.pricing_attribute45,
		x_Line_price_Att_rec.pricing_attribute46,
		x_Line_price_Att_rec.pricing_attribute47,
		x_Line_price_Att_rec.pricing_attribute48,
		x_Line_price_Att_rec.pricing_attribute49,
		x_Line_price_Att_rec.pricing_attribute50,
		x_Line_price_Att_rec.pricing_attribute51,
		x_Line_price_Att_rec.pricing_attribute52,
		x_Line_price_Att_rec.pricing_attribute53,
		x_Line_price_Att_rec.pricing_attribute54,
		x_Line_price_Att_rec.pricing_attribute55,
		x_Line_price_Att_rec.pricing_attribute56,
		x_Line_price_Att_rec.pricing_attribute57,
		x_Line_price_Att_rec.pricing_attribute58,
		x_Line_price_Att_rec.pricing_attribute59,
		x_Line_price_Att_rec.pricing_attribute60,
		x_Line_price_Att_rec.pricing_attribute61,
		x_Line_price_Att_rec.pricing_attribute62,
		x_Line_price_Att_rec.pricing_attribute63,
		x_Line_price_Att_rec.pricing_attribute64,
		x_Line_price_Att_rec.pricing_attribute65,
		x_Line_price_Att_rec.pricing_attribute66,
		x_Line_price_Att_rec.pricing_attribute67,
		x_Line_price_Att_rec.pricing_attribute68,
		x_Line_price_Att_rec.pricing_attribute69,
		x_Line_price_Att_rec.pricing_attribute70,
		x_Line_price_Att_rec.pricing_attribute71,
		x_Line_price_Att_rec.pricing_attribute72,
		x_Line_price_Att_rec.pricing_attribute73,
		x_Line_price_Att_rec.pricing_attribute74,
		x_Line_price_Att_rec.pricing_attribute75,
		x_Line_price_Att_rec.pricing_attribute76,
		x_Line_price_Att_rec.pricing_attribute77,
		x_Line_price_Att_rec.pricing_attribute78,
		x_Line_price_Att_rec.pricing_attribute79,
		x_Line_price_Att_rec.pricing_attribute80,
		x_Line_price_Att_rec.pricing_attribute81,
		x_Line_price_Att_rec.pricing_attribute82,
		x_Line_price_Att_rec.pricing_attribute83,
		x_Line_price_Att_rec.pricing_attribute84,
		x_Line_price_Att_rec.pricing_attribute85,
		x_Line_price_Att_rec.pricing_attribute86,
		x_Line_price_Att_rec.pricing_attribute87,
		x_Line_price_Att_rec.pricing_attribute88,
		x_Line_price_Att_rec.pricing_attribute89,
		x_Line_price_Att_rec.pricing_attribute90,
		x_Line_price_Att_rec.pricing_attribute91,
		x_Line_price_Att_rec.pricing_attribute92,
		x_Line_price_Att_rec.pricing_attribute93,
		x_Line_price_Att_rec.pricing_attribute94,
		x_Line_price_Att_rec.pricing_attribute95,
		x_Line_price_Att_rec.pricing_attribute96,
		x_Line_price_Att_rec.pricing_attribute97,
		x_Line_price_Att_rec.pricing_attribute98,
		x_Line_price_Att_rec.pricing_attribute99,
		x_Line_price_Att_rec.pricing_attribute100,
		x_Line_price_Att_rec.context,
		x_Line_price_Att_rec.attribute1,
		x_Line_price_Att_rec.attribute2,
		x_Line_price_Att_rec.attribute3,
		x_Line_price_Att_rec.attribute4,
		x_Line_price_Att_rec.attribute5,
		x_Line_price_Att_rec.attribute6,
		x_Line_price_Att_rec.attribute7,
		x_Line_price_Att_rec.attribute8,
		x_Line_price_Att_rec.attribute9,
		x_Line_price_Att_rec.attribute10,
		x_Line_price_Att_rec.attribute11,
		x_Line_price_Att_rec.attribute12,
		x_Line_price_Att_rec.attribute13,
		x_Line_price_Att_rec.attribute14,
		x_Line_price_Att_rec.attribute15,
		x_Line_price_Att_rec.flex_title ,
		x_Line_price_Att_rec.override_flag,
		x_Line_price_Att_rec.lock_control,
		x_Line_price_Att_rec.orig_sys_atts_ref
	FROM oe_order_price_attribs
	WHERE line_id =p_line_id;

	l_row_count := SQL%ROWCOUNT;
	x_row_count := l_row_count;

	oe_debug_pub.add('Number of records: ' || l_row_count);
	oe_debug_pub.add('Exiting procedure Oe_Retrobill_Pvt.Prepare_Line_Pricing_Attribs:');

Exception

	WHEN NO_DATA_FOUND THEN
		oe_debug_pub.add('Line pricing attributes not populated for the original Order');
		x_row_count := 0;

	When Others Then
		oe_debug_pub.add('Execption occured in Oe_Retrobill_Pvt.Prepare_Line_Pricing_Attribs:'||SQLERRM);
		Raise;
End;



PROCEDURE INSERT_RETROBILL_REQUEST(p_retrobill_request_rec IN OE_RETROBILL_REQUESTS%ROWTYPE) AS
Begin
INSERT INTO OE_RETROBILL_REQUESTS
( RETROBILL_REQUEST_ID
,NAME
, DESCRIPTION
, EXECUTION_MODE
, ORDER_TYPE_ID
, RETROBILL_REASON_CODE
, EXECUTION_DATE
, INVENTORY_ITEM_ID
, SOLD_TO_ORG_ID
, CREATION_DATE
, CREATED_BY
, LAST_UPDATE_DATE
, LAST_UPDATED_BY
, LAST_UPDATE_LOGIN
, REQUEST_ID
, PROGRAM_APPLICATION_ID
, PROGRAM_ID
, PROGRAM_UPDATED_DATE)
VALUES
(p_retrobill_request_rec.retrobill_request_id,
 nvl(p_retrobill_request_rec.name,'RETRO TEST '||p_retrobill_request_rec.retrobill_request_id),
 p_retrobill_request_rec.description,
 p_retrobill_request_rec.execution_mode,
 p_retrobill_request_rec.order_type_id,
 p_retrobill_request_rec.retrobill_reason_code,
 nvl(p_retrobill_request_rec.execution_date,SYSDATE),
 p_retrobill_request_rec.inventory_item_id,
 p_retrobill_request_rec.sold_to_org_id,
 nvl(p_retrobill_request_rec.creation_date,SYSDATE),
 nvl(p_retrobill_request_rec.created_by,fnd_global.user_id),
 nvl(p_retrobill_request_rec.last_update_date,SYSDATE),
 nvl(p_retrobill_request_rec.last_updated_by,fnd_global.user_id),
 nvl(p_retrobill_request_rec.last_update_login,fnd_global.login_id),
 p_retrobill_request_rec.request_id,
 nvl(p_retrobill_request_rec.program_application_id,fnd_global.prog_appl_id),
 p_retrobill_request_rec.program_id,
 p_retrobill_request_rec.program_updated_date);

Exception
When Others Then
oe_debug_pub.add('RETRO error:'||SQLERRM);
oe_debug_pub.add('RETRO:INSERT_RETROBILL_REQUEST:'||SQLERRM);
End;




/**************************************************************
Called by OE_ORDER_PRICE_PVT, Update retrobill lines
based on the end results. New prie > old --> ORDER then redefault line type
If New price < old --> RETURN existing line type is fine (we always assume return) is
the most commom case
***************************************************************/
Procedure Update_Retrobill_Lines(p_operation IN VARCHAR2)
As

    Cursor priced_lines IS
        select lines.ADJUSTED_UNIT_PRICE*nvl(lines.priced_quantity,l.ordered_quantity)/l.
        ordered_quantity NEW_UNIT_SELLING_PRICE
        , lines.UNIT_PRICE*nvl(lines.priced_quantity,l.ordered_quantity)/l.ordered_quantity NEW_UNIT_LIST_PRICE
        , lines.ADJUSTED_UNIT_PRICE UNIT_SELLING_PRICE_PER_PQTY
        , lines.UNIT_PRICE UNIT_LIST_PRICE_PER_PQTY
        , decode(lines.priced_quantity,-99999,l.ordered_quantity,lines.priced_quantity)  PRICING_QUANTITY
        , decode(lines.priced_quantity,-99999,l.order_quantity_uom,lines.priced_uom_code)PRICING_QUANTITY_UOM
        , lines.price_list_header_id PRICE_LIST_ID
        , lines.price_request_code   PRICE_REQUEST_CODE
        , nvl(lines.percent_price, NULL) UNIT_LIST_PERCENT
        , nvl(lines.parent_price, NULL)  UNIT_PERCENT_BASE_PRICE
        , decode(lines.parent_price, NULL, 0, 0, 0,
               lines.adjusted_unit_price/lines.parent_price) UNIT_SELLING_PERCENT
        , l.unit_selling_price OLD_UNIT_SELLING_PRICE
        , l.unit_list_price OLD_UNIT_LIST_PRICE
        , l.line_id
        , l.header_id
        , l.retrobill_request_id
        , l.order_source_id           --source_id,orig_sys_document_ref and sys_line_ref forms an index
        , l.orig_sys_document_ref
        , l.orig_sys_line_ref
        , l.inventory_item_id        --For identifying unique item
        , l.sold_to_org_id           --For identifying unique customer
        , l.line_number
        , l.lock_control + 1 LOCK_CONTROL
       from  qp_preq_lines_tmp lines,
             oe_order_lines_all l
       where lines.line_id=l.line_id
         and lines.line_type_code='LINE'
         and lines.pricing_status_code in(QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_GSA_VIOLATION);

    cursor get_retrobilled_sum(p_order_source_id IN NUMBER,
                               p_orig_sys_document_ref IN NUMBER,
                               p_orig_sys_line_ref IN NUMBER,
                               p_curr_retro_id IN NUMBER) IS
        select sum(oeol1.unit_selling_price * decode(oeol1.line_category_code,'RETURN',-1,1)),
               sum(oeol1.unit_list_price    * decode(oeol1.line_category_code,'RETURN',-1,1))
        From   oe_order_lines_all oeol1
        Where oeol1.order_source_id = p_order_source_id
        and   oeol1.orig_sys_document_ref =  to_char(p_orig_sys_document_ref) --p_orig_sys_document_ref --commented for bug#7665009
        and   oeol1.orig_sys_line_ref = to_char(p_orig_sys_line_ref) --p_orig_sys_line_ref --commented for bug#7665009
        and   oeol1.retrobill_request_id <> p_curr_retro_id; --exclude current retrobill line

    cursor get_original_price(p_orig_sys_line_ref IN NUMBER) IS
        Select unit_selling_price,unit_list_price
        From   oe_order_lines_all
        Where  line_id = p_orig_sys_line_ref;

    cursor line_number(p_header_id IN NUMBER) IS
        Select line_id from oe_order_lines_all
        Where  header_id = p_header_id
        Order by line_id;

    l_deleted_line NUMBER :=NULL;
    l_deleted_line_hdr NUMBER :=NULL;
    k PLS_INTEGER:=1;
    l_line_id_tbl OE_GLOBALS.NUMBER_TBL_TYPE;
    l_line_num_tbl OE_GLOBALS.NUMBER_TBL_TYPE;
    l_usp_sum Number:=0;
    l_ulp_sum Number:=0;
    l_orig_usp Number:=0;
    l_orig_ulp Number:=0;
    l_retrobill_selling_price Number;
    l_retrobill_list_price Number;
    l_line_rec OE_ORDER_PUB.LINE_REC_TYPE;
    l_line_tbl OE_ORDER_PUB.LINE_TBL_TYPE;
    l_old_line_rec OE_ORDER_PUB.LINE_REC_TYPE;
    l_old_line_tbl  OE_ORDER_PUB.LINE_TBL_TYPE;
    l_debit Varchar2(1);
    j Number:=0;
    l_control_rec  OE_GLOBALS.Control_Rec_Type;
    l_return_status Varchar2(15);
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --skubendr{
    l_inventory_item_id_previous NUMBER;
    l_unique_item  BOOLEAN := TRUE;
    l_sold_to_org_id_previous NUMBER;
    l_unique_customer  BOOLEAN := TRUE;
    l_current_line_deleted VARCHAR2(1);
    --skubendr}

    l_line_category_code  VARCHAR2(100); --Bug# 8609475

BEGIN

    oe_debug_pub.add('Entering update retrobill lines  :  p_operation = '||p_operation);
 --GSCC Not initializing during declaration
  l_debit := 'N';
  l_inventory_item_id_previous := g_retrobill_request_rec.inventory_item_id;
  l_sold_to_org_id_previous := g_retrobill_request_rec.sold_to_org_id;
  l_current_line_deleted := 'N';

  FOR I IN PRICED_LINES LOOP
      open  get_retrobilled_sum(I.order_source_id,I.orig_sys_document_ref,I.orig_sys_line_ref,I.retrobill_request_id);
      fetch get_retrobilled_sum into l_usp_sum,l_ulp_sum;
      close get_retrobilled_sum;
      IF l_usp_sum IS NULL THEN l_usp_sum:=0; END IF;
      IF l_ulp_sum IS NULL THEN l_ulp_sum:=0; END IF;

     IF nvl(p_operation,'xxx') = 'CREATE' THEN
          --now get the difference between the original price and new price minus the sum (if the line has previous retrobilled before)
          l_retrobill_selling_price := I.OLD_UNIT_SELLING_PRICE + l_usp_sum - I.NEW_UNIT_SELLING_PRICE;
          l_retrobill_list_price    := I.OLD_UNIT_LIST_PRICE    + l_ulp_sum - I.NEW_UNIT_LIST_PRICE;
          --I.OLD_UNIT price can not be used because it is the difference of price if it users PREVIEW/reprice
          --the retrobill lines again, therefore we need to query the original price to get the price
     ELSE
          open get_original_price(I.orig_sys_line_ref);
          fetch get_original_price into l_orig_usp,l_orig_ulp;
          close get_original_price;
          IF l_debug_level > 0 THEN
              Oe_Debug_Pub.Add('Retro:orig_usp:'||l_orig_usp||',orig_ulp:'||l_orig_ulp);
          END IF;
          l_retrobill_selling_price := l_orig_usp + l_usp_sum - I.NEW_UNIT_SELLING_PRICE;
          l_retrobill_list_price    := l_orig_ulp + l_ulp_sum - I.NEW_UNIT_LIST_PRICE;
     END IF;

      IF l_debug_level > 0 THEN
        oe_debug_pub.add('retro-old usp:'||I.OLD_UNIT_SELLING_PRICE||' new usp:'||I.NEW_UNIT_SELLING_PRICE);
        oe_debug_pub.add('retro:usp sum'||l_usp_sum);
        oe_debug_pub.add('retro:retrobill selling_price:'|| l_retrobill_selling_price);

        oe_debug_pub.add('retro-old ulp:'||I.OLD_UNIT_LIST_PRICE||' new ULP:'||I.NEW_UNIT_LIST_PRICE);
        oe_debug_pub.add('retro:ulp sum'||l_ulp_sum);
        oe_debug_pub.add('retro:retrobill list_price:'|| l_retrobill_list_price);
      END IF;

    -------- Bug# 8609475 : Start -------
    select line_category_code into l_line_category_code
    from oe_order_lines_all
    where line_id = to_number(I.orig_sys_line_ref);

     oe_debug_pub.add(' line_category_code of original order: l_line_category_code =  '|| l_line_category_code);

    if l_line_category_code = 'RETURN' then
         l_retrobill_list_price := l_retrobill_list_price * -1;
         l_retrobill_selling_price := l_retrobill_selling_price * -1;
    end if;
     oe_debug_pub.add(' l_retrobill_selling_price = '|| l_retrobill_selling_price);
     oe_debug_pub.add(' l_retrobill_list_price = ' || l_retrobill_list_price);
    -------- Bug# 8609475 : end -------

      --Handle the line as a 'return' because new price > old price + previously retrobilled amount
      --bug3654144
      IF l_retrobill_list_price > 0  OR
    	 (l_retrobill_list_price =  0 AND l_retrobill_selling_price > 0)
      THEN
           oe_debug_pub.add('Retro: New price is lower giving credit');
           UPDATE OE_ORDER_LINES_all l
                  SET UNIT_SELLING_PRICE         =l_retrobill_selling_price
                     ,UNIT_LIST_PRICE            =l_retrobill_list_price
                     ,UNIT_SELLING_PRICE_PER_PQTY=I.UNIT_SELLING_PRICE_PER_PQTY
                     ,UNIT_LIST_PRICE_PER_PQTY   =I.UNIT_LIST_PRICE_PER_PQTY
                     ,PRICING_QUANTITY           =I.PRICING_QUANTITY
                     ,PRICING_QUANTITY_UOM       =I.PRICING_QUANTITY_UOM
                     ,PRICE_LIST_ID              =I.PRICE_LIST_ID
                     ,PRICE_REQUEST_CODE         =I.PRICE_REQUEST_CODE
                     ,UNIT_LIST_PERCENT          =I.UNIT_LIST_PERCENT
                     ,UNIT_PERCENT_BASE_PRICE    =I.UNIT_PERCENT_BASE_PRICE
                     ,UNIT_SELLING_PERCENT       =I.UNIT_SELLING_PERCENT
                     ,CALCULATE_PRICE_FLAG       ='N'
                     ,LOCK_CONTROL               =I.LOCK_CONTROL
           WHERE l.line_id = I.line_id;
            --What about update global??? Need to think about it...
           oe_debug_pub.add('retro:updated row number:'|| SQL%ROWCOUNT||'line_id:'|| I.line_id);

          --Handle the line as a 'buy' (invoice customer) if new price is higher
          --This case will be a little complex because we are changing line_category_code
          --by doing so, many line attributes will need to be redefaulted.
          --we need to call process_order oe_order_pvt.lines to update so that redefaulting could take place.
          --bug3654144
      ELSIF l_retrobill_list_price < 0 OR
	       (l_retrobill_list_price = 0 AND l_retrobill_selling_price < 0)
      THEN
        oe_debug_pub.add('Retro: New price is higher charging more');

        l_line_rec:=Oe_Line_Util.Query_Row(I.line_id);

        oe_debug_pub.add(' Retro-0:  l_line_rec.payment_term_id = '||l_line_rec.payment_term_id
                                || ' l_line_rec.price_list_id = ' || l_line_rec.price_list_id
                                || ' l_line_rec.line_type_id = ' || l_line_rec.line_type_id
                                || ' g_retrobill_request_rec.order_type_id = ' || g_retrobill_request_rec.order_type_id
                             ) ;
        SELECT  DEFAULT_OUTBOUND_LINE_TYPE_ID INTO  l_line_rec.line_type_id
        FROM  OE_TRANSACTION_TYPES_all
        WHERE  TRANSACTION_TYPE_ID =  g_retrobill_request_rec.order_type_id    ;    -- bug# 8751523 : Added the SELECT sql

        l_old_line_rec:=l_line_rec;

        l_line_rec.unit_selling_price     :=-1 * l_retrobill_selling_price; --bug3654144
        l_line_rec.unit_list_price        :=abs(l_retrobill_list_price);
        l_line_rec.unit_selling_price_per_pqty:=-1 *I.UNIT_SELLING_PRICE_PER_PQTY;--bug3654144
        l_line_rec.unit_list_price_per_pqty:=abs(I.UNIT_LIST_PRICE_PER_PQTY);
        l_line_rec.pricing_quantity       :=I.PRICING_QUANTITY;
        l_line_rec.pricing_quantity_uom   :=I.PRICING_QUANTITY_UOM;
        l_line_rec.price_list_id          :=I.PRICE_LIST_ID;
        l_line_rec.price_request_code     :=I.PRICE_REQUEST_CODE;
        l_line_rec.unit_list_percent      :=I.UNIT_LIST_PERCENT;
        l_line_rec.unit_percent_base_price:=I.UNIT_PERCENT_BASE_PRICE;
        l_line_rec.unit_selling_percent   :=I.UNIT_SELLING_PERCENT;
        l_line_rec.line_category_code     :='ORDER';
        l_line_rec.calculate_price_flag   :='N';
        --set following to miss char such that redefault can take place.
--        l_line_rec.line_type_id           :=FND_API.G_MISS_NUM;       -- bug# 8751523 : Commented this assignment
        l_line_rec.operation              :=OE_GLOBALS.G_OPR_UPDATE;
        l_debit := 'Y';
        j:=j+1;

--        oe_default_line.attributes(p_x_line_rec   => l_line_rec, p_old_line_rec => l_old_line_rec); --- -- bug# 8751523: Commented this call

    	l_line_rec.price_list_id          :=I.PRICE_LIST_ID;
        l_old_line_rec.price_list_id      :=I.PRICE_LIST_ID;

    	oe_debug_pub.add('Price list id after setting it back:' || l_line_rec.price_list_id);
        oe_debug_pub.add('Old price list id:'||l_old_line_rec.price_list_id);
        oe_debug_pub.add(' Retro-1:  l_line_rec.payment_term_id = '||l_line_rec.payment_term_id
                                || ' l_line_rec.price_list_id = ' || l_line_rec.price_list_id
                                || ' l_line_rec.line_type_id = ' || l_line_rec.line_type_id
                             ) ;

        l_old_line_tbl(j):=l_old_line_rec;
        l_line_tbl(j):=l_line_rec;
      ELSE
         --If the selling price is the same then we remove the created line
         --skubendr{
           l_current_line_deleted := 'Y';
         --skubendr}
         oe_debug_pub.add('Retro:No price difference,delete line_id:'||I.line_id);

         l_deleted_line_hdr := I.header_id;

         IF(I.line_number =1) THEN
            G_FIRST_LINE_DELETED := 'Y';
         END IF;

         Oe_Line_Util.Delete_Row(I.line_id);

         IF G_LINES_NOT_RETRO_DISPLAYED='N' THEN
           FND_MESSAGE.SET_NAME('ONT','ONT_RETROBILL_LINES_NO_CHANGE');
           OE_MSG_PUB.ADD;
           G_LINES_NOT_RETRO_DISPLAYED:='Y';
         END IF;
      END IF;
   --skubendr{
    IF( l_current_line_deleted = 'N') THEN
        g_retrobill_request_rec.inventory_item_id := I.inventory_item_id;
        g_retrobill_request_rec.sold_to_org_id    := I.sold_to_org_id;
        IF(l_unique_item = TRUE and l_inventory_item_id_previous <> I.inventory_item_id) THEN
            l_unique_item := FALSE;
        END If;
        IF(l_unique_customer = TRUE and l_sold_to_org_id_previous <> I.sold_to_org_id) THEN
            l_unique_customer := FALSE;
        END If;
        l_inventory_item_id_previous := I.inventory_item_id;
        l_sold_to_org_id_previous    := I.sold_to_org_id;
   END If;
     l_current_line_deleted := 'N';
   --skubendr}
  END LOOP;


  IF l_debit = 'Y' THEN
    l_control_rec.controlled_operation := TRUE;
    l_control_rec.change_attributes    := TRUE;
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.check_security       := FALSE;
    l_control_rec.write_to_DB          := TRUE;
    l_control_rec.process              := FALSE;
    --  Instruct API to retain its caches
    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    -- set the pricing recursion, so that pricing will not get triggered
    -- again due to the  Oe_Order_Pub.Lines call.
    oe_globals.g_pricing_recursion := 'Y';

    Oe_Order_Pvt.Lines(p_validation_level=> FND_API.G_VALID_LEVEL_NONE,
                         p_control_rec     => l_control_rec,
                         p_x_line_tbl      => l_line_tbl,
                         p_x_old_line_tbl  => l_old_line_tbl,
                         x_return_status   => l_return_status);

    -- Reset the pricing recursion, so that pricing will get triggered after Oe_Order_Pvt.Lines call
    oe_globals.g_pricing_recursion := 'N';
    --deletion occured, need to resequence line number.
  END IF;

  IF l_deleted_line_hdr IS NOT NULL THEN
     oe_debug_pub.add('Retro:before line_num');
    FOR N IN line_number(l_deleted_line_hdr) LOOP
      l_line_num_tbl(k):= k;
      l_line_id_tbl(k):= N.LINE_ID;
      IF(G_FIRST_LINE_DELETED='Y' and k=1) THEN
         SELECT price_list_id INTO G_FIRST_LINE_PRICE_LIST_ID
         FROM oe_order_lines_all
	 WHERE line_id=N.LINE_ID;
      END IF;
      k:=k+1;
    END LOOP;
     oe_debug_pub.add('Retro:before update line_num');
    IF l_line_id_tbl.FIRST IS NOT NULL THEN
      FORALL K IN l_line_id_tbl.FIRST..l_line_id_tbl.LAST
      UPDATE OE_ORDER_LINES_ALL
      SET    LINE_NUMBER = l_line_num_tbl(K)
      WHERE  LINE_ID = l_line_id_tbl(K);
    END IF;
      oe_debug_pub.add('Retro:after update line_num'||SQL%ROWCOUNT);
  END IF;
--skubendr{
      IF(l_unique_item = FALSE) THEN
         g_retrobill_request_rec.inventory_item_id := NULL;
       END IF;
       IF(l_unique_customer = FALSE) THEN
         g_retrobill_request_rec.sold_to_org_id := NULL;
      END IF;
     oe_debug_pub.add('Customer id before inserting'||g_retrobill_request_rec.sold_to_org_id);
     oe_debug_pub.add('Inventory item id before inserting'||g_retrobill_request_rec.inventory_item_id);
--skubendr}
End;



PROCEDURE Insert_diff_Adj As
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

cursor l_debug_cur IS
select operand,operand_per_pqty,list_line_id,applied_flag,arithmetic_operator,updated_flag,adjusted_amount,adjusted_amount_per_pqty
from   oe_price_adjustments
where  retrobill_request_id = G_CURRENT_RETROBILL_REQUEST_ID;

Begin

 IF l_debug_level > 2 THEN
   --will be very slow if debug on fts will happen
    for k in l_debug_cur loop
      oe_debug_pub.add('operand:'||k.operand||'operand_per_pqty:'||k.operand_per_pqty||'list_line_id:'||k.list_line_id||
                       'applied flag:'||k.applied_flag);
      oe_debug_pub.add('arithmetic_operator:'||k.arithmetic_operator||'updated_flag:'||k.updated_flag||'adjusted_amount:'||k.adjusted_amount||'adjusted_amount_per_pqty:'||k.adjusted_amount_per_pqty||' retrobill id:'||G_CURRENT_RETROBILL_REQUEST_ID);

    end loop;
 END IF;

 INSERT INTO OE_PRICE_ADJUSTMENTS
    (       PRICE_ADJUSTMENT_ID
    ,       CREATION_DATE
    ,       CREATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_LOGIN
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       HEADER_ID
    ,       DISCOUNT_ID
    ,       DISCOUNT_LINE_ID
    ,       AUTOMATIC_FLAG
    ,       PERCENT
    ,       LINE_ID
    ,       CONTEXT
    ,       ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ORIG_SYS_DISCOUNT_REF
    ,	  LIST_HEADER_ID
    ,	  LIST_LINE_ID
    ,	  LIST_LINE_TYPE_CODE
    ,	  MODIFIER_MECHANISM_TYPE_CODE
    ,	  MODIFIED_FROM
    ,	  MODIFIED_TO
    ,	  UPDATED_FLAG
    ,	  UPDATE_ALLOWED
    ,	  APPLIED_FLAG
    ,	  CHANGE_REASON_CODE
    ,	  CHANGE_REASON_TEXT
    ,	  operand
    ,	  Arithmetic_operator
    ,	  COST_ID
    ,	  TAX_CODE
    ,	  TAX_EXEMPT_FLAG
    ,	  TAX_EXEMPT_NUMBER
    ,	  TAX_EXEMPT_REASON_CODE
    ,	  PARENT_ADJUSTMENT_ID
    ,	  INVOICED_FLAG
    ,	  ESTIMATED_FLAG
    ,	  INC_IN_SALES_PERFORMANCE
    ,	  SPLIT_ACTION_CODE
    ,	  ADJUSTED_AMOUNT
    ,	  PRICING_PHASE_ID
    ,	  CHARGE_TYPE_CODE
    ,	  CHARGE_SUBTYPE_CODE
    ,     list_line_no
    ,     source_system_code
    ,     benefit_qty
    ,     benefit_uom_code
    ,     print_on_invoice_flag
    ,     expiration_date
    ,     rebate_transaction_type_code
    ,     rebate_transaction_reference
    ,     rebate_payment_system_code
    ,     redeemed_date
    ,     redeemed_flag
    ,     accrual_flag
    ,     range_break_quantity
    ,     accrual_conversion_rate
    ,     pricing_group_sequence
    ,     modifier_level_code
    ,     price_break_type_code
    ,     substitution_attribute
    ,     proration_type_code
    ,       CREDIT_OR_CHARGE_FLAG
    ,       INCLUDE_ON_RETURNS_FLAG
    ,       AC_CONTEXT
    ,       AC_ATTRIBUTE1
    ,       AC_ATTRIBUTE2
    ,       AC_ATTRIBUTE3
    ,       AC_ATTRIBUTE4
    ,       AC_ATTRIBUTE5
    ,       AC_ATTRIBUTE6
    ,       AC_ATTRIBUTE7
    ,       AC_ATTRIBUTE8
    ,       AC_ATTRIBUTE9
    ,       AC_ATTRIBUTE10
    ,       AC_ATTRIBUTE11
    ,       AC_ATTRIBUTE12
    ,       AC_ATTRIBUTE13
    ,       AC_ATTRIBUTE14
    ,       AC_ATTRIBUTE15
    ,       OPERAND_PER_PQTY
    ,       ADJUSTED_AMOUNT_PER_PQTY
    ,	  LOCK_CONTROL
    ,     retrobill_request_id
    )
    ( SELECT     /*+ ORDERED USE_NL(ldets lines qh) */
            oe_price_adjustments_s.nextval -- p_Line_Adj_rec.price_adjustment_id
    ,       sysdate --p_Line_Adj_rec.creation_date
    ,       fnd_global.user_id --p_Line_Adj_rec.created_by
    ,       sysdate --p_Line_Adj_rec.last_update_date
    ,       fnd_global.user_id --p_Line_Adj_rec.last_updated_by
    ,       fnd_global.login_id --p_Line_Adj_rec.last_update_login
    ,       NULL --p_Line_Adj_rec.program_application_id
    ,       NULL --p_Line_Adj_rec.program_id
    ,       NULL --p_Line_Adj_rec.program_update_date
    ,       NULL --p_Line_Adj_rec.request_id
    ,       oe_order_pub.g_hdr.header_id --p_Line_Adj_rec.header_id
    ,       NULL --p_Line_Adj_rec.discount_id
    ,       NULL  --p_Line_Adj_rec.discount_line_id
    ,       ldets.automatic_flag
    ,       NULL --p_Line_Adj_rec.percent
    ,       oepj.line_id
    ,       NULL --p_Line_Adj_rec.context
    ,       NULL --p_Line_Adj_rec.attribute1
    ,       NULL --p_Line_Adj_rec.attribute2
    ,       NULL --p_Line_Adj_rec.attribute3
    ,       NULL --p_Line_Adj_rec.attribute4
    ,       NULL --p_Line_Adj_rec.attribute5
    ,       NULL --p_Line_Adj_rec.attribute6
    ,       NULL --p_Line_Adj_rec.attribute7
    ,       NULL --p_Line_Adj_rec.attribute8
    ,       NULL --p_Line_Adj_rec.attribute9
    ,       NULL --p_Line_Adj_rec.attribute10
    ,       NULL --p_Line_Adj_rec.attribute11
    ,       NULL --p_Line_Adj_rec.attribute12
    ,       NULL --p_Line_Adj_rec.attribute13
    ,       NULL --p_Line_Adj_rec.attribute14
    ,       NULL --p_Line_Adj_rec.attribute15
    ,       NULL --p_Line_Adj_rec.orig_sys_discount_ref
    ,	  ldets.LIST_HEADER_ID
    ,	  ldets.LIST_LINE_ID
    --bug3654144 Changing the list_line_type_code to 'DIS' if ldets.list_line_type_code is 'PBH'
    ,	  decode(ldets.LIST_LINE_TYPE_CODE, 'PBH', 'DIS', ldets.list_line_type_code)
    ,	  NULL --p_Line_Adj_rec.MODIFIER_MECHANISM_TYPE_CODE
    ,	  decode(ldets.list_line_type_code, 'TSN', ldets.substitution_attribute, 'IUE', to_char(ldets.inventory_item_id), NULL)
    ,	  decode(ldets.list_line_type_code, 'TSN', ldets.substitution_value_to, 'IUE', to_char(ldets.related_item_id), NULL)
    ,	  'N' --p_Line_Adj_rec.UPDATED_FLAG
    ,	  'N' --bug3896248 override_allowed
--bug3590893 setting the applied_flag to 'N' if the adjusted_amount on the modifier that is inserted for the retrobill line is 0
    ,	  decode((abs(abs(oepj.adjusted_amount) - abs(ldets.adjustment_amount*nvl(lines.priced_quantity,1)/nvl(lines.line_quantity,1))) * decode(ldets.list_line_type_code,'DIS',-1,1)),0,'N',ldets.APPLIED_FLAG)
    ,	  NULL --p_Line_Adj_rec.CHANGE_REASON_CODE
    ,	  NULL --p_Line_Adj_rec.CHANGE_REASON_TEXT
   --below is operand
   --bug3654144 modifying the calculation so that the operand is opposite in sign to adjusted_amount if the list_line_type_code = 'DIS' and same as adjusted_amount otherwise ('PBH' is considered as 'DIS' in diff adjs)
    ,	  (oepj.adjusted_amount - ldets.adjustment_amount*nvl(lines.priced_quantity,1)/nvl(lines.line_quantity,1)) * decode(oeol.line_category_code, 'RETURN', 1, -1) * decode(ldets.list_line_type_code, 'DIS', -1, 'PBH', -1, 1)
    ,	  'AMT' --arithmetic_operator hardcoded to AMT
    ,	  NULl --p_line_Adj_rec.COST_ID
    ,	  NULL --p_line_Adj_rec.TAX_CODE
    ,	  NULL --p_line_Adj_rec.TAX_EXEMPT_FLAG
    ,	  NULL --p_line_Adj_rec.TAX_EXEMPT_NUMBER
    ,	  NULL --p_line_Adj_rec.TAX_EXEMPT_REASON_CODE
    ,	  NULL --p_line_Adj_rec.PARENT_ADJUSTMENT_ID
    ,	  NULL --p_line_Adj_rec.INVOICED_FLAG
    ,	  NULL --p_line_Adj_rec.ESTIMATED_FLAG
    ,	  NULL --p_line_Adj_rec.INC_IN_SALES_PERFORMANCE
    ,	  NULL --p_line_Adj_rec.SPLIT_ACTION_CODE
--below is adjusted amount
--bug3654144 commenting the following and adding a new calculation for adjusted_amount
--    ,	  abs(abs(oepj.adjusted_amount) - abs(ldets.adjustment_amount*nvl(lines.priced_quantity,1)/nvl(lines.line_quantity,1))) * decode(ldets.list_line_type_code,'DIS',-1,1)
    ,     (oepj.adjusted_amount - ldets.adjustment_amount*nvl(lines.priced_quantity,1)/nvl(lines.line_quantity,1)) * decode(oeol.line_category_code, 'RETURN', 1, -1)
    ,	  ldets.pricing_phase_id --p_line_Adj_rec.PRICING_PHASE_ID
    ,	  ldets.CHARGE_TYPE_CODE
    ,	  ldets.CHARGE_SUBTYPE_CODE
    ,       ldets.list_line_no
    ,       qh.source_system_code
    ,       ldets.benefit_qty
    ,       ldets.benefit_uom_code
    ,       NULL --p_Line_Adj_rec.print_on_invoice_flag
    ,       ldets.expiration_date
    ,       ldets.rebate_transaction_type_code
    ,       NULL --p_Line_Adj_rec.rebate_transaction_reference
    ,       NULL --p_Line_Adj_rec.rebate_payment_system_code
    ,       NULL --p_Line_Adj_rec.redeemed_date
    ,       NULL --p_Line_Adj_rec.redeemed_flag
    ,       ldets.accrual_flag
    ,       ldets.line_quantity  --p_Line_Adj_rec.range_break_quantity
    ,       ldets.accrual_conversion_rate
    ,       ldets.pricing_group_sequence
    ,       ldets.modifier_level_code
    ,       ldets.price_break_type_code
    ,       ldets.substitution_attribute
    ,       ldets.proration_type_code
    ,       NULL --p_Line_Adj_rec.credit_or_charge_flag
    ,       ldets.include_on_returns_flag
    ,       NULL -- p_Line_Adj_rec.ac_context
    ,       NULL -- p_Line_Adj_rec.ac_attribute1
    ,       NULL -- p_Line_Adj_rec.ac_attribute2
    ,       NULL -- p_Line_Adj_rec.ac_attribute3
    ,       NULL -- p_Line_Adj_rec.ac_attribute4
    ,       NULL -- p_Line_Adj_rec.ac_attribute5
    ,       NULL -- p_Line_Adj_rec.ac_attribute6
    ,       NULL -- p_Line_Adj_rec.ac_attribute7
    ,       NULL -- p_Line_Adj_rec.ac_attribute8
    ,       NULL -- p_Line_Adj_rec.ac_attribute9
    ,       NULL -- p_Line_Adj_rec.ac_attribute10
    ,       NULL -- p_Line_Adj_rec.ac_attribute11
    ,       NULL -- p_Line_Adj_rec.ac_attribute12
    ,       NULL -- p_Line_Adj_rec.ac_attribute13
    ,       NULL -- p_Line_Adj_rec.ac_attribute14
    ,       NULL -- p_Line_Adj_rec.ac_attribute15
    --bug3654144 commenting the following and adding a new calculation of operand_per_pqty
--    ,      decode(sign(ldets.OPERAND_value),-1,oepj.operand_per_pqty-ldets.OPERAND_value, abs(oepj.operand_per_pqty - ldets.OPERAND_value))
    ,        (oepj.adjusted_amount_per_pqty - ldets.adjustment_amount) * decode(oeol.line_category_code, 'RETURN', 1, -1) * decode(ldets.list_line_type_code, 'DIS', -1, 'PBH', -1, 1)
    --bug3654144 Multiplying by -1 if the line_category_code = 'ORDER'
    ,       (oepj.adjusted_amount_per_pqty - ldets.adjustment_amount) * decode(oeol.line_category_code, 'RETURN', 1, -1)
    ,       1
    ,null  --this offset adjustment should not have retrobill request id
    FROM QP_LDETS_v ldets
    ,    QP_PREQ_LINES_TMP lines
    ,    QP_LIST_HEADERS_B QH
    ,    OE_PRICE_ADJUSTMENTS oepj
    ,    OE_ORDER_LINES_ALL oeol
    WHERE
         ldets.list_header_id=qh.list_header_id
    --AND  ldets.process_code=QP_PREQ_GRP.G_STATUS_NEW
    AND  lines.pricing_status_code in (QP_PREQ_GRP.G_STATUS_NEW,QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_GSA_VIOLATION)
    --AND lines.process_status <> 'NOT_VALID'
    AND  ldets.line_index=lines.line_index
    AND  oepj.line_id=oeol.line_id
    --AND  (nvl(ldets.automatic_flag,'N') = 'Y')
    AND nvl(ldets.created_from_list_type_code,'xxx') not in ('PRL','AGR')
    AND  ldets.list_line_type_code<>'PLL'
    AND ldets.list_line_type_code<>'IUE'
    AND ldets.price_adjustment_id = oepj.price_adjustment_id
    AND ldets.list_line_id = oepj.list_line_id
    AND oepj.retrobill_request_id = G_CURRENT_RETROBILL_REQUEST_ID
);

oe_debug_pub.add('Retro:'||SQL%ROWCOUNT||' inserted, Retrobill id:'||G_CURRENT_RETROBILL_REQUEST_ID);
Exception
WHEN OTHERS THEN
  IF l_debug_level > 0 THEN
     oe_debug_pub.add('RETRO:ERROR in creating offset adjustments'||sqlerrm);
  END IF;
  Raise FND_API.G_EXC_ERROR;
END Insert_diff_Adj;

Procedure Update_Diff_Adj AS
Begin
 /*UPDATE OE_PRICE_ADJUSTMENTS oepj
 SET (operand,
      operand_per_pqty,
      adjusted_amount,
      adjusted_amount_per_pqty)
 =(SELECT oepj.adjusted_amount - ldets.adjustment_amount* nvl(lines.priced_quantity,1/nvl(lines.line_quantity,1))
          ,oepj.adjusted_amount_per_pqty - ldets.adjustment_amount
          adjusted_amount - ldets.adjustment_amount* nvl(lines.priced_quantity,1/nvl(lines.line_quantity,1))
          adjusted_amont_per_pqty -  ldets.adjustment_amount
   From QP_LDETS_V ldets
   Where   ldets.list_line_id = oepj.list_line_id
         --AND ldets.price_adjustment_id = oepj.price_adjustment_id
           AND oepj.retrobill_request_id = G_CURRENT_RETROBILL_REQUEST_ID
         --AND ldets.process_code = QP_PREQ_GRP.G_STATUS_UPDATED
    )
  WHERE retrobill_request_id IS NULL   --offset adj does not have retrobill_request_id
  AND   */
null;
End;

Procedure Update_Existing_Retro_Adj AS
Begin
   UPDATE OE_PRICE_ADJUSTMENTS adj
    SET ( operand
        , operand_per_pqty
        , adjusted_amount
        , adjusted_amount_per_pqty
        , arithmetic_operator
        , pricing_phase_id
        , pricing_group_sequence
        , automatic_flag
        , list_line_type_code
        , applied_flag
        , modified_from
        , modified_to
        , update_allowed
        , updated_flag
        , charge_type_code
        , charge_subtype_code
        , range_break_quantity
        , accrual_conversion_rate
        , accrual_flag
        , list_line_no
        , benefit_qty
        , benefit_uom_code
        , print_on_invoice_flag
        , expiration_date
        , rebate_transaction_type_code
        , modifier_level_code
        , price_break_type_code
        , substitution_attribute
        , proration_type_code
        , include_on_returns_flag
        , lock_control
        )
    =
       (select
            decode(ldets.operand_calculation_code,
          '%',ldets.operand_value,
          'LUMPSUM', ldets.operand_value,
          ldets.operand_value*nvl(lines.priced_quantity,lines.line_quantity)/lines.line_quantity)
       , ldets.operand_value
       --bug4583857
       , ldets.adjustment_amount* nvl(lines.priced_quantity,1)/nvl(lines.line_quantity,1)
       , ldets.adjustment_amount
       , ldets.operand_calculation_code
       , ldets.pricing_phase_id
       , ldets.pricing_group_sequence
       , ldets.automatic_flag
       , ldets.list_line_type_code
       , 'N'   --ldets.applied_flag
       , decode(ldets.list_line_type_code, 'TSN', ldets.substitution_attribute, 'IUE', to_char(ldets.inventory_item_id), NULL)
       , decode(ldets.list_line_type_code, 'TSN', ldets.substitution_value_to,  'IUE',to_char(ldets.related_item_id), NULL)
        , ldets.override_flag
        , ldets.updated_flag
        , ldets.charge_type_code
        , ldets.charge_subtype_code
        , ldets.line_quantity  --range_break_quantity (?)
        , ldets.accrual_conversion_rate
        , ldets.accrual_flag
        , ldets.list_line_no
        , ldets.benefit_qty
        , ldets.benefit_uom_code
        , ldets.print_on_invoice_flag
        , ldets.expiration_date
        , ldets.rebate_transaction_type_code
        , ldets.modifier_level_code
        , ldets.price_break_type_code
        , ldets.substitution_attribute
        , ldets.proration_type_code
        , ldets.include_on_returns_flag
        , adj.lock_control + 1
       from
           QP_LDETS_v ldets
        ,  QP_PREQ_LINES_TMP lines
       WHERE
        lines.line_index = ldets.line_index
        --and lines.process_status <> 'NOT_VALID'
        and ldets.list_line_id = adj.list_line_id
	--bug3417428
	--and ldets.line_index = adj.header_id+nvl(adj.line_id,0)
	and lines.line_id=adj.line_id
        --and ldets.process_code = QP_PREQ_GRP.G_STATUS_UPDATED
        and adj.retrobill_request_id = G_CURRENT_RETROBILL_REQUEST_ID
       )
    WHERE header_id=oe_order_pub.g_hdr.header_id
   and list_line_id in
       (select list_line_id
        from   qp_ldets_v ldets2, QP_PREQ_LINES_TMP lines2
        where  --lines2.process_status <> 'NOT_VALID'
        --and ldets2.process_code=QP_PREQ_GRP.G_STATUS_UPDATED
               lines2.line_index = ldets2.line_index
        and    ldets2.list_line_id = adj.list_line_id
	--bug3417428
	--and    ldets2.line_index = adj.header_id+nvl(adj.line_id,0))
        and    lines2.line_id=adj.line_id)
    and adj.retrobill_request_id = G_CURRENT_RETROBILL_REQUEST_ID;
oe_debug_pub.add('Retro:'||SQL%ROWCOUNT||' updated');
Exception
WHEN OTHERS THEN

     oe_debug_pub.add('Retro:ERROR in updating adjustments'||sqlerrm);

  --Raise FND_API.G_EXC_ERROR;
End;

--bug3654144 Adding a new procedure to insert adjustment lines corresponding to new modifiers returns by pricing engine.
PROCEDURE Insert_New_Adj As
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
Begin
    INSERT INTO OE_PRICE_ADJUSTMENTS
    (       PRICE_ADJUSTMENT_ID
    ,       CREATION_DATE
    ,       CREATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_LOGIN
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       HEADER_ID
    ,       DISCOUNT_ID
    ,       DISCOUNT_LINE_ID
    ,       AUTOMATIC_FLAG
    ,       PERCENT
    ,       LINE_ID
    ,       CONTEXT
    ,       ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ORIG_SYS_DISCOUNT_REF
    ,	  LIST_HEADER_ID
    ,	  LIST_LINE_ID
    ,	  LIST_LINE_TYPE_CODE
    ,	  MODIFIER_MECHANISM_TYPE_CODE
    ,	  MODIFIED_FROM
    ,	  MODIFIED_TO
    ,	  UPDATED_FLAG
    ,	  UPDATE_ALLOWED
    ,	  APPLIED_FLAG
    ,	  CHANGE_REASON_CODE
    ,	  CHANGE_REASON_TEXT
    ,	  operand
    ,	  Arithmetic_operator
    ,	  COST_ID
    ,	  TAX_CODE
    ,	  TAX_EXEMPT_FLAG
    ,	  TAX_EXEMPT_NUMBER
    ,	  TAX_EXEMPT_REASON_CODE
    ,	  PARENT_ADJUSTMENT_ID
    ,	  INVOICED_FLAG
    ,	  ESTIMATED_FLAG
    ,	  INC_IN_SALES_PERFORMANCE
    ,	  SPLIT_ACTION_CODE
    ,	  ADJUSTED_AMOUNT
    ,	  PRICING_PHASE_ID
    ,	  CHARGE_TYPE_CODE
    ,	  CHARGE_SUBTYPE_CODE
    ,     list_line_no
    ,     source_system_code
    ,     benefit_qty
    ,     benefit_uom_code
    ,     print_on_invoice_flag
    ,     expiration_date
    ,     rebate_transaction_type_code
    ,     rebate_transaction_reference
    ,     rebate_payment_system_code
    ,     redeemed_date
    ,     redeemed_flag
    ,     accrual_flag
    ,     range_break_quantity
    ,     accrual_conversion_rate
    ,     pricing_group_sequence
    ,     modifier_level_code
    ,     price_break_type_code
    ,     substitution_attribute
    ,     proration_type_code
    ,       CREDIT_OR_CHARGE_FLAG
    ,       INCLUDE_ON_RETURNS_FLAG
    ,       AC_CONTEXT
    ,       AC_ATTRIBUTE1
    ,       AC_ATTRIBUTE2
    ,       AC_ATTRIBUTE3
    ,       AC_ATTRIBUTE4
    ,       AC_ATTRIBUTE5
    ,       AC_ATTRIBUTE6
    ,       AC_ATTRIBUTE7
    ,       AC_ATTRIBUTE8
    ,       AC_ATTRIBUTE9
    ,       AC_ATTRIBUTE10
    ,       AC_ATTRIBUTE11
    ,       AC_ATTRIBUTE12
    ,       AC_ATTRIBUTE13
    ,       AC_ATTRIBUTE14
    ,       AC_ATTRIBUTE15
    ,       OPERAND_PER_PQTY
    ,       ADJUSTED_AMOUNT_PER_PQTY
    ,	    LOCK_CONTROL
    ,       RETROBILL_REQUEST_ID
    )
    ( SELECT     /*+ ORDERED USE_NL(ldets lines qh) */
--            oe_price_adjustments_s.nextval -- p_Line_Adj_rec.price_adjustment_id
            ldets.price_adjustment_id
    ,       sysdate --p_Line_Adj_rec.creation_date
    ,       fnd_global.user_id --p_Line_Adj_rec.created_by
    ,       sysdate --p_Line_Adj_rec.last_update_date
    ,       fnd_global.user_id --p_Line_Adj_rec.last_updated_by
    ,       fnd_global.login_id --p_Line_Adj_rec.last_update_login
    ,       NULL --p_Line_Adj_rec.program_application_id
    ,       NULL --p_Line_Adj_rec.program_id
    ,       NULL --p_Line_Adj_rec.program_update_date
    ,       NULL --p_Line_Adj_rec.request_id
    ,       oe_order_pub.g_hdr.header_id --p_Line_Adj_rec.header_id
    ,       NULL --p_Line_Adj_rec.discount_id
    ,       NULL  --p_Line_Adj_rec.discount_line_id
    ,       ldets.automatic_flag
    ,       NULL --p_Line_Adj_rec.percent
    ,       decode(ldets.modifier_level_code,'ORDER',NULL,lines.line_id)
    ,       NULL --p_Line_Adj_rec.context
    ,       NULL --p_Line_Adj_rec.attribute1
    ,       NULL --p_Line_Adj_rec.attribute2
    ,       NULL --p_Line_Adj_rec.attribute3
    ,       NULL --p_Line_Adj_rec.attribute4
    ,       NULL --p_Line_Adj_rec.attribute5
    ,       NULL --p_Line_Adj_rec.attribute6
    ,       NULL --p_Line_Adj_rec.attribute7
    ,       NULL --p_Line_Adj_rec.attribute8
    ,       NULL --p_Line_Adj_rec.attribute9
    ,       NULL --p_Line_Adj_rec.attribute10
    ,       NULL --p_Line_Adj_rec.attribute11
    ,       NULL --p_Line_Adj_rec.attribute12
    ,       NULL --p_Line_Adj_rec.attribute13
    ,       NULL --p_Line_Adj_rec.attribute14
    ,       NULL --p_Line_Adj_rec.attribute15
    ,       NULL --p_Line_Adj_rec.orig_sys_discount_ref
    ,	  ldets.LIST_HEADER_ID
    ,	  ldets.LIST_LINE_ID
    ,	  ldets.LIST_LINE_TYPE_CODE
    ,	  NULL --p_Line_Adj_rec.MODIFIER_MECHANISM_TYPE_CODE
    ,	  decode(ldets.list_line_type_code, 'TSN', ldets.substitution_attribute, 'IUE', to_char(ldets.inventory_item_id), NULL)
    ,	  decode(ldets.list_line_type_code, 'TSN', ldets.substitution_value_to, 'IUE', to_char(ldets.related_item_id), NULL)
    ,	  'N' --p_Line_Adj_rec.UPDATED_FLAG
    ,	  'N' --bug3896248 --override_allowed
    ,	  'N' -- applied_flag
    ,	  NULL --p_Line_Adj_rec.CHANGE_REASON_CODE
    ,	  NULL --p_Line_Adj_rec.CHANGE_REASON_TEXT
    ,	  nvl(ldets.order_qty_operand, decode(ldets.operand_calculation_code,
             '%', ldets.operand_value,
             'LUMPSUM', ldets.operand_value,
             ldets.operand_value*lines.priced_quantity/nvl(lines.line_quantity,1)))
    ,	  ldets.operand_calculation_code --p_Line_Adj_rec.arithmetic_operator
    ,	  NULl --p_line_Adj_rec.COST_ID
    ,	  NULL --p_line_Adj_rec.TAX_CODE
    ,	  NULL --p_line_Adj_rec.TAX_EXEMPT_FLAG
    ,	  NULL --p_line_Adj_rec.TAX_EXEMPT_NUMBER
    ,	  NULL --p_line_Adj_rec.TAX_EXEMPT_REASON_CODE
    ,	  NULL --p_line_Adj_rec.PARENT_ADJUSTMENT_ID
    ,	  NULL --p_line_Adj_rec.INVOICED_FLAG
    ,	  NULL --p_line_Adj_rec.ESTIMATED_FLAG
    ,	  NULL --p_line_Adj_rec.INC_IN_SALES_PERFORMANCE
    ,	  NULL --p_line_Adj_rec.SPLIT_ACTION_CODE
    ,	  nvl(ldets.order_qty_adj_amt, ldets.adjustment_amount*nvl(lines.priced_quantity,1)/nvl(lines.line_quantity,1))
    ,	  ldets.pricing_phase_id --p_line_Adj_rec.PRICING_PHASE_ID
    ,	  ldets.CHARGE_TYPE_CODE
    ,	  ldets.CHARGE_SUBTYPE_CODE
    ,       ldets.list_line_no
    ,       qh.source_system_code
    ,       ldets.benefit_qty
    ,       ldets.benefit_uom_code
    ,       NULL --p_Line_Adj_rec.print_on_invoice_flag
    ,       ldets.expiration_date
    ,       ldets.rebate_transaction_type_code
    ,       NULL --p_Line_Adj_rec.rebate_transaction_reference
    ,       NULL --p_Line_Adj_rec.rebate_payment_system_code
    ,       NULL --p_Line_Adj_rec.redeemed_date
    ,       NULL --p_Line_Adj_rec.redeemed_flag
    ,       ldets.accrual_flag
    ,       ldets.line_quantity  --p_Line_Adj_rec.range_break_quantity
    ,       ldets.accrual_conversion_rate
    ,       ldets.pricing_group_sequence
    ,       ldets.modifier_level_code
    ,       ldets.price_break_type_code
    ,       ldets.substitution_attribute
    ,       ldets.proration_type_code
    ,       NULL --p_Line_Adj_rec.credit_or_charge_flag
    ,       ldets.include_on_returns_flag
    ,       NULL -- p_Line_Adj_rec.ac_context
    ,       NULL -- p_Line_Adj_rec.ac_attribute1
    ,       NULL -- p_Line_Adj_rec.ac_attribute2
    ,       NULL -- p_Line_Adj_rec.ac_attribute3
    ,       NULL -- p_Line_Adj_rec.ac_attribute4
    ,       NULL -- p_Line_Adj_rec.ac_attribute5
    ,       NULL -- p_Line_Adj_rec.ac_attribute6
    ,       NULL -- p_Line_Adj_rec.ac_attribute7
    ,       NULL -- p_Line_Adj_rec.ac_attribute8
    ,       NULL -- p_Line_Adj_rec.ac_attribute9
    ,       NULL -- p_Line_Adj_rec.ac_attribute10
    ,       NULL -- p_Line_Adj_rec.ac_attribute11
    ,       NULL -- p_Line_Adj_rec.ac_attribute12
    ,       NULL -- p_Line_Adj_rec.ac_attribute13
    ,       NULL -- p_Line_Adj_rec.ac_attribute14
    ,       NULL -- p_Line_Adj_rec.ac_attribute15
    ,       ldets.OPERAND_value
    ,       ldets.adjustment_amount
    ,       1
    ,       G_CURRENT_RETROBILL_REQUEST_ID
    FROM
         QP_LDETS_v ldets
    ,    QP_PREQ_LINES_TMP lines
    ,    QP_LIST_HEADERS_B QH
    WHERE
         ldets.list_header_id=qh.list_header_id
    AND  ldets.process_code=QP_PREQ_GRP.G_STATUS_NEW
    AND  lines.pricing_status_code in (QP_PREQ_GRP.G_STATUS_NEW,QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_GSA_VIOLATION)
    AND lines.process_status <> 'NOT_VALID'
    AND  ldets.line_index=lines.line_index
    --AND  ldets.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
    AND  (nvl(ldets.automatic_flag,'N') = 'Y')
--         or
--          (ldets.list_line_type_code = 'FREIGHT_CHARGE'))
    AND ldets.created_from_list_type_code not in ('PRL','AGR')
    AND  ldets.list_line_type_code<>'PLL'
    AND ldets.list_line_type_code<>'IUE'
    AND  ldets.list_line_type_code NOT IN ('TAX','FREIGHT_CHARGE')
  --  AND (l_booked_flag = 'N' or ldets.list_line_type_code<>'IUE')
);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'pviprana INSERTED '||SQL%ROWCOUNT||' NEW ADJUSTMENTS' ) ;
    END IF;

 INSERT INTO OE_PRICE_ADJ_ASSOCS
        (       PRICE_ADJUSTMENT_ID
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                ,PROGRAM_APPLICATION_ID
                ,PROGRAM_ID
                ,PROGRAM_UPDATE_DATE
                ,REQUEST_ID
                ,PRICE_ADJ_ASSOC_ID
                ,LINE_ID
                ,RLTD_PRICE_ADJ_ID
                ,LOCK_CONTROL
        )
        (SELECT  /*+ ORDERED USE_NL(QPL ADJ RADJ) */
                 LDET.price_adjustment_id
                ,sysdate  --p_Line_Adj_Assoc_Rec.creation_date
                ,fnd_global.user_id --p_Line_Adj_Assoc_Rec.CREATED_BY
                ,sysdate  --p_Line_Adj_Assoc_Rec.LAST_UPDATE_DATE
                ,fnd_global.user_id  --p_Line_Adj_Assoc_Rec.LAST_UPDATED_BY
                ,fnd_global.login_id  --p_Line_Adj_Assoc_Rec.LAST_UPDATE_LOGIN
                ,NULL  --p_Line_Adj_Assoc_Rec.PROGRAM_APPLICATION_ID
                ,NULL  --p_Line_Adj_Assoc_Rec.PROGRAM_ID
                ,NULL  --p_Line_Adj_Assoc_Rec.PROGRAM_UPDATE_DATE
                ,NULL  --p_Line_Adj_Assoc_Rec.REQUEST_ID
                ,OE_PRICE_ADJ_ASSOCS_S.nextval
                ,NULL
                ,RLDET.PRICE_ADJUSTMENT_ID
                ,1
        FROM
              QP_PREQ_RLTD_LINES_TMP RLTD,
              QP_PREQ_LDETS_TMP LDET,
              QP_PREQ_LDETS_TMP RLDET
        WHERE
             LDET.LINE_DETAIL_INDEX = RLTD.LINE_DETAIL_INDEX              AND
             RLDET.LINE_DETAIL_INDEX = RLTD.RELATED_LINE_DETAIL_INDEX     AND
             LDET.PRICING_STATUS_CODE = 'N' AND
             LDET.PROCESS_CODE  IN (QP_PREQ_PUB.G_STATUS_NEW,QP_PREQ_PUB.G_STATUS_UNCHANGED,QP_PREQ_PUB.G_STATUS_UPDATED)  AND
             nvl(LDET.AUTOMATIC_FLAG, 'N') = 'Y' AND
             lDET.CREATED_FROM_LIST_TYPE_CODE NOT IN ('PRL','AGR') AND
             lDET.PRICE_ADJUSTMENT_ID IS NOT NULL AND
             RLDET.PRICE_ADJUSTMENT_ID IS NOT NULL AND
             RLDET.PRICING_STATUS_CODE = 'N' AND
             RLDET.PROCESS_CODE = 'N' AND
             nvl(RLDET.AUTOMATIC_FLAG, 'N') = 'Y' AND
             -- not in might not be needed
              RLDET.PRICE_ADJUSTMENT_ID
                NOT IN (SELECT RLTD_PRICE_ADJ_ID
                       FROM   OE_PRICE_ADJ_ASSOCS
                       WHERE PRICE_ADJUSTMENT_ID = LDET.PRICE_ADJUSTMENT_ID ) AND
              RLTD.PRICING_STATUS_CODE = 'N');



   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'pviprana INSERTED '||SQL%ROWCOUNT||' NEW PRICE ADJ ASSOCS' , 3 ) ;
   END IF;


    INSERT INTO OE_PRICE_ADJUSTMENTS
    (       PRICE_ADJUSTMENT_ID
    ,       CREATION_DATE
    ,       CREATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_LOGIN
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       HEADER_ID
    ,       DISCOUNT_ID
    ,       DISCOUNT_LINE_ID
    ,       AUTOMATIC_FLAG
    ,       PERCENT
    ,       LINE_ID
    ,       CONTEXT
    ,       ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ORIG_SYS_DISCOUNT_REF
    ,	  LIST_HEADER_ID
    ,	  LIST_LINE_ID
    ,	  LIST_LINE_TYPE_CODE
    ,	  MODIFIER_MECHANISM_TYPE_CODE
    ,	  MODIFIED_FROM
    ,	  MODIFIED_TO
    ,	  UPDATED_FLAG
    ,	  UPDATE_ALLOWED
    ,	  APPLIED_FLAG
    ,	  CHANGE_REASON_CODE
    ,	  CHANGE_REASON_TEXT
    ,	  operand
    ,	  Arithmetic_operator
    ,	  COST_ID
    ,	  TAX_CODE
    ,	  TAX_EXEMPT_FLAG
    ,	  TAX_EXEMPT_NUMBER
    ,	  TAX_EXEMPT_REASON_CODE
    ,	  PARENT_ADJUSTMENT_ID
    ,	  INVOICED_FLAG
    ,	  ESTIMATED_FLAG
    ,	  INC_IN_SALES_PERFORMANCE
    ,	  SPLIT_ACTION_CODE
    ,	  ADJUSTED_AMOUNT
    ,	  PRICING_PHASE_ID
    ,	  CHARGE_TYPE_CODE
    ,	  CHARGE_SUBTYPE_CODE
    ,     list_line_no
    ,     source_system_code
    ,     benefit_qty
    ,     benefit_uom_code
    ,     print_on_invoice_flag
    ,     expiration_date
    ,     rebate_transaction_type_code
    ,     rebate_transaction_reference
    ,     rebate_payment_system_code
    ,     redeemed_date
    ,     redeemed_flag
    ,     accrual_flag
    ,     range_break_quantity
    ,     accrual_conversion_rate
    ,     pricing_group_sequence
    ,     modifier_level_code
    ,     price_break_type_code
    ,     substitution_attribute
    ,     proration_type_code
    ,       CREDIT_OR_CHARGE_FLAG
    ,       INCLUDE_ON_RETURNS_FLAG
    ,       AC_CONTEXT
    ,       AC_ATTRIBUTE1
    ,       AC_ATTRIBUTE2
    ,       AC_ATTRIBUTE3
    ,       AC_ATTRIBUTE4
    ,       AC_ATTRIBUTE5
    ,       AC_ATTRIBUTE6
    ,       AC_ATTRIBUTE7
    ,       AC_ATTRIBUTE8
    ,       AC_ATTRIBUTE9
    ,       AC_ATTRIBUTE10
    ,       AC_ATTRIBUTE11
    ,       AC_ATTRIBUTE12
    ,       AC_ATTRIBUTE13
    ,       AC_ATTRIBUTE14
    ,       AC_ATTRIBUTE15
    ,       OPERAND_PER_PQTY
    ,       ADJUSTED_AMOUNT_PER_PQTY
    ,	    LOCK_CONTROL
    ,       RETROBILL_REQUEST_ID
    )
    ( SELECT     /*+ ORDERED USE_NL(ldets lines qh) */
            oe_price_adjustments_s.nextval -- p_Line_Adj_rec.price_adjustment_id
    ,       sysdate --p_Line_Adj_rec.creation_date
    ,       fnd_global.user_id --p_Line_Adj_rec.created_by
    ,       sysdate --p_Line_Adj_rec.last_update_date
    ,       fnd_global.user_id --p_Line_Adj_rec.last_updated_by
    ,       fnd_global.login_id --p_Line_Adj_rec.last_update_login
    ,       NULL --p_Line_Adj_rec.program_application_id
    ,       NULL --p_Line_Adj_rec.program_id
    ,       NULL --p_Line_Adj_rec.program_update_date
    ,       NULL --p_Line_Adj_rec.request_id
    ,       oe_order_pub.g_hdr.header_id --p_Line_Adj_rec.header_id
    ,       NULL --p_Line_Adj_rec.discount_id
    ,       NULL  --p_Line_Adj_rec.discount_line_id
    ,       ldets.automatic_flag
    ,       NULL --p_Line_Adj_rec.percent
    ,       decode(ldets.modifier_level_code,'ORDER',NULL,lines.line_id)
    ,       NULL --p_Line_Adj_rec.context
    ,       NULL --p_Line_Adj_rec.attribute1
    ,       NULL --p_Line_Adj_rec.attribute2
    ,       NULL --p_Line_Adj_rec.attribute3
    ,       NULL --p_Line_Adj_rec.attribute4
    ,       NULL --p_Line_Adj_rec.attribute5
    ,       NULL --p_Line_Adj_rec.attribute6
    ,       NULL --p_Line_Adj_rec.attribute7
    ,       NULL --p_Line_Adj_rec.attribute8
    ,       NULL --p_Line_Adj_rec.attribute9
    ,       NULL --p_Line_Adj_rec.attribute10
    ,       NULL --p_Line_Adj_rec.attribute11
    ,       NULL --p_Line_Adj_rec.attribute12
    ,       NULL --p_Line_Adj_rec.attribute13
    ,       NULL --p_Line_Adj_rec.attribute14
    ,       NULL --p_Line_Adj_rec.attribute15
    ,       NULL --p_Line_Adj_rec.orig_sys_discount_ref
    ,	  ldets.LIST_HEADER_ID
    ,	  ldets.LIST_LINE_ID
    ,	  decode(ldets.list_line_type_code,'PBH','DIS',ldets.list_line_type_code)
    ,	  NULL --p_Line_Adj_rec.MODIFIER_MECHANISM_TYPE_CODE
    ,	  decode(ldets.list_line_type_code, 'TSN', ldets.substitution_attribute, 'IUE', to_char(ldets.inventory_item_id), NULL)
    ,	  decode(ldets.list_line_type_code, 'TSN', ldets.substitution_value_to, 'IUE', to_char(ldets.related_item_id), NULL)
    ,	  'N' --p_Line_Adj_rec.UPDATED_FLAG
    ,	  ldets.override_flag
    ,	  ldets.applied_flag
    ,	  NULL --p_Line_Adj_rec.CHANGE_REASON_CODE
    ,	  NULL --p_Line_Adj_rec.CHANGE_REASON_TEXT
    --below is operand
    ,     decode(oeol.line_category_code, 'RETURN', -1, 1) * ldets.adjustment_amount*nvl(lines.priced_quantity,1)/nvl(lines.line_quantity,1) * decode(ldets.list_line_type_code, 'DIS', -1, 'PBH', -1, 1)
    ,	  'AMT' --hardcoded to 'AMT'
    ,	  NULl --p_line_Adj_rec.COST_ID
    ,	  NULL --p_line_Adj_rec.TAX_CODE
    ,	  NULL --p_line_Adj_rec.TAX_EXEMPT_FLAG
    ,	  NULL --p_line_Adj_rec.TAX_EXEMPT_NUMBER
    ,	  NULL --p_line_Adj_rec.TAX_EXEMPT_REASON_CODE
    ,	  NULL --p_line_Adj_rec.PARENT_ADJUSTMENT_ID
    ,	  NULL --p_line_Adj_rec.INVOICED_FLAG
    ,	  NULL --p_line_Adj_rec.ESTIMATED_FLAG
    ,	  NULL --p_line_Adj_rec.INC_IN_SALES_PERFORMANCE
    ,	  NULL --p_line_Adj_rec.SPLIT_ACTION_CODE
    ,	  decode(oeol.line_category_code, 'RETURN', -1, 1) * nvl(ldets.order_qty_adj_amt, ldets.adjustment_amount*nvl(lines.priced_quantity,1)/nvl(lines.line_quantity,1))
    ,	  ldets.pricing_phase_id --p_line_Adj_rec.PRICING_PHASE_ID
    ,	  ldets.CHARGE_TYPE_CODE
    ,	  ldets.CHARGE_SUBTYPE_CODE
    ,       ldets.list_line_no
    ,       qh.source_system_code
    ,       ldets.benefit_qty
    ,       ldets.benefit_uom_code
    ,       NULL --p_Line_Adj_rec.print_on_invoice_flag
    ,       ldets.expiration_date
    ,       ldets.rebate_transaction_type_code
    ,       NULL --p_Line_Adj_rec.rebate_transaction_reference
    ,       NULL --p_Line_Adj_rec.rebate_payment_system_code
    ,       NULL --p_Line_Adj_rec.redeemed_date
    ,       NULL --p_Line_Adj_rec.redeemed_flag
    ,       ldets.accrual_flag
    ,       ldets.line_quantity  --p_Line_Adj_rec.range_break_quantity
    ,       ldets.accrual_conversion_rate
    ,       ldets.pricing_group_sequence
    ,       ldets.modifier_level_code
    ,       ldets.price_break_type_code
    ,       ldets.substitution_attribute
    ,       ldets.proration_type_code
    ,       NULL --p_Line_Adj_rec.credit_or_charge_flag
    ,       ldets.include_on_returns_flag
    ,       NULL -- p_Line_Adj_rec.ac_context
    ,       NULL -- p_Line_Adj_rec.ac_attribute1
    ,       NULL -- p_Line_Adj_rec.ac_attribute2
    ,       NULL -- p_Line_Adj_rec.ac_attribute3
    ,       NULL -- p_Line_Adj_rec.ac_attribute4
    ,       NULL -- p_Line_Adj_rec.ac_attribute5
    ,       NULL -- p_Line_Adj_rec.ac_attribute6
    ,       NULL -- p_Line_Adj_rec.ac_attribute7
    ,       NULL -- p_Line_Adj_rec.ac_attribute8
    ,       NULL -- p_Line_Adj_rec.ac_attribute9
    ,       NULL -- p_Line_Adj_rec.ac_attribute10
    ,       NULL -- p_Line_Adj_rec.ac_attribute11
    ,       NULL -- p_Line_Adj_rec.ac_attribute12
    ,       NULL -- p_Line_Adj_rec.ac_attribute13
    ,       NULL -- p_Line_Adj_rec.ac_attribute14
    ,       NULL -- p_Line_Adj_rec.ac_attribute15
    ,       decode(oeol.line_category_code, 'RETURN', -1, 1) * ldets.adjustment_amount * decode(ldets.list_line_type_code, 'DIS', -1, 'PBH', -1, 1)
    ,       decode(oeol.line_category_code, 'RETURN', -1, 1) * ldets.adjustment_amount
    ,       1
    ,       null --retrobill_request_id
    FROM
         QP_LDETS_v ldets
    ,    QP_PREQ_LINES_TMP lines
    ,    QP_LIST_HEADERS_B QH
    ,    OE_ORDER_LINES_ALL oeol
    WHERE
         ldets.list_header_id=qh.list_header_id
    AND  ldets.process_code=QP_PREQ_GRP.G_STATUS_NEW
    AND  lines.pricing_status_code in (QP_PREQ_GRP.G_STATUS_NEW,QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_GSA_VIOLATION)
    AND  lines.process_status <> 'NOT_VALID'
    AND  ldets.line_index=lines.line_index
    AND  lines.line_id=oeol.line_id
    --AND  ldets.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
    AND  (nvl(ldets.automatic_flag,'N') = 'Y')
--         or
--          (ldets.list_line_type_code = 'FREIGHT_CHARGE'))
    AND  ldets.created_from_list_type_code not in ('PRL','AGR')
    AND  ldets.list_line_type_code<>'PLL'
    AND  ldets.list_line_type_code<>'IUE'
    AND  ldets.list_line_type_code NOT IN ('TAX','FREIGHT_CHARGE')
  --  AND (l_booked_flag = 'N' or ldets.list_line_type_code<>'IUE')
);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'pviprana INSERTED '||SQL%ROWCOUNT||' new DIFF ADJUSTMENTS' ) ;
    END IF;


Exception
WHEN NO_DATA_FOUND THEN
   null;
WHEN OTHERS THEN
  IF l_debug_level > 0 THEN
     oe_debug_pub.add('RETRO:ERROR in creating new offset adjustments'||sqlerrm);
  END IF;
  Raise FND_API.G_EXC_ERROR;
END Insert_New_Adj;

--bug3654144 new procedure added
-- This procedure selects the adjustments which were copied over to oe_price_adjustments
--before the pricing engine call but are invalid in the setup,
--and negates the adjusted_amount, operand etc so that the adjusted_amounts would tally
--in the view adjustments form for the retrobill line.
PROCEDURE Update_Invalid_Diff_Adj AS
    CURSOR invalid_price_adjs IS
    SELECT price_adjustment_id, list_line_id, list_line_type_code, line_id
    FROM oe_price_adjustments adj
    WHERE  adj.list_line_id NOT IN
      (SELECT list_line_id
       FROM
           QP_LDETS_v ldets
        ,  QP_PREQ_LINES_TMP lines
       WHERE
        lines.line_index = ldets.line_index
 	and lines.line_id= adj.line_id
        and adj.list_line_id=ldets.list_line_id)
    AND header_id=oe_order_pub.g_hdr.header_id
    AND nvl(applied_flag,'N') = 'Y'
    AND nvl(automatic_flag,'N') = 'Y'
    AND nvl(list_line_type_code,'TAX') NOT IN ('TAX', 'FREIGHT_CHARGE')
    ORDER BY line_id;

   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   l_price_adjustment_id NUMBER;
   l_updated_inv_adj_count PLS_INTEGER := 0;
   l_last_line_id NUMBER;
   l_line_category_code VARCHAR2(30);

BEGIN
   --GSCC not initializing during declaration
   l_last_line_id := -1;
   FOR invalid_price_adj IN invalid_price_adjs LOOP
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('pviprana: Invalid adj list line id : '||invalid_price_adj.list_line_id);
      oe_debug_pub.add('pviprana: Invalid adj price_adjustment_id : '||invalid_price_adj.price_adjustment_id);
      oe_debug_pub.add('pviprana: Invalid adj list_line_type_code : '||invalid_price_adj.list_line_type_code);
    END IF;

      IF l_last_line_id <> invalid_price_adj.line_id THEN
	 BEGIN
	    SELECT line_category_code INTO l_line_category_code
	    FROM oe_order_lines_all
	    WHERE line_id = invalid_price_adj.line_id;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF l_debug_level > 0 THEN
		  oe_debug_pub.add('RETRO:ERROR in creating offset adjustments'||sqlerrm);
	       END IF;
	       Raise FND_API.G_EXC_ERROR;
	 END;
         l_last_line_id := invalid_price_adj.line_id;
      END IF;

      l_price_adjustment_id := invalid_price_adj.price_adjustment_id;

      UPDATE OE_PRICE_ADJUSTMENTS
      SET ( LAST_UPDATE_DATE
	  , LIST_LINE_TYPE_CODE
	  , UPDATED_FLAG
	  , UPDATE_ALLOWED --bug3896248
	  , APPLIED_FLAG
	  , operand
	  , Arithmetic_operator
	  , ADJUSTED_AMOUNT
	  , OPERAND_PER_PQTY
	  , ADJUSTED_AMOUNT_PER_PQTY
	  , LOCK_CONTROL
	  , retrobill_request_id
    )
      = (SELECT  SYSDATE
	  ,      decode(adj.list_line_type_code,'PBH','DIS',adj.list_line_type_code)
	  ,     'N' --p_Line_Adj_rec.UPDATED_FLAG
          ,     'N' --bug3896248 update_allowed
	  ,     adj.applied_flag
         --below is operand
	  ,     nvl(adj.adjusted_amount,0) * decode(l_line_category_code, 'ORDER', -1, 1) * decode(adj.list_line_type_code, 'DIS', -1, 'PBH', -1, 1)
	  ,     'AMT'
--below is adjusted amount
	  ,     nvl(adj.adjusted_amount,0) * decode(l_line_category_code, 'ORDER', -1, 1)
	  ,     nvl(adj.adjusted_amount_per_pqty,0) * decode(l_line_category_code, 'ORDER', -1, 1) * decode(adj.list_line_type_code, 'DIS', -1, 'PBH', -1, 1)
	  ,     nvl(adj.adjusted_amount_per_pqty,0) * decode(l_line_category_code, 'ORDER', -1, 1)
	  ,     1
	  ,     null  --this offset adjustment should not have retrobill request id
         FROM oe_price_adjustments adj
	  ,   oe_order_lines_all oeol
         WHERE adj.price_adjustment_id = l_price_adjustment_id
	 AND   oeol.line_id=adj.line_id
	)
      WHERE price_adjustment_id=l_price_adjustment_id;
      l_updated_inv_adj_count := l_updated_inv_adj_count + 1;

   END LOOP;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'pviprana UPDATED '|| l_updated_inv_adj_count ||' INVALID DIFF ADJUSTMENTS' ) ;
     END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      oe_debug_pub.add('pviprana: Exception: NO_DATA_FOUND');
   WHEN OTHERS THEN
      oe_debug_pub.add('pviprana: Exception: '||SQLERRM);

END;

--RT{
--Need to code this after final merging since there is significant changes in
--pack I code about qp structure.
Procedure Process_Retrobill_Adjustments(p_operation IN VARCHAR2) As

Begin
oe_debug_pub.add('Retro:Entering Process_Retrobill_Adjustments');
--case 1, Retrobill does not have adjustment phases, only list price phase.
--ideally in this case only adjustment amount(% discount) could have changed,operand should be the same

--insert the offset adjustments, this is always needed in both cases

 Insert_Diff_Adj;

--Update the copied over adjustments, these adjustments were copied over
--from original lines to the new retrobill lines. This procedure handle both cases
--which is 1. No change in pricing setup (RETROBILL event only contains list price phase, and
--         2  which is changes in pricing adjustment setup (RETROBILL event contains pricing phase
--            more than list pirce phase)
Update_Existing_Retro_Adj;

--bug3654144
Insert_New_Adj;

oe_debug_pub.add('Retro:Leaving  Process_Retrobill_Adjustments');

End Process_Retrobill_Adjustments;
--RT}


PROCEDURE Perform_Operations(p_retrobill_tbl  IN RETROBILL_TBL_TYPE,
                             p_execution_mode IN VARCHAR2,
			     --bug5003256
                             x_error_count OUT NOCOPY NUMBER) AS
i PLS_INTEGER;
j PLS_INTEGER;
k NUMBER;
N NUMBER;

l_delete_tbl RETROBILL_TBL_TYPE;
l_update_tbl RETROBILL_TBL_TYPE;
l_null_tbl   RETROBILL_TBL_TYPE;

del_index   PLS_INTEGER:=1;
upd_index   PLS_INTEGER:=1;
n_index  PLS_INTEGER:=1;


l_header_id_tbl OE_GLOBALS.NUMBER_TBL_TYPE;
l_line_id_tbl  OE_GLOBALS.NUMBER_TBL_TYPE;
l_arrange_line_id_tbl  OE_GLOBALS.NUMBER_TBL_TYPE;
l_arrange_line_num_tbl  OE_GLOBALS.NUMBER_TBL_TYPE;
l_retrobill_qty_tbl OE_GLOBALS.NUMBER_TBL_TYPE;
l_line_tbl OE_ORDER_PUB.LINE_TBL_TYPE;
l_return_status VARCHAR2(15);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
Cursor unique_header_id IS
SELECT DISTINCT KEY_ID Header_Id
FROM   OM_ID_LIST_TMP;

Cursor line_numbers(p_header_id IN NUMBER) IS
SELECT line_id
FROM oe_order_lines_all
WHERE header_id=p_header_id;

l_price_control_rec		QP_PREQ_GRP.control_record_type;
--bug5003256
l_book_line_count NUMBER;
Begin

x_error_count := 0;   --bug5003256
i:=p_retrobill_tbl.first;

WHILE i IS NOT NULL LOOP
IF nvl(p_retrobill_tbl(i).operation,'NULL') = 'DELETE' THEN
 l_delete_tbl(del_index):=p_retrobill_tbl(i);
 del_index:=del_index + 1;
ELSIF nvl(p_retrobill_tbl(i).operation,'NULL') IN ('UPDATE','NULL') THEN

 l_header_id_tbl(n_index):=p_retrobill_tbl(i).retrobill_header_id;

 /*IF l_debug_level > 0 THEN
   oe_debug_pub.add('Retro:retrobill_header_id:'||nvl(p_retrobill_tbl(i).retrobill_header_id,'NULL'));
 END IF;*/

 IF nvl(p_retrobill_tbl(i).operation,'NULL') = 'UPDATE' THEN
  l_line_id_tbl(upd_index):=p_retrobill_tbl(i).retrobill_line_id;
  l_retrobill_qty_tbl(upd_index):=p_retrobill_tbl(i).retrobill_qty;
  upd_index:=upd_index+1;
 END IF;

 n_index:=n_index+1;
END IF;
i:=p_retrobill_tbl.next(i);
END LOOP;

 --We need to delete first, otherwise, we will be unable to delete booked records.
 i:=l_delete_tbl.first;
 WHILE i IS NOT NULL LOOP
   oe_debug_pub.add('Retro:Operation DELETE:deleting line id:'||l_delete_tbl(i).retrobill_line_id);
   Oe_Line_Util.Delete_Row(p_line_id=>l_delete_tbl(i).retrobill_line_id);
 i:=l_delete_tbl.next(i);
 END LOOP;

 -- rearranging the line numbers for the headers corresponding to the lines which were deleted.
 DELETE FROM OM_ID_LIST_TMP;

 j := l_delete_tbl.FIRST;
 WHILE j IS NOT NULL LOOP
  INSERT INTO OM_ID_LIST_TMP(KEY_ID)
  VALUES (l_delete_tbl(j).retrobill_header_id);
j:=l_delete_tbl.next(j);
 END LOOP;

 FOR k in unique_header_id LOOP
    j:=1;
    FOR N IN line_numbers(k.header_id) LOOP
      l_arrange_line_num_tbl(j):= j;
      l_arrange_line_id_tbl(j):= N.LINE_ID;
      j:=j+1;
    END LOOP;
     oe_debug_pub.add('Retro:before update line_num');
    IF l_arrange_line_id_tbl.FIRST IS NOT NULL THEN
      FORALL i IN l_arrange_line_id_tbl.FIRST..l_arrange_line_id_tbl.LAST
      UPDATE OE_ORDER_LINES_ALL
      SET    LINE_NUMBER = l_arrange_line_num_tbl(i)
      WHERE  LINE_ID = l_arrange_line_id_tbl(i);
    END IF;
      oe_debug_pub.add('Retro:after update line_num');
END LOOP;

--handle mass update by joing to OM_ID_LIST_TMP
 DELETE FROM OM_ID_LIST_TMP;

 IF  l_line_id_tbl.FIRST IS NOT NULL THEN
  FORALL j IN  l_line_id_tbl.FIRST..l_line_id_tbl.LAST
  INSERT INTO OM_ID_LIST_TMP(KEY_ID,VALUE)
  VALUES (l_line_id_tbl(j),l_retrobill_qty_tbl(j));
  oe_debug_pub.add('Retro:execution mode='||p_execution_mode);

 --pricing quantity derivation might be wrong  need to get back to this!!!
 UPDATE OE_ORDER_LINES_ALL oeol
 SET (ordered_quantity,
      pricing_quantity
     )
 = (Select value,
           (value * oeol.unit_selling_price)/decode(nvl(oeol.unit_selling_price_per_pqty,0),0,1,oeol.unit_selling_price_per_pqty)
    From   OM_ID_LIST_TMP idt
    Where  idt.key_id = oeol.line_id)
 WHERE oeol.retrobill_request_id IS NOT NULL
 AND   line_id in (SELECT key_id
                   FROM OM_ID_LIST_TMP);
 END IF;


 DELETE FROM OM_ID_LIST_TMP;

 IF l_header_id_tbl.FIRST IS NOT NULL THEN
  FORALL j IN  l_header_id_tbl.FIRST..l_header_id_tbl.LAST
  INSERT INTO OM_ID_LIST_TMP(KEY_ID)
  VALUES (l_header_id_tbl(j));
 END IF;

 --execute means book the orders
 IF p_execution_mode = 'EXECUTE' THEN
    FOR k in unique_header_id LOOP
     oe_debug_pub.add('Booking header id:'||k.header_id);
	 -- Progress the workflow so that booking process is kicked off.
	 -- This call should come back with a message OE_ORDER_BOOKED
	 -- if booking completed successfully and if booking was deferred,
	 -- message OE_ORDER_BOOK_DEFERRED is added to the stack.
	 -- If booking was not successful, it should come back with a
	 -- return status of FND_API.G_RET_STS_ERROR or
	 -- FND_API.G_RET_STS_UNEXP_ERROR
	 OE_Order_Book_Util.Complete_Book_Eligible
			( p_api_version_number	=> 1.0
			, p_init_msg_list		=>  FND_API.G_FALSE
			, p_header_id			=> k.header_id
			, x_return_status		=> l_return_status
			, x_msg_count			=> l_msg_count
			, x_msg_data			=> l_msg_data);

     /*Oe_Order_Book_Util.Book_Order(p_api_version_number=>1.0
                              	  ,p_header_id=>k.header_id
                              	  ,x_return_status=>l_return_status
                                  ,x_msg_count=>l_msg_count
                                  ,x_msg_data=>l_msg_data);*/
     IF l_debug_level > 0 THEN
     --skubendr{
       IF (l_return_status<>FND_API.G_RET_STS_SUCCESS) THEN
            Display_Message(l_msg_count,l_msg_data);
       END IF;
     --skubendr}
     END IF;

     --bug5003256 start
     IF (l_return_status<>FND_API.G_RET_STS_SUCCESS) THEN
	SELECT count(*) INTO l_book_line_count
	FROM oe_order_lines_all
	WHERE header_id = k.header_id;
	x_error_count := x_error_count + l_book_line_count;
     END IF;
     --bug5003256 end

    END LOOP;
 ELSIF p_execution_mode = 'PREVIEW' THEN  --preview again, reprice the order
    l_Price_Control_Rec.pricing_event := 'RETROBILL';
    l_Price_Control_Rec.calculate_flag :=  QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
    l_Price_Control_Rec.Simulation_Flag := 'N';

    --bug3738043 start
    --reinitializing G_RETRO_PRICING_PHASE_COUNT when previewed again
    G_RETRO_PRICING_PHASE_COUNT := Get_Retro_Pricing_Phase_count;

   --bug3738043 end

    FOR k in unique_header_id LOOP
     oe_debug_pub.add('Retro:Repricing Order: header id:'||k.header_id);
     --cal price flag from retrobilling lines are 'N', set them to 'Y' before
     --reprice and then set them back to 'N'
     UPDATE OE_ORDER_LINES_ALL
     SET    calculate_price_flag='Y'
     WHERE  header_id=k.header_id;

     oe_order_adj_pvt.Price_line(X_Return_Status	=> l_Return_Status
				,p_Header_id		=> k.header_id
				,p_Request_Type_code=> 'ONT'
				,p_Control_rec		=> l_Price_Control_Rec
				,p_write_to_db      => TRUE
				,x_line_Tbl         => l_Line_Tbl);
     oe_debug_pub.add('Retro:return status from price_line:'||l_Return_Status);

     --bug5003256 start
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	x_error_count := x_error_count + l_line_tbl.count;
     END IF;
     --bug5003256 end

     UPDATE OE_ORDER_LINES_ALL
     SET    calculate_price_flag='N'
     WHERE  header_id=k.header_id;

    END LOOP;
 END IF;

End;

--Procedure for deleting the order header if no retrobill lines are created
PROCEDURE Delete_Order
( p_header_id  in NUMBER,
  --bug5003256
  x_header_deleted out nocopy BOOLEAN)
AS
  l_line_count NUMBER := 0;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data  VARCHAR2(5000);
 BEGIN
  oe_debug_pub.add('Entering procedure Delete_Order');
  --bug5003256
  x_header_deleted := FALSE;
  select count(*) into l_line_count from oe_order_lines_all where header_id=p_header_id;
  IF(l_line_count =0) THEN
     OE_Header_Util.Delete_Row(p_header_id);
     --bug5003256
     x_header_deleted := TRUE;
  END IF;
 EXCEPTION
 WHEN OTHERS THEN
 oe_debug_pub.add('Exception occured in Delete_Order:'||SQLERRM);
END;

PROCEDURE Process_Retrobill_Request
(p_retrobill_request_rec  IN  OE_RETROBILL_REQUESTS%ROWTYPE
,p_retrobill_tbl          IN  RETROBILL_TBL_TYPE
,x_created_retrobill_request_id  OUT NOCOPY NUMBER
,x_msg_count	          OUT NOCOPY NUMBER
,x_msg_data	          OUT NOCOPY VARCHAR2
,x_return_status          OUT NOCOPY VARCHAR2
,x_retrun_status_text	  OUT NOCOPY VARCHAR2
--bug5003256
,x_error_count            OUT NOCOPY NUMBER
) AS
l_sold_to_org NUMBER;
l_currency_code   VARCHAR2(15);
l_conversion_type VARCHAR2(30);
l_header_rec OE_ORDER_PUB.HEADER_REC_TYPE;
l_line_rec   OE_ORDER_PUB.LINE_REC_TYPE;
l_line_tbl   OE_ORDER_PUB.LINE_TBL_TYPE;
l_retrobill_request_id NUMBER;
l_header_price_list_id NUMBER;
l_update_price_list Boolean:=FALSE;
l_retrobill_request_rec OE_RETROBILL_REQUESTS%ROWTYPE;
j PLS_INTEGER:=0;
i PLS_INTEGER:=1;
l_visited Boolean:=FALSE;
stmt NUMBER;
lx_header_id NUMBER;
l_to_be_exe_hdr_id_tbl OE_GLOBALS.NUMBER_TBL_TYPE;
l_msg_count NUMBER;
l_msg_data  VARCHAR2(5000);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
lx_return_status VARCHAR2(15);
l_msg VARCHAR2(2000);
--bug5003256 start
l_book_line_count NUMBER;
l_header_deleted BOOLEAN;
--bug5003256 end
l_cust_po_number VARCHAR2(50); -- Bug# 6603714
l_Line_price_Att_rec         Oe_Order_Pub.Line_Price_Att_Rec_Type; -- 8736629
l_Line_price_Att_tbl         Oe_Order_Pub.Line_Price_Att_Tbl_Type; -- 8736629
l_row_count NUMBER; -- 8736629
Begin
 stmt:=1;
 x_return_status:=FND_API.G_RET_STS_SUCCESS;
 --GSCC (instead of initializing in the spec)
 G_FIRST_LINE_DELETED := 'N';
 G_FIRST_LINE_PL_ASSIGNED := 'N';
 --GSCC not initializing during declaration
 l_sold_to_org :=-9876571.5;
 l_currency_code :='*&)1a--,=2@~';
 l_conversion_type := '#2g?,-871))z';
 l_cust_po_number := '#2g?,-871))z'; -- Bug# 6603714


 l_retrobill_request_rec:=p_retrobill_request_rec;
 --skubendr{
 G_RETROBILL_REQUEST_REC:=p_retrobill_request_rec;
 --skubendr}
G_LINES_NOT_RETRO_DISPLAYED := 'N';
--bug5003256
x_error_count := 0;
 --First time preview or execute, retrobill_line_id is null because retrobill lines not yet created
 If (p_retrobill_request_rec.execution_mode = 'PREVIEW'
     OR p_retrobill_request_rec.execution_mode = 'EXECUTE')
     AND (p_retrobill_tbl(p_retrobill_tbl.first).retrobill_line_id IS NULL)
     AND p_retrobill_request_rec.retrobill_request_id IS NULL
 Then
   stmt:=2;
   Select OE_RETROBILL_REQUEST_S.NEXTVAL
   Into   l_retrobill_request_rec.retrobill_request_id
   From   dual;

   G_CURRENT_RETROBILL_REQUEST_ID:=l_retrobill_request_rec.retrobill_request_id;
   x_created_retrobill_request_id:=l_retrobill_request_rec.retrobill_request_id;
   g_retrobill_request_rec.retrobill_request_id:=l_retrobill_request_rec.retrobill_request_id;
   stmt:=3;
   Insert_Id(p_retrobill_tbl);
   stmt:=4;
   For l In Group_Lines Loop

       If l_sold_to_org <> l.sold_to_org_id1 OR
          l_currency_code   <> l.transactional_curr_code OR
          l_conversion_type <> l.conversion_type_code
       Then  --New group create new header


         If l_visited Then --Process Previous Headers and Lines before creating new group
           --call process order
           Call_Process_Order(p_header_rec       =>l_header_rec,
                              p_line_tbl         =>l_line_tbl,
                              p_Line_price_Att_tbl => l_Line_price_Att_tbl, -- 8736629
                              x_created_header_id=>lx_header_id,
                              x_return_status    =>lx_return_status);
            IF(lx_return_status=FND_API.G_RET_STS_SUCCESS and lx_header_id is not NULL) THEN
            Oe_retrobill_Pvt.Delete_Order(lx_header_id, l_header_deleted);
	    --bug5003256
            ELSE
	       x_error_count := x_error_count + l_line_tbl.count;
            END IF;

            oe_debug_pub.add('Praveen: Price List Id' || G_FIRST_LINE_PRICE_LIST_ID);
           oe_debug_pub.add('Praveen: First Line Deleted' || G_FIRST_LINE_DELETED);

	    BEGIN

	    SELECT price_list_id INTO l_header_price_list_id
	     FROM oe_order_headers_all
	     WHERE header_id=lx_header_id;

	    IF ((G_FIRST_LINE_DELETED='Y' AND
                 G_FIRST_LINE_PL_ASSIGNED='Y' AND
		 G_FIRST_LINE_PRICE_LIST_ID IS NOT NULL) OR
		  (l_header_price_list_id IS NULL)) THEN
	    BEGIN
	      UPDATE oe_order_headers_all
	      SET price_list_id=G_FIRST_LINE_PRICE_LIST_ID
	      WHERE header_id=lx_header_id;
	    EXCEPTION
	       WHEN NO_DATA_FOUND THEN
		  null;
	    END;
	    END IF;
	  EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		 null;
          END;



           If lx_return_status = FND_API.G_RET_STS_SUCCESS AND
	      NOT l_header_deleted Then --bug5003256
             l_to_be_exe_hdr_id_tbl(i):=lx_header_id;
             i:=i+1;
           End If;

           oe_debug_pub.add('Retro:Return status after calling process order:'||lx_return_status);

           --clear header, reset line tbl records
           l_line_tbl.delete;
           l_header_rec:=null;
           L_Line_price_Att_tbl.delete; --8736629
           j:=0;
	   G_FIRST_LINE_DELETED:='N';
	  G_FIRST_LINE_PRICE_LIST_ID:=null;
	  G_FIRST_LINE_PL_ASSIGNED:='N';
         End If;

         l_cust_po_number:= l.cust_po_number; -- Bug# 6603714
         l_sold_to_org := l.sold_to_org_id1;
         l_currency_code   := l.transactional_curr_code;
         l_conversion_type := l.conversion_type_code;
         stmt:=5;
         Prepare_Header(p_cust_po_number       =>l_cust_po_number,  -- Bug# 6603714
                        p_sold_to_org_id       =>l_sold_to_org,
                        p_transaction_curr_code=>l_currency_code,
                        p_conversion_type_code =>l_conversion_type,
                        p_retrobill_request_rec=>l_retrobill_request_rec,
                        x_header_rec           =>l_header_rec);
         stmt:=6;
         l_visited := TRUE;

       End If;
       stmt:=7;
       Prepare_Line(p_oline_rec=>l,
                    p_retrobill_tbl=>p_retrobill_tbl,
                    p_retrobill_request_rec=>l_retrobill_request_rec,
                    x_line_rec=>l_line_rec);

       --8736629
       oe_debug_pub.add('Prining the line_id before call to Prepare_Line_Pricing_Attribs: '|| l.line_id);
       Prepare_Line_Pricing_Attribs(p_line_id => l.line_id,
                                    x_Line_price_Att_rec => l_Line_price_Att_rec,
                                    x_row_count => l_row_count);
       IF l_row_count > 0 THEN
           l_Line_price_Att_rec.operation := OE_GLOBALS.G_OPR_CREATE;
       END IF;
       --8736629


       IF(j=0) THEN
         G_FIRST_LINE_PRICE_LIST_ID := l_line_rec.price_list_id;
       END IF;
       j:=j+1;
       oe_debug_pub.add('Adding line rec to the table to index : '|| j);
       l_line_tbl(j):=l_line_rec;
       -- Added for bug 8736629 Start
       IF l_row_count > 0 THEN
           oe_debug_pub.add('Adding attribute rec to the table to index : '|| j);
           l_Line_price_Att_rec.line_index:= j;
           l_Line_price_Att_tbl(j):=l_Line_price_Att_rec;
           oe_debug_pub.add('Clearing the attribute rec after adding attribute rec to the attribute table');
           l_Line_price_Att_rec:= NULL;
       END IF;
       -- Added for bug 8736629 End
       stmt:=8;
   End Loop;

   --Call Pro Ord If there is only one unique header or for the last header and lines group
   Call_Process_Order(p_header_rec=>l_header_rec,
                      p_line_tbl=>l_line_tbl,
                      p_Line_price_Att_tbl => l_Line_price_Att_tbl, -- 8736629
                      x_created_header_id=>lx_header_id,
                      x_return_status=>lx_return_status);
   IF(lx_return_status=FND_API.G_RET_STS_SUCCESS and lx_header_id is not NULL) THEN
     oe_retrobill_pvt.delete_order(lx_header_id, l_header_deleted); --bug5003256
   --bug5003256
   ELSE
     x_error_count := x_error_count + l_line_tbl.count;

   END IF;

   oe_debug_pub.add('Praveen: Price List Id' || G_FIRST_LINE_PRICE_LIST_ID);
   oe_debug_pub.add('Praveen: First Line Deleted' || G_FIRST_LINE_DELETED);

   If lx_return_status = FND_API.G_RET_STS_SUCCESS AND
      NOT l_header_deleted Then --bug5003256
      l_to_be_exe_hdr_id_tbl(i):=lx_header_id;
   End If;
   BEGIN

	    SELECT price_list_id INTO l_header_price_list_id
	     FROM oe_order_headers_all
	     WHERE header_id=lx_header_id;

	    IF ((G_FIRST_LINE_DELETED='Y' AND
                 G_FIRST_LINE_PL_ASSIGNED='Y' AND
		 G_FIRST_LINE_PRICE_LIST_ID IS NOT NULL) OR
		  (l_header_price_list_id IS NULL)) THEN
	    BEGIN
	      UPDATE oe_order_headers_all
	      SET price_list_id=G_FIRST_LINE_PRICE_LIST_ID
	      WHERE header_id=lx_header_id;
	    EXCEPTION
	       WHEN NO_DATA_FOUND THEN
		  null;
	    END;
	    END IF;
	  EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		 null;
   END;

   IF p_retrobill_request_rec.execution_mode = 'EXECUTE' THEN
     i:=l_to_be_exe_hdr_id_tbl.first;
     --bug5003256
     IF i IS NOT NULL THEN
	x_error_count := 0; --not including the error count obtained while previewing
     END IF;

     WHILE i IS NOT NULL LOOP
       	 OE_Order_Book_Util.Complete_Book_Eligible
			( p_api_version_number	=> 1.0
			, p_init_msg_list		=>  FND_API.G_FALSE
			, p_header_id			=> l_to_be_exe_hdr_id_tbl(i)
			, x_return_status		=> lx_return_status
			, x_msg_count			=> l_msg_count
			, x_msg_data			=> l_msg_data);
       IF l_debug_level > 0 THEN
         oe_debug_pub.add('Retro:Direct Execution without preview');
         --skubendr{
         IF (lx_return_status<>FND_API.G_RET_STS_SUCCESS) THEN
             Display_Message(l_msg_count,l_msg_data);
         END IF;
         --skubendr}
       END IF;

       --bug5003256 start
       IF (lx_return_status<>FND_API.G_RET_STS_SUCCESS) THEN
	  SELECT count(*) INTO l_book_line_count
	  FROM oe_order_lines_all
	  WHERE header_id = l_to_be_exe_hdr_id_tbl(i);

	  x_error_count := x_error_count + l_book_line_count;
       END IF;
       --bug5003256 end

     i:=l_to_be_exe_hdr_id_tbl.next(i);
     END LOOP;
   END IF;
   IF(g_retrobill_request_rec.retrobill_request_id = l_retrobill_request_rec.retrobill_request_id) THEN
      l_retrobill_request_rec.sold_to_org_id:=g_retrobill_request_rec.sold_to_org_id;
      l_retrobill_request_rec.inventory_item_id:=g_retrobill_request_rec.inventory_item_id;
    END IF;
    oe_debug_pub.add('sold_to_org_id'||l_retrobill_request_rec.sold_to_org_id);
    oe_debug_pub.add('inventory_item_id'||l_retrobill_request_rec.inventory_item_id);
   Insert_Retrobill_Request(l_retrobill_request_rec);


 Else --previously previewed request

  --EXECUTE will not reprice the orders/lines, just booked the order and update
  --PREVIEW again will reprice the orders/lines
  oe_debug_pub.add('execution mode:'||p_retrobill_request_rec.execution_mode);

  G_CURRENT_RETROBILL_REQUEST_ID:=p_retrobill_request_rec.retrobill_request_id;

  IF G_CURRENT_RETROBILL_REQUEST_ID IS NULL THEN
    oe_debug_pub.add('Retro:previouly previewed request, request id can not be NULL!');
    l_msg:='Retro:previouly previewed request, request id can not be NULL!';
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --retrobilled request parameters
  Update_Row(p_retrobill_request_rec=>l_retrobill_request_rec);

  --Handle Delete,Update and null operations on the p_retrobill_tbl
  Perform_Operations(p_retrobill_tbl,p_retrobill_request_rec.execution_mode, x_error_count);--bug5003256

 End If; --end if for execution mode

oe_msg_pub.count_and_get(p_count => x_msg_count,p_data=> x_msg_data);
Exception

When FND_API.G_EXC_UNEXPECTED_ERROR Then
 OE_MSG_PUB.Add_Exc_Msg
               (    G_PKG_NAME ,
                    l_msg
               );
 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 oe_msg_pub.count_and_get( p_count => x_msg_count,  p_data => x_msg_data);
 x_created_retrobill_request_id:=NULL;
 --bug5003256
 x_error_count := -1;
When Others Then
 oe_debug_pub.add('Exception occured in process_retrobill_requests:'||SQLERRM);
 oe_debug_pub.add('Statement number:'||stmt);
 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 x_retrun_status_text:='OE_RETROBILL_PVT.Process_Retrobill_Request'||SQLERRM;
 oe_msg_pub.count_and_get( p_count => x_msg_count,  p_data => x_msg_data);
 x_created_retrobill_request_id:=NULL;
 --bug5003256
 x_error_count := -1;
End Process_Retrobill_Request;

-- This procedure gets the request_session_id from the UI and builds the pl/sql table from oe_conc_request_iface table and passes it to
-- Process_Retrobill_Request

PROCEDURE Oe_Build_Retrobill_Tbl
(
p_request_session_id   IN  NUMBER,
p_retrobill_event      IN  VARCHAR2,
p_description          IN  VARCHAR2,
p_order_type_id        IN  NUMBER,
p_retrobill_request_id IN  NUMBER,
p_reason_code          IN  VARCHAR2,
p_retrobill_mode       IN  VARCHAR2,
p_sold_to_org_id       IN  NUMBER,
p_inventory_item_id    IN  NUMBER,
x_return_status        OUT NOCOPY VARCHAR2,
x_msg_count            OUT NOCOPY NUMBER,
x_msg_data             OUT NOCOPY VARCHAR2,
x_return_status_text   OUT NOCOPY VARCHAR2,
x_retrobill_request_id OUT NOCOPY NUMBER,
x_error_count          OUT NOCOPY NUMBER --bug5003256
)
is
   cursor c_lines is
   select line_id,
          header_id,
          numeric_attribute1,
          numeric_attribute2,
          numeric_attribute3,
          char_attribute1
   from oe_conc_request_iface
   where request_id = p_request_session_id
   FOR UPDATE NOWAIT;

   cursor c_open_retrobill_requests(c_header_id NUMBER,c_line_id NUMBER) is
   select name
   from oe_retrobill_requests
   where
   retrobill_request_id
         in
         (select retrobill_request_id from oe_order_lines_all
          where
          order_source_id=27 and
          orig_sys_document_ref=to_char(c_header_id) and
          orig_sys_line_ref=to_char(c_line_id) and
          invoiced_quantity is NULL
         )
   group by name;

   c_lines_record c_lines%rowtype;

   i NUMBER :=1;
   j NUMBER;
   l_retrobill_request_rec OE_RETROBILL_REQUESTS%ROWTYPE;
   l_retrobill_tbl         OE_RETROBILL_PVT.RETROBILL_TBL_TYPE;

   l_return_status varchar2(2000);
   l_msg_count NUMBER;
   l_msg_data  varchar2(2000);
   l_return_status_text varchar2(2000);
   l_retrobill_request_id NUMBER;

   l_request_name  varchar2(2000) := NULL;
   l_lines_not_retrobilled_count NUMBER:=0;

   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
    open c_lines;
    If l_debug_level > 0 Then
        Oe_Debug_Pub.add('skubendr:Entering procedure Oe_Retrobill_Pvt.Oe_Build_Retrobill_Table');
    End If;

    -- Initialize Message Stack
    -- We initialize the message stack here and for the subsequent process order calls pass the init_msg_list as FALSE
       OE_MSG_PUB.initialize;
 LOOP
    fetch c_lines into c_lines_record;
    exit when c_lines%notfound;

      IF(p_retrobill_request_id is NULL) THEN
         FOR  c_open_retrobill_requests_rec in c_open_retrobill_requests(c_lines_record.header_id,c_lines_record.line_id) LOOP
                 l_request_name       := c_open_retrobill_requests_rec.name;
         END LOOP;
         oe_debug_pub.add('l_request_name:'||l_request_name);
      END IF;

    IF(l_request_name is NULL OR p_retrobill_request_id is NOT NULL) THEN
        l_retrobill_tbl(i).original_line_id         :=c_lines_record.line_id;
        l_retrobill_tbl(i).original_header_id       :=c_lines_record.header_id;
        l_retrobill_tbl(i).retrobill_qty            :=
                                                      c_lines_record.numeric_attribute1;
        l_retrobill_tbl(i).retrobill_line_id        :=
                                                      c_lines_record.numeric_attribute2;
        l_retrobill_tbl(i).retrobill_header_id      :=
                                                      c_lines_record.numeric_attribute3;
        l_retrobill_tbl(i).operation                :=
                                                      c_lines_record.char_attribute1;
     ELSE
        -- Setting the Message Context
        OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'LINE'
        ,p_entity_ref                 => null
        ,p_entity_id                  => null
        ,p_header_id                  => c_lines_record.header_id
        ,p_line_id                    => c_lines_record.line_id
--      ,p_batch_request_id           => p_x_header_rec.request_id
        ,p_order_source_id            => null
        ,p_orig_sys_document_ref      => null
        ,p_change_sequence            => null
        ,p_orig_sys_document_line_ref => null
        ,p_orig_sys_shipment_ref      => null
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );

        IF l_debug_level > 0 Then
           oe_debug_pub.add('Line has open retrobill line:'||c_lines_record.line_id);
           oe_debug_pub.add('Open Request:'||l_request_name);
        END IF;

        -- The line has previewed retrobill line and hence cannot be previewed
        FND_MESSAGE.SET_NAME('ONT','ONT_UNINVOICED_RETLINE_EXIST');
        FND_MESSAGE.SET_TOKEN('REQUEST',l_request_name);
        OE_MSG_PUB.ADD;
     END IF;
        l_request_name := NULL;
        i := i + 1;
    END LOOP;

     IF (c_lines%ISOPEN) then
     close c_lines;
     END IF;

     l_retrobill_request_rec.name                  := p_retrobill_event;
     l_retrobill_request_rec.description           := p_description;
     l_retrobill_request_rec.execution_mode        := p_retrobill_mode;
     l_retrobill_request_rec.order_type_id         := p_order_type_id;
     l_retrobill_request_rec.retrobill_reason_code := p_reason_code;
     l_retrobill_request_rec.retrobill_request_id  := p_retrobill_request_id;
     l_retrobill_request_rec.sold_to_org_id        := p_sold_to_org_id;
     l_retrobill_request_rec.inventory_item_id     := p_inventory_item_id;

  If l_debug_level > 0 Then
      Oe_Debug_Pub.add('skubendr:Before calling Oe_Retrobill_Pvt.Process_Retrobill_Request');
  End If;

  IF(l_retrobill_tbl.count <> 0) THEN
     Oe_Retrobill_Pvt.Process_Retrobill_Request
     (p_retrobill_request_rec         => l_retrobill_request_rec
      ,p_retrobill_tbl                => l_retrobill_tbl
      ,x_created_retrobill_request_id => l_retrobill_request_id
      ,x_msg_count                    => l_msg_count
      ,x_msg_data                     => l_msg_data
      ,x_return_status                => l_return_status
      ,x_retrun_status_text           => l_return_status_text
      ,x_error_count                  => x_error_count); --bug5003256
  END IF;

 IF l_debug_level > 0 Then
   Oe_Debug_Pub.add('skubendr:After calling Oe_Retrobill_Pvt.Process_Retrobill_Request :'||l_return_status);
 END IF;

 -- delete the data from temp table after retrobilling process
 IF(p_request_session_id is not NULL) THEN
  Delete from oe_conc_request_iface where request_id =p_request_session_id;
 END IF;

      x_retrobill_request_id   := l_retrobill_request_id;
      x_msg_count              := OE_MSG_PUB.Count_Msg;
      x_msg_data               := l_msg_data;
      x_return_status          := l_return_status;
      x_return_status_text     := l_return_status_text;

 IF l_debug_level > 0 Then
        Oe_Debug_Pub.add('skubendr:Exiting procedure Oe_Retrobill_Pvt.Oe_Build_Retrobill_Table:'||l_return_status);
 END IF;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
    RAISE NO_DATA_FOUND;
 WHEN OTHERS THEN
    oe_debug_pub.add('Error'||SQLERRM);
END  Oe_Build_Retrobill_Tbl;


-- This procedure will be called from the UI when the user submits an concurrent request

PROCEDURE Oe_Retrobill_Conc_Pgm
(
errbuf                  OUT NOCOPY VARCHAR2,
retcode                 OUT NOCOPY NUMBER,
p_request_session_id    IN VARCHAR2,
p_retrobill_event       IN VARCHAR2,
p_description           IN VARCHAR2,
p_order_type_id         IN VARCHAR2,
p_retrobill_request_id  IN VARCHAR2,
p_reason_code           IN VARCHAR2,
p_retrobill_mode        IN VARCHAR2,
p_sold_to_org_id        IN NUMBER,
p_inventory_item_id     IN NUMBER
)
is
    l_return_status  VARCHAR2(2000);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_return_status_text VARCHAR2(2000);
    l_retrobill_request_id NUMBER;

    l_concurrent_request_id NUMBER;
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --rt moac
    l_org_id NUMBER;

    --bug5003256
    l_error_count NUMBER;


BEGIN

   FND_PROFILE.Get('CONC_REQUEST_ID', l_concurrent_request_id);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'REQUEST ID: '|| TO_CHAR ( L_CONCURRENT_REQUEST_ID ) ) ;
   END IF;
   --rt moac start
   BEGIN
      SELECT org_id INTO l_org_id
      FROM oe_transaction_types_all
      WHERE transaction_type_id = p_order_type_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_return_status := FND_API.G_RET_STS_ERROR;
	 fnd_file.put_line(FND_FILE.OUTPUT,'Could not set org context');
	 retcode := -1;
	 RETURN;
   END;
   IF l_org_id IS NOT NULL THEN
      MO_GLOBAL.Set_Policy_Context('S',l_org_id);
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add('Context is set for org_id : '|| mo_global.get_current_org_id);
      END IF;
   ELSE
      l_return_status := FND_API.G_RET_STS_ERROR;
      fnd_file.put_line(FND_FILE.OUTPUT,'Could not set org context');
      retcode := -1;
      RETURN;
   END IF;
   --rt moac end

Oe_Build_Retrobill_Tbl(
    p_request_session_id  =>to_number(p_request_session_id),
    p_retrobill_event     =>p_retrobill_event,
    p_description         =>p_description,
    p_order_type_id       =>to_number(p_order_type_id),
    p_retrobill_request_id=>to_number(p_retrobill_request_id),
    p_reason_code         =>p_reason_code,
    p_retrobill_mode      =>p_retrobill_mode,
    p_sold_to_org_id      =>p_sold_to_org_id,
    p_inventory_item_id   =>p_inventory_item_id,
    x_return_status       =>l_return_status,
    x_msg_count           =>l_msg_count,
    x_msg_data            =>l_msg_data,
    x_return_status_text  =>l_return_status_text,
    x_retrobill_request_id=>l_retrobill_request_id,
    x_error_count         => l_error_count --bug5003256
    );

      IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          OE_MSG_PUB.save_messages (l_concurrent_request_id);
          commit;
          fnd_file.put_line(FND_FILE.OUTPUT,'Sucessful completion');
          errbuf  := FND_MESSAGE.GET;
          retcode := 0;
      ELSE
          rollback;
          OE_MSG_PUB.save_messages (l_concurrent_request_id);
          commit;
          fnd_file.put_line(FND_FILE.OUTPUT,'Failed');
          errbuf  := FND_MESSAGE.GET;
          retcode := -1;
      END IF;
EXCEPTION
  WHEN OTHERS THEN
   rollback;
   oe_debug_pub.add('Error'||SQLERRM);
   retcode := -1;
END Oe_Retrobill_Conc_Pgm;


FUNCTION Retrobill_Enabled RETURN BOOLEAN
IS
 l_enable_retrobilling varchar2(1);
BEGIN
  l_enable_retrobilling := nvl(OE_Sys_Parameters.VALUE('ENABLE_RETROBILLING'),'N');
 IF(l_enable_retrobilling = 'Y') THEN
   return(TRUE);
 ELSE
  return(FALSE);
 END IF;
END Retrobill_Enabled;

PROCEDURE Interface_Retrobilled_RMA
(  p_line_rec    IN    OE_Order_PUB.Line_Rec_Type
,  p_header_rec  IN    OE_Order_PUB.Header_Rec_Type
,  x_return_status     OUT NOCOPY VARCHAR2
,  x_result_out        OUT NOCOPY  VARCHAR2
) IS

l_result_code VARCHAR2(240);
l_return_status VARCHAR2(30);
l_interface_line_rec       OE_Invoice_PUB.RA_Interface_Lines_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

--Find all retrobill bill only lines created before the Return Line
cursor previous_retrobill_lines IS
select /* MOAC_SQL_CHANGE */ retro_line.line_id
, retro_line.header_id
, retro_line.order_source_id
, retro_line.unit_list_price
, retro_line.unit_selling_price
, retro_line.invoiced_quantity
, retro_line.line_category_code
, retro_line.retrobill_request_id
, retro_header.order_number
, retro_header.order_type_id
from
  oe_order_lines_all retro_line
,  oe_order_lines orig_line
,  oe_order_headers_all retro_header
where orig_line.line_id = p_line_rec.reference_line_id
and retro_line.order_source_id=27
and retro_line.orig_sys_document_ref = to_char(orig_line.header_id) --bug5553346
and retro_line.orig_sys_line_ref = to_char(p_line_rec.reference_line_id) --bug5553346
and retro_line.header_id = retro_header.header_id
and retro_line.creation_date < p_line_rec.creation_date;
l_line_rec OE_ORDER_PUB.LINE_REC_TYPE;
l_line_tbl OE_ORDER_PUB.LINE_TBL_TYPE;
i pls_integer;
l_retrobilled_list_price number :=0;
l_retrobilled_selling_price number:=0;
l_retro_adjusted_list_price number :=0;
l_retro_adjusted_selling_price number := 0;
l_orig_header_id NUMBER;
l_orig_list_price NUMBER;
l_orig_selling_price NUMBER;
BEGIN
null;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING INTERFACE_Retrobilled_RMA ( ) PROCEDURE' , 5 ) ;
        oe_debug_pub.add(  'INTERFACING Retro RMA LINE ID '||TO_CHAR ( P_LINE_REC.LINE_ID ), 3);
    END IF;

    -- First credit to original order line, then positive retrobill lines
    i := 1;
    -- the first line is original order line
    l_line_tbl(1) := p_line_rec;

    -- loop through retrobill lines
    For retrobill_line in previous_retrobill_lines
    LOOP
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('find retrobill line'||retrobill_line.line_id, 3);
        oe_debug_pub.add('line category code'||retrobill_line.line_category_code, 3);
        oe_debug_pub.add('retrobill request'||retrobill_line.retrobill_request_id, 3);
        oe_debug_pub.add('order_source_id'||retrobill_line.order_source_id, 3);
        oe_debug_pub.add('list price'||retrobill_line.unit_list_price, 3);
        oe_debug_pub.add('selling price'||retrobill_line.unit_selling_price, 3);
      END IF;
        -- Only credit to positive lines, but want to get the
        -- total retrobilled price even for negative lines,
        -- so that we know whether RMA line price is the same as invoiced price
        IF (retrobill_line.line_category_code='ORDER') THEN
          --3661895 This is for caching retrobill bill only lines header_id and line_id
          G_Retro_Bill_Only_Line_Tbl(i).header_id := retrobill_line.header_id;
          G_Retro_Bill_Only_Line_Tbl(i).line_id   := retrobill_line.line_id;
          l_line_rec := p_line_rec;
          l_line_rec.credit_invoice_line_id := Get_Credit_Invoice_Line_Id(retrobill_line.order_number
                                                                          ,retrobill_line.order_type_id
                                                                          ,retrobill_line.line_id);
          l_line_rec.retrobill_request_id := retrobill_line.retrobill_request_id;
          l_line_rec.order_source_id := retrobill_line.order_source_id;
          l_line_rec.orig_sys_document_ref := retrobill_line.header_id;
          l_line_rec.orig_sys_line_ref := retrobill_line.line_id;
          l_line_rec.unit_list_price := retrobill_line.unit_list_price;
          l_line_rec.unit_selling_price := retrobill_line.unit_selling_price;
          -- The following is for the SQL for discount reference_line_id
          l_line_rec.reference_line_id := retrobill_line.line_id;
          l_retrobilled_list_price := l_retrobilled_list_price  + retrobill_line.unit_list_price;
          l_retrobilled_selling_price := l_retrobilled_selling_price+ retrobill_line.unit_selling_price;
          l_retro_adjusted_list_price := l_retro_adjusted_list_price  + retrobill_line.unit_list_price;
          l_retro_adjusted_selling_price := l_retro_adjusted_selling_price  + retrobill_line.unit_selling_price;

          i := i + 1;
          l_line_tbl(i) := l_line_rec;
         ELSE
          l_retrobilled_list_price := l_retrobilled_list_price - retrobill_line.unit_list_price;
          l_retrobilled_selling_price := l_retrobilled_selling_price- retrobill_line.unit_selling_price;
         END IF;
    END LOOP;

-- Get the original price
    BEGIN
     SELECT header_id
           ,unit_list_price
           ,unit_selling_price INTO
            l_orig_header_id
           ,l_orig_list_price
           ,l_orig_selling_price
       FROM oe_order_lines_all where line_id=p_line_rec.reference_line_id;
EXCEPTION
    WHEN OTHERS THEN
      -- THis is impossible
      RAISE FND_API.G_EXC_ERROR;
    END;

   IF l_debug_level  > 0 THEN
     oe_debug_pub.add('original Price:'||l_orig_selling_price,3);
     oe_debug_pub.add('rma price:'||p_line_rec.unit_selling_price,3);
     oe_debug_pub.add('retrobilled price'||l_retrobilled_selling_price,3);
   END IF;
   -- No retrobill line, interface the current line as it is
   -- If RMA price doesn't match the invoiced price, we don't know how to handle this, credit to the original line: normally should nothappen
   IF (l_line_tbl.count = 1) THEN
     OE_Invoice_PUB.Interface_Single_line(p_line_rec  => p_line_rec
                             ,p_header_rec            => p_header_rec
                             ,p_x_interface_line_rec  => l_interface_line_rec
                             ,x_return_status         => x_return_status
                             ,x_result_out            => x_result_out);
    RETURN;
   END IF;

    -- some retrobill bill only line exists
    i := l_line_tbl.first;
   while i is not null loop
     l_line_rec := l_line_tbl(i);
     IF (i = 1) THEN
        -- credit to original line

       l_line_rec.retrobill_request_id := 0;
       if (l_orig_list_price + l_retro_adjusted_list_price <> p_line_rec.unit_list_price) then
        -- there are other retrobill credit lines that already credit to original invoice
         l_line_rec.unit_list_price := p_line_rec.unit_list_price - l_retro_adjusted_list_price;
         l_line_rec.unit_selling_price := p_line_rec.unit_selling_price - l_retro_adjusted_selling_price;
       else
         l_line_rec.unit_list_price := l_orig_list_price;
         l_line_rec.unit_selling_price := l_orig_selling_price;
       end if;

       l_line_rec.orig_sys_document_ref := l_orig_header_id;
       l_line_rec.orig_sys_line_ref := l_line_rec.reference_line_id;
     ELSE
       l_line_rec.invoiced_quantity := NULL;
     END IF;

   IF l_debug_level  > 0 THEN
     oe_debug_pub.add('retrobill:'||l_line_rec.line_id,3);
     oe_debug_pub.add('retrobill line category'
                      ||l_line_rec.line_category_code,3);
     oe_debug_pub.add('retrobill line type'
                      ||l_line_rec.line_type_id,3);
     oe_debug_pub.add('retrobill item'||l_line_rec.ordered_item,3);
     oe_debug_pub.add('invoiced_quantity'||l_line_rec.invoiced_quantity,3);
   END IF;

   OE_Invoice_PUB. Interface_Single_line(p_line_rec   => l_line_rec
                             ,p_header_rec            => p_header_rec
                             ,p_x_interface_line_rec  => l_interface_line_rec
                             ,x_return_status         => x_return_status
                             ,x_result_out            => x_result_out);

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INTERFACED W/REQUEST_ID : '||
 L_INTERFACE_LINE_REC.REQUEST_ID || ' X_RETURN_STATUS: '|| X_RETURN_STATUS , 5 ) ;
        END IF;
        IF    x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    i := l_line_tbl.next(i);
   END LOOP;

-- 3661895:  we need to clear this global table
   G_Retro_Bill_Only_Line_Tbl.delete;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Clearing the cache G_Retro_Bill_Only_Line_Tbl');
   END IF;
END Interface_Retrobilled_RMA;

Function Invoice_Number(p_order_number IN NUMBER,
			   p_line_id IN NUMBER,
			    p_order_type_id NUMBER) RETURN VARCHAR2 AS

l_order_number NUMBER;
l_line_id NUMBER;
l_order_type_id NUMBER;
l_trx_number ra_customer_trx_all.trx_number%TYPE;

CURSOR invoice_number is
select rct.trx_number
from ra_customer_trx_lines_all rctl,
      ra_customer_trx_all rct,
      oe_transaction_types_tl ott
where rctl.INTERFACE_LINE_CONTEXT='ORDER ENTRY' and
 rctl.INTERFACE_LINE_ATTRIBUTE1= to_char(l_order_number) and -- Added to_char for bug 9323027
 rctl.INTERFACE_LINE_ATTRIBUTE2=ott.name and
rctl. INTERFACE_LINE_ATTRIBUTE6= to_char(l_line_id) and -- Added to_char for bug 9323027
rctl.customer_trx_id = rct.customer_trx_id and
 ott.transaction_type_id=l_order_type_id
and    ott.language = (select language_code from fnd_languages
where  installed_flag = 'B') ;

BEGIN
  --GSCC Not initializing during declaration
  l_order_number := p_order_number;
  l_line_id := p_line_id;
  l_order_type_id := p_order_type_id;

  OPEN invoice_number;
  LOOP
  FETCH invoice_number into l_trx_number;
  EXIT WHEN invoice_number%NOTFOUND;
  END LOOP;
  IF (invoice_number%ROWCOUNT=0) THEN
     l_trx_number:=null;
  END IF;
  return l_trx_number;
END Invoice_Number;

--skubendr{
--Procedure for the api based validation template Return Retrobilled Line
PROCEDURE Return_Retrobilled_Line_Check
( p_application_id                IN   NUMBER,
  p_entity_short_name             IN   VARCHAR2,
  p_validation_entity_short_name  IN   VARCHAR2,
  p_validation_tmplt_short_name   IN   VARCHAR2,
  p_record_set_short_name         IN   VARCHAR2,
  p_scope                         IN   VARCHAR2,
  x_result                        OUT  NOCOPY NUMBER
)
AS
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_count         NUMBER := 0;
  l_line_id       NUMBER;
  l_header_id     NUMBER;
  l_creation_date DATE;
  l_line_category VARCHAR2(30);
BEGIN
   l_line_id       := oe_line_security.g_record.reference_line_id;
   l_header_id     := oe_line_security.g_record.reference_header_id;
   l_line_category := oe_line_security.g_record.line_category_code;
   l_creation_date := oe_line_security.g_record.creation_date;
   If(l_line_category <> 'RETURN') THEN
     x_result :=0;
     RETURN;
   END IF;

   BEGIN
    select count(*) into l_count from
    oe_order_lines_all where
    order_source_id=27 and
    orig_sys_document_ref=to_char(l_header_id) and
    orig_sys_line_ref = to_char(l_line_id)
    and l_creation_date < creation_date;
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
    x_result := 0;
    RETURN;
   END;

   If(l_line_category = 'RETURN' and l_count>0) THEN
      x_result := 1;
   else
      x_result := 0;
  END IF;
END Return_Retrobilled_Line_Check;
--Procedure for Purging Retrobill Request and the related Headers/Lines

PROCEDURE Delete_Retrobill_Orders
( p_purge_preview_orders IN VARCHAR2,
  p_retrobill_request_id IN VARCHAR2,
  p_request_name         IN VARCHAR2,
  x_requests_processed   OUT NOCOPY NUMBER,
  x_headers_processed    OUT NOCOPY NUMBER
)
AS
  cursor retrobill_header(p_retrobill_request_id in VARCHAR2) is
         select header_id,booked_flag from oe_order_headers_all
         where orig_sys_document_ref=to_char(p_retrobill_request_id) --p_retrobill_request_id --commented for bug#7665009
         and order_source_id=27;

  l_header_count                        NUMBER;
  l_msg_count                           NUMBER;
  l_return_status                       VARCHAR2(1);
  l_msg_data                            VARCHAR2(2000);
  l_headers_processed                   NUMBER:= 0;
  l_requests_processed                  NUMBER:= 0;

  --rt moac start
  l_header_rec                OE_ORDER_PUB.Header_Rec_Type;
  l_old_header_rec            OE_ORDER_PUB.Header_Rec_Type;
  l_control_rec               OE_GLOBALS.Control_Rec_Type;
  l_header_out_rec            OE_ORDER_PUB.Header_Rec_Type;
  l_line_out_tbl              OE_ORDER_PUB.Line_Tbl_Type;
  l_line_adj_out_tbl          oe_order_pub.line_Adj_Tbl_Type;
  l_header_adj_out_tbl        OE_Order_PUB.Header_Adj_Tbl_Type;
  l_Header_Scredit_out_tbl    OE_Order_PUB.Header_Scredit_Tbl_Type;
  l_Line_Scredit_out_tbl      OE_Order_PUB.Line_Scredit_Tbl_Type;
  l_Header_Payment_out_tbl    OE_Order_PUB.Header_Payment_Tbl_Type;
  l_Line_Payment_out_tbl      OE_Order_PUB.Line_Payment_Tbl_Type;
  l_action_request_out_tbl    OE_Order_PUB.request_tbl_type;
  l_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
  l_Header_price_Att_tbl		OE_Order_PUB.Header_Price_Att_Tbl_Type;
  l_Header_Adj_Att_tbl		OE_Order_PUB.Header_Adj_Att_Tbl_Type;
  l_Header_Adj_Assoc_tbl		OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
  l_Line_price_Att_tbl		OE_Order_PUB.Line_Price_Att_Tbl_Type;
  l_Line_Adj_Att_tbl		OE_Order_PUB.Line_Adj_Att_Tbl_Type;
  l_Line_Adj_Assoc_tbl		OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
  --rt moac end

BEGIN
                FOR l_retrobill_header_rec in retrobill_header(p_retrobill_request_id) LOOP

                 IF(p_purge_preview_orders='Y') THEN
                   IF(l_retrobill_header_rec.booked_flag = 'N') THEN

		      --rt moac directly calling oe_order_pvt.process_order with delete operation since the context has already been set in procedure oe_retrobill_purge
                      /*
                      Oe_Order_Pub.Delete_Order
                       (
                       p_header_id      =>l_retrobill_header_rec.header_id,
                       x_return_status  =>l_return_status,
                       x_msg_count      =>l_msg_count,
                       x_msg_data       =>l_msg_data
                       );
		       */
		      l_header_rec              := OE_Order_PUB.G_MISS_HEADER_REC;
		      l_header_rec.header_id    := l_retrobill_header_rec.header_id;
		      l_header_rec.operation    := OE_GLOBALS.G_OPR_DELETE;

		      OE_ORDER_PVT.Process_order
			 (   p_api_version_number          => 1.0
			 ,   p_init_msg_list               => FND_API.G_TRUE
			 ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
			 ,   x_return_status               => l_return_status
			 ,   x_msg_count                   => l_msg_count
			 ,   x_msg_data                    => l_msg_data
			 ,   p_control_rec                 => l_control_rec
			 ,   p_x_header_rec                => l_header_rec
			 ,   p_x_Header_Adj_tbl            => l_Header_Adj_out_tbl
			 ,   p_x_Header_Scredit_tbl        => l_Header_Scredit_out_tbl
			 ,   p_x_Header_Payment_tbl        => l_Header_Payment_out_tbl
			 ,   p_x_line_tbl                  => l_line_out_tbl
			 ,   p_x_Line_Adj_tbl              => l_Line_Adj_out_tbl
			 ,   p_x_Line_Scredit_tbl          => l_Line_Scredit_out_tbl
			 ,   p_x_Line_Payment_tbl          => l_Line_Payment_out_tbl
			 ,   p_x_Action_Request_tbl        => l_Action_Request_out_Tbl
			 ,   p_x_lot_serial_tbl            => l_lot_serial_tbl
			 ,   p_x_Header_price_Att_tbl      => l_Header_price_Att_tbl
			 ,   p_x_Header_Adj_Att_tbl	   => l_Header_Adj_Att_tbl
			 ,   p_x_Header_Adj_Assoc_tbl	   => l_Header_Adj_Assoc_tbl
			 ,   p_x_Line_price_Att_tbl	   => l_Line_price_Att_tbl
			 ,   p_x_Line_Adj_Att_tbl	   => l_Line_Adj_Att_tbl
			 ,   p_x_Line_Adj_Assoc_tbl	   => l_Line_Adj_Assoc_tbl
			 );

                      IF(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                         oe_debug_pub.add('Deleted Header:'||l_retrobill_header_rec.header_id);
                         l_headers_processed := l_headers_processed+1;
                      END IF;
                   ELSE
                      oe_debug_pub.add('Cannot purge request as retrobill booked order exists'||p_request_name);
                      FND_MESSAGE.SET_NAME('ONT','ONT_RETRO_PURGE_NOT_ALLOWED');
                      FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_request_name);
                      OE_MSG_PUB.ADD;

                      EXIT;
                   END IF;
                ELSE
                  oe_debug_pub.add('Cannot purge request as purge preview order is N and attached orders exist');
                  FND_MESSAGE.SET_NAME('ONT','ONT_RETRO_PURGE_NOT_ALLOWED');
                  FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_request_name);
                  OE_MSG_PUB.ADD;

                  EXIT;
                END IF;--End of check purge_preview_orders
              END LOOP;

              select count(*) into l_header_count from oe_order_headers_all
              where orig_sys_document_ref=to_char(p_retrobill_request_id)  -- p_retrobill_request_id --commented for bug#7665009
              and order_source_id=27;

              IF(l_header_count = 0) THEN
                 IF(p_retrobill_request_id is NOT NULL) THEN
                    Delete from oe_retrobill_requests where
                    retrobill_request_id=to_number(p_retrobill_request_id);
                    oe_debug_pub.add('Deleted Request'||p_retrobill_request_id);
                    l_requests_processed := l_requests_processed + 1;
                 END IF;
              END IF;
               x_requests_processed := l_requests_processed;
               x_headers_processed  := l_headers_processed;
EXCEPTION
WHEN OTHERS THEN
     oe_debug_pub.add('Exception occured:'||SQLERRM);
     RAISE;
END;

PROCEDURE Oe_Retrobill_Purge
( errbuf                          OUT NOCOPY VARCHAR2,
  retcode                         OUT NOCOPY NUMBER,
  p_org_id                        IN   VARCHAR2, --rt moac
  p_retrobill_request_id          IN   VARCHAR2,
  p_creation_date_from            IN   VARCHAR2,
  p_creation_date_to              IN   VARCHAR2,
  p_execution_date_from           IN   VARCHAR2,
  p_execution_date_to             IN   VARCHAR2,
  p_purge_preview_orders          IN   VARCHAR2
)
AS
  l_header_count                        NUMBER;
  l_msg_count                           NUMBER;
  l_return_status                       VARCHAR2(1);
  l_msg_data                            VARCHAR2(2000);
  l_headers_processed_per_call          NUMBER:= 0;
  l_requests_processed_per_call         NUMBER:= 0;
  l_headers_processed                   NUMBER:= 0;
  l_requests_processed                  NUMBER:= 0;
  l_creation_date_from                  DATE;
  l_creation_date_to                    DATE;
  l_execution_date_from                 DATE;
  l_execution_date_to                   DATE;
  l_request_name                        VARCHAR2(240) := NULL;
  l_concurrent_id                       NUMBER;
  l_booked_flag                         VARCHAR2(1) := NULL;
  l_order_source_id                     NUMBER;
  l_orig_sys_document_ref               VARCHAR2(50);
  l_change_sequence                     VARCHAR2(50);
  l_orig_sys_line_ref                   VARCHAR2(50);
  l_message_text                        VARCHAR2(2000);

  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --rt moac
  l_org_id                              NUMBER;
  l_old_org_id                          NUMBER;

  cursor retrobill_request is
        --bug4752386 Selecting executed requests as well and adding execution_mode to the select clause
         select retrobill_request_id,retro.name,ord_typ.org_id,retro.execution_mode from oe_retrobill_requests retro,oe_order_types_v ord_typ --rt moac selecting the org_id
         where trunc(retro.creation_date) >= nvl(trunc(l_creation_date_from),trunc(retro.creation_date))
         and trunc(retro.creation_date) <= nvl(trunc(l_creation_date_to),trunc(retro.creation_date))
         and trunc(execution_date) >= nvl(trunc(l_execution_date_from),trunc(execution_date))
         and trunc(execution_date) <= nvl(trunc(l_execution_date_to),trunc(execution_date))
--         and execution_mode='PREVIEW'
         and retro.order_type_id = ord_typ.order_type_id
         order by org_id; --rt moac



  cursor retrobill_request_id is
        --bug4752386 Selecting executed requests as well and adding execution_mode to the select clause
         select retrobill_request_id,retro.name,ord_typ.org_id,retro.execution_mode from oe_retrobill_requests retro,oe_order_types_v ord_typ --rt moac selecting the org_id
         where retrobill_request_id = to_number(p_retrobill_request_id)
         and trunc(retro.creation_date) >= nvl(trunc(l_creation_date_from),trunc(retro.creation_date))
         and trunc(retro.creation_date) <= nvl(trunc(l_creation_date_to),trunc(retro.creation_date))
         and trunc(execution_date) >= nvl(trunc(l_execution_date_from),trunc(execution_date))
         and trunc(execution_date) <= nvl(trunc(l_execution_date_to),trunc(execution_date))
--         and execution_mode='PREVIEW'
         and retro.order_type_id = ord_typ.order_type_id;



  /* -----------------------------------------------------------
   Messages cursor
   -----------------------------------------------------------
*/
    CURSOR l_msg_cursor IS
    SELECT /*+ INDEX (a,OE_PROCESSING_MSGS_N2)
           USE_NL (a b) */
           a.order_source_id
         , a.original_sys_document_ref
            , a.change_sequence
         , a.original_sys_document_line_ref
         , b.message_text
      FROM oe_processing_msgs a, oe_processing_msgs_tl b
     WHERE a.request_id = l_concurrent_id
       AND a.transaction_id = b.transaction_id
       AND b.language = oe_globals.g_lang
  ORDER BY a.order_source_id, a.original_sys_document_ref, a.change_sequence;


BEGIN

  --GSCC Not initializing while declaration
    l_creation_date_from                   := fnd_date.canonical_to_date(p_creation_date_from);
    l_creation_date_to                     := fnd_date.canonical_to_date(p_creation_date_to);
    l_execution_date_from                  := fnd_date.canonical_to_date(p_execution_date_from);
    l_execution_date_to                    := fnd_date.canonical_to_date(p_execution_date_to);
     l_message_text                        := '';

  fnd_file.put_line(FND_FILE.OUTPUT,'Parameters :');
  fnd_file.put_line(FND_FILE.OUTPUT,'Request id  :'||p_retrobill_request_id);
  fnd_file.put_line(FND_FILE.OUTPUT,'Creation Date From:'||p_creation_date_from);
  fnd_file.put_line(FND_FILE.OUTPUT,'Creation Date To  :'||p_creation_date_to);
  fnd_file.put_line(FND_FILE.OUTPUT,'Execution Date From:'||p_execution_date_from);
  fnd_file.put_line(FND_FILE.OUTPUT,'Execution Date To  :'||p_execution_date_to);
  fnd_file.put_line(FND_FILE.OUTPUT,'Purge Preview Orders:'||p_purge_preview_orders);
  fnd_file.put_line(FND_FILE.OUTPUT,'Operating Unit Id:'||p_org_id);
  fnd_file.put_line(FND_FILE.OUTPUT,'');

   FND_PROFILE.Get('CONC_REQUEST_ID', l_concurrent_id);

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Entering Oe_Retrobill_Pvt.Oe_Retrobill_Purge',1);
      oe_debug_pub.add(  'CONCURRENT REQUEST ID: '|| TO_CHAR ( L_CONCURRENT_ID ) ) ;
   END IF;

   --rt moac start
   mo_global.init('ONT');
   IF p_org_id IS NOT NULL THEN
      l_org_id := to_number(p_org_id);
      MO_GLOBAL.Set_Policy_Context('S',l_org_id);
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add('Setting the context for org_id : '|| l_org_id);
      END IF;
   ELSE
      MO_GLOBAL.Set_Policy_Context('M',null);
   END IF;
   --rt moac end

 IF(p_retrobill_request_id is NULL) THEN
         l_old_org_id := -99; --rt moac
         FOR l_retrobill_request_rec IN retrobill_request LOOP
           oe_debug_pub.add('Retrobill Request Id:'||l_retrobill_request_rec.retrobill_request_id);
	   --rt moac start
	     IF p_org_id IS NULL THEN
		IF l_retrobill_request_rec.org_id <> l_old_org_id THEN
		   MO_GLOBAL.Set_Policy_Context('S',l_retrobill_request_rec.org_id);
		   IF l_debug_level > 0 THEN
		      oe_debug_pub.add('Setting the context for org_id : '|| l_retrobill_request_rec.org_id);
		      oe_debug_pub.add('mo_global.get_current_org_id : '|| mo_global.get_current_org_id);
		   END IF;
		   l_old_org_id := l_retrobill_request_rec.org_id;
		END IF;
	     END IF;

	     --setting a dummy message context so that the messages not attached to any particular order get the org_id corresponding to the policy context
             OE_MSG_PUB.Set_Msg_Context;
	     --rt moac end

	   --bug4752386 If the execution mode is 'EXECUTE', need to log a message and continue with the next request
           IF l_retrobill_request_rec.execution_mode='EXECUTE' THEN
	      oe_debug_pub.add('Cannot purge request as it has been executed'||l_retrobill_request_rec.name);
	      FND_MESSAGE.SET_NAME('ONT','ONT_RT_EXC_PURGE_NOT_ALLOWED');
	      FND_MESSAGE.SET_TOKEN('EVENT_NAME',l_retrobill_request_rec.name);
	      OE_MSG_PUB.ADD;

           ELSE


             delete_retrobill_orders(p_purge_preview_orders,to_char(l_retrobill_request_rec.retrobill_request_id),l_retrobill_request_rec.name,l_requests_processed_per_call,l_headers_processed_per_call);
             l_requests_processed := l_requests_processed + l_requests_processed_per_call;
             l_headers_processed  := l_headers_processed + l_headers_processed_per_call;
	  END IF; --execution mode = 'EXECUTE'
    END LOOP;
 ELSE
         FOR l_retrobill_request_rec IN retrobill_request_id LOOP
           oe_debug_pub.add('Retrobill Request Id:'||l_retrobill_request_rec.retrobill_request_id);

           --rt moac start
	   IF p_org_id IS NULL THEN
	      MO_GLOBAL.Set_Policy_Context('S',l_retrobill_request_rec.org_id);
	      IF l_debug_level > 0 THEN
		 oe_debug_pub.add('Setting the context for org_id : '|| l_retrobill_request_rec.org_id);
	      END IF;
	   END IF;

	   --setting a dummy message context so that the messages not attached to any particular order get the org_id corresponding to the policy context
	   OE_MSG_PUB.Set_Msg_Context;
	   --rt moac end

	   --bug4752386 If the execution mode is 'EXECUTE', need to log a message and continue with the next request
	   IF l_retrobill_request_rec.execution_mode='EXECUTE' THEN
	      oe_debug_pub.add('Cannot purge request as it has been executed'||l_retrobill_request_rec.name);
	      FND_MESSAGE.SET_NAME('ONT','ONT_RT_EXC_PURGE_NOT_ALLOWED');
	      FND_MESSAGE.SET_TOKEN('EVENT_NAME',l_retrobill_request_rec.name);
	      OE_MSG_PUB.ADD;

	   ELSE

	     delete_retrobill_orders(p_purge_preview_orders,to_char(l_retrobill_request_rec.retrobill_request_id),l_retrobill_request_rec.name,l_requests_processed_per_call,l_headers_processed_per_call);
             l_requests_processed := l_requests_processed + l_requests_processed_per_call;
             l_headers_processed  := l_headers_processed + l_headers_processed_per_call;
	  END IF; --execution mode = 'EXECUTE'
         END LOOP;
 END IF;
   /* Save messages to Process Messages Table */
   OE_MSG_PUB.save_messages(l_concurrent_id);

   /*Displaying messages from Processing Message table*/
    fnd_file.put_line(FND_FILE.OUTPUT,'Source/Order/Seq/Line    Message');
      OPEN l_msg_cursor;
      LOOP
        FETCH l_msg_cursor
         INTO l_order_source_id
            , l_orig_sys_document_ref
            , l_change_sequence
            , l_orig_sys_line_ref
            , l_message_text;
         EXIT WHEN l_msg_cursor%NOTFOUND;

         fnd_file.put_line(FND_FILE.OUTPUT,to_char(l_order_source_id)
                                            ||'/'||l_orig_sys_document_ref
                                            ||'/'||l_change_sequence
                                            ||'/'||l_orig_sys_line_ref
                                            ||' '||l_message_text);
         fnd_file.put_line(FND_FILE.OUTPUT,'');
      END LOOP;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Number of Requests Purged:' ||l_requests_processed);
      oe_debug_pub.add('Number of Orders Purged:'   ||l_headers_processed);
   END IF;

   fnd_file.put_line(FND_FILE.OUTPUT,'Number of Requests Purged:' ||l_requests_processed);
   fnd_file.put_line(FND_FILE.OUTPUT,'Number of Orders Purged:'   ||l_headers_processed);
   oe_debug_pub.add('Exiting Oe_Retrobill_pvt.Oe_retrobill_Purge');
   commit;

EXCEPTION
   WHEN OTHERS THEN
     ROLLBACK;
     retcode := -1;
     oe_debug_pub.add('Error in Procedure Oe_Retrobill_Purge'||sqlerrm);
     Raise;
END  Oe_Retrobill_Purge;
--retro}
-- 3661895 Added the following procedure
/*******************************************************************************************
This function returns the sum of adjusted amount of bill only retrobill lines created before
return retrobilled line for the corresponding list line id
*******************************************************************************************/
FUNCTION Get_Retrobill_Credited_Adj
(
 p_price_adjustment_id IN NUMBER
) RETURN NUMBER
AS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

l_list_line_id NUMBER;
l_sum_credied_amount NUMBER := 0;
l_adjusted_amount    NUMBER := 0;

BEGIN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING FUNCTION Get_Retrobill_Credited_Adj',1);
      oe_debug_pub.add('G_Retro_Bill_Only_Line_Tbl count:'||G_Retro_Bill_Only_Line_Tbl.count);
   END IF;

   IF(p_price_adjustment_id is NOT NULL) THEN
    select list_line_id into l_list_line_id
    from oe_price_adjustments
    where price_adjustment_id = p_price_adjustment_id;
   END IF;

   IF (l_list_line_id is NOT NULL) THEN
    -- Looping through the retrobill only lines and totalling the adjustments for the given list line id of Return retrobilled line

    FOR I IN G_Retro_Bill_Only_Line_Tbl.first.. G_Retro_Bill_Only_Line_Tbl.last LOOP
        BEGIN
            SELECT adjusted_amount into l_adjusted_amount from oe_price_adjustments where
            header_id = G_Retro_Bill_Only_Line_Tbl(i).header_id and
            line_id   = G_Retro_Bill_Only_Line_Tbl(i).line_id   and
	    list_line_id = l_list_line_id and
            applied_flag = 'Y' and
            retrobill_request_id is NULL;

            l_sum_credied_amount := l_sum_credied_amount + nvl(l_adjusted_amount,0);

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
        WHEN OTHERS THEN
             oe_debug_pub.add('Exception occured:'||SQLERRM);
             RAISE;
        END;
     END LOOP;
   END IF;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('l_sum_credied_amount:'||l_sum_credied_amount||'for list line id:'||l_list_line_id);
   END IF;
   RETURN nvl(l_sum_credied_amount,0);

EXCEPTION
WHEN NO_DATA_FOUND THEN
     NULL;
WHEN OTHERS THEN
     oe_debug_pub.add('Exception occured:'||SQLERRM);
     RAISE;
END Get_Retrobill_Credited_Adj;

-- 3661895
/********************************************************************************************************************************
 This procedure is called from OEXPINVB.pls while invoice interfacing the Return Retrobilled RMA.For interfacing the RMA against the
 original line we query return lines adjustments and deduct the credited amount of the Retrobill Only lines. For interfacing the RMA
 against Retrobill Bill only lines we query adjustments of Retrobill bill only Lines
*********************************************************************************************************************************/
PROCEDURE Get_Line_Adjustments
 (
  p_line_rec         IN  OE_Order_Pub.Line_Rec_Type
 ,x_line_adjustments OUT NOCOPY OE_Header_Adj_Util.Line_Adjustments_Tab_Type
 )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_adjustments_tbl OE_Header_Adj_Util.Line_Adjustments_Tab_Type;
l_adj_rec         OE_Header_Adj_Util.Line_Adjustments_Rec_Type;
l_header_id       NUMBER;
l_line_id         NUMBER;

BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_HEADER_ADJ_UTIL.GET_LINE_ADJUSTMENTS' , 1 ) ;
    END IF;

    IF(p_line_rec.retrobill_request_id = 0) THEN
       l_header_id := p_line_rec.header_id;
       l_line_id   := p_line_rec.line_id;
    ELSE
       l_header_id := p_line_rec.orig_sys_document_ref;
       l_line_id   := p_line_rec.orig_sys_line_ref;
    END IF;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('HEADER ID:'||l_header_id);
       oe_debug_pub.add('LINE ID:'||l_line_id);
    END IF;

    OE_Header_Adj_Util.Get_Line_Adjustments
                       (p_header_id         =>   l_header_id
                       ,p_line_id           =>   l_line_id
                       ,x_line_adjustments  =>   l_adjustments_tbl);

    oe_debug_pub.add(  ' p_line_rec.retrobill_request_id = '||p_line_rec.retrobill_request_id , 1 ) ;
    oe_debug_pub.add(  ' l_adjustments_tbl.count = '|| l_adjustments_tbl.count , 1 ) ;

    IF (p_line_rec.retrobill_request_id = 0) THEN

        if l_adjustments_tbl.count > 0 then -- bug# 8435020 :  add if condition
            FOR I IN l_adjustments_tbl.first..l_adjustments_tbl.last LOOP
                 l_adj_rec := l_adjustments_tbl(i);
                 l_adj_rec.unit_discount_amount := l_adj_rec.unit_discount_amount + nvl(Get_Retrobill_Credited_Adj(l_adj_rec.price_adjustment_id),0);
                 x_line_adjustments(i).price_adjustment_id  := l_adj_rec.price_adjustment_id;
                 x_line_adjustments(i).adjustment_name      := l_adj_rec.adjustment_name;
                 x_line_adjustments(i).list_line_no         := l_adj_rec.list_line_no;
                 x_line_adjustments(i).adjustment_type_code := l_adj_rec.adjustment_type_code;
                 x_line_adjustments(i).operand              := l_adj_rec.operand;
                 x_line_adjustments(i).arithmetic_operator  := l_adj_rec.arithmetic_operator;
                 x_line_adjustments(i).unit_discount_amount := l_adj_rec.unit_discount_amount;
            END LOOP;
        end if;

    ELSE

        if l_adjustments_tbl.count > 0 then -- bug# 8435020 :  add if condition
          FOR I IN l_adjustments_tbl.first..l_adjustments_tbl.last LOOP
              l_adj_rec := l_adjustments_tbl(i);
              x_line_adjustments(i).price_adjustment_id  := l_adj_rec.price_adjustment_id;
              x_line_adjustments(i).adjustment_name      := l_adj_rec.adjustment_name;
              x_line_adjustments(i).list_line_no         := l_adj_rec.list_line_no;
              x_line_adjustments(i).adjustment_type_code := l_adj_rec.adjustment_type_code;
              x_line_adjustments(i).operand              := l_adj_rec.operand;
              x_line_adjustments(i).arithmetic_operator  := l_adj_rec.arithmetic_operator;
              x_line_adjustments(i).unit_discount_amount := l_adj_rec.unit_discount_amount;
          END LOOP;
        end if;

   END IF;

  IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_HEADER_ADJ_UTIL.GET_LINE_ADJUSTMENTS' , 1 ) ;
  END IF;

END Get_Line_Adjustments;

End OE_RETROBILL_PVT;

/
