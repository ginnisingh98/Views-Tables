--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_QUALIFIER_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_QUALIFIER_RULES" AS
/* $Header: QPXDQPRB.pls 120.2 2005/07/06 03:01:06 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Qualifier_Rules';

--  Package global used within the package.

g_QUALIFIER_RULES_rec         QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;
g_p_QUALIFIER_RULES_rec       QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;

--  Get functions.

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

FUNCTION Get_Qualifier_Rule
RETURN NUMBER
IS
l_qualifier_rule_id NUMBER;
BEGIN
    SELECT QP_QUALIFIER_RULES_S.NEXTVAL
    INTO l_qualifier_rule_id
    FROM DUAL;
    RETURN l_qualifier_rule_id;

END Get_Qualifier_Rule;

PROCEDURE Get_Flex_Qualifier_Rules
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_QUALIFIER_RULES_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIER_RULES_rec.attribute1 := NULL;
    END IF;

    IF g_QUALIFIER_RULES_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIER_RULES_rec.attribute10 := NULL;
    END IF;

    IF g_QUALIFIER_RULES_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIER_RULES_rec.attribute11 := NULL;
    END IF;

    IF g_QUALIFIER_RULES_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIER_RULES_rec.attribute12 := NULL;
    END IF;

    IF g_QUALIFIER_RULES_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIER_RULES_rec.attribute13 := NULL;
    END IF;

    IF g_QUALIFIER_RULES_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIER_RULES_rec.attribute14 := NULL;
    END IF;

    IF g_QUALIFIER_RULES_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIER_RULES_rec.attribute15 := NULL;
    END IF;

    IF g_QUALIFIER_RULES_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIER_RULES_rec.attribute2 := NULL;
    END IF;

    IF g_QUALIFIER_RULES_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIER_RULES_rec.attribute3 := NULL;
    END IF;

    IF g_QUALIFIER_RULES_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIER_RULES_rec.attribute4 := NULL;
    END IF;

    IF g_QUALIFIER_RULES_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIER_RULES_rec.attribute5 := NULL;
    END IF;

    IF g_QUALIFIER_RULES_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIER_RULES_rec.attribute6 := NULL;
    END IF;

    IF g_QUALIFIER_RULES_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIER_RULES_rec.attribute7 := NULL;
    END IF;

    IF g_QUALIFIER_RULES_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIER_RULES_rec.attribute8 := NULL;
    END IF;

    IF g_QUALIFIER_RULES_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIER_RULES_rec.attribute9 := NULL;
    END IF;

    IF g_QUALIFIER_RULES_rec.context = FND_API.G_MISS_CHAR THEN
        g_QUALIFIER_RULES_rec.context  := NULL;
    END IF;

END Get_Flex_Qualifier_Rules;

--  Procedure Attributes

PROCEDURE Attributes
(   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIER_RULES_REC
,   p_iteration                     IN  NUMBER := 1
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
)
IS
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

    --  Initialize g_QUALIFIER_RULES_rec

    g_QUALIFIER_RULES_rec := p_QUALIFIER_RULES_rec;

    --  Default missing attributes.

    IF g_QUALIFIER_RULES_rec.description = FND_API.G_MISS_CHAR THEN

        g_QUALIFIER_RULES_rec.description := Get_Description;

        IF g_QUALIFIER_RULES_rec.description IS NOT NULL THEN

            IF QP_Validate.Description(g_QUALIFIER_RULES_rec.description)
            THEN
                g_p_QUALIFIER_RULES_rec := g_QUALIFIER_RULES_rec;  -- added for nocopy hint
                QP_Qualifier_Rules_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifier_Rules_Util.G_DESCRIPTION
                ,   p_QUALIFIER_RULES_rec         => g_p_QUALIFIER_RULES_rec
                ,   x_QUALIFIER_RULES_rec         => g_QUALIFIER_RULES_rec
                );
            ELSE
                g_QUALIFIER_RULES_rec.description := NULL;
            END IF;

        END IF;

    END IF;

    IF g_QUALIFIER_RULES_rec.name = FND_API.G_MISS_CHAR THEN

        g_QUALIFIER_RULES_rec.name := Get_Name;

        IF g_QUALIFIER_RULES_rec.name IS NOT NULL THEN

            IF QP_Validate.Name(g_QUALIFIER_RULES_rec.name)
            THEN
                 g_p_QUALIFIER_RULES_rec := g_QUALIFIER_RULES_rec;  -- added for nocopy hint
                QP_Qualifier_Rules_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifier_Rules_Util.G_NAME
                ,   p_QUALIFIER_RULES_rec         => g_p_QUALIFIER_RULES_rec
                ,   x_QUALIFIER_RULES_rec         => g_QUALIFIER_RULES_rec
                );
            ELSE
                g_QUALIFIER_RULES_rec.name := NULL;
            END IF;

        END IF;

    END IF;

    IF g_QUALIFIER_RULES_rec.qualifier_rule_id = FND_API.G_MISS_NUM THEN

       --dbms_output.put_line('calling get_qualifierrule id to generate rule id');
       oe_debug_pub.add('calling get_qualifierrule id to generate rule id');


        g_QUALIFIER_RULES_rec.qualifier_rule_id := Get_Qualifier_Rule;


--dbms_output.put_line('calling get_qualifier '||g_QUALIFIER_RULES_rec.qualifier_rule_id);


        IF g_QUALIFIER_RULES_rec.qualifier_rule_id IS NOT NULL THEN

            IF QP_Validate.Qualifier_Rule(g_QUALIFIER_RULES_rec.qualifier_rule_id)
            THEN
                     g_p_QUALIFIER_RULES_rec := g_QUALIFIER_RULES_rec;  -- added for nocopy hint
                QP_Qualifier_Rules_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifier_Rules_Util.G_QUALIFIER_RULE
                ,   p_QUALIFIER_RULES_rec         => g_p_QUALIFIER_RULES_rec
                ,   x_QUALIFIER_RULES_rec         => g_QUALIFIER_RULES_rec
                );
            ELSE
                g_QUALIFIER_RULES_rec.qualifier_rule_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_QUALIFIER_RULES_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Qualifier_Rules;

    END IF;

    IF g_QUALIFIER_RULES_rec.created_by = FND_API.G_MISS_NUM THEN

        g_QUALIFIER_RULES_rec.created_by := NULL;

    END IF;

    IF g_QUALIFIER_RULES_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_QUALIFIER_RULES_rec.creation_date := NULL;

    END IF;

    IF g_QUALIFIER_RULES_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_QUALIFIER_RULES_rec.last_updated_by := NULL;

    END IF;

    IF g_QUALIFIER_RULES_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_QUALIFIER_RULES_rec.last_update_date := NULL;

    END IF;

    IF g_QUALIFIER_RULES_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_QUALIFIER_RULES_rec.last_update_login := NULL;

    END IF;

    IF g_QUALIFIER_RULES_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_QUALIFIER_RULES_rec.program_application_id := NULL;

    END IF;

    IF g_QUALIFIER_RULES_rec.program_id = FND_API.G_MISS_NUM THEN

        g_QUALIFIER_RULES_rec.program_id := NULL;

    END IF;

    IF g_QUALIFIER_RULES_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_QUALIFIER_RULES_rec.program_update_date := NULL;

    END IF;

    IF g_QUALIFIER_RULES_rec.request_id = FND_API.G_MISS_NUM THEN

        g_QUALIFIER_RULES_rec.request_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_QUALIFIER_RULES_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.context = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.created_by = FND_API.G_MISS_NUM
    OR  g_QUALIFIER_RULES_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_QUALIFIER_RULES_rec.description = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_QUALIFIER_RULES_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_QUALIFIER_RULES_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_QUALIFIER_RULES_rec.name = FND_API.G_MISS_CHAR
    OR  g_QUALIFIER_RULES_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_QUALIFIER_RULES_rec.program_id = FND_API.G_MISS_NUM
    OR  g_QUALIFIER_RULES_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_QUALIFIER_RULES_rec.qualifier_rule_id = FND_API.G_MISS_NUM
    OR  g_QUALIFIER_RULES_rec.request_id = FND_API.G_MISS_NUM
    THEN

        QP_Default_Qualifier_Rules.Attributes
        (   p_QUALIFIER_RULES_rec         => g_QUALIFIER_RULES_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_QUALIFIER_RULES_rec         => x_QUALIFIER_RULES_rec
        );

    ELSE

        --  Done defaulting attributes

        x_QUALIFIER_RULES_rec := g_QUALIFIER_RULES_rec;

    END IF;

END Attributes;

END QP_Default_Qualifier_Rules;

/
