--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_LIMIT_ATTRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_LIMIT_ATTRS" AS
/* $Header: QPXDLATB.pls 120.2 2005/07/07 04:27:11 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Limit_Attrs';

--  Package global used within the package.

g_LIMIT_ATTRS_rec             QP_Limits_PUB.Limit_Attrs_Rec_Type;

--  Get functions.

FUNCTION Get_Comparison_Operator
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Comparison_Operator;


FUNCTION Get_Limit_Attribute
RETURN VARCHAR2
IS
BEGIN

	RETURN NULL;

END Get_Limit_Attribute;


FUNCTION Get_Limit_Attribute_Context
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Limit_Attribute_Context;

FUNCTION Get_Limit_Attribute_Id
RETURN NUMBER
IS
l_limit_attribute_id   NUMBER;
BEGIN

    SELECT qp_limit_attributes_s.nextval
    INTO   l_limit_attribute_id
    FROM   dual;

    RETURN l_limit_attribute_id;

END Get_Limit_Attribute_Id;


FUNCTION Get_Limit_Attribute_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Limit_Attribute_Type;

FUNCTION Get_Limit_Attr_Datatype
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Limit_Attr_Datatype;

FUNCTION Get_Limit_Attr_Value
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Limit_Attr_Value;

FUNCTION Get_Limit
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Limit;

PROCEDURE Get_Flex_Limit_Attrs
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_LIMIT_ATTRS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_ATTRS_rec.attribute1   := NULL;
    END IF;

    IF g_LIMIT_ATTRS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_ATTRS_rec.attribute10  := NULL;
    END IF;

    IF g_LIMIT_ATTRS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_ATTRS_rec.attribute11  := NULL;
    END IF;

    IF g_LIMIT_ATTRS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_ATTRS_rec.attribute12  := NULL;
    END IF;

    IF g_LIMIT_ATTRS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_ATTRS_rec.attribute13  := NULL;
    END IF;

    IF g_LIMIT_ATTRS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_ATTRS_rec.attribute14  := NULL;
    END IF;

    IF g_LIMIT_ATTRS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_ATTRS_rec.attribute15  := NULL;
    END IF;

    IF g_LIMIT_ATTRS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_ATTRS_rec.attribute2   := NULL;
    END IF;

    IF g_LIMIT_ATTRS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_ATTRS_rec.attribute3   := NULL;
    END IF;

    IF g_LIMIT_ATTRS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_ATTRS_rec.attribute4   := NULL;
    END IF;

    IF g_LIMIT_ATTRS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_ATTRS_rec.attribute5   := NULL;
    END IF;

    IF g_LIMIT_ATTRS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_ATTRS_rec.attribute6   := NULL;
    END IF;

    IF g_LIMIT_ATTRS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_ATTRS_rec.attribute7   := NULL;
    END IF;

    IF g_LIMIT_ATTRS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_ATTRS_rec.attribute8   := NULL;
    END IF;

    IF g_LIMIT_ATTRS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_LIMIT_ATTRS_rec.attribute9   := NULL;
    END IF;

    IF g_LIMIT_ATTRS_rec.context = FND_API.G_MISS_CHAR THEN
        g_LIMIT_ATTRS_rec.context      := NULL;
    END IF;

END Get_Flex_Limit_Attrs;

--  Procedure Attributes

PROCEDURE Attributes
(   p_LIMIT_ATTRS_rec               IN  QP_Limits_PUB.Limit_Attrs_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_ATTRS_REC
,   p_iteration                     IN  NUMBER := 1
,   x_LIMIT_ATTRS_rec               OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Attrs_Rec_Type
)
IS
l_LIMIT_ATTRS_rec	QP_Limits_PUB.Limit_Attrs_Rec_Type; --[prarasto]
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

    --  Initialize g_LIMIT_ATTRS_rec

    g_LIMIT_ATTRS_rec := p_LIMIT_ATTRS_rec;

    --  Default missing attributes.

    IF g_LIMIT_ATTRS_rec.comparison_operator_code = FND_API.G_MISS_CHAR THEN

        g_LIMIT_ATTRS_rec.comparison_operator_code := Get_Comparison_Operator;

        IF g_LIMIT_ATTRS_rec.comparison_operator_code IS NOT NULL THEN

            IF QP_Validate.Comparison_Operator(g_LIMIT_ATTRS_rec.comparison_operator_code)
            THEN

	        l_LIMIT_ATTRS_rec := g_LIMIT_ATTRS_rec; --[prarasto]

                QP_Limit_Attrs_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Attrs_Util.G_COMPARISON_OPERATOR
                ,   p_LIMIT_ATTRS_rec             => l_LIMIT_ATTRS_rec
                ,   x_LIMIT_ATTRS_rec             => g_LIMIT_ATTRS_rec
                );
            ELSE
                g_LIMIT_ATTRS_rec.comparison_operator_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_ATTRS_rec.limit_attribute = FND_API.G_MISS_CHAR THEN

        g_LIMIT_ATTRS_rec.limit_attribute := Get_Limit_Attribute;

        IF g_LIMIT_ATTRS_rec.limit_attribute IS NOT NULL THEN

            IF QP_Validate.Limit_Attribute(g_LIMIT_ATTRS_rec.limit_attribute)
            THEN

	        l_LIMIT_ATTRS_rec := g_LIMIT_ATTRS_rec; --[prarasto]

                QP_Limit_Attrs_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Attrs_Util.G_LIMIT_ATTRIBUTE
                ,   p_LIMIT_ATTRS_rec             => l_LIMIT_ATTRS_rec
                ,   x_LIMIT_ATTRS_rec             => g_LIMIT_ATTRS_rec
                );
            ELSE
                g_LIMIT_ATTRS_rec.limit_attribute := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_ATTRS_rec.limit_attribute_context = FND_API.G_MISS_CHAR THEN

        g_LIMIT_ATTRS_rec.limit_attribute_context := Get_Limit_Attribute_Context;

        IF g_LIMIT_ATTRS_rec.limit_attribute_context IS NOT NULL THEN

            IF QP_Validate.Limit_Attribute_Context(g_LIMIT_ATTRS_rec.limit_attribute_context)
            THEN

	        l_LIMIT_ATTRS_rec := g_LIMIT_ATTRS_rec; --[prarasto]

                QP_Limit_Attrs_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Attrs_Util.G_LIMIT_ATTRIBUTE_CONTEXT
                ,   p_LIMIT_ATTRS_rec             => l_LIMIT_ATTRS_rec
                ,   x_LIMIT_ATTRS_rec             => g_LIMIT_ATTRS_rec
                );
            ELSE
                g_LIMIT_ATTRS_rec.limit_attribute_context := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_ATTRS_rec.limit_attribute_id = FND_API.G_MISS_NUM THEN

        g_LIMIT_ATTRS_rec.limit_attribute_id := Get_Limit_Attribute_Id;

        IF g_LIMIT_ATTRS_rec.limit_attribute_id IS NOT NULL THEN

            IF QP_Validate.Limit_Attribute(g_LIMIT_ATTRS_rec.limit_attribute_id)
            THEN

	        l_LIMIT_ATTRS_rec := g_LIMIT_ATTRS_rec; --[prarasto]

                QP_Limit_Attrs_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Attrs_Util.G_LIMIT_ATTRIBUTE
                ,   p_LIMIT_ATTRS_rec             => l_LIMIT_ATTRS_rec
                ,   x_LIMIT_ATTRS_rec             => g_LIMIT_ATTRS_rec
                );
            ELSE
                g_LIMIT_ATTRS_rec.limit_attribute_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_ATTRS_rec.limit_attribute_type = FND_API.G_MISS_CHAR THEN

        g_LIMIT_ATTRS_rec.limit_attribute_type := Get_Limit_Attribute_Type;

        IF g_LIMIT_ATTRS_rec.limit_attribute_type IS NOT NULL THEN

            IF QP_Validate.Limit_Attribute_Type(g_LIMIT_ATTRS_rec.limit_attribute_type)
            THEN

	        l_LIMIT_ATTRS_rec := g_LIMIT_ATTRS_rec; --[prarasto]

                QP_Limit_Attrs_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Attrs_Util.G_LIMIT_ATTRIBUTE_TYPE
                ,   p_LIMIT_ATTRS_rec             => l_LIMIT_ATTRS_rec
                ,   x_LIMIT_ATTRS_rec             => g_LIMIT_ATTRS_rec
                );
            ELSE
                g_LIMIT_ATTRS_rec.limit_attribute_type := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_ATTRS_rec.limit_attr_datatype = FND_API.G_MISS_CHAR THEN

        g_LIMIT_ATTRS_rec.limit_attr_datatype := Get_Limit_Attr_Datatype;

        IF g_LIMIT_ATTRS_rec.limit_attr_datatype IS NOT NULL THEN

            IF QP_Validate.Limit_Attr_Datatype(g_LIMIT_ATTRS_rec.limit_attr_datatype)
            THEN

	        l_LIMIT_ATTRS_rec := g_LIMIT_ATTRS_rec; --[prarasto]

                QP_Limit_Attrs_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Attrs_Util.G_LIMIT_ATTR_DATATYPE
                ,   p_LIMIT_ATTRS_rec             => l_LIMIT_ATTRS_rec
                ,   x_LIMIT_ATTRS_rec             => g_LIMIT_ATTRS_rec
                );
            ELSE
                g_LIMIT_ATTRS_rec.limit_attr_datatype := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_ATTRS_rec.limit_attr_value = FND_API.G_MISS_CHAR THEN

        g_LIMIT_ATTRS_rec.limit_attr_value := Get_Limit_Attr_Value;

        IF g_LIMIT_ATTRS_rec.limit_attr_value IS NOT NULL THEN

            IF QP_Validate.Limit_Attr_Value(g_LIMIT_ATTRS_rec.limit_attr_value)
            THEN

	        l_LIMIT_ATTRS_rec := g_LIMIT_ATTRS_rec; --[prarasto]

                QP_Limit_Attrs_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Attrs_Util.G_LIMIT_ATTR_VALUE
                ,   p_LIMIT_ATTRS_rec             => l_LIMIT_ATTRS_rec
                ,   x_LIMIT_ATTRS_rec             => g_LIMIT_ATTRS_rec
                );
            ELSE
                g_LIMIT_ATTRS_rec.limit_attr_value := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_ATTRS_rec.limit_id = FND_API.G_MISS_NUM THEN

        g_LIMIT_ATTRS_rec.limit_id := Get_Limit;

        IF g_LIMIT_ATTRS_rec.limit_id IS NOT NULL THEN

            IF QP_Validate.Limit(g_LIMIT_ATTRS_rec.limit_id)
            THEN

	        l_LIMIT_ATTRS_rec := g_LIMIT_ATTRS_rec; --[prarasto]

                QP_Limit_Attrs_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limit_Attrs_Util.G_LIMIT
                ,   p_LIMIT_ATTRS_rec             => l_LIMIT_ATTRS_rec
                ,   x_LIMIT_ATTRS_rec             => g_LIMIT_ATTRS_rec
                );
            ELSE
                g_LIMIT_ATTRS_rec.limit_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMIT_ATTRS_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Limit_Attrs;

    END IF;

    IF g_LIMIT_ATTRS_rec.created_by = FND_API.G_MISS_NUM THEN

        g_LIMIT_ATTRS_rec.created_by := NULL;

    END IF;

    IF g_LIMIT_ATTRS_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_LIMIT_ATTRS_rec.creation_date := NULL;

    END IF;

    IF g_LIMIT_ATTRS_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_LIMIT_ATTRS_rec.last_updated_by := NULL;

    END IF;

    IF g_LIMIT_ATTRS_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_LIMIT_ATTRS_rec.last_update_date := NULL;

    END IF;

    IF g_LIMIT_ATTRS_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_LIMIT_ATTRS_rec.last_update_login := NULL;

    END IF;

    IF g_LIMIT_ATTRS_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_LIMIT_ATTRS_rec.program_application_id := NULL;

    END IF;

    IF g_LIMIT_ATTRS_rec.program_id = FND_API.G_MISS_NUM THEN

        g_LIMIT_ATTRS_rec.program_id := NULL;

    END IF;

    IF g_LIMIT_ATTRS_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_LIMIT_ATTRS_rec.program_update_date := NULL;

    END IF;

    IF g_LIMIT_ATTRS_rec.request_id = FND_API.G_MISS_NUM THEN

        g_LIMIT_ATTRS_rec.request_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_LIMIT_ATTRS_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.comparison_operator_code = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.context = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.created_by = FND_API.G_MISS_NUM
    OR  g_LIMIT_ATTRS_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_LIMIT_ATTRS_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_LIMIT_ATTRS_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_LIMIT_ATTRS_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_LIMIT_ATTRS_rec.limit_attribute = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.limit_attribute_context = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.limit_attribute_id = FND_API.G_MISS_NUM
    OR  g_LIMIT_ATTRS_rec.limit_attribute_type = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.limit_attr_datatype = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.limit_attr_value = FND_API.G_MISS_CHAR
    OR  g_LIMIT_ATTRS_rec.limit_id = FND_API.G_MISS_NUM
    OR  g_LIMIT_ATTRS_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_LIMIT_ATTRS_rec.program_id = FND_API.G_MISS_NUM
    OR  g_LIMIT_ATTRS_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_LIMIT_ATTRS_rec.request_id = FND_API.G_MISS_NUM
    THEN

        QP_Default_Limit_Attrs.Attributes
        (   p_LIMIT_ATTRS_rec             => g_LIMIT_ATTRS_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_LIMIT_ATTRS_rec             => x_LIMIT_ATTRS_rec
        );

    ELSE

        --  Done defaulting attributes

        x_LIMIT_ATTRS_rec := g_LIMIT_ATTRS_rec;

    END IF;

END Attributes;

END QP_Default_Limit_Attrs;

/
