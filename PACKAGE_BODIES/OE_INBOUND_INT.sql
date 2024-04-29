--------------------------------------------------------
--  DDL for Package Body OE_INBOUND_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_INBOUND_INT" AS
/* $Header: OEXOEINB.pls 120.3.12010000.23 2009/12/23 00:40:58 snimmaga ship $ */


-------------------------
-- Procedure created during resolution of bug 9131751.
-------------------------
  -- Start of Bug 9131751
  PROCEDURE Add_Manual_Modifier
  (
     p_x_line_tbl     IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type,
     p_x_line_adj_tbl IN OUT NOCOPY OE_ORDER_PUB.Line_Adj_Tbl_Type,
     x_ret_stat       IN OUT NOCOPY VARCHAR2
  )
  IS

    TYPE Key_Rec_Type IS RECORD (line_index  NUMBER);
    TYPE Key_Rec_Tbl IS TABLE OF Key_Rec_Type INDEX BY BINARY_INTEGER;

    l_key_tbl Key_Rec_Tbl;
    l_adj_cnt NUMBER;

    l_list_line_id NUMBER;
    l_list_header_id NUMBER;

    l_debug_level  CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  BEGIN

    IF l_debug_level > 0 THEN
      oe_debug_pub.ADD('Entering Add_Manual_Modifier...');
    END IF;

    --
    -- Check if the profile 'ONT_AIA_MANUAL_MODIFIER' has any value,
    -- if not exit without any processing to retain old behaviour.
    --
    l_list_line_id := to_number(FND_PROFILE.VALUE('ONT_O2C_MANUAL_MODIFIER'));

    IF l_list_line_id IS NOT NULL THEN
      --
      -- If the profile is set, it will return us list_line_id,
      -- we need to derive list_header_id based on the list_line_id.
      --
      -- Process Order API expects us to send both list_line_id and
      -- list_header_id.
      --

      IF l_debug_level > 0 THEN
        oe_debug_pub.ADD('  l_list_line_id: ' || l_list_line_id);
      END IF;

      SELECT list_header_id
      INTO   l_list_header_id
      FROM   qp_list_lines
      WHERE  list_line_id = l_list_line_id;

      IF l_debug_level > 0 THEN
        oe_debug_pub.ADD('  l_list_header_id: ' || l_list_header_id);
      END IF;

    ELSE

      IF l_debug_level > 0 THEN
        oe_debug_pub.ADD('  Profile ONT_O2C_MANUAL_MODIFIER is not set...');
      END IF;

    END IF;

    -- If there is atleast one Line Record
    IF p_x_line_tbl.count() > 0 THEN

       -- If there is atleast one Adjustment Record
       IF p_x_line_adj_tbl.count() > 0 THEN

         --
         -- For each adjustment record, check the line_index, and
         -- mark that line_index as having an corresponding adjustment record.
         --
         -- Type, Amount, Value of the adjustment record does not matter,
         -- even if one adjustment is sent by caller for any line,
         -- we will not automatically add the manual modifier for that Line.
         --
         FOR i IN p_x_line_adj_tbl.first .. p_x_line_adj_tbl.last LOOP
           l_key_tbl(p_x_line_adj_tbl(i).line_index).line_index :=
                                          p_x_line_adj_tbl(i).line_index;
         END LOOP;

       END IF; -- end of p_x_line_adj_tbl.count() > 0

       --
       -- For each Line Record, check if there is a difference in the
       -- List Price and Selling Price, and if Calc Price Flag is Partial (P).
       -- For such records, if no adjustment record exists, then we will
       -- add a Manual Adjustment Record for the difference amount of
       -- List Price and Selling Price.
       --
       -- The Modifier to be added will be picked up from the
       -- Site Level Profile 'ONT_O2C_MANUAL_MODIFIER'.
       --
       -- This profile can hold only a Line Level, Amount Based,
       -- Overrideable, Manual Modifier reference.
       --
       FOR j IN p_x_line_tbl.first .. p_x_line_tbl.last LOOP

         IF l_debug_level > 0 THEN
           oe_debug_pub.ADD('  Checking line: ' || j);
         END IF;

         IF p_x_line_tbl(j).calculate_price_flag = 'P' AND
            nvl(p_x_line_tbl(j).unit_list_price, -1) <> nvl(p_x_line_tbl(j).unit_selling_price, -1) AND
            NOT l_key_tbl.EXISTS(j)
         THEN

           IF l_list_line_id IS NOT NULL THEN
              --
              -- The profile is set.  Proceed with adding a price adjustment
              -- record.
              --
              IF l_debug_level > 0 THEN
                oe_debug_pub.ADD(' Adding price adjustment record explicitly...');
              END IF;

              l_adj_cnt := p_x_line_adj_tbl.count() + 1;
              p_x_line_adj_tbl(l_adj_cnt) := OE_ORDER_PUB.G_MISS_LINE_ADJ_REC;  -- Initiate to G_MISS for defaulting to happen
              p_x_line_adj_tbl(l_adj_cnt).operation := OE_GLOBALS.G_OPR_CREATE; -- Operation is Create
              p_x_line_adj_tbl(l_adj_cnt).line_index := j;                      -- Set the line_index, to indicate to which line this modifier belongs to
              p_x_line_adj_tbl(l_adj_cnt).list_header_id := l_list_header_id;   -- Modifier Id to be applied
              p_x_line_adj_tbl(l_adj_cnt).list_line_id := l_list_line_id;       -- Modifier Id to be applied
              p_x_line_adj_tbl(l_adj_cnt).arithmetic_operator := 'AMT';         -- Modifier Application Method is Amount Based
              p_x_line_adj_tbl(l_adj_cnt).operand := p_x_line_tbl(j).unit_list_price - p_x_line_tbl(j).unit_selling_price;  -- Account for the difference amount
              p_x_line_adj_tbl(l_adj_cnt).adjusted_amount := p_x_line_tbl(j).unit_list_price - p_x_line_tbl(j).unit_selling_price;
              p_x_line_adj_tbl(l_adj_cnt).applied_flag := 'Y'; -- Set to 'Y' to indicate to OM and QP that this modifier is applied and active on the line
              p_x_line_adj_tbl(l_adj_cnt).updated_flag := 'Y'; -- Set to 'Y' to indicate that the value is updated (overridden) by caller
              p_x_line_adj_tbl(l_adj_cnt).change_reason_code := 'MANUAL';  -- This Change reason code is seeded for manual adjustments
              p_x_line_adj_tbl(l_adj_cnt).change_reason_text := 'AIA Manual Modifier'; -- Free text to provide additional information about the modifier

           ELSE
              --
              -- In case the profile is not set, this API will return
              -- an error status.
              --
              IF l_debug_level > 0 THEN
                oe_debug_pub.ADD('  Though LSP and USP differ and calc_price_flg is P, profile not set. Exiting...');
              END IF;
              x_ret_stat := Fnd_Api.G_RET_STS_ERROR;
              EXIT;

           END IF; -- check on l_list_line_id being not null

         END IF; -- end of line level check

       END LOOP; -- end of lines loop

    END IF; -- end of p_x_line_tbl.count() > 0

    IF l_debug_level > 0 THEN
      oe_debug_pub.ADD('Leaving Add_Manual_Modifier finally...');
    END IF;

  END ADD_MANUAL_MODIFIER;

  --
  -- A wrapper to Add_Manual_Modifier(...) using PL/SQL object type
  -- parameters.
  --
  PROCEDURE Add_Manual_Modifier_Obj
  (
    p_x_line_tbl_obj        IN OUT NOCOPY OE_ORDER_PUB_LINE_TBL_TYPE,
    p_x_line_adj_tbl_obj    IN OUT NOCOPY OE_ORDER_PUB_LINE_ADJ_TBL_TYP,
    p_x_ret_stat            IN OUT NOCOPY VARCHAR2
  )
  IS
    l_line_tbl        oe_order_pub.line_tbl_type;
    l_line_adj_tbl    oe_order_pub.line_adj_tbl_type;
  BEGIN

    l_line_tbl      :=  Oe_Inbound_Int.SQL_TO_PL12(p_x_line_tbl_obj);
    l_line_adj_tbl  :=  Oe_Inbound_Int.SQL_TO_PL14(p_x_line_adj_tbl_obj);

    Add_Manual_Modifier(l_line_tbl, l_line_adj_tbl, p_x_ret_stat);

    p_x_line_tbl_obj      :=  Oe_Inbound_Int.PL_TO_SQL12(l_line_tbl);
    p_x_line_adj_tbl_obj  :=  Oe_Inbound_Int.PL_TO_SQL14(l_line_adj_tbl);

  EXCEPTION
    WHEN Others THEN
      p_x_ret_stat := Fnd_Api.G_RET_STS_UNEXP_ERROR;

      IF OE_MSG_PUB.Check_Msg_Level(Oe_Msg_Pub.G_Msg_Lvl_Unexp_Error)
      THEN
              OE_MSG_PUB.Add_Exc_Msg
              (
                'OE_INBOUND_INT',
                'Add_Manual_Modifier_Obj'
              );
      END IF;
  END;

  -- End of bug 9131751
-------------------------

-------------------------
	FUNCTION PL_TO_SQL1(aPlsqlItem OE_ORDER_PUB.HEADER_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_REC_TYPE IS
	aSqlItem OE_ORDER_PUB_HEADER_REC_TYPE;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_REC_TYPE(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.ACCOUNTING_RULE_ID := aPlsqlItem.ACCOUNTING_RULE_ID;
		aSqlItem.AGREEMENT_ID := aPlsqlItem.AGREEMENT_ID;
		aSqlItem.ATTRIBUTE1 := aPlsqlItem.ATTRIBUTE1;
		aSqlItem.ATTRIBUTE10 := aPlsqlItem.ATTRIBUTE10;
		aSqlItem.ATTRIBUTE11 := aPlsqlItem.ATTRIBUTE11;
		aSqlItem.ATTRIBUTE12 := aPlsqlItem.ATTRIBUTE12;
		aSqlItem.ATTRIBUTE13 := aPlsqlItem.ATTRIBUTE13;
		aSqlItem.ATTRIBUTE14 := aPlsqlItem.ATTRIBUTE14;
		aSqlItem.ATTRIBUTE15 := aPlsqlItem.ATTRIBUTE15;
		aSqlItem.ATTRIBUTE16 := aPlsqlItem.ATTRIBUTE16;
		aSqlItem.ATTRIBUTE17 := aPlsqlItem.ATTRIBUTE17;
		aSqlItem.ATTRIBUTE18 := aPlsqlItem.ATTRIBUTE18;
		aSqlItem.ATTRIBUTE19 := aPlsqlItem.ATTRIBUTE19;
		aSqlItem.ATTRIBUTE2 := aPlsqlItem.ATTRIBUTE2;
		aSqlItem.ATTRIBUTE20 := aPlsqlItem.ATTRIBUTE20;
		aSqlItem.ATTRIBUTE3 := aPlsqlItem.ATTRIBUTE3;
		aSqlItem.ATTRIBUTE4 := aPlsqlItem.ATTRIBUTE4;
		aSqlItem.ATTRIBUTE5 := aPlsqlItem.ATTRIBUTE5;
		aSqlItem.ATTRIBUTE6 := aPlsqlItem.ATTRIBUTE6;
		aSqlItem.ATTRIBUTE7 := aPlsqlItem.ATTRIBUTE7;
		aSqlItem.ATTRIBUTE8 := aPlsqlItem.ATTRIBUTE8;
		aSqlItem.ATTRIBUTE9 := aPlsqlItem.ATTRIBUTE9;
		aSqlItem.BOOKED_FLAG := aPlsqlItem.BOOKED_FLAG;
		aSqlItem.CANCELLED_FLAG := aPlsqlItem.CANCELLED_FLAG;
		aSqlItem.CONTEXT := aPlsqlItem.CONTEXT;
		aSqlItem.CONVERSION_RATE := aPlsqlItem.CONVERSION_RATE;
		aSqlItem.CONVERSION_RATE_DATE := aPlsqlItem.CONVERSION_RATE_DATE;
		aSqlItem.CONVERSION_TYPE_CODE := aPlsqlItem.CONVERSION_TYPE_CODE;
		aSqlItem.CUSTOMER_PREFERENCE_SET_CODE := aPlsqlItem.CUSTOMER_PREFERENCE_SET_CODE;
		aSqlItem.CREATED_BY := aPlsqlItem.CREATED_BY;
		aSqlItem.CREATION_DATE := aPlsqlItem.CREATION_DATE;
		aSqlItem.CUST_PO_NUMBER := aPlsqlItem.CUST_PO_NUMBER;
		aSqlItem.DELIVER_TO_CONTACT_ID := aPlsqlItem.DELIVER_TO_CONTACT_ID;
		aSqlItem.DELIVER_TO_ORG_ID := aPlsqlItem.DELIVER_TO_ORG_ID;
		aSqlItem.DEMAND_CLASS_CODE := aPlsqlItem.DEMAND_CLASS_CODE;
		aSqlItem.EARLIEST_SCHEDULE_LIMIT := aPlsqlItem.EARLIEST_SCHEDULE_LIMIT;
		aSqlItem.EXPIRATION_DATE := aPlsqlItem.EXPIRATION_DATE;
		aSqlItem.FOB_POINT_CODE := aPlsqlItem.FOB_POINT_CODE;
		aSqlItem.FREIGHT_CARRIER_CODE := aPlsqlItem.FREIGHT_CARRIER_CODE;
		aSqlItem.FREIGHT_TERMS_CODE := aPlsqlItem.FREIGHT_TERMS_CODE;
		aSqlItem.GLOBAL_ATTRIBUTE1 := aPlsqlItem.GLOBAL_ATTRIBUTE1;
		aSqlItem.GLOBAL_ATTRIBUTE10 := aPlsqlItem.GLOBAL_ATTRIBUTE10;
		aSqlItem.GLOBAL_ATTRIBUTE11 := aPlsqlItem.GLOBAL_ATTRIBUTE11;
		aSqlItem.GLOBAL_ATTRIBUTE12 := aPlsqlItem.GLOBAL_ATTRIBUTE12;
		aSqlItem.GLOBAL_ATTRIBUTE13 := aPlsqlItem.GLOBAL_ATTRIBUTE13;
		aSqlItem.GLOBAL_ATTRIBUTE14 := aPlsqlItem.GLOBAL_ATTRIBUTE14;
		aSqlItem.GLOBAL_ATTRIBUTE15 := aPlsqlItem.GLOBAL_ATTRIBUTE15;
		aSqlItem.GLOBAL_ATTRIBUTE16 := aPlsqlItem.GLOBAL_ATTRIBUTE16;
		aSqlItem.GLOBAL_ATTRIBUTE17 := aPlsqlItem.GLOBAL_ATTRIBUTE17;
		aSqlItem.GLOBAL_ATTRIBUTE18 := aPlsqlItem.GLOBAL_ATTRIBUTE18;
		aSqlItem.GLOBAL_ATTRIBUTE19 := aPlsqlItem.GLOBAL_ATTRIBUTE19;
		aSqlItem.GLOBAL_ATTRIBUTE2 := aPlsqlItem.GLOBAL_ATTRIBUTE2;
		aSqlItem.GLOBAL_ATTRIBUTE20 := aPlsqlItem.GLOBAL_ATTRIBUTE20;
		aSqlItem.GLOBAL_ATTRIBUTE3 := aPlsqlItem.GLOBAL_ATTRIBUTE3;
		aSqlItem.GLOBAL_ATTRIBUTE4 := aPlsqlItem.GLOBAL_ATTRIBUTE4;
		aSqlItem.GLOBAL_ATTRIBUTE5 := aPlsqlItem.GLOBAL_ATTRIBUTE5;
		aSqlItem.GLOBAL_ATTRIBUTE6 := aPlsqlItem.GLOBAL_ATTRIBUTE6;
		aSqlItem.GLOBAL_ATTRIBUTE7 := aPlsqlItem.GLOBAL_ATTRIBUTE7;
		aSqlItem.GLOBAL_ATTRIBUTE8 := aPlsqlItem.GLOBAL_ATTRIBUTE8;
		aSqlItem.GLOBAL_ATTRIBUTE9 := aPlsqlItem.GLOBAL_ATTRIBUTE9;
		aSqlItem.GLOBAL_ATTRIBUTE_CATEGORY := aPlsqlItem.GLOBAL_ATTRIBUTE_CATEGORY;
		aSqlItem.TP_CONTEXT := aPlsqlItem.TP_CONTEXT;
		aSqlItem.TP_ATTRIBUTE1 := aPlsqlItem.TP_ATTRIBUTE1;
		aSqlItem.TP_ATTRIBUTE2 := aPlsqlItem.TP_ATTRIBUTE2;
		aSqlItem.TP_ATTRIBUTE3 := aPlsqlItem.TP_ATTRIBUTE3;
		aSqlItem.TP_ATTRIBUTE4 := aPlsqlItem.TP_ATTRIBUTE4;
		aSqlItem.TP_ATTRIBUTE5 := aPlsqlItem.TP_ATTRIBUTE5;
		aSqlItem.TP_ATTRIBUTE6 := aPlsqlItem.TP_ATTRIBUTE6;
		aSqlItem.TP_ATTRIBUTE7 := aPlsqlItem.TP_ATTRIBUTE7;
		aSqlItem.TP_ATTRIBUTE8 := aPlsqlItem.TP_ATTRIBUTE8;
		aSqlItem.TP_ATTRIBUTE9 := aPlsqlItem.TP_ATTRIBUTE9;
		aSqlItem.TP_ATTRIBUTE10 := aPlsqlItem.TP_ATTRIBUTE10;
		aSqlItem.TP_ATTRIBUTE11 := aPlsqlItem.TP_ATTRIBUTE11;
		aSqlItem.TP_ATTRIBUTE12 := aPlsqlItem.TP_ATTRIBUTE12;
		aSqlItem.TP_ATTRIBUTE13 := aPlsqlItem.TP_ATTRIBUTE13;
		aSqlItem.TP_ATTRIBUTE14 := aPlsqlItem.TP_ATTRIBUTE14;
		aSqlItem.TP_ATTRIBUTE15 := aPlsqlItem.TP_ATTRIBUTE15;
		aSqlItem.HEADER_ID := aPlsqlItem.HEADER_ID;
		aSqlItem.INVOICE_TO_CONTACT_ID := aPlsqlItem.INVOICE_TO_CONTACT_ID;
		aSqlItem.INVOICE_TO_ORG_ID := aPlsqlItem.INVOICE_TO_ORG_ID;
		aSqlItem.INVOICING_RULE_ID := aPlsqlItem.INVOICING_RULE_ID;
		aSqlItem.LAST_UPDATED_BY := aPlsqlItem.LAST_UPDATED_BY;
		aSqlItem.LAST_UPDATE_DATE := aPlsqlItem.LAST_UPDATE_DATE;
		aSqlItem.LAST_UPDATE_LOGIN := aPlsqlItem.LAST_UPDATE_LOGIN;
		aSqlItem.LATEST_SCHEDULE_LIMIT := aPlsqlItem.LATEST_SCHEDULE_LIMIT;
		aSqlItem.OPEN_FLAG := aPlsqlItem.OPEN_FLAG;
		aSqlItem.ORDER_CATEGORY_CODE := aPlsqlItem.ORDER_CATEGORY_CODE;
		aSqlItem.ORDERED_DATE := aPlsqlItem.ORDERED_DATE;
		aSqlItem.ORDER_DATE_TYPE_CODE := aPlsqlItem.ORDER_DATE_TYPE_CODE;
		aSqlItem.ORDER_NUMBER := aPlsqlItem.ORDER_NUMBER;
		aSqlItem.ORDER_SOURCE_ID := aPlsqlItem.ORDER_SOURCE_ID;
		aSqlItem.ORDER_TYPE_ID := aPlsqlItem.ORDER_TYPE_ID;
		aSqlItem.ORG_ID := aPlsqlItem.ORG_ID;
		aSqlItem.ORIG_SYS_DOCUMENT_REF := aPlsqlItem.ORIG_SYS_DOCUMENT_REF;
		aSqlItem.PARTIAL_SHIPMENTS_ALLOWED := aPlsqlItem.PARTIAL_SHIPMENTS_ALLOWED;
		aSqlItem.PAYMENT_TERM_ID := aPlsqlItem.PAYMENT_TERM_ID;
		aSqlItem.PRICE_LIST_ID := aPlsqlItem.PRICE_LIST_ID;
		aSqlItem.PRICE_REQUEST_CODE := aPlsqlItem.PRICE_REQUEST_CODE;
		aSqlItem.PRICING_DATE := aPlsqlItem.PRICING_DATE;
		aSqlItem.PROGRAM_APPLICATION_ID := aPlsqlItem.PROGRAM_APPLICATION_ID;
		aSqlItem.PROGRAM_ID := aPlsqlItem.PROGRAM_ID;
		aSqlItem.PROGRAM_UPDATE_DATE := aPlsqlItem.PROGRAM_UPDATE_DATE;
		aSqlItem.REQUEST_DATE := aPlsqlItem.REQUEST_DATE;
		aSqlItem.REQUEST_ID := aPlsqlItem.REQUEST_ID;
		aSqlItem.RETURN_REASON_CODE := aPlsqlItem.RETURN_REASON_CODE;
		aSqlItem.SALESREP_ID := aPlsqlItem.SALESREP_ID;
		aSqlItem.SALES_CHANNEL_CODE := aPlsqlItem.SALES_CHANNEL_CODE;
		aSqlItem.SHIPMENT_PRIORITY_CODE := aPlsqlItem.SHIPMENT_PRIORITY_CODE;
		aSqlItem.SHIPPING_METHOD_CODE := aPlsqlItem.SHIPPING_METHOD_CODE;
		aSqlItem.SHIP_FROM_ORG_ID := aPlsqlItem.SHIP_FROM_ORG_ID;
		aSqlItem.SHIP_TOLERANCE_ABOVE := aPlsqlItem.SHIP_TOLERANCE_ABOVE;
		aSqlItem.SHIP_TOLERANCE_BELOW := aPlsqlItem.SHIP_TOLERANCE_BELOW;
		aSqlItem.SHIP_TO_CONTACT_ID := aPlsqlItem.SHIP_TO_CONTACT_ID;
		aSqlItem.SHIP_TO_ORG_ID := aPlsqlItem.SHIP_TO_ORG_ID;
		aSqlItem.SOLD_FROM_ORG_ID := aPlsqlItem.SOLD_FROM_ORG_ID;
		aSqlItem.SOLD_TO_CONTACT_ID := aPlsqlItem.SOLD_TO_CONTACT_ID;
		aSqlItem.SOLD_TO_ORG_ID := aPlsqlItem.SOLD_TO_ORG_ID;
		aSqlItem.SOLD_TO_PHONE_ID := aPlsqlItem.SOLD_TO_PHONE_ID;
		aSqlItem.SOURCE_DOCUMENT_ID := aPlsqlItem.SOURCE_DOCUMENT_ID;
		aSqlItem.SOURCE_DOCUMENT_TYPE_ID := aPlsqlItem.SOURCE_DOCUMENT_TYPE_ID;
		aSqlItem.TAX_EXEMPT_FLAG := aPlsqlItem.TAX_EXEMPT_FLAG;
		aSqlItem.TAX_EXEMPT_NUMBER := aPlsqlItem.TAX_EXEMPT_NUMBER;
		aSqlItem.TAX_EXEMPT_REASON_CODE := aPlsqlItem.TAX_EXEMPT_REASON_CODE;
		aSqlItem.TAX_POINT_CODE := aPlsqlItem.TAX_POINT_CODE;
		aSqlItem.TRANSACTIONAL_CURR_CODE := aPlsqlItem.TRANSACTIONAL_CURR_CODE;
		aSqlItem.VERSION_NUMBER := aPlsqlItem.VERSION_NUMBER;
		aSqlItem.RETURN_STATUS := aPlsqlItem.RETURN_STATUS;
		aSqlItem.DB_FLAG := aPlsqlItem.DB_FLAG;
		aSqlItem.OPERATION := aPlsqlItem.OPERATION;
		aSqlItem.FIRST_ACK_CODE := aPlsqlItem.FIRST_ACK_CODE;
		aSqlItem.FIRST_ACK_DATE := aPlsqlItem.FIRST_ACK_DATE;
		aSqlItem.LAST_ACK_CODE := aPlsqlItem.LAST_ACK_CODE;
		aSqlItem.LAST_ACK_DATE := aPlsqlItem.LAST_ACK_DATE;
		aSqlItem.CHANGE_REASON := aPlsqlItem.CHANGE_REASON;
		aSqlItem.CHANGE_COMMENTS := aPlsqlItem.CHANGE_COMMENTS;
		aSqlItem.CHANGE_SEQUENCE := aPlsqlItem.CHANGE_SEQUENCE;
		aSqlItem.CHANGE_REQUEST_CODE := aPlsqlItem.CHANGE_REQUEST_CODE;
		aSqlItem.READY_FLAG := aPlsqlItem.READY_FLAG;
		aSqlItem.STATUS_FLAG := aPlsqlItem.STATUS_FLAG;
		aSqlItem.FORCE_APPLY_FLAG := aPlsqlItem.FORCE_APPLY_FLAG;
		aSqlItem.DROP_SHIP_FLAG := aPlsqlItem.DROP_SHIP_FLAG;
		aSqlItem.CUSTOMER_PAYMENT_TERM_ID := aPlsqlItem.CUSTOMER_PAYMENT_TERM_ID;
		aSqlItem.PAYMENT_TYPE_CODE := aPlsqlItem.PAYMENT_TYPE_CODE;
		aSqlItem.PAYMENT_AMOUNT := aPlsqlItem.PAYMENT_AMOUNT;
		aSqlItem.CHECK_NUMBER := aPlsqlItem.CHECK_NUMBER;
		aSqlItem.CREDIT_CARD_CODE := aPlsqlItem.CREDIT_CARD_CODE;
		aSqlItem.CREDIT_CARD_HOLDER_NAME := aPlsqlItem.CREDIT_CARD_HOLDER_NAME;
		aSqlItem.CREDIT_CARD_NUMBER := aPlsqlItem.CREDIT_CARD_NUMBER;
		aSqlItem.CREDIT_CARD_EXPIRATION_DATE := aPlsqlItem.CREDIT_CARD_EXPIRATION_DATE;
		aSqlItem.CREDIT_CARD_APPROVAL_CODE := aPlsqlItem.CREDIT_CARD_APPROVAL_CODE;
		aSqlItem.CREDIT_CARD_APPROVAL_DATE := aPlsqlItem.CREDIT_CARD_APPROVAL_DATE;
		aSqlItem.SHIPPING_INSTRUCTIONS := aPlsqlItem.SHIPPING_INSTRUCTIONS;
		aSqlItem.PACKING_INSTRUCTIONS := aPlsqlItem.PACKING_INSTRUCTIONS;
		aSqlItem.FLOW_STATUS_CODE := aPlsqlItem.FLOW_STATUS_CODE;
		aSqlItem.BOOKED_DATE := aPlsqlItem.BOOKED_DATE;
		aSqlItem.MARKETING_SOURCE_CODE_ID := aPlsqlItem.MARKETING_SOURCE_CODE_ID;
		aSqlItem.UPGRADED_FLAG := aPlsqlItem.UPGRADED_FLAG;
		aSqlItem.LOCK_CONTROL := aPlsqlItem.LOCK_CONTROL;
		aSqlItem.SHIP_TO_EDI_LOCATION_CODE := aPlsqlItem.SHIP_TO_EDI_LOCATION_CODE;
		aSqlItem.SOLD_TO_EDI_LOCATION_CODE := aPlsqlItem.SOLD_TO_EDI_LOCATION_CODE;
		aSqlItem.BILL_TO_EDI_LOCATION_CODE := aPlsqlItem.BILL_TO_EDI_LOCATION_CODE;
		aSqlItem.SHIP_FROM_EDI_LOCATION_CODE := aPlsqlItem.SHIP_FROM_EDI_LOCATION_CODE;
		aSqlItem.SHIP_FROM_ADDRESS_ID := aPlsqlItem.SHIP_FROM_ADDRESS_ID;
		aSqlItem.SOLD_TO_ADDRESS_ID := aPlsqlItem.SOLD_TO_ADDRESS_ID;
		aSqlItem.SHIP_TO_ADDRESS_ID := aPlsqlItem.SHIP_TO_ADDRESS_ID;
		aSqlItem.INVOICE_ADDRESS_ID := aPlsqlItem.INVOICE_ADDRESS_ID;
		aSqlItem.SHIP_TO_ADDRESS_CODE := aPlsqlItem.SHIP_TO_ADDRESS_CODE;
		aSqlItem.XML_MESSAGE_ID := aPlsqlItem.XML_MESSAGE_ID;
		aSqlItem.SHIP_TO_CUSTOMER_ID := aPlsqlItem.SHIP_TO_CUSTOMER_ID;
		aSqlItem.INVOICE_TO_CUSTOMER_ID := aPlsqlItem.INVOICE_TO_CUSTOMER_ID;
		aSqlItem.DELIVER_TO_CUSTOMER_ID := aPlsqlItem.DELIVER_TO_CUSTOMER_ID;
		aSqlItem.ACCOUNTING_RULE_DURATION := aPlsqlItem.ACCOUNTING_RULE_DURATION;
		aSqlItem.XML_TRANSACTION_TYPE_CODE := aPlsqlItem.XML_TRANSACTION_TYPE_CODE;
		aSqlItem.BLANKET_NUMBER := aPlsqlItem.BLANKET_NUMBER;
		aSqlItem.LINE_SET_NAME := aPlsqlItem.LINE_SET_NAME;
		aSqlItem.FULFILLMENT_SET_NAME := aPlsqlItem.FULFILLMENT_SET_NAME;
		aSqlItem.DEFAULT_FULFILLMENT_SET := aPlsqlItem.DEFAULT_FULFILLMENT_SET;
		aSqlItem.QUOTE_DATE := aPlsqlItem.QUOTE_DATE;
		aSqlItem.QUOTE_NUMBER := aPlsqlItem.QUOTE_NUMBER;
		aSqlItem.SALES_DOCUMENT_NAME := aPlsqlItem.SALES_DOCUMENT_NAME;
		aSqlItem.TRANSACTION_PHASE_CODE := aPlsqlItem.TRANSACTION_PHASE_CODE;
		aSqlItem.USER_STATUS_CODE := aPlsqlItem.USER_STATUS_CODE;
		aSqlItem.DRAFT_SUBMITTED_FLAG := aPlsqlItem.DRAFT_SUBMITTED_FLAG;
		aSqlItem.SOURCE_DOCUMENT_VERSION_NUMBER := aPlsqlItem.SOURCE_DOCUMENT_VERSION_NUMBER;
		aSqlItem.SOLD_TO_SITE_USE_ID := aPlsqlItem.SOLD_TO_SITE_USE_ID;
		aSqlItem.MINISITE_ID := aPlsqlItem.MINISITE_ID;
		aSqlItem.IB_OWNER := aPlsqlItem.IB_OWNER;
		aSqlItem.IB_INSTALLED_AT_LOCATION := aPlsqlItem.IB_INSTALLED_AT_LOCATION;
		aSqlItem.IB_CURRENT_LOCATION := aPlsqlItem.IB_CURRENT_LOCATION;
		aSqlItem.END_CUSTOMER_ID := aPlsqlItem.END_CUSTOMER_ID;
		aSqlItem.END_CUSTOMER_CONTACT_ID := aPlsqlItem.END_CUSTOMER_CONTACT_ID;
		aSqlItem.END_CUSTOMER_SITE_USE_ID := aPlsqlItem.END_CUSTOMER_SITE_USE_ID;
		aSqlItem.SUPPLIER_SIGNATURE := aPlsqlItem.SUPPLIER_SIGNATURE;
		aSqlItem.SUPPLIER_SIGNATURE_DATE := aPlsqlItem.SUPPLIER_SIGNATURE_DATE;
		aSqlItem.CUSTOMER_SIGNATURE := aPlsqlItem.CUSTOMER_SIGNATURE;
		aSqlItem.CUSTOMER_SIGNATURE_DATE := aPlsqlItem.CUSTOMER_SIGNATURE_DATE;
		aSqlItem.SOLD_TO_PARTY_ID := aPlsqlItem.SOLD_TO_PARTY_ID;
		aSqlItem.SOLD_TO_ORG_CONTACT_ID := aPlsqlItem.SOLD_TO_ORG_CONTACT_ID;
		aSqlItem.SHIP_TO_PARTY_ID := aPlsqlItem.SHIP_TO_PARTY_ID;
		aSqlItem.SHIP_TO_PARTY_SITE_ID := aPlsqlItem.SHIP_TO_PARTY_SITE_ID;
		aSqlItem.SHIP_TO_PARTY_SITE_USE_ID := aPlsqlItem.SHIP_TO_PARTY_SITE_USE_ID;
		aSqlItem.DELIVER_TO_PARTY_ID := aPlsqlItem.DELIVER_TO_PARTY_ID;
		aSqlItem.DELIVER_TO_PARTY_SITE_ID := aPlsqlItem.DELIVER_TO_PARTY_SITE_ID;
		aSqlItem.DELIVER_TO_PARTY_SITE_USE_ID := aPlsqlItem.DELIVER_TO_PARTY_SITE_USE_ID;
		aSqlItem.INVOICE_TO_PARTY_ID := aPlsqlItem.INVOICE_TO_PARTY_ID;
		aSqlItem.INVOICE_TO_PARTY_SITE_ID := aPlsqlItem.INVOICE_TO_PARTY_SITE_ID;
		aSqlItem.INVOICE_TO_PARTY_SITE_USE_ID := aPlsqlItem.INVOICE_TO_PARTY_SITE_USE_ID;
		aSqlItem.END_CUSTOMER_PARTY_ID := aPlsqlItem.END_CUSTOMER_PARTY_ID;
		aSqlItem.END_CUSTOMER_PARTY_SITE_ID := aPlsqlItem.END_CUSTOMER_PARTY_SITE_ID;
		aSqlItem.END_CUSTOMER_PARTY_SITE_USE_ID := aPlsqlItem.END_CUSTOMER_PARTY_SITE_USE_ID;
		aSqlItem.END_CUSTOMER_PARTY_NUMBER := aPlsqlItem.END_CUSTOMER_PARTY_NUMBER;
		aSqlItem.END_CUSTOMER_ORG_CONTACT_ID := aPlsqlItem.END_CUSTOMER_ORG_CONTACT_ID;
		aSqlItem.SHIP_TO_CUSTOMER_PARTY_ID := aPlsqlItem.SHIP_TO_CUSTOMER_PARTY_ID;
		aSqlItem.DELIVER_TO_CUSTOMER_PARTY_ID := aPlsqlItem.DELIVER_TO_CUSTOMER_PARTY_ID;
		aSqlItem.INVOICE_TO_CUSTOMER_PARTY_ID := aPlsqlItem.INVOICE_TO_CUSTOMER_PARTY_ID;
		aSqlItem.SHIP_TO_ORG_CONTACT_ID := aPlsqlItem.SHIP_TO_ORG_CONTACT_ID;
		aSqlItem.DELIVER_TO_ORG_CONTACT_ID := aPlsqlItem.DELIVER_TO_ORG_CONTACT_ID;
		aSqlItem.INVOICE_TO_ORG_CONTACT_ID := aPlsqlItem.INVOICE_TO_ORG_CONTACT_ID;
		aSqlItem.CONTRACT_TEMPLATE_ID := aPlsqlItem.CONTRACT_TEMPLATE_ID;
		aSqlItem.CONTRACT_SOURCE_DOC_TYPE_CODE := aPlsqlItem.CONTRACT_SOURCE_DOC_TYPE_CODE;
		aSqlItem.CONTRACT_SOURCE_DOCUMENT_ID := aPlsqlItem.CONTRACT_SOURCE_DOCUMENT_ID;
		aSqlItem.SOLD_TO_PARTY_NUMBER := aPlsqlItem.SOLD_TO_PARTY_NUMBER;
		aSqlItem.SHIP_TO_PARTY_NUMBER := aPlsqlItem.SHIP_TO_PARTY_NUMBER;
		aSqlItem.INVOICE_TO_PARTY_NUMBER := aPlsqlItem.INVOICE_TO_PARTY_NUMBER;
		aSqlItem.DELIVER_TO_PARTY_NUMBER := aPlsqlItem.DELIVER_TO_PARTY_NUMBER;
		aSqlItem.ORDER_FIRMED_DATE := aPlsqlItem.ORDER_FIRMED_DATE;
		RETURN aSqlItem;
	END PL_TO_SQL1;

	FUNCTION SQL_TO_PL1(aSqlItem OE_ORDER_PUB_HEADER_REC_TYPE)
	RETURN OE_ORDER_PUB.HEADER_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_REC_TYPE;
	BEGIN
		aPlsqlItem.ACCOUNTING_RULE_ID := aSqlItem.ACCOUNTING_RULE_ID;
		aPlsqlItem.AGREEMENT_ID := aSqlItem.AGREEMENT_ID;
		aPlsqlItem.ATTRIBUTE1 := aSqlItem.ATTRIBUTE1;
		aPlsqlItem.ATTRIBUTE10 := aSqlItem.ATTRIBUTE10;
		aPlsqlItem.ATTRIBUTE11 := aSqlItem.ATTRIBUTE11;
		aPlsqlItem.ATTRIBUTE12 := aSqlItem.ATTRIBUTE12;
		aPlsqlItem.ATTRIBUTE13 := aSqlItem.ATTRIBUTE13;
		aPlsqlItem.ATTRIBUTE14 := aSqlItem.ATTRIBUTE14;
		aPlsqlItem.ATTRIBUTE15 := aSqlItem.ATTRIBUTE15;
		aPlsqlItem.ATTRIBUTE16 := aSqlItem.ATTRIBUTE16;
		aPlsqlItem.ATTRIBUTE17 := aSqlItem.ATTRIBUTE17;
		aPlsqlItem.ATTRIBUTE18 := aSqlItem.ATTRIBUTE18;
		aPlsqlItem.ATTRIBUTE19 := aSqlItem.ATTRIBUTE19;
		aPlsqlItem.ATTRIBUTE2 := aSqlItem.ATTRIBUTE2;
		aPlsqlItem.ATTRIBUTE20 := aSqlItem.ATTRIBUTE20;
		aPlsqlItem.ATTRIBUTE3 := aSqlItem.ATTRIBUTE3;
		aPlsqlItem.ATTRIBUTE4 := aSqlItem.ATTRIBUTE4;
		aPlsqlItem.ATTRIBUTE5 := aSqlItem.ATTRIBUTE5;
		aPlsqlItem.ATTRIBUTE6 := aSqlItem.ATTRIBUTE6;
		aPlsqlItem.ATTRIBUTE7 := aSqlItem.ATTRIBUTE7;
		aPlsqlItem.ATTRIBUTE8 := aSqlItem.ATTRIBUTE8;
		aPlsqlItem.ATTRIBUTE9 := aSqlItem.ATTRIBUTE9;
		--aPlsqlItem.BOOKED_FLAG := 'Y'; -- aSqlItem.BOOKED_FLAG;
		aPlsqlItem.BOOKED_FLAG := aSqlItem.BOOKED_FLAG;
		aPlsqlItem.CANCELLED_FLAG := aSqlItem.CANCELLED_FLAG;
		aPlsqlItem.CONTEXT := aSqlItem.CONTEXT;
		aPlsqlItem.CONVERSION_RATE := aSqlItem.CONVERSION_RATE;
		aPlsqlItem.CONVERSION_RATE_DATE := aSqlItem.CONVERSION_RATE_DATE;
		aPlsqlItem.CONVERSION_TYPE_CODE := aSqlItem.CONVERSION_TYPE_CODE;
		aPlsqlItem.CUSTOMER_PREFERENCE_SET_CODE := aSqlItem.CUSTOMER_PREFERENCE_SET_CODE;
		aPlsqlItem.CREATED_BY := aSqlItem.CREATED_BY;
		aPlsqlItem.CREATION_DATE := aSqlItem.CREATION_DATE;
		aPlsqlItem.CUST_PO_NUMBER := aSqlItem.CUST_PO_NUMBER;
		aPlsqlItem.DELIVER_TO_CONTACT_ID := aSqlItem.DELIVER_TO_CONTACT_ID;
		aPlsqlItem.DELIVER_TO_ORG_ID := aSqlItem.DELIVER_TO_ORG_ID;
		aPlsqlItem.DEMAND_CLASS_CODE := aSqlItem.DEMAND_CLASS_CODE;
		aPlsqlItem.EARLIEST_SCHEDULE_LIMIT := aSqlItem.EARLIEST_SCHEDULE_LIMIT;
		aPlsqlItem.EXPIRATION_DATE := aSqlItem.EXPIRATION_DATE;
		aPlsqlItem.FOB_POINT_CODE := aSqlItem.FOB_POINT_CODE;
		aPlsqlItem.FREIGHT_CARRIER_CODE := aSqlItem.FREIGHT_CARRIER_CODE;
		aPlsqlItem.FREIGHT_TERMS_CODE := aSqlItem.FREIGHT_TERMS_CODE;
		aPlsqlItem.GLOBAL_ATTRIBUTE1 := aSqlItem.GLOBAL_ATTRIBUTE1;
		aPlsqlItem.GLOBAL_ATTRIBUTE10 := aSqlItem.GLOBAL_ATTRIBUTE10;
		aPlsqlItem.GLOBAL_ATTRIBUTE11 := aSqlItem.GLOBAL_ATTRIBUTE11;
		aPlsqlItem.GLOBAL_ATTRIBUTE12 := aSqlItem.GLOBAL_ATTRIBUTE12;
		aPlsqlItem.GLOBAL_ATTRIBUTE13 := aSqlItem.GLOBAL_ATTRIBUTE13;
		aPlsqlItem.GLOBAL_ATTRIBUTE14 := aSqlItem.GLOBAL_ATTRIBUTE14;
		aPlsqlItem.GLOBAL_ATTRIBUTE15 := aSqlItem.GLOBAL_ATTRIBUTE15;
		aPlsqlItem.GLOBAL_ATTRIBUTE16 := aSqlItem.GLOBAL_ATTRIBUTE16;
		aPlsqlItem.GLOBAL_ATTRIBUTE17 := aSqlItem.GLOBAL_ATTRIBUTE17;
		aPlsqlItem.GLOBAL_ATTRIBUTE18 := aSqlItem.GLOBAL_ATTRIBUTE18;
		aPlsqlItem.GLOBAL_ATTRIBUTE19 := aSqlItem.GLOBAL_ATTRIBUTE19;
		aPlsqlItem.GLOBAL_ATTRIBUTE2 := aSqlItem.GLOBAL_ATTRIBUTE2;
		aPlsqlItem.GLOBAL_ATTRIBUTE20 := aSqlItem.GLOBAL_ATTRIBUTE20;
		aPlsqlItem.GLOBAL_ATTRIBUTE3 := aSqlItem.GLOBAL_ATTRIBUTE3;
		aPlsqlItem.GLOBAL_ATTRIBUTE4 := aSqlItem.GLOBAL_ATTRIBUTE4;
		aPlsqlItem.GLOBAL_ATTRIBUTE5 := aSqlItem.GLOBAL_ATTRIBUTE5;
		aPlsqlItem.GLOBAL_ATTRIBUTE6 := aSqlItem.GLOBAL_ATTRIBUTE6;
		aPlsqlItem.GLOBAL_ATTRIBUTE7 := aSqlItem.GLOBAL_ATTRIBUTE7;
		aPlsqlItem.GLOBAL_ATTRIBUTE8 := aSqlItem.GLOBAL_ATTRIBUTE8;
		aPlsqlItem.GLOBAL_ATTRIBUTE9 := aSqlItem.GLOBAL_ATTRIBUTE9;
		aPlsqlItem.GLOBAL_ATTRIBUTE_CATEGORY := aSqlItem.GLOBAL_ATTRIBUTE_CATEGORY;
		aPlsqlItem.TP_CONTEXT := aSqlItem.TP_CONTEXT;
		aPlsqlItem.TP_ATTRIBUTE1 := aSqlItem.TP_ATTRIBUTE1;
		aPlsqlItem.TP_ATTRIBUTE2 := aSqlItem.TP_ATTRIBUTE2;
		aPlsqlItem.TP_ATTRIBUTE3 := aSqlItem.TP_ATTRIBUTE3;
		aPlsqlItem.TP_ATTRIBUTE4 := aSqlItem.TP_ATTRIBUTE4;
		aPlsqlItem.TP_ATTRIBUTE5 := aSqlItem.TP_ATTRIBUTE5;
		aPlsqlItem.TP_ATTRIBUTE6 := aSqlItem.TP_ATTRIBUTE6;
		aPlsqlItem.TP_ATTRIBUTE7 := aSqlItem.TP_ATTRIBUTE7;
		aPlsqlItem.TP_ATTRIBUTE8 := aSqlItem.TP_ATTRIBUTE8;
		aPlsqlItem.TP_ATTRIBUTE9 := aSqlItem.TP_ATTRIBUTE9;
		aPlsqlItem.TP_ATTRIBUTE10 := aSqlItem.TP_ATTRIBUTE10;
		aPlsqlItem.TP_ATTRIBUTE11 := aSqlItem.TP_ATTRIBUTE11;
		aPlsqlItem.TP_ATTRIBUTE12 := aSqlItem.TP_ATTRIBUTE12;
		aPlsqlItem.TP_ATTRIBUTE13 := aSqlItem.TP_ATTRIBUTE13;
		aPlsqlItem.TP_ATTRIBUTE14 := aSqlItem.TP_ATTRIBUTE14;
		aPlsqlItem.TP_ATTRIBUTE15 := aSqlItem.TP_ATTRIBUTE15;
		aPlsqlItem.HEADER_ID := aSqlItem.HEADER_ID;
		aPlsqlItem.INVOICE_TO_CONTACT_ID := aSqlItem.INVOICE_TO_CONTACT_ID;
		aPlsqlItem.INVOICE_TO_ORG_ID := aSqlItem.INVOICE_TO_ORG_ID;
		aPlsqlItem.INVOICING_RULE_ID := aSqlItem.INVOICING_RULE_ID;
		aPlsqlItem.LAST_UPDATED_BY := aSqlItem.LAST_UPDATED_BY;
		aPlsqlItem.LAST_UPDATE_DATE := aSqlItem.LAST_UPDATE_DATE;
		aPlsqlItem.LAST_UPDATE_LOGIN := aSqlItem.LAST_UPDATE_LOGIN;
		aPlsqlItem.LATEST_SCHEDULE_LIMIT := aSqlItem.LATEST_SCHEDULE_LIMIT;
		aPlsqlItem.OPEN_FLAG := aSqlItem.OPEN_FLAG;
		aPlsqlItem.ORDER_CATEGORY_CODE := aSqlItem.ORDER_CATEGORY_CODE;
		aPlsqlItem.ORDERED_DATE := aSqlItem.ORDERED_DATE;
		aPlsqlItem.ORDER_DATE_TYPE_CODE := aSqlItem.ORDER_DATE_TYPE_CODE;
		aPlsqlItem.ORDER_NUMBER := aSqlItem.ORDER_NUMBER;
		aPlsqlItem.ORDER_SOURCE_ID := aSqlItem.ORDER_SOURCE_ID;
		aPlsqlItem.ORDER_TYPE_ID := aSqlItem.ORDER_TYPE_ID;
		aPlsqlItem.ORG_ID := aSqlItem.ORG_ID;
		aPlsqlItem.ORIG_SYS_DOCUMENT_REF := aSqlItem.ORIG_SYS_DOCUMENT_REF;
		aPlsqlItem.PARTIAL_SHIPMENTS_ALLOWED := aSqlItem.PARTIAL_SHIPMENTS_ALLOWED;
		aPlsqlItem.PAYMENT_TERM_ID := aSqlItem.PAYMENT_TERM_ID;
		aPlsqlItem.PRICE_LIST_ID := aSqlItem.PRICE_LIST_ID;
		aPlsqlItem.PRICE_REQUEST_CODE := aSqlItem.PRICE_REQUEST_CODE;
		aPlsqlItem.PRICING_DATE := aSqlItem.PRICING_DATE;
		aPlsqlItem.PROGRAM_APPLICATION_ID := aSqlItem.PROGRAM_APPLICATION_ID;
		aPlsqlItem.PROGRAM_ID := aSqlItem.PROGRAM_ID;
		aPlsqlItem.PROGRAM_UPDATE_DATE := aSqlItem.PROGRAM_UPDATE_DATE;
		aPlsqlItem.REQUEST_DATE := aSqlItem.REQUEST_DATE;
		aPlsqlItem.REQUEST_ID := aSqlItem.REQUEST_ID;
		aPlsqlItem.RETURN_REASON_CODE := aSqlItem.RETURN_REASON_CODE;
		aPlsqlItem.SALESREP_ID := aSqlItem.SALESREP_ID;
		aPlsqlItem.SALES_CHANNEL_CODE := aSqlItem.SALES_CHANNEL_CODE;
		aPlsqlItem.SHIPMENT_PRIORITY_CODE := aSqlItem.SHIPMENT_PRIORITY_CODE;
		aPlsqlItem.SHIPPING_METHOD_CODE := aSqlItem.SHIPPING_METHOD_CODE;
		aPlsqlItem.SHIP_FROM_ORG_ID := aSqlItem.SHIP_FROM_ORG_ID;
		aPlsqlItem.SHIP_TOLERANCE_ABOVE := aSqlItem.SHIP_TOLERANCE_ABOVE;
		aPlsqlItem.SHIP_TOLERANCE_BELOW := aSqlItem.SHIP_TOLERANCE_BELOW;
		aPlsqlItem.SHIP_TO_CONTACT_ID := aSqlItem.SHIP_TO_CONTACT_ID;
		aPlsqlItem.SHIP_TO_ORG_ID := aSqlItem.SHIP_TO_ORG_ID;
		aPlsqlItem.SOLD_FROM_ORG_ID := aSqlItem.SOLD_FROM_ORG_ID;
		aPlsqlItem.SOLD_TO_CONTACT_ID := aSqlItem.SOLD_TO_CONTACT_ID;
		aPlsqlItem.SOLD_TO_ORG_ID := aSqlItem.SOLD_TO_ORG_ID;
                --oe_debug_pub.add('Srini 102 header sold_to_org_id '||aPlsqlItem.SOLD_TO_ORG_ID);
		aPlsqlItem.SOLD_TO_PHONE_ID := aSqlItem.SOLD_TO_PHONE_ID;
		aPlsqlItem.SOURCE_DOCUMENT_ID := aSqlItem.SOURCE_DOCUMENT_ID;
		aPlsqlItem.SOURCE_DOCUMENT_TYPE_ID := aSqlItem.SOURCE_DOCUMENT_TYPE_ID;
		aPlsqlItem.TAX_EXEMPT_FLAG := aSqlItem.TAX_EXEMPT_FLAG;
		aPlsqlItem.TAX_EXEMPT_NUMBER := aSqlItem.TAX_EXEMPT_NUMBER;
		aPlsqlItem.TAX_EXEMPT_REASON_CODE := aSqlItem.TAX_EXEMPT_REASON_CODE;
		aPlsqlItem.TAX_POINT_CODE := aSqlItem.TAX_POINT_CODE;
		aPlsqlItem.TRANSACTIONAL_CURR_CODE := aSqlItem.TRANSACTIONAL_CURR_CODE;
		aPlsqlItem.VERSION_NUMBER := aSqlItem.VERSION_NUMBER;
		aPlsqlItem.RETURN_STATUS := aSqlItem.RETURN_STATUS;
		aPlsqlItem.DB_FLAG := aSqlItem.DB_FLAG;
		aPlsqlItem.OPERATION := aSqlItem.OPERATION;
		aPlsqlItem.FIRST_ACK_CODE := aSqlItem.FIRST_ACK_CODE;
		aPlsqlItem.FIRST_ACK_DATE := aSqlItem.FIRST_ACK_DATE;
		aPlsqlItem.LAST_ACK_CODE := aSqlItem.LAST_ACK_CODE;
		aPlsqlItem.LAST_ACK_DATE := aSqlItem.LAST_ACK_DATE;
		aPlsqlItem.CHANGE_REASON := aSqlItem.CHANGE_REASON;
		aPlsqlItem.CHANGE_COMMENTS := aSqlItem.CHANGE_COMMENTS;
		aPlsqlItem.CHANGE_SEQUENCE := aSqlItem.CHANGE_SEQUENCE;
		aPlsqlItem.CHANGE_REQUEST_CODE := aSqlItem.CHANGE_REQUEST_CODE;
		aPlsqlItem.READY_FLAG := aSqlItem.READY_FLAG;
		aPlsqlItem.STATUS_FLAG := aSqlItem.STATUS_FLAG;
		aPlsqlItem.FORCE_APPLY_FLAG := aSqlItem.FORCE_APPLY_FLAG;
		aPlsqlItem.DROP_SHIP_FLAG := aSqlItem.DROP_SHIP_FLAG;
		aPlsqlItem.CUSTOMER_PAYMENT_TERM_ID := aSqlItem.CUSTOMER_PAYMENT_TERM_ID;
		aPlsqlItem.PAYMENT_TYPE_CODE := aSqlItem.PAYMENT_TYPE_CODE;
		aPlsqlItem.PAYMENT_AMOUNT := aSqlItem.PAYMENT_AMOUNT;
		aPlsqlItem.CHECK_NUMBER := aSqlItem.CHECK_NUMBER;
		aPlsqlItem.CREDIT_CARD_CODE := aSqlItem.CREDIT_CARD_CODE;
		aPlsqlItem.CREDIT_CARD_HOLDER_NAME := aSqlItem.CREDIT_CARD_HOLDER_NAME;
		aPlsqlItem.CREDIT_CARD_NUMBER := aSqlItem.CREDIT_CARD_NUMBER;
		aPlsqlItem.CREDIT_CARD_EXPIRATION_DATE := aSqlItem.CREDIT_CARD_EXPIRATION_DATE;
		aPlsqlItem.CREDIT_CARD_APPROVAL_CODE := aSqlItem.CREDIT_CARD_APPROVAL_CODE;
		aPlsqlItem.CREDIT_CARD_APPROVAL_DATE := aSqlItem.CREDIT_CARD_APPROVAL_DATE;
		aPlsqlItem.SHIPPING_INSTRUCTIONS := aSqlItem.SHIPPING_INSTRUCTIONS;
		aPlsqlItem.PACKING_INSTRUCTIONS := aSqlItem.PACKING_INSTRUCTIONS;
		aPlsqlItem.FLOW_STATUS_CODE := aSqlItem.FLOW_STATUS_CODE;
		aPlsqlItem.BOOKED_DATE := aSqlItem.BOOKED_DATE;
		aPlsqlItem.MARKETING_SOURCE_CODE_ID := aSqlItem.MARKETING_SOURCE_CODE_ID;
		aPlsqlItem.UPGRADED_FLAG := aSqlItem.UPGRADED_FLAG;
		aPlsqlItem.LOCK_CONTROL := aSqlItem.LOCK_CONTROL;
		aPlsqlItem.SHIP_TO_EDI_LOCATION_CODE := aSqlItem.SHIP_TO_EDI_LOCATION_CODE;
		aPlsqlItem.SOLD_TO_EDI_LOCATION_CODE := aSqlItem.SOLD_TO_EDI_LOCATION_CODE;
		aPlsqlItem.BILL_TO_EDI_LOCATION_CODE := aSqlItem.BILL_TO_EDI_LOCATION_CODE;
		aPlsqlItem.SHIP_FROM_EDI_LOCATION_CODE := aSqlItem.SHIP_FROM_EDI_LOCATION_CODE;
		aPlsqlItem.SHIP_FROM_ADDRESS_ID := aSqlItem.SHIP_FROM_ADDRESS_ID;
		aPlsqlItem.SOLD_TO_ADDRESS_ID := aSqlItem.SOLD_TO_ADDRESS_ID;
		aPlsqlItem.SHIP_TO_ADDRESS_ID := aSqlItem.SHIP_TO_ADDRESS_ID;
		aPlsqlItem.INVOICE_ADDRESS_ID := aSqlItem.INVOICE_ADDRESS_ID;
		aPlsqlItem.SHIP_TO_ADDRESS_CODE := aSqlItem.SHIP_TO_ADDRESS_CODE;
		aPlsqlItem.XML_MESSAGE_ID := aSqlItem.XML_MESSAGE_ID;
		aPlsqlItem.SHIP_TO_CUSTOMER_ID := aSqlItem.SHIP_TO_CUSTOMER_ID;
		aPlsqlItem.INVOICE_TO_CUSTOMER_ID := aSqlItem.INVOICE_TO_CUSTOMER_ID;
		aPlsqlItem.DELIVER_TO_CUSTOMER_ID := aSqlItem.DELIVER_TO_CUSTOMER_ID;
		aPlsqlItem.ACCOUNTING_RULE_DURATION := aSqlItem.ACCOUNTING_RULE_DURATION;
		aPlsqlItem.XML_TRANSACTION_TYPE_CODE := aSqlItem.XML_TRANSACTION_TYPE_CODE;
		aPlsqlItem.BLANKET_NUMBER := aSqlItem.BLANKET_NUMBER;
		aPlsqlItem.LINE_SET_NAME := aSqlItem.LINE_SET_NAME;
		aPlsqlItem.FULFILLMENT_SET_NAME := aSqlItem.FULFILLMENT_SET_NAME;
		aPlsqlItem.DEFAULT_FULFILLMENT_SET := aSqlItem.DEFAULT_FULFILLMENT_SET;
		aPlsqlItem.QUOTE_DATE := aSqlItem.QUOTE_DATE;
		aPlsqlItem.QUOTE_NUMBER := aSqlItem.QUOTE_NUMBER;
		aPlsqlItem.SALES_DOCUMENT_NAME := aSqlItem.SALES_DOCUMENT_NAME;
		aPlsqlItem.TRANSACTION_PHASE_CODE := aSqlItem.TRANSACTION_PHASE_CODE;
		aPlsqlItem.USER_STATUS_CODE := aSqlItem.USER_STATUS_CODE;
		aPlsqlItem.DRAFT_SUBMITTED_FLAG := aSqlItem.DRAFT_SUBMITTED_FLAG;
		aPlsqlItem.SOURCE_DOCUMENT_VERSION_NUMBER := aSqlItem.SOURCE_DOCUMENT_VERSION_NUMBER;
		aPlsqlItem.SOLD_TO_SITE_USE_ID := aSqlItem.SOLD_TO_SITE_USE_ID;
		aPlsqlItem.MINISITE_ID := aSqlItem.MINISITE_ID;
		aPlsqlItem.IB_OWNER := aSqlItem.IB_OWNER;
		aPlsqlItem.IB_INSTALLED_AT_LOCATION := aSqlItem.IB_INSTALLED_AT_LOCATION;
		aPlsqlItem.IB_CURRENT_LOCATION := aSqlItem.IB_CURRENT_LOCATION;
		aPlsqlItem.END_CUSTOMER_ID := aSqlItem.END_CUSTOMER_ID;
		aPlsqlItem.END_CUSTOMER_CONTACT_ID := aSqlItem.END_CUSTOMER_CONTACT_ID;
		aPlsqlItem.END_CUSTOMER_SITE_USE_ID := aSqlItem.END_CUSTOMER_SITE_USE_ID;
		aPlsqlItem.SUPPLIER_SIGNATURE := aSqlItem.SUPPLIER_SIGNATURE;
		aPlsqlItem.SUPPLIER_SIGNATURE_DATE := aSqlItem.SUPPLIER_SIGNATURE_DATE;
		aPlsqlItem.CUSTOMER_SIGNATURE := aSqlItem.CUSTOMER_SIGNATURE;
		aPlsqlItem.CUSTOMER_SIGNATURE_DATE := aSqlItem.CUSTOMER_SIGNATURE_DATE;
		aPlsqlItem.SOLD_TO_PARTY_ID := aSqlItem.SOLD_TO_PARTY_ID;
		aPlsqlItem.SOLD_TO_ORG_CONTACT_ID := aSqlItem.SOLD_TO_ORG_CONTACT_ID;
		aPlsqlItem.SHIP_TO_PARTY_ID := aSqlItem.SHIP_TO_PARTY_ID;
		aPlsqlItem.SHIP_TO_PARTY_SITE_ID := aSqlItem.SHIP_TO_PARTY_SITE_ID;
		aPlsqlItem.SHIP_TO_PARTY_SITE_USE_ID := aSqlItem.SHIP_TO_PARTY_SITE_USE_ID;
		aPlsqlItem.DELIVER_TO_PARTY_ID := aSqlItem.DELIVER_TO_PARTY_ID;
		aPlsqlItem.DELIVER_TO_PARTY_SITE_ID := aSqlItem.DELIVER_TO_PARTY_SITE_ID;
		aPlsqlItem.DELIVER_TO_PARTY_SITE_USE_ID := aSqlItem.DELIVER_TO_PARTY_SITE_USE_ID;
		aPlsqlItem.INVOICE_TO_PARTY_ID := aSqlItem.INVOICE_TO_PARTY_ID;
		aPlsqlItem.INVOICE_TO_PARTY_SITE_ID := aSqlItem.INVOICE_TO_PARTY_SITE_ID;
		aPlsqlItem.INVOICE_TO_PARTY_SITE_USE_ID := aSqlItem.INVOICE_TO_PARTY_SITE_USE_ID;
		aPlsqlItem.END_CUSTOMER_PARTY_ID := aSqlItem.END_CUSTOMER_PARTY_ID;
		aPlsqlItem.END_CUSTOMER_PARTY_SITE_ID := aSqlItem.END_CUSTOMER_PARTY_SITE_ID;
		aPlsqlItem.END_CUSTOMER_PARTY_SITE_USE_ID := aSqlItem.END_CUSTOMER_PARTY_SITE_USE_ID;
		aPlsqlItem.END_CUSTOMER_PARTY_NUMBER := aSqlItem.END_CUSTOMER_PARTY_NUMBER;
		aPlsqlItem.END_CUSTOMER_ORG_CONTACT_ID := aSqlItem.END_CUSTOMER_ORG_CONTACT_ID;
		aPlsqlItem.SHIP_TO_CUSTOMER_PARTY_ID := aSqlItem.SHIP_TO_CUSTOMER_PARTY_ID;
		aPlsqlItem.DELIVER_TO_CUSTOMER_PARTY_ID := aSqlItem.DELIVER_TO_CUSTOMER_PARTY_ID;
		aPlsqlItem.INVOICE_TO_CUSTOMER_PARTY_ID := aSqlItem.INVOICE_TO_CUSTOMER_PARTY_ID;
		aPlsqlItem.SHIP_TO_ORG_CONTACT_ID := aSqlItem.SHIP_TO_ORG_CONTACT_ID;
		aPlsqlItem.DELIVER_TO_ORG_CONTACT_ID := aSqlItem.DELIVER_TO_ORG_CONTACT_ID;
		aPlsqlItem.INVOICE_TO_ORG_CONTACT_ID := aSqlItem.INVOICE_TO_ORG_CONTACT_ID;
		aPlsqlItem.CONTRACT_TEMPLATE_ID := aSqlItem.CONTRACT_TEMPLATE_ID;
		aPlsqlItem.CONTRACT_SOURCE_DOC_TYPE_CODE := aSqlItem.CONTRACT_SOURCE_DOC_TYPE_CODE;
		aPlsqlItem.CONTRACT_SOURCE_DOCUMENT_ID := aSqlItem.CONTRACT_SOURCE_DOCUMENT_ID;
		aPlsqlItem.SOLD_TO_PARTY_NUMBER := aSqlItem.SOLD_TO_PARTY_NUMBER;
		aPlsqlItem.SHIP_TO_PARTY_NUMBER := aSqlItem.SHIP_TO_PARTY_NUMBER;
		aPlsqlItem.INVOICE_TO_PARTY_NUMBER := aSqlItem.INVOICE_TO_PARTY_NUMBER;
		aPlsqlItem.DELIVER_TO_PARTY_NUMBER := aSqlItem.DELIVER_TO_PARTY_NUMBER;
		aPlsqlItem.ORDER_FIRMED_DATE := aSqlItem.ORDER_FIRMED_DATE;

                oe_debug_pub.add('Caliing OE_GENESIS_UTIL.Convert_hdr_null_to_miss', 1);
                OE_GENESIS_UTIL.Convert_hdr_null_to_miss(aPlsqlItem);
                -- Convert_hdr_null_to_miss(aPlsqlItem);
                --convert_hdr_null_to_miss(aPlsqlItem);
                oe_debug_pub.add('After Caliing OE_GENESIS_UTIL.Convert_hdr_null_to_miss', 1);

		RETURN aPlsqlItem;
	END SQL_TO_PL1;

	FUNCTION PL_TO_SQL2(aPlsqlItem OE_ORDER_PUB.HEADER_VAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_VAL_REC_T IS
	aSqlItem OE_ORDER_PUB_HEADER_VAL_REC_T;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_VAL_REC_T(NULL, NULL, NULL, NULL, NULL, NULL
, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
, NULL, NULL);
		aSqlItem.ACCOUNTING_RULE := aPlsqlItem.ACCOUNTING_RULE;
		aSqlItem.AGREEMENT := aPlsqlItem.AGREEMENT;
		aSqlItem.CONVERSION_TYPE := aPlsqlItem.CONVERSION_TYPE;
		aSqlItem.DELIVER_TO_ADDRESS1 := aPlsqlItem.DELIVER_TO_ADDRESS1;
		aSqlItem.DELIVER_TO_ADDRESS2 := aPlsqlItem.DELIVER_TO_ADDRESS2;
		aSqlItem.DELIVER_TO_ADDRESS3 := aPlsqlItem.DELIVER_TO_ADDRESS3;
		aSqlItem.DELIVER_TO_ADDRESS4 := aPlsqlItem.DELIVER_TO_ADDRESS4;
		aSqlItem.DELIVER_TO_CONTACT := aPlsqlItem.DELIVER_TO_CONTACT;
		aSqlItem.DELIVER_TO_LOCATION := aPlsqlItem.DELIVER_TO_LOCATION;
		aSqlItem.DELIVER_TO_ORG := aPlsqlItem.DELIVER_TO_ORG;
		aSqlItem.DELIVER_TO_STATE := aPlsqlItem.DELIVER_TO_STATE;
		aSqlItem.DELIVER_TO_CITY := aPlsqlItem.DELIVER_TO_CITY;
		aSqlItem.DELIVER_TO_ZIP := aPlsqlItem.DELIVER_TO_ZIP;
		aSqlItem.DELIVER_TO_COUNTRY := aPlsqlItem.DELIVER_TO_COUNTRY;
		aSqlItem.DELIVER_TO_COUNTY := aPlsqlItem.DELIVER_TO_COUNTY;
		aSqlItem.DELIVER_TO_PROVINCE := aPlsqlItem.DELIVER_TO_PROVINCE;
		aSqlItem.DEMAND_CLASS := aPlsqlItem.DEMAND_CLASS;
		aSqlItem.FOB_POINT := aPlsqlItem.FOB_POINT;
		aSqlItem.FREIGHT_TERMS := aPlsqlItem.FREIGHT_TERMS;
		aSqlItem.INVOICE_TO_ADDRESS1 := aPlsqlItem.INVOICE_TO_ADDRESS1;
		aSqlItem.INVOICE_TO_ADDRESS2 := aPlsqlItem.INVOICE_TO_ADDRESS2;
		aSqlItem.INVOICE_TO_ADDRESS3 := aPlsqlItem.INVOICE_TO_ADDRESS3;
		aSqlItem.INVOICE_TO_ADDRESS4 := aPlsqlItem.INVOICE_TO_ADDRESS4;
		aSqlItem.INVOICE_TO_STATE := aPlsqlItem.INVOICE_TO_STATE;
		aSqlItem.INVOICE_TO_CITY := aPlsqlItem.INVOICE_TO_CITY;
		aSqlItem.INVOICE_TO_ZIP := aPlsqlItem.INVOICE_TO_ZIP;
		aSqlItem.INVOICE_TO_COUNTRY := aPlsqlItem.INVOICE_TO_COUNTRY;
		aSqlItem.INVOICE_TO_COUNTY := aPlsqlItem.INVOICE_TO_COUNTY;
		aSqlItem.INVOICE_TO_PROVINCE := aPlsqlItem.INVOICE_TO_PROVINCE;
		aSqlItem.INVOICE_TO_CONTACT := aPlsqlItem.INVOICE_TO_CONTACT;
		aSqlItem.INVOICE_TO_CONTACT_FIRST_NAME := aPlsqlItem.INVOICE_TO_CONTACT_FIRST_NAME;
		aSqlItem.INVOICE_TO_CONTACT_LAST_NAME := aPlsqlItem.INVOICE_TO_CONTACT_LAST_NAME;
		aSqlItem.INVOICE_TO_LOCATION := aPlsqlItem.INVOICE_TO_LOCATION;
		aSqlItem.INVOICE_TO_ORG := aPlsqlItem.INVOICE_TO_ORG;
		aSqlItem.INVOICING_RULE := aPlsqlItem.INVOICING_RULE;
		aSqlItem.ORDER_SOURCE := aPlsqlItem.ORDER_SOURCE;
		aSqlItem.ORDER_TYPE := aPlsqlItem.ORDER_TYPE;
		aSqlItem.PAYMENT_TERM := aPlsqlItem.PAYMENT_TERM;
		aSqlItem.PRICE_LIST := aPlsqlItem.PRICE_LIST;
		aSqlItem.RETURN_REASON := aPlsqlItem.RETURN_REASON;
		aSqlItem.SALESREP := aPlsqlItem.SALESREP;
		aSqlItem.SHIPMENT_PRIORITY := aPlsqlItem.SHIPMENT_PRIORITY;
		aSqlItem.SHIP_FROM_ADDRESS1 := aPlsqlItem.SHIP_FROM_ADDRESS1;
		aSqlItem.SHIP_FROM_ADDRESS2 := aPlsqlItem.SHIP_FROM_ADDRESS2;
		aSqlItem.SHIP_FROM_ADDRESS3 := aPlsqlItem.SHIP_FROM_ADDRESS3;
		aSqlItem.SHIP_FROM_ADDRESS4 := aPlsqlItem.SHIP_FROM_ADDRESS4;
		aSqlItem.SHIP_FROM_LOCATION := aPlsqlItem.SHIP_FROM_LOCATION;
		aSqlItem.SHIP_FROM_CITY := aPlsqlItem.SHIP_FROM_CITY;
		aSqlItem.SHIP_FROM_POSTAL_CODE := aPlsqlItem.SHIP_FROM_POSTAL_CODE;
		aSqlItem.SHIP_FROM_COUNTRY := aPlsqlItem.SHIP_FROM_COUNTRY;
		aSqlItem.SHIP_FROM_REGION1 := aPlsqlItem.SHIP_FROM_REGION1;
		aSqlItem.SHIP_FROM_REGION2 := aPlsqlItem.SHIP_FROM_REGION2;
		aSqlItem.SHIP_FROM_REGION3 := aPlsqlItem.SHIP_FROM_REGION3;
		aSqlItem.SHIP_FROM_ORG := aPlsqlItem.SHIP_FROM_ORG;
		aSqlItem.SOLD_TO_ADDRESS1 := aPlsqlItem.SOLD_TO_ADDRESS1;
		aSqlItem.SOLD_TO_ADDRESS2 := aPlsqlItem.SOLD_TO_ADDRESS2;
		aSqlItem.SOLD_TO_ADDRESS3 := aPlsqlItem.SOLD_TO_ADDRESS3;
		aSqlItem.SOLD_TO_ADDRESS4 := aPlsqlItem.SOLD_TO_ADDRESS4;
		aSqlItem.SOLD_TO_STATE := aPlsqlItem.SOLD_TO_STATE;
		aSqlItem.SOLD_TO_COUNTRY := aPlsqlItem.SOLD_TO_COUNTRY;
		aSqlItem.SOLD_TO_ZIP := aPlsqlItem.SOLD_TO_ZIP;
		aSqlItem.SOLD_TO_COUNTY := aPlsqlItem.SOLD_TO_COUNTY;
		aSqlItem.SOLD_TO_PROVINCE := aPlsqlItem.SOLD_TO_PROVINCE;
		aSqlItem.SOLD_TO_CITY := aPlsqlItem.SOLD_TO_CITY;
		aSqlItem.SOLD_TO_CONTACT_LAST_NAME := aPlsqlItem.SOLD_TO_CONTACT_LAST_NAME;
		aSqlItem.SOLD_TO_CONTACT_FIRST_NAME := aPlsqlItem.SOLD_TO_CONTACT_FIRST_NAME;
		aSqlItem.SHIP_TO_ADDRESS1 := aPlsqlItem.SHIP_TO_ADDRESS1;
		aSqlItem.SHIP_TO_ADDRESS2 := aPlsqlItem.SHIP_TO_ADDRESS2;
		aSqlItem.SHIP_TO_ADDRESS3 := aPlsqlItem.SHIP_TO_ADDRESS3;
		aSqlItem.SHIP_TO_ADDRESS4 := aPlsqlItem.SHIP_TO_ADDRESS4;
		aSqlItem.SHIP_TO_STATE := aPlsqlItem.SHIP_TO_STATE;
		aSqlItem.SHIP_TO_COUNTRY := aPlsqlItem.SHIP_TO_COUNTRY;
		aSqlItem.SHIP_TO_ZIP := aPlsqlItem.SHIP_TO_ZIP;
		aSqlItem.SHIP_TO_COUNTY := aPlsqlItem.SHIP_TO_COUNTY;
		aSqlItem.SHIP_TO_PROVINCE := aPlsqlItem.SHIP_TO_PROVINCE;
		aSqlItem.SHIP_TO_CITY := aPlsqlItem.SHIP_TO_CITY;
		aSqlItem.SHIP_TO_CONTACT := aPlsqlItem.SHIP_TO_CONTACT;
		aSqlItem.SHIP_TO_CONTACT_LAST_NAME := aPlsqlItem.SHIP_TO_CONTACT_LAST_NAME;
		aSqlItem.SHIP_TO_CONTACT_FIRST_NAME := aPlsqlItem.SHIP_TO_CONTACT_FIRST_NAME;
		aSqlItem.SHIP_TO_LOCATION := aPlsqlItem.SHIP_TO_LOCATION;
		aSqlItem.SHIP_TO_ORG := aPlsqlItem.SHIP_TO_ORG;
		aSqlItem.SOLD_TO_CONTACT := aPlsqlItem.SOLD_TO_CONTACT;
		aSqlItem.SOLD_TO_ORG := aPlsqlItem.SOLD_TO_ORG;
		aSqlItem.SOLD_FROM_ORG := aPlsqlItem.SOLD_FROM_ORG;
		aSqlItem.TAX_EXEMPT := aPlsqlItem.TAX_EXEMPT;
		aSqlItem.TAX_EXEMPT_REASON := aPlsqlItem.TAX_EXEMPT_REASON;
		aSqlItem.TAX_POINT := aPlsqlItem.TAX_POINT;
		aSqlItem.CUSTOMER_PAYMENT_TERM := aPlsqlItem.CUSTOMER_PAYMENT_TERM;
		aSqlItem.PAYMENT_TYPE := aPlsqlItem.PAYMENT_TYPE;
		aSqlItem.CREDIT_CARD := aPlsqlItem.CREDIT_CARD;
		aSqlItem.STATUS := aPlsqlItem.STATUS;
		aSqlItem.FREIGHT_CARRIER := aPlsqlItem.FREIGHT_CARRIER;
		aSqlItem.SHIPPING_METHOD := aPlsqlItem.SHIPPING_METHOD;
		aSqlItem.ORDER_DATE_TYPE := aPlsqlItem.ORDER_DATE_TYPE;
		aSqlItem.CUSTOMER_NUMBER := aPlsqlItem.CUSTOMER_NUMBER;
		aSqlItem.SHIP_TO_CUSTOMER_NAME := aPlsqlItem.SHIP_TO_CUSTOMER_NAME;
		aSqlItem.INVOICE_TO_CUSTOMER_NAME := aPlsqlItem.INVOICE_TO_CUSTOMER_NAME;
		aSqlItem.SALES_CHANNEL := aPlsqlItem.SALES_CHANNEL;
		aSqlItem.SHIP_TO_CUSTOMER_NUMBER := aPlsqlItem.SHIP_TO_CUSTOMER_NUMBER;
		aSqlItem.INVOICE_TO_CUSTOMER_NUMBER := aPlsqlItem.INVOICE_TO_CUSTOMER_NUMBER;
		aSqlItem.SHIP_TO_CUSTOMER_ID := aPlsqlItem.SHIP_TO_CUSTOMER_ID;
		aSqlItem.INVOICE_TO_CUSTOMER_ID := aPlsqlItem.INVOICE_TO_CUSTOMER_ID;
		aSqlItem.DELIVER_TO_CUSTOMER_ID := aPlsqlItem.DELIVER_TO_CUSTOMER_ID;
		aSqlItem.DELIVER_TO_CUSTOMER_NUMBER := aPlsqlItem.DELIVER_TO_CUSTOMER_NUMBER;
		aSqlItem.DELIVER_TO_CUSTOMER_NAME := aPlsqlItem.DELIVER_TO_CUSTOMER_NAME;
		aSqlItem.DELIVER_TO_CUSTOMER_NUMBER_OI := aPlsqlItem.DELIVER_TO_CUSTOMER_NUMBER_OI;
		aSqlItem.DELIVER_TO_CUSTOMER_NAME_OI := aPlsqlItem.DELIVER_TO_CUSTOMER_NAME_OI;
		aSqlItem.SHIP_TO_CUSTOMER_NUMBER_OI := aPlsqlItem.SHIP_TO_CUSTOMER_NUMBER_OI;
		aSqlItem.SHIP_TO_CUSTOMER_NAME_OI := aPlsqlItem.SHIP_TO_CUSTOMER_NAME_OI;
		aSqlItem.INVOICE_TO_CUSTOMER_NUMBER_OI := aPlsqlItem.INVOICE_TO_CUSTOMER_NUMBER_OI;
		aSqlItem.INVOICE_TO_CUSTOMER_NAME_OI := aPlsqlItem.INVOICE_TO_CUSTOMER_NAME_OI;
		aSqlItem.USER_STATUS := aPlsqlItem.USER_STATUS;
		aSqlItem.TRANSACTION_PHASE := aPlsqlItem.TRANSACTION_PHASE;
		aSqlItem.SOLD_TO_LOCATION_ADDRESS1 := aPlsqlItem.SOLD_TO_LOCATION_ADDRESS1;
		aSqlItem.SOLD_TO_LOCATION_ADDRESS2 := aPlsqlItem.SOLD_TO_LOCATION_ADDRESS2;
		aSqlItem.SOLD_TO_LOCATION_ADDRESS3 := aPlsqlItem.SOLD_TO_LOCATION_ADDRESS3;
		aSqlItem.SOLD_TO_LOCATION_ADDRESS4 := aPlsqlItem.SOLD_TO_LOCATION_ADDRESS4;
		aSqlItem.SOLD_TO_LOCATION := aPlsqlItem.SOLD_TO_LOCATION;
		aSqlItem.SOLD_TO_LOCATION_CITY := aPlsqlItem.SOLD_TO_LOCATION_CITY;
		aSqlItem.SOLD_TO_LOCATION_STATE := aPlsqlItem.SOLD_TO_LOCATION_STATE;
		aSqlItem.SOLD_TO_LOCATION_POSTAL := aPlsqlItem.SOLD_TO_LOCATION_POSTAL;
		aSqlItem.SOLD_TO_LOCATION_COUNTRY := aPlsqlItem.SOLD_TO_LOCATION_COUNTRY;
		aSqlItem.SOLD_TO_LOCATION_COUNTY := aPlsqlItem.SOLD_TO_LOCATION_COUNTY;
		aSqlItem.SOLD_TO_LOCATION_PROVINCE := aPlsqlItem.SOLD_TO_LOCATION_PROVINCE;
		aSqlItem.END_CUSTOMER_NAME := aPlsqlItem.END_CUSTOMER_NAME;
		aSqlItem.END_CUSTOMER_NUMBER := aPlsqlItem.END_CUSTOMER_NUMBER;
		aSqlItem.END_CUSTOMER_CONTACT := aPlsqlItem.END_CUSTOMER_CONTACT;
		aSqlItem.END_CUST_CONTACT_LAST_NAME := aPlsqlItem.END_CUST_CONTACT_LAST_NAME;
		aSqlItem.END_CUST_CONTACT_FIRST_NAME := aPlsqlItem.END_CUST_CONTACT_FIRST_NAME;
		aSqlItem.END_CUSTOMER_SITE_ADDRESS1 := aPlsqlItem.END_CUSTOMER_SITE_ADDRESS1;
		aSqlItem.END_CUSTOMER_SITE_ADDRESS2 := aPlsqlItem.END_CUSTOMER_SITE_ADDRESS2;
		aSqlItem.END_CUSTOMER_SITE_ADDRESS3 := aPlsqlItem.END_CUSTOMER_SITE_ADDRESS3;
		aSqlItem.END_CUSTOMER_SITE_ADDRESS4 := aPlsqlItem.END_CUSTOMER_SITE_ADDRESS4;
		aSqlItem.END_CUSTOMER_SITE_STATE := aPlsqlItem.END_CUSTOMER_SITE_STATE;
		aSqlItem.END_CUSTOMER_SITE_COUNTRY := aPlsqlItem.END_CUSTOMER_SITE_COUNTRY;
		aSqlItem.END_CUSTOMER_SITE_LOCATION := aPlsqlItem.END_CUSTOMER_SITE_LOCATION;
		aSqlItem.END_CUSTOMER_SITE_ZIP := aPlsqlItem.END_CUSTOMER_SITE_ZIP;
		aSqlItem.END_CUSTOMER_SITE_COUNTY := aPlsqlItem.END_CUSTOMER_SITE_COUNTY;
		aSqlItem.END_CUSTOMER_SITE_PROVINCE := aPlsqlItem.END_CUSTOMER_SITE_PROVINCE;
		aSqlItem.END_CUSTOMER_SITE_CITY := aPlsqlItem.END_CUSTOMER_SITE_CITY;
		aSqlItem.END_CUSTOMER_SITE_POSTAL_CODE := aPlsqlItem.END_CUSTOMER_SITE_POSTAL_CODE;
		aSqlItem.BLANKET_AGREEMENT_NAME := aPlsqlItem.BLANKET_AGREEMENT_NAME;
		aSqlItem.IB_OWNER_DSP := aPlsqlItem.IB_OWNER_DSP;
		aSqlItem.IB_INSTALLED_AT_LOCATION_DSP := aPlsqlItem.IB_INSTALLED_AT_LOCATION_DSP;
		aSqlItem.IB_CURRENT_LOCATION_DSP := aPlsqlItem.IB_CURRENT_LOCATION_DSP;
		aSqlItem.CONTRACT_TEMPLATE := aPlsqlItem.CONTRACT_TEMPLATE;
		aSqlItem.CONTRACT_SOURCE := aPlsqlItem.CONTRACT_SOURCE;
		aSqlItem.AUTHORING_PARTY := aPlsqlItem.AUTHORING_PARTY;
		RETURN aSqlItem;
	END PL_TO_SQL2;

	FUNCTION SQL_TO_PL2(aSqlItem OE_ORDER_PUB_HEADER_VAL_REC_T)
	RETURN OE_ORDER_PUB.HEADER_VAL_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_VAL_REC_TYPE;
	BEGIN
		aPlsqlItem.ACCOUNTING_RULE := aSqlItem.ACCOUNTING_RULE;
		aPlsqlItem.AGREEMENT := aSqlItem.AGREEMENT;
		aPlsqlItem.CONVERSION_TYPE := aSqlItem.CONVERSION_TYPE;
		aPlsqlItem.DELIVER_TO_ADDRESS1 := aSqlItem.DELIVER_TO_ADDRESS1;
		aPlsqlItem.DELIVER_TO_ADDRESS2 := aSqlItem.DELIVER_TO_ADDRESS2;
		aPlsqlItem.DELIVER_TO_ADDRESS3 := aSqlItem.DELIVER_TO_ADDRESS3;
		aPlsqlItem.DELIVER_TO_ADDRESS4 := aSqlItem.DELIVER_TO_ADDRESS4;
		aPlsqlItem.DELIVER_TO_CONTACT := aSqlItem.DELIVER_TO_CONTACT;
		aPlsqlItem.DELIVER_TO_LOCATION := aSqlItem.DELIVER_TO_LOCATION;
		aPlsqlItem.DELIVER_TO_ORG := aSqlItem.DELIVER_TO_ORG;
		aPlsqlItem.DELIVER_TO_STATE := aSqlItem.DELIVER_TO_STATE;
		aPlsqlItem.DELIVER_TO_CITY := aSqlItem.DELIVER_TO_CITY;
		aPlsqlItem.DELIVER_TO_ZIP := aSqlItem.DELIVER_TO_ZIP;
		aPlsqlItem.DELIVER_TO_COUNTRY := aSqlItem.DELIVER_TO_COUNTRY;
		aPlsqlItem.DELIVER_TO_COUNTY := aSqlItem.DELIVER_TO_COUNTY;
		aPlsqlItem.DELIVER_TO_PROVINCE := aSqlItem.DELIVER_TO_PROVINCE;
		aPlsqlItem.DEMAND_CLASS := aSqlItem.DEMAND_CLASS;
		aPlsqlItem.FOB_POINT := aSqlItem.FOB_POINT;
		aPlsqlItem.FREIGHT_TERMS := aSqlItem.FREIGHT_TERMS;
		aPlsqlItem.INVOICE_TO_ADDRESS1 := aSqlItem.INVOICE_TO_ADDRESS1;
		aPlsqlItem.INVOICE_TO_ADDRESS2 := aSqlItem.INVOICE_TO_ADDRESS2;
		aPlsqlItem.INVOICE_TO_ADDRESS3 := aSqlItem.INVOICE_TO_ADDRESS3;
		aPlsqlItem.INVOICE_TO_ADDRESS4 := aSqlItem.INVOICE_TO_ADDRESS4;
		aPlsqlItem.INVOICE_TO_STATE := aSqlItem.INVOICE_TO_STATE;
		aPlsqlItem.INVOICE_TO_CITY := aSqlItem.INVOICE_TO_CITY;
		aPlsqlItem.INVOICE_TO_ZIP := aSqlItem.INVOICE_TO_ZIP;
		aPlsqlItem.INVOICE_TO_COUNTRY := aSqlItem.INVOICE_TO_COUNTRY;
		aPlsqlItem.INVOICE_TO_COUNTY := aSqlItem.INVOICE_TO_COUNTY;
		aPlsqlItem.INVOICE_TO_PROVINCE := aSqlItem.INVOICE_TO_PROVINCE;
		aPlsqlItem.INVOICE_TO_CONTACT := aSqlItem.INVOICE_TO_CONTACT;
		aPlsqlItem.INVOICE_TO_CONTACT_FIRST_NAME := aSqlItem.INVOICE_TO_CONTACT_FIRST_NAME;
		aPlsqlItem.INVOICE_TO_CONTACT_LAST_NAME := aSqlItem.INVOICE_TO_CONTACT_LAST_NAME;
		aPlsqlItem.INVOICE_TO_LOCATION := aSqlItem.INVOICE_TO_LOCATION;
		aPlsqlItem.INVOICE_TO_ORG := aSqlItem.INVOICE_TO_ORG;
		aPlsqlItem.INVOICING_RULE := aSqlItem.INVOICING_RULE;
		aPlsqlItem.ORDER_SOURCE := aSqlItem.ORDER_SOURCE;
		aPlsqlItem.ORDER_TYPE := aSqlItem.ORDER_TYPE;
		aPlsqlItem.PAYMENT_TERM := aSqlItem.PAYMENT_TERM;
		aPlsqlItem.PRICE_LIST := aSqlItem.PRICE_LIST;
		aPlsqlItem.RETURN_REASON := aSqlItem.RETURN_REASON;
		aPlsqlItem.SALESREP := aSqlItem.SALESREP;
		aPlsqlItem.SHIPMENT_PRIORITY := aSqlItem.SHIPMENT_PRIORITY;
		aPlsqlItem.SHIP_FROM_ADDRESS1 := aSqlItem.SHIP_FROM_ADDRESS1;
		aPlsqlItem.SHIP_FROM_ADDRESS2 := aSqlItem.SHIP_FROM_ADDRESS2;
		aPlsqlItem.SHIP_FROM_ADDRESS3 := aSqlItem.SHIP_FROM_ADDRESS3;
		aPlsqlItem.SHIP_FROM_ADDRESS4 := aSqlItem.SHIP_FROM_ADDRESS4;
		aPlsqlItem.SHIP_FROM_LOCATION := aSqlItem.SHIP_FROM_LOCATION;
		aPlsqlItem.SHIP_FROM_CITY := aSqlItem.SHIP_FROM_CITY;
		aPlsqlItem.SHIP_FROM_POSTAL_CODE := aSqlItem.SHIP_FROM_POSTAL_CODE;
		aPlsqlItem.SHIP_FROM_COUNTRY := aSqlItem.SHIP_FROM_COUNTRY;
		aPlsqlItem.SHIP_FROM_REGION1 := aSqlItem.SHIP_FROM_REGION1;
		aPlsqlItem.SHIP_FROM_REGION2 := aSqlItem.SHIP_FROM_REGION2;
		aPlsqlItem.SHIP_FROM_REGION3 := aSqlItem.SHIP_FROM_REGION3;
		aPlsqlItem.SHIP_FROM_ORG := aSqlItem.SHIP_FROM_ORG;
		aPlsqlItem.SOLD_TO_ADDRESS1 := aSqlItem.SOLD_TO_ADDRESS1;
		aPlsqlItem.SOLD_TO_ADDRESS2 := aSqlItem.SOLD_TO_ADDRESS2;
		aPlsqlItem.SOLD_TO_ADDRESS3 := aSqlItem.SOLD_TO_ADDRESS3;
		aPlsqlItem.SOLD_TO_ADDRESS4 := aSqlItem.SOLD_TO_ADDRESS4;
		aPlsqlItem.SOLD_TO_STATE := aSqlItem.SOLD_TO_STATE;
		aPlsqlItem.SOLD_TO_COUNTRY := aSqlItem.SOLD_TO_COUNTRY;
		aPlsqlItem.SOLD_TO_ZIP := aSqlItem.SOLD_TO_ZIP;
		aPlsqlItem.SOLD_TO_COUNTY := aSqlItem.SOLD_TO_COUNTY;
		aPlsqlItem.SOLD_TO_PROVINCE := aSqlItem.SOLD_TO_PROVINCE;
		aPlsqlItem.SOLD_TO_CITY := aSqlItem.SOLD_TO_CITY;
		aPlsqlItem.SOLD_TO_CONTACT_LAST_NAME := aSqlItem.SOLD_TO_CONTACT_LAST_NAME;
		aPlsqlItem.SOLD_TO_CONTACT_FIRST_NAME := aSqlItem.SOLD_TO_CONTACT_FIRST_NAME;
		aPlsqlItem.SHIP_TO_ADDRESS1 := aSqlItem.SHIP_TO_ADDRESS1;
		aPlsqlItem.SHIP_TO_ADDRESS2 := aSqlItem.SHIP_TO_ADDRESS2;
		aPlsqlItem.SHIP_TO_ADDRESS3 := aSqlItem.SHIP_TO_ADDRESS3;
		aPlsqlItem.SHIP_TO_ADDRESS4 := aSqlItem.SHIP_TO_ADDRESS4;
		aPlsqlItem.SHIP_TO_STATE := aSqlItem.SHIP_TO_STATE;
		aPlsqlItem.SHIP_TO_COUNTRY := aSqlItem.SHIP_TO_COUNTRY;
		aPlsqlItem.SHIP_TO_ZIP := aSqlItem.SHIP_TO_ZIP;
		aPlsqlItem.SHIP_TO_COUNTY := aSqlItem.SHIP_TO_COUNTY;
		aPlsqlItem.SHIP_TO_PROVINCE := aSqlItem.SHIP_TO_PROVINCE;
		aPlsqlItem.SHIP_TO_CITY := aSqlItem.SHIP_TO_CITY;
		aPlsqlItem.SHIP_TO_CONTACT := aSqlItem.SHIP_TO_CONTACT;
		aPlsqlItem.SHIP_TO_CONTACT_LAST_NAME := aSqlItem.SHIP_TO_CONTACT_LAST_NAME;
		aPlsqlItem.SHIP_TO_CONTACT_FIRST_NAME := aSqlItem.SHIP_TO_CONTACT_FIRST_NAME;
		aPlsqlItem.SHIP_TO_LOCATION := aSqlItem.SHIP_TO_LOCATION;
		aPlsqlItem.SHIP_TO_ORG := aSqlItem.SHIP_TO_ORG;
		aPlsqlItem.SOLD_TO_CONTACT := aSqlItem.SOLD_TO_CONTACT;
		aPlsqlItem.SOLD_TO_ORG := aSqlItem.SOLD_TO_ORG;
		aPlsqlItem.SOLD_FROM_ORG := aSqlItem.SOLD_FROM_ORG;
		aPlsqlItem.TAX_EXEMPT := aSqlItem.TAX_EXEMPT;
		aPlsqlItem.TAX_EXEMPT_REASON := aSqlItem.TAX_EXEMPT_REASON;
		aPlsqlItem.TAX_POINT := aSqlItem.TAX_POINT;
		aPlsqlItem.CUSTOMER_PAYMENT_TERM := aSqlItem.CUSTOMER_PAYMENT_TERM;
		aPlsqlItem.PAYMENT_TYPE := aSqlItem.PAYMENT_TYPE;
		aPlsqlItem.CREDIT_CARD := aSqlItem.CREDIT_CARD;
		aPlsqlItem.STATUS := aSqlItem.STATUS;
		aPlsqlItem.FREIGHT_CARRIER := aSqlItem.FREIGHT_CARRIER;
		aPlsqlItem.SHIPPING_METHOD := aSqlItem.SHIPPING_METHOD;
		aPlsqlItem.ORDER_DATE_TYPE := aSqlItem.ORDER_DATE_TYPE;
		aPlsqlItem.CUSTOMER_NUMBER := aSqlItem.CUSTOMER_NUMBER;
		aPlsqlItem.SHIP_TO_CUSTOMER_NAME := aSqlItem.SHIP_TO_CUSTOMER_NAME;
		aPlsqlItem.INVOICE_TO_CUSTOMER_NAME := aSqlItem.INVOICE_TO_CUSTOMER_NAME;
		aPlsqlItem.SALES_CHANNEL := aSqlItem.SALES_CHANNEL;
		aPlsqlItem.SHIP_TO_CUSTOMER_NUMBER := aSqlItem.SHIP_TO_CUSTOMER_NUMBER;
		aPlsqlItem.INVOICE_TO_CUSTOMER_NUMBER := aSqlItem.INVOICE_TO_CUSTOMER_NUMBER;
		aPlsqlItem.SHIP_TO_CUSTOMER_ID := aSqlItem.SHIP_TO_CUSTOMER_ID;
		aPlsqlItem.INVOICE_TO_CUSTOMER_ID := aSqlItem.INVOICE_TO_CUSTOMER_ID;
		aPlsqlItem.DELIVER_TO_CUSTOMER_ID := aSqlItem.DELIVER_TO_CUSTOMER_ID;
		aPlsqlItem.DELIVER_TO_CUSTOMER_NUMBER := aSqlItem.DELIVER_TO_CUSTOMER_NUMBER;
		aPlsqlItem.DELIVER_TO_CUSTOMER_NAME := aSqlItem.DELIVER_TO_CUSTOMER_NAME;
		aPlsqlItem.DELIVER_TO_CUSTOMER_NUMBER_OI := aSqlItem.DELIVER_TO_CUSTOMER_NUMBER_OI;
		aPlsqlItem.DELIVER_TO_CUSTOMER_NAME_OI := aSqlItem.DELIVER_TO_CUSTOMER_NAME_OI;
		aPlsqlItem.SHIP_TO_CUSTOMER_NUMBER_OI := aSqlItem.SHIP_TO_CUSTOMER_NUMBER_OI;
		aPlsqlItem.SHIP_TO_CUSTOMER_NAME_OI := aSqlItem.SHIP_TO_CUSTOMER_NAME_OI;
		aPlsqlItem.INVOICE_TO_CUSTOMER_NUMBER_OI := aSqlItem.INVOICE_TO_CUSTOMER_NUMBER_OI;
		aPlsqlItem.INVOICE_TO_CUSTOMER_NAME_OI := aSqlItem.INVOICE_TO_CUSTOMER_NAME_OI;
		aPlsqlItem.USER_STATUS := aSqlItem.USER_STATUS;
		aPlsqlItem.TRANSACTION_PHASE := aSqlItem.TRANSACTION_PHASE;
		aPlsqlItem.SOLD_TO_LOCATION_ADDRESS1 := aSqlItem.SOLD_TO_LOCATION_ADDRESS1;
		aPlsqlItem.SOLD_TO_LOCATION_ADDRESS2 := aSqlItem.SOLD_TO_LOCATION_ADDRESS2;
		aPlsqlItem.SOLD_TO_LOCATION_ADDRESS3 := aSqlItem.SOLD_TO_LOCATION_ADDRESS3;
		aPlsqlItem.SOLD_TO_LOCATION_ADDRESS4 := aSqlItem.SOLD_TO_LOCATION_ADDRESS4;
		aPlsqlItem.SOLD_TO_LOCATION := aSqlItem.SOLD_TO_LOCATION;
		aPlsqlItem.SOLD_TO_LOCATION_CITY := aSqlItem.SOLD_TO_LOCATION_CITY;
		aPlsqlItem.SOLD_TO_LOCATION_STATE := aSqlItem.SOLD_TO_LOCATION_STATE;
		aPlsqlItem.SOLD_TO_LOCATION_POSTAL := aSqlItem.SOLD_TO_LOCATION_POSTAL;
		aPlsqlItem.SOLD_TO_LOCATION_COUNTRY := aSqlItem.SOLD_TO_LOCATION_COUNTRY;
		aPlsqlItem.SOLD_TO_LOCATION_COUNTY := aSqlItem.SOLD_TO_LOCATION_COUNTY;
		aPlsqlItem.SOLD_TO_LOCATION_PROVINCE := aSqlItem.SOLD_TO_LOCATION_PROVINCE;
		aPlsqlItem.END_CUSTOMER_NAME := aSqlItem.END_CUSTOMER_NAME;
		aPlsqlItem.END_CUSTOMER_NUMBER := aSqlItem.END_CUSTOMER_NUMBER;
		aPlsqlItem.END_CUSTOMER_CONTACT := aSqlItem.END_CUSTOMER_CONTACT;
		aPlsqlItem.END_CUST_CONTACT_LAST_NAME := aSqlItem.END_CUST_CONTACT_LAST_NAME;
		aPlsqlItem.END_CUST_CONTACT_FIRST_NAME := aSqlItem.END_CUST_CONTACT_FIRST_NAME;
		aPlsqlItem.END_CUSTOMER_SITE_ADDRESS1 := aSqlItem.END_CUSTOMER_SITE_ADDRESS1;
		aPlsqlItem.END_CUSTOMER_SITE_ADDRESS2 := aSqlItem.END_CUSTOMER_SITE_ADDRESS2;
		aPlsqlItem.END_CUSTOMER_SITE_ADDRESS3 := aSqlItem.END_CUSTOMER_SITE_ADDRESS3;
		aPlsqlItem.END_CUSTOMER_SITE_ADDRESS4 := aSqlItem.END_CUSTOMER_SITE_ADDRESS4;
		aPlsqlItem.END_CUSTOMER_SITE_STATE := aSqlItem.END_CUSTOMER_SITE_STATE;
		aPlsqlItem.END_CUSTOMER_SITE_COUNTRY := aSqlItem.END_CUSTOMER_SITE_COUNTRY;
		aPlsqlItem.END_CUSTOMER_SITE_LOCATION := aSqlItem.END_CUSTOMER_SITE_LOCATION;
		aPlsqlItem.END_CUSTOMER_SITE_ZIP := aSqlItem.END_CUSTOMER_SITE_ZIP;
		aPlsqlItem.END_CUSTOMER_SITE_COUNTY := aSqlItem.END_CUSTOMER_SITE_COUNTY;
		aPlsqlItem.END_CUSTOMER_SITE_PROVINCE := aSqlItem.END_CUSTOMER_SITE_PROVINCE;
		aPlsqlItem.END_CUSTOMER_SITE_CITY := aSqlItem.END_CUSTOMER_SITE_CITY;
		aPlsqlItem.END_CUSTOMER_SITE_POSTAL_CODE := aSqlItem.END_CUSTOMER_SITE_POSTAL_CODE;
		aPlsqlItem.BLANKET_AGREEMENT_NAME := aSqlItem.BLANKET_AGREEMENT_NAME;
		aPlsqlItem.IB_OWNER_DSP := aSqlItem.IB_OWNER_DSP;
		aPlsqlItem.IB_INSTALLED_AT_LOCATION_DSP := aSqlItem.IB_INSTALLED_AT_LOCATION_DSP;
		aPlsqlItem.IB_CURRENT_LOCATION_DSP := aSqlItem.IB_CURRENT_LOCATION_DSP;
		aPlsqlItem.CONTRACT_TEMPLATE := aSqlItem.CONTRACT_TEMPLATE;
		aPlsqlItem.CONTRACT_SOURCE := aSqlItem.CONTRACT_SOURCE;
		aPlsqlItem.AUTHORING_PARTY := aSqlItem.AUTHORING_PARTY;
		RETURN aPlsqlItem;
	END SQL_TO_PL2;

	FUNCTION PL_TO_SQL26(aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_ADJ_REC_T IS
	aSqlItem OE_ORDER_PUB_HEADER_ADJ_REC_T;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_ADJ_REC_T(NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                         NULL, NULL, NULL, NULL);
		aSqlItem.ATTRIBUTE1 := aPlsqlItem.ATTRIBUTE1;
		aSqlItem.ATTRIBUTE10 := aPlsqlItem.ATTRIBUTE10;
		aSqlItem.ATTRIBUTE11 := aPlsqlItem.ATTRIBUTE11;
		aSqlItem.ATTRIBUTE12 := aPlsqlItem.ATTRIBUTE12;
		aSqlItem.ATTRIBUTE13 := aPlsqlItem.ATTRIBUTE13;
		aSqlItem.ATTRIBUTE14 := aPlsqlItem.ATTRIBUTE14;
		aSqlItem.ATTRIBUTE15 := aPlsqlItem.ATTRIBUTE15;
		aSqlItem.ATTRIBUTE2 := aPlsqlItem.ATTRIBUTE2;
		aSqlItem.ATTRIBUTE3 := aPlsqlItem.ATTRIBUTE3;
		aSqlItem.ATTRIBUTE4 := aPlsqlItem.ATTRIBUTE4;
		aSqlItem.ATTRIBUTE5 := aPlsqlItem.ATTRIBUTE5;
		aSqlItem.ATTRIBUTE6 := aPlsqlItem.ATTRIBUTE6;
		aSqlItem.ATTRIBUTE7 := aPlsqlItem.ATTRIBUTE7;
		aSqlItem.ATTRIBUTE8 := aPlsqlItem.ATTRIBUTE8;
		aSqlItem.ATTRIBUTE9 := aPlsqlItem.ATTRIBUTE9;
		aSqlItem.AUTOMATIC_FLAG := aPlsqlItem.AUTOMATIC_FLAG;
		aSqlItem.CONTEXT := aPlsqlItem.CONTEXT;
		aSqlItem.CREATED_BY := aPlsqlItem.CREATED_BY;
		aSqlItem.CREATION_DATE := aPlsqlItem.CREATION_DATE;
		aSqlItem.DISCOUNT_ID := aPlsqlItem.DISCOUNT_ID;
		aSqlItem.DISCOUNT_LINE_ID := aPlsqlItem.DISCOUNT_LINE_ID;
		aSqlItem.HEADER_ID := aPlsqlItem.HEADER_ID;
		aSqlItem.LAST_UPDATED_BY := aPlsqlItem.LAST_UPDATED_BY;
		aSqlItem.LAST_UPDATE_DATE := aPlsqlItem.LAST_UPDATE_DATE;
		aSqlItem.LAST_UPDATE_LOGIN := aPlsqlItem.LAST_UPDATE_LOGIN;
		aSqlItem.LINE_ID := aPlsqlItem.LINE_ID;
		aSqlItem.PERCENT := aPlsqlItem.PERCENT;
		aSqlItem.PRICE_ADJUSTMENT_ID := aPlsqlItem.PRICE_ADJUSTMENT_ID;
		aSqlItem.PROGRAM_APPLICATION_ID := aPlsqlItem.PROGRAM_APPLICATION_ID;
		aSqlItem.PROGRAM_ID := aPlsqlItem.PROGRAM_ID;
		aSqlItem.PROGRAM_UPDATE_DATE := aPlsqlItem.PROGRAM_UPDATE_DATE;
		aSqlItem.REQUEST_ID := aPlsqlItem.REQUEST_ID;
		aSqlItem.RETURN_STATUS := aPlsqlItem.RETURN_STATUS;
		aSqlItem.DB_FLAG := aPlsqlItem.DB_FLAG;
		aSqlItem.OPERATION := aPlsqlItem.OPERATION;
		aSqlItem.ORIG_SYS_DISCOUNT_REF := aPlsqlItem.ORIG_SYS_DISCOUNT_REF;
		aSqlItem.CHANGE_REQUEST_CODE := aPlsqlItem.CHANGE_REQUEST_CODE;
		aSqlItem.STATUS_FLAG := aPlsqlItem.STATUS_FLAG;
		aSqlItem.LIST_HEADER_ID := aPlsqlItem.LIST_HEADER_ID;
		aSqlItem.LIST_LINE_ID := aPlsqlItem.LIST_LINE_ID;
		aSqlItem.LIST_LINE_TYPE_CODE := aPlsqlItem.LIST_LINE_TYPE_CODE;
		aSqlItem.MODIFIER_MECHANISM_TYPE_CODE := aPlsqlItem.MODIFIER_MECHANISM_TYPE_CODE;
		aSqlItem.MODIFIED_FROM := aPlsqlItem.MODIFIED_FROM;
		aSqlItem.MODIFIED_TO := aPlsqlItem.MODIFIED_TO;
		aSqlItem.UPDATED_FLAG := aPlsqlItem.UPDATED_FLAG;
		aSqlItem.UPDATE_ALLOWED := aPlsqlItem.UPDATE_ALLOWED;
		aSqlItem.APPLIED_FLAG := aPlsqlItem.APPLIED_FLAG;
		aSqlItem.CHANGE_REASON_CODE := aPlsqlItem.CHANGE_REASON_CODE;
		aSqlItem.CHANGE_REASON_TEXT := aPlsqlItem.CHANGE_REASON_TEXT;
		aSqlItem.OPERAND := aPlsqlItem.OPERAND;
		aSqlItem.OPERAND_PER_PQTY := aPlsqlItem.OPERAND_PER_PQTY;
		aSqlItem.ARITHMETIC_OPERATOR := aPlsqlItem.ARITHMETIC_OPERATOR;
		aSqlItem.COST_ID := aPlsqlItem.COST_ID;
		aSqlItem.TAX_CODE := aPlsqlItem.TAX_CODE;
		aSqlItem.TAX_EXEMPT_FLAG := aPlsqlItem.TAX_EXEMPT_FLAG;
		aSqlItem.TAX_EXEMPT_NUMBER := aPlsqlItem.TAX_EXEMPT_NUMBER;
		aSqlItem.TAX_EXEMPT_REASON_CODE := aPlsqlItem.TAX_EXEMPT_REASON_CODE;
		aSqlItem.PARENT_ADJUSTMENT_ID := aPlsqlItem.PARENT_ADJUSTMENT_ID;
		aSqlItem.INVOICED_FLAG := aPlsqlItem.INVOICED_FLAG;
		aSqlItem.ESTIMATED_FLAG := aPlsqlItem.ESTIMATED_FLAG;
		aSqlItem.INC_IN_SALES_PERFORMANCE := aPlsqlItem.INC_IN_SALES_PERFORMANCE;
		aSqlItem.SPLIT_ACTION_CODE := aPlsqlItem.SPLIT_ACTION_CODE;
		aSqlItem.ADJUSTED_AMOUNT := aPlsqlItem.ADJUSTED_AMOUNT;
		aSqlItem.ADJUSTED_AMOUNT_PER_PQTY := aPlsqlItem.ADJUSTED_AMOUNT_PER_PQTY;
		aSqlItem.PRICING_PHASE_ID := aPlsqlItem.PRICING_PHASE_ID;
		aSqlItem.CHARGE_TYPE_CODE := aPlsqlItem.CHARGE_TYPE_CODE;
		aSqlItem.CHARGE_SUBTYPE_CODE := aPlsqlItem.CHARGE_SUBTYPE_CODE;
		aSqlItem.LIST_LINE_NO := aPlsqlItem.LIST_LINE_NO;
		aSqlItem.SOURCE_SYSTEM_CODE := aPlsqlItem.SOURCE_SYSTEM_CODE;
		aSqlItem.BENEFIT_QTY := aPlsqlItem.BENEFIT_QTY;
		aSqlItem.BENEFIT_UOM_CODE := aPlsqlItem.BENEFIT_UOM_CODE;
		aSqlItem.PRINT_ON_INVOICE_FLAG := aPlsqlItem.PRINT_ON_INVOICE_FLAG;
		aSqlItem.EXPIRATION_DATE := aPlsqlItem.EXPIRATION_DATE;
		aSqlItem.REBATE_TRANSACTION_TYPE_CODE := aPlsqlItem.REBATE_TRANSACTION_TYPE_CODE;
		aSqlItem.REBATE_TRANSACTION_REFERENCE := aPlsqlItem.REBATE_TRANSACTION_REFERENCE;
		aSqlItem.REBATE_PAYMENT_SYSTEM_CODE := aPlsqlItem.REBATE_PAYMENT_SYSTEM_CODE;
		aSqlItem.REDEEMED_DATE := aPlsqlItem.REDEEMED_DATE;
		aSqlItem.REDEEMED_FLAG := aPlsqlItem.REDEEMED_FLAG;
		aSqlItem.ACCRUAL_FLAG := aPlsqlItem.ACCRUAL_FLAG;
		aSqlItem.RANGE_BREAK_QUANTITY := aPlsqlItem.RANGE_BREAK_QUANTITY;
		aSqlItem.ACCRUAL_CONVERSION_RATE := aPlsqlItem.ACCRUAL_CONVERSION_RATE;
		aSqlItem.PRICING_GROUP_SEQUENCE := aPlsqlItem.PRICING_GROUP_SEQUENCE;
		aSqlItem.MODIFIER_LEVEL_CODE := aPlsqlItem.MODIFIER_LEVEL_CODE;
		aSqlItem.PRICE_BREAK_TYPE_CODE := aPlsqlItem.PRICE_BREAK_TYPE_CODE;
		aSqlItem.SUBSTITUTION_ATTRIBUTE := aPlsqlItem.SUBSTITUTION_ATTRIBUTE;
		aSqlItem.PRORATION_TYPE_CODE := aPlsqlItem.PRORATION_TYPE_CODE;
		aSqlItem.CREDIT_OR_CHARGE_FLAG := aPlsqlItem.CREDIT_OR_CHARGE_FLAG;
		aSqlItem.INCLUDE_ON_RETURNS_FLAG := aPlsqlItem.INCLUDE_ON_RETURNS_FLAG;
		aSqlItem.AC_ATTRIBUTE1 := aPlsqlItem.AC_ATTRIBUTE1;
		aSqlItem.AC_ATTRIBUTE10 := aPlsqlItem.AC_ATTRIBUTE10;
		aSqlItem.AC_ATTRIBUTE11 := aPlsqlItem.AC_ATTRIBUTE11;
		aSqlItem.AC_ATTRIBUTE12 := aPlsqlItem.AC_ATTRIBUTE12;
		aSqlItem.AC_ATTRIBUTE13 := aPlsqlItem.AC_ATTRIBUTE13;
		aSqlItem.AC_ATTRIBUTE14 := aPlsqlItem.AC_ATTRIBUTE14;
		aSqlItem.AC_ATTRIBUTE15 := aPlsqlItem.AC_ATTRIBUTE15;
		aSqlItem.AC_ATTRIBUTE2 := aPlsqlItem.AC_ATTRIBUTE2;
		aSqlItem.AC_ATTRIBUTE3 := aPlsqlItem.AC_ATTRIBUTE3;
		aSqlItem.AC_ATTRIBUTE4 := aPlsqlItem.AC_ATTRIBUTE4;
		aSqlItem.AC_ATTRIBUTE5 := aPlsqlItem.AC_ATTRIBUTE5;
		aSqlItem.AC_ATTRIBUTE6 := aPlsqlItem.AC_ATTRIBUTE6;
		aSqlItem.AC_ATTRIBUTE7 := aPlsqlItem.AC_ATTRIBUTE7;
		aSqlItem.AC_ATTRIBUTE8 := aPlsqlItem.AC_ATTRIBUTE8;
		aSqlItem.AC_ATTRIBUTE9 := aPlsqlItem.AC_ATTRIBUTE9;
		aSqlItem.AC_CONTEXT := aPlsqlItem.AC_CONTEXT;
		aSqlItem.LOCK_CONTROL := aPlsqlItem.LOCK_CONTROL;
		aSqlItem.INVOICED_AMOUNT := aPlsqlItem.INVOICED_AMOUNT;
		RETURN aSqlItem;
	END PL_TO_SQL26;

	FUNCTION SQL_TO_PL26(aSqlItem OE_ORDER_PUB_HEADER_ADJ_REC_T)
	RETURN OE_ORDER_PUB.HEADER_ADJ_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_REC_TYPE;
	BEGIN
		aPlsqlItem.ATTRIBUTE1 := aSqlItem.ATTRIBUTE1;
		aPlsqlItem.ATTRIBUTE10 := aSqlItem.ATTRIBUTE10;
		aPlsqlItem.ATTRIBUTE11 := aSqlItem.ATTRIBUTE11;
		aPlsqlItem.ATTRIBUTE12 := aSqlItem.ATTRIBUTE12;
		aPlsqlItem.ATTRIBUTE13 := aSqlItem.ATTRIBUTE13;
		aPlsqlItem.ATTRIBUTE14 := aSqlItem.ATTRIBUTE14;
		aPlsqlItem.ATTRIBUTE15 := aSqlItem.ATTRIBUTE15;
		aPlsqlItem.ATTRIBUTE2 := aSqlItem.ATTRIBUTE2;
		aPlsqlItem.ATTRIBUTE3 := aSqlItem.ATTRIBUTE3;
		aPlsqlItem.ATTRIBUTE4 := aSqlItem.ATTRIBUTE4;
		aPlsqlItem.ATTRIBUTE5 := aSqlItem.ATTRIBUTE5;
		aPlsqlItem.ATTRIBUTE6 := aSqlItem.ATTRIBUTE6;
		aPlsqlItem.ATTRIBUTE7 := aSqlItem.ATTRIBUTE7;
		aPlsqlItem.ATTRIBUTE8 := aSqlItem.ATTRIBUTE8;
		aPlsqlItem.ATTRIBUTE9 := aSqlItem.ATTRIBUTE9;
		aPlsqlItem.AUTOMATIC_FLAG := aSqlItem.AUTOMATIC_FLAG;
		aPlsqlItem.CONTEXT := aSqlItem.CONTEXT;
		aPlsqlItem.CREATED_BY := aSqlItem.CREATED_BY;
		aPlsqlItem.CREATION_DATE := aSqlItem.CREATION_DATE;
		aPlsqlItem.DISCOUNT_ID := aSqlItem.DISCOUNT_ID;
		aPlsqlItem.DISCOUNT_LINE_ID := aSqlItem.DISCOUNT_LINE_ID;
		aPlsqlItem.HEADER_ID := aSqlItem.HEADER_ID;
		aPlsqlItem.LAST_UPDATED_BY := aSqlItem.LAST_UPDATED_BY;
		aPlsqlItem.LAST_UPDATE_DATE := aSqlItem.LAST_UPDATE_DATE;
		aPlsqlItem.LAST_UPDATE_LOGIN := aSqlItem.LAST_UPDATE_LOGIN;
		aPlsqlItem.LINE_ID := aSqlItem.LINE_ID;
		aPlsqlItem.PERCENT := aSqlItem.PERCENT;
		aPlsqlItem.PRICE_ADJUSTMENT_ID := aSqlItem.PRICE_ADJUSTMENT_ID;
		aPlsqlItem.PROGRAM_APPLICATION_ID := aSqlItem.PROGRAM_APPLICATION_ID;
		aPlsqlItem.PROGRAM_ID := aSqlItem.PROGRAM_ID;
		aPlsqlItem.PROGRAM_UPDATE_DATE := aSqlItem.PROGRAM_UPDATE_DATE;
		aPlsqlItem.REQUEST_ID := aSqlItem.REQUEST_ID;
		aPlsqlItem.RETURN_STATUS := aSqlItem.RETURN_STATUS;
		aPlsqlItem.DB_FLAG := aSqlItem.DB_FLAG;
		aPlsqlItem.OPERATION := aSqlItem.OPERATION;
		aPlsqlItem.ORIG_SYS_DISCOUNT_REF := aSqlItem.ORIG_SYS_DISCOUNT_REF;
		aPlsqlItem.CHANGE_REQUEST_CODE := aSqlItem.CHANGE_REQUEST_CODE;
		aPlsqlItem.STATUS_FLAG := aSqlItem.STATUS_FLAG;
		aPlsqlItem.LIST_HEADER_ID := aSqlItem.LIST_HEADER_ID;
		aPlsqlItem.LIST_LINE_ID := aSqlItem.LIST_LINE_ID;
		aPlsqlItem.LIST_LINE_TYPE_CODE := aSqlItem.LIST_LINE_TYPE_CODE;
		aPlsqlItem.MODIFIER_MECHANISM_TYPE_CODE := aSqlItem.MODIFIER_MECHANISM_TYPE_CODE;
		aPlsqlItem.MODIFIED_FROM := aSqlItem.MODIFIED_FROM;
		aPlsqlItem.MODIFIED_TO := aSqlItem.MODIFIED_TO;
		aPlsqlItem.UPDATED_FLAG := aSqlItem.UPDATED_FLAG;
		aPlsqlItem.UPDATE_ALLOWED := aSqlItem.UPDATE_ALLOWED;
		aPlsqlItem.APPLIED_FLAG := aSqlItem.APPLIED_FLAG;
		aPlsqlItem.CHANGE_REASON_CODE := aSqlItem.CHANGE_REASON_CODE;
		aPlsqlItem.CHANGE_REASON_TEXT := aSqlItem.CHANGE_REASON_TEXT;
		aPlsqlItem.OPERAND := aSqlItem.OPERAND;
		aPlsqlItem.OPERAND_PER_PQTY := aSqlItem.OPERAND_PER_PQTY;
		aPlsqlItem.ARITHMETIC_OPERATOR := aSqlItem.ARITHMETIC_OPERATOR;
		aPlsqlItem.COST_ID := aSqlItem.COST_ID;
		aPlsqlItem.TAX_CODE := aSqlItem.TAX_CODE;
		aPlsqlItem.TAX_EXEMPT_FLAG := aSqlItem.TAX_EXEMPT_FLAG;
		aPlsqlItem.TAX_EXEMPT_NUMBER := aSqlItem.TAX_EXEMPT_NUMBER;
		aPlsqlItem.TAX_EXEMPT_REASON_CODE := aSqlItem.TAX_EXEMPT_REASON_CODE;
		aPlsqlItem.PARENT_ADJUSTMENT_ID := aSqlItem.PARENT_ADJUSTMENT_ID;
		aPlsqlItem.INVOICED_FLAG := aSqlItem.INVOICED_FLAG;
		aPlsqlItem.ESTIMATED_FLAG := aSqlItem.ESTIMATED_FLAG;
		aPlsqlItem.INC_IN_SALES_PERFORMANCE := aSqlItem.INC_IN_SALES_PERFORMANCE;
		aPlsqlItem.SPLIT_ACTION_CODE := aSqlItem.SPLIT_ACTION_CODE;
		aPlsqlItem.ADJUSTED_AMOUNT := aSqlItem.ADJUSTED_AMOUNT;
		aPlsqlItem.ADJUSTED_AMOUNT_PER_PQTY := aSqlItem.ADJUSTED_AMOUNT_PER_PQTY;
		aPlsqlItem.PRICING_PHASE_ID := aSqlItem.PRICING_PHASE_ID;
		aPlsqlItem.CHARGE_TYPE_CODE := aSqlItem.CHARGE_TYPE_CODE;
		aPlsqlItem.CHARGE_SUBTYPE_CODE := aSqlItem.CHARGE_SUBTYPE_CODE;
		aPlsqlItem.LIST_LINE_NO := aSqlItem.LIST_LINE_NO;
		aPlsqlItem.SOURCE_SYSTEM_CODE := aSqlItem.SOURCE_SYSTEM_CODE;
		aPlsqlItem.BENEFIT_QTY := aSqlItem.BENEFIT_QTY;
		aPlsqlItem.BENEFIT_UOM_CODE := aSqlItem.BENEFIT_UOM_CODE;
		aPlsqlItem.PRINT_ON_INVOICE_FLAG := aSqlItem.PRINT_ON_INVOICE_FLAG;
		aPlsqlItem.EXPIRATION_DATE := aSqlItem.EXPIRATION_DATE;
		aPlsqlItem.REBATE_TRANSACTION_TYPE_CODE := aSqlItem.REBATE_TRANSACTION_TYPE_CODE;
		aPlsqlItem.REBATE_TRANSACTION_REFERENCE := aSqlItem.REBATE_TRANSACTION_REFERENCE;
		aPlsqlItem.REBATE_PAYMENT_SYSTEM_CODE := aSqlItem.REBATE_PAYMENT_SYSTEM_CODE;
		aPlsqlItem.REDEEMED_DATE := aSqlItem.REDEEMED_DATE;
		aPlsqlItem.REDEEMED_FLAG := aSqlItem.REDEEMED_FLAG;
		aPlsqlItem.ACCRUAL_FLAG := aSqlItem.ACCRUAL_FLAG;
		aPlsqlItem.RANGE_BREAK_QUANTITY := aSqlItem.RANGE_BREAK_QUANTITY;
		aPlsqlItem.ACCRUAL_CONVERSION_RATE := aSqlItem.ACCRUAL_CONVERSION_RATE;
		aPlsqlItem.PRICING_GROUP_SEQUENCE := aSqlItem.PRICING_GROUP_SEQUENCE;
		aPlsqlItem.MODIFIER_LEVEL_CODE := aSqlItem.MODIFIER_LEVEL_CODE;
		aPlsqlItem.PRICE_BREAK_TYPE_CODE := aSqlItem.PRICE_BREAK_TYPE_CODE;
		aPlsqlItem.SUBSTITUTION_ATTRIBUTE := aSqlItem.SUBSTITUTION_ATTRIBUTE;
		aPlsqlItem.PRORATION_TYPE_CODE := aSqlItem.PRORATION_TYPE_CODE;
		aPlsqlItem.CREDIT_OR_CHARGE_FLAG := aSqlItem.CREDIT_OR_CHARGE_FLAG;
		aPlsqlItem.INCLUDE_ON_RETURNS_FLAG := aSqlItem.INCLUDE_ON_RETURNS_FLAG;
		aPlsqlItem.AC_ATTRIBUTE1 := aSqlItem.AC_ATTRIBUTE1;
		aPlsqlItem.AC_ATTRIBUTE10 := aSqlItem.AC_ATTRIBUTE10;
		aPlsqlItem.AC_ATTRIBUTE11 := aSqlItem.AC_ATTRIBUTE11;
		aPlsqlItem.AC_ATTRIBUTE12 := aSqlItem.AC_ATTRIBUTE12;
		aPlsqlItem.AC_ATTRIBUTE13 := aSqlItem.AC_ATTRIBUTE13;
		aPlsqlItem.AC_ATTRIBUTE14 := aSqlItem.AC_ATTRIBUTE14;
		aPlsqlItem.AC_ATTRIBUTE15 := aSqlItem.AC_ATTRIBUTE15;
		aPlsqlItem.AC_ATTRIBUTE2 := aSqlItem.AC_ATTRIBUTE2;
		aPlsqlItem.AC_ATTRIBUTE3 := aSqlItem.AC_ATTRIBUTE3;
		aPlsqlItem.AC_ATTRIBUTE4 := aSqlItem.AC_ATTRIBUTE4;
		aPlsqlItem.AC_ATTRIBUTE5 := aSqlItem.AC_ATTRIBUTE5;
		aPlsqlItem.AC_ATTRIBUTE6 := aSqlItem.AC_ATTRIBUTE6;
		aPlsqlItem.AC_ATTRIBUTE7 := aSqlItem.AC_ATTRIBUTE7;
		aPlsqlItem.AC_ATTRIBUTE8 := aSqlItem.AC_ATTRIBUTE8;
		aPlsqlItem.AC_ATTRIBUTE9 := aSqlItem.AC_ATTRIBUTE9;
		aPlsqlItem.AC_CONTEXT := aSqlItem.AC_CONTEXT;
		aPlsqlItem.LOCK_CONTROL := aSqlItem.LOCK_CONTROL;
		aPlsqlItem.INVOICED_AMOUNT := aSqlItem.INVOICED_AMOUNT;
		RETURN aPlsqlItem;
	END SQL_TO_PL26;

	FUNCTION PL_TO_SQL3(aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_TBL_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_ADJ_TBL_T IS
	aSqlItem OE_ORDER_PUB_HEADER_ADJ_TBL_T;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_ADJ_TBL_T();
        IF aPlsqlItem.COUNT > 0 THEN
		    aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			    aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL26(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL3;

	FUNCTION SQL_TO_PL3(aSqlItem OE_ORDER_PUB_HEADER_ADJ_TBL_T)
	RETURN OE_ORDER_PUB.HEADER_ADJ_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_TBL_TYPE;
	BEGIN
        -- Exception handler added to take care of the exception of
        -- uninitialized collection.
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL26(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL3;

	FUNCTION PL_TO_SQL27(aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_VAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_ADJ_VAL_R IS
	aSqlItem OE_ORDER_PUB_HEADER_ADJ_VAL_R;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_ADJ_VAL_R(NULL, NULL, NULL);
		aSqlItem.DISCOUNT := aPlsqlItem.DISCOUNT;
		aSqlItem.LIST_NAME := aPlsqlItem.LIST_NAME;
		aSqlItem.VERSION_NO := aPlsqlItem.VERSION_NO;
		RETURN aSqlItem;
	END PL_TO_SQL27;

	FUNCTION SQL_TO_PL27(aSqlItem OE_ORDER_PUB_HEADER_ADJ_VAL_R)
	RETURN OE_ORDER_PUB.HEADER_ADJ_VAL_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_VAL_REC_TYPE;
	BEGIN
		aPlsqlItem.DISCOUNT := aSqlItem.DISCOUNT;
		aPlsqlItem.LIST_NAME := aSqlItem.LIST_NAME;
		aPlsqlItem.VERSION_NO := aSqlItem.VERSION_NO;
		RETURN aPlsqlItem;
	END SQL_TO_PL27;

	FUNCTION PL_TO_SQL4(aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_VAL_TBL_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_ADJ_VAL_T IS
	aSqlItem OE_ORDER_PUB_HEADER_ADJ_VAL_T;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_ADJ_VAL_T();
        IF aPlsqlItem.COUNT > 0 THEN
		    aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			    aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL27(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL4;

	FUNCTION SQL_TO_PL4(aSqlItem OE_ORDER_PUB_HEADER_ADJ_VAL_T)
	RETURN OE_ORDER_PUB.HEADER_ADJ_VAL_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_VAL_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL27(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL4;

	FUNCTION PL_TO_SQL28(aPlsqlItem OE_ORDER_PUB.HEADER_PRICE_ATT_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_PRICE_AT6 IS
	aSqlItem OE_ORDER_PUB_HEADER_PRICE_AT6;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_PRICE_AT6(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.ORDER_PRICE_ATTRIB_ID := aPlsqlItem.ORDER_PRICE_ATTRIB_ID;
		aSqlItem.HEADER_ID := aPlsqlItem.HEADER_ID;
		aSqlItem.LINE_ID := aPlsqlItem.LINE_ID;
		aSqlItem.CREATION_DATE := aPlsqlItem.CREATION_DATE;
		aSqlItem.CREATED_BY := aPlsqlItem.CREATED_BY;
		aSqlItem.LAST_UPDATE_DATE := aPlsqlItem.LAST_UPDATE_DATE;
		aSqlItem.LAST_UPDATED_BY := aPlsqlItem.LAST_UPDATED_BY;
		aSqlItem.LAST_UPDATE_LOGIN := aPlsqlItem.LAST_UPDATE_LOGIN;
		aSqlItem.PROGRAM_APPLICATION_ID := aPlsqlItem.PROGRAM_APPLICATION_ID;
		aSqlItem.PROGRAM_ID := aPlsqlItem.PROGRAM_ID;
		aSqlItem.PROGRAM_UPDATE_DATE := aPlsqlItem.PROGRAM_UPDATE_DATE;
		aSqlItem.REQUEST_ID := aPlsqlItem.REQUEST_ID;
		aSqlItem.FLEX_TITLE := aPlsqlItem.FLEX_TITLE;
		aSqlItem.PRICING_CONTEXT := aPlsqlItem.PRICING_CONTEXT;
		aSqlItem.PRICING_ATTRIBUTE1 := aPlsqlItem.PRICING_ATTRIBUTE1;
		aSqlItem.PRICING_ATTRIBUTE2 := aPlsqlItem.PRICING_ATTRIBUTE2;
		aSqlItem.PRICING_ATTRIBUTE3 := aPlsqlItem.PRICING_ATTRIBUTE3;
		aSqlItem.PRICING_ATTRIBUTE4 := aPlsqlItem.PRICING_ATTRIBUTE4;
		aSqlItem.PRICING_ATTRIBUTE5 := aPlsqlItem.PRICING_ATTRIBUTE5;
		aSqlItem.PRICING_ATTRIBUTE6 := aPlsqlItem.PRICING_ATTRIBUTE6;
		aSqlItem.PRICING_ATTRIBUTE7 := aPlsqlItem.PRICING_ATTRIBUTE7;
		aSqlItem.PRICING_ATTRIBUTE8 := aPlsqlItem.PRICING_ATTRIBUTE8;
		aSqlItem.PRICING_ATTRIBUTE9 := aPlsqlItem.PRICING_ATTRIBUTE9;
		aSqlItem.PRICING_ATTRIBUTE10 := aPlsqlItem.PRICING_ATTRIBUTE10;
		aSqlItem.PRICING_ATTRIBUTE11 := aPlsqlItem.PRICING_ATTRIBUTE11;
		aSqlItem.PRICING_ATTRIBUTE12 := aPlsqlItem.PRICING_ATTRIBUTE12;
		aSqlItem.PRICING_ATTRIBUTE13 := aPlsqlItem.PRICING_ATTRIBUTE13;
		aSqlItem.PRICING_ATTRIBUTE14 := aPlsqlItem.PRICING_ATTRIBUTE14;
		aSqlItem.PRICING_ATTRIBUTE15 := aPlsqlItem.PRICING_ATTRIBUTE15;
		aSqlItem.PRICING_ATTRIBUTE16 := aPlsqlItem.PRICING_ATTRIBUTE16;
		aSqlItem.PRICING_ATTRIBUTE17 := aPlsqlItem.PRICING_ATTRIBUTE17;
		aSqlItem.PRICING_ATTRIBUTE18 := aPlsqlItem.PRICING_ATTRIBUTE18;
		aSqlItem.PRICING_ATTRIBUTE19 := aPlsqlItem.PRICING_ATTRIBUTE19;
		aSqlItem.PRICING_ATTRIBUTE20 := aPlsqlItem.PRICING_ATTRIBUTE20;
		aSqlItem.PRICING_ATTRIBUTE21 := aPlsqlItem.PRICING_ATTRIBUTE21;
		aSqlItem.PRICING_ATTRIBUTE22 := aPlsqlItem.PRICING_ATTRIBUTE22;
		aSqlItem.PRICING_ATTRIBUTE23 := aPlsqlItem.PRICING_ATTRIBUTE23;
		aSqlItem.PRICING_ATTRIBUTE24 := aPlsqlItem.PRICING_ATTRIBUTE24;
		aSqlItem.PRICING_ATTRIBUTE25 := aPlsqlItem.PRICING_ATTRIBUTE25;
		aSqlItem.PRICING_ATTRIBUTE26 := aPlsqlItem.PRICING_ATTRIBUTE26;
		aSqlItem.PRICING_ATTRIBUTE27 := aPlsqlItem.PRICING_ATTRIBUTE27;
		aSqlItem.PRICING_ATTRIBUTE28 := aPlsqlItem.PRICING_ATTRIBUTE28;
		aSqlItem.PRICING_ATTRIBUTE29 := aPlsqlItem.PRICING_ATTRIBUTE29;
		aSqlItem.PRICING_ATTRIBUTE30 := aPlsqlItem.PRICING_ATTRIBUTE30;
		aSqlItem.PRICING_ATTRIBUTE31 := aPlsqlItem.PRICING_ATTRIBUTE31;
		aSqlItem.PRICING_ATTRIBUTE32 := aPlsqlItem.PRICING_ATTRIBUTE32;
		aSqlItem.PRICING_ATTRIBUTE33 := aPlsqlItem.PRICING_ATTRIBUTE33;
		aSqlItem.PRICING_ATTRIBUTE34 := aPlsqlItem.PRICING_ATTRIBUTE34;
		aSqlItem.PRICING_ATTRIBUTE35 := aPlsqlItem.PRICING_ATTRIBUTE35;
		aSqlItem.PRICING_ATTRIBUTE36 := aPlsqlItem.PRICING_ATTRIBUTE36;
		aSqlItem.PRICING_ATTRIBUTE37 := aPlsqlItem.PRICING_ATTRIBUTE37;
		aSqlItem.PRICING_ATTRIBUTE38 := aPlsqlItem.PRICING_ATTRIBUTE38;
		aSqlItem.PRICING_ATTRIBUTE39 := aPlsqlItem.PRICING_ATTRIBUTE39;
		aSqlItem.PRICING_ATTRIBUTE40 := aPlsqlItem.PRICING_ATTRIBUTE40;
		aSqlItem.PRICING_ATTRIBUTE41 := aPlsqlItem.PRICING_ATTRIBUTE41;
		aSqlItem.PRICING_ATTRIBUTE42 := aPlsqlItem.PRICING_ATTRIBUTE42;
		aSqlItem.PRICING_ATTRIBUTE43 := aPlsqlItem.PRICING_ATTRIBUTE43;
		aSqlItem.PRICING_ATTRIBUTE44 := aPlsqlItem.PRICING_ATTRIBUTE44;
		aSqlItem.PRICING_ATTRIBUTE45 := aPlsqlItem.PRICING_ATTRIBUTE45;
		aSqlItem.PRICING_ATTRIBUTE46 := aPlsqlItem.PRICING_ATTRIBUTE46;
		aSqlItem.PRICING_ATTRIBUTE47 := aPlsqlItem.PRICING_ATTRIBUTE47;
		aSqlItem.PRICING_ATTRIBUTE48 := aPlsqlItem.PRICING_ATTRIBUTE48;
		aSqlItem.PRICING_ATTRIBUTE49 := aPlsqlItem.PRICING_ATTRIBUTE49;
		aSqlItem.PRICING_ATTRIBUTE50 := aPlsqlItem.PRICING_ATTRIBUTE50;
		aSqlItem.PRICING_ATTRIBUTE51 := aPlsqlItem.PRICING_ATTRIBUTE51;
		aSqlItem.PRICING_ATTRIBUTE52 := aPlsqlItem.PRICING_ATTRIBUTE52;
		aSqlItem.PRICING_ATTRIBUTE53 := aPlsqlItem.PRICING_ATTRIBUTE53;
		aSqlItem.PRICING_ATTRIBUTE54 := aPlsqlItem.PRICING_ATTRIBUTE54;
		aSqlItem.PRICING_ATTRIBUTE55 := aPlsqlItem.PRICING_ATTRIBUTE55;
		aSqlItem.PRICING_ATTRIBUTE56 := aPlsqlItem.PRICING_ATTRIBUTE56;
		aSqlItem.PRICING_ATTRIBUTE57 := aPlsqlItem.PRICING_ATTRIBUTE57;
		aSqlItem.PRICING_ATTRIBUTE58 := aPlsqlItem.PRICING_ATTRIBUTE58;
		aSqlItem.PRICING_ATTRIBUTE59 := aPlsqlItem.PRICING_ATTRIBUTE59;
		aSqlItem.PRICING_ATTRIBUTE60 := aPlsqlItem.PRICING_ATTRIBUTE60;
		aSqlItem.PRICING_ATTRIBUTE61 := aPlsqlItem.PRICING_ATTRIBUTE61;
		aSqlItem.PRICING_ATTRIBUTE62 := aPlsqlItem.PRICING_ATTRIBUTE62;
		aSqlItem.PRICING_ATTRIBUTE63 := aPlsqlItem.PRICING_ATTRIBUTE63;
		aSqlItem.PRICING_ATTRIBUTE64 := aPlsqlItem.PRICING_ATTRIBUTE64;
		aSqlItem.PRICING_ATTRIBUTE65 := aPlsqlItem.PRICING_ATTRIBUTE65;
		aSqlItem.PRICING_ATTRIBUTE66 := aPlsqlItem.PRICING_ATTRIBUTE66;
		aSqlItem.PRICING_ATTRIBUTE67 := aPlsqlItem.PRICING_ATTRIBUTE67;
		aSqlItem.PRICING_ATTRIBUTE68 := aPlsqlItem.PRICING_ATTRIBUTE68;
		aSqlItem.PRICING_ATTRIBUTE69 := aPlsqlItem.PRICING_ATTRIBUTE69;
		aSqlItem.PRICING_ATTRIBUTE70 := aPlsqlItem.PRICING_ATTRIBUTE70;
		aSqlItem.PRICING_ATTRIBUTE71 := aPlsqlItem.PRICING_ATTRIBUTE71;
		aSqlItem.PRICING_ATTRIBUTE72 := aPlsqlItem.PRICING_ATTRIBUTE72;
		aSqlItem.PRICING_ATTRIBUTE73 := aPlsqlItem.PRICING_ATTRIBUTE73;
		aSqlItem.PRICING_ATTRIBUTE74 := aPlsqlItem.PRICING_ATTRIBUTE74;
		aSqlItem.PRICING_ATTRIBUTE75 := aPlsqlItem.PRICING_ATTRIBUTE75;
		aSqlItem.PRICING_ATTRIBUTE76 := aPlsqlItem.PRICING_ATTRIBUTE76;
		aSqlItem.PRICING_ATTRIBUTE77 := aPlsqlItem.PRICING_ATTRIBUTE77;
		aSqlItem.PRICING_ATTRIBUTE78 := aPlsqlItem.PRICING_ATTRIBUTE78;
		aSqlItem.PRICING_ATTRIBUTE79 := aPlsqlItem.PRICING_ATTRIBUTE79;
		aSqlItem.PRICING_ATTRIBUTE80 := aPlsqlItem.PRICING_ATTRIBUTE80;
		aSqlItem.PRICING_ATTRIBUTE81 := aPlsqlItem.PRICING_ATTRIBUTE81;
		aSqlItem.PRICING_ATTRIBUTE82 := aPlsqlItem.PRICING_ATTRIBUTE82;
		aSqlItem.PRICING_ATTRIBUTE83 := aPlsqlItem.PRICING_ATTRIBUTE83;
		aSqlItem.PRICING_ATTRIBUTE84 := aPlsqlItem.PRICING_ATTRIBUTE84;
		aSqlItem.PRICING_ATTRIBUTE85 := aPlsqlItem.PRICING_ATTRIBUTE85;
		aSqlItem.PRICING_ATTRIBUTE86 := aPlsqlItem.PRICING_ATTRIBUTE86;
		aSqlItem.PRICING_ATTRIBUTE87 := aPlsqlItem.PRICING_ATTRIBUTE87;
		aSqlItem.PRICING_ATTRIBUTE88 := aPlsqlItem.PRICING_ATTRIBUTE88;
		aSqlItem.PRICING_ATTRIBUTE89 := aPlsqlItem.PRICING_ATTRIBUTE89;
		aSqlItem.PRICING_ATTRIBUTE90 := aPlsqlItem.PRICING_ATTRIBUTE90;
		aSqlItem.PRICING_ATTRIBUTE91 := aPlsqlItem.PRICING_ATTRIBUTE91;
		aSqlItem.PRICING_ATTRIBUTE92 := aPlsqlItem.PRICING_ATTRIBUTE92;
		aSqlItem.PRICING_ATTRIBUTE93 := aPlsqlItem.PRICING_ATTRIBUTE93;
		aSqlItem.PRICING_ATTRIBUTE94 := aPlsqlItem.PRICING_ATTRIBUTE94;
		aSqlItem.PRICING_ATTRIBUTE95 := aPlsqlItem.PRICING_ATTRIBUTE95;
		aSqlItem.PRICING_ATTRIBUTE96 := aPlsqlItem.PRICING_ATTRIBUTE96;
		aSqlItem.PRICING_ATTRIBUTE97 := aPlsqlItem.PRICING_ATTRIBUTE97;
		aSqlItem.PRICING_ATTRIBUTE98 := aPlsqlItem.PRICING_ATTRIBUTE98;
		aSqlItem.PRICING_ATTRIBUTE99 := aPlsqlItem.PRICING_ATTRIBUTE99;
		aSqlItem.PRICING_ATTRIBUTE100 := aPlsqlItem.PRICING_ATTRIBUTE100;
		aSqlItem.CONTEXT := aPlsqlItem.CONTEXT;
		aSqlItem.ATTRIBUTE1 := aPlsqlItem.ATTRIBUTE1;
		aSqlItem.ATTRIBUTE2 := aPlsqlItem.ATTRIBUTE2;
		aSqlItem.ATTRIBUTE3 := aPlsqlItem.ATTRIBUTE3;
		aSqlItem.ATTRIBUTE4 := aPlsqlItem.ATTRIBUTE4;
		aSqlItem.ATTRIBUTE5 := aPlsqlItem.ATTRIBUTE5;
		aSqlItem.ATTRIBUTE6 := aPlsqlItem.ATTRIBUTE6;
		aSqlItem.ATTRIBUTE7 := aPlsqlItem.ATTRIBUTE7;
		aSqlItem.ATTRIBUTE8 := aPlsqlItem.ATTRIBUTE8;
		aSqlItem.ATTRIBUTE9 := aPlsqlItem.ATTRIBUTE9;
		aSqlItem.ATTRIBUTE10 := aPlsqlItem.ATTRIBUTE10;
		aSqlItem.ATTRIBUTE11 := aPlsqlItem.ATTRIBUTE11;
		aSqlItem.ATTRIBUTE12 := aPlsqlItem.ATTRIBUTE12;
		aSqlItem.ATTRIBUTE13 := aPlsqlItem.ATTRIBUTE13;
		aSqlItem.ATTRIBUTE14 := aPlsqlItem.ATTRIBUTE14;
		aSqlItem.ATTRIBUTE15 := aPlsqlItem.ATTRIBUTE15;
		aSqlItem.OVERRIDE_FLAG := aPlsqlItem.OVERRIDE_FLAG;
		aSqlItem.RETURN_STATUS := aPlsqlItem.RETURN_STATUS;
		aSqlItem.DB_FLAG := aPlsqlItem.DB_FLAG;
		aSqlItem.OPERATION := aPlsqlItem.OPERATION;
		aSqlItem.LOCK_CONTROL := aPlsqlItem.LOCK_CONTROL;
		aSqlItem.ORIG_SYS_ATTS_REF := aPlsqlItem.ORIG_SYS_ATTS_REF;
		aSqlItem.CHANGE_REQUEST_CODE := aPlsqlItem.CHANGE_REQUEST_CODE;
		RETURN aSqlItem;
	END PL_TO_SQL28;

	FUNCTION SQL_TO_PL28(aSqlItem OE_ORDER_PUB_HEADER_PRICE_AT6)
	RETURN OE_ORDER_PUB.HEADER_PRICE_ATT_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_PRICE_ATT_REC_TYPE;
	BEGIN
		aPlsqlItem.ORDER_PRICE_ATTRIB_ID := aSqlItem.ORDER_PRICE_ATTRIB_ID;
		aPlsqlItem.HEADER_ID := aSqlItem.HEADER_ID;
		aPlsqlItem.LINE_ID := aSqlItem.LINE_ID;
		aPlsqlItem.CREATION_DATE := aSqlItem.CREATION_DATE;
		aPlsqlItem.CREATED_BY := aSqlItem.CREATED_BY;
		aPlsqlItem.LAST_UPDATE_DATE := aSqlItem.LAST_UPDATE_DATE;
		aPlsqlItem.LAST_UPDATED_BY := aSqlItem.LAST_UPDATED_BY;
		aPlsqlItem.LAST_UPDATE_LOGIN := aSqlItem.LAST_UPDATE_LOGIN;
		aPlsqlItem.PROGRAM_APPLICATION_ID := aSqlItem.PROGRAM_APPLICATION_ID;
		aPlsqlItem.PROGRAM_ID := aSqlItem.PROGRAM_ID;
		aPlsqlItem.PROGRAM_UPDATE_DATE := aSqlItem.PROGRAM_UPDATE_DATE;
		aPlsqlItem.REQUEST_ID := aSqlItem.REQUEST_ID;
		aPlsqlItem.FLEX_TITLE := aSqlItem.FLEX_TITLE;
		aPlsqlItem.PRICING_CONTEXT := aSqlItem.PRICING_CONTEXT;
		aPlsqlItem.PRICING_ATTRIBUTE1 := aSqlItem.PRICING_ATTRIBUTE1;
		aPlsqlItem.PRICING_ATTRIBUTE2 := aSqlItem.PRICING_ATTRIBUTE2;
		aPlsqlItem.PRICING_ATTRIBUTE3 := aSqlItem.PRICING_ATTRIBUTE3;
		aPlsqlItem.PRICING_ATTRIBUTE4 := aSqlItem.PRICING_ATTRIBUTE4;
		aPlsqlItem.PRICING_ATTRIBUTE5 := aSqlItem.PRICING_ATTRIBUTE5;
		aPlsqlItem.PRICING_ATTRIBUTE6 := aSqlItem.PRICING_ATTRIBUTE6;
		aPlsqlItem.PRICING_ATTRIBUTE7 := aSqlItem.PRICING_ATTRIBUTE7;
		aPlsqlItem.PRICING_ATTRIBUTE8 := aSqlItem.PRICING_ATTRIBUTE8;
		aPlsqlItem.PRICING_ATTRIBUTE9 := aSqlItem.PRICING_ATTRIBUTE9;
		aPlsqlItem.PRICING_ATTRIBUTE10 := aSqlItem.PRICING_ATTRIBUTE10;
		aPlsqlItem.PRICING_ATTRIBUTE11 := aSqlItem.PRICING_ATTRIBUTE11;
		aPlsqlItem.PRICING_ATTRIBUTE12 := aSqlItem.PRICING_ATTRIBUTE12;
		aPlsqlItem.PRICING_ATTRIBUTE13 := aSqlItem.PRICING_ATTRIBUTE13;
		aPlsqlItem.PRICING_ATTRIBUTE14 := aSqlItem.PRICING_ATTRIBUTE14;
		aPlsqlItem.PRICING_ATTRIBUTE15 := aSqlItem.PRICING_ATTRIBUTE15;
		aPlsqlItem.PRICING_ATTRIBUTE16 := aSqlItem.PRICING_ATTRIBUTE16;
		aPlsqlItem.PRICING_ATTRIBUTE17 := aSqlItem.PRICING_ATTRIBUTE17;
		aPlsqlItem.PRICING_ATTRIBUTE18 := aSqlItem.PRICING_ATTRIBUTE18;
		aPlsqlItem.PRICING_ATTRIBUTE19 := aSqlItem.PRICING_ATTRIBUTE19;
		aPlsqlItem.PRICING_ATTRIBUTE20 := aSqlItem.PRICING_ATTRIBUTE20;
		aPlsqlItem.PRICING_ATTRIBUTE21 := aSqlItem.PRICING_ATTRIBUTE21;
		aPlsqlItem.PRICING_ATTRIBUTE22 := aSqlItem.PRICING_ATTRIBUTE22;
		aPlsqlItem.PRICING_ATTRIBUTE23 := aSqlItem.PRICING_ATTRIBUTE23;
		aPlsqlItem.PRICING_ATTRIBUTE24 := aSqlItem.PRICING_ATTRIBUTE24;
		aPlsqlItem.PRICING_ATTRIBUTE25 := aSqlItem.PRICING_ATTRIBUTE25;
		aPlsqlItem.PRICING_ATTRIBUTE26 := aSqlItem.PRICING_ATTRIBUTE26;
		aPlsqlItem.PRICING_ATTRIBUTE27 := aSqlItem.PRICING_ATTRIBUTE27;
		aPlsqlItem.PRICING_ATTRIBUTE28 := aSqlItem.PRICING_ATTRIBUTE28;
		aPlsqlItem.PRICING_ATTRIBUTE29 := aSqlItem.PRICING_ATTRIBUTE29;
		aPlsqlItem.PRICING_ATTRIBUTE30 := aSqlItem.PRICING_ATTRIBUTE30;
		aPlsqlItem.PRICING_ATTRIBUTE31 := aSqlItem.PRICING_ATTRIBUTE31;
		aPlsqlItem.PRICING_ATTRIBUTE32 := aSqlItem.PRICING_ATTRIBUTE32;
		aPlsqlItem.PRICING_ATTRIBUTE33 := aSqlItem.PRICING_ATTRIBUTE33;
		aPlsqlItem.PRICING_ATTRIBUTE34 := aSqlItem.PRICING_ATTRIBUTE34;
		aPlsqlItem.PRICING_ATTRIBUTE35 := aSqlItem.PRICING_ATTRIBUTE35;
		aPlsqlItem.PRICING_ATTRIBUTE36 := aSqlItem.PRICING_ATTRIBUTE36;
		aPlsqlItem.PRICING_ATTRIBUTE37 := aSqlItem.PRICING_ATTRIBUTE37;
		aPlsqlItem.PRICING_ATTRIBUTE38 := aSqlItem.PRICING_ATTRIBUTE38;
		aPlsqlItem.PRICING_ATTRIBUTE39 := aSqlItem.PRICING_ATTRIBUTE39;
		aPlsqlItem.PRICING_ATTRIBUTE40 := aSqlItem.PRICING_ATTRIBUTE40;
		aPlsqlItem.PRICING_ATTRIBUTE41 := aSqlItem.PRICING_ATTRIBUTE41;
		aPlsqlItem.PRICING_ATTRIBUTE42 := aSqlItem.PRICING_ATTRIBUTE42;
		aPlsqlItem.PRICING_ATTRIBUTE43 := aSqlItem.PRICING_ATTRIBUTE43;
		aPlsqlItem.PRICING_ATTRIBUTE44 := aSqlItem.PRICING_ATTRIBUTE44;
		aPlsqlItem.PRICING_ATTRIBUTE45 := aSqlItem.PRICING_ATTRIBUTE45;
		aPlsqlItem.PRICING_ATTRIBUTE46 := aSqlItem.PRICING_ATTRIBUTE46;
		aPlsqlItem.PRICING_ATTRIBUTE47 := aSqlItem.PRICING_ATTRIBUTE47;
		aPlsqlItem.PRICING_ATTRIBUTE48 := aSqlItem.PRICING_ATTRIBUTE48;
		aPlsqlItem.PRICING_ATTRIBUTE49 := aSqlItem.PRICING_ATTRIBUTE49;
		aPlsqlItem.PRICING_ATTRIBUTE50 := aSqlItem.PRICING_ATTRIBUTE50;
		aPlsqlItem.PRICING_ATTRIBUTE51 := aSqlItem.PRICING_ATTRIBUTE51;
		aPlsqlItem.PRICING_ATTRIBUTE52 := aSqlItem.PRICING_ATTRIBUTE52;
		aPlsqlItem.PRICING_ATTRIBUTE53 := aSqlItem.PRICING_ATTRIBUTE53;
		aPlsqlItem.PRICING_ATTRIBUTE54 := aSqlItem.PRICING_ATTRIBUTE54;
		aPlsqlItem.PRICING_ATTRIBUTE55 := aSqlItem.PRICING_ATTRIBUTE55;
		aPlsqlItem.PRICING_ATTRIBUTE56 := aSqlItem.PRICING_ATTRIBUTE56;
		aPlsqlItem.PRICING_ATTRIBUTE57 := aSqlItem.PRICING_ATTRIBUTE57;
		aPlsqlItem.PRICING_ATTRIBUTE58 := aSqlItem.PRICING_ATTRIBUTE58;
		aPlsqlItem.PRICING_ATTRIBUTE59 := aSqlItem.PRICING_ATTRIBUTE59;
		aPlsqlItem.PRICING_ATTRIBUTE60 := aSqlItem.PRICING_ATTRIBUTE60;
		aPlsqlItem.PRICING_ATTRIBUTE61 := aSqlItem.PRICING_ATTRIBUTE61;
		aPlsqlItem.PRICING_ATTRIBUTE62 := aSqlItem.PRICING_ATTRIBUTE62;
		aPlsqlItem.PRICING_ATTRIBUTE63 := aSqlItem.PRICING_ATTRIBUTE63;
		aPlsqlItem.PRICING_ATTRIBUTE64 := aSqlItem.PRICING_ATTRIBUTE64;
		aPlsqlItem.PRICING_ATTRIBUTE65 := aSqlItem.PRICING_ATTRIBUTE65;
		aPlsqlItem.PRICING_ATTRIBUTE66 := aSqlItem.PRICING_ATTRIBUTE66;
		aPlsqlItem.PRICING_ATTRIBUTE67 := aSqlItem.PRICING_ATTRIBUTE67;
		aPlsqlItem.PRICING_ATTRIBUTE68 := aSqlItem.PRICING_ATTRIBUTE68;
		aPlsqlItem.PRICING_ATTRIBUTE69 := aSqlItem.PRICING_ATTRIBUTE69;
		aPlsqlItem.PRICING_ATTRIBUTE70 := aSqlItem.PRICING_ATTRIBUTE70;
		aPlsqlItem.PRICING_ATTRIBUTE71 := aSqlItem.PRICING_ATTRIBUTE71;
		aPlsqlItem.PRICING_ATTRIBUTE72 := aSqlItem.PRICING_ATTRIBUTE72;
		aPlsqlItem.PRICING_ATTRIBUTE73 := aSqlItem.PRICING_ATTRIBUTE73;
		aPlsqlItem.PRICING_ATTRIBUTE74 := aSqlItem.PRICING_ATTRIBUTE74;
		aPlsqlItem.PRICING_ATTRIBUTE75 := aSqlItem.PRICING_ATTRIBUTE75;
		aPlsqlItem.PRICING_ATTRIBUTE76 := aSqlItem.PRICING_ATTRIBUTE76;
		aPlsqlItem.PRICING_ATTRIBUTE77 := aSqlItem.PRICING_ATTRIBUTE77;
		aPlsqlItem.PRICING_ATTRIBUTE78 := aSqlItem.PRICING_ATTRIBUTE78;
		aPlsqlItem.PRICING_ATTRIBUTE79 := aSqlItem.PRICING_ATTRIBUTE79;
		aPlsqlItem.PRICING_ATTRIBUTE80 := aSqlItem.PRICING_ATTRIBUTE80;
		aPlsqlItem.PRICING_ATTRIBUTE81 := aSqlItem.PRICING_ATTRIBUTE81;
		aPlsqlItem.PRICING_ATTRIBUTE82 := aSqlItem.PRICING_ATTRIBUTE82;
		aPlsqlItem.PRICING_ATTRIBUTE83 := aSqlItem.PRICING_ATTRIBUTE83;
		aPlsqlItem.PRICING_ATTRIBUTE84 := aSqlItem.PRICING_ATTRIBUTE84;
		aPlsqlItem.PRICING_ATTRIBUTE85 := aSqlItem.PRICING_ATTRIBUTE85;
		aPlsqlItem.PRICING_ATTRIBUTE86 := aSqlItem.PRICING_ATTRIBUTE86;
		aPlsqlItem.PRICING_ATTRIBUTE87 := aSqlItem.PRICING_ATTRIBUTE87;
		aPlsqlItem.PRICING_ATTRIBUTE88 := aSqlItem.PRICING_ATTRIBUTE88;
		aPlsqlItem.PRICING_ATTRIBUTE89 := aSqlItem.PRICING_ATTRIBUTE89;
		aPlsqlItem.PRICING_ATTRIBUTE90 := aSqlItem.PRICING_ATTRIBUTE90;
		aPlsqlItem.PRICING_ATTRIBUTE91 := aSqlItem.PRICING_ATTRIBUTE91;
		aPlsqlItem.PRICING_ATTRIBUTE92 := aSqlItem.PRICING_ATTRIBUTE92;
		aPlsqlItem.PRICING_ATTRIBUTE93 := aSqlItem.PRICING_ATTRIBUTE93;
		aPlsqlItem.PRICING_ATTRIBUTE94 := aSqlItem.PRICING_ATTRIBUTE94;
		aPlsqlItem.PRICING_ATTRIBUTE95 := aSqlItem.PRICING_ATTRIBUTE95;
		aPlsqlItem.PRICING_ATTRIBUTE96 := aSqlItem.PRICING_ATTRIBUTE96;
		aPlsqlItem.PRICING_ATTRIBUTE97 := aSqlItem.PRICING_ATTRIBUTE97;
		aPlsqlItem.PRICING_ATTRIBUTE98 := aSqlItem.PRICING_ATTRIBUTE98;
		aPlsqlItem.PRICING_ATTRIBUTE99 := aSqlItem.PRICING_ATTRIBUTE99;
		aPlsqlItem.PRICING_ATTRIBUTE100 := aSqlItem.PRICING_ATTRIBUTE100;
		aPlsqlItem.CONTEXT := aSqlItem.CONTEXT;
		aPlsqlItem.ATTRIBUTE1 := aSqlItem.ATTRIBUTE1;
		aPlsqlItem.ATTRIBUTE2 := aSqlItem.ATTRIBUTE2;
		aPlsqlItem.ATTRIBUTE3 := aSqlItem.ATTRIBUTE3;
		aPlsqlItem.ATTRIBUTE4 := aSqlItem.ATTRIBUTE4;
		aPlsqlItem.ATTRIBUTE5 := aSqlItem.ATTRIBUTE5;
		aPlsqlItem.ATTRIBUTE6 := aSqlItem.ATTRIBUTE6;
		aPlsqlItem.ATTRIBUTE7 := aSqlItem.ATTRIBUTE7;
		aPlsqlItem.ATTRIBUTE8 := aSqlItem.ATTRIBUTE8;
		aPlsqlItem.ATTRIBUTE9 := aSqlItem.ATTRIBUTE9;
		aPlsqlItem.ATTRIBUTE10 := aSqlItem.ATTRIBUTE10;
		aPlsqlItem.ATTRIBUTE11 := aSqlItem.ATTRIBUTE11;
		aPlsqlItem.ATTRIBUTE12 := aSqlItem.ATTRIBUTE12;
		aPlsqlItem.ATTRIBUTE13 := aSqlItem.ATTRIBUTE13;
		aPlsqlItem.ATTRIBUTE14 := aSqlItem.ATTRIBUTE14;
		aPlsqlItem.ATTRIBUTE15 := aSqlItem.ATTRIBUTE15;
		aPlsqlItem.OVERRIDE_FLAG := aSqlItem.OVERRIDE_FLAG;
		aPlsqlItem.RETURN_STATUS := aSqlItem.RETURN_STATUS;
		aPlsqlItem.DB_FLAG := aSqlItem.DB_FLAG;
		aPlsqlItem.OPERATION := aSqlItem.OPERATION;
		aPlsqlItem.LOCK_CONTROL := aSqlItem.LOCK_CONTROL;
		aPlsqlItem.ORIG_SYS_ATTS_REF := aSqlItem.ORIG_SYS_ATTS_REF;
		aPlsqlItem.CHANGE_REQUEST_CODE := aSqlItem.CHANGE_REQUEST_CODE;
		RETURN aPlsqlItem;
	END SQL_TO_PL28;

	FUNCTION PL_TO_SQL5(aPlsqlItem OE_ORDER_PUB.HEADER_PRICE_ATT_TBL_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_PRICE_ATT IS
	aSqlItem OE_ORDER_PUB_HEADER_PRICE_ATT;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_PRICE_ATT();
        IF aPlsqlItem.COUNT > 0 THEN
		    aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL28(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL5;

	FUNCTION SQL_TO_PL5(aSqlItem OE_ORDER_PUB_HEADER_PRICE_ATT)
	RETURN OE_ORDER_PUB.HEADER_PRICE_ATT_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_PRICE_ATT_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL28(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL5;

	FUNCTION PL_TO_SQL29(aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_ATT_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_ADJ_ATT_R IS
	aSqlItem OE_ORDER_PUB_HEADER_ADJ_ATT_R;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_ADJ_ATT_R(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.PRICE_ADJ_ATTRIB_ID := aPlsqlItem.PRICE_ADJ_ATTRIB_ID;
		aSqlItem.PRICE_ADJUSTMENT_ID := aPlsqlItem.PRICE_ADJUSTMENT_ID;
		aSqlItem.ADJ_INDEX := aPlsqlItem.ADJ_INDEX;
		aSqlItem.FLEX_TITLE := aPlsqlItem.FLEX_TITLE;
		aSqlItem.PRICING_CONTEXT := aPlsqlItem.PRICING_CONTEXT;
		aSqlItem.PRICING_ATTRIBUTE := aPlsqlItem.PRICING_ATTRIBUTE;
		aSqlItem.CREATION_DATE := aPlsqlItem.CREATION_DATE;
		aSqlItem.CREATED_BY := aPlsqlItem.CREATED_BY;
		aSqlItem.LAST_UPDATE_DATE := aPlsqlItem.LAST_UPDATE_DATE;
		aSqlItem.LAST_UPDATED_BY := aPlsqlItem.LAST_UPDATED_BY;
		aSqlItem.LAST_UPDATE_LOGIN := aPlsqlItem.LAST_UPDATE_LOGIN;
		aSqlItem.PROGRAM_APPLICATION_ID := aPlsqlItem.PROGRAM_APPLICATION_ID;
		aSqlItem.PROGRAM_ID := aPlsqlItem.PROGRAM_ID;
		aSqlItem.PROGRAM_UPDATE_DATE := aPlsqlItem.PROGRAM_UPDATE_DATE;
		aSqlItem.REQUEST_ID := aPlsqlItem.REQUEST_ID;
		aSqlItem.PRICING_ATTR_VALUE_FROM := aPlsqlItem.PRICING_ATTR_VALUE_FROM;
		aSqlItem.PRICING_ATTR_VALUE_TO := aPlsqlItem.PRICING_ATTR_VALUE_TO;
		aSqlItem.COMPARISON_OPERATOR := aPlsqlItem.COMPARISON_OPERATOR;
		aSqlItem.RETURN_STATUS := aPlsqlItem.RETURN_STATUS;
		aSqlItem.DB_FLAG := aPlsqlItem.DB_FLAG;
		aSqlItem.OPERATION := aPlsqlItem.OPERATION;
		aSqlItem.LOCK_CONTROL := aPlsqlItem.LOCK_CONTROL;
		RETURN aSqlItem;
	END PL_TO_SQL29;

	FUNCTION SQL_TO_PL29(aSqlItem OE_ORDER_PUB_HEADER_ADJ_ATT_R)
	RETURN OE_ORDER_PUB.HEADER_ADJ_ATT_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_ATT_REC_TYPE;
	BEGIN
		aPlsqlItem.PRICE_ADJ_ATTRIB_ID := aSqlItem.PRICE_ADJ_ATTRIB_ID;
		aPlsqlItem.PRICE_ADJUSTMENT_ID := aSqlItem.PRICE_ADJUSTMENT_ID;
		aPlsqlItem.ADJ_INDEX := aSqlItem.ADJ_INDEX;
		aPlsqlItem.FLEX_TITLE := aSqlItem.FLEX_TITLE;
		aPlsqlItem.PRICING_CONTEXT := aSqlItem.PRICING_CONTEXT;
		aPlsqlItem.PRICING_ATTRIBUTE := aSqlItem.PRICING_ATTRIBUTE;
		aPlsqlItem.CREATION_DATE := aSqlItem.CREATION_DATE;
		aPlsqlItem.CREATED_BY := aSqlItem.CREATED_BY;
		aPlsqlItem.LAST_UPDATE_DATE := aSqlItem.LAST_UPDATE_DATE;
		aPlsqlItem.LAST_UPDATED_BY := aSqlItem.LAST_UPDATED_BY;
		aPlsqlItem.LAST_UPDATE_LOGIN := aSqlItem.LAST_UPDATE_LOGIN;
		aPlsqlItem.PROGRAM_APPLICATION_ID := aSqlItem.PROGRAM_APPLICATION_ID;
		aPlsqlItem.PROGRAM_ID := aSqlItem.PROGRAM_ID;
		aPlsqlItem.PROGRAM_UPDATE_DATE := aSqlItem.PROGRAM_UPDATE_DATE;
		aPlsqlItem.REQUEST_ID := aSqlItem.REQUEST_ID;
		aPlsqlItem.PRICING_ATTR_VALUE_FROM := aSqlItem.PRICING_ATTR_VALUE_FROM;
		aPlsqlItem.PRICING_ATTR_VALUE_TO := aSqlItem.PRICING_ATTR_VALUE_TO;
		aPlsqlItem.COMPARISON_OPERATOR := aSqlItem.COMPARISON_OPERATOR;
		aPlsqlItem.RETURN_STATUS := aSqlItem.RETURN_STATUS;
		aPlsqlItem.DB_FLAG := aSqlItem.DB_FLAG;
		aPlsqlItem.OPERATION := aSqlItem.OPERATION;
		aPlsqlItem.LOCK_CONTROL := aSqlItem.LOCK_CONTROL;
		RETURN aPlsqlItem;
	END SQL_TO_PL29;

	FUNCTION PL_TO_SQL6(aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_ATT_TBL_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_ADJ_ATT_T IS
	aSqlItem OE_ORDER_PUB_HEADER_ADJ_ATT_T;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_ADJ_ATT_T();
        IF aPlsqlItem.COUNT > 0 THEN
		    aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			    aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL29(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL6;

	FUNCTION SQL_TO_PL6(aSqlItem OE_ORDER_PUB_HEADER_ADJ_ATT_T)
	RETURN OE_ORDER_PUB.HEADER_ADJ_ATT_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_ATT_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL29(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL6;

	FUNCTION PL_TO_SQL30(aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_ASSOC_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_ADJ_ASSO6 IS
	aSqlItem OE_ORDER_PUB_HEADER_ADJ_ASSO6;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_ADJ_ASSO6(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.PRICE_ADJ_ASSOC_ID := aPlsqlItem.PRICE_ADJ_ASSOC_ID;
		aSqlItem.LINE_ID := aPlsqlItem.LINE_ID;
		aSqlItem.LINE_INDEX := aPlsqlItem.LINE_INDEX;
		aSqlItem.PRICE_ADJUSTMENT_ID := aPlsqlItem.PRICE_ADJUSTMENT_ID;
		aSqlItem.ADJ_INDEX := aPlsqlItem.ADJ_INDEX;
		aSqlItem.RLTD_PRICE_ADJ_ID := aPlsqlItem.RLTD_PRICE_ADJ_ID;
		aSqlItem.RLTD_ADJ_INDEX := aPlsqlItem.RLTD_ADJ_INDEX;
		aSqlItem.CREATION_DATE := aPlsqlItem.CREATION_DATE;
		aSqlItem.CREATED_BY := aPlsqlItem.CREATED_BY;
		aSqlItem.LAST_UPDATE_DATE := aPlsqlItem.LAST_UPDATE_DATE;
		aSqlItem.LAST_UPDATED_BY := aPlsqlItem.LAST_UPDATED_BY;
		aSqlItem.LAST_UPDATE_LOGIN := aPlsqlItem.LAST_UPDATE_LOGIN;
		aSqlItem.PROGRAM_APPLICATION_ID := aPlsqlItem.PROGRAM_APPLICATION_ID;
		aSqlItem.PROGRAM_ID := aPlsqlItem.PROGRAM_ID;
		aSqlItem.PROGRAM_UPDATE_DATE := aPlsqlItem.PROGRAM_UPDATE_DATE;
		aSqlItem.REQUEST_ID := aPlsqlItem.REQUEST_ID;
		aSqlItem.RETURN_STATUS := aPlsqlItem.RETURN_STATUS;
		aSqlItem.DB_FLAG := aPlsqlItem.DB_FLAG;
		aSqlItem.OPERATION := aPlsqlItem.OPERATION;
		aSqlItem.LOCK_CONTROL := aPlsqlItem.LOCK_CONTROL;
		RETURN aSqlItem;
	END PL_TO_SQL30;

	FUNCTION SQL_TO_PL30(aSqlItem OE_ORDER_PUB_HEADER_ADJ_ASSO6)
	RETURN OE_ORDER_PUB.HEADER_ADJ_ASSOC_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_ASSOC_REC_TYPE;
	BEGIN
		aPlsqlItem.PRICE_ADJ_ASSOC_ID := aSqlItem.PRICE_ADJ_ASSOC_ID;
		aPlsqlItem.LINE_ID := aSqlItem.LINE_ID;
		aPlsqlItem.LINE_INDEX := aSqlItem.LINE_INDEX;
		aPlsqlItem.PRICE_ADJUSTMENT_ID := aSqlItem.PRICE_ADJUSTMENT_ID;
		aPlsqlItem.ADJ_INDEX := aSqlItem.ADJ_INDEX;
		aPlsqlItem.RLTD_PRICE_ADJ_ID := aSqlItem.RLTD_PRICE_ADJ_ID;
		aPlsqlItem.RLTD_ADJ_INDEX := aSqlItem.RLTD_ADJ_INDEX;
		aPlsqlItem.CREATION_DATE := aSqlItem.CREATION_DATE;
		aPlsqlItem.CREATED_BY := aSqlItem.CREATED_BY;
		aPlsqlItem.LAST_UPDATE_DATE := aSqlItem.LAST_UPDATE_DATE;
		aPlsqlItem.LAST_UPDATED_BY := aSqlItem.LAST_UPDATED_BY;
		aPlsqlItem.LAST_UPDATE_LOGIN := aSqlItem.LAST_UPDATE_LOGIN;
		aPlsqlItem.PROGRAM_APPLICATION_ID := aSqlItem.PROGRAM_APPLICATION_ID;
		aPlsqlItem.PROGRAM_ID := aSqlItem.PROGRAM_ID;
		aPlsqlItem.PROGRAM_UPDATE_DATE := aSqlItem.PROGRAM_UPDATE_DATE;
		aPlsqlItem.REQUEST_ID := aSqlItem.REQUEST_ID;
		aPlsqlItem.RETURN_STATUS := aSqlItem.RETURN_STATUS;
		aPlsqlItem.DB_FLAG := aSqlItem.DB_FLAG;
		aPlsqlItem.OPERATION := aSqlItem.OPERATION;
		aPlsqlItem.LOCK_CONTROL := aSqlItem.LOCK_CONTROL;
		RETURN aPlsqlItem;
	END SQL_TO_PL30;

	FUNCTION PL_TO_SQL7(aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_ASSOC_TBL_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_ADJ_ASSOC IS
	aSqlItem OE_ORDER_PUB_HEADER_ADJ_ASSOC;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_ADJ_ASSOC();
        IF aPlsqlItem.COUNT > 0 THEN
		    aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			    aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL30(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL7;

	FUNCTION SQL_TO_PL7(aSqlItem OE_ORDER_PUB_HEADER_ADJ_ASSOC)
	RETURN OE_ORDER_PUB.HEADER_ADJ_ASSOC_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_ADJ_ASSOC_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL30(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL7;

	FUNCTION PL_TO_SQL31(aPlsqlItem OE_ORDER_PUB.HEADER_SCREDIT_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_SCREDIT_R IS
	aSqlItem OE_ORDER_PUB_HEADER_SCREDIT_R;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_SCREDIT_R(NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                   NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.ATTRIBUTE1 := aPlsqlItem.ATTRIBUTE1;
		aSqlItem.ATTRIBUTE10 := aPlsqlItem.ATTRIBUTE10;
		aSqlItem.ATTRIBUTE11 := aPlsqlItem.ATTRIBUTE11;
		aSqlItem.ATTRIBUTE12 := aPlsqlItem.ATTRIBUTE12;
		aSqlItem.ATTRIBUTE13 := aPlsqlItem.ATTRIBUTE13;
		aSqlItem.ATTRIBUTE14 := aPlsqlItem.ATTRIBUTE14;
		aSqlItem.ATTRIBUTE15 := aPlsqlItem.ATTRIBUTE15;
		aSqlItem.ATTRIBUTE2 := aPlsqlItem.ATTRIBUTE2;
		aSqlItem.ATTRIBUTE3 := aPlsqlItem.ATTRIBUTE3;
		aSqlItem.ATTRIBUTE4 := aPlsqlItem.ATTRIBUTE4;
		aSqlItem.ATTRIBUTE5 := aPlsqlItem.ATTRIBUTE5;
		aSqlItem.ATTRIBUTE6 := aPlsqlItem.ATTRIBUTE6;
		aSqlItem.ATTRIBUTE7 := aPlsqlItem.ATTRIBUTE7;
		aSqlItem.ATTRIBUTE8 := aPlsqlItem.ATTRIBUTE8;
		aSqlItem.ATTRIBUTE9 := aPlsqlItem.ATTRIBUTE9;
		aSqlItem.CONTEXT := aPlsqlItem.CONTEXT;
		aSqlItem.CREATED_BY := aPlsqlItem.CREATED_BY;
		aSqlItem.CREATION_DATE := aPlsqlItem.CREATION_DATE;
		aSqlItem.DW_UPDATE_ADVICE_FLAG := aPlsqlItem.DW_UPDATE_ADVICE_FLAG;
		aSqlItem.HEADER_ID := aPlsqlItem.HEADER_ID;
		aSqlItem.LAST_UPDATED_BY := aPlsqlItem.LAST_UPDATED_BY;
		aSqlItem.LAST_UPDATE_DATE := aPlsqlItem.LAST_UPDATE_DATE;
		aSqlItem.LAST_UPDATE_LOGIN := aPlsqlItem.LAST_UPDATE_LOGIN;
		aSqlItem.LINE_ID := aPlsqlItem.LINE_ID;
		aSqlItem.PERCENT := aPlsqlItem.PERCENT;
		aSqlItem.SALESREP_ID := aPlsqlItem.SALESREP_ID;
		aSqlItem.SALES_CREDIT_TYPE_ID := aPlsqlItem.SALES_CREDIT_TYPE_ID;
		aSqlItem.SALES_CREDIT_ID := aPlsqlItem.SALES_CREDIT_ID;
		aSqlItem.WH_UPDATE_DATE := aPlsqlItem.WH_UPDATE_DATE;
		aSqlItem.RETURN_STATUS := aPlsqlItem.RETURN_STATUS;
		aSqlItem.DB_FLAG := aPlsqlItem.DB_FLAG;
		aSqlItem.OPERATION := aPlsqlItem.OPERATION;
		aSqlItem.ORIG_SYS_CREDIT_REF := aPlsqlItem.ORIG_SYS_CREDIT_REF;
		aSqlItem.CHANGE_REQUEST_CODE := aPlsqlItem.CHANGE_REQUEST_CODE;
		aSqlItem.STATUS_FLAG := aPlsqlItem.STATUS_FLAG;
		aSqlItem.LOCK_CONTROL := aPlsqlItem.LOCK_CONTROL;
		aSqlItem.CHANGE_REASON := aPlsqlItem.CHANGE_REASON;
		aSqlItem.CHANGE_COMMENTS := aPlsqlItem.CHANGE_COMMENTS;
		aSqlItem.SALES_GROUP_ID := aPlsqlItem.SALES_GROUP_ID;
		aSqlItem.SALES_GROUP_UPDATED_FLAG := aPlsqlItem.SALES_GROUP_UPDATED_FLAG;
		RETURN aSqlItem;
	END PL_TO_SQL31;

	FUNCTION SQL_TO_PL31(aSqlItem OE_ORDER_PUB_HEADER_SCREDIT_R)
	RETURN OE_ORDER_PUB.HEADER_SCREDIT_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_SCREDIT_REC_TYPE;
	BEGIN
		aPlsqlItem.ATTRIBUTE1 := aSqlItem.ATTRIBUTE1;
		aPlsqlItem.ATTRIBUTE10 := aSqlItem.ATTRIBUTE10;
		aPlsqlItem.ATTRIBUTE11 := aSqlItem.ATTRIBUTE11;
		aPlsqlItem.ATTRIBUTE12 := aSqlItem.ATTRIBUTE12;
		aPlsqlItem.ATTRIBUTE13 := aSqlItem.ATTRIBUTE13;
		aPlsqlItem.ATTRIBUTE14 := aSqlItem.ATTRIBUTE14;
		aPlsqlItem.ATTRIBUTE15 := aSqlItem.ATTRIBUTE15;
		aPlsqlItem.ATTRIBUTE2 := aSqlItem.ATTRIBUTE2;
		aPlsqlItem.ATTRIBUTE3 := aSqlItem.ATTRIBUTE3;
		aPlsqlItem.ATTRIBUTE4 := aSqlItem.ATTRIBUTE4;
		aPlsqlItem.ATTRIBUTE5 := aSqlItem.ATTRIBUTE5;
		aPlsqlItem.ATTRIBUTE6 := aSqlItem.ATTRIBUTE6;
		aPlsqlItem.ATTRIBUTE7 := aSqlItem.ATTRIBUTE7;
		aPlsqlItem.ATTRIBUTE8 := aSqlItem.ATTRIBUTE8;
		aPlsqlItem.ATTRIBUTE9 := aSqlItem.ATTRIBUTE9;
		aPlsqlItem.CONTEXT := aSqlItem.CONTEXT;
		aPlsqlItem.CREATED_BY := aSqlItem.CREATED_BY;
		aPlsqlItem.CREATION_DATE := aSqlItem.CREATION_DATE;
		aPlsqlItem.DW_UPDATE_ADVICE_FLAG := aSqlItem.DW_UPDATE_ADVICE_FLAG;
		aPlsqlItem.HEADER_ID := aSqlItem.HEADER_ID;
		aPlsqlItem.LAST_UPDATED_BY := aSqlItem.LAST_UPDATED_BY;
		aPlsqlItem.LAST_UPDATE_DATE := aSqlItem.LAST_UPDATE_DATE;
		aPlsqlItem.LAST_UPDATE_LOGIN := aSqlItem.LAST_UPDATE_LOGIN;
		aPlsqlItem.LINE_ID := aSqlItem.LINE_ID;
		aPlsqlItem.PERCENT := aSqlItem.PERCENT;
		aPlsqlItem.SALESREP_ID := aSqlItem.SALESREP_ID;
		aPlsqlItem.SALES_CREDIT_TYPE_ID := aSqlItem.SALES_CREDIT_TYPE_ID;
		aPlsqlItem.SALES_CREDIT_ID := aSqlItem.SALES_CREDIT_ID;
		aPlsqlItem.WH_UPDATE_DATE := aSqlItem.WH_UPDATE_DATE;
		aPlsqlItem.RETURN_STATUS := aSqlItem.RETURN_STATUS;
		aPlsqlItem.DB_FLAG := aSqlItem.DB_FLAG;
		aPlsqlItem.OPERATION := aSqlItem.OPERATION;
		aPlsqlItem.ORIG_SYS_CREDIT_REF := aSqlItem.ORIG_SYS_CREDIT_REF;
		aPlsqlItem.CHANGE_REQUEST_CODE := aSqlItem.CHANGE_REQUEST_CODE;
		aPlsqlItem.STATUS_FLAG := aSqlItem.STATUS_FLAG;
		aPlsqlItem.LOCK_CONTROL := aSqlItem.LOCK_CONTROL;
		aPlsqlItem.CHANGE_REASON := aSqlItem.CHANGE_REASON;
		aPlsqlItem.CHANGE_COMMENTS := aSqlItem.CHANGE_COMMENTS;
		aPlsqlItem.SALES_GROUP_ID := aSqlItem.SALES_GROUP_ID;
		aPlsqlItem.SALES_GROUP_UPDATED_FLAG := aSqlItem.SALES_GROUP_UPDATED_FLAG;
		RETURN aPlsqlItem;
	END SQL_TO_PL31;

	FUNCTION PL_TO_SQL8(aPlsqlItem OE_ORDER_PUB.HEADER_SCREDIT_TBL_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_SCREDIT_T IS
	aSqlItem OE_ORDER_PUB_HEADER_SCREDIT_T;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_SCREDIT_T();
        IF aPlsqlItem.COUNT > 0 THEN
		    aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			    aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL31(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL8;

	FUNCTION SQL_TO_PL8(aSqlItem OE_ORDER_PUB_HEADER_SCREDIT_T)
	RETURN OE_ORDER_PUB.HEADER_SCREDIT_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_SCREDIT_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL31(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL8;

	FUNCTION PL_TO_SQL32(aPlsqlItem OE_ORDER_PUB.HEADER_SCREDIT_VAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_SCREDIT11 IS
	aSqlItem OE_ORDER_PUB_HEADER_SCREDIT11;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_SCREDIT11(NULL, NULL, NULL);
		aSqlItem.SALESREP := aPlsqlItem.SALESREP;
		aSqlItem.SALES_CREDIT_TYPE := aPlsqlItem.SALES_CREDIT_TYPE;
		aSqlItem.SALES_GROUP := aPlsqlItem.SALES_GROUP;
		RETURN aSqlItem;
	END PL_TO_SQL32;

	FUNCTION SQL_TO_PL32(aSqlItem OE_ORDER_PUB_HEADER_SCREDIT11)
	RETURN OE_ORDER_PUB.HEADER_SCREDIT_VAL_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_SCREDIT_VAL_REC_TYPE;
	BEGIN
		aPlsqlItem.SALESREP := aSqlItem.SALESREP;
		aPlsqlItem.SALES_CREDIT_TYPE := aSqlItem.SALES_CREDIT_TYPE;
		aPlsqlItem.SALES_GROUP := aSqlItem.SALES_GROUP;
		RETURN aPlsqlItem;
	END SQL_TO_PL32;

	FUNCTION PL_TO_SQL9(aPlsqlItem OE_ORDER_PUB.HEADER_SCREDIT_VAL_TBL_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_SCREDIT_V IS
	aSqlItem OE_ORDER_PUB_HEADER_SCREDIT_V;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_SCREDIT_V();
        IF aPlsqlItem.COUNT > 0 THEN
		    aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
		        aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL32(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL9;

	FUNCTION SQL_TO_PL9(aSqlItem OE_ORDER_PUB_HEADER_SCREDIT_V)
	RETURN OE_ORDER_PUB.HEADER_SCREDIT_VAL_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_SCREDIT_VAL_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL32(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL9;

	FUNCTION PL_TO_SQL33(aPlsqlItem OE_ORDER_PUB.HEADER_PAYMENT_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_PAYMENT_R IS
	aSqlItem OE_ORDER_PUB_HEADER_PAYMENT_R;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_PAYMENT_R(NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.ATTRIBUTE1 := aPlsqlItem.ATTRIBUTE1;
		aSqlItem.ATTRIBUTE2 := aPlsqlItem.ATTRIBUTE2;
		aSqlItem.ATTRIBUTE3 := aPlsqlItem.ATTRIBUTE3;
		aSqlItem.ATTRIBUTE4 := aPlsqlItem.ATTRIBUTE4;
		aSqlItem.ATTRIBUTE5 := aPlsqlItem.ATTRIBUTE5;
		aSqlItem.ATTRIBUTE6 := aPlsqlItem.ATTRIBUTE6;
		aSqlItem.ATTRIBUTE7 := aPlsqlItem.ATTRIBUTE7;
		aSqlItem.ATTRIBUTE8 := aPlsqlItem.ATTRIBUTE8;
		aSqlItem.ATTRIBUTE9 := aPlsqlItem.ATTRIBUTE9;
		aSqlItem.ATTRIBUTE10 := aPlsqlItem.ATTRIBUTE10;
		aSqlItem.ATTRIBUTE11 := aPlsqlItem.ATTRIBUTE11;
		aSqlItem.ATTRIBUTE12 := aPlsqlItem.ATTRIBUTE12;
		aSqlItem.ATTRIBUTE13 := aPlsqlItem.ATTRIBUTE13;
		aSqlItem.ATTRIBUTE14 := aPlsqlItem.ATTRIBUTE14;
		aSqlItem.ATTRIBUTE15 := aPlsqlItem.ATTRIBUTE15;
		aSqlItem.CHECK_NUMBER := aPlsqlItem.CHECK_NUMBER;
		aSqlItem.CREATED_BY := aPlsqlItem.CREATED_BY;
		aSqlItem.CREATION_DATE := aPlsqlItem.CREATION_DATE;
		aSqlItem.CREDIT_CARD_APPROVAL_CODE := aPlsqlItem.CREDIT_CARD_APPROVAL_CODE;
		aSqlItem.CREDIT_CARD_APPROVAL_DATE := aPlsqlItem.CREDIT_CARD_APPROVAL_DATE;
		aSqlItem.CREDIT_CARD_CODE := aPlsqlItem.CREDIT_CARD_CODE;
		aSqlItem.CREDIT_CARD_EXPIRATION_DATE := aPlsqlItem.CREDIT_CARD_EXPIRATION_DATE;
		aSqlItem.CREDIT_CARD_HOLDER_NAME := aPlsqlItem.CREDIT_CARD_HOLDER_NAME;
		aSqlItem.CREDIT_CARD_NUMBER := aPlsqlItem.CREDIT_CARD_NUMBER;
		aSqlItem.COMMITMENT_APPLIED_AMOUNT := aPlsqlItem.COMMITMENT_APPLIED_AMOUNT;
		aSqlItem.COMMITMENT_INTERFACED_AMOUNT := aPlsqlItem.COMMITMENT_INTERFACED_AMOUNT;
		aSqlItem.CONTEXT := aPlsqlItem.CONTEXT;
		aSqlItem.HEADER_ID := aPlsqlItem.HEADER_ID;
		aSqlItem.LAST_UPDATED_BY := aPlsqlItem.LAST_UPDATED_BY;
		aSqlItem.LAST_UPDATE_DATE := aPlsqlItem.LAST_UPDATE_DATE;
		aSqlItem.LAST_UPDATE_LOGIN := aPlsqlItem.LAST_UPDATE_LOGIN;
		aSqlItem.LINE_ID := aPlsqlItem.LINE_ID;
		aSqlItem.PAYMENT_NUMBER := aPlsqlItem.PAYMENT_NUMBER;
		aSqlItem.PAYMENT_AMOUNT := aPlsqlItem.PAYMENT_AMOUNT;
		aSqlItem.PAYMENT_COLLECTION_EVENT := aPlsqlItem.PAYMENT_COLLECTION_EVENT;
		aSqlItem.PAYMENT_LEVEL_CODE := aPlsqlItem.PAYMENT_LEVEL_CODE;
		aSqlItem.PAYMENT_TRX_ID := aPlsqlItem.PAYMENT_TRX_ID;
		aSqlItem.PAYMENT_TYPE_CODE := aPlsqlItem.PAYMENT_TYPE_CODE;
		aSqlItem.PAYMENT_SET_ID := aPlsqlItem.PAYMENT_SET_ID;
		aSqlItem.PREPAID_AMOUNT := aPlsqlItem.PREPAID_AMOUNT;
		aSqlItem.PROGRAM_APPLICATION_ID := aPlsqlItem.PROGRAM_APPLICATION_ID;
		aSqlItem.PROGRAM_ID := aPlsqlItem.PROGRAM_ID;
		aSqlItem.PROGRAM_UPDATE_DATE := aPlsqlItem.PROGRAM_UPDATE_DATE;
		aSqlItem.RECEIPT_METHOD_ID := aPlsqlItem.RECEIPT_METHOD_ID;
		aSqlItem.REQUEST_ID := aPlsqlItem.REQUEST_ID;
		aSqlItem.TANGIBLE_ID := aPlsqlItem.TANGIBLE_ID;
		aSqlItem.ORIG_SYS_PAYMENT_REF := aPlsqlItem.ORIG_SYS_PAYMENT_REF;
		aSqlItem.CHANGE_REQUEST_CODE := aPlsqlItem.CHANGE_REQUEST_CODE;
		aSqlItem.STATUS_FLAG := aPlsqlItem.STATUS_FLAG;
		aSqlItem.RETURN_STATUS := aPlsqlItem.RETURN_STATUS;
		aSqlItem.DB_FLAG := aPlsqlItem.DB_FLAG;
		aSqlItem.OPERATION := aPlsqlItem.OPERATION;
		aSqlItem.DEFER_PAYMENT_PROCESSING_FLAG := aPlsqlItem.DEFER_PAYMENT_PROCESSING_FLAG;
		aSqlItem.LOCK_CONTROL := aPlsqlItem.LOCK_CONTROL;
		RETURN aSqlItem;
	END PL_TO_SQL33;

	FUNCTION SQL_TO_PL33(aSqlItem OE_ORDER_PUB_HEADER_PAYMENT_R)
	RETURN OE_ORDER_PUB.HEADER_PAYMENT_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_PAYMENT_REC_TYPE;
	BEGIN
		aPlsqlItem.ATTRIBUTE1 := aSqlItem.ATTRIBUTE1;
		aPlsqlItem.ATTRIBUTE2 := aSqlItem.ATTRIBUTE2;
		aPlsqlItem.ATTRIBUTE3 := aSqlItem.ATTRIBUTE3;
		aPlsqlItem.ATTRIBUTE4 := aSqlItem.ATTRIBUTE4;
		aPlsqlItem.ATTRIBUTE5 := aSqlItem.ATTRIBUTE5;
		aPlsqlItem.ATTRIBUTE6 := aSqlItem.ATTRIBUTE6;
		aPlsqlItem.ATTRIBUTE7 := aSqlItem.ATTRIBUTE7;
		aPlsqlItem.ATTRIBUTE8 := aSqlItem.ATTRIBUTE8;
		aPlsqlItem.ATTRIBUTE9 := aSqlItem.ATTRIBUTE9;
		aPlsqlItem.ATTRIBUTE10 := aSqlItem.ATTRIBUTE10;
		aPlsqlItem.ATTRIBUTE11 := aSqlItem.ATTRIBUTE11;
		aPlsqlItem.ATTRIBUTE12 := aSqlItem.ATTRIBUTE12;
		aPlsqlItem.ATTRIBUTE13 := aSqlItem.ATTRIBUTE13;
		aPlsqlItem.ATTRIBUTE14 := aSqlItem.ATTRIBUTE14;
		aPlsqlItem.ATTRIBUTE15 := aSqlItem.ATTRIBUTE15;
		aPlsqlItem.CHECK_NUMBER := aSqlItem.CHECK_NUMBER;
		aPlsqlItem.CREATED_BY := aSqlItem.CREATED_BY;
		aPlsqlItem.CREATION_DATE := aSqlItem.CREATION_DATE;
		aPlsqlItem.CREDIT_CARD_APPROVAL_CODE := aSqlItem.CREDIT_CARD_APPROVAL_CODE;
		aPlsqlItem.CREDIT_CARD_APPROVAL_DATE := aSqlItem.CREDIT_CARD_APPROVAL_DATE;
		aPlsqlItem.CREDIT_CARD_CODE := aSqlItem.CREDIT_CARD_CODE;
		aPlsqlItem.CREDIT_CARD_EXPIRATION_DATE := aSqlItem.CREDIT_CARD_EXPIRATION_DATE;
		aPlsqlItem.CREDIT_CARD_HOLDER_NAME := aSqlItem.CREDIT_CARD_HOLDER_NAME;
		aPlsqlItem.CREDIT_CARD_NUMBER := aSqlItem.CREDIT_CARD_NUMBER;
		aPlsqlItem.COMMITMENT_APPLIED_AMOUNT := aSqlItem.COMMITMENT_APPLIED_AMOUNT;
		aPlsqlItem.COMMITMENT_INTERFACED_AMOUNT := aSqlItem.COMMITMENT_INTERFACED_AMOUNT;
		aPlsqlItem.CONTEXT := aSqlItem.CONTEXT;
		aPlsqlItem.HEADER_ID := aSqlItem.HEADER_ID;
		aPlsqlItem.LAST_UPDATED_BY := aSqlItem.LAST_UPDATED_BY;
		aPlsqlItem.LAST_UPDATE_DATE := aSqlItem.LAST_UPDATE_DATE;
		aPlsqlItem.LAST_UPDATE_LOGIN := aSqlItem.LAST_UPDATE_LOGIN;
		aPlsqlItem.LINE_ID := aSqlItem.LINE_ID;
		aPlsqlItem.PAYMENT_NUMBER := aSqlItem.PAYMENT_NUMBER;
		aPlsqlItem.PAYMENT_AMOUNT := aSqlItem.PAYMENT_AMOUNT;
		aPlsqlItem.PAYMENT_COLLECTION_EVENT := aSqlItem.PAYMENT_COLLECTION_EVENT;
		aPlsqlItem.PAYMENT_LEVEL_CODE := aSqlItem.PAYMENT_LEVEL_CODE;
		aPlsqlItem.PAYMENT_TRX_ID := aSqlItem.PAYMENT_TRX_ID;
		aPlsqlItem.PAYMENT_TYPE_CODE := aSqlItem.PAYMENT_TYPE_CODE;
		aPlsqlItem.PAYMENT_SET_ID := aSqlItem.PAYMENT_SET_ID;
		aPlsqlItem.PREPAID_AMOUNT := aSqlItem.PREPAID_AMOUNT;
		aPlsqlItem.PROGRAM_APPLICATION_ID := aSqlItem.PROGRAM_APPLICATION_ID;
		aPlsqlItem.PROGRAM_ID := aSqlItem.PROGRAM_ID;
		aPlsqlItem.PROGRAM_UPDATE_DATE := aSqlItem.PROGRAM_UPDATE_DATE;
		aPlsqlItem.RECEIPT_METHOD_ID := aSqlItem.RECEIPT_METHOD_ID;
		aPlsqlItem.REQUEST_ID := aSqlItem.REQUEST_ID;
		aPlsqlItem.TANGIBLE_ID := aSqlItem.TANGIBLE_ID;
		aPlsqlItem.ORIG_SYS_PAYMENT_REF := aSqlItem.ORIG_SYS_PAYMENT_REF;
		aPlsqlItem.CHANGE_REQUEST_CODE := aSqlItem.CHANGE_REQUEST_CODE;
		aPlsqlItem.STATUS_FLAG := aSqlItem.STATUS_FLAG;
		aPlsqlItem.RETURN_STATUS := aSqlItem.RETURN_STATUS;
		aPlsqlItem.DB_FLAG := aSqlItem.DB_FLAG;
		aPlsqlItem.OPERATION := aSqlItem.OPERATION;
		aPlsqlItem.DEFER_PAYMENT_PROCESSING_FLAG := aSqlItem.DEFER_PAYMENT_PROCESSING_FLAG;
		aPlsqlItem.LOCK_CONTROL := aSqlItem.LOCK_CONTROL;

                oe_debug_pub.add('Calling OE_GENESIS_UTIL.Convert_hdr_pymnt_null_to_miss', 1);
                OE_GENESIS_UTIL.Convert_hdr_pymnt_null_to_miss(aPlsqlItem);
                oe_debug_pub.add('After Calling OE_GENESIS_UTIL.Convert_hdr_pymnt_null_to_miss', 1);

		RETURN aPlsqlItem;
	END SQL_TO_PL33;

	FUNCTION PL_TO_SQL10(aPlsqlItem OE_ORDER_PUB.HEADER_PAYMENT_TBL_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_PAYMENT_T IS
	aSqlItem OE_ORDER_PUB_HEADER_PAYMENT_T;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_PAYMENT_T();
        IF aPlsqlItem.COUNT > 0 THEN
		    aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			    aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL33(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL10;

	FUNCTION SQL_TO_PL10(aSqlItem OE_ORDER_PUB_HEADER_PAYMENT_T)
	RETURN OE_ORDER_PUB.HEADER_PAYMENT_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_PAYMENT_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL33(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL10;

	FUNCTION PL_TO_SQL34(aPlsqlItem OE_ORDER_PUB.HEADER_PAYMENT_VAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_PAYMENT_5 IS
	aSqlItem OE_ORDER_PUB_HEADER_PAYMENT_5;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_PAYMENT_5(NULL, NULL, NULL, NULL, NULL);
		aSqlItem.PAYMENT_COLLECTION_EVENT_NAME := aPlsqlItem.PAYMENT_COLLECTION_EVENT_NAME;
		aSqlItem.RECEIPT_METHOD := aPlsqlItem.RECEIPT_METHOD;
		aSqlItem.PAYMENT_TYPE := aPlsqlItem.PAYMENT_TYPE;
		aSqlItem.COMMITMENT := aPlsqlItem.COMMITMENT;
		aSqlItem.PAYMENT_PERCENTAGE := aPlsqlItem.PAYMENT_PERCENTAGE;
		RETURN aSqlItem;
	END PL_TO_SQL34;

	FUNCTION SQL_TO_PL34(aSqlItem OE_ORDER_PUB_HEADER_PAYMENT_5)
	RETURN OE_ORDER_PUB.HEADER_PAYMENT_VAL_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_PAYMENT_VAL_REC_TYPE;
	BEGIN
		aPlsqlItem.PAYMENT_COLLECTION_EVENT_NAME := aSqlItem.PAYMENT_COLLECTION_EVENT_NAME;
		aPlsqlItem.RECEIPT_METHOD := aSqlItem.RECEIPT_METHOD;
		aPlsqlItem.PAYMENT_TYPE := aSqlItem.PAYMENT_TYPE;
		aPlsqlItem.COMMITMENT := aSqlItem.COMMITMENT;
		aPlsqlItem.PAYMENT_PERCENTAGE := aSqlItem.PAYMENT_PERCENTAGE;
		RETURN aPlsqlItem;
	END SQL_TO_PL34;

	FUNCTION PL_TO_SQL11(aPlsqlItem OE_ORDER_PUB.HEADER_PAYMENT_VAL_TBL_TYPE)
 	RETURN OE_ORDER_PUB_HEADER_PAYMENT_V IS
	aSqlItem OE_ORDER_PUB_HEADER_PAYMENT_V;
	BEGIN
		aSqlItem := OE_ORDER_PUB_HEADER_PAYMENT_V();
		IF aPlsqlItem.COUNT > 0 THEN
            aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			    aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL34(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL11;

	FUNCTION SQL_TO_PL11(aSqlItem OE_ORDER_PUB_HEADER_PAYMENT_V)
	RETURN OE_ORDER_PUB.HEADER_PAYMENT_VAL_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.HEADER_PAYMENT_VAL_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL34(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL11;

	FUNCTION PL_TO_SQL35(aPlsqlItem OE_ORDER_PUB.LINE_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_REC_TYPE IS
	aSqlItem OE_ORDER_PUB_LINE_REC_TYPE;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_REC_TYPE(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.ACCOUNTING_RULE_ID := aPlsqlItem.ACCOUNTING_RULE_ID;
		aSqlItem.ACTUAL_ARRIVAL_DATE := aPlsqlItem.ACTUAL_ARRIVAL_DATE;
		aSqlItem.ACTUAL_SHIPMENT_DATE := aPlsqlItem.ACTUAL_SHIPMENT_DATE;
		aSqlItem.AGREEMENT_ID := aPlsqlItem.AGREEMENT_ID;
		aSqlItem.ARRIVAL_SET_ID := aPlsqlItem.ARRIVAL_SET_ID;
		aSqlItem.ATO_LINE_ID := aPlsqlItem.ATO_LINE_ID;
		aSqlItem.ATTRIBUTE1 := aPlsqlItem.ATTRIBUTE1;
		aSqlItem.ATTRIBUTE10 := aPlsqlItem.ATTRIBUTE10;
		aSqlItem.ATTRIBUTE11 := aPlsqlItem.ATTRIBUTE11;
		aSqlItem.ATTRIBUTE12 := aPlsqlItem.ATTRIBUTE12;
		aSqlItem.ATTRIBUTE13 := aPlsqlItem.ATTRIBUTE13;
		aSqlItem.ATTRIBUTE14 := aPlsqlItem.ATTRIBUTE14;
		aSqlItem.ATTRIBUTE15 := aPlsqlItem.ATTRIBUTE15;
		aSqlItem.ATTRIBUTE16 := aPlsqlItem.ATTRIBUTE16;
		aSqlItem.ATTRIBUTE17 := aPlsqlItem.ATTRIBUTE17;
		aSqlItem.ATTRIBUTE18 := aPlsqlItem.ATTRIBUTE18;
		aSqlItem.ATTRIBUTE19 := aPlsqlItem.ATTRIBUTE19;
		aSqlItem.ATTRIBUTE2 := aPlsqlItem.ATTRIBUTE2;
		aSqlItem.ATTRIBUTE20 := aPlsqlItem.ATTRIBUTE20;
		aSqlItem.ATTRIBUTE3 := aPlsqlItem.ATTRIBUTE3;
		aSqlItem.ATTRIBUTE4 := aPlsqlItem.ATTRIBUTE4;
		aSqlItem.ATTRIBUTE5 := aPlsqlItem.ATTRIBUTE5;
		aSqlItem.ATTRIBUTE6 := aPlsqlItem.ATTRIBUTE6;
		aSqlItem.ATTRIBUTE7 := aPlsqlItem.ATTRIBUTE7;
		aSqlItem.ATTRIBUTE8 := aPlsqlItem.ATTRIBUTE8;
		aSqlItem.ATTRIBUTE9 := aPlsqlItem.ATTRIBUTE9;
		aSqlItem.AUTHORIZED_TO_SHIP_FLAG := aPlsqlItem.AUTHORIZED_TO_SHIP_FLAG;
		aSqlItem.AUTO_SELECTED_QUANTITY := aPlsqlItem.AUTO_SELECTED_QUANTITY;
		aSqlItem.BOOKED_FLAG := aPlsqlItem.BOOKED_FLAG;
		aSqlItem.CANCELLED_FLAG := aPlsqlItem.CANCELLED_FLAG;
		aSqlItem.CANCELLED_QUANTITY := aPlsqlItem.CANCELLED_QUANTITY;
		aSqlItem.CANCELLED_QUANTITY2 := aPlsqlItem.CANCELLED_QUANTITY2;
		aSqlItem.COMMITMENT_ID := aPlsqlItem.COMMITMENT_ID;
		aSqlItem.COMPONENT_CODE := aPlsqlItem.COMPONENT_CODE;
		aSqlItem.COMPONENT_NUMBER := aPlsqlItem.COMPONENT_NUMBER;
		aSqlItem.COMPONENT_SEQUENCE_ID := aPlsqlItem.COMPONENT_SEQUENCE_ID;
		aSqlItem.CONFIG_HEADER_ID := aPlsqlItem.CONFIG_HEADER_ID;
		aSqlItem.CONFIG_REV_NBR := aPlsqlItem.CONFIG_REV_NBR;
		aSqlItem.CONFIG_DISPLAY_SEQUENCE := aPlsqlItem.CONFIG_DISPLAY_SEQUENCE;
		aSqlItem.CONFIGURATION_ID := aPlsqlItem.CONFIGURATION_ID;
		aSqlItem.CONTEXT := aPlsqlItem.CONTEXT;
		aSqlItem.CREATED_BY := aPlsqlItem.CREATED_BY;
		aSqlItem.CREATION_DATE := aPlsqlItem.CREATION_DATE;
		aSqlItem.CREDIT_INVOICE_LINE_ID := aPlsqlItem.CREDIT_INVOICE_LINE_ID;
		aSqlItem.CUSTOMER_DOCK_CODE := aPlsqlItem.CUSTOMER_DOCK_CODE;
		aSqlItem.CUSTOMER_JOB := aPlsqlItem.CUSTOMER_JOB;
		aSqlItem.CUSTOMER_PRODUCTION_LINE := aPlsqlItem.CUSTOMER_PRODUCTION_LINE;
		aSqlItem.CUSTOMER_TRX_LINE_ID := aPlsqlItem.CUSTOMER_TRX_LINE_ID;
		aSqlItem.CUST_MODEL_SERIAL_NUMBER := aPlsqlItem.CUST_MODEL_SERIAL_NUMBER;
		aSqlItem.CUST_PO_NUMBER := aPlsqlItem.CUST_PO_NUMBER;
		aSqlItem.CUST_PRODUCTION_SEQ_NUM := aPlsqlItem.CUST_PRODUCTION_SEQ_NUM;
		aSqlItem.DELIVERY_LEAD_TIME := aPlsqlItem.DELIVERY_LEAD_TIME;
		aSqlItem.DELIVER_TO_CONTACT_ID := aPlsqlItem.DELIVER_TO_CONTACT_ID;
		aSqlItem.DELIVER_TO_ORG_ID := aPlsqlItem.DELIVER_TO_ORG_ID;
		aSqlItem.DEMAND_BUCKET_TYPE_CODE := aPlsqlItem.DEMAND_BUCKET_TYPE_CODE;
		aSqlItem.DEMAND_CLASS_CODE := aPlsqlItem.DEMAND_CLASS_CODE;
		aSqlItem.DEP_PLAN_REQUIRED_FLAG := aPlsqlItem.DEP_PLAN_REQUIRED_FLAG;
		aSqlItem.EARLIEST_ACCEPTABLE_DATE := aPlsqlItem.EARLIEST_ACCEPTABLE_DATE;
		aSqlItem.END_ITEM_UNIT_NUMBER := aPlsqlItem.END_ITEM_UNIT_NUMBER;
		aSqlItem.EXPLOSION_DATE := aPlsqlItem.EXPLOSION_DATE;
		aSqlItem.FOB_POINT_CODE := aPlsqlItem.FOB_POINT_CODE;
		aSqlItem.FREIGHT_CARRIER_CODE := aPlsqlItem.FREIGHT_CARRIER_CODE;
		aSqlItem.FREIGHT_TERMS_CODE := aPlsqlItem.FREIGHT_TERMS_CODE;
		aSqlItem.FULFILLED_QUANTITY := aPlsqlItem.FULFILLED_QUANTITY;
		aSqlItem.FULFILLED_QUANTITY2 := aPlsqlItem.FULFILLED_QUANTITY2;
		aSqlItem.GLOBAL_ATTRIBUTE1 := aPlsqlItem.GLOBAL_ATTRIBUTE1;
		aSqlItem.GLOBAL_ATTRIBUTE10 := aPlsqlItem.GLOBAL_ATTRIBUTE10;
		aSqlItem.GLOBAL_ATTRIBUTE11 := aPlsqlItem.GLOBAL_ATTRIBUTE11;
		aSqlItem.GLOBAL_ATTRIBUTE12 := aPlsqlItem.GLOBAL_ATTRIBUTE12;
		aSqlItem.GLOBAL_ATTRIBUTE13 := aPlsqlItem.GLOBAL_ATTRIBUTE13;
		aSqlItem.GLOBAL_ATTRIBUTE14 := aPlsqlItem.GLOBAL_ATTRIBUTE14;
		aSqlItem.GLOBAL_ATTRIBUTE15 := aPlsqlItem.GLOBAL_ATTRIBUTE15;
		aSqlItem.GLOBAL_ATTRIBUTE16 := aPlsqlItem.GLOBAL_ATTRIBUTE16;
		aSqlItem.GLOBAL_ATTRIBUTE17 := aPlsqlItem.GLOBAL_ATTRIBUTE17;
		aSqlItem.GLOBAL_ATTRIBUTE18 := aPlsqlItem.GLOBAL_ATTRIBUTE18;
		aSqlItem.GLOBAL_ATTRIBUTE19 := aPlsqlItem.GLOBAL_ATTRIBUTE19;
		aSqlItem.GLOBAL_ATTRIBUTE2 := aPlsqlItem.GLOBAL_ATTRIBUTE2;
		aSqlItem.GLOBAL_ATTRIBUTE20 := aPlsqlItem.GLOBAL_ATTRIBUTE20;
		aSqlItem.GLOBAL_ATTRIBUTE3 := aPlsqlItem.GLOBAL_ATTRIBUTE3;
		aSqlItem.GLOBAL_ATTRIBUTE4 := aPlsqlItem.GLOBAL_ATTRIBUTE4;
		aSqlItem.GLOBAL_ATTRIBUTE5 := aPlsqlItem.GLOBAL_ATTRIBUTE5;
		aSqlItem.GLOBAL_ATTRIBUTE6 := aPlsqlItem.GLOBAL_ATTRIBUTE6;
		aSqlItem.GLOBAL_ATTRIBUTE7 := aPlsqlItem.GLOBAL_ATTRIBUTE7;
		aSqlItem.GLOBAL_ATTRIBUTE8 := aPlsqlItem.GLOBAL_ATTRIBUTE8;
		aSqlItem.GLOBAL_ATTRIBUTE9 := aPlsqlItem.GLOBAL_ATTRIBUTE9;
		aSqlItem.GLOBAL_ATTRIBUTE_CATEGORY := aPlsqlItem.GLOBAL_ATTRIBUTE_CATEGORY;
		aSqlItem.HEADER_ID := aPlsqlItem.HEADER_ID;
		aSqlItem.INDUSTRY_ATTRIBUTE1 := aPlsqlItem.INDUSTRY_ATTRIBUTE1;
		aSqlItem.INDUSTRY_ATTRIBUTE10 := aPlsqlItem.INDUSTRY_ATTRIBUTE10;
		aSqlItem.INDUSTRY_ATTRIBUTE11 := aPlsqlItem.INDUSTRY_ATTRIBUTE11;
		aSqlItem.INDUSTRY_ATTRIBUTE12 := aPlsqlItem.INDUSTRY_ATTRIBUTE12;
		aSqlItem.INDUSTRY_ATTRIBUTE13 := aPlsqlItem.INDUSTRY_ATTRIBUTE13;
		aSqlItem.INDUSTRY_ATTRIBUTE14 := aPlsqlItem.INDUSTRY_ATTRIBUTE14;
		aSqlItem.INDUSTRY_ATTRIBUTE15 := aPlsqlItem.INDUSTRY_ATTRIBUTE15;
		aSqlItem.INDUSTRY_ATTRIBUTE16 := aPlsqlItem.INDUSTRY_ATTRIBUTE16;
		aSqlItem.INDUSTRY_ATTRIBUTE17 := aPlsqlItem.INDUSTRY_ATTRIBUTE17;
		aSqlItem.INDUSTRY_ATTRIBUTE18 := aPlsqlItem.INDUSTRY_ATTRIBUTE18;
		aSqlItem.INDUSTRY_ATTRIBUTE19 := aPlsqlItem.INDUSTRY_ATTRIBUTE19;
		aSqlItem.INDUSTRY_ATTRIBUTE20 := aPlsqlItem.INDUSTRY_ATTRIBUTE20;
		aSqlItem.INDUSTRY_ATTRIBUTE21 := aPlsqlItem.INDUSTRY_ATTRIBUTE21;
		aSqlItem.INDUSTRY_ATTRIBUTE22 := aPlsqlItem.INDUSTRY_ATTRIBUTE22;
		aSqlItem.INDUSTRY_ATTRIBUTE23 := aPlsqlItem.INDUSTRY_ATTRIBUTE23;
		aSqlItem.INDUSTRY_ATTRIBUTE24 := aPlsqlItem.INDUSTRY_ATTRIBUTE24;
		aSqlItem.INDUSTRY_ATTRIBUTE25 := aPlsqlItem.INDUSTRY_ATTRIBUTE25;
		aSqlItem.INDUSTRY_ATTRIBUTE26 := aPlsqlItem.INDUSTRY_ATTRIBUTE26;
		aSqlItem.INDUSTRY_ATTRIBUTE27 := aPlsqlItem.INDUSTRY_ATTRIBUTE27;
		aSqlItem.INDUSTRY_ATTRIBUTE28 := aPlsqlItem.INDUSTRY_ATTRIBUTE28;
		aSqlItem.INDUSTRY_ATTRIBUTE29 := aPlsqlItem.INDUSTRY_ATTRIBUTE29;
		aSqlItem.INDUSTRY_ATTRIBUTE30 := aPlsqlItem.INDUSTRY_ATTRIBUTE30;
		aSqlItem.INDUSTRY_ATTRIBUTE2 := aPlsqlItem.INDUSTRY_ATTRIBUTE2;
		aSqlItem.INDUSTRY_ATTRIBUTE3 := aPlsqlItem.INDUSTRY_ATTRIBUTE3;
		aSqlItem.INDUSTRY_ATTRIBUTE4 := aPlsqlItem.INDUSTRY_ATTRIBUTE4;
		aSqlItem.INDUSTRY_ATTRIBUTE5 := aPlsqlItem.INDUSTRY_ATTRIBUTE5;
		aSqlItem.INDUSTRY_ATTRIBUTE6 := aPlsqlItem.INDUSTRY_ATTRIBUTE6;
		aSqlItem.INDUSTRY_ATTRIBUTE7 := aPlsqlItem.INDUSTRY_ATTRIBUTE7;
		aSqlItem.INDUSTRY_ATTRIBUTE8 := aPlsqlItem.INDUSTRY_ATTRIBUTE8;
		aSqlItem.INDUSTRY_ATTRIBUTE9 := aPlsqlItem.INDUSTRY_ATTRIBUTE9;
		aSqlItem.INDUSTRY_CONTEXT := aPlsqlItem.INDUSTRY_CONTEXT;
		aSqlItem.TP_CONTEXT := aPlsqlItem.TP_CONTEXT;
		aSqlItem.TP_ATTRIBUTE1 := aPlsqlItem.TP_ATTRIBUTE1;
		aSqlItem.TP_ATTRIBUTE2 := aPlsqlItem.TP_ATTRIBUTE2;
		aSqlItem.TP_ATTRIBUTE3 := aPlsqlItem.TP_ATTRIBUTE3;
		aSqlItem.TP_ATTRIBUTE4 := aPlsqlItem.TP_ATTRIBUTE4;
		aSqlItem.TP_ATTRIBUTE5 := aPlsqlItem.TP_ATTRIBUTE5;
		aSqlItem.TP_ATTRIBUTE6 := aPlsqlItem.TP_ATTRIBUTE6;
		aSqlItem.TP_ATTRIBUTE7 := aPlsqlItem.TP_ATTRIBUTE7;
		aSqlItem.TP_ATTRIBUTE8 := aPlsqlItem.TP_ATTRIBUTE8;
		aSqlItem.TP_ATTRIBUTE9 := aPlsqlItem.TP_ATTRIBUTE9;
		aSqlItem.TP_ATTRIBUTE10 := aPlsqlItem.TP_ATTRIBUTE10;
		aSqlItem.TP_ATTRIBUTE11 := aPlsqlItem.TP_ATTRIBUTE11;
		aSqlItem.TP_ATTRIBUTE12 := aPlsqlItem.TP_ATTRIBUTE12;
		aSqlItem.TP_ATTRIBUTE13 := aPlsqlItem.TP_ATTRIBUTE13;
		aSqlItem.TP_ATTRIBUTE14 := aPlsqlItem.TP_ATTRIBUTE14;
		aSqlItem.TP_ATTRIBUTE15 := aPlsqlItem.TP_ATTRIBUTE15;
		aSqlItem.INTERMED_SHIP_TO_ORG_ID := aPlsqlItem.INTERMED_SHIP_TO_ORG_ID;
		aSqlItem.INTERMED_SHIP_TO_CONTACT_ID := aPlsqlItem.INTERMED_SHIP_TO_CONTACT_ID;
		aSqlItem.INVENTORY_ITEM_ID := aPlsqlItem.INVENTORY_ITEM_ID;
		aSqlItem.INVOICE_INTERFACE_STATUS_CODE := aPlsqlItem.INVOICE_INTERFACE_STATUS_CODE;
		aSqlItem.INVOICE_TO_CONTACT_ID := aPlsqlItem.INVOICE_TO_CONTACT_ID;
		aSqlItem.INVOICE_TO_ORG_ID := aPlsqlItem.INVOICE_TO_ORG_ID;
		aSqlItem.INVOICING_RULE_ID := aPlsqlItem.INVOICING_RULE_ID;
		aSqlItem.ORDERED_ITEM := aPlsqlItem.ORDERED_ITEM;
		aSqlItem.ITEM_REVISION := aPlsqlItem.ITEM_REVISION;
		aSqlItem.ITEM_TYPE_CODE := aPlsqlItem.ITEM_TYPE_CODE;
		aSqlItem.LAST_UPDATED_BY := aPlsqlItem.LAST_UPDATED_BY;
		aSqlItem.LAST_UPDATE_DATE := aPlsqlItem.LAST_UPDATE_DATE;
		aSqlItem.LAST_UPDATE_LOGIN := aPlsqlItem.LAST_UPDATE_LOGIN;
		aSqlItem.LATEST_ACCEPTABLE_DATE := aPlsqlItem.LATEST_ACCEPTABLE_DATE;
		aSqlItem.LINE_CATEGORY_CODE := aPlsqlItem.LINE_CATEGORY_CODE;
		aSqlItem.LINE_ID := aPlsqlItem.LINE_ID;
		aSqlItem.LINE_NUMBER := aPlsqlItem.LINE_NUMBER;
		aSqlItem.LINE_TYPE_ID := aPlsqlItem.LINE_TYPE_ID;
		aSqlItem.LINK_TO_LINE_REF := aPlsqlItem.LINK_TO_LINE_REF;
		aSqlItem.LINK_TO_LINE_ID := aPlsqlItem.LINK_TO_LINE_ID;
		aSqlItem.LINK_TO_LINE_INDEX := aPlsqlItem.LINK_TO_LINE_INDEX;
		aSqlItem.MODEL_GROUP_NUMBER := aPlsqlItem.MODEL_GROUP_NUMBER;
		aSqlItem.MFG_COMPONENT_SEQUENCE_ID := aPlsqlItem.MFG_COMPONENT_SEQUENCE_ID;
		aSqlItem.MFG_LEAD_TIME := aPlsqlItem.MFG_LEAD_TIME;
		aSqlItem.OPEN_FLAG := aPlsqlItem.OPEN_FLAG;
		aSqlItem.OPTION_FLAG := aPlsqlItem.OPTION_FLAG;
		aSqlItem.OPTION_NUMBER := aPlsqlItem.OPTION_NUMBER;
		aSqlItem.ORDERED_QUANTITY := aPlsqlItem.ORDERED_QUANTITY;
		aSqlItem.ORDERED_QUANTITY2 := aPlsqlItem.ORDERED_QUANTITY2;
		aSqlItem.ORDER_QUANTITY_UOM := aPlsqlItem.ORDER_QUANTITY_UOM;
		aSqlItem.ORDERED_QUANTITY_UOM2 := aPlsqlItem.ORDERED_QUANTITY_UOM2;
		aSqlItem.ORG_ID := aPlsqlItem.ORG_ID;
		aSqlItem.ORIG_SYS_DOCUMENT_REF := aPlsqlItem.ORIG_SYS_DOCUMENT_REF;
		aSqlItem.ORIG_SYS_LINE_REF := aPlsqlItem.ORIG_SYS_LINE_REF;
		aSqlItem.OVER_SHIP_REASON_CODE := aPlsqlItem.OVER_SHIP_REASON_CODE;
		aSqlItem.OVER_SHIP_RESOLVED_FLAG := aPlsqlItem.OVER_SHIP_RESOLVED_FLAG;
		aSqlItem.PAYMENT_TERM_ID := aPlsqlItem.PAYMENT_TERM_ID;
		aSqlItem.PLANNING_PRIORITY := aPlsqlItem.PLANNING_PRIORITY;
		aSqlItem.PREFERRED_GRADE := aPlsqlItem.PREFERRED_GRADE;
		aSqlItem.PRICE_LIST_ID := aPlsqlItem.PRICE_LIST_ID;
		aSqlItem.PRICE_REQUEST_CODE := aPlsqlItem.PRICE_REQUEST_CODE;
		aSqlItem.PRICING_ATTRIBUTE1 := aPlsqlItem.PRICING_ATTRIBUTE1;
		aSqlItem.PRICING_ATTRIBUTE10 := aPlsqlItem.PRICING_ATTRIBUTE10;
		aSqlItem.PRICING_ATTRIBUTE2 := aPlsqlItem.PRICING_ATTRIBUTE2;
		aSqlItem.PRICING_ATTRIBUTE3 := aPlsqlItem.PRICING_ATTRIBUTE3;
		aSqlItem.PRICING_ATTRIBUTE4 := aPlsqlItem.PRICING_ATTRIBUTE4;
		aSqlItem.PRICING_ATTRIBUTE5 := aPlsqlItem.PRICING_ATTRIBUTE5;
		aSqlItem.PRICING_ATTRIBUTE6 := aPlsqlItem.PRICING_ATTRIBUTE6;
		aSqlItem.PRICING_ATTRIBUTE7 := aPlsqlItem.PRICING_ATTRIBUTE7;
		aSqlItem.PRICING_ATTRIBUTE8 := aPlsqlItem.PRICING_ATTRIBUTE8;
		aSqlItem.PRICING_ATTRIBUTE9 := aPlsqlItem.PRICING_ATTRIBUTE9;
		aSqlItem.PRICING_CONTEXT := aPlsqlItem.PRICING_CONTEXT;
		aSqlItem.PRICING_DATE := aPlsqlItem.PRICING_DATE;
		aSqlItem.PRICING_QUANTITY := aPlsqlItem.PRICING_QUANTITY;
		aSqlItem.PRICING_QUANTITY_UOM := aPlsqlItem.PRICING_QUANTITY_UOM;
		aSqlItem.PROGRAM_APPLICATION_ID := aPlsqlItem.PROGRAM_APPLICATION_ID;
		aSqlItem.PROGRAM_ID := aPlsqlItem.PROGRAM_ID;
		aSqlItem.PROGRAM_UPDATE_DATE := aPlsqlItem.PROGRAM_UPDATE_DATE;
		aSqlItem.PROJECT_ID := aPlsqlItem.PROJECT_ID;
		aSqlItem.PROMISE_DATE := aPlsqlItem.PROMISE_DATE;
		aSqlItem.RE_SOURCE_FLAG := aPlsqlItem.RE_SOURCE_FLAG;
		aSqlItem.REFERENCE_CUSTOMER_TRX_LINE_ID := aPlsqlItem.REFERENCE_CUSTOMER_TRX_LINE_ID;
		aSqlItem.REFERENCE_HEADER_ID := aPlsqlItem.REFERENCE_HEADER_ID;
		aSqlItem.REFERENCE_LINE_ID := aPlsqlItem.REFERENCE_LINE_ID;
		aSqlItem.REFERENCE_TYPE := aPlsqlItem.REFERENCE_TYPE;
		aSqlItem.REQUEST_DATE := aPlsqlItem.REQUEST_DATE;
		aSqlItem.REQUEST_ID := aPlsqlItem.REQUEST_ID;
		aSqlItem.RESERVED_QUANTITY := aPlsqlItem.RESERVED_QUANTITY;
		aSqlItem.RETURN_ATTRIBUTE1 := aPlsqlItem.RETURN_ATTRIBUTE1;
		aSqlItem.RETURN_ATTRIBUTE10 := aPlsqlItem.RETURN_ATTRIBUTE10;
		aSqlItem.RETURN_ATTRIBUTE11 := aPlsqlItem.RETURN_ATTRIBUTE11;
		aSqlItem.RETURN_ATTRIBUTE12 := aPlsqlItem.RETURN_ATTRIBUTE12;
		aSqlItem.RETURN_ATTRIBUTE13 := aPlsqlItem.RETURN_ATTRIBUTE13;
		aSqlItem.RETURN_ATTRIBUTE14 := aPlsqlItem.RETURN_ATTRIBUTE14;
		aSqlItem.RETURN_ATTRIBUTE15 := aPlsqlItem.RETURN_ATTRIBUTE15;
		aSqlItem.RETURN_ATTRIBUTE2 := aPlsqlItem.RETURN_ATTRIBUTE2;
		aSqlItem.RETURN_ATTRIBUTE3 := aPlsqlItem.RETURN_ATTRIBUTE3;
		aSqlItem.RETURN_ATTRIBUTE4 := aPlsqlItem.RETURN_ATTRIBUTE4;
		aSqlItem.RETURN_ATTRIBUTE5 := aPlsqlItem.RETURN_ATTRIBUTE5;
		aSqlItem.RETURN_ATTRIBUTE6 := aPlsqlItem.RETURN_ATTRIBUTE6;
		aSqlItem.RETURN_ATTRIBUTE7 := aPlsqlItem.RETURN_ATTRIBUTE7;
		aSqlItem.RETURN_ATTRIBUTE8 := aPlsqlItem.RETURN_ATTRIBUTE8;
		aSqlItem.RETURN_ATTRIBUTE9 := aPlsqlItem.RETURN_ATTRIBUTE9;
		aSqlItem.RETURN_CONTEXT := aPlsqlItem.RETURN_CONTEXT;
		aSqlItem.RETURN_REASON_CODE := aPlsqlItem.RETURN_REASON_CODE;
		aSqlItem.RLA_SCHEDULE_TYPE_CODE := aPlsqlItem.RLA_SCHEDULE_TYPE_CODE;
		aSqlItem.SALESREP_ID := aPlsqlItem.SALESREP_ID;
		aSqlItem.SCHEDULE_ARRIVAL_DATE := aPlsqlItem.SCHEDULE_ARRIVAL_DATE;
		aSqlItem.SCHEDULE_SHIP_DATE := aPlsqlItem.SCHEDULE_SHIP_DATE;
		aSqlItem.SCHEDULE_ACTION_CODE := aPlsqlItem.SCHEDULE_ACTION_CODE;
		aSqlItem.SCHEDULE_STATUS_CODE := aPlsqlItem.SCHEDULE_STATUS_CODE;
		aSqlItem.SHIPMENT_NUMBER := aPlsqlItem.SHIPMENT_NUMBER;
		aSqlItem.SHIPMENT_PRIORITY_CODE := aPlsqlItem.SHIPMENT_PRIORITY_CODE;
		aSqlItem.SHIPPED_QUANTITY := aPlsqlItem.SHIPPED_QUANTITY;
		aSqlItem.SHIPPED_QUANTITY2 := aPlsqlItem.SHIPPED_QUANTITY2;
		aSqlItem.SHIPPING_INTERFACED_FLAG := aPlsqlItem.SHIPPING_INTERFACED_FLAG;
		aSqlItem.SHIPPING_METHOD_CODE := aPlsqlItem.SHIPPING_METHOD_CODE;
		aSqlItem.SHIPPING_QUANTITY := aPlsqlItem.SHIPPING_QUANTITY;
		aSqlItem.SHIPPING_QUANTITY2 := aPlsqlItem.SHIPPING_QUANTITY2;
		aSqlItem.SHIPPING_QUANTITY_UOM := aPlsqlItem.SHIPPING_QUANTITY_UOM;
		aSqlItem.SHIPPING_QUANTITY_UOM2 := aPlsqlItem.SHIPPING_QUANTITY_UOM2;
		aSqlItem.SHIP_FROM_ORG_ID := aPlsqlItem.SHIP_FROM_ORG_ID;
		aSqlItem.SHIP_MODEL_COMPLETE_FLAG := aPlsqlItem.SHIP_MODEL_COMPLETE_FLAG;
		aSqlItem.SHIP_SET_ID := aPlsqlItem.SHIP_SET_ID;
		aSqlItem.FULFILLMENT_SET_ID := aPlsqlItem.FULFILLMENT_SET_ID;
		aSqlItem.SHIP_TOLERANCE_ABOVE := aPlsqlItem.SHIP_TOLERANCE_ABOVE;
		aSqlItem.SHIP_TOLERANCE_BELOW := aPlsqlItem.SHIP_TOLERANCE_BELOW;
		aSqlItem.SHIP_TO_CONTACT_ID := aPlsqlItem.SHIP_TO_CONTACT_ID;
		aSqlItem.SHIP_TO_ORG_ID := aPlsqlItem.SHIP_TO_ORG_ID;
		aSqlItem.SOLD_TO_ORG_ID := aPlsqlItem.SOLD_TO_ORG_ID;
                --oe_debug_pub.add('Srini 103 header sold_to_org_id '||aSqlItem.SOLD_TO_ORG_ID);
		aSqlItem.SOLD_FROM_ORG_ID := aPlsqlItem.SOLD_FROM_ORG_ID;
		aSqlItem.SORT_ORDER := aPlsqlItem.SORT_ORDER;
		aSqlItem.SOURCE_DOCUMENT_ID := aPlsqlItem.SOURCE_DOCUMENT_ID;
		aSqlItem.SOURCE_DOCUMENT_LINE_ID := aPlsqlItem.SOURCE_DOCUMENT_LINE_ID;
		aSqlItem.SOURCE_DOCUMENT_TYPE_ID := aPlsqlItem.SOURCE_DOCUMENT_TYPE_ID;
		aSqlItem.SOURCE_TYPE_CODE := aPlsqlItem.SOURCE_TYPE_CODE;
		aSqlItem.SPLIT_FROM_LINE_ID := aPlsqlItem.SPLIT_FROM_LINE_ID;
		aSqlItem.TASK_ID := aPlsqlItem.TASK_ID;
		aSqlItem.TAX_CODE := aPlsqlItem.TAX_CODE;
		aSqlItem.TAX_DATE := aPlsqlItem.TAX_DATE;
		aSqlItem.TAX_EXEMPT_FLAG := aPlsqlItem.TAX_EXEMPT_FLAG;
		aSqlItem.TAX_EXEMPT_NUMBER := aPlsqlItem.TAX_EXEMPT_NUMBER;
		aSqlItem.TAX_EXEMPT_REASON_CODE := aPlsqlItem.TAX_EXEMPT_REASON_CODE;
		aSqlItem.TAX_POINT_CODE := aPlsqlItem.TAX_POINT_CODE;
		aSqlItem.TAX_RATE := aPlsqlItem.TAX_RATE;
		aSqlItem.TAX_VALUE := aPlsqlItem.TAX_VALUE;
		aSqlItem.TOP_MODEL_LINE_REF := aPlsqlItem.TOP_MODEL_LINE_REF;
		aSqlItem.TOP_MODEL_LINE_ID := aPlsqlItem.TOP_MODEL_LINE_ID;
		aSqlItem.TOP_MODEL_LINE_INDEX := aPlsqlItem.TOP_MODEL_LINE_INDEX;
		aSqlItem.UNIT_LIST_PRICE := aPlsqlItem.UNIT_LIST_PRICE;
		aSqlItem.UNIT_LIST_PRICE_PER_PQTY := aPlsqlItem.UNIT_LIST_PRICE_PER_PQTY;
		aSqlItem.UNIT_SELLING_PRICE := aPlsqlItem.UNIT_SELLING_PRICE;
		aSqlItem.UNIT_SELLING_PRICE_PER_PQTY := aPlsqlItem.UNIT_SELLING_PRICE_PER_PQTY;
		aSqlItem.VEH_CUS_ITEM_CUM_KEY_ID := aPlsqlItem.VEH_CUS_ITEM_CUM_KEY_ID;
		aSqlItem.VISIBLE_DEMAND_FLAG := aPlsqlItem.VISIBLE_DEMAND_FLAG;
		aSqlItem.RETURN_STATUS := aPlsqlItem.RETURN_STATUS;
		aSqlItem.DB_FLAG := aPlsqlItem.DB_FLAG;
		aSqlItem.OPERATION := aPlsqlItem.OPERATION;
		aSqlItem.FIRST_ACK_CODE := aPlsqlItem.FIRST_ACK_CODE;
		aSqlItem.FIRST_ACK_DATE := aPlsqlItem.FIRST_ACK_DATE;
		aSqlItem.LAST_ACK_CODE := aPlsqlItem.LAST_ACK_CODE;
		aSqlItem.LAST_ACK_DATE := aPlsqlItem.LAST_ACK_DATE;
		aSqlItem.CHANGE_REASON := aPlsqlItem.CHANGE_REASON;
		aSqlItem.CHANGE_COMMENTS := aPlsqlItem.CHANGE_COMMENTS;
		aSqlItem.ARRIVAL_SET := aPlsqlItem.ARRIVAL_SET;
		aSqlItem.SHIP_SET := aPlsqlItem.SHIP_SET;
		aSqlItem.FULFILLMENT_SET := aPlsqlItem.FULFILLMENT_SET;
		aSqlItem.ORDER_SOURCE_ID := aPlsqlItem.ORDER_SOURCE_ID;
		aSqlItem.ORIG_SYS_SHIPMENT_REF := aPlsqlItem.ORIG_SYS_SHIPMENT_REF;
		aSqlItem.CHANGE_SEQUENCE := aPlsqlItem.CHANGE_SEQUENCE;
		aSqlItem.CHANGE_REQUEST_CODE := aPlsqlItem.CHANGE_REQUEST_CODE;
		aSqlItem.STATUS_FLAG := aPlsqlItem.STATUS_FLAG;
		aSqlItem.DROP_SHIP_FLAG := aPlsqlItem.DROP_SHIP_FLAG;
		aSqlItem.CUSTOMER_LINE_NUMBER := aPlsqlItem.CUSTOMER_LINE_NUMBER;
		aSqlItem.CUSTOMER_SHIPMENT_NUMBER := aPlsqlItem.CUSTOMER_SHIPMENT_NUMBER;
		aSqlItem.CUSTOMER_ITEM_NET_PRICE := aPlsqlItem.CUSTOMER_ITEM_NET_PRICE;
		aSqlItem.CUSTOMER_PAYMENT_TERM_ID := aPlsqlItem.CUSTOMER_PAYMENT_TERM_ID;
		aSqlItem.ORDERED_ITEM_ID := aPlsqlItem.ORDERED_ITEM_ID;
		aSqlItem.ITEM_IDENTIFIER_TYPE := aPlsqlItem.ITEM_IDENTIFIER_TYPE;
		aSqlItem.SHIPPING_INSTRUCTIONS := aPlsqlItem.SHIPPING_INSTRUCTIONS;
		aSqlItem.PACKING_INSTRUCTIONS := aPlsqlItem.PACKING_INSTRUCTIONS;
		aSqlItem.CALCULATE_PRICE_FLAG := aPlsqlItem.CALCULATE_PRICE_FLAG;
		aSqlItem.INVOICED_QUANTITY := aPlsqlItem.INVOICED_QUANTITY;
		aSqlItem.SERVICE_TXN_REASON_CODE := aPlsqlItem.SERVICE_TXN_REASON_CODE;
		aSqlItem.SERVICE_TXN_COMMENTS := aPlsqlItem.SERVICE_TXN_COMMENTS;
		aSqlItem.SERVICE_DURATION := aPlsqlItem.SERVICE_DURATION;
		aSqlItem.SERVICE_PERIOD := aPlsqlItem.SERVICE_PERIOD;
		aSqlItem.SERVICE_START_DATE := aPlsqlItem.SERVICE_START_DATE;
		aSqlItem.SERVICE_END_DATE := aPlsqlItem.SERVICE_END_DATE;
		aSqlItem.SERVICE_COTERMINATE_FLAG := aPlsqlItem.SERVICE_COTERMINATE_FLAG;
		aSqlItem.UNIT_LIST_PERCENT := aPlsqlItem.UNIT_LIST_PERCENT;
		aSqlItem.UNIT_SELLING_PERCENT := aPlsqlItem.UNIT_SELLING_PERCENT;
		aSqlItem.UNIT_PERCENT_BASE_PRICE := aPlsqlItem.UNIT_PERCENT_BASE_PRICE;
		aSqlItem.SERVICE_NUMBER := aPlsqlItem.SERVICE_NUMBER;
		aSqlItem.SERVICE_REFERENCE_TYPE_CODE := aPlsqlItem.SERVICE_REFERENCE_TYPE_CODE;
		aSqlItem.SERVICE_REFERENCE_LINE_ID := aPlsqlItem.SERVICE_REFERENCE_LINE_ID;
		aSqlItem.SERVICE_REFERENCE_SYSTEM_ID := aPlsqlItem.SERVICE_REFERENCE_SYSTEM_ID;
		aSqlItem.SERVICE_REF_ORDER_NUMBER := aPlsqlItem.SERVICE_REF_ORDER_NUMBER;
		aSqlItem.SERVICE_REF_LINE_NUMBER := aPlsqlItem.SERVICE_REF_LINE_NUMBER;
		aSqlItem.SERVICE_REFERENCE_ORDER := aPlsqlItem.SERVICE_REFERENCE_ORDER;
		aSqlItem.SERVICE_REFERENCE_LINE := aPlsqlItem.SERVICE_REFERENCE_LINE;
		aSqlItem.SERVICE_REFERENCE_SYSTEM := aPlsqlItem.SERVICE_REFERENCE_SYSTEM;
		aSqlItem.SERVICE_REF_SHIPMENT_NUMBER := aPlsqlItem.SERVICE_REF_SHIPMENT_NUMBER;
		aSqlItem.SERVICE_REF_OPTION_NUMBER := aPlsqlItem.SERVICE_REF_OPTION_NUMBER;
		aSqlItem.SERVICE_LINE_INDEX := aPlsqlItem.SERVICE_LINE_INDEX;
		aSqlItem.LINE_SET_ID := aPlsqlItem.LINE_SET_ID;
		aSqlItem.SPLIT_BY := aPlsqlItem.SPLIT_BY;
		aSqlItem.SPLIT_ACTION_CODE := aPlsqlItem.SPLIT_ACTION_CODE;
		aSqlItem.SHIPPABLE_FLAG := aPlsqlItem.SHIPPABLE_FLAG;
		aSqlItem.MODEL_REMNANT_FLAG := aPlsqlItem.MODEL_REMNANT_FLAG;
		aSqlItem.FLOW_STATUS_CODE := aPlsqlItem.FLOW_STATUS_CODE;
		aSqlItem.FULFILLED_FLAG := aPlsqlItem.FULFILLED_FLAG;
		aSqlItem.FULFILLMENT_METHOD_CODE := aPlsqlItem.FULFILLMENT_METHOD_CODE;
		aSqlItem.REVENUE_AMOUNT := aPlsqlItem.REVENUE_AMOUNT;
		aSqlItem.MARKETING_SOURCE_CODE_ID := aPlsqlItem.MARKETING_SOURCE_CODE_ID;
		aSqlItem.FULFILLMENT_DATE := aPlsqlItem.FULFILLMENT_DATE;
		aSqlItem.SEMI_PROCESSED_FLAG := SYS.SQLJUTL.BOOL2INT(aPlsqlItem.SEMI_PROCESSED_FLAG);
		aSqlItem.UPGRADED_FLAG := aPlsqlItem.UPGRADED_FLAG;
		aSqlItem.LOCK_CONTROL := aPlsqlItem.LOCK_CONTROL;
		aSqlItem.SUBINVENTORY := aPlsqlItem.SUBINVENTORY;
		aSqlItem.SPLIT_FROM_LINE_REF := aPlsqlItem.SPLIT_FROM_LINE_REF;
		aSqlItem.SPLIT_FROM_SHIPMENT_REF := aPlsqlItem.SPLIT_FROM_SHIPMENT_REF;
		aSqlItem.SHIP_TO_EDI_LOCATION_CODE := aPlsqlItem.SHIP_TO_EDI_LOCATION_CODE;
		aSqlItem.BILL_TO_EDI_LOCATION_CODE := aPlsqlItem.BILL_TO_EDI_LOCATION_CODE;
		aSqlItem.SHIP_FROM_EDI_LOCATION_CODE := aPlsqlItem.SHIP_FROM_EDI_LOCATION_CODE;
		aSqlItem.SHIP_FROM_ADDRESS_ID := aPlsqlItem.SHIP_FROM_ADDRESS_ID;
		aSqlItem.SOLD_TO_ADDRESS_ID := aPlsqlItem.SOLD_TO_ADDRESS_ID;
		aSqlItem.SHIP_TO_ADDRESS_ID := aPlsqlItem.SHIP_TO_ADDRESS_ID;
		aSqlItem.INVOICE_ADDRESS_ID := aPlsqlItem.INVOICE_ADDRESS_ID;
		aSqlItem.SHIP_TO_ADDRESS_CODE := aPlsqlItem.SHIP_TO_ADDRESS_CODE;
		aSqlItem.ORIGINAL_INVENTORY_ITEM_ID := aPlsqlItem.ORIGINAL_INVENTORY_ITEM_ID;
		aSqlItem.ORIGINAL_ITEM_IDENTIFIER_TYPE := aPlsqlItem.ORIGINAL_ITEM_IDENTIFIER_TYPE;
		aSqlItem.ORIGINAL_ORDERED_ITEM_ID := aPlsqlItem.ORIGINAL_ORDERED_ITEM_ID;
		aSqlItem.ORIGINAL_ORDERED_ITEM := aPlsqlItem.ORIGINAL_ORDERED_ITEM;
		aSqlItem.ITEM_SUBSTITUTION_TYPE_CODE := aPlsqlItem.ITEM_SUBSTITUTION_TYPE_CODE;
		aSqlItem.LATE_DEMAND_PENALTY_FACTOR := aPlsqlItem.LATE_DEMAND_PENALTY_FACTOR;
		aSqlItem.OVERRIDE_ATP_DATE_CODE := aPlsqlItem.OVERRIDE_ATP_DATE_CODE;
		aSqlItem.SHIP_TO_CUSTOMER_ID := aPlsqlItem.SHIP_TO_CUSTOMER_ID;
		aSqlItem.INVOICE_TO_CUSTOMER_ID := aPlsqlItem.INVOICE_TO_CUSTOMER_ID;
		aSqlItem.DELIVER_TO_CUSTOMER_ID := aPlsqlItem.DELIVER_TO_CUSTOMER_ID;
		aSqlItem.ACCOUNTING_RULE_DURATION := aPlsqlItem.ACCOUNTING_RULE_DURATION;
		aSqlItem.UNIT_COST := aPlsqlItem.UNIT_COST;
		aSqlItem.USER_ITEM_DESCRIPTION := aPlsqlItem.USER_ITEM_DESCRIPTION;
		aSqlItem.XML_TRANSACTION_TYPE_CODE := aPlsqlItem.XML_TRANSACTION_TYPE_CODE;
		aSqlItem.ITEM_RELATIONSHIP_TYPE := aPlsqlItem.ITEM_RELATIONSHIP_TYPE;
		aSqlItem.BLANKET_NUMBER := aPlsqlItem.BLANKET_NUMBER;
		aSqlItem.BLANKET_LINE_NUMBER := aPlsqlItem.BLANKET_LINE_NUMBER;
		aSqlItem.BLANKET_VERSION_NUMBER := aPlsqlItem.BLANKET_VERSION_NUMBER;
		aSqlItem.CSO_RESPONSE_FLAG := aPlsqlItem.CSO_RESPONSE_FLAG;
		aSqlItem.FIRM_DEMAND_FLAG := aPlsqlItem.FIRM_DEMAND_FLAG;
		aSqlItem.EARLIEST_SHIP_DATE := aPlsqlItem.EARLIEST_SHIP_DATE;
		aSqlItem.TRANSACTION_PHASE_CODE := aPlsqlItem.TRANSACTION_PHASE_CODE;
		aSqlItem.SOURCE_DOCUMENT_VERSION_NUMBER := aPlsqlItem.SOURCE_DOCUMENT_VERSION_NUMBER;
		aSqlItem.MINISITE_ID := aPlsqlItem.MINISITE_ID;
		aSqlItem.IB_OWNER := aPlsqlItem.IB_OWNER;
		aSqlItem.IB_INSTALLED_AT_LOCATION := aPlsqlItem.IB_INSTALLED_AT_LOCATION;
		aSqlItem.IB_CURRENT_LOCATION := aPlsqlItem.IB_CURRENT_LOCATION;
		aSqlItem.END_CUSTOMER_ID := aPlsqlItem.END_CUSTOMER_ID;
		aSqlItem.END_CUSTOMER_CONTACT_ID := aPlsqlItem.END_CUSTOMER_CONTACT_ID;
		aSqlItem.END_CUSTOMER_SITE_USE_ID := aPlsqlItem.END_CUSTOMER_SITE_USE_ID;
		aSqlItem.SUPPLIER_SIGNATURE := aPlsqlItem.SUPPLIER_SIGNATURE;
		aSqlItem.SUPPLIER_SIGNATURE_DATE := aPlsqlItem.SUPPLIER_SIGNATURE_DATE;
		aSqlItem.CUSTOMER_SIGNATURE := aPlsqlItem.CUSTOMER_SIGNATURE;
		aSqlItem.CUSTOMER_SIGNATURE_DATE := aPlsqlItem.CUSTOMER_SIGNATURE_DATE;
		aSqlItem.SHIP_TO_PARTY_ID := aPlsqlItem.SHIP_TO_PARTY_ID;
		aSqlItem.SHIP_TO_PARTY_SITE_ID := aPlsqlItem.SHIP_TO_PARTY_SITE_ID;
		aSqlItem.SHIP_TO_PARTY_SITE_USE_ID := aPlsqlItem.SHIP_TO_PARTY_SITE_USE_ID;
		aSqlItem.DELIVER_TO_PARTY_ID := aPlsqlItem.DELIVER_TO_PARTY_ID;
		aSqlItem.DELIVER_TO_PARTY_SITE_ID := aPlsqlItem.DELIVER_TO_PARTY_SITE_ID;
		aSqlItem.DELIVER_TO_PARTY_SITE_USE_ID := aPlsqlItem.DELIVER_TO_PARTY_SITE_USE_ID;
		aSqlItem.INVOICE_TO_PARTY_ID := aPlsqlItem.INVOICE_TO_PARTY_ID;
		aSqlItem.INVOICE_TO_PARTY_SITE_ID := aPlsqlItem.INVOICE_TO_PARTY_SITE_ID;
		aSqlItem.INVOICE_TO_PARTY_SITE_USE_ID := aPlsqlItem.INVOICE_TO_PARTY_SITE_USE_ID;
		aSqlItem.END_CUSTOMER_PARTY_ID := aPlsqlItem.END_CUSTOMER_PARTY_ID;
		aSqlItem.END_CUSTOMER_PARTY_SITE_ID := aPlsqlItem.END_CUSTOMER_PARTY_SITE_ID;
		aSqlItem.END_CUSTOMER_PARTY_SITE_USE_ID := aPlsqlItem.END_CUSTOMER_PARTY_SITE_USE_ID;
		aSqlItem.END_CUSTOMER_PARTY_NUMBER := aPlsqlItem.END_CUSTOMER_PARTY_NUMBER;
		aSqlItem.END_CUSTOMER_ORG_CONTACT_ID := aPlsqlItem.END_CUSTOMER_ORG_CONTACT_ID;
		aSqlItem.SHIP_TO_CUSTOMER_PARTY_ID := aPlsqlItem.SHIP_TO_CUSTOMER_PARTY_ID;
		aSqlItem.DELIVER_TO_CUSTOMER_PARTY_ID := aPlsqlItem.DELIVER_TO_CUSTOMER_PARTY_ID;
		aSqlItem.INVOICE_TO_CUSTOMER_PARTY_ID := aPlsqlItem.INVOICE_TO_CUSTOMER_PARTY_ID;
		aSqlItem.SHIP_TO_ORG_CONTACT_ID := aPlsqlItem.SHIP_TO_ORG_CONTACT_ID;
		aSqlItem.DELIVER_TO_ORG_CONTACT_ID := aPlsqlItem.DELIVER_TO_ORG_CONTACT_ID;
		aSqlItem.INVOICE_TO_ORG_CONTACT_ID := aPlsqlItem.INVOICE_TO_ORG_CONTACT_ID;
		aSqlItem.RETROBILL_REQUEST_ID := aPlsqlItem.RETROBILL_REQUEST_ID;
		aSqlItem.ORIGINAL_LIST_PRICE := aPlsqlItem.ORIGINAL_LIST_PRICE;
		aSqlItem.COMMITMENT_APPLIED_AMOUNT := aPlsqlItem.COMMITMENT_APPLIED_AMOUNT;
		aSqlItem.SHIP_TO_PARTY_NUMBER := aPlsqlItem.SHIP_TO_PARTY_NUMBER;
		aSqlItem.INVOICE_TO_PARTY_NUMBER := aPlsqlItem.INVOICE_TO_PARTY_NUMBER;
		aSqlItem.DELIVER_TO_PARTY_NUMBER := aPlsqlItem.DELIVER_TO_PARTY_NUMBER;
		aSqlItem.ORDER_FIRMED_DATE := aPlsqlItem.ORDER_FIRMED_DATE;
		aSqlItem.ACTUAL_FULFILLMENT_DATE := aPlsqlItem.ACTUAL_FULFILLMENT_DATE;
		aSqlItem.CHANGED_LINES_POCAO := aPlsqlItem.CHANGED_LINES_POCAO;
		aSqlItem.CHARGE_PERIODICITY_CODE := aPlsqlItem.CHARGE_PERIODICITY_CODE;
		RETURN aSqlItem;
	END PL_TO_SQL35;

	FUNCTION SQL_TO_PL35(aSqlItem OE_ORDER_PUB_LINE_REC_TYPE)
	RETURN OE_ORDER_PUB.LINE_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_REC_TYPE;
	BEGIN

                oe_debug_pub.add('Inside the SQL_TO_PL35', 1);

		aPlsqlItem.ACCOUNTING_RULE_ID := aSqlItem.ACCOUNTING_RULE_ID;
		aPlsqlItem.ACTUAL_ARRIVAL_DATE := aSqlItem.ACTUAL_ARRIVAL_DATE;
		aPlsqlItem.ACTUAL_SHIPMENT_DATE := aSqlItem.ACTUAL_SHIPMENT_DATE;
		aPlsqlItem.AGREEMENT_ID := aSqlItem.AGREEMENT_ID;
		aPlsqlItem.ARRIVAL_SET_ID := aSqlItem.ARRIVAL_SET_ID;
		aPlsqlItem.ATO_LINE_ID := aSqlItem.ATO_LINE_ID;
		aPlsqlItem.ATTRIBUTE1 := aSqlItem.ATTRIBUTE1;
		aPlsqlItem.ATTRIBUTE10 := aSqlItem.ATTRIBUTE10;
		aPlsqlItem.ATTRIBUTE11 := aSqlItem.ATTRIBUTE11;
		aPlsqlItem.ATTRIBUTE12 := aSqlItem.ATTRIBUTE12;
		aPlsqlItem.ATTRIBUTE13 := aSqlItem.ATTRIBUTE13;
		aPlsqlItem.ATTRIBUTE14 := aSqlItem.ATTRIBUTE14;
		aPlsqlItem.ATTRIBUTE15 := aSqlItem.ATTRIBUTE15;
		aPlsqlItem.ATTRIBUTE16 := aSqlItem.ATTRIBUTE16;
		aPlsqlItem.ATTRIBUTE17 := aSqlItem.ATTRIBUTE17;
		aPlsqlItem.ATTRIBUTE18 := aSqlItem.ATTRIBUTE18;
		aPlsqlItem.ATTRIBUTE19 := aSqlItem.ATTRIBUTE19;
		aPlsqlItem.ATTRIBUTE2 := aSqlItem.ATTRIBUTE2;
		aPlsqlItem.ATTRIBUTE20 := aSqlItem.ATTRIBUTE20;
		aPlsqlItem.ATTRIBUTE3 := aSqlItem.ATTRIBUTE3;
		aPlsqlItem.ATTRIBUTE4 := aSqlItem.ATTRIBUTE4;
		aPlsqlItem.ATTRIBUTE5 := aSqlItem.ATTRIBUTE5;
		aPlsqlItem.ATTRIBUTE6 := aSqlItem.ATTRIBUTE6;
		aPlsqlItem.ATTRIBUTE7 := aSqlItem.ATTRIBUTE7;
		aPlsqlItem.ATTRIBUTE8 := aSqlItem.ATTRIBUTE8;
		aPlsqlItem.ATTRIBUTE9 := aSqlItem.ATTRIBUTE9;
		aPlsqlItem.AUTHORIZED_TO_SHIP_FLAG := aSqlItem.AUTHORIZED_TO_SHIP_FLAG;
		aPlsqlItem.AUTO_SELECTED_QUANTITY := aSqlItem.AUTO_SELECTED_QUANTITY;
		aPlsqlItem.BOOKED_FLAG := aSqlItem.BOOKED_FLAG;
		aPlsqlItem.CANCELLED_FLAG := aSqlItem.CANCELLED_FLAG;
		aPlsqlItem.CANCELLED_QUANTITY := aSqlItem.CANCELLED_QUANTITY;
		aPlsqlItem.CANCELLED_QUANTITY2 := aSqlItem.CANCELLED_QUANTITY2;
		aPlsqlItem.COMMITMENT_ID := aSqlItem.COMMITMENT_ID;
		aPlsqlItem.COMPONENT_CODE := aSqlItem.COMPONENT_CODE;
		aPlsqlItem.COMPONENT_NUMBER := aSqlItem.COMPONENT_NUMBER;
		aPlsqlItem.COMPONENT_SEQUENCE_ID := aSqlItem.COMPONENT_SEQUENCE_ID;
		aPlsqlItem.CONFIG_HEADER_ID := aSqlItem.CONFIG_HEADER_ID;
		aPlsqlItem.CONFIG_REV_NBR := aSqlItem.CONFIG_REV_NBR;
		aPlsqlItem.CONFIG_DISPLAY_SEQUENCE := aSqlItem.CONFIG_DISPLAY_SEQUENCE;
		aPlsqlItem.CONFIGURATION_ID := aSqlItem.CONFIGURATION_ID;
		aPlsqlItem.CONTEXT := aSqlItem.CONTEXT;
		aPlsqlItem.CREATED_BY := aSqlItem.CREATED_BY;
		aPlsqlItem.CREATION_DATE := aSqlItem.CREATION_DATE;
		aPlsqlItem.CREDIT_INVOICE_LINE_ID := aSqlItem.CREDIT_INVOICE_LINE_ID;
		aPlsqlItem.CUSTOMER_DOCK_CODE := aSqlItem.CUSTOMER_DOCK_CODE;
		aPlsqlItem.CUSTOMER_JOB := aSqlItem.CUSTOMER_JOB;
		aPlsqlItem.CUSTOMER_PRODUCTION_LINE := aSqlItem.CUSTOMER_PRODUCTION_LINE;
		aPlsqlItem.CUSTOMER_TRX_LINE_ID := aSqlItem.CUSTOMER_TRX_LINE_ID;
		aPlsqlItem.CUST_MODEL_SERIAL_NUMBER := aSqlItem.CUST_MODEL_SERIAL_NUMBER;
		aPlsqlItem.CUST_PO_NUMBER := aSqlItem.CUST_PO_NUMBER;
		aPlsqlItem.CUST_PRODUCTION_SEQ_NUM := aSqlItem.CUST_PRODUCTION_SEQ_NUM;
		aPlsqlItem.DELIVERY_LEAD_TIME := aSqlItem.DELIVERY_LEAD_TIME;
		aPlsqlItem.DELIVER_TO_CONTACT_ID := aSqlItem.DELIVER_TO_CONTACT_ID;
		aPlsqlItem.DELIVER_TO_ORG_ID := aSqlItem.DELIVER_TO_ORG_ID;
		aPlsqlItem.DEMAND_BUCKET_TYPE_CODE := aSqlItem.DEMAND_BUCKET_TYPE_CODE;
		aPlsqlItem.DEMAND_CLASS_CODE := aSqlItem.DEMAND_CLASS_CODE;
		aPlsqlItem.DEP_PLAN_REQUIRED_FLAG := aSqlItem.DEP_PLAN_REQUIRED_FLAG;
		aPlsqlItem.EARLIEST_ACCEPTABLE_DATE := aSqlItem.EARLIEST_ACCEPTABLE_DATE;
		aPlsqlItem.END_ITEM_UNIT_NUMBER := aSqlItem.END_ITEM_UNIT_NUMBER;
		aPlsqlItem.EXPLOSION_DATE := aSqlItem.EXPLOSION_DATE;
		aPlsqlItem.FOB_POINT_CODE := aSqlItem.FOB_POINT_CODE;
		aPlsqlItem.FREIGHT_CARRIER_CODE := aSqlItem.FREIGHT_CARRIER_CODE;
		aPlsqlItem.FREIGHT_TERMS_CODE := aSqlItem.FREIGHT_TERMS_CODE;
		aPlsqlItem.FULFILLED_QUANTITY := aSqlItem.FULFILLED_QUANTITY;
		aPlsqlItem.FULFILLED_QUANTITY2 := aSqlItem.FULFILLED_QUANTITY2;
		aPlsqlItem.GLOBAL_ATTRIBUTE1 := aSqlItem.GLOBAL_ATTRIBUTE1;
		aPlsqlItem.GLOBAL_ATTRIBUTE10 := aSqlItem.GLOBAL_ATTRIBUTE10;
		aPlsqlItem.GLOBAL_ATTRIBUTE11 := aSqlItem.GLOBAL_ATTRIBUTE11;
		aPlsqlItem.GLOBAL_ATTRIBUTE12 := aSqlItem.GLOBAL_ATTRIBUTE12;
		aPlsqlItem.GLOBAL_ATTRIBUTE13 := aSqlItem.GLOBAL_ATTRIBUTE13;
		aPlsqlItem.GLOBAL_ATTRIBUTE14 := aSqlItem.GLOBAL_ATTRIBUTE14;
		aPlsqlItem.GLOBAL_ATTRIBUTE15 := aSqlItem.GLOBAL_ATTRIBUTE15;
		aPlsqlItem.GLOBAL_ATTRIBUTE16 := aSqlItem.GLOBAL_ATTRIBUTE16;
		aPlsqlItem.GLOBAL_ATTRIBUTE17 := aSqlItem.GLOBAL_ATTRIBUTE17;
		aPlsqlItem.GLOBAL_ATTRIBUTE18 := aSqlItem.GLOBAL_ATTRIBUTE18;
		aPlsqlItem.GLOBAL_ATTRIBUTE19 := aSqlItem.GLOBAL_ATTRIBUTE19;
		aPlsqlItem.GLOBAL_ATTRIBUTE2 := aSqlItem.GLOBAL_ATTRIBUTE2;
		aPlsqlItem.GLOBAL_ATTRIBUTE20 := aSqlItem.GLOBAL_ATTRIBUTE20;
		aPlsqlItem.GLOBAL_ATTRIBUTE3 := aSqlItem.GLOBAL_ATTRIBUTE3;
		aPlsqlItem.GLOBAL_ATTRIBUTE4 := aSqlItem.GLOBAL_ATTRIBUTE4;
		aPlsqlItem.GLOBAL_ATTRIBUTE5 := aSqlItem.GLOBAL_ATTRIBUTE5;
		aPlsqlItem.GLOBAL_ATTRIBUTE6 := aSqlItem.GLOBAL_ATTRIBUTE6;
		aPlsqlItem.GLOBAL_ATTRIBUTE7 := aSqlItem.GLOBAL_ATTRIBUTE7;
		aPlsqlItem.GLOBAL_ATTRIBUTE8 := aSqlItem.GLOBAL_ATTRIBUTE8;
		aPlsqlItem.GLOBAL_ATTRIBUTE9 := aSqlItem.GLOBAL_ATTRIBUTE9;
		aPlsqlItem.GLOBAL_ATTRIBUTE_CATEGORY := aSqlItem.GLOBAL_ATTRIBUTE_CATEGORY;
		aPlsqlItem.HEADER_ID := aSqlItem.HEADER_ID;
		aPlsqlItem.INDUSTRY_ATTRIBUTE1 := aSqlItem.INDUSTRY_ATTRIBUTE1;
		aPlsqlItem.INDUSTRY_ATTRIBUTE10 := aSqlItem.INDUSTRY_ATTRIBUTE10;
		aPlsqlItem.INDUSTRY_ATTRIBUTE11 := aSqlItem.INDUSTRY_ATTRIBUTE11;
		aPlsqlItem.INDUSTRY_ATTRIBUTE12 := aSqlItem.INDUSTRY_ATTRIBUTE12;
		aPlsqlItem.INDUSTRY_ATTRIBUTE13 := aSqlItem.INDUSTRY_ATTRIBUTE13;
		aPlsqlItem.INDUSTRY_ATTRIBUTE14 := aSqlItem.INDUSTRY_ATTRIBUTE14;
		aPlsqlItem.INDUSTRY_ATTRIBUTE15 := aSqlItem.INDUSTRY_ATTRIBUTE15;
		aPlsqlItem.INDUSTRY_ATTRIBUTE16 := aSqlItem.INDUSTRY_ATTRIBUTE16;
		aPlsqlItem.INDUSTRY_ATTRIBUTE17 := aSqlItem.INDUSTRY_ATTRIBUTE17;
		aPlsqlItem.INDUSTRY_ATTRIBUTE18 := aSqlItem.INDUSTRY_ATTRIBUTE18;
		aPlsqlItem.INDUSTRY_ATTRIBUTE19 := aSqlItem.INDUSTRY_ATTRIBUTE19;
		aPlsqlItem.INDUSTRY_ATTRIBUTE20 := aSqlItem.INDUSTRY_ATTRIBUTE20;
		aPlsqlItem.INDUSTRY_ATTRIBUTE21 := aSqlItem.INDUSTRY_ATTRIBUTE21;
		aPlsqlItem.INDUSTRY_ATTRIBUTE22 := aSqlItem.INDUSTRY_ATTRIBUTE22;
		aPlsqlItem.INDUSTRY_ATTRIBUTE23 := aSqlItem.INDUSTRY_ATTRIBUTE23;
		aPlsqlItem.INDUSTRY_ATTRIBUTE24 := aSqlItem.INDUSTRY_ATTRIBUTE24;
		aPlsqlItem.INDUSTRY_ATTRIBUTE25 := aSqlItem.INDUSTRY_ATTRIBUTE25;
		aPlsqlItem.INDUSTRY_ATTRIBUTE26 := aSqlItem.INDUSTRY_ATTRIBUTE26;
		aPlsqlItem.INDUSTRY_ATTRIBUTE27 := aSqlItem.INDUSTRY_ATTRIBUTE27;
		aPlsqlItem.INDUSTRY_ATTRIBUTE28 := aSqlItem.INDUSTRY_ATTRIBUTE28;
		aPlsqlItem.INDUSTRY_ATTRIBUTE29 := aSqlItem.INDUSTRY_ATTRIBUTE29;
		aPlsqlItem.INDUSTRY_ATTRIBUTE30 := aSqlItem.INDUSTRY_ATTRIBUTE30;
		aPlsqlItem.INDUSTRY_ATTRIBUTE2 := aSqlItem.INDUSTRY_ATTRIBUTE2;
		aPlsqlItem.INDUSTRY_ATTRIBUTE3 := aSqlItem.INDUSTRY_ATTRIBUTE3;
		aPlsqlItem.INDUSTRY_ATTRIBUTE4 := aSqlItem.INDUSTRY_ATTRIBUTE4;
		aPlsqlItem.INDUSTRY_ATTRIBUTE5 := aSqlItem.INDUSTRY_ATTRIBUTE5;
		aPlsqlItem.INDUSTRY_ATTRIBUTE6 := aSqlItem.INDUSTRY_ATTRIBUTE6;
		aPlsqlItem.INDUSTRY_ATTRIBUTE7 := aSqlItem.INDUSTRY_ATTRIBUTE7;
		aPlsqlItem.INDUSTRY_ATTRIBUTE8 := aSqlItem.INDUSTRY_ATTRIBUTE8;
		aPlsqlItem.INDUSTRY_ATTRIBUTE9 := aSqlItem.INDUSTRY_ATTRIBUTE9;
		aPlsqlItem.INDUSTRY_CONTEXT := aSqlItem.INDUSTRY_CONTEXT;
		aPlsqlItem.TP_CONTEXT := aSqlItem.TP_CONTEXT;
		aPlsqlItem.TP_ATTRIBUTE1 := aSqlItem.TP_ATTRIBUTE1;
		aPlsqlItem.TP_ATTRIBUTE2 := aSqlItem.TP_ATTRIBUTE2;
		aPlsqlItem.TP_ATTRIBUTE3 := aSqlItem.TP_ATTRIBUTE3;
		aPlsqlItem.TP_ATTRIBUTE4 := aSqlItem.TP_ATTRIBUTE4;
		aPlsqlItem.TP_ATTRIBUTE5 := aSqlItem.TP_ATTRIBUTE5;
		aPlsqlItem.TP_ATTRIBUTE6 := aSqlItem.TP_ATTRIBUTE6;
		aPlsqlItem.TP_ATTRIBUTE7 := aSqlItem.TP_ATTRIBUTE7;
		aPlsqlItem.TP_ATTRIBUTE8 := aSqlItem.TP_ATTRIBUTE8;
		aPlsqlItem.TP_ATTRIBUTE9 := aSqlItem.TP_ATTRIBUTE9;
		aPlsqlItem.TP_ATTRIBUTE10 := aSqlItem.TP_ATTRIBUTE10;
		aPlsqlItem.TP_ATTRIBUTE11 := aSqlItem.TP_ATTRIBUTE11;
		aPlsqlItem.TP_ATTRIBUTE12 := aSqlItem.TP_ATTRIBUTE12;
		aPlsqlItem.TP_ATTRIBUTE13 := aSqlItem.TP_ATTRIBUTE13;
		aPlsqlItem.TP_ATTRIBUTE14 := aSqlItem.TP_ATTRIBUTE14;
		aPlsqlItem.TP_ATTRIBUTE15 := aSqlItem.TP_ATTRIBUTE15;
		aPlsqlItem.INTERMED_SHIP_TO_ORG_ID := aSqlItem.INTERMED_SHIP_TO_ORG_ID;
		aPlsqlItem.INTERMED_SHIP_TO_CONTACT_ID := aSqlItem.INTERMED_SHIP_TO_CONTACT_ID;
		aPlsqlItem.INVENTORY_ITEM_ID := aSqlItem.INVENTORY_ITEM_ID;
		aPlsqlItem.INVOICE_INTERFACE_STATUS_CODE := aSqlItem.INVOICE_INTERFACE_STATUS_CODE;
		aPlsqlItem.INVOICE_TO_CONTACT_ID := aSqlItem.INVOICE_TO_CONTACT_ID;
		aPlsqlItem.INVOICE_TO_ORG_ID := aSqlItem.INVOICE_TO_ORG_ID;
		aPlsqlItem.INVOICING_RULE_ID := aSqlItem.INVOICING_RULE_ID;
		aPlsqlItem.ORDERED_ITEM := aSqlItem.ORDERED_ITEM;
		aPlsqlItem.ITEM_REVISION := aSqlItem.ITEM_REVISION;
		aPlsqlItem.ITEM_TYPE_CODE := aSqlItem.ITEM_TYPE_CODE;
		aPlsqlItem.LAST_UPDATED_BY := aSqlItem.LAST_UPDATED_BY;
		aPlsqlItem.LAST_UPDATE_DATE := aSqlItem.LAST_UPDATE_DATE;
		aPlsqlItem.LAST_UPDATE_LOGIN := aSqlItem.LAST_UPDATE_LOGIN;
		aPlsqlItem.LATEST_ACCEPTABLE_DATE := aSqlItem.LATEST_ACCEPTABLE_DATE;
		aPlsqlItem.LINE_CATEGORY_CODE := aSqlItem.LINE_CATEGORY_CODE;
		aPlsqlItem.LINE_ID := aSqlItem.LINE_ID; -- FND_API.G_MISS_NUM; -- O2C25
		aPlsqlItem.LINE_NUMBER := aSqlItem.LINE_NUMBER;
		aPlsqlItem.LINE_TYPE_ID := aSqlItem.LINE_TYPE_ID;
		aPlsqlItem.LINK_TO_LINE_REF := aSqlItem.LINK_TO_LINE_REF;
		aPlsqlItem.LINK_TO_LINE_ID := aSqlItem.LINK_TO_LINE_ID;
		aPlsqlItem.LINK_TO_LINE_INDEX := aSqlItem.LINK_TO_LINE_INDEX;
		aPlsqlItem.MODEL_GROUP_NUMBER := aSqlItem.MODEL_GROUP_NUMBER;
		aPlsqlItem.MFG_COMPONENT_SEQUENCE_ID := aSqlItem.MFG_COMPONENT_SEQUENCE_ID;
		aPlsqlItem.MFG_LEAD_TIME := aSqlItem.MFG_LEAD_TIME;
		aPlsqlItem.OPEN_FLAG := aSqlItem.OPEN_FLAG;
		aPlsqlItem.OPTION_FLAG := aSqlItem.OPTION_FLAG;
		aPlsqlItem.OPTION_NUMBER := aSqlItem.OPTION_NUMBER;
		aPlsqlItem.ORDERED_QUANTITY := aSqlItem.ORDERED_QUANTITY;
		aPlsqlItem.ORDERED_QUANTITY2 := aSqlItem.ORDERED_QUANTITY2;
		aPlsqlItem.ORDER_QUANTITY_UOM := aSqlItem.ORDER_QUANTITY_UOM;
		aPlsqlItem.ORDERED_QUANTITY_UOM2 := aSqlItem.ORDERED_QUANTITY_UOM2;
		aPlsqlItem.ORG_ID := aSqlItem.ORG_ID;
		aPlsqlItem.ORIG_SYS_DOCUMENT_REF := aSqlItem.ORIG_SYS_DOCUMENT_REF;
		aPlsqlItem.ORIG_SYS_LINE_REF := aSqlItem.ORIG_SYS_LINE_REF;
		aPlsqlItem.OVER_SHIP_REASON_CODE := aSqlItem.OVER_SHIP_REASON_CODE;
		aPlsqlItem.OVER_SHIP_RESOLVED_FLAG := aSqlItem.OVER_SHIP_RESOLVED_FLAG;
		aPlsqlItem.PAYMENT_TERM_ID := aSqlItem.PAYMENT_TERM_ID;
		aPlsqlItem.PLANNING_PRIORITY := aSqlItem.PLANNING_PRIORITY;
		aPlsqlItem.PREFERRED_GRADE := aSqlItem.PREFERRED_GRADE;
		aPlsqlItem.PRICE_LIST_ID := aSqlItem.PRICE_LIST_ID;
		aPlsqlItem.PRICE_REQUEST_CODE := aSqlItem.PRICE_REQUEST_CODE;
		aPlsqlItem.PRICING_ATTRIBUTE1 := aSqlItem.PRICING_ATTRIBUTE1;
		aPlsqlItem.PRICING_ATTRIBUTE10 := aSqlItem.PRICING_ATTRIBUTE10;
		aPlsqlItem.PRICING_ATTRIBUTE2 := aSqlItem.PRICING_ATTRIBUTE2;
		aPlsqlItem.PRICING_ATTRIBUTE3 := aSqlItem.PRICING_ATTRIBUTE3;
		aPlsqlItem.PRICING_ATTRIBUTE4 := aSqlItem.PRICING_ATTRIBUTE4;
		aPlsqlItem.PRICING_ATTRIBUTE5 := aSqlItem.PRICING_ATTRIBUTE5;
		aPlsqlItem.PRICING_ATTRIBUTE6 := aSqlItem.PRICING_ATTRIBUTE6;
		aPlsqlItem.PRICING_ATTRIBUTE7 := aSqlItem.PRICING_ATTRIBUTE7;
		aPlsqlItem.PRICING_ATTRIBUTE8 := aSqlItem.PRICING_ATTRIBUTE8;
		aPlsqlItem.PRICING_ATTRIBUTE9 := aSqlItem.PRICING_ATTRIBUTE9;
		aPlsqlItem.PRICING_CONTEXT := aSqlItem.PRICING_CONTEXT;
		aPlsqlItem.PRICING_DATE := aSqlItem.PRICING_DATE;
		aPlsqlItem.PRICING_QUANTITY := aSqlItem.PRICING_QUANTITY;
		aPlsqlItem.PRICING_QUANTITY_UOM := aSqlItem.PRICING_QUANTITY_UOM;
		aPlsqlItem.PROGRAM_APPLICATION_ID := aSqlItem.PROGRAM_APPLICATION_ID;
		aPlsqlItem.PROGRAM_ID := aSqlItem.PROGRAM_ID;
		aPlsqlItem.PROGRAM_UPDATE_DATE := aSqlItem.PROGRAM_UPDATE_DATE;
		aPlsqlItem.PROJECT_ID := aSqlItem.PROJECT_ID;
		aPlsqlItem.PROMISE_DATE := aSqlItem.PROMISE_DATE;
		aPlsqlItem.RE_SOURCE_FLAG := aSqlItem.RE_SOURCE_FLAG;
		aPlsqlItem.REFERENCE_CUSTOMER_TRX_LINE_ID := aSqlItem.REFERENCE_CUSTOMER_TRX_LINE_ID;
		aPlsqlItem.REFERENCE_HEADER_ID := aSqlItem.REFERENCE_HEADER_ID;
		aPlsqlItem.REFERENCE_LINE_ID := aSqlItem.REFERENCE_LINE_ID;
		aPlsqlItem.REFERENCE_TYPE := aSqlItem.REFERENCE_TYPE;
		aPlsqlItem.REQUEST_DATE := aSqlItem.REQUEST_DATE;
		aPlsqlItem.REQUEST_ID := aSqlItem.REQUEST_ID;
		aPlsqlItem.RESERVED_QUANTITY := aSqlItem.RESERVED_QUANTITY;
		aPlsqlItem.RETURN_ATTRIBUTE1 := aSqlItem.RETURN_ATTRIBUTE1;
		aPlsqlItem.RETURN_ATTRIBUTE10 := aSqlItem.RETURN_ATTRIBUTE10;
		aPlsqlItem.RETURN_ATTRIBUTE11 := aSqlItem.RETURN_ATTRIBUTE11;
		aPlsqlItem.RETURN_ATTRIBUTE12 := aSqlItem.RETURN_ATTRIBUTE12;
		aPlsqlItem.RETURN_ATTRIBUTE13 := aSqlItem.RETURN_ATTRIBUTE13;
		aPlsqlItem.RETURN_ATTRIBUTE14 := aSqlItem.RETURN_ATTRIBUTE14;
		aPlsqlItem.RETURN_ATTRIBUTE15 := aSqlItem.RETURN_ATTRIBUTE15;
		aPlsqlItem.RETURN_ATTRIBUTE2 := aSqlItem.RETURN_ATTRIBUTE2;
		aPlsqlItem.RETURN_ATTRIBUTE3 := aSqlItem.RETURN_ATTRIBUTE3;
		aPlsqlItem.RETURN_ATTRIBUTE4 := aSqlItem.RETURN_ATTRIBUTE4;
		aPlsqlItem.RETURN_ATTRIBUTE5 := aSqlItem.RETURN_ATTRIBUTE5;
		aPlsqlItem.RETURN_ATTRIBUTE6 := aSqlItem.RETURN_ATTRIBUTE6;
		aPlsqlItem.RETURN_ATTRIBUTE7 := aSqlItem.RETURN_ATTRIBUTE7;
		aPlsqlItem.RETURN_ATTRIBUTE8 := aSqlItem.RETURN_ATTRIBUTE8;
		aPlsqlItem.RETURN_ATTRIBUTE9 := aSqlItem.RETURN_ATTRIBUTE9;
		aPlsqlItem.RETURN_CONTEXT := aSqlItem.RETURN_CONTEXT;
		aPlsqlItem.RETURN_REASON_CODE := aSqlItem.RETURN_REASON_CODE;
		aPlsqlItem.RLA_SCHEDULE_TYPE_CODE := aSqlItem.RLA_SCHEDULE_TYPE_CODE;
		aPlsqlItem.SALESREP_ID := aSqlItem.SALESREP_ID;
		aPlsqlItem.SCHEDULE_ARRIVAL_DATE := aSqlItem.SCHEDULE_ARRIVAL_DATE;
		aPlsqlItem.SCHEDULE_SHIP_DATE := aSqlItem.SCHEDULE_SHIP_DATE;
		aPlsqlItem.SCHEDULE_ACTION_CODE := aSqlItem.SCHEDULE_ACTION_CODE;
		aPlsqlItem.SCHEDULE_STATUS_CODE := aSqlItem.SCHEDULE_STATUS_CODE;
		aPlsqlItem.SHIPMENT_NUMBER := FND_API.G_MISS_NUM; --aSqlItem.SHIPMENT_NUMBER;
		aPlsqlItem.SHIPMENT_PRIORITY_CODE := aSqlItem.SHIPMENT_PRIORITY_CODE;
		aPlsqlItem.SHIPPED_QUANTITY := aSqlItem.SHIPPED_QUANTITY;
		aPlsqlItem.SHIPPED_QUANTITY2 := aSqlItem.SHIPPED_QUANTITY2;
		aPlsqlItem.SHIPPING_INTERFACED_FLAG := aSqlItem.SHIPPING_INTERFACED_FLAG;
		aPlsqlItem.SHIPPING_METHOD_CODE := aSqlItem.SHIPPING_METHOD_CODE;
		aPlsqlItem.SHIPPING_QUANTITY := aSqlItem.SHIPPING_QUANTITY;
		aPlsqlItem.SHIPPING_QUANTITY2 := aSqlItem.SHIPPING_QUANTITY2;
		aPlsqlItem.SHIPPING_QUANTITY_UOM := aSqlItem.SHIPPING_QUANTITY_UOM;
		aPlsqlItem.SHIPPING_QUANTITY_UOM2 := aSqlItem.SHIPPING_QUANTITY_UOM2;
		aPlsqlItem.SHIP_FROM_ORG_ID := aSqlItem.SHIP_FROM_ORG_ID;
		aPlsqlItem.SHIP_MODEL_COMPLETE_FLAG := aSqlItem.SHIP_MODEL_COMPLETE_FLAG;
		aPlsqlItem.SHIP_SET_ID := aSqlItem.SHIP_SET_ID;
		aPlsqlItem.FULFILLMENT_SET_ID := aSqlItem.FULFILLMENT_SET_ID;
		aPlsqlItem.SHIP_TOLERANCE_ABOVE := aSqlItem.SHIP_TOLERANCE_ABOVE;
		aPlsqlItem.SHIP_TOLERANCE_BELOW := aSqlItem.SHIP_TOLERANCE_BELOW;
		aPlsqlItem.SHIP_TO_CONTACT_ID := aSqlItem.SHIP_TO_CONTACT_ID;
		aPlsqlItem.SHIP_TO_ORG_ID := aSqlItem.SHIP_TO_ORG_ID;
		aPlsqlItem.SOLD_TO_ORG_ID := aSqlItem.SOLD_TO_ORG_ID;
                --oe_debug_pub.add('Srini 104 header sold_to_org_id '||aPlsqlItem.SOLD_TO_ORG_ID);
		aPlsqlItem.SOLD_FROM_ORG_ID := aSqlItem.SOLD_FROM_ORG_ID;
		aPlsqlItem.SORT_ORDER := aSqlItem.SORT_ORDER;
		aPlsqlItem.SOURCE_DOCUMENT_ID := aSqlItem.SOURCE_DOCUMENT_ID;
		aPlsqlItem.SOURCE_DOCUMENT_LINE_ID := aSqlItem.SOURCE_DOCUMENT_LINE_ID;
		aPlsqlItem.SOURCE_DOCUMENT_TYPE_ID := aSqlItem.SOURCE_DOCUMENT_TYPE_ID;
		aPlsqlItem.SOURCE_TYPE_CODE := aSqlItem.SOURCE_TYPE_CODE;
		aPlsqlItem.SPLIT_FROM_LINE_ID := aSqlItem.SPLIT_FROM_LINE_ID;
		aPlsqlItem.TASK_ID := aSqlItem.TASK_ID;
		aPlsqlItem.TAX_CODE := aSqlItem.TAX_CODE;
		aPlsqlItem.TAX_DATE := aSqlItem.TAX_DATE;
		aPlsqlItem.TAX_EXEMPT_FLAG := aSqlItem.TAX_EXEMPT_FLAG;
		aPlsqlItem.TAX_EXEMPT_NUMBER := aSqlItem.TAX_EXEMPT_NUMBER;
		aPlsqlItem.TAX_EXEMPT_REASON_CODE := aSqlItem.TAX_EXEMPT_REASON_CODE;
		aPlsqlItem.TAX_POINT_CODE := aSqlItem.TAX_POINT_CODE;
		aPlsqlItem.TAX_RATE := aSqlItem.TAX_RATE;
		aPlsqlItem.TAX_VALUE := aSqlItem.TAX_VALUE;
		aPlsqlItem.TOP_MODEL_LINE_REF := aSqlItem.TOP_MODEL_LINE_REF;
		aPlsqlItem.TOP_MODEL_LINE_ID := aSqlItem.TOP_MODEL_LINE_ID;
		aPlsqlItem.TOP_MODEL_LINE_INDEX := aSqlItem.TOP_MODEL_LINE_INDEX;
		aPlsqlItem.UNIT_LIST_PRICE := aSqlItem.UNIT_LIST_PRICE;
		aPlsqlItem.UNIT_LIST_PRICE_PER_PQTY := aSqlItem.UNIT_LIST_PRICE_PER_PQTY;
		aPlsqlItem.UNIT_SELLING_PRICE := aSqlItem.UNIT_SELLING_PRICE;
		aPlsqlItem.UNIT_SELLING_PRICE_PER_PQTY := aSqlItem.UNIT_SELLING_PRICE_PER_PQTY;
		aPlsqlItem.VEH_CUS_ITEM_CUM_KEY_ID := aSqlItem.VEH_CUS_ITEM_CUM_KEY_ID;
		aPlsqlItem.VISIBLE_DEMAND_FLAG := aSqlItem.VISIBLE_DEMAND_FLAG;
		aPlsqlItem.RETURN_STATUS := aSqlItem.RETURN_STATUS;
		aPlsqlItem.DB_FLAG := aSqlItem.DB_FLAG;
		aPlsqlItem.OPERATION := aSqlItem.OPERATION;
		aPlsqlItem.FIRST_ACK_CODE := aSqlItem.FIRST_ACK_CODE;
		aPlsqlItem.FIRST_ACK_DATE := aSqlItem.FIRST_ACK_DATE;
		aPlsqlItem.LAST_ACK_CODE := aSqlItem.LAST_ACK_CODE;
		aPlsqlItem.LAST_ACK_DATE := aSqlItem.LAST_ACK_DATE;
		aPlsqlItem.CHANGE_REASON := aSqlItem.CHANGE_REASON;
		aPlsqlItem.CHANGE_COMMENTS := aSqlItem.CHANGE_COMMENTS;
		aPlsqlItem.ARRIVAL_SET := aSqlItem.ARRIVAL_SET;
		aPlsqlItem.SHIP_SET := aSqlItem.SHIP_SET;
		aPlsqlItem.FULFILLMENT_SET := aSqlItem.FULFILLMENT_SET;
		aPlsqlItem.ORDER_SOURCE_ID := aSqlItem.ORDER_SOURCE_ID;
		aPlsqlItem.ORIG_SYS_SHIPMENT_REF := aSqlItem.ORIG_SYS_SHIPMENT_REF;
		aPlsqlItem.CHANGE_SEQUENCE := aSqlItem.CHANGE_SEQUENCE;
		aPlsqlItem.CHANGE_REQUEST_CODE := aSqlItem.CHANGE_REQUEST_CODE;
		aPlsqlItem.STATUS_FLAG := aSqlItem.STATUS_FLAG;
		aPlsqlItem.DROP_SHIP_FLAG := aSqlItem.DROP_SHIP_FLAG;
		aPlsqlItem.CUSTOMER_LINE_NUMBER := aSqlItem.CUSTOMER_LINE_NUMBER;
		aPlsqlItem.CUSTOMER_SHIPMENT_NUMBER := aSqlItem.CUSTOMER_SHIPMENT_NUMBER;
		aPlsqlItem.CUSTOMER_ITEM_NET_PRICE := aSqlItem.CUSTOMER_ITEM_NET_PRICE;
		aPlsqlItem.CUSTOMER_PAYMENT_TERM_ID := aSqlItem.CUSTOMER_PAYMENT_TERM_ID;
		aPlsqlItem.ORDERED_ITEM_ID := aSqlItem.ORDERED_ITEM_ID;
		aPlsqlItem.ITEM_IDENTIFIER_TYPE := aSqlItem.ITEM_IDENTIFIER_TYPE;
		aPlsqlItem.SHIPPING_INSTRUCTIONS := aSqlItem.SHIPPING_INSTRUCTIONS;
		aPlsqlItem.PACKING_INSTRUCTIONS := aSqlItem.PACKING_INSTRUCTIONS;
		aPlsqlItem.CALCULATE_PRICE_FLAG := aSqlItem.CALCULATE_PRICE_FLAG;
		aPlsqlItem.INVOICED_QUANTITY := aSqlItem.INVOICED_QUANTITY;
		aPlsqlItem.SERVICE_TXN_REASON_CODE := aSqlItem.SERVICE_TXN_REASON_CODE;
		aPlsqlItem.SERVICE_TXN_COMMENTS := aSqlItem.SERVICE_TXN_COMMENTS;
		aPlsqlItem.SERVICE_DURATION := aSqlItem.SERVICE_DURATION;
		aPlsqlItem.SERVICE_PERIOD := aSqlItem.SERVICE_PERIOD;
		aPlsqlItem.SERVICE_START_DATE := aSqlItem.SERVICE_START_DATE;
		aPlsqlItem.SERVICE_END_DATE := aSqlItem.SERVICE_END_DATE;
		aPlsqlItem.SERVICE_COTERMINATE_FLAG := aSqlItem.SERVICE_COTERMINATE_FLAG;
		aPlsqlItem.UNIT_LIST_PERCENT := aSqlItem.UNIT_LIST_PERCENT;
		aPlsqlItem.UNIT_SELLING_PERCENT := aSqlItem.UNIT_SELLING_PERCENT;
		aPlsqlItem.UNIT_PERCENT_BASE_PRICE := aSqlItem.UNIT_PERCENT_BASE_PRICE;
		aPlsqlItem.SERVICE_NUMBER := aSqlItem.SERVICE_NUMBER;
		aPlsqlItem.SERVICE_REFERENCE_TYPE_CODE := aSqlItem.SERVICE_REFERENCE_TYPE_CODE;
		aPlsqlItem.SERVICE_REFERENCE_LINE_ID := aSqlItem.SERVICE_REFERENCE_LINE_ID;
		aPlsqlItem.SERVICE_REFERENCE_SYSTEM_ID := aSqlItem.SERVICE_REFERENCE_SYSTEM_ID;
		aPlsqlItem.SERVICE_REF_ORDER_NUMBER := aSqlItem.SERVICE_REF_ORDER_NUMBER;
		aPlsqlItem.SERVICE_REF_LINE_NUMBER := aSqlItem.SERVICE_REF_LINE_NUMBER;
		aPlsqlItem.SERVICE_REFERENCE_ORDER := aSqlItem.SERVICE_REFERENCE_ORDER;
		aPlsqlItem.SERVICE_REFERENCE_LINE := aSqlItem.SERVICE_REFERENCE_LINE;
		aPlsqlItem.SERVICE_REFERENCE_SYSTEM := aSqlItem.SERVICE_REFERENCE_SYSTEM;
		aPlsqlItem.SERVICE_REF_SHIPMENT_NUMBER := aSqlItem.SERVICE_REF_SHIPMENT_NUMBER;
		aPlsqlItem.SERVICE_REF_OPTION_NUMBER := aSqlItem.SERVICE_REF_OPTION_NUMBER;
		aPlsqlItem.SERVICE_LINE_INDEX := aSqlItem.SERVICE_LINE_INDEX;
		aPlsqlItem.LINE_SET_ID := aSqlItem.LINE_SET_ID;
		aPlsqlItem.SPLIT_BY := aSqlItem.SPLIT_BY;
		aPlsqlItem.SPLIT_ACTION_CODE := aSqlItem.SPLIT_ACTION_CODE;
		aPlsqlItem.SHIPPABLE_FLAG := aSqlItem.SHIPPABLE_FLAG;
		aPlsqlItem.MODEL_REMNANT_FLAG := aSqlItem.MODEL_REMNANT_FLAG;
		aPlsqlItem.FLOW_STATUS_CODE := aSqlItem.FLOW_STATUS_CODE;
		aPlsqlItem.FULFILLED_FLAG := aSqlItem.FULFILLED_FLAG;
		aPlsqlItem.FULFILLMENT_METHOD_CODE := aSqlItem.FULFILLMENT_METHOD_CODE;
		aPlsqlItem.REVENUE_AMOUNT := aSqlItem.REVENUE_AMOUNT;
		aPlsqlItem.MARKETING_SOURCE_CODE_ID := aSqlItem.MARKETING_SOURCE_CODE_ID;
		aPlsqlItem.FULFILLMENT_DATE := aSqlItem.FULFILLMENT_DATE;
		aPlsqlItem.SEMI_PROCESSED_FLAG := SYS.SQLJUTL.INT2BOOL(aSqlItem.SEMI_PROCESSED_FLAG);
		aPlsqlItem.UPGRADED_FLAG := aSqlItem.UPGRADED_FLAG;
		aPlsqlItem.LOCK_CONTROL := aSqlItem.LOCK_CONTROL;
		aPlsqlItem.SUBINVENTORY := aSqlItem.SUBINVENTORY;
		aPlsqlItem.SPLIT_FROM_LINE_REF := aSqlItem.SPLIT_FROM_LINE_REF;
		aPlsqlItem.SPLIT_FROM_SHIPMENT_REF := aSqlItem.SPLIT_FROM_SHIPMENT_REF;
		aPlsqlItem.SHIP_TO_EDI_LOCATION_CODE := aSqlItem.SHIP_TO_EDI_LOCATION_CODE;
		aPlsqlItem.BILL_TO_EDI_LOCATION_CODE := aSqlItem.BILL_TO_EDI_LOCATION_CODE;
		aPlsqlItem.SHIP_FROM_EDI_LOCATION_CODE := aSqlItem.SHIP_FROM_EDI_LOCATION_CODE;
		aPlsqlItem.SHIP_FROM_ADDRESS_ID := aSqlItem.SHIP_FROM_ADDRESS_ID;
		aPlsqlItem.SOLD_TO_ADDRESS_ID := aSqlItem.SOLD_TO_ADDRESS_ID;
		aPlsqlItem.SHIP_TO_ADDRESS_ID := aSqlItem.SHIP_TO_ADDRESS_ID;
		aPlsqlItem.INVOICE_ADDRESS_ID := aSqlItem.INVOICE_ADDRESS_ID;
		aPlsqlItem.SHIP_TO_ADDRESS_CODE := aSqlItem.SHIP_TO_ADDRESS_CODE;
		aPlsqlItem.ORIGINAL_INVENTORY_ITEM_ID := aSqlItem.ORIGINAL_INVENTORY_ITEM_ID;
		aPlsqlItem.ORIGINAL_ITEM_IDENTIFIER_TYPE := aSqlItem.ORIGINAL_ITEM_IDENTIFIER_TYPE;
		aPlsqlItem.ORIGINAL_ORDERED_ITEM_ID := aSqlItem.ORIGINAL_ORDERED_ITEM_ID;
		aPlsqlItem.ORIGINAL_ORDERED_ITEM := aSqlItem.ORIGINAL_ORDERED_ITEM;
		aPlsqlItem.ITEM_SUBSTITUTION_TYPE_CODE := aSqlItem.ITEM_SUBSTITUTION_TYPE_CODE;
		aPlsqlItem.LATE_DEMAND_PENALTY_FACTOR := aSqlItem.LATE_DEMAND_PENALTY_FACTOR;
		aPlsqlItem.OVERRIDE_ATP_DATE_CODE := aSqlItem.OVERRIDE_ATP_DATE_CODE;
		aPlsqlItem.SHIP_TO_CUSTOMER_ID := aSqlItem.SHIP_TO_CUSTOMER_ID;
		aPlsqlItem.INVOICE_TO_CUSTOMER_ID := aSqlItem.INVOICE_TO_CUSTOMER_ID;
		aPlsqlItem.DELIVER_TO_CUSTOMER_ID := aSqlItem.DELIVER_TO_CUSTOMER_ID;
		aPlsqlItem.ACCOUNTING_RULE_DURATION := aSqlItem.ACCOUNTING_RULE_DURATION;
		aPlsqlItem.UNIT_COST := aSqlItem.UNIT_COST;
		aPlsqlItem.USER_ITEM_DESCRIPTION := aSqlItem.USER_ITEM_DESCRIPTION;
		aPlsqlItem.XML_TRANSACTION_TYPE_CODE := aSqlItem.XML_TRANSACTION_TYPE_CODE;
		aPlsqlItem.ITEM_RELATIONSHIP_TYPE := aSqlItem.ITEM_RELATIONSHIP_TYPE;
		aPlsqlItem.BLANKET_NUMBER := aSqlItem.BLANKET_NUMBER;
		aPlsqlItem.BLANKET_LINE_NUMBER := aSqlItem.BLANKET_LINE_NUMBER;
		aPlsqlItem.BLANKET_VERSION_NUMBER := aSqlItem.BLANKET_VERSION_NUMBER;
		aPlsqlItem.CSO_RESPONSE_FLAG := aSqlItem.CSO_RESPONSE_FLAG;
		aPlsqlItem.FIRM_DEMAND_FLAG := aSqlItem.FIRM_DEMAND_FLAG;
		aPlsqlItem.EARLIEST_SHIP_DATE := aSqlItem.EARLIEST_SHIP_DATE;
		aPlsqlItem.TRANSACTION_PHASE_CODE := aSqlItem.TRANSACTION_PHASE_CODE;
		aPlsqlItem.SOURCE_DOCUMENT_VERSION_NUMBER := aSqlItem.SOURCE_DOCUMENT_VERSION_NUMBER;
		aPlsqlItem.MINISITE_ID := aSqlItem.MINISITE_ID;
		aPlsqlItem.IB_OWNER := aSqlItem.IB_OWNER;
		aPlsqlItem.IB_INSTALLED_AT_LOCATION := aSqlItem.IB_INSTALLED_AT_LOCATION;
		aPlsqlItem.IB_CURRENT_LOCATION := aSqlItem.IB_CURRENT_LOCATION;
		aPlsqlItem.END_CUSTOMER_ID := aSqlItem.END_CUSTOMER_ID;
		aPlsqlItem.END_CUSTOMER_CONTACT_ID := aSqlItem.END_CUSTOMER_CONTACT_ID;
		aPlsqlItem.END_CUSTOMER_SITE_USE_ID := aSqlItem.END_CUSTOMER_SITE_USE_ID;
		aPlsqlItem.SUPPLIER_SIGNATURE := aSqlItem.SUPPLIER_SIGNATURE;
		aPlsqlItem.SUPPLIER_SIGNATURE_DATE := aSqlItem.SUPPLIER_SIGNATURE_DATE;
		aPlsqlItem.CUSTOMER_SIGNATURE := aSqlItem.CUSTOMER_SIGNATURE;
		aPlsqlItem.CUSTOMER_SIGNATURE_DATE := aSqlItem.CUSTOMER_SIGNATURE_DATE;
		aPlsqlItem.SHIP_TO_PARTY_ID := aSqlItem.SHIP_TO_PARTY_ID;
		aPlsqlItem.SHIP_TO_PARTY_SITE_ID := aSqlItem.SHIP_TO_PARTY_SITE_ID;
		aPlsqlItem.SHIP_TO_PARTY_SITE_USE_ID := aSqlItem.SHIP_TO_PARTY_SITE_USE_ID;
		aPlsqlItem.DELIVER_TO_PARTY_ID := aSqlItem.DELIVER_TO_PARTY_ID;
		aPlsqlItem.DELIVER_TO_PARTY_SITE_ID := aSqlItem.DELIVER_TO_PARTY_SITE_ID;
		aPlsqlItem.DELIVER_TO_PARTY_SITE_USE_ID := aSqlItem.DELIVER_TO_PARTY_SITE_USE_ID;
		aPlsqlItem.INVOICE_TO_PARTY_ID := aSqlItem.INVOICE_TO_PARTY_ID;
		aPlsqlItem.INVOICE_TO_PARTY_SITE_ID := aSqlItem.INVOICE_TO_PARTY_SITE_ID;
		aPlsqlItem.INVOICE_TO_PARTY_SITE_USE_ID := aSqlItem.INVOICE_TO_PARTY_SITE_USE_ID;
		aPlsqlItem.END_CUSTOMER_PARTY_ID := aSqlItem.END_CUSTOMER_PARTY_ID;
		aPlsqlItem.END_CUSTOMER_PARTY_SITE_ID := aSqlItem.END_CUSTOMER_PARTY_SITE_ID;
		aPlsqlItem.END_CUSTOMER_PARTY_SITE_USE_ID := aSqlItem.END_CUSTOMER_PARTY_SITE_USE_ID;
		aPlsqlItem.END_CUSTOMER_PARTY_NUMBER := aSqlItem.END_CUSTOMER_PARTY_NUMBER;
		aPlsqlItem.END_CUSTOMER_ORG_CONTACT_ID := aSqlItem.END_CUSTOMER_ORG_CONTACT_ID;
		aPlsqlItem.SHIP_TO_CUSTOMER_PARTY_ID := aSqlItem.SHIP_TO_CUSTOMER_PARTY_ID;
		aPlsqlItem.DELIVER_TO_CUSTOMER_PARTY_ID := aSqlItem.DELIVER_TO_CUSTOMER_PARTY_ID;
		aPlsqlItem.INVOICE_TO_CUSTOMER_PARTY_ID := aSqlItem.INVOICE_TO_CUSTOMER_PARTY_ID;
		aPlsqlItem.SHIP_TO_ORG_CONTACT_ID := aSqlItem.SHIP_TO_ORG_CONTACT_ID;
		aPlsqlItem.DELIVER_TO_ORG_CONTACT_ID := aSqlItem.DELIVER_TO_ORG_CONTACT_ID;
		aPlsqlItem.INVOICE_TO_ORG_CONTACT_ID := aSqlItem.INVOICE_TO_ORG_CONTACT_ID;
		aPlsqlItem.RETROBILL_REQUEST_ID := aSqlItem.RETROBILL_REQUEST_ID;
		aPlsqlItem.ORIGINAL_LIST_PRICE := aSqlItem.ORIGINAL_LIST_PRICE;
		aPlsqlItem.COMMITMENT_APPLIED_AMOUNT := aSqlItem.COMMITMENT_APPLIED_AMOUNT;
		aPlsqlItem.SHIP_TO_PARTY_NUMBER := aSqlItem.SHIP_TO_PARTY_NUMBER;
		aPlsqlItem.INVOICE_TO_PARTY_NUMBER := aSqlItem.INVOICE_TO_PARTY_NUMBER;
		aPlsqlItem.DELIVER_TO_PARTY_NUMBER := aSqlItem.DELIVER_TO_PARTY_NUMBER;
		aPlsqlItem.ORDER_FIRMED_DATE := aSqlItem.ORDER_FIRMED_DATE;
		aPlsqlItem.ACTUAL_FULFILLMENT_DATE := aSqlItem.ACTUAL_FULFILLMENT_DATE;
		aPlsqlItem.CHANGED_LINES_POCAO := aSqlItem.CHANGED_LINES_POCAO;
		aPlsqlItem.CHARGE_PERIODICITY_CODE := aSqlItem.CHARGE_PERIODICITY_CODE;

--      oe_debug_pub.add('Calling OE_GENESIS_UTIL.print_po_payload Before Convert_Line_null_to_miss');
--      OE_GENESIS_UTIL.print_po_payload(
--      P_HEADER_REC_,
--      P_HEADER_VAL_REC_,
--      P_HEADER_PAYMENT_TBL_,
--      P_LINE_TBL_
--      );

                oe_debug_pub.add('Calling OE_GENESIS_UTIL.Convert_Line_null_to_miss', 1);
                OE_GENESIS_UTIL.Convert_Line_null_to_miss(aPlsqlItem);
--      oe_debug_pub.add('Calling OE_GENESIS_UTIL.print_po_payload After Convert_Line_null_to_miss');
--      OE_GENESIS_UTIL.print_po_payload(
--      P_HEADER_REC_,
--      P_HEADER_VAL_REC_,
--      P_HEADER_PAYMENT_TBL_,
--      P_LINE_TBL_
--      );

                -- convert_line_null_to_miss(aPlsqlItem);
                oe_debug_pub.add('After Calling OE_GENESIS_UTIL.Convert_Line_null_to_miss', 1);

		RETURN aPlsqlItem;
	END SQL_TO_PL35;

	FUNCTION PL_TO_SQL12(aPlsqlItem OE_ORDER_PUB.LINE_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_TBL_TYPE IS
	aSqlItem OE_ORDER_PUB_LINE_TBL_TYPE;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_TBL_TYPE();
        IF aPlsqlItem.COUNT > 0 THEN
		    aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			    aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL35(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL12;

	FUNCTION SQL_TO_PL12(aSqlItem OE_ORDER_PUB_LINE_TBL_TYPE)
	RETURN OE_ORDER_PUB.LINE_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
oe_debug_pub.add('Inside SQL_TO_PL12', 1);
			aPlsqlItem(I) := SQL_TO_PL35(aSqlItem(I));
			--aPlsqlItem(1) := SQL_TO_PL35(aSqlItem(1));
oe_debug_pub.add('After the call to  SQL_TO_PL35', 1);
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
oe_debug_pub.add('EXCEPTION in SQL_TO_PL12', 1);
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL12;

	FUNCTION PL_TO_SQL36(aPlsqlItem OE_ORDER_PUB.LINE_VAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_VAL_REC_TYP IS
	aSqlItem OE_ORDER_PUB_LINE_VAL_REC_TYP;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_VAL_REC_TYP(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.ACCOUNTING_RULE := aPlsqlItem.ACCOUNTING_RULE;
		aSqlItem.AGREEMENT := aPlsqlItem.AGREEMENT;
		aSqlItem.COMMITMENT := aPlsqlItem.COMMITMENT;
		aSqlItem.COMMITMENT_APPLIED_AMOUNT := aPlsqlItem.COMMITMENT_APPLIED_AMOUNT;
		aSqlItem.DELIVER_TO_ADDRESS1 := aPlsqlItem.DELIVER_TO_ADDRESS1;
		aSqlItem.DELIVER_TO_ADDRESS2 := aPlsqlItem.DELIVER_TO_ADDRESS2;
		aSqlItem.DELIVER_TO_ADDRESS3 := aPlsqlItem.DELIVER_TO_ADDRESS3;
		aSqlItem.DELIVER_TO_ADDRESS4 := aPlsqlItem.DELIVER_TO_ADDRESS4;
		aSqlItem.DELIVER_TO_CONTACT := aPlsqlItem.DELIVER_TO_CONTACT;
		aSqlItem.DELIVER_TO_LOCATION := aPlsqlItem.DELIVER_TO_LOCATION;
		aSqlItem.DELIVER_TO_ORG := aPlsqlItem.DELIVER_TO_ORG;
		aSqlItem.DELIVER_TO_STATE := aPlsqlItem.DELIVER_TO_STATE;
		aSqlItem.DELIVER_TO_CITY := aPlsqlItem.DELIVER_TO_CITY;
		aSqlItem.DELIVER_TO_ZIP := aPlsqlItem.DELIVER_TO_ZIP;
		aSqlItem.DELIVER_TO_COUNTRY := aPlsqlItem.DELIVER_TO_COUNTRY;
		aSqlItem.DELIVER_TO_COUNTY := aPlsqlItem.DELIVER_TO_COUNTY;
		aSqlItem.DELIVER_TO_PROVINCE := aPlsqlItem.DELIVER_TO_PROVINCE;
		aSqlItem.DEMAND_CLASS := aPlsqlItem.DEMAND_CLASS;
		aSqlItem.DEMAND_BUCKET_TYPE := aPlsqlItem.DEMAND_BUCKET_TYPE;
		aSqlItem.FOB_POINT := aPlsqlItem.FOB_POINT;
		aSqlItem.FREIGHT_TERMS := aPlsqlItem.FREIGHT_TERMS;
		aSqlItem.INVENTORY_ITEM := aPlsqlItem.INVENTORY_ITEM;
		aSqlItem.INVOICE_TO_ADDRESS1 := aPlsqlItem.INVOICE_TO_ADDRESS1;
		aSqlItem.INVOICE_TO_ADDRESS2 := aPlsqlItem.INVOICE_TO_ADDRESS2;
		aSqlItem.INVOICE_TO_ADDRESS3 := aPlsqlItem.INVOICE_TO_ADDRESS3;
		aSqlItem.INVOICE_TO_ADDRESS4 := aPlsqlItem.INVOICE_TO_ADDRESS4;
		aSqlItem.INVOICE_TO_CONTACT := aPlsqlItem.INVOICE_TO_CONTACT;
		aSqlItem.INVOICE_TO_LOCATION := aPlsqlItem.INVOICE_TO_LOCATION;
		aSqlItem.INVOICE_TO_ORG := aPlsqlItem.INVOICE_TO_ORG;
		aSqlItem.INVOICE_TO_STATE := aPlsqlItem.INVOICE_TO_STATE;
		aSqlItem.INVOICE_TO_CITY := aPlsqlItem.INVOICE_TO_CITY;
		aSqlItem.INVOICE_TO_ZIP := aPlsqlItem.INVOICE_TO_ZIP;
		aSqlItem.INVOICE_TO_COUNTRY := aPlsqlItem.INVOICE_TO_COUNTRY;
		aSqlItem.INVOICE_TO_COUNTY := aPlsqlItem.INVOICE_TO_COUNTY;
		aSqlItem.INVOICE_TO_PROVINCE := aPlsqlItem.INVOICE_TO_PROVINCE;
		aSqlItem.INVOICING_RULE := aPlsqlItem.INVOICING_RULE;
		aSqlItem.ITEM_TYPE := aPlsqlItem.ITEM_TYPE;
		aSqlItem.LINE_TYPE := aPlsqlItem.LINE_TYPE;
		aSqlItem.OVER_SHIP_REASON := aPlsqlItem.OVER_SHIP_REASON;
		aSqlItem.PAYMENT_TERM := aPlsqlItem.PAYMENT_TERM;
		aSqlItem.PRICE_LIST := aPlsqlItem.PRICE_LIST;
		aSqlItem.PROJECT := aPlsqlItem.PROJECT;
		aSqlItem.RETURN_REASON := aPlsqlItem.RETURN_REASON;
		aSqlItem.RLA_SCHEDULE_TYPE := aPlsqlItem.RLA_SCHEDULE_TYPE;
		aSqlItem.SALESREP := aPlsqlItem.SALESREP;
		aSqlItem.SHIPMENT_PRIORITY := aPlsqlItem.SHIPMENT_PRIORITY;
		aSqlItem.SHIP_FROM_ADDRESS1 := aPlsqlItem.SHIP_FROM_ADDRESS1;
		aSqlItem.SHIP_FROM_ADDRESS2 := aPlsqlItem.SHIP_FROM_ADDRESS2;
		aSqlItem.SHIP_FROM_ADDRESS3 := aPlsqlItem.SHIP_FROM_ADDRESS3;
		aSqlItem.SHIP_FROM_ADDRESS4 := aPlsqlItem.SHIP_FROM_ADDRESS4;
		aSqlItem.SHIP_FROM_LOCATION := aPlsqlItem.SHIP_FROM_LOCATION;
		aSqlItem.SHIP_FROM_CITY := aPlsqlItem.SHIP_FROM_CITY;
		aSqlItem.SHIP_FROM_POSTAL_CODE := aPlsqlItem.SHIP_FROM_POSTAL_CODE;
		aSqlItem.SHIP_FROM_COUNTRY := aPlsqlItem.SHIP_FROM_COUNTRY;
		aSqlItem.SHIP_FROM_REGION1 := aPlsqlItem.SHIP_FROM_REGION1;
		aSqlItem.SHIP_FROM_REGION2 := aPlsqlItem.SHIP_FROM_REGION2;
		aSqlItem.SHIP_FROM_REGION3 := aPlsqlItem.SHIP_FROM_REGION3;
		aSqlItem.SHIP_FROM_ORG := aPlsqlItem.SHIP_FROM_ORG;
		aSqlItem.SHIP_TO_ADDRESS1 := aPlsqlItem.SHIP_TO_ADDRESS1;
		aSqlItem.SHIP_TO_ADDRESS2 := aPlsqlItem.SHIP_TO_ADDRESS2;
		aSqlItem.SHIP_TO_ADDRESS3 := aPlsqlItem.SHIP_TO_ADDRESS3;
		aSqlItem.SHIP_TO_ADDRESS4 := aPlsqlItem.SHIP_TO_ADDRESS4;
		aSqlItem.SHIP_TO_STATE := aPlsqlItem.SHIP_TO_STATE;
		aSqlItem.SHIP_TO_COUNTRY := aPlsqlItem.SHIP_TO_COUNTRY;
		aSqlItem.SHIP_TO_ZIP := aPlsqlItem.SHIP_TO_ZIP;
		aSqlItem.SHIP_TO_COUNTY := aPlsqlItem.SHIP_TO_COUNTY;
		aSqlItem.SHIP_TO_PROVINCE := aPlsqlItem.SHIP_TO_PROVINCE;
		aSqlItem.SHIP_TO_CITY := aPlsqlItem.SHIP_TO_CITY;
		aSqlItem.SHIP_TO_CONTACT := aPlsqlItem.SHIP_TO_CONTACT;
		aSqlItem.SHIP_TO_CONTACT_LAST_NAME := aPlsqlItem.SHIP_TO_CONTACT_LAST_NAME;
		aSqlItem.SHIP_TO_CONTACT_FIRST_NAME := aPlsqlItem.SHIP_TO_CONTACT_FIRST_NAME;
		aSqlItem.SHIP_TO_LOCATION := aPlsqlItem.SHIP_TO_LOCATION;
		aSqlItem.SHIP_TO_ORG := aPlsqlItem.SHIP_TO_ORG;
		aSqlItem.SOURCE_TYPE := aPlsqlItem.SOURCE_TYPE;
		aSqlItem.INTERMED_SHIP_TO_ADDRESS1 := aPlsqlItem.INTERMED_SHIP_TO_ADDRESS1;
		aSqlItem.INTERMED_SHIP_TO_ADDRESS2 := aPlsqlItem.INTERMED_SHIP_TO_ADDRESS2;
		aSqlItem.INTERMED_SHIP_TO_ADDRESS3 := aPlsqlItem.INTERMED_SHIP_TO_ADDRESS3;
		aSqlItem.INTERMED_SHIP_TO_ADDRESS4 := aPlsqlItem.INTERMED_SHIP_TO_ADDRESS4;
		aSqlItem.INTERMED_SHIP_TO_CONTACT := aPlsqlItem.INTERMED_SHIP_TO_CONTACT;
		aSqlItem.INTERMED_SHIP_TO_LOCATION := aPlsqlItem.INTERMED_SHIP_TO_LOCATION;
		aSqlItem.INTERMED_SHIP_TO_ORG := aPlsqlItem.INTERMED_SHIP_TO_ORG;
		aSqlItem.INTERMED_SHIP_TO_STATE := aPlsqlItem.INTERMED_SHIP_TO_STATE;
		aSqlItem.INTERMED_SHIP_TO_CITY := aPlsqlItem.INTERMED_SHIP_TO_CITY;
		aSqlItem.INTERMED_SHIP_TO_ZIP := aPlsqlItem.INTERMED_SHIP_TO_ZIP;
		aSqlItem.INTERMED_SHIP_TO_COUNTRY := aPlsqlItem.INTERMED_SHIP_TO_COUNTRY;
		aSqlItem.INTERMED_SHIP_TO_COUNTY := aPlsqlItem.INTERMED_SHIP_TO_COUNTY;
		aSqlItem.INTERMED_SHIP_TO_PROVINCE := aPlsqlItem.INTERMED_SHIP_TO_PROVINCE;
		aSqlItem.SOLD_TO_ORG := aPlsqlItem.SOLD_TO_ORG;
		aSqlItem.SOLD_FROM_ORG := aPlsqlItem.SOLD_FROM_ORG;
		aSqlItem.TASK := aPlsqlItem.TASK;
		aSqlItem.TAX_EXEMPT := aPlsqlItem.TAX_EXEMPT;
		aSqlItem.TAX_EXEMPT_REASON := aPlsqlItem.TAX_EXEMPT_REASON;
		aSqlItem.TAX_POINT := aPlsqlItem.TAX_POINT;
		aSqlItem.VEH_CUS_ITEM_CUM_KEY := aPlsqlItem.VEH_CUS_ITEM_CUM_KEY;
		aSqlItem.VISIBLE_DEMAND := aPlsqlItem.VISIBLE_DEMAND;
		aSqlItem.CUSTOMER_PAYMENT_TERM := aPlsqlItem.CUSTOMER_PAYMENT_TERM;
		aSqlItem.REF_ORDER_NUMBER := aPlsqlItem.REF_ORDER_NUMBER;
		aSqlItem.REF_LINE_NUMBER := aPlsqlItem.REF_LINE_NUMBER;
		aSqlItem.REF_SHIPMENT_NUMBER := aPlsqlItem.REF_SHIPMENT_NUMBER;
		aSqlItem.REF_OPTION_NUMBER := aPlsqlItem.REF_OPTION_NUMBER;
		aSqlItem.REF_COMPONENT_NUMBER := aPlsqlItem.REF_COMPONENT_NUMBER;
		aSqlItem.REF_INVOICE_NUMBER := aPlsqlItem.REF_INVOICE_NUMBER;
		aSqlItem.REF_INVOICE_LINE_NUMBER := aPlsqlItem.REF_INVOICE_LINE_NUMBER;
		aSqlItem.CREDIT_INVOICE_NUMBER := aPlsqlItem.CREDIT_INVOICE_NUMBER;
		aSqlItem.TAX_GROUP := aPlsqlItem.TAX_GROUP;
		aSqlItem.STATUS := aPlsqlItem.STATUS;
		aSqlItem.FREIGHT_CARRIER := aPlsqlItem.FREIGHT_CARRIER;
		aSqlItem.SHIPPING_METHOD := aPlsqlItem.SHIPPING_METHOD;
		aSqlItem.CALCULATE_PRICE_DESCR := aPlsqlItem.CALCULATE_PRICE_DESCR;
		aSqlItem.SHIP_TO_CUSTOMER_NAME := aPlsqlItem.SHIP_TO_CUSTOMER_NAME;
		aSqlItem.INVOICE_TO_CUSTOMER_NAME := aPlsqlItem.INVOICE_TO_CUSTOMER_NAME;
		aSqlItem.SHIP_TO_CUSTOMER_NUMBER := aPlsqlItem.SHIP_TO_CUSTOMER_NUMBER;
		aSqlItem.INVOICE_TO_CUSTOMER_NUMBER := aPlsqlItem.INVOICE_TO_CUSTOMER_NUMBER;
		aSqlItem.SHIP_TO_CUSTOMER_ID := aPlsqlItem.SHIP_TO_CUSTOMER_ID;
		aSqlItem.INVOICE_TO_CUSTOMER_ID := aPlsqlItem.INVOICE_TO_CUSTOMER_ID;
		aSqlItem.DELIVER_TO_CUSTOMER_ID := aPlsqlItem.DELIVER_TO_CUSTOMER_ID;
		aSqlItem.DELIVER_TO_CUSTOMER_NUMBER := aPlsqlItem.DELIVER_TO_CUSTOMER_NUMBER;
		aSqlItem.DELIVER_TO_CUSTOMER_NAME := aPlsqlItem.DELIVER_TO_CUSTOMER_NAME;
		aSqlItem.ORIGINAL_ORDERED_ITEM := aPlsqlItem.ORIGINAL_ORDERED_ITEM;
		aSqlItem.ORIGINAL_INVENTORY_ITEM := aPlsqlItem.ORIGINAL_INVENTORY_ITEM;
		aSqlItem.ORIGINAL_ITEM_IDENTIFIER_TYPE := aPlsqlItem.ORIGINAL_ITEM_IDENTIFIER_TYPE;
		aSqlItem.DELIVER_TO_CUSTOMER_NUMBER_OI := aPlsqlItem.DELIVER_TO_CUSTOMER_NUMBER_OI;
		aSqlItem.DELIVER_TO_CUSTOMER_NAME_OI := aPlsqlItem.DELIVER_TO_CUSTOMER_NAME_OI;
		aSqlItem.SHIP_TO_CUSTOMER_NUMBER_OI := aPlsqlItem.SHIP_TO_CUSTOMER_NUMBER_OI;
		aSqlItem.SHIP_TO_CUSTOMER_NAME_OI := aPlsqlItem.SHIP_TO_CUSTOMER_NAME_OI;
		aSqlItem.INVOICE_TO_CUSTOMER_NUMBER_OI := aPlsqlItem.INVOICE_TO_CUSTOMER_NUMBER_OI;
		aSqlItem.INVOICE_TO_CUSTOMER_NAME_OI := aPlsqlItem.INVOICE_TO_CUSTOMER_NAME_OI;
		aSqlItem.ITEM_RELATIONSHIP_TYPE_DSP := aPlsqlItem.ITEM_RELATIONSHIP_TYPE_DSP;
		aSqlItem.TRANSACTION_PHASE := aPlsqlItem.TRANSACTION_PHASE;
		aSqlItem.END_CUSTOMER_NAME := aPlsqlItem.END_CUSTOMER_NAME;
		aSqlItem.END_CUSTOMER_NUMBER := aPlsqlItem.END_CUSTOMER_NUMBER;
		aSqlItem.END_CUSTOMER_CONTACT := aPlsqlItem.END_CUSTOMER_CONTACT;
		aSqlItem.END_CUST_CONTACT_LAST_NAME := aPlsqlItem.END_CUST_CONTACT_LAST_NAME;
		aSqlItem.END_CUST_CONTACT_FIRST_NAME := aPlsqlItem.END_CUST_CONTACT_FIRST_NAME;
		aSqlItem.END_CUSTOMER_SITE_ADDRESS1 := aPlsqlItem.END_CUSTOMER_SITE_ADDRESS1;
		aSqlItem.END_CUSTOMER_SITE_ADDRESS2 := aPlsqlItem.END_CUSTOMER_SITE_ADDRESS2;
		aSqlItem.END_CUSTOMER_SITE_ADDRESS3 := aPlsqlItem.END_CUSTOMER_SITE_ADDRESS3;
		aSqlItem.END_CUSTOMER_SITE_ADDRESS4 := aPlsqlItem.END_CUSTOMER_SITE_ADDRESS4;
		aSqlItem.END_CUSTOMER_SITE_LOCATION := aPlsqlItem.END_CUSTOMER_SITE_LOCATION;
		aSqlItem.END_CUSTOMER_SITE_STATE := aPlsqlItem.END_CUSTOMER_SITE_STATE;
		aSqlItem.END_CUSTOMER_SITE_COUNTRY := aPlsqlItem.END_CUSTOMER_SITE_COUNTRY;
		aSqlItem.END_CUSTOMER_SITE_ZIP := aPlsqlItem.END_CUSTOMER_SITE_ZIP;
		aSqlItem.END_CUSTOMER_SITE_COUNTY := aPlsqlItem.END_CUSTOMER_SITE_COUNTY;
		aSqlItem.END_CUSTOMER_SITE_PROVINCE := aPlsqlItem.END_CUSTOMER_SITE_PROVINCE;
		aSqlItem.END_CUSTOMER_SITE_CITY := aPlsqlItem.END_CUSTOMER_SITE_CITY;
		aSqlItem.END_CUSTOMER_SITE_POSTAL_CODE := aPlsqlItem.END_CUSTOMER_SITE_POSTAL_CODE;
		aSqlItem.BLANKET_AGREEMENT_NAME := aPlsqlItem.BLANKET_AGREEMENT_NAME;
		aSqlItem.IB_OWNER_DSP := aPlsqlItem.IB_OWNER_DSP;
		aSqlItem.IB_CURRENT_LOCATION_DSP := aPlsqlItem.IB_CURRENT_LOCATION_DSP;
		aSqlItem.IB_INSTALLED_AT_LOCATION_DSP := aPlsqlItem.IB_INSTALLED_AT_LOCATION_DSP;
		aSqlItem.SERVICE_PERIOD_DSP := aPlsqlItem.SERVICE_PERIOD_DSP;
		aSqlItem.SERVICE_REFERENCE_TYPE := aPlsqlItem.SERVICE_REFERENCE_TYPE;
		RETURN aSqlItem;
	END PL_TO_SQL36;

	FUNCTION SQL_TO_PL36(aSqlItem OE_ORDER_PUB_LINE_VAL_REC_TYP)
	RETURN OE_ORDER_PUB.LINE_VAL_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_VAL_REC_TYPE;
	BEGIN
		aPlsqlItem.ACCOUNTING_RULE := aSqlItem.ACCOUNTING_RULE;
		aPlsqlItem.AGREEMENT := aSqlItem.AGREEMENT;
		aPlsqlItem.COMMITMENT := aSqlItem.COMMITMENT;
		aPlsqlItem.COMMITMENT_APPLIED_AMOUNT := aSqlItem.COMMITMENT_APPLIED_AMOUNT;
		aPlsqlItem.DELIVER_TO_ADDRESS1 := aSqlItem.DELIVER_TO_ADDRESS1;
		aPlsqlItem.DELIVER_TO_ADDRESS2 := aSqlItem.DELIVER_TO_ADDRESS2;
		aPlsqlItem.DELIVER_TO_ADDRESS3 := aSqlItem.DELIVER_TO_ADDRESS3;
		aPlsqlItem.DELIVER_TO_ADDRESS4 := aSqlItem.DELIVER_TO_ADDRESS4;
		aPlsqlItem.DELIVER_TO_CONTACT := aSqlItem.DELIVER_TO_CONTACT;
		aPlsqlItem.DELIVER_TO_LOCATION := aSqlItem.DELIVER_TO_LOCATION;
		aPlsqlItem.DELIVER_TO_ORG := aSqlItem.DELIVER_TO_ORG;
		aPlsqlItem.DELIVER_TO_STATE := aSqlItem.DELIVER_TO_STATE;
		aPlsqlItem.DELIVER_TO_CITY := aSqlItem.DELIVER_TO_CITY;
		aPlsqlItem.DELIVER_TO_ZIP := aSqlItem.DELIVER_TO_ZIP;
		aPlsqlItem.DELIVER_TO_COUNTRY := aSqlItem.DELIVER_TO_COUNTRY;
		aPlsqlItem.DELIVER_TO_COUNTY := aSqlItem.DELIVER_TO_COUNTY;
		aPlsqlItem.DELIVER_TO_PROVINCE := aSqlItem.DELIVER_TO_PROVINCE;
		aPlsqlItem.DEMAND_CLASS := aSqlItem.DEMAND_CLASS;
		aPlsqlItem.DEMAND_BUCKET_TYPE := aSqlItem.DEMAND_BUCKET_TYPE;
		aPlsqlItem.FOB_POINT := aSqlItem.FOB_POINT;
		aPlsqlItem.FREIGHT_TERMS := aSqlItem.FREIGHT_TERMS;
		aPlsqlItem.INVENTORY_ITEM := aSqlItem.INVENTORY_ITEM;
		aPlsqlItem.INVOICE_TO_ADDRESS1 := aSqlItem.INVOICE_TO_ADDRESS1;
		aPlsqlItem.INVOICE_TO_ADDRESS2 := aSqlItem.INVOICE_TO_ADDRESS2;
		aPlsqlItem.INVOICE_TO_ADDRESS3 := aSqlItem.INVOICE_TO_ADDRESS3;
		aPlsqlItem.INVOICE_TO_ADDRESS4 := aSqlItem.INVOICE_TO_ADDRESS4;
		aPlsqlItem.INVOICE_TO_CONTACT := aSqlItem.INVOICE_TO_CONTACT;
		aPlsqlItem.INVOICE_TO_LOCATION := aSqlItem.INVOICE_TO_LOCATION;
		aPlsqlItem.INVOICE_TO_ORG := aSqlItem.INVOICE_TO_ORG;
		aPlsqlItem.INVOICE_TO_STATE := aSqlItem.INVOICE_TO_STATE;
		aPlsqlItem.INVOICE_TO_CITY := aSqlItem.INVOICE_TO_CITY;
		aPlsqlItem.INVOICE_TO_ZIP := aSqlItem.INVOICE_TO_ZIP;
		aPlsqlItem.INVOICE_TO_COUNTRY := aSqlItem.INVOICE_TO_COUNTRY;
		aPlsqlItem.INVOICE_TO_COUNTY := aSqlItem.INVOICE_TO_COUNTY;
		aPlsqlItem.INVOICE_TO_PROVINCE := aSqlItem.INVOICE_TO_PROVINCE;
		aPlsqlItem.INVOICING_RULE := aSqlItem.INVOICING_RULE;
		aPlsqlItem.ITEM_TYPE := aSqlItem.ITEM_TYPE;
		aPlsqlItem.LINE_TYPE := aSqlItem.LINE_TYPE;
		aPlsqlItem.OVER_SHIP_REASON := aSqlItem.OVER_SHIP_REASON;
		aPlsqlItem.PAYMENT_TERM := aSqlItem.PAYMENT_TERM;
		aPlsqlItem.PRICE_LIST := aSqlItem.PRICE_LIST;
		aPlsqlItem.PROJECT := aSqlItem.PROJECT;
		aPlsqlItem.RETURN_REASON := aSqlItem.RETURN_REASON;
		aPlsqlItem.RLA_SCHEDULE_TYPE := aSqlItem.RLA_SCHEDULE_TYPE;
		aPlsqlItem.SALESREP := aSqlItem.SALESREP;
		aPlsqlItem.SHIPMENT_PRIORITY := aSqlItem.SHIPMENT_PRIORITY;
		aPlsqlItem.SHIP_FROM_ADDRESS1 := aSqlItem.SHIP_FROM_ADDRESS1;
		aPlsqlItem.SHIP_FROM_ADDRESS2 := aSqlItem.SHIP_FROM_ADDRESS2;
		aPlsqlItem.SHIP_FROM_ADDRESS3 := aSqlItem.SHIP_FROM_ADDRESS3;
		aPlsqlItem.SHIP_FROM_ADDRESS4 := aSqlItem.SHIP_FROM_ADDRESS4;
		aPlsqlItem.SHIP_FROM_LOCATION := aSqlItem.SHIP_FROM_LOCATION;
		aPlsqlItem.SHIP_FROM_CITY := aSqlItem.SHIP_FROM_CITY;
		aPlsqlItem.SHIP_FROM_POSTAL_CODE := aSqlItem.SHIP_FROM_POSTAL_CODE;
		aPlsqlItem.SHIP_FROM_COUNTRY := aSqlItem.SHIP_FROM_COUNTRY;
		aPlsqlItem.SHIP_FROM_REGION1 := aSqlItem.SHIP_FROM_REGION1;
		aPlsqlItem.SHIP_FROM_REGION2 := aSqlItem.SHIP_FROM_REGION2;
		aPlsqlItem.SHIP_FROM_REGION3 := aSqlItem.SHIP_FROM_REGION3;
		aPlsqlItem.SHIP_FROM_ORG := aSqlItem.SHIP_FROM_ORG;
		aPlsqlItem.SHIP_TO_ADDRESS1 := aSqlItem.SHIP_TO_ADDRESS1;
		aPlsqlItem.SHIP_TO_ADDRESS2 := aSqlItem.SHIP_TO_ADDRESS2;
		aPlsqlItem.SHIP_TO_ADDRESS3 := aSqlItem.SHIP_TO_ADDRESS3;
		aPlsqlItem.SHIP_TO_ADDRESS4 := aSqlItem.SHIP_TO_ADDRESS4;
		aPlsqlItem.SHIP_TO_STATE := aSqlItem.SHIP_TO_STATE;
		aPlsqlItem.SHIP_TO_COUNTRY := aSqlItem.SHIP_TO_COUNTRY;
		aPlsqlItem.SHIP_TO_ZIP := aSqlItem.SHIP_TO_ZIP;
		aPlsqlItem.SHIP_TO_COUNTY := aSqlItem.SHIP_TO_COUNTY;
		aPlsqlItem.SHIP_TO_PROVINCE := aSqlItem.SHIP_TO_PROVINCE;
		aPlsqlItem.SHIP_TO_CITY := aSqlItem.SHIP_TO_CITY;
		aPlsqlItem.SHIP_TO_CONTACT := aSqlItem.SHIP_TO_CONTACT;
		aPlsqlItem.SHIP_TO_CONTACT_LAST_NAME := aSqlItem.SHIP_TO_CONTACT_LAST_NAME;
		aPlsqlItem.SHIP_TO_CONTACT_FIRST_NAME := aSqlItem.SHIP_TO_CONTACT_FIRST_NAME;
		aPlsqlItem.SHIP_TO_LOCATION := aSqlItem.SHIP_TO_LOCATION;
		aPlsqlItem.SHIP_TO_ORG := aSqlItem.SHIP_TO_ORG;
		aPlsqlItem.SOURCE_TYPE := aSqlItem.SOURCE_TYPE;
		aPlsqlItem.INTERMED_SHIP_TO_ADDRESS1 := aSqlItem.INTERMED_SHIP_TO_ADDRESS1;
		aPlsqlItem.INTERMED_SHIP_TO_ADDRESS2 := aSqlItem.INTERMED_SHIP_TO_ADDRESS2;
		aPlsqlItem.INTERMED_SHIP_TO_ADDRESS3 := aSqlItem.INTERMED_SHIP_TO_ADDRESS3;
		aPlsqlItem.INTERMED_SHIP_TO_ADDRESS4 := aSqlItem.INTERMED_SHIP_TO_ADDRESS4;
		aPlsqlItem.INTERMED_SHIP_TO_CONTACT := aSqlItem.INTERMED_SHIP_TO_CONTACT;
		aPlsqlItem.INTERMED_SHIP_TO_LOCATION := aSqlItem.INTERMED_SHIP_TO_LOCATION;
		aPlsqlItem.INTERMED_SHIP_TO_ORG := aSqlItem.INTERMED_SHIP_TO_ORG;
		aPlsqlItem.INTERMED_SHIP_TO_STATE := aSqlItem.INTERMED_SHIP_TO_STATE;
		aPlsqlItem.INTERMED_SHIP_TO_CITY := aSqlItem.INTERMED_SHIP_TO_CITY;
		aPlsqlItem.INTERMED_SHIP_TO_ZIP := aSqlItem.INTERMED_SHIP_TO_ZIP;
		aPlsqlItem.INTERMED_SHIP_TO_COUNTRY := aSqlItem.INTERMED_SHIP_TO_COUNTRY;
		aPlsqlItem.INTERMED_SHIP_TO_COUNTY := aSqlItem.INTERMED_SHIP_TO_COUNTY;
		aPlsqlItem.INTERMED_SHIP_TO_PROVINCE := aSqlItem.INTERMED_SHIP_TO_PROVINCE;
		aPlsqlItem.SOLD_TO_ORG := aSqlItem.SOLD_TO_ORG;
		aPlsqlItem.SOLD_FROM_ORG := aSqlItem.SOLD_FROM_ORG;
		aPlsqlItem.TASK := aSqlItem.TASK;
		aPlsqlItem.TAX_EXEMPT := aSqlItem.TAX_EXEMPT;
		aPlsqlItem.TAX_EXEMPT_REASON := aSqlItem.TAX_EXEMPT_REASON;
		aPlsqlItem.TAX_POINT := aSqlItem.TAX_POINT;
		aPlsqlItem.VEH_CUS_ITEM_CUM_KEY := aSqlItem.VEH_CUS_ITEM_CUM_KEY;
		aPlsqlItem.VISIBLE_DEMAND := aSqlItem.VISIBLE_DEMAND;
		aPlsqlItem.CUSTOMER_PAYMENT_TERM := aSqlItem.CUSTOMER_PAYMENT_TERM;
		aPlsqlItem.REF_ORDER_NUMBER := aSqlItem.REF_ORDER_NUMBER;
		aPlsqlItem.REF_LINE_NUMBER := aSqlItem.REF_LINE_NUMBER;
		aPlsqlItem.REF_SHIPMENT_NUMBER := aSqlItem.REF_SHIPMENT_NUMBER;
		aPlsqlItem.REF_OPTION_NUMBER := aSqlItem.REF_OPTION_NUMBER;
		aPlsqlItem.REF_COMPONENT_NUMBER := aSqlItem.REF_COMPONENT_NUMBER;
		aPlsqlItem.REF_INVOICE_NUMBER := aSqlItem.REF_INVOICE_NUMBER;
		aPlsqlItem.REF_INVOICE_LINE_NUMBER := aSqlItem.REF_INVOICE_LINE_NUMBER;
		aPlsqlItem.CREDIT_INVOICE_NUMBER := aSqlItem.CREDIT_INVOICE_NUMBER;
		aPlsqlItem.TAX_GROUP := aSqlItem.TAX_GROUP;
		aPlsqlItem.STATUS := aSqlItem.STATUS;
		aPlsqlItem.FREIGHT_CARRIER := aSqlItem.FREIGHT_CARRIER;
		aPlsqlItem.SHIPPING_METHOD := aSqlItem.SHIPPING_METHOD;
		aPlsqlItem.CALCULATE_PRICE_DESCR := aSqlItem.CALCULATE_PRICE_DESCR;
		aPlsqlItem.SHIP_TO_CUSTOMER_NAME := aSqlItem.SHIP_TO_CUSTOMER_NAME;
		aPlsqlItem.INVOICE_TO_CUSTOMER_NAME := aSqlItem.INVOICE_TO_CUSTOMER_NAME;
		aPlsqlItem.SHIP_TO_CUSTOMER_NUMBER := aSqlItem.SHIP_TO_CUSTOMER_NUMBER;
		aPlsqlItem.INVOICE_TO_CUSTOMER_NUMBER := aSqlItem.INVOICE_TO_CUSTOMER_NUMBER;
		aPlsqlItem.SHIP_TO_CUSTOMER_ID := aSqlItem.SHIP_TO_CUSTOMER_ID;
		aPlsqlItem.INVOICE_TO_CUSTOMER_ID := aSqlItem.INVOICE_TO_CUSTOMER_ID;
		aPlsqlItem.DELIVER_TO_CUSTOMER_ID := aSqlItem.DELIVER_TO_CUSTOMER_ID;
		aPlsqlItem.DELIVER_TO_CUSTOMER_NUMBER := aSqlItem.DELIVER_TO_CUSTOMER_NUMBER;
		aPlsqlItem.DELIVER_TO_CUSTOMER_NAME := aSqlItem.DELIVER_TO_CUSTOMER_NAME;
		aPlsqlItem.ORIGINAL_ORDERED_ITEM := aSqlItem.ORIGINAL_ORDERED_ITEM;
		aPlsqlItem.ORIGINAL_INVENTORY_ITEM := aSqlItem.ORIGINAL_INVENTORY_ITEM;
		aPlsqlItem.ORIGINAL_ITEM_IDENTIFIER_TYPE := aSqlItem.ORIGINAL_ITEM_IDENTIFIER_TYPE;
		aPlsqlItem.DELIVER_TO_CUSTOMER_NUMBER_OI := aSqlItem.DELIVER_TO_CUSTOMER_NUMBER_OI;
		aPlsqlItem.DELIVER_TO_CUSTOMER_NAME_OI := aSqlItem.DELIVER_TO_CUSTOMER_NAME_OI;
		aPlsqlItem.SHIP_TO_CUSTOMER_NUMBER_OI := aSqlItem.SHIP_TO_CUSTOMER_NUMBER_OI;
		aPlsqlItem.SHIP_TO_CUSTOMER_NAME_OI := aSqlItem.SHIP_TO_CUSTOMER_NAME_OI;
		aPlsqlItem.INVOICE_TO_CUSTOMER_NUMBER_OI := aSqlItem.INVOICE_TO_CUSTOMER_NUMBER_OI;
		aPlsqlItem.INVOICE_TO_CUSTOMER_NAME_OI := aSqlItem.INVOICE_TO_CUSTOMER_NAME_OI;
		aPlsqlItem.ITEM_RELATIONSHIP_TYPE_DSP := aSqlItem.ITEM_RELATIONSHIP_TYPE_DSP;
		aPlsqlItem.TRANSACTION_PHASE := aSqlItem.TRANSACTION_PHASE;
		aPlsqlItem.END_CUSTOMER_NAME := aSqlItem.END_CUSTOMER_NAME;
		aPlsqlItem.END_CUSTOMER_NUMBER := aSqlItem.END_CUSTOMER_NUMBER;
		aPlsqlItem.END_CUSTOMER_CONTACT := aSqlItem.END_CUSTOMER_CONTACT;
		aPlsqlItem.END_CUST_CONTACT_LAST_NAME := aSqlItem.END_CUST_CONTACT_LAST_NAME;
		aPlsqlItem.END_CUST_CONTACT_FIRST_NAME := aSqlItem.END_CUST_CONTACT_FIRST_NAME;
		aPlsqlItem.END_CUSTOMER_SITE_ADDRESS1 := aSqlItem.END_CUSTOMER_SITE_ADDRESS1;
		aPlsqlItem.END_CUSTOMER_SITE_ADDRESS2 := aSqlItem.END_CUSTOMER_SITE_ADDRESS2;
		aPlsqlItem.END_CUSTOMER_SITE_ADDRESS3 := aSqlItem.END_CUSTOMER_SITE_ADDRESS3;
		aPlsqlItem.END_CUSTOMER_SITE_ADDRESS4 := aSqlItem.END_CUSTOMER_SITE_ADDRESS4;
		aPlsqlItem.END_CUSTOMER_SITE_LOCATION := aSqlItem.END_CUSTOMER_SITE_LOCATION;
		aPlsqlItem.END_CUSTOMER_SITE_STATE := aSqlItem.END_CUSTOMER_SITE_STATE;
		aPlsqlItem.END_CUSTOMER_SITE_COUNTRY := aSqlItem.END_CUSTOMER_SITE_COUNTRY;
		aPlsqlItem.END_CUSTOMER_SITE_ZIP := aSqlItem.END_CUSTOMER_SITE_ZIP;
		aPlsqlItem.END_CUSTOMER_SITE_COUNTY := aSqlItem.END_CUSTOMER_SITE_COUNTY;
		aPlsqlItem.END_CUSTOMER_SITE_PROVINCE := aSqlItem.END_CUSTOMER_SITE_PROVINCE;
		aPlsqlItem.END_CUSTOMER_SITE_CITY := aSqlItem.END_CUSTOMER_SITE_CITY;
		aPlsqlItem.END_CUSTOMER_SITE_POSTAL_CODE := aSqlItem.END_CUSTOMER_SITE_POSTAL_CODE;
		aPlsqlItem.BLANKET_AGREEMENT_NAME := aSqlItem.BLANKET_AGREEMENT_NAME;
		aPlsqlItem.IB_OWNER_DSP := aSqlItem.IB_OWNER_DSP;
		aPlsqlItem.IB_CURRENT_LOCATION_DSP := aSqlItem.IB_CURRENT_LOCATION_DSP;
		aPlsqlItem.IB_INSTALLED_AT_LOCATION_DSP := aSqlItem.IB_INSTALLED_AT_LOCATION_DSP;
		aPlsqlItem.SERVICE_PERIOD_DSP := aSqlItem.SERVICE_PERIOD_DSP;
		aPlsqlItem.SERVICE_REFERENCE_TYPE := aSqlItem.SERVICE_REFERENCE_TYPE;
		RETURN aPlsqlItem;
	END SQL_TO_PL36;

	FUNCTION PL_TO_SQL13(aPlsqlItem OE_ORDER_PUB.LINE_VAL_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_VAL_TBL_TYP IS
	aSqlItem OE_ORDER_PUB_LINE_VAL_TBL_TYP;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_VAL_TBL_TYP();
        IF aPlsqlItem.COUNT > 0 THEN
		    aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
		    	aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL36(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL13;

	FUNCTION SQL_TO_PL13(aSqlItem OE_ORDER_PUB_LINE_VAL_TBL_TYP)
	RETURN OE_ORDER_PUB.LINE_VAL_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_VAL_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL36(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL13;

	FUNCTION PL_TO_SQL37(aPlsqlItem OE_ORDER_PUB.LINE_ADJ_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_ADJ_REC_TYP IS
	aSqlItem OE_ORDER_PUB_LINE_ADJ_REC_TYP;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_ADJ_REC_TYP(NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.ATTRIBUTE1 := aPlsqlItem.ATTRIBUTE1;
		aSqlItem.ATTRIBUTE10 := aPlsqlItem.ATTRIBUTE10;
		aSqlItem.ATTRIBUTE11 := aPlsqlItem.ATTRIBUTE11;
		aSqlItem.ATTRIBUTE12 := aPlsqlItem.ATTRIBUTE12;
		aSqlItem.ATTRIBUTE13 := aPlsqlItem.ATTRIBUTE13;
		aSqlItem.ATTRIBUTE14 := aPlsqlItem.ATTRIBUTE14;
		aSqlItem.ATTRIBUTE15 := aPlsqlItem.ATTRIBUTE15;
		aSqlItem.ATTRIBUTE2 := aPlsqlItem.ATTRIBUTE2;
		aSqlItem.ATTRIBUTE3 := aPlsqlItem.ATTRIBUTE3;
		aSqlItem.ATTRIBUTE4 := aPlsqlItem.ATTRIBUTE4;
		aSqlItem.ATTRIBUTE5 := aPlsqlItem.ATTRIBUTE5;
		aSqlItem.ATTRIBUTE6 := aPlsqlItem.ATTRIBUTE6;
		aSqlItem.ATTRIBUTE7 := aPlsqlItem.ATTRIBUTE7;
		aSqlItem.ATTRIBUTE8 := aPlsqlItem.ATTRIBUTE8;
		aSqlItem.ATTRIBUTE9 := aPlsqlItem.ATTRIBUTE9;
		aSqlItem.AUTOMATIC_FLAG := aPlsqlItem.AUTOMATIC_FLAG;
		aSqlItem.CONTEXT := aPlsqlItem.CONTEXT;
		aSqlItem.CREATED_BY := aPlsqlItem.CREATED_BY;
		aSqlItem.CREATION_DATE := aPlsqlItem.CREATION_DATE;
		aSqlItem.DISCOUNT_ID := aPlsqlItem.DISCOUNT_ID;
		aSqlItem.DISCOUNT_LINE_ID := aPlsqlItem.DISCOUNT_LINE_ID;
		aSqlItem.HEADER_ID := aPlsqlItem.HEADER_ID;
		aSqlItem.LAST_UPDATED_BY := aPlsqlItem.LAST_UPDATED_BY;
		aSqlItem.LAST_UPDATE_DATE := aPlsqlItem.LAST_UPDATE_DATE;
		aSqlItem.LAST_UPDATE_LOGIN := aPlsqlItem.LAST_UPDATE_LOGIN;
		aSqlItem.LINE_ID := aPlsqlItem.LINE_ID;
		aSqlItem.PERCENT := aPlsqlItem.PERCENT;
		aSqlItem.PRICE_ADJUSTMENT_ID := aPlsqlItem.PRICE_ADJUSTMENT_ID;
		aSqlItem.PROGRAM_APPLICATION_ID := aPlsqlItem.PROGRAM_APPLICATION_ID;
		aSqlItem.PROGRAM_ID := aPlsqlItem.PROGRAM_ID;
		aSqlItem.PROGRAM_UPDATE_DATE := aPlsqlItem.PROGRAM_UPDATE_DATE;
		aSqlItem.REQUEST_ID := aPlsqlItem.REQUEST_ID;
		aSqlItem.RETURN_STATUS := aPlsqlItem.RETURN_STATUS;
		aSqlItem.DB_FLAG := aPlsqlItem.DB_FLAG;
		aSqlItem.OPERATION := aPlsqlItem.OPERATION;
		aSqlItem.LINE_INDEX := aPlsqlItem.LINE_INDEX;
		aSqlItem.ORIG_SYS_DISCOUNT_REF := aPlsqlItem.ORIG_SYS_DISCOUNT_REF;
		aSqlItem.CHANGE_REQUEST_CODE := aPlsqlItem.CHANGE_REQUEST_CODE;
		aSqlItem.STATUS_FLAG := aPlsqlItem.STATUS_FLAG;
		aSqlItem.LIST_HEADER_ID := aPlsqlItem.LIST_HEADER_ID;
		aSqlItem.LIST_LINE_ID := aPlsqlItem.LIST_LINE_ID;
		aSqlItem.LIST_LINE_TYPE_CODE := aPlsqlItem.LIST_LINE_TYPE_CODE;
		aSqlItem.MODIFIER_MECHANISM_TYPE_CODE := aPlsqlItem.MODIFIER_MECHANISM_TYPE_CODE;
		aSqlItem.MODIFIED_FROM := aPlsqlItem.MODIFIED_FROM;
		aSqlItem.MODIFIED_TO := aPlsqlItem.MODIFIED_TO;
		aSqlItem.UPDATED_FLAG := aPlsqlItem.UPDATED_FLAG;
		aSqlItem.UPDATE_ALLOWED := aPlsqlItem.UPDATE_ALLOWED;
		aSqlItem.APPLIED_FLAG := aPlsqlItem.APPLIED_FLAG;
		aSqlItem.CHANGE_REASON_CODE := aPlsqlItem.CHANGE_REASON_CODE;
		aSqlItem.CHANGE_REASON_TEXT := aPlsqlItem.CHANGE_REASON_TEXT;
		aSqlItem.OPERAND := aPlsqlItem.OPERAND;
		aSqlItem.OPERAND_PER_PQTY := aPlsqlItem.OPERAND_PER_PQTY;
		aSqlItem.ARITHMETIC_OPERATOR := aPlsqlItem.ARITHMETIC_OPERATOR;
		aSqlItem.COST_ID := aPlsqlItem.COST_ID;
		aSqlItem.TAX_CODE := aPlsqlItem.TAX_CODE;
		aSqlItem.TAX_EXEMPT_FLAG := aPlsqlItem.TAX_EXEMPT_FLAG;
		aSqlItem.TAX_EXEMPT_NUMBER := aPlsqlItem.TAX_EXEMPT_NUMBER;
		aSqlItem.TAX_EXEMPT_REASON_CODE := aPlsqlItem.TAX_EXEMPT_REASON_CODE;
		aSqlItem.PARENT_ADJUSTMENT_ID := aPlsqlItem.PARENT_ADJUSTMENT_ID;
		aSqlItem.INVOICED_FLAG := aPlsqlItem.INVOICED_FLAG;
		aSqlItem.ESTIMATED_FLAG := aPlsqlItem.ESTIMATED_FLAG;
		aSqlItem.INC_IN_SALES_PERFORMANCE := aPlsqlItem.INC_IN_SALES_PERFORMANCE;
		aSqlItem.SPLIT_ACTION_CODE := aPlsqlItem.SPLIT_ACTION_CODE;
		aSqlItem.ADJUSTED_AMOUNT := aPlsqlItem.ADJUSTED_AMOUNT;
		aSqlItem.ADJUSTED_AMOUNT_PER_PQTY := aPlsqlItem.ADJUSTED_AMOUNT_PER_PQTY;
		aSqlItem.PRICING_PHASE_ID := aPlsqlItem.PRICING_PHASE_ID;
		aSqlItem.CHARGE_TYPE_CODE := aPlsqlItem.CHARGE_TYPE_CODE;
		aSqlItem.CHARGE_SUBTYPE_CODE := aPlsqlItem.CHARGE_SUBTYPE_CODE;
		aSqlItem.LIST_LINE_NO := aPlsqlItem.LIST_LINE_NO;
		aSqlItem.SOURCE_SYSTEM_CODE := aPlsqlItem.SOURCE_SYSTEM_CODE;
		aSqlItem.BENEFIT_QTY := aPlsqlItem.BENEFIT_QTY;
		aSqlItem.BENEFIT_UOM_CODE := aPlsqlItem.BENEFIT_UOM_CODE;
		aSqlItem.PRINT_ON_INVOICE_FLAG := aPlsqlItem.PRINT_ON_INVOICE_FLAG;
		aSqlItem.EXPIRATION_DATE := aPlsqlItem.EXPIRATION_DATE;
		aSqlItem.REBATE_TRANSACTION_TYPE_CODE := aPlsqlItem.REBATE_TRANSACTION_TYPE_CODE;
		aSqlItem.REBATE_TRANSACTION_REFERENCE := aPlsqlItem.REBATE_TRANSACTION_REFERENCE;
		aSqlItem.REBATE_PAYMENT_SYSTEM_CODE := aPlsqlItem.REBATE_PAYMENT_SYSTEM_CODE;
		aSqlItem.REDEEMED_DATE := aPlsqlItem.REDEEMED_DATE;
		aSqlItem.REDEEMED_FLAG := aPlsqlItem.REDEEMED_FLAG;
		aSqlItem.ACCRUAL_FLAG := aPlsqlItem.ACCRUAL_FLAG;
		aSqlItem.RANGE_BREAK_QUANTITY := aPlsqlItem.RANGE_BREAK_QUANTITY;
		aSqlItem.ACCRUAL_CONVERSION_RATE := aPlsqlItem.ACCRUAL_CONVERSION_RATE;
		aSqlItem.PRICING_GROUP_SEQUENCE := aPlsqlItem.PRICING_GROUP_SEQUENCE;
		aSqlItem.MODIFIER_LEVEL_CODE := aPlsqlItem.MODIFIER_LEVEL_CODE;
		aSqlItem.PRICE_BREAK_TYPE_CODE := aPlsqlItem.PRICE_BREAK_TYPE_CODE;
		aSqlItem.SUBSTITUTION_ATTRIBUTE := aPlsqlItem.SUBSTITUTION_ATTRIBUTE;
		aSqlItem.PRORATION_TYPE_CODE := aPlsqlItem.PRORATION_TYPE_CODE;
		aSqlItem.CREDIT_OR_CHARGE_FLAG := aPlsqlItem.CREDIT_OR_CHARGE_FLAG;
		aSqlItem.INCLUDE_ON_RETURNS_FLAG := aPlsqlItem.INCLUDE_ON_RETURNS_FLAG;
		aSqlItem.AC_ATTRIBUTE1 := aPlsqlItem.AC_ATTRIBUTE1;
		aSqlItem.AC_ATTRIBUTE10 := aPlsqlItem.AC_ATTRIBUTE10;
		aSqlItem.AC_ATTRIBUTE11 := aPlsqlItem.AC_ATTRIBUTE11;
		aSqlItem.AC_ATTRIBUTE12 := aPlsqlItem.AC_ATTRIBUTE12;
		aSqlItem.AC_ATTRIBUTE13 := aPlsqlItem.AC_ATTRIBUTE13;
		aSqlItem.AC_ATTRIBUTE14 := aPlsqlItem.AC_ATTRIBUTE14;
		aSqlItem.AC_ATTRIBUTE15 := aPlsqlItem.AC_ATTRIBUTE15;
		aSqlItem.AC_ATTRIBUTE2 := aPlsqlItem.AC_ATTRIBUTE2;
		aSqlItem.AC_ATTRIBUTE3 := aPlsqlItem.AC_ATTRIBUTE3;
		aSqlItem.AC_ATTRIBUTE4 := aPlsqlItem.AC_ATTRIBUTE4;
		aSqlItem.AC_ATTRIBUTE5 := aPlsqlItem.AC_ATTRIBUTE5;
		aSqlItem.AC_ATTRIBUTE6 := aPlsqlItem.AC_ATTRIBUTE6;
		aSqlItem.AC_ATTRIBUTE7 := aPlsqlItem.AC_ATTRIBUTE7;
		aSqlItem.AC_ATTRIBUTE8 := aPlsqlItem.AC_ATTRIBUTE8;
		aSqlItem.AC_ATTRIBUTE9 := aPlsqlItem.AC_ATTRIBUTE9;
		aSqlItem.AC_CONTEXT := aPlsqlItem.AC_CONTEXT;
		aSqlItem.LOCK_CONTROL := aPlsqlItem.LOCK_CONTROL;
		aSqlItem.GROUP_VALUE := aPlsqlItem.GROUP_VALUE;
		aSqlItem.INVOICED_AMOUNT := aPlsqlItem.INVOICED_AMOUNT;
		aSqlItem.RETROBILL_REQUEST_ID := aPlsqlItem.RETROBILL_REQUEST_ID;
		RETURN aSqlItem;
	END PL_TO_SQL37;

	FUNCTION SQL_TO_PL37(aSqlItem OE_ORDER_PUB_LINE_ADJ_REC_TYP)
	RETURN OE_ORDER_PUB.LINE_ADJ_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_ADJ_REC_TYPE;
	BEGIN
		aPlsqlItem.ATTRIBUTE1 := aSqlItem.ATTRIBUTE1;
		aPlsqlItem.ATTRIBUTE10 := aSqlItem.ATTRIBUTE10;
		aPlsqlItem.ATTRIBUTE11 := aSqlItem.ATTRIBUTE11;
		aPlsqlItem.ATTRIBUTE12 := aSqlItem.ATTRIBUTE12;
		aPlsqlItem.ATTRIBUTE13 := aSqlItem.ATTRIBUTE13;
		aPlsqlItem.ATTRIBUTE14 := aSqlItem.ATTRIBUTE14;
		aPlsqlItem.ATTRIBUTE15 := aSqlItem.ATTRIBUTE15;
		aPlsqlItem.ATTRIBUTE2 := aSqlItem.ATTRIBUTE2;
		aPlsqlItem.ATTRIBUTE3 := aSqlItem.ATTRIBUTE3;
		aPlsqlItem.ATTRIBUTE4 := aSqlItem.ATTRIBUTE4;
		aPlsqlItem.ATTRIBUTE5 := aSqlItem.ATTRIBUTE5;
		aPlsqlItem.ATTRIBUTE6 := aSqlItem.ATTRIBUTE6;
		aPlsqlItem.ATTRIBUTE7 := aSqlItem.ATTRIBUTE7;
		aPlsqlItem.ATTRIBUTE8 := aSqlItem.ATTRIBUTE8;
		aPlsqlItem.ATTRIBUTE9 := aSqlItem.ATTRIBUTE9;
		aPlsqlItem.AUTOMATIC_FLAG := aSqlItem.AUTOMATIC_FLAG;
		aPlsqlItem.CONTEXT := aSqlItem.CONTEXT;
		aPlsqlItem.CREATED_BY := aSqlItem.CREATED_BY;
		aPlsqlItem.CREATION_DATE := aSqlItem.CREATION_DATE;
		aPlsqlItem.DISCOUNT_ID := aSqlItem.DISCOUNT_ID;
		aPlsqlItem.DISCOUNT_LINE_ID := aSqlItem.DISCOUNT_LINE_ID;
		aPlsqlItem.HEADER_ID := aSqlItem.HEADER_ID;
		aPlsqlItem.LAST_UPDATED_BY := aSqlItem.LAST_UPDATED_BY;
		aPlsqlItem.LAST_UPDATE_DATE := aSqlItem.LAST_UPDATE_DATE;
		aPlsqlItem.LAST_UPDATE_LOGIN := aSqlItem.LAST_UPDATE_LOGIN;
		aPlsqlItem.LINE_ID := aSqlItem.LINE_ID;
		aPlsqlItem.PERCENT := aSqlItem.PERCENT;
		aPlsqlItem.PRICE_ADJUSTMENT_ID := aSqlItem.PRICE_ADJUSTMENT_ID;
		aPlsqlItem.PROGRAM_APPLICATION_ID := aSqlItem.PROGRAM_APPLICATION_ID;
		aPlsqlItem.PROGRAM_ID := aSqlItem.PROGRAM_ID;
		aPlsqlItem.PROGRAM_UPDATE_DATE := aSqlItem.PROGRAM_UPDATE_DATE;
		aPlsqlItem.REQUEST_ID := aSqlItem.REQUEST_ID;
		aPlsqlItem.RETURN_STATUS := aSqlItem.RETURN_STATUS;
		aPlsqlItem.DB_FLAG := aSqlItem.DB_FLAG;
		aPlsqlItem.OPERATION := aSqlItem.OPERATION;
		aPlsqlItem.LINE_INDEX := aSqlItem.LINE_INDEX;
		aPlsqlItem.ORIG_SYS_DISCOUNT_REF := aSqlItem.ORIG_SYS_DISCOUNT_REF;
		aPlsqlItem.CHANGE_REQUEST_CODE := aSqlItem.CHANGE_REQUEST_CODE;
		aPlsqlItem.STATUS_FLAG := aSqlItem.STATUS_FLAG;
		aPlsqlItem.LIST_HEADER_ID := aSqlItem.LIST_HEADER_ID;
		aPlsqlItem.LIST_LINE_ID := aSqlItem.LIST_LINE_ID;
		aPlsqlItem.LIST_LINE_TYPE_CODE := aSqlItem.LIST_LINE_TYPE_CODE;
		aPlsqlItem.MODIFIER_MECHANISM_TYPE_CODE := aSqlItem.MODIFIER_MECHANISM_TYPE_CODE;
		aPlsqlItem.MODIFIED_FROM := aSqlItem.MODIFIED_FROM;
		aPlsqlItem.MODIFIED_TO := aSqlItem.MODIFIED_TO;
		aPlsqlItem.UPDATED_FLAG := aSqlItem.UPDATED_FLAG;
		aPlsqlItem.UPDATE_ALLOWED := aSqlItem.UPDATE_ALLOWED;
		aPlsqlItem.APPLIED_FLAG := aSqlItem.APPLIED_FLAG;
		aPlsqlItem.CHANGE_REASON_CODE := aSqlItem.CHANGE_REASON_CODE;
		aPlsqlItem.CHANGE_REASON_TEXT := aSqlItem.CHANGE_REASON_TEXT;
		aPlsqlItem.OPERAND := aSqlItem.OPERAND;
		aPlsqlItem.OPERAND_PER_PQTY := aSqlItem.OPERAND_PER_PQTY;
		aPlsqlItem.ARITHMETIC_OPERATOR := aSqlItem.ARITHMETIC_OPERATOR;
		aPlsqlItem.COST_ID := aSqlItem.COST_ID;
		aPlsqlItem.TAX_CODE := aSqlItem.TAX_CODE;
		aPlsqlItem.TAX_EXEMPT_FLAG := aSqlItem.TAX_EXEMPT_FLAG;
		aPlsqlItem.TAX_EXEMPT_NUMBER := aSqlItem.TAX_EXEMPT_NUMBER;
		aPlsqlItem.TAX_EXEMPT_REASON_CODE := aSqlItem.TAX_EXEMPT_REASON_CODE;
		aPlsqlItem.PARENT_ADJUSTMENT_ID := aSqlItem.PARENT_ADJUSTMENT_ID;
		aPlsqlItem.INVOICED_FLAG := aSqlItem.INVOICED_FLAG;
		aPlsqlItem.ESTIMATED_FLAG := aSqlItem.ESTIMATED_FLAG;
		aPlsqlItem.INC_IN_SALES_PERFORMANCE := aSqlItem.INC_IN_SALES_PERFORMANCE;
		aPlsqlItem.SPLIT_ACTION_CODE := aSqlItem.SPLIT_ACTION_CODE;
		aPlsqlItem.ADJUSTED_AMOUNT := aSqlItem.ADJUSTED_AMOUNT;
		aPlsqlItem.ADJUSTED_AMOUNT_PER_PQTY := aSqlItem.ADJUSTED_AMOUNT_PER_PQTY;
		aPlsqlItem.PRICING_PHASE_ID := aSqlItem.PRICING_PHASE_ID;
		aPlsqlItem.CHARGE_TYPE_CODE := aSqlItem.CHARGE_TYPE_CODE;
		aPlsqlItem.CHARGE_SUBTYPE_CODE := aSqlItem.CHARGE_SUBTYPE_CODE;
		aPlsqlItem.LIST_LINE_NO := aSqlItem.LIST_LINE_NO;
		aPlsqlItem.SOURCE_SYSTEM_CODE := aSqlItem.SOURCE_SYSTEM_CODE;
		aPlsqlItem.BENEFIT_QTY := aSqlItem.BENEFIT_QTY;
		aPlsqlItem.BENEFIT_UOM_CODE := aSqlItem.BENEFIT_UOM_CODE;
		aPlsqlItem.PRINT_ON_INVOICE_FLAG := aSqlItem.PRINT_ON_INVOICE_FLAG;
		aPlsqlItem.EXPIRATION_DATE := aSqlItem.EXPIRATION_DATE;
		aPlsqlItem.REBATE_TRANSACTION_TYPE_CODE := aSqlItem.REBATE_TRANSACTION_TYPE_CODE;
		aPlsqlItem.REBATE_TRANSACTION_REFERENCE := aSqlItem.REBATE_TRANSACTION_REFERENCE;
		aPlsqlItem.REBATE_PAYMENT_SYSTEM_CODE := aSqlItem.REBATE_PAYMENT_SYSTEM_CODE;
		aPlsqlItem.REDEEMED_DATE := aSqlItem.REDEEMED_DATE;
		aPlsqlItem.REDEEMED_FLAG := aSqlItem.REDEEMED_FLAG;
		aPlsqlItem.ACCRUAL_FLAG := aSqlItem.ACCRUAL_FLAG;
		aPlsqlItem.RANGE_BREAK_QUANTITY := aSqlItem.RANGE_BREAK_QUANTITY;
		aPlsqlItem.ACCRUAL_CONVERSION_RATE := aSqlItem.ACCRUAL_CONVERSION_RATE;
		aPlsqlItem.PRICING_GROUP_SEQUENCE := aSqlItem.PRICING_GROUP_SEQUENCE;
		aPlsqlItem.MODIFIER_LEVEL_CODE := aSqlItem.MODIFIER_LEVEL_CODE;
		aPlsqlItem.PRICE_BREAK_TYPE_CODE := aSqlItem.PRICE_BREAK_TYPE_CODE;
		aPlsqlItem.SUBSTITUTION_ATTRIBUTE := aSqlItem.SUBSTITUTION_ATTRIBUTE;
		aPlsqlItem.PRORATION_TYPE_CODE := aSqlItem.PRORATION_TYPE_CODE;
		aPlsqlItem.CREDIT_OR_CHARGE_FLAG := aSqlItem.CREDIT_OR_CHARGE_FLAG;
		aPlsqlItem.INCLUDE_ON_RETURNS_FLAG := aSqlItem.INCLUDE_ON_RETURNS_FLAG;
		aPlsqlItem.AC_ATTRIBUTE1 := aSqlItem.AC_ATTRIBUTE1;
		aPlsqlItem.AC_ATTRIBUTE10 := aSqlItem.AC_ATTRIBUTE10;
		aPlsqlItem.AC_ATTRIBUTE11 := aSqlItem.AC_ATTRIBUTE11;
		aPlsqlItem.AC_ATTRIBUTE12 := aSqlItem.AC_ATTRIBUTE12;
		aPlsqlItem.AC_ATTRIBUTE13 := aSqlItem.AC_ATTRIBUTE13;
		aPlsqlItem.AC_ATTRIBUTE14 := aSqlItem.AC_ATTRIBUTE14;
		aPlsqlItem.AC_ATTRIBUTE15 := aSqlItem.AC_ATTRIBUTE15;
		aPlsqlItem.AC_ATTRIBUTE2 := aSqlItem.AC_ATTRIBUTE2;
		aPlsqlItem.AC_ATTRIBUTE3 := aSqlItem.AC_ATTRIBUTE3;
		aPlsqlItem.AC_ATTRIBUTE4 := aSqlItem.AC_ATTRIBUTE4;
		aPlsqlItem.AC_ATTRIBUTE5 := aSqlItem.AC_ATTRIBUTE5;
		aPlsqlItem.AC_ATTRIBUTE6 := aSqlItem.AC_ATTRIBUTE6;
		aPlsqlItem.AC_ATTRIBUTE7 := aSqlItem.AC_ATTRIBUTE7;
		aPlsqlItem.AC_ATTRIBUTE8 := aSqlItem.AC_ATTRIBUTE8;
		aPlsqlItem.AC_ATTRIBUTE9 := aSqlItem.AC_ATTRIBUTE9;
		aPlsqlItem.AC_CONTEXT := aSqlItem.AC_CONTEXT;
		aPlsqlItem.LOCK_CONTROL := aSqlItem.LOCK_CONTROL;
		aPlsqlItem.GROUP_VALUE := aSqlItem.GROUP_VALUE;
		aPlsqlItem.INVOICED_AMOUNT := aSqlItem.INVOICED_AMOUNT;
		aPlsqlItem.RETROBILL_REQUEST_ID := aSqlItem.RETROBILL_REQUEST_ID;
		RETURN aPlsqlItem;
	END SQL_TO_PL37;

	FUNCTION PL_TO_SQL14(aPlsqlItem OE_ORDER_PUB.LINE_ADJ_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_ADJ_TBL_TYP IS
	aSqlItem OE_ORDER_PUB_LINE_ADJ_TBL_TYP;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_ADJ_TBL_TYP();
        IF aPlsqlItem.COUNT > 0 THEN
		    aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			    aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL37(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL14;

	FUNCTION SQL_TO_PL14(aSqlItem OE_ORDER_PUB_LINE_ADJ_TBL_TYP)
	RETURN OE_ORDER_PUB.LINE_ADJ_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_ADJ_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL37(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL14;

	FUNCTION PL_TO_SQL38(aPlsqlItem OE_ORDER_PUB.LINE_ADJ_VAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_ADJ_VAL_REC IS
	aSqlItem OE_ORDER_PUB_LINE_ADJ_VAL_REC;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_ADJ_VAL_REC(NULL, NULL, NULL);
		aSqlItem.DISCOUNT := aPlsqlItem.DISCOUNT;
		aSqlItem.LIST_NAME := aPlsqlItem.LIST_NAME;
		aSqlItem.VERSION_NO := aPlsqlItem.VERSION_NO;
		RETURN aSqlItem;
	END PL_TO_SQL38;

	FUNCTION SQL_TO_PL38(aSqlItem OE_ORDER_PUB_LINE_ADJ_VAL_REC)
	RETURN OE_ORDER_PUB.LINE_ADJ_VAL_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_ADJ_VAL_REC_TYPE;
	BEGIN
		aPlsqlItem.DISCOUNT := aSqlItem.DISCOUNT;
		aPlsqlItem.LIST_NAME := aSqlItem.LIST_NAME;
		aPlsqlItem.VERSION_NO := aSqlItem.VERSION_NO;
		RETURN aPlsqlItem;
	END SQL_TO_PL38;

	FUNCTION PL_TO_SQL15(aPlsqlItem OE_ORDER_PUB.LINE_ADJ_VAL_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_ADJ_VAL_TBL IS
	aSqlItem OE_ORDER_PUB_LINE_ADJ_VAL_TBL;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_ADJ_VAL_TBL();
        IF aPlsqlItem.COUNT > 0 THEN
		    aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			    aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL38(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL15;

	FUNCTION SQL_TO_PL15(aSqlItem OE_ORDER_PUB_LINE_ADJ_VAL_TBL)
	RETURN OE_ORDER_PUB.LINE_ADJ_VAL_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_ADJ_VAL_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL38(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL15;

	FUNCTION PL_TO_SQL39(aPlsqlItem OE_ORDER_PUB.LINE_PRICE_ATT_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_PRICE_ATT_R IS
	aSqlItem OE_ORDER_PUB_LINE_PRICE_ATT_R;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_PRICE_ATT_R(NULL, NULL, NULL, NULL, NULL, NULL,
                 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                 NULL, NULL);
		aSqlItem.ORDER_PRICE_ATTRIB_ID := aPlsqlItem.ORDER_PRICE_ATTRIB_ID;
		aSqlItem.HEADER_ID := aPlsqlItem.HEADER_ID;
		aSqlItem.LINE_ID := aPlsqlItem.LINE_ID;
		aSqlItem.LINE_INDEX := aPlsqlItem.LINE_INDEX;
		aSqlItem.CREATION_DATE := aPlsqlItem.CREATION_DATE;
		aSqlItem.CREATED_BY := aPlsqlItem.CREATED_BY;
		aSqlItem.LAST_UPDATE_DATE := aPlsqlItem.LAST_UPDATE_DATE;
		aSqlItem.LAST_UPDATED_BY := aPlsqlItem.LAST_UPDATED_BY;
		aSqlItem.LAST_UPDATE_LOGIN := aPlsqlItem.LAST_UPDATE_LOGIN;
		aSqlItem.PROGRAM_APPLICATION_ID := aPlsqlItem.PROGRAM_APPLICATION_ID;
		aSqlItem.PROGRAM_ID := aPlsqlItem.PROGRAM_ID;
		aSqlItem.PROGRAM_UPDATE_DATE := aPlsqlItem.PROGRAM_UPDATE_DATE;
		aSqlItem.REQUEST_ID := aPlsqlItem.REQUEST_ID;
		aSqlItem.FLEX_TITLE := aPlsqlItem.FLEX_TITLE;
		aSqlItem.PRICING_CONTEXT := aPlsqlItem.PRICING_CONTEXT;
		aSqlItem.PRICING_ATTRIBUTE1 := aPlsqlItem.PRICING_ATTRIBUTE1;
		aSqlItem.PRICING_ATTRIBUTE2 := aPlsqlItem.PRICING_ATTRIBUTE2;
		aSqlItem.PRICING_ATTRIBUTE3 := aPlsqlItem.PRICING_ATTRIBUTE3;
		aSqlItem.PRICING_ATTRIBUTE4 := aPlsqlItem.PRICING_ATTRIBUTE4;
		aSqlItem.PRICING_ATTRIBUTE5 := aPlsqlItem.PRICING_ATTRIBUTE5;
		aSqlItem.PRICING_ATTRIBUTE6 := aPlsqlItem.PRICING_ATTRIBUTE6;
		aSqlItem.PRICING_ATTRIBUTE7 := aPlsqlItem.PRICING_ATTRIBUTE7;
		aSqlItem.PRICING_ATTRIBUTE8 := aPlsqlItem.PRICING_ATTRIBUTE8;
		aSqlItem.PRICING_ATTRIBUTE9 := aPlsqlItem.PRICING_ATTRIBUTE9;
		aSqlItem.PRICING_ATTRIBUTE10 := aPlsqlItem.PRICING_ATTRIBUTE10;
		aSqlItem.PRICING_ATTRIBUTE11 := aPlsqlItem.PRICING_ATTRIBUTE11;
		aSqlItem.PRICING_ATTRIBUTE12 := aPlsqlItem.PRICING_ATTRIBUTE12;
		aSqlItem.PRICING_ATTRIBUTE13 := aPlsqlItem.PRICING_ATTRIBUTE13;
		aSqlItem.PRICING_ATTRIBUTE14 := aPlsqlItem.PRICING_ATTRIBUTE14;
		aSqlItem.PRICING_ATTRIBUTE15 := aPlsqlItem.PRICING_ATTRIBUTE15;
		aSqlItem.PRICING_ATTRIBUTE16 := aPlsqlItem.PRICING_ATTRIBUTE16;
		aSqlItem.PRICING_ATTRIBUTE17 := aPlsqlItem.PRICING_ATTRIBUTE17;
		aSqlItem.PRICING_ATTRIBUTE18 := aPlsqlItem.PRICING_ATTRIBUTE18;
		aSqlItem.PRICING_ATTRIBUTE19 := aPlsqlItem.PRICING_ATTRIBUTE19;
		aSqlItem.PRICING_ATTRIBUTE20 := aPlsqlItem.PRICING_ATTRIBUTE20;
		aSqlItem.PRICING_ATTRIBUTE21 := aPlsqlItem.PRICING_ATTRIBUTE21;
		aSqlItem.PRICING_ATTRIBUTE22 := aPlsqlItem.PRICING_ATTRIBUTE22;
		aSqlItem.PRICING_ATTRIBUTE23 := aPlsqlItem.PRICING_ATTRIBUTE23;
		aSqlItem.PRICING_ATTRIBUTE24 := aPlsqlItem.PRICING_ATTRIBUTE24;
		aSqlItem.PRICING_ATTRIBUTE25 := aPlsqlItem.PRICING_ATTRIBUTE25;
		aSqlItem.PRICING_ATTRIBUTE26 := aPlsqlItem.PRICING_ATTRIBUTE26;
		aSqlItem.PRICING_ATTRIBUTE27 := aPlsqlItem.PRICING_ATTRIBUTE27;
		aSqlItem.PRICING_ATTRIBUTE28 := aPlsqlItem.PRICING_ATTRIBUTE28;
		aSqlItem.PRICING_ATTRIBUTE29 := aPlsqlItem.PRICING_ATTRIBUTE29;
		aSqlItem.PRICING_ATTRIBUTE30 := aPlsqlItem.PRICING_ATTRIBUTE30;
		aSqlItem.PRICING_ATTRIBUTE31 := aPlsqlItem.PRICING_ATTRIBUTE31;
		aSqlItem.PRICING_ATTRIBUTE32 := aPlsqlItem.PRICING_ATTRIBUTE32;
		aSqlItem.PRICING_ATTRIBUTE33 := aPlsqlItem.PRICING_ATTRIBUTE33;
		aSqlItem.PRICING_ATTRIBUTE34 := aPlsqlItem.PRICING_ATTRIBUTE34;
		aSqlItem.PRICING_ATTRIBUTE35 := aPlsqlItem.PRICING_ATTRIBUTE35;
		aSqlItem.PRICING_ATTRIBUTE36 := aPlsqlItem.PRICING_ATTRIBUTE36;
		aSqlItem.PRICING_ATTRIBUTE37 := aPlsqlItem.PRICING_ATTRIBUTE37;
		aSqlItem.PRICING_ATTRIBUTE38 := aPlsqlItem.PRICING_ATTRIBUTE38;
		aSqlItem.PRICING_ATTRIBUTE39 := aPlsqlItem.PRICING_ATTRIBUTE39;
		aSqlItem.PRICING_ATTRIBUTE40 := aPlsqlItem.PRICING_ATTRIBUTE40;
		aSqlItem.PRICING_ATTRIBUTE41 := aPlsqlItem.PRICING_ATTRIBUTE41;
		aSqlItem.PRICING_ATTRIBUTE42 := aPlsqlItem.PRICING_ATTRIBUTE42;
		aSqlItem.PRICING_ATTRIBUTE43 := aPlsqlItem.PRICING_ATTRIBUTE43;
		aSqlItem.PRICING_ATTRIBUTE44 := aPlsqlItem.PRICING_ATTRIBUTE44;
		aSqlItem.PRICING_ATTRIBUTE45 := aPlsqlItem.PRICING_ATTRIBUTE45;
		aSqlItem.PRICING_ATTRIBUTE46 := aPlsqlItem.PRICING_ATTRIBUTE46;
		aSqlItem.PRICING_ATTRIBUTE47 := aPlsqlItem.PRICING_ATTRIBUTE47;
		aSqlItem.PRICING_ATTRIBUTE48 := aPlsqlItem.PRICING_ATTRIBUTE48;
		aSqlItem.PRICING_ATTRIBUTE49 := aPlsqlItem.PRICING_ATTRIBUTE49;
		aSqlItem.PRICING_ATTRIBUTE50 := aPlsqlItem.PRICING_ATTRIBUTE50;
		aSqlItem.PRICING_ATTRIBUTE51 := aPlsqlItem.PRICING_ATTRIBUTE51;
		aSqlItem.PRICING_ATTRIBUTE52 := aPlsqlItem.PRICING_ATTRIBUTE52;
		aSqlItem.PRICING_ATTRIBUTE53 := aPlsqlItem.PRICING_ATTRIBUTE53;
		aSqlItem.PRICING_ATTRIBUTE54 := aPlsqlItem.PRICING_ATTRIBUTE54;
		aSqlItem.PRICING_ATTRIBUTE55 := aPlsqlItem.PRICING_ATTRIBUTE55;
		aSqlItem.PRICING_ATTRIBUTE56 := aPlsqlItem.PRICING_ATTRIBUTE56;
		aSqlItem.PRICING_ATTRIBUTE57 := aPlsqlItem.PRICING_ATTRIBUTE57;
		aSqlItem.PRICING_ATTRIBUTE58 := aPlsqlItem.PRICING_ATTRIBUTE58;
		aSqlItem.PRICING_ATTRIBUTE59 := aPlsqlItem.PRICING_ATTRIBUTE59;
		aSqlItem.PRICING_ATTRIBUTE60 := aPlsqlItem.PRICING_ATTRIBUTE60;
		aSqlItem.PRICING_ATTRIBUTE61 := aPlsqlItem.PRICING_ATTRIBUTE61;
		aSqlItem.PRICING_ATTRIBUTE62 := aPlsqlItem.PRICING_ATTRIBUTE62;
		aSqlItem.PRICING_ATTRIBUTE63 := aPlsqlItem.PRICING_ATTRIBUTE63;
		aSqlItem.PRICING_ATTRIBUTE64 := aPlsqlItem.PRICING_ATTRIBUTE64;
		aSqlItem.PRICING_ATTRIBUTE65 := aPlsqlItem.PRICING_ATTRIBUTE65;
		aSqlItem.PRICING_ATTRIBUTE66 := aPlsqlItem.PRICING_ATTRIBUTE66;
		aSqlItem.PRICING_ATTRIBUTE67 := aPlsqlItem.PRICING_ATTRIBUTE67;
		aSqlItem.PRICING_ATTRIBUTE68 := aPlsqlItem.PRICING_ATTRIBUTE68;
		aSqlItem.PRICING_ATTRIBUTE69 := aPlsqlItem.PRICING_ATTRIBUTE69;
		aSqlItem.PRICING_ATTRIBUTE70 := aPlsqlItem.PRICING_ATTRIBUTE70;
		aSqlItem.PRICING_ATTRIBUTE71 := aPlsqlItem.PRICING_ATTRIBUTE71;
		aSqlItem.PRICING_ATTRIBUTE72 := aPlsqlItem.PRICING_ATTRIBUTE72;
		aSqlItem.PRICING_ATTRIBUTE73 := aPlsqlItem.PRICING_ATTRIBUTE73;
		aSqlItem.PRICING_ATTRIBUTE74 := aPlsqlItem.PRICING_ATTRIBUTE74;
		aSqlItem.PRICING_ATTRIBUTE75 := aPlsqlItem.PRICING_ATTRIBUTE75;
		aSqlItem.PRICING_ATTRIBUTE76 := aPlsqlItem.PRICING_ATTRIBUTE76;
		aSqlItem.PRICING_ATTRIBUTE77 := aPlsqlItem.PRICING_ATTRIBUTE77;
		aSqlItem.PRICING_ATTRIBUTE78 := aPlsqlItem.PRICING_ATTRIBUTE78;
		aSqlItem.PRICING_ATTRIBUTE79 := aPlsqlItem.PRICING_ATTRIBUTE79;
		aSqlItem.PRICING_ATTRIBUTE80 := aPlsqlItem.PRICING_ATTRIBUTE80;
		aSqlItem.PRICING_ATTRIBUTE81 := aPlsqlItem.PRICING_ATTRIBUTE81;
		aSqlItem.PRICING_ATTRIBUTE82 := aPlsqlItem.PRICING_ATTRIBUTE82;
		aSqlItem.PRICING_ATTRIBUTE83 := aPlsqlItem.PRICING_ATTRIBUTE83;
		aSqlItem.PRICING_ATTRIBUTE84 := aPlsqlItem.PRICING_ATTRIBUTE84;
		aSqlItem.PRICING_ATTRIBUTE85 := aPlsqlItem.PRICING_ATTRIBUTE85;
		aSqlItem.PRICING_ATTRIBUTE86 := aPlsqlItem.PRICING_ATTRIBUTE86;
		aSqlItem.PRICING_ATTRIBUTE87 := aPlsqlItem.PRICING_ATTRIBUTE87;
		aSqlItem.PRICING_ATTRIBUTE88 := aPlsqlItem.PRICING_ATTRIBUTE88;
		aSqlItem.PRICING_ATTRIBUTE89 := aPlsqlItem.PRICING_ATTRIBUTE89;
		aSqlItem.PRICING_ATTRIBUTE90 := aPlsqlItem.PRICING_ATTRIBUTE90;
		aSqlItem.PRICING_ATTRIBUTE91 := aPlsqlItem.PRICING_ATTRIBUTE91;
		aSqlItem.PRICING_ATTRIBUTE92 := aPlsqlItem.PRICING_ATTRIBUTE92;
		aSqlItem.PRICING_ATTRIBUTE93 := aPlsqlItem.PRICING_ATTRIBUTE93;
		aSqlItem.PRICING_ATTRIBUTE94 := aPlsqlItem.PRICING_ATTRIBUTE94;
		aSqlItem.PRICING_ATTRIBUTE95 := aPlsqlItem.PRICING_ATTRIBUTE95;
		aSqlItem.PRICING_ATTRIBUTE96 := aPlsqlItem.PRICING_ATTRIBUTE96;
		aSqlItem.PRICING_ATTRIBUTE97 := aPlsqlItem.PRICING_ATTRIBUTE97;
		aSqlItem.PRICING_ATTRIBUTE98 := aPlsqlItem.PRICING_ATTRIBUTE98;
		aSqlItem.PRICING_ATTRIBUTE99 := aPlsqlItem.PRICING_ATTRIBUTE99;
		aSqlItem.PRICING_ATTRIBUTE100 := aPlsqlItem.PRICING_ATTRIBUTE100;
		aSqlItem.CONTEXT := aPlsqlItem.CONTEXT;
		aSqlItem.ATTRIBUTE1 := aPlsqlItem.ATTRIBUTE1;
		aSqlItem.ATTRIBUTE2 := aPlsqlItem.ATTRIBUTE2;
		aSqlItem.ATTRIBUTE3 := aPlsqlItem.ATTRIBUTE3;
		aSqlItem.ATTRIBUTE4 := aPlsqlItem.ATTRIBUTE4;
		aSqlItem.ATTRIBUTE5 := aPlsqlItem.ATTRIBUTE5;
		aSqlItem.ATTRIBUTE6 := aPlsqlItem.ATTRIBUTE6;
		aSqlItem.ATTRIBUTE7 := aPlsqlItem.ATTRIBUTE7;
		aSqlItem.ATTRIBUTE8 := aPlsqlItem.ATTRIBUTE8;
		aSqlItem.ATTRIBUTE9 := aPlsqlItem.ATTRIBUTE9;
		aSqlItem.ATTRIBUTE10 := aPlsqlItem.ATTRIBUTE10;
		aSqlItem.ATTRIBUTE11 := aPlsqlItem.ATTRIBUTE11;
		aSqlItem.ATTRIBUTE12 := aPlsqlItem.ATTRIBUTE12;
		aSqlItem.ATTRIBUTE13 := aPlsqlItem.ATTRIBUTE13;
		aSqlItem.ATTRIBUTE14 := aPlsqlItem.ATTRIBUTE14;
		aSqlItem.ATTRIBUTE15 := aPlsqlItem.ATTRIBUTE15;
		aSqlItem.OVERRIDE_FLAG := aPlsqlItem.OVERRIDE_FLAG;
		aSqlItem.RETURN_STATUS := aPlsqlItem.RETURN_STATUS;
		aSqlItem.DB_FLAG := aPlsqlItem.DB_FLAG;
		aSqlItem.OPERATION := aPlsqlItem.OPERATION;
		aSqlItem.LOCK_CONTROL := aPlsqlItem.LOCK_CONTROL;
		aSqlItem.ORIG_SYS_ATTS_REF := aPlsqlItem.ORIG_SYS_ATTS_REF;
		aSqlItem.CHANGE_REQUEST_CODE := aPlsqlItem.CHANGE_REQUEST_CODE;
		RETURN aSqlItem;
	END PL_TO_SQL39;

	FUNCTION SQL_TO_PL39(aSqlItem OE_ORDER_PUB_LINE_PRICE_ATT_R)
	RETURN OE_ORDER_PUB.LINE_PRICE_ATT_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_PRICE_ATT_REC_TYPE;
	BEGIN
		aPlsqlItem.ORDER_PRICE_ATTRIB_ID := aSqlItem.ORDER_PRICE_ATTRIB_ID;
		aPlsqlItem.HEADER_ID := aSqlItem.HEADER_ID;
		aPlsqlItem.LINE_ID := aSqlItem.LINE_ID;
		aPlsqlItem.LINE_INDEX := aSqlItem.LINE_INDEX;
		aPlsqlItem.CREATION_DATE := aSqlItem.CREATION_DATE;
		aPlsqlItem.CREATED_BY := aSqlItem.CREATED_BY;
		aPlsqlItem.LAST_UPDATE_DATE := aSqlItem.LAST_UPDATE_DATE;
		aPlsqlItem.LAST_UPDATED_BY := aSqlItem.LAST_UPDATED_BY;
		aPlsqlItem.LAST_UPDATE_LOGIN := aSqlItem.LAST_UPDATE_LOGIN;
		aPlsqlItem.PROGRAM_APPLICATION_ID := aSqlItem.PROGRAM_APPLICATION_ID;
		aPlsqlItem.PROGRAM_ID := aSqlItem.PROGRAM_ID;
		aPlsqlItem.PROGRAM_UPDATE_DATE := aSqlItem.PROGRAM_UPDATE_DATE;
		aPlsqlItem.REQUEST_ID := aSqlItem.REQUEST_ID;
		aPlsqlItem.FLEX_TITLE := aSqlItem.FLEX_TITLE;
		aPlsqlItem.PRICING_CONTEXT := aSqlItem.PRICING_CONTEXT;
		aPlsqlItem.PRICING_ATTRIBUTE1 := aSqlItem.PRICING_ATTRIBUTE1;
		aPlsqlItem.PRICING_ATTRIBUTE2 := aSqlItem.PRICING_ATTRIBUTE2;
		aPlsqlItem.PRICING_ATTRIBUTE3 := aSqlItem.PRICING_ATTRIBUTE3;
		aPlsqlItem.PRICING_ATTRIBUTE4 := aSqlItem.PRICING_ATTRIBUTE4;
		aPlsqlItem.PRICING_ATTRIBUTE5 := aSqlItem.PRICING_ATTRIBUTE5;
		aPlsqlItem.PRICING_ATTRIBUTE6 := aSqlItem.PRICING_ATTRIBUTE6;
		aPlsqlItem.PRICING_ATTRIBUTE7 := aSqlItem.PRICING_ATTRIBUTE7;
		aPlsqlItem.PRICING_ATTRIBUTE8 := aSqlItem.PRICING_ATTRIBUTE8;
		aPlsqlItem.PRICING_ATTRIBUTE9 := aSqlItem.PRICING_ATTRIBUTE9;
		aPlsqlItem.PRICING_ATTRIBUTE10 := aSqlItem.PRICING_ATTRIBUTE10;
		aPlsqlItem.PRICING_ATTRIBUTE11 := aSqlItem.PRICING_ATTRIBUTE11;
		aPlsqlItem.PRICING_ATTRIBUTE12 := aSqlItem.PRICING_ATTRIBUTE12;
		aPlsqlItem.PRICING_ATTRIBUTE13 := aSqlItem.PRICING_ATTRIBUTE13;
		aPlsqlItem.PRICING_ATTRIBUTE14 := aSqlItem.PRICING_ATTRIBUTE14;
		aPlsqlItem.PRICING_ATTRIBUTE15 := aSqlItem.PRICING_ATTRIBUTE15;
		aPlsqlItem.PRICING_ATTRIBUTE16 := aSqlItem.PRICING_ATTRIBUTE16;
		aPlsqlItem.PRICING_ATTRIBUTE17 := aSqlItem.PRICING_ATTRIBUTE17;
		aPlsqlItem.PRICING_ATTRIBUTE18 := aSqlItem.PRICING_ATTRIBUTE18;
		aPlsqlItem.PRICING_ATTRIBUTE19 := aSqlItem.PRICING_ATTRIBUTE19;
		aPlsqlItem.PRICING_ATTRIBUTE20 := aSqlItem.PRICING_ATTRIBUTE20;
		aPlsqlItem.PRICING_ATTRIBUTE21 := aSqlItem.PRICING_ATTRIBUTE21;
		aPlsqlItem.PRICING_ATTRIBUTE22 := aSqlItem.PRICING_ATTRIBUTE22;
		aPlsqlItem.PRICING_ATTRIBUTE23 := aSqlItem.PRICING_ATTRIBUTE23;
		aPlsqlItem.PRICING_ATTRIBUTE24 := aSqlItem.PRICING_ATTRIBUTE24;
		aPlsqlItem.PRICING_ATTRIBUTE25 := aSqlItem.PRICING_ATTRIBUTE25;
		aPlsqlItem.PRICING_ATTRIBUTE26 := aSqlItem.PRICING_ATTRIBUTE26;
		aPlsqlItem.PRICING_ATTRIBUTE27 := aSqlItem.PRICING_ATTRIBUTE27;
		aPlsqlItem.PRICING_ATTRIBUTE28 := aSqlItem.PRICING_ATTRIBUTE28;
		aPlsqlItem.PRICING_ATTRIBUTE29 := aSqlItem.PRICING_ATTRIBUTE29;
		aPlsqlItem.PRICING_ATTRIBUTE30 := aSqlItem.PRICING_ATTRIBUTE30;
		aPlsqlItem.PRICING_ATTRIBUTE31 := aSqlItem.PRICING_ATTRIBUTE31;
		aPlsqlItem.PRICING_ATTRIBUTE32 := aSqlItem.PRICING_ATTRIBUTE32;
		aPlsqlItem.PRICING_ATTRIBUTE33 := aSqlItem.PRICING_ATTRIBUTE33;
		aPlsqlItem.PRICING_ATTRIBUTE34 := aSqlItem.PRICING_ATTRIBUTE34;
		aPlsqlItem.PRICING_ATTRIBUTE35 := aSqlItem.PRICING_ATTRIBUTE35;
		aPlsqlItem.PRICING_ATTRIBUTE36 := aSqlItem.PRICING_ATTRIBUTE36;
		aPlsqlItem.PRICING_ATTRIBUTE37 := aSqlItem.PRICING_ATTRIBUTE37;
		aPlsqlItem.PRICING_ATTRIBUTE38 := aSqlItem.PRICING_ATTRIBUTE38;
		aPlsqlItem.PRICING_ATTRIBUTE39 := aSqlItem.PRICING_ATTRIBUTE39;
		aPlsqlItem.PRICING_ATTRIBUTE40 := aSqlItem.PRICING_ATTRIBUTE40;
		aPlsqlItem.PRICING_ATTRIBUTE41 := aSqlItem.PRICING_ATTRIBUTE41;
		aPlsqlItem.PRICING_ATTRIBUTE42 := aSqlItem.PRICING_ATTRIBUTE42;
		aPlsqlItem.PRICING_ATTRIBUTE43 := aSqlItem.PRICING_ATTRIBUTE43;
		aPlsqlItem.PRICING_ATTRIBUTE44 := aSqlItem.PRICING_ATTRIBUTE44;
		aPlsqlItem.PRICING_ATTRIBUTE45 := aSqlItem.PRICING_ATTRIBUTE45;
		aPlsqlItem.PRICING_ATTRIBUTE46 := aSqlItem.PRICING_ATTRIBUTE46;
		aPlsqlItem.PRICING_ATTRIBUTE47 := aSqlItem.PRICING_ATTRIBUTE47;
		aPlsqlItem.PRICING_ATTRIBUTE48 := aSqlItem.PRICING_ATTRIBUTE48;
		aPlsqlItem.PRICING_ATTRIBUTE49 := aSqlItem.PRICING_ATTRIBUTE49;
		aPlsqlItem.PRICING_ATTRIBUTE50 := aSqlItem.PRICING_ATTRIBUTE50;
		aPlsqlItem.PRICING_ATTRIBUTE51 := aSqlItem.PRICING_ATTRIBUTE51;
		aPlsqlItem.PRICING_ATTRIBUTE52 := aSqlItem.PRICING_ATTRIBUTE52;
		aPlsqlItem.PRICING_ATTRIBUTE53 := aSqlItem.PRICING_ATTRIBUTE53;
		aPlsqlItem.PRICING_ATTRIBUTE54 := aSqlItem.PRICING_ATTRIBUTE54;
		aPlsqlItem.PRICING_ATTRIBUTE55 := aSqlItem.PRICING_ATTRIBUTE55;
		aPlsqlItem.PRICING_ATTRIBUTE56 := aSqlItem.PRICING_ATTRIBUTE56;
		aPlsqlItem.PRICING_ATTRIBUTE57 := aSqlItem.PRICING_ATTRIBUTE57;
		aPlsqlItem.PRICING_ATTRIBUTE58 := aSqlItem.PRICING_ATTRIBUTE58;
		aPlsqlItem.PRICING_ATTRIBUTE59 := aSqlItem.PRICING_ATTRIBUTE59;
		aPlsqlItem.PRICING_ATTRIBUTE60 := aSqlItem.PRICING_ATTRIBUTE60;
		aPlsqlItem.PRICING_ATTRIBUTE61 := aSqlItem.PRICING_ATTRIBUTE61;
		aPlsqlItem.PRICING_ATTRIBUTE62 := aSqlItem.PRICING_ATTRIBUTE62;
		aPlsqlItem.PRICING_ATTRIBUTE63 := aSqlItem.PRICING_ATTRIBUTE63;
		aPlsqlItem.PRICING_ATTRIBUTE64 := aSqlItem.PRICING_ATTRIBUTE64;
		aPlsqlItem.PRICING_ATTRIBUTE65 := aSqlItem.PRICING_ATTRIBUTE65;
		aPlsqlItem.PRICING_ATTRIBUTE66 := aSqlItem.PRICING_ATTRIBUTE66;
		aPlsqlItem.PRICING_ATTRIBUTE67 := aSqlItem.PRICING_ATTRIBUTE67;
		aPlsqlItem.PRICING_ATTRIBUTE68 := aSqlItem.PRICING_ATTRIBUTE68;
		aPlsqlItem.PRICING_ATTRIBUTE69 := aSqlItem.PRICING_ATTRIBUTE69;
		aPlsqlItem.PRICING_ATTRIBUTE70 := aSqlItem.PRICING_ATTRIBUTE70;
		aPlsqlItem.PRICING_ATTRIBUTE71 := aSqlItem.PRICING_ATTRIBUTE71;
		aPlsqlItem.PRICING_ATTRIBUTE72 := aSqlItem.PRICING_ATTRIBUTE72;
		aPlsqlItem.PRICING_ATTRIBUTE73 := aSqlItem.PRICING_ATTRIBUTE73;
		aPlsqlItem.PRICING_ATTRIBUTE74 := aSqlItem.PRICING_ATTRIBUTE74;
		aPlsqlItem.PRICING_ATTRIBUTE75 := aSqlItem.PRICING_ATTRIBUTE75;
		aPlsqlItem.PRICING_ATTRIBUTE76 := aSqlItem.PRICING_ATTRIBUTE76;
		aPlsqlItem.PRICING_ATTRIBUTE77 := aSqlItem.PRICING_ATTRIBUTE77;
		aPlsqlItem.PRICING_ATTRIBUTE78 := aSqlItem.PRICING_ATTRIBUTE78;
		aPlsqlItem.PRICING_ATTRIBUTE79 := aSqlItem.PRICING_ATTRIBUTE79;
		aPlsqlItem.PRICING_ATTRIBUTE80 := aSqlItem.PRICING_ATTRIBUTE80;
		aPlsqlItem.PRICING_ATTRIBUTE81 := aSqlItem.PRICING_ATTRIBUTE81;
		aPlsqlItem.PRICING_ATTRIBUTE82 := aSqlItem.PRICING_ATTRIBUTE82;
		aPlsqlItem.PRICING_ATTRIBUTE83 := aSqlItem.PRICING_ATTRIBUTE83;
		aPlsqlItem.PRICING_ATTRIBUTE84 := aSqlItem.PRICING_ATTRIBUTE84;
		aPlsqlItem.PRICING_ATTRIBUTE85 := aSqlItem.PRICING_ATTRIBUTE85;
		aPlsqlItem.PRICING_ATTRIBUTE86 := aSqlItem.PRICING_ATTRIBUTE86;
		aPlsqlItem.PRICING_ATTRIBUTE87 := aSqlItem.PRICING_ATTRIBUTE87;
		aPlsqlItem.PRICING_ATTRIBUTE88 := aSqlItem.PRICING_ATTRIBUTE88;
		aPlsqlItem.PRICING_ATTRIBUTE89 := aSqlItem.PRICING_ATTRIBUTE89;
		aPlsqlItem.PRICING_ATTRIBUTE90 := aSqlItem.PRICING_ATTRIBUTE90;
		aPlsqlItem.PRICING_ATTRIBUTE91 := aSqlItem.PRICING_ATTRIBUTE91;
		aPlsqlItem.PRICING_ATTRIBUTE92 := aSqlItem.PRICING_ATTRIBUTE92;
		aPlsqlItem.PRICING_ATTRIBUTE93 := aSqlItem.PRICING_ATTRIBUTE93;
		aPlsqlItem.PRICING_ATTRIBUTE94 := aSqlItem.PRICING_ATTRIBUTE94;
		aPlsqlItem.PRICING_ATTRIBUTE95 := aSqlItem.PRICING_ATTRIBUTE95;
		aPlsqlItem.PRICING_ATTRIBUTE96 := aSqlItem.PRICING_ATTRIBUTE96;
		aPlsqlItem.PRICING_ATTRIBUTE97 := aSqlItem.PRICING_ATTRIBUTE97;
		aPlsqlItem.PRICING_ATTRIBUTE98 := aSqlItem.PRICING_ATTRIBUTE98;
		aPlsqlItem.PRICING_ATTRIBUTE99 := aSqlItem.PRICING_ATTRIBUTE99;
		aPlsqlItem.PRICING_ATTRIBUTE100 := aSqlItem.PRICING_ATTRIBUTE100;
		aPlsqlItem.CONTEXT := aSqlItem.CONTEXT;
		aPlsqlItem.ATTRIBUTE1 := aSqlItem.ATTRIBUTE1;
		aPlsqlItem.ATTRIBUTE2 := aSqlItem.ATTRIBUTE2;
		aPlsqlItem.ATTRIBUTE3 := aSqlItem.ATTRIBUTE3;
		aPlsqlItem.ATTRIBUTE4 := aSqlItem.ATTRIBUTE4;
		aPlsqlItem.ATTRIBUTE5 := aSqlItem.ATTRIBUTE5;
		aPlsqlItem.ATTRIBUTE6 := aSqlItem.ATTRIBUTE6;
		aPlsqlItem.ATTRIBUTE7 := aSqlItem.ATTRIBUTE7;
		aPlsqlItem.ATTRIBUTE8 := aSqlItem.ATTRIBUTE8;
		aPlsqlItem.ATTRIBUTE9 := aSqlItem.ATTRIBUTE9;
		aPlsqlItem.ATTRIBUTE10 := aSqlItem.ATTRIBUTE10;
		aPlsqlItem.ATTRIBUTE11 := aSqlItem.ATTRIBUTE11;
		aPlsqlItem.ATTRIBUTE12 := aSqlItem.ATTRIBUTE12;
		aPlsqlItem.ATTRIBUTE13 := aSqlItem.ATTRIBUTE13;
		aPlsqlItem.ATTRIBUTE14 := aSqlItem.ATTRIBUTE14;
		aPlsqlItem.ATTRIBUTE15 := aSqlItem.ATTRIBUTE15;
		aPlsqlItem.OVERRIDE_FLAG := aSqlItem.OVERRIDE_FLAG;
		aPlsqlItem.RETURN_STATUS := aSqlItem.RETURN_STATUS;
		aPlsqlItem.DB_FLAG := aSqlItem.DB_FLAG;
		aPlsqlItem.OPERATION := aSqlItem.OPERATION;
		aPlsqlItem.LOCK_CONTROL := aSqlItem.LOCK_CONTROL;
		aPlsqlItem.ORIG_SYS_ATTS_REF := aSqlItem.ORIG_SYS_ATTS_REF;
		aPlsqlItem.CHANGE_REQUEST_CODE := aSqlItem.CHANGE_REQUEST_CODE;
		RETURN aPlsqlItem;
	END SQL_TO_PL39;

	FUNCTION PL_TO_SQL16(aPlsqlItem OE_ORDER_PUB.LINE_PRICE_ATT_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_PRICE_ATT_T IS
	aSqlItem OE_ORDER_PUB_LINE_PRICE_ATT_T;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_PRICE_ATT_T();
		IF aPlsqlItem.COUNT > 0 THEN
            aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			    aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL39(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL16;

	FUNCTION SQL_TO_PL16(aSqlItem OE_ORDER_PUB_LINE_PRICE_ATT_T)
	RETURN OE_ORDER_PUB.LINE_PRICE_ATT_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_PRICE_ATT_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL39(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL16;

	FUNCTION PL_TO_SQL40(aPlsqlItem OE_ORDER_PUB.LINE_ADJ_ATT_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_ADJ_ATT_REC IS
	aSqlItem OE_ORDER_PUB_LINE_ADJ_ATT_REC;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_ADJ_ATT_REC(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.PRICE_ADJ_ATTRIB_ID := aPlsqlItem.PRICE_ADJ_ATTRIB_ID;
		aSqlItem.PRICE_ADJUSTMENT_ID := aPlsqlItem.PRICE_ADJUSTMENT_ID;
		aSqlItem.ADJ_INDEX := aPlsqlItem.ADJ_INDEX;
		aSqlItem.FLEX_TITLE := aPlsqlItem.FLEX_TITLE;
		aSqlItem.PRICING_CONTEXT := aPlsqlItem.PRICING_CONTEXT;
		aSqlItem.PRICING_ATTRIBUTE := aPlsqlItem.PRICING_ATTRIBUTE;
		aSqlItem.CREATION_DATE := aPlsqlItem.CREATION_DATE;
		aSqlItem.CREATED_BY := aPlsqlItem.CREATED_BY;
		aSqlItem.LAST_UPDATE_DATE := aPlsqlItem.LAST_UPDATE_DATE;
		aSqlItem.LAST_UPDATED_BY := aPlsqlItem.LAST_UPDATED_BY;
		aSqlItem.LAST_UPDATE_LOGIN := aPlsqlItem.LAST_UPDATE_LOGIN;
		aSqlItem.PROGRAM_APPLICATION_ID := aPlsqlItem.PROGRAM_APPLICATION_ID;
		aSqlItem.PROGRAM_ID := aPlsqlItem.PROGRAM_ID;
		aSqlItem.PROGRAM_UPDATE_DATE := aPlsqlItem.PROGRAM_UPDATE_DATE;
		aSqlItem.REQUEST_ID := aPlsqlItem.REQUEST_ID;
		aSqlItem.PRICING_ATTR_VALUE_FROM := aPlsqlItem.PRICING_ATTR_VALUE_FROM;
		aSqlItem.PRICING_ATTR_VALUE_TO := aPlsqlItem.PRICING_ATTR_VALUE_TO;
		aSqlItem.COMPARISON_OPERATOR := aPlsqlItem.COMPARISON_OPERATOR;
		aSqlItem.RETURN_STATUS := aPlsqlItem.RETURN_STATUS;
		aSqlItem.DB_FLAG := aPlsqlItem.DB_FLAG;
		aSqlItem.OPERATION := aPlsqlItem.OPERATION;
		aSqlItem.LOCK_CONTROL := aPlsqlItem.LOCK_CONTROL;
		RETURN aSqlItem;
	END PL_TO_SQL40;

	FUNCTION SQL_TO_PL40(aSqlItem OE_ORDER_PUB_LINE_ADJ_ATT_REC)
	RETURN OE_ORDER_PUB.LINE_ADJ_ATT_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_ADJ_ATT_REC_TYPE;
	BEGIN
		aPlsqlItem.PRICE_ADJ_ATTRIB_ID := aSqlItem.PRICE_ADJ_ATTRIB_ID;
		aPlsqlItem.PRICE_ADJUSTMENT_ID := aSqlItem.PRICE_ADJUSTMENT_ID;
		aPlsqlItem.ADJ_INDEX := aSqlItem.ADJ_INDEX;
		aPlsqlItem.FLEX_TITLE := aSqlItem.FLEX_TITLE;
		aPlsqlItem.PRICING_CONTEXT := aSqlItem.PRICING_CONTEXT;
		aPlsqlItem.PRICING_ATTRIBUTE := aSqlItem.PRICING_ATTRIBUTE;
		aPlsqlItem.CREATION_DATE := aSqlItem.CREATION_DATE;
		aPlsqlItem.CREATED_BY := aSqlItem.CREATED_BY;
		aPlsqlItem.LAST_UPDATE_DATE := aSqlItem.LAST_UPDATE_DATE;
		aPlsqlItem.LAST_UPDATED_BY := aSqlItem.LAST_UPDATED_BY;
		aPlsqlItem.LAST_UPDATE_LOGIN := aSqlItem.LAST_UPDATE_LOGIN;
		aPlsqlItem.PROGRAM_APPLICATION_ID := aSqlItem.PROGRAM_APPLICATION_ID;
		aPlsqlItem.PROGRAM_ID := aSqlItem.PROGRAM_ID;
		aPlsqlItem.PROGRAM_UPDATE_DATE := aSqlItem.PROGRAM_UPDATE_DATE;
		aPlsqlItem.REQUEST_ID := aSqlItem.REQUEST_ID;
		aPlsqlItem.PRICING_ATTR_VALUE_FROM := aSqlItem.PRICING_ATTR_VALUE_FROM;
		aPlsqlItem.PRICING_ATTR_VALUE_TO := aSqlItem.PRICING_ATTR_VALUE_TO;
		aPlsqlItem.COMPARISON_OPERATOR := aSqlItem.COMPARISON_OPERATOR;
		aPlsqlItem.RETURN_STATUS := aSqlItem.RETURN_STATUS;
		aPlsqlItem.DB_FLAG := aSqlItem.DB_FLAG;
		aPlsqlItem.OPERATION := aSqlItem.OPERATION;
		aPlsqlItem.LOCK_CONTROL := aSqlItem.LOCK_CONTROL;
		RETURN aPlsqlItem;
	END SQL_TO_PL40;

	FUNCTION PL_TO_SQL17(aPlsqlItem OE_ORDER_PUB.LINE_ADJ_ATT_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_ADJ_ATT_TBL IS
	aSqlItem OE_ORDER_PUB_LINE_ADJ_ATT_TBL;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_ADJ_ATT_TBL();
		IF aPlsqlItem.COUNT > 0 THEN
            aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			    aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL40(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL17;

	FUNCTION SQL_TO_PL17(aSqlItem OE_ORDER_PUB_LINE_ADJ_ATT_TBL)
	RETURN OE_ORDER_PUB.LINE_ADJ_ATT_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_ADJ_ATT_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL40(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL17;

	FUNCTION PL_TO_SQL41(aPlsqlItem OE_ORDER_PUB.LINE_ADJ_ASSOC_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_ADJ_ASSOC_R IS
	aSqlItem OE_ORDER_PUB_LINE_ADJ_ASSOC_R;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_ADJ_ASSOC_R(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.PRICE_ADJ_ASSOC_ID := aPlsqlItem.PRICE_ADJ_ASSOC_ID;
		aSqlItem.LINE_ID := aPlsqlItem.LINE_ID;
		aSqlItem.LINE_INDEX := aPlsqlItem.LINE_INDEX;
		aSqlItem.PRICE_ADJUSTMENT_ID := aPlsqlItem.PRICE_ADJUSTMENT_ID;
		aSqlItem.ADJ_INDEX := aPlsqlItem.ADJ_INDEX;
		aSqlItem.RLTD_PRICE_ADJ_ID := aPlsqlItem.RLTD_PRICE_ADJ_ID;
		aSqlItem.RLTD_ADJ_INDEX := aPlsqlItem.RLTD_ADJ_INDEX;
		aSqlItem.CREATION_DATE := aPlsqlItem.CREATION_DATE;
		aSqlItem.CREATED_BY := aPlsqlItem.CREATED_BY;
		aSqlItem.LAST_UPDATE_DATE := aPlsqlItem.LAST_UPDATE_DATE;
		aSqlItem.LAST_UPDATED_BY := aPlsqlItem.LAST_UPDATED_BY;
		aSqlItem.LAST_UPDATE_LOGIN := aPlsqlItem.LAST_UPDATE_LOGIN;
		aSqlItem.PROGRAM_APPLICATION_ID := aPlsqlItem.PROGRAM_APPLICATION_ID;
		aSqlItem.PROGRAM_ID := aPlsqlItem.PROGRAM_ID;
		aSqlItem.PROGRAM_UPDATE_DATE := aPlsqlItem.PROGRAM_UPDATE_DATE;
		aSqlItem.REQUEST_ID := aPlsqlItem.REQUEST_ID;
		aSqlItem.RETURN_STATUS := aPlsqlItem.RETURN_STATUS;
		aSqlItem.DB_FLAG := aPlsqlItem.DB_FLAG;
		aSqlItem.OPERATION := aPlsqlItem.OPERATION;
		aSqlItem.LOCK_CONTROL := aPlsqlItem.LOCK_CONTROL;
		RETURN aSqlItem;
	END PL_TO_SQL41;

	FUNCTION SQL_TO_PL41(aSqlItem OE_ORDER_PUB_LINE_ADJ_ASSOC_R)
	RETURN OE_ORDER_PUB.LINE_ADJ_ASSOC_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_ADJ_ASSOC_REC_TYPE;
	BEGIN
		aPlsqlItem.PRICE_ADJ_ASSOC_ID := aSqlItem.PRICE_ADJ_ASSOC_ID;
		aPlsqlItem.LINE_ID := aSqlItem.LINE_ID;
		aPlsqlItem.LINE_INDEX := aSqlItem.LINE_INDEX;
		aPlsqlItem.PRICE_ADJUSTMENT_ID := aSqlItem.PRICE_ADJUSTMENT_ID;
		aPlsqlItem.ADJ_INDEX := aSqlItem.ADJ_INDEX;
		aPlsqlItem.RLTD_PRICE_ADJ_ID := aSqlItem.RLTD_PRICE_ADJ_ID;
		aPlsqlItem.RLTD_ADJ_INDEX := aSqlItem.RLTD_ADJ_INDEX;
		aPlsqlItem.CREATION_DATE := aSqlItem.CREATION_DATE;
		aPlsqlItem.CREATED_BY := aSqlItem.CREATED_BY;
		aPlsqlItem.LAST_UPDATE_DATE := aSqlItem.LAST_UPDATE_DATE;
		aPlsqlItem.LAST_UPDATED_BY := aSqlItem.LAST_UPDATED_BY;
		aPlsqlItem.LAST_UPDATE_LOGIN := aSqlItem.LAST_UPDATE_LOGIN;
		aPlsqlItem.PROGRAM_APPLICATION_ID := aSqlItem.PROGRAM_APPLICATION_ID;
		aPlsqlItem.PROGRAM_ID := aSqlItem.PROGRAM_ID;
		aPlsqlItem.PROGRAM_UPDATE_DATE := aSqlItem.PROGRAM_UPDATE_DATE;
		aPlsqlItem.REQUEST_ID := aSqlItem.REQUEST_ID;
		aPlsqlItem.RETURN_STATUS := aSqlItem.RETURN_STATUS;
		aPlsqlItem.DB_FLAG := aSqlItem.DB_FLAG;
		aPlsqlItem.OPERATION := aSqlItem.OPERATION;
		aPlsqlItem.LOCK_CONTROL := aSqlItem.LOCK_CONTROL;
		RETURN aPlsqlItem;
	END SQL_TO_PL41;

	FUNCTION PL_TO_SQL18(aPlsqlItem OE_ORDER_PUB.LINE_ADJ_ASSOC_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_ADJ_ASSOC_T IS
	aSqlItem OE_ORDER_PUB_LINE_ADJ_ASSOC_T;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_ADJ_ASSOC_T();
        IF aPlsqlItem.COUNT > 0 THEN
		    aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			    aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL41(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL18;

	FUNCTION SQL_TO_PL18(aSqlItem OE_ORDER_PUB_LINE_ADJ_ASSOC_T)
	RETURN OE_ORDER_PUB.LINE_ADJ_ASSOC_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_ADJ_ASSOC_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL41(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL18;
	FUNCTION PL_TO_SQL42(aPlsqlItem OE_ORDER_PUB.LINE_SCREDIT_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_SCREDIT_REC IS
	aSqlItem OE_ORDER_PUB_LINE_SCREDIT_REC;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_SCREDIT_REC(NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.ATTRIBUTE1 := aPlsqlItem.ATTRIBUTE1;
		aSqlItem.ATTRIBUTE10 := aPlsqlItem.ATTRIBUTE10;
		aSqlItem.ATTRIBUTE11 := aPlsqlItem.ATTRIBUTE11;
		aSqlItem.ATTRIBUTE12 := aPlsqlItem.ATTRIBUTE12;
		aSqlItem.ATTRIBUTE13 := aPlsqlItem.ATTRIBUTE13;
		aSqlItem.ATTRIBUTE14 := aPlsqlItem.ATTRIBUTE14;
		aSqlItem.ATTRIBUTE15 := aPlsqlItem.ATTRIBUTE15;
		aSqlItem.ATTRIBUTE2 := aPlsqlItem.ATTRIBUTE2;
		aSqlItem.ATTRIBUTE3 := aPlsqlItem.ATTRIBUTE3;
		aSqlItem.ATTRIBUTE4 := aPlsqlItem.ATTRIBUTE4;
		aSqlItem.ATTRIBUTE5 := aPlsqlItem.ATTRIBUTE5;
		aSqlItem.ATTRIBUTE6 := aPlsqlItem.ATTRIBUTE6;
		aSqlItem.ATTRIBUTE7 := aPlsqlItem.ATTRIBUTE7;
		aSqlItem.ATTRIBUTE8 := aPlsqlItem.ATTRIBUTE8;
		aSqlItem.ATTRIBUTE9 := aPlsqlItem.ATTRIBUTE9;
		aSqlItem.CONTEXT := aPlsqlItem.CONTEXT;
		aSqlItem.CREATED_BY := aPlsqlItem.CREATED_BY;
		aSqlItem.CREATION_DATE := aPlsqlItem.CREATION_DATE;
		aSqlItem.DW_UPDATE_ADVICE_FLAG := aPlsqlItem.DW_UPDATE_ADVICE_FLAG;
		aSqlItem.HEADER_ID := aPlsqlItem.HEADER_ID;
		aSqlItem.LAST_UPDATED_BY := aPlsqlItem.LAST_UPDATED_BY;
		aSqlItem.LAST_UPDATE_DATE := aPlsqlItem.LAST_UPDATE_DATE;
		aSqlItem.LAST_UPDATE_LOGIN := aPlsqlItem.LAST_UPDATE_LOGIN;
		aSqlItem.LINE_ID := aPlsqlItem.LINE_ID;
		aSqlItem.PERCENT := aPlsqlItem.PERCENT;
		aSqlItem.SALESREP_ID := aPlsqlItem.SALESREP_ID;
		aSqlItem.SALES_CREDIT_ID := aPlsqlItem.SALES_CREDIT_ID;
		aSqlItem.SALES_CREDIT_TYPE_ID := aPlsqlItem.SALES_CREDIT_TYPE_ID;
		aSqlItem.WH_UPDATE_DATE := aPlsqlItem.WH_UPDATE_DATE;
		aSqlItem.RETURN_STATUS := aPlsqlItem.RETURN_STATUS;
		aSqlItem.DB_FLAG := aPlsqlItem.DB_FLAG;
		aSqlItem.OPERATION := aPlsqlItem.OPERATION;
		aSqlItem.LINE_INDEX := aPlsqlItem.LINE_INDEX;
		aSqlItem.ORIG_SYS_CREDIT_REF := aPlsqlItem.ORIG_SYS_CREDIT_REF;
		aSqlItem.CHANGE_REQUEST_CODE := aPlsqlItem.CHANGE_REQUEST_CODE;
		aSqlItem.STATUS_FLAG := aPlsqlItem.STATUS_FLAG;
		aSqlItem.LOCK_CONTROL := aPlsqlItem.LOCK_CONTROL;
		aSqlItem.CHANGE_REASON := aPlsqlItem.CHANGE_REASON;
		aSqlItem.CHANGE_COMMENTS := aPlsqlItem.CHANGE_COMMENTS;
		aSqlItem.SALES_GROUP_ID := aPlsqlItem.SALES_GROUP_ID;
		aSqlItem.SALES_GROUP_UPDATED_FLAG := aPlsqlItem.SALES_GROUP_UPDATED_FLAG;
		RETURN aSqlItem;
	END PL_TO_SQL42;
	FUNCTION SQL_TO_PL42(aSqlItem OE_ORDER_PUB_LINE_SCREDIT_REC)
	RETURN OE_ORDER_PUB.LINE_SCREDIT_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_SCREDIT_REC_TYPE;
	BEGIN
		aPlsqlItem.ATTRIBUTE1 := aSqlItem.ATTRIBUTE1;
		aPlsqlItem.ATTRIBUTE10 := aSqlItem.ATTRIBUTE10;
		aPlsqlItem.ATTRIBUTE11 := aSqlItem.ATTRIBUTE11;
		aPlsqlItem.ATTRIBUTE12 := aSqlItem.ATTRIBUTE12;
		aPlsqlItem.ATTRIBUTE13 := aSqlItem.ATTRIBUTE13;
		aPlsqlItem.ATTRIBUTE14 := aSqlItem.ATTRIBUTE14;
		aPlsqlItem.ATTRIBUTE15 := aSqlItem.ATTRIBUTE15;
		aPlsqlItem.ATTRIBUTE2 := aSqlItem.ATTRIBUTE2;
		aPlsqlItem.ATTRIBUTE3 := aSqlItem.ATTRIBUTE3;
		aPlsqlItem.ATTRIBUTE4 := aSqlItem.ATTRIBUTE4;
		aPlsqlItem.ATTRIBUTE5 := aSqlItem.ATTRIBUTE5;
		aPlsqlItem.ATTRIBUTE6 := aSqlItem.ATTRIBUTE6;
		aPlsqlItem.ATTRIBUTE7 := aSqlItem.ATTRIBUTE7;
		aPlsqlItem.ATTRIBUTE8 := aSqlItem.ATTRIBUTE8;
		aPlsqlItem.ATTRIBUTE9 := aSqlItem.ATTRIBUTE9;
		aPlsqlItem.CONTEXT := aSqlItem.CONTEXT;
		aPlsqlItem.CREATED_BY := aSqlItem.CREATED_BY;
		aPlsqlItem.CREATION_DATE := aSqlItem.CREATION_DATE;
		aPlsqlItem.DW_UPDATE_ADVICE_FLAG := aSqlItem.DW_UPDATE_ADVICE_FLAG;
		aPlsqlItem.HEADER_ID := aSqlItem.HEADER_ID;
		aPlsqlItem.LAST_UPDATED_BY := aSqlItem.LAST_UPDATED_BY;
		aPlsqlItem.LAST_UPDATE_DATE := aSqlItem.LAST_UPDATE_DATE;
		aPlsqlItem.LAST_UPDATE_LOGIN := aSqlItem.LAST_UPDATE_LOGIN;
		aPlsqlItem.LINE_ID := aSqlItem.LINE_ID;
		aPlsqlItem.PERCENT := aSqlItem.PERCENT;
		aPlsqlItem.SALESREP_ID := aSqlItem.SALESREP_ID;
		aPlsqlItem.SALES_CREDIT_ID := aSqlItem.SALES_CREDIT_ID;
		aPlsqlItem.SALES_CREDIT_TYPE_ID := aSqlItem.SALES_CREDIT_TYPE_ID;
		aPlsqlItem.WH_UPDATE_DATE := aSqlItem.WH_UPDATE_DATE;
		aPlsqlItem.RETURN_STATUS := aSqlItem.RETURN_STATUS;
		aPlsqlItem.DB_FLAG := aSqlItem.DB_FLAG;
		aPlsqlItem.OPERATION := aSqlItem.OPERATION;
		aPlsqlItem.LINE_INDEX := aSqlItem.LINE_INDEX;
		aPlsqlItem.ORIG_SYS_CREDIT_REF := aSqlItem.ORIG_SYS_CREDIT_REF;
		aPlsqlItem.CHANGE_REQUEST_CODE := aSqlItem.CHANGE_REQUEST_CODE;
		aPlsqlItem.STATUS_FLAG := aSqlItem.STATUS_FLAG;
		aPlsqlItem.LOCK_CONTROL := aSqlItem.LOCK_CONTROL;
		aPlsqlItem.CHANGE_REASON := aSqlItem.CHANGE_REASON;
		aPlsqlItem.CHANGE_COMMENTS := aSqlItem.CHANGE_COMMENTS;
		aPlsqlItem.SALES_GROUP_ID := aSqlItem.SALES_GROUP_ID;
		aPlsqlItem.SALES_GROUP_UPDATED_FLAG := aSqlItem.SALES_GROUP_UPDATED_FLAG;
		RETURN aPlsqlItem;
	END SQL_TO_PL42;

	FUNCTION PL_TO_SQL19(aPlsqlItem OE_ORDER_PUB.LINE_SCREDIT_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_SCREDIT_TBL IS
	aSqlItem OE_ORDER_PUB_LINE_SCREDIT_TBL;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_SCREDIT_TBL();
		IF aPlsqlItem.COUNT > 0 THEN
            aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			    aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL42(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL19;

	FUNCTION SQL_TO_PL19(aSqlItem OE_ORDER_PUB_LINE_SCREDIT_TBL)
	RETURN OE_ORDER_PUB.LINE_SCREDIT_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_SCREDIT_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL42(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL19;
	FUNCTION PL_TO_SQL43(aPlsqlItem OE_ORDER_PUB.LINE_SCREDIT_VAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_SCREDIT_VA6 IS
	aSqlItem OE_ORDER_PUB_LINE_SCREDIT_VA6;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_SCREDIT_VA6(NULL, NULL, NULL);
		aSqlItem.SALESREP := aPlsqlItem.SALESREP;
		aSqlItem.SALES_CREDIT_TYPE := aPlsqlItem.SALES_CREDIT_TYPE;
		aSqlItem.SALES_GROUP := aPlsqlItem.SALES_GROUP;
		RETURN aSqlItem;
	END PL_TO_SQL43;
	FUNCTION SQL_TO_PL43(aSqlItem OE_ORDER_PUB_LINE_SCREDIT_VA6)
	RETURN OE_ORDER_PUB.LINE_SCREDIT_VAL_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_SCREDIT_VAL_REC_TYPE;
	BEGIN
		aPlsqlItem.SALESREP := aSqlItem.SALESREP;
		aPlsqlItem.SALES_CREDIT_TYPE := aSqlItem.SALES_CREDIT_TYPE;
		aPlsqlItem.SALES_GROUP := aSqlItem.SALES_GROUP;
		RETURN aPlsqlItem;
	END SQL_TO_PL43;
	FUNCTION PL_TO_SQL20(aPlsqlItem OE_ORDER_PUB.LINE_SCREDIT_VAL_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_SCREDIT_VAL IS
	aSqlItem OE_ORDER_PUB_LINE_SCREDIT_VAL;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_SCREDIT_VAL();
        IF aPlsqlItem.COUNT > 0 THEN
		    aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			    aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL43(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL20;
	FUNCTION SQL_TO_PL20(aSqlItem OE_ORDER_PUB_LINE_SCREDIT_VAL)
	RETURN OE_ORDER_PUB.LINE_SCREDIT_VAL_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_SCREDIT_VAL_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL43(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL20;
	FUNCTION PL_TO_SQL44(aPlsqlItem OE_ORDER_PUB.LINE_PAYMENT_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_PAYMENT_REC IS
	aSqlItem OE_ORDER_PUB_LINE_PAYMENT_REC;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_PAYMENT_REC(NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.ATTRIBUTE1 := aPlsqlItem.ATTRIBUTE1;
		aSqlItem.ATTRIBUTE2 := aPlsqlItem.ATTRIBUTE2;
		aSqlItem.ATTRIBUTE3 := aPlsqlItem.ATTRIBUTE3;
		aSqlItem.ATTRIBUTE4 := aPlsqlItem.ATTRIBUTE4;
		aSqlItem.ATTRIBUTE5 := aPlsqlItem.ATTRIBUTE5;
		aSqlItem.ATTRIBUTE6 := aPlsqlItem.ATTRIBUTE6;
		aSqlItem.ATTRIBUTE7 := aPlsqlItem.ATTRIBUTE7;
		aSqlItem.ATTRIBUTE8 := aPlsqlItem.ATTRIBUTE8;
		aSqlItem.ATTRIBUTE9 := aPlsqlItem.ATTRIBUTE9;
		aSqlItem.ATTRIBUTE10 := aPlsqlItem.ATTRIBUTE10;
		aSqlItem.ATTRIBUTE11 := aPlsqlItem.ATTRIBUTE11;
		aSqlItem.ATTRIBUTE12 := aPlsqlItem.ATTRIBUTE12;
		aSqlItem.ATTRIBUTE13 := aPlsqlItem.ATTRIBUTE13;
		aSqlItem.ATTRIBUTE14 := aPlsqlItem.ATTRIBUTE14;
		aSqlItem.ATTRIBUTE15 := aPlsqlItem.ATTRIBUTE15;
		aSqlItem.CHECK_NUMBER := aPlsqlItem.CHECK_NUMBER;
		aSqlItem.CREATED_BY := aPlsqlItem.CREATED_BY;
		aSqlItem.CREATION_DATE := aPlsqlItem.CREATION_DATE;
		aSqlItem.CREDIT_CARD_APPROVAL_CODE := aPlsqlItem.CREDIT_CARD_APPROVAL_CODE;
		aSqlItem.CREDIT_CARD_APPROVAL_DATE := aPlsqlItem.CREDIT_CARD_APPROVAL_DATE;
		aSqlItem.CREDIT_CARD_CODE := aPlsqlItem.CREDIT_CARD_CODE;
		aSqlItem.CREDIT_CARD_EXPIRATION_DATE := aPlsqlItem.CREDIT_CARD_EXPIRATION_DATE;
		aSqlItem.CREDIT_CARD_HOLDER_NAME := aPlsqlItem.CREDIT_CARD_HOLDER_NAME;
		aSqlItem.CREDIT_CARD_NUMBER := aPlsqlItem.CREDIT_CARD_NUMBER;
		aSqlItem.COMMITMENT_APPLIED_AMOUNT := aPlsqlItem.COMMITMENT_APPLIED_AMOUNT;
		aSqlItem.COMMITMENT_INTERFACED_AMOUNT := aPlsqlItem.COMMITMENT_INTERFACED_AMOUNT;
		aSqlItem.CONTEXT := aPlsqlItem.CONTEXT;
		aSqlItem.HEADER_ID := aPlsqlItem.HEADER_ID;
		aSqlItem.LAST_UPDATED_BY := aPlsqlItem.LAST_UPDATED_BY;
		aSqlItem.LAST_UPDATE_DATE := aPlsqlItem.LAST_UPDATE_DATE;
		aSqlItem.LAST_UPDATE_LOGIN := aPlsqlItem.LAST_UPDATE_LOGIN;
		aSqlItem.LINE_ID := aPlsqlItem.LINE_ID;
		aSqlItem.PAYMENT_NUMBER := aPlsqlItem.PAYMENT_NUMBER;
		aSqlItem.PAYMENT_AMOUNT := aPlsqlItem.PAYMENT_AMOUNT;
		aSqlItem.PAYMENT_COLLECTION_EVENT := aPlsqlItem.PAYMENT_COLLECTION_EVENT;
		aSqlItem.PAYMENT_LEVEL_CODE := aPlsqlItem.PAYMENT_LEVEL_CODE;
		aSqlItem.PAYMENT_TRX_ID := aPlsqlItem.PAYMENT_TRX_ID;
		aSqlItem.PAYMENT_TYPE_CODE := aPlsqlItem.PAYMENT_TYPE_CODE;
		aSqlItem.PAYMENT_SET_ID := aPlsqlItem.PAYMENT_SET_ID;
		aSqlItem.PREPAID_AMOUNT := aPlsqlItem.PREPAID_AMOUNT;
		aSqlItem.PROGRAM_APPLICATION_ID := aPlsqlItem.PROGRAM_APPLICATION_ID;
		aSqlItem.PROGRAM_ID := aPlsqlItem.PROGRAM_ID;
		aSqlItem.PROGRAM_UPDATE_DATE := aPlsqlItem.PROGRAM_UPDATE_DATE;
		aSqlItem.RECEIPT_METHOD_ID := aPlsqlItem.RECEIPT_METHOD_ID;
		aSqlItem.REQUEST_ID := aPlsqlItem.REQUEST_ID;
		aSqlItem.TANGIBLE_ID := aPlsqlItem.TANGIBLE_ID;
		aSqlItem.ORIG_SYS_PAYMENT_REF := aPlsqlItem.ORIG_SYS_PAYMENT_REF;
		aSqlItem.CHANGE_REQUEST_CODE := aPlsqlItem.CHANGE_REQUEST_CODE;
		aSqlItem.STATUS_FLAG := aPlsqlItem.STATUS_FLAG;
		aSqlItem.RETURN_STATUS := aPlsqlItem.RETURN_STATUS;
		aSqlItem.DB_FLAG := aPlsqlItem.DB_FLAG;
		aSqlItem.LINE_INDEX := aPlsqlItem.LINE_INDEX;
		aSqlItem.OPERATION := aPlsqlItem.OPERATION;
		aSqlItem.DEFER_PAYMENT_PROCESSING_FLAG := aPlsqlItem.DEFER_PAYMENT_PROCESSING_FLAG;
		aSqlItem.LOCK_CONTROL := aPlsqlItem.LOCK_CONTROL;
		RETURN aSqlItem;
	END PL_TO_SQL44;
	FUNCTION SQL_TO_PL44(aSqlItem OE_ORDER_PUB_LINE_PAYMENT_REC)
	RETURN OE_ORDER_PUB.LINE_PAYMENT_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_PAYMENT_REC_TYPE;
	BEGIN
		aPlsqlItem.ATTRIBUTE1 := aSqlItem.ATTRIBUTE1;
		aPlsqlItem.ATTRIBUTE2 := aSqlItem.ATTRIBUTE2;
		aPlsqlItem.ATTRIBUTE3 := aSqlItem.ATTRIBUTE3;
		aPlsqlItem.ATTRIBUTE4 := aSqlItem.ATTRIBUTE4;
		aPlsqlItem.ATTRIBUTE5 := aSqlItem.ATTRIBUTE5;
		aPlsqlItem.ATTRIBUTE6 := aSqlItem.ATTRIBUTE6;
		aPlsqlItem.ATTRIBUTE7 := aSqlItem.ATTRIBUTE7;
		aPlsqlItem.ATTRIBUTE8 := aSqlItem.ATTRIBUTE8;
		aPlsqlItem.ATTRIBUTE9 := aSqlItem.ATTRIBUTE9;
		aPlsqlItem.ATTRIBUTE10 := aSqlItem.ATTRIBUTE10;
		aPlsqlItem.ATTRIBUTE11 := aSqlItem.ATTRIBUTE11;
		aPlsqlItem.ATTRIBUTE12 := aSqlItem.ATTRIBUTE12;
		aPlsqlItem.ATTRIBUTE13 := aSqlItem.ATTRIBUTE13;
		aPlsqlItem.ATTRIBUTE14 := aSqlItem.ATTRIBUTE14;
		aPlsqlItem.ATTRIBUTE15 := aSqlItem.ATTRIBUTE15;
		aPlsqlItem.CHECK_NUMBER := aSqlItem.CHECK_NUMBER;
		aPlsqlItem.CREATED_BY := aSqlItem.CREATED_BY;
		aPlsqlItem.CREATION_DATE := aSqlItem.CREATION_DATE;
		aPlsqlItem.CREDIT_CARD_APPROVAL_CODE := aSqlItem.CREDIT_CARD_APPROVAL_CODE;
		aPlsqlItem.CREDIT_CARD_APPROVAL_DATE := aSqlItem.CREDIT_CARD_APPROVAL_DATE;
		aPlsqlItem.CREDIT_CARD_CODE := aSqlItem.CREDIT_CARD_CODE;
		aPlsqlItem.CREDIT_CARD_EXPIRATION_DATE := aSqlItem.CREDIT_CARD_EXPIRATION_DATE;
		aPlsqlItem.CREDIT_CARD_HOLDER_NAME := aSqlItem.CREDIT_CARD_HOLDER_NAME;
		aPlsqlItem.CREDIT_CARD_NUMBER := aSqlItem.CREDIT_CARD_NUMBER;
		aPlsqlItem.COMMITMENT_APPLIED_AMOUNT := aSqlItem.COMMITMENT_APPLIED_AMOUNT;
		aPlsqlItem.COMMITMENT_INTERFACED_AMOUNT := aSqlItem.COMMITMENT_INTERFACED_AMOUNT;
		aPlsqlItem.CONTEXT := aSqlItem.CONTEXT;
		aPlsqlItem.HEADER_ID := aSqlItem.HEADER_ID;
		aPlsqlItem.LAST_UPDATED_BY := aSqlItem.LAST_UPDATED_BY;
		aPlsqlItem.LAST_UPDATE_DATE := aSqlItem.LAST_UPDATE_DATE;
		aPlsqlItem.LAST_UPDATE_LOGIN := aSqlItem.LAST_UPDATE_LOGIN;
		aPlsqlItem.LINE_ID := aSqlItem.LINE_ID;
		aPlsqlItem.PAYMENT_NUMBER := aSqlItem.PAYMENT_NUMBER;
		aPlsqlItem.PAYMENT_AMOUNT := aSqlItem.PAYMENT_AMOUNT;
		aPlsqlItem.PAYMENT_COLLECTION_EVENT := aSqlItem.PAYMENT_COLLECTION_EVENT;
		aPlsqlItem.PAYMENT_LEVEL_CODE := aSqlItem.PAYMENT_LEVEL_CODE;
		aPlsqlItem.PAYMENT_TRX_ID := aSqlItem.PAYMENT_TRX_ID;
		aPlsqlItem.PAYMENT_TYPE_CODE := aSqlItem.PAYMENT_TYPE_CODE;
		aPlsqlItem.PAYMENT_SET_ID := aSqlItem.PAYMENT_SET_ID;
		aPlsqlItem.PREPAID_AMOUNT := aSqlItem.PREPAID_AMOUNT;
		aPlsqlItem.PROGRAM_APPLICATION_ID := aSqlItem.PROGRAM_APPLICATION_ID;
		aPlsqlItem.PROGRAM_ID := aSqlItem.PROGRAM_ID;
		aPlsqlItem.PROGRAM_UPDATE_DATE := aSqlItem.PROGRAM_UPDATE_DATE;
		aPlsqlItem.RECEIPT_METHOD_ID := aSqlItem.RECEIPT_METHOD_ID;
		aPlsqlItem.REQUEST_ID := aSqlItem.REQUEST_ID;
		aPlsqlItem.TANGIBLE_ID := aSqlItem.TANGIBLE_ID;
		aPlsqlItem.ORIG_SYS_PAYMENT_REF := aSqlItem.ORIG_SYS_PAYMENT_REF;
		aPlsqlItem.CHANGE_REQUEST_CODE := aSqlItem.CHANGE_REQUEST_CODE;
		aPlsqlItem.STATUS_FLAG := aSqlItem.STATUS_FLAG;
		aPlsqlItem.RETURN_STATUS := aSqlItem.RETURN_STATUS;
		aPlsqlItem.DB_FLAG := aSqlItem.DB_FLAG;
		aPlsqlItem.LINE_INDEX := aSqlItem.LINE_INDEX;
		aPlsqlItem.OPERATION := aSqlItem.OPERATION;
		aPlsqlItem.DEFER_PAYMENT_PROCESSING_FLAG := aSqlItem.DEFER_PAYMENT_PROCESSING_FLAG;
		aPlsqlItem.LOCK_CONTROL := aSqlItem.LOCK_CONTROL;



		RETURN aPlsqlItem;
	END SQL_TO_PL44;
	FUNCTION PL_TO_SQL21(aPlsqlItem OE_ORDER_PUB.LINE_PAYMENT_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_PAYMENT_TBL IS
	aSqlItem OE_ORDER_PUB_LINE_PAYMENT_TBL;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_PAYMENT_TBL();
        IF aPlsqlItem.COUNT > 0 THEN
		    aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			    aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL44(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL21;
	FUNCTION SQL_TO_PL21(aSqlItem OE_ORDER_PUB_LINE_PAYMENT_TBL)
	RETURN OE_ORDER_PUB.LINE_PAYMENT_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_PAYMENT_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL44(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL21;
	FUNCTION PL_TO_SQL45(aPlsqlItem OE_ORDER_PUB.LINE_PAYMENT_VAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_LINE_PAYMENT_VA3 IS
	aSqlItem OE_ORDER_PUB_LINE_PAYMENT_VA3;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_PAYMENT_VA3(NULL, NULL, NULL, NULL, NULL);
		aSqlItem.PAYMENT_COLLECTION_EVENT_NAME := aPlsqlItem.PAYMENT_COLLECTION_EVENT_NAME;
		aSqlItem.RECEIPT_METHOD := aPlsqlItem.RECEIPT_METHOD;
		aSqlItem.PAYMENT_TYPE := aPlsqlItem.PAYMENT_TYPE;
		aSqlItem.COMMITMENT := aPlsqlItem.COMMITMENT;
		aSqlItem.PAYMENT_PERCENTAGE := aPlsqlItem.PAYMENT_PERCENTAGE;
		RETURN aSqlItem;
	END PL_TO_SQL45;
	FUNCTION SQL_TO_PL45(aSqlItem OE_ORDER_PUB_LINE_PAYMENT_VA3)
	RETURN OE_ORDER_PUB.LINE_PAYMENT_VAL_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_PAYMENT_VAL_REC_TYPE;
	BEGIN
		aPlsqlItem.PAYMENT_COLLECTION_EVENT_NAME := aSqlItem.PAYMENT_COLLECTION_EVENT_NAME;
		aPlsqlItem.RECEIPT_METHOD := aSqlItem.RECEIPT_METHOD;
		aPlsqlItem.PAYMENT_TYPE := aSqlItem.PAYMENT_TYPE;
		aPlsqlItem.COMMITMENT := aSqlItem.COMMITMENT;
		aPlsqlItem.PAYMENT_PERCENTAGE := aSqlItem.PAYMENT_PERCENTAGE;
		RETURN aPlsqlItem;
	END SQL_TO_PL45;
	FUNCTION PL_TO_SQL22(aPlsqlItem OE_ORDER_PUB.LINE_PAYMENT_VAL_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LINE_PAYMENT_VAL IS
	aSqlItem OE_ORDER_PUB_LINE_PAYMENT_VAL;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LINE_PAYMENT_VAL();
        IF aPlsqlItem.COUNT > 0 THEN
		    aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			    aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL45(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL22;
	FUNCTION SQL_TO_PL22(aSqlItem OE_ORDER_PUB_LINE_PAYMENT_VAL)
	RETURN OE_ORDER_PUB.LINE_PAYMENT_VAL_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LINE_PAYMENT_VAL_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL45(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL22;
	FUNCTION PL_TO_SQL46(aPlsqlItem OE_ORDER_PUB.LOT_SERIAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_LOT_SERIAL_REC_T IS
	aSqlItem OE_ORDER_PUB_LOT_SERIAL_REC_T;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LOT_SERIAL_REC_T(NULL, NULL, NULL, NULL, NULL, NULL,
                 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                 NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.ATTRIBUTE1 := aPlsqlItem.ATTRIBUTE1;
		aSqlItem.ATTRIBUTE10 := aPlsqlItem.ATTRIBUTE10;
		aSqlItem.ATTRIBUTE11 := aPlsqlItem.ATTRIBUTE11;
		aSqlItem.ATTRIBUTE12 := aPlsqlItem.ATTRIBUTE12;
		aSqlItem.ATTRIBUTE13 := aPlsqlItem.ATTRIBUTE13;
		aSqlItem.ATTRIBUTE14 := aPlsqlItem.ATTRIBUTE14;
		aSqlItem.ATTRIBUTE15 := aPlsqlItem.ATTRIBUTE15;
		aSqlItem.ATTRIBUTE2 := aPlsqlItem.ATTRIBUTE2;
		aSqlItem.ATTRIBUTE3 := aPlsqlItem.ATTRIBUTE3;
		aSqlItem.ATTRIBUTE4 := aPlsqlItem.ATTRIBUTE4;
		aSqlItem.ATTRIBUTE5 := aPlsqlItem.ATTRIBUTE5;
		aSqlItem.ATTRIBUTE6 := aPlsqlItem.ATTRIBUTE6;
		aSqlItem.ATTRIBUTE7 := aPlsqlItem.ATTRIBUTE7;
		aSqlItem.ATTRIBUTE8 := aPlsqlItem.ATTRIBUTE8;
		aSqlItem.ATTRIBUTE9 := aPlsqlItem.ATTRIBUTE9;
		aSqlItem.CONTEXT := aPlsqlItem.CONTEXT;
		aSqlItem.CREATED_BY := aPlsqlItem.CREATED_BY;
		aSqlItem.CREATION_DATE := aPlsqlItem.CREATION_DATE;
		aSqlItem.FROM_SERIAL_NUMBER := aPlsqlItem.FROM_SERIAL_NUMBER;
		aSqlItem.LAST_UPDATED_BY := aPlsqlItem.LAST_UPDATED_BY;
		aSqlItem.LAST_UPDATE_DATE := aPlsqlItem.LAST_UPDATE_DATE;
		aSqlItem.LAST_UPDATE_LOGIN := aPlsqlItem.LAST_UPDATE_LOGIN;
		aSqlItem.LINE_ID := aPlsqlItem.LINE_ID;
		aSqlItem.LOT_NUMBER := aPlsqlItem.LOT_NUMBER;
		aSqlItem.SUBLOT_NUMBER := aPlsqlItem.SUBLOT_NUMBER;
		aSqlItem.LOT_SERIAL_ID := aPlsqlItem.LOT_SERIAL_ID;
		aSqlItem.QUANTITY := aPlsqlItem.QUANTITY;
		aSqlItem.QUANTITY2 := aPlsqlItem.QUANTITY2;
		aSqlItem.TO_SERIAL_NUMBER := aPlsqlItem.TO_SERIAL_NUMBER;
		aSqlItem.RETURN_STATUS := aPlsqlItem.RETURN_STATUS;
		aSqlItem.DB_FLAG := aPlsqlItem.DB_FLAG;
		aSqlItem.OPERATION := aPlsqlItem.OPERATION;
		aSqlItem.LINE_INDEX := aPlsqlItem.LINE_INDEX;
		aSqlItem.ORIG_SYS_LOTSERIAL_REF := aPlsqlItem.ORIG_SYS_LOTSERIAL_REF;
		aSqlItem.CHANGE_REQUEST_CODE := aPlsqlItem.CHANGE_REQUEST_CODE;
		aSqlItem.STATUS_FLAG := aPlsqlItem.STATUS_FLAG;
		aSqlItem.LINE_SET_ID := aPlsqlItem.LINE_SET_ID;
		aSqlItem.LOCK_CONTROL := aPlsqlItem.LOCK_CONTROL;
		RETURN aSqlItem;
	END PL_TO_SQL46;
	FUNCTION SQL_TO_PL46(aSqlItem OE_ORDER_PUB_LOT_SERIAL_REC_T)
	RETURN OE_ORDER_PUB.LOT_SERIAL_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LOT_SERIAL_REC_TYPE;
	BEGIN
		aPlsqlItem.ATTRIBUTE1 := aSqlItem.ATTRIBUTE1;
		aPlsqlItem.ATTRIBUTE10 := aSqlItem.ATTRIBUTE10;
		aPlsqlItem.ATTRIBUTE11 := aSqlItem.ATTRIBUTE11;
		aPlsqlItem.ATTRIBUTE12 := aSqlItem.ATTRIBUTE12;
		aPlsqlItem.ATTRIBUTE13 := aSqlItem.ATTRIBUTE13;
		aPlsqlItem.ATTRIBUTE14 := aSqlItem.ATTRIBUTE14;
		aPlsqlItem.ATTRIBUTE15 := aSqlItem.ATTRIBUTE15;
		aPlsqlItem.ATTRIBUTE2 := aSqlItem.ATTRIBUTE2;
		aPlsqlItem.ATTRIBUTE3 := aSqlItem.ATTRIBUTE3;
		aPlsqlItem.ATTRIBUTE4 := aSqlItem.ATTRIBUTE4;
		aPlsqlItem.ATTRIBUTE5 := aSqlItem.ATTRIBUTE5;
		aPlsqlItem.ATTRIBUTE6 := aSqlItem.ATTRIBUTE6;
		aPlsqlItem.ATTRIBUTE7 := aSqlItem.ATTRIBUTE7;
		aPlsqlItem.ATTRIBUTE8 := aSqlItem.ATTRIBUTE8;
		aPlsqlItem.ATTRIBUTE9 := aSqlItem.ATTRIBUTE9;
		aPlsqlItem.CONTEXT := aSqlItem.CONTEXT;
		aPlsqlItem.CREATED_BY := aSqlItem.CREATED_BY;
		aPlsqlItem.CREATION_DATE := aSqlItem.CREATION_DATE;
		aPlsqlItem.FROM_SERIAL_NUMBER := aSqlItem.FROM_SERIAL_NUMBER;
		aPlsqlItem.LAST_UPDATED_BY := aSqlItem.LAST_UPDATED_BY;
		aPlsqlItem.LAST_UPDATE_DATE := aSqlItem.LAST_UPDATE_DATE;
		aPlsqlItem.LAST_UPDATE_LOGIN := aSqlItem.LAST_UPDATE_LOGIN;
		aPlsqlItem.LINE_ID := aSqlItem.LINE_ID;
		aPlsqlItem.LOT_NUMBER := aSqlItem.LOT_NUMBER;
		aPlsqlItem.SUBLOT_NUMBER := aSqlItem.SUBLOT_NUMBER;
		aPlsqlItem.LOT_SERIAL_ID := aSqlItem.LOT_SERIAL_ID;
		aPlsqlItem.QUANTITY := aSqlItem.QUANTITY;
		aPlsqlItem.QUANTITY2 := aSqlItem.QUANTITY2;
		aPlsqlItem.TO_SERIAL_NUMBER := aSqlItem.TO_SERIAL_NUMBER;
		aPlsqlItem.RETURN_STATUS := aSqlItem.RETURN_STATUS;
		aPlsqlItem.DB_FLAG := aSqlItem.DB_FLAG;
		aPlsqlItem.OPERATION := aSqlItem.OPERATION;
		aPlsqlItem.LINE_INDEX := aSqlItem.LINE_INDEX;
		aPlsqlItem.ORIG_SYS_LOTSERIAL_REF := aSqlItem.ORIG_SYS_LOTSERIAL_REF;
		aPlsqlItem.CHANGE_REQUEST_CODE := aSqlItem.CHANGE_REQUEST_CODE;
		aPlsqlItem.STATUS_FLAG := aSqlItem.STATUS_FLAG;
		aPlsqlItem.LINE_SET_ID := aSqlItem.LINE_SET_ID;
		aPlsqlItem.LOCK_CONTROL := aSqlItem.LOCK_CONTROL;
		RETURN aPlsqlItem;
	END SQL_TO_PL46;
	FUNCTION PL_TO_SQL23(aPlsqlItem OE_ORDER_PUB.LOT_SERIAL_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LOT_SERIAL_TBL_T IS
	aSqlItem OE_ORDER_PUB_LOT_SERIAL_TBL_T;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LOT_SERIAL_TBL_T();
        IF aPlsqlItem.COUNT > 0 THEN
		    aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			    aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL46(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL23;
	FUNCTION SQL_TO_PL23(aSqlItem OE_ORDER_PUB_LOT_SERIAL_TBL_T)
	RETURN OE_ORDER_PUB.LOT_SERIAL_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LOT_SERIAL_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL46(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL23;
	FUNCTION PL_TO_SQL47(aPlsqlItem OE_ORDER_PUB.LOT_SERIAL_VAL_REC_TYPE)
 	RETURN OE_ORDER_PUB_LOT_SERIAL_VAL_R IS
	aSqlItem OE_ORDER_PUB_LOT_SERIAL_VAL_R;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LOT_SERIAL_VAL_R(NULL, NULL);
		aSqlItem.LINE := aPlsqlItem.LINE;
		aSqlItem.LOT_SERIAL := aPlsqlItem.LOT_SERIAL;
		RETURN aSqlItem;
	END PL_TO_SQL47;
	FUNCTION SQL_TO_PL47(aSqlItem OE_ORDER_PUB_LOT_SERIAL_VAL_R)
	RETURN OE_ORDER_PUB.LOT_SERIAL_VAL_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LOT_SERIAL_VAL_REC_TYPE;
	BEGIN
		aPlsqlItem.LINE := aSqlItem.LINE;
		aPlsqlItem.LOT_SERIAL := aSqlItem.LOT_SERIAL;
		RETURN aPlsqlItem;
	END SQL_TO_PL47;
	FUNCTION PL_TO_SQL24(aPlsqlItem OE_ORDER_PUB.LOT_SERIAL_VAL_TBL_TYPE)
 	RETURN OE_ORDER_PUB_LOT_SERIAL_VAL_T IS
	aSqlItem OE_ORDER_PUB_LOT_SERIAL_VAL_T;
	BEGIN
		aSqlItem := OE_ORDER_PUB_LOT_SERIAL_VAL_T();
        IF aPlsqlItem.COUNT > 0  THEN
		    aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
			    aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL47(aPlsqlItem(I));
		    END LOOP;
        END IF;
		RETURN aSqlItem;
	END PL_TO_SQL24;
	FUNCTION SQL_TO_PL24(aSqlItem OE_ORDER_PUB_LOT_SERIAL_VAL_T)
	RETURN OE_ORDER_PUB.LOT_SERIAL_VAL_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.LOT_SERIAL_VAL_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL47(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
		RETURN aPlsqlItem;
	END SQL_TO_PL24;
	FUNCTION PL_TO_SQL48(aPlsqlItem OE_ORDER_PUB.REQUEST_REC_TYPE)
 	RETURN OE_ORDER_PUB_REQUEST_REC_TYPE IS
	aSqlItem OE_ORDER_PUB_REQUEST_REC_TYPE;
	BEGIN
		aSqlItem := OE_ORDER_PUB_REQUEST_REC_TYPE(NULL, NULL, NULL, NULL, NULL, NULL,
                 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
		aSqlItem.ENTITY_CODE := aPlsqlItem.ENTITY_CODE;
		aSqlItem.ENTITY_ID := aPlsqlItem.ENTITY_ID;
		aSqlItem.ENTITY_INDEX := aPlsqlItem.ENTITY_INDEX;
		aSqlItem.REQUEST_TYPE := aPlsqlItem.REQUEST_TYPE;
		aSqlItem.RETURN_STATUS := aPlsqlItem.RETURN_STATUS;
		aSqlItem.REQUEST_UNIQUE_KEY1 := aPlsqlItem.REQUEST_UNIQUE_KEY1;
		aSqlItem.REQUEST_UNIQUE_KEY2 := aPlsqlItem.REQUEST_UNIQUE_KEY2;
		aSqlItem.REQUEST_UNIQUE_KEY3 := aPlsqlItem.REQUEST_UNIQUE_KEY3;
		aSqlItem.REQUEST_UNIQUE_KEY4 := aPlsqlItem.REQUEST_UNIQUE_KEY4;
		aSqlItem.REQUEST_UNIQUE_KEY5 := aPlsqlItem.REQUEST_UNIQUE_KEY5;
		aSqlItem.PARAM1 := aPlsqlItem.PARAM1;
		aSqlItem.PARAM2 := aPlsqlItem.PARAM2;
		aSqlItem.PARAM3 := aPlsqlItem.PARAM3;
		aSqlItem.PARAM4 := aPlsqlItem.PARAM4;
		aSqlItem.PARAM5 := aPlsqlItem.PARAM5;
		aSqlItem.PARAM6 := aPlsqlItem.PARAM6;
		aSqlItem.PARAM7 := aPlsqlItem.PARAM7;
		aSqlItem.PARAM8 := aPlsqlItem.PARAM8;
		aSqlItem.PARAM9 := aPlsqlItem.PARAM9;
		aSqlItem.PARAM10 := aPlsqlItem.PARAM10;
		aSqlItem.PARAM11 := aPlsqlItem.PARAM11;
		aSqlItem.PARAM12 := aPlsqlItem.PARAM12;
		aSqlItem.PARAM13 := aPlsqlItem.PARAM13;
		aSqlItem.PARAM14 := aPlsqlItem.PARAM14;
		aSqlItem.PARAM15 := aPlsqlItem.PARAM15;
		aSqlItem.PARAM16 := aPlsqlItem.PARAM16;
		aSqlItem.PARAM17 := aPlsqlItem.PARAM17;
		aSqlItem.PARAM18 := aPlsqlItem.PARAM18;
		aSqlItem.PARAM19 := aPlsqlItem.PARAM19;
		aSqlItem.PARAM20 := aPlsqlItem.PARAM20;
		aSqlItem.PARAM21 := aPlsqlItem.PARAM21;
		aSqlItem.PARAM22 := aPlsqlItem.PARAM22;
		aSqlItem.PARAM23 := aPlsqlItem.PARAM23;
		aSqlItem.PARAM24 := aPlsqlItem.PARAM24;
		aSqlItem.PARAM25 := aPlsqlItem.PARAM25;
		aSqlItem.LONG_PARAM1 := aPlsqlItem.LONG_PARAM1;
		aSqlItem.DATE_PARAM1 := aPlsqlItem.DATE_PARAM1;
		aSqlItem.DATE_PARAM2 := aPlsqlItem.DATE_PARAM2;
		aSqlItem.DATE_PARAM3 := aPlsqlItem.DATE_PARAM3;
		aSqlItem.DATE_PARAM4 := aPlsqlItem.DATE_PARAM4;
		aSqlItem.DATE_PARAM5 := aPlsqlItem.DATE_PARAM5;
		aSqlItem.DATE_PARAM6 := aPlsqlItem.DATE_PARAM6;
		aSqlItem.DATE_PARAM7 := aPlsqlItem.DATE_PARAM7;
		aSqlItem.DATE_PARAM8 := aPlsqlItem.DATE_PARAM8;
		aSqlItem.PROCESSED := aPlsqlItem.PROCESSED;
		RETURN aSqlItem;
	END PL_TO_SQL48;
	FUNCTION SQL_TO_PL48(aSqlItem OE_ORDER_PUB_REQUEST_REC_TYPE)
	RETURN OE_ORDER_PUB.REQUEST_REC_TYPE IS
	aPlsqlItem OE_ORDER_PUB.REQUEST_REC_TYPE;
	BEGIN
		aPlsqlItem.ENTITY_CODE := aSqlItem.ENTITY_CODE;
		aPlsqlItem.ENTITY_ID := aSqlItem.ENTITY_ID;
		aPlsqlItem.ENTITY_INDEX := aSqlItem.ENTITY_INDEX;
		aPlsqlItem.REQUEST_TYPE := aSqlItem.REQUEST_TYPE;
		aPlsqlItem.RETURN_STATUS := aSqlItem.RETURN_STATUS;
		aPlsqlItem.REQUEST_UNIQUE_KEY1 := aSqlItem.REQUEST_UNIQUE_KEY1;
		aPlsqlItem.REQUEST_UNIQUE_KEY2 := aSqlItem.REQUEST_UNIQUE_KEY2;
		aPlsqlItem.REQUEST_UNIQUE_KEY3 := aSqlItem.REQUEST_UNIQUE_KEY3;
		aPlsqlItem.REQUEST_UNIQUE_KEY4 := aSqlItem.REQUEST_UNIQUE_KEY4;
		aPlsqlItem.REQUEST_UNIQUE_KEY5 := aSqlItem.REQUEST_UNIQUE_KEY5;
		aPlsqlItem.PARAM1 := aSqlItem.PARAM1;
		aPlsqlItem.PARAM2 := aSqlItem.PARAM2;
		aPlsqlItem.PARAM3 := aSqlItem.PARAM3;
		aPlsqlItem.PARAM4 := aSqlItem.PARAM4;
		aPlsqlItem.PARAM5 := aSqlItem.PARAM5;
		aPlsqlItem.PARAM6 := aSqlItem.PARAM6;
		aPlsqlItem.PARAM7 := aSqlItem.PARAM7;
		aPlsqlItem.PARAM8 := aSqlItem.PARAM8;
		aPlsqlItem.PARAM9 := aSqlItem.PARAM9;
		aPlsqlItem.PARAM10 := aSqlItem.PARAM10;
		aPlsqlItem.PARAM11 := aSqlItem.PARAM11;
		aPlsqlItem.PARAM12 := aSqlItem.PARAM12;
		aPlsqlItem.PARAM13 := aSqlItem.PARAM13;
		aPlsqlItem.PARAM14 := aSqlItem.PARAM14;
		aPlsqlItem.PARAM15 := aSqlItem.PARAM15;
		aPlsqlItem.PARAM16 := aSqlItem.PARAM16;
		aPlsqlItem.PARAM17 := aSqlItem.PARAM17;
		aPlsqlItem.PARAM18 := aSqlItem.PARAM18;
		aPlsqlItem.PARAM19 := aSqlItem.PARAM19;
		aPlsqlItem.PARAM20 := aSqlItem.PARAM20;
		aPlsqlItem.PARAM21 := aSqlItem.PARAM21;
		aPlsqlItem.PARAM22 := aSqlItem.PARAM22;
		aPlsqlItem.PARAM23 := aSqlItem.PARAM23;
		aPlsqlItem.PARAM24 := aSqlItem.PARAM24;
		aPlsqlItem.PARAM25 := aSqlItem.PARAM25;
		aPlsqlItem.LONG_PARAM1 := aSqlItem.LONG_PARAM1;
		aPlsqlItem.DATE_PARAM1 := aSqlItem.DATE_PARAM1;
		aPlsqlItem.DATE_PARAM2 := aSqlItem.DATE_PARAM2;
		aPlsqlItem.DATE_PARAM3 := aSqlItem.DATE_PARAM3;
		aPlsqlItem.DATE_PARAM4 := aSqlItem.DATE_PARAM4;
		aPlsqlItem.DATE_PARAM5 := aSqlItem.DATE_PARAM5;
		aPlsqlItem.DATE_PARAM6 := aSqlItem.DATE_PARAM6;
		aPlsqlItem.DATE_PARAM7 := aSqlItem.DATE_PARAM7;
		aPlsqlItem.DATE_PARAM8 := aSqlItem.DATE_PARAM8;
		aPlsqlItem.PROCESSED := aSqlItem.PROCESSED;
		RETURN aPlsqlItem;
	END SQL_TO_PL48;
	FUNCTION PL_TO_SQL25(aPlsqlItem OE_ORDER_PUB.REQUEST_TBL_TYPE)
 	RETURN OE_ORDER_PUB_REQUEST_TBL_TYPE IS
	aSqlItem OE_ORDER_PUB_REQUEST_TBL_TYPE;
	BEGIN
		aSqlItem := OE_ORDER_PUB_REQUEST_TBL_TYPE();
        IF aPlsqlItem.COUNT > 0 THEN
		    aSqlItem.EXTEND(aPlsqlItem.COUNT);
		    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST LOOP
		      aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL48(aPlsqlItem(I));
              -- Oe_Inbound_Int.G_check_action_ret_status :=
              --        aSqlItem(1).return_status;
              -- oe_debug_pub.add('Srini psu '
              --        ||Oe_Inbound_Int.G_check_action_ret_status);
		    END LOOP;
        end if;
		RETURN aSqlItem;
	END PL_TO_SQL25;

	FUNCTION SQL_TO_PL25(aSqlItem OE_ORDER_PUB_REQUEST_TBL_TYPE)
	RETURN OE_ORDER_PUB.REQUEST_TBL_TYPE IS
	aPlsqlItem OE_ORDER_PUB.REQUEST_TBL_TYPE;
	BEGIN
        BEGIN
		FOR I IN 1..aSqlItem.COUNT LOOP
			aPlsqlItem(I) := SQL_TO_PL48(aSqlItem(I));
		END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;

        --
        -- Commented these as a part of ER 7025965
        --
        -- aPlsqlItem(1).entity_code := OE_GLOBALS.G_ENTITY_HEADER;
        -- aPlsqlItem(1).request_type := OE_GLOBALS.G_BOOK_ORDER;

		RETURN aPlsqlItem;
	END SQL_TO_PL25;

------------------------------
-- For O2C25
  --
  -- O2C25
  --
  --  Process_Order_25(...) specifically created to perform Process Order
  --  operations in O2C25 code line.
  --
  ----------
    PROCEDURE Process_Order_25 (
          P_API_VERSION_NUMBER          NUMBER,
          P_INIT_MSG_LIST               VARCHAR2,
          P_RETURN_VALUES               VARCHAR2,
          P_ACTION_COMMIT               VARCHAR2,
          X_RETURN_STATUS           OUT NOCOPY VARCHAR2 ,
          X_MESSAGES                OUT NOCOPY OE_MESSAGE_OBJ_T,
          P_HEADER_REC                  OE_ORDER_PUB_HEADER_REC_TYPE,
          P_OLD_HEADER_REC              OE_ORDER_PUB_HEADER_REC_TYPE,
          P_HEADER_VAL_REC              OE_ORDER_PUB_HEADER_VAL_REC_T,
          P_OLD_HEADER_VAL_REC          OE_ORDER_PUB_HEADER_VAL_REC_T,
          P_HEADER_ADJ_TBL              OE_ORDER_PUB_HEADER_ADJ_TBL_T,
          P_OLD_HEADER_ADJ_TBL          OE_ORDER_PUB_HEADER_ADJ_TBL_T,
          P_HEADER_ADJ_VAL_TBL          OE_ORDER_PUB_HEADER_ADJ_VAL_T,
          P_OLD_HEADER_ADJ_VAL_TBL      OE_ORDER_PUB_HEADER_ADJ_VAL_T,
          P_HEADER_PRICE_ATT_TBL        OE_ORDER_PUB_HEADER_PRICE_ATT,
          P_OLD_HEADER_PRICE_ATT_TBL    OE_ORDER_PUB_HEADER_PRICE_ATT,
          P_HEADER_ADJ_ATT_TBL          OE_ORDER_PUB_HEADER_ADJ_ATT_T,
          P_OLD_HEADER_ADJ_ATT_TBL      OE_ORDER_PUB_HEADER_ADJ_ATT_T,
          P_HEADER_ADJ_ASSOC_TBL        OE_ORDER_PUB_HEADER_ADJ_ASSOC,
          P_OLD_HEADER_ADJ_ASSOC_TBL    OE_ORDER_PUB_HEADER_ADJ_ASSOC,
          P_HEADER_SCREDIT_TBL          OE_ORDER_PUB_HEADER_SCREDIT_T,
          P_OLD_HEADER_SCREDIT_TBL      OE_ORDER_PUB_HEADER_SCREDIT_T,
          P_HEADER_SCREDIT_VAL_TBL      OE_ORDER_PUB_HEADER_SCREDIT_V,
          P_OLD_HEADER_SCREDIT_VAL_TBL  OE_ORDER_PUB_HEADER_SCREDIT_V,
          P_HEADER_PAYMENT_TBL          OE_ORDER_PUB_HEADER_PAYMENT_T,
          P_OLD_HEADER_PAYMENT_TBL      OE_ORDER_PUB_HEADER_PAYMENT_T,
          P_HEADER_PAYMENT_VAL_TBL      OE_ORDER_PUB_HEADER_PAYMENT_V,
          P_OLD_HEADER_PAYMENT_VAL_TBL  OE_ORDER_PUB_HEADER_PAYMENT_V,
          P_LINE_TBL                    OE_ORDER_PUB_LINE_TBL_TYPE,
          P_OLD_LINE_TBL                OE_ORDER_PUB_LINE_TBL_TYPE,
          P_LINE_VAL_TBL                OE_ORDER_PUB_LINE_VAL_TBL_TYP,
          P_OLD_LINE_VAL_TBL            OE_ORDER_PUB_LINE_VAL_TBL_TYP,
          P_LINE_ADJ_TBL                OE_ORDER_PUB_LINE_ADJ_TBL_TYP,
          P_OLD_LINE_ADJ_TBL            OE_ORDER_PUB_LINE_ADJ_TBL_TYP,
          P_LINE_ADJ_VAL_TBL            OE_ORDER_PUB_LINE_ADJ_VAL_TBL,
          P_OLD_LINE_ADJ_VAL_TBL        OE_ORDER_PUB_LINE_ADJ_VAL_TBL,
          P_LINE_PRICE_ATT_TBL          OE_ORDER_PUB_LINE_PRICE_ATT_T,
          P_OLD_LINE_PRICE_ATT_TBL      OE_ORDER_PUB_LINE_PRICE_ATT_T,
          P_LINE_ADJ_ATT_TBL            OE_ORDER_PUB_LINE_ADJ_ATT_TBL,
          P_OLD_LINE_ADJ_ATT_TBL        OE_ORDER_PUB_LINE_ADJ_ATT_TBL,
          P_LINE_ADJ_ASSOC_TBL          OE_ORDER_PUB_LINE_ADJ_ASSOC_T,
          P_OLD_LINE_ADJ_ASSOC_TBL      OE_ORDER_PUB_LINE_ADJ_ASSOC_T,
          P_LINE_SCREDIT_TBL            OE_ORDER_PUB_LINE_SCREDIT_TBL,
          P_OLD_LINE_SCREDIT_TBL        OE_ORDER_PUB_LINE_SCREDIT_TBL,
          P_LINE_SCREDIT_VAL_TBL        OE_ORDER_PUB_LINE_SCREDIT_VAL,
          P_OLD_LINE_SCREDIT_VAL_TBL    OE_ORDER_PUB_LINE_SCREDIT_VAL,
          P_LINE_PAYMENT_TBL            OE_ORDER_PUB_LINE_PAYMENT_TBL,
          P_OLD_LINE_PAYMENT_TBL        OE_ORDER_PUB_LINE_PAYMENT_TBL,
          P_LINE_PAYMENT_VAL_TBL        OE_ORDER_PUB_LINE_PAYMENT_VAL,
          P_OLD_LINE_PAYMENT_VAL_TBL    OE_ORDER_PUB_LINE_PAYMENT_VAL,
          P_LOT_SERIAL_TBL              OE_ORDER_PUB_LOT_SERIAL_TBL_T,
          P_OLD_LOT_SERIAL_TBL          OE_ORDER_PUB_LOT_SERIAL_TBL_T,
          P_LOT_SERIAL_VAL_TBL          OE_ORDER_PUB_LOT_SERIAL_VAL_T,
          P_OLD_LOT_SERIAL_VAL_TBL      OE_ORDER_PUB_LOT_SERIAL_VAL_T,
          P_ACTION_REQUEST_TBL          OE_ORDER_PUB_REQUEST_TBL_TYPE,
          X_HEADER_REC              OUT NOCOPY    OE_ORDER_PUB_HDR_REC25,
          X_HEADER_VAL_REC          OUT NOCOPY    OE_ORDER_PUB_HEADER_VAL_REC_T,
          X_HEADER_ADJ_TBL          OUT NOCOPY    OE_ORDER_PUB_HEADER_ADJ_TBL_T,
          X_HEADER_ADJ_VAL_TBL      OUT NOCOPY    OE_ORDER_PUB_HEADER_ADJ_VAL_T,
          X_HEADER_PRICE_ATT_TBL    OUT NOCOPY    OE_ORDER_PUB_HEADER_PRICE_ATT,
          X_HEADER_ADJ_ATT_TBL      OUT NOCOPY    OE_ORDER_PUB_HEADER_ADJ_ATT_T,
          X_HEADER_ADJ_ASSOC_TBL    OUT NOCOPY    OE_ORDER_PUB_HEADER_ADJ_ASSOC,
          X_HEADER_SCREDIT_TBL      OUT NOCOPY    OE_ORDER_PUB_HEADER_SCREDIT_T,
          X_HEADER_SCREDIT_VAL_TBL  OUT NOCOPY    OE_ORDER_PUB_HEADER_SCREDIT_V,
          X_HEADER_PAYMENT_TBL      OUT NOCOPY    OE_ORDER_PUB_HEADER_PAYMENT_T,
          X_HEADER_PAYMENT_VAL_TBL  OUT NOCOPY    OE_ORDER_PUB_HEADER_PAYMENT_V,
          X_LINE_TBL                OUT NOCOPY    OE_ORDER_PUB_LINE_TAB25,
          X_LINE_VAL_TBL            OUT NOCOPY    OE_ORDER_PUB_LINE_VAL_TBL_TYP,
          X_LINE_ADJ_TBL            OUT NOCOPY    OE_ORDER_PUB_LINE_ADJ_TBL_TYP ,
          X_LINE_ADJ_VAL_TBL        OUT NOCOPY    OE_ORDER_PUB_LINE_ADJ_VAL_TBL,
          X_LINE_PRICE_ATT_TBL      OUT NOCOPY    OE_ORDER_PUB_LINE_PRICE_ATT_T,
          X_LINE_ADJ_ATT_TBL        OUT NOCOPY    OE_ORDER_PUB_LINE_ADJ_ATT_TBL,
          X_LINE_ADJ_ASSOC_TBL      OUT NOCOPY    OE_ORDER_PUB_LINE_ADJ_ASSOC_T,
          X_LINE_SCREDIT_TBL        OUT NOCOPY    OE_ORDER_PUB_LINE_SCREDIT_TBL,
          X_LINE_SCREDIT_VAL_TBL    OUT NOCOPY    OE_ORDER_PUB_LINE_SCREDIT_VAL,
          X_LINE_PAYMENT_TBL        OUT NOCOPY    OE_ORDER_PUB_LINE_PAYMENT_TBL,
          X_LINE_PAYMENT_VAL_TBL    OUT NOCOPY    OE_ORDER_PUB_LINE_PAYMENT_VAL,
          X_LOT_SERIAL_TBL          OUT NOCOPY    OE_ORDER_PUB_LOT_SERIAL_TBL_T,
          X_LOT_SERIAL_VAL_TBL      OUT NOCOPY    OE_ORDER_PUB_LOT_SERIAL_VAL_T ,
          X_ACTION_REQUEST_TBL      OUT NOCOPY    OE_ORDER_PUB_REQUEST_TBL_TYPE,
          P_RTRIM_DATA                            VARCHAR2
        )
  IS
    l_header_rec_old      OE_ORDER_PUB_HEADER_REC_TYPE;
    l_line_tab_old        OE_ORDER_PUB_LINE_TBL_TYPE;

    l_in_line_tab         OE_ORDER_PUB_LINE_TBL_TYPE;
    l_in_line_val_tab     OE_ORDER_PUB_LINE_VAL_TBL_TYP;

    TYPE config_process_rec_type IS RECORD (
      line_id             oe_order_lines_all.line_id%TYPE,
      config_header_id    oe_order_lines_all.config_header_id%TYPE,
      inventory_item_id   oe_order_lines_all.inventory_item_id%TYPE,
      ordered_quantity    oe_order_lines_all.ordered_quantity%TYPE,
      unit_selling_price  oe_order_lines_all.unit_selling_price%TYPE,
      unit_list_price     oe_order_lines_all.unit_list_price%TYPE
    );

    TYPE config_process_tab_type IS TABLE OF config_process_rec_type
                                INDEX BY PLS_INTEGER;

    l_config_process_rec    config_process_rec_type;
    o_config_process_rec    config_process_rec_type;

    l_config_process_tab    config_process_tab_type;

    -- Bug 9019601
    l_ret_stat              VARCHAR2(1) :=  Fnd_Api.G_RET_STS_SUCCESS;

    -- Bug 9131751
    l_amm_ret_stat          VARCHAR2(1) :=  Fnd_Api.G_RET_STS_SUCCESS;
    l_line_adj_tbl          Oe_Order_Pub_Line_Adj_Tbl_Typ;
    l_debug_level  CONSTANT NUMBER := oe_debug_pub.g_debug_level;

  BEGIN
    --  Pre-Processing specific to O2C25

    --  Pre-Processing specific to O2C25 (for configuration items)
    --  If it is a model line and if the mode is UPDATE, just pass only the
    --  model line.  Nothing else.
    --
    l_in_line_tab         :=  Oe_Order_Pub_Line_Tbl_Type();
    l_in_line_val_tab     :=  Oe_Order_Pub_Line_Val_Tbl_Typ();

    DECLARE
      l_line_reco       OE_ORDER_PUB_LINE_REC_TYPE;
      l_line_val_reco   OE_ORDER_PUB_LINE_VAL_REC_TYP;
      l_count           NUMBER  := 0;
    BEGIN
      FOR i IN p_line_tbl.first..p_line_tbl.last
      LOOP
        -- Identify the line record to be passed to process_order(...) API.
        IF p_line_tbl(i).operation IN (oe_globals.g_opr_update) THEN
          -- For update operation, ignore the config/option/class items lines.
          -- Whether a line is the top model line or not, is indicated by
          -- the top_model_line_ref being the same as orig_sys_line_ref in
          -- incoming AIA payload.  This holds good even for nested models
          -- as well.
          IF p_line_tbl(i).top_model_line_ref =
                p_line_tbl(i).orig_sys_line_ref  THEN
             -- This is the top model line.
             l_line_reco     :=  p_line_tbl(i);
             l_line_val_reco :=  p_line_val_tbl(i);
          ELSIF p_line_tbl(i).top_model_line_ref IS NOT NULL AND
                p_line_tbl(i).top_model_line_ref <> p_line_tbl(i).orig_sys_line_ref
            THEN
             -- To take care of children under the configuration hierarchy.
             -- These are not populated into the 'input' of Process_Order(...).
             -- A snapshot with attributes of interest in configuration
             -- children lines (for AIA purposes) is made (into
             -- l_config_process_tab) for a lookup in post-processing
             -- phase.
             l_count :=  l_count + 1;
             l_config_process_rec.line_id            :=  p_line_tbl(i).line_id;
             l_config_process_rec.config_header_id   :=  p_line_tbl(i).config_header_id;
             l_config_process_rec.inventory_item_id  :=  p_line_tbl(i).inventory_item_id;
             l_config_process_rec.ordered_quantity   :=  p_line_tbl(i).ordered_quantity;
             l_config_process_rec.unit_selling_price :=  p_line_tbl(i).unit_selling_price;
             l_config_process_rec.unit_list_price    :=  p_line_tbl(i).unit_list_price;

             l_config_process_tab(l_count)           :=  l_config_process_rec;
             l_config_process_rec  :=  NULL;
          ELSE
            -- To take care of standard item lines for UPDATE operation.
            IF p_line_tbl(i).top_model_line_ref IS NULL THEN
              l_line_reco      := p_line_tbl(i);
              l_line_val_reco  := p_line_val_tbl(i);
            END IF;
          END IF;
        ELSE
          -- For all other operations, pass all the contents of p_line_tab to
          -- process_order(...) API.
          l_line_reco      :=  p_line_tbl(i);
          l_line_val_reco  :=  p_line_val_tbl(i);
        END IF; -- Check on OPERATION on the line record.

        -- Put the line record in the table, provided it is non-null.
        IF l_line_reco.orig_sys_line_ref IS NOT NULL THEN
          l_in_line_tab.extend;
          l_in_line_val_tab.extend;
          l_in_line_tab(i + 1 - p_line_tbl.first)     := l_line_reco;
          l_in_line_val_tab(i + 1 - p_line_tbl.first) := l_line_val_reco;
          l_line_reco  :=  NULL;
        END IF;
      END LOOP;
    EXCEPTION
      WHEN Others THEN
        oe_debug_pub.ADD('Error at location PRE-PROCESS: ' || SQLERRM);
    END;

    --
    -- Bug 9131751: Start
    --
    l_line_adj_tbl := Oe_Order_Pub_Line_Adj_Tbl_Typ();

    Add_Manual_Modifier_Obj(l_in_line_tab, l_line_adj_tbl, l_amm_ret_stat);

    IF l_amm_ret_stat = Fnd_Api.G_RET_STS_SUCCESS THEN
      -- only now proceed with executing this logic.
      IF l_debug_level > 0 THEN
        Oe_Debug_Pub.ADD('Proceeding with Invocation to Process_Order...');
      END IF;

    ELSIF l_amm_ret_stat = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
      -- Some problem in executing Add_Manual_Modifier; either relevant
      -- modifier reference is missing or multiple rows got identified.
      --
      IF l_debug_level > 0 THEN
        Oe_Debug_Pub.ADD('Problem in deriving valid modifier...');
      END IF;

      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RETURN;

    ELSE
      -- push an error message into x_messages table and get out.
      IF l_debug_level > 0 THEN
        Oe_Debug_Pub.ADD('Price modifier not found.  Exiting...');
      END IF;
      x_messages := OE_MESSAGE_OBJ_T();
      x_messages.EXTEND;
      x_messages(x_messages.Count) := OE_MESSAGE_OBJ(
                fnd_message.get_string('ONT', 'OE_AIA_MISSING_MAN_MOD')
            );
      --
      -- This API now will return an ERROR status to the caller,
      -- because it does not make sense to proceed in the absence of
      -- a valid modifier reference, accounting for difference between
      -- USP and ULP of at least one order line.
      --
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RETURN;

    END IF;
    --
    -- Bug 9131751: End
    --

    --  Call to generic web service wrapper for Process_Order(...)
    Oe_Inbound_Int.Process_Order
    (
      P_API_VERSION_NUMBER,
      P_INIT_MSG_LIST,
      P_RETURN_VALUES,
      P_ACTION_COMMIT,
      X_RETURN_STATUS,
      X_MESSAGES,
      P_HEADER_REC,
      P_OLD_HEADER_REC,
      P_HEADER_VAL_REC,
      P_OLD_HEADER_VAL_REC,
      P_HEADER_ADJ_TBL,
      P_OLD_HEADER_ADJ_TBL,
      P_HEADER_ADJ_VAL_TBL,
      P_OLD_HEADER_ADJ_VAL_TBL,
      P_HEADER_PRICE_ATT_TBL,
      P_OLD_HEADER_PRICE_ATT_TBL,
      P_HEADER_ADJ_ATT_TBL,
      P_OLD_HEADER_ADJ_ATT_TBL,
      P_HEADER_ADJ_ASSOC_TBL,
      P_OLD_HEADER_ADJ_ASSOC_TBL,
      P_HEADER_SCREDIT_TBL,
      P_OLD_HEADER_SCREDIT_TBL,
      P_HEADER_SCREDIT_VAL_TBL,
      P_OLD_HEADER_SCREDIT_VAL_TBL,
      P_HEADER_PAYMENT_TBL,
      P_OLD_HEADER_PAYMENT_TBL,
      P_HEADER_PAYMENT_VAL_TBL,
      P_OLD_HEADER_PAYMENT_VAL_TBL,
      l_in_line_tab, -- P_LINE_TBL,
      P_OLD_LINE_TBL,
      l_in_line_val_tab, -- P_LINE_VAL_TBL,
      P_OLD_LINE_VAL_TBL,
      l_line_adj_tbl, -- P_LINE_ADJ_TBL, -- Bug 9131751
      P_OLD_LINE_ADJ_TBL,
      P_LINE_ADJ_VAL_TBL,
      P_OLD_LINE_ADJ_VAL_TBL,
      P_LINE_PRICE_ATT_TBL,
      P_OLD_LINE_PRICE_ATT_TBL,
      P_LINE_ADJ_ATT_TBL,
      P_OLD_LINE_ADJ_ATT_TBL,
      P_LINE_ADJ_ASSOC_TBL,
      P_OLD_LINE_ADJ_ASSOC_TBL,
      P_LINE_SCREDIT_TBL,
      P_OLD_LINE_SCREDIT_TBL,
      P_LINE_SCREDIT_VAL_TBL,
      P_OLD_LINE_SCREDIT_VAL_TBL,
      P_LINE_PAYMENT_TBL,
      P_OLD_LINE_PAYMENT_TBL,
      P_LINE_PAYMENT_VAL_TBL,
      P_OLD_LINE_PAYMENT_VAL_TBL,
      P_LOT_SERIAL_TBL,
      P_OLD_LOT_SERIAL_TBL,
      P_LOT_SERIAL_VAL_TBL,
      P_OLD_LOT_SERIAL_VAL_TBL,
      P_ACTION_REQUEST_TBL,
      l_header_rec_old,
      X_HEADER_VAL_REC,
      X_HEADER_ADJ_TBL,
      X_HEADER_ADJ_VAL_TBL,
      X_HEADER_PRICE_ATT_TBL,
      X_HEADER_ADJ_ATT_TBL,
      X_HEADER_ADJ_ASSOC_TBL,
      X_HEADER_SCREDIT_TBL,
      X_HEADER_SCREDIT_VAL_TBL,
      X_HEADER_PAYMENT_TBL,
      X_HEADER_PAYMENT_VAL_TBL,
      l_line_tab_old,
      X_LINE_VAL_TBL,
      X_LINE_ADJ_TBL,
      X_LINE_ADJ_VAL_TBL,
      X_LINE_PRICE_ATT_TBL,
      X_LINE_ADJ_ATT_TBL,
      X_LINE_ADJ_ASSOC_TBL,
      X_LINE_SCREDIT_TBL,
      X_LINE_SCREDIT_VAL_TBL,
      X_LINE_PAYMENT_TBL,
      X_LINE_PAYMENT_VAL_TBL,
      X_LOT_SERIAL_TBL,
      X_LOT_SERIAL_VAL_TBL,
      X_ACTION_REQUEST_TBL,
      P_RTRIM_DATA
    );

    --  Post-Processing specific to O2C25.  This involves calculation of
    --  freight charges roll-up, tax-roll up at header and line level,
    --  based on the profile option set up.  These values are going to be
    --  loaded into the new output record structures (datatypes of which
    --  have '25' in the suffix).

    --
    --  Bug 9019601.
    --
    --  This post-processing is to be executed ONLY after the success
    --  status from Oe_Inbound_Int.Process_Order(...).  If that errored
    --  out (X_RETURN_STATUS being 'E' or 'U'), we set the current
    --  API's return status to 'E' or 'U' and skip this processing.
    --  This will improve overall performance as well.

-- Bug 9019061

IF ( X_RETURN_STATUS IN ('E', 'U') ) THEN

  oe_debug_pub.ADD('Oe_Inbound_Int.Process_Order failed.  Check its processing messages.');

  -- Would it be a good idea to push an additional information message onto x_messages?

ELSE
    --  Step 1: Load the output parameters: x_header_rec, and x_line_tbl.
    oe_genesis_util.header_rec_to_hdr_rec25(
                          l_header_rec_old, x_header_rec
                                            );

    oe_genesis_util.line_tab_to_line_tab25(
                          l_line_tab_old, x_line_tbl
                                          );

    -- Step 2: Based on profile option set up, populate freight_charge,
    --         tax_value at header and line levels.
    -- 2(a). When tax roll up at header level is required.
    IF Nvl(fnd_profile.Value('ONT_TAX_ROLLUP_HDR_AIA'), fnd_api.g_miss_char)
        = 'Y'
    THEN
      Oe_Oe_Totals_Summary.Global_Totals(x_header_rec.header_id);
      x_header_rec.tax_value  :=  Oe_Oe_Totals_Summary.Taxes(x_header_rec.header_id);
    END IF;

    -- 2(b). When the freight charges roll-up at header level is required.
    IF Nvl(fnd_profile.Value('ONT_CHARGES_ROLLUP_HDR_AIA'), fnd_api.g_miss_char)
        = 'Y'
    THEN
      x_header_rec.freight_charge :=
                        Oe_Oe_Totals_Summary.Charges(x_header_rec.header_id);
    END IF;

    -- 2(c). When the freight charges roll-up at each individual line level is required.
    IF Nvl(fnd_profile.Value('ONT_CHARGES_ROLLUP_LINE_AIA'), fnd_api.g_miss_char)
         =  'Y'
    THEN
      BEGIN
        IF x_line_tbl.Count > 0 THEN
          FOR i IN 1..x_line_tbl.Count
          LOOP
            x_line_tbl(i).freight_charge :=  Oe_Oe_Totals_Summary.Line_Charges(
                                x_line_tbl(i).header_id, x_line_tbl(i).line_id
                                        );
          END LOOP;
        END IF; -- check on x_line_tbl.Count
      EXCEPTION
        WHEN Others THEN
          Oe_Debug_Pub.ADD('Error at step 2c:  ' || SQLERRM);
      END;
    END IF;

    -- 2(d). Correct signing of taxes on individual line level -- Bug 8977354
    --
    -- This step 2(d) would no longer be required because this
    -- 'signing' behavior is implemented directly in OEXUGNIB.pls,
    -- line_to_line_rec25(...), as a part of 9151484. Hence the commenting.
    --
    /*
    IF x_line_tbl.Count > 0 THEN
      FOR i IN 1..x_line_tbl.Count
      LOOP
        IF x_line_tbl(i).line_category_code = 'RETURN' THEN
          x_line_tbl(i).tax_value := -x_line_tbl(i).tax_value;
        END IF;
      END LOOP;
    END IF;
    */

    --
    -- Step 3(a): Load the latest value of flow status code at the header
    --            into the header output variable.
    --
    -- (For bug 8652389)
    --
    IF ( p_header_rec.operation = oe_globals.G_OPR_UPDATE ) AND
       ( p_header_rec.header_id IS NOT NULL )               AND
       ( Nvl(x_header_rec.flow_status_code, 'NULL') = 'NULL' )
    THEN
      DECLARE
      l_hdr_fstat   oe_order_headers_all.flow_status_code%TYPE;
      BEGIN
        SELECT  h.flow_status_code
            INTO  l_hdr_fstat
        FROM    oe_order_headers_all h
        WHERE   h.header_id = p_header_rec.header_id;

        x_header_rec.flow_status_code :=  l_hdr_fstat;
      EXCEPTION
        WHEN Others THEN
          oe_debug_pub.ADD('Error at step 3a: ' || SQLERRM);
      END;
    END IF;

    --
    -- Step 3B: Load the flow_status_code for each line from the database.
    --
    DECLARE
      l_flow_stat       oe_order_lines_all.flow_status_code%TYPE;
      l_item_type       oe_order_lines_all.item_type_code%TYPE;
      l_config_rev_nbr  oe_order_lines_all.config_rev_nbr%TYPE;

      TYPE number_table_type IS TABLE OF NUMBER;
      l_model_line_tab        number_table_type;
      l_count                 NUMBER  :=  0;

      CURSOR config_child_lines(p_top_model_line_id IN NUMBER) IS
        SELECT  line_id
          FROM    oe_order_lines_all
          WHERE   top_model_line_id = p_top_model_line_id
          AND     line_id <> p_top_model_line_id
          AND     flow_status_code <> 'CANCELLED'
        ;

      l_line_rec          oe_order_pub.line_rec_type;
      l_line_rec_obj      oe_order_pub_line_rec_type;
      l_line_rec25_obj    oe_order_pub_line_rec25;
    BEGIN
      l_model_line_tab  :=  number_table_type();

      oe_debug_pub.ADD('Entered 3b.....');
      FOR idx IN x_line_tbl.first..x_line_tbl.last
      LOOP
        oe_debug_pub.ADD('line_id in loop..... ' || x_line_tbl(idx).line_id);
        SELECT  flow_status_code, item_type_code, config_rev_nbr
            INTO  l_flow_stat, l_item_type, l_config_rev_nbr
        FROM    oe_order_lines_all l
        WHERE   l.line_id = x_line_tbl(idx).line_id;

        x_line_tbl(idx).flow_status_code  :=  l_flow_stat;
        x_line_tbl(idx).config_rev_nbr    :=  l_config_rev_nbr;

        IF ( l_item_type IN ('MODEL', 'KIT') ) THEN
          oe_debug_pub.ADD('    ........ it is a model/kit. ');
          l_model_line_tab.extend;
          l_count := l_count + 1;
          l_model_line_tab(l_count) :=  x_line_tbl(idx).line_id;
        END IF;

      END LOOP;

      -- For each model, get all its children lines and put them in
      -- x_line_tbl (the output lines table).
      oe_debug_pub.ADD('  p_line_tbl count.... ' || p_line_tbl.Count);
      oe_debug_pub.ADD('  x_line_tbl count.... ' || x_line_tbl.Count);

      IF p_line_tbl.Count <> x_line_tbl.Count THEN
        l_count :=  x_line_tbl.last;
        oe_debug_pub.ADD('           l_count: ' || l_count);
        FOR i IN l_model_line_tab.first..l_model_line_tab.last
        LOOP

          FOR line IN config_child_lines(l_model_line_tab(i))
          LOOP
            oe_line_util.query_row(line.line_id, l_line_rec);
            ------------------
            --  Check if this line is to be repriced (based on incoming data
            --  from AIA).
            ------------------
            DECLARE
              l_reprice_flag      VARCHAR2(1) :=  'N';
              tmp_line_rec        oe_order_pub.line_rec_type;
            BEGIN
              tmp_line_rec  :=  l_line_rec;
              oe_debug_pub.ADD('  Just before the loop... with j as index....');
              oe_debug_pub.ADD('  # of records in l_config_process_tab.count...' ||
                                              l_config_process_tab.Count);
              FOR j IN  1..l_config_process_tab.Count
              LOOP
                  oe_debug_pub.ADD(' ........ Value of j = ' || j);
                  o_config_process_rec  :=  l_config_process_tab(j);

                  IF o_config_process_rec.config_header_id =
                                            tmp_line_rec.config_header_id THEN
                    oe_debug_pub.ADD('  .... config_header_id equality check!');
                    IF o_config_process_rec.line_id IS NULL AND
                       o_config_process_rec.inventory_item_id = tmp_line_rec.inventory_item_id AND
                       o_config_process_rec.ordered_quantity  = tmp_line_rec.ordered_quantity AND
                       (o_config_process_rec.unit_list_price <> tmp_line_rec.unit_list_price OR
                       o_config_process_rec.unit_selling_price <> tmp_line_rec.unit_selling_price)
                    THEN
                      -- Newly added options during this configuration edit.
                      -- Always re-price the option line here.
                      l_reprice_flag  :=  'Y';
                      oe_debug_pub.ADD('  loc1 reprice_flag: ' || l_reprice_flag);
                    ELSE
                      -- Check if line price and the input price are
                      -- varying.  If they are varying, then the source of truth
                      -- is the input.
                      IF
                          o_config_process_rec.line_id = tmp_line_rec.line_id AND
                          (o_config_process_rec.unit_list_price <> tmp_line_rec.unit_selling_price OR
                          o_config_process_rec.unit_selling_price <> tmp_line_rec.unit_selling_price)
                      THEN
                        l_reprice_flag  :=  'Y';
                        oe_debug_pub.ADD('  loc2 reprice_flag: ' || l_reprice_flag);
                      END IF; -- checking line record price and input price
                    END IF; -- check on l_config_process_rec.line_id being null.

                  END IF; -- check for configuration_id equality on input/queried line.
                oe_debug_pub.ADD('  loc3 reprice_flag: ' || l_reprice_flag);
                EXIT WHEN l_reprice_flag = 'Y';
              END LOOP; -- over l_config_process_tab, for current line.

              ------------
              -- If the current line is found to be a candidate, reprice it.
              ------------
              oe_debug_pub.ADD('  checking if re-pricing is to be done for: ' || tmp_line_rec.line_id);
              IF l_reprice_flag = 'Y' THEN
                oe_debug_pub.ADD(' Yes..... indeed it is required.');
                DECLARE
                  repr_control_rec       oe_globals.control_rec_type;
                  repr_line_tbl          oe_order_pub.line_tbl_type;
                  repr_old_line_tbl      oe_order_pub.line_tbl_type;

                  repr_line_rec          oe_order_pub.line_rec_type;
                  repr_old_line_rec      oe_order_pub.line_rec_type;

                  repr_return_status     VARCHAR2(30);
                BEGIN
                  repr_old_line_rec     :=  tmp_line_rec;
                  repr_old_line_tbl(1)  :=  repr_old_line_rec;

                  repr_line_rec         :=  tmp_line_rec;
                  repr_line_rec.operation             :=  'UPDATE';
                  repr_line_rec.calculate_price_flag  :=  'P';
                  repr_line_rec.unit_list_price       :=  o_config_process_rec.unit_list_price;
                  repr_line_rec.unit_selling_price    :=  o_config_process_rec.unit_selling_price;

                  repr_line_tbl(1)  :=  repr_line_rec;

                  oe_debug_pub.ADD(' Initializing the control record for UPDATE...');
                  repr_control_rec  :=  oe_globals.init_control_rec(
                                      repr_line_rec.operation, repr_control_rec);

                  oe_debug_pub.ADD(' Calling Lines(...)....');
                  oe_order_pvt.lines(
                    p_validation_level    =>  FND_API.G_VALID_LEVEL_NONE,
                    p_control_rec         =>  repr_control_rec,
                    p_x_line_tbl          =>  repr_line_tbl,
                    p_x_old_line_tbl      =>  repr_old_line_tbl,
                    x_return_status       =>  repr_return_status
                  );
                  oe_debug_pub.ADD(' Return status from Lines(...)' ||
                                                    repr_return_status);

                  -- Raise O2C business event so that the price change gets
                  -- synched to AIA.
                  DECLARE
                    l_sso_seq   NUMBER;
                    l_stat      VARCHAR2(30);
                    l_hdr_rec   oe_order_pub.header_rec_type;
                  BEGIN
                    oe_debug_pub.ADD(' Price Changed on line ' || repr_line_tbl(1).line_id);

                    SELECT  OE_XML_MESSAGE_SEQ_S.NEXTVAL INTO l_sso_seq FROM dual;

                    oe_header_util.query_row(repr_line_tbl(1).header_id, l_hdr_rec);

                    oe_debug_pub.ADD(' Calling Insert_Sync_Line...');
                      OE_SYNC_ORDER_PVT.INSERT_SYNC_lINE(
                                  P_LINE_rec   => repr_line_tbl(1),
                                    p_change_type   => 'PRICE_CHG',
                                    p_req_id        => l_sso_seq,
                                      X_RETURN_STATUS => l_stat);

                      IF l_stat = FND_API.G_RET_STS_SUCCESS THEN
                      oe_debug_pub.ADD(' Calling Sync_Header_Line...');
                        OE_SYNC_ORDER_PVT.SYNC_HEADER_LINE(
                                  p_header_rec          => l_hdr_rec,
                                  p_line_rec            => repr_line_tbl(1),
                                  p_hdr_req_id          => l_sso_seq,
                                    p_lin_req_id          => l_sso_seq,
                                    p_change_type         => 'PRICE_CHG');
                    END IF;
                    oe_debug_pub.ADD('...... Done raising event.');
                  END;

                  COMMIT;

                  tmp_line_rec  :=  repr_line_tbl(1);
                  l_line_rec    :=  tmp_line_rec;
                END;
                -- Reseting the reprice flag.
                l_reprice_flag  :=  'N';
              ELSE
                l_line_rec  :=  tmp_line_rec;
              END IF;

            END; -- for the declare.
            ------------------
            l_line_rec_obj := PL_TO_SQL35(l_line_rec);
            oe_genesis_util.line_rec_to_line_rec25(l_line_rec_obj,
                                                        l_line_rec25_obj);
            x_line_tbl.extend;
            l_count :=  l_count + 1;
            x_line_tbl(l_count) := l_line_rec25_obj;
          END LOOP;
        END LOOP;
      END IF;
    EXCEPTION
      WHEN Others THEN
        IF SQLCODE = -6531 THEN
           --  A pure header level update.  In such case, the order line table will
           --  have been neither populated, nor have been returned (on the
           --  signature of process_order(...) API).
           oe_debug_pub.ADD('Ignorable Error occurred: ' || SQLERRM);
        ELSE
          oe_debug_pub.ADD('Error occurred: ' || SQLERRM);
        END IF;
    END; -- End of the Block that started with 3B

END IF; -- Bug 9019061

  END process_order_25;
------- O2C25


----------------------------------------
-- This newer, overloaded form of OE_INBOUND_INT.Process_Order(..)
-- is the most recent, intended-to-be used one.
----------------------------------------
PROCEDURE Process_Order (
      P_API_VERSION_NUMBER        NUMBER,
      P_INIT_MSG_LIST             VARCHAR2,
      P_RETURN_VALUES             VARCHAR2,
      P_ACTION_COMMIT             VARCHAR2,
      X_RETURN_STATUS   OUT NOCOPY      VARCHAR2 ,
      X_MESSAGES        OUT NOCOPY      OE_MESSAGE_OBJ_T,
      P_HEADER_REC OE_ORDER_PUB_HEADER_REC_TYPE,
      P_OLD_HEADER_REC OE_ORDER_PUB_HEADER_REC_TYPE,
      P_HEADER_VAL_REC OE_ORDER_PUB_HEADER_VAL_REC_T,
      P_OLD_HEADER_VAL_REC OE_ORDER_PUB_HEADER_VAL_REC_T,
      P_HEADER_ADJ_TBL OE_ORDER_PUB_HEADER_ADJ_TBL_T,
      P_OLD_HEADER_ADJ_TBL OE_ORDER_PUB_HEADER_ADJ_TBL_T,
      P_HEADER_ADJ_VAL_TBL OE_ORDER_PUB_HEADER_ADJ_VAL_T,
      P_OLD_HEADER_ADJ_VAL_TBL OE_ORDER_PUB_HEADER_ADJ_VAL_T,
      P_HEADER_PRICE_ATT_TBL OE_ORDER_PUB_HEADER_PRICE_ATT,
      P_OLD_HEADER_PRICE_ATT_TBL OE_ORDER_PUB_HEADER_PRICE_ATT,
      P_HEADER_ADJ_ATT_TBL OE_ORDER_PUB_HEADER_ADJ_ATT_T,
      P_OLD_HEADER_ADJ_ATT_TBL OE_ORDER_PUB_HEADER_ADJ_ATT_T,
      P_HEADER_ADJ_ASSOC_TBL OE_ORDER_PUB_HEADER_ADJ_ASSOC,
      P_OLD_HEADER_ADJ_ASSOC_TBL OE_ORDER_PUB_HEADER_ADJ_ASSOC,
      P_HEADER_SCREDIT_TBL OE_ORDER_PUB_HEADER_SCREDIT_T,
      P_OLD_HEADER_SCREDIT_TBL OE_ORDER_PUB_HEADER_SCREDIT_T,
      P_HEADER_SCREDIT_VAL_TBL OE_ORDER_PUB_HEADER_SCREDIT_V,
      P_OLD_HEADER_SCREDIT_VAL_TBL OE_ORDER_PUB_HEADER_SCREDIT_V,
      P_HEADER_PAYMENT_TBL OE_ORDER_PUB_HEADER_PAYMENT_T,
      P_OLD_HEADER_PAYMENT_TBL OE_ORDER_PUB_HEADER_PAYMENT_T,
      P_HEADER_PAYMENT_VAL_TBL OE_ORDER_PUB_HEADER_PAYMENT_V,
      P_OLD_HEADER_PAYMENT_VAL_TBL OE_ORDER_PUB_HEADER_PAYMENT_V,
      P_LINE_TBL OE_ORDER_PUB_LINE_TBL_TYPE,
      P_OLD_LINE_TBL OE_ORDER_PUB_LINE_TBL_TYPE,
      P_LINE_VAL_TBL OE_ORDER_PUB_LINE_VAL_TBL_TYP,
      P_OLD_LINE_VAL_TBL OE_ORDER_PUB_LINE_VAL_TBL_TYP,
      P_LINE_ADJ_TBL OE_ORDER_PUB_LINE_ADJ_TBL_TYP,
      P_OLD_LINE_ADJ_TBL OE_ORDER_PUB_LINE_ADJ_TBL_TYP,
      P_LINE_ADJ_VAL_TBL OE_ORDER_PUB_LINE_ADJ_VAL_TBL,
      P_OLD_LINE_ADJ_VAL_TBL OE_ORDER_PUB_LINE_ADJ_VAL_TBL,
      P_LINE_PRICE_ATT_TBL OE_ORDER_PUB_LINE_PRICE_ATT_T,
      P_OLD_LINE_PRICE_ATT_TBL OE_ORDER_PUB_LINE_PRICE_ATT_T,
      P_LINE_ADJ_ATT_TBL OE_ORDER_PUB_LINE_ADJ_ATT_TBL,
      P_OLD_LINE_ADJ_ATT_TBL OE_ORDER_PUB_LINE_ADJ_ATT_TBL,
      P_LINE_ADJ_ASSOC_TBL OE_ORDER_PUB_LINE_ADJ_ASSOC_T,
      P_OLD_LINE_ADJ_ASSOC_TBL OE_ORDER_PUB_LINE_ADJ_ASSOC_T,
      P_LINE_SCREDIT_TBL OE_ORDER_PUB_LINE_SCREDIT_TBL,
      P_OLD_LINE_SCREDIT_TBL OE_ORDER_PUB_LINE_SCREDIT_TBL,
      P_LINE_SCREDIT_VAL_TBL OE_ORDER_PUB_LINE_SCREDIT_VAL,
      P_OLD_LINE_SCREDIT_VAL_TBL OE_ORDER_PUB_LINE_SCREDIT_VAL,
      P_LINE_PAYMENT_TBL OE_ORDER_PUB_LINE_PAYMENT_TBL,
      P_OLD_LINE_PAYMENT_TBL OE_ORDER_PUB_LINE_PAYMENT_TBL,
      P_LINE_PAYMENT_VAL_TBL OE_ORDER_PUB_LINE_PAYMENT_VAL,
      P_OLD_LINE_PAYMENT_VAL_TBL OE_ORDER_PUB_LINE_PAYMENT_VAL,
      P_LOT_SERIAL_TBL OE_ORDER_PUB_LOT_SERIAL_TBL_T,
      P_OLD_LOT_SERIAL_TBL OE_ORDER_PUB_LOT_SERIAL_TBL_T,
      P_LOT_SERIAL_VAL_TBL OE_ORDER_PUB_LOT_SERIAL_VAL_T,
      P_OLD_LOT_SERIAL_VAL_TBL OE_ORDER_PUB_LOT_SERIAL_VAL_T,
      P_ACTION_REQUEST_TBL OE_ORDER_PUB_REQUEST_TBL_TYPE,
      X_HEADER_REC             OUT NOCOPY OE_ORDER_PUB_HEADER_REC_TYPE ,
      X_HEADER_VAL_REC         OUT NOCOPY OE_ORDER_PUB_HEADER_VAL_REC_T ,
      X_HEADER_ADJ_TBL         OUT NOCOPY OE_ORDER_PUB_HEADER_ADJ_TBL_T ,
      X_HEADER_ADJ_VAL_TBL     OUT NOCOPY OE_ORDER_PUB_HEADER_ADJ_VAL_T ,
      X_HEADER_PRICE_ATT_TBL   OUT NOCOPY OE_ORDER_PUB_HEADER_PRICE_ATT ,
      X_HEADER_ADJ_ATT_TBL     OUT NOCOPY OE_ORDER_PUB_HEADER_ADJ_ATT_T ,
      X_HEADER_ADJ_ASSOC_TBL   OUT NOCOPY OE_ORDER_PUB_HEADER_ADJ_ASSOC ,
      X_HEADER_SCREDIT_TBL     OUT NOCOPY OE_ORDER_PUB_HEADER_SCREDIT_T ,
      X_HEADER_SCREDIT_VAL_TBL OUT NOCOPY OE_ORDER_PUB_HEADER_SCREDIT_V ,
      X_HEADER_PAYMENT_TBL     OUT NOCOPY OE_ORDER_PUB_HEADER_PAYMENT_T ,
      X_HEADER_PAYMENT_VAL_TBL OUT NOCOPY OE_ORDER_PUB_HEADER_PAYMENT_V ,
      X_LINE_TBL              OUT NOCOPY OE_ORDER_PUB_LINE_TBL_TYPE  ,
      X_LINE_VAL_TBL          OUT NOCOPY OE_ORDER_PUB_LINE_VAL_TBL_TYP ,
      X_LINE_ADJ_TBL          OUT NOCOPY OE_ORDER_PUB_LINE_ADJ_TBL_TYP ,
      X_LINE_ADJ_VAL_TBL      OUT NOCOPY OE_ORDER_PUB_LINE_ADJ_VAL_TBL ,
      X_LINE_PRICE_ATT_TBL    OUT NOCOPY OE_ORDER_PUB_LINE_PRICE_ATT_T ,
      X_LINE_ADJ_ATT_TBL      OUT NOCOPY OE_ORDER_PUB_LINE_ADJ_ATT_TBL ,
      X_LINE_ADJ_ASSOC_TBL    OUT NOCOPY OE_ORDER_PUB_LINE_ADJ_ASSOC_T ,
      X_LINE_SCREDIT_TBL      OUT NOCOPY OE_ORDER_PUB_LINE_SCREDIT_TBL ,
      X_LINE_SCREDIT_VAL_TBL  OUT NOCOPY OE_ORDER_PUB_LINE_SCREDIT_VAL ,
      X_LINE_PAYMENT_TBL      OUT NOCOPY OE_ORDER_PUB_LINE_PAYMENT_TBL ,
      X_LINE_PAYMENT_VAL_TBL  OUT NOCOPY OE_ORDER_PUB_LINE_PAYMENT_VAL ,
      X_LOT_SERIAL_TBL        OUT NOCOPY OE_ORDER_PUB_LOT_SERIAL_TBL_T ,
      X_LOT_SERIAL_VAL_TBL    OUT NOCOPY OE_ORDER_PUB_LOT_SERIAL_VAL_T ,
      X_ACTION_REQUEST_TBL    OUT NOCOPY OE_ORDER_PUB_REQUEST_TBL_TYPE ,
      P_RTRIM_DATA VARCHAR2
      )
IS
      P_HEADER_REC_ APPS.OE_ORDER_PUB.HEADER_REC_TYPE;
      P_OLD_HEADER_REC_ APPS.OE_ORDER_PUB.HEADER_REC_TYPE;
      P_HEADER_VAL_REC_ APPS.OE_ORDER_PUB.HEADER_VAL_REC_TYPE;
      P_OLD_HEADER_VAL_REC_ APPS.OE_ORDER_PUB.HEADER_VAL_REC_TYPE;
      P_HEADER_ADJ_TBL_ APPS.OE_ORDER_PUB.HEADER_ADJ_TBL_TYPE;
      P_OLD_HEADER_ADJ_TBL_ APPS.OE_ORDER_PUB.HEADER_ADJ_TBL_TYPE;
      P_HEADER_ADJ_VAL_TBL_ APPS.OE_ORDER_PUB.HEADER_ADJ_VAL_TBL_TYPE;
      P_OLD_HEADER_ADJ_VAL_TBL_ APPS.OE_ORDER_PUB.HEADER_ADJ_VAL_TBL_TYPE;
      P_HEADER_PRICE_ATT_TBL_ APPS.OE_ORDER_PUB.HEADER_PRICE_ATT_TBL_TYPE;
      P_OLD_HEADER_PRICE_ATT_TBL_ APPS.OE_ORDER_PUB.HEADER_PRICE_ATT_TBL_TYPE;
      P_HEADER_ADJ_ATT_TBL_ APPS.OE_ORDER_PUB.HEADER_ADJ_ATT_TBL_TYPE;
      P_OLD_HEADER_ADJ_ATT_TBL_ APPS.OE_ORDER_PUB.HEADER_ADJ_ATT_TBL_TYPE;
      P_HEADER_ADJ_ASSOC_TBL_ APPS.OE_ORDER_PUB.HEADER_ADJ_ASSOC_TBL_TYPE;
      P_OLD_HEADER_ADJ_ASSOC_TBL_ APPS.OE_ORDER_PUB.HEADER_ADJ_ASSOC_TBL_TYPE;
      P_HEADER_SCREDIT_TBL_ APPS.OE_ORDER_PUB.HEADER_SCREDIT_TBL_TYPE;
      P_OLD_HEADER_SCREDIT_TBL_ APPS.OE_ORDER_PUB.HEADER_SCREDIT_TBL_TYPE;
      P_HEADER_SCREDIT_VAL_TBL_ APPS.OE_ORDER_PUB.HEADER_SCREDIT_VAL_TBL_TYPE;
      P_OLD_HEADER_SCREDIT_VAL_TBL_ APPS.OE_ORDER_PUB.HEADER_SCREDIT_VAL_TBL_TYPE;
      P_HEADER_PAYMENT_TBL_ APPS.OE_ORDER_PUB.HEADER_PAYMENT_TBL_TYPE;
      P_OLD_HEADER_PAYMENT_TBL_ APPS.OE_ORDER_PUB.HEADER_PAYMENT_TBL_TYPE;
      P_HEADER_PAYMENT_VAL_TBL_ APPS.OE_ORDER_PUB.HEADER_PAYMENT_VAL_TBL_TYPE;
      P_OLD_HEADER_PAYMENT_VAL_TBL_ APPS.OE_ORDER_PUB.HEADER_PAYMENT_VAL_TBL_TYPE;
      P_LINE_TBL_ APPS.OE_ORDER_PUB.LINE_TBL_TYPE;
      P_OLD_LINE_TBL_ APPS.OE_ORDER_PUB.LINE_TBL_TYPE;
      P_LINE_VAL_TBL_ APPS.OE_ORDER_PUB.LINE_VAL_TBL_TYPE;
      P_OLD_LINE_VAL_TBL_ APPS.OE_ORDER_PUB.LINE_VAL_TBL_TYPE;
      P_LINE_ADJ_TBL_ APPS.OE_ORDER_PUB.LINE_ADJ_TBL_TYPE;
      P_OLD_LINE_ADJ_TBL_ APPS.OE_ORDER_PUB.LINE_ADJ_TBL_TYPE;
      P_LINE_ADJ_VAL_TBL_ APPS.OE_ORDER_PUB.LINE_ADJ_VAL_TBL_TYPE;
      P_OLD_LINE_ADJ_VAL_TBL_ APPS.OE_ORDER_PUB.LINE_ADJ_VAL_TBL_TYPE;
      P_LINE_PRICE_ATT_TBL_ APPS.OE_ORDER_PUB.LINE_PRICE_ATT_TBL_TYPE;
      P_OLD_LINE_PRICE_ATT_TBL_ APPS.OE_ORDER_PUB.LINE_PRICE_ATT_TBL_TYPE;
      P_LINE_ADJ_ATT_TBL_ APPS.OE_ORDER_PUB.LINE_ADJ_ATT_TBL_TYPE;
      P_OLD_LINE_ADJ_ATT_TBL_ APPS.OE_ORDER_PUB.LINE_ADJ_ATT_TBL_TYPE;
      P_LINE_ADJ_ASSOC_TBL_ APPS.OE_ORDER_PUB.LINE_ADJ_ASSOC_TBL_TYPE;
      P_OLD_LINE_ADJ_ASSOC_TBL_ APPS.OE_ORDER_PUB.LINE_ADJ_ASSOC_TBL_TYPE;
      P_LINE_SCREDIT_TBL_ APPS.OE_ORDER_PUB.LINE_SCREDIT_TBL_TYPE;
      P_OLD_LINE_SCREDIT_TBL_ APPS.OE_ORDER_PUB.LINE_SCREDIT_TBL_TYPE;
      P_LINE_SCREDIT_VAL_TBL_ APPS.OE_ORDER_PUB.LINE_SCREDIT_VAL_TBL_TYPE;
      P_OLD_LINE_SCREDIT_VAL_TBL_ APPS.OE_ORDER_PUB.LINE_SCREDIT_VAL_TBL_TYPE;
      P_LINE_PAYMENT_TBL_ APPS.OE_ORDER_PUB.LINE_PAYMENT_TBL_TYPE;
      P_OLD_LINE_PAYMENT_TBL_ APPS.OE_ORDER_PUB.LINE_PAYMENT_TBL_TYPE;
      P_LINE_PAYMENT_VAL_TBL_ APPS.OE_ORDER_PUB.LINE_PAYMENT_VAL_TBL_TYPE;
      P_OLD_LINE_PAYMENT_VAL_TBL_ APPS.OE_ORDER_PUB.LINE_PAYMENT_VAL_TBL_TYPE;
      P_LOT_SERIAL_TBL_ APPS.OE_ORDER_PUB.LOT_SERIAL_TBL_TYPE;
      P_OLD_LOT_SERIAL_TBL_ APPS.OE_ORDER_PUB.LOT_SERIAL_TBL_TYPE;
      P_LOT_SERIAL_VAL_TBL_ APPS.OE_ORDER_PUB.LOT_SERIAL_VAL_TBL_TYPE;
      P_OLD_LOT_SERIAL_VAL_TBL_ APPS.OE_ORDER_PUB.LOT_SERIAL_VAL_TBL_TYPE;
      P_ACTION_REQUEST_TBL_ APPS.OE_ORDER_PUB.REQUEST_TBL_TYPE;
      X_HEADER_REC_ APPS.OE_ORDER_PUB.HEADER_REC_TYPE;
      X_HEADER_VAL_REC_ APPS.OE_ORDER_PUB.HEADER_VAL_REC_TYPE;
      X_HEADER_ADJ_TBL_ APPS.OE_ORDER_PUB.HEADER_ADJ_TBL_TYPE;
      X_HEADER_ADJ_VAL_TBL_ APPS.OE_ORDER_PUB.HEADER_ADJ_VAL_TBL_TYPE;
      X_HEADER_PRICE_ATT_TBL_ APPS.OE_ORDER_PUB.HEADER_PRICE_ATT_TBL_TYPE;
      X_HEADER_ADJ_ATT_TBL_ APPS.OE_ORDER_PUB.HEADER_ADJ_ATT_TBL_TYPE;
      X_HEADER_ADJ_ASSOC_TBL_ APPS.OE_ORDER_PUB.HEADER_ADJ_ASSOC_TBL_TYPE;
      X_HEADER_SCREDIT_TBL_ APPS.OE_ORDER_PUB.HEADER_SCREDIT_TBL_TYPE;
      X_HEADER_SCREDIT_VAL_TBL_ APPS.OE_ORDER_PUB.HEADER_SCREDIT_VAL_TBL_TYPE;
      X_HEADER_PAYMENT_TBL_ APPS.OE_ORDER_PUB.HEADER_PAYMENT_TBL_TYPE;
      X_HEADER_PAYMENT_VAL_TBL_ APPS.OE_ORDER_PUB.HEADER_PAYMENT_VAL_TBL_TYPE;
      X_LINE_TBL_ APPS.OE_ORDER_PUB.LINE_TBL_TYPE;
      X_LINE_VAL_TBL_ APPS.OE_ORDER_PUB.LINE_VAL_TBL_TYPE;
      X_LINE_ADJ_TBL_ APPS.OE_ORDER_PUB.LINE_ADJ_TBL_TYPE;
      X_LINE_ADJ_VAL_TBL_ APPS.OE_ORDER_PUB.LINE_ADJ_VAL_TBL_TYPE;
      X_LINE_PRICE_ATT_TBL_ APPS.OE_ORDER_PUB.LINE_PRICE_ATT_TBL_TYPE;
      X_LINE_ADJ_ATT_TBL_ APPS.OE_ORDER_PUB.LINE_ADJ_ATT_TBL_TYPE;
      X_LINE_ADJ_ASSOC_TBL_ APPS.OE_ORDER_PUB.LINE_ADJ_ASSOC_TBL_TYPE;
      X_LINE_SCREDIT_TBL_ APPS.OE_ORDER_PUB.LINE_SCREDIT_TBL_TYPE;
      X_LINE_SCREDIT_VAL_TBL_ APPS.OE_ORDER_PUB.LINE_SCREDIT_VAL_TBL_TYPE;
      X_LINE_PAYMENT_TBL_ APPS.OE_ORDER_PUB.LINE_PAYMENT_TBL_TYPE;
      X_LINE_PAYMENT_VAL_TBL_ APPS.OE_ORDER_PUB.LINE_PAYMENT_VAL_TBL_TYPE;
      X_LOT_SERIAL_TBL_ APPS.OE_ORDER_PUB.LOT_SERIAL_TBL_TYPE;
      X_LOT_SERIAL_VAL_TBL_ APPS.OE_ORDER_PUB.LOT_SERIAL_VAL_TBL_TYPE;
      X_ACTION_REQUEST_TBL_ APPS.OE_ORDER_PUB.REQUEST_TBL_TYPE;
      l_temp_var  VARCHAR2(2000) := NULL;
      l_return_status VARCHAR2(256);

      L_MSG_COUNT    NUMBER ;
      L_MSG_DATA     VARCHAR2(2000);
      l_debug_level  CONSTANT NUMBER := oe_debug_pub.g_debug_level;
      l_booking_action_index NUMBER := NULL; -- Bug 8872110
   BEGIN
      oe_debug_pub.initialize;

      l_temp_var := oe_debug_pub.set_debug_mode('FILE');

      oe_debug_pub.debug_on;

      IF l_debug_level > 0  THEN
        oe_debug_pub.add('Inside the cover API...');
        oe_debug_pub.add('Line table count is: '||p_line_tbl.COUNT);
      END IF;


      P_HEADER_REC_ := Oe_Inbound_Int.SQL_TO_PL1(P_HEADER_REC);
      P_OLD_HEADER_REC_ := Oe_Inbound_Int.SQL_TO_PL1(P_OLD_HEADER_REC);
      P_HEADER_VAL_REC_ := Oe_Inbound_Int.SQL_TO_PL2(P_HEADER_VAL_REC);
      P_OLD_HEADER_VAL_REC_ := Oe_Inbound_Int.SQL_TO_PL2(P_OLD_HEADER_VAL_REC);
      P_HEADER_ADJ_TBL_ := Oe_Inbound_Int.SQL_TO_PL3(P_HEADER_ADJ_TBL);
      P_OLD_HEADER_ADJ_TBL_ := Oe_Inbound_Int.SQL_TO_PL3(P_OLD_HEADER_ADJ_TBL);
      P_HEADER_ADJ_VAL_TBL_ := Oe_Inbound_Int.SQL_TO_PL4(P_HEADER_ADJ_VAL_TBL);
      P_OLD_HEADER_ADJ_VAL_TBL_ := Oe_Inbound_Int.SQL_TO_PL4(P_OLD_HEADER_ADJ_VAL_TBL);
      P_HEADER_PRICE_ATT_TBL_ := Oe_Inbound_Int.SQL_TO_PL5(P_HEADER_PRICE_ATT_TBL);
      P_OLD_HEADER_PRICE_ATT_TBL_ := Oe_Inbound_Int.SQL_TO_PL5(P_OLD_HEADER_PRICE_ATT_TBL);
      P_HEADER_ADJ_ATT_TBL_ := Oe_Inbound_Int.SQL_TO_PL6(P_HEADER_ADJ_ATT_TBL);
      P_OLD_HEADER_ADJ_ATT_TBL_ := Oe_Inbound_Int.SQL_TO_PL6(P_OLD_HEADER_ADJ_ATT_TBL);
      P_HEADER_ADJ_ASSOC_TBL_ := Oe_Inbound_Int.SQL_TO_PL7(P_HEADER_ADJ_ASSOC_TBL);
      P_OLD_HEADER_ADJ_ASSOC_TBL_ := Oe_Inbound_Int.SQL_TO_PL7(P_OLD_HEADER_ADJ_ASSOC_TBL);
      P_HEADER_SCREDIT_TBL_ := Oe_Inbound_Int.SQL_TO_PL8(P_HEADER_SCREDIT_TBL);
      P_OLD_HEADER_SCREDIT_TBL_ := Oe_Inbound_Int.SQL_TO_PL8(P_OLD_HEADER_SCREDIT_TBL);
      P_HEADER_SCREDIT_VAL_TBL_ := Oe_Inbound_Int.SQL_TO_PL9(P_HEADER_SCREDIT_VAL_TBL);
      P_OLD_HEADER_SCREDIT_VAL_TBL_ := Oe_Inbound_Int.SQL_TO_PL9(P_OLD_HEADER_SCREDIT_VAL_TBL);
      P_HEADER_PAYMENT_TBL_ := Oe_Inbound_Int.SQL_TO_PL10(P_HEADER_PAYMENT_TBL);
      P_OLD_HEADER_PAYMENT_TBL_ := Oe_Inbound_Int.SQL_TO_PL10(P_OLD_HEADER_PAYMENT_TBL);
      P_HEADER_PAYMENT_VAL_TBL_ := Oe_Inbound_Int.SQL_TO_PL11(P_HEADER_PAYMENT_VAL_TBL);
      P_OLD_HEADER_PAYMENT_VAL_TBL_ := Oe_Inbound_Int.SQL_TO_PL11(P_OLD_HEADER_PAYMENT_VAL_TBL);
      P_LINE_TBL_ := Oe_Inbound_Int.SQL_TO_PL12(P_LINE_TBL);
      --P_OLD_LINE_TBL_ := Oe_Inbound_Int.SQL_TO_PL12(P_OLD_LINE_TBL);
      P_LINE_VAL_TBL_ := Oe_Inbound_Int.SQL_TO_PL13(P_LINE_VAL_TBL);
      P_OLD_LINE_VAL_TBL_ := Oe_Inbound_Int.SQL_TO_PL13(P_OLD_LINE_VAL_TBL);
      P_LINE_ADJ_TBL_ := Oe_Inbound_Int.SQL_TO_PL14(P_LINE_ADJ_TBL);
      P_OLD_LINE_ADJ_TBL_ := Oe_Inbound_Int.SQL_TO_PL14(P_OLD_LINE_ADJ_TBL);
      P_LINE_ADJ_VAL_TBL_ := Oe_Inbound_Int.SQL_TO_PL15(P_LINE_ADJ_VAL_TBL);
      P_OLD_LINE_ADJ_VAL_TBL_ := Oe_Inbound_Int.SQL_TO_PL15(P_OLD_LINE_ADJ_VAL_TBL);
      P_LINE_PRICE_ATT_TBL_ := Oe_Inbound_Int.SQL_TO_PL16(P_LINE_PRICE_ATT_TBL);
      P_OLD_LINE_PRICE_ATT_TBL_ := Oe_Inbound_Int.SQL_TO_PL16(P_OLD_LINE_PRICE_ATT_TBL);
      P_LINE_ADJ_ATT_TBL_ := Oe_Inbound_Int.SQL_TO_PL17(P_LINE_ADJ_ATT_TBL);
      P_OLD_LINE_ADJ_ATT_TBL_ := Oe_Inbound_Int.SQL_TO_PL17(P_OLD_LINE_ADJ_ATT_TBL);
      P_LINE_ADJ_ASSOC_TBL_ := Oe_Inbound_Int.SQL_TO_PL18(P_LINE_ADJ_ASSOC_TBL);
      P_OLD_LINE_ADJ_ASSOC_TBL_ := Oe_Inbound_Int.SQL_TO_PL18(P_OLD_LINE_ADJ_ASSOC_TBL);
      P_LINE_SCREDIT_TBL_ := Oe_Inbound_Int.SQL_TO_PL19(P_LINE_SCREDIT_TBL);
      P_OLD_LINE_SCREDIT_TBL_ := Oe_Inbound_Int.SQL_TO_PL19(P_OLD_LINE_SCREDIT_TBL);
      P_LINE_SCREDIT_VAL_TBL_ := Oe_Inbound_Int.SQL_TO_PL20(P_LINE_SCREDIT_VAL_TBL);
      P_OLD_LINE_SCREDIT_VAL_TBL_ := Oe_Inbound_Int.SQL_TO_PL20(P_OLD_LINE_SCREDIT_VAL_TBL);
      P_LINE_PAYMENT_TBL_ := Oe_Inbound_Int.SQL_TO_PL21(P_LINE_PAYMENT_TBL);
      P_OLD_LINE_PAYMENT_TBL_ := Oe_Inbound_Int.SQL_TO_PL21(P_OLD_LINE_PAYMENT_TBL);
      P_LINE_PAYMENT_VAL_TBL_ := Oe_Inbound_Int.SQL_TO_PL22(P_LINE_PAYMENT_VAL_TBL);
      P_OLD_LINE_PAYMENT_VAL_TBL_ := Oe_Inbound_Int.SQL_TO_PL22(P_OLD_LINE_PAYMENT_VAL_TBL);
      P_LOT_SERIAL_TBL_ := Oe_Inbound_Int.SQL_TO_PL23(P_LOT_SERIAL_TBL);
      P_OLD_LOT_SERIAL_TBL_ := Oe_Inbound_Int.SQL_TO_PL23(P_OLD_LOT_SERIAL_TBL);
      P_LOT_SERIAL_VAL_TBL_ := Oe_Inbound_Int.SQL_TO_PL24(P_LOT_SERIAL_VAL_TBL);
      P_OLD_LOT_SERIAL_VAL_TBL_ := Oe_Inbound_Int.SQL_TO_PL24(P_OLD_LOT_SERIAL_VAL_TBL);
      P_ACTION_REQUEST_TBL_ := Oe_Inbound_Int.SQL_TO_PL25(P_ACTION_REQUEST_TBL);

      --
      -- Code Changes Start: ER 7025965
      --
      -- Set the action request to BOOK_ORDER, if and only if the document
      -- being created is a sales order.  For quotes, we do not request
      -- booking.
      --
      IF ( Nvl(p_header_rec.transaction_phase_code, 'F') = 'F'  OR
               p_header_rec.transaction_phase_code = FND_API.G_MISS_CHAR) THEN --Bug 8442659
           IF l_debug_level > 0 THEN
             oe_debug_pub.add('+++ Sales order under creation...');
	   END IF;
        -- Bug 7629966
        IF ( Nvl(p_header_rec.booked_flag, 'N') = 'Y' AND
                 -- Bug 8872110
                 p_header_rec.operation = Oe_Globals.G_Opr_Create) THEN
          IF l_debug_level > 0 THEN
            oe_debug_pub.add('+++ Requesting booking...');
          END IF;
          p_action_request_tbl_(p_action_request_tbl_.COUNT+1).request_type := OE_GLOBALS.G_BOOK_ORDER;  --Bug 8442659
  	      p_action_request_tbl_(p_action_request_tbl_.COUNT).entity_code := OE_GLOBALS.G_ENTITY_HEADER; --Bug 8442659
          l_booking_action_index    := p_action_request_tbl_.COUNT; -- Bug 8872110
	      p_header_rec_.booked_flag := FND_API.G_MISS_CHAR;  --Bug 8485302
        END IF;
      ELSIF ( p_header_rec.transaction_phase_code = 'N' ) THEN
        IF l_debug_level > 0 THEN
          oe_debug_pub.add('+++ Quote under creation, not populating action request table.');
        END IF;
      END IF;
      --
      -- Code Changes End  : ER 7025965
      --

      IF l_debug_level > 0 THEN
        oe_debug_pub.add('Before calling PO');
        oe_debug_pub.add('Header Attributes');
        oe_debug_pub.add('header sold_to_org_id '||p_header_rec_.sold_to_org_id);
        oe_debug_pub.add('header Order Type '||p_header_rec_.order_type_id);
        oe_debug_pub.add('header order_source_id'||p_header_rec_.order_source_id);
        oe_debug_pub.add('header salesrep_id '||p_header_rec_.salesrep_id);
        oe_debug_pub.add('header Org Id '||p_header_rec_.Org_id);
        oe_debug_pub.add('header orig_sys_document_ref '||p_header_rec_.orig_sys_document_ref);
        oe_debug_pub.add('Line Attributes');
        oe_debug_pub.add('Line table count is '||p_line_tbl_.COUNT);
     END IF;

      if p_line_tbl_.COUNT > 0 then
       if l_debug_level > 0 THEN
         oe_debug_pub.add('line inventory_item_id '||p_line_tbl_(1).inventory_item_id);
         oe_debug_pub.add('line ordered_quantity '||p_line_tbl_(1).ordered_quantity);
       end if;
      end if;

      if l_debug_level > 0 then
        oe_debug_pub.add('22Calling OE_GENESIS_UTIL.print_po_payload');
      end if;

      OE_GENESIS_UTIL.print_po_payload(
        P_HEADER_REC_,
        P_HEADER_VAL_REC_,
        P_HEADER_PAYMENT_TBL_,
        P_LINE_TBL_
      );

      if l_debug_level > 0 then
       oe_debug_pub.add('Calling OE_ORDER_IMPORT_CONFIG_PVT.Pre_Process');
      end if;
      OE_ORDER_IMPORT_CONFIG_PVT.Pre_Process(
          p_header_rec => P_HEADER_REC_
         ,p_x_line_tbl => P_LINE_TBL_
         ,p_return_status => l_return_status);
      if l_debug_level > 0 then
       oe_debug_pub.add('After OE_ORDER_IMPORT_CONFIG_PVT.Pre_Process' ||
	                                     l_return_status);
      end if;

      APPS.OE_ORDER_PUB.PROCESS_ORDER(
             p_header_rec.org_id,  -- MOAC Changes in R12
             NULL,                 -- MOAC Changes in R12
             1.0,
             FND_API.G_TRUE,
             FND_API.G_TRUE,
             FND_API.G_FALSE,
             X_RETURN_STATUS,
             L_MSG_COUNT,
             L_MSG_DATA,
             P_HEADER_REC_,
             P_OLD_HEADER_REC_,
             P_HEADER_VAL_REC_,
             P_OLD_HEADER_VAL_REC_,
             P_HEADER_ADJ_TBL_,
             P_OLD_HEADER_ADJ_TBL_,
             P_HEADER_ADJ_VAL_TBL_,
             P_OLD_HEADER_ADJ_VAL_TBL_,
             P_HEADER_PRICE_ATT_TBL_,
             P_OLD_HEADER_PRICE_ATT_TBL_,
             P_HEADER_ADJ_ATT_TBL_,
             P_OLD_HEADER_ADJ_ATT_TBL_,
             P_HEADER_ADJ_ASSOC_TBL_,
             P_OLD_HEADER_ADJ_ASSOC_TBL_,
             P_HEADER_SCREDIT_TBL_,
             P_OLD_HEADER_SCREDIT_TBL_,
             P_HEADER_SCREDIT_VAL_TBL_,
             P_OLD_HEADER_SCREDIT_VAL_TBL_,
             P_HEADER_PAYMENT_TBL_,
             P_OLD_HEADER_PAYMENT_TBL_,
             P_HEADER_PAYMENT_VAL_TBL_,
             P_OLD_HEADER_PAYMENT_VAL_TBL_,
             P_LINE_TBL_,P_OLD_LINE_TBL_,
             P_LINE_VAL_TBL_,
             P_OLD_LINE_VAL_TBL_,
             P_LINE_ADJ_TBL_,
             P_OLD_LINE_ADJ_TBL_,
             P_LINE_ADJ_VAL_TBL_,
             P_OLD_LINE_ADJ_VAL_TBL_,
             P_LINE_PRICE_ATT_TBL_,
             P_OLD_LINE_PRICE_ATT_TBL_,
             P_LINE_ADJ_ATT_TBL_,
             P_OLD_LINE_ADJ_ATT_TBL_,
             P_LINE_ADJ_ASSOC_TBL_,
             P_OLD_LINE_ADJ_ASSOC_TBL_,
             P_LINE_SCREDIT_TBL_,
             P_OLD_LINE_SCREDIT_TBL_,
             P_LINE_SCREDIT_VAL_TBL_,
             P_OLD_LINE_SCREDIT_VAL_TBL_,
             P_LINE_PAYMENT_TBL_,
             P_OLD_LINE_PAYMENT_TBL_,
             P_LINE_PAYMENT_VAL_TBL_,
             P_OLD_LINE_PAYMENT_VAL_TBL_,
             P_LOT_SERIAL_TBL_,
             P_OLD_LOT_SERIAL_TBL_,
             P_LOT_SERIAL_VAL_TBL_,
             P_OLD_LOT_SERIAL_VAL_TBL_,
             P_ACTION_REQUEST_TBL_,
             X_HEADER_REC_,
             X_HEADER_VAL_REC_,
             X_HEADER_ADJ_TBL_,
             X_HEADER_ADJ_VAL_TBL_,
             X_HEADER_PRICE_ATT_TBL_,
             X_HEADER_ADJ_ATT_TBL_,
             X_HEADER_ADJ_ASSOC_TBL_,
             X_HEADER_SCREDIT_TBL_,
             X_HEADER_SCREDIT_VAL_TBL_,
             X_HEADER_PAYMENT_TBL_,
             X_HEADER_PAYMENT_VAL_TBL_,
             X_LINE_TBL_,X_LINE_VAL_TBL_,
             X_LINE_ADJ_TBL_,X_LINE_ADJ_VAL_TBL_,
             X_LINE_PRICE_ATT_TBL_,
             X_LINE_ADJ_ATT_TBL_,
             X_LINE_ADJ_ASSOC_TBL_,
             X_LINE_SCREDIT_TBL_,
             X_LINE_SCREDIT_VAL_TBL_,
             X_LINE_PAYMENT_TBL_,
             X_LINE_PAYMENT_VAL_TBL_,
             X_LOT_SERIAL_TBL_,
             X_LOT_SERIAL_VAL_TBL_,
             X_ACTION_REQUEST_TBL_,
             P_RTRIM_DATA);

      if l_debug_level > 0 then
       oe_debug_pub.add('After calling PO');
      end if;

      X_HEADER_REC := Oe_Inbound_Int.PL_TO_SQL1(X_HEADER_REC_);
      X_HEADER_VAL_REC := Oe_Inbound_Int.PL_TO_SQL2(X_HEADER_VAL_REC_);
      X_HEADER_ADJ_TBL := Oe_Inbound_Int.PL_TO_SQL3(X_HEADER_ADJ_TBL_);
      X_HEADER_ADJ_VAL_TBL := Oe_Inbound_Int.PL_TO_SQL4(X_HEADER_ADJ_VAL_TBL_);
      X_HEADER_PRICE_ATT_TBL := Oe_Inbound_Int.PL_TO_SQL5(X_HEADER_PRICE_ATT_TBL_);
      X_HEADER_ADJ_ATT_TBL := Oe_Inbound_Int.PL_TO_SQL6(X_HEADER_ADJ_ATT_TBL_);
      X_HEADER_ADJ_ASSOC_TBL := Oe_Inbound_Int.PL_TO_SQL7(X_HEADER_ADJ_ASSOC_TBL_);
      X_HEADER_SCREDIT_TBL := Oe_Inbound_Int.PL_TO_SQL8(X_HEADER_SCREDIT_TBL_);
      X_HEADER_SCREDIT_VAL_TBL := Oe_Inbound_Int.PL_TO_SQL9(X_HEADER_SCREDIT_VAL_TBL_);
      X_HEADER_PAYMENT_TBL := Oe_Inbound_Int.PL_TO_SQL10(X_HEADER_PAYMENT_TBL_);
      X_HEADER_PAYMENT_VAL_TBL := Oe_Inbound_Int.PL_TO_SQL11(X_HEADER_PAYMENT_VAL_TBL_);
      X_LINE_TBL := Oe_Inbound_Int.PL_TO_SQL12(X_LINE_TBL_);
      X_LINE_VAL_TBL := Oe_Inbound_Int.PL_TO_SQL13(X_LINE_VAL_TBL_);
      X_LINE_ADJ_TBL := Oe_Inbound_Int.PL_TO_SQL14(X_LINE_ADJ_TBL_);
      X_LINE_ADJ_VAL_TBL := Oe_Inbound_Int.PL_TO_SQL15(X_LINE_ADJ_VAL_TBL_);
      X_LINE_PRICE_ATT_TBL := Oe_Inbound_Int.PL_TO_SQL16(X_LINE_PRICE_ATT_TBL_);
      X_LINE_ADJ_ATT_TBL := Oe_Inbound_Int.PL_TO_SQL17(X_LINE_ADJ_ATT_TBL_);
      X_LINE_ADJ_ASSOC_TBL := Oe_Inbound_Int.PL_TO_SQL18(X_LINE_ADJ_ASSOC_TBL_);
      X_LINE_SCREDIT_TBL := Oe_Inbound_Int.PL_TO_SQL19(X_LINE_SCREDIT_TBL_);
      X_LINE_SCREDIT_VAL_TBL := Oe_Inbound_Int.PL_TO_SQL20(X_LINE_SCREDIT_VAL_TBL_);
      X_LINE_PAYMENT_TBL := Oe_Inbound_Int.PL_TO_SQL21(X_LINE_PAYMENT_TBL_);
      X_LINE_PAYMENT_VAL_TBL := Oe_Inbound_Int.PL_TO_SQL22(X_LINE_PAYMENT_VAL_TBL_);
      X_LOT_SERIAL_TBL := Oe_Inbound_Int.PL_TO_SQL23(X_LOT_SERIAL_TBL_);
      X_LOT_SERIAL_VAL_TBL := Oe_Inbound_Int.PL_TO_SQL24(X_LOT_SERIAL_VAL_TBL_);
      X_ACTION_REQUEST_TBL := Oe_Inbound_Int.PL_TO_SQL25(X_ACTION_REQUEST_TBL_);
      X_ACTION_REQUEST_TBL := Oe_Inbound_Int.PL_TO_SQL25(X_ACTION_REQUEST_TBL_);

     -- Bug 8872110
     IF x_return_status = 'S'                                AND
        l_booking_action_index IS NOT NULL                   AND
        x_action_request_tbl_.EXISTS(l_booking_action_index) AND
        x_action_request_tbl_(l_booking_action_index).return_status
                                                            IN ('E','U')
     THEN
       x_return_status := x_action_request_tbl_(l_booking_action_index).return_status;
     END IF;

      IF Oe_Inbound_Int.G_check_action_ret_status IN ('E','U')
           OR
         x_return_status IN ('E', 'U')
      THEN
         if l_debug_level > 0 then
          oe_debug_pub.add('In the Rollback section ');
	 end if;
         ROLLBACK;
      ELSE
         if l_debug_level > 0 then
           oe_debug_pub.add('Commit has been triggered here! ');
         end if;
         COMMIT;
      END IF;

	 -- Populate OM Processing Messages onto the OUT parameter
         -- 'x_messages'.
	 if l_debug_level > 0 then
         oe_debug_pub.add('Populating message_tbl for Genesis');
	 end if;

         -- Ensure to have a clean message object table
         x_messages := OE_MESSAGE_OBJ_T();

         IF ( l_msg_count      > 1  AND
              x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
           FOR i IN 1..l_msg_count LOOP
              x_messages.EXTEND;
              x_messages(i) :=
                   OE_MESSAGE_OBJ(
                     oe_msg_pub.get (p_msg_index => i, p_encoded   => 'F')
                   );
           END LOOP;
         ELSE
            x_messages.EXTEND;
            x_messages(1) := OE_MESSAGE_OBJ(
                    oe_msg_pub.get (p_msg_index => 1, p_encoded => 'F')
                   );
         END IF; -- on l_msg_count > 1 et al.

         -- If debugging is on, add the name of the debug file as an
         -- additional message (so that it can be viewed in the XML
         -- message generated in case of BPEL fault).
         IF ( oe_debug_pub.IsDebugOn ) THEN
            x_messages.EXTEND;
            x_messages(x_messages.Count) :=
                      OE_MESSAGE_OBJ ('Debug File: ' || l_temp_var);
         END IF;

         oe_msg_pub.save_messages(999999999);

   END Process_Order;  -- Overloaded form with newer signature

------------------------------

-- Oe_Inbound_Int.Process_Order(...) API with the older signature.
--
-- Deprecated.  Retained only for backward compatibility purposes.
-- All the clients should use the appropriate overloaded form of the API
-- with newer signature (because the newer signature supports the retrieval
-- of all processing messages through an OUT parameter on it.

PROCEDURE Process_Order (
      P_API_VERSION_NUMBER        NUMBER,
      P_INIT_MSG_LIST             VARCHAR2,
      P_RETURN_VALUES             VARCHAR2,
      P_ACTION_COMMIT             VARCHAR2,
      X_RETURN_STATUS   OUT NOCOPY      VARCHAR2 ,
      X_MSG_COUNT       OUT NOCOPY      NUMBER   ,
      X_MSG_DATA        OUT NOCOPY       VARCHAR2 ,
      P_HEADER_REC OE_ORDER_PUB_HEADER_REC_TYPE,
      P_OLD_HEADER_REC OE_ORDER_PUB_HEADER_REC_TYPE,
      P_HEADER_VAL_REC OE_ORDER_PUB_HEADER_VAL_REC_T,
      P_OLD_HEADER_VAL_REC OE_ORDER_PUB_HEADER_VAL_REC_T,
      P_HEADER_ADJ_TBL OE_ORDER_PUB_HEADER_ADJ_TBL_T,
      P_OLD_HEADER_ADJ_TBL OE_ORDER_PUB_HEADER_ADJ_TBL_T,
      P_HEADER_ADJ_VAL_TBL OE_ORDER_PUB_HEADER_ADJ_VAL_T,
      P_OLD_HEADER_ADJ_VAL_TBL OE_ORDER_PUB_HEADER_ADJ_VAL_T,
      P_HEADER_PRICE_ATT_TBL OE_ORDER_PUB_HEADER_PRICE_ATT,
      P_OLD_HEADER_PRICE_ATT_TBL OE_ORDER_PUB_HEADER_PRICE_ATT,
      P_HEADER_ADJ_ATT_TBL OE_ORDER_PUB_HEADER_ADJ_ATT_T,
      P_OLD_HEADER_ADJ_ATT_TBL OE_ORDER_PUB_HEADER_ADJ_ATT_T,
      P_HEADER_ADJ_ASSOC_TBL OE_ORDER_PUB_HEADER_ADJ_ASSOC,
      P_OLD_HEADER_ADJ_ASSOC_TBL OE_ORDER_PUB_HEADER_ADJ_ASSOC,
      P_HEADER_SCREDIT_TBL OE_ORDER_PUB_HEADER_SCREDIT_T,
      P_OLD_HEADER_SCREDIT_TBL OE_ORDER_PUB_HEADER_SCREDIT_T,
      P_HEADER_SCREDIT_VAL_TBL OE_ORDER_PUB_HEADER_SCREDIT_V,
      P_OLD_HEADER_SCREDIT_VAL_TBL OE_ORDER_PUB_HEADER_SCREDIT_V,
      P_HEADER_PAYMENT_TBL OE_ORDER_PUB_HEADER_PAYMENT_T,
      P_OLD_HEADER_PAYMENT_TBL OE_ORDER_PUB_HEADER_PAYMENT_T,
      P_HEADER_PAYMENT_VAL_TBL OE_ORDER_PUB_HEADER_PAYMENT_V,
      P_OLD_HEADER_PAYMENT_VAL_TBL OE_ORDER_PUB_HEADER_PAYMENT_V,
      P_LINE_TBL OE_ORDER_PUB_LINE_TBL_TYPE,
      P_OLD_LINE_TBL OE_ORDER_PUB_LINE_TBL_TYPE,
      P_LINE_VAL_TBL OE_ORDER_PUB_LINE_VAL_TBL_TYP,
      P_OLD_LINE_VAL_TBL OE_ORDER_PUB_LINE_VAL_TBL_TYP,
      P_LINE_ADJ_TBL OE_ORDER_PUB_LINE_ADJ_TBL_TYP,
      P_OLD_LINE_ADJ_TBL OE_ORDER_PUB_LINE_ADJ_TBL_TYP,
      P_LINE_ADJ_VAL_TBL OE_ORDER_PUB_LINE_ADJ_VAL_TBL,
      P_OLD_LINE_ADJ_VAL_TBL OE_ORDER_PUB_LINE_ADJ_VAL_TBL,
      P_LINE_PRICE_ATT_TBL OE_ORDER_PUB_LINE_PRICE_ATT_T,
      P_OLD_LINE_PRICE_ATT_TBL OE_ORDER_PUB_LINE_PRICE_ATT_T,
      P_LINE_ADJ_ATT_TBL OE_ORDER_PUB_LINE_ADJ_ATT_TBL,
      P_OLD_LINE_ADJ_ATT_TBL OE_ORDER_PUB_LINE_ADJ_ATT_TBL,
      P_LINE_ADJ_ASSOC_TBL OE_ORDER_PUB_LINE_ADJ_ASSOC_T,
      P_OLD_LINE_ADJ_ASSOC_TBL OE_ORDER_PUB_LINE_ADJ_ASSOC_T,
      P_LINE_SCREDIT_TBL OE_ORDER_PUB_LINE_SCREDIT_TBL,
      P_OLD_LINE_SCREDIT_TBL OE_ORDER_PUB_LINE_SCREDIT_TBL,
      P_LINE_SCREDIT_VAL_TBL OE_ORDER_PUB_LINE_SCREDIT_VAL,
      P_OLD_LINE_SCREDIT_VAL_TBL OE_ORDER_PUB_LINE_SCREDIT_VAL,
      P_LINE_PAYMENT_TBL OE_ORDER_PUB_LINE_PAYMENT_TBL,
      P_OLD_LINE_PAYMENT_TBL OE_ORDER_PUB_LINE_PAYMENT_TBL,
      P_LINE_PAYMENT_VAL_TBL OE_ORDER_PUB_LINE_PAYMENT_VAL,
      P_OLD_LINE_PAYMENT_VAL_TBL OE_ORDER_PUB_LINE_PAYMENT_VAL,
      P_LOT_SERIAL_TBL OE_ORDER_PUB_LOT_SERIAL_TBL_T,
      P_OLD_LOT_SERIAL_TBL OE_ORDER_PUB_LOT_SERIAL_TBL_T,
      P_LOT_SERIAL_VAL_TBL OE_ORDER_PUB_LOT_SERIAL_VAL_T,
      P_OLD_LOT_SERIAL_VAL_TBL OE_ORDER_PUB_LOT_SERIAL_VAL_T,
      P_ACTION_REQUEST_TBL OE_ORDER_PUB_REQUEST_TBL_TYPE,
      X_HEADER_REC             OUT NOCOPY OE_ORDER_PUB_HEADER_REC_TYPE ,
      X_HEADER_VAL_REC         OUT NOCOPY OE_ORDER_PUB_HEADER_VAL_REC_T ,
      X_HEADER_ADJ_TBL         OUT NOCOPY OE_ORDER_PUB_HEADER_ADJ_TBL_T ,
      X_HEADER_ADJ_VAL_TBL     OUT NOCOPY OE_ORDER_PUB_HEADER_ADJ_VAL_T ,
      X_HEADER_PRICE_ATT_TBL   OUT NOCOPY OE_ORDER_PUB_HEADER_PRICE_ATT ,
      X_HEADER_ADJ_ATT_TBL     OUT NOCOPY OE_ORDER_PUB_HEADER_ADJ_ATT_T ,
      X_HEADER_ADJ_ASSOC_TBL   OUT NOCOPY OE_ORDER_PUB_HEADER_ADJ_ASSOC ,
      X_HEADER_SCREDIT_TBL     OUT NOCOPY OE_ORDER_PUB_HEADER_SCREDIT_T ,
      X_HEADER_SCREDIT_VAL_TBL OUT NOCOPY OE_ORDER_PUB_HEADER_SCREDIT_V ,
      X_HEADER_PAYMENT_TBL     OUT NOCOPY OE_ORDER_PUB_HEADER_PAYMENT_T ,
      X_HEADER_PAYMENT_VAL_TBL OUT NOCOPY OE_ORDER_PUB_HEADER_PAYMENT_V ,
      X_LINE_TBL              OUT NOCOPY OE_ORDER_PUB_LINE_TBL_TYPE  ,
      X_LINE_VAL_TBL          OUT NOCOPY OE_ORDER_PUB_LINE_VAL_TBL_TYP ,
      X_LINE_ADJ_TBL          OUT NOCOPY OE_ORDER_PUB_LINE_ADJ_TBL_TYP ,
      X_LINE_ADJ_VAL_TBL      OUT NOCOPY OE_ORDER_PUB_LINE_ADJ_VAL_TBL ,
      X_LINE_PRICE_ATT_TBL    OUT NOCOPY OE_ORDER_PUB_LINE_PRICE_ATT_T ,
      X_LINE_ADJ_ATT_TBL      OUT NOCOPY OE_ORDER_PUB_LINE_ADJ_ATT_TBL ,
      X_LINE_ADJ_ASSOC_TBL    OUT NOCOPY OE_ORDER_PUB_LINE_ADJ_ASSOC_T ,
      X_LINE_SCREDIT_TBL      OUT NOCOPY OE_ORDER_PUB_LINE_SCREDIT_TBL ,
      X_LINE_SCREDIT_VAL_TBL  OUT NOCOPY OE_ORDER_PUB_LINE_SCREDIT_VAL ,
      X_LINE_PAYMENT_TBL      OUT NOCOPY OE_ORDER_PUB_LINE_PAYMENT_TBL ,
      X_LINE_PAYMENT_VAL_TBL  OUT NOCOPY OE_ORDER_PUB_LINE_PAYMENT_VAL ,
      X_LOT_SERIAL_TBL        OUT NOCOPY OE_ORDER_PUB_LOT_SERIAL_TBL_T ,
      X_LOT_SERIAL_VAL_TBL    OUT NOCOPY OE_ORDER_PUB_LOT_SERIAL_VAL_T ,
      X_ACTION_REQUEST_TBL    OUT NOCOPY OE_ORDER_PUB_REQUEST_TBL_TYPE ,
      P_RTRIM_DATA VARCHAR2
      )
 IS

  l_messages oe_message_obj_t;
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
  if l_debug_level > 0 then
   oe_debug_pub.add('Oe_Inbound_Int.Process_Order with deprecated signature invoked...');
   oe_debug_pub.add('Calling...');
  end if;

  Process_Order (
	P_API_VERSION_NUMBER  => P_API_VERSION_NUMBER,
	P_INIT_MSG_LIST       => P_INIT_MSG_LIST,
	P_RETURN_VALUES       => P_RETURN_VALUES,
	P_ACTION_COMMIT       => P_ACTION_COMMIT,
	X_RETURN_STATUS       => X_RETURN_STATUS ,
	X_MESSAGES            => l_messages,
	P_HEADER_REC          =>  P_HEADER_REC,
	P_OLD_HEADER_REC      =>  P_OLD_HEADER_REC,
	P_HEADER_VAL_REC      =>  P_HEADER_VAL_REC,
	P_OLD_HEADER_VAL_REC  =>  P_OLD_HEADER_VAL_REC,
	P_HEADER_ADJ_TBL      =>  P_HEADER_ADJ_TBL,
	P_OLD_HEADER_ADJ_TBL  =>  P_OLD_HEADER_ADJ_TBL,
	P_HEADER_ADJ_VAL_TBL  =>  P_HEADER_ADJ_VAL_TBL,
	P_OLD_HEADER_ADJ_VAL_TBL    => P_OLD_HEADER_ADJ_VAL_TBL,
	P_HEADER_PRICE_ATT_TBL      => P_HEADER_PRICE_ATT_TBL,
	P_OLD_HEADER_PRICE_ATT_TBL  => P_OLD_HEADER_PRICE_ATT_TBL,
	P_HEADER_ADJ_ATT_TBL        => P_HEADER_ADJ_ATT_TBL,
	P_OLD_HEADER_ADJ_ATT_TBL    => P_OLD_HEADER_ADJ_ATT_TBL,
	P_HEADER_ADJ_ASSOC_TBL      => P_HEADER_ADJ_ASSOC_TBL,
	P_OLD_HEADER_ADJ_ASSOC_TBL  => P_OLD_HEADER_ADJ_ASSOC_TBL,
	P_HEADER_SCREDIT_TBL        => P_HEADER_SCREDIT_TBL,
	P_OLD_HEADER_SCREDIT_TBL    => P_OLD_HEADER_SCREDIT_TBL,
	P_HEADER_SCREDIT_VAL_TBL    => P_HEADER_SCREDIT_VAL_TBL,
	P_OLD_HEADER_SCREDIT_VAL_TBL =>   P_OLD_HEADER_SCREDIT_VAL_TBL,
	P_HEADER_PAYMENT_TBL         =>   P_HEADER_PAYMENT_TBL,
	P_OLD_HEADER_PAYMENT_TBL    =>    P_OLD_HEADER_PAYMENT_TBL,
	P_HEADER_PAYMENT_VAL_TBL    =>    P_HEADER_PAYMENT_VAL_TBL,
	P_OLD_HEADER_PAYMENT_VAL_TBL  =>  P_OLD_HEADER_PAYMENT_VAL_TBL,
        P_LINE_TBL          =>  P_LINE_TBL,
        P_OLD_LINE_TBL      =>  P_OLD_LINE_TBL,
        P_LINE_VAL_TBL      =>  P_LINE_VAL_TBL,
        P_OLD_LINE_VAL_TBL  =>  P_OLD_LINE_VAL_TBL,
        P_LINE_ADJ_TBL      =>  P_LINE_ADJ_TBL,
        P_OLD_LINE_ADJ_TBL  =>  P_OLD_LINE_ADJ_TBL,
        P_LINE_ADJ_VAL_TBL  =>  P_LINE_ADJ_VAL_TBL,
        P_OLD_LINE_ADJ_VAL_TBL    => P_OLD_LINE_ADJ_VAL_TBL,
        P_LINE_PRICE_ATT_TBL      => P_LINE_PRICE_ATT_TBL,
        P_OLD_LINE_PRICE_ATT_TBL  => P_OLD_LINE_PRICE_ATT_TBL,
        P_LINE_ADJ_ATT_TBL        => P_LINE_ADJ_ATT_TBL,
        P_OLD_LINE_ADJ_ATT_TBL    => P_OLD_LINE_ADJ_ATT_TBL,
        P_LINE_ADJ_ASSOC_TBL      => P_LINE_ADJ_ASSOC_TBL,
        P_OLD_LINE_ADJ_ASSOC_TBL  => P_OLD_LINE_ADJ_ASSOC_TBL,
        P_LINE_SCREDIT_TBL        => P_LINE_SCREDIT_TBL,
        P_OLD_LINE_SCREDIT_TBL    => P_OLD_LINE_SCREDIT_TBL,
        P_LINE_SCREDIT_VAL_TBL    => P_LINE_SCREDIT_VAL_TBL,
        P_OLD_LINE_SCREDIT_VAL_TBL  =>  P_OLD_LINE_SCREDIT_VAL_TBL,
        P_LINE_PAYMENT_TBL          =>  P_LINE_PAYMENT_TBL,
        P_OLD_LINE_PAYMENT_TBL      =>  P_OLD_LINE_PAYMENT_TBL,
        P_LINE_PAYMENT_VAL_TBL      =>  P_LINE_PAYMENT_VAL_TBL,
        P_OLD_LINE_PAYMENT_VAL_TBL  =>  P_OLD_LINE_PAYMENT_VAL_TBL,
        P_LOT_SERIAL_TBL            =>  P_LOT_SERIAL_TBL,
        P_OLD_LOT_SERIAL_TBL        =>  P_OLD_LOT_SERIAL_TBL,
        P_LOT_SERIAL_VAL_TBL        =>  P_LOT_SERIAL_VAL_TBL,
        P_OLD_LOT_SERIAL_VAL_TBL    =>  P_OLD_LOT_SERIAL_VAL_TBL,
        P_ACTION_REQUEST_TBL        =>  P_ACTION_REQUEST_TBL,
	X_HEADER_REC                =>  X_HEADER_REC ,
        X_HEADER_VAL_REC            =>  X_HEADER_VAL_REC ,
        X_HEADER_ADJ_TBL            =>  X_HEADER_ADJ_TBL ,
        X_HEADER_ADJ_VAL_TBL        =>  X_HEADER_ADJ_VAL_TBL ,
        X_HEADER_PRICE_ATT_TBL      =>  X_HEADER_PRICE_ATT_TBL ,
        X_HEADER_ADJ_ATT_TBL        =>  X_HEADER_ADJ_ATT_TBL ,
        X_HEADER_ADJ_ASSOC_TBL      =>  X_HEADER_ADJ_ASSOC_TBL ,
        X_HEADER_SCREDIT_TBL        =>  X_HEADER_SCREDIT_TBL ,
        X_HEADER_SCREDIT_VAL_TBL    =>  X_HEADER_SCREDIT_VAL_TBL ,
        X_HEADER_PAYMENT_TBL        =>  X_HEADER_PAYMENT_TBL ,
        X_HEADER_PAYMENT_VAL_TBL    =>  X_HEADER_PAYMENT_VAL_TBL ,
        X_LINE_TBL                  =>  X_LINE_TBL  ,
        X_LINE_VAL_TBL              =>  X_LINE_VAL_TBL ,
        X_LINE_ADJ_TBL              =>  X_LINE_ADJ_TBL ,
        X_LINE_ADJ_VAL_TBL          =>  X_LINE_ADJ_VAL_TBL ,
        X_LINE_PRICE_ATT_TBL        =>  X_LINE_PRICE_ATT_TBL ,
        X_LINE_ADJ_ATT_TBL          =>  X_LINE_ADJ_ATT_TBL ,
        X_LINE_ADJ_ASSOC_TBL        =>  X_LINE_ADJ_ASSOC_TBL ,
        X_LINE_SCREDIT_TBL          =>  X_LINE_SCREDIT_TBL ,
        X_LINE_SCREDIT_VAL_TBL      =>  X_LINE_SCREDIT_VAL_TBL ,
        X_LINE_PAYMENT_TBL          =>  X_LINE_PAYMENT_TBL ,
        X_LINE_PAYMENT_VAL_TBL      =>  X_LINE_PAYMENT_VAL_TBL ,
        X_LOT_SERIAL_TBL            =>  X_LOT_SERIAL_TBL ,
        X_LOT_SERIAL_VAL_TBL        =>  X_LOT_SERIAL_VAL_TBL ,
        X_ACTION_REQUEST_TBL        =>  X_ACTION_REQUEST_TBL ,
        P_RTRIM_DATA                =>  P_RTRIM_DATA
      );

    if l_debug_level > 0 then
     oe_debug_pub.add('After calling the newer signature of Process_Order...');
     oe_debug_pub.add('Setting x_msg_count and x_msg_data...');
    end if;

    x_msg_count :=  l_messages.COUNT;
    x_msg_data  :=  l_messages(1).message_text;

    if l_debug_level > 0 then
     oe_debug_pub.add('Done... returning to caller...');
    end if;


END Process_Order; -- Overloaded form with the older deprecated signature.

----------------- O2C25: Start ---------
  PROCEDURE Convert_Line_null_to_miss(p_x_line_rec IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type)
  IS
  BEGIN
    oe_genesis_util.Convert_Line_null_to_miss(p_x_line_rec);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  PROCEDURE Convert_hdr_null_to_miss (p_x_header_rec IN OUT NOCOPY  OE_Order_PUB.Header_Rec_Type)
  IS
  BEGIN
    oe_genesis_util.Convert_hdr_null_to_miss (p_x_header_rec);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;
----------------- O2C25: End  --------

END Oe_Inbound_Int;

/
