--------------------------------------------------------
--  DDL for Package Body OE_BULK_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BULK_PRICE_PVT" AS
/* $Header: OEBVPRCB.pls 120.2.12010000.5 2009/01/08 15:45:40 smanian ship $ */

G_PKG_NAME         CONSTANT     VARCHAR2(30):='OE_BULK_PRICE_PVT';

PROCEDURE mark_header_error(p_header_index IN NUMBER,
                p_header_rec  IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE);

PROCEDURE Booking_Failed(p_index        IN            NUMBER,  --bug 4558078
                         p_header_rec   IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE);

---------------------------------------------------------------------
-- PROCEDURE Insert_Adjustments
--
-- Inserts manual price adjustments for this bulk import batch,
-- from interface tables into oe_price_adjustments table.
-- This API should be called before Price_Orders to ensure that
-- manual adjustments are applied when pricing the order.
---------------------------------------------------------------------

PROCEDURE Insert_Adjustments
        (p_batch_id            IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2)

IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   INSERT INTO OE_PRICE_ADJUSTMENTS
    (PRICE_ADJUSTMENT_ID
    ,CREATION_DATE
    ,CREATED_BY
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_LOGIN
    ,PROGRAM_APPLICATION_ID
    ,PROGRAM_ID
    ,PROGRAM_UPDATE_DATE
    ,REQUEST_ID
    ,HEADER_ID
    ,DISCOUNT_ID
    ,DISCOUNT_LINE_ID
    ,AUTOMATIC_FLAG
    ,PERCENT
    ,LINE_ID
    ,CONTEXT
    ,ATTRIBUTE1
    ,ATTRIBUTE2
    ,ATTRIBUTE3
    ,ATTRIBUTE4
    ,ATTRIBUTE5
    ,ATTRIBUTE6
    ,ATTRIBUTE7
    ,ATTRIBUTE8
    ,ATTRIBUTE9
    ,ATTRIBUTE10
    ,ATTRIBUTE11
    ,ATTRIBUTE12
    ,ATTRIBUTE13
    ,ATTRIBUTE14
    ,ATTRIBUTE15
    ,ORIG_SYS_DISCOUNT_REF
    ,LIST_HEADER_ID
    ,LIST_LINE_ID
    ,LIST_LINE_TYPE_CODE
    ,MODIFIER_MECHANISM_TYPE_CODE
    ,MODIFIED_FROM
    ,MODIFIED_TO
    ,UPDATED_FLAG
    ,UPDATE_ALLOWED
    ,APPLIED_FLAG
    ,CHANGE_REASON_CODE
    ,CHANGE_REASON_TEXT
    ,operand
    ,Arithmetic_operator
    ,COST_ID
    ,TAX_CODE
    ,TAX_EXEMPT_FLAG
    ,TAX_EXEMPT_NUMBER
    ,TAX_EXEMPT_REASON_CODE
    ,PARENT_ADJUSTMENT_ID
    ,INVOICED_FLAG
    ,ESTIMATED_FLAG
    ,INC_IN_SALES_PERFORMANCE
    ,SPLIT_ACTION_CODE
    ,ADJUSTED_AMOUNT
    ,PRICING_PHASE_ID
    ,CHARGE_TYPE_CODE
    ,CHARGE_SUBTYPE_CODE
    ,list_line_no
    ,source_system_code
    ,benefit_qty
    ,benefit_uom_code
    ,print_on_invoice_flag
    ,expiration_date
    ,rebate_transaction_type_code
    ,rebate_transaction_reference
    ,rebate_payment_system_code
    ,redeemed_date
    ,redeemed_flag
    ,accrual_flag
    ,range_break_quantity
    ,accrual_conversion_rate
    ,pricing_group_sequence
    ,modifier_level_code
    ,price_break_type_code
    ,substitution_attribute
    ,proration_type_code
    ,CREDIT_OR_CHARGE_FLAG
    ,INCLUDE_ON_RETURNS_FLAG
    ,AC_CONTEXT
    ,AC_ATTRIBUTE1
    ,AC_ATTRIBUTE2
    ,AC_ATTRIBUTE3
    ,AC_ATTRIBUTE4
    ,AC_ATTRIBUTE5
    ,AC_ATTRIBUTE6
    ,AC_ATTRIBUTE7
    ,AC_ATTRIBUTE8
    ,AC_ATTRIBUTE9
    ,AC_ATTRIBUTE10
    ,AC_ATTRIBUTE11
    ,AC_ATTRIBUTE12
    ,AC_ATTRIBUTE13
    ,AC_ATTRIBUTE14
    ,AC_ATTRIBUTE15
    ,OPERAND_PER_PQTY
    ,ADJUSTED_AMOUNT_PER_PQTY
    ,LOCK_CONTROL
    )
    SELECT
     OE_PRICE_ADJUSTMENTS_S.NEXTVAL
    ,sysdate
    ,FND_GLOBAL.USER_ID
    ,sysdate
    ,FND_GLOBAL.USER_ID
    ,NULL
    ,a.program_application_id
    ,a.program_id
    ,a.program_update_date
    ,a.request_id
    ,h.header_id
    ,a.discount_id
    ,a.discount_line_id
    ,nvl(a.automatic_flag,ll.automatic_flag)
    ,a.percent
    ,l.line_id
    ,a.context
    ,a.attribute1
    ,a.attribute2
    ,a.attribute3
    ,a.attribute4
    ,a.attribute5
    ,a.attribute6
    ,a.attribute7
    ,a.attribute8
    ,a.attribute9
    ,a.attribute10
    ,a.attribute11
    ,a.attribute12
    ,a.attribute13
    ,a.attribute14
    ,a.attribute15
    ,a.orig_sys_discount_ref
    ,a.LIST_HEADER_ID
    ,a.LIST_LINE_ID
    ,nvl(a.LIST_LINE_TYPE_CODE,ll.list_line_type_code)
    ,a.MODIFIER_MECHANISM_TYPE_CODE
    ,a.MODIFIED_FROM
    ,a.MODIFIED_TO
    ,a.UPDATED_FLAG
    ,nvl(a.UPDATE_ALLOWED,ll.override_flag)
    ,a.APPLIED_FLAG
    ,a.CHANGE_REASON_CODE
    ,a.CHANGE_REASON_TEXT
    ,nvl(a.operand,ll.operand)
    ,nvl(a.arithmetic_operator,ll.arithmetic_operator)
    ,a.COST_ID
    ,a.TAX_CODE
    ,NULL          -- a.TAX_EXEMPT_FLAG
    ,NULL          -- a.TAX_EXEMPT_NUMBER
    ,NULL          -- a.TAX_EXEMPT_REASON_CODE
    ,a.PARENT_ADJUSTMENT_ID
    ,a.INVOICED_FLAG
    ,nvl(a.ESTIMATED_FLAG
         ,decode(ll.list_line_type_code,'FREIGHT_CHARGE','Y',NULL))
    ,a.INC_IN_SALES_PERFORMANCE
    ,NULL         -- a.SPLIT_ACTION_CODE
    ,a.ADJUSTED_AMOUNT
    ,nvl(a.PRICING_PHASE_ID,ll.Pricing_phase_id)
    ,nvl(a.CHARGE_TYPE_CODE,ll.charge_type_code)
    ,nvl(a.CHARGE_SUBTYPE_CODE,ll.charge_subtype_code)
    ,nvl(a.list_line_number,ll.list_line_no)
    ,lh.source_system_code
    ,ll.benefit_qty
    ,ll.benefit_uom_code
    ,ll.print_on_invoice_flag
    ,ll.expiration_date
    ,ll.rebate_transaction_type_code
    ,NULL       -- a.rebate_transaction_reference
    ,NULL       -- a.rebate_payment_system_code
    ,NULL       -- a.redeemed_date
    ,NULL       -- a.redeemed_flag
    ,ll.accrual_flag
    ,NULL       -- a.range_break_quantity
    ,ll.accrual_conversion_rate
    ,ll.pricing_group_sequence
    ,ll.modifier_level_code
    ,ll.price_break_type_code
    ,ll.substitution_attribute
    ,ll.proration_type_code
    ,a.credit_or_charge_flag
    ,nvl(a.include_on_returns_flag,ll.include_on_returns_flag)
    ,a.ac_context
    ,a.ac_attribute1
    ,a.ac_attribute2
    ,a.ac_attribute3
    ,a.ac_attribute4
    ,a.ac_attribute5
    ,a.ac_attribute6
    ,a.ac_attribute7
    ,a.ac_attribute8
    ,a.ac_attribute9
    ,a.ac_attribute10
    ,a.ac_attribute11
    ,a.ac_attribute12
    ,a.ac_attribute13
    ,a.ac_attribute14
    ,a.ac_attribute15
    ,nvl(a.OPERAND_PER_PQTY,ll.operand)
    ,a.ADJUSTED_AMOUNT_PER_PQTY
    ,1
    FROM OE_PRICE_ADJS_IFACE_ALL a
         , OE_ORDER_HEADERS h
         , QP_LIST_HEADERS lh
         , QP_LIST_LINES ll
         , OE_ORDER_LINES_ALL l  -- Changes for SQL Id 14876372
    WHERE h.batch_id = p_batch_id
      AND a.order_source_id = h.order_source_id
      AND a.orig_sys_document_ref = h.orig_sys_document_ref
      AND lh.list_header_id = a.list_header_id
      AND ll.list_line_id = a.list_line_id
      AND l.order_source_id(+) = a.order_source_id
      AND l.orig_sys_document_ref(+) = a.orig_sys_document_ref
      AND l.orig_sys_line_ref(+) = a.orig_sys_line_ref
   ;

   -- Cannot have OR with outer join operator, in any case - BULK
   -- does not support shipment line creation!
   --   OR l.orig_sys_shipment_ref(+) = a.orig_sys_shipment_ref

EXCEPTION
   WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , INSERT_ADJUSTMENTS' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
      OE_BULK_MSG_PUB.Add_Exc_Msg
           (G_PKG_NAME
            ,'Insert_Adjustments');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Insert_Adjustments;


---------------------------------------------------------------------
-- PROCEDURE Price_Orders
--
-- Pricing for all orders in this batch. Currently, this API is NOT
-- BULK enabled and calls pricing integration API (oe_order_adj_pvt)
-- to price order by order. The integration API directly updates the
-- pricing fields on order lines table.
-- IN parameter -
-- p_header_rec: order headers in the batch
-- Modifying this procedure to do the credit checking for Orders in
-- a batch.
---------------------------------------------------------------------

PROCEDURE Price_Orders
        (p_header_rec          IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE
        ,p_process_tax        IN VARCHAR2 DEFAULT 'N'
        ,x_return_status OUT NOCOPY VARCHAR2

        )
IS
l_price_control_rec      QP_PREQ_GRP.control_record_type;
l_request_rec            oe_order_pub.request_rec_type;
l_line_tbl               oe_order_pub.line_tbl_type;
l_multiple_events        VARCHAR2(1);
l_book_failed            VARCHAR2(1);
l_header_id              NUMBER;
l_header_count           NUMBER := p_header_rec.HEADER_ID.COUNT;
I                        NUMBER;
l_ec_installed           VARCHAR2(1);
l_index                  NUMBER;
l_start_index            NUMBER := 1;
--bug 4558078
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
l_return_status          VARCHAR2(1);

CURSOR c_price_attributes(l_header_id NUMBER) IS
   SELECT line_id
          ,price_list_id
          ,unit_list_price
          ,unit_selling_price
   FROM OE_ORDER_LINES l
   WHERE l.header_id = l_header_id;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Set this global so that pricing integration will not fire security
   -- checks for update of pricing fields back on order lines.
   OE_GLOBALS.G_HEADER_CREATED := TRUE;

   -- Set EDI installed status to 'N' so that acknowledgment records are
   -- not created in the pricing call. These will be created via the
   -- bulk acknowledgments API (OEBVACKB.pls) later during bulk import.
   l_ec_installed := OE_GLOBALS.G_EC_INSTALLED;
   OE_GLOBALS.G_EC_INSTALLED := 'N';

  -- added for HVOP Tax project
  IF p_process_tax = 'N' THEN
   FOR I IN 1..l_header_count LOOP

     l_header_id := p_header_rec.header_id(i);
     l_book_failed := 'N'; --bug 4558078

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'HEADER ID:'||L_HEADER_ID ) ;
     END IF;

     IF nvl(p_header_rec.lock_control(i),0) <> -99 AND
        nvl(p_header_rec.lock_control(i),0) <> -98 AND
        nvl(p_header_rec.lock_control(i),0) <> -97
     THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PRICE ORDER , HEADER ID:'||L_HEADER_ID ) ;
      END IF;

      IF OE_BULK_ORDER_PVT.G_PRICING_NEEDED = 'Y' THEN   --bug 455807

          IF p_header_rec.booked_flag(i) = 'Y' THEN
            l_multiple_events := 'Y';
            l_price_control_rec.pricing_event := 'BATCH,BOOK';
          ELSE
            l_multiple_events := 'N';
            l_price_control_rec.pricing_event := 'BATCH';
          END IF;

          l_Price_Control_Rec.calculate_flag :=  QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
          l_Price_Control_Rec.Simulation_Flag := 'N';


          -- Changes for bug 4180619
          BEGIN

              OE_Order_Adj_Pvt.Price_Line
              (x_return_status     => x_return_status
              ,p_Header_id        => l_header_id
              ,p_Request_Type_code=> 'ONT'
              ,p_Control_rec      => l_Price_Control_Rec
              ,p_write_to_db      => TRUE
              ,p_request_rec      => l_request_rec
              ,p_multiple_events  => l_multiple_events
            -- Action code of 'PRICE_ORDER' forces integration to query all
            -- lines and send to pricing engine. Else it would send only
            -- changed lines but changed lines global is not populated in
            -- bulk import.
            -- In future, when bulk supports changes to existing orders, it
            -- should populate changed lines table and for such orders, call
            -- with action code of 'PRICE_LINE'.
              ,p_action_code      => 'PRICE_ORDER'
              ,x_line_Tbl         => l_Line_Tbl
              );

              IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  OE_DEBUG_PUB.Add('UnExpected Error in Pricing '|| l_header_id,2);
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 OE_DEBUG_PUB.Add('Expected Error in Pricing '|| l_header_id,2);
                  -- Mark the header for error
                  mark_header_error(i, p_header_rec);
                  p_header_rec.lock_control(i) := -99;
                  x_return_status := FND_API.G_RET_STS_SUCCESS;
              END IF;

     EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
           IF l_debug_level > 0 then
             OE_DEBUG_PUB.Add('Expected Error in Pricing '|| l_header_id,2);
           End if;
           mark_header_error(i,p_header_rec);
           p_header_rec.lock_control(i) := -99;
           x_return_status := FND_API.G_RET_STS_SUCCESS;

       WHEN OTHERS THEN
           IF l_debug_level > 0 THEN
              OE_DEBUG_PUB.Add('Unexp Error in Pricing:'||l_header_id|| ' '||SqlErrm, 1);
           End if;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      END IF; -- IF OE_BULK_ORDER_PVT.G_PRICING_NEEDED = --bug 455807

      IF p_header_rec.booked_flag(i) = 'Y'
      AND  nvl(p_header_rec.lock_control(i),0) <> -99
      THEN

        BEGIN
           SELECT 'Y'
           INTO   l_book_failed
           FROM OE_ORDER_LINES l
           WHERE l.header_id = l_header_id
             AND (l.price_list_id IS NULL
               OR l.unit_list_price IS NULL
               OR l.unit_selling_price IS NULL)
             AND rownum = 1;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'DATA FOUND , BOOK FAILED' ) ;
            END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_book_failed := 'N';
        END;

        -- PLEASE ADD CODE HERE FOR COMPARING PRICE AND PAYMENT TERM
        -- FROM POST_PROCESS IN OEXVIMSB.pls

        IF l_book_failed = 'Y' THEN

            FOR c1 IN c_price_attributes(l_header_id) LOOP

              OE_BULK_MSG_PUB.set_msg_context(
                 p_entity_code                => 'LINE'
                ,p_entity_id                  => c1.line_id
                ,p_header_id                  => l_header_id
                ,p_line_id                    => c1.line_id
                ,p_orig_sys_document_ref      =>
                   p_header_rec.orig_sys_document_ref(i)
                ,p_orig_sys_document_line_ref => null
                ,p_source_document_id         => null
                ,p_source_document_line_id    => null
                ,p_order_source_id            =>
                   p_header_rec.order_source_id(i)
                ,p_source_document_type_id    => null);

              IF c1.price_list_id IS NULL THEN
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('PRICE_LIST_ID'));
                OE_BULK_MSG_PUB.ADD;
              END IF;


              IF c1.unit_list_price IS NULL THEN
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('UNIT_LIST_PRICE'));
                OE_BULK_MSG_PUB.ADD;
              END IF;

              IF c1.unit_selling_price IS NULL THEN
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('UNIT_SELLING_PRICE'));
                OE_BULK_MSG_PUB.ADD;
              END IF;


            END LOOP;

            Booking_Failed( i, p_header_rec); --bug 455807
        ELSE

          -- Also add message to indicate that order has been booked. At this
          -- stage, booked flag should be set to 'Y' only if order passed all
          -- booking validations including price related validations.
          OE_BULK_MSG_PUB.set_msg_context(
                 p_entity_code                => 'HEADER'
                ,p_entity_id                  => l_header_id
                ,p_header_id                  => l_header_id
                ,p_line_id                    => null
                ,p_orig_sys_document_ref      =>
                   p_header_rec.orig_sys_document_ref(i)
                ,p_orig_sys_document_line_ref => null
                ,p_source_document_id         => null
                ,p_source_document_line_id    => null
                ,p_order_source_id            =>
                   p_header_rec.order_source_id(i)
                ,p_source_document_type_id    => null
                );
          FND_MESSAGE.SET_NAME('ONT','OE_ORDER_BOOKED');
          OE_BULK_MSG_PUB.Add;

        END IF; -- if book failed, populate errors else add message that
                -- order is booked
      --bug 455807
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('G_CC_REQUIRED IS: '||OE_BULK_ORDER_PVT.G_CC_REQUIRED ) ;
           oe_debug_pub.add('l_book_failed IS : '||l_book_failed ) ;
           oe_debug_pub.add('G_REALTIME_CC_REQUIRED IS: '||OE_BULK_ORDER_PVT.G_REALTIME_CC_REQUIRED ) ;
        END IF;

        IF OE_BULK_ORDER_PVT.G_CC_REQUIRED = 'Y' AND l_book_failed = 'N' THEN

            -- Update the booked flag only if real Time CC is required
            -- else the booked_flag is already set on the record

            IF OE_BULK_ORDER_PVT.G_REALTIME_CC_REQUIRED = 'Y' THEN
                    UPDATE oe_order_headers_all
                    SET booked_flag = p_header_rec.booked_flag(i)
                    WHERE header_id = p_header_rec.header_id(i);
            END IF;

            -- Do credit checking if needed for the order

            IF OE_BULK_CACHE.IS_CC_REQUIRED(p_header_rec.order_type_id(i))
            THEN

                -- Call the Credit checking API
                OE_Verify_Payment_PUB.Verify_Payment
                     ( p_header_id      => p_header_rec.header_id(i)
                     , p_calling_action => 'BOOKING'
                     , p_delayed_request=> FND_API.G_FALSE
                     , p_msg_count      => l_msg_count
                     , p_msg_data       => l_msg_data
                     , p_return_status  => l_return_status
                     );
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                    Booking_Failed( i, p_header_rec);

                END IF; --IF l_return_status <> FND_API.G_RET_STS_SUCC

            END IF; -- IF OE_BULK_CACHE.IS_CC_REQUIRED(p_head

        END IF; -- IF OE_BULK_ORDER_PVT.G_CC_REQUIRED --bug 455807
      END IF; -- for booked orders, check for pricing attributes

     END IF; -- price only orders without errors

   END LOOP;

 ELSIF p_process_tax = 'Y' THEN

   FOR I IN 1..l_header_count LOOP

     l_header_id := p_header_rec.header_id(i);
     l_book_failed := 'N';

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'HEADER ID:'||L_HEADER_ID ) ;
     END IF;

     IF nvl(p_header_rec.lock_control(i),0) <> -99 AND
        nvl(p_header_rec.lock_control(i),0) <> -98 AND
        nvl(p_header_rec.lock_control(i),0) <> -97
     THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PRICE ORDER , HEADER ID:'||L_HEADER_ID ) ;
      END IF;

      IF OE_BULK_ORDER_PVT.G_PRICING_NEEDED = 'Y' THEN

IF p_header_rec.booked_flag(i) = 'Y' THEN
            l_multiple_events := 'Y';
            l_price_control_rec.pricing_event := 'BATCH,BOOK';
          ELSE
            l_multiple_events := 'N';
            l_price_control_rec.pricing_event := 'BATCH';
          END IF;

          l_Price_Control_Rec.calculate_flag :=
QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
          l_Price_Control_Rec.Simulation_Flag := 'N';

          --added for HVOP Tax project
          OE_BULK_PRICE_PVT.G_Booking_Failed := FALSE;
          OE_BULK_PRICE_PVT.G_Header_Index := I;

          OE_Order_Adj_Pvt.Price_Line
         (x_return_status     => x_return_status
          ,p_Header_id        => l_header_id
          ,p_Request_Type_code=> 'ONT'
          ,p_Control_rec      => l_Price_Control_Rec
          ,p_write_to_db      => TRUE
          ,p_request_rec      => l_request_rec
          ,p_multiple_events  => l_multiple_events
          -- Action code of 'PRICE_ORDER' forces integration to query all
          -- lines and send to pricing engine. Else it would send only
          -- changed lines but changed lines global is not populated in
          -- bulk import.
          ,p_action_code      => 'PRICE_ORDER'
          ,x_line_Tbl         => l_Line_Tbl
          );

          IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
              OR x_return_status = FND_API.G_RET_STS_ERROR )
          THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

      END IF; -- IF OE_BULK_ORDER_PVT.G_PRICING_NEEDED =

      IF p_header_rec.booked_flag(i) = 'Y' THEN

          IF OE_BULK_PRICE_PVT.G_BOOKING_FAILED THEN
             l_book_failed := 'Y';
          ELSE
             l_book_failed := 'N';
          END IF;

    IF l_book_failed = 'Y' THEN

            FOR c1 IN c_price_attributes(l_header_id) LOOP

              OE_BULK_MSG_PUB.set_msg_context(
                 p_entity_code                => 'LINE'
                ,p_entity_id                  => c1.line_id
                ,p_header_id                  => l_header_id
                ,p_line_id                    => c1.line_id
                ,p_orig_sys_document_ref      =>
                   p_header_rec.orig_sys_document_ref(i)
                ,p_orig_sys_document_line_ref => null
                ,p_source_document_id         => null
                ,p_source_document_line_id    => null
                ,p_order_source_id            =>
                   p_header_rec.order_source_id(i)
                ,p_source_document_type_id    => null);

              IF c1.price_list_id IS NULL THEN
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('PRICE_LIST_ID'));
                OE_BULK_MSG_PUB.ADD;
              END IF;

             IF c1.unit_list_price IS NULL THEN
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('UNIT_LIST_PRICE'));
                OE_BULK_MSG_PUB.ADD;
              END IF;

              IF c1.unit_selling_price IS NULL THEN
                FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQD_LINE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_UTIL.Get_Attribute_Name('UNIT_SELLING_PRICE'));
                OE_BULK_MSG_PUB.ADD;
              END IF;


            END LOOP;

            Booking_Failed( i, p_header_rec);
        ELSE
          -- Also add message to indicate that order has been booked. At this
          -- stage, booked flag should be set to 'Y' only if order passed all
          -- booking validations including price related validations.
          OE_BULK_MSG_PUB.set_msg_context(
                 p_entity_code                => 'HEADER'
                ,p_entity_id                  => l_header_id
                ,p_header_id                  => l_header_id
                ,p_line_id                    => null
                ,p_orig_sys_document_ref      =>
                   p_header_rec.orig_sys_document_ref(i)
                ,p_orig_sys_document_line_ref => null
                ,p_source_document_id         => null
                ,p_source_document_line_id    => null
                ,p_order_source_id            =>
                   p_header_rec.order_source_id(i)
                ,p_source_document_type_id    => null
                );
          FND_MESSAGE.SET_NAME('ONT','OE_ORDER_BOOKED');
          OE_BULK_MSG_PUB.Add;

        END IF; -- if book failed, populate errors else add message that
                -- order is booked

      END IF; -- for booked orders, check for pricing attributes
     END IF; -- price only orders without errors

   END LOOP;

   OE_BULK_TAX_UTIL.Calculate_Tax(p_post_insert => TRUE);

   IF OE_BULK_ORDER_PVT.G_CC_REQUIRED = 'Y' THEN
     FOR I IN 1..l_header_count LOOP

       IF nvl(p_header_rec.lock_control(i),0) <> -99 AND
          nvl(p_header_rec.lock_control(i),0) <> -98 AND
          nvl(p_header_rec.lock_control(i),0) <> -97
       THEN

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CREDIT CHECK ORDER , HEADER ID:'||L_HEADER_ID )
;
           oe_debug_pub.add('G_CC_REQUIRED IS: '||OE_BULK_ORDER_PVT.G_CC_REQUIRED ) ;
           oe_debug_pub.add('l_book_failed IS : '||l_book_failed ) ;
           oe_debug_pub.add('G_REALTIME_CC_REQUIRED IS: '||OE_BULK_ORDER_PVT.G_REALTIME_CC_REQUIRED ) ;
          END IF;

          IF p_header_rec.booked_flag(i) = 'Y' THEN

      -- Update the booked flag only if real Time CC is required
            -- else the booked_flag is already set on the record

            IF OE_BULK_ORDER_PVT.G_REALTIME_CC_REQUIRED = 'Y' THEN
                    UPDATE oe_order_headers_all
                    SET booked_flag = p_header_rec.booked_flag(i)
                    WHERE header_id = p_header_rec.header_id(i);
            END IF;

            -- Do credit checking if needed for the order

            IF OE_BULK_CACHE.IS_CC_REQUIRED(p_header_rec.order_type_id(i))
            THEN

                -- Call the Credit checking API
                OE_Verify_Payment_PUB.Verify_Payment
                     ( p_header_id      => p_header_rec.header_id(i)
                     , p_calling_action => 'BOOKING'
                     , p_delayed_request=> FND_API.G_FALSE
                     , p_msg_count      => l_msg_count
                     , p_msg_data       => l_msg_data
                     , p_return_status  => l_return_status
                     );
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                    Booking_Failed( i, p_header_rec);
                 END IF; --IF l_return_status <> FND_API.G_RET_STS_SUCC

            END IF; -- IF OE_BULK_CACHE.IS_CC_REQUIRED(p_head

        END IF; -- IF p_header_rec.booked_flag = 'Y'

     END IF; -- price only orders without errors

    END LOOP;
   END IF; -- if g_cc_required
  END IF; -- if p_process_tax...



   OE_GLOBALS.G_EC_INSTALLED := l_ec_installed;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      OE_GLOBALS.G_EC_INSTALLED := l_ec_installed;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      OE_GLOBALS.G_EC_INSTALLED := l_ec_installed;
      OE_BULK_MSG_PUB.Add_Exc_Msg
           (G_PKG_NAME
            ,'Price_Orders');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Price_Orders;

--bug 455807 This procedure has been added
PROCEDURE Booking_Failed(p_index        IN            NUMBER,
                         p_header_rec   IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE)
IS
l_start_index  BINARY_INTEGER;
BEGIN
    -- Update DB values
    UPDATE OE_ORDER_LINES
    SET booked_flag = 'N'
    ,flow_status_code = 'ENTERED'
    WHERE header_id = p_header_rec.header_id(p_index);

    UPDATE OE_ORDER_HEADERS
    SET booked_flag = 'N'
       ,booked_date = NULL
       ,flow_status_code = 'ENTERED'
    WHERE header_id = p_header_rec.header_id(p_index);

    -- Also, delete from DBI tables if booking fails
    IF OE_BULK_ORDER_PVT.G_DBI_INSTALLED = 'Y' THEN
       DELETE FROM ONT_DBI_CHANGE_LOG
       WHERE header_id = p_header_rec.header_id(p_index);
    END IF;

    -- Un-set booking fields on global records
    p_header_rec.booked_flag(p_index) := 'N';
    l_start_index := 1;

    FOR l_index IN l_start_index..OE_Bulk_Order_PVT.G_LINE_REC.HEADER_ID.COUNT LOOP
        IF OE_Bulk_Order_PVT.G_LINE_REC.header_id(l_index) = p_header_rec.header_id(p_index)
        THEN
            OE_Bulk_Order_PVT.G_LINE_REC.booked_flag(l_index) := 'N';
        ELSIF OE_Bulk_Order_PVT.G_LINE_REC.header_id(l_index) >
               p_header_rec.header_id(p_index)
        THEN
            l_start_index := l_index;
            EXIT;
        END IF;
    END LOOP;

END Booking_Failed;


PROCEDURE Update_Pricing_Attributes
        (p_line_tbl          IN  OE_ORDER_PUB.LINE_TBL_TYPE
        )
IS
l_last_index binary_integer;
BEGIN
 oe_debug_pub.add(' In Update_Pricing_Attributes', 1);
 oe_debug_pub.add(' table count :'|| p_line_tbl.count, 1 );

 IF OE_BULK_PRICE_PVT.G_HEADER_INDEX IS  NULL THEN
    RETURN;
 ELSE
  l_last_index := NVL(OE_BULK_ORDER_PVT.G_HEADER_REC.start_line_index(OE_BULK_PRICE_PVT.G_HEADER_INDEX),1);
                  --NVL added to prevent pl/sql numeric/value error in for loop.bug7685103

  FOR j in 1..p_line_tbl.count LOOP
    FOR i IN l_last_index..
             OE_BULK_ORDER_PVT.G_HEADER_REC.end_line_index(OE_BULK_PRICE_PVT.G_HEADER_INDEX)
LOOP
      IF p_line_tbl(j).line_id = OE_BULK_ORDER_PVT.G_LINE_REC.line_id(i) THEN
          -- match
          IF
OE_BULK_ORDER_PVT.G_HEADER_REC.BOOKED_FLAG(OE_BULK_PRICE_PVT.G_HEADER_INDEX) = 'Y' AND
             (p_line_tbl(j).unit_selling_price IS NULL OR
              p_line_tbl(j).unit_list_price IS NULL OR
              p_line_tbl(j).price_list_id IS NULL) THEN
              OE_BULK_PRICE_PVT.G_BOOKING_FAILED := TRUE;
          END IF;

          OE_BULK_ORDER_PVT.G_LINE_REC.unit_selling_price(i) := p_line_tbl(j).unit_selling_price;
          OE_BULK_ORDER_PVT.G_LINE_REC.unit_list_price(i) := p_line_tbl(j).unit_list_price;
          OE_BULK_ORDER_PVT.G_LINE_REC.price_list_id(i) := p_line_tbl(j).price_list_id;

          IF i = l_last_index THEN
              -- increment search space
              l_last_index := l_last_index + 1;
          END IF;
      END IF;
    END LOOP;
  END LOOP;
 END IF;
  oe_debug_pub.add(' Exit Update_Pricing_Attributes' ,1);

END Update_Pricing_Attributes;


PROCEDURE mark_header_error(p_header_index IN NUMBER,
               p_header_rec IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE)
IS
error_count NUMBER := OE_Bulk_Order_Pvt.G_ERROR_REC.header_id.COUNT;
BEGIN
     OE_DEBUG_PUB.Add('The error count is '|| error_count,2);
     error_count := error_count + 1;

     OE_Bulk_Order_Pvt.G_ERROR_REC.order_source_id.EXTEND(1);
     OE_Bulk_Order_Pvt.G_ERROR_REC.order_source_id(error_count)
                        := p_header_rec.order_source_id(p_header_index);

     OE_Bulk_Order_Pvt.G_ERROR_REC.orig_sys_document_ref.EXTEND(1);
     OE_Bulk_Order_Pvt.G_ERROR_REC.orig_sys_document_ref(error_count)
                        := p_header_rec.orig_sys_document_ref(p_header_index);

     OE_Bulk_Order_Pvt.G_ERROR_REC.header_id.EXTEND(1);
     OE_Bulk_Order_Pvt.G_ERROR_REC.header_id(error_count)
                        := p_header_rec.header_id(p_header_index);
     OE_DEBUG_PUB.Add(' Exiting mark_header_error ',2);

END mark_header_error;


END OE_BULK_PRICE_PVT;

/
