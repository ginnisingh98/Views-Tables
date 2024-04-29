--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_SSC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_SSC" AS
/* $Header: QPXDSSCB.pls 120.2 2005/07/06 04:30:25 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Ssc';

--  Package global used within the package.

g_SSC_rec                     QP_Attr_Map_PUB.Ssc_Rec_Type;

--  Get functions.

FUNCTION Get_Application_Short_Name
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Application_Short_Name;

FUNCTION Get_Enabled
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Enabled;

FUNCTION Get_Pte
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pte;

FUNCTION Get_Pte_Source_System
RETURN NUMBER
IS
  l_pte_source_system_id   number(15);
BEGIN
    select qp_pte_source_system_s.nextval
    into l_pte_source_system_id
    from dual;
    RETURN (l_pte_source_system_id);

END Get_Pte_Source_System;

PROCEDURE Get_Flex_Ssc
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_SSC_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_SSC_rec.attribute1           := NULL;
    END IF;

    IF g_SSC_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_SSC_rec.attribute10          := NULL;
    END IF;

    IF g_SSC_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_SSC_rec.attribute11          := NULL;
    END IF;

    IF g_SSC_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_SSC_rec.attribute12          := NULL;
    END IF;

    IF g_SSC_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_SSC_rec.attribute13          := NULL;
    END IF;

    IF g_SSC_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_SSC_rec.attribute14          := NULL;
    END IF;

    IF g_SSC_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_SSC_rec.attribute15          := NULL;
    END IF;

    IF g_SSC_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_SSC_rec.attribute2           := NULL;
    END IF;

    IF g_SSC_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_SSC_rec.attribute3           := NULL;
    END IF;

    IF g_SSC_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_SSC_rec.attribute4           := NULL;
    END IF;

    IF g_SSC_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_SSC_rec.attribute5           := NULL;
    END IF;

    IF g_SSC_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_SSC_rec.attribute6           := NULL;
    END IF;

    IF g_SSC_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_SSC_rec.attribute7           := NULL;
    END IF;

    IF g_SSC_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_SSC_rec.attribute8           := NULL;
    END IF;

    IF g_SSC_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_SSC_rec.attribute9           := NULL;
    END IF;

    IF g_SSC_rec.context = FND_API.G_MISS_CHAR THEN
        g_SSC_rec.context              := NULL;
    END IF;

END Get_Flex_Ssc;

--  Procedure Attributes

PROCEDURE Attributes
(   p_SSC_rec                       IN  QP_Attr_Map_PUB.Ssc_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SSC_REC
,   p_iteration                     IN  NUMBER := 1
,   x_SSC_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Ssc_Rec_Type
)
IS
 g_p_SSC_rec         QP_Attr_Map_PUB.Ssc_Rec_Type;
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

    --  Initialize g_SSC_rec

    g_SSC_rec := p_SSC_rec;

    --  Default missing attributes.

    IF g_SSC_rec.application_short_name = FND_API.G_MISS_CHAR THEN

        g_SSC_rec.application_short_name := Get_Application_Short_Name;

        IF g_SSC_rec.application_short_name IS NOT NULL THEN

            IF QP_Validate.Application_Short_Name(g_SSC_rec.application_short_name)
            THEN
                g_p_SSC_rec := g_SSC_rec;
                QP_Ssc_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Ssc_Util.G_APPLICATION_SHORT_NAME
                ,   p_SSC_rec                     => g_p_SSC_rec
                ,   x_SSC_rec                     => g_SSC_rec
                );
            ELSE
                g_SSC_rec.application_short_name := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SSC_rec.enabled_flag = FND_API.G_MISS_CHAR THEN

        g_SSC_rec.enabled_flag := Get_Enabled;

        IF g_SSC_rec.enabled_flag IS NOT NULL THEN

            IF QP_Validate.Enabled(g_SSC_rec.enabled_flag)
            THEN
                g_p_SSC_rec := g_SSC_rec;
                QP_Ssc_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Ssc_Util.G_ENABLED
                ,   p_SSC_rec                     => g_p_SSC_rec
                ,   x_SSC_rec                     => g_SSC_rec
                );
            ELSE
                g_SSC_rec.enabled_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SSC_rec.pte_code = FND_API.G_MISS_CHAR THEN

        g_SSC_rec.pte_code := Get_Pte;

        IF g_SSC_rec.pte_code IS NOT NULL THEN

            IF QP_Validate.Pte(g_SSC_rec.pte_code)
            THEN
                g_p_SSC_rec := g_SSC_rec;
                QP_Ssc_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Ssc_Util.G_PTE
                ,   p_SSC_rec                     => g_p_SSC_rec
                ,   x_SSC_rec                     => g_SSC_rec
                );
            ELSE
                g_SSC_rec.pte_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SSC_rec.pte_source_system_id = FND_API.G_MISS_NUM THEN

        g_SSC_rec.pte_source_system_id := Get_Pte_Source_System;

        IF g_SSC_rec.pte_source_system_id IS NOT NULL THEN

            IF QP_Validate.Pte_Source_System(g_SSC_rec.pte_source_system_id)
            THEN
                g_p_SSC_rec := g_SSC_rec;
                QP_Ssc_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Ssc_Util.G_PTE_SOURCE_SYSTEM
                ,   p_SSC_rec                     => g_p_SSC_rec
                ,   x_SSC_rec                     => g_SSC_rec
                );
            ELSE
                g_SSC_rec.pte_source_system_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SSC_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Ssc;

    END IF;

    IF g_SSC_rec.created_by = FND_API.G_MISS_NUM THEN

        g_SSC_rec.created_by := NULL;

    END IF;

    IF g_SSC_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_SSC_rec.creation_date := NULL;

    END IF;

    IF g_SSC_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_SSC_rec.last_updated_by := NULL;

    END IF;

    IF g_SSC_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_SSC_rec.last_update_date := NULL;

    END IF;

    IF g_SSC_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_SSC_rec.last_update_login := NULL;

    END IF;

    IF g_SSC_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_SSC_rec.program_application_id := NULL;

    END IF;

    IF g_SSC_rec.program_id = FND_API.G_MISS_NUM THEN

        g_SSC_rec.program_id := NULL;

    END IF;

    IF g_SSC_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_SSC_rec.program_update_date := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_SSC_rec.application_short_name = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.context = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.created_by = FND_API.G_MISS_NUM
    OR  g_SSC_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_SSC_rec.enabled_flag = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_SSC_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_SSC_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_SSC_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_SSC_rec.program_id = FND_API.G_MISS_NUM
    OR  g_SSC_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_SSC_rec.pte_code = FND_API.G_MISS_CHAR
    OR  g_SSC_rec.pte_source_system_id = FND_API.G_MISS_NUM
    THEN

        QP_Default_Ssc.Attributes
        (   p_SSC_rec                     => g_SSC_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_SSC_rec                     => x_SSC_rec
        );

    ELSE

        --  Done defaulting attributes

        x_SSC_rec := g_SSC_rec;

    END IF;

END Attributes;

END QP_Default_Ssc;

/
