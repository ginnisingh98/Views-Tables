--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_RQT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_RQT" AS
/* $Header: QPXDRQTB.pls 120.2 2005/07/06 04:30:58 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Rqt';

--  Package global used within the package.

g_RQT_rec                     QP_Attr_Map_PUB.Rqt_Rec_Type;

--  Get functions.

FUNCTION Get_Enabled
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Enabled;

FUNCTION Get_Line_Level_Global_Struct
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Line_Level_Global_Struct;

FUNCTION Get_Line_Level_View_Name
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Line_Level_View_Name;

FUNCTION Get_Order_Level_Global_Struct
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Order_Level_Global_Struct;

FUNCTION Get_Order_Level_View_Name
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Order_Level_View_Name;

FUNCTION Get_Pte
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pte;

FUNCTION Get_Request_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Request_Type;

FUNCTION Get_Request_Type_Desc
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Request_Type_Desc;

FUNCTION Get_Row
RETURN ROWID
IS
BEGIN

    RETURN NULL;

END Get_Row;

PROCEDURE Get_Flex_Rqt
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_RQT_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_RQT_rec.attribute1           := NULL;
    END IF;

    IF g_RQT_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_RQT_rec.attribute10          := NULL;
    END IF;

    IF g_RQT_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_RQT_rec.attribute11          := NULL;
    END IF;

    IF g_RQT_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_RQT_rec.attribute12          := NULL;
    END IF;

    IF g_RQT_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_RQT_rec.attribute13          := NULL;
    END IF;

    IF g_RQT_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_RQT_rec.attribute14          := NULL;
    END IF;

    IF g_RQT_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_RQT_rec.attribute15          := NULL;
    END IF;

    IF g_RQT_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_RQT_rec.attribute2           := NULL;
    END IF;

    IF g_RQT_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_RQT_rec.attribute3           := NULL;
    END IF;

    IF g_RQT_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_RQT_rec.attribute4           := NULL;
    END IF;

    IF g_RQT_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_RQT_rec.attribute5           := NULL;
    END IF;

    IF g_RQT_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_RQT_rec.attribute6           := NULL;
    END IF;

    IF g_RQT_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_RQT_rec.attribute7           := NULL;
    END IF;

    IF g_RQT_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_RQT_rec.attribute8           := NULL;
    END IF;

    IF g_RQT_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_RQT_rec.attribute9           := NULL;
    END IF;

    IF g_RQT_rec.context = FND_API.G_MISS_CHAR THEN
        g_RQT_rec.context              := NULL;
    END IF;

END Get_Flex_Rqt;

--  Procedure Attributes

PROCEDURE Attributes
(   p_RQT_rec                       IN  QP_Attr_Map_PUB.Rqt_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_RQT_REC
,   p_iteration                     IN  NUMBER := 1
,   x_RQT_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Rqt_Rec_Type
)
IS
 g_p_RQT_rec         QP_Attr_Map_PUB.Rqt_Rec_Type;
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

    --  Initialize g_RQT_rec

    g_RQT_rec := p_RQT_rec;

    --  Default missing attributes.

    IF g_RQT_rec.enabled_flag = FND_API.G_MISS_CHAR THEN

        g_RQT_rec.enabled_flag := Get_Enabled;

        IF g_RQT_rec.enabled_flag IS NOT NULL THEN

            IF QP_Validate.Enabled(g_RQT_rec.enabled_flag)
            THEN
                g_p_RQT_rec  := g_RQT_rec;
                QP_Rqt_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Rqt_Util.G_ENABLED
                ,   p_RQT_rec                     => g_p_RQT_rec
                ,   x_RQT_rec                     => g_RQT_rec
                );
            ELSE
                g_RQT_rec.enabled_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_RQT_rec.line_level_global_struct = FND_API.G_MISS_CHAR THEN

        g_RQT_rec.line_level_global_struct := Get_Line_Level_Global_Struct;

        IF g_RQT_rec.line_level_global_struct IS NOT NULL THEN

            IF QP_Validate.Line_Level_Global_Struct(g_RQT_rec.line_level_global_struct)
            THEN
                g_p_RQT_rec  := g_RQT_rec;
                QP_Rqt_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Rqt_Util.G_LINE_LEVEL_GLOBAL_STRUCT
                ,   p_RQT_rec                     => g_p_RQT_rec
                ,   x_RQT_rec                     => g_RQT_rec
                );
            ELSE
                g_RQT_rec.line_level_global_struct := NULL;
            END IF;

        END IF;

    END IF;

    IF g_RQT_rec.line_level_view_name = FND_API.G_MISS_CHAR THEN

        g_RQT_rec.line_level_view_name := Get_Line_Level_View_Name;

        IF g_RQT_rec.line_level_view_name IS NOT NULL THEN

            IF QP_Validate.Line_Level_View_Name(g_RQT_rec.line_level_view_name)
            THEN
                g_p_RQT_rec  := g_RQT_rec;
                QP_Rqt_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Rqt_Util.G_LINE_LEVEL_VIEW_NAME
                ,   p_RQT_rec                     => g_p_RQT_rec
                ,   x_RQT_rec                     => g_RQT_rec
                );
            ELSE
                g_RQT_rec.line_level_view_name := NULL;
            END IF;

        END IF;

    END IF;

    IF g_RQT_rec.order_level_global_struct = FND_API.G_MISS_CHAR THEN

        g_RQT_rec.order_level_global_struct := Get_Order_Level_Global_Struct;

        IF g_RQT_rec.order_level_global_struct IS NOT NULL THEN

            IF QP_Validate.Order_Level_Global_Struct(g_RQT_rec.order_level_global_struct)
            THEN
                g_p_RQT_rec  := g_RQT_rec;
                QP_Rqt_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Rqt_Util.G_ORDER_LEVEL_GLOBAL_STRUCT
                ,   p_RQT_rec                     => g_p_RQT_rec
                ,   x_RQT_rec                     => g_RQT_rec
                );
            ELSE
                g_RQT_rec.order_level_global_struct := NULL;
            END IF;

        END IF;

    END IF;

    IF g_RQT_rec.order_level_view_name = FND_API.G_MISS_CHAR THEN

        g_RQT_rec.order_level_view_name := Get_Order_Level_View_Name;

        IF g_RQT_rec.order_level_view_name IS NOT NULL THEN

            IF QP_Validate.Order_Level_View_Name(g_RQT_rec.order_level_view_name)
            THEN
                g_p_RQT_rec  := g_RQT_rec;
                QP_Rqt_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Rqt_Util.G_ORDER_LEVEL_VIEW_NAME
                ,   p_RQT_rec                     => g_p_RQT_rec
                ,   x_RQT_rec                     => g_RQT_rec
                );
            ELSE
                g_RQT_rec.order_level_view_name := NULL;
            END IF;

        END IF;

    END IF;

    IF g_RQT_rec.pte_code = FND_API.G_MISS_CHAR THEN

        g_RQT_rec.pte_code := Get_Pte;

        IF g_RQT_rec.pte_code IS NOT NULL THEN

            IF QP_Validate.Pte(g_RQT_rec.pte_code)
            THEN
                g_p_RQT_rec  := g_RQT_rec;
                QP_Rqt_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Rqt_Util.G_PTE
                ,   p_RQT_rec                     => g_p_RQT_rec
                ,   x_RQT_rec                     => g_RQT_rec
                );
            ELSE
                g_RQT_rec.pte_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_RQT_rec.request_type_code = FND_API.G_MISS_CHAR THEN

        g_RQT_rec.request_type_code := Get_Request_Type;

        IF g_RQT_rec.request_type_code IS NOT NULL THEN

            IF QP_Validate.Request_Type(g_RQT_rec.request_type_code)
            THEN
                g_p_RQT_rec  := g_RQT_rec;
                QP_Rqt_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Rqt_Util.G_REQUEST_TYPE
                ,   p_RQT_rec                     => g_p_RQT_rec
                ,   x_RQT_rec                     => g_RQT_rec
                );
            ELSE
                g_RQT_rec.request_type_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_RQT_rec.request_type_desc = FND_API.G_MISS_CHAR THEN

        g_RQT_rec.request_type_desc := Get_Request_Type_Desc;

        IF g_RQT_rec.request_type_desc IS NOT NULL THEN

            IF QP_Validate.Request_Type_Desc(g_RQT_rec.request_type_desc)
            THEN
                g_p_RQT_rec  := g_RQT_rec;
                QP_Rqt_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Rqt_Util.G_REQUEST_TYPE_DESC
                ,   p_RQT_rec                     => g_p_RQT_rec
                ,   x_RQT_rec                     => g_RQT_rec
                );
            ELSE
                g_RQT_rec.request_type_desc := NULL;
            END IF;

        END IF;

    END IF;

    IF g_RQT_rec.row_id = FND_API.G_MISS_CHAR THEN

        g_RQT_rec.row_id := Get_Row;

        IF g_RQT_rec.row_id IS NOT NULL THEN

            IF QP_Validate.Row(g_RQT_rec.row_id)
            THEN
                g_p_RQT_rec  := g_RQT_rec;
                QP_Rqt_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Rqt_Util.G_ROW
                ,   p_RQT_rec                     => g_p_RQT_rec
                ,   x_RQT_rec                     => g_RQT_rec
                );
            ELSE
                g_RQT_rec.row_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_RQT_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Rqt;

    END IF;

    IF g_RQT_rec.created_by = FND_API.G_MISS_NUM THEN

        g_RQT_rec.created_by := NULL;

    END IF;

    IF g_RQT_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_RQT_rec.creation_date := NULL;

    END IF;

    IF g_RQT_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_RQT_rec.last_updated_by := NULL;

    END IF;

    IF g_RQT_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_RQT_rec.last_update_date := NULL;

    END IF;

    IF g_RQT_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_RQT_rec.last_update_login := NULL;

    END IF;

    IF g_RQT_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_RQT_rec.program_application_id := NULL;

    END IF;

    IF g_RQT_rec.program_id = FND_API.G_MISS_NUM THEN

        g_RQT_rec.program_id := NULL;

    END IF;

    IF g_RQT_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_RQT_rec.program_update_date := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_RQT_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.context = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.created_by = FND_API.G_MISS_NUM
    OR  g_RQT_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_RQT_rec.enabled_flag = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_RQT_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_RQT_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_RQT_rec.line_level_global_struct = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.line_level_view_name = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.order_level_global_struct = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.order_level_view_name = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_RQT_rec.program_id = FND_API.G_MISS_NUM
    OR  g_RQT_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_RQT_rec.pte_code = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.request_type_code = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.request_type_desc = FND_API.G_MISS_CHAR
    OR  g_RQT_rec.row_id = FND_API.G_MISS_CHAR
    THEN

        QP_Default_Rqt.Attributes
        (   p_RQT_rec                     => g_RQT_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_RQT_rec                     => x_RQT_rec
        );

    ELSE

        --  Done defaulting attributes

        x_RQT_rec := g_RQT_rec;

    END IF;

END Attributes;

END QP_Default_Rqt;

/
