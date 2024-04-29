--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_PSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_PSG" AS
/* $Header: QPXDPSGB.pls 120.2 2005/07/06 04:31:33 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Psg';

--  Package global used within the package.

g_PSG_rec                     QP_Attr_Map_PUB.Psg_Rec_Type;

--  Get functions.

FUNCTION Get_Limits_Enabled
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Limits_Enabled;

FUNCTION Get_Lov_Enabled
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Lov_Enabled;

FUNCTION Get_Pte
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pte;

FUNCTION Get_Seeded_Sourcing_Method
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Seeded_Sourcing_Method;

FUNCTION Get_Segment
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Segment;

FUNCTION Get_Segment_Level
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Segment_Level;

FUNCTION Get_Segment_Pte
RETURN NUMBER
IS
  l_segment_pte_id   number(15);
BEGIN
    select qp_pte_segments_s.nextval
    into l_segment_pte_id
    from dual;
    RETURN (l_segment_pte_id);

END Get_Segment_Pte;

FUNCTION Get_Sourcing_Enabled
RETURN VARCHAR2
IS
BEGIN
    RETURN NULL;

END Get_Sourcing_Enabled;

FUNCTION Get_Sourcing_Status
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Sourcing_Status;

FUNCTION Get_User_Sourcing_Method
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_User_Sourcing_Method;

PROCEDURE Get_Flex_Psg
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_PSG_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_PSG_rec.attribute1           := NULL;
    END IF;

    IF g_PSG_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_PSG_rec.attribute10          := NULL;
    END IF;

    IF g_PSG_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_PSG_rec.attribute11          := NULL;
    END IF;

    IF g_PSG_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_PSG_rec.attribute12          := NULL;
    END IF;

    IF g_PSG_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_PSG_rec.attribute13          := NULL;
    END IF;

    IF g_PSG_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_PSG_rec.attribute14          := NULL;
    END IF;

    IF g_PSG_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_PSG_rec.attribute15          := NULL;
    END IF;

    IF g_PSG_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_PSG_rec.attribute2           := NULL;
    END IF;

    IF g_PSG_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_PSG_rec.attribute3           := NULL;
    END IF;

    IF g_PSG_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_PSG_rec.attribute4           := NULL;
    END IF;

    IF g_PSG_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_PSG_rec.attribute5           := NULL;
    END IF;

    IF g_PSG_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_PSG_rec.attribute6           := NULL;
    END IF;

    IF g_PSG_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_PSG_rec.attribute7           := NULL;
    END IF;

    IF g_PSG_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_PSG_rec.attribute8           := NULL;
    END IF;

    IF g_PSG_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_PSG_rec.attribute9           := NULL;
    END IF;

    IF g_PSG_rec.context = FND_API.G_MISS_CHAR THEN
        g_PSG_rec.context              := NULL;
    END IF;

END Get_Flex_Psg;

--  Procedure Attributes

PROCEDURE Attributes
(   p_PSG_rec                       IN  QP_Attr_Map_PUB.Psg_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PSG_REC
,   p_iteration                     IN  NUMBER := 1
,   x_PSG_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Psg_Rec_Type
)
IS
 g_p_PSG_rec         QP_Attr_Map_PUB.Psg_Rec_Type;
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

    --  Initialize g_PSG_rec

    g_PSG_rec := p_PSG_rec;

    --  Default missing attributes.

    IF g_PSG_rec.limits_enabled = FND_API.G_MISS_CHAR THEN

        g_PSG_rec.limits_enabled := Get_Limits_Enabled;

        IF g_PSG_rec.limits_enabled IS NOT NULL THEN

            IF QP_Validate.Limits_Enabled(g_PSG_rec.limits_enabled)
            THEN
                g_p_PSG_rec := g_PSG_rec;
                QP_Psg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Psg_Util.G_LIMITS_ENABLED
                ,   p_PSG_rec                     => g_p_PSG_rec
                ,   x_PSG_rec                     => g_PSG_rec
                );
            ELSE
                g_PSG_rec.limits_enabled := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PSG_rec.lov_enabled = FND_API.G_MISS_CHAR THEN

        g_PSG_rec.lov_enabled := Get_Lov_Enabled;

        IF g_PSG_rec.lov_enabled IS NOT NULL THEN

            IF QP_Validate.Lov_Enabled(g_PSG_rec.lov_enabled)
            THEN
                g_p_PSG_rec := g_PSG_rec;
                QP_Psg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Psg_Util.G_LOV_ENABLED
                ,   p_PSG_rec                     => g_p_PSG_rec
                ,   x_PSG_rec                     => g_PSG_rec
                );
            ELSE
                g_PSG_rec.lov_enabled := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PSG_rec.pte_code = FND_API.G_MISS_CHAR THEN

        g_PSG_rec.pte_code := Get_Pte;

        IF g_PSG_rec.pte_code IS NOT NULL THEN

            IF QP_Validate.Pte(g_PSG_rec.pte_code)
            THEN
                g_p_PSG_rec := g_PSG_rec;
                QP_Psg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Psg_Util.G_PTE
                ,   p_PSG_rec                     => g_p_PSG_rec
                ,   x_PSG_rec                     => g_PSG_rec
                );
            ELSE
                g_PSG_rec.pte_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PSG_rec.seeded_sourcing_method = FND_API.G_MISS_CHAR THEN

        g_PSG_rec.seeded_sourcing_method := Get_Seeded_Sourcing_Method;

        IF g_PSG_rec.seeded_sourcing_method IS NOT NULL THEN

            IF QP_Validate.Seeded_Sourcing_Method(g_PSG_rec.seeded_sourcing_method)
            THEN
                g_p_PSG_rec := g_PSG_rec;
                QP_Psg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Psg_Util.G_SEEDED_SOURCING_METHOD
                ,   p_PSG_rec                     => g_p_PSG_rec
                ,   x_PSG_rec                     => g_PSG_rec
                );
            ELSE
                g_PSG_rec.seeded_sourcing_method := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PSG_rec.segment_id = FND_API.G_MISS_NUM THEN

        g_PSG_rec.segment_id := Get_Segment;

        IF g_PSG_rec.segment_id IS NOT NULL THEN

            IF QP_Validate.Segment(g_PSG_rec.segment_id)
            THEN
                g_p_PSG_rec := g_PSG_rec;
                QP_Psg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Psg_Util.G_SEGMENT
                ,   p_PSG_rec                     => g_p_PSG_rec
                ,   x_PSG_rec                     => g_PSG_rec
                );
            ELSE
                g_PSG_rec.segment_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PSG_rec.segment_level = FND_API.G_MISS_CHAR THEN

        g_PSG_rec.segment_level := Get_Segment_Level;

        IF g_PSG_rec.segment_level IS NOT NULL THEN

            IF QP_Validate.Segment_Level(g_PSG_rec.segment_level)
            THEN
                g_p_PSG_rec := g_PSG_rec;
                QP_Psg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Psg_Util.G_SEGMENT_LEVEL
                ,   p_PSG_rec                     => g_p_PSG_rec
                ,   x_PSG_rec                     => g_PSG_rec
                );
            ELSE
                g_PSG_rec.segment_level := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PSG_rec.segment_pte_id = FND_API.G_MISS_NUM THEN

        g_PSG_rec.segment_pte_id := Get_Segment_Pte;

        IF g_PSG_rec.segment_pte_id IS NOT NULL THEN

            IF QP_Validate.Segment_Pte(g_PSG_rec.segment_pte_id)
            THEN
                g_p_PSG_rec := g_PSG_rec;
                QP_Psg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Psg_Util.G_SEGMENT_PTE
                ,   p_PSG_rec                     => g_p_PSG_rec
                ,   x_PSG_rec                     => g_PSG_rec
                );
            ELSE
                g_PSG_rec.segment_pte_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PSG_rec.sourcing_enabled = FND_API.G_MISS_CHAR THEN

        g_PSG_rec.sourcing_enabled := Get_Sourcing_Enabled;

        IF g_PSG_rec.sourcing_enabled IS NOT NULL THEN

            IF QP_Validate.Sourcing_Enabled(g_PSG_rec.sourcing_enabled)
            THEN
                g_p_PSG_rec := g_PSG_rec;
                QP_Psg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Psg_Util.G_SOURCING_ENABLED
                ,   p_PSG_rec                     => g_p_PSG_rec
                ,   x_PSG_rec                     => g_PSG_rec
                );
            ELSE
                g_PSG_rec.sourcing_enabled := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PSG_rec.sourcing_status = FND_API.G_MISS_CHAR THEN

        g_PSG_rec.sourcing_status := Get_Sourcing_Status;

        IF g_PSG_rec.sourcing_status IS NOT NULL THEN

            IF QP_Validate.Sourcing_Status(g_PSG_rec.sourcing_status)
            THEN
                g_p_PSG_rec := g_PSG_rec;
                QP_Psg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Psg_Util.G_SOURCING_STATUS
                ,   p_PSG_rec                     => g_p_PSG_rec
                ,   x_PSG_rec                     => g_PSG_rec
                );
            ELSE
                g_PSG_rec.sourcing_status := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PSG_rec.user_sourcing_method = FND_API.G_MISS_CHAR THEN

        g_PSG_rec.user_sourcing_method := Get_User_Sourcing_Method;

        IF g_PSG_rec.user_sourcing_method IS NOT NULL THEN

            IF QP_Validate.User_Sourcing_Method(g_PSG_rec.user_sourcing_method)
            THEN
                g_p_PSG_rec := g_PSG_rec;
                QP_Psg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Psg_Util.G_USER_SOURCING_METHOD
                ,   p_PSG_rec                     => g_p_PSG_rec
                ,   x_PSG_rec                     => g_PSG_rec
                );
            ELSE
                g_PSG_rec.user_sourcing_method := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PSG_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Psg;

    END IF;

    IF g_PSG_rec.created_by = FND_API.G_MISS_NUM THEN

        g_PSG_rec.created_by := NULL;

    END IF;

    IF g_PSG_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_PSG_rec.creation_date := NULL;

    END IF;

    IF g_PSG_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_PSG_rec.last_updated_by := NULL;

    END IF;

    IF g_PSG_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_PSG_rec.last_update_date := NULL;

    END IF;

    IF g_PSG_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_PSG_rec.last_update_login := NULL;

    END IF;

    IF g_PSG_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_PSG_rec.program_application_id := NULL;

    END IF;

    IF g_PSG_rec.program_id = FND_API.G_MISS_NUM THEN

        g_PSG_rec.program_id := NULL;

    END IF;

    IF g_PSG_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_PSG_rec.program_update_date := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_PSG_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.context = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.created_by = FND_API.G_MISS_NUM
    OR  g_PSG_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_PSG_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_PSG_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_PSG_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_PSG_rec.limits_enabled = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.lov_enabled = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_PSG_rec.program_id = FND_API.G_MISS_NUM
    OR  g_PSG_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_PSG_rec.pte_code = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.seeded_sourcing_method = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.segment_id = FND_API.G_MISS_NUM
    OR  g_PSG_rec.segment_level = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.segment_pte_id = FND_API.G_MISS_NUM
    OR  g_PSG_rec.sourcing_enabled = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.sourcing_status = FND_API.G_MISS_CHAR
    OR  g_PSG_rec.user_sourcing_method = FND_API.G_MISS_CHAR
    THEN

        QP_Default_Psg.Attributes
        (   p_PSG_rec                     => g_PSG_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_PSG_rec                     => x_PSG_rec
        );

    ELSE

        --  Done defaulting attributes

        x_PSG_rec := g_PSG_rec;

    END IF;

END Attributes;

END QP_Default_Psg;

/
