--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_SEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_SEG" AS
/* $Header: QPXDSEGB.pls 120.3 2005/08/03 07:36:40 srashmi ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Seg';

--  Package global used within the package.

g_SEG_rec                     QP_Attributes_PUB.Seg_Rec_Type;

--  Get functions.

FUNCTION Get_Availability_In_Basic
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Availability_In_Basic;

FUNCTION Get_Prc_Context
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Prc_Context;

FUNCTION Get_Seeded
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Seeded;

FUNCTION Get_Seeded_Format_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Seeded_Format_Type;

FUNCTION Get_Seeded_Precedence
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Seeded_Precedence;

FUNCTION Get_Seeded_Segment_Name
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Seeded_Segment_Name;

FUNCTION Get_Seeded_Description
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Seeded_Description;

FUNCTION Get_User_Description
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_User_Description;

FUNCTION Get_Seeded_Valueset
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Seeded_Valueset;

FUNCTION Get_Segment_code
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Segment_code;

FUNCTION Get_Segment
RETURN NUMBER
IS
  l_segment_id   number(15);
BEGIN
    select qp_segments_s.nextval
    into l_segment_id
    from dual;
    RETURN (l_segment_id);

END Get_Segment;

FUNCTION Get_Application_Id
RETURN NUMBER
IS
BEGIN

    -- Id for Applicatin Mane "Oracle Pricing"
    RETURN 661;

END Get_Application_Id;

FUNCTION Get_Segment_Mapping_Column
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Segment_Mapping_Column;

FUNCTION Get_User_Format_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_User_Format_Type;

FUNCTION Get_User_Precedence
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_User_Precedence;

FUNCTION Get_User_Segment_Name
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_User_Segment_Name;

FUNCTION Get_User_Valueset
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_User_Valueset;

FUNCTION Get_Required_Flag
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;
END Get_Required_Flag;

-- Added for TCA
FUNCTION Get_Party_Hierarchy_Enabled
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;
END Get_Party_Hierarchy_Enabled;

PROCEDURE Get_Flex_Seg
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_SEG_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_SEG_rec.attribute1           := NULL;
    END IF;

    IF g_SEG_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_SEG_rec.attribute10          := NULL;
    END IF;

    IF g_SEG_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_SEG_rec.attribute11          := NULL;
    END IF;

    IF g_SEG_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_SEG_rec.attribute12          := NULL;
    END IF;

    IF g_SEG_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_SEG_rec.attribute13          := NULL;
    END IF;

    IF g_SEG_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_SEG_rec.attribute14          := NULL;
    END IF;

    IF g_SEG_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_SEG_rec.attribute15          := NULL;
    END IF;

    IF g_SEG_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_SEG_rec.attribute2           := NULL;
    END IF;

    IF g_SEG_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_SEG_rec.attribute3           := NULL;
    END IF;

    IF g_SEG_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_SEG_rec.attribute4           := NULL;
    END IF;

    IF g_SEG_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_SEG_rec.attribute5           := NULL;
    END IF;

    IF g_SEG_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_SEG_rec.attribute6           := NULL;
    END IF;

    IF g_SEG_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_SEG_rec.attribute7           := NULL;
    END IF;

    IF g_SEG_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_SEG_rec.attribute8           := NULL;
    END IF;

    IF g_SEG_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_SEG_rec.attribute9           := NULL;
    END IF;

    IF g_SEG_rec.context = FND_API.G_MISS_CHAR THEN
        g_SEG_rec.context              := NULL;
    END IF;

END Get_Flex_Seg;

--  Procedure Attributes

PROCEDURE Attributes
(   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_SEG_REC
,   p_iteration                     IN  NUMBER := 1
,   x_SEG_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Seg_Rec_Type
)
IS
 g_p_SEG_rec          QP_Attributes_PUB.Seg_Rec_Type;
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

    --  Initialize g_SEG_rec

    g_SEG_rec := p_SEG_rec;

    --  Default missing attributes.

    IF g_SEG_rec.availability_in_basic = FND_API.G_MISS_CHAR THEN

        g_SEG_rec.availability_in_basic := Get_Availability_In_Basic;

        IF g_SEG_rec.availability_in_basic IS NOT NULL THEN

            IF QP_Validate.Availability_In_Basic(g_SEG_rec.availability_in_basic)
            THEN
               g_p_SEG_rec := g_SEG_rec;
                QP_Seg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Seg_Util.G_AVAILABILITY_IN_BASIC
                ,   p_SEG_rec                     => g_p_SEG_rec
                ,   x_SEG_rec                     => g_SEG_rec
                );
            ELSE
                g_SEG_rec.availability_in_basic := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SEG_rec.prc_context_id = FND_API.G_MISS_NUM THEN

        g_SEG_rec.prc_context_id := Get_Prc_Context;

        IF g_SEG_rec.prc_context_id IS NOT NULL THEN

            IF QP_Validate.Prc_Context(g_SEG_rec.prc_context_id)
            THEN
               g_p_SEG_rec := g_SEG_rec;
                QP_Seg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Seg_Util.G_PRC_CONTEXT
                ,   p_SEG_rec                     => g_p_SEG_rec
                ,   x_SEG_rec                     => g_SEG_rec
                );
            ELSE
                g_SEG_rec.prc_context_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SEG_rec.seeded_flag = FND_API.G_MISS_CHAR THEN

        g_SEG_rec.seeded_flag := Get_Seeded;

        IF g_SEG_rec.seeded_flag IS NOT NULL THEN

            IF QP_Validate.Seeded(g_SEG_rec.seeded_flag)
            THEN
               g_p_SEG_rec := g_SEG_rec;
                QP_Seg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Seg_Util.G_SEEDED
                ,   p_SEG_rec                     => g_p_SEG_rec
                ,   x_SEG_rec                     => g_SEG_rec
                );
            ELSE
                g_SEG_rec.seeded_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SEG_rec.seeded_format_type = FND_API.G_MISS_CHAR THEN

        g_SEG_rec.seeded_format_type := Get_Seeded_Format_Type;

        IF g_SEG_rec.seeded_format_type IS NOT NULL THEN

            IF QP_Validate.Seeded_Format_Type(g_SEG_rec.seeded_format_type)
            THEN
               g_p_SEG_rec := g_SEG_rec;
                QP_Seg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Seg_Util.G_SEEDED_FORMAT_TYPE
                ,   p_SEG_rec                     => g_p_SEG_rec
                ,   x_SEG_rec                     => g_SEG_rec
                );
            ELSE
                g_SEG_rec.seeded_format_type := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SEG_rec.seeded_precedence = FND_API.G_MISS_NUM THEN

        g_SEG_rec.seeded_precedence := Get_Seeded_Precedence;

        IF g_SEG_rec.seeded_precedence IS NOT NULL THEN

            IF QP_Validate.Seeded_Precedence(g_SEG_rec.seeded_precedence)
            THEN
               g_p_SEG_rec := g_SEG_rec;
                QP_Seg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Seg_Util.G_SEEDED_PRECEDENCE
                ,   p_SEG_rec                     => g_p_SEG_rec
                ,   x_SEG_rec                     => g_SEG_rec
                );
            ELSE
                g_SEG_rec.seeded_precedence := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SEG_rec.seeded_segment_name = FND_API.G_MISS_CHAR THEN

        g_SEG_rec.seeded_segment_name := Get_Seeded_Segment_Name;

        IF g_SEG_rec.seeded_segment_name IS NOT NULL THEN

            IF QP_Validate.Seeded_Segment_Name(g_SEG_rec.seeded_segment_name)
            THEN
               g_p_SEG_rec := g_SEG_rec;
                QP_Seg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Seg_Util.G_SEEDED_SEGMENT_NAME
                ,   p_SEG_rec                     => g_p_SEG_rec
                ,   x_SEG_rec                     => g_SEG_rec
                );
            ELSE
                g_SEG_rec.seeded_segment_name := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SEG_rec.seeded_description = FND_API.G_MISS_CHAR THEN

        g_SEG_rec.seeded_description := Get_Seeded_Description;

        IF g_SEG_rec.seeded_description IS NOT NULL THEN

            IF QP_Validate.Seeded_Description_Seg(g_SEG_rec.seeded_description)
            THEN
               g_p_SEG_rec := g_SEG_rec;
                QP_Seg_Util.Clear_Dependent_Attr
                (   p_attr_id              => QP_Seg_Util.G_SEEDED_DESCRIPTION
                ,   p_SEG_rec                     => g_p_SEG_rec
                ,   x_SEG_rec                     => g_SEG_rec
                );
            ELSE
                g_SEG_rec.seeded_description := NULL;
            END IF;

        END IF;

     END IF;


     IF g_SEG_rec.user_description = FND_API.G_MISS_CHAR THEN

        g_SEG_rec.user_description := Get_Seeded_Description;

        IF g_SEG_rec.user_description IS NOT NULL THEN

            IF QP_Validate.User_Description_Seg(g_SEG_rec.user_description)
            THEN
               g_p_SEG_rec := g_SEG_rec;
                QP_Seg_Util.Clear_Dependent_Attr
                (   p_attr_id            => QP_Seg_Util.G_USER_DESCRIPTION
                ,   p_SEG_rec                     => g_p_SEG_rec
                ,   x_SEG_rec                     => g_SEG_rec
                );
            ELSE
                g_SEG_rec.user_description := NULL;
            END IF;

        END IF;

    END IF;


    IF g_SEG_rec.seeded_valueset_id = FND_API.G_MISS_NUM THEN

        g_SEG_rec.seeded_valueset_id := Get_Seeded_Valueset;

        IF g_SEG_rec.seeded_valueset_id IS NOT NULL THEN

            IF QP_Validate.Seeded_Valueset(g_SEG_rec.seeded_valueset_id)
            THEN
               g_p_SEG_rec := g_SEG_rec;
                QP_Seg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Seg_Util.G_SEEDED_VALUESET
                ,   p_SEG_rec                     => g_p_SEG_rec
                ,   x_SEG_rec                     => g_SEG_rec
                );
            ELSE
                g_SEG_rec.seeded_valueset_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SEG_rec.segment_code = FND_API.G_MISS_CHAR THEN

        g_SEG_rec.segment_code := Get_Segment_code;

        IF g_SEG_rec.segment_code IS NOT NULL THEN

            IF QP_Validate.Segment_code(g_SEG_rec.segment_code)
            THEN
               g_p_SEG_rec := g_SEG_rec;
                QP_Seg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Seg_Util.G_SEGMENT_code
                ,   p_SEG_rec                     => g_p_SEG_rec
                ,   x_SEG_rec                     => g_SEG_rec
                );
            ELSE
                g_SEG_rec.segment_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SEG_rec.segment_id = FND_API.G_MISS_NUM THEN

        g_SEG_rec.segment_id := Get_Segment;

        IF g_SEG_rec.segment_id IS NOT NULL THEN

            IF QP_Validate.Segment(g_SEG_rec.segment_id)
            THEN
               g_p_SEG_rec := g_SEG_rec;
                QP_Seg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Seg_Util.G_SEGMENT
                ,   p_SEG_rec                     => g_p_SEG_rec
                ,   x_SEG_rec                     => g_SEG_rec
                );
            ELSE
                g_SEG_rec.segment_id := NULL;
            END IF;

        END IF;

    END IF;
    -- Added Application_Id by Abhijit
    IF g_SEG_rec.application_id = FND_API.G_MISS_NUM THEN

        g_SEG_rec.application_id := Get_application_id;

        IF g_SEG_rec.application_id IS NOT NULL THEN

            IF QP_Validate.application_id(g_SEG_rec.application_id)
            THEN
               g_p_SEG_rec := g_SEG_rec;
                QP_Seg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Seg_Util.G_APPLICATION_ID
                ,   p_SEG_rec                     => g_p_SEG_rec
                ,   x_SEG_rec                     => g_SEG_rec
                );
            ELSE
                g_SEG_rec.application_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SEG_rec.segment_mapping_column = FND_API.G_MISS_CHAR THEN

        g_SEG_rec.segment_mapping_column := Get_Segment_Mapping_Column;

        IF g_SEG_rec.segment_mapping_column IS NOT NULL THEN

            IF QP_Validate.Segment_Mapping_Column(g_SEG_rec.segment_mapping_column)
            THEN
               g_p_SEG_rec := g_SEG_rec;
                QP_Seg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Seg_Util.G_SEGMENT_MAPPING_COLUMN
                ,   p_SEG_rec                     => g_p_SEG_rec
                ,   x_SEG_rec                     => g_SEG_rec
                );
            ELSE
                g_SEG_rec.segment_mapping_column := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SEG_rec.user_format_type = FND_API.G_MISS_CHAR THEN

        g_SEG_rec.user_format_type := Get_User_Format_Type;

        IF g_SEG_rec.user_format_type IS NOT NULL THEN

            IF QP_Validate.User_Format_Type(g_SEG_rec.user_format_type)
            THEN
               g_p_SEG_rec := g_SEG_rec;
                QP_Seg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Seg_Util.G_USER_FORMAT_TYPE
                ,   p_SEG_rec                     => g_p_SEG_rec
                ,   x_SEG_rec                     => g_SEG_rec
                );
            ELSE
                g_SEG_rec.user_format_type := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SEG_rec.user_precedence = FND_API.G_MISS_NUM THEN

        g_SEG_rec.user_precedence := Get_User_Precedence;

        IF g_SEG_rec.user_precedence IS NOT NULL THEN

            IF QP_Validate.User_Precedence(g_SEG_rec.user_precedence)
            THEN
               g_p_SEG_rec := g_SEG_rec;
                QP_Seg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Seg_Util.G_USER_PRECEDENCE
                ,   p_SEG_rec                     => g_p_SEG_rec
                ,   x_SEG_rec                     => g_SEG_rec
                );
            ELSE
                g_SEG_rec.user_precedence := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SEG_rec.user_segment_name = FND_API.G_MISS_CHAR THEN

        g_SEG_rec.user_segment_name := Get_User_Segment_Name;

        IF g_SEG_rec.user_segment_name IS NOT NULL THEN

            IF QP_Validate.User_Segment_Name(g_SEG_rec.user_segment_name)
            THEN
               g_p_SEG_rec := g_SEG_rec;
                QP_Seg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Seg_Util.G_USER_SEGMENT_NAME
                ,   p_SEG_rec                     => g_p_SEG_rec
                ,   x_SEG_rec                     => g_SEG_rec
                );
            ELSE
                g_SEG_rec.user_segment_name := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SEG_rec.user_valueset_id = FND_API.G_MISS_NUM THEN

        g_SEG_rec.user_valueset_id := Get_User_Valueset;

        IF g_SEG_rec.user_valueset_id IS NOT NULL THEN

            IF QP_Validate.User_Valueset(g_SEG_rec.user_valueset_id)
            THEN
               g_p_SEG_rec := g_SEG_rec;
                QP_Seg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Seg_Util.G_USER_VALUESET
                ,   p_SEG_rec                     => g_p_SEG_rec
                ,   x_SEG_rec                     => g_SEG_rec
                );
            ELSE
                g_SEG_rec.user_valueset_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_SEG_rec.required_flag = FND_API.G_MISS_CHAR THEN

        g_SEG_rec.required_flag := Get_Required_Flag;

        IF g_SEG_rec.required_flag IS NOT NULL THEN

            IF QP_Validate.required_flag(g_SEG_rec.user_valueset_id)
            THEN
               g_p_SEG_rec := g_SEG_rec;
                QP_Seg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Seg_Util.G_REQUIRED_FLAG
                ,   p_SEG_rec                     => g_p_SEG_rec
                ,   x_SEG_rec                     => g_SEG_rec
                );
            ELSE
                g_SEG_rec.required_flag := NULL;
            END IF;

        END IF;

    END IF;

    -- Added for TCA
    IF g_SEG_rec.party_hierarchy_enabled_flag = FND_API.G_MISS_CHAR THEN

        g_SEG_rec.party_hierarchy_enabled_flag := Get_Party_Hierarchy_Enabled;

        IF g_SEG_rec.party_hierarchy_enabled_flag IS NOT NULL THEN

            IF
QP_Validate.party_hierarchy_enabled_flag(g_SEG_rec.party_hierarchy_enabled_flag)
            THEN
                g_p_SEG_rec := g_SEG_rec;
                QP_Seg_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Seg_Util.G_PARTY_HIERARCHY_ENABLED_FLAG
                ,   p_SEG_rec                     => g_p_SEG_rec
                ,   x_SEG_rec                     => g_SEG_rec
                );
            ELSE
                g_SEG_rec.party_hierarchy_enabled_flag:= NULL;
            END IF;

        END IF;

    END IF;

    IF g_SEG_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Seg;

    END IF;

    IF g_SEG_rec.created_by = FND_API.G_MISS_NUM THEN

        g_SEG_rec.created_by := NULL;

    END IF;

    IF g_SEG_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_SEG_rec.creation_date := NULL;

    END IF;

    IF g_SEG_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_SEG_rec.last_updated_by := NULL;

    END IF;

    IF g_SEG_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_SEG_rec.last_update_date := NULL;

    END IF;

    IF g_SEG_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_SEG_rec.last_update_login := NULL;

    END IF;

    IF g_SEG_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_SEG_rec.program_application_id := NULL;

    END IF;

    IF g_SEG_rec.program_id = FND_API.G_MISS_NUM THEN

        g_SEG_rec.program_id := NULL;

    END IF;

    IF g_SEG_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_SEG_rec.program_update_date := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_SEG_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.availability_in_basic = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.context = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.created_by = FND_API.G_MISS_NUM
    OR  g_SEG_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_SEG_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_SEG_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_SEG_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_SEG_rec.prc_context_id = FND_API.G_MISS_NUM
    OR  g_SEG_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_SEG_rec.program_id = FND_API.G_MISS_NUM
    OR  g_SEG_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_SEG_rec.seeded_flag = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.seeded_format_type = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.seeded_precedence = FND_API.G_MISS_NUM
    OR  g_SEG_rec.seeded_segment_name = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.seeded_valueset_id = FND_API.G_MISS_NUM
    OR  g_SEG_rec.segment_code = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.segment_id = FND_API.G_MISS_NUM
    -- Added Application_Id by Abhijit
    OR  g_SEG_rec.application_id = FND_API.G_MISS_NUM
    OR  g_SEG_rec.segment_mapping_column = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.user_format_type = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.user_precedence = FND_API.G_MISS_NUM
    OR  g_SEG_rec.user_segment_name = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.required_flag = FND_API.G_MISS_CHAR
    OR  g_SEG_rec.user_valueset_id = FND_API.G_MISS_NUM
     -- Added for TCA
    OR  g_SEG_rec.party_hierarchy_enabled_flag = FND_API.G_MISS_CHAR
    THEN

        QP_Default_Seg.Attributes
        (   p_SEG_rec                     => g_SEG_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_SEG_rec                     => x_SEG_rec
        );

    ELSE

        --  Done defaulting attributes

        x_SEG_rec := g_SEG_rec;

    END IF;

END Attributes;

END QP_Default_Seg;

/
