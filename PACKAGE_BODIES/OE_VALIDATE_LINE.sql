--------------------------------------------------------
--  DDL for Package Body OE_VALIDATE_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VALIDATE_LINE" AS
/* $Header: OEXLLINB.pls 120.52.12010000.16 2010/05/07 07:29:19 spothula ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Validate_Line';
--var added for bug 4171642
g_master_org_id               NUMBER :=  OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID') ;
--g_cust_ord_enabled_flag       varchar2(1):=nvl(FND_PROFILE.Value('ONT_VAL_CUST_ORD_ENABLED_FLAG'),'N'); --bug4343544
-- LOCAL PROCEDURES

-- QUOTING changes
/*-------------------------------------------------------
PROCEDURE:    Check_Negotiation_Attributes
Description:  This procedures validates the order line attributes
              against transaction phase (Negotiation vs Fulfillment).
--------------------------------------------------------*/

PROCEDURE Check_Negotiation_Attributes
( p_line_rec              IN OE_Order_PUB.Line_Rec_Type
, p_old_line_rec          IN OE_Order_PUB.Line_Rec_Type
, x_return_status         IN OUT NOCOPY VARCHAR2
)
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Enter OE_VALIDATE_LINE.Check_Negotiation_Attributes',1);
    oe_debug_pub.add('Phase: '||p_line_rec.transaction_phase_code,1);
  end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

       -- Transaction phase cannot be updated on a saved transaction.

       IF OE_Quote_Util.G_COMPLETE_NEG = 'N' AND
          NOT OE_GLOBALS.EQUAL(p_line_rec.transaction_phase_code
                                ,p_old_line_rec.transaction_phase_code)
       THEN
          FND_MESSAGE.SET_NAME('ONT','OE_PHASE_UPDATE_NOT_ALLOWED');
          OE_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF; -- End of check for UPDATE operation


    -- Start checks specific to the transaction phase

    IF p_line_rec.transaction_phase_code = 'N' THEN

       -- Cannot update following order attributes in negotiation phase

       IF NVL(p_line_rec.arrival_set,fnd_api.g_miss_char)
                <> fnd_api.g_miss_char
          OR NOT OE_GLOBALS.EQUAL(p_line_rec.arrival_set_id
                         ,p_old_line_rec.arrival_set_id)
       THEN
          if l_debug_level > 0 then
             oe_debug_pub.add('arrival set :'||p_line_rec.arrival_set);
             oe_debug_pub.add('arrival set id :'||p_line_rec.arrival_set_id);
             oe_debug_pub.add('old arrival set id :'||p_old_line_rec.arrival_set_id);
          end if;
          FND_MESSAGE.SET_NAME('ONT','OE_CANT_UPDATE_ORDER_ATTR');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
              OE_Order_UTIL.Get_Attribute_Name('ARRIVAL_SET_ID'));
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       IF NVL(p_line_rec.ship_set,fnd_api.g_miss_char)
                <> fnd_api.g_miss_char
          OR NOT OE_GLOBALS.EQUAL(p_line_rec.ship_set_id
                         ,p_old_line_rec.ship_set_id)
       THEN
          if l_debug_level > 0 then
             oe_debug_pub.add('ship set :'||p_line_rec.ship_set);
             oe_debug_pub.add('ship set id :'||p_line_rec.ship_set_id);
             oe_debug_pub.add('old ship set id :'||p_old_line_rec.ship_set_id);
          end if;
          FND_MESSAGE.SET_NAME('ONT','OE_CANT_UPDATE_ORDER_ATTR');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
              OE_Order_UTIL.Get_Attribute_Name('SHIP_SET_ID'));
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
       --for bug 3450282. Added NVL condition to consider g_miss_char during comparision
       IF NOT OE_GLOBALS.EQUAL(NVL(p_line_rec.schedule_ship_date,FND_API.G_MISS_DATE)
                         ,NVL(p_old_line_rec.schedule_ship_date,FND_API.G_MISS_DATE))
       THEN
          FND_MESSAGE.SET_NAME('ONT','OE_CANT_UPDATE_ORDER_ATTR');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
              OE_Order_UTIL.Get_Attribute_Name('SCHEDULE_SHIP_DATE'));
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
       --for bug 3450282. Added NVL condition to consider g_miss_char during comparision
       IF NOT OE_GLOBALS.EQUAL(NVL(p_line_rec.schedule_arrival_date,FND_API.G_MISS_DATE)
                         ,NVL(p_old_line_rec.schedule_arrival_date,FND_API.G_MISS_DATE))
       THEN
          FND_MESSAGE.SET_NAME('ONT','OE_CANT_UPDATE_ORDER_ATTR');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
              OE_Order_UTIL.Get_Attribute_Name('SCHEDULE_ARRIVAL_DATE'));
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       --for bug 3450282. Added NVL condition to consider g_miss_char during comparision
       IF NOT OE_GLOBALS.EQUAL(NVL(p_line_rec.override_atp_date_code,FND_API.G_MISS_CHAR)
                         ,NVL(p_old_line_rec.override_atp_date_code,FND_API.G_MISS_CHAR))
       THEN
          FND_MESSAGE.SET_NAME('ONT','OE_CANT_UPDATE_ORDER_ATTR');
          --The following line was modified for bug 3153680
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Override ATP');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       IF NOT OE_GLOBALS.EQUAL(p_line_rec.reserved_quantity
                         ,p_old_line_rec.reserved_quantity)
       THEN
          --Added for bug 3158444
          IF NOT (( p_old_line_rec.reserved_quantity=FND_API.G_MISS_NUM AND
                                        p_line_rec.reserved_quantity IS NULL)
                 OR (p_line_rec.reserved_quantity=FND_API.G_MISS_NUM AND
                                        p_old_line_rec.reserved_quantity IS NULL))
          THEN
             FND_MESSAGE.SET_NAME('ONT','OE_CANT_UPDATE_ORDER_ATTR');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                OE_Order_UTIL.Get_Attribute_Name('RESERVED_QUANTITY'));
             OE_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
       END IF;

        -- INVCONV OPM Inventory Convergence  as above
       IF NOT OE_GLOBALS.EQUAL(p_line_rec.reserved_quantity2
                         ,p_old_line_rec.reserved_quantity2)
       THEN

          IF NOT (( p_old_line_rec.reserved_quantity2=FND_API.G_MISS_NUM AND
                                        p_line_rec.reserved_quantity2 IS NULL)
                 OR (p_line_rec.reserved_quantity2=FND_API.G_MISS_NUM AND
                                        p_old_line_rec.reserved_quantity2 IS NULL))
          THEN
             FND_MESSAGE.SET_NAME('ONT','OE_CANT_UPDATE_ORDER_ATTR');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                OE_Order_UTIL.Get_Attribute_Name('RESERVED_QUANTITY2'));
             OE_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
       END IF;



       --for bug 3450282. Added NVL condition to consider g_miss_char during comparision
       IF NOT OE_GLOBALS.EQUAL(NVL(p_line_rec.firm_demand_flag,FND_API.G_MISS_CHAR)
                         ,NVL(p_old_line_rec.firm_demand_flag,FND_API.G_MISS_CHAR))
       THEN
          FND_MESSAGE.SET_NAME('ONT','OE_CANT_UPDATE_ORDER_ATTR');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Firm Demand');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
        --for bug 3450282. Added NVL condition to consider g_miss_num during comparision
       IF NOT OE_GLOBALS.EQUAL(NVL(p_line_rec.late_demand_penalty_factor,FND_API.G_MISS_NUM)
                         ,NVL(p_old_line_rec.late_demand_penalty_factor,FND_API.G_MISS_NUM))
       THEN
          FND_MESSAGE.SET_NAME('ONT','OE_CANT_UPDATE_ORDER_ATTR');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Late Demand Penalty');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       -- schedule action is not a DB field so check for not null only
       IF p_line_rec.schedule_action_code IS NOT NULL
       THEN
          FND_MESSAGE.SET_NAME('ONT','OE_CANT_UPDATE_ORDER_ATTR');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
              OE_Order_UTIL.Get_Attribute_Name('SCHEDULE_ACTION_CODE'));
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       -- Return orders not supported
       IF p_line_rec.line_category_code = 'RETURN' THEN
          FND_MESSAGE.SET_NAME('ONT','OE_QUOTE_RETURN_NOT_SUPP');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       -- Internal sales orders not allowed
       IF p_line_rec.order_source_id = 10 THEN
          FND_MESSAGE.SET_NAME('ONT','OE_QUOTE_INT_ORD_NOT_SUPP');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       -- Cancellation operation not supported for quotes
       IF p_line_rec.cancelled_flag = 'Y' THEN
          FND_MESSAGE.SET_NAME('ONT','OE_QUOTE_CANCEL_NOT_SUPP');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

    END IF; -- End of check if phase = F/N

  if l_debug_level > 0 then
    oe_debug_pub.add('Exit OE_VALIDATE_LINE.Check_Negotiation_Attributes',1);
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (  G_PKG_NAME ,
        'Check_Negotiation_Attributes'
      );
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Check_Negotiation_Attributes;

-- Check_Book_Reqd_Attributes
-- This procedure checks for all the attributes that are required
-- on booked order lines.
-- IMPORTANT:
-- 1) With the fix for bug 1785143, booking would query
-- only the attributes that are being checked for in this
-- procedure if ASO and EDI products are not installed on the instance.
-- Therefore, if you add checks for/based on attributes that
-- were not being accessed before your change in this procedure,
-- please add it to the query_lines cursor and in the fetch
-- from the cursor in OEXUBOKB.pls - procedure update_booked_flag.
-- 2) Anytime you add new validation in this procedure, please add
-- the same to Check_Book_Reqd_Attributes procedure in OEXVCLNB.pls.
-- OEXVCLNB.pls is used to validate attributes when importing closed
-- orders.


PROCEDURE Check_Book_Reqd_Attributes
( p_line_rec           IN OE_Order_PUB.Line_Rec_Type
, p_old_line_rec       IN OE_Order_PUB.Line_Rec_Type
, x_return_status      IN OUT NOCOPY VARCHAR2
)
IS
l_proj_ref_enabled                              NUMBER;
l_proj_control_level                    NUMBER;
l_calculate_tax_flag                    VARCHAR2(1) := 'N';
--l_line_type_rec                         OE_Order_Cache.Line_Type_Rec_Type;
l_item_type_code                                VARCHAR2(30);
l_revision_controlled                   VARCHAR2(1);
l_rule_type                             VARCHAR2(10);
l_tax_calculation_event_code            VARCHAR2(30);
--key Transaction Dates
l_hdr_booked_date                       DATE ;
l_cust_trx_type_id                      NUMBER := 0;
l_cust_trx_rec_type OE_ORDER_CACHE.cust_trx_rec_type;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

        IF l_debug_level > 0 then
            OE_DEBUG_PUB.Add('Entering OE_VALIDATE_LINE.Check_Book_Reqd_Attributes',1);
        END IF;
        -- Check for fields required on a booked order line

        IF p_line_rec.sold_to_org_id IS NULL THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('SOLD_TO_ORG_ID'));
             OE_MSG_PUB.ADD;
        END IF;

        IF p_line_rec.invoice_to_org_id IS NULL THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('INVOICE_TO_ORG_ID'));
             OE_MSG_PUB.ADD;
        END IF;

        IF p_line_rec.tax_exempt_flag IS NULL THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('TAX_EXEMPT_FLAG'));
             OE_MSG_PUB.ADD;
        END IF;


        -- Item, Quantity and UOM Required
        IF p_line_rec.inventory_item_id IS NULL THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('INVENTORY_ITEM_ID'));
             OE_MSG_PUB.ADD;
        END IF;

        IF p_line_rec.order_quantity_uom IS NULL THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('ORDER_QUANTITY_UOM'));
             OE_MSG_PUB.ADD;
        END IF;

     -- Fix bug 1277092: ordered quantity should not be = 0 on a booked line
        IF p_line_rec.ordered_quantity IS NULL
           OR p_line_rec.ordered_quantity = 0 THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('ORDERED_QUANTITY'));
             OE_MSG_PUB.ADD;
        END IF;

        -- For all items that are NOT included items OR config items,
        -- price list, unit selling price and unit list price are required.

     IF p_line_rec.line_category_code = 'RETURN' THEN
                l_item_type_code := OE_Line_Util.Get_Return_Item_Type_Code
                                                        (p_line_rec);
        ELSE
                l_item_type_code := p_line_rec.item_type_code;
     END IF;

/*
  If p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE Then
       --Fix bug 1759025
       --Move this validation to pricing integration OEXVADJB.pls. Fix bug 1650652
       Null;
  Else
*/
        IF (l_item_type_code <> 'INCLUDED'
            AND l_item_type_code <> 'CONFIG')
        THEN

         -- Move this validation to pricing integration OEXVADJB.pls. Fix bug 1650652
         -- Except in Cases 1 and 2 below when pricing will not be called

         -- Case 1: If user is explicitly updating the value of selling price to
         -- null, then raise error if selling price is null
         IF p_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
            AND NOT OE_GLOBALS.EQUAL(p_line_rec.unit_selling_price
                                ,p_old_line_rec.unit_selling_price) THEN

           IF p_line_rec.unit_selling_price IS NULL THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('UNIT_SELLING_PRICE'));
                OE_MSG_PUB.ADD;
           END IF;

         END IF;


         -- Case 2: If booking is calling this procedure, then do the check for all
         -- 3 pricing attributes
         IF p_line_rec.operation <> OE_GLOBALS.G_OPR_CREATE
            AND NOT OE_GLOBALS.EQUAL(p_line_rec.booked_flag
                                ,p_old_line_rec.booked_flag) THEN

        	 --ER 9059812
		 --LSP Project OM Changes
		 -- Price list , price are not mandatoy for LSP orders during booking


		 IF (WSH_INTEGRATION.Validate_Oe_Attributes(p_line_rec.order_source_id) = 'Y') THEN
			   IF p_line_rec.price_list_id IS NULL THEN
				x_return_status := FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
				FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
					OE_Order_UTIL.Get_Attribute_Name('PRICE_LIST_ID'));
				OE_MSG_PUB.ADD;
			   END IF;


			   IF p_line_rec.unit_list_price IS NULL THEN
				x_return_status := FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
				FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
					OE_Order_UTIL.Get_Attribute_Name('UNIT_LIST_PRICE'));
				OE_MSG_PUB.ADD;
			   END IF;

			   IF p_line_rec.unit_selling_price IS NULL THEN
				x_return_status := FND_API.G_RET_STS_ERROR;
				FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
				FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
					OE_Order_UTIL.Get_Attribute_Name('UNIT_SELLING_PRICE'));
				OE_MSG_PUB.ADD;
			   END IF;
		  END IF;


          END IF;

        END IF; -- End of check for pricing attributes

        -- Fix bug 1262790
        -- Ship To and Payment Term required on ORDER lines,
        -- NOT on RETURN lines

        IF p_line_rec.line_category_code <> OE_GLOBALS.G_RETURN_CATEGORY_CODE THEN

          IF p_line_rec.ship_to_org_id IS NULL THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('SHIP_TO_ORG_ID'));
                OE_MSG_PUB.ADD;
          END IF;

          IF p_line_rec.payment_term_id IS NULL THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('PAYMENT_TERM_ID'));
             OE_MSG_PUB.ADD;
          END IF;

          IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
          IF p_line_rec.item_type_code <> 'SERVICE' THEN
             IF p_line_rec.accounting_rule_id IS NOT NULL AND
                p_line_rec.accounting_rule_id <> FND_API.G_MISS_NUM THEN
                IF l_debug_level > 0 then
                oe_debug_pub.add('Getting accounting rule type');
                END IF;
                SELECT type
                INTO l_rule_type
                FROM ra_rules
                WHERE rule_id = p_line_rec.accounting_rule_id;
                IF l_debug_level > 0 then
                oe_debug_pub.add('Rule_Type is :'||l_rule_type||': accounting rule duration is: '||p_line_rec.accounting_rule_duration);
                END IF;
                IF l_rule_type = 'ACC_DUR' THEN
                   IF p_line_rec.accounting_rule_duration IS NULL THEN
                      x_return_status := FND_API.G_RET_STS_ERROR;
                      FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                      FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                      OE_Order_UTIL.Get_Attribute_Name('ACCOUNTING_RULE_DURATION'));
                      OE_MSG_PUB.ADD;
                   END IF; -- end of accounting_rule_duration null
                END IF; -- end of variable accounting rule type

-- WEBROOT ER bug 6826344 start
           oe_debug_pub.add(' before new rule validations');

           IF l_rule_type = 'PP_DR_PP' OR l_rule_type = 'PP_DR_ALL' THEN
               oe_debug_pub.add('inside new rule validation conditions');

               IF p_line_rec.service_start_date IS NULL THEN
	              oe_debug_pub.add(' inside new rule validation conditions service start date');
                      x_return_status := FND_API.G_RET_STS_ERROR;
                      FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Accounting Rule Start Date' );
                      OE_MSG_PUB.ADD;
               END IF;
               IF p_line_rec.service_end_date IS NULL THEN
                      x_return_status := FND_API.G_RET_STS_ERROR;
                      FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                      FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'Accounting Rule End Date' );
                      OE_MSG_PUB.ADD;
               END IF;

         END IF;

-- WEBROOT ER bug 6826344 end

             END IF; -- end of accounting_rule_id not null
          END IF;  -- end of non-service line
          END IF;  -- end of code release level

        END IF;


        -- Warehouse and schedule date required on RETURN lines

        IF p_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE THEN

           IF p_line_rec.ship_from_org_id IS NULL THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_RETURN_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('SHIP_FROM_ORG_ID'));
                OE_MSG_PUB.ADD;
        END IF;

           IF p_line_rec.request_date IS NULL THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_RETURN_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('REQUEST_DATE'));
                OE_MSG_PUB.ADD;
        END IF;

        END IF;

     /* Added by Manish */

     IF p_line_rec.tax_date IS NULL
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_RETURN_ATTRIBUTE');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('TAX_DATE'));
         OE_MSG_PUB.ADD;
     END IF;

        -- Tax code is required under following conditions.
        -- 1. The tax hadnling is required at line level.
        --    (i.e. Tax_exempt_flag = 'R'-Required.)
        -- 2. The calculate tax flag on customer transaction type for this line
        --    type is set to Yes.

  --7306510
      --Following booking validation that requires 'Tax Classification Code' when the AR trx type has
      -- 'Default tax Classfication' checked will no more be done.This is to follow what AR has done (AR has
      --- completly removed this validation )

/*
     IF p_line_rec.tax_code IS NULL THEN


        IF p_line_rec.commitment_id IS NOT NULL AND
           p_line_rec.commitment_id <> FND_API.G_MISS_NUM THEN
           BEGIN
              SELECT NVL(cust_type.subsequent_trx_type_id,cust_type.cust_trx_type_id)
              INTO l_cust_trx_type_id
              FROM ra_cust_trx_types cust_type,ra_customer_trx cust_trx
              WHERE cust_type.cust_trx_type_id = cust_trx.cust_trx_type_id
              AND cust_trx.customer_trx_id = p_line_rec.commitment_id;

              IF l_debug_level > 0 THEN
                 oe_debug_pub.add( 'value of commitment customer trx type id '||l_cust_trx_type_id,1);
              END IF;

           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 l_cust_trx_type_id := 0;
              WHEN OTHERS THEN
                 null;
           END;
        ELSE
           l_cust_trx_type_id := OE_Invoice_PUB.Get_Customer_Transaction_Type(p_line_rec);
        END IF;
        IF l_debug_level > 0 THEN
           oe_debug_pub.add( 'value of customer trx type id '||l_cust_trx_type_id,1);
        END IF;

        IF l_cust_trx_type_id IS NOT NULL AND l_cust_trx_type_id <> 0 THEN
            l_cust_trx_rec_type := OE_ORDER_CACHE.Load_Cust_Trx_Type(l_cust_Trx_type_id);
            l_calculate_tax_flag := l_cust_trx_rec_type.tax_calculation_flag;
        END IF;

       IF l_debug_level > 0 THEN
          oe_debug_pub.add( 'value of tax_calculation_flag '||l_calculate_tax_flag,1);
       END IF;

-- end bug#5462464

--      l_line_type_rec := OE_Order_Cache.Load_Line_Type(p_line_rec.line_type_id);

    -- fix for bug 1701388 - commented the following code
            -- Fix bug#1098412: check for calculate tax flag ONLY if receivable
         -- transaction type EXISTS on the line type
       IF l_line_type_rec.cust_trx_type_id IS NOT NULL
          THEN

                SELECT tax_calculation_flag
                INTO l_calculate_tax_flag
                FROM RA_CUST_TRX_TYPES
                WHERE CUST_TRX_TYPE_ID = l_line_type_rec.cust_trx_type_id;

       END IF;



          IF (l_calculate_tax_flag = 'Y' OR p_line_rec.tax_exempt_flag = 'R')
          THEN

            SELECT TAX_CALCULATION_EVENT_CODE
            INTO   l_tax_calculation_event_code
            FROM   oe_transaction_types_all
            WHERE  transaction_type_id
                   = OE_Order_Cache.g_header_rec.order_type_id;

            IF nvl(l_tax_calculation_event_code, 'ENTERING') IN ('ENTERING', 'BOOKING') THEN

                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('ONT','OE_VAL_TAX_CODE_REQD');
                OE_MSG_PUB.ADD;
            END IF;
          END IF;

     END IF;

--This block has been repleaced by the following for 1888018
     -- Service Duration is required on SERVICE lines
       IF l_item_type_code = 'SERVICE' THEN
           IF p_line_rec.service_duration IS NULL THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_SERVICE_DURATION');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                    OE_Order_UTIL.Get_Attribute_Name('SERVICE_DURATION'));
             OE_MSG_PUB.ADD;
        END IF;
       END IF;
*/


IF l_item_type_code = 'SERVICE' THEN
           IF p_line_rec.service_coterminate_flag = 'Y' OR
              p_line_rec.service_reference_type_code = 'CUSTOMER_PRODUCT' THEN
             IF p_line_rec.service_start_date IS NULL THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE', OE_Order_UTIL.Get_Attribute_Name('SERVICE_START_DATE'));
                OE_MSG_PUB.ADD;
             END IF;
             IF p_line_rec.service_end_date IS NULL THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE', OE_Order_UTIL.Get_Attribute_Name('SERVICE_END_DATE'));
                OE_MSG_PUB.ADD;
             END IF;
           END IF;

           IF p_line_rec.service_duration IS NULL THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                    OE_Order_UTIL.Get_Attribute_Name('SERVICE_DURATION'));
                OE_MSG_PUB.ADD;
           END IF;
           IF p_line_rec.service_period IS NULL THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                    OE_Order_UTIL.Get_Attribute_Name('SERVICE_PERIOD'));
                OE_MSG_PUB.ADD;
           END IF;
       END IF;
       /* End of 1888018 change */

   ------------------------------------------------------------------------
    --Check over return
   ------------------------------------------------------------------------

    IF p_line_rec.line_category_code = 'RETURN' AND
       p_line_rec.reference_line_id is not NULL AND
       p_line_rec.cancelled_flag <> 'Y'
    THEN
        IF (OE_LINE_UTIL.Is_Over_Return(p_line_rec)) THEN
                  x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('ONT', 'OE_RETURN_INVALID_QUANTITY');
            OE_MSG_PUB.ADD;
        END IF;

    END IF;

--key Transaction dates
    l_hdr_booked_date := oe_order_cache.g_header_rec.booked_date ;
    IF l_hdr_booked_date = FND_API.G_MISS_DATE or l_hdr_booked_date IS NULL THEN
        l_hdr_booked_date := sysdate ;
    END IF ;

    IF (OE_CODE_CONTROL.Code_Release_Level >= '110509' and  p_line_rec.order_firmed_date > l_hdr_booked_date
                      and p_line_rec.creation_date <= l_hdr_booked_date) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('ONT','ONT_ORDER_FIRMED_DATE_INVALID');
        OE_MSG_PUB.Add;
    END IF;
--end

    /* Fix Bug 2429989: Returning Revision Controlled Items */

    /* Need to take out this validation as a fix for 3230755 */

     --- commented out-----
    /*
    IF p_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE THEN
      IF p_line_rec.item_revision = FND_API.G_MISS_CHAR OR
         p_line_rec.item_revision IS NULL THEN
        Begin
          select decode(revision_qty_control_code, 2, 'Y', 'N')
          into   l_revision_controlled
          from   mtl_system_items
          where  inventory_item_id = p_line_rec.inventory_item_id
          and    organization_id   = OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID');
          Exception
            When NO_DATA_FOUND Then
              l_revision_controlled := 'N';
        End;
        IF l_revision_controlled = 'Y' THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_RETURN_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', OE_Order_UTIL.Get_Attribute_Name('ITEM_REVISION'));
          OE_MSG_PUB.ADD;
        END IF;
      END IF;
    END IF;
   */
    IF l_debug_level > 0 then
    OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_LINE.Check_Book_Reqd_Attributes',1);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Book_Reqd_Attributes'
            );
        END IF;
END Check_Book_Reqd_Attributes;



----------------------------------------------------
-- Local Procedures for ER 2502504
-- This Procedure validates Ship Sets and SMC Models.
-- Validation is done when lines are being added to Pick
-- Released Ship Sets and SMC Models. This is called from
-- procedure Entity.
-----------------------------------------------------------

Procedure Validate_ShipSet_SMC
( p_line_rec       IN    OE_Order_PUB.Line_Rec_Type
 ,p_old_line_rec   IN    OE_Order_PUB.Line_Rec_Type
 ,x_return_status  OUT   NOCOPY   VARCHAR2
  )
IS
  l_debug_level      CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_shipset_enforce  VARCHAR2(1);
  l_set_name         VARCHAR2(30);
  l_model_name       VARCHAR2(30);
  l_model_item_id    NUMBER;
  l_smc_model        NUMBER := 0;
  l_ship_set         NUMBER := 0;
BEGIN

    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    IF l_debug_level > 0 then
       OE_DEBUG_PUB.Add('Entering OE_VALIDATE_LINE.Validate_Shipset_SMC',1);
    END IF;

    -- Select statement to check the Ship Set Enforce Parameter.
    BEGIN
        SELECT Enforce_Ship_Set_And_Smc
          INTO l_shipset_enforce
          FROM Wsh_Shipping_Parameters
          WHERE Organization_Id = p_line_rec.ship_from_org_Id;
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
              NULL;
         WHEN OTHERS THEN
              NULL;
    END;


    IF NOT OE_GLOBALS.Equal(p_line_rec.ship_set_id,
                            p_old_line_rec.ship_set_id) THEN

       -- Select statement to check whether the set is pick released.
/*
       SELECT  count(*)
         INTO  l_ship_set
         FROM  Wsh_Delivery_Details
        WHERE  Ship_Set_Id = p_line_rec.ship_set_id
          AND  Source_Code = 'OE'
          AND  Source_Header_Id = p_line_rec.header_id
          AND  Released_Status In ('S','Y','C')
          AND  ROWNUM = 1;  -- 3229707 Removed 'B' from Released_Status check
*/
       SELECT count(*)
        INTO   l_ship_set
        FROM   wsh_delivery_details wdd
        WHERE  wdd.ship_set_id = p_line_rec.ship_set_id
        AND    wdd.source_code = 'OE'
        AND    wdd.source_header_id = p_line_rec.header_id
        AND   ((wdd.released_status = 'C')
        OR EXISTS (select wda.delivery_detail_id
        FROM   wsh_delivery_assignments wda, wsh_new_deliveries wnd
        WHERE  wda.delivery_detail_id = wdd.delivery_detail_id
        AND    wda.delivery_id = wnd.delivery_id
        AND    wnd.status_code in ('CO', 'IT', 'CL', 'SA')))
        AND rownum = 1;

       IF  l_ship_set > 0 AND l_shipset_enforce = 'Y' THEN
               FND_MESSAGE.Set_Name ('ONT','ONT_SET_PICK_RELEASED');
               BEGIN
                SELECT SET_NAME
                INTO l_set_name
                FROM OE_SETS
                WHERE set_id = p_line_rec.ship_set_id;
               EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_set_name := null;
               END;
               FND_MESSAGE.Set_Token('SHIP_SET',l_set_name);
               OE_MSG_PUB.Add;
               x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

    END IF;


    IF  p_line_rec.top_model_line_id IS NOT NULL AND
        p_line_rec.top_model_line_id <> p_line_rec.line_id  AND
        p_line_rec.ship_model_complete_flag = 'Y' THEN

       -- Select statement to check whether the SMC is pick released.

       -- Bug 4766576, removed B from Released_Status

       SELECT count(*)
         INTO l_smc_model
         FROM Wsh_Delivery_Details
        WHERE Ship_Model_Complete_Flag = 'Y'
          AND Top_Model_Line_Id  = p_line_rec.top_model_line_id
          AND Source_Header_Id = p_line_rec.header_id
          AND Source_Code = 'OE'
          AND Released_Status In ('S','Y','C')
          AND ROWNUM = 1;

       IF  l_smc_model  > 0 AND l_shipset_enforce = 'Y' THEN
           FND_MESSAGE.Set_Name ('ONT','ONT_SMC_PICK_RELEASED');
           BEGIN
                SELECT ORDERED_ITEM,inventory_item_id
                INTO l_model_name,l_model_item_id
                FROM OE_ORDER_LINES
                WHERE line_id = p_line_rec.top_model_line_id;
               EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_model_name := null;
            END;
            FND_MESSAGE.Set_Token('MODEL',nvl(l_model_name,l_model_item_id));
            OE_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;


    IF l_debug_level > 0 then
       OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_LINE.Validate_Shipset_SMC:'
                                                     ||x_return_status,1);
    END IF;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
           if l_debug_level > 0 then
                OE_DEBUG_PUB.Add('Expected Error in Validate_Shipset_SMC ',2);
           End if;

           x_return_status := FND_API.G_RET_STS_ERROR;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           if l_debug_level > 0 then
              OE_DEBUG_PUB.Add('Unexpected Error in Validate_Shipset_SMC:'||SqlErrm, 1);
           End if;

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
               OE_MSG_PUB.Add_Exc_Msg
                               (   'OE_VALIDATE_LINE',
                                  'Validate_Shipset_SMC');
           END IF;
END Validate_Shipset_SMC;


FUNCTION Get_Date_Type
( p_header_id      IN NUMBER)
RETURN VARCHAR2
IS
l_order_date_type_code   VARCHAR2(30) := null;
BEGIN

  SELECT order_date_type_code
  INTO   l_order_date_type_code
  FROM   oe_order_headers
  WHERE  header_id = p_header_id;

  RETURN l_order_date_type_code;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
        RETURN NULL;
  WHEN OTHERS THEN
       RETURN null;
END Get_Date_Type;

PROCEDURE Validate_Decimal_Quantity
                ( p_item_id                     IN  NUMBER
                , p_item_type_code              IN  VARCHAR2
                , p_input_quantity              IN  NUMBER
                , p_uom_code                    IN  VARCHAR2
                , p_ato_line_id                 IN  NUMBER
                , p_line_id                     IN  NUMBER
                , p_line_num                    IN  VARCHAR2
                -- 3705273
                , p_action_split                 IN  VARCHAR2 := 'N'
                , x_output_quantity             OUT NOCOPY NUMBER
                , x_return_status               IN OUT NOCOPY VARCHAR2
                ) IS
l_validated_quantity    NUMBER;
l_primary_quantity       NUMBER;
l_qty_return_status      VARCHAR2(1);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
        IF l_debug_level > 0 then
        OE_DEBUG_PUB.Add('Entering OE_VALIDATE_LINE.Validate_Decimal_Quantity',1);
        END IF;
         -- validate input quantity
         -- Changes for Decimal ATO's

         IF (p_input_quantity is not null AND
             p_input_quantity <> FND_API.G_MISS_NUM) THEN

           IF trunc(p_input_quantity) <> p_input_quantity THEN
             IF l_debug_level > 0 then
             oe_debug_pub.add('input quantity is decimal',2);
             END IF;

             IF p_item_type_code is not NULL THEN

                IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

                    IF p_item_type_code IN ('MODEL', 'KIT','CLASS','INCLUDED', 'CONFIG') OR
                      (p_item_type_code  = 'OPTION' AND
                        (p_ato_line_id is NULL OR
                          p_ato_line_id  = p_line_id)) THEN
                            IF l_debug_level > 0 then
                            OE_DEBUG_PUB.Add('item is config related with decimal qty',2);
                            END IF;
                            FND_MESSAGE.SET_NAME('ONT', 'OE_CONFIG_NO_DECIMALS');
                            FND_MESSAGE.SET_TOKEN('ITEM', nvl(OE_Id_To_Value.Inventory_Item(p_item_id),p_item_id));
                            FND_Message.Set_Token('LINE_NUM', p_line_num);
                            OE_MSG_PUB.Add;
                            x_return_status := FND_API.G_RET_STS_ERROR;
                    END IF;

                 ELSE

                    IF p_item_type_code IN ('MODEL', 'KIT','CLASS','INCLUDED','OPTION', 'CONFIG') THEN
                        IF l_debug_level > 0 then
                         OE_DEBUG_PUB.Add('item is config related with decimal qty',2);
                        END IF;
                         FND_MESSAGE.SET_NAME('ONT', 'OE_CONFIG_NO_DECIMALS');
                         FND_MESSAGE.SET_TOKEN('ITEM', nvl(OE_Id_To_Value.Inventory_Item(p_item_id),p_item_id));
                         FND_Message.Set_Token('LINE_NUM', p_line_num);
                         OE_MSG_PUB.Add;
                         x_return_status := FND_API.G_RET_STS_ERROR;
                    END IF;

                 END IF;

             END IF; -- item_type_code is null
           END IF; -- if not decimal qty

/* Moved this code out nocopy of the input_quantity IF statement for bug 2253207 */
           IF l_debug_level > 0 then
           oe_debug_pub.add('before calling inv decimals api',2);
           END IF;
           inv_decimals_pub.validate_quantity(
                p_item_id          => p_item_id,
                p_organization_id  =>
                      OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID'),
                p_input_quantity   => p_input_quantity,
                p_uom_code         => p_uom_code,
                x_output_quantity  => l_validated_quantity,
                x_primary_quantity => l_primary_quantity,
                x_return_status    => l_qty_return_status);

            IF l_qty_return_status = 'W' OR l_qty_return_status = 'E' THEN
              IF l_debug_level > 0 then
              oe_debug_pub.add('inv decimal api return ' || l_qty_return_status,2);
              oe_debug_pub.add('input_qty ' || p_input_quantity,2);
              oe_debug_pub.add('l_pri_qty ' || l_primary_quantity,2);
              oe_debug_pub.add('l_val_qty ' || l_validated_quantity,2);
              END IF;
              x_output_quantity := l_validated_quantity;

              /* bug 2926436 */
              -- bug 3705273 condition added for split lines.
              IF l_qty_return_status = 'W' THEN
                 IF OE_CONFIG_UTIL.CASCADE_CHANGES_FLAG = 'Y' OR
                    OE_CONFIG_PVT.OECFG_VALIDATE_CONFIG = 'N' OR
                    p_action_split = 'Y' THEN
                     IF l_debug_level > 0 then
                       OE_DEBUG_PUB.Add('do not error out,cascading',1);
                     END IF;
                   x_return_status := FND_API.G_RET_STS_SUCCESS;
                 ELSE
                   fnd_message.set_name('ONT', 'OE_DECIMAL_MAX_PRECISION');
                   -- move INV error message to OE message stack
                   oe_msg_pub.add;
                   x_return_status := FND_API.G_RET_STS_ERROR;
                 END IF;
              ELSIF l_qty_return_status = 'E' THEN
                   oe_msg_pub.add;
                   x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

            ELSIF l_qty_return_status = 'S' THEN
               x_output_quantity := p_input_quantity;
            END IF;

         END IF; -- quantity is null
        IF l_debug_level > 0 then
        OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_LINE.Validate_Decimal_Quantity',1);
        END IF;
END Validate_Decimal_Quantity;

/*---------------------------------------------------------------------
PROCEDURE Decimal_Ratio_Check
Description: This procedure was initially part of package OE_CONFIG_UTIL
This is has been moved here becuase this code is common for all both cz
and bill validation. This checks whether there is any decimal ratio exists
between model and children and raises an error. After pack J decimal ratios
for ATO options are allowed.
-----------------------------------------------------------------------*/

PROCEDURE Decimal_Ratio_Check
 (p_line_rec      IN    OE_ORDER_PUB.Line_rec_type
 ,x_return_status OUT   NOCOPY VARCHAR2)
IS
  l_ordered_item        VARCHAR2(2000);
  l_item_type_code      VARCHAR2(30);
  l_inv_item_id         NUMBER;
  l_ordered_quantity    NUMBER;
  l_indivisible_flag      VARCHAR2(1);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
     OE_DEBUG_PUB.ADD('Entering Decimal_ratio_check '||p_line_rec.line_id, 1);
     OE_DEBUG_PUB.ADD('Item Type:'||p_line_rec.item_type_code, 1);
  END IF;

  SELECT ordered_item, item_type_code,inventory_item_id,ordered_quantity
  INTO   l_ordered_item, l_item_type_code,l_inv_item_id,l_ordered_quantity
  FROM   oe_order_lines
  WHERE  line_id = p_line_rec.top_model_line_id;

  IF MOD(p_line_rec.ordered_quantity,l_ordered_quantity) <> 0 THEN

    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

       -- No Checks will be done for ATO Options.

       IF p_line_rec.ato_line_id is not null AND
          p_line_rec.item_type_code = 'OPTION' AND
          p_line_rec.ato_line_id <> p_line_rec.line_id THEN
            IF l_debug_level  > 0 THEN
               OE_DEBUG_PUB.ADD('ATO Option:'||p_line_rec.line_id, 1);
            END IF;

            SELECT INDIVISIBLE_FLAG
            INTO   l_indivisible_flag
            FROM   mtl_system_items
            WHERE  inventory_item_id = p_line_rec.inventory_item_id
            AND    organization_id   =
                   OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');

            IF nvl(l_indivisible_flag, 'N') = 'N' THEN
              IF l_debug_level  > 0 THEN
                OE_DEBUG_PUB.ADD('this Option can have decimal ratio', 1);
              END IF;
              RETURN;
            ELSE
              IF FLOOR(p_line_rec.ordered_quantity) <>
                 p_line_rec.ordered_quantity THEN
                IF l_debug_level  > 0 THEN
                  OE_DEBUG_PUB.ADD
                  ('this Option has decimal qty no need to check ratio', 1);
                END IF;
                RETURN;
              END IF;
            END IF;
       END IF;
    END IF;

    FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_DECIMAL_RATIO');

    FND_MESSAGE.Set_TOKEN('ITEM', nvl(p_line_rec.ordered_item,
                                    p_line_rec.inventory_item_id));
    FND_MESSAGE.Set_TOKEN('TYPECODE', p_line_rec.item_type_code);
    FND_MESSAGE.Set_TOKEN('VALUE',
                        to_char(l_ordered_quantity/p_line_rec.ordered_quantity));

    FND_MESSAGE.Set_TOKEN('MODEL', nvl(l_ordered_item,l_inv_item_id));
    FND_MESSAGE.Set_TOKEN('PTYPECODE', l_item_type_code);

    OE_MSG_PUB.Add;

    x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Leaving decimal_ratio_check' , 3 );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Decimal_ratio_check '|| sqlerrm , 1);
    END IF;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Decimal_Ratio_Check;



Procedure Validate_Line_Type(p_line_rec     IN oe_order_pub.line_rec_type,
                                            p_old_line_rec IN oe_order_pub.line_rec_type)
IS

lorder_type_id     NUMBER;
lexists            VARCHAR2(30);
lprocessname       VARCHAR2(80);
l_new_wf_item_type VARCHAR2(30);
l_old_wf_item_type VARCHAR2(30);
lline_category_code VARCHAR2(30);

CURSOR find_LineProcessname IS
 SELECT 'EXISTS'
 FROM  oe_workflow_assignments a
 WHERE a.line_type_id = p_line_rec.line_type_id
 AND   nvl(a.item_type_code,nvl(l_new_wf_item_type,'-99')) = nvl(l_new_wf_item_type,'-99')
 AND   a.process_name = lprocessname
 AND   a.order_type_id = lorder_type_id
 AND   sysdate BETWEEN A.START_DATE_ACTIVE
 AND   nvl( A.END_DATE_ACTIVE, sysdate + 1 )
 ORDER BY a.item_type_code ;

CURSOR Get_Order_Type IS
 SELECT order_type_id
 FROM   oe_order_headers
 WHERE  header_id = p_line_rec.header_id ;

Cursor find_config_assign is
 SELECT 'EXISTS'
 FROM   oe_workflow_assignments a
 WHERE  a.line_type_id = p_line_rec.line_type_id
 AND    a.item_type_code = l_new_wf_item_type
 AND       a.order_type_id = lorder_type_id
 AND    sysdate between A.START_DATE_ACTIVE
 AND    nvl( A.END_DATE_ACTIVE, sysdate + 1 );

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
        IF l_debug_level > 0 then
        OE_DEBUG_PUB.Add('Entering OE_VALIDATE_LINE.Validate_Line_Type',1);
        END IF;

      /* Added for the bug #3257965.
         Validation for Line Type and Line Category.
      */
      IF (NOT OE_GLOBALS.EQUAL(p_line_rec.line_category_code,p_old_line_rec.line_category_code))
         OR (NOT OE_GLOBALS.EQUAL(p_line_rec.line_type_id,p_old_line_rec.line_type_id))
      THEN
        IF l_debug_level > 0 then
        OE_DEBUG_PUB.Add('IN  OE_VALIDATE_LINE.Validate_Line_Type old line cate: '||p_old_line_rec.line_category_code);
        OE_DEBUG_PUB.Add('IN  OE_VALIDATE_LINE.Validate_Line_Type new line cate: '||p_line_rec.line_category_code);
        OE_DEBUG_PUB.Add('IN OE_VALIDATE_LINE.Validate_Line_Type old line type Id: '||p_old_line_rec.line_type_id);
        OE_DEBUG_PUB.Add('IN  OE_VALIDATE_LINE.Validate_Line_Type new line type Id: '||p_line_rec.line_type_id);
        END IF;
        select ORDER_CATEGORY_CODE
        into lline_category_code from oe_transaction_types_all
        where transaction_type_id = p_line_rec.line_type_id;

        if p_line_rec.line_category_code <> lline_category_code then
           IF l_debug_level > 0 then
           oe_debug_pub.add(' Validate Line Type Line Cat Code from the OE_TRXT_ALL table: '||lline_category_code);
           oe_debug_pub.add(' Validate Line Type Line Cat Code from the UI: '||p_line_rec.line_category_code);
           END IF;
           fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
           fnd_message.set_token('ATTRIBUTE',  OE_Order_Util.Get_Attribute_Name('Line_type_id'));
           OE_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        end if;
      END IF;


      IF p_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

         l_new_wf_item_type := OE_Order_WF_Util.get_wf_item_type(p_line_rec);
         l_old_wf_item_type := OE_Order_WF_Util.get_wf_item_type(p_old_line_rec);

         IF NOT OE_Globals.Equal(l_new_wf_item_type, l_old_wf_item_type)
         THEN
           oe_debug_pub.add('workflow item type changed', 1);

--           FND_Message.Set_Name('ONT', 'OE_WF_ITEM_TYPE_CHANGED');
            FND_Message.Set_Name('ONT', 'OE_ITEM_TYPE_CONST');
           oe_msg_pub.add;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

            IF (NOT OE_GLOBALS.EQUAL(p_line_rec.line_type_id,p_old_line_rec.line_type_id))
            OR (NOT OE_GLOBALS.EQUAL(p_line_rec.item_type_code,p_old_line_rec.item_type_code))
            THEN

          -- Get Wf itme type
          --  litemtype := OE_Order_WF_Util.get_wf_item_type(p_line_rec);

               OPEN  Get_Order_Type;
               FETCH Get_Order_Type
               INTO  lorder_type_id;
               CLOSE Get_Order_Type;

            Select root_activity
            Into   lprocessname
            From   wf_items_v
            Where  item_type = 'OEOL'
            And    item_key  = to_char(p_line_rec.line_id) -- 2212128
            And    rownum    = 1;


            OPEN  find_LineProcessname;
            FETCH find_LineProcessname
                  INTO lexists;
                  CLOSE find_LineProcessname;

                  IF lexists IS NULL THEN
                    IF l_debug_level > 0 then
                    oe_debug_pub.add('Flow is different',1);
                    END IF;
                    RAISE NO_DATA_FOUND;
                  END IF;

            END IF;
        ELSIF p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            IF p_line_rec.ITEM_TYPE_CODE = OE_GLOBALS.G_ITEM_CONFIG THEN
            l_new_wf_item_type := OE_Order_WF_Util.get_wf_item_type(p_line_rec);

               OPEN Get_Order_Type;
               FETCH Get_Order_Type
               INTO lorder_type_id;
               CLOSE Get_Order_Type;

               OPEN find_config_assign;
               FETCH find_config_assign
               INTO lexists;
               CLOSE find_config_assign;

                  IF lexists IS NULL THEN
                        IF l_debug_level > 0 then
                        oe_debug_pub.add('No explicit assignment exists',2);
                        END IF;
                        FND_MESSAGE.SET_NAME('ONT','OE_EXP_ASSIGN_REQ');
                        OE_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                  END IF;

            END IF;

     END IF; -- Operation
        IF l_debug_level > 0 then
        OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_LINE.Validate_Line_Type',1);
        END IF;
EXCEPTION
     WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.SET_NAME('ONT','OE_FLOW_CNT_CHANGE');
         OE_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     WHEN FND_API.G_EXC_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;

     WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
       OE_MSG_PUB.Add_Exc_Msg
               (    G_PKG_NAME ,
                    'Validate_Line_Type'
               );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_line_type;


FUNCTION Validate_Receiving_Org
( p_inventory_item_id  IN  NUMBER
, p_ship_from_org_id   IN  NUMBER)
RETURN BOOLEAN
IS
l_validate VARCHAR2(1) := 'Y';
l_dummy    VARCHAR2(10);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  IF l_debug_level > 0 then
  OE_DEBUG_PUB.Add('Entering OE_VALIDATE_LINE.Validate_Receiving_Org',1);
  END IF;

  IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510'
  -- AND INVCONV
  --     NOT INV_GMI_RSV_BRANCH.Process_Branch(p_ship_from_org_id)  INVCONV
  THEN

      SELECT null
        INTO l_dummy
        FROM mtl_system_items_b msi,
             org_organization_definitions org
       WHERE msi.inventory_item_id = p_inventory_item_id
         AND org.organization_id= msi.organization_id
         AND msi.customer_order_enabled_flag =
             DECODE(l_validate, 'Y', 'Y',
                    msi.customer_order_enabled_flag)
         AND sysdate <= nvl( org.disable_date, sysdate)
         AND org.organization_id= p_ship_from_org_id;
    ELSE
        SELECT null
          INTO l_dummy
          FROM mtl_system_items_b msi,
               org_organization_definitions org
         WHERE msi.inventory_item_id = p_inventory_item_id
           AND org.organization_id= msi.organization_id
           AND msi.customer_order_enabled_flag =
                 DECODE(l_validate, 'Y', 'Y',
                      msi.customer_order_enabled_flag)
           AND sysdate <= nvl( org.disable_date, sysdate)
           AND org.organization_id= p_ship_from_org_id
           AND org.set_of_books_id= ( SELECT fsp.set_of_books_id
                              FROM financials_system_parameters fsp);

    END IF;
    IF l_debug_level > 0 then
    OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_LINE.Validate_Receiving_Org',1);
    END IF;

   RETURN TRUE;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ITEM_WHSE');
       OE_MSG_PUB.add;
       RETURN FALSE;
   WHEN OTHERS THEN
       FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ITEM_WHSE');
       OE_MSG_PUB.add;
       RETURN FALSE;
END Validate_Receiving_Org;

-- bug 6647169 begin
FUNCTION Validate_Warehouse_Change
(   p_line_rec					IN  OE_ORDER_PUB.Line_Rec_Type
,   p_old_line_rec              IN  OE_ORDER_PUB.Line_Rec_Type
) RETURN BOOLEAN
IS
l_result 	BOOLEAN;
l_shipable_flag_new VARCHAR2(1);
l_shipable_flag_old VARCHAR2(1);
BEGIN
	IF(Nvl(p_line_rec.shipping_interfaced_flag,'N') = 'Y') THEN
	     BEGIN
			SELECT  a.shippable_item_flag, b.shippable_item_flag
			INTO    l_shipable_flag_old,l_shipable_flag_new
			FROM    mtl_system_items_b a,mtl_system_items_b b
			WHERE   a.inventory_item_id = p_line_rec.inventory_item_id
			AND     b.inventory_item_id = a.inventory_item_id
			AND     a.organization_id = p_old_line_rec.ship_from_org_id
			AND     b.organization_id = p_line_rec.ship_from_org_id;

			oe_debug_pub.add('Old Shipable flag, New shipable flag : '||l_shipable_flag_old||l_shipable_flag_new);
	        IF (l_shipable_flag_old <> l_shipable_flag_new AND l_shipable_flag_new = 'N') THEN
				l_result := FALSE;
                FND_MESSAGE.SET_NAME('ONT','OE_INVLD_CHG_SHP_FROM_ORG');
                oe_msg_pub.add;
			ELSE
				l_result := TRUE;
			END IF;
             EXCEPTION when others then
		    l_result := TRUE;
             END;
	ELSE
		l_result := TRUE;
	END IF;
	RETURN(l_result);
END Validate_Warehouse_Change;
-- bug 6647169 end


FUNCTION Validate_Item_Warehouse
( p_inventory_item_id           IN  NUMBER
, p_ship_from_org_id            IN  NUMBER
, p_item_type_code              IN  VARCHAR2
, p_line_id                     IN  NUMBER
, p_top_model_line_id           IN  NUMBER
, p_source_document_type_id     IN NUMBER   /*Bug 1741158- chhung */
, p_line_category_code          IN VARCHAR2)/*Bug 1741158- chhung */
RETURN BOOLEAN
IS
--l_validate VARCHAR2(1) := 'Y'; /*chhung comment out :bug 1741158*/
l_dummy    VARCHAR2(10);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
   IF l_debug_level > 0 then
   oe_debug_pub.add('Entering Validate_Item_Warehouse',1);
   oe_debug_pub.add('p_inventory_item_id: '||p_inventory_item_id);
   oe_debug_pub.add('p_ship_from_org_id: '||p_ship_from_org_id);
   oe_debug_pub.add('p_item_type_code: '||p_item_type_code);
   oe_debug_pub.add('p_line_id: '||p_line_id);
   oe_debug_pub.add('p_top_model_line_id: '||p_top_model_line_id);
   oe_debug_pub.add('p_source_document_type_id: '||p_source_document_type_id);
   oe_debug_pub.add('p_line_category_code: '||p_line_category_code);
   END IF;
   -- The customer_order_enabled_flag for config item
   -- is set to 'N'

   /* Bug 1741158 chhung modify BEGIN */
   IF  p_line_category_code ='ORDER' THEN
        IF p_source_document_type_id = 10
        /* for Internal Orders */
        /* Internal Orders only support standard item */
        THEN
                SELECT null
                INTO  l_dummy
                FROM  mtl_system_items_b msi,
                      org_organization_definitions org
                WHERE msi.inventory_item_id = p_inventory_item_id
                AND   org.organization_id= msi.organization_id
                AND   msi.internal_order_enabled_flag = 'Y'
                AND   sysdate <= nvl( org.disable_date, sysdate)
                AND   org.organization_id= p_ship_from_org_id
                AND   rownum=1;
         ELSE /* other orders  except Internal*/
                IF p_item_type_code = OE_GLOBALS.G_ITEM_INCLUDED OR
                   p_item_type_code = OE_GLOBALS.G_ITEM_CONFIG
                THEN
                        SELECT null
                        INTO  l_dummy
                        FROM  mtl_system_items_b msi,
                              org_organization_definitions org
                        WHERE msi.inventory_item_id = p_inventory_item_id
                        AND   org.organization_id= msi.organization_id
                        AND   sysdate <= nvl( org.disable_date, sysdate)
                        AND   org.organization_id= p_ship_from_org_id
                        AND   rownum=1;

                ELSIF p_item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
                      p_item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
                     (p_item_type_code = OE_GLOBALS.G_ITEM_KIT AND
                      nvl(p_top_model_line_id, -1) <> p_line_id)
                THEN
                  --Commented for bug 4343544 start
                        /*SELECT null
                        INTO  l_dummy
                        FROM  mtl_system_items_b msi,
                                  org_organization_definitions org
                        WHERE msi.inventory_item_id = p_inventory_item_id
                        AND   org.organization_id= msi.organization_id
                        AND   sysdate <= nvl( org.disable_date, sysdate)
                        AND   org.organization_id= p_ship_from_org_id
                                AND   msi.customer_order_enabled_flag =
                                     Decode(g_cust_ord_enabled_flag,  'Y'
                                     ,'Y','N',msi.customer_order_enabled_flag)
                        AND   rownum=1;*/
                  --Commented for bug 4343544 end
                   --Added for bug 4343544 start changed decode for better performance
                        if g_cust_ord_enabled_flag='Y'  then
                             SELECT null
                                INTO  l_dummy
                                FROM  mtl_system_items_b msi,
                                org_organization_definitions org
                             WHERE msi.inventory_item_id = p_inventory_item_id
                             AND   org.organization_id= msi.organization_id
                             AND   sysdate <= nvl( org.disable_date, sysdate)
                             AND   org.organization_id= p_ship_from_org_id
                             AND   msi.customer_order_enabled_flag = g_cust_ord_enabled_flag
                             AND   rownum=1;
                        else
                             SELECT null
                                INTO  l_dummy
                                FROM  mtl_system_items_b msi,
                                org_organization_definitions org
                             WHERE msi.inventory_item_id = p_inventory_item_id
                             AND   org.organization_id= msi.organization_id
                             AND   sysdate <= nvl( org.disable_date, sysdate)
                             AND   org.organization_id= p_ship_from_org_id
                             AND   rownum =1;
                        end if;
                    --Added for bug 4343544 end
                ELSE /* item type is MODEL,STANDARD,SERVICE,KIT in top most level*/
                        SELECT null
                        INTO  l_dummy
                        FROM  mtl_system_items_b msi,
                              org_organization_definitions org
                        WHERE msi.inventory_item_id = p_inventory_item_id
                        AND   org.organization_id= msi.organization_id
                        AND   msi.customer_order_enabled_flag = 'Y'
                        AND   sysdate <= nvl( org.disable_date, sysdate)
                        AND   org.organization_id= p_ship_from_org_id
                        AND   rownum=1;
                END IF;
        END IF;
   /* Bug 1741158 chhung modify END */
   ELSE /* p_line_category_code is 'RETURN */
   -- It's for Return group!!
        null;
   END IF;
   IF l_debug_level > 0 then
   oe_debug_pub.add('Exiting Validate_Item_Warehouse',1);
   END IF;
   RETURN TRUE;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       IF l_debug_level > 0 then
       oe_debug_pub.add('RR: No data found',1);
       END IF;

       FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ITEM_WHSE');
       OE_MSG_PUB.add;
       RETURN FALSE;

   WHEN OTHERS THEN
       IF l_debug_level > 0 then
       oe_debug_pub.add('RR: OTHERS',1);
       END IF;
       FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ITEM_WHSE');
       OE_MSG_PUB.add;
       RETURN FALSE;

END Validate_Item_Warehouse;

FUNCTION Validate_task
( p_project_id  IN  NUMBER
, p_task_id     IN  NUMBER)
RETURN BOOLEAN
IS
l_dummy VARCHAR2(10);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
   IF l_debug_level > 0 then
   oe_debug_pub.add('Entering Validate_Task',1);
   END IF;
    SELECT 'VALID'
    INTO   l_dummy
    FROM   mtl_task_v
    WHERE  project_id = p_project_id
    AND    task_id = p_task_id;

   IF l_debug_level > 0 then
   oe_debug_pub.add('Exiting Validate_Task',1);
   END IF;
    RETURN TRUE;

EXCEPTION

   WHEN OTHERS THEN
      RETURN FALSE;

END Validate_task;

FUNCTION Validate_task_reqd
( p_project_id  IN  NUMBER
 ,p_ship_from_org_id IN NUMBER)
RETURN BOOLEAN
IS
l_project_control_level NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
   IF l_debug_level > 0 then
   oe_debug_pub.add('Entering Validate_task_reqd',1);
   END IF;

        -- If project control level in MTL_PARAMETERS for the warehouse
        -- is set to 'Task', then project references on the order must
        -- consist of both Project and Task.

                SELECT NVL(PROJECT_CONTROL_LEVEL,0)
                INTO   l_project_control_level
                FROM   MTL_PARAMETERS
                WHERE  ORGANIZATION_ID = p_ship_from_org_id;

                 IF l_project_control_level = 2                 -- control level is 'Task'
              THEN
              IF l_debug_level > 0 then
              oe_debug_pub.add('Exiting Validate_task_reqd',1);
              END IF;
                        RETURN TRUE;
           ELSE
              IF l_debug_level > 0 then
              oe_debug_pub.add('Exiting Validate_task_reqd',1);
              END IF;
                        RETURN FALSE;
                 END IF;

EXCEPTION

   WHEN OTHERS THEN
      RETURN FALSE;

END Validate_task_reqd;

FUNCTION Validate_Item_Fields
( p_inventory_item_id           IN  NUMBER
, p_ordered_item_id             IN  NUMBER
, p_item_identifier_type        IN  VARCHAR2
, p_ordered_item                IN  VARCHAR2
, p_sold_to_org_id              IN  NUMBER
, p_line_category_code          IN  VARCHAR2 /*Bug 1678296- chhung adds*/
, p_item_type_code              IN  VARCHAR2 /*Bug 1741158- chhung adds */
, p_line_id                     IN  NUMBER  /*Bug 1741158- chhung adds */
, p_top_model_line_id           IN  NUMBER /*Bug 1741158- chhung adds */
, p_source_document_type_id     IN  NUMBER /*Bug 1741158- chhung adds */
, p_operation                   IN  VARCHAR2 /* Bug 1805985 add*/
)
RETURN BOOLEAN
IS
l_dummy    VARCHAR2(10);

/* added for 2219230 */
l_org_flag   NUMBER := 2;
item_val_org NUMBER := to_number(OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID'));
CURSOR xref IS
        SELECT DECODE(items.org_independent_flag, 'Y', 1,
                 DECODE(items.organization_id, item_val_org, 1, 2))
        FROM  mtl_cross_reference_types types
            , mtl_cross_references items
            , mtl_system_items_vl sitems
        WHERE types.cross_reference_type = items.cross_reference_type
           AND items.inventory_item_id = sitems.inventory_item_id
           AND sitems.organization_id = item_val_org
           AND sitems.inventory_item_id = p_inventory_item_id
           AND items.cross_reference_type = p_item_identifier_type
           AND items.cross_reference = p_ordered_item
           AND (types.disable_date is NULL or types.disable_date > sysdate)   --And condition added for bug 3844345 shewgupt
           AND sitems.customer_order_enabled_flag = 'Y'                       --And condition added for bug 3844345 shewgupt
           ORDER BY 1;

--cursor added for bug 3844345
CURSOR xref_return IS
        SELECT DECODE(items.org_independent_flag, 'Y', 1,
                 DECODE(items.organization_id, item_val_org, 1, 2))
        FROM  mtl_cross_reference_types types
            , mtl_cross_references items
            , mtl_system_items_vl sitems
        WHERE types.cross_reference_type = items.cross_reference_type
           AND items.inventory_item_id = sitems.inventory_item_id
           AND sitems.organization_id = item_val_org
           AND sitems.inventory_item_id = p_inventory_item_id
           AND items.cross_reference_type = p_item_identifier_type
           AND items.cross_reference = p_ordered_item
           ORDER BY 1;
/* end of code added for 2219230 */
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
   IF l_debug_level > 0 then
   oe_debug_pub.add('Entering Validate_Item_Fields',1);
   oe_debug_pub.add('p_inventory_item_id: '||p_inventory_item_id);
   oe_debug_pub.add('p_ordered_item_id: '||p_ordered_item_id);
   oe_debug_pub.add('p_item_identifier_type: '||p_item_identifier_type);
   oe_debug_pub.add('p_ordered_item: '||p_ordered_item);
   oe_debug_pub.add('p_sold_to_org_id: '||p_sold_to_org_id);
   oe_debug_pub.add('p_line_category_code: '||p_line_category_code);
   oe_debug_pub.add('p_item_type_code: '||p_item_type_code);
   oe_debug_pub.add('p_line_id: '||p_line_id);
   oe_debug_pub.add('p_top_model_line_id: '||p_top_model_line_id);
   oe_debug_pub.add('p_source_document_type_id: '||p_source_document_type_id);
   oe_debug_pub.add('p_operation: '||p_operation);
   oe_debug_pub.add('pricing_recursion : '||OE_GLOBALS.g_pricing_recursion);

   -- Bug 1805985 start
   IF(OE_GLOBALS.G_UI_FLAG) THEN
        oe_debug_pub.add('G_UI_FLAG = TRUE');
   ELSE
        oe_debug_pub.add('G_UI_FLAG = FALSE');
   END IF;
   -- Bug 1805985 end
   END IF;

   IF nvl(p_item_identifier_type, 'INT') = 'INT' THEN
        /* Bug 1741158 chhung modify BEGIN */
        IF  p_line_category_code ='ORDER' THEN
                IF p_source_document_type_id = 10
                /* for Internal Orders */
                /* Internal Orders only support standard item */
                THEN
                        SELECT 'valid'
                        INTO  l_dummy
                        FROM  mtl_system_items_b
                        WHERE inventory_item_id = p_inventory_item_id
                        AND organization_id = OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID')
                        AND internal_order_enabled_flag = 'Y';
                ELSE  /* other orders  except Internal*/
                        IF p_item_type_code = OE_GLOBALS.G_ITEM_INCLUDED OR
                           p_item_type_code = OE_GLOBALS.G_ITEM_CONFIG OR
                           p_item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
                           p_item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
                           (p_item_type_code = OE_GLOBALS.G_ITEM_KIT AND
                            nvl(p_top_model_line_id, -1) <> p_line_id)
                        THEN
                                SELECT 'valid'
                                INTO  l_dummy
                                FROM  mtl_system_items_b
                                WHERE inventory_item_id = p_inventory_item_id
                                AND organization_id = OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID');
                        ELSE /* item type is MODEL,STANDARD,SERVICE,KIT in top most level*/

/* Change for bug 1805985
 -------------------------------------------------------
 To avoid duplicated item validation for
 customer_order_enabled flag and item validation org in client and server side
 Logic :
 If item is buy item and G_UI_FLAG is 'FALSE', then we do server validation.
 If item is get/free item, then we always do server validation.
 */

                            IF (NOT (OE_GLOBALS.g_pricing_recursion='Y' AND p_operation= OE_GLOBALS.G_OPR_CREATE )) THEN
                            -- Item is BUY item
                                IF(NOT OE_GLOBALS.G_UI_FLAG) THEN

                                --changes for bug 4171642
                               IF ( OE_ORDER_CACHE.g_item_rec.master_org_id <> FND_API.G_MISS_NUM ) AND
                                  ( OE_ORDER_CACHE.g_item_rec.master_org_id = g_master_org_id) AND
                                       ( OE_ORDER_CACHE.g_item_rec.inventory_item_id = p_inventory_item_id)
                                    THEN
                                        if OE_ORDER_CACHE.g_item_rec.customer_order_enabled_flag = 'Y' then
                                                l_dummy := 'VALID';
                    else
                    RAISE NO_DATA_FOUND ;
                    end if;
                                    ELSE
                                        OE_ORDER_CACHE.Load_Item( p_key1 => p_inventory_item_id ) ;
                                        if (OE_ORDER_CACHE.g_item_rec.customer_order_enabled_flag = 'Y') then
                                                l_dummy := 'VALID';
                                        else
                                                Raise No_Data_Found ;
                                        end if ;
                                    END IF ;

                                   /*SELECT 'valid'
                                   INTO  l_dummy
                                   FROM  mtl_system_items_b
                                   WHERE inventory_item_id = p_inventory_item_id
                                   AND organization_id = OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID')
                                   AND customer_order_enabled_flag = 'Y'; */
-- end bug 4171642

                                 END IF;
                            ELSE /* Item is get or free item */

                                --changes for bug 3975762
                                    IF ( OE_ORDER_CACHE.g_item_rec.master_org_id <> FND_API.G_MISS_NUM ) AND
                                       ( OE_ORDER_CACHE.g_item_rec.master_org_id = g_master_org_id) AND
                                       (OE_ORDER_CACHE.g_item_rec.inventory_item_id = p_inventory_item_id)
                                    THEN
                                        if OE_ORDER_CACHE.g_item_rec.customer_order_enabled_flag = 'Y' then
                                                l_dummy := 'VALID';
                                        else
                                                RAISE NO_DATA_FOUND ;
                                        end if ;
                                    ELSE
                                        OE_ORDER_CACHE.Load_Item( p_key1 => p_inventory_item_id ) ;
                                        if (OE_ORDER_CACHE.g_item_rec.customer_order_enabled_flag = 'Y') then
                                                l_dummy := 'VALID';
                                        else
                                                Raise No_Data_Found ;
                                        end if ;
                                    END IF ;
-- bug 4171642

                                /*SELECT 'valid'
                                INTO  l_dummy
                                FROM  mtl_system_items_b
                                WHERE inventory_item_id = p_inventory_item_id
                                AND organization_id = OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID')
                                AND customer_order_enabled_flag = 'Y'; */
   -- End bug 4171642
                            END IF;
                        END IF;
                END IF;
        /* Bug 1741158 chhung modify END */
        ELSE /* p_line_category_code is 'RETURN */
        -- It's for Return group!!
                null;
        END IF;
   ELSIF nvl(p_item_identifier_type, 'INT') = 'CUST' THEN
       --Bug 1678296 chhung modify BEGIN
      IF  p_line_category_code ='ORDER' THEN

        SELECT 'valid'
        INTO  l_dummy
        FROM   mtl_customer_items citems
                ,mtl_customer_item_xrefs cxref
                ,mtl_system_items_vl sitems
                ,mtl_parameters mp                                                         -- 4402603
        WHERE citems.customer_item_id = cxref.customer_item_id
                AND cxref.inventory_item_id = sitems.inventory_item_id
                AND sitems.inventory_item_id = p_inventory_item_id
                AND sitems.organization_id =
                OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID')
                AND sitems.customer_order_enabled_flag = 'Y' -- bug 3835602
                AND citems.customer_item_id = p_ordered_item_id
                AND citems.customer_id = p_sold_to_org_id
                AND citems.inactive_flag = 'N'
                AND cxref.inactive_flag = 'N'
                AND mp.organization_id = sitems.organization_id                            -- 4402603
                AND cxref.master_organization_id = mp.master_organization_id  ;            -- 4402603

       ELSE /* line_category_code is 'RETURN'*/

        SELECT 'valid'
        INTO  l_dummy
        FROM   mtl_customer_items citems
                ,mtl_customer_item_xrefs cxref
                ,mtl_system_items_vl sitems
                ,mtl_parameters mp                                                         -- 4402603
        WHERE citems.customer_item_id = cxref.customer_item_id
                AND cxref.inventory_item_id = sitems.inventory_item_id
                AND sitems.inventory_item_id = p_inventory_item_id
                AND sitems.organization_id =
                OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID')
                AND citems.customer_item_id = p_ordered_item_id
                AND citems.customer_id = p_sold_to_org_id
                AND mp.organization_id = sitems.organization_id                            -- 4402603
                AND cxref.master_organization_id = mp.master_organization_id  ;            -- 4402603

      END IF;
      --Bug 1678296 chhung modify END
   ELSE
      IF p_ordered_item_id IS NOT NULL THEN
        RETURN FALSE;
      ELSIF p_line_category_code ='ORDER' THEN    /* SELECT replaced for with the following for 2219230 */
        IF l_debug_level > 0 then
        oe_debug_pub.add('Validating generic item when category code is ORDER , item_val_org:'||to_char(item_val_org),5);
        END IF;
        OPEN xref;
        FETCH xref INTO l_org_flag;
        IF xref%NOTFOUND OR l_org_flag <> 1 THEN
          IF l_debug_level > 0 then
          oe_debug_pub.add('Invalid Generic Item', 1);
          END IF;
          CLOSE xref;
          RETURN FALSE;
        END IF;
        CLOSE xref;
      ELSIF p_line_category_code = 'RETURN' then   /* elsif condition added for bug 3844345 */
        IF l_debug_level > 0 then
        oe_debug_pub.add('Validating generic item when category code is RETURN , item_val_org:'||to_char(item_val_org),5);
        END IF;
        OPEN xref_return;
        FETCH xref_return INTO l_org_flag;
        IF xref_return%NOTFOUND OR l_org_flag <> 1 THEN
           IF l_debug_level > 0 then
          oe_debug_pub.add('Invalid Generic Item', 1);
           END IF;
          CLOSE xref_return;
          RETURN FALSE;
        END IF;
        CLOSE xref_return;
      END IF;
   END IF;
   IF l_debug_level > 0 then
   oe_debug_pub.add('Exiting Validate_Item_Fields',1);
   END IF;
   RETURN TRUE;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       IF l_debug_level > 0 then
       oe_debug_pub.add('Validate_Item_Fields: No data found',1);
       IF nvl(p_item_identifier_type, 'INT') = 'INT' THEN
         oe_debug_pub.add('Invalid internal item');
       ELSIF nvl(p_item_identifier_type, 'INT') = 'CUST' THEN
         oe_debug_pub.add('Invalid Customer Item');
       ELSE
         oe_debug_pub.add('Invalid Generic Item');
       END IF;
       END IF;
       RETURN FALSE;
   WHEN OTHERS THEN
       IF l_debug_level > 0 then
       oe_debug_pub.add('Validate_Item_Fields: When Others',1);
       END IF;
       RETURN FALSE;
END Validate_Item_Fields;

FUNCTION Validate_Return_Item_Mismatch
( p_reference_line_id    IN NUMBER
, p_inventory_item_id    IN NUMBER)
RETURN BOOLEAN
IS
l_ref_inventory_item_id NUMBER;
l_profile               VARCHAR2(1);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
   IF l_debug_level > 0 then
   oe_debug_pub.add('Entering Validate_Return_Item_Mismatch',1);
   END IF;

   IF (p_reference_line_id IS NULL) THEN
     RETURN TRUE;
   END IF;

   -- Check Profile Option to see if allow item mismatch
   l_profile := FND_PROFILE.value('ONT_RETURN_ITEM_MISMATCH_ACTION');

   IF (l_profile is NULL OR l_profile = 'A') THEN
     RETURN TRUE;
   ELSE

        SELECT inventory_item_id
        INTO  l_ref_inventory_item_id
        FROM  oe_order_lines
        WHERE line_id = p_reference_line_id;

      IF (l_ref_inventory_item_id = p_inventory_item_id) THEN
        RETURN TRUE;
      ELSIF (l_profile = 'R') THEN
        RETURN FALSE;
      ELSE  -- warning
        FND_MESSAGE.SET_NAME('ONT','OE_RETURN_ITEM_MISMATCH_WARNIN');
        OE_MSG_PUB.ADD;
      END IF;

   END IF;
   IF l_debug_level > 0 then
   oe_debug_pub.add('Exiting Validate_Return_Item_Mismatch',1);
   END IF;
   RETURN TRUE;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       IF l_debug_level > 0 then
       oe_debug_pub.add('Validate_Return_Item_Mismatch: No data found',1);
       END IF;
       RETURN FALSE;
   WHEN OTHERS THEN
       IF l_debug_level > 0 then
       oe_debug_pub.add('Validate_Return_Item_Mismatch: When Others',1);
       END IF;
       RETURN FALSE;
END Validate_Return_Item_Mismatch;

FUNCTION Validate_Return_Fulfilled_Line
(p_reference_line_id IN NUMBER
) RETURN BOOLEAN
IS
l_ref_fulfilled_quantity NUMBER;
l_ref_shippable_flag     VARCHAR2(1);
l_ref_shipped_quantity   NUMBER;
l_ref_inv_iface_status   VARCHAR2(30);
l_profile                VARCHAR2(1);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
   IF l_debug_level > 0 then
   oe_debug_pub.add('Entering Validate return fulfilled line',1);
   END IF;

   IF (p_reference_line_id IS NULL) THEN
     RETURN TRUE;
   END IF;

   -- Check Profile Option to see if allow item mismatch
   l_profile := FND_PROFILE.value('ONT_RETURN_FULFILLED_LINE_ACTION');

   IF (l_profile is NULL OR l_profile = 'A') THEN
     RETURN TRUE;

        /*
        ** As per the fix for Bug # 1541972, modified the following ELSE
        ** clause to return a success even if Fulfilled Quantity is null
        ** and some other conditions are met.
        */
   ELSE


        SELECT nvl(fulfilled_quantity, 0)
           ,      nvl(shippable_flag, 'N')
           ,      invoice_interface_status_code
           ,      nvl(shipped_quantity, 0)
        INTO  l_ref_fulfilled_quantity
           ,     l_ref_shippable_flag
           ,     l_ref_inv_iface_status
           ,     l_ref_shipped_quantity
        FROM  oe_order_lines
        WHERE line_id = p_reference_line_id;

      IF (l_ref_shippable_flag = 'N' AND l_ref_inv_iface_status = 'NOT_ELIGIBLE') THEN
           RETURN TRUE;
      ELSIF l_ref_inv_iface_status in ('YES', 'RFR-PENDING', 'MANUAL-PENDING') THEN
           RETURN TRUE;
      ELSIF l_ref_fulfilled_quantity > 0 THEN
        RETURN TRUE;
      ELSIF l_ref_shipped_quantity > 0 THEN
           RETURN TRUE;
      ELSIF (l_profile = 'R') THEN
        RETURN FALSE;
      ELSE  -- warning
        FND_MESSAGE.SET_NAME('ONT','OE_UNFULFILLED_LINE_WARNING');
        OE_MSG_PUB.ADD;
      END IF;

   END IF;
   IF l_debug_level > 0 then
   oe_debug_pub.add('Exiting Validate return fulfilled line',1);
   END IF;
   RETURN TRUE;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       IF l_debug_level > 0 then
       oe_debug_pub.add('Validate_Return_Fulfilled_Line: No data found',1);
       END IF;
       RETURN FALSE;
   WHEN OTHERS THEN
       IF l_debug_level > 0 then
       oe_debug_pub.add('Validate_Return_Fulfilled_Line: When Others',1);
       END IF;
       RETURN FALSE;
END Validate_Return_Fulfilled_Line;

PROCEDURE Validate_Return_Item
(p_inventory_item_id    IN NUMBER,
 p_ship_from_org_id     IN NUMBER,
 x_return_status        IN OUT NOCOPY VARCHAR2)
IS
l_returnable_flag Varchar2(1);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
   IF l_debug_level > 0 then
  oe_debug_pub.add('Entering Validate_Return_Item',1);
   END IF;
-- bug 4171642
IF ( OE_ORDER_CACHE.g_item_rec.master_org_id <> FND_API.G_MISS_NUM ) AND
   (g_master_org_id = OE_ORDER_CACHE.g_item_rec.master_org_id) AND
   (OE_ORDER_CACHE.g_item_rec.inventory_item_id = p_inventory_item_id)
 THEN
  l_returnable_flag := nvl(OE_ORDER_CACHE.g_item_rec.returnable_flag , 'Y');
ELSE
   OE_ORDER_CACHE.Load_Item( p_key1 => p_inventory_item_id ,
                             p_key2 => p_ship_from_org_id );
  l_returnable_flag := nvl(OE_ORDER_CACHE.g_item_rec.returnable_flag , 'Y');
END IF ;
/*
  SELECT nvl(returnable_flag,'Y')
  INTO  l_returnable_flag
  FROM  mtl_system_items_b
  WHERE inventory_item_id = p_inventory_item_id
  and organization_id = nvl(p_ship_from_org_id,
     oe_sys_parameters.value_wnps('MASTER_ORGANIZATION_ID')); */

-- bug 4171642

  IF l_returnable_flag = 'Y' THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
  ELSE
      fnd_message.set_name('ONT', 'OE_ITEM_NOT_RETURNABLE');
      OE_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       IF l_debug_level > 0 then
       oe_debug_pub.add('Validate_Return_Item: No data found',1);
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ITEM_WHSE');
       OE_MSG_PUB.add;
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF l_debug_level > 0 then
       oe_debug_pub.add('Validate_Return_Item: When Others',1);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Return_Item;

--bug 5898152
 FUNCTION Validate_Return_Reference_Tax
    (p_reference_line_id    IN NUMBER,
     p_tax_code             IN VARCHAR2)
     RETURN BOOLEAN
    IS

    l_tax_code Varchar2(50);
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    BEGIN
     if l_debug_level > 0 then
      oe_debug_pub.add('Enter Validate_Return_Reference_tax',1);
      oe_debug_pub.add('The TAX '||p_tax_code,1);
     end if;

      SELECT tax_code
      INTO  l_tax_code
      FROM  oe_order_lines
      WHERE line_id = p_reference_line_id
      and line_category_code = 'ORDER';

      IF NOT OE_GLOBALS.EQUAL(l_tax_code,p_tax_code) THEN
        fnd_message.set_name('ONT','OE_RETURN_ATTR_CANNOT_CHANGE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Tax Code');
        OE_MSG_PUB.Add;
        RETURN FALSE;
      END IF;

     if l_debug_level > 0 then
      oe_debug_pub.add('Exit Validate_Return_Reference_tax',1);
     end if;
      RETURN TRUE;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          if l_debug_level > 0 then
           oe_debug_pub.add('Validate_Return_Reference: No data found',1);
          end if;
           fnd_message.set_name('ONT', 'OE_RETURN_INVALID_SO_LINE');
           OE_MSG_PUB.Add;
           RETURN FALSE;
       WHEN OTHERS THEN
          if l_debug_level > 0 then
           oe_debug_pub.add('Validate_Return_Reference: When Others',1);
          end if;
           fnd_message.set_name('ONT', 'OE_RETURN_INVALID_SO_LINE');
           OE_MSG_PUB.Add;
           RETURN FALSE;
END Validate_Return_Reference_Tax;

FUNCTION Validate_Return_Reference
(p_reference_line_id    IN NUMBER,
 p_uom_code             IN VARCHAR2)
 RETURN BOOLEAN
IS
l_booked_flag Varchar2(1);
l_uom_code Varchar2(3);
l_source_document_type_id NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
   IF l_debug_level > 0 then
  oe_debug_pub.add('Enter Validate_Return_Reference',1);
  oe_debug_pub.add('The UOM '||p_uom_code,1);
   END IF;

  SELECT nvl(booked_flag,'N'),
         nvl(ORDER_QUANTITY_UOM,' '),
         source_document_type_id
  INTO  l_booked_flag,
        l_uom_code,
        l_source_document_type_id
  FROM  oe_order_lines
  WHERE line_id = p_reference_line_id
  and line_category_code = 'ORDER';

  IF l_source_document_type_id = 10 THEN
    fnd_message.set_name('ONT','OE_NO_RMA_FOR_INTERNAL_ORDER');
    OE_MSG_PUB.Add;
    RETURN FALSE;
  END IF;

  IF NOT OE_GLOBALS.EQUAL(l_uom_code,p_uom_code) THEN
    fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Unit Of Measure');
    OE_MSG_PUB.Add;
    RETURN FALSE;
  END IF;

  IF l_booked_flag = 'Y' THEN
        RETURN TRUE;
  ELSE
            fnd_message.set_name('ONT', 'OE_RETURN_UNBOOKED_ORDER');
            OE_MSG_PUB.Add;
  END IF;
  IF l_debug_level > 0 then
  oe_debug_pub.add('Exit Validate_Return_Reference',1);
  END IF;
  RETURN FALSE;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       IF l_debug_level > 0 then
       oe_debug_pub.add('Validate_Return_Reference: No data found',1);
       END IF;
       fnd_message.set_name('ONT', 'OE_RETURN_INVALID_SO_LINE');
       OE_MSG_PUB.Add;
       RETURN FALSE;
   WHEN OTHERS THEN
       IF l_debug_level > 0 then
       oe_debug_pub.add('Validate_Return_Reference: When Others',1);
       END IF;
       fnd_message.set_name('ONT', 'OE_RETURN_INVALID_SO_LINE');
       OE_MSG_PUB.Add;
       RETURN FALSE;
END Validate_Return_Reference;

/*
** Fix Bug # 2791253:
** New Procedure to Validate existence of Return for sales order
** lines that are being cancelled.
*/
FUNCTION Validate_Return_Existence
(p_line_id    IN NUMBER,
 p_ord_qty    IN NUMBER,
 p_action_code IN VARCHAR2 DEFAULT NULL) -- bug 7707133
 RETURN BOOLEAN
IS
 l_ord_qty number;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Enter Validate_Return_Existence',1);
  END IF;

  SELECT NVL(SUM(ordered_quantity),0)
  INTO  l_ord_qty
  FROM  oe_order_lines
  WHERE line_category_code= 'RETURN'
  and   reference_line_id = p_line_id;

  IF l_debug_level  > 0 THEN
  oe_debug_pub.add('Quantity Referenced on RMAs: '||l_ord_qty);
  END IF;

  IF l_ord_qty > 0 THEN
    -- Begin : Changes for bug 7707133
    -- Introduced additional ELSE clause
    IF p_ord_qty <= 0 THEN -- line cancellation
      fnd_message.set_name('ONT','OE_LINE_HAS_RMA_CANNOT_CANCEL');
      OE_MSG_PUB.Add;
      RETURN FALSE;
    ELSIF p_ord_qty < l_ord_qty THEN -- Higher Return quantity
      fnd_message.set_name('ONT','OE_LINE_HAS_RMA_HIGHER_QTY');
      OE_MSG_PUB.Add;
      RETURN FALSE;
    ELSIF p_action_code = OE_GLOBALS.G_OPR_DELETE THEN
      -- Line deletion during config item delinking (p_ord_qty>0)
      fnd_message.set_name('ONT','OE_LINE_HAS_RMA_CANNOT_DELINK');
      OE_MSG_PUB.Add;
      RETURN FALSE;
    END IF;
    -- End : Changes for bug 7707133
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Exit Validate_Return_Existence',1);
  END IF;

  RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Validate_Return_Existence: When Others',1);
     END IF;

     RETURN FALSE;
END Validate_Return_Existence;


FUNCTION Validate_Ship_to_Org
( p_ship_to_org_id      IN  NUMBER
, p_sold_to_org_id      IN  NUMBER)
RETURN BOOLEAN
IS
l_dummy VARCHAR2(10);
lcustomer_relations varchar2(1);
--added for bug 3739650
   l_site_use_code   VARCHAR2(30);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
    IF l_debug_level > 0 then
    oe_debug_pub.add('Entering Validate_ship_to_org',1);
    oe_debug_pub.add('ship_to_org_id :'||to_char(p_ship_to_org_id),2);
    END IF;

    lcustomer_relations := OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG');

    IF nvl(lcustomer_relations,'N') = 'N' THEN

    Select 'VALID'
    Into   l_dummy
    From   oe_ship_to_orgs_v
    Where  customer_id = p_sold_to_org_id
    AND          site_use_id = p_ship_to_org_id
    AND  status = 'A'
    AND  address_status ='A'; --bug 2752321
    IF l_debug_level > 0 then
    oe_debug_pub.add('Exiting Validate_ship_to_org',1);
    END IF;
    RETURN TRUE;
    ELSIF lcustomer_relations = 'Y' THEN
        IF l_debug_level > 0 then
        oe_debug_pub.add ('Cr: Yes Line Ship',2);
        END IF;

--variable added for bug 3739650
    l_site_use_code := 'SHIP_TO' ;
    SELECT /* MOAC_SQL_CHANGE */ 'VALID'
    Into   l_dummy
    FROM   HZ_CUST_SITE_USES_ALL SITE,
           HZ_CUST_ACCT_SITES ACCT_SITE
    WHERE SITE.SITE_USE_ID     = p_ship_to_org_id
    AND SITE.SITE_USE_CODE     = l_site_use_code
    AND SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
    AND SITE.STATUS = 'A'
       AND ACCT_SITE.STATUS ='A' AND --bug 2752321
    ACCT_SITE.CUST_ACCOUNT_ID in (
                    SELECT p_sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE_ALL h WHERE
                    RELATED_CUST_ACCOUNT_ID = p_sold_to_org_id
                    and h.org_id=acct_site.org_id
                        and ship_to_flag = 'Y' and status = 'A')
    --bug 4205113
    AND EXISTS(SELECT 1 FROM HZ_CUST_ACCOUNTS WHERE CUST_ACCOUNT_ID = ACCT_SITE.CUST_ACCOUNT_ID AND STATUS='A')
    AND ROWNUM = 1;
   RETURN TRUE;
    ELSIF lcustomer_relations = 'A' THEN
    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_SHIP_TO_ORGS_V   SHP
    WHERE   SHP.ORGANIZATION_ID =p_ship_to_org_id
    AND     SHP.STATUS = 'A'
    AND     SHP.ADDRESS_STATUS ='A' --bug 2752321
    AND     SYSDATE BETWEEN NVL(SHP.START_DATE_ACTIVE, SYSDATE)
                    AND     NVL(SHP.END_DATE_ACTIVE, SYSDATE);

        RETURN TRUE;


    END IF;
   RETURN TRUE;


EXCEPTION

   WHEN OTHERS THEN
      RETURN FALSE;

END Validate_Ship_To_Org;

FUNCTION Validate_Deliver_To_Org
( p_deliver_to_org_id IN  NUMBER
, p_sold_to_org_id        IN  NUMBER)
RETURN BOOLEAN
IS
l_dummy VARCHAR2(10);
lcustomer_relations varchar2(1);
--added for bug 3739650
   l_site_use_code   VARCHAR2(30);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  IF l_debug_level > 0 then
  oe_debug_pub.add('Entering OE_VALIDATE_LINE.Validate_Deliver_To_Org',1);
  oe_debug_pub.add('deliver_to_org_id :'||to_char(p_deliver_to_org_id),2);
  END IF;

  lcustomer_relations := OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG');

  IF nvl(lcustomer_relations,'N') = 'N' THEN
    SELECT 'VALID'
    INTO   l_dummy
    FROM   oe_deliver_to_orgs_v
    WHERE  customer_id = p_sold_to_org_id
    AND          site_use_id = p_deliver_to_org_id
    AND  status = 'A'
    AND  address_status ='A';--bug 2752321
    IF l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_VALIDATE_LINE.Validate_Deliver_To_Org',1);
    END IF;
    RETURN TRUE;

  ELSIF lcustomer_relations = 'Y' THEN
    IF l_debug_level > 0 then
    oe_debug_pub.add('Cr: Yes Line Deliver',2);
    END IF;
--variable added for bug 3739650
    l_site_use_code := 'DELIVER_TO' ;
    SELECT /* MOAC_SQL_CHANGE */ 'VALID'
      Into   l_dummy
      FROM   HZ_CUST_SITE_USES_ALL SITE,
           HZ_CUST_ACCT_SITES ACCT_SITE
     WHERE SITE.SITE_USE_ID     = p_deliver_to_org_id
       AND SITE.SITE_USE_CODE     = l_site_use_code
       AND SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
       AND SITE.STATUS = 'A'
       AND ACCT_SITE.STATUS ='A' AND --bug 2752321
       ACCT_SITE.CUST_ACCOUNT_ID in (
                    SELECT p_sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE_ALL h WHERE
                    RELATED_CUST_ACCOUNT_ID = p_sold_to_org_id
                    and h.org_id=acct_site.org_id
                        and ship_to_flag = 'Y' and status='A')
    -- bug 4205113
    AND EXISTS(SELECT 1 FROM HZ_CUST_ACCOUNTS WHERE CUST_ACCOUNT_ID = ACCT_SITE.CUST_ACCOUNT_ID AND STATUS='A')
        AND ROWNUM = 1;
    IF l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_VALIDATE_LINE.Validate_Deliver_To_Org',1);
    END IF;
    RETURN TRUE;

  ELSIF lcustomer_relations = 'A' THEN

    SELECT  'VALID'
      INTO    l_dummy
      FROM    OE_DELIVER_TO_ORGS_V   DEL
     WHERE   DEL.ORGANIZATION_ID =p_deliver_to_org_id
       AND     DEL.STATUS = 'A'
               AND DEL.ADDRESS_STATUS ='A' --bug 2752321
       AND     SYSDATE BETWEEN NVL(DEL.START_DATE_ACTIVE, SYSDATE)
                    AND     NVL(DEL.END_DATE_ACTIVE, SYSDATE);
    IF l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_VALIDATE_LINE.Validate_Deliver_To_Org',1);
    END IF;
    RETURN TRUE;


  END IF;
   IF l_debug_level > 0 then
  oe_debug_pub.add('Exiting OE_VALIDATE_LINE.Validate_Deliver_To_Org',1);
   END IF;
  RETURN TRUE;

EXCEPTION

   WHEN OTHERS THEN
      RETURN FALSE;

END Validate_Deliver_To_Org;


---------------------------------------------------
-- Procedure Name: Validate_Commitment
-- Abstract: to validate a commitment number on an order line for the
--           given sold_to_org_id, and against OTA course end date.
---------------------------------------------------

PROCEDURE Validate_Commitment
( p_line_rec            IN OE_Order_PUB.Line_Rec_Type
, p_hdr_currency_code   IN VARCHAR2
, p_ota_line            IN BOOLEAN := FALSE
, x_return_status       OUT NOCOPY VARCHAR2
) IS

l_event_end_date        DATE := NULL;
l_comm_end_date         DATE := NULL;
l_commitment_number     VARCHAR2(20);
l_inventory_item_id     NUMBER;
l_agreement_id          NUMBER;

l_commitment_bal        NUMBER;
l_class                 VARCHAR2(30);
l_oe_source_code        VARCHAR2(30);
l_oe_installed_flag     VARCHAR2(30);

l_exists                VARCHAR2(1) := 'N';
l_debug_level           CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if l_debug_level > 0 then
    OE_DEBUG_PUB.Add('Entering OE_VALIDATE_LINE.Validate_Commitment',1);
    OE_DEBUG_PUB.Add('Commitment ID: '||p_line_rec.commitment_id||' Sold To Cust: '||p_line_rec.sold_to_org_id||
                     ' Invoice To Cust: '||p_line_rec.invoice_to_customer_id||' Curr Code: '||p_hdr_currency_code);
  end if;

  -- commented out the following SQL to replace it with new SQL.
  /***
  select ratrx.end_date_commitment, ratrx.trx_number
  into   l_comm_end_date, l_commitment_number
  from   ra_customer_trx ratrx
  where  ratrx.customer_trx_id = p_line_rec.commitment_id
  and    exists
        ( Select 1
          From ra_cust_trx_types ractt
          Where ractt.type in ('DEP','GUAR')
          and ratrx.cust_trx_type_id = ractt.cust_trx_type_id
          and ractt.org_id = p_line_rec.org_id)
  and    ratrx.bill_to_customer_id
        in (select      to_number(p_line_rec.sold_to_org_id )
            from        sys.dual
            union
            select      cust_account_id customer_id
          from hz_cust_acct_relate
          where related_cust_account_id = p_line_rec.sold_to_org_id
          and status = 'A')

  and   ratrx.invoice_currency_code = p_hdr_currency_code
  and   trunc(sysdate) between trunc(nvl( ratrx.start_date_commitment, sysdate))
        and trunc(nvl( ratrx.end_date_commitment, sysdate ))
  and   ratrx.complete_flag = 'Y' ;
  ***/

  /*
  ** Fix Bug # 3015881 Start
  ** Commitment Needs to be validated against Line Level Sold To or Invoice To
  */
  begin
    select /* MOAC_SQL_CHANGE */ 'Y'
    into   l_exists
    from   ra_customer_trx ratrx
    where  ratrx.bill_to_customer_id in
          (select p_line_rec.sold_to_org_id
           from   sys.dual
           union
           select cust_account_id customer_id
           from   hz_cust_acct_relate_all h
           where  related_cust_account_id = p_line_rec.sold_to_org_id
           and    status = 'A'
           and    bill_to_flag = 'Y'
           and    h.org_id =ratrx.org_id
           union
           select cas.cust_account_id customer_id
           from   hz_cust_site_uses_all su,
                  hz_cust_acct_sites_all cas
           where  cas.cust_acct_site_id = su.cust_acct_site_id
           and    su.site_use_id        = p_line_rec.invoice_to_org_id
           and    cas.org_id=ratrx.org_id
           union
           select c.cust_account_id customer_id
           from   hz_cust_acct_relate_all c,
                  hz_cust_site_uses_all su,
                  hz_cust_acct_sites_all cas
           where  cas.cust_acct_site_id     = su.cust_acct_site_id
           and    su.site_use_id            = p_line_rec.invoice_to_org_id
           and    c.related_cust_account_id = cas.cust_account_id
           and    c.status = 'A'
           and    c.org_id =ratrx.org_id
           and    cas.org_id=ratrx.org_id
           and    c.bill_to_flag = 'Y')
    and    ratrx.customer_trx_id = p_line_rec.commitment_id;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        null;
  end;

  if l_exists = 'N' then
    if l_debug_level > 0 then
      oe_debug_pub.add('Error: Commitment NOT related to Sold To/Invoice To at the line level');
    end if;

    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('ONT','ONT_COM_CUSTOMER_MISMATCH');
    FND_MESSAGE.SET_TOKEN('CUSTOMER','');
    OE_MSG_PUB.ADD;
  end if;

  /* Fix Bug # 3015881 End */

  -- fix bug 1618229
  select /* MOAC_SQL_CHANGE */ ratrx.end_date_commitment, ratrx.trx_number,
         ratrx.agreement_id, ratrl.inventory_item_id
  INTO   l_comm_end_date, l_commitment_number,
         l_agreement_id, l_inventory_item_id
  from   ra_customer_trx_all ratrx,
         ra_cust_trx_types_all ractt,
         ra_customer_trx_lines ratrl
  where  ractt.type in ('DEP','GUAR')
  AND    ratrx.cust_trx_type_id = ractt.cust_trx_type_id
  AND    ractt.org_id = p_line_rec.org_id
  AND    ratrl.org_id =ratrx.org_id
  AND    ratrl.customer_trx_id = ratrx.customer_trx_id
  and    ratrx.invoice_currency_code = p_hdr_currency_code
  and    trunc(sysdate) between trunc(nvl( ratrx.start_date_commitment, sysdate))
         and trunc(nvl( ratrx.end_date_commitment, sysdate ))
  and    ratrx.complete_flag = 'Y'
  AND    ratrx.customer_trx_id = p_line_rec.commitment_id;


  IF NOT OE_GLOBALS.EQUAL(nvl(l_agreement_id, p_line_rec.agreement_id), p_line_rec.agreement_id)
     AND p_line_rec.agreement_id IS NOT NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_message.set_name('ONT','ONT_COM_AGREEMENT_MISMATCH');
    FND_MESSAGE.SET_TOKEN('AGREEMENT',OE_Id_To_Value.Agreement(p_line_rec.agreement_id));
    OE_MSG_PUB.Add;
  END IF;

  IF NOT OE_GLOBALS.EQUAL(nvl(l_inventory_item_id, p_line_rec.inventory_item_id), p_line_rec.inventory_item_id) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_message.set_name('ONT','ONT_COM_ITEM_MISMATCH');
    FND_MESSAGE.SET_TOKEN('ITEM', OE_Id_To_Value.Inventory_Item(p_line_rec.inventory_item_id));
    OE_MSG_PUB.Add;
  END IF;
  IF l_debug_level > 0 then
  oe_debug_pub.add('OEXLLINB: commitment end date is: '||l_comm_end_date, 3);
  END IF;

  -- validating commitment against event end date for OTA line.
  IF p_ota_line THEN

    l_event_end_date := OE_OTA_UTIL.Get_OTA_Event_End_Date(
                                p_line_id => p_line_rec.line_id,
                                p_UOM     => p_line_rec.order_quantity_uom);
    IF l_debug_level > 0 then
    oe_debug_pub.add('Ota line- l_event_end_date: '||l_event_end_date||' l_comm_end_date: '||l_comm_end_date);
    END IF;

    IF l_event_end_date is NOT NULL AND
       l_comm_end_date is NOT NULL THEN
      IF trunc(l_comm_end_date)< trunc(l_event_end_date)
      THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('ONT','ONT_COM_END_DATE');
        FND_MESSAGE.SET_TOKEN('COMMITMENT',l_commitment_number);
        OE_MSG_PUB.Add;
      END IF;
    END IF;
  END IF;

  /* Start: Fix Bug # 2507479 - Validate Commitment Balance */

  IF p_line_rec.commitment_id IS NOT NULL AND
     p_line_rec.commitment_id <> FND_API.G_MISS_NUM THEN

    l_class := NULL;
    l_oe_source_code := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
    l_oe_installed_flag := 'I';
    IF l_debug_level > 0 then
    OE_DEBUG_PUB.Add('Before calling ARP_BAL_UTIL.GET_COMMITMENT_BALANCE');
    END IF;

    l_commitment_bal := ARP_BAL_UTIL.GET_COMMITMENT_BALANCE(
                          p_line_rec.commitment_id
                        , l_class
                        , l_oe_source_code
                        , l_oe_installed_flag );
    IF l_debug_level > 0 then
    OE_DEBUG_PUB.Add('After calling ARP_BAL_UTIL.GET_COMMITMENT_BALANCE');
    OE_DEBUG_PUB.Add('Commitment Balance is '||l_commitment_bal);
    END IF;

    IF l_commitment_bal <= 0 THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ONT','OE_COM_ZERO_BALANCE');
      FND_MESSAGE.SET_TOKEN('COMMITMENT',l_commitment_number);
      OE_MSG_PUB.Add;
    END IF;

  END IF;

  /* End: Fix Bug # 2507479 */
  IF l_debug_level > 0 then
  OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_LINE.Validate_Commitment',1);
  END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        IF l_debug_level > 0 then
        OE_DEBUG_PUB.Add('Validate_Commitment: When no data found');
        END IF;
        fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Commitment Number');
        OE_MSG_PUB.Add;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        IF l_debug_level > 0 then
        OE_DEBUG_PUB.Add('Validate_Commitment: When others');
        END IF;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_Commitment'
            );
        END IF;

END Validate_Commitment;


/*-------------------------------------------------------------
PROCEDURE Validate_Source_Type

We use this procedure to add validations related to source_type
= EXTERNAL.
--------------------------------------------------------------*/
PROCEDURE Validate_Source_Type
( p_line_rec      IN  OE_Order_PUB.Line_Rec_Type
 ,p_old_line_rec  IN  OE_Order_PUB.Line_Rec_Type
,x_return_status OUT NOCOPY VARCHAR2)

IS
  l_purchasing_enabled_flag VARCHAR2(1) := 'Y';
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  IF l_debug_level > 0 then
  OE_DEBUG_PUB.Add('Entering Validate_source_type', 3);
  END IF;

  IF (NOT OE_GLOBALS.Equal(p_line_rec.source_type_code,
                          p_old_line_rec.source_type_code) OR
      NOT OE_GLOBALS.Equal(p_line_rec.ship_from_org_id,
                          p_old_line_rec.ship_from_org_id)) AND
         OE_GLOBALS.Equal(p_line_rec.source_type_code,
                          OE_GLOBALS.G_SOURCE_EXTERNAL) THEN

    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110508'
    THEN
      IF p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_SERVICE OR
         p_line_rec.ship_model_complete_flag = 'Y'
      THEN
        IF l_debug_level > 0 then
        oe_debug_pub.add('service / part of smc model', 4);
        END IF;
        FND_MESSAGE.SET_NAME('ONT', 'OE_DS_NOT_VALID_ITEM');
        FND_MESSAGE.SET_TOKEN('ITEM', nvl(p_line_rec.ordered_item,p_line_rec.inventory_item_id));
        OE_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      ELSE
        IF l_debug_level > 0 then
        oe_debug_pub.add('validate line: pack H new logic DS', 1);
        END IF;
      END IF;
    ELSE
      IF (p_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_STANDARD) THEN
        IF l_debug_level > 0 then
        oe_debug_pub.add('Cannot dropship non-standard item',2);
        END IF;
        FND_MESSAGE.SET_NAME('ONT', 'OE_DS_NOT_ALLOWED');
        OE_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
    END IF;

    -- Validate Receiving Organization

    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510'
     -- AND INVCONV
     --   NOT INV_GMI_RSV_BRANCH.Process_Branch(p_line_rec.ship_from_org_id)  INVCONV
       THEN

          SELECT purchasing_enabled_flag
          INTO   l_purchasing_enabled_flag
          FROM   mtl_system_items msi,
                  org_organization_definitions org
          WHERE  msi.inventory_item_id = p_line_rec.inventory_item_id
          AND org.organization_id= msi.organization_id
          AND sysdate <= nvl( org.disable_date, sysdate)
          AND org.organization_id = nvl(p_line_rec.ship_from_org_id,
                   OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID'));
          IF l_debug_level > 0 then
          OE_DEBUG_PUB.Add('Pack-J Across SOB',2);
          END IF;
    ELSE
          SELECT purchasing_enabled_flag
          INTO   l_purchasing_enabled_flag
          FROM   mtl_system_items msi,
                 org_organization_definitions org
          WHERE msi.inventory_item_id = p_line_rec.inventory_item_id
          AND   org.organization_id= msi.organization_id
          AND sysdate <= nvl( org.disable_date, sysdate)
          AND org.organization_id = nvl(p_line_rec.ship_from_org_id,
                     OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID'))
          AND org.set_of_books_id= ( SELECT fsp.set_of_books_id
                               FROM financials_system_parameters fsp);
          IF l_debug_level > 0 then
          OE_DEBUG_PUB.Add('Pre Pack-J Logic',2);
          END IF;
    END IF;

    IF l_purchasing_enabled_flag = 'N' THEN
      FND_MESSAGE.SET_NAME('ONT', 'OE_DS_NOT_ENABLED');
      FND_MESSAGE.SET_TOKEN('ITEM', nvl(p_line_rec.ordered_item,p_line_rec.inventory_item_id));
      FND_MESSAGE.SET_TOKEN('ORG', nvl(p_line_rec.ship_from_org_id,
                     OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID')));
      OE_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

 END IF; -- if external

  IF p_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
     NOT OE_GLOBALS.Equal(p_line_rec.source_type_code,
                          p_old_line_rec.source_type_code) AND
     p_line_rec.ato_line_id <> p_line_rec.line_id AND
     OE_Config_Util.CASCADE_CHANGES_FLAG = 'N' AND
     OE_CODE_CONTROL.Get_Code_Release_Level >= '110508'
  THEN
    IF l_debug_level > 0 then
    oe_debug_pub.add('item under ato model', 4);
    END IF;
    FND_MESSAGE.SET_NAME('ONT', 'OE_DS_CHANGE_NOT_ALLOWED');
    OE_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  IF l_debug_level > 0 then
  oe_debug_pub.add('leaving validate_source_type', 3);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    oe_debug_pub.add('error in Validate_Source_Type');
    RAISE;
END Validate_Source_Type;


FUNCTION Validate_Set_id
( p_line_rec      IN  OE_Order_PUB.Line_Rec_Type
 ,p_old_line_rec  IN  OE_Order_PUB.Line_Rec_Type)
RETURN BOOLEAN
IS
l_arrival_set_id Number;
l_ship_set_id    Number;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN


     IF  (p_line_rec.top_model_line_id IS NOT NULL AND
          p_line_rec.top_model_line_id <> FND_API.G_MISS_NUM)
     AND  p_line_rec.top_model_line_id <> p_line_rec.line_id THEN

      IF (NOT OE_GLOBALS.Equal(p_line_rec.ship_set_id,
                               p_old_line_rec.ship_set_id) OR
          NOT OE_GLOBALS.Equal(p_line_rec.arrival_set_id,
                               p_old_line_rec.arrival_set_id)) THEN

        BEGIN

         Select arrival_set_id,
                ship_set_id
         Into   l_arrival_set_id,
                l_ship_set_id
         FROM OE_ORDER_LINES_ALL
         Where line_id = p_line_rec.top_model_line_id;

        EXCEPTION
          WHEN OTHERS THEN
            l_arrival_set_id := p_line_rec.arrival_set_id;
            l_ship_set_id    := p_line_rec.ship_set_id;
        END;

        IF l_debug_level > 0 then
        oe_debug_pub.add('ship_set_id : '|| p_line_rec.ship_set_id,2);
        oe_debug_pub.add('old ship_set_id : '|| p_old_line_rec.ship_set_id,2);
        oe_debug_pub.add('arrival_set_id : '|| p_line_rec.arrival_set_id,2);
        oe_debug_pub.add('old arrival_set_id : '|| p_old_line_rec.arrival_set_id,2);
        oe_debug_pub.add('l_arrival_set_id : '|| l_arrival_set_id,2);
        oe_debug_pub.add('l_ship_set_id : '|| l_ship_set_id,2);
        oe_debug_pub.add('3039131: OESCH_PERFORM_SCHEDULING:' ||
            OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING,1);
        END IF;

/* added the AND condition in the following if to fix the bug 3039131 */

        IF (NOT OE_GLOBALS.Equal(p_line_rec.ship_set_id,
                                 l_ship_set_id) OR
            NOT OE_GLOBALS.Equal(p_line_rec.arrival_set_id,
                                 l_arrival_set_id))  AND
            OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING = 'Y' THEN

           FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SET_OPR');
           FND_MESSAGE.SET_TOKEN('ITEMTYPE', p_line_rec.item_type_code);
           OE_MSG_PUB.ADD;
           IF l_debug_level > 0 then
           oe_debug_pub.add('Set- not allowed for this itemtype');
           END IF;
           RETURN FALSE;
        END IF;
      END IF; -- id
      IF l_debug_level > 0 then
      oe_debug_pub.add('OESCH_PERFORM_SCHEDULING:' ||
            OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING,1);
      END IF;
      IF ((p_line_rec.ship_set IS NOT NULL AND
          p_line_rec.ship_set <> FND_API.G_MISS_CHAR AND
          p_line_rec.ship_set_id is NULL )  OR
         (p_line_rec.arrival_set IS NOT NULL AND
          p_line_rec.arrival_set <> FND_API.G_MISS_CHAR AND
          p_line_rec.arrival_set_id IS NULL)) AND
          OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING = 'Y' THEN
          IF l_debug_level > 0 then
          oe_debug_pub.add('ship_set_id : '|| p_line_rec.ship_set_id,2);
          oe_debug_pub.add('ship_set : '|| p_line_rec.ship_set,2);
          oe_debug_pub.add('arrival_set_id : '|| p_line_rec.arrival_set_id,2);
          oe_debug_pub.add('arrival_set : '|| p_line_rec.arrival_set,2);
           oe_debug_pub.add('Set name - not allowed for this itemtype');
          END IF;
           FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SET_OPR');
           FND_MESSAGE.SET_TOKEN('ITEMTYPE', p_line_rec.item_type_code);
           OE_MSG_PUB.ADD;
           RETURN FALSE;
      END IF; -- set name
     END IF; -- main

  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level > 0 then
    oe_debug_pub.add('error in Validate_Set_id');
    END IF;
    RETURN FALSE;
END Validate_Set_id;

PROCEDURE Validate_User_Item_Description
 (p_line_rec                    IN OE_Order_PUB.Line_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2

  )
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  IF l_debug_level > 0 then
  oe_debug_pub.add('Enter Validate_User_Item_Description',1);
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF LENGTHB(p_line_rec.user_item_description) > 240 THEN
    fnd_message.set_name('ONT','ONT_USER_ITEM_DESC_TOO_LONG');
    OE_MSG_PUB.Add;
    IF l_debug_level > 0 then
    Oe_debug_pub.add('The length of user_item_description should not exceed 240 characters for drop ship lines.',3);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  IF l_debug_level > 0 then
  oe_debug_pub.add('Exit Validate_User_Item_Description',1);
  END IF;

EXCEPTION
    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        OE_DEBUG_PUB.Add('Validate_User_Item_Description: When others');
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_User_Item_Description'
            );
        END IF;
END Validate_User_Item_Description;


----------------------------------------------------------------------------
-- Procedure Validate_Blanket_Values
----------------------------------------------------------------------------

Procedure Validate_Blanket_Values
  (  p_line_rec       IN    OE_Order_PUB.Line_Rec_Type,
     p_old_line_rec   IN    OE_Order_PUB.Line_Rec_Type,
     x_return_status  OUT   NOCOPY   VARCHAR2
  )
  IS
     l_temp VARCHAR2(240);
     l_sold_to_org_id NUMBER;
     l_on_hold_flag VARCHAR2(1);
     l_item_id NUMBER;
     l_item_context VARCHAR2(240);
     l_item_cross_ref_type VARCHAR2(30);
     l_start_date_active DATE;
     l_end_date_active DATE;
     l_hdr_start_date_active DATE;
     l_hdr_end_date_active DATE;
     l_enforce_price_list_flag VARCHAR2(1);
     l_enforce_ship_to_flag VARCHAR2(1);
     l_enforce_invoice_to_flag VARCHAR2(1);
     l_enforce_freight_term_flag VARCHAR2(1);
     l_enforce_shipping_method_flag VARCHAR2(1);
     l_enforce_payment_term_flag VARCHAR2(1);
     l_enforce_accounting_rule_flag VARCHAR2(1);
     l_enforce_invoicing_rule_flag VARCHAR2(1);
     l_price_list_id NUMBER;
     L_SHIP_TO_ORG_ID NUMBER;
     L_INVOICE_TO_ORG_ID NUMBER;
     L_FREIGHT_TERMS_CODE VARCHAR2(30);
     L_SHIPPING_METHOD_CODE VARCHAR2(30);
     L_PAYMENT_TERM_ID NUMBER;
     L_ACCOUNTING_RULE_ID NUMBER;
     L_INVOICING_RULE_ID NUMBER;
     l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
     l_item_val_org         NUMBER;
     --FOR BUG 3192386
     l_flow_status_code     VARCHAR2(30);
     -- Bug 3232544
     lcustomer_relations    varchar2(1)  :=
               OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG');
     l_exists               varchar2(1);
     --For Bug 3257240
     l_customer_name                    VARCHAR2(240);
     l_customer_number                  NUMBER;
     l_address1                         VARCHAR2(240);
     l_address2                         VARCHAR2(240);
     l_address3                         VARCHAR2(240);
     l_address4                         VARCHAR2(240);
     l_location                         VARCHAR2(240);
     l_org                              VARCHAR2(240);
     l_city                             VARCHAR2(240);
     l_state                            VARCHAR2(240);
     l_postal_code                      VARCHAR2(240);
     l_country                          VARCHAR2(240);

      l_ordered_item_id NUMBER;
      l_ordered_item    OE_BLANKET_LINES_ALL.ORDERED_ITEM%TYPE; --Bug 7635963
 BEGIN

     x_return_status := fnd_api.g_ret_sts_success;

      if l_debug_level > 0 then
        OE_DEBUG_PUB.Add('Entering OE_VALIDATE_LINE.Validate_Blanket_Values',1);
      end if;

      IF p_line_rec.blanket_line_number IS NULL OR
                       p_line_rec.blanket_version_number IS NULL  THEN
          if l_debug_level > 0 then
             oe_debug_pub.add('Blanket Line Number is not supplied: Blanket #:'||
                           p_line_rec.blanket_number || ', Inventory Item #:'||p_line_rec.inventory_item_id, 2);
         end if;
         FND_MESSAGE.SET_NAME('ONT', 'OE_BLKT_NO_BLANKET_LINE_NUM');
         OE_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;


      if oe_code_control.get_code_release_level < '110510' then /* added by Srini FOR Pack J*/
        -- Bug 2757773 =>
        -- Items that are not standard items and are not top level kit items
        -- are not supported for blankets.
        IF ((p_line_rec.item_type_code <> 'STANDARD') AND
          NOT (p_line_rec.item_type_code = 'KIT' AND  p_line_rec.top_model_line_id = p_line_rec.line_id)) THEN

          SELECT meaning
          INTO l_temp
          FROM OE_LOOKUPS
          WHERE LOOKUP_TYPE = 'ITEM_TYPE'
          AND LOOKUP_CODE = p_line_rec.item_type_code;

          if l_debug_level > 0 then
              oe_debug_pub.add('Blankets only support standard items', 1);
          end if;

          FND_MESSAGE.SET_NAME('ONT', 'OE_BLKT_NON_STANDARD_ITEM');
          OE_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;
      ELSE --for bug  3372805
         IF(p_line_rec.item_type_code ='INCLUDED')
         THEN
            if l_debug_level > 0 then
              oe_debug_pub.add('Blankets does not support Included items', 1);
            end if;

            FND_MESSAGE.SET_NAME('ONT', 'OE_BLKT_INCLUDED_ITEM');
            OE_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

      END IF;  -- End of Pack -J changes.
      -- Blanket AND Agreement cannot co-exist on release line

      IF p_line_rec.agreement_id IS NOT NULL THEN
         FND_MESSAGE.SET_NAME('ONT', 'OE_BLKT_AGREEMENT_EXISTS');
         OE_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- If any of the above checks failed, no need to proceed with
      -- further blanket validations
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RETURN;
      END IF;


      -- Get data we'll need from blanket tables
      --Altered the sql for bug 3192386. Blankets in Negotiation or with Draft submitted as 'N' should not be selected
      SELECT /* MOAC_SQL_CHANGE */ BL.SOLD_TO_ORG_ID,
              BHE.on_hold_flag,
              BLE.START_DATE_ACTIVE,
              BLE.END_DATE_ACTIVE,
              BL.INVENTORY_ITEM_ID,
	      BL.ORDERED_ITEM_ID, --bug6929192
	      BL.ORDERED_ITEM,    --bug6929192
              BL.ITEM_IDENTIFIER_TYPE,
              BL.PRICE_LIST_ID,
              BL.SHIP_TO_ORG_ID,
              BL.INVOICE_TO_ORG_ID,
              BL.FREIGHT_TERMS_CODE,
              BL.SHIPPING_METHOD_CODE,
              BL.PAYMENT_TERM_ID,
              BL.ACCOUNTING_RULE_ID,
              BL.INVOICING_RULE_ID,
              BLE.ENFORCE_PRICE_LIST_FLAG,
              BLE.ENFORCE_SHIP_TO_FLAG,
              BLE.ENFORCE_INVOICE_TO_FLAG,
              BLE.ENFORCE_FREIGHT_TERM_FLAG,
              BLE.ENFORCE_SHIPPING_METHOD_FLAG,
              BLE.ENFORCE_PAYMENT_TERM_FLAG,
              BLE.ENFORCE_ACCOUNTING_RULE_FLAG,
              BLE.ENFORCE_INVOICING_RULE_FLAG,
              NVL(BH.FLOW_STATUS_CODE,'ACTIVE')
      INTO    l_sold_to_org_id,
              l_on_hold_flag,
              l_start_date_active,
              l_end_date_active,
              l_item_id,
	      l_ordered_item_id,
	      l_ordered_item,
              l_item_context,
              l_price_list_id,
              L_SHIP_TO_ORG_ID,
              L_INVOICE_TO_ORG_ID,
              L_FREIGHT_TERMS_CODE,
              L_SHIPPING_METHOD_CODE,
              L_PAYMENT_TERM_ID,
              L_ACCOUNTING_RULE_ID,
              L_INVOICING_RULE_ID,
              l_enforce_price_list_flag,
              l_enforce_ship_to_flag,
              l_enforce_invoice_to_flag,
              l_enforce_freight_term_flag,
              l_enforce_shipping_method_flag,
              l_enforce_payment_term_flag,
              l_enforce_accounting_rule_flag,
              l_enforce_invoicing_rule_flag,
              l_flow_status_code
      FROM    OE_BLANKET_LINES_ALL BL,OE_BLANKET_HEADERS BH,
              OE_BLANKET_HEADERS_EXT BHE,OE_BLANKET_LINES_EXT BLE
      WHERE   BLE.ORDER_NUMBER  = p_line_rec.blanket_number
      AND     BLE.LINE_NUMBER   = p_line_rec.blanket_line_number
      AND     BHE.ORDER_NUMBER  = BLE.ORDER_NUMBER
      AND     BL.LINE_ID        = BLE.LINE_ID
      AND     BH.ORDER_NUMBER   = BHE.ORDER_NUMBER
      AND     BL.SALES_DOCUMENT_TYPE_CODE = 'B'
      AND     BH.ORG_ID =BL.ORG_ID
      AND     NVL(BH.TRANSACTION_PHASE_CODE,'F')='F'
      AND     NVL(BH.DRAFT_SUBMITTED_FLAG,'Y') = 'Y';

      -- Set Item validation org parameter value
      l_item_val_org := to_number(OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID'));

      -- Blanket/Item Validations

      IF p_line_rec.inventory_item_id IS NOT NULL
         AND (NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_number
                             ,p_old_line_rec.blanket_number)
              OR NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_line_number
                             ,p_old_line_rec.blanket_line_number)
              OR NOT OE_GLOBALS.EQUAL(p_line_rec.inventory_item_id
                             ,p_old_line_rec.inventory_item_id)
	      OR NOT OE_GLOBALS.EQUAL(p_line_rec.ordered_item_id --bug6929192
                             ,p_old_line_rec.ordered_item_id)
	      OR NOT OE_GLOBALS.EQUAL(p_line_rec.ordered_item
                             ,p_old_line_rec.ordered_item)

			     )
      THEN

      --for cust and xrefs, validate l_item_id against p_inventory_item_id
   --bug6929192
   IF l_item_context = 'INT'  THEN      -- = '1' THEN

	   IF (l_item_id <>  p_line_rec.inventory_item_id) THEN
             if l_debug_level > 0 then
                oe_debug_pub.add('Release does not match blanket line inventory item', 1);
             end if;
             FND_MESSAGE.SET_NAME('ONT', 'OE_BLKT_INVALID_ATTRIBUTE');
             fnd_message.set_token('ATTRIBUTE',  OE_Order_Util.Get_Attribute_Name('INVENTORY_ITEM_ID'));
             --for bug 3257240
             FND_MESSAGE.SET_TOKEN('BLANKET_VALUE', OE_Id_To_Value.Inventory_Item(l_item_id));
             OE_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
      ELSIF l_item_context = 'CUST' THEN

	   IF (l_ordered_item_id <>  p_line_rec.ordered_item_id
	       OR l_item_id <> p_line_rec.inventory_item_id ) THEN
             if l_debug_level > 0 then
                oe_debug_pub.add('Release does not match blanket line customer item', 1);
             end if;
             FND_MESSAGE.SET_NAME('ONT', 'OE_BLKT_INVALID_ATTRIBUTE');
             fnd_message.set_token('ATTRIBUTE',  OE_Order_Util.Get_Attribute_Name('CUSTOMER_ITEM_ID'));
             --for bug 3257240
             FND_MESSAGE.SET_TOKEN('BLANKET_VALUE', OE_Id_To_Value.Inventory_Item(l_item_id));
             OE_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

      ELSIF l_item_context = 'ALL' THEN
            NULL; --Item is valid
      ELSIF l_item_context = 'CAT' THEN
            oe_debug_pub.add('SHIP FROM ORG ID: '||p_line_rec.ship_from_org_id);
            oe_debug_pub.add('INV ORG: '||l_item_val_org);
            oe_debug_pub.add('Cat ID: '||l_item_id);

            BEGIN
              SELECT  'VALID'
              INTO    l_temp
              FROM    MTL_ITEM_CATEGORIES
              WHERE   ORGANIZATION_ID = l_item_val_org  -- 5630818
              AND     INVENTORY_ITEM_ID = p_line_rec.inventory_item_id
              AND     CATEGORY_ID = l_item_id
              -- Bug 2857391 => Item can be assigned to this category
              -- in multiple category sets, select only 1 row to avoid
              -- multiple rows error.
              AND     ROWNUM = 1;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                SELECT DESCRIPTION
                INTO   l_temp
                FROM   MTL_CATEGORIES_VL
                WHERE  CATEGORY_ID = l_item_id;
                  if l_debug_level > 0 then
                     oe_debug_pub.add('Release does not match blanket line item category', 1);
                  end if;
                FND_MESSAGE.SET_NAME('ONT', 'OE_BLKT_INVALID_ATTRIBUTE');
                fnd_message.set_token('ATTRIBUTE',  OE_Order_Util.Get_Attribute_Name('INVENTORY_ITEM_ID'));
                --for bug 3257240
                FND_MESSAGE.SET_TOKEN('BLANKET_VALUE', OE_Id_To_Value.Inventory_Item(l_item_id));
                OE_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;
            END;

      ELSE
	 IF (l_ordered_item  <>  p_line_rec.ordered_item
	     OR l_item_id <> p_line_rec.inventory_item_id ) THEN

             if l_debug_level > 0 then
                oe_debug_pub.add('Release does not match blanket line xref item  item', 1);
             end if;
             FND_MESSAGE.SET_NAME('ONT', 'OE_BLKT_INVALID_ATTRIBUTE');
             fnd_message.set_token('ATTRIBUTE',  OE_Order_Util.Get_Attribute_Name('ORDERED_ITEM'));
             --for bug 3257240
             FND_MESSAGE.SET_TOKEN('BLANKET_VALUE', OE_Id_To_Value.Inventory_Item(l_item_id));
             OE_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
     END IF;
  END IF;



      -- Blanket/Customer Validation

      IF (NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_number
                             ,p_old_line_rec.blanket_number)
         OR NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_line_number
                             ,p_old_line_rec.blanket_line_number)
         OR NOT OE_GLOBALS.EQUAL(p_line_rec.sold_to_org_id
                             ,p_old_line_rec.sold_to_org_id) )
         AND l_sold_to_org_id <>  p_line_rec.sold_to_org_id
      THEN
       if l_debug_level > 0 then
          oe_debug_pub.add('Customer on release does not match blanket customer', 1);
          oe_debug_pub.add('blkt customer :'||l_sold_to_org_id);
          oe_debug_pub.add('line customer :'||p_line_rec.sold_to_org_id);
        end if;
        if lcustomer_relations = 'Y' then
           begin
           SELECT 'Y'
             INTO l_exists
             FROM HZ_CUST_ACCT_RELATE
            WHERE RELATED_CUST_ACCOUNT_ID = p_line_rec.sold_to_org_id
              AND CUST_ACCOUNT_ID = l_sold_to_org_id
              AND STATUS = 'A'
              AND ROWNUM = 1;
           exception
             when no_data_found then
               FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name
                                                ('SOLD_TO_ORG_ID'));
               --for bug 3257240
               OE_Id_To_Value.Sold_To_Org
                (   p_sold_to_org_id              => l_sold_to_org_id
                ,   x_org                         => l_customer_name
                ,   x_customer_number             => l_customer_number
                );
               FND_MESSAGE.SET_TOKEN('BLANKET_VALUE',l_customer_name);
               OE_MSG_PUB.Add;
               x_return_status := FND_API.G_RET_STS_ERROR;
           end;
        else
           FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_ATTRIBUTE');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name
                                                ('SOLD_TO_ORG_ID'));
           --for bug 3257240
           OE_Id_To_Value.Sold_To_Org
             (   p_sold_to_org_id              => l_sold_to_org_id
             ,   x_org                         => l_customer_name
             ,   x_customer_number             => l_customer_number
             );
           FND_MESSAGE.SET_TOKEN('BLANKET_VALUE',l_customer_name);
           OE_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
        end if;
      END IF;


      -- Blanket ON Hold Validation

      --only check if not a return
      -- Bug 2761943 => on hold check corrected.
      IF p_line_rec.line_category_code = 'ORDER' AND ( l_on_hold_flag <>  'N')
         AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_number
                             ,p_old_line_rec.blanket_number)
               OR NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_line_number
                             ,p_old_line_rec.blanket_line_number))
      THEN
        if l_debug_level > 0 then
           oe_debug_pub.add('Blanket order is currently on hold', 1);
        end if;
        FND_MESSAGE.SET_NAME('ONT', 'OE_BLKT_ON_HOLD');
        OE_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      --Active Blanket Validation for release lines.For Bug 3192386
      IF p_line_rec.line_category_code = 'ORDER' AND ( l_flow_status_code<>'ACTIVE')
         AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_number
                             ,p_old_line_rec.blanket_number)
               OR NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_line_number
                             ,p_old_line_rec.blanket_line_number))
      THEN
        if l_debug_level > 0 then
           oe_debug_pub.add('Blanket is not in Active Status', 1);
        end if;
        FND_MESSAGE.SET_NAME('ONT', 'OE_BLKT_INVALID_BLANKET');
        OE_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;


      -- Blanket/Request Date Validation

      IF p_line_rec.line_category_code = 'ORDER'
         AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_number
                             ,p_old_line_rec.blanket_number)
                OR NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_line_number
                             ,p_old_line_rec.blanket_line_number)
                OR NOT OE_GLOBALS.EQUAL(p_line_rec.request_date
                             ,p_old_line_rec.request_date))
         AND NOT trunc(nvl(p_line_rec.request_date,sysdate))
           BETWEEN trunc(l_start_date_active)
           -- Bug 2895023
           -- If end date active is null, substitute current request date
           -- so that validation will pass as long as request date is
           -- greater than start_date_active.
           AND     trunc(nvl(l_end_date_active
                             ,p_line_rec.request_date) )
      THEN
        if l_debug_level > 0 then
           oe_debug_pub.add('Request date is not within active blanket line dates', 1);
        end if;
        FND_MESSAGE.SET_NAME('ONT', 'OE_BLKT_INVALID_LINE_REQ_DATE');
        OE_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;



      -- Blankets: Check for fields that should be enforced to be
      -- same value as on blanket line.
      -- The check fires only if field is not null on both release line
      -- and blanket line (if l_value <>  p_line_rec.value check will return
      -- TRUE only if both are not null and the values do not match)

      IF l_enforce_price_list_flag = 'Y'
          AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_number
                             ,p_old_line_rec.blanket_number)
                OR NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_line_number
                             ,p_old_line_rec.blanket_line_number)
                OR NOT OE_GLOBALS.EQUAL(p_line_rec.price_list_id
                             ,p_old_line_rec.price_list_id) )
      THEN
          IF l_price_list_id <>  p_line_rec.price_list_id THEN
             FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name
                                                ('PRICE_LIST_ID'));
             --for bug 3257240
             FND_MESSAGE.SET_TOKEN('BLANKET_VALUE',OE_Id_To_Value.Price_List(l_price_list_id));
             OE_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
       END IF;

       IF l_enforce_ship_to_flag = 'Y'
          AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_number
                             ,p_old_line_rec.blanket_number)
                OR NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_line_number
                             ,p_old_line_rec.blanket_line_number)
                OR NOT OE_GLOBALS.EQUAL(p_line_rec.ship_to_org_id
                             ,p_old_line_rec.ship_to_org_id) )
       THEN
          IF l_ship_to_org_id <>  p_line_rec.ship_to_org_id THEN
             FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name
                                                ('SHIP_TO_ORG_ID'));
             --for bug 3257240
             OE_ID_TO_VALUE.ship_to_Org
                ( p_ship_to_org_id      => p_line_rec.ship_to_org_id
                , x_ship_to_address1    => l_address1
                , x_ship_to_address2    => l_address2
                , x_ship_to_address3    => l_address3
                , x_ship_to_address4    => l_address4
                , x_ship_to_location    => l_location
                , x_ship_to_org         => l_org
                , x_ship_to_city        => l_city
                , x_ship_to_state       => l_state
                , x_ship_to_postal_code => l_postal_code
                , x_ship_to_country     => l_country
                );
             FND_MESSAGE.SET_TOKEN('BLANKET_VALUE',l_org);
             OE_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
       END IF;

       IF l_enforce_invoice_to_flag = 'Y'
          AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_number
                             ,p_old_line_rec.blanket_number)
                OR NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_line_number
                             ,p_old_line_rec.blanket_line_number)
                OR NOT OE_GLOBALS.EQUAL(p_line_rec.invoice_to_org_id
                             ,p_old_line_rec.invoice_to_org_id) )
       THEN
          IF l_invoice_to_org_id <> p_line_rec.invoice_to_org_id THEN
             FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name
                                                ('INVOICE_TO_ORG_ID'));
             --for bug 3257240
             OE_ID_TO_VALUE.Invoice_To_Org
                ( p_invoice_to_org_id      => p_line_rec.invoice_to_org_id
                , x_invoice_to_address1    => l_address1
                , x_invoice_to_address2    => l_address2
                , x_invoice_to_address3    => l_address3
                , x_invoice_to_address4    => l_address4
                , x_invoice_to_location    => l_location
                , x_invoice_to_org         => l_org
                , x_invoice_to_city        => l_city
                , x_invoice_to_state       => l_state
                , x_invoice_to_postal_code => l_postal_code
                , x_invoice_to_country     => l_country
                );
             FND_MESSAGE.SET_TOKEN('BLANKET_VALUE',l_org);
             OE_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
       END IF;

       IF l_enforce_freight_term_flag = 'Y'
          AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_number
                             ,p_old_line_rec.blanket_number)
                OR NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_line_number
                             ,p_old_line_rec.blanket_line_number)
                OR NOT OE_GLOBALS.EQUAL(p_line_rec.freight_terms_code
                             ,p_old_line_rec.freight_terms_code) )
       THEN
          IF l_freight_terms_code <> p_line_rec.freight_terms_code THEN
             FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name
                                                ('FREIGHT_TERMS_CODE'));
             --for bug 3257240
             FND_MESSAGE.SET_TOKEN('BLANKET_VALUE',OE_Id_To_Value.Freight_Terms(l_freight_terms_code));
             OE_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
       END IF;

       IF l_enforce_shipping_method_flag = 'Y'
          AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_number
                             ,p_old_line_rec.blanket_number)
                OR NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_line_number
                             ,p_old_line_rec.blanket_line_number)
                OR NOT OE_GLOBALS.EQUAL(p_line_rec.shipping_method_code
                             ,p_old_line_rec.shipping_method_code) )
       THEN
          IF l_shipping_method_code <> p_line_rec.shipping_method_code THEN
             FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name
                                                ('SHIPPING_METHOD_CODE'));
             --for bug 3257240
             FND_MESSAGE.SET_TOKEN('BLANKET_VALUE',OE_Id_To_Value.Ship_Method(l_shipping_method_code));
             OE_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
       END IF;

       IF l_enforce_payment_term_flag = 'Y'
          AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_number
                             ,p_old_line_rec.blanket_number)
                OR NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_line_number
                             ,p_old_line_rec.blanket_line_number)
                OR NOT OE_GLOBALS.EQUAL(p_line_rec.payment_term_id
                             ,p_old_line_rec.payment_term_id) )
       THEN
          IF l_payment_term_id <> p_line_rec.payment_term_id THEN
             FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name
                                                ('PAYMENT_TERM_ID'));
             --for bug 3257240
             FND_MESSAGE.SET_TOKEN('BLANKET_VALUE',OE_Id_To_Value.Payment_Term(l_payment_term_id));
             OE_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
       END IF;

       IF l_enforce_accounting_rule_flag = 'Y'
          AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_number
                             ,p_old_line_rec.blanket_number)
                OR NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_line_number
                             ,p_old_line_rec.blanket_line_number)
                OR NOT OE_GLOBALS.EQUAL(p_line_rec.accounting_rule_id
                             ,p_old_line_rec.accounting_rule_id) )
       THEN
          IF l_accounting_rule_id <> p_line_rec.accounting_rule_id THEN
             FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name
                                                ('ACCOUNTING_RULE_ID'));
             --for bug 3257240
             FND_MESSAGE.SET_TOKEN('BLANKET_VALUE',OE_Id_To_Value.Accounting_Rule(l_accounting_rule_id));
             OE_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
       END IF;

       IF l_enforce_invoicing_rule_flag = 'Y'
          AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_number
                             ,p_old_line_rec.blanket_number)
                OR NOT OE_GLOBALS.EQUAL(p_line_rec.blanket_line_number
                             ,p_old_line_rec.blanket_line_number)
                OR NOT OE_GLOBALS.EQUAL(p_line_rec.invoicing_rule_id
                             ,p_old_line_rec.invoicing_rule_id) )
       THEN
          IF l_invoicing_rule_id <> p_line_rec.invoicing_rule_id THEN
             FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name
                                                ('INVOICING_RULE_ID'));
             --for bug 3257240
             FND_MESSAGE.SET_TOKEN('BLANKET_VALUE',OE_Id_To_Value.Invoicing_Rule(l_invoicing_rule_id));
             OE_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
       END IF;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
          if l_debug_level  > 0 then
             oe_debug_pub.add('Blanket Values combination is not valid: Blanket #:'||
                       p_line_rec.blanket_number || ', Blanket Line #:'||p_line_rec.blanket_line_number, 2);
          end if;
             FND_MESSAGE.SET_NAME('ONT', 'OE_BLKT_INVALID_BLANKET');
             OE_MSG_PUB.Add;
             x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
        if l_debug_level > 0 then
        OE_DEBUG_PUB.Add('Expected Error in Validate Blanket Values',2);
      End if;

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    if l_debug_level > 0 then
        OE_DEBUG_PUB.Add('Unexpected Error in Validate Blanket Values:'||SqlErrm, 1);
    End if;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   'OE_VALIDATE_LINE',
              'Validate_Blanket_Values');
        END IF;

END Validate_Blanket_Values;

/*------------------------------------------------------------------------------
Procedure Name: Get_Return_Line_Attributes
    Procedure to return the item type code of the reference line in case of
returns. In case the line is part of ato model the function also returns the
ato_line_id. Added for bug 3718547.
------------------------------------------------------------------------------*/
PROCEDURE Get_Return_Line_Attributes
( p_line_rec        IN OE_Order_PUB.Line_Rec_Type
, x_line_id         OUT NOCOPY NUMBER
, x_item_type_code  OUT NOCOPY VARCHAR2
, x_ato_line_id     OUT NOCOPY NUMBER
, x_return_status   OUT NOCOPY VARCHAR2
)
IS
l_debug_level       CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

   x_item_type_code := p_line_rec.item_type_code;
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   IF p_line_rec.line_category_code = 'RETURN'
      AND p_line_rec.reference_line_id IS NOT NULL
      AND p_line_rec.return_context IS NOT NULL
   THEN

      SELECT item_type_code, ato_line_id
      INTO x_item_type_code, x_ato_line_id
      FROM oe_order_lines
      WHERE line_id = p_line_rec.reference_line_id;

      x_line_id        := p_line_rec.reference_line_id;
   END IF;

EXCEPTION

   WHEN OTHERS THEN

      x_ato_line_id    := p_line_rec.ato_line_id;
      x_item_type_code := p_line_rec.item_type_code;
      x_line_id        := p_line_rec.reference_line_id;

      IF l_debug_level > 0 THEN
        oe_debug_pub.add('Unexpected error in OE_Validate_Line.Get_Return_Line_Attributes');
      END IF;

END Get_Return_Line_Attributes;

------------------------------------------------------------
-- PUBLIC PROCEDURES

--change record for MACD
--MACD: It calls the OE_CONFIG_TSO_PVT.Validate_Container_Model
--to ensure that model restrictions are followed.
--  Procedure Entity
-- We are modifying the procedure ENTITY signature to make p_line_rec as
-- IN OUT NOCOPY. If Entity Validation fails for a combination of attributes
-- then these attributes can be set to MISSING and get new values re-defaulted
-- This logic is needed if
--     * COPY is calling process_order.
--     * User is trying to create a referenced RMA.
--     * User is trying to change the RMA reference.
--
--
PROCEDURE Entity
( x_return_status OUT NOCOPY VARCHAR2
, p_line_rec      IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type
, p_old_line_rec  IN  OE_Order_PUB.Line_Rec_Type := OE_Order_PUB.G_MISS_LINE_REC
, p_validation_level                  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
)
IS
l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_commitment_status   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_valid_line_number   VARCHAR2(1) := 'Y';
l_dummy               VARCHAR2(10);
l_uom                 VARCHAR2(3);
l_uom_count           NUMBER;
/*1544265*/
l_ret_status              BOOLEAN:=TRUE;
/*1544265*/
l_agreement_name          VARCHAR2(240);
l_item_type_code          VARCHAR2(30);
l_sold_to_org             NUMBER;
l_price_list_id   NUMBER;
l_price_list_name         VARCHAR2(240);
l_option_count        NUMBER;
l_is_ota_line       BOOLEAN;
l_order_quantity_uom VARCHAR2(3);
lcustomer_relations varchar2(1)  := OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG');
l_list_type_code          VARCHAR2(30);
l_currency_code           VARCHAR2(30);
l_hdr_currency_code       VARCHAR2(30);
l_restrict_subinv         NUMBER;
l_auto_schedule_sets   VARCHAR2(1):='Y' ;  --rakesh 4241385
--l_price_list_name         VARCHAR2(240);
--MC BGN
l_validate_result VARCHAR2(1):='Y';
--MC End
/*OPM 02/JUN/00 BEGIN
====================*/
l_item_rec         OE_ORDER_CACHE.item_rec_type; -- OPM
--l_OPM_UOM           VARCHAR2(4);    --OPM 06/22  --INVCONV
l_status            VARCHAR2(1);    --OPM 06/22
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(2000);
l_return            NUMBER;
--3718547
l_ato_line_id       NUMBER;
l_line_id           NUMBER;
--Begin Bug 2639667
l_delta_qty1        NUMBER;
l_delta_qty2        NUMBER;
l_req_qty1          NUMBER;
l_req_qty2          NUMBER;
l_delivery_count    NUMBER;
l_pick_flag         VARCHAR2(1);
l_rounded_qty       NUMBER;

l_top_container_model VARCHAR2(1);
l_part_of_container   VARCHAR2(1);
l_item_description    VARCHAR2(240);
l_mast_org_id NUMBER := OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID');
CURSOR pick_status IS
SELECT  RELEASED_STATUS, SRC_REQUESTED_QUANTITY,
        SRC_REQUESTED_QUANTITY2
FROM    WSH_DELIVERY_DETAILS
WHERE   SOURCE_CODE = 'OE'
  AND   SOURCE_LINE_ID = p_line_rec.line_id;

--End Bug 2639667
/*OPM 02/JUN/00 END
==================*/
l_header_created    BOOLEAN := FALSE;

-- Added for Enhanced Project Validation
result                 VARCHAR2(1) := PJM_PROJECT.G_VALIDATE_SUCCESS;
errcode                VARCHAR2 (80);
l_order_date_type_code VARCHAR2(10);
p_date                 DATE;

l_scheduling_Level_code VARCHAR2(30);   -- 2691825
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

--l_po_status            VARCHAR2(4100);
l_req_status           VARCHAR2(4100);
l_ds_req               VARCHAR2(240) := '';
l_ds_po                VARCHAR2(240) := '';
l_line_num              VARCHAR2(50);

-- Ar System Parameters
l_AR_Sys_Param_Rec    AR_SYSTEM_PARAMETERS_ALL%ROWTYPE;
l_sob_id              NUMBER;

-- For Bug 3323610
l_tot_transaction_quantity      NUMBER :=0;
l_quantity_entered          NUMBER :=0;
l_notnull_revision_flag     VARCHAR2(1) := 'N';

--bug 4411054
l_req_header_id         NUMBER;
l_po_header_id          NUMBER;
l_po_status_rec         PO_STATUS_REC_TYPE;
l_cancel_flag           VARCHAR2(1);
l_closed_code           VARCHAR2(30);

CURSOR c_transaction_quantity IS
        SELECT ABS(mmt.transaction_quantity) transaction_quantity,
               mmt.transaction_uom,
               mmt.revision
        FROM   oe_order_lines_all ool, mtl_material_transactions mmt
        WHERE  ool.line_id = p_line_rec.reference_line_id
        AND    mmt.transaction_source_type_id = 2
        AND    mmt.transaction_type_id = 33
        AND    mmt.trx_source_line_id = ool.line_id
        AND    mmt.inventory_item_id = ool.inventory_item_id
        AND    mmt.organization_id = ool.ship_from_org_id;
     --   AND    mmt.revision = p_line_rec.item_revision;

-- For bug3327250
    l_old_line_tbl                 OE_Order_PUB.Line_Tbl_Type;
    l_line_tbl                     OE_Order_PUB.Line_Tbl_Type;
    l_control_rec                  OE_GLOBALS.Control_Rec_Type;
    l_old_line_rec                 OE_Order_PUB.Line_Rec_Type;
--  Variable to indicate Referenced RMA creation or change of reference
    G_REF_RMA    VARCHAR2(1) := 'N';
--  Variable to indicate that a oe_order_pvt.line call is needed to redefault
--  Missing / Invalid attributes
    G_REDEFAULT_MISSING  VARCHAR2(1) := 'N';
--added for bug 3739650
   l_site_use_code   VARCHAR2(30);

   l_ordered_quantity     NUMBER;
   l_cancelled_quantity   NUMBER;

 -- eBTax Changes
   l_ship_to_cust_Acct_id  hz_cust_Accounts.cust_Account_id%type;
  l_ship_to_party_id      hz_cust_accounts.party_id%type;
  l_ship_to_party_site_id hz_party_sites.party_site_id%type;
  l_bill_to_cust_Acct_id  hz_cust_Accounts.cust_Account_id%type;
  l_bill_to_party_id      hz_cust_accounts.party_id%type;
  l_bill_to_party_site_id hz_party_sites.party_site_id%type;
  l_org_id                NUMBER;
-- l_legal_entity_id       NUMBER;

     cursor partyinfo(p_site_org_id HZ_CUST_SITE_USES_ALL.SITE_USE_ID%type) is
     SELECT cust_acct.cust_account_id,
            cust_Acct.party_id,
            acct_site.party_site_id,
            site_use.org_id
      FROM
            HZ_CUST_SITE_USES_ALL       site_use,
            HZ_CUST_ACCT_SITES_ALL      acct_site,
            HZ_CUST_ACCOUNTS_ALL        cust_Acct
     WHERE  site_use.site_use_id = p_site_org_id
       AND  site_use.cust_acct_site_id  = acct_site.cust_acct_site_id
       and  acct_site.cust_account_id = cust_acct.cust_account_id;

 -- end eBTax changes
 --added for bug 4200055
   l_price_list_rec    OE_ORDER_CACHE.Price_List_Rec_Type ;
 --PP Revenue Recognition
 --bug 4893057
 l_rule_type VARCHAR2(10);
 l_line_type VARCHAR2(80);
BEGIN
    IF l_debug_level > 0 then
    oe_debug_pub.add('Enter OE_VALIDATE_LINE.ENTITY',1);
    END IF;

    IF OE_GLOBALS.G_HEADER_CREATED
    THEN
        IF l_debug_level > 0 then
    oe_debug_pub.add('Header has got created in the same call',1);
        END IF;
        OE_Order_Cache.Load_Order_Header(p_line_rec.header_id);
        l_header_created := TRUE;
    END IF;

    -----------------------------------------------------------
    --  Check required attributes.
    -----------------------------------------------------------

   IF l_debug_level > 0 then
    oe_debug_pub.add('1 '||l_return_status, 1);
   END IF;
    IF  p_line_rec.line_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('LINE_ID'));
        OE_MSG_PUB.Add;

    END IF;
    IF l_debug_level > 0 then
    oe_debug_pub.add('2 '||l_return_status, 1);
    END IF;
    IF p_line_rec.inventory_item_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('INVENTORY_ITEM_ID'));
        OE_MSG_PUB.Add;

    END IF;
    IF l_debug_level > 0 then
    oe_debug_pub.add('3 '||l_return_status, 1);
    END IF;
    IF  p_line_rec.line_type_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('LINE_TYPE_ID'));
        OE_MSG_PUB.Add;

    ELSIF p_line_rec.line_type_id IS NOT NULL  AND  -- Bug 5873408
          ( nvl(p_line_rec.transaction_phase_code, 'F') <> 'N' )
       THEN
               Validate_line_type(p_line_rec => p_line_rec,
                                  p_old_line_rec => p_old_line_rec);

    END IF;
--begin rakesh 4241385
    l_auto_schedule_sets := NVL(oe_sys_parameters.Value('ONT_AUTO_SCH_SETS',p_line_rec.org_id),'Y'); --rakesh 4241385
    IF l_auto_schedule_sets = 'N' THEN

      IF ((p_line_rec.arrival_set_id IS NOT  NULL
       AND p_line_rec.arrival_set_id <> FND_API.G_MISS_NUM)
       OR
       ( p_line_rec.arrival_set IS NOT NULL
     AND p_line_rec.arrival_set <> FND_API.G_MISS_char ))
     THEN

      IF  p_line_rec.ship_from_org_id IS NULL THEN
	   FND_MESSAGE.SET_NAME('ONT','ONT_ATTR_REQ_SET');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',oe_order_util.GET_ATTRIBUTE_name('SHIP_FROM_ORG_ID'));
			OE_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
      END IF ;

    /*  IF  p_line_rec.shipping_method_code IS NULL THEN
	   FND_MESSAGE.SET_NAME('ONT','ONT_ATTR_REQ_SET');  --rakesh
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Ship Method');
			OE_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
      END IF ; */

   END IF ;

   IF ((p_line_rec.ship_set_id IS NOT  NULL
    AND p_line_rec.ship_set_id <> FND_API.G_MISS_NUM)
    OR
   ( p_line_rec.ship_set IS NOT NULL
   AND p_line_rec.ship_set <> FND_API.G_MISS_char ))
   THEN

       IF  p_line_rec.ship_from_org_id IS NULL THEN
	   FND_MESSAGE.SET_NAME('ONT','ONT_ATTR_REQ_SET');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',oe_order_util.GET_ATTRIBUTE_name('SHIP_FROM_ORG_ID'));
			OE_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
      END IF ;

     /* IF  p_line_rec.shipping_method_code IS NULL THEN
	   FND_MESSAGE.SET_NAME('ONT','ONT_ATTR_REQ_SET');   --rakesh
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Ship Method');
			OE_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
      END IF ; */
   END IF ;
  END IF ;
-- end rakesh 4241385
    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    -- Changes for bug 8889277 - Start
    IF  p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_SERVICE THEN

        oe_debug_pub.add(  '1  P_LINE_REC.service_number  = '||P_LINE_REC.service_number  ) ;
        oe_debug_pub.add(  '2  P_LINE_REC.service_reference_type_code  = '||P_LINE_REC.service_reference_type_code  ) ;
        oe_debug_pub.add(  '3  P_LINE_REC.service_reference_line_id  = '||P_LINE_REC.service_reference_line_id  ) ;
        oe_debug_pub.add(  '4  P_LINE_REC.service_reference_system_id  = '||P_LINE_REC.service_reference_system_id  ) ;
        oe_debug_pub.add(  '5  P_LINE_REC.service_ref_order_number  = '||P_LINE_REC.service_ref_order_number  ) ;
	oe_debug_pub.add(  '6  P_LINE_REC.service_ref_line_number  = '||P_LINE_REC.service_ref_line_number  ) ;
	oe_debug_pub.add(  '7  P_LINE_REC.service_reference_order  = '||P_LINE_REC.service_reference_order  ) ;
	oe_debug_pub.add(  '8  P_LINE_REC.service_reference_line  = '||P_LINE_REC.service_reference_line  ) ;
	oe_debug_pub.add(  '9  P_LINE_REC.service_reference_system  = '||P_LINE_REC.service_reference_system  ) ;
	oe_debug_pub.add(  '10 P_LINE_REC.service_ref_shipment_number  = '||P_LINE_REC.service_ref_shipment_number  ) ;
	oe_debug_pub.add(  '11 P_LINE_REC.service_ref_option_number  = '||P_LINE_REC.service_ref_option_number  ) ;
	oe_debug_pub.add(  '12 P_LINE_REC.service_line_index  = '||P_LINE_REC.service_line_index  ) ;

	IF NVL(P_LINE_REC.SERVICE_REFERENCE_TYPE_CODE, FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR THEN
	   l_return_status := FND_API.G_RET_STS_ERROR;
	   fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE', oe_order_util.get_attribute_name('SERVICE_REFERENCE_TYPE_CODE'));
	   OE_MSG_PUB.Add;
	ELSIF NVL(P_LINE_REC.SERVICE_REFERENCE_LINE_ID, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
	      l_return_status := FND_API.G_RET_STS_ERROR;
	      fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE', oe_order_util.get_attribute_name('SERVICE_REFERENCE_LINE_ID'));
	      OE_MSG_PUB.Add;
	END IF;

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
	END IF;

    END IF;
    -- Changes for bug 8889277 - End


    --------------------------------------------------------------
    --  Check conditionally required attributes here.
    --------------------------------------------------------------

    -- QUOTING changes
    IF oe_code_control.code_release_level >= '110510' THEN

       Check_Negotiation_Attributes(p_line_rec
                                   ,p_old_line_rec
                                   ,l_return_status
                                   );

    ELSE

       -- Feature not supported prior to 11i10, raise error
       IF p_line_rec.transaction_phase_code = 'N' THEN
          FND_MESSAGE.SET_NAME('ONT','OE_QUOTE_INVALID_RELEASE');
          OE_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;

    l_item_type_code := p_line_rec.item_type_code;

    --  For return lines, Return_Reason_Code is required
    IF l_debug_level > 0 then
    oe_debug_pub.add('5 '||l_return_status, 1);
    END IF;
    IF p_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE
    THEN
        --  For return lines, Return_Reason_Code is required
        IF p_line_rec.return_reason_code is NULL
        THEN
            l_return_status := FND_API.G_RET_STS_ERROR;

            fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('RETURN_REASON_CODE'));
            OE_MSG_PUB.Add;
        END IF;

        -- Set the G_REF_RMA if the RMA is getting created or the reference is
        -- changing.

        if l_debug_level > 0 then
            oe_debug_pub.add('The return attr 2 is '||p_line_rec.return_attribute2);
            oe_debug_pub.add('The old return attr 2 is '||p_old_line_rec.return_attribute2);
           oe_debug_pub.add('The ship_to_org_id is '||p_line_rec.ship_to_org_id);
        end if;
        IF l_return_status = FND_API.G_RET_STS_SUCCESS AND
           NOT OE_GLOBALS.EQUAL(p_line_rec.return_attribute2,
                                p_old_line_rec.return_attribute2)
        THEN
            G_REF_RMA := 'Y';
            if l_debug_level > 0 then
                OE_DEBUG_PUB.Add('Setting G_REF_RMA',1);
            end if;
        END IF;

        --3718547
        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
	   Get_Return_Line_Attributes
              ( p_line_rec        => p_line_rec
              , x_line_id         => l_line_id
              , x_item_type_code  => l_item_type_code
              , x_ato_line_id     => l_ato_line_id
              , x_return_status   => l_return_status);
	END IF;

    END IF;

    IF l_debug_level > 0 then
    oe_debug_pub.add('6 '||l_return_status, 1);
    END IF;

    ---- Start 2691825  ---
    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
       IF l_debug_level > 0 then
       oe_debug_pub.add('Checking that it is a standard item...',1);
       END IF;

       IF (p_line_rec.item_type_code IN( 'MODEL','CLASS','KIT','OPTION')
          AND p_line_rec.line_category_code = 'ORDER'
          AND p_line_rec.source_type_code = 'INTERNAL')
       OR (p_line_rec.ship_set_id is not null
          OR  P_line_rec.arrival_set_id is not null) THEN   -- 2527722
          IF l_debug_level > 0 then
             oe_debug_pub.add('Checking the level...',1);
          END IF;
          l_scheduling_level_code := Oe_Schedule_Util.Get_Scheduling_Level(p_line_rec.header_id,
                                                                          p_line_rec.line_type_id);
          l_line_type :=nvl(Oe_Schedule_Util.sch_cached_line_type ,'0');
          -- Any item other than Standard can not have level - four or five
          IF (l_scheduling_level_code = OE_SCHEDULE_UTIL.SCH_LEVEL_FOUR
              OR l_scheduling_level_code = OE_SCHEDULE_UTIL.SCH_LEVEL_FIVE) THEN

             -- Standalone
	     -- Allow Inactive Demand lines with SCH level as 4 or 5 to a set
	     -- Active Demand lines with other sch levels will not be allowed to a Inactive Demand set and vice versa.

	     IF p_line_rec.item_type_code = 'STANDARD' THEN

 	        IF OE_SET_UTIL.stand_alone_set_exists(P_SHIP_SET_ID => p_line_rec.ship_set_id ,
                                                 p_arrival_set_id => p_line_rec.arrival_set_id,
                                        p_header_id    => p_line_rec.header_id,
                                        p_line_id  => p_line_rec.line_id,
                                        p_sch_level => l_scheduling_level_code) THEN
                   NULL;
	        ELSE
                   FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_NONSTANDALONE');
                   OE_MSG_PUB.Add;
                   IF l_debug_level > 0 then
                      oe_debug_pub.add(  'This is a Active Demand set. Inactive Demand lines not allowed', 1 ) ;
                   END IF;
                   l_return_status := FND_API.G_RET_STS_ERROR;
	        END IF;
             ELSE
               FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_INACTIVE_STD_ONLY');
               FND_MESSAGE.SET_TOKEN('LTYPE',l_line_type);
               OE_MSG_PUB.Add;
               l_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
         ELSIF (p_line_rec.ship_set_id is not null
          OR  P_line_rec.arrival_set_id is not null)
          AND NOT OE_SET_UTIL.stand_alone_set_exists(P_SHIP_SET_ID => p_line_rec.ship_set_id ,
                                                 p_arrival_set_id => p_line_rec.arrival_set_id,
                                        p_header_id    => p_line_rec.header_id,
                                        p_line_id  => p_line_rec.line_id,
                                        p_sch_level => l_scheduling_level_code) THEN
             IF l_debug_level > 0 then
                oe_debug_pub.add(  'This is a Inactive Demand set. Active Demand lines not allowed', 1 ) ;
             END IF;

            FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_STANDALONE');
            OE_MSG_PUB.Add;
            l_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

       END IF;
    END IF;
    -- End 2691825 -----
    -- Start 2720165 --
    IF  p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_SERVICE
    AND p_line_rec.reserved_quantity is not null
    AND p_line_rec.reserved_quantity <> FND_API.G_MISS_NUM  THEN
          IF l_debug_level > 0 then
          oe_debug_pub.add(  'A SERVICE LINE ', 1 ) ;
          END IF;

          FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
          OE_MSG_PUB.Add;
          l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    ---- End 2720165 --

    -- subinventory
    IF l_debug_level > 0 then
    oe_debug_pub.add('Entity: subinventory - ' || p_line_rec.subinventory);
    END IF;
    -- first validate warehouse/subinv combination is valid

    IF p_line_rec.ship_from_org_id is not null AND
       p_line_rec.subinventory is not null AND
       p_line_rec.ship_From_org_id <> FND_API.G_MISS_NUM AND
       p_line_rec.subinventory <> FND_API.G_MISS_CHAR THEN

       IF p_line_rec.ship_from_org_id <> nvl(p_old_line_rec.ship_from_org_id, 0) OR
          p_line_rec.subinventory <> nvl(p_old_line_rec.subinventory, '0') THEN
            BEGIN
               SELECT 'VALID'
               INTO  l_dummy
               FROM MTL_SUBINVENTORIES_TRK_VAL_V
               WHERE organization_id = p_line_rec.ship_from_org_id
               AND secondary_inventory_name = p_line_rec.subinventory;
            EXCEPTION
               WHEN OTHERS THEN
                   fnd_message.set_name('ONT','OE_SUBINV_INVALID');
                   OE_MSG_PUB.Add;
                   l_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
            END;
       END IF;
    END IF;

    --Shipment number cannot be updated. Bug 3456544
    IF  nvl(p_line_rec.shipment_number,FND_API.G_MISS_NUM) <> nvl(p_old_line_rec.shipment_number,FND_API.G_MISS_NUM)
    AND p_line_rec.operation =OE_GLOBALS.G_OPR_UPDATE
    AND nvl(p_line_rec.split_action_code,'X')<>'SPLIT'
    THEN
          fnd_message.set_name('ONT','OE_CANT_UPDATE_SHIPMENT_NO');
          OE_MSG_PUB.Add;
          l_return_status:=FND_API.G_RET_STS_ERROR;
    END IF;

    IF p_line_rec.subinventory is not null THEN
          IF p_line_rec.source_type_code = 'INTERNAL' OR
             p_line_rec.source_type_code is null THEN
                IF l_debug_level > 0 then
                oe_debug_pub.add('Entity Validateion:  subinventory', 1);
                END IF;
            IF p_line_rec.ship_from_org_id is null THEN
                 l_return_status := FND_API.G_RET_STS_ERROR;
                 fnd_message.set_name('ONT', 'OE_ATTRIBUTE_REQUIRED');
                 fnd_message.set_token('ATTRIBUTE',OE_Order_UTIL.Get_Attribute_Name('SHIP_FROM_ORG_ID'));
                 OE_MSG_PUB.Add;
            ELSE
               -- validate the subinv is allowed (expense/asset)
               -- because defaulting can be defaulting an expense sub
               -- and the INV profile is set to No.
               IF l_debug_level > 0 then
               oe_debug_pub.add('Entity: p_line_rec.order_source_id:' || p_line_rec.order_source_id, 5);
               oe_debug_pub.add('Entity: profile expense_asset:' || fnd_profile.value('INV:EXPENSE_TO_ASSET_TRANSFER'), 5);
               END IF;
/* fix bug 2570174, check for restricted subinv */
               BEGIN
-- bug 4171642
                     if (OE_ORDER_CACHE.g_item_rec.organization_id <> FND_API.G_MISS_NUM
                                          AND
                      OE_ORDER_CACHE.g_item_rec.organization_id = p_line_rec.ship_from_org_id
                                          AND
                      OE_ORDER_CACHE.g_item_rec.inventory_item_id = p_line_rec.inventory_item_id)
                THEN
                        l_restrict_subinv := OE_ORDER_CACHE.g_item_rec.restrict_subinventories_code;
                 else
                       OE_ORDER_CACHE.Load_Item( p_key1 => p_line_rec.inventory_item_id ,
                             p_key2 => p_line_rec.ship_from_org_id );
                        if ( OE_ORDER_CACHE.g_item_rec.organization_id = p_line_rec.ship_from_org_id
                           and OE_ORDER_CACHE.g_item_rec.inventory_item_id = p_line_rec.inventory_item_id) THEN
                               l_restrict_subinv := OE_ORDER_CACHE.g_item_rec.restrict_subinventories_code;
                        else
                                l_restrict_subinv := 0;
                        end if ;
                  end if ;
                  /*SELECT RESTRICT_SUBINVENTORIES_CODE
                  INTO l_restrict_subinv
                  FROM MTL_SYSTEM_ITEMS
                  WHERE inventory_item_id = p_line_rec.inventory_item_id
                  AND organization_id = p_line_rec.ship_from_org_id;*/
-- bug 4171642
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                  l_restrict_subinv := 0;
               END;

               IF nvl(l_restrict_subinv, 0) = 1 THEN
                BEGIN
                   select 'Y'
                   into l_dummy
                   from MTL_ITEM_SUB_INVENTORIES_ALL_V
                   where organization_id = p_line_rec.ship_from_org_id
                   and  inventory_item_id = p_line_rec.inventory_item_id
                   and  secondary_inventory = p_line_rec.subinventory;
                EXCEPTION
                  WHEN OTHERS THEN
                  l_return_status := FND_API.G_RET_STS_ERROR;
                  fnd_message.set_name('ONT', 'OE_SUBINV_INVALID');
                  oe_msg_pub.add;
                END;
               ELSE -- not a restricted subinv case
               BEGIN
               select 'Y'
               into l_dummy
               from mtl_subinventories_trk_val_v sub
               where sub.organization_id = p_line_rec.ship_from_org_id
               and sub.secondary_inventory_name = p_line_rec.subinventory
               and (fnd_profile.value('INV:EXPENSE_TO_ASSET_TRANSFER') = 1
                    OR
                   (fnd_profile.value('INV:EXPENSE_TO_ASSET_TRANSFER') <> 1
                    and nvl(p_line_rec.order_source_id, -1) <> 10
                   )
                    OR
                   (fnd_profile.value('INV:EXPENSE_TO_ASSET_TRANSFER') <> 1
                    and nvl(p_line_rec.order_source_id, -1) = 10
                    and 'N' = (select inventory_asset_flag
                               from mtl_system_items
                               where inventory_item_id = p_line_rec.inventory_item_id
                               and organization_id = p_line_rec.ship_from_org_id)
                   )
                    OR
                   (fnd_profile.value('INV:EXPENSE_TO_ASSET_TRANSFER') <> 1
                    and nvl(p_line_rec.order_source_id, -1) = 10
                    and 'Y' = (select inventory_asset_flag
                               from mtl_system_items
                               where inventory_item_id = p_line_rec.inventory_item_id
                               and organization_id = p_line_rec.ship_from_org_id)
                    and sub.asset_inventory = 1
                   )
                   );
               EXCEPTION
                    WHEN OTHERS THEN
                         l_return_status := FND_API.G_RET_STS_ERROR;
                         fnd_message.set_name('ONT', 'OE_SUBINV_NON_ASSET');
                         oe_msg_pub.add;
               END;
              END IF; -- restrict subinv or not
            END IF;
          ELSE -- external
            l_return_status := FND_API.G_RET_STS_ERROR;
            fnd_message.set_name('ONT', 'OE_SUBINV_EXTERNAL');
            OE_MSG_PUB.Add;
          END IF;
    END IF;

    -- end subinventory
    IF l_debug_level > 0 then
    oe_debug_pub.add('Entity: done subinv validation', 1);
    END IF;

    --  If line is booked, then check for the attributes required on booked lines
    --  Fix bug 1277092: this check not required for fully cancelled lines
    IF p_line_rec.booked_flag = 'Y'
          AND p_line_rec.cancelled_flag <> 'Y' THEN
/*IF NOT OE_Sales_Can_Util.G_Require_Reason
             -- added check for cancellation request
             AND NOT OE_delayed_requests_Pvt.Check_For_Request
        (p_entity_code                          => OE_GLOBALS.G_ENTITY_ALL,
        p_entity_id                             => p_line_rec.line_id,
        p_request_type                  => OE_GLOBALS.G_CANCEL_WF) THEN
*/

       Check_Book_Reqd_Attributes( p_line_rec   => p_line_rec
                                   , p_old_line_rec => p_old_line_rec
                                   , x_return_status    => l_return_status);
--              END IF;

    END IF;

    --  Return Error if a conditionally required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    -- Bug3412008 Suppressing the validation of item_revision and
    -- l_tot_transaction_quantity for retrobill lines
   IF p_line_rec.order_source_id <>27 THEN
    --bug 3323610
    IF  p_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE AND
       (p_line_rec.item_revision is not NULL and
        p_line_rec.item_revision <> FND_API.G_MISS_CHAR) AND
       (p_line_rec.ship_from_org_id is not NULL and
        p_line_rec.ship_from_org_id <> FND_API.G_MISS_NUM) AND
       ((NOT OE_GLOBALS.Equal(p_line_rec.Item_revision,
                              p_old_line_rec.Item_revision)) OR
       (NOT OE_GLOBALS.Equal(p_line_rec.ship_from_org_id,
                              p_old_line_rec.ship_from_org_id)) OR
       (NOT OE_GLOBALS.Equal(p_line_rec.ordered_quantity,
                             p_old_line_rec.ordered_quantity)) OR
       (NOT OE_GLOBALS.Equal(p_line_rec.inventory_item_id,
                             p_old_line_rec.inventory_item_id)))
    THEN
       BEGIN
            SELECT 1
            INTO   l_dummy
            FROM   mtl_item_revisions
            WHERE  inventory_item_id=p_line_rec.inventory_item_id
            AND    organization_id=p_line_rec.ship_from_org_id
            AND    effectivity_date<=sysdate
            AND    revision= p_line_rec.item_revision;
       EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 fnd_message.set_name('ONT','ONT_REV_WH_NOT_EXIST');
                 OE_MSG_PUB.Add;
                 l_return_status :=  FND_API.G_RET_STS_ERROR;
       END;
       IF p_line_rec.reference_line_id is NOT NULL AND
          p_line_rec.reference_line_id <> FND_API.G_MISS_NUM
       THEN
          FOR r_transaction_quantity IN c_transaction_quantity
          LOOP
             -- Set the flag to mark a valid record exists in inventory for
             -- the shipped line with item revision.

             IF r_transaction_quantity.revision IS NOT NULL THEN
                 l_notnull_revision_flag := 'Y';
             END IF;

             IF r_transaction_quantity.revision = p_line_rec.item_revision THEN

                  l_tot_transaction_quantity:=l_tot_transaction_quantity +
                                     OE_Order_Misc_Util.convert_uom(
                                     p_line_rec.inventory_item_id,
                                                         r_transaction_quantity.transaction_uom,
                                     p_line_rec.order_quantity_uom,
                                                     r_transaction_quantity.transaction_quantity
                                     );
             END IF;
          END LOOP;

          -- If the item revision entered on RMA line doesn't match the one
          -- on shipped line then give a warning message.

          IF l_notnull_revision_flag = 'Y' AND
             l_tot_transaction_quantity = 0
          THEN
              fnd_message.set_name('ONT','ONT_ITEM_REV_MISMATCH');
              OE_MSG_PUB.Add;
          END IF;

          IF l_tot_transaction_quantity > 0
          THEN
              -- Check if there are other booked RMA lines with the same item
              -- revision.
              BEGIN

              select sum(ordered_quantity)
              into l_quantity_entered
              from oe_order_lines
              where reference_line_id = p_line_rec.reference_line_id
              and line_category_code = 'RETURN'
              and item_revision = p_line_rec.item_revision
              and sold_to_org_id = p_line_rec.sold_to_org_id
              and booked_flag = 'Y'
              and cancelled_flag <> 'Y'
              and line_id <> p_line_rec.line_id;

              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                 NULL;
              END;
      If l_debug_level > 0 THEN
         oe_debug_pub.add('The quantity entered is '||l_quantity_entered);
         oe_debug_pub.add('l_tot_transaction_quantity '||l_tot_transaction_quantity);
      END IF;
              IF (l_tot_transaction_quantity - NVL(l_quantity_entered,0))
                 < p_line_rec.ordered_quantity
              THEN
                  fnd_message.set_name('ONT','ONT_RMA_EXCEED_SHIP_QTY');
                  OE_MSG_PUB.Add;
                  l_return_status :=  FND_API.G_RET_STS_ERROR;
              END IF;
          END IF; -- IF l_tot_transaction_quantity > 0
       END IF; -- IF p_line_rec.reference_line_id is NOT NULL

    END IF;
    --end bug 3323610
    END IF; --bug3412008

    -- OPM 02/JUN/00 START
    -- For a dual control process item, check qty1/2 both present and sync'd
    -- =====================================================================
    IF l_debug_level > 0 THEN
        oe_debug_pub.add('Entity DUAL X-VAL start', 1);
    END IF;
    IF OE_Line_Util.dual_uom_control
                    (p_line_rec.inventory_item_id
                    ,p_line_rec.ship_from_org_id
                    ,l_item_rec)
    THEN
      --IF l_item_rec.dualum_ind in (1,2,3) THEN INVCONV
        IF l_debug_level > 0 THEN
                oe_debug_pub.add('DUAL X-VAL dualum  is true', 2);
                                END IF;

        IF (p_line_rec.ordered_quantity <> FND_API.G_MISS_NUM OR
            p_line_rec.ordered_quantity IS NOT NULL) AND
           (p_line_rec.ordered_quantity2 = FND_API.G_MISS_NUM OR
            p_line_rec.ordered_quantity2 IS NULL) THEN
                                                IF l_debug_level > 0 THEN
                                oe_debug_pub.add('dual X-VAL qty 1 not empty', 2);
                                                END IF;
            l_return_status := FND_API.G_RET_STS_ERROR;
            fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Ordered_Quantity2');
            OE_MSG_PUB.Add;

        ELSIF (p_line_rec.ordered_quantity2 <> FND_API.G_MISS_NUM OR
               p_line_rec.ordered_quantity2 IS NOT NULL) AND
              (p_old_line_rec.ordered_quantity = FND_API.G_MISS_NUM OR
               p_line_rec.ordered_quantity IS NULL) THEN

            l_return_status := FND_API.G_RET_STS_ERROR;
            fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Ordered_Quantity');
            OE_MSG_PUB.Add;
        END IF;
      -- END IF; INVCONV

      /* If qty1/qty2 both populated, check tolerances
      ================================================*/
      IF l_debug_level > 0 THEN
                oe_debug_pub.add('dual -  start tolerance check', 2);
                        END IF;

                        IF l_item_rec.secondary_default_ind in ('D','N') THEN -- INVCONV
      --IF l_item_rec.dualum_ind in (2,3) THEN
        IF (p_line_rec.ordered_quantity <> FND_API.G_MISS_NUM AND
            p_line_rec.ordered_quantity IS NOT NULL) AND
           (p_line_rec.ordered_quantity2 <> FND_API.G_MISS_NUM AND
            p_line_rec.ordered_quantity2 IS NOT NULL)
            --and (p_line_rec.order_quantity_uom  <> p_line_rec.ordered_quantity_uom2 ) -- INVCONV
            AND (p_line_rec.ordered_quantity <> p_line_rec.ordered_quantity2 ) -- INVCONV

            THEN

                                                IF l_debug_level  > 0 THEN
                                        oe_debug_pub.add('Entity - DUAL X-Val. ordered_quantity =  ' || p_line_rec.ordered_quantity ,1);
                                        oe_debug_pub.add('Entity - DUAL X-Val. ordered_quantity2 =  ' || p_line_rec.ordered_quantity2 ,1);
                        END IF;
            -- OPM BEGIN 06/22
            /* Get the OPM equivalent code for order_quantity_uom
            =====================================================      -- INVCONV
            GMI_Reservation_Util.Get_OPMUOM_from_AppsUOM
                     (p_Apps_UOM       => p_line_rec.order_quantity_uom
                     ,x_OPM_UOM        => l_OPM_UOM
                     ,x_return_status  => l_status
                     ,x_msg_count      => l_msg_count
                     ,x_msg_data       => l_msg_data);

            l_return := GMICVAL.dev_validation(l_item_rec.opm_item_id
                                  ,0
                                  ,p_line_rec.ordered_quantity
                                  ,l_OPM_UOM
                                  ,p_line_rec.ordered_quantity2
                                  ,l_item_rec.opm_item_um2
                                  ,0);
          -- OPM END 06/22       */
          l_return := INV_CONVERT.Within_Deviation  -- INVCONV
                       ( p_organization_id   => p_line_rec.ship_from_org_id
                       , p_inventory_item_id => p_line_rec.inventory_item_id
                       , p_precision         => 5
                       , p_quantity          => abs(p_line_rec.ordered_quantity) -- Added abs for bug 6485013
                       , p_uom_code1         => p_line_rec.order_quantity_uom
                       , p_quantity2         => abs(p_line_rec.ordered_quantity2) -- Added abs for bug 6485013
                       , p_uom_code2         => p_line_rec.ordered_quantity_uom2 );

           IF l_return = 0 -- (false)
                 then
            IF l_debug_level  > 0 THEN
                                        oe_debug_pub.add('Entity - dual UM with tolerance error 1.  return = '|| l_return ,1);
                                 END IF;

                         l_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST, -- INVCONV
                                         p_encoded => 'F');
           oe_msg_pub.add_text(p_message_text => l_msg_data);
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(l_msg_data,1);
                         END IF;
                         RAISE fnd_api.g_exc_error;

                else

                IF l_debug_level  > 0 THEN
                        oe_debug_pub.add('Entity - dual UM with no tolerance error ',1);
                        END IF; -- INVCONV

          --Begin Bug 2639667
          -- Code added till End Bug 2639667 comment.


            l_pick_flag := 'N';
            l_delivery_count := 0;
            l_delta_qty1 := Null;
            l_delta_qty2 := Null;

            FOR r_pick_status IN pick_status LOOP
               l_delivery_count := l_delivery_count + 1;
               l_req_qty1 := r_pick_status.SRC_REQUESTED_QUANTITY;
               l_req_qty2 := r_pick_status.SRC_REQUESTED_QUANTITY2;
               IF r_pick_status.RELEASED_STATUS IN ('Y', 'S', 'N', 'X') THEN
                    l_pick_flag := 'Y';
               END IF;
            END LOOP;


            IF (l_pick_flag = 'Y' OR l_delivery_count > 1) THEN

               l_delta_qty1 := p_line_rec.ordered_quantity - l_req_qty1;
               l_delta_qty2 := p_line_rec.ordered_quantity2 -  nvl(l_req_qty2,0);

               IF ( l_delta_qty1 > 0 AND l_delta_qty2 <= 0) OR (l_delta_qty2 > 0 AND l_delta_qty1 <= 0) THEN
                  l_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MESSAGE.set_name('GMI', 'GMI_SHIPPING_SPLIT_DEV_ERR'); -- INVCONV change this message to INV
                  OE_MSG_PUB.Add;
               END IF;

               IF  (l_delta_qty1 > 0) AND (l_delta_qty2 > 0) THEN

                  l_return := INV_CONVERT.Within_Deviation  -- INVCONV
                       ( p_organization_id   =>
                                 p_line_rec.ship_from_org_id
                       , p_inventory_item_id =>
                                 p_line_rec.inventory_item_id
                       , p_precision         => 5
                       , p_quantity          => l_delta_qty1
                       , p_uom_code1         => p_line_rec.order_quantity_uom -- INVCONV
                       , p_quantity2         => l_delta_qty2
                       , p_uom_code2         => l_item_rec.secondary_uom_code );

                 IF l_return = 0 -- (false) -- INVCONV
                                                                then
                                                                IF l_debug_level  > 0 THEN
                                                                                        oe_debug_pub.add('Entity - dual UM with tolerance error 2.  return = '|| l_return ,1);
                                                                                        END IF;

                                                                                        l_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST, -- INVCONV
                                         p_encoded => 'F');
                                                                        oe_msg_pub.add_text(p_message_text => l_msg_data);
                                                                        IF l_debug_level  > 0 THEN
                                                                        oe_debug_pub.add(l_msg_data,1);
                                                                                        END IF;
                                                                                        l_return_status := FND_API.G_RET_STS_ERROR;
                                                                                        RAISE fnd_api.g_exc_error;
                                                        END IF; --  IF l_return = 0 -- (false)


               END IF; -- IF  (l_delta_qty1 > 0) AND (l_delta_qty2 > 0) THEN
            END IF;
          --End Bug 2639667
          END IF; -- IF (l_pick_flag = 'Y' OR l_delivery_count > 1) THEN
        END IF; -- else
      END IF;
    END IF;

    --  Return Error if a required quantity validation fails
    --  ====================================================
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --  OPM 02/JUN/00 END
    --  ===================


    ---------------------------------------------------------------------
    --  Validate attribute dependencies here.
    ---------------------------------------------------------------------

    -- BEGINNING : line number validation
    -- Validate line number if item type or line number changed
    -- AND if the line is not being created by splits.

/* IF NOT l_header_created commented out nocopy for 2068070. Also replaced the following AND with IF */


    IF NOT (p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
                         p_line_rec.split_from_line_id IS NOT NULL)
       AND ( NOT OE_GLOBALS.Equal
                    (p_line_rec.item_type_code,p_old_line_rec.item_type_code)
              OR NOT OE_GLOBALS.Equal
                    (p_line_rec.line_number,p_old_line_rec.line_number) )
    THEN

        -- Line number should be unique on all standard and top level
        -- model lines on an order

        IF ( p_line_rec.item_type_code = 'STANDARD'
           --Bug 6186554
           --For Top Models, top_model_line_id and line_id are equal.
	   --OR (p_line_rec.top_model_line_id <> p_line_rec.line_id
           OR (p_line_rec.top_model_line_id = p_line_rec.line_id
	      AND p_line_rec.item_type_code = 'MODEL'))
           AND OE_ORDER_IMPORT_MAIN_PVT.G_CONTEXT_ID IS NULL   --- validate only if not Order import Condition added for bug no 5493479
        THEN

          BEGIN
           SELECT 'N'
           INTO   l_valid_line_number
           FROM   oe_order_lines L
           WHERE  L.line_number = p_line_rec.line_number
           AND    L.header_id = p_line_rec.header_id
           AND    L.line_id <> p_line_rec.line_id
           AND    ( L.item_type_code = 'STANDARD'
           OR     ( L.top_model_line_id = L.line_id
           AND      L.item_type_code = 'MODEL'));

          EXCEPTION
                WHEN no_data_found THEN
                   l_valid_line_number := 'Y';
             -- Too many rows exception would be raised if there are split
                -- lines with the same line number
                WHEN too_many_rows THEN
                   l_valid_line_number := 'N';
          END;

          IF l_valid_line_number = 'N' THEN
                FND_MESSAGE.SET_NAME('ONT','OE_LINE_NUMBER_EXISTS');
                OE_MSG_PUB.ADD;
                /* x_return_status := FND_API.G_RET_STS_ERROR; This line replaced with next for 2068070 */
                l_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

         END IF;

   END IF;
   	oe_debug_pub.add('l_valid_line_number end ***'||l_valid_line_number);
    -- END : line number validation


    -- Validate if the warehouse, item combination is valid
    IF p_line_rec.inventory_item_id is not null AND
       p_line_rec.ship_from_org_id is not null AND
       p_line_rec.inventory_item_id <> FND_API.G_MISS_NUM AND
       p_line_rec.ship_from_org_id  <> FND_API.G_MISS_NUM THEN

       IF p_line_rec.inventory_item_id <>
                                    nvl(p_old_line_rec.inventory_item_id,0) OR
          p_line_rec.ship_from_org_id <> nvl(p_old_line_rec.ship_from_org_id,0)
       THEN
          IF p_line_rec.source_type_code = OE_GLOBALS.G_SOURCE_INTERNAL
                or p_line_rec.source_type_code is null
          THEN
             IF l_debug_level > 0 then
             oe_debug_pub.add('Source Type is Internal',1);
             END IF;

            -- FOR RMAs we don't validate Item Warehouse combination

            IF NOT Validate_Item_Warehouse
                    (p_line_rec.inventory_item_id,
                     p_line_rec.ship_from_org_id,
                             l_item_type_code,
                     p_line_rec.line_id,
                     p_line_rec.top_model_line_id,
                             p_line_rec.source_document_type_id, /*Bug1741158 chhung*/
                             p_line_rec.line_category_code)/* Bug1741158 chhung */
            THEN
                l_return_status := FND_API.G_RET_STS_ERROR;
                -- Schords (R12 Project #6403)
                IF OE_SCH_CONC_REQUESTS.g_conc_program = 'Y' AND
                   (p_line_rec.top_model_line_id = p_line_rec.ato_line_id OR
                    (p_line_rec.ship_model_complete_flag = 'Y' AND
                    p_line_rec.top_model_line_id IS NOT NULL))THEN
                   IF l_debug_level  > 0 THEN
                      oe_debug_pub.add('ROLLBACK THE CHANGES   ' ,2);
                   END IF;

                   UPDATE OE_ORDER_LINES_ALL
                   SET SCHEDULE_SHIP_DATE  = p_old_line_rec.schedule_ship_date,
                       SCHEDULE_ARRIVAL_DATE = p_old_line_rec.schedule_arrival_date,
                       SHIP_FROM_ORG_ID      = p_old_line_rec.ship_from_org_id
                   WHERE top_model_line_id = p_line_rec.top_model_line_id;
                   --5166476
                   OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(p_line_rec.line_id) := 'N';
                END IF;
            END IF;

	   --bug 6647169 start
			IF (p_line_rec.ship_from_org_id <> nvl(p_old_line_rec.ship_from_org_id,0)) THEN
				IF NOT Validate_Warehouse_Change
						( p_line_rec => p_line_rec
						  ,p_old_line_rec => p_old_line_rec )
			THEN
					oe_debug_pub.add('The warehouse change is invalid as the item is not shippable in new warehoues');
					l_return_status := FND_API.G_RET_STS_ERROR;
				END IF;
			END IF;
	  --bug 6647169 end

          ELSE
             IF l_debug_level > 0 then
             oe_debug_pub.add('Source Type is External',1);
             END IF;
             -- In release 12, discrete and process warehouses can also belong to any SOB.
             -- Bug 4190927, Validate_Item_Warehouse would be used instead of Validate_Receiving_Org
             -- IF NOT Validate_Receiving_Org
             --       (p_line_rec.inventory_item_id,
             --        p_line_rec.ship_from_org_id)
             IF NOT Validate_Item_Warehouse
                   (p_inventory_item_id       => p_line_rec.inventory_item_id,
                    p_ship_from_org_id        => p_line_rec.ship_from_org_id,
                    p_item_type_code          => l_item_type_code,
                    p_line_id                 => p_line_rec.line_id,
                    p_top_model_line_id       => p_line_rec.top_model_line_id,
                    p_source_document_type_id => p_line_rec.source_document_type_id,
                    p_line_category_code      => p_line_rec.line_category_code)
             THEN
                l_return_status := FND_API.G_RET_STS_ERROR;
             END IF;

          END IF;
       END IF;
    END IF;

    -- start decimal qty validation
    IF p_line_rec.inventory_item_id is not null THEN
       IF l_debug_level > 0 then
       oe_debug_pub.add('decimal1',2);
       END IF;
       IF p_line_rec.order_quantity_uom is not null THEN

         l_line_num := RTRIM(p_line_rec.line_number      || '.' ||
                             p_line_rec.shipment_number  || '.' ||
                             p_line_rec.option_number    || '.' ||
                             p_line_rec.component_number || '.' ||
                             p_line_rec.service_number, '.');

         -- validate ordered quantity
         IF NOT OE_GLOBALS.EQUAL(p_line_rec.ordered_quantity
                                ,p_old_line_rec.ordered_quantity)
           OR NOT OE_GLOBALS.EQUAL(p_line_rec.order_quantity_uom, p_old_line_rec.order_quantity_uom) --Bug 7563563

           OR p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

           l_ordered_quantity :=p_line_rec.ordered_quantity;
   /* This local var will be passed as an IN parameter below */
  /* l_ordered_quantity is IN and p_line_rec.ordered_quantity is OUT */

            Validate_Decimal_Quantity
            (p_item_id          => p_line_rec.inventory_item_id
            ,p_item_type_code   => l_item_type_code
       --   ,p_input_quantity   => p_line_rec.ordered_quantity no copy effect
            ,p_input_quantity   => l_ordered_quantity
            ,p_uom_code            => p_line_rec.order_quantity_uom
            -- 3718547
            ,p_ato_line_id         => nvl(l_ato_line_id, p_line_rec.ato_line_id)
            ,p_line_id             => nvl(l_line_id, p_line_rec.line_id)
            ,p_line_num            => l_line_num
            ,x_output_quantity     => p_line_rec.ordered_quantity
            -- 4197444
            ,x_return_status    => l_status);

            -- 4197444
            IF l_status = FND_API.G_RET_STS_ERROR THEN
                l_return_status := l_status;
            ELSIF l_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF l_debug_level > 0 then
            oe_debug_pub.add('Ordered Qty '||p_line_rec.ordered_quantity,2);
            END IF;

         END IF;

         -- validate invoiced_quantity
         IF NOT OE_GLOBALS.EQUAL(p_line_rec.invoiced_quantity
                                ,p_old_line_rec.invoiced_quantity)
           OR p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            Validate_Decimal_Quantity
            (p_item_id          => p_line_rec.inventory_item_id
            ,p_item_type_code   => l_item_type_code
            ,p_input_quantity   => p_line_rec.invoiced_quantity
            ,p_uom_code         => p_line_rec.order_quantity_uom
            -- 3718547
            ,p_ato_line_id         => nvl(l_ato_line_id, p_line_rec.ato_line_id)
            ,p_line_id             => nvl(l_line_id, p_line_rec.line_id)
            ,p_line_num            => l_line_num
            ,x_output_quantity     => l_rounded_qty
            -- 4197444
            ,x_return_status     => l_status);

            -- 4197444
            IF l_status = FND_API.G_RET_STS_ERROR THEN
               l_return_status := l_status;
            ELSIF l_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF l_debug_level > 0 then
            oe_debug_pub.add('Invoiced Qty '||p_line_rec.invoiced_quantity,2);
            END IF;
         END IF;

         -- cancelled quantity
         -- 3840386 : Condition added to validate cancel quantity
         -- for change in ordered quantity or create operation.
         -- Also x_output_quantity is assigned back to cancelled_quantity
         IF NOT OE_GLOBALS.EQUAL(p_line_rec.ordered_quantity
                                ,p_old_line_rec.ordered_quantity)
           OR p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

           l_cancelled_quantity :=p_line_rec.cancelled_quantity;
   /* This local var will be passed as an IN parameter below */
  /* l_ordered_quantity is IN and p_line_rec.ordered_quantity is OUT */

            Validate_Decimal_Quantity
            (p_item_id          => p_line_rec.inventory_item_id
            ,p_item_type_code   => l_item_type_code
      --    ,p_input_quantity   => p_line_rec.cancelled_quantity nocopy effect
            ,p_input_quantity   => l_cancelled_quantity
            ,p_uom_code         => p_line_rec.order_quantity_uom
             -- 3718547
            ,p_ato_line_id         => nvl(l_ato_line_id, p_line_rec.ato_line_id)
            ,p_line_id             => nvl(l_line_id, p_line_rec.line_id)
            ,p_line_num            => l_line_num
            ,x_output_quantity     => p_line_rec.cancelled_quantity     --l_rounded_qty
            -- 4197444
            ,x_return_status     => l_status);

            -- 4197444
            IF l_status = FND_API.G_RET_STS_ERROR THEN
               l_return_status := l_status;
            ELSIF l_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF l_debug_level > 0 then
            oe_debug_pub.add('Cancel Qty '||p_line_rec.cancelled_quantity,2);
            END IF;
         END IF;
         -- auto_selected quantity
         IF NOT OE_GLOBALS.EQUAL(p_line_rec.auto_selected_quantity
                                ,p_old_line_rec.auto_selected_quantity)
           OR p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            Validate_Decimal_Quantity
            (p_item_id          => p_line_rec.inventory_item_id
            ,p_item_type_code   => l_item_type_code
            ,p_input_quantity   => p_line_rec.auto_selected_quantity
            ,p_uom_code         => p_line_rec.order_quantity_uom
            -- 3718547
            ,p_ato_line_id         => nvl(l_ato_line_id, p_line_rec.ato_line_id)
            ,p_line_id             => nvl(l_line_id, p_line_rec.line_id)
            ,p_line_num            => l_line_num
            ,x_output_quantity     => l_rounded_qty
            -- 4197444
            ,x_return_status    => l_status);

            -- 4197444
            IF l_status = FND_API.G_RET_STS_ERROR THEN
               l_return_status := l_status;
            ELSIF l_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

            IF l_debug_level > 0 then
            oe_debug_pub.add('Auto Selected Qty '||p_line_rec.auto_selected_quantity,2);
            END IF;
         END IF;

         -- reserved quantity
         IF NOT OE_GLOBALS.EQUAL(p_line_rec.reserved_quantity
                                ,p_old_line_rec.reserved_quantity)
           OR p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            Validate_Decimal_Quantity
            (p_item_id          => p_line_rec.inventory_item_id
            ,p_item_type_code   => l_item_type_code
            ,p_input_quantity   => p_line_rec.reserved_quantity
            ,p_uom_code         => p_line_rec.order_quantity_uom
             -- 3718547
            ,p_ato_line_id         => nvl(l_ato_line_id, p_line_rec.ato_line_id)
            ,p_line_id             => nvl(l_line_id, p_line_rec.line_id)
            ,p_line_num            => l_line_num
            ,x_output_quantity     => l_rounded_qty
            -- 4197444
            ,x_return_status     => l_status);

            -- 4197444
            IF l_status = FND_API.G_RET_STS_ERROR THEN
               l_return_status := l_status;
            ELSIF l_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF l_debug_level > 0 then
            oe_debug_pub.add('Reserved Qty '||p_line_rec.reserved_quantity,2);
            END IF;
         END IF;


         -- fulfilled quantity, double check with Shashi
         IF NOT OE_GLOBALS.EQUAL(p_line_rec.fulfilled_quantity
                                ,p_old_line_rec.fulfilled_quantity)
           OR p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
            Validate_Decimal_Quantity
            (p_item_id          => p_line_rec.inventory_item_id
            ,p_item_type_code   => l_item_type_code
            ,p_input_quantity   => p_line_rec.fulfilled_quantity
            ,p_uom_code         => p_line_rec.order_quantity_uom
            -- 3718547
            ,p_ato_line_id         => nvl(l_ato_line_id, p_line_rec.ato_line_id)
            ,p_line_id             => nvl(l_line_id, p_line_rec.line_id)
            ,p_line_num            => l_line_num
            ,x_output_quantity     => l_rounded_qty
            -- 4197444
            ,x_return_status    => l_status);

            -- 4197444
            IF l_status = FND_API.G_RET_STS_ERROR THEN
               l_return_status := l_status;
            ELSIF l_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF l_debug_level > 0 then
            oe_debug_pub.add('Fulfilled Qty '||p_line_rec.fulfilled_quantity,2);
            END IF;
         END IF;

      END IF; -- order quantity uom not null

      -- validate pricing quantity starts here
      -- bug 1391668, don't need to validate pricing quantity
      /*
      IF (p_line_rec.pricing_quantity_uom is not null AND
           p_line_rec.pricing_quantity is not null) THEN

            Validate_Decimal_Quantity
                                        (p_item_id           => p_line_rec.inventory_item_id
                                        ,p_item_type_code       => p_line_rec.item_type_code
                                        ,p_input_quantity       => p_line_rec.pricing_quantity
                                        ,p_uom_code             => p_line_rec.pricing_quantity_uom
,x_output_quantity  => l_rounded_qty
                                        ,x_return_status        => l_return_status
                                        );

       END IF; -- quantity or uom is null
       */
    END IF; -- inventory_item_id is null
    -- end decimal quantity validation

    -- Check to see if the user has changed both the Schedule Ship Date
    -- and Schedule Arrival Date. This is not allowed. The user can change
    -- either one, but not both.

/*
     IF (NOT OE_GLOBALS.Equal(p_line_rec.schedule_ship_date,
                             p_old_line_rec.schedule_ship_date)) AND
        (NOT OE_GLOBALS.Equal(p_line_rec.schedule_arrival_date,
                             p_old_line_rec.schedule_arrival_date)) AND
        (OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING = 'Y') THEN

        -- Config item is created and passed by the CTO team. So this is
        -- is the only item type, which when gets created, already has
        -- Schedule_Ship_Date and schedule_Arrival_date. We should not
        -- error out for this item.

        IF p_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_CONFIG THEN
           FND_MESSAGE.SET_NAME('ONT','OE_SCH_INVALID_CHANGE');
           OE_MSG_PUB.Add;
           l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

     END IF;
*/

    Validate_Source_Type
    ( p_line_rec      => p_line_rec
     ,p_old_line_rec  => p_old_line_rec
     ,x_return_status => l_status);

    IF l_status =  FND_API.G_RET_STS_ERROR THEN
      l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- PJM validation.

    IF PJM_UNIT_EFF.ENABLED = 'Y' THEN
     /* Added the below IF clause for bug 6243026.
     The Project / Task / End Item Unit Number validation should happen
     only when one of the below attributes change */
     IF (NOT OE_GLOBALS.Equal(p_line_rec.project_id, p_old_line_rec.project_id)) Or
        (NOT OE_GLOBALS.Equal(p_line_rec.task_id, p_old_line_rec.task_id)) Or
        (NOT OE_GLOBALS.Equal(p_line_rec.inventory_item_id, p_old_line_rec.inventory_item_id)) or
        (NOT OE_GLOBALS.Equal(p_line_rec.ship_from_org_id, p_old_line_rec.ship_from_org_id)) or
        (NOT OE_GLOBALS.Equal(p_line_rec.request_date, p_old_line_rec.request_date)) or
        (NOT OE_GLOBALS.Equal(p_line_rec.schedule_ship_date, p_old_line_rec.schedule_ship_date)) or
        (NOT OE_GLOBALS.Equal(p_line_rec.schedule_arrival_date, p_old_line_rec.schedule_arrival_date)) or
        (NOT OE_GLOBALS.Equal(p_line_rec.end_item_unit_number, p_old_line_rec.end_item_unit_number))
     THEN

        IF (p_line_rec.project_id IS NOT NULL
            AND p_line_rec.ship_from_org_id IS NULL) THEN

            l_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('ONT', 'OE_SHIP_FROM_REQD');
                  OE_MSG_PUB.add;
        ELSIF (p_line_rec.task_id IS NOT NULL AND
               p_line_rec.project_id IS NULL)  THEN

            l_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('ONT', 'OE_VAL_PROJECT_REQD');
            OE_MSG_PUB.add;
        END IF;

          -- Added Code for Enhanced Project Validation and Controls.

            l_order_date_type_code := NVL(OE_SCHEDULE_UTIL.Get_Date_Type(
                                            p_line_rec.header_id), 'SHIP');


                     IF l_order_date_type_code = 'SHIP' THEN
                        p_date := NVL(p_line_rec.schedule_ship_date,
                                            p_line_rec.request_date);
                     ELSIF l_order_date_type_code = 'ARRIVAL' THEN
                        p_date := NVL(p_line_rec.schedule_arrival_date,
                                            p_line_rec.request_date);
                     END IF;
                   IF l_debug_level > 0 then
                   OE_DEBUG_PUB.Add('Before calling Validate Proj References',1);
                   END IF;

                     result := PJM_PROJECT.VALIDATE_PROJ_REFERENCES
                       ( X_inventory_org_id => p_line_rec.ship_from_org_id
                       , X_operating_unit   => p_line_rec.org_id
                       , X_project_id       => p_line_rec.project_id
                       , X_task_id          => p_line_rec.task_id
                       , X_date1            => p_date
                       , X_date2            => NULL
                       , X_calling_function =>'OEXOEORD'
                       , X_error_code       => errcode
                       );
                   IF l_debug_level > 0 then
                   OE_DEBUG_PUB.Add('Validate Proj References Error:'||
                                                    errcode,1);
                   OE_DEBUG_PUB.Add('Validate Proj References Result:'||
                                                   result,1);
                   END IF;
                          IF result <> PJM_PROJECT.G_VALIDATE_SUCCESS  THEN
                                OE_MSG_PUB.Transfer_Msg_Stack;
                                l_msg_count:=OE_MSG_PUB.COUNT_MSG;
                                   FOR I in 1..l_msg_count loop
                                      l_msg_data := OE_MSG_PUB.Get(I,'F');
                                      IF l_debug_level > 0 then
                                      OE_DEBUG_PUB.add(l_msg_data,1);
                                      END IF;
                                   END LOOP;
                           END IF;

                IF result = PJM_PROJECT.G_VALIDATE_FAILURE  THEN
                   l_return_status := FND_API.G_RET_STS_ERROR;
                   IF l_debug_level > 0 then
                   OE_DEBUG_PUB.Add('PJM Validation API returned with Errors',1);
                   END IF;
                ELSIF result = PJM_PROJECT.G_VALIDATE_WARNING  THEN
                   IF l_debug_level > 0 then
                   OE_DEBUG_PUB.Add('PJM Validation API returned with Warnings',1);
                   END IF;
                END IF;



/*      -- Code Commented for Enhanced Project Validation and Controls.

           ELSIF ((NOT OE_GLOBALS.Equal(p_line_rec.ship_from_org_id,
                                                          p_old_line_rec.ship_from_org_id)) OR
               (NOT  OE_GLOBALS.Equal(p_line_rec.project_id,
                                                           p_old_line_rec.project_id)))
           AND    (p_line_rec.ship_from_org_id IS NOT NULL AND
                   p_line_rec.project_id IS NOT NULL) THEN

             --  Validate project/warehouse combination.
                   IF pjm_project.val_proj_idtonum
                     (p_line_rec.project_id,
                      p_line_rec.ship_from_org_id) IS NULL THEN

                 l_return_status := FND_API.G_RET_STS_ERROR;
                    FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_SHIP_FROM_PROJ');
                       OE_MSG_PUB.add;
             END IF;

        END IF;

        IF (p_line_rec.task_id IS NOT NULL
           AND p_line_rec.project_id IS NULL)  THEN

            l_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('ONT', 'OE_VAL_PROJECT_REQD');
                  OE_MSG_PUB.add;

           ELSIF (p_line_rec.task_id is NOT NULL
           AND p_line_rec.project_id IS NOT NULL) THEN

             IF NOT Validate_task(
                       p_line_rec.project_id,
                          p_line_rec.task_id) THEN

                  l_return_status := FND_API.G_RET_STS_ERROR;
                  OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TASK_ID');
                        fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                                OE_Order_Util.Get_Attribute_Name('task_id'));
                           OE_MSG_PUB.Add;
                           OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

                 END IF;

           ELSIF (p_line_rec.task_id is  NULL
           AND p_line_rec.project_id IS NOT NULL) THEN

              IF   Validate_task_reqd(
                       p_line_rec.project_id,
                          p_line_rec.ship_from_org_id) THEN

                  l_return_status := FND_API.G_RET_STS_ERROR;
                           FND_MESSAGE.SET_NAME('ONT', 'OE_VAL_TASK_REQD');
                           OE_MSG_PUB.ADD;

                 END IF;

        END IF;
*/

        -- End Item Unit number logic.
        IF l_debug_level > 0 then
        oe_debug_pub.add('10 '||l_return_status, 1);
        END IF;
        IF (p_line_rec.inventory_item_id IS NOT NULL) AND
                   (p_line_rec.ship_from_org_id IS NOT NULL) AND
                   (p_line_rec.end_item_unit_number IS NULL) THEN

              IF PJM_UNIT_EFF.UNIT_EFFECTIVE_ITEM
                        (p_line_rec.inventory_item_id,p_line_rec.ship_from_org_id) = 'Y'
                    THEN

                  l_return_status := FND_API.G_RET_STS_ERROR;
                           fnd_message.set_name('ONT', 'OE_UEFF_NUMBER_REQD');
                        OE_MSG_PUB.add;
                    END IF;

        END IF;
     END IF; -- Added for bug 6243026
    ELSE -- When project manufacturing is not enabled at the site.

        IF (NOT  OE_GLOBALS.Equal(p_line_rec.project_id,
                                           p_old_line_rec.project_id)) Or
           (NOT  OE_GLOBALS.Equal(p_line_rec.task_id,
                                           p_old_line_rec.task_id)) Or
           (NOT  OE_GLOBALS.Equal(p_line_rec.end_item_unit_number,
                                           p_old_line_rec.end_item_unit_number))
        THEN

          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT', 'OE_PJM_NOT_INSTALLED');
          OE_MSG_PUB.add;

        END IF;


    END IF; --End if PJM_UNIT_EFF.ENABLED

    -- Donot allow to update project and task when a option/class is under ATO
    -- Model.
    IF l_debug_level > 0 then
    oe_debug_pub.add('11 '||l_return_status, 1);
    END IF;
    IF p_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

           IF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
               p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
               p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG) AND
               OE_Config_Util.CASCADE_CHANGES_FLAG = 'N' AND
               p_line_rec.line_id <> p_line_rec.ato_line_id THEN

                 IF (NOT OE_GLOBALS.EQUAL(p_line_rec.project_id,
                                          p_old_line_rec.project_id)) THEN
                               l_return_status := FND_API.G_RET_STS_ERROR;
                               FND_MESSAGE.SET_NAME('ONT', 'OE_VAL_PROJ_UPD');
                            OE_MSG_PUB.add;
                  ELSIF  (NOT OE_GLOBALS.EQUAL(p_line_rec.task_id,
                                          p_old_line_rec.task_id)) THEN
                               l_return_status := FND_API.G_RET_STS_ERROR;
                               FND_MESSAGE.SET_NAME('ONT', 'OE_VAL_TASK_UPD');
                            OE_MSG_PUB.add;
                 END IF;

           END IF;

    END IF;
    -- End of PJM validation.


    -- Validate if item, item_identifier_type, inventory_item combination is valid
    IF l_debug_level > 0 then
    oe_debug_pub.add('12-1 '||l_return_status, 1);
    END IF;
    IF p_line_rec.inventory_item_id IS NOT NULL AND
       p_line_rec.inventory_item_id <> nvl(p_old_line_rec.inventory_item_id,0) OR
       NVL(p_line_rec.item_identifier_type, 'INT') <> NVL(p_old_line_rec.item_identifier_type, 'INT') OR
       p_line_rec.ordered_item_id <> nvl(p_old_line_rec.ordered_item_id, 0) OR
       p_line_rec.ordered_item <> p_old_line_rec.ordered_item OR
       p_line_rec.sold_to_org_id <> nvl(p_old_line_rec.sold_to_org_id, 0) THEN

       IF NOT Validate_Item_Fields
              (  p_line_rec.inventory_item_id
               , p_line_rec.ordered_item_id
               , p_line_rec.item_identifier_type
               , p_line_rec.ordered_item
               , p_line_rec.sold_to_org_id
               , p_line_rec.line_category_code /* Bug1678296 chhung modify */
               , p_line_rec.item_type_code /* Bug1741158- chhung adds */
               , p_line_rec.line_id        /* Bug1741158- chhung adds */
               , p_line_rec.top_model_line_id /* Bug1741158- chhung adds */
               , p_line_rec.source_document_type_id /* Bug1741158- chhung adds */
               , p_line_rec.operation /*Bug 1805985 add*/
               )
       THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT', 'OE_ITEM_VALIDATION_FAILED');
          OE_MSG_PUB.add;
       END IF;

    END IF;
    IF l_debug_level > 0 then
    oe_debug_pub.add('12 '||l_return_status, 1);
    END IF;


      --Added for Item Orderability feature
       -- Validate Item Orderability Rules
     IF  (p_line_rec.inventory_item_id IS NOT NULL
               and ( NVL(p_line_rec.item_type_code,OE_GLOBALS.G_ITEM_STANDARD) = OE_GLOBALS.G_ITEM_STANDARD
                     OR p_line_rec.item_type_code =  OE_GLOBALS.G_ITEM_MODEL )) then

            IF NOT OE_ITORD_UTIL.Validate_Item_Orderability(p_line_rec) then
		  l_return_status := FND_API.G_RET_STS_ERROR;
		  fnd_message.set_name('ONT', 'OE_ITORD_VALIDATION_FAILED');
                  fnd_message.set_token('ITEM',OE_ITORD_UTIL.get_item_name(p_line_rec.inventory_item_id));
		  fnd_message.set_token('CATEGORY',OE_ITORD_UTIL.get_item_category_name(p_line_rec.inventory_item_id));
		  OE_MSG_PUB.add;
	    END IF;
      END IF;

    IF l_debug_level > 0 then
	oe_debug_pub.add('Item Orderability Validation Result : '||l_return_status, 1);
    END IF;


    -- Validate if return item and item on referenced sales order line mismatch
    IF (p_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE and
        p_line_rec.reference_line_id is not null and
       p_line_rec.inventory_item_id IS NOT NULL and
       p_line_rec.inventory_item_id <> nvl(p_old_line_rec.inventory_item_id
                                                       ,-99))
    THEN
       IF NOT Validate_Return_Item_Mismatch
              (  p_line_rec.reference_line_id
               , p_line_rec.inventory_item_id
              )
       THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT', 'OE_RETURN_ITEM_MISMATCH_REJECT');
          OE_MSG_PUB.add;
       END IF;
    END IF;
    IF l_debug_level > 0 then
    oe_debug_pub.add('13 '||l_return_status, 1);
    END IF;

    -- Validate if returning a fulfilled sales order line
    IF (p_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE and
       p_line_rec.reference_line_id is not null and
       p_line_rec.reference_line_id <> nvl(p_old_line_rec.reference_line_id
                                                       ,-99))
     THEN
       IF NOT Validate_Return_Fulfilled_Line
              (  p_line_rec.reference_line_id
              )
       THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT', 'OE_UNFULFILLED_LINE_REJECT');
          OE_MSG_PUB.add;
       END IF;

    END IF;
    IF l_debug_level > 0 then
    oe_debug_pub.add('14 '||l_return_status, 1);
    END IF;

    -- Validate if item on the Return is Returnable
    IF (p_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE and
       p_line_rec.inventory_item_id IS NOT NULL and
       p_line_rec.inventory_item_id <> nvl(p_old_line_rec.inventory_item_id
                                                       ,-99))
    THEN
       Validate_Return_Item(p_line_rec.inventory_item_id,
                            p_line_rec.ship_from_org_id,
                            l_status);
      IF l_status <>  FND_API.G_RET_STS_SUCCESS  THEN
        IF l_debug_level > 0 then
        oe_debug_pub.add('Validate_Return_Item error '||l_status, 3);
        END IF;
        l_return_status := l_status;
      END IF;

    END IF;

    IF l_debug_level > 0 then
    oe_debug_pub.add('14_1 '||l_return_status, 1);
    END IF;

--bug 5898152
    IF p_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE and
        p_line_rec.reference_line_id is not null and
        p_line_rec.reference_line_id <> fnd_api.g_miss_num AND
        --p_line_rec.tax_code is NOT NULL  AND  commented this condition for bug 5990058
	p_line_rec.return_context = 'ORDER'
        THEN
        IF NOT Validate_Return_Reference_Tax(p_line_rec.reference_line_id,p_line_rec.tax_code) THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    -- Validate if Reference SO Line is Valid
    IF p_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE and
      p_line_rec.reference_line_id is not null and
     (p_line_rec.reference_line_id <> nvl(p_old_line_rec.reference_line_id,-99)
      OR NOT OE_GLOBALS.equal(p_line_rec.order_quantity_uom,p_old_line_rec.order_quantity_uom ))
    THEN
       IF NOT Validate_Return_Reference(p_line_rec.reference_line_id,
                                        p_line_rec.ORDER_QUANTITY_UOM)
       THEN
          -- Message is populated in the function
          l_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;
    IF l_debug_level > 0 then
    oe_debug_pub.add('14_2 '||l_return_status, 1);
    END IF;

    -- Fix Bug # 2791253: Check if SO Line is being referenced by RMA(s)
    IF p_line_rec.line_category_code = 'ORDER' AND
     (p_line_rec.ordered_quantity <> nvl(p_old_line_rec.ordered_quantity,-99))
    THEN
       IF NOT Validate_Return_Existence(p_line_rec.line_id,
                                        p_line_rec.ordered_quantity)
       THEN
          -- Message is populated in the function
          l_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;
    IF l_debug_level > 0 then
    oe_debug_pub.add('14_2_1'||l_return_status, 1);
    END IF;

    -- Validate the quantity = 1 on RMA for Serial Number reference
    IF (p_line_rec.line_category_code = OE_GLOBALS.G_RETURN_CATEGORY_CODE and
      p_line_rec.reference_line_id is not null and
      p_line_rec.return_context = 'SERIAL' and
      p_line_rec.cancelled_flag <> 'Y' and
      NVL(p_line_rec.ordered_quantity,1) <> 1)
    THEN
       l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT','OE_SERIAL_REFERENCED_RMA');
       OE_MSG_PUB.Add;
    END IF;

    IF l_debug_level > 0 then
    oe_debug_pub.add('14_3 '||l_return_status, 1);
    END IF;

        -- Validation of Ship To Org Id.
        IF p_line_rec.ship_to_org_id IS NOT NULL
    AND NOT (l_header_created AND OE_GLOBALS.EQUAL
        (OE_Order_Cache.g_header_rec.ship_to_org_id,p_line_rec.ship_to_org_id))
    AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.ship_to_org_id
                                                        ,p_old_line_rec.ship_to_org_id)
          OR NOT OE_GLOBALS.EQUAL(p_line_rec.sold_to_org_id
                                                        ,p_old_line_rec.sold_to_org_id))
        THEN

                IF      NOT Validate_Ship_To_Org(p_line_rec.ship_to_org_id,
                                                                         p_line_rec.sold_to_org_id
                                                                                 )
        THEN
           IF G_REF_RMA = 'Y' THEN
               p_line_rec.ship_to_org_id := NULL;
               l_old_line_rec.ship_to_org_id := NULL;
               if l_debug_level > 0 then
                   OE_DEBUG_PUB.Add('Setting ship_to_org_id to NULL',1);
               end if;
           ELSE

               l_return_status := FND_API.G_RET_STS_ERROR;
                       fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                           OE_Order_Util.Get_Attribute_Name('ship_to_org_id'));
                           OE_MSG_PUB.Add;
           END IF;
                END IF;

        END IF;


     --    Ship to contact depends on Ship To Org
        IF p_line_rec.ship_to_contact_id IS NOT NULL
     AND NOT (l_header_created
     AND OE_GLOBALS.EQUAL(OE_Order_Cache.g_header_rec.ship_to_contact_id, p_line_rec.ship_to_contact_id)
     AND OE_GLOBALS.EQUAL(OE_Order_Cache.g_header_rec.ship_to_org_id,p_line_rec.ship_to_org_id))
     AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.ship_to_contact_id,p_old_line_rec.ship_to_contact_id)
     OR NOT OE_GLOBALS.EQUAL(p_line_rec.ship_to_org_id,p_old_line_rec.ship_to_org_id))
 --Bug 5679739 AND OE_GLOBALS.EQUAL(OE_Order_Cache.g_header_rec.ship_to_org_id,p_line_rec.ship_to_org_id)
        THEN

        BEGIN
          IF l_debug_level > 0 then
          oe_debug_pub.add('ship_to_contact_id :'||to_char(p_line_rec.ship_to_contact_id),2);
          END IF;

        SELECT  /* MOAC_SQL_CHANGE */ 'VALID'
        INTO    l_dummy
        FROM
             HZ_CUST_ACCOUNT_ROLES ACCT_ROLE,
             HZ_CUST_SITE_USES_ALL   SITE_USE,    --changed SHIP to SITE_USE for bug 3739650
             HZ_CUST_ACCT_SITES  ADDR
        WHERE
             ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_line_rec.ship_to_contact_id
             AND  ACCT_ROLE.CUST_ACCOUNT_ID = ADDR.CUST_ACCOUNT_ID
             AND  ACCT_ROLE.ROLE_TYPE = 'CONTACT'
             AND  ADDR.CUST_ACCT_SITE_ID = SITE_USE.CUST_ACCT_SITE_ID
             AND  SITE_USE.SITE_USE_ID = p_line_rec.ship_to_org_id
             AND  SITE_USE.STATUS = 'A'
             AND  ADDR.STATUS ='A' --bug 2752321
             AND  ACCT_ROLE.STATUS = 'A'
             AND  ROWNUM = 1;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
           IF G_REF_RMA = 'Y' THEN
              p_line_rec.ship_to_contact_id := NULL;
              l_old_line_rec.ship_to_contact_id := NULL;
              if l_debug_level > 0 then
                  OE_DEBUG_PUB.Add('Setting ship_to_contact_id to NULL',1);
              end if;
           ELSE
              l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                OE_Order_Util.Get_Attribute_Name('ship_to_contact_id'));
              OE_MSG_PUB.Add;
           END IF;
                WHEN OTHERS THEN
            IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              OE_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME ,
                'Record - Ship To Contact validation '
              );
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

     END IF;


        -- Validation of Deliver To Org Id.
        IF  p_line_rec.deliver_to_org_id IS NOT NULL
    AND NOT (l_header_created AND OE_GLOBALS.EQUAL
        (OE_Order_Cache.g_header_rec.deliver_to_org_id,
         p_line_rec.deliver_to_org_id))
        AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.deliver_to_org_id
                                                        ,p_old_line_rec.deliver_to_org_id)
              OR NOT OE_GLOBALS.EQUAL(p_line_rec.sold_to_org_id
                                                        ,p_old_line_rec.sold_to_org_id))
        THEN

                IF      NOT Validate_Deliver_To_Org(p_line_rec.deliver_to_org_id,
                                                                         p_line_rec.sold_to_org_id
                                                                                 ) THEN
           IF G_REF_RMA = 'Y' THEN
               p_line_rec.deliver_to_org_id := NULL;
               l_old_line_rec.deliver_to_org_id := NULL;
               if l_debug_level > 0 then
                   OE_DEBUG_PUB.Add('Setting deliver_to_org_id to NULL',1);
               end if;
           ELSE
               l_return_status := FND_API.G_RET_STS_ERROR;
                       fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
               OE_Order_Util.Get_Attribute_Name('deliver_to_org_id'));
               OE_MSG_PUB.Add;
           END IF;
                END IF;

        END IF;

     --    Deliver to contact depends on Deliver To Org
        IF p_line_rec.deliver_to_contact_id IS NOT NULL
    AND NOT (l_header_created AND OE_GLOBALS.EQUAL
        (OE_Order_Cache.g_header_rec.deliver_to_org_id,
         p_line_rec.deliver_to_org_id) AND OE_GLOBALS.EQUAL
        (OE_Order_Cache.g_header_rec.deliver_to_contact_id,
         p_line_rec.deliver_to_contact_id))
          AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.deliver_to_contact_id
                                                        ,p_old_line_rec.deliver_to_contact_id)
              OR NOT OE_GLOBALS.EQUAL(p_line_rec.deliver_to_org_id
                                                        ,p_old_line_rec.deliver_to_org_id))
        THEN

        BEGIN
         IF l_debug_level > 0 then
         oe_debug_pub.add('deliver_to_contact_id :'||to_char(p_line_rec.deliver_to_contact_id),2);
         END IF;

        SELECT /* MOAC_SQL_CHANGE */ 'VALID'
        INTO    l_dummy
        FROM
             HZ_CUST_ACCOUNT_ROLES ACCT_ROLE,
             HZ_CUST_SITE_USES_ALL   SITE_USE,       --changed INV to SITE_USE for bug 3739650
             HZ_CUST_ACCT_SITES  ADDR
        WHERE
             ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_line_rec.deliver_to_contact_id
             AND  ACCT_ROLE.CUST_ACCOUNT_ID = ADDR.CUST_ACCOUNT_ID
             AND  ACCT_ROLE.ROLE_TYPE = 'CONTACT'
             AND  ADDR.CUST_ACCT_SITE_ID = SITE_USE.CUST_ACCT_SITE_ID
             AND  SITE_USE.SITE_USE_ID = p_line_rec.deliver_to_org_id
             AND  SITE_USE.STATUS = 'A'
             AND  ADDR.STATUS ='A' --bug 2752321
             AND  ACCT_ROLE.STATUS = 'A'
             AND  ROWNUM = 1;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
           IF G_REF_RMA = 'Y' THEN
              p_line_rec.deliver_to_contact_id := NULL;
              l_old_line_rec.deliver_to_contact_id := NULL;
              if l_debug_level > 0 then
                  OE_DEBUG_PUB.Add('Setting deliver_to_contact_id to NULL',1);
              end if;
           ELSE
              l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                OE_Order_Util.Get_Attribute_Name('deliver_to_contact_id'));
              OE_MSG_PUB.Add;
           END IF;
                WHEN OTHERS THEN
            IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              OE_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME ,
                'Record - Deliver To Contact validation '
              );
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

     END IF;

        -- Validation of Invoice To Org Id.
        IF p_line_rec.invoice_to_org_id IS NOT NULL
    AND NOT (l_header_created AND OE_GLOBALS.EQUAL
        (OE_Order_Cache.g_header_rec.invoice_to_org_id,
         p_line_rec.invoice_to_org_id))
          AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.invoice_to_org_id
                                                        ,p_old_line_rec.invoice_to_org_id)
              OR NOT OE_GLOBALS.EQUAL(p_line_rec.sold_to_org_id
                                                        ,p_old_line_rec.sold_to_org_id))
        THEN

        BEGIN
            IF l_debug_level > 0 then
            oe_debug_pub.add('invoice_to_org_id :'||to_char(p_line_rec.invoice_to_org_id),2);
            END IF;
  --lcustomer_relations := FND_PROFILE.VALUE('ONT_CUSTOMER_RELATIONSHIPS');

    IF nvl(lcustomer_relations,'N') = 'N' THEN

            Select 'VALID'
            Into   l_dummy
            From   oe_invoice_to_orgs_v
            Where  customer_id = p_line_rec.sold_to_org_id
            And    site_use_id = p_line_rec.invoice_to_org_id
            and    status='A'
            and   address_status ='A';--bug 2752321

    ELSIF lcustomer_relations = 'Y' THEN
        IF l_debug_level > 0 then
        oe_debug_pub.add('Cr: Yes Line Inv',2);
        END IF;
--variable added for bug 3739650
    l_site_use_code := 'BILL_TO' ;
    SELECT /* MOAC_SQL_CHANGE */ 'VALID'
    Into   l_dummy
    FROM   HZ_CUST_SITE_USES_ALL SITE,
           HZ_CUST_ACCT_SITES ACCT_SITE
    WHERE SITE.SITE_USE_ID     = p_line_rec.invoice_to_org_id
    AND SITE.SITE_USE_CODE     = l_site_use_code
    AND SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
    AND SITE.STATUS = 'A'
       AND ACCT_SITE.STATUS ='A' AND --bug 2752321
    ACCT_SITE.CUST_ACCOUNT_ID in (
                    SELECT p_line_rec.sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE_ALL h WHERE
                    RELATED_CUST_ACCOUNT_ID = p_line_rec.sold_to_org_id
                    and h.org_id=acct_site.org_id
                        and bill_to_flag = 'Y' and status='A')
    --bug 4205113
    AND EXISTS(SELECT 1 FROM HZ_CUST_ACCOUNTS WHERE CUST_ACCOUNT_ID = ACCT_SITE.CUST_ACCOUNT_ID AND STATUS='A')
    AND ROWNUM = 1;
    END IF;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
           IF G_REF_RMA = 'Y' THEN
              G_REDEFAULT_MISSING := 'Y';
              -- Check if l_old_line_rec has already got populated
              IF l_old_line_rec.invoice_to_org_id IS NULL THEN
                  l_old_line_rec := p_line_rec;
                  if l_debug_level > 0 then
                     OE_DEBUG_PUB.Add('Setting l_old_line_rec',1);
                  end if;
              END IF;
              -- set invoice_to_org_id to G_MISS_NUM so that it gets
              -- re-defaulted.
              p_line_rec.invoice_to_org_id := FND_API.G_MISS_NUM;
              p_line_rec.invoice_to_contact_id := FND_API.G_MISS_NUM;
              if l_debug_level > 0 then
                  OE_DEBUG_PUB.Add('Setting invoice_to_org_id to MISSING',1);
              end if;
           ELSE
              l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_Util.Get_Attribute_Name('invoice_to_org_id'));
              OE_MSG_PUB.Add;
           END IF;
                WHEN OTHERS THEN
            IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              OE_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME ,
                'Record - Invoice To Org validation '
              );
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

     END IF;

        -- Validation of Invoice To Contact Id.
        IF  p_line_rec.invoice_to_contact_id IS NOT NULL
    AND p_line_rec.invoice_to_contact_id <> FND_API.G_MISS_NUM
    AND NOT (l_header_created AND OE_GLOBALS.EQUAL
        (OE_Order_Cache.g_header_rec.invoice_to_contact_id,
         p_line_rec.invoice_to_contact_id))
        AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.invoice_to_contact_id
                                                        ,p_old_line_rec.invoice_to_contact_id)
              OR NOT OE_GLOBALS.EQUAL(p_line_rec.invoice_to_org_id
                                                        ,p_old_line_rec.invoice_to_org_id))
        THEN

        BEGIN
         IF l_debug_level > 0 then
         oe_debug_pub.add('invoice_to_contact_id :'||to_char(p_line_rec.invoice_to_contact_id),2);
         END IF;

          SELECT  'VALID'
          INTO    l_dummy
          FROM
             HZ_CUST_ACCOUNT_ROLES ACCT_ROLE,
             HZ_CUST_SITE_USES_ALL   SITE_USE,                --changed INV to SITE_USE for bug 3739650
             HZ_CUST_ACCT_SITES_ALL  ADDR
          WHERE
             ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_line_rec.invoice_to_contact_id
             AND  ACCT_ROLE.CUST_ACCOUNT_ID = ADDR.CUST_ACCOUNT_ID
             AND  ACCT_ROLE.ROLE_TYPE = 'CONTACT'
             AND  ADDR.CUST_ACCT_SITE_ID = SITE_USE.CUST_ACCT_SITE_ID
             AND  SITE_USE.SITE_USE_ID = p_line_rec.invoice_to_org_id
             AND  SITE_USE.STATUS = 'A'
             AND  ADDR.STATUS ='A' --bug 2752321
             AND  ACCT_ROLE.STATUS = 'A'
             AND  ROWNUM = 1;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
           IF G_REF_RMA = 'Y' THEN
              p_line_rec.invoice_to_contact_id := NULL;
              l_old_line_rec.invoice_to_contact_id := NULL;
              if l_debug_level > 0 then
                  OE_DEBUG_PUB.Add('Setting invoice_to_contact_id to NULL',1);
              end if;
           ELSE
              l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                OE_Order_Util.Get_Attribute_Name('invoice_to_contact_id'));
              OE_MSG_PUB.Add;
           END IF;
                WHEN OTHERS THEN
            IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              OE_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME ,
                'Record - Invoice To Contact validation '
              );
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

     END IF;


   /* Added by Manish */

    -- Validating Tax Information
    IF p_line_rec.tax_code IS NOT NULL AND
       p_line_rec.tax_date IS NOT NULL
          AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.tax_code
                                                        ,p_old_line_rec.tax_code)
              OR NOT OE_GLOBALS.EQUAL(p_line_rec.tax_date
                                                        ,p_old_line_rec.tax_date))
    THEN
           BEGIN
-- EBTax Changes
/*            IF oe_code_control.code_release_level < '110510' THEN
               SELECT 'VALID'
               INTO   l_dummy
               FROM   AR_VAT_TAX V,
                      AR_SYSTEM_PARAMETERS P
               WHERE  V.TAX_CODE = p_line_rec.tax_code
               AND V.SET_OF_BOOKS_ID = P.SET_OF_BOOKS_ID
               AND NVL(V.ENABLED_FLAG,'Y')='Y'
               AND NVL(V.TAX_CLASS,'O')='O'
               AND NVL(V.DISPLAYED_FLAG,'Y')='Y'
               AND TRUNC(p_line_rec.tax_date) BETWEEN TRUNC(V.START_DATE) AND
                   TRUNC(NVL(V.END_DATE, p_line_rec.tax_date))
               AND ROWNUM = 1;
            Else
               l_AR_Sys_Param_Rec := OE_Sys_Parameters_Pvt.Get_AR_Sys_Params;
               l_sob_id := l_AR_Sys_Param_Rec.set_of_books_id;

               SELECT 'VALID'
               INTO   l_dummy
               FROM   AR_VAT_TAX V
               WHERE  V.TAX_CODE = p_line_rec.tax_code
               AND V.SET_OF_BOOKS_ID = l_sob_id
               AND NVL(V.ENABLED_FLAG,'Y')='Y'
               AND NVL(V.TAX_CLASS,'O')='O'
               AND NVL(V.DISPLAYED_FLAG,'Y')='Y'
               AND TRUNC(p_line_rec.tax_date) BETWEEN TRUNC(V.START_DATE) AND
                   TRUNC(NVL(V.END_DATE, p_line_rec.tax_date))
               AND ROWNUM = 1;
            End if;
*/
              SELECT 'VALID'
                INTO l_dummy
                FROM ZX_OUTPUT_CLASSIFICATIONS_V
               WHERE LOOKUP_CODE = p_line_rec.tax_code
                -- AND LOOKUP_TYPE = 'ZX_OUTPUT_CLASSIFICATIONS'
                 AND ENABLED_FLAG ='Y'
                 AND ORG_ID in (p_line_rec.org_id, -99)
                 AND TRUNC(p_line_rec.tax_date) BETWEEN
                        TRUNC(START_DATE_ACTIVE) AND
                        TRUNC(NVL(END_DATE_ACTIVE, p_line_rec.tax_date))
                 AND ROWNUM = 1;

        EXCEPTION

                WHEN NO_DATA_FOUND THEN
                    l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_Util.Get_Attribute_Name('TAX_CODE'));
              OE_MSG_PUB.Add;

                WHEN OTHERS THEN
                    IF OE_MSG_PUB.Check_Msg_Level (
                        OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                    THEN
                        OE_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME ,
                                'Record - Tax Code validation '
                        );
                    END IF;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END; -- BEGIN
    END IF;



   --bug6441512
   IF p_line_rec.tax_exempt_flag = 'S'  AND
          (p_line_rec.tax_exempt_number IS NOT NULL OR
           p_line_rec.tax_exempt_reason_code IS NOT NULL)
    THEN
           l_return_status := FND_API.G_RET_STS_ERROR;
           IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
                  fnd_message.set_name('ONT','OE_NO_TAX_EXEMPTION');
            OE_MSG_PUB.Add;
           END IF;

    END IF; -- If Tax handling is Standard


     --bug6441512
   IF p_line_rec.tax_exempt_flag = 'E'
    THEN
           -- Check for Tax exempt reason

	 --bug6732513
	 /* IF p_line_rec.tax_exempt_number IS NULL
           THEN
               l_return_status := FND_API.G_RET_STS_ERROR;
               IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                fnd_message.set_name('ONT','OE_TAX_EXEMPTION_REQUIRED');
                OE_MSG_PUB.Add;
               END IF;
        END IF;*/


	IF p_line_rec.tax_exempt_reason_code IS NULL
           THEN
               l_return_status := FND_API.G_RET_STS_ERROR;
               IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
                   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_Util.Get_Attribute_Name('TAX_EXEMPT_REASON_CODE'));
                   OE_MSG_PUB.Add;
               END IF;
        END IF;
    END IF; -- If Tax handling is exempt


 --bug6441512
  IF p_line_rec.tax_exempt_flag =  'R' AND
          (p_line_rec.tax_exempt_number IS NOT NULL OR
           p_line_rec.tax_exempt_reason_code IS NOT NULL)
    THEN
           l_return_status := FND_API.G_RET_STS_ERROR;
           IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
                  fnd_message.set_name('ONT','OE_TAX_EXEMPTION_NOT_ALLOWED');
            OE_MSG_PUB.Add;
           END IF;

    END IF; -- If Tax handling is Required


    -- Removing the following Tax Exemption Number Validation for bug 6441512

    --  Check for Tax Exempt number/ Tax Exempt reason code depends on
    --    following attributes if the Tax_exempt_flag = 'S' (Standard)

  /*  IF p_line_rec.tax_exempt_flag IS NOT NULL
     AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.tax_exempt_number
                                                        ,p_old_line_rec.tax_exempt_number)
              OR NOT OE_GLOBALS.EQUAL(p_line_rec.tax_exempt_reason_code
                                                        ,p_old_line_rec.tax_exempt_reason_code)
              OR NOT OE_GLOBALS.EQUAL(p_line_rec.tax_date
                                                        ,p_old_line_rec.tax_date)
              OR NOT OE_GLOBALS.EQUAL(p_line_rec.ship_to_org_id
                                                        ,p_old_line_rec.ship_to_org_id)
              OR NOT OE_GLOBALS.EQUAL(p_line_rec.invoice_to_org_id
                                                        ,p_old_line_rec.invoice_to_org_id)
              OR NOT OE_GLOBALS.EQUAL(p_line_rec.sold_to_org_id
                                                        ,p_old_line_rec.sold_to_org_id)
                )
    THEN

           BEGIN

                  oe_debug_pub.Add('Tax Exempt Flag is :'|| p_line_rec.tax_exempt_flag, 1);
                  --bug 6118092
                  IF ( p_line_rec.tax_exempt_flag = 'S' OR p_line_rec.tax_exempt_flag = 'E' ) and
                        p_line_rec.tax_exempt_number IS NOT NULL and
                        p_line_rec.tax_exempt_reason_code IS NOT NULL and
                        p_line_rec.tax_code IS NOT NULL
                  THEN
                   -- EBTax Changes

                       open partyinfo(p_line_rec.invoice_to_org_id);
                       fetch partyinfo into l_bill_to_cust_Acct_id,
                                            l_bill_to_party_id,
                                            l_bill_to_party_site_id,
                                            l_org_id;
                       close partyinfo;

                       if p_line_rec.ship_to_org_id = p_line_rec.invoice_to_org_id then
                          l_ship_to_cust_Acct_id    :=  l_bill_to_cust_Acct_id;
                          l_ship_to_party_id        :=  l_bill_to_party_id;
                          l_ship_to_party_site_id   :=  l_bill_to_party_site_id ;
                       else
                          open partyinfo(p_line_rec.ship_to_org_id);
                          fetch partyinfo into l_ship_to_cust_Acct_id,
                                               l_ship_to_party_id,
                                               l_ship_to_party_site_id,
                                               l_org_id;
                          close partyinfo;
                       end if;

                     -- Modified below code to validate Tax Exempt Number based on Tax Handling for Bug 6378168
                     IF ( p_line_rec.tax_exempt_flag = 'S' ) THEN
                       SELECT 'VALID'
                        INTO l_dummy
                        FROM ZX_EXEMPTIONS_V
                       WHERE EXEMPT_CERTIFICATE_NUMBER = p_line_rec.tax_exempt_number
                         AND EXEMPT_REASON_CODE = p_line_rec.tax_exempt_reason_code
                         AND nvl(site_use_id,nvl(p_line_rec.ship_to_org_id,
                                               p_line_rec.invoice_to_org_id))
                             =  nvl(p_line_rec.ship_to_org_id,
                                               p_line_rec.invoice_to_org_id)
                         AND nvl(cust_account_id, l_bill_to_cust_acct_id) = l_bill_to_cust_acct_id
                         AND nvl(PARTY_SITE_ID,nvl(l_ship_to_party_site_id, l_bill_to_party_site_id))=
                                           nvl(l_ship_to_party_site_id, l_bill_to_party_site_id)
--*                      AND TAX_CODE = p_line_rec.tax_code
                         AND  org_id = l_org_id
                         AND  party_id = l_bill_to_party_id
--                       AND nvl(LEGAL_ENTITY_ID,-99) IN (nvl(l_legal_entity_id, legal_entity_id), -99)
                         AND EXEMPTION_STATUS_CODE = 'PRIMARY'
                         AND TRUNC(NVL(p_line_rec.request_date,sysdate))
                               BETWEEN TRUNC(EFFECTIVE_FROM)
                                       AND TRUNC(NVL(EFFECTIVE_TO,NVL(p_line_rec.request_date,sysdate)))
                         AND ROWNUM = 1;
                      ELSIF ( p_line_rec.tax_exempt_flag = 'E' ) THEN
                       SELECT 'VALID'
                        INTO l_dummy
                        FROM ZX_EXEMPTIONS_V
                       WHERE EXEMPT_CERTIFICATE_NUMBER = p_line_rec.tax_exempt_number
                         AND EXEMPT_REASON_CODE = p_line_rec.tax_exempt_reason_code
                         AND nvl(site_use_id,nvl(p_line_rec.ship_to_org_id,
                                               p_line_rec.invoice_to_org_id))
                             =  nvl(p_line_rec.ship_to_org_id,
                                               p_line_rec.invoice_to_org_id)
                         AND nvl(cust_account_id, l_bill_to_cust_acct_id) = l_bill_to_cust_acct_id
                         AND nvl(PARTY_SITE_ID,nvl(l_ship_to_party_site_id, l_bill_to_party_site_id))=
                                           nvl(l_ship_to_party_site_id, l_bill_to_party_site_id)
--*                      AND TAX_CODE = p_line_rec.tax_code
                         AND  org_id = l_org_id
                         AND  party_id = l_bill_to_party_id
--                       AND nvl(LEGAL_ENTITY_ID,-99) IN (nvl(l_legal_entity_id, legal_entity_id), -99)
                         AND EXEMPTION_STATUS_CODE IN ( 'PRIMARY', 'MANUAL', 'UNAPPROVED' )
                         AND TRUNC(NVL(p_line_rec.request_date,sysdate))
                               BETWEEN TRUNC(EFFECTIVE_FROM)
                                       AND TRUNC(NVL(EFFECTIVE_TO,NVL(p_line_rec.request_date,sysdate)))
                         AND ROWNUM = 1;
                      END IF;
                  -- end eBTax changes
            END IF;

               oe_debug_pub.Add(' Valid Tax Exempt Number',1);

          EXCEPTION

             WHEN NO_DATA_FOUND THEN
                    -- Bug 6118092 Redefault as it may be no more valid
                   IF p_line_rec.line_category_code = 'RETURN' THEN
                      null;
                    ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
                          p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE   THEN
                          p_line_rec.tax_exempt_number := FND_API.G_MISS_CHAR;
                          p_line_rec.tax_exempt_reason_code := FND_API.G_MISS_CHAR;
                          p_line_rec.tax_exempt_flag :=FND_API.G_MISS_CHAR;
                          G_REDEFAULT_MISSING := 'Y';

                          oe_debug_pub.Add('Redefault the tax_exempt_number',1);

                   ELSE

                        l_return_status := FND_API.G_RET_STS_ERROR;

                       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                       THEN
                         fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                         OE_Order_Util.Get_Attribute_Name('TAX_EXEMPT_NUMBER'));
                         OE_MSG_PUB.Add;
                         END IF;
                  END IF;

                WHEN OTHERS THEN
                    IF OE_MSG_PUB.Check_Msg_Level (
                        OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                    THEN
                        OE_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME ,
                                'Record - Tax Exemptions '
                        );
                    END IF;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END; -- BEGIN

    END IF; -- Tax exempton info validation.

 */

 /* Added by Manish */

   -- order_quantity_uom should be primary uom for model/class/option.
     IF  p_line_rec.order_quantity_uom is not null
        AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.inventory_item_id,p_old_line_rec.inventory_item_id)
        OR   NOT OE_GLOBALS.EQUAL(p_line_rec.order_quantity_uom,p_old_line_rec.order_quantity_uom)
        OR   NOT OE_GLOBALS.EQUAL(p_line_rec.ship_from_org_id,p_old_line_rec.ship_from_org_id))
     THEN

     IF ( p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
        p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
        p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
        p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT OR
        p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_INCLUDED OR
        p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG)
     THEN
      BEGIN
  /*        -- bug 4171642  commented following for bug 8704697,8894555
         IF ((OE_ORDER_CACHE.g_item_rec.organization_id <> FND_API.G_MISS_NUM)
                                 AND
         (nvl(p_line_rec.ship_from_org_id,g_master_org_id) = OE_ORDER_CACHE.g_item_rec.organization_id)
                                 AND
          OE_ORDER_CACHE.g_item_rec.inventory_item_id = p_line_rec.inventory_item_id ) THEN
                l_uom := OE_ORDER_CACHE.g_item_rec.primary_uom_code ;
         ELSE
              OE_ORDER_CACHE.Load_Item( p_key1 => p_line_rec.inventory_item_id ,                             p_key2 => p_line_rec.ship_from_org_id );
                l_uom := OE_ORDER_CACHE.g_item_rec.primary_uom_code ;
          END IF ;
end of bug 8894555,8704697 */
         /*SELECT primary_uom_code
         INTO   l_uom
         FROM   mtl_system_items_b
         WHERE  inventory_item_id = p_line_rec.inventory_item_id
         AND    organization_id   = nvl(p_line_rec.ship_from_org_id,
                                    OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID'));
*/
 -- end bug 4171642
        ---Start bug 8894555 Primary uom should be validated against the Master org for model items
         ---UOM will be picked from cache if ship_from and master org are same else get from DB
       IF ( (OE_ORDER_CACHE.g_item_rec.organization_id <> FND_API.G_MISS_NUM)
		                 AND
                (g_master_org_id = OE_ORDER_CACHE.g_item_rec.organization_id)
				 AND
	         OE_ORDER_CACHE.g_item_rec.inventory_item_id = p_line_rec.inventory_item_id ) THEN


            	l_uom := OE_ORDER_CACHE.g_item_rec.primary_uom_code ;
               if l_debug_level > 0 then
                  oe_debug_pub.add('Primary uom from item cache : '||l_uom);
             end if;

      ELSE

         SELECT primary_uom_code
         INTO   l_uom
         FROM   mtl_system_items
         WHERE  inventory_item_id = p_line_rec.inventory_item_id
         AND    organization_id   =  g_master_org_id ;

         if l_debug_level > 0 then
                  oe_debug_pub.add('Primary uom from master org:'||g_master_org_id||'is'|| l_uom);

             end if;

       END IF ;
     ---End bug 8894555

         IF l_debug_level > 0 then
         oe_debug_pub.add('primary uom: '|| l_uom, 1);
         oe_debug_pub.add('uom entered: '||p_line_rec.order_quantity_uom , 1);
         END IF;

         IF l_uom <> p_line_rec.order_quantity_uom
         THEN
            IF l_debug_level > 0 then
            oe_debug_pub.add('uom other than primary uom is entered', 1);
            END IF;

            fnd_message.set_name('ONT','OE_INVALID_ORDER_QUANTITY_UOM');
            fnd_message.set_token('ITEM',nvl(p_line_rec.ordered_item,p_line_rec.inventory_item_id));
            fnd_message.set_token('UOM', l_uom);
            OE_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      EXCEPTION
         when no_data_found then
            IF l_debug_level > 0 then
            oe_debug_pub.add('OEXLLINB, no_data_found in uom validation', 1);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
      END;

     ELSE -- not ato related, validate item, uom combination
           /*1544265*/
        /*SELECT count(*)
        INTO l_uom_count
        FROM mtl_item_uoms_view
        WHERE inventory_item_id = p_line_rec.inventory_item_id
        AND uom_code = p_line_rec.order_quantity_uom
           AND organization_id = nvl(p_line_rec.ship_from_org_id,
                                 OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID'));


        IF l_uom_count = 0 THEN
            IF l_debug_level > 0 then
            oe_debug_pub.add('uom/item combination invalid',2);
            END IF;
            fnd_message.set_name('ONT', 'OE_INVALID_ITEM_UOM');
            OE_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

*/
           l_ret_status := inv_convert.validate_item_uom(p_line_rec.order_quantity_uom,p_line_rec.inventory_item_id,nvl(p_line_rec.ship_from_org_id,OE_Sys_Parameters.VALUE_WNPS('MASTER_ORGANIZATION_ID')));
        IF NOT l_ret_status THEN
            IF l_debug_level > 0 then
            oe_debug_pub.add('uom/item combination invalid',2);
            END IF;
            fnd_message.set_name('ONT', 'OE_INVALID_ITEM_UOM');
            OE_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
           /*1544265*/
     END IF;
   END IF;

    If p_line_rec.agreement_id is not null and
          NOT OE_GLOBALS.EQUAL(p_line_rec.agreement_id, fnd_api.g_miss_num) then
         If not oe_globals.equal(p_line_rec.agreement_id,p_old_line_rec.agreement_id) then

        -- Check for Agreement +sold_org_id

        -- Where cluase added to check start and end date for agreements
        -- Geresh

                BEGIN
                  BEGIN
              select list_type_code
                    into l_list_type_code
                    from qp_list_headers_vl
                    where list_header_id = p_line_rec.price_list_id;
                  EXCEPTION WHEN NO_DATA_FOUND THEN
                    null;
            END;

          BEGIN
                        SELECT name ,sold_to_org_id , price_list_id
                        INTO   l_agreement_name,l_sold_to_org,l_price_list_id
                        FROM   oe_agreements_v
                        WHERE  agreement_id = p_line_rec.agreement_id
                        AND    trunc(nvl(p_line_rec.pricing_date,sysdate)) between
                                  trunc(nvl(START_DATE_ACTIVE,add_months(sysdate,-10000)))
               AND    trunc(nvl(END_DATE_ACTIVE,add_months(sysdate,+10000)));
                  EXCEPTION WHEN NO_DATA_FOUND THEN
                    null;
            END;

--for bug 2345712   begin
  if p_line_rec.price_list_id is not null and
     p_line_rec.price_list_id <> FND_API.G_MISS_NUM
  then
          IF NOT OE_GLOBALS.EQUAL(l_list_type_code,'PRL') THEN
                -- any price list with 'PRL' type should be allowed to
                -- be associated with any agreement according to bug 1386406.
                        IF NOT OE_GLOBALS.EQUAL(l_price_list_id, p_line_rec.price_list_id) THEN
                        fnd_message.set_name('ONT', 'OE_INVALID_AGREEMENT_PLIST');
                        fnd_message.set_Token('AGREEMENT_NAME', l_agreement_name);
                                BEGIN
                                        SELECT name
                         INTO   l_price_list_name
                                        FROM   qp_List_headers_vl
                                        WHERE  list_header_id = p_line_rec.price_list_id
                                        AND    trunc(nvl(p_line_rec.pricing_date,sysdate)) BETWEEN
                                               trunc(nvl(START_DATE_ACTIVE,add_months(sysdate,-10000)))
                                        AND       trunc(nvl(END_DATE_ACTIVE,add_months(sysdate,+10000)));

                                        Exception when no_data_found then
                                                l_price_list_name := p_line_rec.price_list_id;
                                END;
                        fnd_message.set_Token('PRICE_LIST1', l_price_list_name);
                                BEGIN

                                        SELECT name
                         INTO   l_price_list_name
                                        FROM   QP_List_headers_vl
                                        WHERE  list_header_id = l_price_list_id
                                        AND    trunc(nvl(p_line_rec.pricing_date,sysdate)) BETWEEN
                                                  trunc(nvl(START_DATE_ACTIVE,add_months(sysdate,-10000)))
                                     AND    trunc(nvl(END_DATE_ACTIVE,add_months(sysdate,+10000)));
                                EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                                                l_price_list_name := l_price_list_id;
                                END;
                        fnd_message.set_Token('PRICE_LIST2', l_price_list_name);
                        OE_MSG_PUB.Add;
                        IF l_debug_level > 0 then
                                oe_debug_pub.add('Invalid Agreement +price_list_id combination',2);
                        END IF;
                                raise FND_API.G_EXC_ERROR;
                        END IF;
            END IF;    -- end of if l_list_type_code <> 'PRL'
 end if; --for bug 2345712   end

                -- modified by lkxu, to check for customer relationships.
        IF l_sold_to_org IS NOT NULL AND l_sold_to_org <> -1
                AND NOT OE_GLOBALS.EQUAL(l_sold_to_org,p_line_rec.sold_to_org_id) THEN
                IF nvl(lcustomer_relations,'N') = 'N' THEN
                        fnd_message.set_name('ONT', 'OE_INVALID_AGREEMENT');
                        fnd_message.set_Token('AGREEMENT_ID', p_line_rec.agreement_id);
                        fnd_message.set_Token('AGREEMENT_NAME', l_agreement_name);
                        fnd_message.set_Token('CUSTOMER_ID', p_line_rec.sold_to_org_id);
                        OE_MSG_PUB.Add;
                        IF l_debug_level > 0 then
                                oe_debug_pub.add('Invalid Agreement +sold_org_id combination',2);
                        END IF;
                                RAISE FND_API.G_EXC_ERROR;
        ELSIF lcustomer_relations = 'Y' THEN

                        BEGIN
                          SELECT        'VALID'
                          INTO  l_dummy
                          FROM  dual
                          WHERE         exists(
                        select 'x' from
                        hz_cust_acct_relate where
                        related_cust_account_id = p_line_rec.sold_to_org_id
                        and status = 'A'
                                AND cust_account_id = l_sold_to_org
                                        );

                        EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                        fnd_message.set_name('ONT', 'OE_INVALID_AGREEMENT');
                        fnd_message.set_Token('AGREEMENT_ID', p_line_rec.agreement_id);
                        fnd_message.set_Token('AGREEMENT_NAME', l_agreement_name);
                        fnd_message.set_Token('CUSTOMER_ID', p_line_rec.sold_to_org_id);
                        OE_MSG_PUB.Add;
                        IF l_debug_level > 0 then
                                oe_debug_pub.add('Invalid Agreement +sold_org_id combination',2);
                        END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END;
           END IF;
         END IF;


                EXCEPTION
               WHEN NO_DATA_FOUND THEN
                fnd_message.set_name('ONT', 'OE_INVALID_AGREEMENT');
                fnd_message.set_Token('AGREEMENT_ID', p_line_rec.agreement_id);
                fnd_message.set_Token('AGREEMENT_NAME', l_agreement_name);
                fnd_message.set_Token('CUSTOMER_ID', l_sold_to_org);
                OE_MSG_PUB.Add;
                IF l_debug_level > 0 then
                        oe_debug_pub.add('Invalid Agreement +sold_org_id combination',2);
                END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END;
         END IF; -- Agreement has changed

    -- fixed bug 1672380, only validate for not null price list id
    ELSIF p_line_rec.price_list_id IS NOT NULL and
          NOT OE_GLOBALS.EQUAL(p_line_rec.price_list_id,p_old_line_rec.price_list_id)
      THEN

       if p_line_rec.cancelled_flag <> 'Y' and
          p_line_rec.calculate_price_flag not in ('P','N') Then
        BEGIN
          --
        l_hdr_currency_code := OE_ORDER_CACHE.g_header_rec.transactional_curr_code;

        --fix a problem in which for some rare cases in which cachce has a null of transactional_curr_code
        If nvl(l_hdr_currency_code,FND_API.G_MISS_CHAR) =  FND_API.G_MISS_CHAR Then
          Select transactional_curr_code
          into   l_hdr_currency_code
          From   oe_order_headers_all
          Where  header_id = p_line_rec.header_id;
        End If;

        QP_UTIL_PUB.Validate_Price_list_Curr_code(p_line_rec.price_list_id,
                                                  l_hdr_currency_code,
                                                  p_line_rec.pricing_date,
                                                  l_validate_result);

          --
        EXCEPTION
          --
          WHEN NO_DATA_FOUND THEN
            --
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
              --
              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PRICE_LIST_ID');

              fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                OE_Order_Util.Get_Attribute_Name('price_list_id'));
              OE_MSG_PUB.Add;
              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
              --
            END IF;
            --
            RAISE FND_API.G_EXC_ERROR;
            --
        END;
        --
       end if;
        IF l_debug_level > 0 then
        OE_DEBUG_PUB.ADD('l_hdr_currency_code:' || l_hdr_currency_code,2);
        OE_DEBUG_PUB.ADD('l_validate_result:'||l_VALIDATE_RESULT);
        OE_DEBUG_PUB.ADD('operation:'||p_line_rec.operation);
        OE_DEBUG_PUB.ADD('validate level'||p_validation_level);
        END IF;
        --
        IF l_VALIDATE_RESULT = 'N' THEN
          --bug 3572931 depending on the validation level set the Price List to NULL or G_MISS_NUM
          --if it is not valid, else raise an error.
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL
              AND  p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE    THEN
                p_line_rec.price_list_id := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF
              AND  p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE   THEN
                p_line_rec.price_list_id := FND_API.G_MISS_NUM;
                G_REDEFAULT_MISSING := 'Y';
           ELSE

             --
             FND_MESSAGE.SET_NAME('ONT','OE_CURRENCY_MISMATCH');
             FND_MESSAGE.SET_TOKEN('LINE_CURR_CODE', l_currency_code);
             FND_MESSAGE.SET_TOKEN('PRICE_LIST_NAME', l_price_list_name);
             FND_MESSAGE.SET_TOKEN('HEADER_CURR_CODE', l_hdr_currency_code);
             OE_MSG_PUB.ADD;
             --
             RAISE FND_API.G_EXC_ERROR;
             --
             END IF;
        END IF;

        --
        IF NOT oe_globals.equal(p_line_rec.pricing_date,p_old_line_rec.pricing_date) OR
                not oe_globals.equal(p_line_rec.price_list_id,p_old_line_rec.price_list_id) THEN

        -- Allow only the non agreement price_lists
        -- do not need to validate price list if calculate_price_flag is N or P.
          IF p_line_rec.calculate_price_flag Not IN ('N', 'P')
          --Bug 3572931 added the condition so that code is called only when Price List is not NULL and G_MISS_NUM
            AND not (oe_globals.equal(p_line_rec.price_list_id,FND_API.G_MISS_NUM)  OR
                        (p_line_rec.price_list_id IS NULL ) )
          THEN

          BEGIN
           IF l_debug_level > 0 then
           oe_debug_pub.add('Pricing date is '||p_line_rec.pricing_date,2);
           END IF;

           -- Modified 09-DEC-2001
           -- Blankets: modified select to select list_type_code instead
           -- of selecting only PRL price list
           -- modified by lkxu: to select from qp_list_headers_vl instead
           -- of from qp_price_lists_v to select only PRL type list headers.

       --use cache instead of sql for bug 4200055
             l_price_list_rec :=  OE_ORDER_CACHE.Load_Price_List(p_line_rec.price_list_id) ;
       IF ( l_price_list_rec.price_list_id <> FND_API.G_MISS_NUM
         AND l_price_list_rec.price_list_id IS NOT NULL
         AND l_price_list_rec.price_list_id = p_line_rec.price_list_id ) THEN
        if (
           trunc(nvl(l_price_list_rec.start_date_active,add_months(sysdate,-10000))) <= trunc(nvl(p_line_rec.pricing_date,sysdate))
        and trunc(nvl(l_price_list_rec.end_date_active,add_months(sysdate,10000))) >= trunc(nvl(p_line_rec.pricing_date,sysdate))
                   )  then
            l_price_list_name :=  l_price_list_rec.name ;
            l_list_type_code  :=  l_price_list_rec.list_type_code ;
        else
            RAISE NO_DATA_FOUND ;
        end if ;
       ELSE
            RAISE NO_DATA_FOUND ;
       END IF ;
           /*SELECT name, list_type_code
           INTO l_price_list_name, l_list_type_code
                FROM   qp_list_headers_vl
                WHERE  list_header_id = p_line_rec.price_list_id
                AND    trunc(nvl(p_line_rec.pricing_date,sysdate)) BETWEEN
                          trunc(nvl(START_DATE_ACTIVE,add_months(sysdate,-10000)))
                AND    trunc(nvl(END_DATE_ACTIVE,add_months(sysdate,+10000))); */
        -- end bug 4200055

           IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110509'
                AND p_line_rec.blanket_number IS NOT NULL
           THEN

             -- For release lines, any price lists other than PRL and AGR are
             -- invalid.
             IF l_list_type_code NOT IN ('PRL','AGR') THEN
                RAISE NO_DATA_FOUND;
             END IF;

             -- If price list is of type 'AGR', validate customer on agreement
             -- against customer on line. If sold_to_org_id on agreement is -1,
             -- price list is valid for all customers.
             IF l_list_type_code = 'AGR' THEN
                IF lcustomer_relations = 'N' THEN
                  SELECT 'Y'
                    INTO l_dummy
                    FROM oe_agreements oa
                   WHERE price_list_id = p_line_rec.price_list_id
                     AND (sold_to_org_id = -1
                          OR sold_to_org_id = p_line_rec.sold_to_org_id);
                ELSIF lcustomer_relations = 'Y' THEN
                  SELECT 'Y'
                    INTO l_dummy
                    FROM oe_agreements oa
                   WHERE price_list_id = p_line_rec.price_list_id
                     AND sold_to_org_id IN
                            (select -1
                               from dual
                             union
                             select p_line_rec.sold_to_org_id
                               from dual
                             union
                             select r.cust_account_id
                               from hz_cust_acct_relate r
                              where r.related_cust_account_id = p_line_rec.sold_to_org_id);
                END IF;
             END IF;

           -- For regular lines, price list other than of type PRL is invalid
           ELSIF l_list_type_code <> 'PRL'  THEN
              RAISE NO_DATA_FOUND;
           END IF;

          EXCEPTION
          WHEN NO_DATA_FOUND THEN
           fnd_message.set_name('ONT', 'OE_INVALID_NONAGR_PLIST');
           fnd_message.set_Token('PRICE_LIST1', p_line_rec.price_list_id);
           fnd_message.set_Token('PRICING_DATE', p_line_rec.pricing_date);
           OE_MSG_PUB.Add;
           IF l_debug_level > 0 then
                oe_debug_pub.add('Invalid non agreement price list ',2);
           END IF;
                RAISE FND_API.G_EXC_ERROR;
          END;

         END IF; --calculate_price_flag
        END IF; -- Price list or pricing date has changed
    END IF;
    IF l_debug_level > 0 then
    oe_debug_pub.add('15 '||l_return_status ,1);
    END IF;

    -- Line number validation.
    -- Allow line number updates only on Model, Standard, Kit,
    -- and stand alone service line.
    -- Bug 2382657 : Modified the condition for KIT and added
    --               condition for INCLUDED items.

    IF p_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

           IF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION) OR
              (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS)  OR
              (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT AND
               p_line_rec.line_id <> p_line_rec.top_model_line_id )   OR    --bug 2382657
              (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_INCLUDED) OR
              (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_SERVICE AND
                     p_line_rec.service_reference_line_id IS NOT NULL      AND
                        p_line_rec.service_reference_line_id <> FND_API.G_MISS_NUM)

                 THEN

              IF (NOT OE_GLOBALS.EQUAL(p_line_rec.line_number,
                                       p_old_line_rec.line_number)) THEN

                  l_return_status := FND_API.G_RET_STS_ERROR;
                           fnd_message.set_name('ONT', 'OE_LINE_NUMBER_UPD');
                        OE_MSG_PUB.add;

                    END IF;
                 END IF;

    END IF;

    IF l_debug_level > 0 then
    oe_debug_pub.add('16 '||l_return_status ,1);
    END IF;
  IF l_debug_level > 0 then
  IF p_line_rec.top_model_line_id is not null AND
        p_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
        p_line_rec.ordered_quantity = 0
    THEN
    IF l_debug_level > 0 then
    oe_debug_pub.add('qty of a configuration related line 0'|| p_line_rec.item_type_code, 1);
    END IF;
  END IF;
  END IF;
/*
    -- If a model has classes/options under it, making ordered_quantity from n
    -- to 0 is not allowed.  It has some issues when the next time user
    -- changing model's quantity from 0 to n, we can not simply cascade etc. We
    -- will give a message which says that => user needs to delete all the
    -- options/classes under this model and then he can change the quantity to
    -- 0. I will add this message and modify code accordingly.
    -- Also the next time user wants to go to configurator, he should change
    -- the ordered quantity on the model line from 0 to something, else we will
    -- not open configurator. I will add a message for this. Order Import also
    -- will have same behavior. However we do see if this is a complete cancellation.


    IF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS   OR
        p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION) AND
        p_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE        AND
        p_line_rec.ordered_quantity = 0
    THEN
         IF l_debug_level > 0 then
         oe_debug_pub.add('class/option qty changed to 0', 1);
         END IF;
         l_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('ONT', 'OE_CONFIG_NO_ZERO_QTY');
         oe_msg_pub.add;
    END IF;

    l_option_count := 0;

    IF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
        p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT) AND
        p_line_rec.ordered_quantity = 0 AND
        p_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
       OE_Sales_Can_Util.G_Require_Reason = FALSE
    THEN
       -- this is a decrement and not a cancellation.

       SELECT count(*)
       INTO   l_option_count
       FROM   oe_order_lines
       WHERE  top_model_line_id = p_line_rec.line_id
       AND    line_id <> p_line_rec.line_id;

       IF l_option_count > 0 THEN
         IF l_debug_level > 0 then
         oe_debug_pub.add('models qty changed to 0, no cancellation', 1);
         END IF;
         l_return_status := FND_API.G_RET_STS_ERROR;
         FND_Message.Set_Name('ONT', 'OE_CONFIG_NO_ZERO_QTY');
         oe_msg_pub.add;
       END IF;
     END IF;
*/
    IF l_debug_level > 0 then
    oe_debug_pub.add('OEXLLINB, RR:T2',1);
    oe_debug_pub.add('17 '||l_return_status ,1);
    END IF;

    -- Validate ordered quantity for OTA lines. OTA Lines are
    -- identified by item_type_code of training. The ordered
    -- quantity cannot be greater than 1 for OTA lines.

    l_order_quantity_uom := p_line_rec.order_quantity_uom;
    l_is_ota_line := OE_OTA_UTIL.Is_OTA_Line(l_order_quantity_uom);

    IF (l_is_ota_line) AND
        p_line_rec.ordered_quantity > 1 then
         IF l_debug_level > 0 then
         oe_debug_pub.add('Ordered Qty cannot be greater than 1 for OTA lines', 1);
         END IF;
         l_return_status := FND_API.G_RET_STS_ERROR;
         FND_Message.Set_Name('ONT', 'OE_OTA_INVALID_QTY');
         oe_msg_pub.add;
    END IF;

    /* End of validation for OTA */

    --bug3412008 Suppressing the warning message for PO number for retrobill lines
   IF p_line_rec.order_source_id <> 27 THEN
    -- Fix bug 1162304: issue a warning message if the PO number
    -- is being referenced by another order
    IF p_line_rec.cust_po_number IS NOT NULL
          AND ( NOT OE_GLOBALS.EQUAL(p_line_rec.sold_to_org_id
                              ,p_old_line_rec.sold_to_org_id)
             OR NOT OE_GLOBALS.EQUAL(p_line_rec.cust_po_number
                              ,p_old_line_rec.cust_po_number)
            )
    THEN

      -- Fixed bug 1949756: validate line level cust po number
      -- only if it is different from header cust po number
      OE_Order_Cache.Load_Order_Header(p_line_rec.header_id);
      IF NOT OE_GLOBALS.EQUAL(OE_Order_Cache.g_header_rec.cust_po_number,
                              p_line_rec.cust_po_number)
         AND OE_Validate_Header.Is_Duplicate_PO_Number
           (p_line_rec.cust_po_number
           ,p_line_rec.sold_to_org_id
           ,p_line_rec.header_id )
      THEN
          FND_MESSAGE.SET_NAME('ONT','OE_VAL_DUP_PO_NUMBER');
          OE_MSG_PUB.ADD;
      END IF;

    END IF;
    -- End of check for duplicate PO number
   END IF; --bug3412008

    --  Bug -2124989 Added Agreement validation.

    IF p_line_rec.agreement_id IS NOT NULL AND
       p_line_rec.agreement_id <> FND_API.G_MISS_NUM THEN

         IF NOT oe_globals.equal(p_line_rec.pricing_date,
                                 p_old_line_rec.pricing_date) OR
                not oe_globals.equal(p_line_rec.agreement_id,
                                     p_old_line_rec.agreement_id) THEN
        -- Allow only the Active agreement Revision

        BEGIN
          IF l_debug_level > 0 then
          oe_debug_pub.add('Pricing date is '||p_line_rec.pricing_date,2);
          END IF;

          SELECT name
          INTO   l_agreement_name
                FROM   oe_agreements_vl
                WHERE  agreement_id = p_line_rec.agreement_id
                AND    trunc(nvl(p_line_rec.pricing_date,sysdate)) BETWEEN
                       trunc(nvl(START_DATE_ACTIVE,add_months(sysdate,-10000)))
                AND    trunc(nvl(END_DATE_ACTIVE,add_months(sysdate,+10000)));

         EXCEPTION
         WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('ONT', 'ONT_INVALID_AGR');
          fnd_message.set_Token('PRICING_DATE', p_line_rec.pricing_date);
          OE_MSG_PUB.Add;
          IF l_debug_level > 0 then
                oe_debug_pub.add('Invalid Agreement',2);
          END IF;
                RAISE FND_API.G_EXC_ERROR;
      END;
     End If;
   END IF; /* End of Bug-2124989 */


    -- Fix for bug#1411346:
    -- SERVICE end date must be after service start date.

    IF (p_line_rec.service_end_date <> FND_API.G_MISS_DATE OR
        p_line_rec.service_end_date IS NOT NULL) AND
       (p_line_rec.service_start_date <> FND_API.G_MISS_DATE OR
        p_line_rec.service_start_date IS NOT NULL) THEN

          IF (p_line_rec.service_end_date < p_line_rec.service_start_date)   --  2992944
          THEN
         l_return_status := FND_API.G_RET_STS_ERROR;
         fnd_message.set_name('ONT','OE_SERV_END_DATE');
         OE_MSG_PUB.Add;
       END IF;

    END IF;


    -- Validating Commitment on an order line.
    -- Also Enhancement Request #1741013:
    -- to validate Commitment End Date against OTA Event End Date.

    -- fix bug 1618229.
    -- Fix Bug # 3015881: Validate Commitment for change in Line Level Invoice To
    IF p_line_rec.commitment_id is not NULL AND
       (NOT OE_GLOBALS.EQUAL(p_old_line_rec.commitment_id, p_line_rec.commitment_id)
        OR NOT OE_GLOBALS.EQUAL(p_old_line_rec.sold_to_org_id, p_line_rec.sold_to_org_id)
        OR NOT OE_GLOBALS.EQUAL(p_old_line_rec.invoice_to_org_id, p_line_rec.invoice_to_org_id)
        OR NOT OE_GLOBALS.EQUAL(p_old_line_rec.inventory_item_id, p_line_rec.inventory_item_id)
        OR NOT OE_GLOBALS.EQUAL(p_old_line_rec.ordered_item_id, p_line_rec.ordered_item_id)
        OR NOT OE_GLOBALS.EQUAL(p_old_line_rec.ordered_item, p_line_rec.ordered_item)
        OR (NOT OE_GLOBALS.EQUAL(p_old_line_rec.agreement_id, p_line_rec.agreement_id)
            AND p_line_rec.agreement_id IS NOT NULL)) THEN

        IF l_debug_level > 0 then
        OE_DEBUG_PUB.ADD('l_hdr_currency_code1:' || l_hdr_currency_code,2);
        END IF;
        l_hdr_currency_code := OE_ORDER_CACHE.g_header_rec.transactional_curr_code;
        Validate_Commitment(
                  p_line_rec          => p_line_rec
                , p_hdr_currency_code => l_hdr_currency_code
                , p_ota_line          => l_is_ota_line
                , x_return_status     => l_commitment_status    );

        IF l_commitment_status = FND_API.G_RET_STS_ERROR THEN
                l_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;
    IF l_debug_level > 0 then
    oe_debug_pub.add('18 '||l_return_status ,1);
    END IF;

    IF  (nvl(p_line_rec.top_model_line_id,-1) <> nvl(p_line_rec.ato_line_id,-1) AND
        p_line_rec.top_model_line_id IS NOT NULL) AND
        (nvl(p_line_rec.ship_tolerance_below,0) <> 0 OR
        nvl(p_line_rec.ship_tolerance_above,0) <> 0 )THEN
        IF l_debug_level > 0 then
        oe_debug_pub.add('Ship tolerances can not be specified on PTOs',3);
        END IF;
        l_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('ONT','OE_NO_TOL_FOR_PTO');
        OE_MSG_PUB.Add;

    END IF;
    IF l_debug_level > 0 then
    oe_debug_pub.add('19 '||l_return_status ,1);
    END IF;


    IF p_line_rec.top_model_line_id is NOT NULL AND
       p_line_rec.top_model_line_id <> p_line_rec.line_id AND
       p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
       p_line_rec.ordered_quantity is NULL THEN

      IF l_debug_level > 0 then
      oe_debug_pub.add('child line of model with null qty', 3);
      END IF;
      l_return_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('ONT','OE_CONFIG_NULL_QUANTITY');
      fnd_message.set_Token('ITEM', nvl(p_line_rec.ordered_item,p_line_rec.inventory_item_id));
      OE_MSG_PUB.Add;

    END IF;

   IF l_debug_level > 0 then
   oe_debug_pub.add('20 '||l_return_status ,1);
   END IF;

    -- Added the logic to fix bug 2116353.
    IF NOT Validate_set_id
            (p_line_rec => p_line_rec,
             p_old_line_rec => p_old_line_rec) THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

    -- BUG 1282873
    IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN

      IF NVL(p_line_rec.override_atp_date_code, 'N') = 'Y' THEN

        IF p_line_rec.schedule_ship_date IS NULL AND
           p_line_rec.schedule_arrival_date IS NULL AND
           p_line_rec.ship_set_id IS NULL AND
           p_line_rec.arrival_set_id IS NULL AND
           p_line_rec.schedule_action_code IS NULL THEN

           -- Must have some scheduling action when you set the Override
           -- ATP Flag
           FND_MESSAGE.SET_NAME('ONT','OE_SCH_OVER_ATP_NO_SCH_ACT');
           OE_MSG_PUB.Add;
           IF l_debug_level > 0 then
           Oe_debug_pub.add('Missing Schedule Action',1);
           END IF;
           l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_SERVICE OR
            p_line_rec.line_category_code = 'RETURN' OR
            p_line_rec.source_type_code = OE_GLOBALS.G_SOURCE_EXTERNAL) THEN

            -- Override ATP flag cannot be set for Service, Return,
            -- and Drop Ship Lines.
            FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_OVER_ATP_INVLD_LINE');
            OE_MSG_PUB.Add;
            IF l_debug_level > 0 then
            Oe_debug_pub.add('Override ATP cannot be set for Service, Return and
                                Drop Ship lines',1);
            END IF;
            l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

     END IF; -- override atp set to Y

   ELSE

     IF p_line_rec.override_atp_date_code IS NOT NULL  THEN

       fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Override Atp');
       OE_MSG_PUB.Add;
       l_return_status := FND_API.G_RET_STS_ERROR;
       IF l_debug_level > 0 then
       Oe_debug_pub.add('Override ATP cannot be set prior to pack-I' ||
                                  p_line_rec.override_atp_date_code,2);
       END IF;

     END IF;
   END IF; -- check for code release level
   -- END 1282873

   IF  Nvl(p_line_rec.firm_demand_flag,'N') <> FND_API.G_MISS_CHAR
   AND NOT OE_GLOBALS.EQUAL(p_line_rec.firm_demand_flag,
                            p_old_line_rec.firm_demand_flag)
   THEN
    IF l_debug_level > 0 then
    oe_debug_pub.add('Old firm flag : ' || p_old_line_rec.firm_demand_flag,3);
    oe_debug_pub.add('New firm flag : ' || p_line_rec.firm_demand_flag,3);
    END IF;
    IF nvl(p_line_rec.cancelled_flag,'N') = 'Y'
    OR p_line_rec.shipped_quantity is NOT NULL
    OR p_line_rec.source_type_code = OE_GLOBALS.G_SOURCE_EXTERNAL
    OR p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_SERVICE
    OR p_line_rec.line_category_code =  'RETURN'
    OR p_line_rec.open_flag = 'N'  THEN

       FND_MESSAGE.SET_NAME('ONT','OE_INVALID_FIRM_OPR');
       OE_MSG_PUB.Add;
       l_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

   END IF;

   IF p_line_rec.user_item_description IS NOT NULL
      AND p_line_rec.source_type_code = 'EXTERNAL'
      AND NOT OE_GLOBALS.EQUAL(p_line_rec.user_item_description,
                               fnd_api.g_miss_char)
      AND (NOT oe_globals.equal(p_line_rec.user_item_description,
                               p_old_line_rec.user_item_description)
           OR NOT oe_globals.equal(p_line_rec.source_type_code,
                               p_old_line_rec.source_type_code))
      AND OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN

        Validate_User_Item_Description
            ( p_line_rec      => p_line_rec
             ,x_return_status => l_status);

        IF l_status =  FND_API.G_RET_STS_ERROR THEN
           l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
   END IF;

    -------------------------------------------------------------------
    -- Validating Blankets
    -------------------------------------------------------------------

    IF OE_CODE_CONTROL.Get_Code_Release_Level < '110509' THEN

       IF  (p_line_rec.blanket_number IS NOT NULL OR
              p_line_rec.blanket_line_number IS NOT NULL OR
                   p_line_rec.blanket_version_number IS NOT NULL) THEN
        if l_debug_level > 0 then
            OE_DEBUG_PUB.Add('Blankets are only available in Pack I or greater',1);
        end if;
        l_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('ONT','OE_BLANKET_INVALID_VERSION');
        OE_MSG_PUB.Add;
      END IF;

    ELSE

        IF p_line_rec.blanket_number IS NOT NULL THEN

            Validate_Blanket_Values
               (p_line_rec      => p_line_rec,
                p_old_line_rec  => p_old_line_rec,
                x_return_status => l_status);
            IF l_status = FND_API.G_RET_STS_ERROR THEN
               l_return_status := l_status;
            ELSIF l_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

         END IF;

    END IF; --check if less than pack I

    ---------------------------------------------------------
    -- Validate Pick Released Shipsets and SMC Models
    ---------------------------------------------------------
    IF p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
       p_line_rec.booked_flag = 'Y' AND
       (p_line_rec.ship_set_id IS NOT NULL  OR
        p_line_rec.ship_model_complete_flag = 'Y')
    THEN
        Validate_Shipset_SMC
        ( p_line_rec           =>   p_line_rec
         ,p_old_line_rec       =>   p_old_line_rec
         ,x_return_status      =>   l_status);

        IF l_status = FND_API.G_RET_STS_ERROR THEN
           l_return_status := l_status;
        ELSIF l_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    IF p_line_rec.source_type_code = 'EXTERNAL' AND
       p_line_rec.booked_flag = 'Y' AND
       NOT OE_GLOBALS.EQUAL(p_line_rec.ordered_quantity,
                           p_old_line_rec.ordered_quantity) THEN

      IF l_debug_level > 0 THEN
        oe_debug_pub.add('dropship line - check if message reqd', 1);
      END IF;

      BEGIN
        SELECT requisition_header_id, po_header_id
        --INTO   l_uom_count, l_msg_count
        INTO l_req_header_id,l_po_header_id
        FROM   oe_drop_ship_sources
        WHERE  line_id = p_line_rec.line_id;

        IF l_debug_level > 0 THEN
          oe_debug_pub.add(l_req_header_id || ' - '|| l_po_header_id, 1);
        END IF;

        IF l_req_header_id is not null THEN
          l_req_status := po_releases_sv2.get_release_status(l_req_header_id);
          IF l_debug_level > 0 THEN
            oe_debug_pub.add('l_req_status- '|| l_req_status, 3);
          END IF;

          IF l_req_status is null THEN
            po_reqs_sv2.get_reqs_auth_status
            (l_req_header_id,
             l_req_status,
             l_ds_req,
             l_ds_po);

            l_req_status := UPPER(l_req_status);
          END IF;

        END IF; -- req created


        IF l_po_header_id is not null THEN

          -- comment out for bug 4411054
          /*l_po_status := UPPER(po_headers_sv3.get_po_status(l_po_header_id));
          IF l_debug_level > 0 THEN
            oe_debug_pub.add('l_po_status- '|| l_po_status, 2);
          END IF;*/
          PO_DOCUMENT_CHECKS_GRP.po_status_check
                                (p_api_version => 1.0
                                , p_header_id => l_po_header_id
                                , p_mode => 'GET_STATUS'
                                , x_po_status_rec => l_po_status_rec
                                , x_return_status => l_return_status);
          IF(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              l_cancel_flag := l_po_status_rec.cancel_flag(1);
              l_closed_code := l_po_status_rec.closed_code(1);
              IF l_debug_level > 0 THEN
                 OE_DEBUG_PUB.Add('Sucess call from PO_DOCUMENT_CHECKS_GRP.po_status_check',2);
                 OE_DEBUG_PUB.Add('Cancel_flag : '|| l_cancel_flag, 2);
                 OE_DEBUG_PUB.Add('Closed_code : '|| l_closed_code,2);
               END IF;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
          END IF;

        END IF; -- po created

        IF ((INSTR(nvl(l_req_status, 'z'), 'CANCELLED') = 0 AND
            INSTR(nvl(l_req_status, 'z'), 'FINALLY CLOSED') = 0) OR
           --(INSTR(nvl(l_po_status, 'z'), 'CANCELLED') = 0 AND
           --INSTR(nvl(l_po_status, 'z'), 'FINALLY CLOSED') = 0)) AND
           (nvl(l_cancel_flag,'z')='Y' AND
           nvl(l_closed_code, 'z')= 'FINALLY CLOSED' )) AND
              (PO_CODE_RELEASE_GRP.Current_Release <
                   PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J AND
                     OE_CODE_CONTROL.Code_Release_Level  < '110510') THEN


           Fnd_Message.Set_Name('ONT','ONT_DS_PO_CHANGE_REQD');

           l_ds_req := RTRIM(p_line_rec.line_number      || '.' ||
                             p_line_rec.shipment_number  || '.' ||
                             p_line_rec.option_number    || '.' ||
                             p_line_rec.component_number || '.' ||
                             p_line_rec.service_number, '.');


           FND_Message.Set_Token('LINE_NUM', l_ds_req);

           IF l_debug_level > 0 THEN
             oe_debug_pub.add('dropship line - message reqd', 1);
           END IF;

           BEGIN
             SELECT segment1
             INTO   l_sold_to_org
             FROM   po_requisition_headers_all
             WHERE  requisition_header_id =  l_req_header_id;

             FND_Message.Set_Token('REQ_NUM', l_sold_to_org);
             FND_Message.Set_Token('REQ_STS', nvl(l_req_status, '-'));

           EXCEPTION
             WHEN OTHERS THEN
               null;
           END;

           IF l_po_header_id is not NULL THEN

             SELECT segment1
             INTO   l_sold_to_org
             FROM   po_headers_all
             WHERE  po_header_id = l_po_header_id;

             FND_Message.Set_Token('PO_NUM', l_sold_to_org);
             -- bug 4411054
             --FND_Message.Set_Token('PO_STS', nvl(l_po_status, '-'));
             FND_Message.Set_Token('PO_STS', nvl(l_closed_code, '-'));

           ELSE

             FND_Message.Set_Token('PO_NUM', '-');
             FND_Message.Set_Token('PO_STS', 'NOT CREATED');
             IF l_debug_level > 0 THEN
               oe_debug_pub.add('no po', 4);
             END IF;
           END IF;

           OE_MSG_PUB.Add;
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF l_debug_level > 0 THEN
            oe_debug_pub.add('dropship line - message not reqd', 4);
          END IF;
        WHEN OTHERS THEN
          IF l_debug_level > 0 THEN
            oe_debug_pub.add('dropship line - others '|| sqlerrm, 3);
          END IF;
      END;
    END IF; --qty change on dropship line

    --------------------------------------------------
    -- Decimal Ratio Check.
    --------------------------------------------------

    IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.ADD('Before Decimal Ratio Check.. ');
        OE_DEBUG_PUB.add('No Decimal Check for Included Remnant Lines - 3132424',5);
    END IF;

    IF (p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE OR
        (p_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
              p_line_rec.item_type_code <> 'CONFIG' )) AND
       (p_line_rec.top_model_line_id is NOT NULL and
        p_line_rec.top_model_line_id <> p_line_rec.line_id)
       AND NVL(p_line_rec.model_remnant_flag,'N')='N'
    THEN
        Decimal_Ratio_Check
        ( p_line_rec           =>   p_line_rec
         ,x_return_status      =>   l_status);

        IF l_status = FND_API.G_RET_STS_ERROR THEN
           l_return_status := l_status;
        ELSIF l_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

--Macd
 -- This is to make sure If Old value is INSTALL_BASE it should not change
    IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.ADD('old rec ib_owner'||p_old_line_rec.ib_owner);
        OE_DEBUG_PUB.ADD('new rec ib_owner'||p_line_rec.ib_owner);
        OE_DEBUG_PUB.ADD('old rec ib_current_location'||p_old_line_rec.ib_current_location);
        OE_DEBUG_PUB.ADD('new rec ib_current_location'||p_line_rec.ib_current_location);
        OE_DEBUG_PUB.ADD('old rec ib_installed_at_location'||p_old_line_rec.ib_installed_at_location);
        OE_DEBUG_PUB.ADD('new rec ib_installed_at_location'||p_line_rec.ib_installed_at_location);
    END IF;

      IF p_old_line_rec.ib_owner='INSTALL_BASE' AND
       NOT OE_GLOBALS.EQUAL(p_line_rec.ib_owner,p_old_line_rec.ib_owner)
          THEN
    IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.ADD('VALIDATION FOR IB_OWNER FAILED IN OEXLLINB.pls');
        OE_DEBUG_PUB.ADD('OLD LINE HAS INSTALL_BASE CAN NOT CHANGE IT');
    END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_OWNER'));
             OE_MSG_PUB.Add;
          END IF;


     IF p_old_line_rec.ib_installed_at_location='INSTALL_BASE' AND
       NOT OE_GLOBALS.EQUAL(p_line_rec.ib_installed_at_location,p_old_line_rec.ib_installed_at_location)
          THEN
    IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.ADD('VALIDATION FOR IB_INSTALLED_AT_LOCATION FAILED IN OEXLLINB.pls');
        OE_DEBUG_PUB.ADD('OLD LINE HAS INSTALL_BASE CAN NOT CHANGE IT');
    END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_INSTALLED_AT_LOCATION'));
             OE_MSG_PUB.Add;
          END IF;


     IF p_old_line_rec.ib_current_location='INSTALL_BASE' AND
       NOT OE_GLOBALS.EQUAL(p_line_rec.ib_current_location,p_old_line_rec.ib_current_location)
           THEN
    IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.ADD('VALIDATION FOR IB_CURRENT_LOCATION FAILED IN OEXLLINB.pls');
        OE_DEBUG_PUB.ADD('OLD LINE HAS INSTALL_BASE CAN NOT CHANGE IT');
    END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_CURRENT_LOCATION'));
             OE_MSG_PUB.Add;
          END IF;

 -- END OF check.

-- This will prevent updating the three Ib fields with the value INSTALL_BASE
--  where the current value is not null

    IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.ADD('1 old rec ib_owner'||p_old_line_rec.ib_owner);
    END IF;
      IF p_line_rec.ib_owner='INSTALL_BASE' and p_old_line_rec.ib_owner in ('END_CUSTOMER','SOLD_TO') THEN
    IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.ADD('VALIDATION FOR IB_OWNER FAILED IN OEXLLINB.pls');
        OE_DEBUG_PUB.ADD('TRYING TO UPDATE WITH INSTALL_BASE OLD LINE HAS SOME VALUE');
    END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_OWNER'));
             OE_MSG_PUB.Add;
       END IF;

      IF p_line_rec.ib_installed_at_location='INSTALL_BASE' and p_old_line_rec.ib_installed_at_location in ('BILL_TO','DELIVER_TO','END_CUSTOMER','SHIP_TO','SOLD_TO') THEN
    IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.ADD('VALIDATION FOR IB_INSTALLED_AT_LOCATION FAILED IN OEXLLINB.pls');
        OE_DEBUG_PUB.ADD('TRYING TO UPDATE WITH INSTALL_BASE OLD LINE HAS SOME VALUE');
    END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_INSTALLED_AT_LOCATION'));
             OE_MSG_PUB.Add;
       END IF;

      IF p_line_rec.ib_current_location='INSTALL_BASE' and p_old_line_rec.ib_current_location in ('BILL_TO','DELIVER_TO','END_CUSTOMER','SHIP_TO','SOLD_TO') THEN
    IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.ADD('VALIDATION FOR IB_CURRENT_LOCATION FAILED IN OEXLLINB.pls');
        OE_DEBUG_PUB.ADD('TRYING TO UPDATE WITH INSTALL_BASE OLD LINE HAS SOME VALUE');
    END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_CURRENT_LOCATION'));
             OE_MSG_PUB.Add;
       END IF;

    IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' THEN

 IF p_line_rec.ib_owner='INSTALL_BASE' and p_old_line_rec.ib_owner Is NULL THEN

   IF p_line_rec.top_model_line_id is NULL THEN  -- This is not a model line

       IF l_debug_level >0 THEN
          OE_DEBUG_PUB.ADD('Validation for IB_OWNER failed from OEXLLINB.pls');
          OE_DEBUG_PUB.ADD('THIS IS NOT A MODEL , CAN NOT HAVE INSTALL_BASE ');
       END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_OWNER'));
             OE_MSG_PUB.Add;

    END IF;

   END IF;

 IF p_line_rec.ib_installed_at_location='INSTALL_BASE' and p_old_line_rec.ib_installed_at_location Is NULL THEN

   IF p_line_rec.top_model_line_id is NULL THEN  -- This is not a model line

       IF l_debug_level >0 THEN
          OE_DEBUG_PUB.ADD('Validation for IB_INSTALLED_AT_LOCATION failed from OEXLLINB.pls');
          OE_DEBUG_PUB.ADD('This is not a model , can not have INSTALL_BASE ');
       END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_INSTALLED_AT_LOCATION'));
             OE_MSG_PUB.Add;

  END IF;

 END IF;


 IF p_line_rec.ib_current_location='INSTALL_BASE' and p_old_line_rec.ib_current_location Is NULL THEN

   IF p_line_rec.top_model_line_id is NULL THEN  -- This is not a model line

       IF l_debug_level >0 THEN
          OE_DEBUG_PUB.ADD('Validation for IB_CURRENT_LOCATION failed from OEXLLINB.pls');
          OE_DEBUG_PUB.ADD('THIS IS NOT A MODEL , CAN NOT HAVE INSTALL_BASE ');
       END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_CURRENT_LOCATION'));
             OE_MSG_PUB.Add;

 END IF;

END IF;

END IF;

----Macd
    -- distributed orders @
    IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.ADD('old rec ib_owner:'||p_old_line_rec.ib_owner);
    END IF;
    IF p_line_rec.ib_owner IS NOT NULL AND
       (NOT OE_GLOBALS.EQUAL(p_line_rec.ib_owner,p_old_line_rec.ib_owner)
        OR NOT OE_GLOBALS.EQUAL(p_line_rec.sold_to_org_id, p_old_line_rec.sold_to_org_id)
        OR NOT OE_GLOBALS.EQUAL(p_line_rec.end_customer_id, p_old_line_rec.end_customer_id)
        OR  p_old_line_rec.ib_owner IS NULL )
    THEN
          IF p_line_rec.ib_owner = 'END_CUSTOMER' AND
             p_line_rec.end_customer_id is null
          THEN
             IF l_debug_level >0 THEN
                OE_DEBUG_PUB.ADD('end customer id is null but value is end_customer!');
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_OWNER'));
             OE_MSG_PUB.Add;

          ELSIF p_line_rec.ib_owner = 'SOLD_TO' AND
                p_line_rec.sold_to_org_id is null
          THEN
             IF l_debug_level >0 THEN
                OE_DEBUG_PUB.ADD(' sold_to_org_id is null but value is sold_to!');
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_OWNER'));
             OE_MSG_PUB.Add;
          END IF;
       END IF;
       IF l_debug_level > 0 then
       oe_debug_pub.ADD('ib_installed_at_location: '||p_line_rec.ib_installed_at_location);
       END IF;

       IF p_line_rec.ib_installed_at_location IS NOT NULL AND
          (NOT OE_GLOBALS.EQUAL(p_line_rec.ib_installed_at_location,p_old_line_rec.ib_installed_at_location)
           OR NOT OE_GLOBALS.EQUAL(p_line_rec.invoice_to_org_id ,p_old_line_rec.invoice_to_org_id)
           OR NOT OE_GLOBALS.EQUAL(p_line_rec.ship_to_org_id ,p_old_line_rec.ship_to_org_id)
           OR NOT OE_GLOBALS.EQUAL(p_line_rec.deliver_to_org_id ,p_old_line_rec.deliver_to_org_id)
           OR NOT OE_GLOBALS.EQUAL(p_line_rec.end_customer_site_use_id ,p_old_line_rec.end_customer_site_use_id)
           OR  p_old_line_rec.ib_installed_at_location IS NULL )
       THEN
          IF p_line_rec.ib_installed_at_location = 'BILL_TO' AND
             p_line_rec.invoice_to_org_id is null
          THEN
             IF l_debug_level >0 THEN
                OE_DEBUG_PUB.ADD(' bill_to_org_id is null but value is bill_to!');
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_INSTALLED_AT_LOCATION'));
             OE_MSG_PUB.Add;

          ELSIF p_line_rec.ib_installed_at_location = 'SHIP_TO' AND
                p_line_rec.ship_to_org_id is null
          THEN
             IF l_debug_level >0 THEN
                OE_DEBUG_PUB.ADD(' ship_to_org_id is null but value is ship_to!');
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_INSTALLED_AT_LOCATION'));
             OE_MSG_PUB.Add;

          ELSIF p_line_rec.ib_installed_at_location = 'DELIVER_TO' AND
                p_line_rec.deliver_to_org_id is null
          THEN
             IF l_debug_level >0 THEN
                OE_DEBUG_PUB.ADD(' deliver_to_org_id is null but value is deliver_to!');
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_INSTALLED_AT_LOCATION'));
             OE_MSG_PUB.Add;
          ELSIF p_line_rec.ib_installed_at_location = 'END_CUSTOMER' AND
                p_line_rec.end_customer_site_use_id is null
          THEN
             IF l_debug_level >0 THEN
                OE_DEBUG_PUB.ADD('end customer id is null but value is end_customer!');
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_INSTALLED_AT_LOCATION'));
             OE_MSG_PUB.Add;

            -- no validation for SOLD_TO
              -- since no line level sold_to_site_use_id
              -- REMOVE after LOV is fixed
          ELSIF p_line_rec.ib_installed_at_location = 'SOLD_TO'
                AND OE_Order_Cache.g_header_rec.sold_to_site_use_id is null
          THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_INSTALLED_AT_LOCATION'));
             OE_MSG_PUB.Add;

          END IF;
       END IF;
       IF l_debug_level > 0 then
       oe_debug_pub.ADD('ib_current_location: '||p_line_rec.ib_current_location);
       END IF;

       IF p_line_rec.ib_current_location IS NOT NULL AND
          (NOT OE_GLOBALS.EQUAL(p_line_rec.ib_current_location, p_old_line_rec.ib_current_location)
           OR NOT OE_GLOBALS.EQUAL(p_line_rec.invoice_to_org_id ,p_old_line_rec.invoice_to_org_id)
           OR NOT OE_GLOBALS.EQUAL(p_line_rec.ship_to_org_id ,p_old_line_rec.ship_to_org_id)
           OR NOT OE_GLOBALS.EQUAL(p_line_rec.deliver_to_org_id ,p_old_line_rec.deliver_to_org_id)
           OR NOT OE_GLOBALS.EQUAL(p_line_rec.end_customer_site_use_id ,p_old_line_rec.end_customer_site_use_id)
           OR  p_old_line_rec.ib_current_location IS NULL )
       THEN
          IF p_line_rec.ib_current_location = 'BILL_TO' AND
             p_line_rec.invoice_to_org_id is null
          THEN
       IF l_debug_level >0 THEN
          OE_DEBUG_PUB.ADD(' bill_to_org_id is null but value is bill_to!');
       END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_CURRENT_LOCATION'));
             OE_MSG_PUB.Add;

          ELSIF p_line_rec.ib_current_location = 'SHIP_TO' AND
                p_line_rec.ship_to_org_id is null
          THEN
             IF l_debug_level >0 THEN
                OE_DEBUG_PUB.ADD(' ship_to_org_id is null but value is ship_to!');
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_CURRENT_LOCATION'));
             OE_MSG_PUB.Add;

          ELSIF p_line_rec.ib_current_location = 'DELIVER_TO' AND
                p_line_rec.deliver_to_org_id is null
          THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_CURRENT_LOCATION'));
             OE_MSG_PUB.Add;

          ELSIF p_line_rec.ib_current_location = 'END_CUSTOMER' AND
                p_line_rec.end_customer_site_use_id is null
          THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_CURRENT_LOCATION'));
             OE_MSG_PUB.Add;

           -- no validation for SOLD_TO
             -- since no line level sold_to_site_use_id
             -- REMOVE after LOV is fixed
           ELSIF p_line_rec.ib_current_location = 'SOLD_TO'
                AND OE_Order_Cache.g_header_rec.sold_to_site_use_id is null
          THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_CURRENT_LOCATION'));
             OE_MSG_PUB.Add;


          END IF;
       END IF;

       -- end customer contact id depends on end customer id
       IF p_line_rec.end_customer_contact_id IS NOT NULL AND
     ( NOT OE_GLOBALS.EQUAL(p_line_rec.end_customer_contact_id
                           ,p_old_line_rec.end_customer_contact_id) OR
       NOT OE_GLOBALS.EQUAL(p_line_rec.end_customer_id
                           ,p_old_line_rec.end_customer_id))
    THEN

      BEGIN

        SELECT  'VALID'
        INTO  l_dummy
        FROM
             HZ_CUST_ACCOUNT_ROLES ACCT_ROLE
        WHERE
             ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_line_rec.end_customer_contact_id
             AND  ACCT_ROLE.CUST_ACCOUNT_ID = p_line_rec.end_customer_id
             AND  ROWNUM = 1
             AND  ACCT_ROLE.ROLE_TYPE = 'CONTACT'
             AND  STATUS= 'A';

        --  Valid Sold To Contact

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
          OE_Order_Util.Get_Attribute_Name('END_CUSTOMER_CONTACT_ID'));
          OE_MSG_PUB.Add;

        WHEN OTHERS THEN
          IF OE_MSG_PUB.Check_Msg_Level
          ( OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            OE_MSG_PUB.Add_Exc_Msg
            (  G_PKG_NAME ,
              'Record - End Customer Contact'
             );
          END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END; -- BEGIN

    END IF; -- End Customer contact needed validation.

    IF p_line_rec.end_customer_site_use_id IS NOT NULL AND
     ( NOT OE_GLOBALS.EQUAL(p_line_rec.end_customer_site_use_id
                           ,p_old_line_rec.end_customer_id) OR
       NOT OE_GLOBALS.EQUAL(p_line_rec.end_customer_id
                           ,p_old_line_rec.end_customer_id))
    THEN

      BEGIN

         SELECT /* MOAC_SQL_CHANGE */ 'VALID'
            INTO
            l_dummy
            FROM
            hz_cust_site_uses_all site_use,
            hz_cust_acct_sites acct_site
            WHERE
            site_use.site_use_id=p_line_rec.end_customer_site_use_id
            and site_use.cust_acct_site_id=acct_site.cust_acct_site_id
            and acct_site.cust_account_id=p_line_rec.end_customer_id;

        --  Valid End customer site

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
          OE_Order_Util.Get_Attribute_Name('END_CUSTOMER_SITE_USE_ID'));
          OE_MSG_PUB.Add;

        WHEN OTHERS THEN
          IF OE_MSG_PUB.Check_Msg_Level
          ( OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            OE_MSG_PUB.Add_Exc_Msg
            (  G_PKG_NAME ,
              'Record - End Customer Site'
             );
          END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END; -- BEGIN

    END IF; -- End Customer site needed validation.
    IF l_debug_level > 0 then
    oe_debug_pub.add('Top Model line:'||p_line_rec.top_model_line_id, 4);
    oe_debug_pub.add('Validate cfg? :'||OE_CONFIG_PVT.OECFG_VALIDATE_CONFIG, 4);
    oe_debug_pub.add('Return status before MACD Logic:'||l_return_status,4);
    END IF;

    IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' AND
       p_line_rec.top_model_line_id is NOT NULL THEN

       IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('MACD Logic, calling Validate_Container_model',3);
       END IF;

       --bug3314488
       --must use l_status as return variable so that value in
       --l_return_status is not overridden by the output of
       --Validate_Container_Model procedure
       OE_CONFIG_TSO_PVT.Validate_Container_Model
       (  p_line_rec      => p_line_rec
         ,p_old_line_rec  => p_old_line_rec
         --,x_return_status => l_return_status );
         ,x_return_status => l_status );

       IF l_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug_level > 0 THEN
             OE_DEBUG_PUB.Add('Error in Validate_Container_Model',2);
          END IF;
          l_return_status := l_status;
       ELSIF l_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          IF l_debug_level > 0 THEN
             OE_DEBUG_PUB.Add('Unexpected error in Validate_Container_Model',1);          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --end of bug3314488 fix
    ELSE
       IF l_debug_level > 0 then
       OE_DEBUG_PUB.Add('Not part of model||Not in 110510 - no MACD logic',3);
       END IF;
    END IF;

    IF l_debug_level > 0 THEN
       oe_debug_pub.add('Return status after MACD Logic:'||l_return_status,4);
    END IF;

  --{ Recurring Charges operation create or update of periodicity
  IF p_line_rec.charge_periodicity_code <> FND_API.G_MISS_CHAR AND
     NOT OE_GLOBALS.Equal(p_line_rec.charge_periodicity_code,
                          p_old_line_rec.charge_periodicity_code) THEN

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add ('Line has changed recurring charges:'
                     ||p_line_rec.charge_periodicity_code,3);
     END IF;

     IF OE_Validate.Charge_Periodicity (p_line_rec.charge_periodicity_code) THEN

        IF OE_SYS_PARAMETERS.Value ('RECURRING_CHARGES') = 'Y' THEN

           IF p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

              IF p_line_rec.top_model_line_id IS NOT NULL THEN
                 OE_CONFIG_TSO_PVT.Is_Part_Of_Container_Model
                    (  p_top_model_line_id   => p_line_rec.top_model_line_id
                      ,p_inventory_item_id   => p_line_rec.inventory_item_id
                      ,p_line_id             => p_line_rec.line_id
                      ,p_operation           => p_line_rec.operation
                      ,x_top_container_model => l_top_container_model
                      ,x_part_of_container   => l_part_of_container
                    );
              ELSE
                 l_part_of_container := 'N';
              END IF;

              IF l_part_of_container = 'N' OR
                 l_top_container_model = 'Y' THEN
                 IF l_debug_level > 0 THEN
                    OE_DEBUG_PUB.Add('ERR: Line not child of container model',2);
                    OE_DEBUG_PUB.Add('Line should not have charge periodicity',1);
                    OE_DEBUG_PUB.Add('Line ID:'||p_line_rec.line_id,1);
                 END IF;

                 --SELECT description
                 --INTO   l_item_description
                 --FROM   MTL_SYSTEM_ITEMS mtl_msi
                 --WHERE  mtl_msi.inventory_item_id = p_line_rec.inventory_item_id
                 --AND    mtl_msi.organization_id =
                 --   OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID');

                 FND_MESSAGE.SET_NAME('ONT','ONT_NO_RC_ALLOWED');
                 --FND_MESSAGE.SET_TOKEN('ITEM',l_item_description);
                 OE_MSG_PUB.Add;
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
           END IF; --operation CREATE

           IF p_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
              OE_GLOBALS.Equal (p_line_rec.inventory_item_id,
                                p_old_line_rec.inventory_item_id) THEN

              IF l_debug_level > 0 THEN
                 OE_DEBUG_PUB.Add('Line ID:'||p_line_rec.line_id,2);
                 OE_DEBUG_PUB.Add('Line Num:'||p_line_rec.line_number,2);
                 OE_DEBUG_PUB.Add('ERR: Update of charge periodicity',3);
              END IF;

              FND_MESSAGE.SET_NAME('ONT','ONT_NO_UPDATE_ON_PERIODICITY');
              FND_MESSAGE.SET_TOKEN('LINE_NUM',p_line_rec.line_number);
              OE_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;

           END IF;
        ELSE --recurring charges system paramter is N
           IF l_debug_level > 0 THEN
              OE_DEBUG_PUB.Add('ERR: Recurring Charges SYS Param is disabled');
           END IF;
           FND_MESSAGE.SET_NAME('ONT','ONT_RECUR_CHARGES_NOT_ENABLED');
           OE_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;

        END IF;
     ELSE -- Invalid charge_periodicity
        l_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
  END IF;
  -- Recurring Charges }
    --Shifted the code from procedure attributes to procedure entity as this is a cross attribute validation
    --for bug4963691
     --Added for bug 4905987 start

    IF p_line_rec.item_type_code <>'SERVICE'
    	AND NOT (l_rule_type = 'PP_DR_PP' OR l_rule_type = 'PP_DR_ALL') -- webroot bug 6826344 modified start
    	 then

       if p_line_rec.service_duration is not null and p_line_rec.service_duration <>FND_API.G_MISS_NUM then
           l_return_status := FND_API.G_RET_STS_ERROR;
    	   fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
           OE_Order_UTIL.Get_Attribute_Name('SERVICE_DURATION'));
           OE_MSG_PUB.ADD;
       end if;

       if p_line_rec.service_period is not null and p_line_rec.service_period <>FND_API.G_MISS_CHAR then
           l_return_status := FND_API.G_RET_STS_ERROR;
           fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
           OE_Order_UTIL.Get_Attribute_Name('SERVICE_PERIOD'));
           OE_MSG_PUB.ADD;
       end if;

       if p_line_rec.service_start_date is not null and p_line_rec.service_start_date <>FND_API.G_MISS_DATE  then
           l_return_status := FND_API.G_RET_STS_ERROR;
       fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
           OE_Order_UTIL.Get_Attribute_Name('SERVICE_START_DATE'));
           OE_MSG_PUB.ADD;
       end if;

       if p_line_rec.service_end_date is not null and p_line_rec.service_end_date <>FND_API.G_MISS_DATE then
           l_return_status := FND_API.G_RET_STS_ERROR;
       fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
           OE_Order_UTIL.Get_Attribute_Name('SERVICE_END_DATE'));
           OE_MSG_PUB.ADD;
       end if;

    -- webroot bug 6826344 added start
    END IF;

    IF p_line_rec.item_type_code <>'SERVICE' then

    -- webroot bug 6826344 added end

       if p_line_rec.service_txn_comments is not null and p_line_rec.service_txn_comments <>FND_API.G_MISS_CHAR then
           l_return_status := FND_API.G_RET_STS_ERROR;
       fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
           OE_Order_UTIL.Get_Attribute_Name('SERVICE_TXN_COMMENTS'));
           OE_MSG_PUB.ADD;
       end if;

       if p_line_rec.service_txn_reason_code is not null and p_line_rec.service_txn_reason_code <>FND_API.G_MISS_CHAR then
           l_return_status := FND_API.G_RET_STS_ERROR;
       fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
           OE_Order_UTIL.Get_Attribute_Name('SERVICE_TXN_REASON_CODE'));
           OE_MSG_PUB.ADD;
       end if;

       if p_line_rec.service_coterminate_flag is not null and p_line_rec.service_coterminate_flag <>FND_API.G_MISS_CHAR  then
           l_return_status := FND_API.G_RET_STS_ERROR;
       fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
           OE_Order_UTIL.Get_Attribute_Name('SERVICE_COTERMINATE_FLAG'));
           OE_MSG_PUB.ADD;
       end if;
     end if;

     --PP Revenue Recognition
     --bug 4893057
     -- webroot bug 6826344 modified the condition
     IF p_line_rec.item_type_code NOT IN ('SERVICE', 'STANDARD') THEN
	IF p_line_rec.accounting_rule_id <> FND_API.G_MISS_NUM AND
	p_line_rec.accounting_rule_id IS NOT NULL THEN
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Getting accounting rule type');
		END IF;
		SELECT type
			INTO l_rule_type
		FROM ra_rules
			WHERE rule_id = p_line_rec.accounting_rule_id;
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Rule Type is :'||l_rule_type);
		END IF;
		IF l_rule_type = 'PP_DR_ALL' or l_rule_type = 'PP_DR_PP' THEN
			l_return_status := FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.Set_Name('ONT','OE_INVALID_ATTRIBUTE');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
			OE_Order_Util.Get_Attribute_Name('ACCOUNTING_RULE_ID'));
			OE_MSG_PUB.ADD;
		END IF; --End of rule type
	END IF;--End of accounting type id is not null
      END IF; --End of item type not Service
      --PP Revenue Recognition
      --bug 4893057

      IF p_line_rec.item_type_code='SERVICE' and p_line_rec.service_period is not null and p_line_rec.service_period <>FND_API.G_MISS_CHAR then
         declare
       l_uom varchar2(3);
         begin
	/*Modified the query for bug # 4955363*/
        IF p_line_rec.ship_from_org_id = FND_API.G_MISS_NUM or p_line_rec.ship_from_org_id is NULL
           THEN
           SELECT uom_code
             INTO   l_uom
             FROM   mtl_item_uoms_view
             WHERE  inventory_item_id = p_line_rec.inventory_item_id
             and    uom_code=p_line_rec.service_period
             AND    organization_id   = l_mast_org_id
             and rownum=1;

        ELSE
             SELECT uom_code
             INTO   l_uom
             FROM   mtl_item_uoms_view
             WHERE  inventory_item_id = p_line_rec.inventory_item_id
             and    uom_code=p_line_rec.service_period
             AND    organization_id   = p_line_rec.ship_from_org_id
             and rownum=1;

        END IF;

         exception
       when no_data_found then
          begin
	/*Modified the query for bug # 4955363*/
        IF p_line_rec.ship_from_org_id = FND_API.G_MISS_NUM or p_line_rec.ship_from_org_id is NULL
	   THEN
             SELECT primary_uom_code
                  INTO   l_uom
                  FROM   mtl_system_items_b
                  WHERE  inventory_item_id = p_line_rec.inventory_item_id
                  AND    organization_id   = l_mast_org_id
                  and rownum=1;
        ELSE
             SELECT primary_uom_code
                  INTO   l_uom
                  FROM   mtl_system_items_b
                  WHERE  inventory_item_id = p_line_rec.inventory_item_id
                  AND    organization_id   = p_line_rec.ship_from_org_id
                  and rownum=1;
        END IF;

                  fnd_message.set_name('ONT','OE_INVALID_ORDER_QUANTITY_UOM');
                  fnd_message.set_token('ITEM',nvl(p_line_rec.ordered_item,p_line_rec.inventory_item_id));
                  fnd_message.set_token('UOM', l_uom);
              l_return_status := FND_API.G_RET_STS_ERROR;
              OE_MSG_PUB.ADD;
             exception
          when no_data_found then
                      IF l_debug_level > 0 then
                          oe_debug_pub.add('OEXLLINB, no_data_found in service period validation', 1);
                      END IF;
                      RAISE FND_API.G_EXC_ERROR;
              end;
          end ;
      end if;
     --Added for bug 4905987 end


    -- Please do not add code below this procedure. This has to be the last
    -- procedure in ENTITY
    IF G_REDEFAULT_MISSING = 'Y' AND
       l_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
        IF l_debug_level > 0 then
        oe_debug_pub.add('Inside G_REDEFAULT_MISSING',4);
        END IF;

        -- Need to Call Oe_Order_Pvt.Lines to re-default missing attributes

        l_control_rec.controlled_operation    := TRUE;
        l_control_rec.check_security          := TRUE;
        l_control_rec.clear_dependents        := TRUE;
        l_control_rec.default_attributes      := TRUE;
        l_control_rec.change_attributes       := TRUE;
        l_control_rec.validate_entity         := TRUE;
        l_control_rec.write_to_DB             := FALSE;
        l_control_rec.process                 := FALSE;


        l_old_line_tbl(1)                     := l_old_line_rec;
        l_line_tbl(1)                         := p_line_rec;

        Oe_Order_Pvt.Lines
        ( p_validation_level     => FND_API.G_VALID_LEVEL_NONE
        , p_control_rec          => l_control_rec
        , p_x_line_tbl           => l_line_tbl
        , p_x_old_line_tbl       => l_old_line_tbl
        , x_return_status        => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        p_line_rec := l_line_tbl(1);

   END IF;
   x_return_status := l_return_status;

   --  Done validating entity
   IF l_debug_level > 0 then
   oe_debug_pub.add('Exit OE_VALIDATE_LINE.ENTITY ' || x_return_status,1);
   END IF;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;

--  Procedure Attributes

PROCEDURE Attributes
( x_return_status OUT NOCOPY VARCHAR2

,   p_x_line_rec        IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec      IN OE_Order_PUB.Line_Rec_Type :=
                            OE_Order_PUB.G_MISS_LINE_REC
,   p_validation_level  IN NUMBER := FND_API.G_VALID_LEVEL_FULL
)
IS
l_return_status   VARCHAR2(1);
l_header_rec      OE_Order_PUB.Header_Rec_Type;
l_type_code       VARCHAR2(30);
l_header_created  BOOLEAN := FALSE;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_ret_sts_dff VARCHAR2(1) :=  FND_API.G_RET_STS_SUCCESS ; --bug8302126

BEGIN
    IF l_debug_level > 0 then
    oe_debug_pub.add('Enter procedure OE_validate_line.Attributes',1);
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Compare line attributes with header record if the header record is
    -- created in the same call to process_order. If they match
    -- then no need to re-validate line attributes.

    IF OE_GLOBALS.G_HEADER_CREATED
    THEN
    IF l_debug_level > 0 then
    oe_debug_pub.add('Header has got created in the same call',1);
    END IF;
        OE_Order_Cache.Load_Order_Header(p_x_line_rec.header_id);
        l_header_created := TRUE;
    END IF;

    --  Validate line attributes

    IF  p_x_line_rec.accounting_rule_id IS NOT NULL AND
        (   p_x_line_rec.accounting_rule_id <>
            p_old_line_rec.accounting_rule_id OR
            p_old_line_rec.accounting_rule_id IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.accounting_rule_id,
           OE_Order_Cache.g_header_rec.accounting_rule_id ))
        THEN
        IF l_debug_level > 0 then
        oe_debug_pub.add('Calling OE_VALIDATE for accounting_rule',1);
        END IF;
        IF NOT OE_Validate.Accounting_Rule(p_x_line_rec.accounting_rule_id) THEN
          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
             p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
                p_x_line_rec.accounting_rule_id := NULL;
          ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
             p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
                p_x_line_rec.accounting_rule_id := FND_API.G_MISS_NUM;
             ELSE
             x_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.accounting_rule_duration IS NOT NULL AND
        (   p_x_line_rec.accounting_rule_duration <>
            p_old_line_rec.accounting_rule_duration OR
            p_old_line_rec.accounting_rule_duration IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.accounting_rule_duration,
           OE_Order_Cache.g_header_rec.accounting_rule_duration ))
        THEN
        IF l_debug_level > 0 then
        oe_debug_pub.add('Calling OE_VALIDATE for accounting_rule_duration',1);
        END IF;
        IF NOT OE_Validate.Accounting_Rule_Duration(p_x_line_rec.accounting_rule_duration) THEN
          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
             p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
                p_x_line_rec.accounting_rule_duration := NULL;
          ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
             p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
                p_x_line_rec.accounting_rule_duration := FND_API.G_MISS_NUM;
          ELSE
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.agreement_id IS NOT NULL AND
        (   p_x_line_rec.agreement_id <>
            p_old_line_rec.agreement_id OR
            p_old_line_rec.agreement_id IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.agreement_id,
           OE_Order_Cache.g_header_rec.agreement_id ))
        THEN

        IF NOT OE_Validate.Agreement(p_x_line_rec.agreement_id) THEN
          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
             p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
           p_x_line_rec.agreement_id := NULL;
          ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
             p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
           p_x_line_rec.agreement_id := FND_API.G_MISS_NUM;
             ELSE
                   x_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
        END IF;

        END IF;
    END IF;


    IF  p_x_line_rec.deliver_to_contact_id IS NOT NULL AND
        (   p_x_line_rec.deliver_to_contact_id <>
            p_old_line_rec.deliver_to_contact_id OR
            p_old_line_rec.deliver_to_contact_id IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.deliver_to_contact_id,
           OE_Order_Cache.g_header_rec.deliver_to_contact_id ))
        THEN

        IF NOT OE_Validate.Deliver_To_Contact(p_x_line_rec.deliver_to_contact_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.deliver_to_contact_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE
         THEN
            p_x_line_rec.deliver_to_contact_id := FND_API.G_MISS_NUM;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.deliver_to_org_id IS NOT NULL AND
        (   p_x_line_rec.deliver_to_org_id <>
            p_old_line_rec.deliver_to_org_id OR
            p_old_line_rec.deliver_to_org_id IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.deliver_to_org_id,
           OE_Order_Cache.g_header_rec.deliver_to_org_id ))
        THEN

        IF NOT OE_Validate.Deliver_To_Org(p_x_line_rec.deliver_to_org_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.deliver_to_org_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE
         THEN
            p_x_line_rec.deliver_to_org_id := FND_API.G_MISS_NUM;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.demand_class_code IS NOT NULL AND
        (   p_x_line_rec.demand_class_code <>
            p_old_line_rec.demand_class_code OR
            p_old_line_rec.demand_class_code IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.demand_class_code,
           OE_Order_Cache.g_header_rec.demand_class_code ))
        THEN

        IF NOT OE_Validate.Demand_Class(p_x_line_rec.demand_class_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.demand_class_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.demand_class_code := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.dep_plan_required_flag IS NOT NULL AND
        (   p_x_line_rec.dep_plan_required_flag <>
            p_old_line_rec.dep_plan_required_flag OR
            p_old_line_rec.dep_plan_required_flag IS NULL )
    THEN
        IF NOT OE_Validate.Dep_Plan_Required(p_x_line_rec.dep_plan_required_flag) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.dep_plan_required_flag := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.dep_plan_required_flag := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.end_item_unit_number IS NOT NULL AND
        (   p_x_line_rec.end_item_unit_number <>
            p_old_line_rec.end_item_unit_number OR
            p_old_line_rec.end_item_unit_number IS NULL )
    THEN
      IF NOT OE_Validate.End_Item_Unit_Number(p_x_line_rec.end_item_unit_number) THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
           p_x_line_rec.end_item_unit_number := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
           p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
           p_x_line_rec.end_item_unit_number := FND_API.G_MISS_CHAR;
           ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
      END IF;
    END IF;

    IF  p_x_line_rec.fob_point_code IS NOT NULL AND
        (   p_x_line_rec.fob_point_code <>
            p_old_line_rec.fob_point_code OR
            p_old_line_rec.fob_point_code IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.fob_point_code,
           OE_Order_Cache.g_header_rec.fob_point_code ))
        THEN

        IF NOT OE_Validate.Fob_Point(p_x_line_rec.fob_point_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.fob_point_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.fob_point_code := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.freight_terms_code IS NOT NULL AND
        (   p_x_line_rec.freight_terms_code <>
            p_old_line_rec.freight_terms_code OR
            p_old_line_rec.freight_terms_code IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.freight_terms_code,
           OE_Order_Cache.g_header_rec.freight_terms_code ))
        THEN

        IF NOT OE_Validate.Freight_Terms(p_x_line_rec.freight_terms_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.freight_terms_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.freight_terms_code := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.invoice_to_contact_id IS NOT NULL AND
        (   p_x_line_rec.invoice_to_contact_id <>
            p_old_line_rec.invoice_to_contact_id OR
            p_old_line_rec.invoice_to_contact_id IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.invoice_to_contact_id,
           OE_Order_Cache.g_header_rec.invoice_to_contact_id ))
        THEN

        IF NOT OE_Validate.Invoice_To_Contact(p_x_line_rec.invoice_to_contact_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.invoice_to_contact_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.invoice_to_contact_id := FND_API.G_MISS_NUM;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.invoice_to_org_id IS NOT NULL AND
        (   p_x_line_rec.invoice_to_org_id <>
            p_old_line_rec.invoice_to_org_id OR
            p_old_line_rec.invoice_to_org_id IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.invoice_to_org_id,
           OE_Order_Cache.g_header_rec.invoice_to_org_id ))
        THEN

        IF NOT OE_Validate.Invoice_To_Org(p_x_line_rec.invoice_to_org_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.invoice_to_org_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.invoice_to_org_id := FND_API.G_MISS_NUM;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.invoicing_rule_id IS NOT NULL AND
        (   p_x_line_rec.invoicing_rule_id <>
            p_old_line_rec.invoicing_rule_id OR
            p_old_line_rec.invoicing_rule_id IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.invoicing_rule_id,
           OE_Order_Cache.g_header_rec.invoicing_rule_id ))
        THEN

        IF NOT OE_Validate.Invoicing_Rule(p_x_line_rec.invoicing_rule_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.invoicing_rule_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.invoicing_rule_id := FND_API.G_MISS_NUM;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.item_type_code IS NOT NULL AND
        (   p_x_line_rec.item_type_code <>
            p_old_line_rec.item_type_code OR
            p_old_line_rec.item_type_code IS NULL )
    THEN
        IF NOT OE_Validate.Item_Type(p_x_line_rec.item_type_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.item_type_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.item_type_code := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
    END IF;

  --Added for bug 3575484
    IF p_x_line_rec.line_type_id IS NOT NULL AND
        ( p_x_line_rec.line_type_id <>
          p_old_line_rec.line_type_id OR
          p_old_line_rec.line_type_id IS NULL )
    THEN
        IF NOT OE_Validate.Line_Type(p_x_line_rec.line_type_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.line_type_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.line_type_id := FND_API.G_MISS_NUM;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
        END IF;
    END IF;
    --End of bug 3575484

    IF  p_x_line_rec.ordered_quantity IS NOT NULL AND
        (   p_x_line_rec.ordered_quantity <>
            p_old_line_rec.ordered_quantity OR
            p_old_line_rec.ordered_quantity IS NULL )
    THEN
        IF NOT OE_Validate.ordered_quantity(p_x_line_rec.ordered_quantity) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.ordered_quantity := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.ordered_quantity := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
    END IF;


    IF  p_x_line_rec.payment_term_id IS NOT NULL AND
        (   p_x_line_rec.payment_term_id <>
            p_old_line_rec.payment_term_id OR
            p_old_line_rec.payment_term_id IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.payment_term_id,
           OE_Order_Cache.g_header_rec.payment_term_id ))
        THEN

        IF NOT OE_Validate.Payment_Term(p_x_line_rec.payment_term_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.payment_term_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.payment_term_id := FND_API.G_MISS_NUM;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
        END IF;

        END IF;
    END IF;

     -- Changes for Late Demand Penalty Factor
        IF l_debug_level > 0 then
        OE_DEBUG_PUB.Add('Checking late_demand penalty factor');
        END IF;

    IF  p_x_line_rec.late_demand_penalty_factor IS NOT NULL AND
        (   p_x_line_rec.late_demand_penalty_factor <>
                    p_old_line_rec.late_demand_penalty_factor OR
                        p_old_line_rec.late_demand_penalty_factor IS NULL)
    THEN

         IF NOT OE_Validate.Late_Demand_Penalty_Factor
              (p_x_line_rec.late_demand_penalty_factor) THEN

             IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
                p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN

                p_x_line_rec.late_demand_penalty_factor := NULL;

             ELSE

                l_return_status := FND_API.G_RET_STS_ERROR;

             END IF;

       END IF;

    END IF;

    IF  p_x_line_rec.price_list_id IS NOT NULL AND
        (   p_x_line_rec.price_list_id <>
            p_old_line_rec.price_list_id OR
            p_old_line_rec.price_list_id IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.price_list_id,
           OE_Order_Cache.g_header_rec.price_list_id ))
        THEN

        IF NOT OE_Validate.Price_List(p_x_line_rec.price_list_id) THEN
         --No partial level validation if this is a mandatory field.
         --IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
         --   p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
         --   p_x_line_rec.price_list_id := NULL;
         IF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN

            -- bug 3572931 added the calculate price flag check
            -- because freeze price line shouldn't get a new price list
            IF nvl(p_x_line_rec.calculate_price_flag, 'Y') = 'Y' THEN
              p_x_line_rec.price_list_id := FND_API.G_MISS_NUM;
            END IF;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.project_id IS NOT NULL AND
        (   p_x_line_rec.project_id <>
            p_old_line_rec.project_id OR
            p_old_line_rec.project_id IS NULL )
    THEN
        IF NOT OE_Validate.Project(p_x_line_rec.project_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.project_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.project_id := FND_API.G_MISS_NUM;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
    END IF;
    IF l_debug_level > 0 then
    oe_debug_pub.add('Checking for Ship Dates....',1);
    END IF;
    -- If the order date type is does not match the change, error out.
    IF Nvl(p_x_line_rec.source_type_code,OE_GLOBALS.G_SOURCE_INTERNAL) =
        OE_GLOBALS.G_SOURCE_INTERNAL THEN
    IF NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_ship_date,
                            p_old_line_rec.schedule_ship_date) AND
        p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
    THEN
        l_type_code    := Get_Date_Type(p_x_line_rec.header_id);
        -- If Date type is Arrival, then the user is not allowed
        -- to change the schedule ship date.

        IF l_type_code = 'ARRIVAL' THEN

           FND_MESSAGE.SET_NAME('ONT','OE_SCH_INV_SHP_DATE');
           OE_MSG_PUB.Add;

           l_return_status := FND_API.G_RET_STS_ERROR;

        END IF;
    END IF;
    IF l_debug_level > 0 then
    oe_debug_pub.add('Checking for Arival Dates....',1);
    END IF;

    -- If the order date type is does not match the change, error out.
    IF NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_arrival_date,
                            p_old_line_rec.schedule_arrival_date) AND
        p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
    THEN
        l_type_code    := Get_Date_Type(p_x_line_rec.header_id);
        -- If Date type is Ship, then the user is not allowed
        -- to change the schedule arrival date.

        IF nvl(l_type_code,'SHIP') = 'SHIP' THEN

           FND_MESSAGE.SET_NAME('ONT','OE_SCH_INV_ARR_DATE');
           OE_MSG_PUB.Add;

           l_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

    END IF;
    END IF;
    IF  p_x_line_rec.shipment_priority_code IS NOT NULL AND
        (   p_x_line_rec.shipment_priority_code <>
            p_old_line_rec.shipment_priority_code OR
            p_old_line_rec.shipment_priority_code IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.shipment_priority_code,
           OE_Order_Cache.g_header_rec.shipment_priority_code ))
        THEN

        IF NOT OE_Validate.Shipment_Priority(p_x_line_rec.shipment_priority_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.shipment_priority_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.shipment_priority_code := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.shipping_method_code IS NOT NULL AND
        (   p_x_line_rec.shipping_method_code <>
            p_old_line_rec.shipping_method_code OR
            p_old_line_rec.shipping_method_code IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.shipping_method_code,
           OE_Order_Cache.g_header_rec.shipping_method_code ))
        THEN

        IF NOT OE_Validate.Shipping_Method(p_x_line_rec.shipping_method_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.shipping_method_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.shipping_method_code := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.ship_from_org_id IS NOT NULL AND
        (   p_x_line_rec.ship_from_org_id <>
            p_old_line_rec.ship_from_org_id OR
            p_old_line_rec.ship_from_org_id IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.ship_from_org_id,
           OE_Order_Cache.g_header_rec.ship_from_org_id ))
        THEN

        IF NOT OE_Validate.Ship_From_Org(p_x_line_rec.ship_from_org_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.ship_from_org_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.ship_from_org_id := FND_API.G_MISS_NUM;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.shipping_interfaced_flag IS NOT NULL AND
        (   p_x_line_rec.shipping_interfaced_flag <>
            p_old_line_rec.shipping_interfaced_flag OR
            p_old_line_rec.shipping_interfaced_flag IS NULL )
    THEN
        IF NOT OE_Validate.Shipping_Interfaced(p_x_line_rec.shipping_interfaced_flag) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.shipping_interfaced_flag := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.shipping_interfaced_flag := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.shippable_flag IS NOT NULL AND
        (   p_x_line_rec.shippable_flag <>
            p_old_line_rec.shippable_flag OR
            p_old_line_rec.shippable_flag IS NULL )
    THEN
        IF NOT OE_Validate.shippable(p_x_line_rec.shippable_flag) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.shippable_flag := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.shippable_flag := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.ship_to_contact_id IS NOT NULL AND
        (   p_x_line_rec.ship_to_contact_id <>
            p_old_line_rec.ship_to_contact_id OR
            p_old_line_rec.ship_to_contact_id IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.ship_to_contact_id,
           OE_Order_Cache.g_header_rec.ship_to_contact_id ))
        THEN

        IF NOT OE_Validate.Ship_To_Contact(p_x_line_rec.ship_to_contact_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.ship_to_contact_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.ship_to_contact_id := FND_API.G_MISS_NUM;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.ship_to_org_id IS NOT NULL AND
        (   p_x_line_rec.ship_to_org_id <>
            p_old_line_rec.ship_to_org_id OR
            p_old_line_rec.ship_to_org_id IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.ship_to_org_id,
           OE_Order_Cache.g_header_rec.ship_to_org_id ))
        THEN

        IF NOT OE_Validate.Ship_To_Org(p_x_line_rec.ship_to_org_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.ship_to_org_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.ship_to_org_id := FND_API.G_MISS_NUM;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.sold_to_org_id IS NOT NULL AND
        (   p_x_line_rec.sold_to_org_id <>
            p_old_line_rec.sold_to_org_id OR
            p_old_line_rec.sold_to_org_id IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.sold_to_org_id,
           OE_Order_Cache.g_header_rec.sold_to_org_id ))
        THEN

        IF NOT OE_Validate.Sold_To_Org(p_x_line_rec.sold_to_org_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.sold_to_org_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.sold_to_org_id := FND_API.G_MISS_NUM;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.source_type_code IS NOT NULL AND
        (   p_x_line_rec.source_type_code <>
            p_old_line_rec.source_type_code OR
            p_old_line_rec.source_type_code IS NULL )
    THEN
        IF NOT OE_Validate.Source_Type(p_x_line_rec.source_type_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.source_type_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.source_type_code := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.tax_exempt_flag IS NOT NULL AND
        (   p_x_line_rec.tax_exempt_flag <>
            p_old_line_rec.tax_exempt_flag OR
            p_old_line_rec.tax_exempt_flag IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.tax_exempt_flag,
           OE_Order_Cache.g_header_rec.tax_exempt_flag ))
        THEN

        IF NOT OE_Validate.Tax_Exempt(p_x_line_rec.tax_exempt_flag) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.tax_exempt_flag := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.tax_exempt_flag := FND_API.G_MISS_CHAR;
           ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.tax_exempt_reason_code IS NOT NULL AND
        (   p_x_line_rec.tax_exempt_reason_code <>
            p_old_line_rec.tax_exempt_reason_code OR
            p_old_line_rec.tax_exempt_reason_code IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.tax_exempt_reason_code,
           OE_Order_Cache.g_header_rec.tax_exempt_reason_code ))
        THEN

        IF NOT OE_Validate.Tax_Exempt_Reason(p_x_line_rec.tax_exempt_reason_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.tax_exempt_reason_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.tax_exempt_reason_code := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.tax_point_code IS NOT NULL AND
        (   p_x_line_rec.tax_point_code <>
            p_old_line_rec.tax_point_code OR
            p_old_line_rec.tax_point_code IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.tax_point_code,
           OE_Order_Cache.g_header_rec.tax_point_code ))
        THEN

        IF NOT OE_Validate.Tax_Point(p_x_line_rec.tax_point_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.tax_point_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.tax_point_code := FND_API.G_MISS_CHAR;
             ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.fulfilled_flag IS NOT NULL AND
        (   p_x_line_rec.fulfilled_flag <>
            p_old_line_rec.fulfilled_flag OR
            p_old_line_rec.fulfilled_flag IS NULL )
    THEN
        IF NOT OE_Validate.fulfilled(p_x_line_rec.fulfilled_flag) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.fulfilled_flag := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.fulfilled_flag := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.flow_status_code IS NOT NULL AND
        (   p_x_line_rec.flow_status_code <>
            p_old_line_rec.flow_status_code OR
            p_old_line_rec.flow_status_code IS NULL )
    THEN
        IF NOT OE_Validate.Line_Flow_Status(p_x_line_rec.flow_status_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.flow_status_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.flow_status_code := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
    END IF;

    --  Flex Validation code has been moved to Procedure Validate_Flex, bug 2511313
   if OE_GLOBALS.g_validate_desc_flex ='Y' then --4343612
    Validate_Flex( p_x_line_rec        => p_x_line_rec,
                   p_old_line_rec      => p_old_line_rec,
                   p_validation_level  => p_validation_level,
                   x_return_status     => l_ret_sts_dff -- bug8302126
                   );
   end if;
   -- Done with flex Validation

    -- bug8302126
    IF l_ret_sts_dff = FND_API.G_RET_STS_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
   -- bug 8302126

    IF  p_x_line_rec.salesrep_id IS NOT NULL AND
        (   p_x_line_rec.salesrep_id <>
            p_old_line_rec.salesrep_id OR
            p_old_line_rec.salesrep_id IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.salesrep_id,
           OE_Order_Cache.g_header_rec.salesrep_id ))
        THEN

        IF NOT OE_Validate.salesrep(p_x_line_rec.salesrep_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.salesrep_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.salesrep_id := FND_API.G_MISS_NUM;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;
    END IF;

    IF  p_x_line_rec.return_reason_code IS NOT NULL AND
        (   p_x_line_rec.return_reason_code <>
            p_old_line_rec.return_reason_code OR
            p_old_line_rec.return_reason_code IS NULL )
    THEN
        IF NOT OE_Validate.return_reason(p_x_line_rec.return_reason_code) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.return_reason_code := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.return_reason_code := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
    END IF;

   -- Validate Commitment
   IF  (p_x_line_rec.commitment_id IS NOT NULL)
   AND (p_x_line_rec.commitment_id <> p_old_line_rec.commitment_id
   OR  p_old_line_rec.commitment_id IS NULL) THEN
      IF NOT oe_validate.commitment(p_x_line_rec.commitment_id) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
   END IF;

    IF  p_x_line_rec.user_item_description IS NOT NULL AND
        (   p_x_line_rec.user_item_description <>
            p_old_line_rec.user_item_description OR
            p_old_line_rec.user_item_description IS NULL )
    THEN
        IF NOT OE_Validate.User_Item_Description(p_x_line_rec.user_item_description) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.user_item_description := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.user_item_description := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;
    END IF;
   IF l_debug_level > 0 then
   oe_debug_pub.ADD('item_relationship_type :'||p_x_line_rec.item_relationship_type,1);
   END IF;
   IF  p_x_line_rec.item_relationship_type IS NOT NULL AND
        (   p_x_line_rec.item_relationship_type <>
            p_old_line_rec.item_relationship_type OR
            p_old_line_rec.item_relationship_type IS NULL )
    THEN
        IF NOT OE_Validate.item_relationship_type(p_x_line_rec.item_relationship_type) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.item_relationship_type := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.item_relationship_type := FND_API.G_MISS_NUM;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
        END IF;
    END IF;

    IF  p_x_line_rec.Minisite_Id IS NOT NULL AND
        (   p_x_line_rec.Minisite_id <>
            p_old_line_rec.Minisite_id OR
            p_old_line_rec.Minisite_id IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.minisite_id,
           OE_Order_Cache.g_header_rec.minisite_id ))

        THEN

        IF NOT OE_Validate.Minisite(p_x_line_rec.Minisite_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.Minisite_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.Minisite_id := FND_API.G_MISS_NUM;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;

     END IF;

    -- distributed orders @

    IF  p_x_line_rec.Ib_owner IS NOT NULL AND
        (   p_x_line_rec.Ib_owner <>
            p_old_line_rec.Ib_owner OR
            p_old_line_rec.Ib_owner IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.Ib_owner,
           OE_Order_Cache.g_header_rec.Ib_owner ))

        THEN

        IF NOT OE_Validate.IB_OWNER(p_x_line_rec.Ib_owner) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.Ib_owner := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.Ib_Owner := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;

     END IF;

    IF  p_x_line_rec.Ib_installed_at_location IS NOT NULL AND
        (   p_x_line_rec.Ib_installed_at_location <>
            p_old_line_rec.Ib_installed_at_location OR
            p_old_line_rec.Ib_installed_at_location IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.Ib_installed_at_location,
           OE_Order_Cache.g_header_rec.Ib_installed_at_location ))

        THEN

        IF NOT OE_Validate.IB_INSTALLED_AT_LOCATION(p_x_line_rec.Ib_installed_at_location) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.Ib_installed_at_location := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.Ib_installed_at_location := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;

     END IF;

    IF  p_x_line_rec.Ib_current_location IS NOT NULL AND
        (   p_x_line_rec.Ib_current_location <>
            p_old_line_rec.Ib_current_location OR
            p_old_line_rec.Ib_current_location IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.Ib_current_location,
           OE_Order_Cache.g_header_rec.Ib_current_location ))

        THEN

       IF NOT OE_Validate.IB_CURRENT_LOCATION(p_x_line_rec.ib_current_location) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.Ib_current_location := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.Ib_current_location := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;

     END IF;

    IF  p_x_line_rec.End_customer_id IS NOT NULL AND
        (   p_x_line_rec.End_customer_id <>
            p_old_line_rec.End_customer_id OR
            p_old_line_rec.End_customer_id IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.End_customer_id,
           OE_Order_Cache.g_header_rec.End_customer_id ))

        THEN

       IF NOT OE_Validate.END_CUSTOMER(p_x_line_rec.End_customer_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.End_customer_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.End_customer_id := FND_API.G_MISS_NUM;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;

     END IF;

    IF  p_x_line_rec.End_customer_contact_id IS NOT NULL AND
        (   p_x_line_rec.End_customer_contact_id <>
            p_old_line_rec.End_customer_contact_id OR
            p_old_line_rec.End_customer_contact_id IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.End_customer_contact_id,
           OE_Order_Cache.g_header_rec.End_customer_contact_id ))

        THEN

       IF NOT OE_Validate.END_CUSTOMER_CONTACT(p_x_line_rec.End_customer_contact_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.End_customer_contact_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.End_customer_contact_id := FND_API.G_MISS_NUM;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;

     END IF;

    IF  p_x_line_rec.End_customer_site_use_id IS NOT NULL AND
        (   p_x_line_rec.End_customer_site_use_id <>
            p_old_line_rec.End_customer_site_use_id OR
            p_old_line_rec.End_customer_site_use_id IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.End_customer_site_use_id,
           OE_Order_Cache.g_header_rec.End_customer_site_use_id ))

        THEN

       IF NOT OE_Validate.END_CUSTOMER_SITE_USE(p_x_line_rec.End_customer_site_use_id) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.End_customer_site_use_id := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.End_customer_site_use_id := FND_API.G_MISS_NUM;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;

     END IF;


-- OPM bug 3457463

    if l_debug_level > 0 then
      oe_debug_pub.ADD('preferred_grade:'||p_x_line_rec.preferred_grade,1);
    end if;


     IF  p_x_line_rec.preferred_grade IS NOT NULL AND
        (   p_x_line_rec.preferred_grade <>
            p_old_line_rec.preferred_grade OR
            p_old_line_rec.preferred_grade IS NULL )
     THEN
        IF NOT OE_Validate.preferred_grade(p_x_line_rec.preferred_grade) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.preferred_grade := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.preferred_grade := FND_API.G_MISS_CHAR;
        ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
        END IF;
     END IF;
  --Customer Acceptance
     IF p_old_line_rec.accepted_quantity IS NOT NULL AND
          p_old_line_rec.accepted_quantity <> FND_API.G_MISS_NUM AND
          p_old_line_rec.accepted_quantity <> p_x_line_rec.accepted_quantity
     THEN
          p_x_line_rec.accepted_quantity := p_old_line_rec.accepted_quantity;
          FND_MESSAGE.SET_NAME('ONT','ONT_CANNOT_UPDATE_ACCEPTANCE');
          OE_MSG_PUB.Add;
     END IF;

     IF p_old_line_rec.REVREC_SIGNATURE_DATE IS NOT NULL AND
          p_old_line_rec.REVREC_SIGNATURE_DATE <> FND_API.G_MISS_DATE AND
          p_old_line_rec.REVREC_SIGNATURE_DATE <> p_x_line_rec.REVREC_SIGNATURE_DATE
     THEN
          p_x_line_rec.REVREC_SIGNATURE_DATE := p_old_line_rec.REVREC_SIGNATURE_DATE;
          FND_MESSAGE.SET_NAME('ONT','ONT_CANNOT_UPDATE_ACCEPTANCE');
          OE_MSG_PUB.Add;
     END IF;

     IF p_old_line_rec.accepted_by IS NOT NULL AND
          p_old_line_rec.accepted_by <> FND_API.G_MISS_NUM AND
          p_old_line_rec.accepted_by <> p_x_line_rec.accepted_by
     THEN
          p_x_line_rec.accepted_by := p_old_line_rec.accepted_by;
          FND_MESSAGE.SET_NAME('ONT','ONT_CANNOT_UPDATE_ACCEPTANCE');
          OE_MSG_PUB.Add;
     END IF;
     --

    IF l_debug_level > 0 then
    oe_debug_pub.add('Exiting procedure OE_validate_line.Attributes',1);
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;

 /* IF  p_x_line_rec.supplier_signature IS NOT NULL AND
        (   p_x_line_rec.supplier_signature <>
            p_old_line_rec.supplier_signature OR
            p_old_line_rec.supplier_signature IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.supplier_signature,
           OE_Order_Cache.g_header_rec.supplier_signature ))

        THEN

        IF NOT OE_Validate.SUPPLIER_SIGNATURE(p_x_line_rec.supplier_signature) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.supplier_signature := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.supplier_signature := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;

     END IF;

  IF  p_x_line_rec.supplier_signature_date IS NOT NULL AND
        (   p_x_line_rec.supplier_signature_date <>
            p_old_line_rec.supplier_signature_date OR
            p_old_line_rec.supplier_signature_date IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.supplier_signature_date,
           OE_Order_Cache.g_header_rec.supplier_signature_date ))

        THEN

        IF NOT OE_Validate.SUPPLIER_SIGNATURE_DATE(p_x_line_rec.supplier_signature_date) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.supplier_signature_date := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.supplier_signature_date := FND_API.G_MISS_DATE;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;

     END IF;

  IF  p_x_line_rec.customer_signature IS NOT NULL AND
        (   p_x_line_rec.customer_signature <>
            p_old_line_rec.customer_signature OR
            p_old_line_rec.customer_signature IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.customer_signature,
           OE_Order_Cache.g_header_rec.customer_signature ))

        THEN

        IF NOT OE_Validate.CUSTOMER_SIGNATURE(p_x_line_rec.customer_signature) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.customer_signature := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.customer_signature := FND_API.G_MISS_CHAR;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;

     END IF;

  IF  p_x_line_rec.customer_signature_date IS NOT NULL AND
        (   p_x_line_rec.customer_signature_date <>
            p_old_line_rec.customer_signature_date OR
            p_old_line_rec.customer_signature_date IS NULL )
    THEN
        IF NOT(l_header_created) OR
          (l_header_created AND
           NOT OE_GLOBALS.EQUAL(p_x_line_rec.customer_signature_date,
           OE_Order_Cache.g_header_rec.customer_signature_date ))

        THEN

        IF NOT OE_Validate.CUSTOMER_SIGNATURE_DATE(p_x_line_rec.customer_signature_date) THEN
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.customer_signature_date := NULL;
         ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
            p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
            p_x_line_rec.customer_signature_date := FND_API.G_MISS_DATE;
            ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        END IF;

     END IF;

*/

END Attributes;


------------------------------------------------------------------
-- Procedure Validate_Flex : for bug 2511313
--    The flex validations have been moved from the procedure Attributes
--    to this new procedure. The call to this procedure not only validates
--    the flex values on the line record passed to it but also defaults
--    the segments which can be defaulted.
--
--    This procedure is also called from OE_CONFIG_UTIL.Default_Child_Line
--    procedure with the validation level set to NONE to default the flex segments.
---------------------------------------------------------------------


PROCEDURE Validate_Flex
(   p_x_line_rec         IN OUT NOCOPY OE_ORDER_PUB.Line_Rec_Type,
    p_old_line_rec       IN            OE_ORDER_PUB.line_rec_type :=
                                         OE_Order_PUB.G_MISS_LINE_REC,
    p_validation_level   IN            NUMBER,
    x_return_status      OUT NOCOPY    VARCHAR2
)
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--Start of bug#7380336
 l_context_required_flag fnd_descriptive_flexs_vl.context_required_flag%TYPE;
 l_default_context_field_name fnd_descriptive_flexs_vl.default_context_field_name%TYPE;
 l_validate_line VARCHAR2(1) := 'Y';
    CURSOR c_check_context(l_flex_name fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE) IS
     SELECT context_required_flag, default_context_field_name
     FROM FND_DESCRIPTIVE_FLEXS_VL
     WHERE (application_id = 660)
     AND (descriptive_flexfield_name = l_flex_name); --End of bug#7380336

BEGIN
if OE_GLOBALS.g_validate_desc_flex ='Y' then --4230230
      IF l_debug_level > 0 then
      oe_debug_pub.add('Entering Oe_Validate_Line.Validate_Flex with status: '||x_return_status,2);
      END IF;

--            Bug 2333071 : Excluding Flexfield validation for CONFIG line
--            Fixing 2375476 to skip the Flex field validation in case of
--            Internal Orders. This condition will be removed once process Order
--            starts defaulting the FF
--            The AND condition added for 2611912, to exclude validation in
--            case of order lines coming from CRM. It can be removed once
--            Process Order starts defaulting the FF

--   IF (p_x_line_rec.item_type_code  <> OE_GLOBALS.G_ITEM_CONFIG  AND
--       p_x_line_rec.order_source_id <> 10 AND -- added for 2611912
--       (p_x_line_rec.source_document_type_id IS NULL OR
--        p_x_line_rec.source_document_type_id = FND_API.G_MISS_NUM OR
--        p_x_line_rec.source_document_type_id = 2)) THEN

--Start of bug#7380336
 	 OPEN c_check_context('OE_LINE_ATTRIBUTES');
 	 FETCH c_check_context INTO l_context_required_flag,l_default_context_field_name;
 	 CLOSE c_check_context;

 	 -- Skip the Validation if not changes are made in the DFF from the UI.
 	 IF l_context_required_flag = 'Y' AND ( p_x_line_rec.context IS NULL OR p_x_line_rec.context = FND_API.G_MISS_CHAR ) AND (OE_GLOBALS.G_UI_FLAG) THEN
 	   l_validate_line := 'N';
 	   IF l_debug_level > 0 then
 	     oe_debug_pub.add('Skipping Validation');
 	   END IF;

 	 ELSIF l_context_required_flag = 'Y' AND ( p_x_line_rec.context IS NULL OR p_x_line_rec.context = FND_API.G_MISS_CHAR ) AND NOT (OE_GLOBALS.G_UI_FLAG) THEN
 	         -- Show Error message if appropriate context value is not passed
         	 -- from the Process Order Call and if the Context field is required.
 	         IF l_debug_level  > 0 THEN
 	             oe_debug_pub.add(  'before call to desc_flex Context not set for OE_LINE_ATTRIBUTES DFF ' ) ;
 	         END IF;

 	  ELSE
 	      -- Validate the DFF in all other cases.
 	      l_validate_line := 'Y';
 	      IF l_debug_level > 0 then
 	         oe_debug_pub.add('Validating the Flex Field');
 	      END IF;
 	  END IF;   --End of bug#7380336

  IF(l_validate_line = 'Y') THEN   --Bug#7380336

    IF p_x_line_rec.operation = oe_globals.g_opr_create OR
        (p_x_line_rec.operation = oe_globals.g_opr_update  AND
          (p_x_line_rec.attribute1 IS NOT NULL AND
        (   p_x_line_rec.attribute1 <>
            p_old_line_rec.attribute1 OR
            p_old_line_rec.attribute1 IS NULL ))
    OR  (p_x_line_rec.attribute10 IS NOT NULL AND
        (   p_x_line_rec.attribute10 <>
            p_old_line_rec.attribute10 OR
            p_old_line_rec.attribute10 IS NULL ))
    OR  (p_x_line_rec.attribute11 IS NOT NULL AND
        (   p_x_line_rec.attribute11 <>
            p_old_line_rec.attribute11 OR
            p_old_line_rec.attribute11 IS NULL ))
    OR  (p_x_line_rec.attribute12 IS NOT NULL AND
        (   p_x_line_rec.attribute12 <>
            p_old_line_rec.attribute12 OR
            p_old_line_rec.attribute12 IS NULL ))
    OR  (p_x_line_rec.attribute13 IS NOT NULL AND
        (   p_x_line_rec.attribute13 <>
            p_old_line_rec.attribute13 OR
            p_old_line_rec.attribute13 IS NULL ))
    OR  (p_x_line_rec.attribute14 IS NOT NULL AND
        (   p_x_line_rec.attribute14 <>
            p_old_line_rec.attribute14 OR
            p_old_line_rec.attribute14 IS NULL ))
    OR  (p_x_line_rec.attribute15 IS NOT NULL AND
        (   p_x_line_rec.attribute15 <>
            p_old_line_rec.attribute15 OR
            p_old_line_rec.attribute15 IS NULL ))
    OR  (p_x_line_rec.attribute16 IS NOT NULL AND -- For bug 2184255
        (   p_x_line_rec.attribute16 <>
            p_old_line_rec.attribute16 OR
            p_old_line_rec.attribute16 IS NULL ))
    OR  (p_x_line_rec.attribute17 IS NOT NULL AND
        (   p_x_line_rec.attribute17 <>
            p_old_line_rec.attribute17 OR
            p_old_line_rec.attribute17 IS NULL ))
    OR  (p_x_line_rec.attribute18 IS NOT NULL AND
        (   p_x_line_rec.attribute18 <>
            p_old_line_rec.attribute18 OR
            p_old_line_rec.attribute18 IS NULL ))
    OR  (p_x_line_rec.attribute19 IS NOT NULL AND
        (   p_x_line_rec.attribute19 <>
            p_old_line_rec.attribute19 OR
            p_old_line_rec.attribute19 IS NULL ))
    OR  (p_x_line_rec.attribute2 IS NOT NULL AND
        (   p_x_line_rec.attribute2 <>
            p_old_line_rec.attribute2 OR
            p_old_line_rec.attribute2 IS NULL ))
    OR  (p_x_line_rec.attribute20 IS NOT NULL AND
        (   p_x_line_rec.attribute20 <>
            p_old_line_rec.attribute20 OR
            p_old_line_rec.attribute20 IS NULL ))
    OR  (p_x_line_rec.attribute3 IS NOT NULL AND
        (   p_x_line_rec.attribute3 <>
            p_old_line_rec.attribute3 OR
            p_old_line_rec.attribute3 IS NULL ))
    OR  (p_x_line_rec.attribute4 IS NOT NULL AND
        (   p_x_line_rec.attribute4 <>
            p_old_line_rec.attribute4 OR
            p_old_line_rec.attribute4 IS NULL ))
    OR  (p_x_line_rec.attribute5 IS NOT NULL AND
        (   p_x_line_rec.attribute5 <>
            p_old_line_rec.attribute5 OR
            p_old_line_rec.attribute5 IS NULL ))
    OR  (p_x_line_rec.attribute6 IS NOT NULL AND
        (   p_x_line_rec.attribute6 <>
            p_old_line_rec.attribute6 OR
            p_old_line_rec.attribute6 IS NULL ))
    OR  (p_x_line_rec.attribute7 IS NOT NULL AND
        (   p_x_line_rec.attribute7 <>
            p_old_line_rec.attribute7 OR
            p_old_line_rec.attribute7 IS NULL ))
    OR  (p_x_line_rec.attribute8 IS NOT NULL AND
        (   p_x_line_rec.attribute8 <>
            p_old_line_rec.attribute8 OR
            p_old_line_rec.attribute8 IS NULL ))
    OR  (p_x_line_rec.attribute9 IS NOT NULL AND
        (   p_x_line_rec.attribute9 <>
            p_old_line_rec.attribute9 OR
            p_old_line_rec.attribute9 IS NULL ))
    OR  (p_x_line_rec.context IS NOT NULL AND
        (   p_x_line_rec.context <>
            p_old_line_rec.context OR
            p_old_line_rec.context IS NULL )))
    THEN
       IF l_debug_level > 0 then
       oe_debug_pub.add('Before calling line_desc_flex',2);
       END IF;
       IF Oe_Order_Cache.IS_FLEX_ENABLED('OE_LINE_ATTRIBUTES') = 'Y'  THEN

          IF NOT OE_VALIDATE.Line_Desc_Flex
            (p_context            => p_x_line_rec.context
             ,p_attribute1         => p_x_line_rec.attribute1
             ,p_attribute2         => p_x_line_rec.attribute2
             ,p_attribute3         => p_x_line_rec.attribute3
             ,p_attribute4         => p_x_line_rec.attribute4
             ,p_attribute5         => p_x_line_rec.attribute5
             ,p_attribute6         => p_x_line_rec.attribute6
             ,p_attribute7         => p_x_line_rec.attribute7
             ,p_attribute8         => p_x_line_rec.attribute8
             ,p_attribute9         => p_x_line_rec.attribute9
             ,p_attribute10        => p_x_line_rec.attribute10
             ,p_attribute11        => p_x_line_rec.attribute11
             ,p_attribute12        => p_x_line_rec.attribute12
             ,p_attribute13        => p_x_line_rec.attribute13
             ,p_attribute14        => p_x_line_rec.attribute14
             ,p_attribute15        => p_x_line_rec.attribute15
             ,p_attribute16        => p_x_line_rec.attribute16  -- for bug 2184255
             ,p_attribute17        => p_x_line_rec.attribute17
             ,p_attribute18        => p_x_line_rec.attribute18
             ,p_attribute19        => p_x_line_rec.attribute19
             ,p_attribute20        => p_x_line_rec.attribute20) THEN

             IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
               p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE   THEN

                p_x_line_rec.context    := null;
                p_x_line_rec.attribute1 := null;
                p_x_line_rec.attribute2 := null;
                p_x_line_rec.attribute3 := null;
                p_x_line_rec.attribute4 := null;
                p_x_line_rec.attribute5 := null;
                p_x_line_rec.attribute6 := null;
                p_x_line_rec.attribute7 := null;
                p_x_line_rec.attribute8 := null;
                p_x_line_rec.attribute9 := null;
                p_x_line_rec.attribute10 := null;
                p_x_line_rec.attribute11 := null;
                p_x_line_rec.attribute12 := null;
                p_x_line_rec.attribute13 := null;
                p_x_line_rec.attribute14 := null;
                p_x_line_rec.attribute15 := null;
                p_x_line_rec.attribute16 := null;  -- for bug 2184255
                p_x_line_rec.attribute17 := null;
                p_x_line_rec.attribute18 := null;
                p_x_line_rec.attribute19 := null;
                p_x_line_rec.attribute20 := null;

           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
             p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN

                p_x_line_rec.context    := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute1 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute2 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute3 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute4 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute5 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute6 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute7 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute8 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute9 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute10 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute11 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute12 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute13 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute14 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute15 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute16 := FND_API.G_MISS_CHAR;  -- for bug 2184255
                p_x_line_rec.attribute17 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute18 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute19 := FND_API.G_MISS_CHAR;
                p_x_line_rec.attribute20 := FND_API.G_MISS_CHAR;

           ELSIF p_validation_level = FND_API.G_VALID_LEVEL_NONE THEN
                NULL;

          ELSE
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

        ELSE -- if the flex validation is successfull
            -- For bug 2511313
            IF p_x_line_rec.context IS NULL
              OR p_x_line_rec.context = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.context    := oe_validate.g_context;
            END IF;

            IF p_x_line_rec.attribute1 IS NULL
              OR p_x_line_rec.attribute1 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute1 := oe_validate.g_attribute1;
            END IF;

            IF p_x_line_rec.attribute2 IS NULL
              OR p_x_line_rec.attribute2 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute2 := oe_validate.g_attribute2;
            END IF;

            IF p_x_line_rec.attribute3 IS NULL
              OR p_x_line_rec.attribute3 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute3 := oe_validate.g_attribute3;
            END IF;

            IF p_x_line_rec.attribute4 IS NULL
              OR p_x_line_rec.attribute4 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute4 := oe_validate.g_attribute4;
            END IF;

            IF p_x_line_rec.attribute5 IS NULL
              OR p_x_line_rec.attribute5 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute5 := oe_validate.g_attribute5;
            END IF;

            IF p_x_line_rec.attribute6 IS NULL
              OR p_x_line_rec.attribute6 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute6 := oe_validate.g_attribute6;
            END IF;

            IF p_x_line_rec.attribute7 IS NULL
              OR p_x_line_rec.attribute7 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute7 := oe_validate.g_attribute7;
            END IF;

            IF p_x_line_rec.attribute8 IS NULL
              OR p_x_line_rec.attribute8 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute8 := oe_validate.g_attribute8;
            END IF;

            IF p_x_line_rec.attribute9 IS NULL
              OR p_x_line_rec.attribute9 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute9 := oe_validate.g_attribute9;
            END IF;

            IF p_x_line_rec.attribute10 IS NULL
              OR p_x_line_rec.attribute10 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute10 := Oe_validate.G_attribute10;
            End IF;

            IF p_x_line_rec.attribute11 IS NULL
              OR p_x_line_rec.attribute11 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute11 := oe_validate.g_attribute11;
            END IF;

            IF p_x_line_rec.attribute12 IS NULL
              OR p_x_line_rec.attribute12 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute12 := oe_validate.g_attribute12;
            END IF;

            IF p_x_line_rec.attribute13 IS NULL
              OR p_x_line_rec.attribute13 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute13 := oe_validate.g_attribute13;
            END IF;

            IF p_x_line_rec.attribute14 IS NULL
              OR p_x_line_rec.attribute14 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute14 := oe_validate.g_attribute14;
            END IF;

            IF p_x_line_rec.attribute15 IS NULL
              OR p_x_line_rec.attribute15 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute15 := oe_validate.g_attribute15;
            END IF;
            IF p_x_line_rec.attribute16 IS NULL  -- for bug 2184255
              OR p_x_line_rec.attribute16 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute16 := oe_validate.g_attribute16;
            END IF;

            IF p_x_line_rec.attribute17 IS NULL
              OR p_x_line_rec.attribute17 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute17 := oe_validate.g_attribute17;
            END IF;

            IF p_x_line_rec.attribute18 IS NULL
              OR p_x_line_rec.attribute18 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute18 := oe_validate.g_attribute18;
            END IF;

            IF p_x_line_rec.attribute19 IS NULL
              OR p_x_line_rec.attribute19 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute19 := oe_validate.g_attribute19;
            END IF;

            IF p_x_line_rec.attribute20 IS NULL  -- for bug 2184255
              OR p_x_line_rec.attribute20 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.attribute20 := oe_validate.g_attribute20;
            END IF;

            -- end of assignments, bug 2511313
         END IF; -- Flex Validation successfull
        END IF; -- Is flex enabled
         IF l_debug_level > 0 then
         oe_debug_pub.add('After line_desc_flex  ' || x_return_status,2);
         END IF;

    END IF;  -- For Additional Line Information

 END IF; --bug#7380336

 --Start of bug#7380336
 --Added the condition here so that, if default value are provided, they can be defaulted by the flex api.

 IF l_context_required_flag = 'Y' AND ( p_x_line_rec.context IS NULL OR p_x_line_rec.context = FND_API.G_MISS_CHAR ) AND NOT (OE_GLOBALS.G_UI_FLAG) THEN

 	 -- Show Error message if appropriate context value is not passed
 	 -- from the Process Order Call and if the Context field is required
 	 -- and context is not defaulted by the flex api.

 	    IF OE_OE_PRICING_AVAILABILITY.IS_PRICING_AVAILIBILITY = 'N' THEN
 	         FND_MESSAGE.SET_NAME('FND', 'ONT_CONTEXT_NOT_FOUND');
 	         OE_MSG_PUB.ADD;
 	         IF l_debug_level  > 0 THEN
 	             oe_debug_pub.add('desc_flex Context Not set for OE_LINE_ATTRIBUTES DFF ') ;
 	         END IF;
 	         RAISE FND_API.G_EXC_ERROR;
 	    END IF;
 END IF;		--End of bug#7380336

--   END IF;
         /*  Fixing 2375476 to skip the Flex field validation in case of
             Internal Orders. This condition will be removed once process Order
             starts defaulting the FF */
--    IF  p_x_line_rec.order_source_id <> 10 THEN
        IF p_x_line_rec.operation = oe_globals.g_opr_create
         OR
        (  p_x_line_rec.operation = oe_globals.g_opr_update  AND
      (p_x_line_rec.global_attribute1 IS NOT NULL AND
        (   p_x_line_rec.global_attribute1 <>
            p_old_line_rec.global_attribute1 OR
            p_old_line_rec.global_attribute1 IS NULL ))
    OR  (p_x_line_rec.global_attribute10 IS NOT NULL AND
        (   p_x_line_rec.global_attribute10 <>
            p_old_line_rec.global_attribute10 OR
            p_old_line_rec.global_attribute10 IS NULL ))
    OR  (p_x_line_rec.global_attribute11 IS NOT NULL AND
        (   p_x_line_rec.global_attribute11 <>
            p_old_line_rec.global_attribute11 OR
            p_old_line_rec.global_attribute11 IS NULL ))
    OR  (p_x_line_rec.global_attribute12 IS NOT NULL AND
        (   p_x_line_rec.global_attribute12 <>
            p_old_line_rec.global_attribute12 OR
            p_old_line_rec.global_attribute12 IS NULL ))
    OR  (p_x_line_rec.global_attribute13 IS NOT NULL AND
        (   p_x_line_rec.global_attribute13 <>
            p_old_line_rec.global_attribute13 OR
            p_old_line_rec.global_attribute13 IS NULL ))
    OR  (p_x_line_rec.global_attribute14 IS NOT NULL AND
        (   p_x_line_rec.global_attribute14 <>
            p_old_line_rec.global_attribute14 OR
            p_old_line_rec.global_attribute14 IS NULL ))
    OR  (p_x_line_rec.global_attribute15 IS NOT NULL AND
        (   p_x_line_rec.global_attribute15 <>
            p_old_line_rec.global_attribute15 OR
            p_old_line_rec.global_attribute15 IS NULL ))
    OR  (p_x_line_rec.global_attribute16 IS NOT NULL AND
        (   p_x_line_rec.global_attribute16 <>
            p_old_line_rec.global_attribute16 OR
            p_old_line_rec.global_attribute16 IS NULL ))
    OR  (p_x_line_rec.global_attribute17 IS NOT NULL AND
        (   p_x_line_rec.global_attribute17 <>
            p_old_line_rec.global_attribute17 OR
            p_old_line_rec.global_attribute17 IS NULL ))
    OR  (p_x_line_rec.global_attribute18 IS NOT NULL AND
        (   p_x_line_rec.global_attribute18 <>
            p_old_line_rec.global_attribute18 OR
            p_old_line_rec.global_attribute18 IS NULL ))
    OR  (p_x_line_rec.global_attribute19 IS NOT NULL AND
        (   p_x_line_rec.global_attribute19 <>
            p_old_line_rec.global_attribute19 OR
            p_old_line_rec.global_attribute19 IS NULL ))
    OR  (p_x_line_rec.global_attribute2 IS NOT NULL AND
        (   p_x_line_rec.global_attribute2 <>
            p_old_line_rec.global_attribute2 OR
            p_old_line_rec.global_attribute2 IS NULL ))
    OR  (p_x_line_rec.global_attribute20 IS NOT NULL AND
        (   p_x_line_rec.global_attribute20 <>
            p_old_line_rec.global_attribute20 OR
            p_old_line_rec.global_attribute20 IS NULL ))
    OR  (p_x_line_rec.global_attribute3 IS NOT NULL AND
        (   p_x_line_rec.global_attribute3 <>
            p_old_line_rec.global_attribute3 OR
            p_old_line_rec.global_attribute3 IS NULL ))
    OR  (p_x_line_rec.global_attribute4 IS NOT NULL AND
        (   p_x_line_rec.global_attribute4 <>
            p_old_line_rec.global_attribute4 OR
            p_old_line_rec.global_attribute4 IS NULL ))
    OR  (p_x_line_rec.global_attribute5 IS NOT NULL AND
        (   p_x_line_rec.global_attribute5 <>
            p_old_line_rec.global_attribute5 OR
            p_old_line_rec.global_attribute5 IS NULL ))
    OR  (p_x_line_rec.global_attribute6 IS NOT NULL AND
        (   p_x_line_rec.global_attribute6 <>
            p_old_line_rec.global_attribute6 OR
            p_old_line_rec.global_attribute6 IS NULL ))
    OR  (p_x_line_rec.global_attribute7 IS NOT NULL AND
        (   p_x_line_rec.global_attribute7 <>
            p_old_line_rec.global_attribute7 OR
            p_old_line_rec.global_attribute7 IS NULL ))
    OR  (p_x_line_rec.global_attribute8 IS NOT NULL AND
        (   p_x_line_rec.global_attribute8 <>
            p_old_line_rec.global_attribute8 OR
            p_old_line_rec.global_attribute8 IS NULL ))
    OR  (p_x_line_rec.global_attribute9 IS NOT NULL AND
        (   p_x_line_rec.global_attribute9 <>
            p_old_line_rec.global_attribute9 OR
            p_old_line_rec.global_attribute9 IS NULL ))
    OR  (p_x_line_rec.global_attribute_category IS NOT NULL AND
        (   p_x_line_rec.global_attribute_category <>
            p_old_line_rec.global_attribute_category OR
            p_old_line_rec.global_attribute_category IS NULL )))
    THEN


          IF l_debug_level > 0 then
          OE_DEBUG_PUB.ADD('Before G_line_desc_flex',2);
          END IF;
        IF Oe_Order_Cache.IS_FLEX_ENABLED('OE_LINE_GLOBAL_ATTRIBUTE') = 'Y' THEN
          IF NOT OE_VALIDATE.G_Line_Desc_Flex
          (p_context            => p_x_line_rec.global_attribute_category
          ,p_attribute1         => p_x_line_rec.global_attribute1
          ,p_attribute2         => p_x_line_rec.global_attribute2
          ,p_attribute3         => p_x_line_rec.global_attribute3
          ,p_attribute4         => p_x_line_rec.global_attribute4
          ,p_attribute5         => p_x_line_rec.global_attribute5
          ,p_attribute6         => p_x_line_rec.global_attribute6
          ,p_attribute7         => p_x_line_rec.global_attribute7
          ,p_attribute8         => p_x_line_rec.global_attribute8
          ,p_attribute9         => p_x_line_rec.global_attribute9
          ,p_attribute10        => p_x_line_rec.global_attribute10
          ,p_attribute11        => p_x_line_rec.global_attribute11
          ,p_attribute12        => p_x_line_rec.global_attribute12
          ,p_attribute13        => p_x_line_rec.global_attribute13
          ,p_attribute14        => p_x_line_rec.global_attribute13
          ,p_attribute15        => p_x_line_rec.global_attribute14
          ,p_attribute16        => p_x_line_rec.global_attribute16
          ,p_attribute17        => p_x_line_rec.global_attribute17
          ,p_attribute18        => p_x_line_rec.global_attribute18
          ,p_attribute19        => p_x_line_rec.global_attribute19
          ,p_attribute20        => p_x_line_rec.global_attribute20) THEN

          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
             p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE   THEN

                p_x_line_rec.global_attribute_category    := null;
                p_x_line_rec.global_attribute1 := null;
                p_x_line_rec.global_attribute2 := null;
                p_x_line_rec.global_attribute3 := null;
                p_x_line_rec.global_attribute4 := null;
                p_x_line_rec.global_attribute5 := null;
                p_x_line_rec.global_attribute6 := null;
                p_x_line_rec.global_attribute7 := null;
                p_x_line_rec.global_attribute8 := null;
                p_x_line_rec.global_attribute9 := null;
                p_x_line_rec.global_attribute11 := null;
                p_x_line_rec.global_attribute12 := null;
                p_x_line_rec.global_attribute13 := null;
                p_x_line_rec.global_attribute14 := null;
                p_x_line_rec.global_attribute15 := null;
                p_x_line_rec.global_attribute16 := null;
                p_x_line_rec.global_attribute17 := null;
                p_x_line_rec.global_attribute18 := null;
                p_x_line_rec.global_attribute19 := null;
                p_x_line_rec.global_attribute20 := null;

        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
           p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
                p_x_line_rec.global_attribute_category    := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute1 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute2 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute3 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute4 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute5 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute6 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute7 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute8 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute9 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute11 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute12 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute13 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute14 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute15 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute16 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute17 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute18 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute19 := FND_API.G_MISS_CHAR;
                p_x_line_rec.global_attribute20 := FND_API.G_MISS_CHAR;

           ELSIF p_validation_level = FND_API.G_VALID_LEVEL_NONE THEN
               NULL;

          ELSE
                x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

        ELSE -- for bug 2511313
             IF p_x_line_rec.global_attribute_category IS NULL
               OR p_x_line_rec.global_attribute_category = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute_category := oe_validate.g_context;
             END IF;

             IF p_x_line_rec.global_attribute1 IS NULL
               OR p_x_line_rec.global_attribute1 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute1 := oe_validate.g_attribute1;
             END IF;

             IF p_x_line_rec.global_attribute2 IS NULL
               OR p_x_line_rec.global_attribute2 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute2 := oe_validate.g_attribute2;
             END IF;

             IF p_x_line_rec.global_attribute3 IS NULL
               OR p_x_line_rec.global_attribute3 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute3 := oe_validate.g_attribute3;
             END IF;

             IF p_x_line_rec.global_attribute4 IS NULL
               OR p_x_line_rec.global_attribute4 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute4 := oe_validate.g_attribute4;
             END IF;

             IF p_x_line_rec.global_attribute5 IS NULL
               OR p_x_line_rec.global_attribute5 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute5 := oe_validate.g_attribute5;
             END IF;

             IF p_x_line_rec.global_attribute6 IS NULL
               OR p_x_line_rec.global_attribute6 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute6 := oe_validate.g_attribute6;
             END IF;

             IF p_x_line_rec.global_attribute7 IS NULL
               OR p_x_line_rec.global_attribute7 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute7 := oe_validate.g_attribute7;
             END IF;

             IF p_x_line_rec.global_attribute8 IS NULL
               OR p_x_line_rec.global_attribute8 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute8 := oe_validate.g_attribute8;
             END IF;

             IF p_x_line_rec.global_attribute9 IS NULL
               OR p_x_line_rec.global_attribute9 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute9 := oe_validate.g_attribute9;
             END IF;

             IF p_x_line_rec.global_attribute11 IS NULL
               OR p_x_line_rec.global_attribute11 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute11 := oe_validate.g_attribute11;
             END IF;

             IF p_x_line_rec.global_attribute12 IS NULL
               OR p_x_line_rec.global_attribute12 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute12 := oe_validate.g_attribute12;
             END IF;

             IF p_x_line_rec.global_attribute13 IS NULL
               OR p_x_line_rec.global_attribute13 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute13 := oe_validate.g_attribute13;
             END IF;

             IF p_x_line_rec.global_attribute14 IS NULL
               OR p_x_line_rec.global_attribute14 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute14 := oe_validate.g_attribute14;
             END IF;

             IF p_x_line_rec.global_attribute15 IS NULL
               OR p_x_line_rec.global_attribute15 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute15 := oe_validate.g_attribute15;
             END IF;

             IF p_x_line_rec.global_attribute16 IS NULL
               OR p_x_line_rec.global_attribute16 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute16 := oe_validate.g_attribute16;
             END IF;

             IF p_x_line_rec.global_attribute17 IS NULL
               OR p_x_line_rec.global_attribute17 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute17 := oe_validate.g_attribute17;
             END IF;

             IF p_x_line_rec.global_attribute18 IS NULL
               OR p_x_line_rec.global_attribute18 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute18 := oe_validate.g_attribute18;
             END IF;

             IF p_x_line_rec.global_attribute19 IS NULL
               OR p_x_line_rec.global_attribute19 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute19 := oe_validate.g_attribute19;
             END IF;

             IF p_x_line_rec.global_attribute20 IS NULL
               OR p_x_line_rec.global_attribute20 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute20 := oe_validate.g_attribute20;
             END IF;

             IF p_x_line_rec.global_attribute10 IS NULL
               OR p_x_line_rec.global_attribute10 = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.global_attribute10 := oe_validate.g_attribute10;
             END IF;
             -- end of bug 2511313
         END IF;

        END IF; -- Is flex enabled
          IF l_debug_level > 0 then
          OE_DEBUG_PUB.ADD('After G_Line_desc_flex ' || x_return_status,2);
          END IF;

    END IF;
    --   END IF;

        IF  p_x_line_rec.operation = oe_globals.g_opr_create OR
   (  p_x_line_rec.operation = oe_globals.g_opr_update  AND
      (p_x_line_rec.industry_attribute1 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute1 <>
            p_old_line_rec.industry_attribute1 OR
            p_old_line_rec.industry_attribute1 IS NULL ))
    OR  (p_x_line_rec.industry_attribute10 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute10 <>
            p_old_line_rec.industry_attribute10 OR
            p_old_line_rec.industry_attribute10 IS NULL ))
    OR  (p_x_line_rec.industry_attribute11 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute11 <>
            p_old_line_rec.industry_attribute11 OR
            p_old_line_rec.industry_attribute11 IS NULL ))
    OR  (p_x_line_rec.industry_attribute12 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute12 <>
            p_old_line_rec.industry_attribute12 OR
            p_old_line_rec.industry_attribute12 IS NULL ))
    OR  (p_x_line_rec.industry_attribute13 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute13 <>
            p_old_line_rec.industry_attribute13 OR
            p_old_line_rec.industry_attribute13 IS NULL ))
    OR  (p_x_line_rec.industry_attribute14 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute14 <>
            p_old_line_rec.industry_attribute14 OR
            p_old_line_rec.industry_attribute14 IS NULL ))
    OR  (p_x_line_rec.industry_attribute15 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute15 <>
            p_old_line_rec.industry_attribute15 OR
            p_old_line_rec.industry_attribute15 IS NULL ))
    OR  (p_x_line_rec.industry_attribute16 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute16 <>
            p_old_line_rec.industry_attribute16 OR
            p_old_line_rec.industry_attribute16 IS NULL ))
    OR  (p_x_line_rec.industry_attribute17 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute17 <>
            p_old_line_rec.industry_attribute17 OR
            p_old_line_rec.industry_attribute17 IS NULL ))
    OR  (p_x_line_rec.industry_attribute18 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute18 <>
            p_old_line_rec.industry_attribute18 OR
            p_old_line_rec.industry_attribute18 IS NULL ))
    OR  (p_x_line_rec.industry_attribute19 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute19 <>
            p_old_line_rec.industry_attribute19 OR
            p_old_line_rec.industry_attribute19 IS NULL ))
    OR  (p_x_line_rec.industry_attribute2 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute2 <>
            p_old_line_rec.industry_attribute2 OR
            p_old_line_rec.industry_attribute2 IS NULL ))
    OR  (p_x_line_rec.industry_attribute20 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute20 <>
            p_old_line_rec.industry_attribute20 OR
            p_old_line_rec.industry_attribute20 IS NULL ))
    OR  (p_x_line_rec.industry_attribute21 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute21 <>
            p_old_line_rec.industry_attribute21 OR
            p_old_line_rec.industry_attribute21 IS NULL ))
    OR  (p_x_line_rec.industry_attribute22 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute22 <>
            p_old_line_rec.industry_attribute22 OR
            p_old_line_rec.industry_attribute22 IS NULL ))
    OR  (p_x_line_rec.industry_attribute23 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute23 <>
            p_old_line_rec.industry_attribute23 OR
            p_old_line_rec.industry_attribute23 IS NULL ))
    OR  (p_x_line_rec.industry_attribute24 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute24 <>
            p_old_line_rec.industry_attribute24 OR
            p_old_line_rec.industry_attribute24 IS NULL ))
    OR  (p_x_line_rec.industry_attribute25 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute25 <>
            p_old_line_rec.industry_attribute25 OR
            p_old_line_rec.industry_attribute25 IS NULL ))
    OR  (p_x_line_rec.industry_attribute26 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute26 <>
            p_old_line_rec.industry_attribute26 OR
            p_old_line_rec.industry_attribute26 IS NULL ))
    OR  (p_x_line_rec.industry_attribute27 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute27 <>
            p_old_line_rec.industry_attribute27 OR
            p_old_line_rec.industry_attribute27 IS NULL ))
    OR  (p_x_line_rec.industry_attribute28 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute28 <>
            p_old_line_rec.industry_attribute28 OR
            p_old_line_rec.industry_attribute28 IS NULL ))
    OR  (p_x_line_rec.industry_attribute29 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute29 <>
            p_old_line_rec.industry_attribute29 OR
            p_old_line_rec.industry_attribute29 IS NULL ))
    OR  (p_x_line_rec.industry_attribute3 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute3 <>
            p_old_line_rec.industry_attribute3 OR
            p_old_line_rec.industry_attribute3 IS NULL ))
    OR  (p_x_line_rec.industry_attribute30 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute30 <>
            p_old_line_rec.industry_attribute30 OR
            p_old_line_rec.industry_attribute30 IS NULL ))
    OR  (p_x_line_rec.industry_attribute4 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute4 <>
            p_old_line_rec.industry_attribute4 OR
            p_old_line_rec.industry_attribute4 IS NULL ))
    OR  (p_x_line_rec.industry_attribute5 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute5 <>
            p_old_line_rec.industry_attribute5 OR
            p_old_line_rec.industry_attribute5 IS NULL ))
    OR  (p_x_line_rec.industry_attribute6 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute6 <>
            p_old_line_rec.industry_attribute6 OR
            p_old_line_rec.industry_attribute6 IS NULL ))
    OR  (p_x_line_rec.industry_attribute7 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute7 <>
            p_old_line_rec.industry_attribute7 OR
            p_old_line_rec.industry_attribute7 IS NULL ))
    OR  (p_x_line_rec.industry_attribute8 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute8 <>
            p_old_line_rec.industry_attribute8 OR
            p_old_line_rec.industry_attribute8 IS NULL ))
    OR  (p_x_line_rec.industry_attribute9 IS NOT NULL AND
        (   p_x_line_rec.industry_attribute9 <>
            p_old_line_rec.industry_attribute9 OR
            p_old_line_rec.industry_attribute9 IS NULL ))
    OR  (p_x_line_rec.industry_context IS NOT NULL AND
        (   p_x_line_rec.industry_context <>
            p_old_line_rec.industry_context OR
            p_old_line_rec.industry_context IS NULL )))
    THEN
IF Oe_Order_Cache.IS_FLEX_ENABLED('OE_LINE_INDUSTRY_ATTRIBUTE') = 'Y' THEN
         IF NOT OE_VALIDATE.I_Line_Desc_Flex
          (p_context            => p_x_line_rec.Industry_context
          ,p_attribute1         => p_x_line_rec.Industry_attribute1
          ,p_attribute2         => p_x_line_rec.Industry_attribute2
          ,p_attribute3         => p_x_line_rec.Industry_attribute3
          ,p_attribute4         => p_x_line_rec.Industry_attribute4
          ,p_attribute5         => p_x_line_rec.Industry_attribute5
          ,p_attribute6         => p_x_line_rec.Industry_attribute6
          ,p_attribute7         => p_x_line_rec.Industry_attribute7
          ,p_attribute8         => p_x_line_rec.Industry_attribute8
          ,p_attribute9         => p_x_line_rec.Industry_attribute9
          ,p_attribute10        => p_x_line_rec.Industry_attribute10
          ,p_attribute11        => p_x_line_rec.Industry_attribute11
          ,p_attribute12        => p_x_line_rec.Industry_attribute12
          ,p_attribute13        => p_x_line_rec.Industry_attribute13
          ,p_attribute14        => p_x_line_rec.Industry_attribute14
          ,p_attribute15        => p_x_line_rec.Industry_attribute15
          ,p_attribute16         => p_x_line_rec.Industry_attribute16
          ,p_attribute17         => p_x_line_rec.Industry_attribute17
          ,p_attribute18         => p_x_line_rec.Industry_attribute18
          ,p_attribute19         => p_x_line_rec.Industry_attribute19
          ,p_attribute20         => p_x_line_rec.Industry_attribute20
          ,p_attribute21         => p_x_line_rec.Industry_attribute21
          ,p_attribute22         => p_x_line_rec.Industry_attribute22
          ,p_attribute23         => p_x_line_rec.Industry_attribute23
          ,p_attribute24         => p_x_line_rec.Industry_attribute24
          ,p_attribute25        => p_x_line_rec.Industry_attribute25
          ,p_attribute26        => p_x_line_rec.Industry_attribute26
          ,p_attribute27        => p_x_line_rec.Industry_attribute27
          ,p_attribute28        => p_x_line_rec.Industry_attribute28
          ,p_attribute29        => p_x_line_rec.Industry_attribute29
          ,p_attribute30        => p_x_line_rec.Industry_attribute30) THEN

          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
             p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE   THEN


                p_x_line_rec.Industry_context    := null;
                p_x_line_rec.Industry_attribute1 := null;
                p_x_line_rec.Industry_attribute2 := null;
                p_x_line_rec.Industry_attribute3 := null;
                p_x_line_rec.Industry_attribute4 := null;
                p_x_line_rec.Industry_attribute5 := null;
                p_x_line_rec.Industry_attribute6 := null;
                p_x_line_rec.Industry_attribute7 := null;
                p_x_line_rec.Industry_attribute8 := null;
                p_x_line_rec.Industry_attribute9 := null;
                p_x_line_rec.Industry_attribute10 := null;
                p_x_line_rec.Industry_attribute11 := null;
                p_x_line_rec.Industry_attribute12 := null;
                p_x_line_rec.Industry_attribute13 := null;
                p_x_line_rec.Industry_attribute14 := null;
                p_x_line_rec.Industry_attribute15 := null;
                p_x_line_rec.Industry_attribute16 := null;
                p_x_line_rec.Industry_attribute17 := null;
                p_x_line_rec.Industry_attribute18 := null;
                p_x_line_rec.Industry_attribute19 := null;
                p_x_line_rec.Industry_attribute20 := null;
                p_x_line_rec.Industry_attribute21 := null;
                p_x_line_rec.Industry_attribute22 := null;
                p_x_line_rec.Industry_attribute23 := null;
                p_x_line_rec.Industry_attribute24 := null;
                p_x_line_rec.Industry_attribute25 := null;
                p_x_line_rec.Industry_attribute26 := null;
                p_x_line_rec.Industry_attribute27 := null;
                p_x_line_rec.Industry_attribute28 := null;
                p_x_line_rec.Industry_attribute29 := null;
                p_x_line_rec.Industry_attribute30 := null;

        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
           p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN

                p_x_line_rec.Industry_context    := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute1 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute2 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute3 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute4 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute5 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute6 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute7 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute8 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute9 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute10 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute11 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute12 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute13 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute14 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute15 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute16 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute17 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute18 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute19 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute20 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute21 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute22 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute23 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute24 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute25 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute26 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute27 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute28 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute29 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Industry_attribute30 := FND_API.G_MISS_CHAR;

           ELSIF p_validation_level = FND_API.G_VALID_LEVEL_NONE THEN
                NULL;

           ELSE
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          ELSE -- for bug 2511313
            IF p_x_line_rec.industry_context IS NULL
              OR p_x_line_rec.industry_context = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_context := oe_validate.g_context;
            END IF;

            IF p_x_line_rec.industry_attribute1 IS NULL
              OR p_x_line_rec.industry_attribute1 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute1 := oe_validate.g_attribute1;
            END IF;

            IF p_x_line_rec.industry_attribute2 IS NULL
              OR p_x_line_rec.industry_attribute2 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute2 := oe_validate.g_attribute2;
            END IF;

            IF p_x_line_rec.industry_attribute3 IS NULL
              OR p_x_line_rec.industry_attribute3 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute3 := oe_validate.g_attribute3;
            END IF;

            IF p_x_line_rec.industry_attribute4 IS NULL
              OR p_x_line_rec.industry_attribute4 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute4 := oe_validate.g_attribute4;
            END IF;

            IF p_x_line_rec.industry_attribute5 IS NULL
              OR p_x_line_rec.industry_attribute5 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute5 := oe_validate.g_attribute5;
            END IF;

            IF p_x_line_rec.industry_attribute6 IS NULL
              OR p_x_line_rec.industry_attribute6 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute6 := oe_validate.g_attribute6;
            END IF;

            IF p_x_line_rec.industry_attribute7 IS NULL
              OR p_x_line_rec.industry_attribute7 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute7 := oe_validate.g_attribute7;
            END IF;

            IF p_x_line_rec.industry_attribute8 IS NULL
              OR p_x_line_rec.industry_attribute8 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute8 := oe_validate.g_attribute8;
            END IF;

            IF p_x_line_rec.industry_attribute9 IS NULL
              OR p_x_line_rec.industry_attribute9 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute9 := oe_validate.g_attribute9;
            END IF;

            IF p_x_line_rec.industry_attribute10 IS NULL
              OR p_x_line_rec.industry_attribute10 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute10 := oe_validate.g_attribute10;
            END IF;

            IF p_x_line_rec.industry_attribute11 IS NULL
              OR p_x_line_rec.industry_attribute11 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute11 := oe_validate.g_attribute11;
            END IF;

            IF p_x_line_rec.industry_attribute12 IS NULL
              OR p_x_line_rec.industry_attribute12 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute12 := oe_validate.g_attribute12;
            END IF;

            IF p_x_line_rec.industry_attribute13 IS NULL
              OR p_x_line_rec.industry_attribute13 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute13 := oe_validate.g_attribute13;
            END IF;

            IF p_x_line_rec.industry_attribute14 IS NULL
              OR p_x_line_rec.industry_attribute14 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute14 := oe_validate.g_attribute14;
            END IF;

            IF p_x_line_rec.industry_attribute15 IS NULL
              OR p_x_line_rec.industry_attribute15 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute15 := oe_validate.g_attribute15;
            END IF;

            IF p_x_line_rec.industry_attribute16 IS NULL
              OR p_x_line_rec.industry_attribute16 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute16 := oe_validate.g_attribute16;
            END IF;

            IF p_x_line_rec.industry_attribute17 IS NULL
              OR p_x_line_rec.industry_attribute17 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute17 := oe_validate.g_attribute17;
            END IF;

            IF p_x_line_rec.industry_attribute18 IS NULL
              OR p_x_line_rec.industry_attribute18 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute18 := oe_validate.g_attribute18;
            END IF;

            IF p_x_line_rec.industry_attribute19 IS NULL
              OR p_x_line_rec.industry_attribute19 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute19 := oe_validate.g_attribute19;
            END IF;

            IF p_x_line_rec.industry_attribute20 IS NULL
              OR p_x_line_rec.industry_attribute20 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute20 := oe_validate.g_attribute20;
            END IF;

            IF p_x_line_rec.industry_attribute21 IS NULL
              OR p_x_line_rec.industry_attribute21 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute21 := oe_validate.g_attribute21;
            END IF;

            IF p_x_line_rec.industry_attribute22 IS NULL
              OR p_x_line_rec.industry_attribute22 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute22 := oe_validate.g_attribute22;
            END IF;

            IF p_x_line_rec.industry_attribute23 IS NULL
              OR p_x_line_rec.industry_attribute23 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute23 := oe_validate.g_attribute23;
            END IF;

            IF p_x_line_rec.industry_attribute24 IS NULL
              OR p_x_line_rec.industry_attribute24 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute24 := oe_validate.g_attribute24;
            END IF;

            IF p_x_line_rec.industry_attribute25 IS NULL
              OR p_x_line_rec.industry_attribute25 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute25 := oe_validate.g_attribute25;
            END IF;

            IF p_x_line_rec.industry_attribute26 IS NULL
              OR p_x_line_rec.industry_attribute26 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute26 := oe_validate.g_attribute26;
            END IF;

            IF p_x_line_rec.industry_attribute27 IS NULL
              OR p_x_line_rec.industry_attribute27 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute27 := oe_validate.g_attribute27;
            END IF;

            IF p_x_line_rec.industry_attribute28 IS NULL
              OR p_x_line_rec.industry_attribute28 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute28 := oe_validate.g_attribute28;
            END IF;

            IF p_x_line_rec.industry_attribute29 IS NULL
              OR p_x_line_rec.industry_attribute29 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute29 := oe_validate.g_attribute29;
            END IF;

            IF p_x_line_rec.industry_attribute30 IS NULL
              OR p_x_line_rec.industry_attribute30 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.industry_attribute30 := oe_validate.g_attribute30;
            END IF;

            -- end of bug 2511313
         END IF;
        END IF; -- Is flex enabled
         IF l_debug_level > 0 then
         oe_debug_pub.add('After I_line_desc_flex  ' || x_return_status,2);
         END IF;

    END IF;

    /* Trading Partner Attributes */
        IF  p_x_line_rec.operation = oe_globals.g_opr_create OR
   (  p_x_line_rec.operation = oe_globals.g_opr_update  AND
      (p_x_line_rec.tp_attribute1 IS NOT NULL AND
        (   p_x_line_rec.tp_attribute1 <>
            p_old_line_rec.tp_attribute1 OR
            p_old_line_rec.tp_attribute1 IS NULL ))
    OR  (p_x_line_rec.tp_attribute2 IS NOT NULL AND
        (   p_x_line_rec.tp_attribute2 <>
            p_old_line_rec.tp_attribute2 OR
            p_old_line_rec.tp_attribute2 IS NULL ))
    OR  (p_x_line_rec.tp_attribute3 IS NOT NULL AND
        (   p_x_line_rec.tp_attribute3 <>
            p_old_line_rec.tp_attribute3 OR
            p_old_line_rec.tp_attribute3 IS NULL ))
    OR  (p_x_line_rec.tp_attribute4 IS NOT NULL AND
        (   p_x_line_rec.tp_attribute4 <>
            p_old_line_rec.tp_attribute4 OR
            p_old_line_rec.tp_attribute4 IS NULL ))
    OR  (p_x_line_rec.tp_attribute5 IS NOT NULL AND
        (   p_x_line_rec.tp_attribute5 <>
            p_old_line_rec.tp_attribute5 OR
            p_old_line_rec.tp_attribute5 IS NULL ))
    OR  (p_x_line_rec.tp_attribute6 IS NOT NULL AND
        (   p_x_line_rec.tp_attribute6 <>
            p_old_line_rec.tp_attribute6 OR
            p_old_line_rec.tp_attribute6 IS NULL ))
    OR  (p_x_line_rec.tp_attribute7 IS NOT NULL AND
        (   p_x_line_rec.tp_attribute7 <>
            p_old_line_rec.tp_attribute7 OR
            p_old_line_rec.tp_attribute7 IS NULL ))
    OR  (p_x_line_rec.tp_attribute8 IS NOT NULL AND
        (   p_x_line_rec.tp_attribute8 <>
            p_old_line_rec.tp_attribute8 OR
            p_old_line_rec.tp_attribute8 IS NULL ))
    OR  (p_x_line_rec.tp_attribute9 IS NOT NULL AND
        (   p_x_line_rec.tp_attribute9 <>
            p_old_line_rec.tp_attribute9 OR
            p_old_line_rec.tp_attribute9 IS NULL ))
    OR  (p_x_line_rec.tp_attribute10 IS NOT NULL AND
        (   p_x_line_rec.tp_attribute10 <>
            p_old_line_rec.tp_attribute10 OR
            p_old_line_rec.tp_attribute10 IS NULL ))
    OR  (p_x_line_rec.tp_attribute11 IS NOT NULL AND
        (   p_x_line_rec.tp_attribute11 <>
            p_old_line_rec.tp_attribute11 OR
            p_old_line_rec.tp_attribute11 IS NULL ))
    OR  (p_x_line_rec.tp_attribute12 IS NOT NULL AND
        (   p_x_line_rec.tp_attribute12 <>
            p_old_line_rec.tp_attribute12 OR
            p_old_line_rec.tp_attribute12 IS NULL ))
    OR  (p_x_line_rec.tp_attribute13 IS NOT NULL AND
        (   p_x_line_rec.tp_attribute13 <>
            p_old_line_rec.tp_attribute13 OR
            p_old_line_rec.tp_attribute13 IS NULL ))
    OR  (p_x_line_rec.tp_attribute14 IS NOT NULL AND
        (   p_x_line_rec.tp_attribute14 <>
            p_old_line_rec.tp_attribute14 OR
            p_old_line_rec.tp_attribute14 IS NULL ))
    OR  (p_x_line_rec.tp_attribute15 IS NOT NULL AND
        (   p_x_line_rec.tp_attribute15 <>
            p_old_line_rec.tp_attribute15 OR
            p_old_line_rec.tp_attribute15 IS NULL )))

    THEN

IF Oe_Order_Cache.IS_FLEX_ENABLED('OE_LINE_TP_ATTRIBUTES') = 'Y' THEN
         IF NOT OE_VALIDATE.TP_Line_Desc_Flex
          (p_context            => p_x_line_rec.tp_context
          ,p_attribute1         => p_x_line_rec.tp_attribute1
          ,p_attribute2         => p_x_line_rec.tp_attribute2
          ,p_attribute3         => p_x_line_rec.tp_attribute3
          ,p_attribute4         => p_x_line_rec.tp_attribute4
          ,p_attribute5         => p_x_line_rec.tp_attribute5
          ,p_attribute6         => p_x_line_rec.tp_attribute6
          ,p_attribute7         => p_x_line_rec.tp_attribute7
          ,p_attribute8         => p_x_line_rec.tp_attribute8
          ,p_attribute9         => p_x_line_rec.tp_attribute9
          ,p_attribute10        => p_x_line_rec.tp_attribute10
          ,p_attribute11        => p_x_line_rec.tp_attribute11
          ,p_attribute12        => p_x_line_rec.tp_attribute12
          ,p_attribute13        => p_x_line_rec.tp_attribute13
          ,p_attribute14        => p_x_line_rec.tp_attribute14
          ,p_attribute15        => p_x_line_rec.tp_attribute15) THEN

          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
             p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE   THEN


                p_x_line_rec.tp_context    := null;
                p_x_line_rec.tp_attribute1 := null;
                p_x_line_rec.tp_attribute2 := null;
                p_x_line_rec.tp_attribute3 := null;
                p_x_line_rec.tp_attribute4 := null;
                p_x_line_rec.tp_attribute5 := null;
                p_x_line_rec.tp_attribute6 := null;
                p_x_line_rec.tp_attribute7 := null;
                p_x_line_rec.tp_attribute8 := null;
                p_x_line_rec.tp_attribute9 := null;
                p_x_line_rec.tp_attribute10 := null;
                p_x_line_rec.tp_attribute11 := null;
                p_x_line_rec.tp_attribute12 := null;
                p_x_line_rec.tp_attribute13 := null;
                p_x_line_rec.tp_attribute14 := null;
                p_x_line_rec.tp_attribute15 := null;

        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
           p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN

                p_x_line_rec.tp_context    := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute1 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute2 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute3 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute4 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute5 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute6 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute7 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute8 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute9 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute10 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute11 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute12 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute13 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute14 := FND_API.G_MISS_CHAR;
                p_x_line_rec.tp_attribute15 := FND_API.G_MISS_CHAR;

           ELSIF p_validation_level = FND_API.G_VALID_LEVEL_NONE THEN
                NULL;

           ELSE
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          ELSE -- if the flex validation is successfull
            -- For bug 2511313
            IF p_x_line_rec.tp_context IS NULL
              OR p_x_line_rec.tp_context = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.tp_context    := oe_validate.g_context;
            END IF;

            IF p_x_line_rec.tp_attribute1 IS NULL
              OR p_x_line_rec.tp_attribute1 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.tp_attribute1 := oe_validate.g_attribute1;
            END IF;

            IF p_x_line_rec.tp_attribute2 IS NULL
              OR p_x_line_rec.tp_attribute2 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.tp_attribute2 := oe_validate.g_attribute2;
            END IF;

            IF p_x_line_rec.tp_attribute3 IS NULL
              OR p_x_line_rec.tp_attribute3 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.tp_attribute3 := oe_validate.g_attribute3;
            END IF;

            IF p_x_line_rec.tp_attribute4 IS NULL
              OR p_x_line_rec.tp_attribute4 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.tp_attribute4 := oe_validate.g_attribute4;
            END IF;

            IF p_x_line_rec.tp_attribute5 IS NULL
              OR p_x_line_rec.tp_attribute5 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.tp_attribute5 := oe_validate.g_attribute5;
            END IF;

            IF p_x_line_rec.tp_attribute6 IS NULL
              OR p_x_line_rec.tp_attribute6 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.tp_attribute6 := oe_validate.g_attribute6;
            END IF;

            IF p_x_line_rec.tp_attribute7 IS NULL
              OR p_x_line_rec.tp_attribute7 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.tp_attribute7 := oe_validate.g_attribute7;
            END IF;

            IF p_x_line_rec.tp_attribute8 IS NULL
              OR p_x_line_rec.tp_attribute8 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.tp_attribute8 := oe_validate.g_attribute8;
            END IF;

            IF p_x_line_rec.tp_attribute9 IS NULL
              OR p_x_line_rec.tp_attribute9 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.tp_attribute9 := oe_validate.g_attribute9;
            END IF;

            IF p_x_line_rec.tp_attribute10 IS NULL
              OR p_x_line_rec.tp_attribute10 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.tp_attribute10 := Oe_validate.G_attribute10;
            End IF;

            IF p_x_line_rec.tp_attribute11 IS NULL
              OR p_x_line_rec.tp_attribute11 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.tp_attribute11 := oe_validate.g_attribute11;
            END IF;

            IF p_x_line_rec.tp_attribute12 IS NULL
              OR p_x_line_rec.tp_attribute12 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.tp_attribute12 := oe_validate.g_attribute12;
            END IF;

            IF p_x_line_rec.tp_attribute13 IS NULL
              OR p_x_line_rec.tp_attribute13 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.tp_attribute13 := oe_validate.g_attribute13;
            END IF;

            IF p_x_line_rec.tp_attribute14 IS NULL
              OR p_x_line_rec.tp_attribute14 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.tp_attribute14 := oe_validate.g_attribute14;
            END IF;

            IF p_x_line_rec.tp_attribute15 IS NULL
              OR p_x_line_rec.tp_attribute15 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.tp_attribute15 := oe_validate.g_attribute15;
            END IF;
            -- end of assignments, bug 2511313

         END IF;
        END IF; -- Is flex enabled

         --oe_debug_pub.add('After TP_line_desc_flex  ' || x_return_status);

    END IF;
    /* Trading Partner */

--For bug 2517505
    IF ( p_x_line_rec.operation = oe_globals.g_opr_create AND
         p_x_line_rec.line_category_code = 'RETURN' ) OR
   (  p_x_line_rec.operation = oe_globals.g_opr_update  AND
      p_x_line_rec.line_category_code = 'RETURN' AND  -- added for bug 2750455
      ((p_x_line_rec.return_attribute1 IS NOT NULL AND  -- additional pair of braces added for 2750455
        (   p_x_line_rec.return_attribute1 <>
            p_old_line_rec.return_attribute1 OR
            p_old_line_rec.return_attribute1 IS NULL ))
    OR  (p_x_line_rec.return_attribute2 IS NOT NULL AND
        (   p_x_line_rec.return_attribute2 <>
            p_old_line_rec.return_attribute2 OR
            p_old_line_rec.return_attribute2 IS NULL ))
    OR  (p_x_line_rec.return_context IS NOT NULL AND
        (   p_x_line_rec.return_context <>
            p_old_line_rec.return_context OR
            p_old_line_rec.return_context IS NULL ))))
    THEN

         IF l_debug_level > 0 then
         oe_debug_pub.add('Before calling Return line_desc_flex',2);
         END IF;
IF Oe_Order_Cache.IS_FLEX_ENABLED('OE_LINE_RETURN_ATTRIBUTE') = 'Y' THEN
         IF NOT OE_VALIDATE.R_Line_Desc_Flex
          (p_context            => p_x_line_rec.Return_context
          ,p_attribute1         => p_x_line_rec.Return_attribute1
          ,p_attribute2         => p_x_line_rec.Return_attribute2
          ,p_attribute3         => p_x_line_rec.Return_attribute3
          ,p_attribute4         => p_x_line_rec.Return_attribute4
          ,p_attribute5         => p_x_line_rec.Return_attribute5
          ,p_attribute6         => p_x_line_rec.Return_attribute6
          ,p_attribute7         => p_x_line_rec.Return_attribute7
          ,p_attribute8         => p_x_line_rec.Return_attribute8
          ,p_attribute9         => p_x_line_rec.Return_attribute9
          ,p_attribute10        => p_x_line_rec.Return_attribute10
          ,p_attribute11        => p_x_line_rec.Return_attribute11
          ,p_attribute12        => p_x_line_rec.Return_attribute12
          ,p_attribute13        => p_x_line_rec.Return_attribute13
          ,p_attribute14        => p_x_line_rec.Return_attribute14
          ,p_attribute15        => p_x_line_rec.Return_attribute15) THEN

          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
             p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE   THEN


                p_x_line_rec.Return_context    := null;
                p_x_line_rec.Return_attribute1 := null;
                p_x_line_rec.Return_attribute2 := null;
                p_x_line_rec.Return_attribute3 := null;
                p_x_line_rec.Return_attribute4 := null;
                p_x_line_rec.Return_attribute5 := null;
                p_x_line_rec.Return_attribute6 := null;
                p_x_line_rec.Return_attribute7 := null;
                p_x_line_rec.Return_attribute8 := null;
                p_x_line_rec.Return_attribute9 := null;
                p_x_line_rec.Return_attribute11 := null;
                p_x_line_rec.Return_attribute12 := null;
                p_x_line_rec.Return_attribute13 := null;
                p_x_line_rec.Return_attribute14 := null;
                p_x_line_rec.Return_attribute15 := null;
                p_x_line_rec.Return_attribute10 := null;

        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
           p_x_line_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN
                p_x_line_rec.Return_context    := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute1 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute2 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute3 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute4 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute5 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute6 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute7 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute8 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute9 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute11 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute12 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute13 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute14 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute15 := FND_API.G_MISS_CHAR;
                p_x_line_rec.Return_attribute10 := FND_API.G_MISS_CHAR;

           ELSIF p_validation_level = FND_API.G_VALID_LEVEL_NONE THEN
                NULL;

          ELSE

                x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
           ELSE -- for bug 2511313
            IF p_x_line_rec.return_context IS NULL
              OR p_x_line_rec.return_context = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.return_context := oe_validate.g_context;
            END IF;

            IF p_x_line_rec.return_attribute1 IS NULL
              OR p_x_line_rec.return_attribute1 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.return_attribute1 := oe_validate.g_attribute1;
            END IF;

            IF p_x_line_rec.return_attribute2 IS NULL
              OR p_x_line_rec.return_attribute2 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.return_attribute2 := oe_validate.g_attribute2;
            END IF;

            IF p_x_line_rec.return_attribute3 IS NULL
              OR p_x_line_rec.return_attribute3 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.return_attribute3 := oe_validate.g_attribute3;
            END IF;

            IF p_x_line_rec.return_attribute4 IS NULL
              OR p_x_line_rec.return_attribute4 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.return_attribute4 := oe_validate.g_attribute4;
            END IF;

            IF p_x_line_rec.return_attribute5 IS NULL
              OR p_x_line_rec.return_attribute5 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.return_attribute5 := oe_validate.g_attribute5;
            END IF;

            IF p_x_line_rec.return_attribute6 IS NULL
              OR p_x_line_rec.return_attribute6 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.return_attribute6 := oe_validate.g_attribute6;
            END IF;

            IF p_x_line_rec.return_attribute7 IS NULL
              OR p_x_line_rec.return_attribute7 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.return_attribute7 := oe_validate.g_attribute7;
            END IF;

            IF p_x_line_rec.return_attribute8 IS NULL
              OR p_x_line_rec.return_attribute8 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.return_attribute8 := oe_validate.g_attribute8;
            END IF;

            IF p_x_line_rec.return_attribute9 IS NULL
              OR p_x_line_rec.return_attribute9 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.return_attribute9 := oe_validate.g_attribute9;
            END IF;

            IF p_x_line_rec.return_attribute10 IS NULL
              OR p_x_line_rec.return_attribute10 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.return_attribute10 := oe_validate.g_attribute10;
            END IF;

            IF p_x_line_rec.return_attribute11 IS NULL
              OR p_x_line_rec.return_attribute11 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.return_attribute11 := oe_validate.g_attribute11;
            END IF;

            IF p_x_line_rec.return_attribute12 IS NULL
              OR p_x_line_rec.return_attribute12 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.return_attribute12 := oe_validate.g_attribute12;
            END IF;

            IF p_x_line_rec.return_attribute13 IS NULL
              OR p_x_line_rec.return_attribute13 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.return_attribute13 := oe_validate.g_attribute13;
            END IF;

            IF p_x_line_rec.return_attribute14 IS NULL
              OR p_x_line_rec.return_attribute14 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.return_attribute14 := oe_validate.g_attribute14;
            END IF;

            IF p_x_line_rec.return_attribute15 IS NULL
              OR p_x_line_rec.return_attribute15 = FND_API.G_MISS_CHAR THEN
               p_x_line_rec.return_attribute15 := oe_validate.g_attribute15;
            END IF;
            -- end of bug 2511313
         END IF;
        END IF; -- Is flex enabled
         IF l_debug_level > 0 then
         oe_debug_pub.add('After Return line_desc_flex  ' || x_return_status,2);
         END IF;
    END IF;
  end if;  --end if OE_GLOBALS.g_validate_desc_flex ='Y' then --4343612
    --  Done validating attributes

EXCEPTION
  WHEN OTHERS THEN
    oe_debug_pub.add('error in Validate_Flex '|| sqlerrm, 1);
    RAISE;
END Validate_Flex;

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
( x_return_status OUT NOCOPY VARCHAR2
, p_line_rec      IN  OE_Order_PUB.Line_Rec_Type
)
IS
l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

    -- Validate entity delete.

    -- Begin : Changes for bug 7707133
    -- Earlier no validation was done for entity being deleted as deletion is
    -- not possible after booking via normal flow. Introducing check for open
    -- RMA as delinking of a config item triggers deletion and invalidates the
    -- reference on any open RMAs ceated against it.

    IF l_debug_level > 0 THEN
      Oe_debug_pub.ADD('Entering Oe_validate_line.entity_delete for line ID : ' || p_line_rec.line_id);
    END IF;

    IF p_line_rec.line_category_code = 'ORDER' AND p_line_rec.item_type_code = 'CONFIG'
    THEN
       IF NOT Validate_Return_Existence(p_line_rec.line_id,
                                        p_line_rec.ordered_quantity,
                                        OE_GLOBALS.G_OPR_DELETE)
       THEN
          -- Message is populated in the function
          l_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;

    IF l_debug_level > 0 THEN
      oe_debug_pub.add('Leaving Oe_validate_line.entity_delete with status : '||l_return_status, 1);
    END IF;
    -- NULL;
    -- End : Changes for bug 7707133

    -- Done.

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity_Delete'
            );
        END IF;

END Entity_Delete;

END OE_Validate_Line;

/
