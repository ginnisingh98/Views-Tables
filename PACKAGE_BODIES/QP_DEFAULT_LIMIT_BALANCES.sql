--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_LIMIT_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_LIMIT_BALANCES" AS
/* $Header: QPXDLMBB.pls 120.2 2005/07/07 04:27:37 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Limit_Balances';

--  Package global used within the package.

g_LIMIT_BALANCES_rec          QP_Limits_PUB.Limit_Balances_Rec_Type;

--  Get functions.

FUNCTION Get_Available_Amount
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Available_Amount;

FUNCTION Get_Consumed_Amount
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Consumed_Amount;

FUNCTION Get_Limit_Balance
RETURN NUMBER
IS
l_limit_balance_id  NUMBER;
BEGIN


    SELECT qp_limit_balances_s.nextval
    INTO   l_limit_balance_id
    FROM   dual;

    RETURN l_limit_balance_id;

END Get_Limit_Balance;

FUNCTION Get_Limit
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Limit;

FUNCTION Get_Multival_Attr1_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Multival_Attr1_Type;

FUNCTION Get_Multival_Attr1_Context
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Multival_Attr1_Context;

FUNCTION Get_Multival_Attribute1
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Multival_Attribute1;

FUNCTION Get_Multival_Attr1_Value
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Multival_Attr1_Value;


FUNCTION Get_Multival_Attr1_Datatype
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Multival_Attr1_Datatype;

FUNCTION Get_Multival_Attr2_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Multival_Attr2_Type;

FUNCTION Get_Multival_Attr2_Context
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Multival_Attr2_Context;

FUNCTION Get_Multival_Attribute2
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Multival_Attribute2;

FUNCTION Get_Multival_Attr2_Value
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Multival_Attr2_Value;


FUNCTION Get_Multival_Attr2_Datatype
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Multival_Attr2_Datatype;

FUNCTION Get_Organization_Attr_Context
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Organization_Attr_Context;

FUNCTION Get_Organization_Attribute
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Organization_Attribute;

FUNCTION Get_Organization_Attr_Value
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Organization_Attr_Value;

FUNCTION Get_Reserved_Amount
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Reserved_Amount;

PROCEDURE Get_Flex_Limit_Balances
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_LIMIT_BALANCES_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_BALANCES_rec.attribute1 := NULL;
    END IF;

    IF g_LIMIT_BALANCES_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_BALANCES_rec.attribute10 := NULL;
    END IF;

    IF g_LIMIT_BALANCES_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_BALANCES_rec.attribute11 := NULL;
    END IF;

    IF g_LIMIT_BALANCES_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_BALANCES_rec.attribute12 := NULL;
    END IF;

    IF g_LIMIT_BALANCES_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_BALANCES_rec.attribute13 := NULL;
    END IF;

    IF g_LIMIT_BALANCES_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_BALANCES_rec.attribute14 := NULL;
    END IF;

    IF g_LIMIT_BALANCES_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_BALANCES_rec.attribute15 := NULL;
    END IF;

    IF g_LIMIT_BALANCES_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_BALANCES_rec.attribute2 := NULL;
    END IF;

    IF g_LIMIT_BALANCES_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_BALANCES_rec.attribute3 := NULL;
    END IF;

    IF g_LIMIT_BALANCES_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_BALANCES_rec.attribute4 := NULL;
    END IF;

    IF g_LIMIT_BALANCES_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_BALANCES_rec.attribute5 := NULL;
    END IF;

    IF g_LIMIT_BALANCES_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_BALANCES_rec.attribute6 := NULL;
    END IF;

    IF g_LIMIT_BALANCES_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_BALANCES_rec.attribute7 := NULL;
    END IF;

    IF g_LIMIT_BALANCES_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_BALANCES_rec.attribute8 := NULL;
    END IF;

    IF g_LIMIT_BALANCES_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_BALANCES_rec.attribute9 := NULL;
    END IF;

    IF g_LIMIT_BALANCES_rec.context = FND_API.G_MISS_CHAR THEN
        g_LIMIT_BALANCES_rec.context   := NULL;
    END IF;

END Get_Flex_Limit_Balances;

--  Procedure Attributes

PROCEDURE Attributes
(   p_LIMIT_BALANCES_rec            IN  QP_Limits_PUB.Limit_Balances_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_BALANCES_REC
,   p_iteration                     IN  NUMBER := 1
,   x_LIMIT_BALANCES_rec            OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Balances_Rec_Type
)
IS
l_LIMIT_BALANCES_rec	QP_Limits_PUB.Limit_Balances_Rec_Type; --[prarasto]
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

    --  Initialize g_LIMIT_BALANCES_rec

    g_LIMIT_BALANCES_rec := p_LIMIT_BALANCES_rec;

    --  Default missing attributes.

    IF g_LIMIT_BALANCES_rec.available_amount = FND_API.G_MISS_NUM THEN

        g_LIMIT_BALANCES_rec.available_amount := Get_Available_Amount;

        IF g_LIMIT_BALANCES_rec.available_amount IS NOT NULL THEN

            IF QP_Validate.Available_Amount(g_LIMIT_BALANCES_rec.available_amount)
            THEN

	        l_LIMIT_BALANCES_rec := g_LIMIT_BALANCES_rec; --[prarasto]

                QP_Limit_Balances_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Balances_Util.G_AVAILABLE_AMOUNT
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   x_LIMIT_BALANCES_rec          => g_LIMIT_BALANCES_rec
                );
            ELSE
                g_LIMIT_BALANCES_rec.available_amount := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_BALANCES_rec.consumed_amount = FND_API.G_MISS_NUM THEN

        g_LIMIT_BALANCES_rec.consumed_amount := Get_Consumed_Amount;

        IF g_LIMIT_BALANCES_rec.consumed_amount IS NOT NULL THEN

            IF QP_Validate.Consumed_Amount(g_LIMIT_BALANCES_rec.consumed_amount)
            THEN

	        l_LIMIT_BALANCES_rec := g_LIMIT_BALANCES_rec; --[prarasto]

                QP_Limit_Balances_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Balances_Util.G_CONSUMED_AMOUNT
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   x_LIMIT_BALANCES_rec          => g_LIMIT_BALANCES_rec
                );
            ELSE
                g_LIMIT_BALANCES_rec.consumed_amount := NULL;
            END IF;

        END IF;

    END IF;


    IF g_LIMIT_BALANCES_rec.limit_balance_id = FND_API.G_MISS_NUM THEN

        g_LIMIT_BALANCES_rec.limit_balance_id := Get_Limit_Balance;

        IF g_LIMIT_BALANCES_rec.limit_balance_id IS NOT NULL THEN

            IF QP_Validate.Limit_Balance(g_LIMIT_BALANCES_rec.limit_balance_id)
            THEN

	        l_LIMIT_BALANCES_rec := g_LIMIT_BALANCES_rec; --[prarasto]

                QP_Limit_Balances_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Balances_Util.G_LIMIT_BALANCE
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   x_LIMIT_BALANCES_rec          => g_LIMIT_BALANCES_rec
                );
            ELSE
                g_LIMIT_BALANCES_rec.limit_balance_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_BALANCES_rec.limit_id = FND_API.G_MISS_NUM THEN

        g_LIMIT_BALANCES_rec.limit_id := Get_Limit;

        IF g_LIMIT_BALANCES_rec.limit_id IS NOT NULL THEN

            IF QP_Validate.Limit(g_LIMIT_BALANCES_rec.limit_id)
            THEN

	        l_LIMIT_BALANCES_rec := g_LIMIT_BALANCES_rec; --[prarasto]

                QP_Limit_Balances_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Balances_Util.G_LIMIT
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   x_LIMIT_BALANCES_rec          => g_LIMIT_BALANCES_rec
                );
            ELSE
                g_LIMIT_BALANCES_rec.limit_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_BALANCES_rec.multival_attr1_type = FND_API.G_MISS_CHAR THEN

        g_LIMIT_BALANCES_rec.multival_attr1_type := Get_Multival_Attr1_Type;

        IF g_LIMIT_BALANCES_rec.multival_attr1_type IS NOT NULL THEN

            IF QP_Validate.Multival_Attr1_Type(g_LIMIT_BALANCES_rec.multival_attr1_type)
            THEN

	        l_LIMIT_BALANCES_rec := g_LIMIT_BALANCES_rec; --[prarasto]

                QP_Limit_Balances_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Balances_Util.G_MULTIVAL_ATTR1_TYPE
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   x_LIMIT_BALANCES_rec          => g_LIMIT_BALANCES_rec
                );
            ELSE
                g_LIMIT_BALANCES_rec.multival_attr1_type := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_BALANCES_rec.multival_attr1_context = FND_API.G_MISS_CHAR THEN

        g_LIMIT_BALANCES_rec.multival_attr1_context := Get_Multival_Attr1_Context;

        IF g_LIMIT_BALANCES_rec.multival_attr1_context IS NOT NULL THEN

            IF QP_Validate.Multival_Attr1_Context(g_LIMIT_BALANCES_rec.multival_attr1_context)
            THEN

	        l_LIMIT_BALANCES_rec := g_LIMIT_BALANCES_rec; --[prarasto]

                QP_Limit_Balances_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Balances_Util.G_MULTIVAL_ATTR1_CONTEXT
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   x_LIMIT_BALANCES_rec          => g_LIMIT_BALANCES_rec
                );
            ELSE
                g_LIMIT_BALANCES_rec.multival_attr1_context := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_BALANCES_rec.multival_attribute1 = FND_API.G_MISS_CHAR THEN

        g_LIMIT_BALANCES_rec.multival_attribute1 := Get_Multival_Attribute1;

        IF g_LIMIT_BALANCES_rec.multival_attribute1 IS NOT NULL THEN

            IF QP_Validate.Multival_Attribute1(g_LIMIT_BALANCES_rec.multival_attribute1)
            THEN

	        l_LIMIT_BALANCES_rec := g_LIMIT_BALANCES_rec; --[prarasto]

                QP_Limit_Balances_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Balances_Util.G_MULTIVAL_ATTRIBUTE1
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   x_LIMIT_BALANCES_rec          => g_LIMIT_BALANCES_rec
                );
            ELSE
                g_LIMIT_BALANCES_rec.multival_attribute1 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_BALANCES_rec.multival_attr1_value = FND_API.G_MISS_CHAR THEN

        g_LIMIT_BALANCES_rec.multival_attr1_value := Get_Multival_Attr1_Value;

        IF g_LIMIT_BALANCES_rec.multival_attr1_value IS NOT NULL THEN

            IF QP_Validate.Multival_Attr1_Value(g_LIMIT_BALANCES_rec.multival_attr1_value)
            THEN

	        l_LIMIT_BALANCES_rec := g_LIMIT_BALANCES_rec; --[prarasto]

                QP_Limit_Balances_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Balances_Util.G_MULTIVAL_ATTR1_VALUE
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   x_LIMIT_BALANCES_rec          => g_LIMIT_BALANCES_rec
                );
            ELSE
                g_LIMIT_BALANCES_rec.multival_attr1_value := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_BALANCES_rec.multival_attr1_datatype = FND_API.G_MISS_CHAR THEN

        g_LIMIT_BALANCES_rec.multival_attr1_datatype := Get_Multival_Attr1_Datatype;

        IF g_LIMIT_BALANCES_rec.multival_attr1_datatype IS NOT NULL THEN

            IF QP_Validate.Multival_Attr1_Datatype(g_LIMIT_BALANCES_rec.multival_attr1_datatype)
            THEN

	        l_LIMIT_BALANCES_rec := g_LIMIT_BALANCES_rec; --[prarasto]

                QP_Limit_Balances_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Balances_Util.G_MULTIVAL_ATTR1_DATATYPE
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   x_LIMIT_BALANCES_rec          => g_LIMIT_BALANCES_rec
                );
            ELSE
                g_LIMIT_BALANCES_rec.multival_attr1_datatype := NULL;
            END IF;

        END IF;

    END IF;


    IF g_LIMIT_BALANCES_rec.multival_attr2_type = FND_API.G_MISS_CHAR THEN

        g_LIMIT_BALANCES_rec.multival_attr2_type := Get_Multival_Attr2_Type;

        IF g_LIMIT_BALANCES_rec.multival_attr2_type IS NOT NULL THEN

            IF QP_Validate.Multival_Attr2_Type(g_LIMIT_BALANCES_rec.multival_attr2_type)
            THEN

	        l_LIMIT_BALANCES_rec := g_LIMIT_BALANCES_rec; --[prarasto]

                QP_Limit_Balances_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Balances_Util.G_MULTIVAL_ATTR2_TYPE
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   x_LIMIT_BALANCES_rec          => g_LIMIT_BALANCES_rec
                );
            ELSE
                g_LIMIT_BALANCES_rec.multival_attr2_type := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_BALANCES_rec.multival_attr2_context = FND_API.G_MISS_CHAR THEN

        g_LIMIT_BALANCES_rec.multival_attr2_context := Get_Multival_Attr2_Context;

        IF g_LIMIT_BALANCES_rec.multival_attr2_context IS NOT NULL THEN

            IF QP_Validate.Multival_Attr2_Context(g_LIMIT_BALANCES_rec.multival_attr2_context)
            THEN

	        l_LIMIT_BALANCES_rec := g_LIMIT_BALANCES_rec; --[prarasto]

                QP_Limit_Balances_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Balances_Util.G_MULTIVAL_ATTR2_CONTEXT
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   x_LIMIT_BALANCES_rec          => g_LIMIT_BALANCES_rec
                );
            ELSE
                g_LIMIT_BALANCES_rec.multival_attr2_context := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_BALANCES_rec.multival_attribute2 = FND_API.G_MISS_CHAR THEN

        g_LIMIT_BALANCES_rec.multival_attribute2 := Get_Multival_Attribute2;

        IF g_LIMIT_BALANCES_rec.multival_attribute2 IS NOT NULL THEN

            IF QP_Validate.Multival_Attribute2(g_LIMIT_BALANCES_rec.multival_attribute2)
            THEN

	        l_LIMIT_BALANCES_rec := g_LIMIT_BALANCES_rec; --[prarasto]

                QP_Limit_Balances_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Balances_Util.G_MULTIVAL_ATTRIBUTE2
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   x_LIMIT_BALANCES_rec          => g_LIMIT_BALANCES_rec
                );
            ELSE
                g_LIMIT_BALANCES_rec.multival_attribute2 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_BALANCES_rec.multival_attr2_value = FND_API.G_MISS_CHAR THEN

        g_LIMIT_BALANCES_rec.multival_attr2_value := Get_Multival_Attr2_Value;

        IF g_LIMIT_BALANCES_rec.multival_attr2_value IS NOT NULL THEN

            IF QP_Validate.Multival_Attr2_Value(g_LIMIT_BALANCES_rec.multival_attr2_value)
            THEN

	        l_LIMIT_BALANCES_rec := g_LIMIT_BALANCES_rec; --[prarasto]

                QP_Limit_Balances_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Balances_Util.G_MULTIVAL_ATTR2_VALUE
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   x_LIMIT_BALANCES_rec          => g_LIMIT_BALANCES_rec
                );
            ELSE
                g_LIMIT_BALANCES_rec.multival_attr2_value := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_BALANCES_rec.multival_attr2_datatype = FND_API.G_MISS_CHAR THEN

        g_LIMIT_BALANCES_rec.multival_attr2_datatype := Get_Multival_Attr2_Datatype;

        IF g_LIMIT_BALANCES_rec.multival_attr2_datatype IS NOT NULL THEN

            IF QP_Validate.Multival_Attr2_Datatype(g_LIMIT_BALANCES_rec.multival_attr2_datatype)
            THEN

	        l_LIMIT_BALANCES_rec := g_LIMIT_BALANCES_rec; --[prarasto]

                QP_Limit_Balances_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Balances_Util.G_MULTIVAL_ATTR2_DATATYPE
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   x_LIMIT_BALANCES_rec          => g_LIMIT_BALANCES_rec
                );
            ELSE
                g_LIMIT_BALANCES_rec.multival_attr2_datatype := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_BALANCES_rec.organization_attr_context = FND_API.G_MISS_CHAR THEN

        g_LIMIT_BALANCES_rec.organization_attr_context := Get_Organization_Attr_Context;

        IF g_LIMIT_BALANCES_rec.organization_attr_context IS NOT NULL THEN

            IF QP_Validate.Organization_Attr_Context(g_LIMIT_BALANCES_rec.organization_attr_context)
            THEN

	        l_LIMIT_BALANCES_rec := g_LIMIT_BALANCES_rec; --[prarasto]

                QP_Limit_Balances_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Balances_Util.G_ORGANIZATION_ATTR_CONTEXT
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   x_LIMIT_BALANCES_rec          => g_LIMIT_BALANCES_rec
                );
            ELSE
                g_LIMIT_BALANCES_rec.organization_attr_context := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_BALANCES_rec.organization_attribute = FND_API.G_MISS_CHAR THEN

        g_LIMIT_BALANCES_rec.organization_attribute := Get_Organization_Attribute;

        IF g_LIMIT_BALANCES_rec.organization_attribute IS NOT NULL THEN

            IF QP_Validate.Organization_Attribute(g_LIMIT_BALANCES_rec.organization_attribute)
            THEN

	        l_LIMIT_BALANCES_rec := g_LIMIT_BALANCES_rec; --[prarasto]

                QP_Limit_Balances_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Balances_Util.G_ORGANIZATION_ATTRIBUTE
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   x_LIMIT_BALANCES_rec          => g_LIMIT_BALANCES_rec
                );
            ELSE
                g_LIMIT_BALANCES_rec.organization_attribute := NULL;
            END IF;

        END IF;

    END IF;


    IF g_LIMIT_BALANCES_rec.organization_attr_value = FND_API.G_MISS_CHAR THEN

        g_LIMIT_BALANCES_rec.organization_attr_value := Get_Organization_Attr_Value;

        IF g_LIMIT_BALANCES_rec.organization_attr_value IS NOT NULL THEN

            IF QP_Validate.Organization_Attr_Value(g_LIMIT_BALANCES_rec.organization_attr_value)
            THEN

	        l_LIMIT_BALANCES_rec := g_LIMIT_BALANCES_rec; --[prarasto]

                QP_Limit_Balances_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Balances_Util.G_ORGANIZATION_ATTR_VALUE
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   x_LIMIT_BALANCES_rec          => g_LIMIT_BALANCES_rec
                );
            ELSE
                g_LIMIT_BALANCES_rec.organization_attr_value := NULL;
            END IF;

        END IF;

    END IF;


    IF g_LIMIT_BALANCES_rec.reserved_amount = FND_API.G_MISS_NUM THEN

        g_LIMIT_BALANCES_rec.reserved_amount := Get_Reserved_Amount;

        IF g_LIMIT_BALANCES_rec.reserved_amount IS NOT NULL THEN

            IF QP_Validate.Reserved_Amount(g_LIMIT_BALANCES_rec.reserved_amount)
            THEN

	        l_LIMIT_BALANCES_rec := g_LIMIT_BALANCES_rec; --[prarasto]

                QP_Limit_Balances_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Balances_Util.G_RESERVED_AMOUNT
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   x_LIMIT_BALANCES_rec          => g_LIMIT_BALANCES_rec
                );
            ELSE
                g_LIMIT_BALANCES_rec.reserved_amount := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_BALANCES_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Limit_Balances;

    END IF;

    IF g_LIMIT_BALANCES_rec.created_by = FND_API.G_MISS_NUM THEN

        g_LIMIT_BALANCES_rec.created_by := NULL;

    END IF;

    IF g_LIMIT_BALANCES_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_LIMIT_BALANCES_rec.creation_date := NULL;

    END IF;

    IF g_LIMIT_BALANCES_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_LIMIT_BALANCES_rec.last_updated_by := NULL;

    END IF;

    IF g_LIMIT_BALANCES_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_LIMIT_BALANCES_rec.last_update_date := NULL;

    END IF;

    IF g_LIMIT_BALANCES_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_LIMIT_BALANCES_rec.last_update_login := NULL;

    END IF;

    IF g_LIMIT_BALANCES_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_LIMIT_BALANCES_rec.program_application_id := NULL;

    END IF;

    IF g_LIMIT_BALANCES_rec.program_id = FND_API.G_MISS_NUM THEN

        g_LIMIT_BALANCES_rec.program_id := NULL;

    END IF;

    IF g_LIMIT_BALANCES_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_LIMIT_BALANCES_rec.program_update_date := NULL;

    END IF;

    IF g_LIMIT_BALANCES_rec.request_id = FND_API.G_MISS_NUM THEN

        g_LIMIT_BALANCES_rec.request_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_LIMIT_BALANCES_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.available_amount = FND_API.G_MISS_NUM
    OR  g_LIMIT_BALANCES_rec.consumed_amount = FND_API.G_MISS_NUM
    OR  g_LIMIT_BALANCES_rec.context = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.created_by = FND_API.G_MISS_NUM
    OR  g_LIMIT_BALANCES_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_LIMIT_BALANCES_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_LIMIT_BALANCES_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_LIMIT_BALANCES_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_LIMIT_BALANCES_rec.limit_balance_id = FND_API.G_MISS_NUM
    OR  g_LIMIT_BALANCES_rec.limit_id = FND_API.G_MISS_NUM
    OR  g_LIMIT_BALANCES_rec.multival_attr1_type = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.multival_attr1_context = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.multival_attribute1 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.multival_attr1_value = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.multival_attr1_datatype = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.multival_attr2_type = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.multival_attr2_context = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.multival_attribute2 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.multival_attr2_value = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.multival_attr2_datatype = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.organization_attr_context = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.organization_attribute = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.organization_attr_value = FND_API.G_MISS_CHAR
    OR  g_LIMIT_BALANCES_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_LIMIT_BALANCES_rec.program_id = FND_API.G_MISS_NUM
    OR  g_LIMIT_BALANCES_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_LIMIT_BALANCES_rec.request_id = FND_API.G_MISS_NUM
    OR  g_LIMIT_BALANCES_rec.reserved_amount = FND_API.G_MISS_NUM
    THEN

        QP_Default_Limit_Balances.Attributes
        (   p_LIMIT_BALANCES_rec          => g_LIMIT_BALANCES_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_LIMIT_BALANCES_rec          => x_LIMIT_BALANCES_rec
        );

    ELSE

        --  Done defaulting attributes

        x_LIMIT_BALANCES_rec := g_LIMIT_BALANCES_rec;

    END IF;

END Attributes;

END QP_Default_Limit_Balances;

/
