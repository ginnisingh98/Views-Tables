--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_FNA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_FNA" AS
/* $Header: QPXDFNAB.pls 120.2 2005/07/20 11:37:22 sfiresto noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Fna';

--  Package global used within the package.

g_FNA_rec                     QP_Attr_Map_PUB.Fna_Rec_Type;

--  Get functions.

FUNCTION Get_Enabled
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Enabled;

FUNCTION Get_Functional_Area
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Functional_Area;

FUNCTION Get_Pte_Sourcesystem_Fnarea
RETURN NUMBER
IS
l_pte_ss_fn NUMBER;
BEGIN
    select QP_PTE_SS_FNAREA_ID_S.nextval
    into l_pte_ss_fn
    from dual;

    RETURN l_pte_ss_fn;
END Get_Pte_Sourcesystem_Fnarea;

FUNCTION Get_Pte_Source_System
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Pte_Source_System;

FUNCTION Get_Seeded
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Seeded;

PROCEDURE Get_Flex_Fna
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_FNA_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_FNA_rec.attribute1           := NULL;
    END IF;

    IF g_FNA_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_FNA_rec.attribute10          := NULL;
    END IF;

    IF g_FNA_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_FNA_rec.attribute11          := NULL;
    END IF;

    IF g_FNA_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_FNA_rec.attribute12          := NULL;
    END IF;

    IF g_FNA_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_FNA_rec.attribute13          := NULL;
    END IF;

    IF g_FNA_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_FNA_rec.attribute14          := NULL;
    END IF;

    IF g_FNA_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_FNA_rec.attribute15          := NULL;
    END IF;

    IF g_FNA_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_FNA_rec.attribute2           := NULL;
    END IF;

    IF g_FNA_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_FNA_rec.attribute3           := NULL;
    END IF;

    IF g_FNA_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_FNA_rec.attribute4           := NULL;
    END IF;

    IF g_FNA_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_FNA_rec.attribute5           := NULL;
    END IF;

    IF g_FNA_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_FNA_rec.attribute6           := NULL;
    END IF;

    IF g_FNA_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_FNA_rec.attribute7           := NULL;
    END IF;

    IF g_FNA_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_FNA_rec.attribute8           := NULL;
    END IF;

    IF g_FNA_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_FNA_rec.attribute9           := NULL;
    END IF;

    IF g_FNA_rec.context = FND_API.G_MISS_CHAR THEN
        g_FNA_rec.context              := NULL;
    END IF;

END Get_Flex_Fna;

--  Procedure Attributes

PROCEDURE Attributes
(   p_FNA_rec                       IN  QP_Attr_Map_PUB.Fna_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_FNA_REC
,   p_iteration                     IN  NUMBER := 1
,   x_FNA_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Fna_Rec_Type
)
IS
  g_p_FNA_rec        QP_Attr_Map_PUB.Fna_Rec_Type;
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

    --  Initialize g_FNA_rec

    g_FNA_rec := p_FNA_rec;

    --  Default missing attributes.

    IF g_FNA_rec.enabled_flag = FND_API.G_MISS_CHAR THEN

        g_FNA_rec.enabled_flag := Get_Enabled;

        IF g_FNA_rec.enabled_flag IS NOT NULL THEN

            IF QP_Validate.Enabled(g_FNA_rec.enabled_flag)
            THEN
                g_p_FNA_rec := g_FNA_rec;
                QP_Fna_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Fna_Util.G_ENABLED
                ,   p_FNA_rec                     => g_p_FNA_rec
                ,   x_FNA_rec                     => g_FNA_rec
                );
            ELSE
                g_FNA_rec.enabled_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FNA_rec.functional_area_id = FND_API.G_MISS_NUM THEN

        g_FNA_rec.functional_area_id := Get_Functional_Area;

        IF g_FNA_rec.functional_area_id IS NOT NULL THEN

            IF QP_Validate.Functional_Area(g_FNA_rec.functional_area_id)
            THEN
                g_p_FNA_rec := g_FNA_rec;
                QP_Fna_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Fna_Util.G_FUNCTIONAL_AREA
                ,   p_FNA_rec                     => g_p_FNA_rec
                ,   x_FNA_rec                     => g_FNA_rec
                );
            ELSE
                g_FNA_rec.functional_area_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FNA_rec.pte_sourcesystem_fnarea_id = FND_API.G_MISS_NUM THEN

        g_FNA_rec.pte_sourcesystem_fnarea_id := Get_Pte_Sourcesystem_Fnarea;

        IF g_FNA_rec.pte_sourcesystem_fnarea_id IS NOT NULL THEN

            IF QP_Validate.Pte_Sourcesystem_Fnarea(g_FNA_rec.pte_sourcesystem_fnarea_id)
            THEN
               g_p_FNA_rec := g_FNA_rec;
               QP_Fna_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Fna_Util.G_PTE_SOURCESYSTEM_FNAREA
                ,   p_FNA_rec                     => g_p_FNA_rec
                ,   x_FNA_rec                     => g_FNA_rec
                );
            ELSE
                g_FNA_rec.pte_sourcesystem_fnarea_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FNA_rec.pte_source_system_id = FND_API.G_MISS_NUM THEN

        g_FNA_rec.pte_source_system_id := Get_Pte_Source_System;

        IF g_FNA_rec.pte_source_system_id IS NOT NULL THEN

            IF QP_Validate.Pte_Source_System(g_FNA_rec.pte_source_system_id)
            THEN
                g_p_FNA_rec := g_FNA_rec;
                QP_Fna_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Fna_Util.G_PTE_SOURCE_SYSTEM
                ,   p_FNA_rec                     => g_p_FNA_rec
                ,   x_FNA_rec                     => g_FNA_rec
                );
            ELSE
                g_FNA_rec.pte_source_system_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FNA_rec.seeded_flag = FND_API.G_MISS_CHAR THEN

        g_FNA_rec.seeded_flag := Get_Seeded;

        IF g_FNA_rec.seeded_flag IS NOT NULL THEN

            IF QP_Validate.Seeded(g_FNA_rec.seeded_flag)
            THEN
                g_p_FNA_rec := g_FNA_rec;
                QP_Fna_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Fna_Util.G_SEEDED
                ,   p_FNA_rec                     => g_p_FNA_rec
                ,   x_FNA_rec                     => g_FNA_rec
                );
            ELSE
                g_FNA_rec.seeded_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_FNA_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Fna;

    END IF;

    IF g_FNA_rec.created_by = FND_API.G_MISS_NUM THEN

        g_FNA_rec.created_by := NULL;

    END IF;

    IF g_FNA_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_FNA_rec.creation_date := NULL;

    END IF;

    IF g_FNA_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_FNA_rec.last_updated_by := NULL;

    END IF;

    IF g_FNA_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_FNA_rec.last_update_date := NULL;

    END IF;

    IF g_FNA_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_FNA_rec.last_update_login := NULL;

    END IF;

    IF g_FNA_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_FNA_rec.program_application_id := NULL;

    END IF;

    IF g_FNA_rec.program_id = FND_API.G_MISS_NUM THEN

        g_FNA_rec.program_id := NULL;

    END IF;

    IF g_FNA_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_FNA_rec.program_update_date := NULL;

    END IF;

    IF g_FNA_rec.request_id = FND_API.G_MISS_NUM THEN

        g_FNA_rec.request_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_FNA_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.context = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.created_by = FND_API.G_MISS_NUM
    OR  g_FNA_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_FNA_rec.enabled_flag = FND_API.G_MISS_CHAR
    OR  g_FNA_rec.functional_area_id = FND_API.G_MISS_NUM
    OR  g_FNA_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_FNA_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_FNA_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_FNA_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_FNA_rec.program_id = FND_API.G_MISS_NUM
    OR  g_FNA_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_FNA_rec.pte_sourcesystem_fnarea_id = FND_API.G_MISS_NUM
    OR  g_FNA_rec.pte_source_system_id = FND_API.G_MISS_NUM
    OR  g_FNA_rec.request_id = FND_API.G_MISS_NUM
    OR  g_FNA_rec.seeded_flag = FND_API.G_MISS_CHAR
    THEN

        QP_Default_Fna.Attributes
        (   p_FNA_rec                     => g_FNA_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_FNA_rec                     => x_FNA_rec
        );

    ELSE

        --  Done defaulting attributes

        x_FNA_rec := g_FNA_rec;

    END IF;

END Attributes;

END QP_Default_Fna;

/
