--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_LINE_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_LINE_ADJ" AS
/* $Header: OEXDLADB.pls 120.1 2005/06/14 10:49:45 appldev  $ */


--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Default_Line_Adj';

-- Commented for bug 2155582
--g_Line_Adj_rec              OE_AK_LINE_PRCADJS_V%ROWTYPE;

g_line_adj_rec OE_ORDER_PUB.Line_Adj_Rec_Type;

-- Get functions.

FUNCTION Get_Price_Adjustment
RETURN NUMBER
  IS
	l_adjustment_id     NUMBER := NULL;
BEGIN

	SELECT  OE_PRICE_ADJUSTMENTS_S.NEXTVAL
		INTO  l_adjustment_id
	FROM  DUAL;

  RETURN l_adjustment_id;

END Get_Price_Adjustment;

PROCEDURE Attributes
(   p_x_Line_Adj_rec                in out nocopy OE_Order_PUB.Line_Adj_Rec_Type
,   p_old_Line_Adj_rec              IN  OE_Order_PUB.Line_Adj_Rec_Type
,   p_iteration                     IN  NUMBER := 1
)

IS

-- Commented for bug 2155582
--    l_old_line_adj_rec     OE_AK_LINE_PRCADJS_V%ROWTYPE;
    l_operation		   VARCHAR2(30);
    l_Modifiers_Rec		OE_Order_Cache.Modifiers_Rec_Type;

BEGIN
    oe_debug_pub.add('Enter OE_Default_Line_Adj.attributes');

    IF p_x_line_adj_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
       p_x_line_adj_rec.list_line_type_code = 'FREIGHT_CHARGE'
    THEN
	  IF p_x_line_adj_rec.estimated_flag IS NULL OR
	     p_x_line_adj_rec.estimated_flag = FND_API.G_MISS_CHAR
       THEN
	      p_x_line_adj_rec.estimated_flag := 'Y';
       END IF;
	  IF p_x_line_adj_rec.invoiced_flag IS NULL OR
	     p_x_line_adj_rec.invoiced_flag = FND_API.G_MISS_CHAR
       THEN
	      p_x_line_adj_rec.invoiced_flag := 'N';
       END IF;
	  IF p_x_line_adj_rec.credit_or_charge_flag IS NULL OR
	     p_x_line_adj_rec.credit_or_charge_flag = FND_API.G_MISS_CHAR
       THEN
	      p_x_line_adj_rec.credit_or_charge_flag := 'D';
       END IF;
    END IF;

-- Commented for bug 2155582
-- --  Due to incompatibilities in the record type structure
-- --  copy the data to a rowtype record format

--          OE_Line_Adj_UTIL.API_Rec_To_Rowtype_Rec
-- 			(p_line_adj_rec => p_x_line_adj_rec,
--                 x_rowtype_rec => g_Line_Adj_rec);
--          OE_Line_Adj_UTIL.API_Rec_To_Rowtype_Rec
-- 			(p_line_adj_rec => p_old_line_adj_rec,
-- 			 x_rowtype_rec => l_old_Line_Adj_rec);

    g_line_adj_rec := p_x_line_adj_rec;

--  For some fields, get hardcoded defaults based on the operation
	l_operation := p_x_line_adj_rec.operation;

	IF l_operation = OE_GLOBALS.G_OPR_CREATE THEN
                -- 3709642
		IF nvl(g_Line_Adj_rec.price_adjustment_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
     oe_debug_pub.add('aksingh ==> creating adj_id ');
	  		g_Line_Adj_rec.price_adjustment_id   := Get_Price_Adjustment;
      p_x_Line_Adj_rec.orig_sys_discount_ref := 'OE_PRICE_ADJUSTMENTS'||g_Line_Adj_rec.price_adjustment_id;
		END IF;

	END IF;
     If g_Line_Adj_rec.list_line_id <> FND_API.G_MISS_NUM and
        g_Line_Adj_rec.list_line_id is not null and
        (OE_Globals.G_PRICING_RECURSION <> 'Y') Then
     oe_debug_pub.add('aksingh ==> adding the default for adjustments');

	l_Modifiers_Rec:= OE_Order_Cache.Load_List_Lines(g_Line_Adj_rec.list_line_id);

	IF g_Line_Adj_rec.AUTOMATIC_FLAG = FND_API.G_MISS_CHAR  or
			g_Line_Adj_rec.AUTOMATIC_FLAG is null THEN
		g_Line_Adj_rec.AUTOMATIC_FLAG := l_Modifiers_Rec.AUTOMATIC_FLAG;
	End If;

	IF g_Line_Adj_rec.List_line_type_code = FND_API.G_MISS_CHAR  or
			g_Line_Adj_rec.List_line_type_code is null THEN
		g_Line_Adj_rec.List_line_type_code := l_Modifiers_Rec.List_line_type_code;
	End If;

	IF g_Line_Adj_rec.update_allowed = FND_API.G_MISS_CHAR  or
			g_Line_Adj_rec.update_allowed is null THEN
		g_Line_Adj_rec.update_allowed := l_Modifiers_Rec.override_flag;
	End If;

	IF g_Line_Adj_rec.operand = FND_API.G_MISS_NUM  or
			g_Line_Adj_rec.operand is null THEN
		g_Line_Adj_rec.operand := l_Modifiers_Rec.operand;
	End If;

	IF g_Line_Adj_rec.Arithmetic_operator = FND_API.G_MISS_CHAR  or
			g_Line_Adj_rec.Arithmetic_operator is null THEN
		g_Line_Adj_rec.Arithmetic_operator := l_Modifiers_Rec.Arithmetic_operator;
	End If;

	IF g_Line_Adj_rec.Pricing_phase_id = FND_API.G_MISS_NUM  or
			g_Line_Adj_rec.Pricing_phase_id is null THEN
		g_Line_Adj_rec.Pricing_phase_id := l_Modifiers_Rec.Pricing_phase_id;
	End If;

	IF g_Line_Adj_rec.charge_type_code = FND_API.G_MISS_CHAR  or
			g_Line_Adj_rec.charge_type_code is null THEN
		g_Line_Adj_rec.charge_type_code := l_Modifiers_Rec.charge_type_code;
	End If;

	IF g_Line_Adj_rec.charge_subtype_code = FND_API.G_MISS_CHAR  or
			g_Line_Adj_rec.charge_subtype_code is null THEN
		g_Line_Adj_rec.charge_subtype_code := l_Modifiers_Rec.charge_subtype_code;
	End If;

	IF g_Line_Adj_rec.list_line_no = FND_API.G_MISS_CHAR  or
			g_Line_Adj_rec.list_line_no is null THEN
		g_Line_Adj_rec.list_line_no := l_Modifiers_Rec.list_line_no;
	End If;

	IF g_Line_Adj_rec.benefit_qty = FND_API.G_MISS_NUM  or
			g_Line_Adj_rec.benefit_qty is null THEN
		g_Line_Adj_rec.benefit_qty := l_Modifiers_Rec.benefit_qty;
	End If;

	IF g_Line_Adj_rec.benefit_uom_code = FND_API.G_MISS_CHAR  or
			g_Line_Adj_rec.benefit_uom_code is null THEN
		g_Line_Adj_rec.benefit_uom_code := l_Modifiers_Rec.benefit_uom_code;
	End If;

	IF g_Line_Adj_rec.Accrual_conversion_rate = FND_API.G_MISS_NUM  or
			g_Line_Adj_rec.Accrual_conversion_rate is null THEN
		g_Line_Adj_rec.Accrual_conversion_rate := l_Modifiers_Rec.Accrual_conversion_rate;
	End If;

	IF g_Line_Adj_rec.pricing_group_sequence = FND_API.G_MISS_NUM  or
			g_Line_Adj_rec.pricing_group_sequence is null THEN
		g_Line_Adj_rec.pricing_group_sequence := l_Modifiers_Rec.pricing_group_sequence;
	End If;

	IF g_Line_Adj_rec.modifier_level_Code = FND_API.G_MISS_CHAR  or
			g_Line_Adj_rec.modifier_level_Code is null THEN
		g_Line_Adj_rec.modifier_level_Code := l_Modifiers_Rec.modifier_level_Code;
	End If;

	IF g_Line_Adj_rec.Price_break_type_code = FND_API.G_MISS_CHAR  or
			g_Line_Adj_rec.Price_break_type_code is null THEN
		g_Line_Adj_rec.Price_break_type_code := l_Modifiers_Rec.Price_break_type_code;
	End If;

	IF g_Line_Adj_rec.substitution_attribute = FND_API.G_MISS_CHAR  or
			g_Line_Adj_rec.substitution_attribute is null THEN
		g_Line_Adj_rec.substitution_attribute := l_Modifiers_Rec.substitution_attribute;
	End If;

	IF g_Line_Adj_rec.proration_type_code = FND_API.G_MISS_CHAR  or
			g_Line_Adj_rec.proration_type_code is null THEN
		g_Line_Adj_rec.proration_type_code := l_Modifiers_Rec.proration_type_code;
	End If;

	IF g_Line_Adj_rec.Include_on_returns_flag = FND_API.G_MISS_CHAR  or
			g_Line_Adj_rec.Include_on_returns_flag is null THEN
		g_Line_Adj_rec.Include_on_returns_flag := l_Modifiers_Rec.Include_on_returns_flag;
	End If;

        IF g_Line_Adj_rec.PRINT_ON_INVOICE_FLAG = FND_API.G_MISS_CHAR  or
                        g_Line_Adj_rec.PRINT_ON_INVOICE_FLAG is null THEN
                g_Line_Adj_rec.PRINT_ON_INVOICE_FLAG := l_Modifiers_Rec.PRINT_ON_INVOICE_FLAG;
        End If;

        IF g_Line_Adj_rec.ACCRUAL_FLAG = FND_API.G_MISS_CHAR  or
                        g_Line_Adj_rec.ACCRUAL_FLAG is null THEN
                g_Line_Adj_rec.ACCRUAL_FLAG := l_Modifiers_Rec.ACCRUAL_FLAG;
        End If;

End If;

-- Commented for bug 2155582
-- --  call the default handler framework to default the missing attributes

--     ONT_LINE_ADJ_Def_Hdlr.Default_Record
-- 		(p_x_rec		=> g_Line_Adj_rec
-- 		,p_in_old_rec	=> l_old_Line_Adj_rec
-- 		);

-- --  copy the data back to a format that is compatible with the API architecture

--         OE_Line_Adj_UTIL.RowType_Rec_to_API_Rec
-- 		(p_record => g_Line_Adj_rec,
-- 		 x_api_rec => p_x_line_adj_rec);

        -- Code added for bug 2155582

	p_x_line_adj_rec := g_line_adj_rec;

	oe_debug_pub.add('call convert_miss_to_null');
	OE_LINE_ADJ_UTIL.Convert_Miss_To_Null( p_x_line_adj_rec );

	-- end bug 2155582

    /* 1581620 start */

    IF p_x_Line_Adj_rec.modifier_mechanism_type_code = FND_API.G_MISS_CHAR THEN
      p_x_Line_Adj_rec.modifier_mechanism_type_code := NULL;
    END IF;

    oe_debug_pub.add('dis sys = '||p_x_Line_Adj_rec.orig_sys_discount_ref);
    IF p_x_Line_Adj_rec.orig_sys_discount_ref = FND_API.G_MISS_CHAR THEN
      p_x_Line_Adj_rec.orig_sys_discount_ref := 'OE_PRICE_ADJUSTMENTS'||p_x_Line_Adj_rec.price_adjustment_id;
    END IF;

    IF p_x_Line_Adj_rec.invoiced_flag = FND_API.G_MISS_CHAR THEN
      p_x_Line_Adj_rec.invoiced_flag := NULL;
    END IF;

    IF p_x_Line_Adj_rec.lock_control = FND_API.G_MISS_NUM THEN
      p_x_Line_Adj_rec.lock_control := NULL;
    END IF;

    -- eBTax changes
     If (p_x_line_adj_rec.tax_rate_id = FND_API.G_MISS_NUM) then
           p_x_line_adj_rec.tax_rate_id := NULL;
     end if;


    /* 1581620 end */

    oe_debug_pub.add('Exit OE_Default_Line_Adj.attributes');

End Attributes;

END OE_Default_Line_Adj ;

/
