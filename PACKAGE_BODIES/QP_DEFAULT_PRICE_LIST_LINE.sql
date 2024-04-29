--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_PRICE_LIST_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_PRICE_LIST_LINE" AS
/* $Header: QPXDPLLB.pls 120.3 2005/11/21 13:29:37 shulin ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Price_List_Line';

--  Package global used within the package.

g_PRICE_LIST_LINE_rec         QP_Price_List_PUB.Price_List_Line_Rec_Type;

--  Get functions.

FUNCTION Get_Accrual_Qty
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Accrual_Qty;

FUNCTION Get_Qualification_Ind
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Qualification_Ind;

FUNCTION Get_Accrual_Uom
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Accrual_Uom;

FUNCTION Get_Arithmetic_Operator
RETURN VARCHAR2
IS
BEGIN

    RETURN 'UNIT_PRICE';

END Get_Arithmetic_Operator;

FUNCTION Get_Automatic
RETURN VARCHAR2
IS
BEGIN

    RETURN 'Y';

END Get_Automatic;

FUNCTION Get_Base_Qty
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Base_Qty;

FUNCTION Get_Base_Uom
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Base_Uom;

FUNCTION Get_Comments
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Comments;

FUNCTION Get_Effective_Period_Uom
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Effective_Period_Uom;

FUNCTION Get_End_Date_Active
RETURN DATE
IS
l_end_date date;
BEGIN

    RETURN NULL;

END Get_End_Date_Active;

FUNCTION Get_Estim_Accrual_Rate
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Estim_Accrual_Rate;

FUNCTION Get_Generate_Using_Formula
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Generate_Using_Formula;

FUNCTION Get_Inventory_Item
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Inventory_Item;

FUNCTION Get_List_Header
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_List_Header;

FUNCTION Get_List_Line_No(a_list_line_no IN VARCHAR2) -- 4751658, 4199398
RETURN VARCHAR2
IS
BEGIN

  RETURN a_list_line_no;

END Get_List_Line_No;

FUNCTION Get_List_Line
RETURN NUMBER
IS
l_list_line_id number;
BEGIN

   select qp_list_lines_s.nextval
   into l_list_line_id
   from dual;

   return l_list_line_id;

EXCEPTION

   WHEN OTHERS THEN RETURN NULL;

END Get_List_Line;

FUNCTION Get_List_Line_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN 'PLL';

END Get_List_Line_Type;

FUNCTION Get_List_Price
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_List_Price;

FUNCTION Get_From_Rltd_Modifier_Id
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_From_Rltd_Modifier_Id;

FUNCTION Get_Rltd_Modifier_Group_No
RETURN NUMBER
IS
l_rltd_modifier_grp_no number := NULL;
BEGIN

    SELECT qp_rltd_modifier_grp_no_s.nextval
    into l_rltd_modifier_grp_no
    from dual;

    return l_rltd_modifier_grp_no;

EXCEPTION

    WHEN OTHERS THEN RETURN NULL;

END Get_Rltd_Modifier_Group_No;

FUNCTION Get_Product_Precedence
RETURN NUMBER
IS
l_prod_precedence number := NULL;
BEGIN

  IF    ( ( g_PRICE_LIST_LINE_rec.from_rltd_modifier_id is not null )
      and ( g_PRICE_LIST_LINE_rec.from_rltd_modifier_id <> FND_API.G_MISS_NUM ) )
  THEN

	 select product_precedence
	 into l_prod_precedence
	 from qp_list_lines
	 where list_line_id = g_PRICE_LIST_LINE_rec.from_rltd_modifier_id;

  END IF;

  return l_prod_precedence;

 EXCEPTION

   WHEN OTHERS THEN RETURN NULL;


END Get_Product_Precedence;

FUNCTION Get_Modifier_Level
RETURN VARCHAR2
IS
BEGIN

    RETURN 'LINE';

END Get_Modifier_Level;

FUNCTION Get_Number_Effective_Periods
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Number_Effective_Periods;

FUNCTION Get_Operand
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Operand;

FUNCTION Get_Organization
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Organization;

FUNCTION Get_Override
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Override;

FUNCTION Get_Percent_Price
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Percent_Price;

FUNCTION Get_Price_Break_Type
RETURN VARCHAR2
IS
l_price_break_type varchar2(30) := NULL;
BEGIN

  select price_break_type_code
  into l_price_break_type
  from qp_list_lines
  where list_line_id = g_price_list_line_rec.from_rltd_modifier_id
  and rownum < 2;

  return l_price_break_type;

exception

   when others then return null;

END Get_Price_Break_Type;

FUNCTION Get_Price_By_Formula
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Price_By_Formula;

FUNCTION Get_Primary_Uom
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Primary_Uom;

FUNCTION Get_Print_On_Invoice
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Print_On_Invoice;

FUNCTION Get_Rebate_Transaction_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Rebate_Transaction_Type;

-- block pricing
FUNCTION Get_Recurring_Value
RETURN NUMBER
IS
BEGIN
  RETURN NULL;
END Get_Recurring_Value;

FUNCTION Get_Related_Item
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Related_Item;

FUNCTION Get_Relationship_Type
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Relationship_Type;

FUNCTION Get_Reprice
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Reprice;

FUNCTION Get_Revision
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Revision;

FUNCTION Get_Revision_Date
RETURN DATE
IS
BEGIN

    RETURN SYSDATE;

END Get_Revision_Date;

FUNCTION Get_Revision_Reason
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Revision_Reason;

FUNCTION Get_Start_Date_Active
RETURN DATE
IS
l_start_date date;
BEGIN

    select start_date_active
    into l_start_date
    from qp_list_headers_b
    where list_header_id = g_PRICE_LIST_LINE_rec.list_header_id;

    return l_start_date;

EXCEPTION

    WHEN OTHERS THEN RETURN NULL;

END Get_Start_Date_Active;

FUNCTION Get_Substitution_Attribute
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Substitution_Attribute;

FUNCTION Get_Substitution_Context
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Substitution_Context;

FUNCTION Get_Substitution_Value
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Substitution_Value;

-- Blanket Pricing
FUNCTION Get_Customer_Item_Id
RETURN VARCHAR2
IS BEGIN

    RETURN NULL;

END Get_Customer_Item_Id;

-- Break Uom Proration
FUNCTION Get_Break_Uom_Code
RETURN VARCHAR2
IS BEGIN

    RETURN NULL;

END Get_Break_Uom_Code;

-- Break Uom Proration
FUNCTION Get_Break_Uom_Context
RETURN VARCHAR2
IS BEGIN

    RETURN NULL;

END Get_Break_Uom_Context;

-- Break Uom Proration
FUNCTION Get_Break_Uom_Attribute
RETURN VARCHAR2
IS BEGIN

    RETURN NULL;

END Get_Break_Uom_Attribute;

PROCEDURE Get_Flex_Price_List_Line
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_PRICE_LIST_LINE_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute1 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute10 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute11 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute12 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute13 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute14 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute15 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute2 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute3 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute4 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute5 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute6 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute7 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute8 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.attribute9 := NULL;
    END IF;

    IF g_PRICE_LIST_LINE_rec.context = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_LINE_rec.context  := NULL;
    END IF;

END Get_Flex_Price_List_Line;

--  Procedure Attributes

PROCEDURE Attributes
(   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
,   p_iteration                     IN  NUMBER := 1
,   x_PRICE_LIST_LINE_rec           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Rec_Type
)
IS
 g_p_PRICE_LIST_LINE_rec        QP_Price_List_PUB.Price_List_Line_Rec_Type;
BEGIN

    oe_debug_pub.add('entering attributes');

    --  Check number of iterations.

    IF p_iteration > QP_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_DEF_MAX_ITERATION');
            oe_msg_pub.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Initialize g_PRICE_LIST_LINE_rec

    g_PRICE_LIST_LINE_rec := p_PRICE_LIST_LINE_rec;

    --  Default missing attributes.

    IF g_PRICE_LIST_LINE_rec.accrual_qty = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.accrual_qty := Get_Accrual_Qty;

	   oe_debug_pub.add('get_accrual_qty');

	   /*

        IF g_PRICE_LIST_LINE_rec.accrual_qty IS NOT NULL THEN

	    oe_debug_pub.add('accrual qty');

            IF QP_Validate.Accrual_Qty(g_PRICE_LIST_LINE_rec.accrual_qty)
            THEN
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_ACCRUAL_QTY
                ,   p_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.accrual_qty := NULL;
            END IF;

        END IF;

	   */

    END IF;


    IF g_PRICE_LIST_LINE_rec.accrual_uom_code = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.accrual_uom_code := Get_Accrual_Uom;

	    oe_debug_pub.add('get_accrual_uom');

       /*

        IF g_PRICE_LIST_LINE_rec.accrual_uom_code IS NOT NULL THEN

            IF QP_Validate.Accrual_Uom(g_PRICE_LIST_LINE_rec.accrual_uom_code)
            THEN
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_ACCRUAL_UOM
                ,   p_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.accrual_uom_code := NULL;
            END IF;

        END IF;

       */

    END IF;


    IF g_PRICE_LIST_LINE_rec.arithmetic_operator = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.arithmetic_operator := Get_Arithmetic_Operator;

	   oe_debug_pub.add('get arithmetic operator');

        IF g_PRICE_LIST_LINE_rec.arithmetic_operator IS NOT NULL THEN

            IF QP_Validate.Arithmetic_Operator(g_PRICE_LIST_LINE_rec.arithmetic_operator)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_ARITHMETIC_OPERATOR
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.arithmetic_operator := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.automatic_flag = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.automatic_flag := Get_Automatic;

	    oe_debug_pub.add('get automatic');

        IF g_PRICE_LIST_LINE_rec.automatic_flag IS NOT NULL THEN

            IF QP_Validate.Automatic(g_PRICE_LIST_LINE_rec.automatic_flag)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_AUTOMATIC
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.automatic_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.base_qty = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.base_qty := Get_Base_Qty;

	   oe_debug_pub.add('get base qty');

       /*

        IF g_PRICE_LIST_LINE_rec.base_qty IS NOT NULL THEN

            IF QP_Validate.Base_Qty(g_PRICE_LIST_LINE_rec.base_qty)
            THEN
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_BASE_QTY
                ,   p_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.base_qty := NULL;
            END IF;

        END IF;

       */

    END IF;

    IF g_PRICE_LIST_LINE_rec.base_uom_code = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.base_uom_code := Get_Base_Uom;

	   oe_debug_pub.add('get base uom');

        /*

        IF g_PRICE_LIST_LINE_rec.base_uom_code IS NOT NULL THEN

            IF QP_Validate.Base_Uom(g_PRICE_LIST_LINE_rec.base_uom_code)
            THEN
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_BASE_UOM
                ,   p_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.base_uom_code := NULL;
            END IF;

        END IF;

        */

    END IF;

    IF g_PRICE_LIST_LINE_rec.comments = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.comments := Get_Comments;

	   oe_debug_pub.add('get comments');

        IF g_PRICE_LIST_LINE_rec.comments IS NOT NULL THEN

            IF QP_Validate.Comments(g_PRICE_LIST_LINE_rec.comments)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_COMMENTS
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.comments := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.effective_period_uom = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.effective_period_uom := Get_Effective_Period_Uom;

	   oe_debug_pub.add('get effective period uom');

        IF g_PRICE_LIST_LINE_rec.effective_period_uom IS NOT NULL THEN

            IF QP_Validate.Effective_Period_Uom(g_PRICE_LIST_LINE_rec.effective_period_uom)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_EFFECTIVE_PERIOD_UOM
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.effective_period_uom := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.end_date_active = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_LINE_rec.end_date_active := Get_End_Date_Active;

	   oe_debug_pub.add('get end_date_active');

        IF g_PRICE_LIST_LINE_rec.end_date_active IS NOT NULL THEN

            IF QP_Validate.End_Date_Active(g_PRICE_LIST_LINE_rec.end_date_active)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_END_DATE_ACTIVE
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.end_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.estim_accrual_rate = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.estim_accrual_rate := Get_Estim_Accrual_Rate;

	   oe_debug_pub.add('get estim accrual rate');

        IF g_PRICE_LIST_LINE_rec.estim_accrual_rate IS NOT NULL THEN

            IF QP_Validate.Estim_Accrual_Rate(g_PRICE_LIST_LINE_rec.estim_accrual_rate)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_ESTIM_ACCRUAL_RATE
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.estim_accrual_rate := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.generate_using_formula_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.generate_using_formula_id := Get_Generate_Using_Formula;
	   oe_debug_pub.add('get generate using formula');

        IF g_PRICE_LIST_LINE_rec.generate_using_formula_id IS NOT NULL THEN

            IF QP_Validate.Generate_Using_Formula(g_PRICE_LIST_LINE_rec.generate_using_formula_id)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_GENERATE_USING_FORMULA
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.generate_using_formula_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.inventory_item_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.inventory_item_id := Get_Inventory_Item;

	   oe_debug_pub.add('get inventory item');

        IF g_PRICE_LIST_LINE_rec.inventory_item_id IS NOT NULL THEN

            IF QP_Validate.Inventory_Item(g_PRICE_LIST_LINE_rec.inventory_item_id)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_INVENTORY_ITEM
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.inventory_item_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.list_header_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.list_header_id := Get_List_Header;

	   oe_debug_pub.add('get list header');

        IF g_PRICE_LIST_LINE_rec.list_header_id IS NOT NULL THEN

            IF QP_Validate.List_Header(g_PRICE_LIST_LINE_rec.list_header_id)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_LIST_HEADER
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.list_header_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.list_line_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.list_line_id := Get_List_Line;

        IF g_PRICE_LIST_LINE_rec.list_line_id IS NOT NULL THEN

            IF QP_Validate.List_Line(g_PRICE_LIST_LINE_rec.list_line_id)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_LIST_LINE
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.list_line_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.list_line_no = FND_API.G_MISS_CHAR THEN -- 4751658, 4199398

        g_PRICE_LIST_LINE_rec.list_line_no :=
			 Get_List_Line_No(g_PRICE_LIST_LINE_rec.list_line_id);

	   oe_debug_pub.add('get list line no');

    END IF;

    IF g_PRICE_LIST_LINE_rec.list_line_type_code = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.list_line_type_code := Get_List_Line_Type;

	   oe_debug_pub.add('get list line type');

        IF g_PRICE_LIST_LINE_rec.list_line_type_code IS NOT NULL THEN

            IF QP_Validate.List_Line_Type(g_PRICE_LIST_LINE_rec.list_line_type_code)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_LIST_LINE_TYPE
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.list_line_type_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.list_price = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.list_price := Get_List_Price;

	   oe_debug_pub.add('get list price');

        IF g_PRICE_LIST_LINE_rec.list_price IS NOT NULL THEN

            IF QP_Validate.List_Price(g_PRICE_LIST_LINE_rec.list_price)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_LIST_PRICE
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.list_price := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.from_rltd_modifier_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.from_rltd_modifier_id := Get_From_Rltd_Modifier_Id;

	   oe_debug_pub.add('get rltd modifier');

       /*

        IF g_PRICE_LIST_LINE_rec.from_rltd_modifier_id IS NOT NULL THEN

            IF QP_Validate.From_Rltd_Modifier_Id(g_PRICE_LIST_LINE_rec.from_rltd_modifier_id)
            THEN
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_FROM_RLTD_MODIFIER
                ,   p_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.from_rltd_modifier_id := NULL;
            END IF;

        END IF;

         */

    END IF;

    IF g_PRICE_LIST_LINE_rec.product_precedence = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.product_precedence := Get_Product_Precedence;

	   oe_debug_Pub.add('get product precedence');

        /*

        IF g_PRICE_LIST_LINE_rec.product_precedence IS NOT NULL THEN

            IF QP_Validate.Product_Precedence(g_PRICE_LIST_LINE_rec.product_precedence)
            THEN
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_PRODUCT_PRECEDENCE
                ,   p_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.product_precedence := NULL;
            END IF;

        END IF;
       */

    END IF;

    IF g_PRICE_LIST_LINE_rec.rltd_modifier_group_no = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.rltd_modifier_group_no := Get_Rltd_Modifier_Group_No;

	   oe_debug_pub.add('get rltd modifier group no');
       /*

        IF g_PRICE_LIST_LINE_rec.rltd_modifier_group_no IS NOT NULL THEN

            IF QP_Validate.Rltd_Modifier_Group_No(g_PRICE_LIST_LINE_rec.rltd_modifier_group_no)
            THEN
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_RLTD_MODIFIER_GROUP_NO
                ,   p_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.rltd_modifier_group_no := NULL;
            END IF;

        END IF;
        */

    END IF;
    IF g_PRICE_LIST_LINE_rec.modifier_level_code = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.modifier_level_code := Get_Modifier_Level;

	   oe_debug_pub.add('get modifier level');

        IF g_PRICE_LIST_LINE_rec.modifier_level_code IS NOT NULL THEN

            IF QP_Validate.Modifier_Level(g_PRICE_LIST_LINE_rec.modifier_level_code)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_MODIFIER_LEVEL
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.modifier_level_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.number_effective_periods = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.number_effective_periods := Get_Number_Effective_Periods;

	   oe_debug_pub.add('get number effective periods');

        IF g_PRICE_LIST_LINE_rec.number_effective_periods IS NOT NULL THEN

            IF QP_Validate.Number_Effective_Periods(g_PRICE_LIST_LINE_rec.number_effective_periods)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_NUMBER_EFFECTIVE_PERIODS
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.number_effective_periods := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.operand = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.operand := Get_Operand;

	   oe_debug_pub.add('get operand');

        IF g_PRICE_LIST_LINE_rec.operand IS NOT NULL THEN

            IF QP_Validate.Operand(g_PRICE_LIST_LINE_rec.operand)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_OPERAND
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.operand := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.organization_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.organization_id := Get_Organization;

	   oe_debug_pub.add('get organization');

        IF g_PRICE_LIST_LINE_rec.organization_id IS NOT NULL THEN

            IF QP_Validate.Organization(g_PRICE_LIST_LINE_rec.organization_id)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_ORGANIZATION
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.organization_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.override_flag = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.override_flag := Get_Override;

	   oe_debug_pub.add('get override');

        IF g_PRICE_LIST_LINE_rec.override_flag IS NOT NULL THEN

            IF QP_Validate.Override(g_PRICE_LIST_LINE_rec.override_flag)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_OVERRIDE
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.override_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.percent_price = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.percent_price := Get_Percent_Price;

	   oe_debug_pub.add('get percent price');

        IF g_PRICE_LIST_LINE_rec.percent_price IS NOT NULL THEN

            IF QP_Validate.Percent_Price(g_PRICE_LIST_LINE_rec.percent_price)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_PERCENT_PRICE
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.percent_price := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.price_break_type_code = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.price_break_type_code := Get_Price_Break_Type;

	   oe_debug_pub.add('get price break type');

        IF g_PRICE_LIST_LINE_rec.price_break_type_code IS NOT NULL THEN

            IF QP_Validate.Price_Break_Type(g_PRICE_LIST_LINE_rec.price_break_type_code)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_PRICE_BREAK_TYPE
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.price_break_type_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.price_by_formula_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.price_by_formula_id := Get_Price_By_Formula;

	   oe_debug_pub.add('get price formula');

        IF g_PRICE_LIST_LINE_rec.price_by_formula_id IS NOT NULL THEN

            IF QP_Validate.Price_By_Formula(g_PRICE_LIST_LINE_rec.price_by_formula_id)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_PRICE_BY_FORMULA
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.price_by_formula_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.primary_uom_flag = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.primary_uom_flag := Get_Primary_Uom;

	   oe_debug_pub.add('get primary uom');

        IF g_PRICE_LIST_LINE_rec.primary_uom_flag IS NOT NULL THEN

            IF QP_Validate.Primary_Uom(g_PRICE_LIST_LINE_rec.primary_uom_flag)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_PRIMARY_UOM
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.primary_uom_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.print_on_invoice_flag = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.print_on_invoice_flag := Get_Print_On_Invoice;

	   oe_debug_pub.add('get print on invoice');

        IF g_PRICE_LIST_LINE_rec.print_on_invoice_flag IS NOT NULL THEN

            IF QP_Validate.Print_On_Invoice(g_PRICE_LIST_LINE_rec.print_on_invoice_flag)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_PRINT_ON_INVOICE
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.print_on_invoice_flag := NULL;
            END IF;

        END IF;

    END IF;


    IF g_PRICE_LIST_LINE_rec.rebate_trxn_type_code = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.rebate_trxn_type_code := Get_Rebate_Transaction_Type;

	   oe_debug_pub.add('get rebate trxn type');

        IF g_PRICE_LIST_LINE_rec.rebate_trxn_type_code IS NOT NULL THEN

            IF QP_Validate.Rebate_Transaction_Type(g_PRICE_LIST_LINE_rec.rebate_trxn_type_code)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_REBATE_TRANSACTION_TYPE
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.rebate_trxn_type_code := NULL;
            END IF;

        END IF;

    END IF;

    -- block pricing
    IF g_PRICE_LIST_LINE_rec.recurring_value = FND_API.G_MISS_NUM THEN
      g_PRICE_LIST_LINE_rec.recurring_value := Get_Recurring_Value;
      IF g_PRICE_LIST_LINE_rec.recurring_value IS NOT NULL THEN
        IF QP_Validate.recurring_value(g_PRICE_LIST_LINE_rec.recurring_value)
        THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
          QP_Price_List_Line_Util.Clear_Dependent_Attr
            (p_attr_id             => QP_Price_List_Line_Util.G_RECURRING_VALUE,
             p_PRICE_LIST_LINE_rec => g_p_PRICE_LIST_LINE_rec,
             x_PRICE_LIST_LINE_rec => g_PRICE_LIST_LINE_rec);
        ELSE
          g_PRICE_LIST_LINE_rec.related_item_id := NULL;
        END IF;
      END IF;
    END IF;

    IF g_PRICE_LIST_LINE_rec.related_item_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.related_item_id := Get_Related_Item;

	   oe_debug_pub.add('get related item');

        IF g_PRICE_LIST_LINE_rec.related_item_id IS NOT NULL THEN

            IF QP_Validate.Related_Item(g_PRICE_LIST_LINE_rec.related_item_id)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_RELATED_ITEM
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.related_item_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.relationship_type_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.relationship_type_id := Get_Relationship_Type;

	   oe_debug_pub.add('get relationship type');

        IF g_PRICE_LIST_LINE_rec.relationship_type_id IS NOT NULL THEN

            IF QP_Validate.Relationship_Type(g_PRICE_LIST_LINE_rec.relationship_type_id)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_RELATIONSHIP_TYPE
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.relationship_type_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.reprice_flag = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.reprice_flag := Get_Reprice;

	   oe_debug_pub.add('get reprice');

        IF g_PRICE_LIST_LINE_rec.reprice_flag IS NOT NULL THEN

            IF QP_Validate.Reprice(g_PRICE_LIST_LINE_rec.reprice_flag)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_REPRICE
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.reprice_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.revision = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.revision := Get_Revision;

	   oe_debug_pub.add('get revision');

        IF g_PRICE_LIST_LINE_rec.revision IS NOT NULL THEN

            IF QP_Validate.Revision(g_PRICE_LIST_LINE_rec.revision)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_REVISION
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.revision := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.revision_date = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_LINE_rec.revision_date := Get_Revision_Date;

	   oe_debug_pub.add('get revision date');

        IF g_PRICE_LIST_LINE_rec.revision_date IS NOT NULL THEN

            IF QP_Validate.Revision_Date(g_PRICE_LIST_LINE_rec.revision_date)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_REVISION_DATE
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.revision_date := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.revision_reason_code = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.revision_reason_code := Get_Revision_Reason;

	   oe_debug_pub.add('get revision reason');

        IF g_PRICE_LIST_LINE_rec.revision_reason_code IS NOT NULL THEN

            IF QP_Validate.Revision_Reason(g_PRICE_LIST_LINE_rec.revision_reason_code)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_REVISION_REASON
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.revision_reason_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.start_date_active = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_LINE_rec.start_date_active := Get_Start_Date_Active;

	   oe_debug_pub.add('get start date active');

        IF g_PRICE_LIST_LINE_rec.start_date_active IS NOT NULL THEN

            IF QP_Validate.Start_Date_Active(g_PRICE_LIST_LINE_rec.start_date_active)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_START_DATE_ACTIVE
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.start_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.substitution_attribute = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.substitution_attribute := Get_Substitution_Attribute;

	   oe_debug_pub.add('get substitution');

        IF g_PRICE_LIST_LINE_rec.substitution_attribute IS NOT NULL THEN

            IF QP_Validate.Substitution_Attribute(g_PRICE_LIST_LINE_rec.substitution_attribute)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_SUBSTITUTION_ATTRIBUTE
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.substitution_attribute := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.substitution_context = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.substitution_context := Get_Substitution_Context;

	   oe_debug_pub.add('get substitution context');

        IF g_PRICE_LIST_LINE_rec.substitution_context IS NOT NULL THEN

            IF QP_Validate.Substitution_Context(g_PRICE_LIST_LINE_rec.substitution_context)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_SUBSTITUTION_CONTEXT
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.substitution_context := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.substitution_value = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.substitution_value := Get_Substitution_Value;

	   oe_debug_pub.add('get substitution value');

        IF g_PRICE_LIST_LINE_rec.substitution_value IS NOT NULL THEN

            IF QP_Validate.Substitution_Value(g_PRICE_LIST_LINE_rec.substitution_value)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_SUBSTITUTION_VALUE
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.substitution_value := NULL;
            END IF;

        END IF;

    END IF;

    -- Blanket Pricing
    IF g_PRICE_LIST_LINE_rec.customer_item_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.customer_item_id := Get_Customer_Item_Id;

	   oe_debug_pub.add('get customer item id');

        IF g_PRICE_LIST_LINE_rec.customer_item_id IS NOT NULL THEN

            IF QP_Validate.Customer_Item_Id(g_PRICE_LIST_LINE_rec.customer_item_id)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_CUSTOMER_ITEM_ID
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.customer_item_id := NULL;
            END IF;

        END IF;

    END IF;

    -- Break Uom Proration
    IF g_PRICE_LIST_LINE_rec.break_uom_code = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.break_uom_code := Get_break_uom_code;

	   oe_debug_pub.add('get break_uom_code ');

        IF g_PRICE_LIST_LINE_rec.break_uom_code IS NOT NULL THEN

            IF QP_Validate.break_uom_code(g_PRICE_LIST_LINE_rec.break_uom_code)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_BREAK_UOM_CODE
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.break_uom_code := NULL;
            END IF;

        END IF;

    END IF;

    -- Break Uom Proration
    IF g_PRICE_LIST_LINE_rec.break_uom_context = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.break_uom_context := Get_break_uom_context;

	   oe_debug_pub.add('get break_uom_context ');

        IF g_PRICE_LIST_LINE_rec.break_uom_context IS NOT NULL THEN

            IF QP_Validate.break_uom_context(g_PRICE_LIST_LINE_rec.break_uom_context)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_BREAK_UOM_CONTEXT
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.break_uom_context := NULL;
            END IF;

        END IF;

    END IF;

    -- Break Uom Proration
    IF g_PRICE_LIST_LINE_rec.break_uom_attribute = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_LINE_rec.break_uom_attribute := Get_break_uom_attribute;

	   oe_debug_pub.add('get break_uom_attribute ');

        IF g_PRICE_LIST_LINE_rec.break_uom_attribute IS NOT NULL THEN

            IF QP_Validate.break_uom_attribute(g_PRICE_LIST_LINE_rec.break_uom_attribute)
            THEN
                g_p_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;
                QP_Price_List_Line_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Line_Util.G_BREAK_UOM_ATTRIBUTE
                ,   p_PRICE_LIST_LINE_rec         => g_p_PRICE_LIST_LINE_rec
                ,   x_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
                );
            ELSE
                g_PRICE_LIST_LINE_rec.break_uom_attribute := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_LINE_rec.qualification_ind = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.qualification_ind := Get_Qualification_Ind;

	oe_debug_pub.add('get_qualification_ind');

    END IF;


    IF g_PRICE_LIST_LINE_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.context = FND_API.G_MISS_CHAR
    THEN

	   oe_debug_pub.add('get flex price list');

        Get_Flex_Price_List_Line;

	   oe_debug_pub.add('after get flex price list line');

    END IF;

    IF g_PRICE_LIST_LINE_rec.created_by = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.created_by := NULL;

    END IF;

    IF g_PRICE_LIST_LINE_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_LINE_rec.creation_date := NULL;

    END IF;

    IF g_PRICE_LIST_LINE_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.last_updated_by := NULL;

    END IF;

    IF g_PRICE_LIST_LINE_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_LINE_rec.last_update_date := NULL;

    END IF;

    IF g_PRICE_LIST_LINE_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.last_update_login := NULL;

    END IF;

    IF g_PRICE_LIST_LINE_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.program_application_id := NULL;

    END IF;

    IF g_PRICE_LIST_LINE_rec.program_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.program_id := NULL;

    END IF;

    IF g_PRICE_LIST_LINE_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_LINE_rec.program_update_date := NULL;

    END IF;

    IF g_PRICE_LIST_LINE_rec.request_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_LINE_rec.request_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_PRICE_LIST_LINE_rec.accrual_qty = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.accrual_uom_code = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.arithmetic_operator = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.automatic_flag = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.base_qty = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.base_uom_code = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.comments = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.context = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.created_by = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_LINE_rec.effective_period_uom = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.end_date_active = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_LINE_rec.estim_accrual_rate = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.generate_using_formula_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.inventory_item_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_LINE_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.list_header_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.list_line_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.list_line_type_code = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.list_price = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.from_rltd_modifier_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.rltd_modifier_group_no = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.product_precedence = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.modifier_level_code = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.number_effective_periods = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.operand = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.organization_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.override_flag = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.percent_price = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.price_break_type_code = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.price_by_formula_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.primary_uom_flag = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.print_on_invoice_flag = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.program_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_LINE_rec.rebate_trxn_type_code = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.related_item_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.relationship_type_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.reprice_flag = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.request_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_LINE_rec.revision = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.revision_date = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_LINE_rec.revision_reason_code = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.start_date_active = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_LINE_rec.substitution_attribute = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.substitution_context = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_LINE_rec.substitution_value = FND_API.G_MISS_CHAR
    THEN

	 oe_debug_pub.add('default attributes');

        QP_Default_Price_List_Line.Attributes
        (   p_PRICE_LIST_LINE_rec         => g_PRICE_LIST_LINE_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_PRICE_LIST_LINE_rec         => x_PRICE_LIST_LINE_rec
        );

    ELSE

        --  Done defaulting attributes

        x_PRICE_LIST_LINE_rec := g_PRICE_LIST_LINE_rec;


 oe_debug_pub.add('exiting attributes of list line');


    END IF;

    oe_debug_pub.add('after executing everything in attributes');

END Attributes;

END QP_Default_Price_List_Line;

/
