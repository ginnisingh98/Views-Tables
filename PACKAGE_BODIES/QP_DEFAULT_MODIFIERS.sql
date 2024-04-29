--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_MODIFIERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_MODIFIERS" AS
/* $Header: QPXDMLLB.pls 120.2 2005/07/07 04:29:01 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Modifiers';

--  Package global used within the package.

g_MODIFIERS_rec               QP_Modifiers_PUB.Modifiers_Rec_Type;

--  Get functions.



FUNCTION Get_Arithmetic_Operator
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Arithmetic_Operator;

FUNCTION Get_Automatic
RETURN VARCHAR2
IS
BEGIN

    RETURN 'Y';

END Get_Automatic;

/* FUNCTION Get_Base_Qty
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Base_Qty;
*/
FUNCTION Get_Pricing_Phase
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Phase;

/* FUNCTION Get_Base_Uom
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Base_Uom;
*/
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
BEGIN

    RETURN NULL;

END Get_End_Date_Active;

FUNCTION Get_Estim_Accrual_Rate
RETURN NUMBER
IS
l_estim_accrual_rate NUMBER := FND_API.G_MISS_NUM;
BEGIN

l_estim_accrual_rate := 100;

    RETURN l_estim_accrual_rate;

END Get_Estim_Accrual_Rate;

FUNCTION Get_Generate_Using_Formula
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Generate_Using_Formula;

/* FUNCTION Get_Gl_Class
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Gl_Class; */

FUNCTION Get_Inventory_Item
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Inventory_Item;

FUNCTION Get_List_Header
RETURN NUMBER
IS
-- l_list_header_id NUMBER := FND_API.G_MISS_NUM;
BEGIN

--    l_list_header_id := QP_Default_Modifier_List.Get_List_Header;
--    RETURN l_list_header_id;

    RETURN NULL;

END Get_List_Header;

FUNCTION Get_List_Line
RETURN NUMBER
IS
l_list_line_id NUMBER := FND_API.G_MISS_NUM;
BEGIN

    select QP_LIST_LINES_S.nextval
    into   l_list_line_id
    from   dual;

    RETURN l_list_line_id;

END Get_List_Line;

FUNCTION Get_List_Line_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_List_Line_Type;

FUNCTION Get_List_Price
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_List_Price;

/* FUNCTION Get_List_Price_Uom
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_List_Price_Uom;  */

FUNCTION Get_Modifier_Level
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Modifier_Level;

/* FUNCTION Get_New_Price
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_New_Price; */

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

    RETURN 'N';

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
BEGIN

    RETURN NULL;

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

    RETURN 'Y';

END Get_Print_On_Invoice;

/* FUNCTION Get_Rebate_Subtype
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Rebate_Subtype; */

FUNCTION Get_Rebate_Transaction_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Rebate_Transaction_Type;

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

    RETURN NULL;

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
BEGIN

    RETURN NULL;

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

FUNCTION Get_Product_Precedence
RETURN NUMBER
IS
BEGIN

       RETURN NULL;

END Get_Product_Precedence;

FUNCTION Get_Exp_Period_Start_Date
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_Exp_Period_Start_Date;

FUNCTION Get_Number_Expiration_Periods
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Number_Expiration_Periods;

FUNCTION Get_Expiration_Period_Uom
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Expiration_Period_Uom;

FUNCTION Get_Expiration_Date
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_Expiration_Date;

FUNCTION Get_Estim_Gl_Value
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Estim_Gl_Value;

FUNCTION Get_Ben_Price_List_Line
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Ben_Price_List_Line;

/* FUNCTION Get_Recurring
RETURN VARCHAR2
IS
BEGIN

    RETURN 'N';

END Get_Recurring;
*/
FUNCTION Get_Benefit_Limit
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Benefit_Limit;

FUNCTION Get_Charge_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Charge_Type;

FUNCTION Get_Charge_Subtype
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Charge_Subtype;

FUNCTION Get_Benefit_Qty
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Benefit_Qty;

FUNCTION Get_Benefit_Uom
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Benefit_Uom;

FUNCTION Get_Accrual_Conversion_Rate
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Accrual_Conversion_Rate;

FUNCTION Get_Include_On_Returns_Flag
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Include_On_Returns_Flag;

FUNCTION Get_Proration_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN 'N';

END Get_Proration_Type;

FUNCTION Get_From_Rltd_Modifier
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_From_Rltd_Modifier;

FUNCTION Get_To_Rltd_Modifier
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_To_Rltd_Modifier;

FUNCTION Get_Rltd_Modifier_Grp_No
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Rltd_Modifier_Grp_No;

FUNCTION Get_Rltd_Modifier_Grp_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Rltd_Modifier_Grp_Type;

FUNCTION Get_Accrual
RETURN VARCHAR2
IS
BEGIN

    RETURN 'N';

END Get_Accrual;

FUNCTION Get_Pricing_Group_Sequence( p_automatic_flag VARCHAR2)
RETURN NUMBER
IS
l_qp_status                   VARCHAR2(1);
BEGIN
 l_qp_status := QP_UTIL.GET_QP_STATUS;

 IF l_qp_status in ('N','S') and p_automatic_flag ='Y' THEN
    RETURN '1';
 END IF;

    RETURN NULL;
END Get_Pricing_Group_Sequence;

FUNCTION Get_Incompatibility_Grp( p_automatic_flag VARCHAR2)
RETURN VARCHAR2
IS
l_qp_status                   VARCHAR2(1);
BEGIN
 l_qp_status := QP_UTIL.GET_QP_STATUS;

 IF l_qp_status in ('N','S') and p_automatic_flag ='Y' THEN
    RETURN 'LVL 1';
 END IF;

    RETURN NULL;

END Get_Incompatibility_Grp;

FUNCTION Get_List_Line_No
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_List_Line_No;

FUNCTION get_qualification_ind
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_qualification_ind;

FUNCTION Get_accum_attribute
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_accum_attribute;


FUNCTION Get_Net_Amount
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Net_Amount;

PROCEDURE Get_Flex_Modifiers
IS
BEGIN

oe_debug_pub.add('BEGIN Get_Flex_Modifiers in QPXDMLLB');

    --  In the future call Flex APIs for defaults

    IF g_MODIFIERS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_MODIFIERS_rec.attribute1     := NULL;
    END IF;

    IF g_MODIFIERS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_MODIFIERS_rec.attribute10    := NULL;
    END IF;

    IF g_MODIFIERS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_MODIFIERS_rec.attribute11    := NULL;
    END IF;

    IF g_MODIFIERS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_MODIFIERS_rec.attribute12    := NULL;
    END IF;

    IF g_MODIFIERS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_MODIFIERS_rec.attribute13    := NULL;
    END IF;

    IF g_MODIFIERS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_MODIFIERS_rec.attribute14    := NULL;
    END IF;

    IF g_MODIFIERS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_MODIFIERS_rec.attribute15    := NULL;
    END IF;

    IF g_MODIFIERS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_MODIFIERS_rec.attribute2     := NULL;
    END IF;

    IF g_MODIFIERS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_MODIFIERS_rec.attribute3     := NULL;
    END IF;

    IF g_MODIFIERS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_MODIFIERS_rec.attribute4     := NULL;
    END IF;

    IF g_MODIFIERS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_MODIFIERS_rec.attribute5     := NULL;
    END IF;

    IF g_MODIFIERS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_MODIFIERS_rec.attribute6     := NULL;
    END IF;

    IF g_MODIFIERS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_MODIFIERS_rec.attribute7     := NULL;
    END IF;

    IF g_MODIFIERS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_MODIFIERS_rec.attribute8     := NULL;
    END IF;

    IF g_MODIFIERS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_MODIFIERS_rec.attribute9     := NULL;
    END IF;

    IF g_MODIFIERS_rec.context = FND_API.G_MISS_CHAR THEN
        g_MODIFIERS_rec.context        := NULL;
    END IF;

oe_debug_pub.add('END Get_Flex_Modifiers in QPXDMLLB');

END Get_Flex_Modifiers;

--  Procedure Attributes

PROCEDURE Attributes
(   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIERS_REC
,   p_iteration                     IN  NUMBER := 1
,   x_MODIFIERS_rec                 OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifiers_Rec_Type
)
IS
l_MODIFIERS_rec		QP_Modifiers_PUB.Modifiers_Rec_Type; --[prarasto]
BEGIN


oe_debug_pub.add('BEGIN Attributes in QPXDMLLB');

    --  Check number of iterations.

    IF p_iteration > QP_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_DEF_MAX_ITERATION');
            OE_MSG_PUB.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Initialize g_MODIFIERS_rec

    g_MODIFIERS_rec := p_MODIFIERS_rec;

    --  Default missing attributes.

    IF g_MODIFIERS_rec.arithmetic_operator = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.arithmetic_operator := Get_Arithmetic_Operator;

        IF g_MODIFIERS_rec.arithmetic_operator IS NOT NULL THEN

            IF QP_Validate.Arithmetic_Operator(g_MODIFIERS_rec.arithmetic_operator)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_ARITHMETIC_OPERATOR
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.arithmetic_operator := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.automatic_flag = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.automatic_flag := Get_Automatic;

        IF g_MODIFIERS_rec.automatic_flag IS NOT NULL THEN

            IF QP_Validate.Automatic(g_MODIFIERS_rec.automatic_flag)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_AUTOMATIC
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.automatic_flag := NULL;
            END IF;

        END IF;

    END IF;

/*    IF g_MODIFIERS_rec.base_qty = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.base_qty := Get_Base_Qty;

        IF g_MODIFIERS_rec.base_qty IS NOT NULL THEN

            IF QP_Validate.Base_Qty(g_MODIFIERS_rec.base_qty)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_BASE_QTY
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.base_qty := NULL;
            END IF;

        END IF;

    END IF;
*/
    IF g_MODIFIERS_rec.pricing_phase_id = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.pricing_phase_id := Get_Pricing_Phase;

        IF g_MODIFIERS_rec.pricing_phase_id IS NOT NULL THEN

            IF QP_Validate.Pricing_Phase(g_MODIFIERS_rec.pricing_phase_id)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_PRICING_PHASE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.pricing_phase_id := NULL;
            END IF;

        END IF;

    END IF;

/*    IF g_MODIFIERS_rec.base_uom_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.base_uom_code := Get_Base_Uom;

        IF g_MODIFIERS_rec.base_uom_code IS NOT NULL THEN

            IF QP_Validate.Base_Uom(g_MODIFIERS_rec.base_uom_code)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_BASE_UOM
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.base_uom_code := NULL;
            END IF;

        END IF;

    END IF;
*/
    IF g_MODIFIERS_rec.comments = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.comments := Get_Comments;

        IF g_MODIFIERS_rec.comments IS NOT NULL THEN

            IF QP_Validate.Comments(g_MODIFIERS_rec.comments)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_COMMENTS
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.comments := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.effective_period_uom = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.effective_period_uom := Get_Effective_Period_Uom;

        IF g_MODIFIERS_rec.effective_period_uom IS NOT NULL THEN

            IF QP_Validate.Effective_Period_Uom(g_MODIFIERS_rec.effective_period_uom)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_EFFECTIVE_PERIOD_UOM
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.effective_period_uom := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.end_date_active = FND_API.G_MISS_DATE THEN

        g_MODIFIERS_rec.end_date_active := Get_End_Date_Active;

        IF g_MODIFIERS_rec.end_date_active IS NOT NULL THEN

            IF QP_Validate.End_Date_Active(g_MODIFIERS_rec.end_date_active)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_END_DATE_ACTIVE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.end_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.estim_accrual_rate = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.estim_accrual_rate := Get_Estim_Accrual_Rate;

        IF g_MODIFIERS_rec.estim_accrual_rate IS NOT NULL THEN

            IF QP_Validate.Estim_Accrual_Rate(g_MODIFIERS_rec.estim_accrual_rate)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_ESTIM_ACCRUAL_RATE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.estim_accrual_rate := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.generate_using_formula_id = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.generate_using_formula_id := Get_Generate_Using_Formula;

        IF g_MODIFIERS_rec.generate_using_formula_id IS NOT NULL THEN

            IF QP_Validate.Generate_Using_Formula(g_MODIFIERS_rec.generate_using_formula_id)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_GENERATE_USING_FORMULA
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.generate_using_formula_id := NULL;
            END IF;

        END IF;

    END IF;

/*    IF g_MODIFIERS_rec.gl_class_id = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.gl_class_id := Get_Gl_Class;

        IF g_MODIFIERS_rec.gl_class_id IS NOT NULL THEN

            IF QP_Validate.Gl_Class(g_MODIFIERS_rec.gl_class_id)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_GL_CLASS
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.gl_class_id := NULL;
            END IF;

        END IF;

    END IF;
*/
    IF g_MODIFIERS_rec.inventory_item_id = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.inventory_item_id := Get_Inventory_Item;

        IF g_MODIFIERS_rec.inventory_item_id IS NOT NULL THEN

            IF QP_Validate.Inventory_Item(g_MODIFIERS_rec.inventory_item_id)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_INVENTORY_ITEM
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.inventory_item_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.list_header_id = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.list_header_id := Get_List_Header;

        IF g_MODIFIERS_rec.list_header_id IS NOT NULL THEN

            IF QP_Validate.List_Header(g_MODIFIERS_rec.list_header_id)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_LIST_HEADER
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.list_header_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.list_line_id = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.list_line_id := Get_List_Line;

        IF g_MODIFIERS_rec.list_line_id IS NOT NULL THEN

            IF QP_Validate.List_Line(g_MODIFIERS_rec.list_line_id)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_LIST_LINE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.list_line_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.list_line_type_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.list_line_type_code := Get_List_Line_Type;

        IF g_MODIFIERS_rec.list_line_type_code IS NOT NULL THEN

            IF QP_Validate.List_Line_Type(g_MODIFIERS_rec.list_line_type_code)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_LIST_LINE_TYPE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.list_line_type_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.list_price = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.list_price := Get_List_Price;

        IF g_MODIFIERS_rec.list_price IS NOT NULL THEN

            IF QP_Validate.List_Price(g_MODIFIERS_rec.list_price)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_LIST_PRICE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.list_price := NULL;
            END IF;

        END IF;

    END IF;

/*    IF g_MODIFIERS_rec.list_price_uom_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.list_price_uom_code := Get_List_Price_Uom;

        IF g_MODIFIERS_rec.list_price_uom_code IS NOT NULL THEN

            IF QP_Validate.List_Price_Uom(g_MODIFIERS_rec.list_price_uom_code)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_LIST_PRICE_UOM
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.list_price_uom_code := NULL;
            END IF;

        END IF;

    END IF;
*/
    IF g_MODIFIERS_rec.modifier_level_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.modifier_level_code := Get_Modifier_Level;

        IF g_MODIFIERS_rec.modifier_level_code IS NOT NULL THEN

            IF QP_Validate.Modifier_Level(g_MODIFIERS_rec.modifier_level_code)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_MODIFIER_LEVEL
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.modifier_level_code := NULL;
            END IF;

        END IF;

    END IF;

/*    IF g_MODIFIERS_rec.new_price = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.new_price := Get_New_Price;

        IF g_MODIFIERS_rec.new_price IS NOT NULL THEN

            IF QP_Validate.New_Price(g_MODIFIERS_rec.new_price)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_NEW_PRICE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.new_price := NULL;
            END IF;

        END IF;

    END IF;
*/
    IF g_MODIFIERS_rec.number_effective_periods = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.number_effective_periods := Get_Number_Effective_Periods;

        IF g_MODIFIERS_rec.number_effective_periods IS NOT NULL THEN

            IF QP_Validate.Number_Effective_Periods(g_MODIFIERS_rec.number_effective_periods)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_NUMBER_EFFECTIVE_PERIODS
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.number_effective_periods := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.operand = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.operand := Get_Operand;

        IF g_MODIFIERS_rec.operand IS NOT NULL THEN

            IF QP_Validate.Operand(g_MODIFIERS_rec.operand)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_OPERAND
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.operand := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.organization_id = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.organization_id := Get_Organization;

        IF g_MODIFIERS_rec.organization_id IS NOT NULL THEN

            IF QP_Validate.Organization(g_MODIFIERS_rec.organization_id)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_ORGANIZATION
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.organization_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.override_flag = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.override_flag := Get_Override;

        IF g_MODIFIERS_rec.override_flag IS NOT NULL THEN

            IF QP_Validate.Override(g_MODIFIERS_rec.override_flag)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_OVERRIDE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.override_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.percent_price = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.percent_price := Get_Percent_Price;

        IF g_MODIFIERS_rec.percent_price IS NOT NULL THEN

            IF QP_Validate.Percent_Price(g_MODIFIERS_rec.percent_price)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_PERCENT_PRICE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.percent_price := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.price_break_type_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.price_break_type_code := Get_Price_Break_Type;

        IF g_MODIFIERS_rec.price_break_type_code IS NOT NULL THEN

            IF QP_Validate.Price_Break_Type(g_MODIFIERS_rec.price_break_type_code)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_PRICE_BREAK_TYPE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.price_break_type_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.price_by_formula_id = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.price_by_formula_id := Get_Price_By_Formula;

        IF g_MODIFIERS_rec.price_by_formula_id IS NOT NULL THEN

            IF QP_Validate.Price_By_Formula(g_MODIFIERS_rec.price_by_formula_id)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_PRICE_BY_FORMULA
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.price_by_formula_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.primary_uom_flag = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.primary_uom_flag := Get_Primary_Uom;

        IF g_MODIFIERS_rec.primary_uom_flag IS NOT NULL THEN

            IF QP_Validate.Primary_Uom(g_MODIFIERS_rec.primary_uom_flag)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_PRIMARY_UOM
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.primary_uom_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.print_on_invoice_flag = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.print_on_invoice_flag := Get_Print_On_Invoice;

        IF g_MODIFIERS_rec.print_on_invoice_flag IS NOT NULL THEN

            IF QP_Validate.Print_On_Invoice(g_MODIFIERS_rec.print_on_invoice_flag)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_PRINT_ON_INVOICE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.print_on_invoice_flag := NULL;
            END IF;

        END IF;

    END IF;

/*    IF g_MODIFIERS_rec.rebate_subtype_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.rebate_subtype_code := Get_Rebate_Subtype;

        IF g_MODIFIERS_rec.rebate_subtype_code IS NOT NULL THEN

            IF QP_Validate.Rebate_Subtype(g_MODIFIERS_rec.rebate_subtype_code)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_REBATE_SUBTYPE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.rebate_subtype_code := NULL;
            END IF;

        END IF;

    END IF;
*/
    IF g_MODIFIERS_rec.rebate_trxn_type_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.rebate_trxn_type_code := Get_Rebate_Transaction_Type;

        IF g_MODIFIERS_rec.rebate_trxn_type_code IS NOT NULL THEN

            IF QP_Validate.Rebate_Transaction_Type(g_MODIFIERS_rec.rebate_trxn_type_code)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_REBATE_TRANSACTION_TYPE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.rebate_trxn_type_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.related_item_id = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.related_item_id := Get_Related_Item;

        IF g_MODIFIERS_rec.related_item_id IS NOT NULL THEN

            IF QP_Validate.Related_Item(g_MODIFIERS_rec.related_item_id)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_RELATED_ITEM
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.related_item_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.relationship_type_id = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.relationship_type_id := Get_Relationship_Type;

        IF g_MODIFIERS_rec.relationship_type_id IS NOT NULL THEN

            IF QP_Validate.Relationship_Type(g_MODIFIERS_rec.relationship_type_id)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_RELATIONSHIP_TYPE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.relationship_type_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.reprice_flag = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.reprice_flag := Get_Reprice;

        IF g_MODIFIERS_rec.reprice_flag IS NOT NULL THEN

            IF QP_Validate.Reprice(g_MODIFIERS_rec.reprice_flag)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_REPRICE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.reprice_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.revision = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.revision := Get_Revision;

        IF g_MODIFIERS_rec.revision IS NOT NULL THEN

            IF QP_Validate.Revision(g_MODIFIERS_rec.revision)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_REVISION
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.revision := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.revision_date = FND_API.G_MISS_DATE THEN

        g_MODIFIERS_rec.revision_date := Get_Revision_Date;

        IF g_MODIFIERS_rec.revision_date IS NOT NULL THEN

            IF QP_Validate.Revision_Date(g_MODIFIERS_rec.revision_date)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_REVISION_DATE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.revision_date := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.revision_reason_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.revision_reason_code := Get_Revision_Reason;

        IF g_MODIFIERS_rec.revision_reason_code IS NOT NULL THEN

            IF QP_Validate.Revision_Reason(g_MODIFIERS_rec.revision_reason_code)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_REVISION_REASON
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.revision_reason_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.start_date_active = FND_API.G_MISS_DATE THEN

        g_MODIFIERS_rec.start_date_active := Get_Start_Date_Active;

        IF g_MODIFIERS_rec.start_date_active IS NOT NULL THEN

            IF QP_Validate.Start_Date_Active(g_MODIFIERS_rec.start_date_active)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_START_DATE_ACTIVE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.start_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.substitution_attribute = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.substitution_attribute := Get_Substitution_Attribute;

        IF g_MODIFIERS_rec.substitution_attribute IS NOT NULL THEN

            IF QP_Validate.Substitution_Attribute(g_MODIFIERS_rec.substitution_attribute)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_SUBSTITUTION_ATTRIBUTE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.substitution_attribute := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.substitution_context = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.substitution_context := Get_Substitution_Context;

        IF g_MODIFIERS_rec.substitution_context IS NOT NULL THEN

            IF QP_Validate.Substitution_Context(g_MODIFIERS_rec.substitution_context)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_SUBSTITUTION_CONTEXT
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.substitution_context := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.substitution_value = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.substitution_value := Get_Substitution_Value;

        IF g_MODIFIERS_rec.substitution_value IS NOT NULL THEN

            IF QP_Validate.Substitution_Value(g_MODIFIERS_rec.substitution_value)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_SUBSTITUTION_VALUE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.substitution_value := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.product_precedence = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.product_precedence := Get_Product_Precedence;

        IF g_MODIFIERS_rec.product_precedence IS NOT NULL THEN

            IF QP_Validate.Product_Precedence(g_MODIFIERS_rec.product_precedence)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_PRODUCT_PRECEDENCE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.product_precedence := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.expiration_period_start_date = FND_API.G_MISS_DATE THEN

        g_MODIFIERS_rec.expiration_period_start_date := Get_Exp_Period_Start_Date;

        IF g_MODIFIERS_rec.expiration_period_start_date IS NOT NULL THEN

            IF QP_Validate.Exp_Period_Start_Date(g_MODIFIERS_rec.expiration_period_start_date)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_EXPIRATION_PERIOD_START_DATE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.expiration_period_start_date := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.number_expiration_periods = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.number_expiration_periods := Get_Number_Expiration_Periods;

        IF g_MODIFIERS_rec.number_expiration_periods IS NOT NULL THEN

            IF QP_Validate.Number_Expiration_Periods(g_MODIFIERS_rec.number_expiration_periods)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_NUMBER_EXPIRATION_PERIODS
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.number_expiration_periods := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.expiration_period_uom = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.expiration_period_uom := Get_Expiration_Period_Uom;

        IF g_MODIFIERS_rec.expiration_period_uom IS NOT NULL THEN

            IF QP_Validate.Expiration_Period_Uom(g_MODIFIERS_rec.expiration_period_uom)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_EXPIRATION_PERIOD_UOM
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.expiration_period_uom := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.expiration_date = FND_API.G_MISS_DATE THEN

        g_MODIFIERS_rec.expiration_date := Get_Expiration_Date;

        IF g_MODIFIERS_rec.expiration_date IS NOT NULL THEN

            IF QP_Validate.Expiration_Date(g_MODIFIERS_rec.expiration_date)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_EXPIRATION_DATE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.expiration_date := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.estim_gl_value = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.estim_gl_value := Get_Estim_Gl_Value;

        IF g_MODIFIERS_rec.estim_gl_value IS NOT NULL THEN

            IF QP_Validate.Estim_Gl_Value(g_MODIFIERS_rec.estim_gl_value)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_ESTIM_GL_VALUE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.estim_gl_value := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.benefit_price_list_line_id = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.benefit_price_list_line_id := Get_Ben_Price_List_Line;

        IF g_MODIFIERS_rec.benefit_price_list_line_id IS NOT NULL THEN

            IF QP_Validate.Ben_Price_List_Line(g_MODIFIERS_rec.benefit_price_list_line_id)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_BENEFIT_PRICE_LIST_LINE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.benefit_price_list_line_id := NULL;
            END IF;

        END IF;

    END IF;

/*    IF g_MODIFIERS_rec.recurring_flag = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.recurring_flag := Get_Recurring;

        IF g_MODIFIERS_rec.recurring_flag IS NOT NULL THEN

            IF QP_Validate.Recurring(g_MODIFIERS_rec.recurring_flag)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_RECURRING_FLAG
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.recurring_flag := NULL;
            END IF;

        END IF;

    END IF;
*/
    IF g_MODIFIERS_rec.benefit_limit = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.benefit_limit := Get_Benefit_Limit;

        IF g_MODIFIERS_rec.benefit_limit IS NOT NULL THEN

            IF QP_Validate.Benefit_Limit(g_MODIFIERS_rec.benefit_limit)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_BENEFIT_LIMIT
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.benefit_limit := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.charge_type_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.charge_type_code := Get_Charge_Type;

        IF g_MODIFIERS_rec.charge_type_code IS NOT NULL THEN

            IF QP_Validate.Charge_Type(g_MODIFIERS_rec.charge_type_code)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_CHARGE_TYPE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.charge_type_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.charge_subtype_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.charge_subtype_code := Get_Charge_Subtype;

        IF g_MODIFIERS_rec.charge_subtype_code IS NOT NULL THEN

            IF QP_Validate.Charge_Subtype(g_MODIFIERS_rec.charge_subtype_code)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_CHARGE_SUBTYPE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.charge_subtype_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.benefit_qty = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.benefit_qty := Get_Benefit_Qty;

        IF g_MODIFIERS_rec.benefit_qty IS NOT NULL THEN

            IF QP_Validate.Benefit_Qty(g_MODIFIERS_rec.benefit_qty)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_BENEFIT_QTY
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.benefit_qty := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.benefit_uom_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.benefit_uom_code := Get_Benefit_Uom;

        IF g_MODIFIERS_rec.benefit_uom_code IS NOT NULL THEN

            IF QP_Validate.Benefit_Uom(g_MODIFIERS_rec.benefit_uom_code)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_BENEFIT_UOM
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.benefit_uom_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.accrual_conversion_rate = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.accrual_conversion_rate := Get_Accrual_Conversion_Rate;

        IF g_MODIFIERS_rec.accrual_conversion_rate IS NOT NULL THEN

            IF QP_Validate.Accrual_Conversion_Rate(g_MODIFIERS_rec.accrual_conversion_rate)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_ACCRUAL_CONVERSION_RATE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.accrual_conversion_rate := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.include_on_returns_flag = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.include_on_returns_flag := Get_Include_On_Returns_Flag;

        IF g_MODIFIERS_rec.include_on_returns_flag IS NOT NULL THEN

            IF QP_Validate.Include_On_Returns_Flag(g_MODIFIERS_rec.include_on_returns_flag)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_INCLUDE_ON_RETURNS_FLAG
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.include_on_returns_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.proration_type_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.proration_type_code := Get_Proration_Type;

        IF g_MODIFIERS_rec.proration_type_code IS NOT NULL THEN

            IF QP_Validate.Proration_Type(g_MODIFIERS_rec.proration_type_code)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_PRORATION_TYPE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.proration_type_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.from_rltd_modifier_id = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.from_rltd_modifier_id := Get_From_Rltd_Modifier;

        IF g_MODIFIERS_rec.from_rltd_modifier_id IS NOT NULL THEN

            IF QP_Validate.From_Rltd_Modifier(g_MODIFIERS_rec.from_rltd_modifier_id)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_FROM_RLTD_MODIFIER
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.from_rltd_modifier_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.to_rltd_modifier_id = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.to_rltd_modifier_id := Get_To_Rltd_Modifier;

        IF g_MODIFIERS_rec.to_rltd_modifier_id IS NOT NULL THEN

            IF QP_Validate.To_Rltd_Modifier(g_MODIFIERS_rec.to_rltd_modifier_id)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_TO_RLTD_MODIFIER
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.to_rltd_modifier_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.rltd_modifier_grp_no = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.rltd_modifier_grp_no := Get_Rltd_Modifier_Grp_No;

        IF g_MODIFIERS_rec.rltd_modifier_grp_no IS NOT NULL THEN

            IF QP_Validate.Rltd_Modifier_Grp_No(g_MODIFIERS_rec.rltd_modifier_grp_no)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_RLTD_MODIFIER_GRP_NO
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.rltd_modifier_grp_no := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.rltd_modifier_grp_type = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.rltd_modifier_grp_type := Get_Rltd_Modifier_Grp_Type;

        IF g_MODIFIERS_rec.rltd_modifier_grp_type IS NOT NULL THEN

            IF QP_Validate.Rltd_Modifier_Grp_Type(g_MODIFIERS_rec.rltd_modifier_grp_type)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_RLTD_MODIFIER_GRP_TYPE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.rltd_modifier_grp_type := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.accrual_flag = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.accrual_flag := Get_Accrual;

        IF g_MODIFIERS_rec.accrual_flag IS NOT NULL THEN

            IF QP_Validate.Accrual_Flag(g_MODIFIERS_rec.accrual_flag)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_ACCRUAL_FLAG
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.accrual_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.pricing_group_sequence = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.pricing_group_sequence :=
Get_Pricing_Group_Sequence(g_MODIFIERS_rec.automatic_flag);

        IF g_MODIFIERS_rec.pricing_group_sequence IS NOT NULL THEN

            IF QP_Validate.Pricing_Group_Sequence(g_MODIFIERS_rec.pricing_group_sequence)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_PRICING_GROUP_SEQUENCE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.pricing_group_sequence := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.incompatibility_grp_code = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.incompatibility_grp_code :=
Get_Incompatibility_Grp(g_MODIFIERS_rec.automatic_flag);

        IF g_MODIFIERS_rec.incompatibility_grp_code IS NOT NULL THEN

            IF QP_Validate.Incompatibility_Grp_Code(g_MODIFIERS_rec.incompatibility_grp_code)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_INCOMPATIBILITY_GRP_CODE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.incompatibility_grp_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.list_line_no = FND_API.G_MISS_CHAR THEN
-- changes for making the modifier no unique for logistics requirement
-- defaulting the list_line_id for list_line_no
        g_MODIFIERS_rec.list_line_no := g_MODIFIERS_rec.list_line_id;

        IF g_MODIFIERS_rec.list_line_no IS NOT NULL THEN

            IF QP_Validate.List_Line_No(g_MODIFIERS_rec.list_line_no)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_LIST_LINE_NO
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.list_line_no := NULL;
            END IF;

        END IF;

    END IF;

    IF g_MODIFIERS_rec.qualification_ind = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.qualification_ind := Get_qualification_ind;

	oe_debug_pub.add('get_qualification_ind');

    END IF;

    /*
    IF g_MODIFIERS_rec.qualification_ind = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.qualification_ind := Get_qualification_ind;

        IF g_MODIFIERS_rec.qualification_ind IS NOT NULL THEN

            IF QP_Validate.qualification_ind(g_MODIFIERS_rec.qualification_ind)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_QUALIFICATION_IND
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.qualification_ind := NULL;
            END IF;

        END IF;

    END IF;
    */

   IF g_MODIFIERS_rec.accum_attribute = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.accum_attribute := Get_Accum_Attribute;

        IF g_MODIFIERS_rec.accum_attribute IS NOT NULL THEN

            IF QP_Validate.Accum_Attribute(g_MODIFIERS_rec.accum_attribute)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_ACCUM_ATTRIBUTE
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.accum_attribute := NULL;
            END IF;

        END IF;

    END IF;

IF g_MODIFIERS_rec.net_amount_flag = FND_API.G_MISS_CHAR THEN

        g_MODIFIERS_rec.net_amount_flag := Get_Net_Amount;

        IF g_MODIFIERS_rec.net_amount_flag IS NOT NULL THEN

            IF QP_Validate.Net_Amount(g_MODIFIERS_rec.net_amount_flag)
            THEN

	        l_MODIFIERS_rec := g_MODIFIERS_rec; --[prarasto]

                QP_Modifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Modifiers_Util.G_NET_AMOUNT
                ,   p_MODIFIERS_rec               => l_MODIFIERS_rec
                ,   x_MODIFIERS_rec               => g_MODIFIERS_rec
                );
            ELSE
                g_MODIFIERS_rec.net_amount_flag := NULL;
            END IF;

        END IF;

    END IF;



    IF g_MODIFIERS_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Modifiers;

    END IF;

    IF g_MODIFIERS_rec.created_by = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.created_by := NULL;

    END IF;

    IF g_MODIFIERS_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_MODIFIERS_rec.creation_date := NULL;

    END IF;

    IF g_MODIFIERS_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.last_updated_by := NULL;

    END IF;

    IF g_MODIFIERS_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_MODIFIERS_rec.last_update_date := NULL;

    END IF;

    IF g_MODIFIERS_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.last_update_login := NULL;

    END IF;

    IF g_MODIFIERS_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.program_application_id := NULL;

    END IF;

    IF g_MODIFIERS_rec.program_id = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.program_id := NULL;

    END IF;

    IF g_MODIFIERS_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_MODIFIERS_rec.program_update_date := NULL;

    END IF;

    IF g_MODIFIERS_rec.request_id = FND_API.G_MISS_NUM THEN

        g_MODIFIERS_rec.request_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_MODIFIERS_rec.arithmetic_operator = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.automatic_flag = FND_API.G_MISS_CHAR
--    OR  g_MODIFIERS_rec.base_qty = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.pricing_phase_id = FND_API.G_MISS_NUM
--    OR  g_MODIFIERS_rec.base_uom_code = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.comments = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.context = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.created_by = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_MODIFIERS_rec.effective_period_uom = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.end_date_active = FND_API.G_MISS_DATE
    OR  g_MODIFIERS_rec.estim_accrual_rate = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.generate_using_formula_id = FND_API.G_MISS_NUM
--    OR  g_MODIFIERS_rec.gl_class_id = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.inventory_item_id = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_MODIFIERS_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.list_header_id = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.list_line_id = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.list_line_type_code = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.list_price = FND_API.G_MISS_NUM
--    OR  g_MODIFIERS_rec.list_price_uom_code = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.modifier_level_code = FND_API.G_MISS_CHAR
--    OR  g_MODIFIERS_rec.new_price = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.number_effective_periods = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.operand = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.organization_id = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.override_flag = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.percent_price = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.price_break_type_code = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.price_by_formula_id = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.primary_uom_flag = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.print_on_invoice_flag = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.program_id = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.program_update_date = FND_API.G_MISS_DATE
--    OR  g_MODIFIERS_rec.rebate_subtype_code = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.rebate_trxn_type_code = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.related_item_id = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.relationship_type_id = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.reprice_flag = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.request_id = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.revision = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.revision_date = FND_API.G_MISS_DATE
    OR  g_MODIFIERS_rec.revision_reason_code = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.start_date_active = FND_API.G_MISS_DATE
    OR  g_MODIFIERS_rec.substitution_attribute = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.substitution_context = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.substitution_value = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.product_precedence = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.expiration_period_start_date = FND_API.G_MISS_DATE
    OR  g_MODIFIERS_rec.number_expiration_periods = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.expiration_period_uom = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.expiration_date = FND_API.G_MISS_DATE
    OR  g_MODIFIERS_rec.estim_gl_value = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.benefit_price_list_line_id = FND_API.G_MISS_NUM
--    OR  g_MODIFIERS_rec.recurring_flag = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.benefit_limit = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.charge_type_code = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.charge_subtype_code = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.benefit_qty = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.benefit_uom_code = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.accrual_conversion_rate = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.include_on_returns_flag = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.proration_type_code = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.accrual_flag = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.pricing_group_sequence = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.incompatibility_grp_code = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.list_line_no = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.from_rltd_modifier_id = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.to_rltd_modifier_id = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.rltd_modifier_grp_no = FND_API.G_MISS_NUM
    OR  g_MODIFIERS_rec.rltd_modifier_grp_type = FND_API.G_MISS_CHAR
    OR  g_MODIFIERS_rec.net_amount_flag = FND_API.G_MISS_CHAR
    THEN

        QP_Default_Modifiers.Attributes
        (   p_MODIFIERS_rec               => g_MODIFIERS_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_MODIFIERS_rec               => x_MODIFIERS_rec
        );

    ELSE

        --  Done defaulting attributes

        x_MODIFIERS_rec := g_MODIFIERS_rec;

    END IF;

oe_debug_pub.add('END Attributes in QPXDMLLB');

END Attributes;

END QP_Default_Modifiers;

/
