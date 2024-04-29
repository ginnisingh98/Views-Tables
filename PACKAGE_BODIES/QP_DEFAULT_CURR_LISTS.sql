--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_CURR_LISTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_CURR_LISTS" AS
/* $Header: QPXDCURB.pls 120.2 2005/07/07 04:26:46 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Curr_Lists';

--  Package global used within the package.

g_CURR_LISTS_rec              QP_Currency_PUB.Curr_Lists_Rec_Type;

--  Get functions.

FUNCTION Get_Base_Currency
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Base_Currency;

FUNCTION Get_Currency_Header
RETURN NUMBER
IS
l_currency_header_id NUMBER := FND_API.G_MISS_NUM;
BEGIN
    -- oe_debug_pub.add('Get_Currency_Header of D-HDR is being called to generate new header_id');

    select QP_CURRENCY_LISTS_B_S.nextval
    into   l_currency_header_id
    from   dual;

    RETURN l_currency_header_id;

END Get_Currency_Header;

FUNCTION Get_Description
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Description;

FUNCTION Get_Name
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Name;

FUNCTION Get_base_rounding_factor
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_base_rounding_factor;

FUNCTION Get_base_markup_operator
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_base_markup_operator;

FUNCTION Get_base_markup_value
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_base_markup_value;

FUNCTION Get_base_markup_formula
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_base_markup_formula;

FUNCTION Get_Row
RETURN ROWID
IS
BEGIN

    RETURN NULL;

END Get_Row;

PROCEDURE Get_Flex_Curr_Lists
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_CURR_LISTS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_CURR_LISTS_rec.attribute1    := NULL;
    END IF;

    IF g_CURR_LISTS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_CURR_LISTS_rec.attribute10   := NULL;
    END IF;

    IF g_CURR_LISTS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_CURR_LISTS_rec.attribute11   := NULL;
    END IF;

    IF g_CURR_LISTS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_CURR_LISTS_rec.attribute12   := NULL;
    END IF;

    IF g_CURR_LISTS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_CURR_LISTS_rec.attribute13   := NULL;
    END IF;

    IF g_CURR_LISTS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_CURR_LISTS_rec.attribute14   := NULL;
    END IF;

    IF g_CURR_LISTS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_CURR_LISTS_rec.attribute15   := NULL;
    END IF;

    IF g_CURR_LISTS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_CURR_LISTS_rec.attribute2    := NULL;
    END IF;

    IF g_CURR_LISTS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_CURR_LISTS_rec.attribute3    := NULL;
    END IF;

    IF g_CURR_LISTS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_CURR_LISTS_rec.attribute4    := NULL;
    END IF;

    IF g_CURR_LISTS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_CURR_LISTS_rec.attribute5    := NULL;
    END IF;

    IF g_CURR_LISTS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_CURR_LISTS_rec.attribute6    := NULL;
    END IF;

    IF g_CURR_LISTS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_CURR_LISTS_rec.attribute7    := NULL;
    END IF;

    IF g_CURR_LISTS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_CURR_LISTS_rec.attribute8    := NULL;
    END IF;

    IF g_CURR_LISTS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_CURR_LISTS_rec.attribute9    := NULL;
    END IF;

    IF g_CURR_LISTS_rec.context = FND_API.G_MISS_CHAR THEN
        g_CURR_LISTS_rec.context       := NULL;
    END IF;

END Get_Flex_Curr_Lists;

--  Procedure Attributes

PROCEDURE Attributes
(   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_LISTS_REC
,   p_iteration                     IN  NUMBER := 1
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Lists_Rec_Type
)
IS
l_CURR_LISTS_rec	QP_Currency_PUB.Curr_Lists_Rec_Type; --[prarasto]
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

    --  Initialize g_CURR_LISTS_rec

    g_CURR_LISTS_rec := p_CURR_LISTS_rec;

    --  Default missing attributes.

    IF g_CURR_LISTS_rec.base_currency_code = FND_API.G_MISS_CHAR THEN

        g_CURR_LISTS_rec.base_currency_code := Get_Base_Currency;

        IF g_CURR_LISTS_rec.base_currency_code IS NOT NULL THEN

            IF QP_Validate.Base_Currency(g_CURR_LISTS_rec.base_currency_code)
            THEN

	        l_CURR_LISTS_rec := g_CURR_LISTS_rec; --[prarasto]

                QP_Curr_Lists_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Lists_Util.G_BASE_CURRENCY
                ,   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
                ,   x_CURR_LISTS_rec              => g_CURR_LISTS_rec
                );
            ELSE
                g_CURR_LISTS_rec.base_currency_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_LISTS_rec.currency_header_id = FND_API.G_MISS_NUM THEN

        g_CURR_LISTS_rec.currency_header_id := Get_Currency_Header;

        IF g_CURR_LISTS_rec.currency_header_id IS NOT NULL THEN

            IF QP_Validate.Currency_Header(g_CURR_LISTS_rec.currency_header_id)
            THEN

	        l_CURR_LISTS_rec := g_CURR_LISTS_rec; --[prarasto]

                QP_Curr_Lists_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Lists_Util.G_CURRENCY_HEADER
                ,   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
                ,   x_CURR_LISTS_rec              => g_CURR_LISTS_rec
                );
            ELSE
                g_CURR_LISTS_rec.currency_header_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_LISTS_rec.description = FND_API.G_MISS_CHAR THEN

        g_CURR_LISTS_rec.description := Get_Description;

        IF g_CURR_LISTS_rec.description IS NOT NULL THEN

            IF QP_Validate.Description(g_CURR_LISTS_rec.description)
            THEN

	        l_CURR_LISTS_rec := g_CURR_LISTS_rec; --[prarasto]

                QP_Curr_Lists_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Lists_Util.G_DESCRIPTION
                ,   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
                ,   x_CURR_LISTS_rec              => g_CURR_LISTS_rec
                );
            ELSE
                g_CURR_LISTS_rec.description := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_LISTS_rec.name = FND_API.G_MISS_CHAR THEN

        g_CURR_LISTS_rec.name := Get_Name;

        IF g_CURR_LISTS_rec.name IS NOT NULL THEN

            IF QP_Validate.Name(g_CURR_LISTS_rec.name)
            THEN

	        l_CURR_LISTS_rec := g_CURR_LISTS_rec; --[prarasto]

                QP_Curr_Lists_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Lists_Util.G_NAME
                ,   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
                ,   x_CURR_LISTS_rec              => g_CURR_LISTS_rec
                );
            ELSE
                g_CURR_LISTS_rec.name := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_LISTS_rec.base_rounding_factor = FND_API.G_MISS_NUM THEN

        g_CURR_LISTS_rec.base_rounding_factor := Get_base_rounding_factor;

        IF g_CURR_LISTS_rec.base_rounding_factor IS NOT NULL THEN

            IF QP_Validate.base_rounding_factor(g_CURR_LISTS_rec.base_rounding_factor)
            THEN

	        l_CURR_LISTS_rec := g_CURR_LISTS_rec; --[prarasto]

                QP_Curr_Lists_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Lists_Util.G_BASE_ROUNDING_FACTOR
                ,   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
                ,   x_CURR_LISTS_rec              => g_CURR_LISTS_rec
                );
            ELSE
                g_CURR_LISTS_rec.base_rounding_factor := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_LISTS_rec.base_markup_operator = FND_API.G_MISS_CHAR THEN

        g_CURR_LISTS_rec.base_markup_operator := Get_base_markup_operator;

        IF g_CURR_LISTS_rec.base_markup_operator IS NOT NULL THEN

            IF QP_Validate.base_markup_operator(g_CURR_LISTS_rec.base_markup_operator)
            THEN

	        l_CURR_LISTS_rec := g_CURR_LISTS_rec; --[prarasto]

                QP_Curr_Lists_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Lists_Util.G_BASE_MARKUP_OPERATOR
                ,   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
                ,   x_CURR_LISTS_rec              => g_CURR_LISTS_rec
                );
            ELSE
                g_CURR_LISTS_rec.base_markup_operator := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_LISTS_rec.base_markup_value = FND_API.G_MISS_NUM THEN

        g_CURR_LISTS_rec.base_markup_value := Get_base_markup_value;

        IF g_CURR_LISTS_rec.base_markup_value IS NOT NULL THEN

            IF QP_Validate.base_markup_value(g_CURR_LISTS_rec.base_markup_value)
            THEN

	        l_CURR_LISTS_rec := g_CURR_LISTS_rec; --[prarasto]

                QP_Curr_Lists_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Lists_Util.G_BASE_MARKUP_VALUE
                ,   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
                ,   x_CURR_LISTS_rec              => g_CURR_LISTS_rec
                );
            ELSE
                g_CURR_LISTS_rec.base_markup_value := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CURR_LISTS_rec.base_markup_formula_id = FND_API.G_MISS_NUM THEN

        g_CURR_LISTS_rec.base_markup_formula_id := Get_base_markup_formula;

        IF g_CURR_LISTS_rec.base_markup_formula_id IS NOT NULL THEN

            IF QP_Validate.base_markup_formula(g_CURR_LISTS_rec.base_markup_formula_id)
            THEN

	        l_CURR_LISTS_rec := g_CURR_LISTS_rec; --[prarasto]

                QP_Curr_Lists_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Lists_Util.G_BASE_MARKUP_FORMULA
                ,   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
                ,   x_CURR_LISTS_rec              => g_CURR_LISTS_rec
                );
            ELSE
                g_CURR_LISTS_rec.base_markup_formula_id := NULL;
            END IF;

        END IF;

    END IF;


/* Commented by Sunil
    IF g_CURR_LISTS_rec.row_id = FND_API.G_MISS_CHAR THEN

        g_CURR_LISTS_rec.row_id := Get_Row;

        IF g_CURR_LISTS_rec.row_id IS NOT NULL THEN

            IF QP_Validate.Row(g_CURR_LISTS_rec.row_id)
            THEN

	        l_CURR_LISTS_rec := g_CURR_LISTS_rec; --[prarasto]

                QP_Curr_Lists_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Curr_Lists_Util.G_ROW
                ,   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
                ,   x_CURR_LISTS_rec              => g_CURR_LISTS_rec
                );
            ELSE
                g_CURR_LISTS_rec.row_id := NULL;
            END IF;

        END IF;

    END IF;
   Commented by Sunil */

    IF g_CURR_LISTS_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Curr_Lists;

    END IF;

    IF g_CURR_LISTS_rec.created_by = FND_API.G_MISS_NUM THEN

        g_CURR_LISTS_rec.created_by := NULL;

    END IF;

    IF g_CURR_LISTS_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_CURR_LISTS_rec.creation_date := NULL;

    END IF;

    IF g_CURR_LISTS_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_CURR_LISTS_rec.last_updated_by := NULL;

    END IF;

    IF g_CURR_LISTS_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_CURR_LISTS_rec.last_update_date := NULL;

    END IF;

    IF g_CURR_LISTS_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_CURR_LISTS_rec.last_update_login := NULL;

    END IF;

    IF g_CURR_LISTS_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_CURR_LISTS_rec.program_application_id := NULL;

    END IF;

    IF g_CURR_LISTS_rec.program_id = FND_API.G_MISS_NUM THEN

        g_CURR_LISTS_rec.program_id := NULL;

    END IF;

    IF g_CURR_LISTS_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_CURR_LISTS_rec.program_update_date := NULL;

    END IF;

    IF g_CURR_LISTS_rec.request_id = FND_API.G_MISS_NUM THEN

        g_CURR_LISTS_rec.request_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_CURR_LISTS_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.base_currency_code = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.context = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.created_by = FND_API.G_MISS_NUM
    OR  g_CURR_LISTS_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_CURR_LISTS_rec.currency_header_id = FND_API.G_MISS_NUM
    OR  g_CURR_LISTS_rec.description = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_CURR_LISTS_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_CURR_LISTS_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_CURR_LISTS_rec.name = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_CURR_LISTS_rec.program_id = FND_API.G_MISS_NUM
    OR  g_CURR_LISTS_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_CURR_LISTS_rec.request_id = FND_API.G_MISS_NUM
    OR  g_CURR_LISTS_rec.request_id = FND_API.G_MISS_NUM
    OR  g_CURR_LISTS_rec.base_rounding_factor = FND_API.G_MISS_NUM
    OR  g_CURR_LISTS_rec.base_markup_operator = FND_API.G_MISS_CHAR
    OR  g_CURR_LISTS_rec.base_markup_value = FND_API.G_MISS_NUM
    OR  g_CURR_LISTS_rec.base_markup_formula_id = FND_API.G_MISS_NUM
    -- OR  g_CURR_LISTS_rec.row_id = FND_API.G_MISS_NUM --Commented by Sunil
    THEN

        QP_Default_Curr_Lists.Attributes
        (   p_CURR_LISTS_rec              => g_CURR_LISTS_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_CURR_LISTS_rec              => x_CURR_LISTS_rec
        );

    ELSE

        --  Done defaulting attributes

        x_CURR_LISTS_rec := g_CURR_LISTS_rec;

    END IF;

END Attributes;

END QP_Default_Curr_Lists;

/
