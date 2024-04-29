--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_LIMITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_LIMITS" AS
/* $Header: QPXDLMTB.pls 120.2 2005/07/07 04:28:04 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Limits';

--  Package global used within the package.

g_LIMITS_rec                  QP_Limits_PUB.Limits_Rec_Type;

--  Get functions.

FUNCTION Get_Amount
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Amount;

FUNCTION Get_Basis
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Basis;

FUNCTION Get_Limit_Exceed_Action
RETURN VARCHAR2
IS
l_limit_exceed_action_code VARCHAR2(30);
BEGIN

    l_limit_exceed_action_code := FND_PROFILE.VALUE('QP_LIMIT_EXCEED_ACTION');
    RETURN l_limit_exceed_action_code;

END Get_Limit_Exceed_Action;

FUNCTION Get_Limit
RETURN NUMBER
IS
l_limit_id NUMBER;
BEGIN


    SELECT qp_limits_s.nextval
    INTO   l_limit_id
    FROM   dual;

    RETURN l_limit_id;

END Get_Limit;

FUNCTION Get_Limit_Hold
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Limit_Hold;


FUNCTION Get_Limit_Level
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Limit_Level;

FUNCTION Get_Limit_Number
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Limit_Number;

FUNCTION Get_List_Header
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_List_Header;

FUNCTION Get_List_Line
RETURN NUMBER
IS
l_list_line_id  NUMBER;
BEGIN

    l_list_line_id := -1;
    RETURN l_list_line_id;

END Get_List_Line;

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

FUNCTION Get_Multival_Attr2_Datatype
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Multival_Attr2_Datatype;


FUNCTION Get_Organization
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Organization;

PROCEDURE Get_Flex_Limits
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_LIMITS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_LIMITS_rec.attribute1        := NULL;
    END IF;

    IF g_LIMITS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_LIMITS_rec.attribute10       := NULL;
    END IF;

    IF g_LIMITS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_LIMITS_rec.attribute11       := NULL;
    END IF;

    IF g_LIMITS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_LIMITS_rec.attribute12       := NULL;
    END IF;

    IF g_LIMITS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_LIMITS_rec.attribute13       := NULL;
    END IF;

    IF g_LIMITS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_LIMITS_rec.attribute14       := NULL;
    END IF;

    IF g_LIMITS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_LIMITS_rec.attribute15       := NULL;
    END IF;

    IF g_LIMITS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_LIMITS_rec.attribute2        := NULL;
    END IF;

    IF g_LIMITS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_LIMITS_rec.attribute3        := NULL;
    END IF;

    IF g_LIMITS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_LIMITS_rec.attribute4        := NULL;
    END IF;

    IF g_LIMITS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_LIMITS_rec.attribute5        := NULL;
    END IF;

    IF g_LIMITS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_LIMITS_rec.attribute6        := NULL;
    END IF;

    IF g_LIMITS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_LIMITS_rec.attribute7        := NULL;
    END IF;

    IF g_LIMITS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_LIMITS_rec.attribute8        := NULL;
    END IF;

    IF g_LIMITS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_LIMITS_rec.attribute9        := NULL;
    END IF;

    IF g_LIMITS_rec.context = FND_API.G_MISS_CHAR THEN
        g_LIMITS_rec.context           := NULL;
    END IF;

END Get_Flex_Limits;

--  Procedure Attributes

PROCEDURE Attributes
(   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMITS_REC
,   p_iteration                     IN  NUMBER := 1
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limits_Rec_Type
)
IS
l_LIMITS_rec	QP_Limits_PUB.Limits_Rec_Type; --[prarasto]
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

    --  Initialize g_LIMITS_rec

    g_LIMITS_rec := p_LIMITS_rec;

    --  Default missing attributes.

    IF g_LIMITS_rec.amount = FND_API.G_MISS_NUM THEN

        g_LIMITS_rec.amount := Get_Amount;

        IF g_LIMITS_rec.amount IS NOT NULL THEN

            IF QP_Validate.Amount(g_LIMITS_rec.amount)
            THEN

	        l_LIMITS_rec := g_LIMITS_rec; --[prarasto]

                QP_Limits_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limits_Util.G_AMOUNT
                ,   p_LIMITS_rec                  => l_LIMITS_rec
                ,   x_LIMITS_rec                  => g_LIMITS_rec
                );
            ELSE
                g_LIMITS_rec.amount := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMITS_rec.basis = FND_API.G_MISS_CHAR THEN

        g_LIMITS_rec.basis := Get_Basis;

        IF g_LIMITS_rec.basis IS NOT NULL THEN

            IF QP_Validate.Basis(g_LIMITS_rec.basis)
            THEN

	        l_LIMITS_rec := g_LIMITS_rec; --[prarasto]

                QP_Limits_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limits_Util.G_BASIS
                ,   p_LIMITS_rec                  => l_LIMITS_rec
                ,   x_LIMITS_rec                  => g_LIMITS_rec
                );
            ELSE
                g_LIMITS_rec.basis := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMITS_rec.limit_exceed_action_code = FND_API.G_MISS_CHAR THEN

        g_LIMITS_rec.limit_exceed_action_code := Get_Limit_Exceed_Action;

        IF g_LIMITS_rec.limit_exceed_action_code IS NOT NULL THEN

            IF QP_Validate.Limit_Exceed_Action(g_LIMITS_rec.limit_exceed_action_code)
            THEN

	        l_LIMITS_rec := g_LIMITS_rec; --[prarasto]

                QP_Limits_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limits_Util.G_LIMIT_EXCEED_ACTION
                ,   p_LIMITS_rec                  => l_LIMITS_rec
                ,   x_LIMITS_rec                  => g_LIMITS_rec
                );
            ELSE
                g_LIMITS_rec.limit_exceed_action_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMITS_rec.limit_id = FND_API.G_MISS_NUM THEN

        g_LIMITS_rec.limit_id := Get_Limit;
        --dbms_output.put_line('Processing Limits - Inside QPXDLMTB ' || g_LIMITS_rec.limit_id);

        IF g_LIMITS_rec.limit_id IS NOT NULL THEN

            IF QP_Validate.Limit(g_LIMITS_rec.limit_id)
            THEN

	        l_LIMITS_rec := g_LIMITS_rec; --[prarasto]

                QP_Limits_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limits_Util.G_LIMIT
                ,   p_LIMITS_rec                  => l_LIMITS_rec
                ,   x_LIMITS_rec                  => g_LIMITS_rec
                );
            ELSE
                g_LIMITS_rec.limit_id := NULL;
                --dbms_output.put_line('Processing Limits - Inside QPXDLMTB ' || g_LIMITS_rec.limit_id);
            END IF;

        END IF;

    END IF;

    IF g_LIMITS_rec.limit_level_code = FND_API.G_MISS_CHAR THEN

        g_LIMITS_rec.limit_level_code := Get_Limit_Level;

        IF g_LIMITS_rec.limit_level_code IS NOT NULL THEN

            IF QP_Validate.Limit_Level(g_LIMITS_rec.limit_level_code)
            THEN

	        l_LIMITS_rec := g_LIMITS_rec; --[prarasto]

                QP_Limits_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limits_Util.G_LIMIT_LEVEL
                ,   p_LIMITS_rec                  => l_LIMITS_rec
                ,   x_LIMITS_rec                  => g_LIMITS_rec
                );
            ELSE
                g_LIMITS_rec.limit_level_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMITS_rec.limit_number = FND_API.G_MISS_NUM THEN

        g_LIMITS_rec.limit_number := Get_Limit_Number;

        IF g_LIMITS_rec.limit_number IS NOT NULL THEN

            IF QP_Validate.Limit_Number(g_LIMITS_rec.limit_number)
            THEN

	        l_LIMITS_rec := g_LIMITS_rec; --[prarasto]

                QP_Limits_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limits_Util.G_LIMIT_NUMBER
                ,   p_LIMITS_rec                  => l_LIMITS_rec
                ,   x_LIMITS_rec                  => g_LIMITS_rec
                );
            ELSE
                g_LIMITS_rec.limit_number := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMITS_rec.list_header_id = FND_API.G_MISS_NUM THEN

        g_LIMITS_rec.list_header_id := Get_List_Header;

        IF g_LIMITS_rec.list_header_id IS NOT NULL THEN

            IF QP_Validate.List_Header(g_LIMITS_rec.list_header_id)
            THEN

	        l_LIMITS_rec := g_LIMITS_rec; --[prarasto]

                QP_Limits_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limits_Util.G_LIST_HEADER
                ,   p_LIMITS_rec                  => l_LIMITS_rec
                ,   x_LIMITS_rec                  => g_LIMITS_rec
                );
            ELSE
                g_LIMITS_rec.list_header_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMITS_rec.list_line_id = FND_API.G_MISS_NUM THEN

        g_LIMITS_rec.list_line_id := Get_List_Line;

        IF g_LIMITS_rec.list_line_id IS NOT NULL THEN

            IF QP_Validate.List_Line(g_LIMITS_rec.list_line_id)
            THEN

	        l_LIMITS_rec := g_LIMITS_rec; --[prarasto]

                QP_Limits_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limits_Util.G_LIST_LINE
                ,   p_LIMITS_rec                  => l_LIMITS_rec
                ,   x_LIMITS_rec                  => g_LIMITS_rec
                );
            ELSE
                g_LIMITS_rec.list_line_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMITS_rec.limit_hold_flag = FND_API.G_MISS_CHAR THEN

        g_LIMITS_rec.limit_hold_flag := Get_Limit_Hold;

        IF g_LIMITS_rec.limit_hold_flag IS NOT NULL THEN

            IF QP_Validate.Limit_Hold(g_LIMITS_rec.limit_hold_flag)
            THEN

	        l_LIMITS_rec := g_LIMITS_rec; --[prarasto]

                QP_Limits_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limits_Util.G_LIMIT_HOLD
                ,   p_LIMITS_rec                  => l_LIMITS_rec
                ,   x_LIMITS_rec                  => g_LIMITS_rec
                );
            ELSE
                g_LIMITS_rec.limit_hold_flag := NULL;
            END IF;

        END IF;

    END IF;


    IF g_LIMITS_rec.multival_attr1_type = FND_API.G_MISS_CHAR THEN

        g_LIMITS_rec.multival_attr1_type := Get_Multival_Attr1_Type;

        IF g_LIMITS_rec.multival_attr1_type IS NOT NULL THEN

            IF QP_Validate.Multival_Attr1_Type(g_LIMITS_rec.multival_attr1_type)
            THEN

	        l_LIMITS_rec := g_LIMITS_rec; --[prarasto]

                QP_Limits_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limits_Util.G_MULTIVAL_ATTR1_TYPE
                ,   p_LIMITS_rec                  => l_LIMITS_rec
                ,   x_LIMITS_rec                  => g_LIMITS_rec
                );
            ELSE
                g_LIMITS_rec.multival_attr1_type := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMITS_rec.multival_attr1_context = FND_API.G_MISS_CHAR THEN

        g_LIMITS_rec.multival_attr1_context := Get_Multival_Attr1_Context;

        IF g_LIMITS_rec.multival_attr1_context IS NOT NULL THEN

            IF QP_Validate.Multival_Attr1_Context(g_LIMITS_rec.multival_attr1_context)
            THEN

	        l_LIMITS_rec := g_LIMITS_rec; --[prarasto]

                QP_Limits_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limits_Util.G_MULTIVAL_ATTR1_CONTEXT
                ,   p_LIMITS_rec                  => l_LIMITS_rec
                ,   x_LIMITS_rec                  => g_LIMITS_rec
                );
            ELSE
                g_LIMITS_rec.multival_attr1_context := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMITS_rec.multival_attribute1 = FND_API.G_MISS_CHAR THEN

        g_LIMITS_rec.multival_attribute1 := Get_Multival_Attribute1;

        IF g_LIMITS_rec.multival_attribute1 IS NOT NULL THEN

            IF QP_Validate.Multival_Attribute1(g_LIMITS_rec.multival_attribute1)
            THEN

	        l_LIMITS_rec := g_LIMITS_rec; --[prarasto]

                QP_Limits_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limits_Util.G_MULTIVAL_ATTRIBUTE1
                ,   p_LIMITS_rec                  => l_LIMITS_rec
                ,   x_LIMITS_rec                  => g_LIMITS_rec
                );
            ELSE
                g_LIMITS_rec.multival_attribute1 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMITS_rec.multival_attr1_datatype = FND_API.G_MISS_CHAR THEN

        g_LIMITS_rec.multival_attr1_datatype := Get_Multival_Attr1_Datatype;

        IF g_LIMITS_rec.multival_attr1_datatype IS NOT NULL THEN

            IF QP_Validate.Multival_Attr1_Datatype(g_LIMITS_rec.multival_attr1_datatype)
            THEN

	        l_LIMITS_rec := g_LIMITS_rec; --[prarasto]

                QP_Limits_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limits_Util.G_MULTIVAL_ATTR1_DATATYPE
                ,   p_LIMITS_rec                  => l_LIMITS_rec
                ,   x_LIMITS_rec                  => g_LIMITS_rec
                );
            ELSE
                g_LIMITS_rec.multival_attr1_datatype := NULL;
            END IF;

        END IF;

    END IF;


    IF g_LIMITS_rec.multival_attr2_type = FND_API.G_MISS_CHAR THEN

        g_LIMITS_rec.multival_attr2_type := Get_Multival_Attr2_Type;

        IF g_LIMITS_rec.multival_attr2_type IS NOT NULL THEN

            IF QP_Validate.Multival_Attr2_Type(g_LIMITS_rec.multival_attr2_type)
            THEN

	        l_LIMITS_rec := g_LIMITS_rec; --[prarasto]

                QP_Limits_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limits_Util.G_MULTIVAL_ATTR2_TYPE
                ,   p_LIMITS_rec                  => l_LIMITS_rec
                ,   x_LIMITS_rec                  => g_LIMITS_rec
                );
            ELSE
                g_LIMITS_rec.multival_attr2_type := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMITS_rec.multival_attr2_context = FND_API.G_MISS_CHAR THEN

        g_LIMITS_rec.multival_attr2_context := Get_Multival_Attr2_Context;

        IF g_LIMITS_rec.multival_attr2_context IS NOT NULL THEN

            IF QP_Validate.Multival_Attr2_Context(g_LIMITS_rec.multival_attr2_context)
            THEN

	        l_LIMITS_rec := g_LIMITS_rec; --[prarasto]

                QP_Limits_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limits_Util.G_MULTIVAL_ATTR2_CONTEXT
                ,   p_LIMITS_rec                  => l_LIMITS_rec
                ,   x_LIMITS_rec                  => g_LIMITS_rec
                );
            ELSE
                g_LIMITS_rec.multival_attr2_context := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMITS_rec.multival_attribute2 = FND_API.G_MISS_CHAR THEN

        g_LIMITS_rec.multival_attribute2 := Get_Multival_Attribute2;

        IF g_LIMITS_rec.multival_attribute2 IS NOT NULL THEN

            IF QP_Validate.Multival_Attribute2(g_LIMITS_rec.multival_attribute2)
            THEN

	        l_LIMITS_rec := g_LIMITS_rec; --[prarasto]

                QP_Limits_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limits_Util.G_MULTIVAL_ATTRIBUTE2
                ,   p_LIMITS_rec                  => l_LIMITS_rec
                ,   x_LIMITS_rec                  => g_LIMITS_rec
                );
            ELSE
                g_LIMITS_rec.multival_attribute2 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMITS_rec.multival_attr2_datatype = FND_API.G_MISS_CHAR THEN

        g_LIMITS_rec.multival_attr2_datatype := Get_Multival_Attr2_Datatype;

        IF g_LIMITS_rec.multival_attr2_datatype IS NOT NULL THEN

            IF QP_Validate.Multival_Attr2_Datatype(g_LIMITS_rec.multival_attr2_datatype)
            THEN

	        l_LIMITS_rec := g_LIMITS_rec; --[prarasto]

                QP_Limits_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limits_Util.G_MULTIVAL_ATTR2_DATATYPE
                ,   p_LIMITS_rec                  => l_LIMITS_rec
                ,   x_LIMITS_rec                  => g_LIMITS_rec
                );
            ELSE
                g_LIMITS_rec.multival_attr2_datatype := NULL;
            END IF;

        END IF;

    END IF;


    IF g_LIMITS_rec.organization_flag = FND_API.G_MISS_CHAR THEN

        g_LIMITS_rec.organization_flag := Get_Organization;

        IF g_LIMITS_rec.organization_flag IS NOT NULL THEN

            IF QP_Validate.Organization(g_LIMITS_rec.organization_flag)
            THEN

	        l_LIMITS_rec := g_LIMITS_rec; --[prarasto]

                QP_Limits_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Limits_Util.G_ORGANIZATION
                ,   p_LIMITS_rec                  => l_LIMITS_rec
                ,   x_LIMITS_rec                  => g_LIMITS_rec
                );
            ELSE
                g_LIMITS_rec.organization_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_LIMITS_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Limits;

    END IF;

    IF g_LIMITS_rec.created_by = FND_API.G_MISS_NUM THEN

        g_LIMITS_rec.created_by := NULL;

    END IF;

    IF g_LIMITS_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_LIMITS_rec.creation_date := NULL;

    END IF;

    IF g_LIMITS_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_LIMITS_rec.last_updated_by := NULL;

    END IF;

    IF g_LIMITS_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_LIMITS_rec.last_update_date := NULL;

    END IF;

    IF g_LIMITS_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_LIMITS_rec.last_update_login := NULL;

    END IF;

    IF g_LIMITS_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_LIMITS_rec.program_application_id := NULL;

    END IF;

    IF g_LIMITS_rec.program_id = FND_API.G_MISS_NUM THEN

        g_LIMITS_rec.program_id := NULL;

    END IF;

    IF g_LIMITS_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_LIMITS_rec.program_update_date := NULL;

    END IF;

    IF g_LIMITS_rec.request_id = FND_API.G_MISS_NUM THEN

        g_LIMITS_rec.request_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_LIMITS_rec.amount = FND_API.G_MISS_NUM
    OR  g_LIMITS_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.basis = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.context = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.created_by = FND_API.G_MISS_NUM
    OR  g_LIMITS_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_LIMITS_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_LIMITS_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_LIMITS_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_LIMITS_rec.limit_exceed_action_code = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.limit_id = FND_API.G_MISS_NUM
    OR  g_LIMITS_rec.limit_level_code = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.limit_number = FND_API.G_MISS_NUM
    OR  g_LIMITS_rec.list_header_id = FND_API.G_MISS_NUM
    OR  g_LIMITS_rec.list_line_id = FND_API.G_MISS_NUM
    OR  g_LIMITS_rec.multival_attr1_type = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.multival_attr1_context = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.multival_attribute1 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.multival_attr1_datatype = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.multival_attr2_type = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.multival_attr2_context = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.multival_attribute2 = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.multival_attr2_datatype = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.organization_flag = FND_API.G_MISS_CHAR
    OR  g_LIMITS_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_LIMITS_rec.program_id = FND_API.G_MISS_NUM
    OR  g_LIMITS_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_LIMITS_rec.request_id = FND_API.G_MISS_NUM
    THEN

        QP_Default_Limits.Attributes
        (   p_LIMITS_rec                  => g_LIMITS_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_LIMITS_rec                  => x_LIMITS_rec
        );

    ELSE

        --  Done defaulting attributes

        x_LIMITS_rec := g_LIMITS_rec;

    END IF;

END Attributes;

END QP_Default_Limits;

/
