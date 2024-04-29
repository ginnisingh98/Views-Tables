--------------------------------------------------------
--  DDL for Package Body OE_ADV_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ADV_PRICE_PVT" AS
/* $Header: OEXVAPRB.pls 120.9.12010000.7 2010/01/27 16:15:49 plowe ship $ */

--  Global constant holding the package name

G_PRICE_LINE_ID_TBL          OE_ORDER_ADJ_PVT.Index_Tbl_Type;
G_DEBUG BOOLEAN;
G_REQUEST_ID NUMBER:=NULL;
G_BINARY_LIMIT CONSTANT NUMBER := OE_GLOBALS.G_BINARY_LIMIT;         -- BUG 8631297

procedure Adj_Debug (p_text IN VARCHAR2, p_level IN NUMBER:=5) As
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  If G_DEBUG Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  P_TEXT , P_LEVEL ) ;
     END IF;
  End If;
End Adj_Debug;

procedure Sort_Line_Table(
          px_line_tbl IN Oe_Order_Pub.Line_Tbl_Type,
          px_price_line_id_tbl IN OUT NOCOPY Oe_Order_Adj_Pvt.Index_Tbl_Type)
 IS
    l_line_index Number;
    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --
Begin

    l_line_index := px_line_tbl.First;
    While l_line_index Is Not Null Loop
        px_price_line_id_tbl(MOD(px_line_tbl(l_line_index).line_id,G_BINARY_LIMIT)) := l_line_index;  -- Bug 8631297
        l_line_index := px_line_tbl.Next(l_line_index);
    End Loop;
End;


Procedure Call_Process_Order(
             p_old_header_rec                     OE_Order_Pub.Header_Rec_Type,
             px_header_rec        IN  OUT NOCOPY OE_Order_Pub.Header_Rec_Type,
             px_line_tbl          IN  OUT NOCOPY  OE_Order_Pub.Line_Tbl_Type,
             px_old_line_tbl          IN OUT NOCOPY  OE_Order_Pub.Line_Tbl_Type,
             p_control_rec       IN  OUT NOCOPY  OE_GLOBALS.Control_Rec_Type,
             x_return_status     OUT NOCOPY VARCHAR2)
IS
        lx_old_header_rec  OE_Order_Pub.Header_Rec_Type := p_old_header_rec;
        l_line_index                    NUMBER;
                    -- process_order in variables

        I                               NUMBER;
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(2000);
        l_return_status                 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
        l_index                         NUMBER:=1;
        l_new_line_tbl                  OE_Order_Pub.Line_Tbl_Type;
        l_old_line_tbl                  OE_Order_Pub.Line_Tbl_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INSIDE CALL PROCESS ORDER' , 1 ) ;
      END IF;
    IF px_line_tbl.COUNT > 0 THEN
        l_line_index := px_line_tbl.first;
        while l_line_index is not null loop
           IF nvl(px_line_tbl(l_line_index).operation,OE_GLOBALS.G_OPR_NONE) = OE_GLOBALS.G_OPR_NONE THEN
            IF l_debug_level  > 0 THEN
             oe_debug_pub.add('Operation none or null:'||px_line_tbl(l_line_index).line_id||' from px_line_tbl' , 1 ) ;
            END IF;
              --Do nothing on this line. None operation
              NULL;
           ELSE
            IF l_debug_level  > 0 THEN
             oe_debug_pub.add('Deleting line id:'||px_line_tbl(l_line_index).line_id||' from px_line_tbl' , 1 ) ;
            END IF;
               l_new_line_tbl(l_index):=px_line_tbl(l_line_index);
               oe_debug_pub.add(' l_index:'||l_index);
               oe_debug_pub.add(' l_line_index:'||l_line_index);
               oe_debug_pub.add(' new_line_tbl.count:'||px_line_tbl.count);
               oe_debug_pub.add(' old_line_tbl.count:'||px_old_line_tbl.count);

               IF px_old_line_tbl.exists(l_line_index) THEN
                  l_old_line_tbl(l_index):=px_old_line_tbl(l_line_index);
               END IF;

               l_index:=l_index + 1;

           END IF;
           l_line_index := px_line_tbl.next(l_line_index);
        end loop;

       -- caller set the security and procees flags on ctrl rec.

        p_control_rec.default_attributes   := TRUE;
        p_control_rec.controlled_operation := TRUE;
        p_control_rec.change_attributes    := TRUE;
        p_control_rec.validate_entity      := TRUE;
        p_control_rec.write_to_DB          := TRUE;
        p_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_HEADER;
        p_control_rec.process              := FALSE; --bug 2866986 added to set process flag to false

        OE_GLOBALS.G_PRICING_RECURSION := 'Y';

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE CALLING OE_ORDER_PVT.HEADER' , 1 ) ;
          oe_debug_pub.add(  'LX_OLD_HEADER_REC.HEADER_ID='||LX_OLD_HEADER_REC.HEADER_ID , 1 ) ;
          oe_debug_pub.add(  'LX_OLD_HEADER_REC.PAYMENT_TERM_ID='||LX_OLD_HEADER_REC.PAYMENT_TERM_ID , 1 ) ;
          oe_debug_pub.add(  'LX_OLD_HEADER_REC.OPERATION='||LX_OLD_HEADER_REC.OPERATION , 1 ) ;
          oe_debug_pub.add(  'PX_HEADER_REC.HEADER_ID='||PX_HEADER_REC.HEADER_ID , 1 ) ;
          oe_debug_pub.add(  'PX_HEADER_REC.PAYMENT_TERM_ID='||PX_HEADER_REC.PAYMENT_TERM_ID , 1 ) ;
          oe_debug_pub.add(  'PX_HEADER_REC.OPERATION='||PX_HEADER_REC.OPERATION , 1 ) ;
        END IF;

       IF (px_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE) Then
        OE_Order_Pvt.Header
        (   p_validation_level  => FND_API.G_VALID_LEVEL_FULL
         ,  p_control_rec       => p_control_rec
         ,  p_x_header_rec      => px_header_rec
         ,  p_x_old_header_rec  => lx_old_header_rec
         ,  x_return_status     => l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
        p_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_LINE;
      IF (l_new_line_tbl.count > 0) THEN  --bug 2855986 change px_line_tbl to l_new_line_tbl.count
        OE_Order_Pvt.Lines
        (   p_validation_level  => FND_API.G_VALID_LEVEL_FULL
        ,   p_control_rec       => p_control_rec
        ,   p_x_line_tbl        => l_new_line_tbl
        ,   p_x_old_line_tbl    => l_old_line_tbl
        ,   x_return_status     => l_return_status);

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
      END IF;
       OE_GLOBALS.G_PRICING_RECURSION := 'N';
  END IF; -- count > 0
End Call_Process_Order;



procedure set_item_for_iue(
       px_line_rec      in out nocopy OE_Order_PUB.line_rec_type
       ,p_related_item_id   NUMBER
     )
is
      l_org_id NUMBER := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
      l_ordered_item                  varchar2(300);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ENTERING OE_ORDER_PRICE_PVT.SET_ITEM_FOR_IUE' ) ;

            /*sdatti*/
	 oe_debug_pub.ADD('px_line_rec.original_inventory_item_id:'||px_line_rec.INVENTORY_ITEM_ID,1);
	 oe_debug_pub.ADD('px_line_rec.original_inventory_item_id:'||px_line_rec.original_INVENTORY_ITEM_ID,1);
	 oe_debug_pub.ADD('px_line_rec.original_ordered_item_id:'||px_line_rec.ordered_item_id,1);
	 oe_debug_pub.ADD('px_line_rec.original_item_identifier_type:'||px_line_rec.item_identifier_type,1);
	 oe_debug_pub.ADD('px_line_rec.original_ordered_item:'||px_line_rec.ordered_item,1);


      END IF;

      if px_line_rec.original_inventory_item_id is  null then
	 px_line_rec.original_inventory_item_id :=px_line_rec.INVENTORY_ITEM_ID;
	 px_line_rec.original_ordered_item_id :=px_line_rec.ORDERED_ITEM_ID;
	 px_line_rec.original_item_identifier_type :=px_line_rec.item_identifier_type;
	 px_line_rec.original_ordered_item :=px_line_rec.ordered_item;
	 px_line_rec.item_relationship_type :=14;
   end if;
/*sdatti*/


      -- There is an item upgrade for this line
      px_line_rec.inventory_item_id := p_related_item_id;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PX_LINE_REC.INVENTORY_ITEM_ID ='||PX_LINE_REC.INVENTORY_ITEM_ID ) ;
      END IF;
      px_line_rec.item_identifier_type := 'INT'; --bug 2281351
      If px_line_rec.item_identifier_type ='INT' then
         px_line_rec.ordered_item_id := p_related_item_id;
         Begin
                SELECT concatenated_segments
                INTO   px_line_rec.ordered_item
                FROM   mtl_system_items_kfv
                WHERE  inventory_item_id = px_line_rec.inventory_item_id
                  AND    organization_id = l_org_id;
          Exception when no_data_found then
             Null;
          End;
      End If;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING OE_ORDER_ADJ_PVT.SET_ITEM_FOR_IUE' ) ;
      END IF;
end set_item_for_iue;


Procedure delete_attribs_for_iue(p_price_adjustment_id in number)
is
  l_Line_Adj_rec  OE_Order_PUB.Line_Adj_Rec_Type;
  l_return_status         VARCHAR2(30);
  l_index    NUMBER;
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

begin
    l_Line_Adj_rec.operation := OE_GLOBALS.G_OPR_DELETE;
    l_Line_Adj_rec.price_adjustment_id := p_price_adjustment_id;
    OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_line_adj_rec =>l_line_adj_rec,
                    p_line_adj_id => l_line_adj_rec.price_adjustment_id,
                    p_old_line_adj_rec =>l_line_adj_rec,
                    x_index => l_index,
                    x_return_status => l_return_status);

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_ADV_PRICE_PVT.DELETE_ATTRIBS_FOR_IUE IS: ' || L_RETURN_STATUS ) ;
            END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
               oe_debug_pub.add(  'EXITING OE_ADV_PRICE_PVT.DELETE_ATTRIBS_FOR_IUE' , 1 ) ;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_ADV_PRICE_PVT.DELETE_ATTRIBS_FOR_IUE' ) ;
               oe_debug_pub.add(  'EXITING OE_ORDER_PRICE_PVT.DELETE_DEPENDENTS' , 1 ) ;
           END IF;
        RAISE FND_API.G_EXC_ERROR;
       END IF;

    DELETE FROM OE_PRICE_ADJ_ATTRIBS  WHERE price_adjustment_id  = p_price_adjustment_id;
End;

Procedure Item_Upgrade
        ( px_old_line_tbl  IN OUT NOCOPY        OE_ORDER_PUB.Line_Tbl_Type,
          px_line_tbl      IN OUT NOCOPY        OE_ORDER_PUB.Line_Tbl_Type,
          p_pricing_events IN  VARCHAR2
        )
IS

        Cursor upgraded_items IS
            SELECT ldets.line_detail_index,ldets.Line_index,ldets.related_item_id,lines.line_id
            FROM QP_LDETS_V ldets,
                 QP_PREQ_LINES_TMP lines
            WHERE ldets.list_line_Type_code /*created_from_list_line_type list_line_Type_code*/= 'IUE'
                AND      ldets.process_code IN (QP_PREQ_PUB.G_STATUS_NEW,
                                         QP_PREQ_PUB.G_STATUS_UPDATED)
    AND  lines.pricing_status_code in (QP_PREQ_GRP.G_STATUS_NEW,QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_GSA_VIOLATION)
    AND lines.process_status <> 'NOT_VALID'
    AND  ldets.line_index=lines.line_index;


             --amy: revert to original item if the IUE is deleted
         Cursor revert_back_items IS
               SELECT adj.line_id, adj.modified_from,adj.price_adjustment_id
               FROM OE_PRICE_ADJUSTMENTS adj
               WHERE HEADER_ID = oe_order_cache.g_header_rec.header_id
               AND list_line_Type_code = 'IUE'
               AND PRICING_PHASE_ID IN (select pricing_phase_id from qp_event_phases
                    where instr(p_pricing_events||',', pricing_event_code||',') >0)
               AND LINE_ID IN (select line_id
                       from qp_preq_lines_tmp where
                       line_type_code='LINE'
                       and price_flag  IN ('Y','P')
                       and process_status <> 'NOT_VALID'
                       and pricing_status_code in (QP_PREQ_PUB.G_STATUS_UPDATED,                                             QP_PREQ_PUB.G_STATUS_GSA_VIOLATION,                                             QP_PREQ_PUB.G_STATUS_UNCHANGED))
            /*  AND list_line_id NOT IN (SELECT list_line_id
                                       from qp_ldets_v where process_code
                                       IN (QP_PREQ_PUB.G_STATUS_UNCHANGED,QP_PREQ_PUB.G_STATUS_UPDATED) and line_index=adj.line_id+oe_order_cache.g_header_rec.header_id)*/
                AND list_line_id NOT IN (SELECT list_line_id
                                       from qp_ldets_v ld, qp_preq_lines_tmp l
                                       where ld.process_code
                                       IN (QP_PREQ_PUB.G_STATUS_UNCHANGED,QP_PREQ_PUB.G_STATUS_UPDATED) and l.line_index = ld.line_index
                                       and l.line_id = adj.line_id);



i              number;
l_header_id    number := oe_order_cache.g_header_rec.header_id;
l_mod_line_id  NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


        IF oe_order_cache.g_header_rec.booked_flag = 'Y' THEN
             RETURN;
        END IF;

        -- AmyIUE: let's revert back the following way
        FOR i in revert_back_items LOOP
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'REVERT BACK ITEM'||I.LINE_ID ) ;
             END IF;
-- 8631297
               l_mod_line_id := MOD(i.line_id,G_BINARY_LIMIT);
               oe_debug_pub.add(  '  mod line id :'|| l_mod_line_id,1);
               oe_debug_pub.add(  'line id :'|| G_PRICE_LINE_ID_TBL(l_mod_line_id));

-- 8631297
-- Replaced i.line_id with l_mod_line_id
          --bug 2858712
            IF (px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).line_set_id IS NULL OR
               px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).line_set_id = FND_API.G_MISS_NUM) THEN
             set_item_for_iue(px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)),to_number(i.modified_from));
             px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).operation := OE_GLOBALS.G_OPR_UPDATE;
   --bug 2795409
             px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).change_reason := 'SYSTEM';
             px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).change_comments := 'REPRICING';

        --bug 2858712
             DELETE FROM OE_PRICE_ADJUSTMENTS
              WHERE PRICE_ADJUSTMENT_ID = i.price_adjustment_id;
             delete_attribs_for_iue(i.price_adjustment_id);
            END IF;
        END LOOP;

        FOR i in upgraded_items LOOP

-- 8631297
                    l_mod_line_id := MOD(i.line_id,G_BINARY_LIMIT);
                    oe_debug_pub.add(  '  mod line id :'|| l_mod_line_id,1);

 /* change i.line_index - l_header_id with i.line_id */

-- 8631297
-- Replaced i.line_id with l_mod_line_id
           IF (px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).top_model_line_id IS NULL OR
               px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).top_model_line_id = FND_API.G_MISS_NUM) THEN
         --bug 2858712
             IF (px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).line_set_id IS NULL OR
               px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).line_set_id = FND_API.G_MISS_NUM) THEN

                set_item_for_iue(px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)),i.Related_Item_ID);
                px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).operation := OE_GLOBALS.G_OPR_UPDATE;
   --bug 2795409
                px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).change_reason := 'SYSTEM';
                px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).change_comments := 'REPRICING';

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
    ,     LIST_HEADER_ID
    ,     LIST_LINE_ID
    ,     LIST_LINE_TYPE_CODE
    ,     MODIFIER_MECHANISM_TYPE_CODE
    ,     MODIFIED_FROM
    ,     MODIFIED_TO
    ,     UPDATED_FLAG
    ,     UPDATE_ALLOWED
    ,     APPLIED_FLAG
    ,     CHANGE_REASON_CODE
    ,     CHANGE_REASON_TEXT
    ,     operand
    ,     Arithmetic_operator
    ,     COST_ID
    ,     TAX_CODE
    ,     TAX_EXEMPT_FLAG
    ,     TAX_EXEMPT_NUMBER
    ,     TAX_EXEMPT_REASON_CODE
    ,     PARENT_ADJUSTMENT_ID
    ,     INVOICED_FLAG
    ,     ESTIMATED_FLAG
    ,     INC_IN_SALES_PERFORMANCE
    ,     SPLIT_ACTION_CODE
    ,     ADJUSTED_AMOUNT
    ,     PRICING_PHASE_ID
    ,     CHARGE_TYPE_CODE
    ,     CHARGE_SUBTYPE_CODE
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
    ,     LOCK_CONTROL
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
    ,       decode(ldets.modifier_level_code,'ORDER',NULL,i.line_id)
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
    ,     ldets.LIST_HEADER_ID
    ,     ldets.LIST_LINE_ID
    ,     ldets.LIST_LINE_TYPE_CODE
    ,     NULL --p_Line_Adj_rec.MODIFIER_MECHANISM_TYPE_CODE
    ,     to_char(ldets.inventory_item_id)
    ,     to_char(ldets.related_item_id)
    ,     'N' --p_Line_Adj_rec.UPDATED_FLAG
    ,     ldets.override_flag
    ,     ldets.APPLIED_FLAG
    ,     NULL --p_Line_Adj_rec.CHANGE_REASON_CODE
    ,     NULL --p_Line_Adj_rec.CHANGE_REASON_TEXT
    ,     NULL
    ,     ldets.operand_calculation_code --p_Line_Adj_rec.arithmetic_operator
    ,     NULl --p_line_Adj_rec.COST_ID
    ,     NULL --p_line_Adj_rec.TAX_CODE
    ,     NULL --p_line_Adj_rec.TAX_EXEMPT_FLAG
    ,     NULL --p_line_Adj_rec.TAX_EXEMPT_NUMBER
    ,     NULL --p_line_Adj_rec.TAX_EXEMPT_REASON_CODE
    ,     NULL --p_line_Adj_rec.PARENT_ADJUSTMENT_ID
    ,     NULL --p_line_Adj_rec.INVOICED_FLAG
    ,     NULL --p_line_Adj_rec.ESTIMATED_FLAG
    ,     NULL --p_line_Adj_rec.INC_IN_SALES_PERFORMANCE
    ,     NULL --p_line_Adj_rec.SPLIT_ACTION_CODE
    ,     NULL
    ,     ldets.pricing_phase_id --p_line_Adj_rec.PRICING_PHASE_ID
    ,     ldets.CHARGE_TYPE_CODE
    ,     ldets.CHARGE_SUBTYPE_CODE
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
    ,       NULL
    ,       NULL
    ,       1
    FROM
         QP_LDETS_v ldets
    ,    QP_LIST_HEADERS_B QH
    WHERE
         ldets.line_detail_index = i.line_detail_index
    and  ldets.list_header_id=qh.list_header_id
    AND  ldets.process_code=QP_PREQ_GRP.G_STATUS_NEW
   );

    --AND  ldets.pricing_status_code = QP_PREQ_GRP.G_STATUS_NEW
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'in upgraded items cursor');
        oe_debug_pub.add(  'INSERTED '||SQL%ROWCOUNT||' ADJUSTMENTS' ) ;
    END IF;
   END IF;
  END IF;
 END LOOP;

END Item_Upgrade;



Procedure Term_Substitution
	( p_old_header_rec  IN                OE_ORDER_PUB.Header_Rec_Type,
          px_header_rec     IN OUT NOCOPY     OE_ORDER_PUB.Header_Rec_Type,
          px_old_line_tbl   IN OUT NOCOPY     OE_ORDER_PUB.Line_Tbl_Type,
          px_line_tbl       IN OUT NOCOPY     OE_ORDER_PUB.Line_Tbl_Type
        )
Is
        cursor oe_price_adj_cur(p_line_id  number) is
         select price_adjustment_id,LIST_LINE_ID,PRICING_PHASE_ID ,
            MODIFIER_LEVEL_CODE
          from oe_price_adjustments where
             line_id = p_line_id and LIST_LINE_TYPE_CODE = 'TSN';

        Cursor ldets_cur is
         select line_index,LINE_DETAIL_INDEX,LINE_DETAIL_TYPE_CODE,
         CREATED_FROM_LIST_LINE_ID,CREATED_FROM_LIST_LINE_TYPE,
         CREATED_FROM_LIST_TYPE_CODE,SUBSTITUTION_TYPE_CODE,
         SUBSTITUTION_VALUE_FROM,SUBSTITUTION_VALUE_TO,PROCESSED_FLAG,
         PRICING_STATUS_CODE,PRICING_PHASE_ID,APPLIED_FLAG,PROCESS_CODE,
         UPDATED_FLAG
              from qp_preq_ldets_tmp where
            CREATED_FROM_LIST_LINE_TYPE = 'TSN';
        Cursor test is
          select Line_index,substitution_attribute,substitution_value_to,
          process_code
          FROM QP_LDETS_V
           WHERE list_line_type_code = 'TSN';
	Cursor new_terms IS
	SELECT ldets.Line_index, ldets.line_detail_index, lines.line_id --bug 4190357 added line_detail_index
	, ldets.substitution_attribute, ldets.substitution_value_to
        ,CHANGE_REASON_CODE,CHANGE_REASON_TEXT
        ,lines.line_type_code --bug 4190357
	FROM QP_LDETS_V ldets, qp_preq_lines_tmp lines
	WHERE ldets.list_line_type_code = 'TSN'
	AND      ldets.process_code IN (QP_PREQ_PUB.G_STATUS_NEW
                                        , QP_PREQ_PUB.G_STATUS_UPDATED
                                        )
        AND ldets.Line_index = lines.Line_index
        order by ldets.line_index ASC;

	i              number;
	l_header_id    number := oe_order_cache.g_header_rec.header_id;
        l_mod_line_id  NUMBER;
        j              number;
        k              number;
        l              number;
        vcount         number;
        m              number;
   --     l_header_rec   OE_ORDER_PUB.Header_Rec_Type := oe_order_cache.g_header_rec;
          --bug 4190357
          l_count        NUMBER;
          --bug 4190357
          l_old_shipping_method_code Varchar2(30); --bug 4190357
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
	BEGIN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'IN TERMS SUBSTITUTION' , 1 ) ;
        END IF;

       If G_DEBUG Then
        for l in ldets_cur loop
                 oe_debug_pub.add(  'LINE_INDEX='||L.LINE_INDEX , 1 ) ;
                 oe_debug_pub.add(  'LINE_DETAIL_INDEX='||L.LINE_DETAIL_INDEX , 1 ) ;
                 oe_debug_pub.add(  'LINE_DETAIL_TYPE_CODE='||L.LINE_DETAIL_TYPE_CODE , 1 ) ;
                 oe_debug_pub.add(  'CREATED_FROM_LIST_LINE_ID='||L.CREATED_FROM_LIST_LINE_ID , 1 ) ;
                 oe_debug_pub.add(  'CREATED_FROM_LIST_LINE_TYPE='||L.CREATED_FROM_LIST_LINE_TYPE , 1 ) ;
                 oe_debug_pub.add(  'CREATED_FROM_LIST_TYPE_CODE='||L.CREATED_FROM_LIST_TYPE_CODE , 1 ) ;
                 oe_debug_pub.add(  'SUBSTITUTION_TYPE_CODE='||L.SUBSTITUTION_TYPE_CODE , 1 ) ;
                 oe_debug_pub.add(  'SUBSTITUTION_VALUE_FROM='||L.SUBSTITUTION_VALUE_FROM , 1 ) ;
                 oe_debug_pub.add(  'SUBSTITUTION_VALUE_TO='||L.SUBSTITUTION_VALUE_TO , 1 ) ;
                 oe_debug_pub.add(  'PROCESSED_FLAG='||L.PROCESSED_FLAG , 1 ) ;
                 oe_debug_pub.add(  'PRICING_STATUS_CODE='||L.PRICING_STATUS_CODE , 1 ) ;
                 oe_debug_pub.add(  'PRICING_PHASE_ID='||L.PRICING_PHASE_ID , 1 ) ;
                 oe_debug_pub.add(  'APPLIED_FLAG='||L.APPLIED_FLAG , 1 ) ;
                 oe_debug_pub.add(  'PROCESS_CODE='||L.PROCESS_CODE , 1 ) ;
                 oe_debug_pub.add(  'UPDATED_FLAG='||L.UPDATED_FLAG , 1 ) ;

         end loop;

        for k in test loop
              oe_debug_pub.add(  'LINE_INDEX = '||K.LINE_INDEX , 1 ) ;
              oe_debug_pub.add(  'SUBSTITUTION_ATTRIBUTE = '||K.SUBSTITUTION_ATTRIBUTE , 1 ) ;
              oe_debug_pub.add(  'SUBSTITUTION_VALUE_TO = '||K.SUBSTITUTION_VALUE_TO , 1 ) ;
              oe_debug_pub.add(  'PROCESS_CODE = '||K.PROCESS_CODE , 1 ) ;
        end loop;
       End If;  --end if for g_debug

--6965002 start
              px_header_rec.change_reason := 'SYSTEM';
              px_header_rec.change_comments := 'REPRICING';
--6965002 end


	FOR i in new_terms LOOP
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'L_HEADER_ID = '||L_HEADER_ID , 1 ) ;
              oe_debug_pub.add(  'LINE INDEX = '||I.LINE_INDEX , 1 ) ;
              oe_debug_pub.add(  'SUBSTITUTION_ATTRIBUTE = '||I.SUBSTITUTION_ATTRIBUTE , 1 ) ;
              oe_debug_pub.add(  'SUBSTITUTION_VALUE_TO = '||I.SUBSTITUTION_VALUE_TO , 1 ) ;
             oe_debug_pub.add('change rason code = '||I.CHANGE_REASON_CODE);
             oe_debug_pub.add('change reason text = '||I.CHANGE_REASON_TEXT);
          END IF;

	-- for header level term substitution, needs to update all lines
	IF (i.line_id = l_header_id and i.line_type_code = 'ORDER') THEN
          --bug 4190357
          l_count := 0;
          --bug 4190357
          if i.Substitution_Attribute ='QUALIFIER_ATTRIBUTE1' Then
             px_header_rec.payment_term_id := i.Substitution_value_to;
          elsIf i.Substitution_Attribute ='QUALIFIER_ATTRIBUTE11' Then
               l_old_shipping_method_code := px_header_rec.shipping_method_code;
               px_header_rec.shipping_method_code := i.Substitution_value_to;
               --bug 4190357
               SELECT count(*)
                 INTO   l_count
                 FROM   wsh_carrier_services wsh,
                        wsh_org_carrier_services wsh_org
                 WHERE  wsh_org.organization_id      = px_header_rec.ship_from_org_id
                   AND  wsh.carrier_service_id       = wsh_org.carrier_service_id
                   AND  wsh.ship_method_code         = px_header_rec.shipping_method_code
                   AND  wsh_org.enabled_flag         = 'Y';
                --bug 4190357
          elsIf i.Substitution_Attribute ='QUALIFIER_ATTRIBUTE10' Then
               px_header_rec.freight_terms_code := i.Substitution_value_to;
          End If;
          px_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
	-- LOOP through all lines, update terms on the line
           j := px_line_tbl.FIRST;
           WHILE j Is Not Null loop
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'J = '||J , 1 ) ;
                  oe_debug_pub.add(  'LINE ID = '||PX_LINE_TBL ( J ) .LINE_ID , 1 ) ;
                  oe_debug_pub.add(  'INDEX IN SORTED TABLE = '||G_PRICE_LINE_ID_TBL(MOD( PX_LINE_TBL ( J ) .LINE_ID,G_BINARY_LIMIT)),1);   -- BUG 8631297
              END IF;

              If G_DEBUG Then
               for m in oe_price_adj_cur(px_line_tbl(j).line_id) loop
                     oe_debug_pub.add(  'PRICE_ADJUSTMENT_ID='||M.PRICE_ADJUSTMENT_ID , 1 ) ;
                     oe_debug_pub.add(  'LIST_LINE_ID='||M.LIST_LINE_ID , 1 ) ;
                     oe_debug_pub.add(  'PRICING_PHASE_ID='||M.PRICING_PHASE_ID , 1 ) ;
                     oe_debug_pub.add(  'MODIFIER_LEVEL_CODE='||M.MODIFIER_LEVEL_CODE , 1 ) ;
                end loop;
              End If;

             --bug 4271297   update line only if open  and not cancelled
	       if( nvl(px_line_tbl(j).cancelled_flag,'N') <> 'Y' and nvl(px_line_tbl(j).open_flag,'Y') <> 'N' ) THEN
	     if (l_debug_level > 0) then
                   oe_debug_pub.add(  'Lalit As the line in not closed/cancelled updating LINE ID = '||PX_LINE_TBL ( J ) .LINE_ID , 1 ) ;
	     end if;
              select count(*) into vcount from oe_price_adjustments where
               line_id = px_line_tbl(j).line_id and
               LIST_LINE_TYPE_CODE = 'TSN' and MODIFIER_LEVEL_CODE = 'LINE';
               If vcount = 0 then
              If i.Substitution_Attribute ='QUALIFIER_ATTRIBUTE1' Then
                  px_line_tbl(j).payment_term_id := i.Substitution_value_to;
              elsIf i.Substitution_Attribute ='QUALIFIER_ATTRIBUTE11' Then
                 --bug 4190357 added the if - else
                  IF l_count <> 0 THEN
                     px_line_tbl(j).shipping_method_code := i.Substitution_value_to;
                  ELSE
                     --px_line_tbl(j).shipping_method_code := NULL;
                     null;
                  END IF;
              elsIf i.Substitution_Attribute ='QUALIFIER_ATTRIBUTE10' Then
                  px_line_tbl(j).freight_terms_code := i.Substitution_value_to;
              End If;
              px_line_tbl(j).operation := OE_GLOBALS.G_OPR_UPDATE;
   --bug 2795409
              px_line_tbl(j).change_reason := 'SYSTEM';
              px_line_tbl(j).change_comments := 'REPRICING';
            END IF;  -- bug 4271297
             end if;
              j := px_line_tbl.Next(j);

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'J = END OF LOOP '||J , 1 ) ;
              END IF;

           END LOOP;

	   -- END LOOP;
	ELSE --for line level term substitution, need to update the line
	   l_mod_line_id := MOD(i.line_id,G_BINARY_LIMIT); -- Bug 8631297
          -- Replaced i.line_id with l_mod_line_id in the following 7 lines.
	   If i.Substitution_Attribute ='QUALIFIER_ATTRIBUTE1' Then
              px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).payment_term_id :=  i.Substitution_value_to;
           elsIf i.Substitution_Attribute ='QUALIFIER_ATTRIBUTE11' Then
              l_old_shipping_method_code := px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).shipping_method_code;
              px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).shipping_method_code :=  i.Substitution_value_to;
           elsIf i.Substitution_Attribute ='QUALIFIER_ATTRIBUTE10' Then
              px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).freight_terms_code :=  i.Substitution_value_to;
        End If;
        px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).operation := OE_GLOBALS.G_OPR_UPDATE;
  --bug 2795409
       px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).change_reason := 'SYSTEM';
       px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).change_comments := 'REPRICING';
  End If;
--bug 4190357
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
    ,     LIST_HEADER_ID
    ,     LIST_LINE_ID
    ,     LIST_LINE_TYPE_CODE
    ,     MODIFIER_MECHANISM_TYPE_CODE
    ,     MODIFIED_FROM
    ,     MODIFIED_TO
    ,     UPDATED_FLAG
    ,     UPDATE_ALLOWED
    ,     APPLIED_FLAG
    ,     CHANGE_REASON_CODE
    ,     CHANGE_REASON_TEXT
    ,     operand
    ,     Arithmetic_operator
    ,     COST_ID
    ,     TAX_CODE
    ,     TAX_EXEMPT_FLAG
    ,     TAX_EXEMPT_NUMBER
    ,     TAX_EXEMPT_REASON_CODE
    ,     PARENT_ADJUSTMENT_ID
    ,     INVOICED_FLAG
    ,     ESTIMATED_FLAG
    ,     INC_IN_SALES_PERFORMANCE
    ,     SPLIT_ACTION_CODE
    ,     ADJUSTED_AMOUNT
    ,     PRICING_PHASE_ID
    ,     CHARGE_TYPE_CODE
    ,     CHARGE_SUBTYPE_CODE
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
    ,     LOCK_CONTROL
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
    ,       decode(ldets.modifier_level_code,'ORDER',NULL,i.line_id)
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
    ,     ldets.LIST_HEADER_ID
    ,     ldets.LIST_LINE_ID
    ,     ldets.LIST_LINE_TYPE_CODE
    ,     NULL --p_Line_Adj_rec.MODIFIER_MECHANISM_TYPE_CODE
    ,     l_old_shipping_method_code
    ,     i.Substitution_value_to
    ,     'N' --p_Line_Adj_rec.UPDATED_FLAG
    ,     ldets.override_flag
    ,     ldets.APPLIED_FLAG
    ,     NULL --p_Line_Adj_rec.CHANGE_REASON_CODE
    ,     NULL --p_Line_Adj_rec.CHANGE_REASON_TEXT
    ,     NULL
    ,     ldets.operand_calculation_code --p_Line_Adj_rec.arithmetic_operator
    ,     NULl --p_line_Adj_rec.COST_ID
    ,     NULL --p_line_Adj_rec.TAX_CODE
    ,     NULL --p_line_Adj_rec.TAX_EXEMPT_FLAG
    ,     NULL --p_line_Adj_rec.TAX_EXEMPT_NUMBER
    ,     NULL --p_line_Adj_rec.TAX_EXEMPT_REASON_CODE
    ,     NULL --p_line_Adj_rec.PARENT_ADJUSTMENT_ID
    ,     NULL --p_line_Adj_rec.INVOICED_FLAG
    ,     NULL --p_line_Adj_rec.ESTIMATED_FLAG
    ,     NULL --p_line_Adj_rec.INC_IN_SALES_PERFORMANCE
    ,     NULL --p_line_Adj_rec.SPLIT_ACTION_CODE
    ,     NULL
    ,     ldets.pricing_phase_id --p_line_Adj_rec.PRICING_PHASE_ID
    ,     ldets.CHARGE_TYPE_CODE
    ,     ldets.CHARGE_SUBTYPE_CODE
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
    ,       NULL
    ,       NULL
    ,       1
    FROM
         QP_LDETS_v ldets
    ,    QP_LIST_HEADERS_B QH
    WHERE
         ldets.line_detail_index = i.line_detail_index
    and  ldets.list_header_id=qh.list_header_id
    AND  ldets.process_code=QP_PREQ_GRP.G_STATUS_NEW
   );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'in new_terms cursor');
        oe_debug_pub.add(  'INSERTED '||SQL%ROWCOUNT||' ADJUSTMENTS' ) ;
    END IF;
--bug 4190357
End Loop;
END Term_Substitution;

Procedure Set_Prg(
 px_line_rec IN OUT NOCOPY OE_Order_Pub.line_rec_type
, p_line_id IN QP_PREQ_LINES_TMP.line_id%TYPE
, p_line_index IN QP_PREQ_LINES_TMP.line_index%TYPE
, p_line_quantity IN QP_PREQ_LINES_TMP.line_quantity%TYPE
, p_line_uom_code IN QP_PREQ_LINES_TMP.line_uom_code%TYPE
, p_unit_price IN QP_PREQ_LINES_TMP.unit_price%TYPE
, p_adjusted_unit_price IN QP_PREQ_LINES_TMP.adjusted_unit_price%TYPE
, p_line_unit_price IN QP_PREQ_LINES_TMP.line_unit_price%TYPE
, p_order_uom_selling_price IN QP_PREQ_LINES_TMP.order_uom_selling_price%TYPE
, p_line_category IN QP_PREQ_LINES_TMP.line_category%TYPE
, p_priced_quantity IN QP_PREQ_LINES_TMP.priced_quantity%TYPE
, p_price_list_header_id IN QP_PREQ_LINES_TMP.price_list_header_id%TYPE
, p_percent_price IN QP_PREQ_LINES_TMP.percent_price%TYPE
, p_priced_uom_code IN QP_PREQ_LINES_TMP.priced_uom_code%TYPE
, p_price_request_code IN QP_PREQ_LINES_TMP.price_request_code%TYPE
)
IS
l_line_rec Oe_Order_Pub.line_rec_type := px_line_rec;
l_org_id Number:= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
l_tot_qty        OE_ORDER_LINES_ALL.ordered_quantity%TYPE;
l_tot_price_qty  OE_ORDER_LINES_ALL.pricing_quantity%TYPE;
l_pricing_event varchar2(30);
l_return_status varchar2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_org ORG_ORGANIZATION_DEFINITIONS.ORGANIZATION_NAME%TYPE;
l_modifier QP_LIST_HEADERS_TL.NAME%TYPE;
l_list_line_no QP_LIST_LINES.LIST_LINE_NO%TYPE;
Begin
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SET PRG'||L_LINE_REC.OPERATION||' qty'||p_line_quantity ) ;
        END IF;
        if p_line_quantity < 0
         and
         ( p_line_category is null or
           p_line_category  = 'ORDER'
           )  then
         l_line_rec.line_category_code := 'RETURN' ;
         l_line_rec.return_reason_code := 'RETURN' ;
        elsif p_line_quantity < 0 and p_line_category = 'RETURN' then
         l_line_rec.line_category_code := 'ORDER';
        elsif p_line_category is not null then
         l_line_rec.line_category_code := p_line_category;
        else
          l_line_rec.line_category_code := 'ORDER';
        end if;
   --for bug 2412868  end
        -- uom begin
        l_line_rec.unit_selling_price_per_pqty := p_adjusted_unit_price ;
        l_line_rec.unit_list_price_per_pqty := p_unit_price ;
       --for bug 2412868 begin
        if l_line_rec.unit_selling_price_per_pqty < 0 then
        l_line_rec.unit_selling_price_per_pqty :=
         abs(p_adjusted_unit_price ) ;
        l_line_rec.unit_list_price_per_pqty :=
         abs(p_unit_price );
        end if;
       --for bug 2412868  end
        l_line_rec.unit_list_percent := p_percent_price ;
                if  nvl(p_percent_price,0) <> 0 then
                l_line_rec.unit_selling_percent :=
                                 ( l_line_rec.unit_selling_price_per_pqty * l_line_rec.unit_list_percent)/
                                p_percent_price ;
                end if;
  /*
   IF (l_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
    begin
      select nvl(sum(ordered_quantity),0),nvl(sum(pricing_quantity),0)
      into l_tot_qty,l_tot_price_qty
      from oe_order_lines
      where split_from_line_id = l_line_rec.line_id
      and  header_id = l_line_rec.header_id;
     exception
      when others then
       null;
     end;
     l_line_rec.pricing_quantity :=
         p_priced_quantity - nvl(l_tot_price_qty,0);
     l_line_rec.ordered_quantity :=
          p_line_quantity - nvl(l_tot_qty,0);
     ELSE
  */

        l_line_rec.pricing_quantity := p_priced_quantity ;
        l_line_rec.Ordered_Quantity := p_line_quantity ;
     --END IF;

     --for bug 2412868  begin
 if l_line_rec.pricing_quantity < 0 and l_line_rec.Ordered_quantity < 0
 then
    l_line_rec.pricing_quantity := abs(l_line_rec.pricing_quantity);
    l_line_rec.ordered_quantity := abs(l_line_rec.ordered_quantity);
  end if;

     --for bug 2412868  end
        l_line_rec.pricing_quantity_uom := p_priced_uom_code ;
        l_line_rec.unit_list_price := nvl(p_line_unit_price,
                                      l_line_rec.unit_list_price_per_pqty
                                      * l_line_rec.pricing_quantity
                                      / nvl(l_line_rec.ordered_quantity, 1));
        l_line_rec.unit_selling_price := nvl(p_order_uom_selling_price,
                                       l_line_rec.unit_selling_price_per_pqty
                                      * l_line_rec.pricing_quantity
                                      / nvl(l_line_rec.ordered_quantity,1));
        l_line_rec.price_request_code := p_price_request_code;

        --Why hardcode to INT ?
        l_line_rec.item_identifier_type := 'INT';

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RLANKA: SETTING ORDERED QUANTITY UOM' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UOM = ' || P_LINE_UOM_CODE ) ;
        END IF;
        l_line_rec.order_quantity_uom := p_line_uom_code;

        --end Bug 1805134

        l_line_rec.price_list_id := p_price_list_header_id;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'PRG_LINES'||L_LINE_REC.OPERATION ) ;
        END IF;

                                G_STMT_NO := 'Process_Other_Item_Line#140';
                                Begin
                                        SELECT attr.value_from
                                        INTO l_line_rec.inventory_item_id
                                        FROM qp_preq_line_attrs_tmp attr
                                        WHERE attr.context = 'ITEM'
                                        AND attr.attribute =
                                                                    'PRICING_ATTRIBUTE1'
                                        AND attr.line_index = p_line_index;
                                Exception When no_data_found Then
                                  Null;
                                End;

                                Begin

                                        SELECT   concatenated_segments
                                        INTO   l_line_rec.ordered_item
                                        FROM   mtl_system_items_kfv
                                        WHERE  inventory_item_id = l_line_rec.inventory_item_id
                                        AND    organization_id = l_org_id;
                                        Exception when no_data_found then
                                          FND_MESSAGE.SET_NAME('ONT', 'ONT_PRG_INVALID_MASTER_ORG');
                                          SELECT QH.NAME, LDET.LIST_LINE_NO
                                          INTO l_modifier
                                             , l_list_line_no
                                          FROM QP_PREQ_RLTD_LINES_TMP RLTD
                                              ,QP_LDETS_V LDET
                                              , QP_LIST_HEADERS_TL QH
                                          WHERE RLTD.RELATED_LINE_INDEX = p_line_index
                                           AND RLTD.RELATIONSHIP_TYPE_CODE = 'GENERATED_LINE'
                                           AND RLTD.LINE_DETAIL_INDEX = LDET.LINE_DETAIL_INDEX
                                           AND LDET.LIST_HEADER_ID = QH.LIST_HEADER_ID AND ROWNUM=1;


                                          FND_MESSAGE.SET_TOKEN('MODIFIER', l_modifier);
                                          FND_MESSAGE.SET_TOKEN('LIST_LINE_NO', l_list_line_no);
                                          FND_MESSAGE.SET_TOKEN('ITEM', l_line_rec.inventory_item_id);
                                          BEGIN
                                            SELECT ORGANIZATION_NAME
                                            INTO l_org
                                            FROM ORG_ORGANIZATION_DEFINITIONS
                                            WHERE ORGANIZATION_ID = l_org_id;
                                          EXCEPTION WHEN OTHERS THEN
                                            l_org := l_org_id;
                                          END;
                                          FND_MESSAGE.SET_TOKEN('ORG', l_org);
                                          OE_MSG_PUB.ADD;
                                          l_line_rec.operation := OE_GLOBALS.G_OPR_NONE;
                                          QP_UTIL_PUB.Update_Lines('MAKE_STATUS_INVALID',l_line_rec.line_id,
                                                                    NULL,NULL);
                                End;

        /*
          Fix for Bug 1729372 : Change calculate_price_flag to 'R'
          so that charges can be applied to the new line.  This will be
          handled in OEXULINB.pls
        */

        IF l_line_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          l_line_rec.calculate_price_flag := 'R';
        ELSIF (l_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
          if nvl(l_line_rec.booked_flag, 'N') = 'Y' then
            l_pricing_event := 'BATCH,BOOK';
          else
            l_pricing_event := 'BATCH';
          end if;

	 l_line_rec.ordered_quantity2 := null; -- 8459311

          OE_delayed_requests_Pvt.log_request(
                p_entity_code           =>OE_GLOBALS.G_ENTITY_ALL,
                p_entity_id             => l_line_rec.line_Id,
                p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                p_requesting_entity_id   => l_line_rec.line_Id,
                p_request_unique_key1   => l_pricing_event,
                p_param1                 => l_line_rec.header_id,
                p_param2                 => l_pricing_event,
                p_request_type           => OE_GLOBALS.G_PRICE_LINE,
                x_return_status          => l_return_status);
           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'unexp error logging batch event for updated free goods line', 3) ;
                 oe_debug_pub.add(  'EXITING OE_ADV_PRICE_PVT.set_prg', 3);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'error logging batch event for update free goods line',3);
                oe_debug_pub.add(  'EXITING OE_ADV_PRICE_PVT.set_prg' , 1 ) ;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;

        px_line_rec := l_line_rec;
exception when others then
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'ERROR IN SET_PRG'||SQLERRM ) ;
 END IF;
 raise fnd_api.g_exc_error;
end Set_Prg;

Procedure Delete_Prg(
 px_line_rec IN OUT NOCOPY OE_Order_Pub.line_rec_type
)
IS
l_line_rec OE_Order_Pub.line_rec_type := px_line_rec;
l_pricing_event varchar2(30);
l_return_status varchar2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
      IF (nvl(l_line_rec.booked_flag, 'N') = 'N') Then
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'DELETE UNBOOKED ORDER' ) ;
	 END IF;
        l_line_rec.operation := OE_GLOBALS.G_OPR_DELETE;
      ELSE
        l_line_rec.change_reason := 'SYSTEM';
        l_line_rec.change_comments := 'REPRICING';
        IF (l_line_rec.shipped_quantity IS NULL) THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'CANCEL BOOKED ORDER , LINE NOT SHIPPED' ) ;
	 END IF;
	 l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
         BEGIN
           IF OE_CODE_CONTROL.Get_Code_Release_Level < '110510' THEN
              UPDATE QP_PREQ_LINES_TMP
              SET PROCESS_STATUS='NOT_VALID'
              WHERE LINE_ID = l_line_rec.line_id;
           ELSE
              QP_UTIL_PUB.Update_Lines('MAKE_STATUS_INVALID',l_line_rec.line_id,
                                   NULL,NULL);
           END IF;
         EXCEPTION
           WHEN OTHERS THEN
           NULL;
         END;
  	 l_line_rec.ordered_quantity := 0;
	 l_line_rec.pricing_quantity := 0;
        ELSE
      	 IF l_debug_level  > 0 THEN
      	     oe_debug_pub.add(  'REPRICE BOOKED ORDER , SHIPPED LINE' ) ;
      	 END IF;
	 l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
	 l_line_rec.calculate_price_flag := 'Y';
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'LOGGING DELAYED REQUEST TO PRICE LINE' ) ;
         END IF;

          l_pricing_event := 'BATCH,BOOK';
	  OE_delayed_requests_Pvt.log_request(
                p_entity_code           =>OE_GLOBALS.G_ENTITY_ALL,
                p_entity_id             => l_line_rec.line_Id,
                p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                p_requesting_entity_id   => l_line_rec.line_Id,
                p_request_unique_key1   => l_pricing_event,
                p_param1                 => l_line_rec.header_id,
                p_param2                 => l_pricing_event,
                p_request_type           => OE_GLOBALS.G_PRICE_LINE,
                x_return_status          => l_return_status);

       end if;
     end if;
     px_line_rec := l_line_rec;
Exception
When Others then
  Raise FND_API.G_EXC_ERROR;
End Delete_Prg;

procedure Process_PRG(px_line_Tbl in out nocopy oe_order_pub.line_tbl_type
, px_old_line_tbl in out nocopy oe_order_pub.line_tbl_type
, px_price_line_id_tbl IN OUT NOCOPY Oe_Order_Adj_Pvt.Index_Tbl_Type
)
IS
cursor prg_lines IS
select line_id
, line_index
, line_quantity
, line_uom_code
, unit_price
, adjusted_unit_price
, line_unit_price
, order_uom_selling_price
, process_status
, line_category
, priced_quantity
, price_list_header_id
, percent_price
, priced_uom_code
, price_request_code
From qp_preq_lines_tmp
where
--processed_code = 'ENGINE';
process_status IN (QP_PREQ_PUB.G_STATUS_NEW
                       , QP_PREQ_PUB.G_STATUS_UPDATED
                       , QP_PREQ_PUB.G_STATUS_DELETED
                       , 'FREEGOOD'
                      );
l_line_rec oe_order_pub.line_rec_type;
l_buy_line_rec oe_order_pub.line_rec_type;
l_parent_line_index pls_integer;
l_parent_line_id number ; -- pls_integer; bug 8631297
l_return_status varchar2(1);
E_CLOSED_LINE Exception;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_tot_qty        OE_ORDER_LINES_ALL.ordered_quantity%TYPE ;
l_tot_price_qty  OE_ORDER_LINES_ALL.pricing_quantity%TYPE ;
l_ordered_quantity OE_ORDER_LINES_ALL.ordered_quantity%TYPE;
l_pricing_quantity OE_ORDER_LINES_ALL.pricing_quantity%TYPE;
l_mod_line_id  NUMBER;

Begin
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING PRG_LINES' ) ;
  END IF;

  For i in prg_lines Loop
    -- 8631297

    IF i.line_id IS NOT NULL THEN
       l_mod_line_id := MOD(i.line_id,G_BINARY_LIMIT);
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  '  mod line id :'|| l_mod_line_id,1);
        oe_debug_pub.add(  'PRG LINE:'||I.LINE_ID||' PROCESS STATUS: '||I.PROCESS_STATUS ) ;
    END IF;

-- 8631297

    If (i.Process_status = QP_PREQ_PUB.G_STATUS_DELETED) THEN
      l_line_rec := px_line_tbl(px_price_line_id_tbl(l_mod_line_id));
      Delete_Prg(l_line_rec);
      px_line_tbl(px_price_line_id_tbl(l_mod_line_id)) := l_line_rec;
    Elsif (i.Process_Status = 'FREEGOOD'
     and nvl(px_line_tbl(px_price_line_id_tbl(l_mod_line_id)).cancelled_quantity, 0) = 0) THEN
      Null;
    Elsif (i.Process_Status = QP_PREQ_PUB.G_STATUS_UPDATED
        OR i.Process_Status = 'FREEGOOD') THEN
      l_line_rec := px_line_tbl(px_price_line_id_tbl(l_mod_line_id));
      If l_line_rec.open_flag = 'N' Then
        Raise E_Closed_Line;
      End If;

    begin
      select nvl(sum(ordered_quantity + nvl(cancelled_quantity,0)),0),nvl(sum(pricing_quantity + nvl(cancelled_quantity,0)),0)
      into l_tot_qty,l_tot_price_qty
      from oe_order_lines
      where split_from_line_id = l_line_rec.line_id
      and  header_id = l_line_rec.header_id;
     exception
      when others then
        l_tot_qty := 0;
        l_tot_price_qty := 0;
       null;
     end;
     l_pricing_quantity :=
         i.priced_quantity - nvl(l_tot_price_qty,0);
     l_ordered_quantity :=
          i.line_quantity - nvl(l_tot_qty,0);


           IF l_debug_level  > 0 THEN
            oe_debug_pub.add('priced quantity:'||l_pricing_quantity);
            oe_debug_pub.add(  'ordered_quantity:Cancelled_quantity'||l_ordered_quantity||':'||l_line_rec.cancelled_quantity ) ;
        END IF;
     if (l_ordered_quantity <= nvl(l_line_rec.cancelled_quantity, 0)) Then
        oe_line_util.update_adjustment_flags(l_line_rec, l_line_rec);
        Delete_Prg(l_line_rec);
     else
       l_ordered_quantity := l_ordered_quantity - nvl(l_line_rec.cancelled_quantity, 0);
       l_pricing_quantity := l_pricing_quantity - nvl(l_line_rec.cancelled_quantity, 0);
        IF nvl(l_line_rec.cancelled_quantity, 0) > 0 THEN
        BEGIN
          IF OE_CODE_CONTROL.Get_Code_Release_Level < '110510' THEN
             UPDATE QP_PREQ_LINES_TMP
             SET PRICED_QUANTITY = l_pricing_quantity
             where line_id = l_line_rec.line_id;
          ELSE
             QP_UTIL_PUB.Update_Lines('UPDATE_PRICED_QUANTITY',l_line_rec.line_id,null,l_pricing_quantity);
          END IF;
        EXCEPTION
         WHEN OTHERS THEN
          NULL;
        END;
        END IF;
         l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
         l_line_rec.change_reason := 'SYSTEM';
         l_line_rec.change_comments := 'REPRICING';
         Set_PRG(
                l_line_rec
               , i.line_id
               , i.line_index
               , l_ordered_quantity
               , i.line_uom_code
               , i.unit_price
               , i.adjusted_unit_price
               , i.line_unit_price
               , i.order_uom_selling_price
               , i.line_category
               , l_pricing_quantity
               , i.price_list_header_id
               , i.percent_price
               , i.priced_uom_code
               , i.price_request_code
                );
      End If; -- cancelled_quantity larger than ordered_quantity?
     IF (l_line_rec.operation <> OE_GLOBALS.G_OPR_NONE) THEN
        px_line_tbl(px_price_line_id_tbl(l_mod_line_id)) := l_line_rec;    -- Bug 8631297
      END IF;
    Elsif (i.Process_Status = QP_PREQ_PUB.G_STATUS_NEW) THEN
         l_line_rec:=OE_ORDER_PUB.G_MISS_LINE_REC;
         l_line_rec.cancelled_quantity := 0;
         l_line_rec.operation := OE_GLOBALS.G_OPR_CREATE;
         l_line_rec.Header_id := oe_order_cache.g_header_rec.header_id;
         l_line_rec.line_id := OE_DEFAULT_LINE.get_line;
         --for Bug 3350425. To Prevent Blanket feilds being defaulting from Header.
         l_line_rec.blanket_number:=NULL;
         l_line_rec.blanket_line_number:=NULL;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NEW LINE ID'||L_LINE_REC.LINE_ID ) ;
         END IF;
         --bug 4234500
         l_line_rec.change_reason := 'SYSTEM';
         l_line_rec.change_comments := 'REPRICING';
         --bug 4234500

         BEGIN
           IF OE_CODE_CONTROL.Get_Code_Release_Level < '110510' THEN
              UPDATE QP_PREQ_LINES_TMP
              SET LINE_ID = l_line_rec.line_id
              where line_index = i.line_index;
           ELSE
              QP_UTIL_PUB.Update_Lines('UPDATE_LINE_ID', l_line_rec.line_id,
                                     i.line_index, null);
           END IF;
         END;

         BEGIN
          SELECT rltd.line_index
          INTO l_parent_line_index
          FROM qp_preq_rltd_lines_tmp rltd
          WHERE rltd.related_line_index = i.line_index
          AND relationship_type_code = 'GENERATED_LINE' and rownum=1;

          SELECT line_id
          INTO l_parent_line_id
          FROM qp_preq_lines_tmp
          WHERE line_index = l_parent_line_index;

          l_buy_line_rec := px_line_tbl(px_price_line_id_tbl(MOD(l_parent_line_id, G_BINARY_LIMIT)));   --BUG 8631297
          If l_buy_line_rec.line_category_code = 'RETURN' and l_buy_line_rec.return_reason_code is Not Null Then
            l_line_rec.return_reason_code := l_buy_line_rec.return_reason_code;
          End If;

          -- put into the same ship set
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'PUTTING TO SHIP SET'||L_BUY_LINE_REC.SHIP_SET_ID ) ;
          END IF;
          l_line_rec.ship_set_id := l_buy_line_rec.ship_set_id;
         --bug 7000338/7002146
         IF (l_buy_line_rec.ship_set_id is NOT NULL AND l_buy_line_rec.ship_set_id <> FND_API.G_MISS_NUM) THEN
  		select set_name INTO l_line_rec.ship_set  from oe_sets where set_id= l_buy_line_rec.ship_set_id ;
		oe_debug_pub.add(  'PUTTING TO SHIP SET name'||L_LINE_REC.SHIP_SET ) ;
	 END IF;

	 EXCEPTION WHEN NO_DATA_FOUND THEN
            NULL;
         END;

        Set_PRG(
                l_line_rec
               , i.line_id
               , i.line_index
               , i.line_quantity
               , i.line_uom_code
               , i.unit_price
               , i.adjusted_unit_price
               , i.line_unit_price
               , i.order_uom_selling_price
               , i.line_category
               , i.priced_quantity
               , i.price_list_header_id
               , i.percent_price
               , i.priced_uom_code
               , i.price_request_code
               );
     IF (l_line_rec.operation <> OE_GLOBALS.G_OPR_NONE) THEN
        -- Display the PRG Item
         FND_MESSAGE.SET_NAME('ONT','ONT_CREATED_NEW_LINE');
         FND_MESSAGE.SET_TOKEN('ITEM',nvl(l_line_rec.ordered_item,l_line_rec.inventory_item_id));
         --bug 2412868  begin
         if l_line_rec.line_category_code = 'RETURN' then
           FND_MESSAGE.SET_TOKEN('QUANTITY',(-1) * l_line_rec.Ordered_quantity);
         else
         --bug 2412868  end
           FND_MESSAGE.SET_TOKEN('QUANTITY',l_line_rec.Ordered_quantity);
         end if;
         OE_MSG_PUB.Add('N');
       px_line_tbl(px_line_tbl.last+1) := l_line_rec;
       px_price_line_id_tbl(MOD(l_line_rec.line_id, G_BINARY_LIMIT)) := px_line_tbl.last;    -- BUG 8631297
     END IF;
    End If;
  End Loop;

EXCEPTION
  WHEN E_CLOSED_LINE THEN
    NULL;
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ERROR IN PROCESS_PRG'||SQLERRM ) ;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
End Process_PRG;


Procedure Promotion_Put_Hold(
p_header_id                             Number
,p_line_id                              Number
)
is
l_hold_source_rec               OE_Holds_Pvt.hold_source_rec_type;
l_hold_release_rec              OE_Holds_Pvt.Hold_Release_REC_Type;
l_return_status                 varchar2(30);
l_x_msg_count                   number;
l_x_msg_data                    Varchar2(2000);
l_x_result_out                  Varchar2(30);
l_list_name                     varchar2(240);
l_operand                       number;
l_msg_text                      Varchar2(200);

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

Begin

IF l_debug_level  > 0 THEN
oe_debug_pub.add('PROMOTIONS - start of procedure Promotion_Put_Hold ');
END IF;

                -- use the seeded hold_id
  IF (p_line_id IS NULL) THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('putting header '||p_header_id||' on hold',3);
    END IF;

      l_hold_source_rec.hold_id := G_SEEDED_PROM_ORDER_HOLD_ID;
  ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('putting line '||p_line_id||' on hold',3);
    END IF;
      l_hold_source_rec.hold_id := G_SEEDED_PROM_LINE_HOLD_ID;
  END IF;

 IF l_debug_level  > 0 THEN
--oe_debug_pub.add('PAL PROMOTIONS - after select in procedure Promotion_Put_Hold ');
--oe_debug_pub.add('PAL PROMOTIONS - hold id is '|| l_hold_source_rec.hold_id,2);
--oe_debug_pub.add(' PROMOTIONS - header_id is '|| p_header_id,2);
--oe_debug_pub.add('PAL PROMOTIONS - line_id is '|| p_line_id,2);
  null;
 END IF;

        l_hold_source_rec.hold_entity_id := p_header_id;
        l_hold_source_rec.header_id := p_header_id;

        l_hold_source_rec.line_id := p_line_id;
        l_hold_source_rec.Hold_Entity_code := 'O';

       -- check if line already on PROMOTION hold, place hold if not

OE_Holds_Pub.Check_Holds(
                                        p_api_version           => 1.0
                                        ,p_header_id            => p_header_id
                                        ,p_line_id              => p_line_id
                                        ,p_hold_id              => l_hold_source_rec.Hold_id
                                        ,x_return_status        => l_return_status
                                        ,x_msg_count            => l_x_msg_count
                                        ,x_msg_data             => l_x_msg_data
                                        ,x_result_out           => l_x_result_out
                                        );

IF l_debug_level  > 0 THEN
--oe_debug_pub.add('PAL PROMOTIONS - hold_entity_code is '|| l_hold_source_rec.Hold_Entity_code||l_x_result_out,2);
null;
end if;

           IF (l_return_status <> FND_API.g_ret_sts_success) THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
                If  l_x_result_out = FND_API.G_FALSE then
                     IF l_debug_level  > 0 THEN
                                  oe_debug_pub.add('PAL PROMOTIONS - apply holds in procedure Promotion_Put_Hold ');
                                  oe_debug_pub.add('hold line with header_id:'||p_header_id||' line_id: '||p_line_id,1);
                     END IF;
                                  OE_HOLDS_PUB.Apply_Holds(
                                        p_api_version           => 1.0
                                        ,p_hold_source_rec      => l_hold_source_rec
                                        ,x_return_status        => l_return_status
                                        ,x_msg_count            => l_x_msg_count
                                        ,x_msg_data             => l_x_msg_data

                                        );

          If l_return_status = FND_API.g_ret_sts_success then
             IF (p_line_id IS NULL) THEN
                FND_MESSAGE.SET_NAME('ONT','ONT_PROMO_HOLD_APPLIED');
             ELSE
                FND_MESSAGE.SET_NAME('ONT', 'ONT_LINE_PROMO_HOLD_APPLIED');
             END IF;
                OE_MSG_PUB.Add;
          Else
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('error applying hold',3);
             END IF;
                RAISE FND_API.G_EXC_ERROR;
          End If;
       End If; /* check hold */

  IF l_debug_level  > 0 THEN
-- oe_debug_pub.add('PAL PROMOTIONS - end of procedure Promotion_Put_Hold ');
 null;
  END IF;
end Promotion_Put_Hold;


Procedure Process_Limits IS

   Cursor Hold_Lines IS
     SELECT line_index, line_id, line_Type_code, hold_code
     FROM QP_PREQ_LINES_TMP
     WHERE HOLD_CODE IN (QP_PREQ_GRP.G_STATUS_LIMIT_HOLD, QP_PREQ_GRP.G_STATUS_LIMIT_ADJUSTED);

    Cursor limit_violated_details IS
      SELECT ldets.line_index, ldets.limit_text, lines.line_id
      FROM QP_LDETS_V ldets, qp_preq_lines_tmp lines
      WHERE ldets.LIMIT_CODE IN (QP_PREQ_GRP.G_STATUS_LIMIT_EXCEEDED,  QP_PREQ_GRP.G_STATUS_LIMIT_ADJUSTED )
      AND ldets.line_index = lines.line_index;
      l_limit_hold_action varchar2(30):=NVL(fnd_profile.value('ONT_PROMOTION_LIMIT_VIOLATION_ACTION'), 'NO_HOLD');
      l_Header_id number := oe_order_cache.g_header_rec.Header_id;

      l_TRANSACTION_PHASE_CODE varchar2(30) := oe_order_cache.g_header_rec.TRANSACTION_PHASE_CODE;

        l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

 l_order_source_id           NUMBER;
 l_orig_sys_document_ref     VARCHAR2(50);
 l_orig_sys_line_ref         VARCHAR2(50);
 l_orig_sys_shipment_ref     VARCHAR2(50);
 l_change_sequence           VARCHAR2(50);
 l_source_document_type_id   NUMBER;
 l_source_document_id        NUMBER;
 l_source_document_line_id   NUMBER;
 l_line_id                   NUMBER;
BEGIN
     IF l_debug_level > 0 THEN
       oe_debug_pub.add('inside procedure process_limits',1);
     END IF;
--      First, hold order or line
        For I in hold_lines LOOP
         IF l_debug_level > 0 THEN
          oe_debug_pub.add('line_index = '||I.line_index,1);
          oe_debug_pub.add('line_id = '||I.line_id,1);

          oe_debug_pub.add('line_Type_code = '||I.line_Type_code,1);
          oe_debug_pub.add('line_Type_code = '||I.hold_code,1);
	  oe_debug_pub.add('TRANSACTION_PHASE_CODE = '||l_TRANSACTION_PHASE_CODE);

         END IF;

              IF (l_limit_hold_action = 'NO_HOLD' or
		  i.hold_code = QP_PREQ_GRP.G_STATUS_LIMIT_ADJUSTED or
		  nvl(l_TRANSACTION_PHASE_CODE, 'F') <> 'F'
              ) THEN
                    FND_MESSAGE.SET_NAME('ONT','ONT_PROMO_LIMIT_EXCEEDED');
                    OE_MSG_PUB.ADD;
              ELSE
                  IF    ( i.line_type_code = 'LINE')
                        Then
                     --Promotion_Put_Hold can be copied from OEXVADJB.pls
                        Promotion_Put_Hold (p_header_id   => l_Header_id,

                                      p_line_id     => i.line_id);
                        IF (l_limit_hold_action = 'ORDER_HOLD') THEN
                         Promotion_Put_Hold(p_header_id => l_header_id,
                                            p_line_id => NULL);
                        END IF;

                  ELSIF  ( i.line_type_code = 'ORDER' )
                        Then
                        Promotion_Put_Hold (p_header_id   => l_header_id,


                                      p_line_id     => NULL) ;

                  END IF; -- i.line_type_code = 'LINE' )
                 END IF;  -- limit violation action
        END LOOP;
--      Second, put message about adjustments who violated limits
              For I in limit_violated_details LOOP
               IF l_debug_level > 0 THEN
               oe_debug_pub.add('line_index = '||I.line_index,1);
               oe_debug_pub.add('limit_text = '||I.limit_text,1);
               END IF;
                IF (i.line_id = l_header_id) THEN
                        OE_MSG_PUB.set_msg_context
                        ( p_entity_code                 => 'HEADER'
                        ,p_entity_id                   => l_header_id
                        ,p_header_id                 =>l_header_id
                        ,p_line_id                     => NULL
                        ,p_orig_sys_document_ref       => oe_order_cache.g_header_rec.orig_sys_document_ref
                        ,p_orig_sys_document_line_ref  => NULL
                        ,p_source_document_id          => oe_order_cache.g_header_rec.source_document_id
                        ,p_source_document_line_id     => NULL
                        ,p_change_sequence             => oe_order_cache.g_header_rec.change_sequence
                        ,p_order_source_id             => oe_order_cache.g_header_rec.order_source_id
                        ,p_source_document_type_id     => oe_order_cache.g_header_rec.source_document_type_id);
                ELSE
                    l_line_id :=  i.line_id;
                    IF l_line_id IS NOT NULL AND l_line_id <> 0 AND
                       l_line_id <> FND_API.G_MISS_NUM THEN
                       BEGIN
                          IF l_debug_level > 0 THEN
                             oe_debug_pub.add('Getting reference data ');
                          END IF;

                          select order_source_id, orig_sys_document_ref,
                                 orig_sys_line_ref, orig_sys_shipment_ref,
                                 change_sequence, source_document_type_id,
                                 source_document_id, source_document_line_id
                          into   l_order_source_id, l_orig_sys_document_ref,
                                 l_orig_sys_line_ref, l_orig_sys_shipment_ref,
                                 l_change_sequence, l_source_document_type_id,
                                 l_source_document_id, l_source_document_line_id
                          from   oe_order_lines_all
                          where line_id = l_line_id;
                       EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                          IF l_debug_level > 0 THEN
                             oe_debug_pub.add('no data found while getting reference data ');
                          END IF;
                           l_order_source_id           := NULL;
                           l_orig_sys_document_ref     := NULL;
                           l_orig_sys_line_ref         := NULL;
                           l_orig_sys_shipment_ref     := NULL;
                           l_change_sequence           := NULL;
                           l_source_document_type_id   := NULL;
                           l_source_document_id        := NULL;
                           l_source_document_line_id   := NULL;
                       END;
                    END IF;

                    OE_MSG_PUB.set_msg_context
                        ( p_entity_code                 => 'LINE'
                        ,p_entity_id                   => i.line_id
                        ,p_header_id                   =>l_header_id
                        ,p_line_id                     => i.line_id
                        ,p_orig_sys_document_ref       => nvl(l_orig_sys_document_ref,
                                                         oe_order_cache.g_header_rec.orig_sys_document_ref)
                        ,p_orig_sys_document_line_ref  => l_orig_sys_line_ref
                        ,p_orig_sys_shipment_ref       => l_orig_sys_shipment_ref
                        ,p_change_sequence             => nvl(l_change_sequence,
                                                          oe_order_cache.g_header_rec.change_sequence)
                        ,p_source_document_id          => nvl(l_source_document_id,
                                                          oe_order_cache.g_header_rec.source_document_id)
                        ,p_source_document_line_id     => l_source_document_line_id
                        ,p_order_source_id             =>nvl(l_order_source_id,
                                                           oe_order_cache.g_header_rec.order_source_id)
                        ,p_source_document_type_id     => nvl(l_source_document_type_id,
                                                        oe_order_cache.g_header_rec.source_document_type_id));
                END IF;

                FND_MESSAGE.SET_NAME('ONT','ONT_PROMO_LIMIT_EXCEEDED');
                FND_MESSAGE.SET_TOKEN('ERR_TEXT', i.LIMIT_TEXT);
                OE_MSG_PUB.Add;
                IF (OE_GLOBALS.G_UI_FLAG ) THEN
                        IF (G_REQUEST_ID IS NULL) THEN
                                select oe_msg_request_id_s.nextval into g_request_id from dual;
                        END IF;
                        OE_MSG_PUB.INSERT_MESSAGE(OE_MSG_PUB.COUNT_MSG, G_REQUEST_ID,'U');
                        OE_MSG_PUB.DELETE_MSG(OE_MSG_PUB.COUNT_MSG);
                END IF;


            end LOOP;
 End Process_Limits;


function check_notify_OC
   return boolean
is
    l_source_document_type_id   number := oe_order_cache.g_header_rec.source_document_type_id;
    l_header_id   number := oe_order_cache.g_header_rec.header_id;
    l_source_system_code number := 0;
     l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
begin

   IF l_debug_level > 0 THEN
     oe_debug_pub.add(' In OE_ADV_PRICE_PVT.CHECK_NOTIFY');
   END IF;
  begin
    select 1 into l_source_system_code from
      oe_order_headers_all oh,
      qp_list_headers qh,
    --  qp_preq_lines_tmp lines,
      qp_preq_ldets_tmp ldets
    where qh.currency_code = oh.transactional_curr_code
        and oh.header_id =  l_header_id
   --    and lines.line_index = ldets.line_index
      and ldets.CREATED_FROM_LIST_HEADER_ID = qh.LIST_HEADER_ID
      and qh.source_system_code = 'AMS'
      and qh.active_flag = 'Y'
      and rownum = 1;
   exception
   when no_data_found then
     null;
   end;

     IF l_debug_level > 0 THEN
       oe_debug_pub.add('l_source_document_type_id = '||l_source_document_type_id);
       oe_debug_pub.add('l_source_system_code = '||l_source_system_code);
     END IF;


         IF nvl(l_source_document_type_id,0) IN (1, 3, 4, 7, 8, 11, 12, 13, 14,15, 16, 17, 18 , 19)  OR l_source_system_code = 1
         THEN
             return true;
         else return false;
         end if;
  end;


procedure new_and_updated_notify is

  l_booked_flag  varchar2(1) := oe_order_cache.g_header_rec.booked_flag;
  cursor insert_adj_cur is
  select price_adjustment_id, ldets.automatic_flag auto_flag,line_id,
         modifier_level_code, ldets.LIST_HEADER_ID list_header_id,
         LIST_LINE_ID, LIST_LINE_TYPE_CODE,inventory_item_id,
         substitution_value_to, related_item_id,process_code,
         APPLIED_FLAG, override_flag,operand_calculation_code, operand_value,
         lines.priced_quantity priced_quantity,lines.line_quantity lquantity,
         adjustment_amount,pricing_phase_id,updated_flag,
         order_qty_operand, order_qty_adj_amt,
         CHARGE_TYPE_CODE, CHARGE_SUBTYPE_CODE,list_line_no,
         source_system_code,benefit_qty, benefit_uom_code,
         expiration_date, rebate_transaction_type_code,

         accrual_flag, ldets.line_quantity line_quantity,accrual_conversion_rate,
         pricing_group_sequence,print_on_invoice_flag,
         price_break_type_code, substitution_attribute,
         proration_type_code, include_on_returns_flag,lines.line_index line_index
  from
         QP_LDETS_v ldets
    ,    QP_PREQ_LINES_TMP lines
    ,    QP_LIST_HEADERS_B QH
  where
     ldets.LIST_HEADER_ID = qh.list_header_id
    AND  ldets.process_code IN (QP_PREQ_GRP.G_STATUS_NEW,QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_UNCHANGED)   --Bug8467307
    AND  lines.pricing_status_code in (QP_PREQ_GRP.G_STATUS_NEW,QP_PREQ_GRP.G_STATUS_UPDATED,QP_PREQ_GRP.G_STATUS_GSA_VIOLATION)
    AND  lines.process_status <> 'NOT_VALID'
    AND  ldets.line_index=lines.line_index
    AND  (nvl(ldets.automatic_flag,'N') = 'Y')
--          or
--          (ldets.list_line_type_code = 'FREIGHT_CHARGE')
    AND ldets.created_from_list_type_code not in ('PRL','AGR')
    AND  ldets.list_line_type_code<>'PLL'

    AND (l_booked_flag = 'N' or ldets.list_line_type_code<>'IUE');

    l_Line_Adj_rec    OE_Order_PUB.Line_Adj_Rec_Type;
    l_Header_Adj_rec  OE_Order_PUB.Header_Adj_Rec_Type;
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    l_index                 NUMBER;
    l_return_status         VARCHAR2(1);
    l_qty		    NUMBER;           --Bug8467307
    l_ind                   PLS_INTEGER;      --Bug8467307
    G_MAX_REQUESTS          NUMBER := 10000;  --Bug8467307

 begin
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('in new_and_updated_notify',1);
      END IF;
      FOR l_insert  IN insert_adj_cur LOOP
       IF l_insert.modifier_level_code <> 'ORDER' THEN
        l_Line_Adj_rec.line_id :=  l_insert.line_id;
        l_Line_Adj_rec.price_adjustment_id := l_insert.price_adjustment_id;
        l_Line_Adj_rec.creation_date := sysdate;
        l_Line_Adj_rec.created_by := fnd_global.user_id;
        l_Line_Adj_rec.last_update_date := sysdate;
        l_Line_Adj_rec.last_updated_by := fnd_global.user_id;
        l_Line_Adj_rec.last_update_login := fnd_global.user_id;
        l_Line_Adj_rec.header_id := oe_order_pub.g_hdr.header_id;
        l_Line_Adj_rec.automatic_flag := l_insert.auto_flag;
        l_Line_Adj_rec.LIST_HEADER_ID := l_insert.LIST_HEADER_ID;
        l_Line_Adj_rec.LIST_LINE_ID := l_insert.LIST_LINE_ID;
        l_Line_Adj_rec.LIST_LINE_TYPE_CODE := l_insert.LIST_LINE_TYPE_CODE;
        If l_insert.LIST_LINE_TYPE_CODE = 'TSN' Then
           l_Line_Adj_rec.modified_from := l_insert.substitution_attribute;
           l_Line_Adj_rec.modified_to := l_insert.substitution_value_to;
        Elsif l_insert.LIST_LINE_TYPE_CODE = 'IUE' Then
           l_Line_Adj_rec.modified_from := to_char(l_insert.inventory_item_id);
           l_Line_Adj_rec.modified_to := to_char(l_insert.related_item_id);
        End If;
        If l_insert.process_code = QP_PREQ_GRP.G_STATUS_NEW Then
            l_Line_Adj_rec.UPDATED_FLAG := 'N';
        Elsif l_insert.process_code = QP_PREQ_GRP.G_STATUS_UPDATED Then
            l_Line_Adj_rec.UPDATED_FLAG := l_insert.updated_flag;
            l_Line_Adj_rec.print_on_invoice_flag := l_insert.print_on_invoice_flag;
        End If;
        l_Line_Adj_rec.UPDATE_ALLOWED := l_insert.override_flag;
        l_Line_Adj_rec.APPLIED_FLAG := l_insert.APPLIED_FLAG;
        IF l_insert.operand_calculation_code = '%' or
            l_insert.operand_calculation_code = 'LUMPSUM'  then
                l_Line_Adj_rec.operand := nvl(l_insert.order_qty_operand, l_insert.operand_value);
        ELSE
          IF l_insert.process_code = QP_PREQ_GRP.G_STATUS_NEW Then
            l_Line_Adj_rec.operand := nvl(l_insert.order_qty_operand, l_insert.operand_value*l_insert.priced_quantity/nvl(l_insert.lquantity,1));
          ELSIF l_insert.process_code = QP_PREQ_GRP.G_STATUS_UPDATED Then
            l_Line_Adj_rec.operand := nvl(l_insert.order_qty_operand, l_insert.operand_value*nvl(l_insert.priced_quantity,l_insert.lquantity)/l_insert.lquantity);
          END IF;
        END IF;
        l_Line_Adj_rec.arithmetic_operator := l_insert.operand_calculation_code;
        l_Line_Adj_rec.ADJUSTED_AMOUNT := nvl(l_insert.order_qty_adj_amt, l_insert.adjustment_amount*nvl(l_insert.priced_quantity,1)/nvl(l_insert.lquantity,1));
        l_Line_Adj_rec.pricing_phase_id := l_insert.pricing_phase_id;
        l_Line_Adj_rec.CHARGE_TYPE_CODE := l_insert.CHARGE_TYPE_CODE;
        l_Line_Adj_rec.CHARGE_SUBTYPE_CODE := l_insert.CHARGE_SUBTYPE_CODE;
        l_Line_Adj_rec.list_line_no := l_insert.list_line_no;
        l_Line_Adj_rec.source_system_code := l_insert.source_system_code;
        l_Line_Adj_rec.benefit_qty := l_insert.benefit_qty;
        l_Line_Adj_rec.benefit_uom_code := l_insert.benefit_uom_code;
        l_Line_Adj_rec.expiration_date := l_insert.expiration_date;
        l_Line_Adj_rec.rebate_transaction_type_code := l_insert.rebate_transaction_type_code;
        l_Line_Adj_rec.accrual_flag := l_insert.accrual_flag;
        l_Line_Adj_rec.range_break_quantity := l_insert.line_quantity;
        l_Line_Adj_rec.accrual_conversion_rate := l_insert.accrual_conversion_rate;
        l_Line_Adj_rec.pricing_group_sequence := l_insert.pricing_group_sequence;
        l_Line_Adj_rec.modifier_level_code := l_insert.modifier_level_code;
        l_Line_Adj_rec.price_break_type_code := l_insert.price_break_type_code;
        l_Line_Adj_rec.substitution_attribute := l_insert.substitution_attribute;
        l_Line_Adj_rec.proration_type_code := l_insert.proration_type_code;
        l_Line_Adj_rec.include_on_returns_flag := l_insert.include_on_returns_flag;
        l_Line_Adj_rec.OPERAND_PER_PQTY := l_insert.OPERAND_value;

        l_Line_Adj_rec.ADJUSTED_AMOUNT_PER_PQTY := l_insert.adjustment_amount;

        l_Line_Adj_rec.line_index := l_insert.line_index;
        l_Line_Adj_rec.return_status   := FND_API.G_RET_STS_SUCCESS;
        IF l_insert.process_code = QP_PREQ_GRP.G_STATUS_NEW Then
            l_Line_Adj_rec.db_flag := FND_API.G_FALSE;
            l_Line_Adj_rec.operation := OE_GLOBALS.G_OPR_CREATE;
            OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_old_line_adj_rec => NULL,
                    p_line_adj_rec =>l_line_adj_rec,
                    p_line_adj_id => l_line_adj_rec.price_adjustment_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
        ELSIF l_insert.process_code = QP_PREQ_GRP.G_STATUS_UPDATED Then
            l_Line_Adj_rec.db_flag := FND_API.G_TRUE;
            l_Line_Adj_rec.operation := OE_GLOBALS.G_OPR_UPDATE;

            OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_line_adj_rec =>l_line_adj_rec,
                    p_line_adj_id => l_line_adj_rec.price_adjustment_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
        --Start of bug#8467307
        ELSIF l_insert.process_code = QP_PREQ_GRP.G_STATUS_UNCHANGED Then
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add ('Adj ID=' ||l_insert.price_adjustment_id);
              END IF;
              -- To find the old line quantity
              l_qty := l_insert.lquantity;
              l_ind := (mod(l_Line_Adj_rec.line_id,100000) * G_MAX_REQUESTS)+1;
	      IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('Index- :'||l_ind);
	      END IF;
              IF OE_ORDER_UTIL.g_old_line_tbl.exists(l_ind) THEN
                 l_qty := OE_ORDER_UTIL.g_old_line_tbl(l_ind).ordered_quantity;
	         IF l_debug_level  > 0 THEN
                    oe_debug_pub.add('FOUND Old Line Quantity :'||l_qty);
	         END IF;
              ELSE
                 IF l_debug_level  > 0 THEN
                    oe_debug_pub.add('NOT FOUND ');
	         END IF;
              END IF;
	      IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('Old Line Quantity :'||l_qty);
	         oe_debug_pub.add('l_insert.lquantity :'||l_insert.lquantity);
	      END IF;
 	      IF l_qty <> l_insert.lquantity THEN    -- IF the Quantity has changed on the Line THEN
                 l_Line_Adj_rec.UPDATED_FLAG := 'Y';
                 l_Line_Adj_rec.db_flag := FND_API.G_TRUE;
      	         l_Line_Adj_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
                 OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                         p_line_adj_rec =>l_line_adj_rec,
                         p_line_adj_id => l_line_adj_rec.price_adjustment_id,
                         x_index => l_index,
                         x_return_status => l_return_status);
              END IF; ---End of Bug#8467307
        END IF;
       ELSE  -- modifier level code 'ORDER'
        --l_Header_Adj_rec.line_id :=  l_insert.line_id;
        l_Header_Adj_rec.price_adjustment_id := l_insert.price_adjustment_id;
        l_Header_Adj_rec.creation_date := sysdate;
        l_Header_Adj_rec.created_by := fnd_global.user_id;
        l_Header_Adj_rec.last_update_date := sysdate;
        l_Header_Adj_rec.last_updated_by := fnd_global.user_id;
        l_Header_Adj_rec.last_update_login := fnd_global.user_id;
        l_Header_Adj_rec.header_id := oe_order_pub.g_hdr.header_id;
        l_Header_Adj_rec.automatic_flag := l_insert.auto_flag;
        l_Header_Adj_rec.LIST_HEADER_ID := l_insert.LIST_HEADER_ID;
        l_Header_Adj_rec.LIST_LINE_ID := l_insert.LIST_LINE_ID;
        l_Header_Adj_rec.LIST_LINE_TYPE_CODE := l_insert.LIST_LINE_TYPE_CODE;
        If l_insert.LIST_LINE_TYPE_CODE = 'TSN' Then
           l_Header_Adj_rec.modified_from := l_insert.substitution_attribute;
           l_Header_Adj_rec.modified_to := l_insert.substitution_value_to;
        Elsif l_insert.LIST_LINE_TYPE_CODE = 'IUE' Then
           l_Header_Adj_rec.modified_from := to_char(l_insert.inventory_item_id);
           l_Header_Adj_rec.modified_to := to_char(l_insert.related_item_id);
        End If;
        If l_insert.process_code = QP_PREQ_GRP.G_STATUS_NEW Then
            l_Header_Adj_rec.UPDATED_FLAG := 'N';
        Elsif l_insert.process_code = QP_PREQ_GRP.G_STATUS_UPDATED Then
            l_Header_Adj_rec.UPDATED_FLAG := l_insert.updated_flag;
            l_Header_Adj_rec.print_on_invoice_flag := l_insert.print_on_invoice_flag;
        End If;
        l_Header_Adj_rec.UPDATE_ALLOWED := l_insert.override_flag;
        l_Header_Adj_rec.APPLIED_FLAG := l_insert.APPLIED_FLAG;
        IF l_insert.operand_calculation_code = '%' or
            l_insert.operand_calculation_code = 'LUMPSUM'  then
                l_Header_Adj_rec.operand := nvl(l_insert.order_qty_operand, l_insert.operand_value);
        ELSE
          IF l_insert.process_code = QP_PREQ_GRP.G_STATUS_NEW Then
            l_Header_Adj_rec.operand := nvl(l_insert.order_qty_operand, l_insert.operand_value*l_insert.priced_quantity/nvl(l_insert.lquantity,1));
          ELSIF l_insert.process_code = QP_PREQ_GRP.G_STATUS_UPDATED Then
            l_Header_Adj_rec.operand := nvl(l_insert.order_qty_operand, l_insert.operand_value*nvl(l_insert.priced_quantity,l_insert.lquantity)/l_insert.lquantity);
          END IF;
        END IF;
        l_Header_Adj_rec.arithmetic_operator := l_insert.operand_calculation_code;
        l_Header_Adj_rec.ADJUSTED_AMOUNT := nvl(l_insert.order_qty_adj_amt, l_insert.adjustment_amount*nvl(l_insert.priced_quantity,1)/nvl(l_insert.lquantity,1));
        l_Header_Adj_rec.pricing_phase_id := l_insert.pricing_phase_id;
        l_Header_Adj_rec.CHARGE_TYPE_CODE := l_insert.CHARGE_TYPE_CODE;
        l_Header_Adj_rec.CHARGE_SUBTYPE_CODE := l_insert.CHARGE_SUBTYPE_CODE;
        l_Header_Adj_rec.list_line_no := l_insert.list_line_no;
        l_Header_Adj_rec.source_system_code := l_insert.source_system_code;
        l_Header_Adj_rec.benefit_qty := l_insert.benefit_qty;
        l_Header_Adj_rec.benefit_uom_code := l_insert.benefit_uom_code;
        l_Header_Adj_rec.expiration_date := l_insert.expiration_date;
        l_Header_Adj_rec.rebate_transaction_type_code := l_insert.rebate_transaction_type_code;
        l_Header_Adj_rec.accrual_flag := l_insert.accrual_flag;
        l_Header_Adj_rec.range_break_quantity := l_insert.line_quantity;
        l_Header_Adj_rec.accrual_conversion_rate := l_insert.accrual_conversion_rate;
        l_Header_Adj_rec.pricing_group_sequence := l_insert.pricing_group_sequence;
        l_Header_Adj_rec.modifier_level_code := l_insert.modifier_level_code;
        l_Header_Adj_rec.price_break_type_code := l_insert.price_break_type_code;
        l_Header_Adj_rec.substitution_attribute := l_insert.substitution_attribute;
        l_Header_Adj_rec.proration_type_code := l_insert.proration_type_code;
        l_Header_Adj_rec.include_on_returns_flag := l_insert.include_on_returns_flag;
        l_Header_Adj_rec.OPERAND_PER_PQTY := l_insert.OPERAND_value;

        l_Header_Adj_rec.ADJUSTED_AMOUNT_PER_PQTY := l_insert.adjustment_amount;

        --l_Header_Adj_rec.line_index := l_insert.line_index;
        l_Header_Adj_rec.return_status   := FND_API.G_RET_STS_SUCCESS;
        IF l_insert.process_code = QP_PREQ_GRP.G_STATUS_NEW Then
            l_Header_Adj_rec.db_flag := FND_API.G_FALSE;
            l_Header_Adj_rec.operation := OE_GLOBALS.G_OPR_CREATE;
            OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_old_hdr_adj_rec => NULL,
                    p_hdr_adj_rec =>l_header_adj_rec,
                    p_hdr_adj_id => l_header_adj_rec.price_adjustment_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
        ELSIF l_insert.process_code = QP_PREQ_GRP.G_STATUS_UPDATED Then
            l_Header_Adj_rec.db_flag := FND_API.G_TRUE;
            l_Header_Adj_rec.operation := OE_GLOBALS.G_OPR_UPDATE;

            OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_hdr_adj_rec =>l_header_adj_rec,
                    p_hdr_adj_id => l_header_adj_rec.price_adjustment_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
        END IF;
       END IF;--modifier_leveL_code
        /*OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_line_adj_rec =>l_line_adj_rec,
                    p_line_adj_id => l_line_adj_rec.price_adjustment_id,
                    x_index => l_index,
                    x_return_status => l_return_status);*/

        IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_ADV_PRICE_PVT.NEW_AND_UPDATE_NOTIFY IS: ' || L_RETURN_STATUS ) ;
         END IF;
         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
                 oe_debug_pub.add(  'EXITING OE_ADV_PRICE_PVT.NEW_AND_UPDATE_NOTIFY');
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_ADV_PRICE_PVT.NEW_AND_UPDATE_NOTIFY' ) ;
                oe_debug_pub.add(  'EXITING OE_ADV_PRICE_PVT.NEW_AND_UPDATE_NOTIFY' , 1 ) ;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

    end loop;

 end;



--bug 3702538
procedure Register_price_list(
   px_line_Tbl                     IN OUT NOCOPY     oe_Order_Pub.Line_Tbl_Type
  )
IS

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_mod_line_id NUMBER;

Cursor updated_lines_prl IS
SELECT l.LINE_ID,
       lines.PRICE_LIST_HEADER_ID,
       l.price_list_id
FROM
       QP_PREQ_LINES_TMP lines
      ,OE_ORDER_LINES l
WHERE lines.pricing_status_code IN
      ( QP_PREQ_GRP.G_STATUS_UPDATED
       ,QP_PREQ_GRP.G_STATUS_GSA_VIOLATION)
  AND lines.process_status <> 'NOT_VALID'
  AND lines.line_type_code='LINE'
  AND nvl(decode(lines.price_list_header_id,-9999,NULL,lines.price_list_header_id),0) <> nvl(l.price_list_id,0)
  AND l.line_id = lines.line_id
  AND l.ordered_quantity <> 0;

BEGIN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('In Register_price_list');
  END IF;
  for i in updated_lines_prl loop
 l_mod_line_id := MOD(i.line_id,G_BINARY_LIMIT); -- Bug 8631297

    IF l_debug_level > 0 THEN
       oe_debug_pub.add('Old Price List id : '||i.price_list_id);
       oe_debug_pub.add('New Price List id : '||i.price_list_header_id);
    END IF;
    px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).price_list_id := i.price_list_header_id;
    px_line_tbl(G_PRICE_LINE_ID_TBL(l_mod_line_id)).operation := OE_GLOBALS.G_OPR_UPDATE;
  end loop;
END Register_price_list;--bug 3702538


procedure process_adv_modifiers
(
x_return_status                 OUT NOCOPY Varchar2,
p_Control_Rec                   IN OE_ORDER_PRICE_PVT.Control_rec_type,
p_any_frozen_line               IN Boolean,
px_line_Tbl                     IN OUT NOCOPY     oe_Order_Pub.Line_Tbl_Type,
px_old_line_Tbl                 IN OUT NOCOPY     oe_order_pub.line_tbl_type,
p_header_id                     IN number,
p_line_id                       IN number,
p_header_rec                    IN oe_Order_Pub.header_rec_type,
p_pricing_events                IN varchar2
) IS

l_control_rec                 OE_GLOBALS.Control_Rec_Type;
lx_new_header_rec oe_Order_Pub.header_rec_type := p_header_rec;
l_notify_flag  BOOLEAN;
l_booked_flag  varchar2(1) := oe_order_cache.g_header_rec.booked_flag;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  NULL;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   If OE_DEBUG_PUB.G_DEBUG = FND_API.G_TRUE Then
    G_DEBUG := TRUE;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BCT G_DEBUG IS:'||OE_DEBUG_PUB.G_DEBUG ) ;
    END IF;
   Else
    G_DEBUG := FALSE;
   End If;

  -- not need to process prg, iue, tsn, limits for calculate only call
  IF p_control_rec.p_calculate_flag <> QP_PREQ_GRP.G_CALCULATE_ONLY
  THEN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'INSIDE OE_ORDER_ADV_PVT.PROCESS_ADV_MODIFIERS' , 1 ) ;
  END IF;

  Sort_Line_Table(px_line_Tbl,G_PRICE_LINE_ID_TBL);
  Item_Upgrade(px_old_line_tbl,px_line_Tbl,p_pricing_events);
  Term_Substitution(p_header_rec,lx_new_header_rec,px_old_line_tbl,px_line_Tbl);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_PRICING_EVENTS = '||P_PRICING_EVENTS , 1 ) ;
       oe_debug_pub.add(  'BEFORE CALL TO CALL PROCESS ORDER' , 1 ) ;
       oe_debug_pub.add(  'P_HEADER_REC.HEADER_ID='||P_HEADER_REC.HEADER_ID , 1 ) ;
       oe_debug_pub.add(  'P_HEADER_REC.PAYMENT_TERM_ID='||P_HEADER_REC.PAYMENT_TERM_ID , 1 ) ;
       oe_debug_pub.add(  'P_HEADER_REC.OPERATION='||P_HEADER_REC.OPERATION , 1 ) ;
       oe_debug_pub.add(  'LX_NEW_HEADER_REC.HEADER_ID='||LX_NEW_HEADER_REC.HEADER_ID , 1 ) ;
       oe_debug_pub.add(  'LX_NEW_HEADER_REC.PAYMENT_TERM_ID='||LX_NEW_HEADER_REC.PAYMENT_TERM_ID , 1 ) ;
       oe_debug_pub.add(  'LX_NEW_HEADER_REC.OPERATION='||LX_NEW_HEADER_REC.OPERATION , 1 ) ;
   END IF;

   Process_Prg(px_line_Tbl
              , px_old_line_tbl
              ,G_PRICE_LINE_ID_TBL);

      Process_Limits;

--bug 3702538
      Register_price_list(px_line_Tbl);
--bug 3702538

      Call_Process_Order(p_header_rec,
                       lx_new_header_rec,
                       px_line_Tbl,
                       px_old_line_tbl,
                       l_control_rec,
                       x_return_status);

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('l_booked_flag = '||l_booked_flag);
      oe_debug_pub.add('oe_order_cache.g_header_rec.booked_flag = '||oe_order_cache.g_header_rec.booked_flag);
   END IF;

  END IF;  -- <> Calculate_Only

  new_and_updated_notify;

END process_adv_modifiers;

Procedure Insert_Adj(p_header_id in Number default null)
IS
l_booked_flag varchar2(1) := oe_order_cache.g_header_rec.booked_flag;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'INSIDE OE_ADV_PRICE_PVT.INSERT_ADJ' ) ;
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
    ,       decode(p_header_id, NULL, oe_order_pub.g_hdr.header_id, p_header_id) --p_Line_Adj_rec.header_id
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
    -- Bug 7523118
    ,       'OE_PRICE_ADJUSTMENTS'||ldets.price_adjustment_id  --p_Line_Adj_rec.orig_sys_discount_ref
    ,	  ldets.LIST_HEADER_ID
    ,	  ldets.LIST_LINE_ID
    ,	  ldets.LIST_LINE_TYPE_CODE
    ,	  NULL --p_Line_Adj_rec.MODIFIER_MECHANISM_TYPE_CODE
    ,	  decode(ldets.list_line_type_code, 'TSN', ldets.substitution_attribute, 'IUE', to_char(ldets.inventory_item_id), NULL)
    ,	  decode(ldets.list_line_type_code, 'TSN', ldets.substitution_value_to, 'IUE', to_char(ldets.related_item_id), NULL)
    ,	  'N' --p_Line_Adj_rec.UPDATED_FLAG
    ,	  ldets.override_flag
    ,	  ldets.APPLIED_FLAG
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
    AND ldets.list_line_type_code NOT IN ('IUE', 'TSN')  --bug 4190357 excluded TSN
 --   AND (p_line_id is null or (p_line_id is not null and lines.line_id = p_line_id and lines.line_type_code = 'LINE'))
  --  AND (l_booked_flag = 'N' or ldets.list_line_type_code<>'IUE')
);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INSERTED '||SQL%ROWCOUNT||' ADJUSTMENTS' ) ;
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
              QP_PREQ_LDETS_TMP RLDET,
              QP_PREQ_LINES_TMP RLINE
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
              RLTD.PRICING_STATUS_CODE = 'N'
             AND RLINE.LINE_INDEX = RLDET.LINE_INDEX
             AND RLINE.PROCESS_STATUS <> 'NOT_VALID' );



   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INSERTED '||SQL%ROWCOUNT||' PRICE ADJ ASSOCS' , 3 ) ;
   END IF;
Exception
WHEN OTHERS THEN
  IF l_debug_level > 0 THEN
     oe_debug_pub.add('ERROR in inserting adjustments and associations'||sqlerrm);
  END IF;
  Raise FND_API.G_EXC_ERROR;
END Insert_Adj;

end OE_ADV_PRICE_PVT;

/
