--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_HEADER_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_HEADER_ADJ" AS
/* $Header: OEXDHADB.pls 120.0 2005/05/31 23:48:47 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Default_Header_Adj';

--  Package global used within the package.

-- For bug 2155582
g_header_adj_rec OE_ORDER_PUB.Header_Adj_Rec_Type;

--  Get functions.

FUNCTION Get_Price_Adjustment
RETURN NUMBER
  IS
     l_adjustment_id	NUMBER := NULL;
BEGIN

   SELECT  OE_PRICE_ADJUSTMENTS_S.NEXTVAL
     INTO  l_adjustment_id
     FROM  DUAL;

   RETURN l_adjustment_id;

END Get_Price_Adjustment;


PROCEDURE Attributes
(   p_x_Header_Adj_rec              IN  out nocopy OE_Order_PUB.Header_Adj_Rec_Type
,   p_old_Header_Adj_rec            IN  OE_Order_PUB.Header_Adj_Rec_Type
,   p_iteration                     IN  NUMBER := 1
)
IS

--Commented for bug 2155582
--l_old_Header_Adj_rec      OE_AK_HEADER_PRCADJS_V%ROWTYPE;
l_operation			 VARCHAR2(30);
l_Modifiers_Rec		OE_Order_Cache.Modifiers_Rec_Type;

BEGIN
    oe_debug_pub.add('Enter OE_Default_Header_Adj.Attributes');

    IF p_x_header_Adj_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
       p_x_header_Adj_rec.list_line_type_code = 'FREIGHT_CHARGE'
    THEN
	  IF p_x_header_Adj_rec.estimated_flag IS NULL OR
	     p_x_header_Adj_rec.estimated_flag = FND_API.G_MISS_CHAR
       THEN
	      p_x_header_Adj_rec.estimated_flag := 'Y';
       END IF;
	  IF p_x_header_Adj_rec.invoiced_flag IS NULL OR
	     p_x_header_Adj_rec.invoiced_flag = FND_API.G_MISS_CHAR
       THEN
	      p_x_header_Adj_rec.invoiced_flag := 'N';
       END IF;
	  IF p_x_header_Adj_rec.credit_or_charge_flag IS NULL OR
	     p_x_header_Adj_rec.credit_or_charge_flag = FND_API.G_MISS_CHAR
       THEN
	      p_x_header_Adj_rec.credit_or_charge_flag := 'D';
       END IF;
    END IF;

-- /* Commenting for bug 2155582
--     --  Due to incompatibilities in the record type structure
--     --  copy the data to a rowtype record format
-- 	OE_Header_Adj_UTIL.API_Rec_To_Rowtype_Rec
-- 		(p_header_Adj_rec => p_x_header_adj_rec,
-- 	     x_rowtype_rec => g_Header_Adj_rec);
-- 	 OE_Header_Adj_UTIL.API_Rec_To_Rowtype_Rec
-- 		(p_header_Adj_rec => p_old_header_adj_rec,
-- 	  x_rowtype_rec => l_old_Header_Adj_rec);
--  */

	  g_header_adj_rec := p_x_header_adj_rec;

--  For some fields, get hardcoded defaults based on the operation
	l_operation := p_x_header_Adj_rec.operation;

	IF l_operation = OE_GLOBALS.G_OPR_CREATE THEN
          -- 3709642
	  IF nvl(g_header_Adj_rec.price_adjustment_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
		g_header_Adj_rec.price_adjustment_id   := Get_Price_Adjustment;
	  END IF;

	END IF;

	If g_header_Adj_rec.list_line_id <> FND_API.G_MISS_NUM and g_header_Adj_rec.list_line_id is not null then

	   l_Modifiers_Rec:= OE_Order_Cache.Load_List_Lines(g_header_Adj_rec.list_line_id);

	   IF g_header_Adj_rec.AUTOMATIC_FLAG = FND_API.G_MISS_CHAR  or
	     g_header_Adj_rec.AUTOMATIC_FLAG is null THEN
	      g_header_Adj_rec.AUTOMATIC_FLAG := l_Modifiers_Rec.AUTOMATIC_FLAG;
	   End If;

	   IF g_header_Adj_rec.List_line_type_code = FND_API.G_MISS_CHAR  or
	     g_header_Adj_rec.List_line_type_code is null THEN
	      g_header_Adj_rec.List_line_type_code := l_Modifiers_Rec.List_line_type_code;
	   End If;

	   IF g_header_Adj_rec.update_allowed = FND_API.G_MISS_CHAR  or
	     g_header_Adj_rec.update_allowed is null THEN
	      g_header_Adj_rec.update_allowed := l_Modifiers_Rec.override_flag;
	   End If;

	   IF g_header_Adj_rec.operand = FND_API.G_MISS_NUM  or
	     g_header_Adj_rec.operand is null THEN
	      g_header_Adj_rec.operand := l_Modifiers_Rec.operand;
	   End If;

	   IF g_header_Adj_rec.Arithmetic_operator = FND_API.G_MISS_CHAR  or
	     g_header_Adj_rec.Arithmetic_operator is null THEN
	      g_header_Adj_rec.Arithmetic_operator := l_Modifiers_Rec.Arithmetic_operator;
	   End If;

	   IF g_header_Adj_rec.Pricing_phase_id = FND_API.G_MISS_NUM  or
	     g_header_Adj_rec.Pricing_phase_id is null THEN
	      g_header_Adj_rec.Pricing_phase_id := l_Modifiers_Rec.Pricing_phase_id;
	   End If;

	   IF g_header_Adj_rec.charge_type_code = FND_API.G_MISS_CHAR  or
	     g_header_Adj_rec.charge_type_code is null THEN
	      g_header_Adj_rec.charge_type_code := l_Modifiers_Rec.charge_type_code;
	   End If;

	   IF g_header_Adj_rec.charge_subtype_code = FND_API.G_MISS_CHAR  or
	     g_header_Adj_rec.charge_subtype_code is null THEN
	      g_header_Adj_rec.charge_subtype_code := l_Modifiers_Rec.charge_subtype_code;
	   End If;

	   IF g_header_Adj_rec.list_line_no = FND_API.G_MISS_CHAR  or
	     g_header_Adj_rec.list_line_no is null THEN
	      g_header_Adj_rec.list_line_no := l_Modifiers_Rec.list_line_no;
	   End If;

	   IF g_header_Adj_rec.benefit_qty = FND_API.G_MISS_NUM  or
	     g_header_Adj_rec.benefit_qty is null THEN
	      g_header_Adj_rec.benefit_qty := l_Modifiers_Rec.benefit_qty;
	   End If;

	   IF g_header_Adj_rec.benefit_uom_code = FND_API.G_MISS_CHAR  or
	     g_header_Adj_rec.benefit_uom_code is null THEN
	      g_header_Adj_rec.benefit_uom_code := l_Modifiers_Rec.benefit_uom_code;
	   End If;

	   IF g_header_Adj_rec.Accrual_conversion_rate = FND_API.G_MISS_NUM  or
	     g_header_Adj_rec.Accrual_conversion_rate is null THEN
	      g_header_Adj_rec.Accrual_conversion_rate := l_Modifiers_Rec.Accrual_conversion_rate;
	   End If;

	   IF g_header_Adj_rec.pricing_group_sequence = FND_API.G_MISS_NUM  or
	     g_header_Adj_rec.pricing_group_sequence is null THEN
	      g_header_Adj_rec.pricing_group_sequence := l_Modifiers_Rec.pricing_group_sequence;
	   End If;

	   IF g_header_Adj_rec.modifier_level_Code = FND_API.G_MISS_CHAR  or
	     g_header_Adj_rec.modifier_level_Code is null THEN
	      g_header_Adj_rec.modifier_level_Code := l_Modifiers_Rec.modifier_level_Code;
	   End If;

	   IF g_header_Adj_rec.Price_break_type_code = FND_API.G_MISS_CHAR  or
	     g_header_Adj_rec.Price_break_type_code is null THEN
	      g_header_Adj_rec.Price_break_type_code := l_Modifiers_Rec.Price_break_type_code;
	   End If;

	   IF g_header_Adj_rec.substitution_attribute = FND_API.G_MISS_CHAR  or
	     g_header_Adj_rec.substitution_attribute is null THEN
	      g_header_Adj_rec.substitution_attribute := l_Modifiers_Rec.substitution_attribute;
	   End If;

	   IF g_header_Adj_rec.proration_type_code = FND_API.G_MISS_CHAR  or
	     g_header_Adj_rec.proration_type_code is null THEN
	      g_header_Adj_rec.proration_type_code := l_Modifiers_Rec.proration_type_code;
	   End If;

	   IF g_header_Adj_rec.Include_on_returns_flag = FND_API.G_MISS_CHAR  or
	     g_header_Adj_rec.Include_on_returns_flag is null THEN
	      g_header_Adj_rec.Include_on_returns_flag := l_Modifiers_Rec.Include_on_returns_flag;
	   End If;

	End If;


--     Commented for bug 2155582
-- --  call the default handler framework to default the missing attributes

--     ONT_HEADER_ADJ_Def_Hdlr.Default_Record
--    		(p_x_rec		=> g_header_Adj_rec
-- 		,p_in_old_rec	=>  l_old_header_Adj_rec
-- 		);

-- --  copy the data back to a format that is compatible with the API architecture

-- 	OE_Header_Adj_UTIL.RowType_Rec_to_API_Rec
-- 			(p_record => g_header_Adj_rec
-- 			,x_api_rec => p_x_header_Adj_rec);

	-- Code added for bug 2155582

	p_x_header_adj_rec := g_header_adj_rec;

	oe_debug_pub.add('call convert_miss_to_null');
	OE_HEADER_ADJ_UTIL.Convert_Miss_To_Null( p_x_header_adj_rec );

	-- end bug 2155582

    /* 1581620 start */

    IF p_x_header_Adj_rec.modifier_mechanism_type_code = FND_API.G_MISS_CHAR THEN
      p_x_header_Adj_rec.modifier_mechanism_type_code := NULL;
    END IF;

    IF p_x_header_Adj_rec.orig_sys_discount_ref = FND_API.G_MISS_CHAR THEN
      oe_debug_pub.add('discount ref = '||p_x_header_Adj_rec.price_adjustment_id);
      p_x_header_Adj_rec.orig_sys_discount_ref := 'OE_PRICE_ADJUSTMENTS'||p_x_header_Adj_rec.price_adjustment_id;
    END IF;

    IF p_x_header_Adj_rec.invoiced_flag = FND_API.G_MISS_CHAR THEN
      p_x_header_Adj_rec.invoiced_flag := NULL;
    END IF;

    IF p_x_header_Adj_rec.lock_control = FND_API.G_MISS_NUM THEN
      p_x_header_Adj_rec.lock_control := NULL;
    END IF;

    /* 1581620 end */

    oe_debug_pub.add('Exit OE_Default_Header_Adj.Attributes');

END Attributes;

END OE_Default_Header_Adj;

/
