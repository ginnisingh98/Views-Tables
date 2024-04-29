--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_CURR_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_CURR_DETAILS" AS
/* $Header: QPXDCDTB.pls 120.2 2005/07/07 04:26:12 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Curr_Details';

--  Package global used within the package.

g_CURR_DETAILS_rec            QP_Currency_PUB.Curr_Details_Rec_Type;

--  Get functions.

FUNCTION Get_Conversion_Date
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_Conversion_Date;

FUNCTION Get_Conversion_Date_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Conversion_Date_Type;

/*
FUNCTION Get_Conversion_Method
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Conversion_Method;
*/

FUNCTION Get_Conversion_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Conversion_Type;

FUNCTION Get_Currency_Detail
RETURN NUMBER
IS
l_currency_detail_id NUMBER := FND_API.G_MISS_NUM;
BEGIN

    select QP_CURRENCY_DETAILS_S.nextval
    into   l_currency_detail_id
    from   dual;

    RETURN l_currency_detail_id;

END Get_Currency_Detail;

FUNCTION Get_Currency_Header
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Currency_Header;

FUNCTION Get_End_Date_Active
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_End_Date_Active;

FUNCTION Get_Fixed_Value
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Fixed_Value;

FUNCTION Get_Markup_Formula
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Markup_Formula;

FUNCTION Get_Markup_Operator
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Markup_Operator;

FUNCTION Get_Markup_Value
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Markup_Value;

FUNCTION Get_Price_Formula
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Price_Formula;

FUNCTION Get_Rounding_Factor
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Rounding_Factor;

FUNCTION Get_Selling_Rounding_Factor
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Selling_Rounding_Factor;

FUNCTION Get_Start_Date_Active
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_Start_Date_Active;

FUNCTION Get_To_Currency
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_To_Currency;

FUNCTION Get_curr_attribute_type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_curr_attribute_type;

FUNCTION Get_curr_attribute_context
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_curr_attribute_context;

FUNCTION Get_curr_attribute
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_curr_attribute;

FUNCTION Get_curr_attribute_value
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_curr_attribute_value;

FUNCTION Get_Precedence
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Precedence;


PROCEDURE Get_Flex_Curr_Details
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_CURR_DETAILS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_CURR_DETAILS_rec.attribute1  := NULL;
    END IF;

    IF g_CURR_DETAILS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_CURR_DETAILS_rec.attribute10 := NULL;
    END IF;

    IF g_CURR_DETAILS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_CURR_DETAILS_rec.attribute11 := NULL;
    END IF;

    IF g_CURR_DETAILS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_CURR_DETAILS_rec.attribute12 := NULL;
    END IF;

    IF g_CURR_DETAILS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_CURR_DETAILS_rec.attribute13 := NULL;
    END IF;

    IF g_CURR_DETAILS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_CURR_DETAILS_rec.attribute14 := NULL;
    END IF;

    IF g_CURR_DETAILS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_CURR_DETAILS_rec.attribute15 := NULL;
    END IF;

    IF g_CURR_DETAILS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_CURR_DETAILS_rec.attribute2  := NULL;
    END IF;

    IF g_CURR_DETAILS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_CURR_DETAILS_rec.attribute3  := NULL;
    END IF;

    IF g_CURR_DETAILS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_CURR_DETAILS_rec.attribute4  := NULL;
    END IF;

    IF g_CURR_DETAILS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_CURR_DETAILS_rec.attribute5  := NULL;
    END IF;

    IF g_CURR_DETAILS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_CURR_DETAILS_rec.attribute6  := NULL;
    END IF;

    IF g_CURR_DETAILS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_CURR_DETAILS_rec.attribute7  := NULL;
    END IF;

    IF g_CURR_DETAILS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_CURR_DETAILS_rec.attribute8  := NULL;
    END IF;

    IF g_CURR_DETAILS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_CURR_DETAILS_rec.attribute9  := NULL;
    END IF;

    IF g_CURR_DETAILS_rec.context = FND_API.G_MISS_CHAR THEN
        g_CURR_DETAILS_rec.context     := NULL;
    END IF;

END Get_Flex_Curr_Details;

--  Procedure Attributes

PROCEDURE Attributes
(   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_DETAILS_REC
,   p_iteration                     IN  NUMBER := 1
,   x_CURR_DETAILS_rec              OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Details_Rec_Type
)
IS
l_CURR_DETAILS_rec	QP_Currency_PUB.Curr_Details_Rec_Type; --[prarasto]
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

    --  Initialize g_CURR_DETAILS_rec

    g_CURR_DETAILS_rec := p_CURR_DETAILS_rec;

    --  Default missing attributes.

    IF g_CURR_DETAILS_rec.conversion_date = FND_API.G_MISS_DATE THEN

        g_CURR_DETAILS_rec.conversion_date := Get_Conversion_Date;

        IF g_CURR_DETAILS_rec.conversion_date IS NOT NULL THEN

            IF QP_Validate.Conversion_Date(g_CURR_DETAILS_rec.conversion_date)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_CONVERSION_DATE
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.conversion_date := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_DETAILS_rec.conversion_date_type = FND_API.G_MISS_CHAR THEN

        g_CURR_DETAILS_rec.conversion_date_type := Get_Conversion_Date_Type;

        IF g_CURR_DETAILS_rec.conversion_date_type IS NOT NULL THEN

            IF QP_Validate.Conversion_Date_Type(g_CURR_DETAILS_rec.conversion_date_type)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_CONVERSION_DATE_TYPE
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.conversion_date_type := NULL;
            END IF;

        END IF;

    END IF;

    /*
    IF g_CURR_DETAILS_rec.conversion_method = FND_API.G_MISS_CHAR THEN

        g_CURR_DETAILS_rec.conversion_method := Get_Conversion_Method;

        IF g_CURR_DETAILS_rec.conversion_method IS NOT NULL THEN

            IF QP_Validate.Conversion_Method(g_CURR_DETAILS_rec.conversion_method)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_CONVERSION_METHOD
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.conversion_method := NULL;
            END IF;

        END IF;

    END IF;
    */

    IF g_CURR_DETAILS_rec.conversion_type = FND_API.G_MISS_CHAR THEN

        g_CURR_DETAILS_rec.conversion_type := Get_Conversion_Type;

        IF g_CURR_DETAILS_rec.conversion_type IS NOT NULL THEN

            IF QP_Validate.Conversion_Type(g_CURR_DETAILS_rec.conversion_type)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_CONVERSION_TYPE
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.conversion_type := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_DETAILS_rec.currency_detail_id = FND_API.G_MISS_NUM THEN

        g_CURR_DETAILS_rec.currency_detail_id := Get_Currency_Detail;

        IF g_CURR_DETAILS_rec.currency_detail_id IS NOT NULL THEN

            IF QP_Validate.Currency_Detail(g_CURR_DETAILS_rec.currency_detail_id)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_CURRENCY_DETAIL
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.currency_detail_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_DETAILS_rec.currency_header_id = FND_API.G_MISS_NUM THEN

        g_CURR_DETAILS_rec.currency_header_id := Get_Currency_Header;

        IF g_CURR_DETAILS_rec.currency_header_id IS NOT NULL THEN

            IF QP_Validate.Currency_Header(g_CURR_DETAILS_rec.currency_header_id)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_CURRENCY_HEADER
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.currency_header_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_DETAILS_rec.end_date_active = FND_API.G_MISS_DATE THEN

        g_CURR_DETAILS_rec.end_date_active := Get_End_Date_Active;

        IF g_CURR_DETAILS_rec.end_date_active IS NOT NULL THEN

            IF QP_Validate.End_Date_Active(g_CURR_DETAILS_rec.end_date_active)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_END_DATE_ACTIVE
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.end_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_DETAILS_rec.fixed_value = FND_API.G_MISS_NUM THEN

        g_CURR_DETAILS_rec.fixed_value := Get_Fixed_Value;

        IF g_CURR_DETAILS_rec.fixed_value IS NOT NULL THEN

            IF QP_Validate.Fixed_Value(g_CURR_DETAILS_rec.fixed_value)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_FIXED_VALUE
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.fixed_value := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_DETAILS_rec.markup_formula_id = FND_API.G_MISS_NUM THEN

        g_CURR_DETAILS_rec.markup_formula_id := Get_Markup_Formula;

        IF g_CURR_DETAILS_rec.markup_formula_id IS NOT NULL THEN

            IF QP_Validate.Markup_Formula(g_CURR_DETAILS_rec.markup_formula_id)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_MARKUP_FORMULA
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.markup_formula_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_DETAILS_rec.markup_operator = FND_API.G_MISS_CHAR THEN

        g_CURR_DETAILS_rec.markup_operator := Get_Markup_Operator;

        IF g_CURR_DETAILS_rec.markup_operator IS NOT NULL THEN

            IF QP_Validate.Markup_Operator(g_CURR_DETAILS_rec.markup_operator)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_MARKUP_OPERATOR
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.markup_operator := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_DETAILS_rec.markup_value = FND_API.G_MISS_NUM THEN

        g_CURR_DETAILS_rec.markup_value := Get_Markup_Value;

        IF g_CURR_DETAILS_rec.markup_value IS NOT NULL THEN

            IF QP_Validate.Markup_Value(g_CURR_DETAILS_rec.markup_value)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_MARKUP_VALUE
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.markup_value := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_DETAILS_rec.price_formula_id = FND_API.G_MISS_NUM THEN

        g_CURR_DETAILS_rec.price_formula_id := Get_Price_Formula;

        IF g_CURR_DETAILS_rec.price_formula_id IS NOT NULL THEN

            IF QP_Validate.Price_Formula(g_CURR_DETAILS_rec.price_formula_id)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_PRICE_FORMULA
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.price_formula_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_DETAILS_rec.rounding_factor = FND_API.G_MISS_NUM THEN

        g_CURR_DETAILS_rec.rounding_factor := Get_Rounding_Factor;

        IF g_CURR_DETAILS_rec.rounding_factor IS NOT NULL THEN

            IF QP_Validate.Rounding_Factor(g_CURR_DETAILS_rec.rounding_factor)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_ROUNDING_FACTOR
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.rounding_factor := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_DETAILS_rec.selling_rounding_factor = FND_API.G_MISS_NUM THEN

        g_CURR_DETAILS_rec.selling_rounding_factor := Get_Selling_Rounding_Factor;

        IF g_CURR_DETAILS_rec.selling_rounding_factor IS NOT NULL THEN

            IF QP_Validate.Rounding_Factor(g_CURR_DETAILS_rec.selling_rounding_factor)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_SELLING_ROUNDING_FACTOR
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.selling_rounding_factor := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_DETAILS_rec.start_date_active = FND_API.G_MISS_DATE THEN

        g_CURR_DETAILS_rec.start_date_active := Get_Start_Date_Active;

        IF g_CURR_DETAILS_rec.start_date_active IS NOT NULL THEN

            IF QP_Validate.Start_Date_Active(g_CURR_DETAILS_rec.start_date_active)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_START_DATE_ACTIVE
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.start_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_DETAILS_rec.to_currency_code = FND_API.G_MISS_CHAR THEN

        g_CURR_DETAILS_rec.to_currency_code := Get_To_Currency;

        IF g_CURR_DETAILS_rec.to_currency_code IS NOT NULL THEN

            IF QP_Validate.To_Currency(g_CURR_DETAILS_rec.to_currency_code)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_TO_CURRENCY
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.to_currency_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_DETAILS_rec.curr_attribute_type = FND_API.G_MISS_CHAR THEN

        g_CURR_DETAILS_rec.curr_attribute_type := Get_curr_attribute_type;

        IF g_CURR_DETAILS_rec.curr_attribute_type IS NOT NULL THEN

            IF QP_Validate.Curr_Attribute_Type(g_CURR_DETAILS_rec.curr_attribute_type)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_curr_attribute_type
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.curr_attribute_type := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_DETAILS_rec.curr_attribute_context = FND_API.G_MISS_CHAR THEN

        g_CURR_DETAILS_rec.curr_attribute_context := Get_curr_attribute_context;

        IF g_CURR_DETAILS_rec.curr_attribute_context IS NOT NULL THEN

            IF QP_Validate.Curr_Attribute_Context(g_CURR_DETAILS_rec.curr_attribute_context)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_curr_attribute_context
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.curr_attribute_context := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_DETAILS_rec.curr_attribute = FND_API.G_MISS_CHAR THEN

        g_CURR_DETAILS_rec.curr_attribute := Get_curr_attribute;

        IF g_CURR_DETAILS_rec.curr_attribute IS NOT NULL THEN

            IF QP_Validate.Curr_Attribute(g_CURR_DETAILS_rec.curr_attribute)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_curr_attribute
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.curr_attribute := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_DETAILS_rec.curr_attribute_value = FND_API.G_MISS_CHAR THEN

        g_CURR_DETAILS_rec.curr_attribute_value := Get_curr_attribute_value;

        IF g_CURR_DETAILS_rec.curr_attribute_value IS NOT NULL THEN

            IF QP_Validate.Curr_Attribute_Value(g_CURR_DETAILS_rec.curr_attribute_value)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_curr_attribute_value
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.curr_attribute_value := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_DETAILS_rec.precedence = FND_API.G_MISS_NUM THEN

        g_CURR_DETAILS_rec.precedence := Get_Precedence;

        IF g_CURR_DETAILS_rec.precedence IS NOT NULL THEN

            IF QP_Validate.Precedence(g_CURR_DETAILS_rec.precedence)
            THEN

	        l_CURR_DETAILS_rec := g_CURR_DETAILS_rec; --[prarasto]

                QP_Curr_Details_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Details_Util.G_precedence
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   x_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
                );
            ELSE
                g_CURR_DETAILS_rec.precedence := NULL;
            END IF;

        END IF;

    END IF;


    IF g_CURR_DETAILS_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Curr_Details;

    END IF;

    IF g_CURR_DETAILS_rec.created_by = FND_API.G_MISS_NUM THEN

        g_CURR_DETAILS_rec.created_by := NULL;

    END IF;

    IF g_CURR_DETAILS_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_CURR_DETAILS_rec.creation_date := NULL;

    END IF;

    IF g_CURR_DETAILS_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_CURR_DETAILS_rec.last_updated_by := NULL;

    END IF;

    IF g_CURR_DETAILS_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_CURR_DETAILS_rec.last_update_date := NULL;

    END IF;

    IF g_CURR_DETAILS_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_CURR_DETAILS_rec.last_update_login := NULL;

    END IF;

    IF g_CURR_DETAILS_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_CURR_DETAILS_rec.program_application_id := NULL;

    END IF;

    IF g_CURR_DETAILS_rec.program_id = FND_API.G_MISS_NUM THEN

        g_CURR_DETAILS_rec.program_id := NULL;

    END IF;

    IF g_CURR_DETAILS_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_CURR_DETAILS_rec.program_update_date := NULL;

    END IF;

    IF g_CURR_DETAILS_rec.request_id = FND_API.G_MISS_NUM THEN

        g_CURR_DETAILS_rec.request_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_CURR_DETAILS_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.context = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.conversion_date = FND_API.G_MISS_DATE
    OR  g_CURR_DETAILS_rec.conversion_date_type = FND_API.G_MISS_CHAR
    --OR  g_CURR_DETAILS_rec.conversion_method = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.conversion_type = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.created_by = FND_API.G_MISS_NUM
    OR  g_CURR_DETAILS_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_CURR_DETAILS_rec.currency_detail_id = FND_API.G_MISS_NUM
    OR  g_CURR_DETAILS_rec.currency_header_id = FND_API.G_MISS_NUM
    OR  g_CURR_DETAILS_rec.end_date_active = FND_API.G_MISS_DATE
    OR  g_CURR_DETAILS_rec.fixed_value = FND_API.G_MISS_NUM
    OR  g_CURR_DETAILS_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_CURR_DETAILS_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_CURR_DETAILS_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_CURR_DETAILS_rec.markup_formula_id = FND_API.G_MISS_NUM
    OR  g_CURR_DETAILS_rec.markup_operator = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.markup_value = FND_API.G_MISS_NUM
    OR  g_CURR_DETAILS_rec.price_formula_id = FND_API.G_MISS_NUM
    OR  g_CURR_DETAILS_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_CURR_DETAILS_rec.program_id = FND_API.G_MISS_NUM
    OR  g_CURR_DETAILS_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_CURR_DETAILS_rec.request_id = FND_API.G_MISS_NUM
    OR  g_CURR_DETAILS_rec.rounding_factor = FND_API.G_MISS_NUM
    OR  g_CURR_DETAILS_rec.selling_rounding_factor = FND_API.G_MISS_NUM
    OR  g_CURR_DETAILS_rec.start_date_active = FND_API.G_MISS_DATE
    OR  g_CURR_DETAILS_rec.to_currency_code = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.curr_attribute_type = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.curr_attribute_context = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.curr_attribute = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.curr_attribute_value = FND_API.G_MISS_CHAR
    OR  g_CURR_DETAILS_rec.precedence = FND_API.G_MISS_NUM
    THEN

        QP_Default_Curr_Details.Attributes
        (   p_CURR_DETAILS_rec            => g_CURR_DETAILS_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_CURR_DETAILS_rec            => x_CURR_DETAILS_rec
        );

    ELSE

        --  Done defaulting attributes

        x_CURR_DETAILS_rec := g_CURR_DETAILS_rec;

    END IF;

END Attributes;

END QP_Default_Curr_Details;

/
