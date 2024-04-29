--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_FORMULA_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_FORMULA_LINES" AS
/* $Header: QPXDPFLB.pls 120.2 2005/07/06 01:57:42 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Formula_Lines';

--  Package global used within the package.

g_FORMULA_LINES_rec           QP_Price_Formula_PUB.Formula_Lines_Rec_Type;

--  Get functions.

FUNCTION Get_End_Date_Active
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_End_Date_Active;

FUNCTION Get_Numeric_Constant
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Numeric_Constant;

FUNCTION Get_Reqd_Flag
RETURN VARCHAR2
IS
BEGIN

    RETURN 'N';

END Get_Reqd_Flag;

FUNCTION Get_Price_Formula
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Price_Formula;

FUNCTION Get_Price_Formula_Line
RETURN NUMBER
IS
l_price_formula_line_id NUMBER := NULL;
BEGIN

oe_debug_pub.add('Entering Get_Price_Formula_line in FormulaLines Default Pkg');
    SELECT QP_PRICE_FORMULA_LINES_S.nextval
    INTO   l_price_formula_line_id
    FROM   dual;

oe_debug_pub.add('Leaving Get_Price_Formula_line in FormulaLines Default Pkg');
    RETURN l_price_formula_line_id;

END Get_Price_Formula_Line;

FUNCTION Get_Price_Formula_Line_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Price_Formula_Line_Type;

FUNCTION Get_Price_List_Line
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Price_List_Line;

FUNCTION Get_Price_Modifier_List
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Price_Modifier_List;

FUNCTION Get_Pricing_Attribute
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute;

FUNCTION Get_Pricing_Attribute_Context
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute_Context;

FUNCTION Get_Start_Date_Active
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_Start_Date_Active;

FUNCTION Get_Step_Number
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Step_Number;

PROCEDURE Get_Flex_Formula_Lines
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_FORMULA_LINES_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_LINES_rec.attribute1 := NULL;
    END IF;

    IF g_FORMULA_LINES_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_LINES_rec.attribute10 := NULL;
    END IF;

    IF g_FORMULA_LINES_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_LINES_rec.attribute11 := NULL;
    END IF;

    IF g_FORMULA_LINES_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_LINES_rec.attribute12 := NULL;
    END IF;

    IF g_FORMULA_LINES_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_LINES_rec.attribute13 := NULL;
    END IF;

    IF g_FORMULA_LINES_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_LINES_rec.attribute14 := NULL;
    END IF;

    IF g_FORMULA_LINES_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_LINES_rec.attribute15 := NULL;
    END IF;

    IF g_FORMULA_LINES_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_LINES_rec.attribute2 := NULL;
    END IF;

    IF g_FORMULA_LINES_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_LINES_rec.attribute3 := NULL;
    END IF;

    IF g_FORMULA_LINES_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_LINES_rec.attribute4 := NULL;
    END IF;

    IF g_FORMULA_LINES_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_LINES_rec.attribute5 := NULL;
    END IF;

    IF g_FORMULA_LINES_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_LINES_rec.attribute6 := NULL;
    END IF;

    IF g_FORMULA_LINES_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_LINES_rec.attribute7 := NULL;
    END IF;

    IF g_FORMULA_LINES_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_LINES_rec.attribute8 := NULL;
    END IF;

    IF g_FORMULA_LINES_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_FORMULA_LINES_rec.attribute9 := NULL;
    END IF;

    IF g_FORMULA_LINES_rec.context = FND_API.G_MISS_CHAR THEN
        g_FORMULA_LINES_rec.context    := NULL;
    END IF;

END Get_Flex_Formula_Lines;

--  Procedure Attributes

PROCEDURE Attributes
(   p_FORMULA_LINES_rec             IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_LINES_REC
,   p_iteration                     IN  NUMBER := 1
,   x_FORMULA_LINES_rec             OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Lines_Rec_Type
)
IS
l_FORMULA_LINES_rec		QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
BEGIN
    --  Check number of iterations.

    IF p_iteration > QP_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_DEF_MAX_ITERATION');
            OE_MSG_PUB.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Initialize g_FORMULA_LINES_rec

    g_FORMULA_LINES_rec := p_FORMULA_LINES_rec;

    --  Default missing attributes.

    IF g_FORMULA_LINES_rec.end_date_active = FND_API.G_MISS_DATE THEN

        g_FORMULA_LINES_rec.end_date_active := Get_End_Date_Active;

        IF g_FORMULA_LINES_rec.end_date_active IS NOT NULL THEN

            IF QP_Validate.End_Date_Active(g_FORMULA_LINES_rec.end_date_active)
            THEN

	        l_FORMULA_LINES_rec := g_FORMULA_LINES_rec;

                QP_Formula_Lines_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Formula_Lines_Util.G_END_DATE_ACTIVE
                ,   p_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
                ,   x_FORMULA_LINES_rec           => g_FORMULA_LINES_rec
                );
            ELSE
                g_FORMULA_LINES_rec.end_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FORMULA_LINES_rec.numeric_constant = FND_API.G_MISS_NUM THEN

        g_FORMULA_LINES_rec.numeric_constant := Get_Numeric_Constant;

        IF g_FORMULA_LINES_rec.numeric_constant IS NOT NULL THEN

            IF QP_Validate.Numeric_Constant(g_FORMULA_LINES_rec.numeric_constant)
            THEN

	        l_FORMULA_LINES_rec := g_FORMULA_LINES_rec;

                QP_Formula_Lines_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Formula_Lines_Util.G_NUMERIC_CONSTANT
                ,   p_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
                ,   x_FORMULA_LINES_rec           => g_FORMULA_LINES_rec
                );
            ELSE
                g_FORMULA_LINES_rec.numeric_constant := NULL;
            END IF;

        END IF;

    END IF;

    --Added by rchellam on 30-AUG-01. POSCO change.
    IF g_FORMULA_LINES_rec.reqd_flag = FND_API.G_MISS_CHAR THEN

        g_FORMULA_LINES_rec.reqd_flag := Get_Reqd_Flag;

        IF g_FORMULA_LINES_rec.reqd_flag IS NOT NULL THEN

            IF QP_Validate.Reqd_Flag(g_FORMULA_LINES_rec.reqd_flag)
            THEN

	        l_FORMULA_LINES_rec := g_FORMULA_LINES_rec;

                QP_Formula_Lines_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Formula_Lines_Util.G_REQD_FLAG
                ,   p_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
                ,   x_FORMULA_LINES_rec           => g_FORMULA_LINES_rec
                );
            ELSE
                g_FORMULA_LINES_rec.reqd_flag := NULL;
            END IF;

        END IF;

    END IF;


    IF g_FORMULA_LINES_rec.price_formula_id = FND_API.G_MISS_NUM THEN

        g_FORMULA_LINES_rec.price_formula_id := Get_Price_Formula;

        IF g_FORMULA_LINES_rec.price_formula_id IS NOT NULL THEN

            IF QP_Validate.Price_Formula(g_FORMULA_LINES_rec.price_formula_id)
            THEN

	        l_FORMULA_LINES_rec := g_FORMULA_LINES_rec;

                QP_Formula_Lines_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Formula_Lines_Util.G_PRICE_FORMULA
                ,   p_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
                ,   x_FORMULA_LINES_rec           => g_FORMULA_LINES_rec
                );
            ELSE
                g_FORMULA_LINES_rec.price_formula_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FORMULA_LINES_rec.price_formula_line_id = FND_API.G_MISS_NUM THEN

        g_FORMULA_LINES_rec.price_formula_line_id := Get_Price_Formula_Line;

        IF g_FORMULA_LINES_rec.price_formula_line_id IS NOT NULL THEN

            IF QP_Validate.Price_Formula_Line(g_FORMULA_LINES_rec.price_formula_line_id)
            THEN

	        l_FORMULA_LINES_rec := g_FORMULA_LINES_rec;

                QP_Formula_Lines_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Formula_Lines_Util.G_PRICE_FORMULA_LINE
                ,   p_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
                ,   x_FORMULA_LINES_rec           => g_FORMULA_LINES_rec
                );
            ELSE
                g_FORMULA_LINES_rec.price_formula_line_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FORMULA_LINES_rec.formula_line_type_code = FND_API.G_MISS_CHAR THEN

        g_FORMULA_LINES_rec.formula_line_type_code := Get_Price_Formula_Line_Type;

        IF g_FORMULA_LINES_rec.formula_line_type_code IS NOT NULL THEN

            IF QP_Validate.Price_Formula_Line_Type(g_FORMULA_LINES_rec.formula_line_type_code)
            THEN

	        l_FORMULA_LINES_rec := g_FORMULA_LINES_rec;

                QP_Formula_Lines_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Formula_Lines_Util.G_PRICE_FORMULA_LINE_TYPE
                ,   p_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
                ,   x_FORMULA_LINES_rec           => g_FORMULA_LINES_rec
                );
            ELSE
                g_FORMULA_LINES_rec.formula_line_type_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FORMULA_LINES_rec.price_list_line_id = FND_API.G_MISS_NUM THEN

        g_FORMULA_LINES_rec.price_list_line_id := Get_Price_List_Line;

        IF g_FORMULA_LINES_rec.price_list_line_id IS NOT NULL THEN

            IF QP_Validate.Price_List_Line(g_FORMULA_LINES_rec.price_list_line_id)
            THEN

	        l_FORMULA_LINES_rec := g_FORMULA_LINES_rec;

                QP_Formula_Lines_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Formula_Lines_Util.G_PRICE_LIST_LINE
                ,   p_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
                ,   x_FORMULA_LINES_rec           => g_FORMULA_LINES_rec
                );
            ELSE
                g_FORMULA_LINES_rec.price_list_line_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FORMULA_LINES_rec.price_modifier_list_id = FND_API.G_MISS_NUM THEN

        g_FORMULA_LINES_rec.price_modifier_list_id := Get_Price_Modifier_List;

        IF g_FORMULA_LINES_rec.price_modifier_list_id IS NOT NULL THEN

            IF QP_Validate.Price_Modifier_List(g_FORMULA_LINES_rec.price_modifier_list_id)
            THEN

	        l_FORMULA_LINES_rec := g_FORMULA_LINES_rec;

                QP_Formula_Lines_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Formula_Lines_Util.G_PRICE_MODIFIER_LIST
                ,   p_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
                ,   x_FORMULA_LINES_rec           => g_FORMULA_LINES_rec
                );
            ELSE
                g_FORMULA_LINES_rec.price_modifier_list_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FORMULA_LINES_rec.pricing_attribute = FND_API.G_MISS_CHAR THEN

        g_FORMULA_LINES_rec.pricing_attribute := Get_Pricing_Attribute;

        IF g_FORMULA_LINES_rec.pricing_attribute IS NOT NULL THEN

            IF QP_Validate.Pricing_Attribute(g_FORMULA_LINES_rec.pricing_attribute)
            THEN

	        l_FORMULA_LINES_rec := g_FORMULA_LINES_rec;

                QP_Formula_Lines_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Formula_Lines_Util.G_PRICING_ATTRIBUTE
                ,   p_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
                ,   x_FORMULA_LINES_rec           => g_FORMULA_LINES_rec
                );
            ELSE
                g_FORMULA_LINES_rec.pricing_attribute := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FORMULA_LINES_rec.pricing_attribute_context = FND_API.G_MISS_CHAR THEN

        g_FORMULA_LINES_rec.pricing_attribute_context := Get_Pricing_Attribute_Context;

        IF g_FORMULA_LINES_rec.pricing_attribute_context IS NOT NULL THEN

            IF QP_Validate.Pricing_Attribute_Context(g_FORMULA_LINES_rec.pricing_attribute_context)
            THEN

	        l_FORMULA_LINES_rec := g_FORMULA_LINES_rec;

                QP_Formula_Lines_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Formula_Lines_Util.G_PRICING_ATTRIBUTE_CONTEXT
                ,   p_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
                ,   x_FORMULA_LINES_rec           => g_FORMULA_LINES_rec
                );
            ELSE
                g_FORMULA_LINES_rec.pricing_attribute_context := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FORMULA_LINES_rec.start_date_active = FND_API.G_MISS_DATE THEN

        g_FORMULA_LINES_rec.start_date_active := Get_Start_Date_Active;

        IF g_FORMULA_LINES_rec.start_date_active IS NOT NULL THEN

            IF QP_Validate.Start_Date_Active(g_FORMULA_LINES_rec.start_date_active)
            THEN

	        l_FORMULA_LINES_rec := g_FORMULA_LINES_rec;

                QP_Formula_Lines_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Formula_Lines_Util.G_START_DATE_ACTIVE
                ,   p_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
                ,   x_FORMULA_LINES_rec           => g_FORMULA_LINES_rec
                );
            ELSE
                g_FORMULA_LINES_rec.start_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FORMULA_LINES_rec.step_number = FND_API.G_MISS_NUM THEN

        g_FORMULA_LINES_rec.step_number := Get_Step_Number;

        IF g_FORMULA_LINES_rec.step_number IS NOT NULL THEN

            IF QP_Validate.Step_Number(g_FORMULA_LINES_rec.step_number)
            THEN

	        l_FORMULA_LINES_rec := g_FORMULA_LINES_rec;

                QP_Formula_Lines_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Formula_Lines_Util.G_STEP_NUMBER
                ,   p_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
                ,   x_FORMULA_LINES_rec           => g_FORMULA_LINES_rec
                );
            ELSE
                g_FORMULA_LINES_rec.step_number := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FORMULA_LINES_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Formula_Lines;

    END IF;

    IF g_FORMULA_LINES_rec.created_by = FND_API.G_MISS_NUM THEN

        g_FORMULA_LINES_rec.created_by := NULL;

    END IF;

    IF g_FORMULA_LINES_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_FORMULA_LINES_rec.creation_date := NULL;

    END IF;

    IF g_FORMULA_LINES_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_FORMULA_LINES_rec.last_updated_by := NULL;

    END IF;

    IF g_FORMULA_LINES_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_FORMULA_LINES_rec.last_update_date := NULL;

    END IF;

    IF g_FORMULA_LINES_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_FORMULA_LINES_rec.last_update_login := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_FORMULA_LINES_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.context = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.created_by = FND_API.G_MISS_NUM
    OR  g_FORMULA_LINES_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_FORMULA_LINES_rec.end_date_active = FND_API.G_MISS_DATE
    OR  g_FORMULA_LINES_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_FORMULA_LINES_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_FORMULA_LINES_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_FORMULA_LINES_rec.numeric_constant = FND_API.G_MISS_NUM
    OR  g_FORMULA_LINES_rec.price_formula_id = FND_API.G_MISS_NUM
    OR  g_FORMULA_LINES_rec.price_formula_line_id = FND_API.G_MISS_NUM
    OR  g_FORMULA_LINES_rec.formula_line_type_code = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.price_list_line_id = FND_API.G_MISS_NUM
    OR  g_FORMULA_LINES_rec.price_modifier_list_id = FND_API.G_MISS_NUM
    OR  g_FORMULA_LINES_rec.pricing_attribute = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.pricing_attribute_context = FND_API.G_MISS_CHAR
    OR  g_FORMULA_LINES_rec.start_date_active = FND_API.G_MISS_DATE
    OR  g_FORMULA_LINES_rec.step_number = FND_API.G_MISS_NUM
    OR  g_FORMULA_LINES_rec.reqd_flag = FND_API.G_MISS_CHAR
    THEN

        QP_Default_Formula_Lines.Attributes
        (   p_FORMULA_LINES_rec           => g_FORMULA_LINES_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_FORMULA_LINES_rec           => x_FORMULA_LINES_rec
        );
    ELSE

        --  Done defaulting attributes

        x_FORMULA_LINES_rec := g_FORMULA_LINES_rec;

    END IF;

END Attributes;

END QP_Default_Formula_Lines;

/
