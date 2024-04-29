--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_SOU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_SOU" AS
/* $Header: QPXDSOUB.pls 120.2 2005/07/06 04:25:48 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Sou';

--  Package global used within the package.

g_SOU_rec                     QP_Attr_Map_PUB.Sou_Rec_Type;

--  Get functions.

FUNCTION Get_Attribute_Sourcing
RETURN NUMBER
IS
  l_attribute_sourcing_id   number(15);
BEGIN
oe_debug_pub.add('In QPXDSOUB.pls--at sequence' );
   select qp_attribute_sourcing_s.nextval
   into l_attribute_sourcing_id
   from dual;
   RETURN (l_attribute_sourcing_id);

END Get_Attribute_Sourcing;

FUNCTION Get_Attribute_Sourcing_Level
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Attribute_Sourcing_Level;

FUNCTION Get_application_id
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_application_id;

FUNCTION Get_Enabled
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Enabled;

FUNCTION Get_Request_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Request_Type;

FUNCTION Get_Seeded
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Seeded;

FUNCTION Get_Seeded_Sourcing_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Seeded_Sourcing_Type;

FUNCTION Get_Seeded_Value_String
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Seeded_Value_String;

FUNCTION Get_Segment
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Segment;

FUNCTION Get_User_Sourcing_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_User_Sourcing_Type;

FUNCTION Get_User_Value_String
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_User_Value_String;

PROCEDURE Get_Flex_Sou
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_SOU_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_SOU_rec.attribute1           := NULL;
    END IF;

    IF g_SOU_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_SOU_rec.attribute10          := NULL;
    END IF;

    IF g_SOU_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_SOU_rec.attribute11          := NULL;
    END IF;

    IF g_SOU_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_SOU_rec.attribute12          := NULL;
    END IF;

    IF g_SOU_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_SOU_rec.attribute13          := NULL;
    END IF;

    IF g_SOU_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_SOU_rec.attribute14          := NULL;
    END IF;

    IF g_SOU_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_SOU_rec.attribute15          := NULL;
    END IF;

    IF g_SOU_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_SOU_rec.attribute2           := NULL;
    END IF;

    IF g_SOU_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_SOU_rec.attribute3           := NULL;
    END IF;

    IF g_SOU_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_SOU_rec.attribute4           := NULL;
    END IF;

    IF g_SOU_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_SOU_rec.attribute5           := NULL;
    END IF;

    IF g_SOU_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_SOU_rec.attribute6           := NULL;
    END IF;

    IF g_SOU_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_SOU_rec.attribute7           := NULL;
    END IF;

    IF g_SOU_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_SOU_rec.attribute8           := NULL;
    END IF;

    IF g_SOU_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_SOU_rec.attribute9           := NULL;
    END IF;

    IF g_SOU_rec.context = FND_API.G_MISS_CHAR THEN
        g_SOU_rec.context              := NULL;
    END IF;

END Get_Flex_Sou;

--  Procedure Attributes

PROCEDURE Attributes
(   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SOU_REC
,   p_iteration                     IN  NUMBER := 1
,   x_SOU_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Sou_Rec_Type
)
IS
 g_p_SOU_rec        QP_Attr_Map_PUB.Sou_Rec_Type;
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

    --  Initialize g_SOU_rec

    g_SOU_rec := p_SOU_rec;

    --  Default missing attributes.

    IF g_SOU_rec.attribute_sourcing_id = FND_API.G_MISS_NUM THEN

        g_SOU_rec.attribute_sourcing_id := Get_Attribute_Sourcing;

        IF g_SOU_rec.attribute_sourcing_id IS NOT NULL THEN

            IF QP_Validate.Attribute_Sourcing(g_SOU_rec.attribute_sourcing_id)
            THEN
                g_p_SOU_rec := g_SOU_rec;
                QP_Sou_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Sou_Util.G_ATTRIBUTE_SOURCING
                ,   p_SOU_rec                     => g_p_SOU_rec
                ,   x_SOU_rec                     => g_SOU_rec
                );
            ELSE
                g_SOU_rec.attribute_sourcing_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SOU_rec.attribute_sourcing_level = FND_API.G_MISS_CHAR THEN

        g_SOU_rec.attribute_sourcing_level := Get_Attribute_Sourcing_Level;

        IF g_SOU_rec.attribute_sourcing_level IS NOT NULL THEN

            IF QP_Validate.Attribute_Sourcing_Level(g_SOU_rec.attribute_sourcing_level)
            THEN
                g_p_SOU_rec := g_SOU_rec;
                QP_Sou_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Sou_Util.G_ATTRIBUTE_SOURCING_LEVEL
                ,   p_SOU_rec                     => g_p_SOU_rec
                ,   x_SOU_rec                     => g_SOU_rec
                );
            ELSE
                g_SOU_rec.attribute_sourcing_level := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SOU_rec.application_id = FND_API.G_MISS_NUM THEN

        g_SOU_rec.application_id := Get_application_id;

        IF g_SOU_rec.application_id IS NOT NULL THEN

            IF QP_Validate.application_id(g_SOU_rec.application_id)
            THEN
                g_p_SOU_rec := g_SOU_rec;
                QP_Sou_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Sou_Util.G_APPLICATION_ID
                ,   p_SOU_rec                     => g_p_SOU_rec
                ,   x_SOU_rec                     => g_SOU_rec
                );
            ELSE
                g_SOU_rec.application_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SOU_rec.enabled_flag = FND_API.G_MISS_CHAR THEN

        g_SOU_rec.enabled_flag := Get_Enabled;

        IF g_SOU_rec.enabled_flag IS NOT NULL THEN

            IF QP_Validate.Enabled(g_SOU_rec.enabled_flag)
            THEN
                g_p_SOU_rec := g_SOU_rec;
                QP_Sou_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Sou_Util.G_ENABLED
                ,   p_SOU_rec                     => g_p_SOU_rec
                ,   x_SOU_rec                     => g_SOU_rec
                );
            ELSE
                g_SOU_rec.enabled_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SOU_rec.request_type_code = FND_API.G_MISS_CHAR THEN

        g_SOU_rec.request_type_code := Get_Request_Type;

        IF g_SOU_rec.request_type_code IS NOT NULL THEN

            IF QP_Validate.Request_Type(g_SOU_rec.request_type_code)
            THEN
                g_p_SOU_rec := g_SOU_rec;
                QP_Sou_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Sou_Util.G_REQUEST_TYPE
                ,   p_SOU_rec                     => g_p_SOU_rec
                ,   x_SOU_rec                     => g_SOU_rec
                );
            ELSE
                g_SOU_rec.request_type_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SOU_rec.seeded_flag = FND_API.G_MISS_CHAR THEN

        g_SOU_rec.seeded_flag := Get_Seeded;

        IF g_SOU_rec.seeded_flag IS NOT NULL THEN

            IF QP_Validate.Seeded(g_SOU_rec.seeded_flag)
            THEN
                g_p_SOU_rec := g_SOU_rec;
                QP_Sou_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Sou_Util.G_SEEDED
                ,   p_SOU_rec                     => g_p_SOU_rec
                ,   x_SOU_rec                     => g_SOU_rec
                );
            ELSE
                g_SOU_rec.seeded_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SOU_rec.seeded_sourcing_type = FND_API.G_MISS_CHAR THEN

        g_SOU_rec.seeded_sourcing_type := Get_Seeded_Sourcing_Type;

        IF g_SOU_rec.seeded_sourcing_type IS NOT NULL THEN

            IF QP_Validate.Seeded_Sourcing_Type(g_SOU_rec.seeded_sourcing_type)
            THEN
                g_p_SOU_rec := g_SOU_rec;
                QP_Sou_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Sou_Util.G_SEEDED_SOURCING_TYPE
                ,   p_SOU_rec                     => g_p_SOU_rec
                ,   x_SOU_rec                     => g_SOU_rec
                );
            ELSE
                g_SOU_rec.seeded_sourcing_type := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SOU_rec.seeded_value_string = FND_API.G_MISS_CHAR THEN

        g_SOU_rec.seeded_value_string := Get_Seeded_Value_String;

        IF g_SOU_rec.seeded_value_string IS NOT NULL THEN

            IF QP_Validate.Seeded_Value_String(g_SOU_rec.seeded_value_string)
            THEN
                g_p_SOU_rec := g_SOU_rec;
                QP_Sou_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Sou_Util.G_SEEDED_VALUE_STRING
                ,   p_SOU_rec                     => g_p_SOU_rec
                ,   x_SOU_rec                     => g_SOU_rec
                );
            ELSE
                g_SOU_rec.seeded_value_string := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SOU_rec.segment_id = FND_API.G_MISS_NUM THEN

        g_SOU_rec.segment_id := Get_Segment;

        IF g_SOU_rec.segment_id IS NOT NULL THEN

            IF QP_Validate.Segment(g_SOU_rec.segment_id)
            THEN
                g_p_SOU_rec := g_SOU_rec;
                QP_Sou_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Sou_Util.G_SEGMENT
                ,   p_SOU_rec                     => g_p_SOU_rec
                ,   x_SOU_rec                     => g_SOU_rec
                );
            ELSE
                g_SOU_rec.segment_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SOU_rec.user_sourcing_type = FND_API.G_MISS_CHAR THEN

        g_SOU_rec.user_sourcing_type := Get_User_Sourcing_Type;

        IF g_SOU_rec.user_sourcing_type IS NOT NULL THEN

            IF QP_Validate.User_Sourcing_Type(g_SOU_rec.user_sourcing_type)
            THEN
                g_p_SOU_rec := g_SOU_rec;
                QP_Sou_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Sou_Util.G_USER_SOURCING_TYPE
                ,   p_SOU_rec                     => g_p_SOU_rec
                ,   x_SOU_rec                     => g_SOU_rec
                );
            ELSE
                g_SOU_rec.user_sourcing_type := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SOU_rec.user_value_string = FND_API.G_MISS_CHAR THEN

        g_SOU_rec.user_value_string := Get_User_Value_String;

        IF g_SOU_rec.user_value_string IS NOT NULL THEN

            IF QP_Validate.User_Value_String(g_SOU_rec.user_value_string)
            THEN
                g_p_SOU_rec := g_SOU_rec;
                QP_Sou_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Sou_Util.G_USER_VALUE_STRING
                ,   p_SOU_rec                     => g_p_SOU_rec
                ,   x_SOU_rec                     => g_SOU_rec
                );
            ELSE
                g_SOU_rec.user_value_string := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SOU_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Sou;

    END IF;

    IF g_SOU_rec.created_by = FND_API.G_MISS_NUM THEN

        g_SOU_rec.created_by := NULL;

    END IF;

    IF g_SOU_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_SOU_rec.creation_date := NULL;

    END IF;

    IF g_SOU_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_SOU_rec.last_updated_by := NULL;

    END IF;

    IF g_SOU_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_SOU_rec.last_update_date := NULL;

    END IF;

    IF g_SOU_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_SOU_rec.last_update_login := NULL;

    END IF;

    IF g_SOU_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_SOU_rec.program_application_id := NULL;

    END IF;

    IF g_SOU_rec.program_id = FND_API.G_MISS_NUM THEN

        g_SOU_rec.program_id := NULL;

    END IF;

    IF g_SOU_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_SOU_rec.program_update_date := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_SOU_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.attribute_sourcing_id = FND_API.G_MISS_NUM
    OR  g_SOU_rec.attribute_sourcing_level = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.application_id = FND_API.G_MISS_NUM
    OR  g_SOU_rec.context = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.created_by = FND_API.G_MISS_NUM
    OR  g_SOU_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_SOU_rec.enabled_flag = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_SOU_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_SOU_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_SOU_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_SOU_rec.program_id = FND_API.G_MISS_NUM
    OR  g_SOU_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_SOU_rec.request_type_code = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.seeded_flag = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.seeded_sourcing_type = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.seeded_value_string = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.segment_id = FND_API.G_MISS_NUM
    OR  g_SOU_rec.user_sourcing_type = FND_API.G_MISS_CHAR
    OR  g_SOU_rec.user_value_string = FND_API.G_MISS_CHAR
    THEN

        QP_Default_Sou.Attributes
        (   p_SOU_rec                     => g_SOU_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_SOU_rec                     => x_SOU_rec
        );

    ELSE

        --  Done defaulting attributes

        x_SOU_rec := g_SOU_rec;

    END IF;

END Attributes;

END QP_Default_Sou;

/
