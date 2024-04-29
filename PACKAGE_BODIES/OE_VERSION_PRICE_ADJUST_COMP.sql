--------------------------------------------------------
--  DDL for Package Body OE_VERSION_PRICE_ADJUST_COMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VERSION_PRICE_ADJUST_COMP" AS
/* $Header: OEXPCOMB.pls 120.3.12010000.2 2010/04/09 09:31:32 msundara ship $ */

PROCEDURE QUERY_HEADER_ADJ_ROW
(p_header_id	                  NUMBER,
 p_price_adjustment_id	          NUMBER,
 p_version	                  NUMBER,
 p_phase_change_flag	          VARCHAR2,
 x_header_adj_rec                 IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type)
IS
l_org_id                NUMBER;
l_phase_change_flag     VARCHAR2(1);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
oe_debug_pub.add('l_debug_level'||l_debug_level );
IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering OE_VERSION_PRICE_ADJUST_COMP.QUERY_HEADER_ADJ_ROW');
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('price adjust' ||p_price_adjustment_id);
  oe_debug_pub.add('version' ||p_version);
END IF;

    l_org_id := OE_GLOBALS.G_ORG_ID;

    IF l_org_id IS NULL THEN
      OE_GLOBALS.Set_Context;
      l_org_id := OE_GLOBALS.G_ORG_ID;
    END IF;

    SELECT  distinct ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       AUTOMATIC_FLAG
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DISCOUNT_ID
    ,       DISCOUNT_LINE_ID
    ,       HEADER_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       PERCENT
    ,       PRICE_ADJUSTMENT_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,	    LIST_HEADER_ID
    ,	    LIST_LINE_ID
    ,	    LIST_LINE_TYPE_CODE
    ,	    MODIFIER_MECHANISM_TYPE_CODE
    ,	    MODIFIED_FROM
    ,	    MODIFIED_TO
    ,	    UPDATED_FLAG
    ,	    UPDATE_ALLOWED
    ,	    APPLIED_FLAG
    ,	    CHANGE_REASON_CODE
    ,	    CHANGE_REASON_TEXT
    ,	    operand
    ,       arithmetic_operator
    ,	    COST_ID
    ,	    TAX_CODE
    ,	    TAX_EXEMPT_FLAG
    ,	    TAX_EXEMPT_NUMBER
    ,	    TAX_EXEMPT_REASON_CODE
    ,	    PARENT_ADJUSTMENT_ID
    ,	    INVOICED_FLAG
    ,	    ESTIMATED_FLAG
    ,	    INC_IN_SALES_PERFORMANCE
    ,	    SPLIT_ACTION_CODE
    ,	    ADJUSTED_AMOUNT
    ,	    PRICING_PHASE_ID
    ,	    CHARGE_TYPE_CODE
    ,	    CHARGE_SUBTYPE_CODE
    ,       list_line_no
    ,       source_system_code
    ,       benefit_qty
    ,       benefit_uom_code
    ,       print_on_invoice_flag
    ,       expiration_date
    ,       rebate_transaction_type_code
    ,       rebate_transaction_reference
    ,       rebate_payment_system_code
    ,       redeemed_date
    ,       redeemed_flag
    ,       accrual_flag
    ,       range_break_quantity
    ,       accrual_conversion_rate
    ,       pricing_group_sequence
    ,       modifier_level_code
    ,       price_break_type_code
    ,       substitution_attribute
    ,       proration_type_code
    ,       CREDIT_OR_CHARGE_FLAG
    ,       INCLUDE_ON_RETURNS_FLAG
    ,       AC_ATTRIBUTE1
    ,       AC_ATTRIBUTE10
    ,       AC_ATTRIBUTE11
    ,       AC_ATTRIBUTE12
    ,       AC_ATTRIBUTE13
    ,       AC_ATTRIBUTE14
    ,       AC_ATTRIBUTE15
    ,       AC_ATTRIBUTE2
    ,       AC_ATTRIBUTE3
    ,       AC_ATTRIBUTE4
    ,       AC_ATTRIBUTE5
    ,       AC_ATTRIBUTE6
    ,       AC_ATTRIBUTE7
    ,       AC_ATTRIBUTE8
    ,       AC_ATTRIBUTE9
    ,       AC_CONTEXT
    ,       orig_sys_discount_ref
    ,       OPERAND_PER_PQTY
    ,       ADJUSTED_AMOUNT_PER_PQTY
--    ,       INVOICED_AMOUNT
    ,	    LOCK_CONTROL
INTO
    x_header_adj_rec.ATTRIBUTE1
    ,x_header_adj_rec.ATTRIBUTE10
    ,x_header_adj_rec.ATTRIBUTE11
    ,x_header_adj_rec.ATTRIBUTE12
    ,x_header_adj_rec.ATTRIBUTE13
    ,x_header_adj_rec.ATTRIBUTE14
    ,x_header_adj_rec.ATTRIBUTE15
    ,x_header_adj_rec.ATTRIBUTE2
    ,x_header_adj_rec.ATTRIBUTE3
    ,x_header_adj_rec.ATTRIBUTE4
    ,x_header_adj_rec.ATTRIBUTE5
    ,x_header_adj_rec.ATTRIBUTE6
    ,x_header_adj_rec.ATTRIBUTE7
    ,x_header_adj_rec.ATTRIBUTE8
    ,x_header_adj_rec.ATTRIBUTE9
    ,x_header_adj_rec.AUTOMATIC_FLAG
    ,x_header_adj_rec.CONTEXT
    ,x_header_adj_rec.CREATED_BY
    ,x_header_adj_rec.CREATION_DATE
    ,x_header_adj_rec.DISCOUNT_ID
    ,x_header_adj_rec.DISCOUNT_LINE_ID
    ,x_header_adj_rec.HEADER_ID
    ,x_header_adj_rec.LAST_UPDATED_BY
    ,x_header_adj_rec.LAST_UPDATE_DATE
    ,x_header_adj_rec.LAST_UPDATE_LOGIN
    ,x_header_adj_rec.LINE_ID
    ,x_header_adj_rec.PERCENT
    ,x_header_adj_rec.PRICE_ADJUSTMENT_ID
    ,x_header_adj_rec.PROGRAM_APPLICATION_ID
    ,x_header_adj_rec.PROGRAM_ID
    ,x_header_adj_rec.PROGRAM_UPDATE_DATE
    ,x_header_adj_rec.REQUEST_ID
    ,x_header_adj_rec.LIST_HEADER_ID
    ,x_header_adj_rec.LIST_LINE_ID
    ,x_header_adj_rec.LIST_LINE_TYPE_CODE
    ,x_header_adj_rec.MODIFIER_MECHANISM_TYPE_CODE
    ,x_header_adj_rec.MODIFIED_FROM
    ,x_header_adj_rec.MODIFIED_TO
    ,x_header_adj_rec.UPDATED_FLAG
    ,x_header_adj_rec.UPDATE_ALLOWED
    ,x_header_adj_rec.APPLIED_FLAG
    ,x_header_adj_rec.CHANGE_REASON_CODE
    ,x_header_adj_rec.CHANGE_REASON_TEXT
    ,x_header_adj_rec.operand
    ,x_header_adj_rec.arithmetic_operator
    ,x_header_adj_rec.COST_ID
    ,x_header_adj_rec.TAX_CODE
    ,x_header_adj_rec.TAX_EXEMPT_FLAG
    ,x_header_adj_rec.TAX_EXEMPT_NUMBER
    ,x_header_adj_rec.TAX_EXEMPT_REASON_CODE
    ,x_header_adj_rec.PARENT_ADJUSTMENT_ID
    ,x_header_adj_rec.INVOICED_FLAG
    ,x_header_adj_rec.ESTIMATED_FLAG
    ,x_header_adj_rec.INC_IN_SALES_PERFORMANCE
    ,x_header_adj_rec.SPLIT_ACTION_CODE
    ,x_header_adj_rec.ADJUSTED_AMOUNT
    ,x_header_adj_rec.PRICING_PHASE_ID
    ,x_header_adj_rec.CHARGE_TYPE_CODE
    ,x_header_adj_rec.CHARGE_SUBTYPE_CODE
    ,x_header_adj_rec.list_line_no
    ,x_header_adj_rec.source_system_code
    ,x_header_adj_rec.benefit_qty
    ,x_header_adj_rec.benefit_uom_code
    ,x_header_adj_rec.print_on_invoice_flag
    ,x_header_adj_rec.expiration_date
    ,x_header_adj_rec.rebate_transaction_type_code
    ,x_header_adj_rec.rebate_transaction_reference
    ,x_header_adj_rec.rebate_payment_system_code
    ,x_header_adj_rec.redeemed_date
    ,x_header_adj_rec.redeemed_flag
    ,x_header_adj_rec.accrual_flag
    ,x_header_adj_rec.range_break_quantity
    ,x_header_adj_rec.accrual_conversion_rate
    ,x_header_adj_rec.pricing_group_sequence
    ,x_header_adj_rec.modifier_level_code
    ,x_header_adj_rec.price_break_type_code
    ,x_header_adj_rec.substitution_attribute
    ,x_header_adj_rec.proration_type_code
    ,x_header_adj_rec.CREDIT_OR_CHARGE_FLAG
    ,x_header_adj_rec.INCLUDE_ON_RETURNS_FLAG
    ,x_header_adj_rec.AC_ATTRIBUTE1
    ,x_header_adj_rec.AC_ATTRIBUTE10
    ,x_header_adj_rec.AC_ATTRIBUTE11
    ,x_header_adj_rec.AC_ATTRIBUTE12
    ,x_header_adj_rec.AC_ATTRIBUTE13
    ,x_header_adj_rec.AC_ATTRIBUTE14
    ,x_header_adj_rec.AC_ATTRIBUTE15
    ,x_header_adj_rec.AC_ATTRIBUTE2
    ,x_header_adj_rec.AC_ATTRIBUTE3
    ,x_header_adj_rec.AC_ATTRIBUTE4
    ,x_header_adj_rec.AC_ATTRIBUTE5
    ,x_header_adj_rec.AC_ATTRIBUTE6
    ,x_header_adj_rec.AC_ATTRIBUTE7
    ,x_header_adj_rec.AC_ATTRIBUTE8
    ,x_header_adj_rec.AC_ATTRIBUTE9
    ,x_header_adj_rec.AC_CONTEXT
    ,x_header_adj_rec.orig_sys_discount_ref
    ,x_header_adj_rec.OPERAND_PER_PQTY
    ,x_header_adj_rec.ADJUSTED_AMOUNT_PER_PQTY
   -- ,x_header_adj_rec.INVOICED_AMOUNT
    ,x_header_adj_rec.LOCK_CONTROL
    FROM    OE_PRICE_ADJS_HISTORY
    WHERE  PRICE_ADJUSTMENT_ID = p_price_adjustment_id
    and HEADER_ID              = p_header_id
    AND LINE_ID IS NULL
    and version_number         = p_version
    AND    (PHASE_CHANGE_FLAG  = p_phase_change_flag
     OR     (nvl(p_phase_change_flag, 'NULL') <> 'Y'
     AND     VERSION_FLAG = 'Y'));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    --       RAISE NO_DATA_FOUND;
	 null;
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
               'Query_HEADER_Adj_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END QUERY_HEADER_Adj_ROW;

PROCEDURE QUERY_HEADER_ADJ_TRANS_ROW
(p_header_id	                  NUMBER,
 p_price_adjustment_id	          NUMBER,
 p_version	                  NUMBER,
 x_header_adj_rec                    IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type)
IS
l_org_id                NUMBER;
l_phase_change_flag     VARCHAR2(1);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering OE_VERSION_PRICE_ADJUST_COMP.QUERY_HEADER_ADJ_TRANS_ROW', 1);
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('hprice' ||p_price_adjustment_id);
  oe_debug_pub.add('version' ||p_version);
END IF;

    l_org_id := OE_GLOBALS.G_ORG_ID;

    IF l_org_id IS NULL THEN
      OE_GLOBALS.Set_Context;
      l_org_id := OE_GLOBALS.G_ORG_ID;
    END IF;

    SELECT  distinct ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       AUTOMATIC_FLAG
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DISCOUNT_ID
    ,       DISCOUNT_LINE_ID
    ,       HEADER_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       PERCENT
    ,       PRICE_ADJUSTMENT_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,	    LIST_HEADER_ID
    ,	    LIST_LINE_ID
    ,	    LIST_LINE_TYPE_CODE
    ,	    MODIFIER_MECHANISM_TYPE_CODE
    ,	    MODIFIED_FROM
    ,	    MODIFIED_TO
    ,	    UPDATED_FLAG
    ,	    UPDATE_ALLOWED
    ,	    APPLIED_FLAG
    ,	    CHANGE_REASON_CODE
    ,	    CHANGE_REASON_TEXT
    ,	    operand
    ,       arithmetic_operator
    ,	    COST_ID
    ,	    TAX_CODE
    ,	    TAX_EXEMPT_FLAG
    ,	    TAX_EXEMPT_NUMBER
    ,	    TAX_EXEMPT_REASON_CODE
    ,	    PARENT_ADJUSTMENT_ID
    ,	    INVOICED_FLAG
    ,	    ESTIMATED_FLAG
    ,	    INC_IN_SALES_PERFORMANCE
    ,	    SPLIT_ACTION_CODE
    ,	    ADJUSTED_AMOUNT
    ,	    PRICING_PHASE_ID
    ,	    CHARGE_TYPE_CODE
    ,	    CHARGE_SUBTYPE_CODE
    ,       list_line_no
    ,       source_system_code
    ,       benefit_qty
    ,       benefit_uom_code
    ,       print_on_invoice_flag
    ,       expiration_date
    ,       rebate_transaction_type_code
    ,       rebate_transaction_reference
    ,       rebate_payment_system_code
    ,       redeemed_date
    ,       redeemed_flag
    ,       accrual_flag
    ,       range_break_quantity
    ,       accrual_conversion_rate
    ,       pricing_group_sequence
    ,       modifier_level_code
    ,       price_break_type_code
    ,       substitution_attribute
    ,       proration_type_code
    ,       CREDIT_OR_CHARGE_FLAG
    ,       INCLUDE_ON_RETURNS_FLAG
    ,       AC_ATTRIBUTE1
    ,       AC_ATTRIBUTE10
    ,       AC_ATTRIBUTE11
    ,       AC_ATTRIBUTE12
    ,       AC_ATTRIBUTE13
    ,       AC_ATTRIBUTE14
    ,       AC_ATTRIBUTE15
    ,       AC_ATTRIBUTE2
    ,       AC_ATTRIBUTE3
    ,       AC_ATTRIBUTE4
    ,       AC_ATTRIBUTE5
    ,       AC_ATTRIBUTE6
    ,       AC_ATTRIBUTE7
    ,       AC_ATTRIBUTE8
    ,       AC_ATTRIBUTE9
    ,       AC_CONTEXT
    ,       orig_sys_discount_ref
    ,       OPERAND_PER_PQTY
    ,       ADJUSTED_AMOUNT_PER_PQTY
--    ,       INVOICED_AMOUNT
    ,	    LOCK_CONTROL
INTO
    x_header_adj_rec.ATTRIBUTE1
    ,x_header_adj_rec.ATTRIBUTE10
    ,x_header_adj_rec.ATTRIBUTE11
    ,x_header_adj_rec.ATTRIBUTE12
    ,x_header_adj_rec.ATTRIBUTE13
    ,x_header_adj_rec.ATTRIBUTE14
    ,x_header_adj_rec.ATTRIBUTE15
    ,x_header_adj_rec.ATTRIBUTE2
    ,x_header_adj_rec.ATTRIBUTE3
    ,x_header_adj_rec.ATTRIBUTE4
    ,x_header_adj_rec.ATTRIBUTE5
    ,x_header_adj_rec.ATTRIBUTE6
    ,x_header_adj_rec.ATTRIBUTE7
    ,x_header_adj_rec.ATTRIBUTE8
    ,x_header_adj_rec.ATTRIBUTE9
    ,x_header_adj_rec.AUTOMATIC_FLAG
    ,x_header_adj_rec.CONTEXT
    ,x_header_adj_rec.CREATED_BY
    ,x_header_adj_rec.CREATION_DATE
    ,x_header_adj_rec.DISCOUNT_ID
    ,x_header_adj_rec.DISCOUNT_LINE_ID
    ,x_header_adj_rec.HEADER_ID
    ,x_header_adj_rec.LAST_UPDATED_BY
    ,x_header_adj_rec.LAST_UPDATE_DATE
    ,x_header_adj_rec.LAST_UPDATE_LOGIN
    ,x_header_adj_rec.LINE_ID
    ,x_header_adj_rec.PERCENT
    ,x_header_adj_rec.PRICE_ADJUSTMENT_ID
    ,x_header_adj_rec.PROGRAM_APPLICATION_ID
    ,x_header_adj_rec.PROGRAM_ID
    ,x_header_adj_rec.PROGRAM_UPDATE_DATE
    ,x_header_adj_rec.REQUEST_ID
    ,x_header_adj_rec.LIST_HEADER_ID
    ,x_header_adj_rec.LIST_LINE_ID
    ,x_header_adj_rec.LIST_LINE_TYPE_CODE
    ,x_header_adj_rec.MODIFIER_MECHANISM_TYPE_CODE
    ,x_header_adj_rec.MODIFIED_FROM
    ,x_header_adj_rec.MODIFIED_TO
    ,x_header_adj_rec.UPDATED_FLAG
    ,x_header_adj_rec.UPDATE_ALLOWED
    ,x_header_adj_rec.APPLIED_FLAG
    ,x_header_adj_rec.CHANGE_REASON_CODE
    ,x_header_adj_rec.CHANGE_REASON_TEXT
    ,x_header_adj_rec.operand
    ,x_header_adj_rec.arithmetic_operator
    ,x_header_adj_rec.COST_ID
    ,x_header_adj_rec.TAX_CODE
    ,x_header_adj_rec.TAX_EXEMPT_FLAG
    ,x_header_adj_rec.TAX_EXEMPT_NUMBER
    ,x_header_adj_rec.TAX_EXEMPT_REASON_CODE
    ,x_header_adj_rec.PARENT_ADJUSTMENT_ID
    ,x_header_adj_rec.INVOICED_FLAG
    ,x_header_adj_rec.ESTIMATED_FLAG
    ,x_header_adj_rec.INC_IN_SALES_PERFORMANCE
    ,x_header_adj_rec.SPLIT_ACTION_CODE
    ,x_header_adj_rec.ADJUSTED_AMOUNT
    ,x_header_adj_rec.PRICING_PHASE_ID
    ,x_header_adj_rec.CHARGE_TYPE_CODE
    ,x_header_adj_rec.CHARGE_SUBTYPE_CODE
    ,x_header_adj_rec.list_line_no
    ,x_header_adj_rec.source_system_code
    ,x_header_adj_rec.benefit_qty
    ,x_header_adj_rec.benefit_uom_code
    ,x_header_adj_rec.print_on_invoice_flag
    ,x_header_adj_rec.expiration_date
    ,x_header_adj_rec.rebate_transaction_type_code
    ,x_header_adj_rec.rebate_transaction_reference
    ,x_header_adj_rec.rebate_payment_system_code
    ,x_header_adj_rec.redeemed_date
    ,x_header_adj_rec.redeemed_flag
    ,x_header_adj_rec.accrual_flag
    ,x_header_adj_rec.range_break_quantity
    ,x_header_adj_rec.accrual_conversion_rate
    ,x_header_adj_rec.pricing_group_sequence
    ,x_header_adj_rec.modifier_level_code
    ,x_header_adj_rec.price_break_type_code
    ,x_header_adj_rec.substitution_attribute
    ,x_header_adj_rec.proration_type_code
    ,x_header_adj_rec.CREDIT_OR_CHARGE_FLAG
    ,x_header_adj_rec.INCLUDE_ON_RETURNS_FLAG
    ,x_header_adj_rec.AC_ATTRIBUTE1
    ,x_header_adj_rec.AC_ATTRIBUTE10
    ,x_header_adj_rec.AC_ATTRIBUTE11
    ,x_header_adj_rec.AC_ATTRIBUTE12
    ,x_header_adj_rec.AC_ATTRIBUTE13
    ,x_header_adj_rec.AC_ATTRIBUTE14
    ,x_header_adj_rec.AC_ATTRIBUTE15
    ,x_header_adj_rec.AC_ATTRIBUTE2
    ,x_header_adj_rec.AC_ATTRIBUTE3
    ,x_header_adj_rec.AC_ATTRIBUTE4
    ,x_header_adj_rec.AC_ATTRIBUTE5
    ,x_header_adj_rec.AC_ATTRIBUTE6
    ,x_header_adj_rec.AC_ATTRIBUTE7
    ,x_header_adj_rec.AC_ATTRIBUTE8
    ,x_header_adj_rec.AC_ATTRIBUTE9
    ,x_header_adj_rec.AC_CONTEXT
    ,x_header_adj_rec.orig_sys_discount_ref
    ,x_header_adj_rec.OPERAND_PER_PQTY
    ,x_header_adj_rec.ADJUSTED_AMOUNT_PER_PQTY
   -- ,x_header_adj_rec.INVOICED_AMOUNT
    ,x_header_adj_rec.LOCK_CONTROL
    FROM    OE_PRICE_ADJUSTMENTS
    WHERE  PRICE_ADJUSTMENT_ID = p_price_adjustment_id
    and HEADER_ID = p_header_id AND LINE_ID IS NULL ;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    --       RAISE NO_DATA_FOUND;
	 null;
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
               'Query_HEADER_Adj_TRANS_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END QUERY_HEADER_Adj_TRANS_ROW;

PROCEDURE COMPARE_HEADER_adj_ATTRIBUTES
(p_header_id	                  NUMBER,
 p_price_adjustment_id	          NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag        VARCHAR2,
 g_curr_phase_change_flag         VARCHAR2,
 g_next_phase_change_flag         VARCHAR2,
 x_header_adj_changed_attr_tbl    IN OUT NOCOPY OE_VERSION_PRICE_ADJUST_COMP.header_adj_tbl_type,
 p_total_lines                    NUMBER)
IS

p_curr_rec                       OE_Order_PUB.Header_adj_Rec_Type;
p_next_rec                       OE_Order_PUB.Header_adj_Rec_Type;
p_prior_rec                      OE_Order_PUB.Header_adj_Rec_Type;


v_totcol NUMBER:=10;
v_header_col VARCHAR2(50);
ind NUMBER;
prior_exists VARCHAR2(1) := 'N';
j NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
p_prior_rec_exists VARCHAR2(1) := 'N';
p_curr_rec_exists VARCHAR2(1)  := 'N';
p_next_rec_exists VARCHAR2(1)  := 'N';
p_trans_rec_exists VARCHAR2(1)  := 'N';
BEGIN

IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering  comparing_header_adj_attributes');
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('price_adjustment_id' ||p_price_adjustment_id);
  oe_debug_pub.add('prior version' ||p_prior_version);
  oe_debug_pub.add('current version' ||p_current_version);
  oe_debug_pub.add('next version' ||p_next_version);
  oe_debug_pub.add('max version' ||g_max_version);
  oe_debug_pub.add('trans version' ||g_trans_version);
END IF;

if p_total_lines > 0 THEN
IF l_debug_level > 0 THEN
  oe_debug_pub.add(' p_total_lines '||p_total_lines);
end if;
ind := p_total_lines;
ELSE
ind := 0;
end if;

IF p_price_adjustment_id IS NOT NULL THEN

p_prior_rec := NULL;
p_curr_rec := NULL;
p_next_rec := NULL;

IF l_debug_level > 0 THEN
  oe_debug_pub.add(' Quering prior line version details');
  oe_debug_pub.add('prior version' ||p_prior_version);
END IF;

IF p_prior_version IS NOT NULL THEN
OE_VERSION_PRICE_ADJUST_COMP.QUERY_HEADER_adj_ROW(p_header_id      => p_header_id,
                          p_price_adjustment_id       => p_price_adjustment_id,
                          p_version                   => p_prior_version,
                          p_phase_change_flag    => g_prior_phase_change_flag,
			  x_header_adj_rec            => p_prior_rec);
     IF p_prior_rec.price_adjustment_id is NULL THEN
          p_prior_rec_exists := 'N';
     ELSE
          p_prior_rec_exists := 'Y';
     END IF;
END IF;
IF l_debug_level > 0 THEN
  oe_debug_pub.add(' Quering current line version details');
  oe_debug_pub.add('current version' ||p_current_version);
END IF;

IF p_current_version IS NOT NULL THEN
OE_VERSION_PRICE_ADJUST_COMP.QUERY_HEADER_adj_ROW(p_header_id      => p_header_id,
                          p_price_adjustment_id       => p_price_adjustment_id,
			  p_version                   => p_current_version,
                          p_phase_change_flag    => g_curr_phase_change_flag,
			  x_header_adj_rec            => p_curr_rec);
     IF p_curr_rec.price_adjustment_id is NULL THEN
          p_curr_rec_exists := 'N';
     ELSE
          p_curr_rec_exists := 'Y';
     END IF;

END IF;
IF l_debug_level > 0 THEN
  oe_debug_pub.add(' Quering next/trans line version details');
  oe_debug_pub.add('next version' ||p_next_version);
  oe_debug_pub.add('trans version' ||g_trans_version);
END IF;

IF p_next_version = g_trans_version then
       IF g_trans_version is not null then
OE_VERSION_PRICE_ADJUST_COMP.QUERY_HEADER_adj_TRANS_ROW(p_header_id    => p_header_id,
                          p_price_adjustment_id           => p_price_adjustment_id,
                          p_version                       => p_next_version,
			  x_header_adj_rec                => p_next_rec);
       END IF;
     IF p_next_rec.price_adjustment_id is NULL THEN
          p_trans_rec_exists := 'N';
     ELSE
          p_trans_rec_exists := 'Y';
          p_next_rec_exists := 'Y';
     END IF;
ELSE
IF p_next_version IS NOT NULL THEN
OE_VERSION_PRICE_ADJUST_COMP.QUERY_HEADER_adj_ROW(p_header_id      => p_header_id,
                          p_price_adjustment_id       => p_price_adjustment_id,
                          p_version                   => p_next_version,
                          p_phase_change_flag    => g_next_phase_change_flag,
			  x_header_adj_rec            => p_next_rec);
     IF p_next_rec.price_adjustment_id is NULL THEN
          p_next_rec_exists := 'N';
     ELSE
          p_next_rec_exists := 'Y';
     END IF;
END IF;
END IF;

IF l_debug_level > 0 THEN
oe_debug_pub.add(' p_prior_rec adjustments'||p_prior_rec.price_adjustment_id);
oe_debug_pub.add(' p_curr_rec '||p_curr_rec.price_adjustment_id);
oe_debug_pub.add(' p_next_rec '||p_next_rec.price_adjustment_id);
oe_debug_pub.add(' p_prior_reclist header id'||p_prior_rec.list_header_id);
oe_debug_pub.add(' p_curr_rec '||p_curr_rec.list_header_id);
oe_debug_pub.add(' p_next_rec '||p_next_rec.list_header_id);
    oe_debug_pub.add(' checking whether price_adjustment_id are same or not');
    oe_debug_pub.add(' p_prior_rec_exists'||p_prior_rec_exists);
    oe_debug_pub.add(' p_curr_rec_exists'||p_curr_rec_exists);
    oe_debug_pub.add(' p_next_rec_exists'||p_next_rec_exists);
    oe_debug_pub.add(' p_trans_rec_exists'||p_trans_rec_exists);
END IF;
IF  (p_prior_rec_exists = 'Y' and p_curr_rec_exists ='Y') OR
    (p_curr_rec_exists = 'Y' and p_next_rec_exists ='Y') THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' both exists - checking if both are same');
         END IF;
       IF OE_Globals.Equal(p_prior_rec.list_header_id,p_curr_rec.list_header_id) OR
         OE_Globals.Equal( p_curr_rec.list_header_id, p_next_rec.list_header_id) THEN
/****************************/

/****************************/
/* START attribute1*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute1,
       p_prior_rec.attribute1) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute1';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute1;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute1;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute1,
       p_next_rec.attribute1) THEN
    IF prior_exists = 'Y' THEN
   x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute1;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute1';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute1;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute1;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute1;
END IF;
END IF; /*  NEXT */

/* END attribute1*/
/****************************/

/****************************/
/* START attribute2*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute2,
       p_prior_rec.attribute2) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute2';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute2;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute2;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute2,
       p_next_rec.attribute2) THEN
    IF prior_exists = 'Y' THEN
   x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute2;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute2';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute2;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute2;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute2;
END IF;
END IF; /*  NEXT */

/* END attribute2*/
/****************************/
/****************************/
/* START attribute3*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute3,
       p_prior_rec.attribute3) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute3';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute3;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute3;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute3,
       p_next_rec.attribute3) THEN
    IF prior_exists = 'Y' THEN
   x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute3;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute3';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute3;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute3;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute3;
END IF;
END IF; /*  NEXT */

/* END attribute3*/
/****************************/

/****************************/
/* START attribute4*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute4,
       p_prior_rec.attribute4) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute4';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute4;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute4;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute4,
       p_next_rec.attribute4) THEN
    IF prior_exists = 'Y' THEN
   x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute4;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute4';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute4;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute4;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute4;
END IF;
END IF; /*  NEXT */

/* END attribute4*/
/****************************/
/****************************/
/* START attribute5*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute5,
       p_prior_rec.attribute5) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute5';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute5;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute5;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute5,
       p_next_rec.attribute5) THEN
    IF prior_exists = 'Y' THEN
   x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute5;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute5';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute5;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute5;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute5;
END IF;
END IF; /*  NEXT */

/* END attribute5*/
/****************************/

/****************************/
/* START attribute6*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute6,
       p_prior_rec.attribute6) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute6';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute6;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute6;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute6,
       p_next_rec.attribute6) THEN
    IF prior_exists = 'Y' THEN
   x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute6;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute6';
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute6;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute6;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute6;
END IF;
END IF; /*  NEXT */

/* END attribute6*/
/****************************/
/****************************/
/* START attribute7*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute7,
       p_prior_rec.attribute7) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute7';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute7;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute7;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute7,
       p_next_rec.attribute7) THEN
    IF prior_exists = 'Y' THEN
   x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute7;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute7';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute7;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute7;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute7;
END IF;
END IF; /*  NEXT */

/* END attribute7*/
/****************************/

/****************************/
/* START attribute8*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute8,
       p_prior_rec.attribute8) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute8';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute8;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute8;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute8,
       p_next_rec.attribute8) THEN
    IF prior_exists = 'Y' THEN
   x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute8;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute8';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute8;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute8;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute8;
END IF;
END IF; /*  NEXT */

/* END attribute8*/
/****************************/
/****************************/
/* START attribute9*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute9,
       p_prior_rec.attribute9) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute9';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute9;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute9;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute9,
       p_next_rec.attribute9) THEN
    IF prior_exists = 'Y' THEN
   x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute9;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute9';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute9;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute9;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute9;
END IF;
END IF; /*  NEXT */

/* END attribute9*/
/****************************/

/****************************/
/* START attribute10*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute10,
       p_prior_rec.attribute10) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute10';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute10;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute10;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute10,
       p_next_rec.attribute10) THEN
    IF prior_exists = 'Y' THEN
   x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute10;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute10';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute10;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute10;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute10;
END IF;
END IF; /*  NEXT */

/* END attribute10*/
/****************************/

/****************************/
/* START attribute11*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute11,
       p_prior_rec.attribute11) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute11';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute11;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute11;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute11,
       p_next_rec.attribute11) THEN
    IF prior_exists = 'Y' THEN
   x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute11;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute11';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute11;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute11;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute11;
END IF;
END IF; /*  NEXT */

/* END attribute11*/
/****************************/

/****************************/
/* START attribute12*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute12,
       p_prior_rec.attribute12) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute12';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute12;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute12;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute12,
       p_next_rec.attribute12) THEN
    IF prior_exists = 'Y' THEN
   x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute12;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute12';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute12;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute12;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute12;
END IF;
END IF; /*  NEXT */

/* END attribute12*/
/****************************/

/****************************/
/* START attribute13*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute13,
       p_prior_rec.attribute13) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute13';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute13;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute13;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute13,
       p_next_rec.attribute13) THEN
    IF prior_exists = 'Y' THEN
   x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute13;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute13';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute13;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute13;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute13;
END IF;
END IF; /*  NEXT */

/* END attribute13*/
/****************************/

/****************************/
/* START attribute14*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute14,
       p_prior_rec.attribute14) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute14';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute14;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute14;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute14,
       p_next_rec.attribute14) THEN
    IF prior_exists = 'Y' THEN
   x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute14;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute14';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute14;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute14;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute14;
END IF;
END IF; /*  NEXT */

/* END attribute14*/
/****************************/

/****************************/
/* START attribute15*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute15,
       p_prior_rec.attribute15) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute15';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute15;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute15;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute15,
       p_next_rec.attribute15) THEN
    IF prior_exists = 'Y' THEN
   x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute15;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute15';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute15;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute15;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute15;
END IF;
END IF; /*  NEXT */

/* END attribute15*/
/****************************/
/****************************/
/* START context*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.context,
       p_prior_rec.context) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'context';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.context;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.context;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.context,
       p_next_rec.context) THEN
    IF prior_exists = 'Y' THEN
   x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.context;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'context';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.context;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.context;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.context;
END IF;
END IF; /*  NEXT */

/* END context*/

/****************************/

/****************************/
/* START AUTOMATIC_FLAG*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.AUTOMATIC_FLAG,
       p_prior_rec.AUTOMATIC_FLAG) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'AUTOMATIC_FLAG';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.AUTOMATIC_FLAG;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.AUTOMATIC_FLAG;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.AUTOMATIC_FLAG,
       p_next_rec.AUTOMATIC_FLAG) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.AUTOMATIC_FLAG;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'AUTOMATIC_FLAG';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.AUTOMATIC_FLAG;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.AUTOMATIC_FLAG;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.AUTOMATIC_FLAG;
END IF;
END IF; /*  NEXT */

/* END AUTOMATIC_FLAG*/
/****************************/

/****************************/
/* START LIST_LINE_TYPE_CODE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.LIST_LINE_TYPE_CODE,
       p_prior_rec.LIST_LINE_TYPE_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'LIST_LINE_TYPE';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.LIST_LINE_TYPE_CODE;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.LIST_LINE_TYPE_CODE;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.LIST_LINE_TYPE_CODE,
       p_next_rec.LIST_LINE_TYPE_CODE) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.LIST_LINE_TYPE_CODE;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'LIST_LINE_TYPE';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.LIST_LINE_TYPE_CODE;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.LIST_LINE_TYPE_CODE;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.LIST_LINE_TYPE_CODE;
END IF;
END IF; /*  NEXT */

/* END LIST_LINE_TYPE_CODE*/
/****************************/


/****************************/
/* START CHANGE_REASON_CODE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CHANGE_REASON_CODE,
       p_prior_rec.CHANGE_REASON_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'CHANGE_REASON_CODE';
   x_header_adj_changed_attr_tbl(ind).prior_id        := p_prior_rec.CHANGE_REASON_CODE;
   x_header_adj_changed_attr_tbl(ind).prior_value      :=  OE_ID_TO_VALUE.change_reason(p_prior_rec.CHANGE_REASON_CODE);
   x_header_adj_changed_attr_tbl(ind).current_id      := p_curr_rec.CHANGE_REASON_CODE;
   x_header_adj_changed_attr_tbl(ind).current_value      :=  OE_ID_TO_VALUE.change_reason(p_curr_rec.CHANGE_REASON_CODE);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CHANGE_REASON_CODE,
       p_next_rec.CHANGE_REASON_CODE) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     :=  OE_ID_TO_VALUE.change_reason(p_curr_rec.CHANGE_REASON_CODE);
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'CHANGE_REASON_CODE';
   x_header_adj_changed_attr_tbl(ind).prior_id        := p_prior_rec.CHANGE_REASON_CODE;
   x_header_adj_changed_attr_tbl(ind).prior_value      :=  OE_ID_TO_VALUE.change_reason(p_prior_rec.CHANGE_REASON_CODE);
   x_header_adj_changed_attr_tbl(ind).current_id      := p_curr_rec.CHANGE_REASON_CODE;
   x_header_adj_changed_attr_tbl(ind).current_value      :=  OE_ID_TO_VALUE.change_reason(p_curr_rec.CHANGE_REASON_CODE);
   x_header_adj_changed_attr_tbl(ind).next_id         := p_next_rec.CHANGE_REASON_CODE;
   x_header_adj_changed_attr_tbl(ind).next_value      :=  OE_ID_TO_VALUE.change_reason(p_next_rec.CHANGE_REASON_CODE);
END IF;
END IF; /*  NEXT */

/* END CHANGE_REASON_CODE*/
/****************************/

/****************************/
/* START CHANGE_REASON_TEXT*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CHANGE_REASON_TEXT,
       p_prior_rec.CHANGE_REASON_TEXT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'CHANGE_REASON_TEXT';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.CHANGE_REASON_TEXT;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.CHANGE_REASON_TEXT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CHANGE_REASON_TEXT,
       p_next_rec.CHANGE_REASON_TEXT) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.CHANGE_REASON_TEXT;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'CHANGE_REASON_TEXT';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.CHANGE_REASON_TEXT;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.CHANGE_REASON_TEXT;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.CHANGE_REASON_TEXT;
END IF;
END IF; /*  NEXT */

/* END CHANGE_REASON_TEXT*/
/****************************/


/****************************/
/* START list_line_no*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.list_line_no,
       p_prior_rec.list_line_no) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'list_line_no';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.list_line_no;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.list_line_no;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.list_line_no,
       p_next_rec.list_line_no) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.list_line_no;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'list_line_no';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.list_line_no;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.list_line_no;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.list_line_no;
END IF;
END IF; /*  NEXT */

/* END list_line_no*/
/****************************/
/****************************/
/* START source_system_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.source_system_code,
       p_prior_rec.source_system_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'source_system_code';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.source_system_code;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.source_system_code;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.source_system_code,
       p_next_rec.source_system_code) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.source_system_code;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'source_system_code';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.source_system_code;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.source_system_code;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.source_system_code;
END IF;
END IF; /*  NEXT */

/* END source_system_code*/
/****************************/

/****************************/
/* START benefit_qty*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.benefit_qty,
       p_prior_rec.benefit_qty) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'benefit_qty';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.benefit_qty;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.benefit_qty;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.benefit_qty,
       p_next_rec.benefit_qty) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.benefit_qty;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'benefit_qty';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.benefit_qty;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.benefit_qty;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.benefit_qty;
END IF;
END IF; /*  NEXT */

/* END benefit_qty*/
/****************************/

/****************************/
/* START benefit_uom_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.benefit_uom_code,
       p_prior_rec.benefit_uom_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'benefit_uom_code';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.benefit_uom_code;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.benefit_uom_code;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.benefit_uom_code,
       p_next_rec.benefit_uom_code) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.benefit_uom_code;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'benefit_uom_code';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.benefit_uom_code;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.benefit_uom_code;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.benefit_uom_code;
END IF;
END IF; /*  NEXT */

/* END benefit_uom_code*/
/****************************/

/****************************/
/* START expiration_date*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.expiration_date,
       p_prior_rec.expiration_date) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'expiration_date';
   x_header_adj_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.expiration_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_adj_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.expiration_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.expiration_date,
       p_next_rec.expiration_date) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := to_char(p_curr_rec.expiration_date,'DD-MON-YYYY HH24:MI:SS');
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'expiration_date';
   x_header_adj_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.expiration_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_adj_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.expiration_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_adj_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.expiration_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  NEXT */

/* END expiration_date*/
/****************************/

/****************************/
/* START rebate_transaction_type_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.rebate_transaction_type_code,
       p_prior_rec.rebate_transaction_type_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'rebate_transaction_type_code';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.rebate_transaction_type_code;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.rebate_transaction_type_code;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.rebate_transaction_type_code,
       p_next_rec.rebate_transaction_type_code) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.rebate_transaction_type_code;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'rebate_transaction_type_code';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.rebate_transaction_type_code;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.rebate_transaction_type_code;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.rebate_transaction_type_code;
END IF;
END IF; /*  NEXT */

/* END rebate_transaction_type_code*/
/****************************/

/****************************/
/* START rebate_transaction_reference*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.rebate_transaction_reference,
       p_prior_rec.rebate_transaction_reference) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'rebate_transaction_reference';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.rebate_transaction_reference;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.rebate_transaction_reference;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.rebate_transaction_reference,
       p_next_rec.rebate_transaction_reference) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.rebate_transaction_reference;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'rebate_transaction_reference';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.rebate_transaction_reference;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.rebate_transaction_reference;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.rebate_transaction_reference;
END IF;
END IF; /*  NEXT */

/* END rebate_transaction_reference*/
/****************************/

/****************************/
/* START rebate_payment_system_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.rebate_payment_system_code,
       p_prior_rec.rebate_payment_system_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'rebate_payment_system_code';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.rebate_payment_system_code;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.rebate_payment_system_code;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.rebate_payment_system_code,
       p_next_rec.rebate_payment_system_code) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.rebate_payment_system_code;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'rebate_payment_system_code';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.rebate_payment_system_code;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.rebate_payment_system_code;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.rebate_payment_system_code;
END IF;
END IF; /*  NEXT */

/* END rebate_payment_system_code*/
/****************************/

/****************************/
/* START redeemed_date*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.redeemed_date,
       p_prior_rec.redeemed_date) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'redeemed_date';
   x_header_adj_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.redeemed_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_adj_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.redeemed_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.redeemed_date,
       p_next_rec.redeemed_date) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := to_char(p_curr_rec.redeemed_date,'DD-MON-YYYY HH24:MI:SS');
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'redeemed_date';
   x_header_adj_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.redeemed_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_adj_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.redeemed_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_adj_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.redeemed_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  NEXT */

/* END redeemed_date*/
/****************************/

/****************************/
/* START redeemed_flag*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.redeemed_flag,
       p_prior_rec.redeemed_flag) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'redeemed_flag';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.redeemed_flag;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.redeemed_flag;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.redeemed_flag,
       p_next_rec.redeemed_flag) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.redeemed_flag;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'redeemed_flag';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.redeemed_flag;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.redeemed_flag;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.redeemed_flag;
END IF;
END IF; /*  NEXT */

/* END redeemed_flag*/
/****************************/

/****************************/
/* START accrual_flag*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.accrual_flag,
       p_prior_rec.accrual_flag) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'accrual_flag';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.accrual_flag;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.accrual_flag;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.accrual_flag,
       p_next_rec.accrual_flag) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.accrual_flag;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'accrual_flag';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.accrual_flag;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.accrual_flag;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.accrual_flag;
END IF;
END IF; /*  NEXT */

/* END accrual_flag*/
/****************************/

/****************************/
/* START range_break_quantity*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.range_break_quantity,
       p_prior_rec.range_break_quantity) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'range_break_quantity';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.range_break_quantity;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.range_break_quantity;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.range_break_quantity,
       p_next_rec.range_break_quantity) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.range_break_quantity;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'range_break_quantity';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.range_break_quantity;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.range_break_quantity;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.range_break_quantity;
END IF;
END IF; /*  NEXT */

/* END range_break_quantity*/
/****************************/

/****************************/
/* START accrual_conversion_rate*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.accrual_conversion_rate,
       p_prior_rec.accrual_conversion_rate) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'accrual_conversion_rate';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.accrual_conversion_rate;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.accrual_conversion_rate;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.accrual_conversion_rate,
       p_next_rec.accrual_conversion_rate) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.accrual_conversion_rate;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'accrual_conversion_rate';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.accrual_conversion_rate;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.accrual_conversion_rate;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.accrual_conversion_rate;
END IF;
END IF; /*  NEXT */

/* END accrual_conversion_rate*/
/****************************/

/****************************/
/* START modifier_level_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.modifier_level_code,
       p_prior_rec.modifier_level_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'modifier_level_code';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.modifier_level_code;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.modifier_level_code;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.modifier_level_code,
       p_next_rec.modifier_level_code) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.modifier_level_code;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'modifier_level_code';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.modifier_level_code;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.modifier_level_code;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.modifier_level_code;
END IF;
END IF; /*  NEXT */

/* END modifier_level_code*/
/****************************/

/****************************/
/* START price_break_type_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.price_break_type_code,
       p_prior_rec.price_break_type_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'price_break_type_code';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.price_break_type_code;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.price_break_type_code;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.price_break_type_code,
       p_next_rec.price_break_type_code) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.price_break_type_code;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'price_break_type_code';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.price_break_type_code;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.price_break_type_code;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.price_break_type_code;
END IF;
END IF; /*  NEXT */

/* END price_break_type_code*/
/****************************/

/****************************/
/* START substitution_attribute*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.substitution_attribute,
       p_prior_rec.substitution_attribute) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'substitution_attribute';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.substitution_attribute;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.substitution_attribute;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.substitution_attribute,
       p_next_rec.substitution_attribute) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.substitution_attribute;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'substitution_attribute';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.substitution_attribute;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.substitution_attribute;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.substitution_attribute;
END IF;
END IF; /*  NEXT */

/* END substitution_attribute*/
/****************************/

/****************************/
/* START proration_type_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.proration_type_code,
       p_prior_rec.proration_type_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'proration_type_code';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.proration_type_code;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.proration_type_code;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.proration_type_code,
       p_next_rec.proration_type_code) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.proration_type_code;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'proration_type_code';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.proration_type_code;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.proration_type_code;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.proration_type_code;
END IF;
END IF; /*  NEXT */

/* END proration_type_code*/
/****************************/

/****************************/
/* START ac_attribute1*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute1,
       p_prior_rec.ac_attribute1) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute1';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute1;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute1;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute1,
       p_next_rec.ac_attribute1) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute1;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute1';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute1;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute1;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute1;
END IF;
END IF; /*  NEXT */

/* END ac_attribute1*/
/****************************/

/****************************/
/* START ac_attribute2*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute2,
       p_prior_rec.ac_attribute2) THEN
 null;
ELSE
   ind := ind+1;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   prior_exists := 'Y';
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute2';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute2;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute2;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute2,
       p_next_rec.ac_attribute2) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute2;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute2';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute2;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute2;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute2;
END IF;
END IF; /*  NEXT */

/* END ac_attribute2*/
/****************************/
/****************************/
/* START ac_attribute3*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute3,
       p_prior_rec.ac_attribute3) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute3';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute3;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute3;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute3,
       p_next_rec.ac_attribute3) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute3;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute3';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute3;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute3;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute3;
END IF;
END IF; /*  NEXT */

/* END ac_attribute3*/
/****************************/

/****************************/
/* START ac_attribute4*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute4,
       p_prior_rec.ac_attribute4) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute4';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute4;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute4;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute4,
       p_next_rec.ac_attribute4) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute4;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute4';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute4;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute4;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute4;
END IF;
END IF; /*  NEXT */

/* END ac_attribute4*/
/****************************/
/****************************/
/* START ac_attribute5*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute5,
       p_prior_rec.ac_attribute5) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute5';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute5;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute5;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute5,
       p_next_rec.ac_attribute5) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute5;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute5';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute5;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute5;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute5;
END IF;
END IF; /*  NEXT */

/* END ac_attribute5*/
/****************************/

/****************************/
/* START ac_attribute6*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute6,
       p_prior_rec.ac_attribute6) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute6';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute6;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute6;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute6,
       p_next_rec.ac_attribute6) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute6;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute6';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute6;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute6;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute6;
END IF;
END IF; /*  NEXT */

/* END ac_attribute6*/
/****************************/
/****************************/
/* START ac_attribute7*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute7,
       p_prior_rec.ac_attribute7) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute7';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute7;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute7;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute7,
       p_next_rec.ac_attribute7) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute7;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute7;
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute7';
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute7;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute7;
END IF;
END IF; /*  NEXT */

/* END ac_attribute7*/
/****************************/

/****************************/
/* START ac_attribute8*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute8,
       p_prior_rec.ac_attribute8) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute8';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute8;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute8;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute8,
       p_next_rec.ac_attribute8) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute8;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute8';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute8;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute8;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute8;
END IF;
END IF; /*  NEXT */

/* END ac_attribute8*/
/****************************/
/****************************/
/* START ac_attribute9*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute9,
       p_prior_rec.ac_attribute9) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute9';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute9;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute9;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute9,
       p_next_rec.ac_attribute9) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute9;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute9';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute9;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute9;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute9;
END IF;
END IF; /*  NEXT */

/* END ac_attribute9*/
/****************************/

/****************************/
/* START ac_attribute10*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute10,
       p_prior_rec.ac_attribute10) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute10';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute10;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute10;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute10,
       p_next_rec.ac_attribute10) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute10;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute10';
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute10;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute10;
END IF;
END IF; /*  NEXT */

/* END ac_attribute10*/
/****************************/

/****************************/
/* START ac_attribute11*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute11,
       p_prior_rec.ac_attribute11) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute11';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute11;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute11;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute11,
       p_next_rec.ac_attribute11) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute11;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute11';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute10;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute11;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute11;
END IF;
END IF; /*  NEXT */

/* END ac_attribute11*/
/****************************/

/****************************/
/* START ac_attribute12*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute12,
       p_prior_rec.ac_attribute12) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute12';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute12;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute12;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute12,
       p_next_rec.ac_attribute12) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute12;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute12';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute12;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute12;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute12;
END IF;
END IF; /*  NEXT */

/* END ac_attribute12*/
/****************************/

/****************************/
/* START ac_attribute13*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute13,
       p_prior_rec.ac_attribute13) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute13';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute13;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute13;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute13,
       p_next_rec.ac_attribute13) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute13;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute13';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute13;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute13;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute13;
END IF;
END IF; /*  NEXT */

/* END ac_attribute13*/
/****************************/

/****************************/
/* START ac_attribute14*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute14,
       p_prior_rec.ac_attribute14) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute14';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute14;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute14;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute14,
       p_next_rec.ac_attribute14) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute14;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute14';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute14;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute14;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute14;
END IF;
END IF; /*  NEXT */

/* END ac_attribute14*/
/****************************/

/****************************/
/* START ac_attribute15*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute15,
       p_prior_rec.ac_attribute15) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'attribute15';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute15;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute15;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute15,
       p_next_rec.ac_attribute15) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute15;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'attribute15';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute15;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute15;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute15;
END IF;
END IF; /*  NEXT */

/* END ac_attribute15*/
/****************************/

/****************************/
/* START ac_context*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_context,
       p_prior_rec.ac_context) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name  := 'ac_context';
   x_header_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_context;
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_context;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_context,
       p_next_rec.ac_context) THEN
   IF prior_exists = 'Y' THEN
     x_header_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_context;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
 x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_header_adj_changed_attr_tbl(ind).attribute_name := 'ac_context';
   x_header_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_context;
   x_header_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_context;
   x_header_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_context;
END IF;
END IF; /*  NEXT */

/* END ac_context*/
/****************************/
/****************************/

      END IF;  /* if price adjustment is same */
END IF;	/* p and c = Y or c and n=y */

IF l_debug_level > 0 THEN
    oe_debug_pub.add(' before finding new  price_adjustment_id  ');
    oe_debug_pub.add(' p_prior_rec_exists'||p_prior_rec_exists);
    oe_debug_pub.add(' p_curr_rec_exists'||p_curr_rec_exists);
    oe_debug_pub.add(' p_next_rec_exists'||p_next_rec_exists);
    oe_debug_pub.add(' p_trans_rec_exists'||p_trans_rec_exists);
END IF;
IF (p_prior_rec_exists = 'N' and p_curr_rec_exists = 'Y') OR
    (p_curr_rec_exists = 'N' and p_next_rec_exists ='Y') THEN
   IF p_prior_version IS NOT NULL and p_curr_rec_exists = 'Y' THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Prior is not there - current is there');
         END IF;
       ind := ind+1;
       x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
       x_header_adj_changed_attr_tbl(ind).prior_value        :=  null;
       x_header_adj_changed_attr_tbl(ind).current_value      :=  'ADD';
       x_header_adj_changed_attr_tbl(ind).next_value         :=  null;
   ELSIF (p_curr_rec_exists = 'N' and p_next_rec_exists = 'Y') THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Current is not there - next is there');
         END IF;
       ind := ind+1;
       x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_next_rec.list_header_id);
       x_header_adj_changed_attr_tbl(ind).prior_value        :=  null;
       x_header_adj_changed_attr_tbl(ind).current_value      :=  null;
       x_header_adj_changed_attr_tbl(ind).next_value         :=  'ADD';
  end if;
END IF;

IF l_debug_level > 0 THEN
    oe_debug_pub.add(' before finding deleted new_modifier_list');
    oe_debug_pub.add(' p_prior_rec_exists'||p_prior_rec_exists);
    oe_debug_pub.add(' p_curr_rec_exists'||p_curr_rec_exists);
    oe_debug_pub.add(' p_next_rec_exists'||p_next_rec_exists);
    oe_debug_pub.add(' p_trans_rec_exists'||p_trans_rec_exists);
END IF;
IF (p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'N') OR
    (p_curr_rec_exists = 'Y' and p_next_rec_exists ='N') THEN
   IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'N' THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Prior is there - current is not there');
         END IF;
       ind := ind+1;
       x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_prior_rec.list_header_id);
       x_header_adj_changed_attr_tbl(ind).prior_value        :=  null;
       x_header_adj_changed_attr_tbl(ind).current_value      :=  'DELETE';
       x_header_adj_changed_attr_tbl(ind).next_value         :=  null;
   ELSIF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'N' THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' p_next_version'||p_next_version);
               oe_debug_pub.add(' g_trans_version'||g_trans_version);
         END IF;
      --if p_next_version != g_trans_version THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Current is there - next is not there');
         END IF;
       ind := ind+1;
       x_header_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
       x_header_adj_changed_attr_tbl(ind).prior_value        :=  null;
       x_header_adj_changed_attr_tbl(ind).current_value      :=  null;
       x_header_adj_changed_attr_tbl(ind).next_value         :=  'DELETE';
     --end if;
  end if;
END IF;
IF l_debug_level > 0 THEN
  oe_debug_pub.add('******BEFORE COMPARING ATTRIBUTES*************');
  oe_debug_pub.add('current ind '|| ind);
END IF;

END IF; /* line_id not null */
IF l_debug_level > 0 THEN
  oe_debug_pub.add('******AFTER COMPARING ATTRIBUTES*************');
  oe_debug_pub.add('current ind '|| ind);
END IF;
IF l_debug_level  > 0 THEN
   oe_debug_pub.add(' Exiting OE_VERSION_PRICE_ADJUST_COMP.Compare_header_adj_Attributes ');
END IF;
/*
j := 0;
dbms_output.put_line('No of records'||x_header_adj_changed_attr_tbl.count);
WHILE j < x_header_adj_changed_attr_tbl.count
LOOP
j:=j+1;
dbms_output.put_line('attribute value '||x_header_adj_changed_attr_tbl(j).attribute_name ||
||' Prior '||x_header_adj_changed_attr_tbl(j).prior_value||
||' Current '||x_header_adj_changed_attr_tbl(j).current_value ||
||' Next '||x_header_adj_changed_attr_tbl(j).next_value);
END LOOP;
*/
END COMPARE_HEADER_adj_ATTRIBUTES;

PROCEDURE COMPARE_HEADER_adj_VERSIONS
(p_header_id	                  NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag        VARCHAR2,
 g_curr_phase_change_flag         VARCHAR2,
 g_next_phase_change_flag         VARCHAR2,
 x_header_adj_changed_attr_tbl        IN OUT NOCOPY OE_VERSION_PRICE_ADJUST_COMP.header_adj_tbl_type)
IS

CURSOR C_get_adjustments(p_header_id IN NUMBER,p_prior_version IN NUMBER, p_current_version IN NUMBER, p_next_version IN NUMBER) IS
           SELECT distinct price_adjustment_id
           from oe_price_adjs_history
           where header_id = p_header_id
           and line_id is null
           --and phase_change_flag = p_transaction_phase_code
           and version_number in (p_prior_version,p_current_version,p_next_version)
           and list_line_type_code <> 'FREIGHT_CHARGE'
	   and list_header_id IS NOT NULL -- it will be null for TAX and COST
           union
           SELECT price_adjustment_id
           from oe_price_adjustments
           where header_id=p_header_id
           and list_line_type_code <> 'FREIGHT_CHARGE'
	   and list_header_id IS NOT NULL
           and line_id is null;
           --and transaction_phase_code = p_transaction_phase_code;

CURSOR C_get_hist_adjustments(p_header_id IN NUMBER,p_prior_version IN NUMBER, p_current_version IN NUMBER, p_next_version IN NUMBER) IS
           SELECT distinct price_adjustment_id
           from oe_price_adjs_history
           where header_id = p_header_id
           and line_id is null
           and list_line_type_code <> 'FREIGHT_CHARGE'
	   and list_header_id IS NOT NULL
           --and phase_change_flag = p_transaction_phase_code
           and version_number in (p_prior_version,p_current_version,p_next_version);
ind1 NUMBER;
l_price_adjustment_id NUMBER;
total_lines NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering Compare_header_adj_versions');
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('prior version' ||p_prior_version);
  oe_debug_pub.add('current version' ||p_current_version);
  oe_debug_pub.add('next version' ||p_next_version);
  oe_debug_pub.add('max version' ||g_max_version);
  oe_debug_pub.add('trans version' ||g_trans_version);
END IF;

ind1:=0;
total_lines:=0;
IF p_header_id IS NOT NULL THEN
  IF p_next_version = g_trans_version THEN
    OPEN C_GET_adjustments(p_header_id,p_prior_version,p_current_version,p_next_version);
    LOOP
    FETCH C_GET_adjustments INTO l_price_adjustment_id;
    EXIT WHEN C_GET_adjustments%NOTFOUND;
    IF l_debug_level  > 0 THEN
         oe_debug_pub.add('*************adjustments found(trans)******************'||l_price_adjustment_id);    END IF;

     IF l_price_adjustment_id IS NOT NULL THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************before call total price_adjustment_id(trans) ******************'||ind1);
         END IF;
         COMPARE_HEADER_adj_ATTRIBUTES(p_header_id                 => p_header_id,
                          p_price_adjustment_id                     => l_price_adjustment_id,
                          p_prior_version               => p_prior_version,
                          p_current_version             => p_current_version,
                          p_next_version                => p_next_version,
                          g_max_version                 => g_max_version,
                          g_trans_version               => g_trans_version,

                          g_prior_phase_change_flag     => g_prior_phase_change_flag,
                          g_curr_phase_change_flag      => g_curr_phase_change_flag,
                          g_next_phase_change_flag      => g_next_phase_change_flag,
                          x_header_adj_changed_attr_tbl  => x_header_adj_changed_attr_tbl,
                          p_total_lines                 => ind1);
         IF x_header_adj_changed_attr_tbl.count > 0 THEN
                ind1 := x_header_adj_changed_attr_tbl.count;
        --      ind1 := ind1 + total_lines;
         END IF;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************after call total price_adjustment_id(trans) ******************'||ind1);
         END IF;
     END IF; /* price_adjustment_id is not null */
  END LOOP;
  CLOSE C_GET_adjustments;
  ELSE
    OPEN C_GET_HIST_adjustments(p_header_id,p_prior_version,p_current_version,p_next_version);
    LOOP
    FETCH C_GET_HIST_adjustments INTO l_price_adjustment_id;
    EXIT WHEN C_GET_HIST_adjustments%NOTFOUND;
    IF l_debug_level  > 0 THEN
         oe_debug_pub.add('*************adjustments found******************'||l_price_adjustment_id);
    END IF;

     IF l_price_adjustment_id IS NOT NULL THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************before call total price_adjustment ******************'||ind1);
         END IF;
         COMPARE_HEADER_adj_ATTRIBUTES(p_header_id               => p_header_id,
                          p_price_adjustment_id                     => l_price_adjustment_id,
                          p_prior_version               => p_prior_version,
                          p_current_version             => p_current_version,
                          p_next_version                => p_next_version,
                          g_max_version                 => g_max_version,
                          g_prior_phase_change_flag     => g_prior_phase_change_flag,
                          g_curr_phase_change_flag      => g_curr_phase_change_flag,
                          g_next_phase_change_flag      => g_next_phase_change_flag,
                          g_trans_version               => g_trans_version,
                          x_header_adj_changed_attr_tbl       => x_header_adj_changed_attr_tbl,
                          p_total_lines                 => ind1);
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************after call total price_adjustment_id credits ******************'||ind1);
         END IF;
         IF x_header_adj_changed_attr_tbl.count > 0 THEN
                ind1 := x_header_adj_changed_attr_tbl.count;
        --      ind1 := ind1 + total_lines;
         END IF;
     END IF; /* price_adjustment_id is not null */
    END LOOP;
    CLOSE C_GET_HIST_adjustments;
 END IF;/* next equals trans */
END IF;/*header_id is not null*/
END COMPARE_HEADER_adj_VERSIONS;

/***************************************/
PROCEDURE QUERY_line_ADJ_ROW
(p_header_id	                  NUMBER,
 p_price_adjustment_id            NUMBER,
 p_version	                  NUMBER,
 p_phase_change_flag      	  VARCHAR2,
 x_line_adj_rec                    IN OUT NOCOPY OE_Order_PUB.line_Adj_Rec_Type)
IS
l_org_id                NUMBER;
l_phase_change_flag     VARCHAR2(1);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering OE_VERSION_PRICE_ADJUST_COMP.QUERY_line_ADJ_ROW');
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('header' ||p_price_adjustment_id);
  oe_debug_pub.add('version' ||p_version);
END IF;

    l_org_id := OE_GLOBALS.G_ORG_ID;

    IF l_org_id IS NULL THEN
      OE_GLOBALS.Set_Context;
      l_org_id := OE_GLOBALS.G_ORG_ID;
    END IF;


    SELECT  ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       AUTOMATIC_FLAG
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DISCOUNT_ID
    ,       DISCOUNT_LINE_ID
    ,       line_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       PERCENT
    ,       PRICE_ADJUSTMENT_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,	    LIST_HEADER_ID
    ,	    LIST_LINE_ID
    ,	    LIST_LINE_TYPE_CODE
    ,	    MODIFIER_MECHANISM_TYPE_CODE
    ,	    MODIFIED_FROM
    ,	    MODIFIED_TO
    ,	    UPDATED_FLAG
    ,	    UPDATE_ALLOWED
    ,	    APPLIED_FLAG
    ,	    CHANGE_REASON_CODE
    ,	    CHANGE_REASON_TEXT
    ,	    operand
    ,       arithmetic_operator
    ,	    COST_ID
    ,	    TAX_CODE
    ,	    TAX_EXEMPT_FLAG
    ,	    TAX_EXEMPT_NUMBER
    ,	    TAX_EXEMPT_REASON_CODE
    ,	    PARENT_ADJUSTMENT_ID
    ,	    INVOICED_FLAG
    ,	    ESTIMATED_FLAG
    ,	    INC_IN_SALES_PERFORMANCE
    ,	    SPLIT_ACTION_CODE
    ,	    ADJUSTED_AMOUNT
    ,	    PRICING_PHASE_ID
    ,	    CHARGE_TYPE_CODE
    ,	    CHARGE_SUBTYPE_CODE
    ,       list_line_no
    ,       source_system_code
    ,       benefit_qty
    ,       benefit_uom_code
    ,       print_on_invoice_flag
    ,       expiration_date
    ,       rebate_transaction_type_code
    ,       rebate_transaction_reference
    ,       rebate_payment_system_code
    ,       redeemed_date
    ,       redeemed_flag
    ,       accrual_flag
    ,       range_break_quantity
    ,       accrual_conversion_rate
    ,       pricing_group_sequence
    ,       modifier_level_code
    ,       price_break_type_code
    ,       substitution_attribute
    ,       proration_type_code
    ,       CREDIT_OR_CHARGE_FLAG
    ,       INCLUDE_ON_RETURNS_FLAG
    ,       AC_ATTRIBUTE1
    ,       AC_ATTRIBUTE10
    ,       AC_ATTRIBUTE11
    ,       AC_ATTRIBUTE12
    ,       AC_ATTRIBUTE13
    ,       AC_ATTRIBUTE14
    ,       AC_ATTRIBUTE15
    ,       AC_ATTRIBUTE2
    ,       AC_ATTRIBUTE3
    ,       AC_ATTRIBUTE4
    ,       AC_ATTRIBUTE5
    ,       AC_ATTRIBUTE6
    ,       AC_ATTRIBUTE7
    ,       AC_ATTRIBUTE8
    ,       AC_ATTRIBUTE9
    ,       AC_CONTEXT
    ,       orig_sys_discount_ref
    ,       OPERAND_PER_PQTY
    ,       ADJUSTED_AMOUNT_PER_PQTY
--    ,       INVOICED_AMOUNT
    ,	    LOCK_CONTROL
INTO
    x_line_adj_rec.ATTRIBUTE1
    ,x_line_adj_rec.ATTRIBUTE10
    ,x_line_adj_rec.ATTRIBUTE11
    ,x_line_adj_rec.ATTRIBUTE12
    ,x_line_adj_rec.ATTRIBUTE13
    ,x_line_adj_rec.ATTRIBUTE14
    ,x_line_adj_rec.ATTRIBUTE15
    ,x_line_adj_rec.ATTRIBUTE2
    ,x_line_adj_rec.ATTRIBUTE3
    ,x_line_adj_rec.ATTRIBUTE4
    ,x_line_adj_rec.ATTRIBUTE5
    ,x_line_adj_rec.ATTRIBUTE6
    ,x_line_adj_rec.ATTRIBUTE7
    ,x_line_adj_rec.ATTRIBUTE8
    ,x_line_adj_rec.ATTRIBUTE9
    ,x_line_adj_rec.AUTOMATIC_FLAG
    ,x_line_adj_rec.CONTEXT
    ,x_line_adj_rec.CREATED_BY
    ,x_line_adj_rec.CREATION_DATE
    ,x_line_adj_rec.DISCOUNT_ID
    ,x_line_adj_rec.DISCOUNT_LINE_ID
    ,x_line_adj_rec.line_ID
    ,x_line_adj_rec.LAST_UPDATED_BY
    ,x_line_adj_rec.LAST_UPDATE_DATE
    ,x_line_adj_rec.LAST_UPDATE_LOGIN
    ,x_line_adj_rec.LINE_ID
    ,x_line_adj_rec.PERCENT
    ,x_line_adj_rec.PRICE_ADJUSTMENT_ID
    ,x_line_adj_rec.PROGRAM_APPLICATION_ID
    ,x_line_adj_rec.PROGRAM_ID
    ,x_line_adj_rec.PROGRAM_UPDATE_DATE
    ,x_line_adj_rec.REQUEST_ID
    ,x_line_adj_rec.LIST_HEADER_ID
    ,x_line_adj_rec.LIST_LINE_ID
    ,x_line_adj_rec.LIST_LINE_TYPE_CODE
    ,x_line_adj_rec.MODIFIER_MECHANISM_TYPE_CODE
    ,x_line_adj_rec.MODIFIED_FROM
    ,x_line_adj_rec.MODIFIED_TO
    ,x_line_adj_rec.UPDATED_FLAG
    ,x_line_adj_rec.UPDATE_ALLOWED
    ,x_line_adj_rec.APPLIED_FLAG
    ,x_line_adj_rec.CHANGE_REASON_CODE
    ,x_line_adj_rec.CHANGE_REASON_TEXT
    ,x_line_adj_rec.operand
    ,x_line_adj_rec.arithmetic_operator
    ,x_line_adj_rec.COST_ID
    ,x_line_adj_rec.TAX_CODE
    ,x_line_adj_rec.TAX_EXEMPT_FLAG
    ,x_line_adj_rec.TAX_EXEMPT_NUMBER
    ,x_line_adj_rec.TAX_EXEMPT_REASON_CODE
    ,x_line_adj_rec.PARENT_ADJUSTMENT_ID
    ,x_line_adj_rec.INVOICED_FLAG
    ,x_line_adj_rec.ESTIMATED_FLAG
    ,x_line_adj_rec.INC_IN_SALES_PERFORMANCE
    ,x_line_adj_rec.SPLIT_ACTION_CODE
    ,x_line_adj_rec.ADJUSTED_AMOUNT
    ,x_line_adj_rec.PRICING_PHASE_ID
    ,x_line_adj_rec.CHARGE_TYPE_CODE
    ,x_line_adj_rec.CHARGE_SUBTYPE_CODE
    ,x_line_adj_rec.list_line_no
    ,x_line_adj_rec.source_system_code
    ,x_line_adj_rec.benefit_qty
    ,x_line_adj_rec.benefit_uom_code
    ,x_line_adj_rec.print_on_invoice_flag
    ,x_line_adj_rec.expiration_date
    ,x_line_adj_rec.rebate_transaction_type_code
    ,x_line_adj_rec.rebate_transaction_reference
    ,x_line_adj_rec.rebate_payment_system_code
    ,x_line_adj_rec.redeemed_date
    ,x_line_adj_rec.redeemed_flag
    ,x_line_adj_rec.accrual_flag
    ,x_line_adj_rec.range_break_quantity
    ,x_line_adj_rec.accrual_conversion_rate
    ,x_line_adj_rec.pricing_group_sequence
    ,x_line_adj_rec.modifier_level_code
    ,x_line_adj_rec.price_break_type_code
    ,x_line_adj_rec.substitution_attribute
    ,x_line_adj_rec.proration_type_code
    ,x_line_adj_rec.CREDIT_OR_CHARGE_FLAG
    ,x_line_adj_rec.INCLUDE_ON_RETURNS_FLAG
    ,x_line_adj_rec.AC_ATTRIBUTE1
    ,x_line_adj_rec.AC_ATTRIBUTE10
    ,x_line_adj_rec.AC_ATTRIBUTE11
    ,x_line_adj_rec.AC_ATTRIBUTE12
    ,x_line_adj_rec.AC_ATTRIBUTE13
    ,x_line_adj_rec.AC_ATTRIBUTE14
    ,x_line_adj_rec.AC_ATTRIBUTE15
    ,x_line_adj_rec.AC_ATTRIBUTE2
    ,x_line_adj_rec.AC_ATTRIBUTE3
    ,x_line_adj_rec.AC_ATTRIBUTE4
    ,x_line_adj_rec.AC_ATTRIBUTE5
    ,x_line_adj_rec.AC_ATTRIBUTE6
    ,x_line_adj_rec.AC_ATTRIBUTE7
    ,x_line_adj_rec.AC_ATTRIBUTE8
    ,x_line_adj_rec.AC_ATTRIBUTE9
    ,x_line_adj_rec.AC_CONTEXT
    ,x_line_adj_rec.orig_sys_discount_ref
    ,x_line_adj_rec.OPERAND_PER_PQTY
    ,x_line_adj_rec.ADJUSTED_AMOUNT_PER_PQTY
   -- ,x_line_adj_rec.INVOICED_AMOUNT
    ,x_line_adj_rec.LOCK_CONTROL
    FROM    OE_PRICE_ADJS_HISTORY
    WHERE  PRICE_ADJUSTMENT_ID = p_price_adjustment_id
    and    header_ID           = p_header_id
    and    version_number      = p_version
    AND    LINE_ID IS NOT NULL
    AND    (PHASE_CHANGE_FLAG  = p_phase_change_flag
     OR    (nvl(p_phase_change_flag, 'NULL') <> 'Y'
    AND    VERSION_FLAG = 'Y'));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    --       RAISE NO_DATA_FOUND;
	 null;
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
               'Query_line_Adj_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END QUERY_line_Adj_ROW;

PROCEDURE QUERY_line_ADJ_TRANS_ROW
(p_header_id	                  NUMBER,
 p_price_adjustment_id            NUMBER,
 p_version	                  NUMBER,
 x_line_adj_rec                    IN OUT NOCOPY OE_Order_PUB.line_Adj_Rec_Type)
IS
l_org_id                NUMBER;
l_phase_change_flag     VARCHAR2(1);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering OE_VERSION_PRICE_ADJUST_COMP.QUERY_line_ADJ_TRANS_ROW' );
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('price' ||p_price_adjustment_id);
  oe_debug_pub.add('version' ||p_version);
END IF;

    l_org_id := OE_GLOBALS.G_ORG_ID;

    IF l_org_id IS NULL THEN
      OE_GLOBALS.Set_Context;
      l_org_id := OE_GLOBALS.G_ORG_ID;
    END IF;


    SELECT  ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       AUTOMATIC_FLAG
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DISCOUNT_ID
    ,       DISCOUNT_LINE_ID
    ,       line_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       PERCENT
    ,       PRICE_ADJUSTMENT_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,	    LIST_HEADER_ID
    ,	    LIST_LINE_ID
    ,	    LIST_LINE_TYPE_CODE
    ,	    MODIFIER_MECHANISM_TYPE_CODE
    ,	    MODIFIED_FROM
    ,	    MODIFIED_TO
    ,	    UPDATED_FLAG
    ,	    UPDATE_ALLOWED
    ,	    APPLIED_FLAG
    ,	    CHANGE_REASON_CODE
    ,	    CHANGE_REASON_TEXT
    ,	    operand
    ,       arithmetic_operator
    ,	    COST_ID
    ,	    TAX_CODE
    ,	    TAX_EXEMPT_FLAG
    ,	    TAX_EXEMPT_NUMBER
    ,	    TAX_EXEMPT_REASON_CODE
    ,	    PARENT_ADJUSTMENT_ID
    ,	    INVOICED_FLAG
    ,	    ESTIMATED_FLAG
    ,	    INC_IN_SALES_PERFORMANCE
    ,	    SPLIT_ACTION_CODE
    ,	    ADJUSTED_AMOUNT
    ,	    PRICING_PHASE_ID
    ,	    CHARGE_TYPE_CODE
    ,	    CHARGE_SUBTYPE_CODE
    ,       list_line_no
    ,       source_system_code
    ,       benefit_qty
    ,       benefit_uom_code
    ,       print_on_invoice_flag
    ,       expiration_date
    ,       rebate_transaction_type_code
    ,       rebate_transaction_reference
    ,       rebate_payment_system_code
    ,       redeemed_date
    ,       redeemed_flag
    ,       accrual_flag
    ,       range_break_quantity
    ,       accrual_conversion_rate
    ,       pricing_group_sequence
    ,       modifier_level_code
    ,       price_break_type_code
    ,       substitution_attribute
    ,       proration_type_code
    ,       CREDIT_OR_CHARGE_FLAG
    ,       INCLUDE_ON_RETURNS_FLAG
    ,       AC_ATTRIBUTE1
    ,       AC_ATTRIBUTE10
    ,       AC_ATTRIBUTE11
    ,       AC_ATTRIBUTE12
    ,       AC_ATTRIBUTE13
    ,       AC_ATTRIBUTE14
    ,       AC_ATTRIBUTE15
    ,       AC_ATTRIBUTE2
    ,       AC_ATTRIBUTE3
    ,       AC_ATTRIBUTE4
    ,       AC_ATTRIBUTE5
    ,       AC_ATTRIBUTE6
    ,       AC_ATTRIBUTE7
    ,       AC_ATTRIBUTE8
    ,       AC_ATTRIBUTE9
    ,       AC_CONTEXT
    ,       orig_sys_discount_ref
    ,       OPERAND_PER_PQTY
    ,       ADJUSTED_AMOUNT_PER_PQTY
--    ,       INVOICED_AMOUNT
    ,	    LOCK_CONTROL
INTO
    x_line_adj_rec.ATTRIBUTE1
    ,x_line_adj_rec.ATTRIBUTE10
    ,x_line_adj_rec.ATTRIBUTE11
    ,x_line_adj_rec.ATTRIBUTE12
    ,x_line_adj_rec.ATTRIBUTE13
    ,x_line_adj_rec.ATTRIBUTE14
    ,x_line_adj_rec.ATTRIBUTE15
    ,x_line_adj_rec.ATTRIBUTE2
    ,x_line_adj_rec.ATTRIBUTE3
    ,x_line_adj_rec.ATTRIBUTE4
    ,x_line_adj_rec.ATTRIBUTE5
    ,x_line_adj_rec.ATTRIBUTE6
    ,x_line_adj_rec.ATTRIBUTE7
    ,x_line_adj_rec.ATTRIBUTE8
    ,x_line_adj_rec.ATTRIBUTE9
    ,x_line_adj_rec.AUTOMATIC_FLAG
    ,x_line_adj_rec.CONTEXT
    ,x_line_adj_rec.CREATED_BY
    ,x_line_adj_rec.CREATION_DATE
    ,x_line_adj_rec.DISCOUNT_ID
    ,x_line_adj_rec.DISCOUNT_LINE_ID
    ,x_line_adj_rec.line_ID
    ,x_line_adj_rec.LAST_UPDATED_BY
    ,x_line_adj_rec.LAST_UPDATE_DATE
    ,x_line_adj_rec.LAST_UPDATE_LOGIN
    ,x_line_adj_rec.LINE_ID
    ,x_line_adj_rec.PERCENT
    ,x_line_adj_rec.PRICE_ADJUSTMENT_ID
    ,x_line_adj_rec.PROGRAM_APPLICATION_ID
    ,x_line_adj_rec.PROGRAM_ID
    ,x_line_adj_rec.PROGRAM_UPDATE_DATE
    ,x_line_adj_rec.REQUEST_ID
    ,x_line_adj_rec.LIST_HEADER_ID
    ,x_line_adj_rec.LIST_LINE_ID
    ,x_line_adj_rec.LIST_LINE_TYPE_CODE
    ,x_line_adj_rec.MODIFIER_MECHANISM_TYPE_CODE
    ,x_line_adj_rec.MODIFIED_FROM
    ,x_line_adj_rec.MODIFIED_TO
    ,x_line_adj_rec.UPDATED_FLAG
    ,x_line_adj_rec.UPDATE_ALLOWED
    ,x_line_adj_rec.APPLIED_FLAG
    ,x_line_adj_rec.CHANGE_REASON_CODE
    ,x_line_adj_rec.CHANGE_REASON_TEXT
    ,x_line_adj_rec.operand
    ,x_line_adj_rec.arithmetic_operator
    ,x_line_adj_rec.COST_ID
    ,x_line_adj_rec.TAX_CODE
    ,x_line_adj_rec.TAX_EXEMPT_FLAG
    ,x_line_adj_rec.TAX_EXEMPT_NUMBER
    ,x_line_adj_rec.TAX_EXEMPT_REASON_CODE
    ,x_line_adj_rec.PARENT_ADJUSTMENT_ID
    ,x_line_adj_rec.INVOICED_FLAG
    ,x_line_adj_rec.ESTIMATED_FLAG
    ,x_line_adj_rec.INC_IN_SALES_PERFORMANCE
    ,x_line_adj_rec.SPLIT_ACTION_CODE
    ,x_line_adj_rec.ADJUSTED_AMOUNT
    ,x_line_adj_rec.PRICING_PHASE_ID
    ,x_line_adj_rec.CHARGE_TYPE_CODE
    ,x_line_adj_rec.CHARGE_SUBTYPE_CODE
    ,x_line_adj_rec.list_line_no
    ,x_line_adj_rec.source_system_code
    ,x_line_adj_rec.benefit_qty
    ,x_line_adj_rec.benefit_uom_code
    ,x_line_adj_rec.print_on_invoice_flag
    ,x_line_adj_rec.expiration_date
    ,x_line_adj_rec.rebate_transaction_type_code
    ,x_line_adj_rec.rebate_transaction_reference
    ,x_line_adj_rec.rebate_payment_system_code
    ,x_line_adj_rec.redeemed_date
    ,x_line_adj_rec.redeemed_flag
    ,x_line_adj_rec.accrual_flag
    ,x_line_adj_rec.range_break_quantity
    ,x_line_adj_rec.accrual_conversion_rate
    ,x_line_adj_rec.pricing_group_sequence
    ,x_line_adj_rec.modifier_level_code
    ,x_line_adj_rec.price_break_type_code
    ,x_line_adj_rec.substitution_attribute
    ,x_line_adj_rec.proration_type_code
    ,x_line_adj_rec.CREDIT_OR_CHARGE_FLAG
    ,x_line_adj_rec.INCLUDE_ON_RETURNS_FLAG
    ,x_line_adj_rec.AC_ATTRIBUTE1
    ,x_line_adj_rec.AC_ATTRIBUTE10
    ,x_line_adj_rec.AC_ATTRIBUTE11
    ,x_line_adj_rec.AC_ATTRIBUTE12
    ,x_line_adj_rec.AC_ATTRIBUTE13
    ,x_line_adj_rec.AC_ATTRIBUTE14
    ,x_line_adj_rec.AC_ATTRIBUTE15
    ,x_line_adj_rec.AC_ATTRIBUTE2
    ,x_line_adj_rec.AC_ATTRIBUTE3
    ,x_line_adj_rec.AC_ATTRIBUTE4
    ,x_line_adj_rec.AC_ATTRIBUTE5
    ,x_line_adj_rec.AC_ATTRIBUTE6
    ,x_line_adj_rec.AC_ATTRIBUTE7
    ,x_line_adj_rec.AC_ATTRIBUTE8
    ,x_line_adj_rec.AC_ATTRIBUTE9
    ,x_line_adj_rec.AC_CONTEXT
    ,x_line_adj_rec.orig_sys_discount_ref
    ,x_line_adj_rec.OPERAND_PER_PQTY
    ,x_line_adj_rec.ADJUSTED_AMOUNT_PER_PQTY
   -- ,x_line_adj_rec.INVOICED_AMOUNT
    ,x_line_adj_rec.LOCK_CONTROL
    FROM    OE_PRICE_ADJUSTMENTS
    WHERE  PRICE_ADJUSTMENT_ID = p_price_adjustment_id
    and header_ID = p_header_id
    AND LINE_ID IS NOT NULL;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    --       RAISE NO_DATA_FOUND;
	 null;
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
               'Query_line_Adj_TRANS_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END QUERY_line_Adj_TRANS_ROW;

PROCEDURE COMPARE_line_adj_ATTRIBUTES
(p_header_id	                  NUMBER,
 p_price_adjustment_id	          NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag        VARCHAR2,
 g_curr_phase_change_flag         VARCHAR2,
 g_next_phase_change_flag         VARCHAR2,
 x_line_adj_changed_attr_tbl       IN OUT NOCOPY OE_VERSION_PRICE_ADJUST_COMP.line_adj_tbl_type,
 p_total_lines                    NUMBER,
 x_line_number                    VARCHAR2)
IS
p_curr_rec                       OE_Order_PUB.line_adj_Rec_Type;
p_next_rec                       OE_Order_PUB.line_adj_Rec_Type;
p_prior_rec                      OE_Order_PUB.line_adj_Rec_Type;


v_totcol NUMBER:=10;
v_line_col VARCHAR2(50);
ind NUMBER;
prior_exists VARCHAR2(1) := 'N';
j NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
p_prior_rec_exists VARCHAR2(1) := 'N';
p_curr_rec_exists VARCHAR2(1)  := 'N';
p_next_rec_exists VARCHAR2(1)  := 'N';
p_trans_rec_exists VARCHAR2(1)  := 'N';
BEGIN

IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering  comparing_line_adj_attributes');
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('adjustment id' ||p_price_adjustment_id);
  oe_debug_pub.add('prior version' ||p_prior_version);
  oe_debug_pub.add('current version' ||p_current_version);
  oe_debug_pub.add('next version' ||p_next_version);
  oe_debug_pub.add('max version' ||g_max_version);
  oe_debug_pub.add('trans version' ||g_trans_version);
END IF;

if p_total_lines > 0 THEN
IF l_debug_level > 0 THEN
  oe_debug_pub.add(' p_total_lines '||p_total_lines);
end if;
ind := p_total_lines;
ELSE
ind := 0;
end if;

IF p_price_adjustment_id IS NOT NULL THEN

p_prior_rec := NULL;
p_curr_rec := NULL;
p_next_rec := NULL;

IF l_debug_level > 0 THEN
  oe_debug_pub.add(' Quering prior line version details');
  oe_debug_pub.add('prior version' ||p_prior_version);
END IF;

IF p_prior_version IS NOT NULL THEN
OE_VERSION_PRICE_ADJUST_COMP.QUERY_line_adj_ROW(p_header_id         => p_header_id,
                          p_price_adjustment_id           => p_price_adjustment_id,
                          p_version                   => p_prior_version,
                          p_phase_change_flag    => g_prior_phase_change_flag,
			  x_line_adj_rec        => p_prior_rec);
     IF p_prior_rec.price_adjustment_id is NULL THEN
          p_prior_rec_exists := 'N';
     ELSE
          p_prior_rec_exists := 'Y';
     END IF;
END IF;
IF l_debug_level > 0 THEN
  oe_debug_pub.add(' Quering current line version details');
  oe_debug_pub.add('current version' ||p_current_version);
END IF;

IF p_current_version IS NOT NULL THEN
OE_VERSION_PRICE_ADJUST_COMP.QUERY_line_adj_ROW(p_header_id         => p_header_id,
                          p_price_adjustment_id           => p_price_adjustment_id,
			  p_version                   => p_current_version,
                          p_phase_change_flag    => g_curr_phase_change_flag,
			  x_line_adj_rec        => p_curr_rec);
     IF p_curr_rec.price_adjustment_id is NULL THEN
          p_curr_rec_exists := 'N';
     ELSE
          p_curr_rec_exists := 'Y';
     END IF;

END IF;
IF l_debug_level > 0 THEN
  oe_debug_pub.add(' Quering next/trans line version details');
  oe_debug_pub.add('next version' ||p_next_version);
  oe_debug_pub.add('trans version' ||g_trans_version);
END IF;

IF p_next_version = g_trans_version then
       IF g_trans_version is not null then
OE_VERSION_PRICE_ADJUST_COMP.QUERY_line_adj_TRANS_ROW(p_header_id       => p_header_id,
                          p_price_adjustment_id           => p_price_adjustment_id,
                          p_version                   => p_next_version,
			  x_line_adj_rec        => p_next_rec);
       END IF;
     IF p_next_rec.price_adjustment_id is NULL THEN
          p_trans_rec_exists := 'N';
     ELSE
          p_trans_rec_exists := 'Y';
          p_next_rec_exists := 'Y';
     END IF;
ELSE
IF p_next_version IS NOT NULL THEN
OE_VERSION_PRICE_ADJUST_COMP.QUERY_line_adj_ROW(p_header_id       => p_header_id,
                          p_price_adjustment_id           => p_price_adjustment_id,
                          p_version                   => p_next_version,
                          p_phase_change_flag    => g_next_phase_change_flag,
			  x_line_adj_rec        => p_next_rec);
     IF p_next_rec.price_adjustment_id is NULL THEN
          p_next_rec_exists := 'N';
     ELSE
          p_next_rec_exists := 'Y';
     END IF;
END IF;
END IF;

IF l_debug_level > 0 THEN
oe_debug_pub.add(' p_prior_rec list header id'||p_prior_rec.list_header_id);
oe_debug_pub.add(' p_curr_rec '||p_curr_rec.list_header_id);
oe_debug_pub.add(' p_next_rec '||p_next_rec.list_header_id);
    oe_debug_pub.add(' checking whether adjustments are same or not');
    oe_debug_pub.add(' p_prior_rec_exists'||p_prior_rec_exists);
    oe_debug_pub.add(' p_curr_rec_exists'||p_curr_rec_exists);
    oe_debug_pub.add(' p_next_rec_exists'||p_next_rec_exists);
    oe_debug_pub.add(' p_trans_rec_exists'||p_trans_rec_exists);
END IF;
IF  (p_prior_rec_exists = 'Y' and p_curr_rec_exists ='Y') OR
    (p_curr_rec_exists = 'Y' and p_next_rec_exists ='Y') THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' both exists - checking if both are same');
         END IF;
       IF OE_Globals.Equal(p_prior_rec.list_header_id,p_curr_rec.list_header_id) OR
         OE_Globals.Equal( p_curr_rec.list_header_id, p_next_rec.list_header_id) THEN
/****************************/

/****************************/
/* START attribute1*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute1,
       p_prior_rec.attribute1) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute1';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute1;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute1;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute1,
       p_next_rec.attribute1) THEN
    IF prior_exists = 'Y' THEN
   x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute1;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute1';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute1;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute1;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute1;
END IF;
END IF; /*  NEXT */

/* END attribute1*/
/****************************/

/****************************/
/* START attribute2*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute2,
       p_prior_rec.attribute2) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute2';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute2;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute2;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute2,
       p_next_rec.attribute2) THEN
    IF prior_exists = 'Y' THEN
   x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute2;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute2';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute2;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute2;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute2;
END IF;
END IF; /*  NEXT */

/* END attribute2*/
/****************************/
/****************************/
/* START attribute3*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute3,
       p_prior_rec.attribute3) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute3';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute3;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute3;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute3,
       p_next_rec.attribute3) THEN
    IF prior_exists = 'Y' THEN
   x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute3;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute3';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute3;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute3;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute3;
END IF;
END IF; /*  NEXT */

/* END attribute3*/
/****************************/

/****************************/
/* START attribute4*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute4,
       p_prior_rec.attribute4) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute4';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute4;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute4;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute4,
       p_next_rec.attribute4) THEN
    IF prior_exists = 'Y' THEN
   x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute4;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute4';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute4;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute4;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute4;
END IF;
END IF; /*  NEXT */

/* END attribute4*/
/****************************/
/****************************/
/* START attribute5*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute5,
       p_prior_rec.attribute5) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute5';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute5;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute5;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute5,
       p_next_rec.attribute5) THEN
    IF prior_exists = 'Y' THEN
   x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute5;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute5';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute5;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute5;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute5;
END IF;
END IF; /*  NEXT */

/* END attribute5*/
/****************************/

/****************************/
/* START attribute6*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute6,
       p_prior_rec.attribute6) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute6';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute6;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute6;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute6,
       p_next_rec.attribute6) THEN
    IF prior_exists = 'Y' THEN
   x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute6;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute6';
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute6;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute6;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute6;
END IF;
END IF; /*  NEXT */

/* END attribute6*/
/****************************/
/****************************/
/* START attribute7*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute7,
       p_prior_rec.attribute7) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute7';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute7;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute7;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute7,
       p_next_rec.attribute7) THEN
    IF prior_exists = 'Y' THEN
   x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute7;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute7';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute7;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute7;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute7;
END IF;
END IF; /*  NEXT */

/* END attribute7*/
/****************************/

/****************************/
/* START attribute8*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute8,
       p_prior_rec.attribute8) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute8';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute8;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute8;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute8,
       p_next_rec.attribute8) THEN
    IF prior_exists = 'Y' THEN
   x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute8;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute8';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute8;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute8;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute8;
END IF;
END IF; /*  NEXT */

/* END attribute8*/
/****************************/
/****************************/
/* START attribute9*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute9,
       p_prior_rec.attribute9) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute9';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute9;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute9;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute9,
       p_next_rec.attribute9) THEN
    IF prior_exists = 'Y' THEN
   x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute9;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute9';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute9;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute9;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute9;
END IF;
END IF; /*  NEXT */

/* END attribute9*/
/****************************/

/****************************/
/* START attribute10*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute10,
       p_prior_rec.attribute10) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute10';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute10;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute10;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute10,
       p_next_rec.attribute10) THEN
    IF prior_exists = 'Y' THEN
   x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute10;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute10';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute10;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute10;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute10;
END IF;
END IF; /*  NEXT */

/* END attribute10*/
/****************************/

/****************************/
/* START attribute11*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute11,
       p_prior_rec.attribute11) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute11';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute11;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute11;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute11,
       p_next_rec.attribute11) THEN
    IF prior_exists = 'Y' THEN
   x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute11;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute11';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute11;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute11;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute11;
END IF;
END IF; /*  NEXT */

/* END attribute11*/
/****************************/

/****************************/
/* START attribute12*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute12,
       p_prior_rec.attribute12) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute12';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute12;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute12;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute12,
       p_next_rec.attribute12) THEN
    IF prior_exists = 'Y' THEN
   x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute12;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute12';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute12;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute12;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute12;
END IF;
END IF; /*  NEXT */

/* END attribute12*/
/****************************/

/****************************/
/* START attribute13*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute13,
       p_prior_rec.attribute13) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute13';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute13;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute13;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute13,
       p_next_rec.attribute13) THEN
    IF prior_exists = 'Y' THEN
   x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute13;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute13';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute13;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute13;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute13;
END IF;
END IF; /*  NEXT */

/* END attribute13*/
/****************************/

/****************************/
/* START attribute14*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute14,
       p_prior_rec.attribute14) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute14';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute14;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute14;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute14,
       p_next_rec.attribute14) THEN
    IF prior_exists = 'Y' THEN
   x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute14;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute14';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute14;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute14;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute14;
END IF;
END IF; /*  NEXT */

/* END attribute14*/
/****************************/

/****************************/
/* START attribute15*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute15,
       p_prior_rec.attribute15) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute15';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute15;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute15;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute15,
       p_next_rec.attribute15) THEN
    IF prior_exists = 'Y' THEN
   x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute15;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute15';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute15;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute15;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.attribute15;
END IF;
END IF; /*  NEXT */

/* END attribute15*/
/****************************/
/****************************/
/* START context*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.context,
       p_prior_rec.context) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'context';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.context;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.context;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.context,
       p_next_rec.context) THEN
    IF prior_exists = 'Y' THEN
   x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.context;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
   x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'context';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.context;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.context;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.context;
END IF;
END IF; /*  NEXT */

/* END context*/

/****************************/

/****************************/
/* START AUTOMATIC_FLAG*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.AUTOMATIC_FLAG,
       p_prior_rec.AUTOMATIC_FLAG) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'AUTOMATIC_FLAG';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.AUTOMATIC_FLAG;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.AUTOMATIC_FLAG;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.AUTOMATIC_FLAG,
       p_next_rec.AUTOMATIC_FLAG) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.AUTOMATIC_FLAG;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'AUTOMATIC_FLAG';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.AUTOMATIC_FLAG;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.AUTOMATIC_FLAG;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.AUTOMATIC_FLAG;
END IF;
END IF; /*  NEXT */

/* END AUTOMATIC_FLAG*/
/****************************/

/****************************/
/* START LIST_LINE_TYPE_CODE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.LIST_LINE_TYPE_CODE,
       p_prior_rec.LIST_LINE_TYPE_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'LIST_LINE_TYPE';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.LIST_LINE_TYPE_CODE;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.LIST_LINE_TYPE_CODE;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.LIST_LINE_TYPE_CODE,
       p_next_rec.LIST_LINE_TYPE_CODE) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.LIST_LINE_TYPE_CODE;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'LIST_LINE_TYPE';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.LIST_LINE_TYPE_CODE;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.LIST_LINE_TYPE_CODE;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.LIST_LINE_TYPE_CODE;
END IF;
END IF; /*  NEXT */

/* END LIST_LINE_TYPE_CODE*/
/****************************/


/****************************/
/* START CHANGE_REASON_CODE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CHANGE_REASON_CODE,
       p_prior_rec.CHANGE_REASON_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'CHANGE_REASON_CODE';
   x_line_adj_changed_attr_tbl(ind).prior_id        := p_prior_rec.CHANGE_REASON_CODE;
   x_line_adj_changed_attr_tbl(ind).prior_value      :=  OE_ID_TO_VALUE.change_reason(p_prior_rec.CHANGE_REASON_CODE);
   x_line_adj_changed_attr_tbl(ind).current_id      := p_curr_rec.CHANGE_REASON_CODE;
   x_line_adj_changed_attr_tbl(ind).current_value      :=  OE_ID_TO_VALUE.change_reason(p_curr_rec.CHANGE_REASON_CODE);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CHANGE_REASON_CODE,
       p_next_rec.CHANGE_REASON_CODE) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := OE_ID_TO_VALUE.change_reason(p_curr_rec.CHANGE_REASON_CODE);
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'CHANGE_REASON_CODE';
   x_line_adj_changed_attr_tbl(ind).prior_id        := p_prior_rec.CHANGE_REASON_CODE;
   x_line_adj_changed_attr_tbl(ind).prior_value      :=  OE_ID_TO_VALUE.change_reason(p_prior_rec.CHANGE_REASON_CODE);
   x_line_adj_changed_attr_tbl(ind).current_id      := p_curr_rec.CHANGE_REASON_CODE;
   x_line_adj_changed_attr_tbl(ind).current_value      :=  OE_ID_TO_VALUE.change_reason(p_curr_rec.CHANGE_REASON_CODE);
   x_line_adj_changed_attr_tbl(ind).next_id         := p_next_rec.CHANGE_REASON_CODE;
   x_line_adj_changed_attr_tbl(ind).next_value      :=  OE_ID_TO_VALUE.change_reason(p_next_rec.CHANGE_REASON_CODE);
END IF;
END IF; /*  NEXT */

/* END CHANGE_REASON_CODE*/
/****************************/

/****************************/
/* START CHANGE_REASON_TEXT*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CHANGE_REASON_TEXT,
       p_prior_rec.CHANGE_REASON_TEXT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'CHANGE_REASON_TEXT';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.CHANGE_REASON_TEXT;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.CHANGE_REASON_TEXT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CHANGE_REASON_TEXT,
       p_next_rec.CHANGE_REASON_TEXT) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.CHANGE_REASON_TEXT;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'CHANGE_REASON_TEXT';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.CHANGE_REASON_TEXT;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.CHANGE_REASON_TEXT;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.CHANGE_REASON_TEXT;
END IF;
END IF; /*  NEXT */

/* END CHANGE_REASON_TEXT*/
/****************************/

/****************************/
/* START ADJUSTED_AMOUNT*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ADJUSTED_AMOUNT,
       p_prior_rec.ADJUSTED_AMOUNT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name   := 'ADJUSTED_AMOUNT';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ADJUSTED_AMOUNT;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ADJUSTED_AMOUNT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ADJUSTED_AMOUNT,
       p_next_rec.ADJUSTED_AMOUNT) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ADJUSTED_AMOUNT;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name   := 'ADJUSTED_AMOUNT';
   x_line_adj_changed_attr_tbl(ind).prior_value      := p_prior_rec.ADJUSTED_AMOUNT;
   x_line_adj_changed_attr_tbl(ind).current_value    := p_curr_rec.ADJUSTED_AMOUNT;
   x_line_adj_changed_attr_tbl(ind).next_value       := p_next_rec.ADJUSTED_AMOUNT;
END IF;
END IF; /*  NEXT */

/* END ADJUSTED_AMOUNT*/
/****************************/


/****************************/
/* START list_line_no*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.list_line_no,
       p_prior_rec.list_line_no) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'list_line_no';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.list_line_no;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.list_line_no;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.list_line_no,
       p_next_rec.list_line_no) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.list_line_no;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'list_line_no';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.list_line_no;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.list_line_no;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.list_line_no;
END IF;
END IF; /*  NEXT */

/* END list_line_no*/
/****************************/
/****************************/
/* START source_system_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.source_system_code,
       p_prior_rec.source_system_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'source_system_code';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.source_system_code;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.source_system_code;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.source_system_code,
       p_next_rec.source_system_code) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.source_system_code;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'source_system_code';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.source_system_code;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.source_system_code;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.source_system_code;
END IF;
END IF; /*  NEXT */

/* END source_system_code*/
/****************************/

/****************************/
/* START benefit_qty*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.benefit_qty,
       p_prior_rec.benefit_qty) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'benefit_qty';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.benefit_qty;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.benefit_qty;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.benefit_qty,
       p_next_rec.benefit_qty) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.benefit_qty;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'benefit_qty';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.benefit_qty;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.benefit_qty;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.benefit_qty;
END IF;
END IF; /*  NEXT */

/* END benefit_qty*/
/****************************/

/****************************/
/* START benefit_uom_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.benefit_uom_code,
       p_prior_rec.benefit_uom_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'benefit_uom_code';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.benefit_uom_code;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.benefit_uom_code;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.benefit_uom_code,
       p_next_rec.benefit_uom_code) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.benefit_uom_code;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'benefit_uom_code';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.benefit_uom_code;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.benefit_uom_code;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.benefit_uom_code;
END IF;
END IF; /*  NEXT */

/* END benefit_uom_code*/
/****************************/

/****************************/
/* START expiration_date*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.expiration_date,
       p_prior_rec.expiration_date) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'expiration_date';
   x_line_adj_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.expiration_date,'DD-MON-YYYY HH24:MI:SS');
   x_line_adj_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.expiration_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.expiration_date,
       p_next_rec.expiration_date) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := to_char(p_curr_rec.expiration_date,'DD-MON-YYYY HH24:MI:SS');
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'expiration_date';
   x_line_adj_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.expiration_date,'DD-MON-YYYY HH24:MI:SS');
   x_line_adj_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.expiration_date,'DD-MON-YYYY HH24:MI:SS');
   x_line_adj_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.expiration_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  NEXT */

/* END expiration_date*/
/****************************/

/****************************/
/* START rebate_transaction_type_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.rebate_transaction_type_code,
       p_prior_rec.rebate_transaction_type_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'rebate_transaction_type_code';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.rebate_transaction_type_code;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.rebate_transaction_type_code;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.rebate_transaction_type_code,
       p_next_rec.rebate_transaction_type_code) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.rebate_transaction_type_code;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'rebate_transaction_type_code';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.rebate_transaction_type_code;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.rebate_transaction_type_code;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.rebate_transaction_type_code;
END IF;
END IF; /*  NEXT */

/* END rebate_transaction_type_code*/
/****************************/

/****************************/
/* START rebate_transaction_reference*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.rebate_transaction_reference,
       p_prior_rec.rebate_transaction_reference) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'rebate_transaction_reference';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.rebate_transaction_reference;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.rebate_transaction_reference;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.rebate_transaction_reference,
       p_next_rec.rebate_transaction_reference) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.rebate_transaction_reference;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'rebate_transaction_reference';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.rebate_transaction_reference;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.rebate_transaction_reference;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.rebate_transaction_reference;
END IF;
END IF; /*  NEXT */

/* END rebate_transaction_reference*/
/****************************/

/****************************/
/* START rebate_payment_system_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.rebate_payment_system_code,
       p_prior_rec.rebate_payment_system_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'rebate_payment_system_code';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.rebate_payment_system_code;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.rebate_payment_system_code;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.rebate_payment_system_code,
       p_next_rec.rebate_payment_system_code) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.rebate_payment_system_code;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'rebate_payment_system_code';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.rebate_payment_system_code;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.rebate_payment_system_code;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.rebate_payment_system_code;
END IF;
END IF; /*  NEXT */

/* END rebate_payment_system_code*/
/****************************/

/****************************/
/* START redeemed_date*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.redeemed_date,
       p_prior_rec.redeemed_date) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'redeemed_date';
   x_line_adj_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.redeemed_date,'DD-MON-YYYY HH24:MI:SS');
   x_line_adj_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.redeemed_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.redeemed_date,
       p_next_rec.redeemed_date) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := to_char(p_curr_rec.redeemed_date,'DD-MON-YYYY HH24:MI:SS');
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'redeemed_date';
   x_line_adj_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.redeemed_date,'DD-MON-YYYY HH24:MI:SS');
   x_line_adj_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.redeemed_date,'DD-MON-YYYY HH24:MI:SS');
   x_line_adj_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.redeemed_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  NEXT */

/* END redeemed_date*/
/****************************/

/****************************/
/* START redeemed_flag*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.redeemed_flag,
       p_prior_rec.redeemed_flag) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'redeemed_flag';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.redeemed_flag;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.redeemed_flag;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.redeemed_flag,
       p_next_rec.redeemed_flag) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.redeemed_flag;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'redeemed_flag';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.redeemed_flag;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.redeemed_flag;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.redeemed_flag;
END IF;
END IF; /*  NEXT */

/* END redeemed_flag*/
/****************************/

/****************************/
/* START accrual_flag*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.accrual_flag,
       p_prior_rec.accrual_flag) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'accrual_flag';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.accrual_flag;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.accrual_flag;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.accrual_flag,
       p_next_rec.accrual_flag) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.accrual_flag;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'accrual_flag';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.accrual_flag;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.accrual_flag;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.accrual_flag;
END IF;
END IF; /*  NEXT */

/* END accrual_flag*/
/****************************/

/****************************/
/* START range_break_quantity*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.range_break_quantity,
       p_prior_rec.range_break_quantity) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'range_break_quantity';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.range_break_quantity;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.range_break_quantity;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.range_break_quantity,
       p_next_rec.range_break_quantity) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.range_break_quantity;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'range_break_quantity';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.range_break_quantity;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.range_break_quantity;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.range_break_quantity;
END IF;
END IF; /*  NEXT */

/* END range_break_quantity*/
/****************************/

/****************************/
/* START accrual_conversion_rate*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.accrual_conversion_rate,
       p_prior_rec.accrual_conversion_rate) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'accrual_conversion_rate';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.accrual_conversion_rate;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.accrual_conversion_rate;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.accrual_conversion_rate,
       p_next_rec.accrual_conversion_rate) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.accrual_conversion_rate;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'accrual_conversion_rate';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.accrual_conversion_rate;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.accrual_conversion_rate;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.accrual_conversion_rate;
END IF;
END IF; /*  NEXT */

/* END accrual_conversion_rate*/
/****************************/

/****************************/
/* START modifier_level_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.modifier_level_code,
       p_prior_rec.modifier_level_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'modifier_level_code';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.modifier_level_code;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.modifier_level_code;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.modifier_level_code,
       p_next_rec.modifier_level_code) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.modifier_level_code;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'modifier_level_code';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.modifier_level_code;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.modifier_level_code;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.modifier_level_code;
END IF;
END IF; /*  NEXT */

/* END modifier_level_code*/
/****************************/

/****************************/
/* START price_break_type_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.price_break_type_code,
       p_prior_rec.price_break_type_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'price_break_type_code';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.price_break_type_code;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.price_break_type_code;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.price_break_type_code,
       p_next_rec.price_break_type_code) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.price_break_type_code;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'price_break_type_code';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.price_break_type_code;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.price_break_type_code;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.price_break_type_code;
END IF;
END IF; /*  NEXT */

/* END price_break_type_code*/
/****************************/

/****************************/
/* START substitution_attribute*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.substitution_attribute,
       p_prior_rec.substitution_attribute) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'substitution_attribute';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.substitution_attribute;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.substitution_attribute;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.substitution_attribute,
       p_next_rec.substitution_attribute) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.substitution_attribute;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'substitution_attribute';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.substitution_attribute;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.substitution_attribute;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.substitution_attribute;
END IF;
END IF; /*  NEXT */

/* END substitution_attribute*/
/****************************/

/****************************/
/* START proration_type_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.proration_type_code,
       p_prior_rec.proration_type_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'proration_type_code';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.proration_type_code;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.proration_type_code;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.proration_type_code,
       p_next_rec.proration_type_code) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.proration_type_code;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'proration_type_code';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.proration_type_code;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.proration_type_code;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.proration_type_code;
END IF;
END IF; /*  NEXT */

/* END proration_type_code*/
/****************************/

/****************************/
/* START ac_attribute1*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute1,
       p_prior_rec.ac_attribute1) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute1';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute1;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute1;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute1,
       p_next_rec.ac_attribute1) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute1;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute1';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute1;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute1;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute1;
END IF;
END IF; /*  NEXT */

/* END ac_attribute1*/
/****************************/

/****************************/
/* START ac_attribute2*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute2,
       p_prior_rec.ac_attribute2) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute2';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute2;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute2;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute2,
       p_next_rec.ac_attribute2) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute2;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute2';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute2;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute2;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute2;
END IF;
END IF; /*  NEXT */

/* END ac_attribute2*/
/****************************/
/****************************/
/* START ac_attribute3*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute3,
       p_prior_rec.ac_attribute3) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute3';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute3;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute3;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute3,
       p_next_rec.ac_attribute3) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute3;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute3';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute3;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute3;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute3;
END IF;
END IF; /*  NEXT */

/* END ac_attribute3*/
/****************************/

/****************************/
/* START ac_attribute4*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute4,
       p_prior_rec.ac_attribute4) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute4';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute4;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute4;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute4,
       p_next_rec.ac_attribute4) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute4;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute4';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute4;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute4;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute4;
END IF;
END IF; /*  NEXT */

/* END ac_attribute4*/
/****************************/
/****************************/
/* START ac_attribute5*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute5,
       p_prior_rec.ac_attribute5) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute5';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute5;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute5;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute5,
       p_next_rec.ac_attribute5) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute5;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute5';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute5;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute5;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute5;
END IF;
END IF; /*  NEXT */

/* END ac_attribute5*/
/****************************/

/****************************/
/* START ac_attribute6*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute6,
       p_prior_rec.ac_attribute6) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute6';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute6;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute6;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute6,
       p_next_rec.ac_attribute6) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute6;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute6';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute6;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute6;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute6;
END IF;
END IF; /*  NEXT */

/* END ac_attribute6*/
/****************************/
/****************************/
/* START ac_attribute7*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute7,
       p_prior_rec.ac_attribute7) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute7';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute7;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute7;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute7,
       p_next_rec.ac_attribute7) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute7;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute7;
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute7';
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute7;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute7;
END IF;
END IF; /*  NEXT */

/* END ac_attribute7*/
/****************************/

/****************************/
/* START ac_attribute8*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute8,
       p_prior_rec.ac_attribute8) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute8';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute8;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute8;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute8,
       p_next_rec.ac_attribute8) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute8;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute8';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute8;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute8;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute8;
END IF;
END IF; /*  NEXT */

/* END ac_attribute8*/
/****************************/
/****************************/
/* START ac_attribute9*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute9,
       p_prior_rec.ac_attribute9) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute9';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute9;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute9;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute9,
       p_next_rec.ac_attribute9) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute9;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute9';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute9;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute9;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute9;
END IF;
END IF; /*  NEXT */

/* END ac_attribute9*/
/****************************/

/****************************/
/* START ac_attribute10*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute10,
       p_prior_rec.ac_attribute10) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute10';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute10;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute10;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute10,
       p_next_rec.ac_attribute10) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute10;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute10';
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute10;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute10;
END IF;
END IF; /*  NEXT */

/* END ac_attribute10*/
/****************************/

/****************************/
/* START ac_attribute11*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute11,
       p_prior_rec.ac_attribute11) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute11';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute11;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute11;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute11,
       p_next_rec.ac_attribute11) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute11;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute11';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute10;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute11;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute11;
END IF;
END IF; /*  NEXT */

/* END ac_attribute11*/
/****************************/

/****************************/
/* START ac_attribute12*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute12,
       p_prior_rec.ac_attribute12) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute12';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute12;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute12;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute12,
       p_next_rec.ac_attribute12) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute12;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute12';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute12;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute12;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute12;
END IF;
END IF; /*  NEXT */

/* END ac_attribute12*/
/****************************/

/****************************/
/* START ac_attribute13*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute13,
       p_prior_rec.ac_attribute13) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute13';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute13;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute13;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute13,
       p_next_rec.ac_attribute13) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute13;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute13';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute13;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute13;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute13;
END IF;
END IF; /*  NEXT */

/* END ac_attribute13*/
/****************************/

/****************************/
/* START ac_attribute14*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute14,
       p_prior_rec.ac_attribute14) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute14';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute14;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute14;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute14,
       p_next_rec.ac_attribute14) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute14;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute14';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute14;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute14;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute14;
END IF;
END IF; /*  NEXT */

/* END ac_attribute14*/
/****************************/

/****************************/
/* START ac_attribute15*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute15,
       p_prior_rec.ac_attribute15) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'attribute15';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_attribute15;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute15;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_attribute15,
       p_next_rec.ac_attribute15) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_attribute15;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'attribute15';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_attribute15;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_attribute15;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_attribute15;
END IF;
END IF; /*  NEXT */

/* END ac_attribute15*/
/****************************/

/****************************/
/* START ac_context*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_context,
       p_prior_rec.ac_context) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name  := 'ac_context';
   x_line_adj_changed_attr_tbl(ind).current_value      := p_curr_rec.ac_context;
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_context;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ac_context,
       p_next_rec.ac_context) THEN
   IF prior_exists = 'Y' THEN
     x_line_adj_changed_attr_tbl(ind).next_value     := p_curr_rec.ac_context;
   END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_adj_changed_attr_tbl(ind).line_number      := x_line_number;
 x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
   x_line_adj_changed_attr_tbl(ind).attribute_name := 'ac_context';
   x_line_adj_changed_attr_tbl(ind).prior_value        := p_prior_rec.ac_context;
   x_line_adj_changed_attr_tbl(ind).current_value     := p_curr_rec.ac_context;
   x_line_adj_changed_attr_tbl(ind).next_value      := p_next_rec.ac_context;
END IF;
END IF; /*  NEXT */

/* END ac_context*/
/****************************/
/****************************/

      END IF; /* same list header id */
END IF;	/* p and c = Y or c and n=y */

IF l_debug_level > 0 THEN
    oe_debug_pub.add(' before finding new sales credits  ');
    oe_debug_pub.add(' p_prior_rec_exists'||p_prior_rec_exists);
    oe_debug_pub.add(' p_curr_rec_exists'||p_curr_rec_exists);
    oe_debug_pub.add(' p_next_rec_exists'||p_next_rec_exists);
    oe_debug_pub.add(' p_trans_rec_exists'||p_trans_rec_exists);
END IF;
IF (p_prior_rec_exists = 'N' and p_curr_rec_exists = 'Y') OR
    (p_curr_rec_exists = 'N' and p_next_rec_exists ='Y') THEN
   IF p_prior_version IS NOT NULL and p_curr_rec_exists = 'Y' THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Prior is not there - current is there');
         END IF;
       ind := ind+1;
       x_line_adj_changed_attr_tbl(ind).line_number        := x_line_number;
       x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
       x_line_adj_changed_attr_tbl(ind).prior_value        :=  null;
       x_line_adj_changed_attr_tbl(ind).current_value      :=  'ADD';
       x_line_adj_changed_attr_tbl(ind).next_value         :=  null;
   ELSIF (p_curr_rec_exists = 'N' and p_next_rec_exists = 'Y') THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Current is not there - next is there');
               oe_debug_pub.add(' new mod' ||p_next_rec.list_header_id);
         END IF;
       ind := ind+1;
       x_line_adj_changed_attr_tbl(ind).line_number        := x_line_number;
       x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_next_rec.list_header_id);
       x_line_adj_changed_attr_tbl(ind).prior_value        :=  null;
       x_line_adj_changed_attr_tbl(ind).current_value      :=  null;
       x_line_adj_changed_attr_tbl(ind).next_value         :=  'ADD';
  end if;
END IF;

IF l_debug_level > 0 THEN
    oe_debug_pub.add(' before finding deleted new_modifier_list');
    oe_debug_pub.add(' p_prior_rec_exists'||p_prior_rec_exists);
    oe_debug_pub.add(' p_curr_rec_exists'||p_curr_rec_exists);
    oe_debug_pub.add(' p_next_rec_exists'||p_next_rec_exists);
    oe_debug_pub.add(' p_trans_rec_exists'||p_trans_rec_exists);
END IF;
IF (p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'N') OR
    (p_curr_rec_exists = 'Y' and p_next_rec_exists ='N') THEN
   IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'N' THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Prior is there - current is not there');
         END IF;
       ind := ind+1;
       x_line_adj_changed_attr_tbl(ind).line_number        := x_line_number;
       x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_prior_rec.list_header_id);
       x_line_adj_changed_attr_tbl(ind).prior_value        :=  null;
       x_line_adj_changed_attr_tbl(ind).current_value      :=  'DELETE';
       x_line_adj_changed_attr_tbl(ind).next_value         :=  null;
   ELSIF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'N' THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' p_next_version'||p_next_version);
               oe_debug_pub.add(' g_trans_version'||g_trans_version);
         END IF;
      --if p_next_version != g_trans_version THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Current is there - next is not there');
         END IF;
       ind := ind+1;
       x_line_adj_changed_attr_tbl(ind).line_number        := x_line_number;
       x_line_adj_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.new_modifier_list(p_curr_rec.list_header_id);
       x_line_adj_changed_attr_tbl(ind).prior_value        :=  null;
       x_line_adj_changed_attr_tbl(ind).current_value      :=  null;
       x_line_adj_changed_attr_tbl(ind).next_value         :=  'DELETE';
     --end if;
  end if;
END IF;
IF l_debug_level > 0 THEN
  oe_debug_pub.add('******BEFORE COMPARING ATTRIBUTES*************');
  oe_debug_pub.add('current ind '|| ind);
END IF;

END IF; /* price_adjustment_id not null */
IF l_debug_level > 0 THEN
  oe_debug_pub.add('******AFTER COMPARING ATTRIBUTES*************');
  oe_debug_pub.add('current ind '|| ind);
END IF;
IF l_debug_level  > 0 THEN
   oe_debug_pub.add(' Exiting OE_VERSION_PRICE_ADJUST_COMP.Compare_line_adj_Attributes ');
END IF;
/*
j := 0;
dbms_output.put_line('No of resales dreditcords'||x_line_adj_changed_attr_tbl.count);
WHILE j < x_line_adj_changed_attr_tbl.count
LOOP
j:=j+1;
dbms_output.put_line('attribute value '||x_line_adj_changed_attr_tbl(j).attribute_name ||
||' Prior '||x_line_adj_changed_attr_tbl(j).prior_value||
||' Current '||x_line_adj_changed_attr_tbl(j).current_value ||
||' Next '||x_line_adj_changed_attr_tbl(j).next_value);
END LOOP;
*/
END COMPARE_line_adj_ATTRIBUTES;

PROCEDURE COMPARE_line_adj_VERSIONS
(p_header_id	                  NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag        VARCHAR2,
 g_curr_phase_change_flag         VARCHAR2,
 g_next_phase_change_flag         VARCHAR2,
 x_line_adj_changed_attr_tbl        IN OUT NOCOPY OE_VERSION_PRICE_ADJUST_COMP.line_adj_tbl_type)
IS

CURSOR C_get_adjustments(p_header_id IN NUMBER,p_prior_version IN NUMBER, p_current_version IN NUMBER, p_next_version IN NUMBER) IS
           SELECT distinct price_adjustment_id,line_id
           from oe_price_adjs_history
           where header_id = p_header_id
           and line_id is  not null
           --and phase_change_flag = p_transaction_phase_code
           and list_line_type_code <> 'FREIGHT_CHARGE'
	   and list_header_id IS NOT NULL
           and version_number in (p_prior_version,p_current_version,p_next_version)
           union
           SELECT price_adjustment_id,line_id
           from oe_price_adjustments
           where header_id=p_header_id
           and list_line_type_code <> 'FREIGHT_CHARGE'
	   and list_header_id IS NOT NULL
           and line_id is not null;
           --and transaction_phase_code = p_transaction_phase_code;

CURSOR C_get_hist_adjustments(p_header_id IN NUMBER,p_prior_version IN NUMBER, p_current_version IN NUMBER, p_next_version IN NUMBER) IS
           SELECT distinct price_adjustment_id,line_id
           from oe_price_adjs_history
           where header_id = p_header_id
           and line_id is not null
           and list_line_type_code <> 'FREIGHT_CHARGE'
	   and list_header_id IS NOT NULL
           --and phase_change_flag = p_transaction_phase_code
           and version_number in (p_prior_version,p_current_version,p_next_version);
ind1 NUMBER;
l_price_adjustment_id NUMBER;
total_lines NUMBER;
l_line_id   NUMBER;
x_line_number VARCHAR2(30);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering Compare_line_adj_versions');
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('prior version' ||p_prior_version);
  oe_debug_pub.add('current version' ||p_current_version);
  oe_debug_pub.add('next version' ||p_next_version);
  oe_debug_pub.add('max version' ||g_max_version);
  oe_debug_pub.add('trans version' ||g_trans_version);
END IF;

ind1:=0;
total_lines:=0;
IF p_header_id IS NOT NULL THEN
  IF p_next_version = g_trans_version THEN
    OPEN C_GET_adjustments(p_header_id,p_prior_version,p_current_version,p_next_version);
    LOOP
    FETCH C_GET_adjustments INTO l_price_adjustment_id,l_line_id;
    EXIT WHEN C_GET_adjustments%NOTFOUND;
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('*************adjustments found(trans)******************'||l_price_adjustment_id);
      oe_debug_pub.add('*************adjustments found(line_id)******************'||l_line_id);
    END IF;

     IF l_price_adjustment_id IS NOT NULL THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************before call total adjustments(trans) ******************'||ind1);
         END IF;

         IF l_line_id IS NOT NULL THEN
         -- bug 9299752
         begin
           select oe_order_misc_pub.get_concat_hist_line_number(l_line_id) into x_line_number from dual;
         exception
	  when others then
	   select oe_order_misc_pub.get_concat_hist_line_number(l_line_id,p_current_version) into x_line_number from dual;
	 end;
         -- bug 9299752
         END IF;
         IF x_line_number IS NULL THEN
         select oe_order_misc_pub.get_concat_line_number(l_line_id) into x_line_number from dual;
         END IF;

         COMPARE_line_adj_ATTRIBUTES(p_header_id        => p_header_id,
                          p_price_adjustment_id         => l_price_adjustment_id,
                          p_prior_version               => p_prior_version,
                          p_current_version             => p_current_version,
                          p_next_version                => p_next_version,
                          g_max_version                 => g_max_version,
	                  g_trans_version               => g_trans_version,
                          g_prior_phase_change_flag     => g_prior_phase_change_flag,
                          g_curr_phase_change_flag      => g_curr_phase_change_flag,
                          g_next_phase_change_flag      => g_next_phase_change_flag,
                          x_line_adj_changed_attr_tbl   => x_line_adj_changed_attr_tbl,
                          p_total_lines                 => ind1,
                          x_line_number                 => x_line_number);
         IF x_line_adj_changed_attr_tbl.count > 0 THEN
                ind1 := x_line_adj_changed_attr_tbl.count;
        --      ind1 := ind1 + total_lines;
         END IF;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************after call total price adjustments(trans) ******************'||ind1);
         END IF;
     END IF; /* price_adjustment_id is not null */
  END LOOP;
  CLOSE C_GET_adjustments;
  ELSE
    OPEN C_GET_HIST_adjustments(p_header_id,p_prior_version,p_current_version,p_next_version);
    LOOP
    FETCH C_GET_HIST_adjustments INTO l_price_adjustment_id,l_line_id;
    EXIT WHEN C_GET_HIST_adjustments%NOTFOUND;
    IF l_debug_level  > 0 THEN
         oe_debug_pub.add('*************adjustments found******************'||l_price_adjustment_id);
    END IF;

     IF l_price_adjustment_id IS NOT NULL THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************before call total price adjustments ******************'||ind1);
         END IF;
         -- bug 9299752
         begin
          select oe_order_misc_pub.get_concat_hist_line_number(l_line_id) into x_line_number from dual;
         exception
          when others then
           select oe_order_misc_pub.get_concat_hist_line_number(l_line_id,p_current_version) into x_line_number from dual; -- bug 9299752
         end;
         -- bug 9299752
         COMPARE_line_adj_ATTRIBUTES(p_header_id               => p_header_id,
                          p_price_adjustment_id                     => l_price_adjustment_id,
                          p_prior_version               => p_prior_version,
                          p_current_version             => p_current_version,
                          p_next_version                => p_next_version,
                          g_max_version                 => g_max_version,
                          g_trans_version               => g_trans_version,
                          g_prior_phase_change_flag     => g_prior_phase_change_flag,
                          g_curr_phase_change_flag      => g_curr_phase_change_flag,
                          g_next_phase_change_flag      => g_next_phase_change_flag,
                          x_line_adj_changed_attr_tbl    => x_line_adj_changed_attr_tbl,
                          p_total_lines                 => ind1,
                          x_line_number                 => x_line_number);
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************after call total adjustments  ******************'||ind1);
         END IF;
         IF x_line_adj_changed_attr_tbl.count > 0 THEN
                ind1 := x_line_adj_changed_attr_tbl.count;
        --      ind1 := ind1 + total_lines;
         END IF;
     END IF; /* adjustments is not null */
    END LOOP;
    CLOSE C_GET_HIST_adjustments;
 END IF;/* next equals trans */
END IF;/*header_id is not null*/
END COMPARE_line_adj_VERSIONS;

--added for bug 4302049
/* Function to get segment prompt */

 FUNCTION get_dff_seg_prompt(p_application_id               IN NUMBER,
		     p_descriptive_flexfield_name   IN VARCHAR2,
		     p_descriptive_flex_context_cod IN VARCHAR2,
		     p_desc_flex_context_cod_prior IN VARCHAR2,
		     p_desc_flex_context_cod_next IN VARCHAR2,
		     p_application_column_name      IN VARCHAR2)
   RETURN VARCHAR2
 IS
   l_prompt varchar2(2000);
   x_prompt varchar2(2000);
   slash    varchar2(20);
   CURSOR c1 IS select form_left_prompt from fnd_descr_flex_col_usage_vl
	   where application_id=660
	   and descriptive_flexfield_name= p_descriptive_flexfield_name
	   and application_column_name =p_application_column_name
	   and DESCRIPTIVE_FLEX_CONTEXT_CODE in (p_descriptive_flex_context_cod, p_desc_flex_context_cod_prior, p_desc_flex_context_cod_next, 'Global Data Elements');
   BEGIN
	oe_debug_pub.add('Entering get_dff_seg_prompt');
	fnd_message.set_name('ONT','ONT_SLASH_SEPARATOR');
	slash:=FND_MESSAGE.GET;

	IF p_application_column_name = 'CONTEXT' THEN		--Context Prompt
		select FORM_CONTEXT_PROMPT into l_prompt from FND_DESCRIPTIVE_FLEXS_VL
		where APPLICATION_ID = p_application_id
		and DESCRIPTIVE_FLEXFIELD_NAME = p_descriptive_flexfield_name;

		oe_debug_pub.add('Context Prompt='||l_prompt);
	ELSE						--Attribute Prompt
	IF p_descriptive_flex_context_cod IS NULL
	 AND p_desc_flex_context_cod_prior IS NULL
	  AND p_desc_flex_context_cod_next IS NULL THEN
	  select form_left_prompt into l_prompt from fnd_descr_flex_col_usage_vl where application_id=660
	   and descriptive_flexfield_name= p_descriptive_flexfield_name
	   and application_column_name =p_application_column_name;

	   oe_debug_pub.add('Prompt='||l_prompt);
	ELSE						--Context has been passed
	  OPEN c1;
	   LOOP
	       FETCH c1 into l_prompt;
	       EXIT WHEN c1%NOTFOUND;
	       if x_prompt IS NULL THEN
			x_prompt:=l_prompt;
		ELSIF x_prompt <> l_prompt   THEN
			x_prompt:=x_prompt||slash||l_prompt;
		END IF;
           END LOOP;
           CLOSE C1;
           oe_debug_pub.add('Prompt='||x_prompt);
	   RETURN(x_prompt);
       END IF;				--Context been passed
       END IF;				--Context/Attribute Prompt
      RETURN(l_prompt);
EXCEPTION
   WHEN no_data_found THEN
	Return null;
   WHEN OTHERS THEN
	oe_debug_pub.add('error is'||SQLCODE||'message'||SQLERRM);
	Return NULL;
END get_dff_seg_prompt;
--bug 4302049

END OE_VERSION_PRICE_ADJUST_COMP;

/
