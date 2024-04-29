--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_CON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_CON" AS
/* $Header: QPXDCONB.pls 120.2 2005/07/06 04:51:29 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Con';

--  Package global used within the package.

g_CON_rec                     QP_Attributes_PUB.Con_Rec_Type;

--  Get functions.

FUNCTION Get_Enabled
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Enabled;

FUNCTION Get_Prc_Context_code
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Prc_Context_code;

FUNCTION Get_Prc_Context
RETURN NUMBER
IS
  l_prc_context_id   number(15);
BEGIN
    select qp_prc_contexts_s.nextval
    into l_prc_context_id
    from dual;
    RETURN (l_prc_context_id);

END Get_Prc_Context;

FUNCTION Get_Prc_Context_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Prc_Context_Type;

FUNCTION Get_Seeded_Description
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Seeded_Description;

FUNCTION Get_Seeded
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Seeded;

FUNCTION Get_Seeded_Prc_Context_Name
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Seeded_Prc_Context_Name;

FUNCTION Get_User_Description
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_User_Description;

FUNCTION Get_User_Prc_Context_Name
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_User_Prc_Context_Name;

PROCEDURE Get_Flex_Con
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_CON_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_CON_rec.attribute1           := NULL;
    END IF;

    IF g_CON_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_CON_rec.attribute10          := NULL;
    END IF;

    IF g_CON_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_CON_rec.attribute11          := NULL;
    END IF;

    IF g_CON_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_CON_rec.attribute12          := NULL;
    END IF;

    IF g_CON_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_CON_rec.attribute13          := NULL;
    END IF;

    IF g_CON_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_CON_rec.attribute14          := NULL;
    END IF;

    IF g_CON_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_CON_rec.attribute15          := NULL;
    END IF;

    IF g_CON_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_CON_rec.attribute2           := NULL;
    END IF;

    IF g_CON_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_CON_rec.attribute3           := NULL;
    END IF;

    IF g_CON_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_CON_rec.attribute4           := NULL;
    END IF;

    IF g_CON_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_CON_rec.attribute5           := NULL;
    END IF;

    IF g_CON_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_CON_rec.attribute6           := NULL;
    END IF;

    IF g_CON_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_CON_rec.attribute7           := NULL;
    END IF;

    IF g_CON_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_CON_rec.attribute8           := NULL;
    END IF;

    IF g_CON_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_CON_rec.attribute9           := NULL;
    END IF;

    IF g_CON_rec.context = FND_API.G_MISS_CHAR THEN
        g_CON_rec.context              := NULL;
    END IF;

END Get_Flex_Con;

--  Procedure Attributes

PROCEDURE Attributes
(   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_CON_REC
,   p_iteration                     IN  NUMBER := 1
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Con_Rec_Type
)
IS
 g_p_CON_rec       QP_Attributes_PUB.Con_Rec_Type;
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

    --  Initialize g_CON_rec

    g_CON_rec := p_CON_rec;

    --  Default missing attributes.

    IF g_CON_rec.enabled_flag = FND_API.G_MISS_CHAR THEN

        g_CON_rec.enabled_flag := Get_Enabled;

        IF g_CON_rec.enabled_flag IS NOT NULL THEN

            IF QP_Validate.Enabled(g_CON_rec.enabled_flag)
            THEN
                g_p_CON_rec := g_CON_rec;
                QP_Con_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Con_Util.G_ENABLED
                ,   p_CON_rec                     => g_p_CON_rec
                ,   x_CON_rec                     => g_CON_rec
                );
            ELSE
                g_CON_rec.enabled_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CON_rec.prc_context_code = FND_API.G_MISS_CHAR THEN

        g_CON_rec.prc_context_code := Get_Prc_Context_code;

        IF g_CON_rec.prc_context_code IS NOT NULL THEN

            IF QP_Validate.Prc_Context_code(g_CON_rec.prc_context_code)
            THEN
                g_p_CON_rec := g_CON_rec;
                QP_Con_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Con_Util.G_PRC_CONTEXT_code
                ,   p_CON_rec                     => g_p_CON_rec
                ,   x_CON_rec                     => g_CON_rec
                );
            ELSE
                g_CON_rec.prc_context_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CON_rec.prc_context_id = FND_API.G_MISS_NUM THEN

        g_CON_rec.prc_context_id := Get_Prc_Context;

        IF g_CON_rec.prc_context_id IS NOT NULL THEN

            IF QP_Validate.Prc_Context(g_CON_rec.prc_context_id)
            THEN
                g_p_CON_rec := g_CON_rec;
                QP_Con_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Con_Util.G_PRC_CONTEXT
                ,   p_CON_rec                     => g_p_CON_rec
                ,   x_CON_rec                     => g_CON_rec
                );
            ELSE
                g_CON_rec.prc_context_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CON_rec.prc_context_type = FND_API.G_MISS_CHAR THEN

        g_CON_rec.prc_context_type := Get_Prc_Context_Type;

        IF g_CON_rec.prc_context_type IS NOT NULL THEN

            IF QP_Validate.Prc_Context_Type(g_CON_rec.prc_context_type)
            THEN
                g_p_CON_rec := g_CON_rec;
                QP_Con_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Con_Util.G_PRC_CONTEXT_TYPE
                ,   p_CON_rec                     => g_p_CON_rec
                ,   x_CON_rec                     => g_CON_rec
                );
            ELSE
                g_CON_rec.prc_context_type := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CON_rec.seeded_description = FND_API.G_MISS_CHAR THEN

        g_CON_rec.seeded_description := Get_Seeded_Description;

        IF g_CON_rec.seeded_description IS NOT NULL THEN

            IF QP_Validate.Seeded_Description(g_CON_rec.seeded_description)
            THEN
                g_p_CON_rec := g_CON_rec;
                QP_Con_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Con_Util.G_SEEDED_DESCRIPTION
                ,   p_CON_rec                     => g_p_CON_rec
                ,   x_CON_rec                     => g_CON_rec
                );
            ELSE
                g_CON_rec.seeded_description := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CON_rec.seeded_flag = FND_API.G_MISS_CHAR THEN

        g_CON_rec.seeded_flag := Get_Seeded;

        IF g_CON_rec.seeded_flag IS NOT NULL THEN

            IF QP_Validate.Seeded(g_CON_rec.seeded_flag)
            THEN
                g_p_CON_rec := g_CON_rec;
                QP_Con_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Con_Util.G_SEEDED
                ,   p_CON_rec                     => g_p_CON_rec
                ,   x_CON_rec                     => g_CON_rec
                );
            ELSE
                g_CON_rec.seeded_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CON_rec.seeded_prc_context_name = FND_API.G_MISS_CHAR THEN

        g_CON_rec.seeded_prc_context_name := Get_Seeded_Prc_Context_Name;

        IF g_CON_rec.seeded_prc_context_name IS NOT NULL THEN

            IF QP_Validate.Seeded_Prc_Context_Name(g_CON_rec.seeded_prc_context_name)
            THEN
                g_p_CON_rec := g_CON_rec;
                QP_Con_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Con_Util.G_SEEDED_PRC_CONTEXT_NAME
                ,   p_CON_rec                     => g_p_CON_rec
                ,   x_CON_rec                     => g_CON_rec
                );
            ELSE
                g_CON_rec.seeded_prc_context_name := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CON_rec.user_description = FND_API.G_MISS_CHAR THEN

        g_CON_rec.user_description := Get_User_Description;

        IF g_CON_rec.user_description IS NOT NULL THEN

            IF QP_Validate.User_Description(g_CON_rec.user_description)
            THEN
                g_p_CON_rec := g_CON_rec;
                QP_Con_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Con_Util.G_USER_DESCRIPTION
                ,   p_CON_rec                     => g_p_CON_rec
                ,   x_CON_rec                     => g_CON_rec
                );
            ELSE
                g_CON_rec.user_description := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CON_rec.user_prc_context_name = FND_API.G_MISS_CHAR THEN

        g_CON_rec.user_prc_context_name := Get_User_Prc_Context_Name;

        IF g_CON_rec.user_prc_context_name IS NOT NULL THEN

            IF QP_Validate.User_Prc_Context_Name(g_CON_rec.user_prc_context_name)
            THEN
                g_p_CON_rec := g_CON_rec;
                QP_Con_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Con_Util.G_USER_PRC_CONTEXT_NAME
                ,   p_CON_rec                     => g_p_CON_rec
                ,   x_CON_rec                     => g_CON_rec
                );
            ELSE
                g_CON_rec.user_prc_context_name := NULL;
            END IF;

        END IF;

    END IF;

    IF g_CON_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Con;

    END IF;

    IF g_CON_rec.created_by = FND_API.G_MISS_NUM THEN

        g_CON_rec.created_by := NULL;

    END IF;

    IF g_CON_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_CON_rec.creation_date := NULL;

    END IF;

    IF g_CON_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_CON_rec.last_updated_by := NULL;

    END IF;

    IF g_CON_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_CON_rec.last_update_date := NULL;

    END IF;

    IF g_CON_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_CON_rec.last_update_login := NULL;

    END IF;

    IF g_CON_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_CON_rec.program_application_id := NULL;

    END IF;

    IF g_CON_rec.program_id = FND_API.G_MISS_NUM THEN

        g_CON_rec.program_id := NULL;

    END IF;

    IF g_CON_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_CON_rec.program_update_date := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_CON_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_CON_rec.context = FND_API.G_MISS_CHAR
    OR  g_CON_rec.created_by = FND_API.G_MISS_NUM
    OR  g_CON_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_CON_rec.enabled_flag = FND_API.G_MISS_CHAR
    OR  g_CON_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_CON_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_CON_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_CON_rec.prc_context_code = FND_API.G_MISS_CHAR
    OR  g_CON_rec.prc_context_id = FND_API.G_MISS_NUM
    OR  g_CON_rec.prc_context_type = FND_API.G_MISS_CHAR
    OR  g_CON_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_CON_rec.program_id = FND_API.G_MISS_NUM
    OR  g_CON_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_CON_rec.seeded_description = FND_API.G_MISS_CHAR
    OR  g_CON_rec.seeded_flag = FND_API.G_MISS_CHAR
    OR  g_CON_rec.seeded_prc_context_name = FND_API.G_MISS_CHAR
    OR  g_CON_rec.user_description = FND_API.G_MISS_CHAR
    OR  g_CON_rec.user_prc_context_name = FND_API.G_MISS_CHAR
    THEN

        QP_Default_Con.Attributes
        (   p_CON_rec                     => g_CON_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_CON_rec                     => x_CON_rec
        );

    ELSE

        --  Done defaulting attributes

        x_CON_rec := g_CON_rec;

    END IF;

END Attributes;

END QP_Default_Con;

/
