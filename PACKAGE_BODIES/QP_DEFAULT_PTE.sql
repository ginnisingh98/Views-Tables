--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_PTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_PTE" AS
/* $Header: QPXDPTEB.pls 120.2 2005/07/06 04:23:59 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Pte';

--  Package global used within the package.

g_PTE_rec                     QP_Attr_Map_PUB.Pte_Rec_Type;

--  Get functions.

FUNCTION Get_Description
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Description;

FUNCTION Get_Enabled
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Enabled;

FUNCTION Get_End_Date_Active
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_End_Date_Active;

FUNCTION Get_Lookup
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Lookup;

FUNCTION Get_Lookup_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Lookup_Type;

FUNCTION Get_Meaning
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Meaning;

FUNCTION Get_Start_Date_Active
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_Start_Date_Active;

--  Procedure Attributes

PROCEDURE Attributes
(   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PTE_REC
,   p_iteration                     IN  NUMBER := 1
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Pte_Rec_Type
)
IS
 g_p_PTE_rec       QP_Attr_Map_PUB.Pte_Rec_Type;
BEGIN

    --  Check number of iterations.

    IF p_iteration > QP_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_DEF_MAX_ITERATION');
            FND_MSG_PUB.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Initialize g_PTE_rec

    g_PTE_rec := p_PTE_rec;

    --  Default missing attributes.

    IF g_PTE_rec.description = FND_API.G_MISS_CHAR THEN

        g_PTE_rec.description := Get_Description;

        IF g_PTE_rec.description IS NOT NULL THEN

            IF QP_Validate.Description(g_PTE_rec.description)
            THEN
                g_p_PTE_rec := g_PTE_rec;
                QP_Pte_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Pte_Util.G_DESCRIPTION
                ,   p_PTE_rec                     => g_p_PTE_rec
                ,   x_PTE_rec                     => g_PTE_rec
                );
            ELSE
                g_PTE_rec.description := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PTE_rec.enabled_flag = FND_API.G_MISS_CHAR THEN

        g_PTE_rec.enabled_flag := Get_Enabled;

        IF g_PTE_rec.enabled_flag IS NOT NULL THEN

            IF QP_Validate.Enabled(g_PTE_rec.enabled_flag)
            THEN
                g_p_PTE_rec := g_PTE_rec;
                QP_Pte_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Pte_Util.G_ENABLED
                ,   p_PTE_rec                     => g_p_PTE_rec
                ,   x_PTE_rec                     => g_PTE_rec
                );
            ELSE
                g_PTE_rec.enabled_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PTE_rec.end_date_active = FND_API.G_MISS_DATE THEN

        g_PTE_rec.end_date_active := Get_End_Date_Active;

        IF g_PTE_rec.end_date_active IS NOT NULL THEN

            IF QP_Validate.End_Date_Active(g_PTE_rec.end_date_active)
            THEN
                g_p_PTE_rec := g_PTE_rec;
                QP_Pte_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Pte_Util.G_END_DATE_ACTIVE
                ,   p_PTE_rec                     => g_p_PTE_rec
                ,   x_PTE_rec                     => g_PTE_rec
                );
            ELSE
                g_PTE_rec.end_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PTE_rec.lookup_code = FND_API.G_MISS_CHAR THEN

        g_PTE_rec.lookup_code := Get_Lookup;

        IF g_PTE_rec.lookup_code IS NOT NULL THEN

            IF QP_Validate.Lookup(g_PTE_rec.lookup_code)
            THEN
                g_p_PTE_rec := g_PTE_rec;
                QP_Pte_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Pte_Util.G_LOOKUP
                ,   p_PTE_rec                     => g_p_PTE_rec
                ,   x_PTE_rec                     => g_PTE_rec
                );
            ELSE
                g_PTE_rec.lookup_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PTE_rec.lookup_type = FND_API.G_MISS_CHAR THEN

        g_PTE_rec.lookup_type := Get_Lookup_Type;

        IF g_PTE_rec.lookup_type IS NOT NULL THEN

            IF QP_Validate.Lookup_Type(g_PTE_rec.lookup_type)
            THEN
                g_p_PTE_rec := g_PTE_rec;
                QP_Pte_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Pte_Util.G_LOOKUP_TYPE
                ,   p_PTE_rec                     => g_p_PTE_rec
                ,   x_PTE_rec                     => g_PTE_rec
                );
            ELSE
                g_PTE_rec.lookup_type := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PTE_rec.meaning = FND_API.G_MISS_CHAR THEN

        g_PTE_rec.meaning := Get_Meaning;

        IF g_PTE_rec.meaning IS NOT NULL THEN

            IF QP_Validate.Meaning(g_PTE_rec.meaning)
            THEN
                g_p_PTE_rec := g_PTE_rec;
                QP_Pte_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Pte_Util.G_MEANING
                ,   p_PTE_rec                     => g_p_PTE_rec
                ,   x_PTE_rec                     => g_PTE_rec
                );
            ELSE
                g_PTE_rec.meaning := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PTE_rec.start_date_active = FND_API.G_MISS_DATE THEN

        g_PTE_rec.start_date_active := Get_Start_Date_Active;

        IF g_PTE_rec.start_date_active IS NOT NULL THEN

            IF QP_Validate.Start_Date_Active(g_PTE_rec.start_date_active)
            THEN
                g_p_PTE_rec := g_PTE_rec;
                QP_Pte_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Pte_Util.G_START_DATE_ACTIVE
                ,   p_PTE_rec                     => g_p_PTE_rec
                ,   x_PTE_rec                     => g_PTE_rec
                );
            ELSE
                g_PTE_rec.start_date_active := NULL;
            END IF;

        END IF;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_PTE_rec.description = FND_API.G_MISS_CHAR
    OR  g_PTE_rec.enabled_flag = FND_API.G_MISS_CHAR
    OR  g_PTE_rec.end_date_active = FND_API.G_MISS_DATE
    OR  g_PTE_rec.lookup_code = FND_API.G_MISS_CHAR
    OR  g_PTE_rec.lookup_type = FND_API.G_MISS_CHAR
    OR  g_PTE_rec.meaning = FND_API.G_MISS_CHAR
    OR  g_PTE_rec.start_date_active = FND_API.G_MISS_DATE
    THEN

        QP_Default_Pte.Attributes
        (   p_PTE_rec                     => g_PTE_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_PTE_rec                     => x_PTE_rec
        );

    ELSE

        --  Done defaulting attributes

        x_PTE_rec := g_PTE_rec;

    END IF;

END Attributes;

END QP_Default_Pte;

/
