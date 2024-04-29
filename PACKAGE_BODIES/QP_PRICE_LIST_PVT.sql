--------------------------------------------------------
--  DDL for Package Body QP_PRICE_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PRICE_LIST_PVT" AS
/* $Header: OEXVPRLB.pls 120.2 2005/07/07 05:35:34 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_PRICE_LIST_PVT';

G_Fetch_Level	    NUMBER := 0;

--  Utility function called by Fetch)List_Price API.

FUNCTION    Get_Sec_Price_List
(   p_price_list_id	IN  NUMBER  )
RETURN NUMBER;

FUNCTION    Get_Price_List_Name
(   p_price_list_id	IN  NUMBER  )
RETURN VARCHAR2;

FUNCTION    Get_Item_Description
(   p_item_id	IN  NUMBER  )
RETURN VARCHAR2;

FUNCTION    Get_Unit_Name
(   p_unit_code	IN  VARCHAR2 )
RETURN VARCHAR2;

--  Price_List

PROCEDURE Price_List
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN  OE_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
,   x_old_PRICE_LIST_rec            OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_PRICE_LIST_rec              OE_Price_List_PUB.Price_List_Rec_Type := p_PRICE_LIST_rec;
l_p_PRICE_LIST_rec            OE_Price_List_PUB.Price_List_Rec_Type := p_PRICE_LIST_rec;
l_old_PRICE_LIST_rec          OE_Price_List_PUB.Price_List_Rec_Type := p_old_PRICE_LIST_rec;
BEGIN

    --  Load API control record

    l_control_rec := OE_GLOBALS.Init_Control_Rec
    (   p_operation     => l_PRICE_LIST_rec.operation
    ,   p_control_rec   => p_control_rec
    );

    --  Set record return status.

    l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  Prepare record.

    IF l_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

        l_PRICE_LIST_rec.db_flag := FND_API.G_FALSE;

        --  Set missing old record elements to NULL.

        l_old_PRICE_LIST_rec :=
        OE_Price_List_Util.Convert_Miss_To_Null (l_old_PRICE_LIST_rec);

    ELSIF l_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE
    OR    l_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_DELETE
    THEN

        l_PRICE_LIST_rec.db_flag := FND_API.G_TRUE;

        --  Query Old if missing

        IF  l_old_PRICE_LIST_rec.Name = FND_API.G_MISS_CHAR
        OR  l_old_PRICE_LIST_rec.price_list_id = FND_API.G_MISS_NUM
        THEN

            l_old_PRICE_LIST_rec := OE_Price_List_Util.Query_Row
            (   p_name                        => l_PRICE_LIST_rec.name
            ,   p_price_list_id               => l_PRICE_LIST_rec.price_list_id
            );

        ELSE

            --  Set missing old record elements to NULL.

            l_old_PRICE_LIST_rec :=
            OE_Price_List_Util.Convert_Miss_To_Null (l_old_PRICE_LIST_rec);

        END IF;

        --  Complete new record from old

        l_PRICE_LIST_rec := OE_Price_List_Util.Complete_Record
        (   p_PRICE_LIST_rec              => l_PRICE_LIST_rec
        ,   p_old_PRICE_LIST_rec          => l_old_PRICE_LIST_rec
        );

    END IF;

    --  Attribute level validation.

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

            OE_Validate_Price_List.Attributes
            (   x_return_status               => l_return_status
            ,   p_PRICE_LIST_rec              => l_PRICE_LIST_rec
            ,   p_old_PRICE_LIST_rec          => l_old_PRICE_LIST_rec
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

    END IF;

        --  Clear dependent attributes.

    IF  l_control_rec.change_attributes THEN
           l_p_PRICE_LIST_rec := l_PRICE_LIST_rec;
        OE_Price_List_Util.Clear_Dependent_Attr
        (   p_PRICE_LIST_rec              => l_p_PRICE_LIST_rec
        ,   p_old_PRICE_LIST_rec          => l_old_PRICE_LIST_rec
        ,   x_PRICE_LIST_rec              => l_PRICE_LIST_rec
        );

    END IF;

    --  Default missing attributes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN
          l_p_PRICE_LIST_rec := l_PRICE_LIST_rec;
        OE_Default_Price_List.Attributes
        (   p_PRICE_LIST_rec              => l_p_PRICE_LIST_rec
        ,   x_PRICE_LIST_rec              => l_PRICE_LIST_rec
        );

    END IF;

    --  Apply attribute changes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN
         l_p_PRICE_LIST_rec := l_PRICE_LIST_rec;
        OE_Price_List_Util.Apply_Attribute_Changes
        (   p_PRICE_LIST_rec              => l_p_PRICE_LIST_rec
        ,   p_old_PRICE_LIST_rec          => l_old_PRICE_LIST_rec
        ,   x_PRICE_LIST_rec              => l_PRICE_LIST_rec
        );

    END IF;

    --  Entity level validation.

    IF l_control_rec.validate_entity THEN

        IF l_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

            OE_Validate_Price_List.Entity_Delete
            (   x_return_status               => l_return_status
            ,   p_PRICE_LIST_rec              => l_PRICE_LIST_rec
            );

        ELSE

            OE_Validate_Price_List.Entity
            (   x_return_status               => l_return_status
            ,   p_PRICE_LIST_rec              => l_PRICE_LIST_rec
            ,   p_old_PRICE_LIST_rec          => l_old_PRICE_LIST_rec
            );

        END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    --  Step 4. Write to DB

    IF l_control_rec.write_to_db THEN

        IF l_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

            OE_Price_List_Util.Delete_Row
            (   p_name                        => l_PRICE_LIST_rec.name
            ,   p_price_list_id               => l_PRICE_LIST_rec.price_list_id
            );

        ELSE

            --  Get Who Information

            l_PRICE_LIST_rec.last_update_date := SYSDATE;
            l_PRICE_LIST_rec.last_updated_by := FND_GLOBAL.USER_ID;
            l_PRICE_LIST_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

            IF l_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

                OE_Price_List_Util.Update_Row (l_PRICE_LIST_rec);

            ELSIF l_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                l_PRICE_LIST_rec.creation_date := SYSDATE;
                l_PRICE_LIST_rec.created_by    := FND_GLOBAL.USER_ID;

                OE_Price_List_Util.Insert_Row (l_PRICE_LIST_rec);

            END IF;

        END IF;

    END IF;

    --  Load OUT parameters

    x_PRICE_LIST_rec               := l_PRICE_LIST_rec;
    x_old_PRICE_LIST_rec           := l_old_PRICE_LIST_rec;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
        x_PRICE_LIST_rec               := l_PRICE_LIST_rec;
        x_old_PRICE_LIST_rec           := l_old_PRICE_LIST_rec;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_PRICE_LIST_rec               := l_PRICE_LIST_rec;
        x_old_PRICE_LIST_rec           := l_old_PRICE_LIST_rec;

        RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_List'
            );
        END IF;

        l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_PRICE_LIST_rec               := l_PRICE_LIST_rec;
        x_old_PRICE_LIST_rec           := l_old_PRICE_LIST_rec;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_List;

--  Price_List_Lines

PROCEDURE Price_List_Lines
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_PRICE_LIST_LINE_tbl           IN  OE_Price_List_PUB.Price_List_Line_Tbl_Type
,   p_old_PRICE_LIST_LINE_tbl       IN  OE_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_old_PRICE_LIST_LINE_tbl       OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_PRICE_LIST_LINE_rec         OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_p_PRICE_LIST_LINE_rec       OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_PRICE_LIST_LINE_tbl         OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_old_PRICE_LIST_LINE_rec     OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_old_PRICE_LIST_LINE_tbl     OE_Price_List_PUB.Price_List_Line_Tbl_Type;
BEGIN

    --  Init local table variables.

    l_PRICE_LIST_LINE_tbl          := p_PRICE_LIST_LINE_tbl;
    l_old_PRICE_LIST_LINE_tbl      := p_old_PRICE_LIST_LINE_tbl;

    FOR I IN 1..l_PRICE_LIST_LINE_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_PRICE_LIST_LINE_rec := l_PRICE_LIST_LINE_tbl(I);

        IF l_old_PRICE_LIST_LINE_tbl.EXISTS(I) THEN
            l_old_PRICE_LIST_LINE_rec := l_old_PRICE_LIST_LINE_tbl(I);
        ELSE
            l_old_PRICE_LIST_LINE_rec := OE_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC;
        END IF;

        --  Load API control record

        l_control_rec := OE_GLOBALS.Init_Control_Rec
        (   p_operation     => l_PRICE_LIST_LINE_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_PRICE_LIST_LINE_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            l_PRICE_LIST_LINE_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_PRICE_LIST_LINE_rec :=
            OE_Price_List_Line_Util.Convert_Miss_To_Null (l_old_PRICE_LIST_LINE_rec);

        ELSIF l_PRICE_LIST_LINE_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        OR    l_PRICE_LIST_LINE_rec.operation = OE_GLOBALS.G_OPR_DELETE
        THEN

            l_PRICE_LIST_LINE_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_PRICE_LIST_LINE_rec.price_list_line_id = FND_API.G_MISS_NUM
            THEN

                l_old_PRICE_LIST_LINE_rec := OE_Price_List_Line_Util.Query_Row
                (   p_price_list_line_id          => l_PRICE_LIST_LINE_rec.price_list_line_id
                ,   p_price_list_id          => l_PRICE_LIST_LINE_rec.price_list_id
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_PRICE_LIST_LINE_rec :=
                OE_Price_List_Line_Util.Convert_Miss_To_Null (l_old_PRICE_LIST_LINE_rec);

            END IF;

            --  Complete new record from old

            l_PRICE_LIST_LINE_rec := OE_Price_List_Line_Util.Complete_Record
            (   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
            ,   p_old_PRICE_LIST_LINE_rec     => l_old_PRICE_LIST_LINE_rec
            );

        END IF;

        --  Attribute level validation.

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                OE_Validate_Price_List_Line.Attributes
                (   x_return_status               => l_return_status
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   p_old_PRICE_LIST_LINE_rec     => l_old_PRICE_LIST_LINE_rec
                );

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;

        END IF;

            --  Clear dependent attributes.

        IF  l_control_rec.change_attributes THEN
               l_p_PRICE_LIST_LINE_rec := l_PRICE_LIST_LINE_rec;
            OE_Price_List_Line_Util.Clear_Dependent_Attr
            (   p_PRICE_LIST_LINE_rec         => l_p_PRICE_LIST_LINE_rec
            ,   p_old_PRICE_LIST_LINE_rec     => l_old_PRICE_LIST_LINE_rec
            ,   x_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
            );

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
          l_p_PRICE_LIST_LINE_rec := l_PRICE_LIST_LINE_rec;
            OE_Default_Price_List_Line.Attributes
            (   p_PRICE_LIST_LINE_rec         => l_p_PRICE_LIST_LINE_rec
            ,   x_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
            );

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
            l_p_PRICE_LIST_LINE_rec := l_PRICE_LIST_LINE_rec;
            OE_Price_List_Line_Util.Apply_Attribute_Changes
            (   p_PRICE_LIST_LINE_rec         => l_p_PRICE_LIST_LINE_rec
            ,   p_old_PRICE_LIST_LINE_rec     => l_old_PRICE_LIST_LINE_rec
            ,   x_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
            );

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_PRICE_LIST_LINE_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                OE_Validate_Price_List_Line.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                );

            ELSE

                OE_Validate_Price_List_Line.Entity
                (   x_return_status               => l_return_status
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                ,   p_old_PRICE_LIST_LINE_rec     => l_old_PRICE_LIST_LINE_rec
                );

            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

        --  Step 4. Write to DB

        IF l_control_rec.write_to_db THEN

            IF l_PRICE_LIST_LINE_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                OE_Price_List_Line_Util.Delete_Row
                (   p_price_list_line_id          => l_PRICE_LIST_LINE_rec.price_list_line_id
                );

            ELSE

                --  Get Who Information

                l_PRICE_LIST_LINE_rec.last_update_date := SYSDATE;
                l_PRICE_LIST_LINE_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_PRICE_LIST_LINE_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_PRICE_LIST_LINE_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

                    OE_Price_List_Line_Util.Update_Row (l_PRICE_LIST_LINE_rec);

                ELSIF l_PRICE_LIST_LINE_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                    l_PRICE_LIST_LINE_rec.creation_date := SYSDATE;
                    l_PRICE_LIST_LINE_rec.created_by := FND_GLOBAL.USER_ID;

                    OE_Price_List_Line_Util.Insert_Row (l_PRICE_LIST_LINE_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        l_PRICE_LIST_LINE_tbl(I)       := l_PRICE_LIST_LINE_rec;
        l_old_PRICE_LIST_LINE_tbl(I)   := l_old_PRICE_LIST_LINE_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            l_PRICE_LIST_LINE_tbl(I)       := l_PRICE_LIST_LINE_rec;
            l_old_PRICE_LIST_LINE_tbl(I)   := l_old_PRICE_LIST_LINE_rec;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_PRICE_LIST_LINE_tbl(I)       := l_PRICE_LIST_LINE_rec;
            l_old_PRICE_LIST_LINE_tbl(I)   := l_old_PRICE_LIST_LINE_rec;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_PRICE_LIST_LINE_tbl(I)       := l_PRICE_LIST_LINE_rec;
            l_old_PRICE_LIST_LINE_tbl(I)   := l_old_PRICE_LIST_LINE_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Price_List_Lines'
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_PRICE_LIST_LINE_tbl          := l_PRICE_LIST_LINE_tbl;
    x_old_PRICE_LIST_LINE_tbl      := l_old_PRICE_LIST_LINE_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_List_Lines'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_List_Lines;

--  Start of Comments
--  API name    Process_Price_List
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Process_Price_List
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type :=
                                        OE_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   p_old_PRICE_LIST_rec            IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   p_PRICE_LIST_LINE_tbl           IN  OE_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_LINE_TBL
,   p_old_PRICE_LIST_LINE_tbl       IN  OE_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_LINE_TBL
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Price_List';
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_PRICE_LIST_rec              OE_Price_List_PUB.Price_List_Rec_Type := p_PRICE_LIST_rec;
l_p_PRICE_LIST_rec            OE_Price_List_PUB.Price_List_Rec_Type := p_PRICE_LIST_rec;
l_old_PRICE_LIST_rec          OE_Price_List_PUB.Price_List_Rec_Type := p_old_PRICE_LIST_rec;
l_p_old_PRICE_LIST_rec        OE_Price_List_PUB.Price_List_Rec_Type := p_old_PRICE_LIST_rec;
l_PRICE_LIST_LINE_rec         OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_PRICE_LIST_LINE_tbl         OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_p_PRICE_LIST_LINE_tbl       OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_old_PRICE_LIST_LINE_rec     OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_old_PRICE_LIST_LINE_tbl     OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_p_old_PRICE_LIST_LINE_tbl   OE_Price_List_PUB.Price_List_Line_Tbl_Type;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    --  Init local table variables.

    l_PRICE_LIST_LINE_tbl          := p_PRICE_LIST_LINE_tbl;
    l_old_PRICE_LIST_LINE_tbl      := p_old_PRICE_LIST_LINE_tbl;

    --  Price_List
     l_p_PRICE_LIST_rec := l_PRICE_LIST_rec;
     l_p_old_PRICE_LIST_rec := l_old_PRICE_LIST_rec;
    Price_List
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_PRICE_LIST_rec              => l_p_PRICE_LIST_rec
    ,   p_old_PRICE_LIST_rec          => l_p_old_PRICE_LIST_rec
    ,   x_PRICE_LIST_rec              => l_PRICE_LIST_rec
    ,   x_old_PRICE_LIST_rec          => l_old_PRICE_LIST_rec
    );

    --  Perform PRICE_LIST group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_PRICE_LHEADER)
    THEN

        NULL;

    END IF;

    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_PRICE_LIST_LINE_tbl.COUNT LOOP

        l_PRICE_LIST_LINE_rec := l_PRICE_LIST_LINE_tbl(I);

        IF l_PRICE_LIST_LINE_rec.operation = OE_GLOBALS.G_OPR_CREATE
  --      AND (l_PRICE_LIST_LINE_rec.name IS NULL OR
  --          l_PRICE_LIST_LINE_rec.name = FND_API.G_MISS_CHAR)
        AND (l_PRICE_LIST_LINE_rec.price_list_id IS NULL OR
            l_PRICE_LIST_LINE_rec.price_list_id = FND_API.G_MISS_NUM)
        THEN

            --  Copy parent_id.

         --   l_PRICE_LIST_LINE_tbl(I).name := l_PRICE_LIST_rec.price_list_id;
            l_PRICE_LIST_LINE_tbl(I).price_list_id := l_PRICE_LIST_rec.price_list_id;
        END IF;
    END LOOP;

    --  Price_List_Lines
    l_p_PRICE_LIST_LINE_tbl := l_PRICE_LIST_LINE_tbl;
    l_p_old_PRICE_LIST_LINE_tbl := l_old_PRICE_LIST_LINE_tbl;
    Price_List_Lines
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_PRICE_LIST_LINE_tbl         => l_p_PRICE_LIST_LINE_tbl
    ,   p_old_PRICE_LIST_LINE_tbl     => l_p_old_PRICE_LIST_LINE_tbl
    ,   x_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
    ,   x_old_PRICE_LIST_LINE_tbl     => l_old_PRICE_LIST_LINE_tbl
    );

    --  Perform PRICE_LIST_LINE group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_PRICE_LLINE)
    THEN

        NULL;

    END IF;

    --  Step 6. Perform Object group logic

    IF p_control_rec.process AND
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL
    THEN

        NULL;

    END IF;

    --  Done processing, load OUT parameters.

    x_PRICE_LIST_rec               := l_PRICE_LIST_rec;
    x_PRICE_LIST_LINE_tbl          := l_PRICE_LIST_LINE_tbl;

    --  Clear API cache.

    IF p_control_rec.clear_api_cache THEN

        NULL;

    END IF;

    --  Clear API request tbl.

    IF p_control_rec.clear_api_requests THEN

        NULL;

    END IF;

    --  Derive return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_PRICE_LIST_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    FOR I IN 1..l_PRICE_LIST_LINE_tbl.COUNT LOOP

        IF l_PRICE_LIST_LINE_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END LOOP;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Price_List'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Price_List;

--  Start of Comments
--  API name    Lock_Price_List
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Lock_Price_List
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   p_PRICE_LIST_LINE_tbl           IN  OE_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_LINE_TBL
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Price_List';
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_PRICE_LIST_LINE_rec         OE_Price_List_PUB.Price_List_Line_Rec_Type;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    --  Set Savepoint

    SAVEPOINT Lock_Price_List_PVT;

    --  Lock PRICE_LIST

    IF p_PRICE_LIST_rec.operation = OE_GLOBALS.G_OPR_LOCK THEN

        OE_Price_List_Util.Lock_Row
        (   p_PRICE_LIST_rec              => p_PRICE_LIST_rec
        ,   x_PRICE_LIST_rec              => x_PRICE_LIST_rec
        ,   x_return_status               => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    END IF;

    --  Lock PRICE_LIST_LINE

    FOR I IN 1..p_PRICE_LIST_LINE_tbl.COUNT LOOP

        IF p_PRICE_LIST_LINE_tbl(I).operation = OE_GLOBALS.G_OPR_LOCK THEN

            OE_Price_List_Line_Util.Lock_Row
            (   p_PRICE_LIST_LINE_rec         => p_PRICE_LIST_LINE_tbl(I)
            ,   x_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_PRICE_LIST_LINE_tbl(I)       := l_PRICE_LIST_LINE_rec;

        END IF;

    END LOOP;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Price_List_PVT;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Price_List_PVT;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Price_List'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Price_List_PVT;

END Lock_Price_List;

--  Start of Comments
--  API name    Get_Price_List
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Get_Price_List
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_name                          IN  VARCHAR2
,   p_price_list_id                 IN  NUMBER
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Price_List';
l_PRICE_LIST_rec              OE_Price_List_PUB.Price_List_Rec_Type;
l_PRICE_LIST_LINE_tbl         OE_Price_List_PUB.Price_List_Line_Tbl_Type;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    --  Get PRICE_LIST ( parent = PRICE_LIST )

    l_PRICE_LIST_rec :=  OE_Price_List_Util.Query_Row
    (   p_name                => p_name
    ,   p_price_list_id       => p_price_list_id
    );

        --  Get PRICE_LIST_LINE ( parent = PRICE_LIST )

         l_PRICE_LIST_LINE_tbl :=  OE_Price_List_Line_Util.Query_Rows
            (   p_price_list_id          => p_price_list_id);

--  l_PRICE_LIST_LINE_rec :=  OE_Price_List_Line_Util.Query_Row
--          (   p_price_list_line_id          => l_PRICE_LIST_LINE_rec.price_list_line_id);

--  Load out parameters

    x_PRICE_LIST_rec               := l_PRICE_LIST_rec;
    x_PRICE_LIST_LINE_tbl          := l_PRICE_LIST_LINE_tbl;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Price_List'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Price_List;

PROCEDURE Fetch_List_Price
( p_api_version_number	IN  NUMBER	    	    	    	    	,
  p_init_msg_list	IN  VARCHAR2    := FND_API.G_FALSE		,
  p_validation_level	IN  NUMBER	:= FND_API.G_VALID_LEVEL_FULL	,
  p_return_status   	OUT NOCOPY /* file.sql.39 change */ VARCHAR2					,
  p_msg_count		OUT NOCOPY /* file.sql.39 change */ NUMBER					,
  p_msg_data		OUT NOCOPY /* file.sql.39 change */ VARCHAR2					,
  p_price_list_id	IN  NUMBER	:= NULL				,
  p_inventory_item_id	IN  NUMBER	:= NULL				,
  p_unit_code		IN  VARCHAR2	:= NULL				,
  p_service_duration	IN  NUMBER	:= NULL				,
  p_item_type_code	IN  VARCHAR2	:= NULL				,
  p_prc_method_code	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute1	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute2	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute3	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute4	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute5	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute6	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute7	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute8	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute9	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute10	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute11	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute12	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute13	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute14	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute15	IN  VARCHAR2	:= NULL				,
  p_base_price		IN  NUMBER	:= NULL				,
  p_pricing_date	IN  DATE	:= NULL				,
  p_fetch_attempts	IN  NUMBER	:= G_PRC_LST_DEF_ATTEMPTS	,
  p_price_list_id_out	    OUT NOCOPY /* file.sql.39 change */	NUMBER					,
  p_prc_method_code_out	    OUT NOCOPY /* file.sql.39 change */	VARCHAR2				,
  p_list_price		    OUT NOCOPY /* file.sql.39 change */	NUMBER					,
  p_list_percent	    OUT NOCOPY /* file.sql.39 change */	NUMBER					,
  p_rounding_factor	    OUT NOCOPY /* file.sql.39 change */	NUMBER
)
IS
    l_api_version_number    CONSTANT    NUMBER  	:=  1.0;
    l_api_name  	    CONSTANT    VARCHAR2(30):=  'Fetch_List_Price';
    l_return_status	    VARCHAR2(1);
    l_fetch_attempts	    NUMBER	    := p_fetch_attempts;
    l_validation_error	    BOOLEAN	    := FALSE;
    l_prc_method_code       VARCHAR2(4)	    :=	p_prc_method_code	;
    l_price_list_id		NUMBER	    :=	p_price_list_id		;
    l_prc_method_code_out	VARCHAR2(4) :=	NULL	;
    l_list_price		NUMBER	    :=	NULL	;
    l_list_percent	    	NUMBER	    :=	NULL	;
    l_rounding_factor	    	NUMBER	    :=	NULL	;
    l_pricing_date		DATE	    :=  NVL(p_pricing_date, SYSDATE);
    l_percent_price             NUMBER      :=  NULL;
    l_pricing_attribute1    VARCHAR2(150)    := p_pricing_attribute1;
    l_pricing_attribute2    VARCHAR2(150)    := p_pricing_attribute2;
    l_pricing_attribute3    VARCHAR2(150)    := p_pricing_attribute3;
    l_pricing_attribute4    VARCHAR2(150)    := p_pricing_attribute4;
    l_pricing_attribute5    VARCHAR2(150)    := p_pricing_attribute5;
    l_pricing_attribute6    VARCHAR2(150)    := p_pricing_attribute6;
    l_pricing_attribute7    VARCHAR2(150)    := p_pricing_attribute7;
    l_pricing_attribute8    VARCHAR2(150)    := p_pricing_attribute8;
    l_pricing_attribute9    VARCHAR2(150)    := p_pricing_attribute9;
    l_pricing_attribute10    VARCHAR2(150)    := p_pricing_attribute10;
    l_pricing_attribute11    VARCHAR2(150)    := p_pricing_attribute11;
    l_pricing_attribute12    VARCHAR2(150)    := p_pricing_attribute12;
    l_pricing_attribute13    VARCHAR2(150)    := p_pricing_attribute13;
    l_pricing_attribute14    VARCHAR2(150)    := p_pricing_attribute14;
    l_pricing_attribute15    VARCHAR2(150)    := p_pricing_attribute15;


  fname varchar2(80);


BEGIN

  p_price_list_id_out	:=1000;
  p_prc_method_code_out :='AMT';
  p_list_price          :=10.25;
  p_list_percent        :=2;
  p_rounding_factor	:=2;
  return;

    --For backward compatibility, we need to convert AMNT to AMT and etc.
   IF l_prc_method_code = 'AMNT' THEN l_prc_method_code := 'AMT'; END IF;
   IF l_prc_method_code = 'PERC' THEN l_prc_method_code := '%';   END IF;


    --Make sure there is no MISS Charaters

IF p_pricing_attribute1 = FND_API.G_MISS_CHAR THEN
 l_pricing_attribute1 := NULL;
END IF;

IF (p_pricing_attribute2 = FND_API.G_MISS_CHAR) THEN
 l_pricing_attribute2:=NULL;
END IF;

IF (p_pricing_attribute3 = FND_API.G_MISS_CHAR) THEN
 l_pricing_attribute3:=NULL;
END IF;

IF (p_pricing_attribute4 = FND_API.G_MISS_CHAR) THEN
 l_pricing_attribute4:=NULL;
END IF;

IF (p_pricing_attribute5 = FND_API.G_MISS_CHAR) THEN
 l_pricing_attribute5:=NULL;
END IF;

IF (p_pricing_attribute6 = FND_API.G_MISS_CHAR) THEN
 l_pricing_attribute6:=NULL;
END IF;

IF (p_pricing_attribute7 = FND_API.G_MISS_CHAR) THEN
 l_pricing_attribute7:=NULL;
END IF;

IF (p_pricing_attribute8 = FND_API.G_MISS_CHAR) THEN
 l_pricing_attribute8:=NULL;
END IF;

IF (p_pricing_attribute9 = FND_API.G_MISS_CHAR) THEN
 l_pricing_attribute9:=NULL;
END IF;

IF (p_pricing_attribute10 = FND_API.G_MISS_CHAR) THEN
 l_pricing_attribute10 := NULL;
END IF;

IF (p_pricing_attribute11 = FND_API.G_MISS_CHAR) THEN
 l_pricing_attribute11 := NULL;
END IF;

IF (p_pricing_attribute12 = FND_API.G_MISS_CHAR) THEN
 l_pricing_attribute12:=NULL;
END IF;

IF (p_pricing_attribute13 = FND_API.G_MISS_CHAR) THEN
 l_pricing_attribute13:=NULL;
END IF;

IF (p_pricing_attribute14 = FND_API.G_MISS_CHAR) THEN
 l_pricing_attribute14:=NULL;
END IF;

IF (p_pricing_attribute15 = FND_API.G_MISS_CHAR) THEN
 l_pricing_attribute15:=NULL;
END IF;

    --  Standard call to check for call compatibility
    --oe_debug_pub.initialize;
        oe_debug_pub.debug_on;
        fname := oe_debug_pub.set_debug_mode('FILE');
        oe_debug_pub.add('Debugging is on in Procedure Fetch List Price ');
        oe_debug_pub.add('Begin Kanan Fetch_List_Price');
        oe_debug_pub.add('============================');
        oe_debug_pub.add(' p_validation_level: '|| p_validation_level);
        oe_debug_pub.add('price_list_id: '||p_price_list_id);
        oe_debug_pub.add('inventory_item_id: '|| p_inventory_item_id);
        oe_debug_pub.add('Unit code :'||p_unit_code);
        oe_debug_pub.add('p_service_duration :'|| p_service_duration);
        oe_debug_pub.add(' p_item_type_code :'|| p_item_type_code);
        oe_debug_pub.add('Base Price : '|| p_base_price);
        oe_debug_pub.add(' p_pricing_date: '|| p_pricing_date);
        oe_debug_pub.add('p_fetch_attempts: '||p_fetch_attempts	);
        oe_debug_pub.add('p_prc_method_code: '||p_prc_method_code);
        oe_debug_pub.add(' p_pricing_attribute1: '|| p_pricing_attribute1);
        oe_debug_pub.add(' p_pricing_attribute2: '|| p_pricing_attribute2);
        oe_debug_pub.add(' p_pricing_attribute3: '|| p_pricing_attribute3);
        oe_debug_pub.add(' p_pricing_attribute4: '|| p_pricing_attribute4);


    --DBMS_output.Put_line('Begin Kanan Fetch_List_Price');
    --DBMS_output.Put_line('============================');
    --DBMS_OUTPUT.PUT_LINE('p_api_version_number: '||p_api_version_number);
    --DBMS_OUTPUT.PUT_LINE(' p_validation_level: '|| p_validation_level);
    --DBMS_OUTPUT.PUT_LINE('p_init_msg_list: '||p_init_msg_list);
    --DBMS_OUTPUT.PUT_LINE('price_list_id: '||p_price_list_id);
    --DBMS_OUTPUT.PUT_LINE('inventory_item_id: '|| p_inventory_item_id);
    --DBMS_OUTPUT.PUT_LINE('Unit code :'||p_unit_code);
    --DBMS_OUTPUT.PUT_LINE('p_service_duration :'|| p_service_duration);
    --DBMS_OUTPUT.PUT_LINE(' p_item_type_code :'|| p_item_type_code);
    --DBMS_OUTPUT.PUT_LINE('Base Price : '|| p_base_price);
    --DBMS_OUTPUT.PUT_LINE(' p_pricing_date: '|| p_pricing_date);
    --DBMS_OUTPUT.PuT_LINE('p_fetch_attempts: '||p_fetch_attempts	);
    --DBMS_OUTPUT.PuT_LINE('p_prc_method_code: '||p_prc_method_code);
    --DBMS_OUTPUT.PUT_LINE(' p_pricing_attribute1: '|| p_pricing_attribute1);
    --DBMS_OUTPUT.PUT_LINE(' p_pricing_attribute2: '|| p_pricing_attribute2);
    --DBMS_OUTPUT.PUT_LINE(' p_pricing_attribute3: '|| p_pricing_attribute3);
    --DBMS_OUTPUT.PUT_LINE(' p_pricing_attribute4: '|| p_pricing_attribute4);
    --DBMS_OUTPUT.PUT_LINE(' p_pricing_attribute5: '|| p_pricing_attribute5);
    --DBMS_OUTPUT.PUT_LINE(' p_pricing_attribute6: '|| p_pricing_attribute6);
    --DBMS_OUTPUT.PUT_LINE(' p_pricing_attribute7: '|| p_pricing_attribute7);
    --DBMS_OUTPUT.PUT_LINE(' p_pricing_attribute8: '|| p_pricing_attribute8);
    --DBMS_OUTPUT.PUT_LINE(' p_pricing_attribute9: '|| p_pricing_attribute9);
    --DBMS_OUTPUT.PUT_LINE(' p_pricing_attribute10: '|| p_pricing_attribute10);
    --DBMS_OUTPUT.PUT_LINE(' p_pricing_attribute11: '|| p_pricing_attribute11);
    --DBMS_OUTPUT.PUT_LINE(' p_pricing_attribute12: '|| p_pricing_attribute12);
    --DBMS_OUTPUT.PUT_LINE(' p_pricing_attribute13: '|| p_pricing_attribute13);
    --DBMS_OUTPUT.PUT_LINE(' p_pricing_attribute14: '|| p_pricing_attribute14);
    --DBMS_OUTPUT.PUT_LINE(' p_pricing_attribute15: '|| p_pricing_attribute15);




    IF NOT FND_API.Compatible_API_Call
    (	l_api_version_number,
        p_api_version_number,
	l_api_name	    ,
	G_PKG_NAME	    )
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list if p_init_msg_list is set to TRUE

    IF FND_API.to_Boolean(p_init_msg_list)  THEN

 	    OE_MSG_PUB.initialize;

    END IF;

    --  Initialize p_return_status

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    --	Validate Input. Start with mandatory validation.

    --  Fetch_attempts can not be greater that max attempts allowed

    --DBMS_Output.Put_LIne(Substr('P_Fetch_Attempts = ' ||
    --To_Char(p_Fetch_attempts) || ' G_PRC_LST_MAX_ATTEMPTS = '
    --|| To_Char(G_PRC_LST_MAX_ATTEMPTS),1,250));
    IF p_fetch_attempts > G_PRC_LST_MAX_ATTEMPTS THEN

	l_validation_error := TRUE;

	FND_MESSAGE.SET_NAME('OE','OE_PRC_LIST_INVALID_FETCH_ATTEMPTS');
	FND_MESSAGE.SET_TOKEN('PASSED_FETCH_ATTEMPTS',p_fetch_attempts);
	FND_MESSAGE.SET_TOKEN('MAX_FETCH_ATTEMPTS',G_PRC_LST_MAX_ATTEMPTS);
	OE_MSG_PUB.Add;

    END IF;

    --	Validation that can be turned off through the use of
    --	validation level.

    IF p_validation_level = FND_API.G_VALID_LEVEL_FULL THEN

	--  Validate :
	--	price_list_id
	--	item_id
	--	unit_code
	--	item_type_code
	--	fetch_attempts
	--  This code needs to be added in the future if we provide a
	--  public API.

	NULL;

    END IF;

    IF l_validation_error THEN
	--DBMS_output.put_line('validation_error');
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    --	Check required parameters.

    IF  p_price_list_id IS NULL
    OR  p_inventory_item_id IS NULL
    OR  p_unit_code IS NULL
    THEN
	--DBMS_Output.put_line('returning since price_list_id, inventory_id, unit_code is null');
	RETURN;
    END IF;

    --	Set the G_Fetch_level. Since this API calls itself
    --	recursively, this variable indicates the call level. It is
    --	used forward on.

    G_Fetch_Level := G_Fetch_Level + 1;

    --	Fetch list price.

    --	There are two fetch statements :
    --	    1.	General statement that drives on item id.
    --	    2.	Special case for Oracle USA where we drive on item_id
    --		and pricing_attribute2
    --		In case a customer doesn't have an index on
    --		PRICING_ATTRIBUTE2, it shouldn't be aproblem because
    --		the statement will still drive on item_id.
    --
    --	The ROWNUM = 1 condition is to accomodate the case where there
    --	is more than one active price list line that meets the select
    --	criteria. Inherited from release 9.


    --	Block encapsulating the fetch statements to handle the case
    --	where no rows are found. The reason it is not handled in the
    --	API exception handler, is that the handler itself may raise
    --	exceptions that should be handled by the API exception
    --	handler.  are no rows.

    BEGIN

    IF p_pricing_attribute2 IS NULL THEN

	--  Debug info
/*

	OE_MSG_PUB.Add_Exc_Msg
	(   p_error_text    =>	'pricing_attribute2 is null' );
*/

	--  Fecth driving on item_id
	/*  ordered use_nl(OELST OELIN) index(OELST OE_PRICE_LISTS_U1) index(OELIN OE_PRICE_LIST_LINES_N1) */

	SELECT
		QPLST.ROUNDING_FACTOR
	,	QPLIN.ARITHMETIC_OPERATOR
	,	QPLIN.LIST_PRICE
	,	QPLIN.PERCENT_PRICE
	INTO
		l_rounding_factor
	,	l_prc_method_code_out
	,	l_list_price
	,	l_percent_price
	FROM	QP_LIST_HEADERS QPLST
        ,	QP_LIST_LINES QPLIN
        ,	QP_PRICING_ATTRIBUTES QPPRC
	WHERE	QPLST.LIST_HEADER_ID = QPLIN.LIST_HEADER_ID
	  AND   QPLIN.LIST_LINE_ID   = QPPRC.LIST_LINE_ID
	  AND   QPLIN.LIST_LINE_TYPE_CODE   = G_PRC_PRICE_LIST_LINE
	AND	DECODE(QPLIN.LIST_PRICE,NULL,G_PRC_METHOD_PERCENT,G_PRC_METHOD_AMOUNT) =
		NVL( l_prc_method_code,DECODE(QPLIN.LIST_PRICE,NULL,G_PRC_METHOD_PERCENT,G_PRC_METHOD_AMOUNT) )
	AND	TRUNC(L_PRICING_DATE)
                BETWEEN NVL( QPLIN.START_DATE_ACTIVE, TRUNC(L_PRICING_DATE) )
		AND     NVL( QPLIN.END_DATE_ACTIVE, TRUNC(L_PRICING_DATE) )
	  AND   Decode(l_pricing_attribute1,Null,
	  QP_PRICE_LIST_PVT.Does_Pricing_Attribute_Exist ( 'ITEM', 'PRICING_ATTRIBUTE1',
					  p_inventory_item_id, p_unit_code,
					  --the following two attributes must
					  -- not be hardcoded...Kannan..10/01/99
					 'ALL',
					 'ALL',
					 'ALL',
					 Null,
					 qplin.list_line_id,
					 qplin.list_header_id),
	  QP_PRICE_LIST_PVT.Does_Pricing_Attribute_Exist (
	  'ITEM', 'PRICING_ATTRIBUTE1',
					  p_inventory_item_id, p_unit_code,
					  --the following two attributes must
					  -- not be hardcoded...Kannan..10/01/99
					 'PRICING_ATTRIBUTE_CONTEXT',
					 'PRICING_ATTRIBUTE1',
					 l_pricing_attribute1,
					 l_pricing_attribute1,
					 qplin.list_line_id,
					 qplin.list_header_id)) = 'Y'
	  AND   Decode(l_pricing_attribute2,Null,'Y',QP_PRICE_LIST_PVT.Does_Pricing_Attribute_Exist ( 'ITEM', 'PRICING_ATTRIBUTE1',
					  p_inventory_item_id, p_unit_code,
					  --the following two attributes must
					  -- not be hardcoded...Kannan..10/01/99
					 'PRICING_ATTRIBUTE_CONTEXT',
					 'PRICING_ATTRIBUTE2',
					 l_pricing_attribute2,
					 l_pricing_attribute2,
					 qplin.list_line_id,
					 qplin.list_header_id)) = 'Y'
	  AND   Decode(l_pricing_attribute3,Null,'Y',QP_PRICE_LIST_PVT.Does_Pricing_Attribute_Exist ( 'ITEM', 'PRICING_ATTRIBUTE1',
					  p_inventory_item_id, p_unit_code,
					  --the following two attributes must
					  -- not be hardcoded...Kannan..10/01/99
					 'PRICING_ATTRIBUTE_CONTEXT',
					 'PRICING_ATTRIBUTE3',
					 l_pricing_attribute3,
					 l_pricing_attribute3,
					 qplin.list_line_id,
					 qplin.list_header_id)) = 'Y'
	  AND   Decode(l_pricing_attribute4,Null,'Y',QP_PRICE_LIST_PVT.Does_Pricing_Attribute_Exist ( 'ITEM', 'PRICING_ATTRIBUTE1',
					  p_inventory_item_id, p_unit_code,
					  --the following two attributes must
					  -- not be hardcoded...Kannan..10/01/99
					 'PRICING_ATTRIBUTE_CONTEXT',
					 'PRICING_ATTRIBUTE4',
					 l_pricing_attribute4,
					 l_pricing_attribute4,
					 qplin.list_line_id,
					 qplin.list_header_id)) = 'Y'
	  AND   Decode(l_pricing_attribute5,Null,'Y',QP_PRICE_LIST_PVT.Does_Pricing_Attribute_Exist ( 'ITEM', 'PRICING_ATTRIBUTE1',
					  p_inventory_item_id, p_unit_code,
					  --the following two attributes must
					  -- not be hardcoded...Kannan..10/01/99
					 'PRICING_ATTRIBUTE_CONTEXT',
					 'PRICING_ATTRIBUTE5',
					 l_pricing_attribute5,
					 l_pricing_attribute5,
					 qplin.list_line_id,
					 qplin.list_header_id)) = 'Y'
	  AND   Decode(l_pricing_attribute6,Null,'Y',QP_PRICE_LIST_PVT.Does_Pricing_Attribute_Exist ( 'ITEM', 'PRICING_ATTRIBUTE1',
					  p_inventory_item_id, p_unit_code,
					  --the following two attributes must
					  -- not be hardcoded...Kannan..10/01/99
					 'PRICING_ATTRIBUTE_CONTEXT',
					 'PRICING_ATTRIBUTE6',
					 l_pricing_attribute6,
					 l_pricing_attribute6,
					 qplin.list_line_id,
					 qplin.list_header_id)) = 'Y'
	  AND   Decode(l_pricing_attribute7,Null,'Y',QP_PRICE_LIST_PVT.Does_Pricing_Attribute_Exist ( 'ITEM', 'PRICING_ATTRIBUTE1',
					  p_inventory_item_id, p_unit_code,
					  --the following two attributes must
					  -- not be hardcoded...Kannan..10/01/99
					 'PRICING_ATTRIBUTE_CONTEXT',
					 'PRICING_ATTRIBUTE7',
					 l_pricing_attribute7,
					 l_pricing_attribute7,
					 qplin.list_line_id,
					 qplin.list_header_id)) = 'Y'
	  AND   Decode(l_pricing_attribute8,Null,'Y',QP_PRICE_LIST_PVT.Does_Pricing_Attribute_Exist ( 'ITEM', 'PRICING_ATTRIBUTE1',
					  p_inventory_item_id, p_unit_code,
					  --the following two attributes must
					  -- not be hardcoded...Kannan..10/01/99
					 'PRICING_ATTRIBUTE_CONTEXT',
					 'PRICING_ATTRIBUTE8',
					 l_pricing_attribute8,
					 l_pricing_attribute8,
					 qplin.list_line_id,
					 qplin.list_header_id)) = 'Y'
	  AND   Decode(l_pricing_attribute9,Null,'Y',QP_PRICE_LIST_PVT.Does_Pricing_Attribute_Exist ( 'ITEM', 'PRICING_ATTRIBUTE1',
					  p_inventory_item_id, p_unit_code,
					  --the following two attributes must
					  -- not be hardcoded...Kannan..10/01/99
					 'PRICING_ATTRIBUTE_CONTEXT',
					 'PRICING_ATTRIBUTE9',
					 l_pricing_attribute9,
					 l_pricing_attribute9,
					 qplin.list_line_id,
					 qplin.list_header_id)) = 'Y'
	  AND   Decode(l_pricing_attribute10,Null,'Y',QP_PRICE_LIST_PVT.Does_Pricing_Attribute_Exist ( 'ITEM', 'PRICING_ATTRIBUTE1',
					  p_inventory_item_id, p_unit_code,
					  --the following two attributes must
					  -- not be hardcoded...Kannan..10/01/99
					 'PRICING_ATTRIBUTE_CONTEXT',
					 'PRICING_ATTRIBUTE10',
					 l_pricing_attribute10,
					 l_pricing_attribute10,
					 qplin.list_line_id,
					 qplin.list_header_id)) = 'Y'
	  AND   Decode(l_pricing_attribute11,Null,'Y',QP_PRICE_LIST_PVT.Does_Pricing_Attribute_Exist ( 'ITEM', 'PRICING_ATTRIBUTE1',
					  p_inventory_item_id, p_unit_code,
					  --the following two attributes must
					  -- not be hardcoded...Kannan..10/01/99
					 'PRICING_ATTRIBUTE_CONTEXT',
					 'PRICING_ATTRIBUTE11',
					 l_pricing_attribute11,
					 l_pricing_attribute11,
					 qplin.list_line_id,
					 qplin.list_header_id)) = 'Y'
	  AND   Decode(l_pricing_attribute12,Null,'Y',QP_PRICE_LIST_PVT.Does_Pricing_Attribute_Exist ( 'ITEM', 'PRICING_ATTRIBUTE1',
					  p_inventory_item_id, p_unit_code,
					  --the following two attributes must
					  -- not be hardcoded...Kannan..10/01/99
					 'PRICING_ATTRIBUTE_CONTEXT',
					 'PRICING_ATTRIBUTE12',
					 l_pricing_attribute12,
					 l_pricing_attribute12,
					 qplin.list_line_id,
					 qplin.list_header_id)) = 'Y'
	  AND   Decode(l_pricing_attribute13,Null,'Y',QP_PRICE_LIST_PVT.Does_Pricing_Attribute_Exist ( 'ITEM', 'PRICING_ATTRIBUTE1',
					  p_inventory_item_id, p_unit_code,
					  --the following two attributes must
					  -- not be hardcoded...Kannan..10/01/99
					 'PRICING_ATTRIBUTE_CONTEXT',
					 'PRICING_ATTRIBUTE13',
					 l_pricing_attribute13,
					 l_pricing_attribute13,
					 qplin.list_line_id,
					 qplin.list_header_id)) = 'Y'
	  AND   Decode(l_pricing_attribute14,Null,'Y',QP_PRICE_LIST_PVT.Does_Pricing_Attribute_Exist ( 'ITEM', 'PRICING_ATTRIBUTE1',
					  p_inventory_item_id, p_unit_code,
					  --the following two attributes must
					  -- not be hardcoded...Kannan..10/01/99
					 'PRICING_ATTRIBUTE_CONTEXT',
					 'PRICING_ATTRIBUTE14',
					 l_pricing_attribute14,
					 l_pricing_attribute14,
					 qplin.list_line_id,
					 qplin.list_header_id)) = 'Y'
	  AND   Decode(l_pricing_attribute15,Null,'Y',QP_PRICE_LIST_PVT.Does_Pricing_Attribute_Exist ( 'ITEM', 'PRICING_ATTRIBUTE1',
					  p_inventory_item_id, p_unit_code,
					  --the following two attributes must
					  -- not be hardcoded...Kannan..10/01/99
					 'PRICING_ATTRIBUTE_CONTEXT',
					 'PRICING_ATTRIBUTE15',
					 l_pricing_attribute15,
					 l_pricing_attribute15,
					 qplin.list_line_id,
					 qplin.list_header_id)) = 'Y'
	AND	QPLST.LIST_HEADER_ID = p_price_list_id
	AND	TRUNC(L_PRICING_DATE)
		BETWEEN NVL( QPLST.START_DATE_ACTIVE, TRUNC(L_PRICING_DATE) )
		AND     NVL( QPLST.END_DATE_ACTIVE, TRUNC(L_PRICING_DATE) );
	----DBMS_Output.put_line(' l_rounding_factor = ' || to_char(l_rounding_factor));
	----DBMS_Output.put_line(' l_prc_method_code_out = ' ||l_prc_method_code_out);
	----DBMS_Output.put_line(' l_list_price = ' || to_char(l_list_price));

    ELSE

	Null;

	--  Fetch driving on p_pricing_attribute2
	/*  ordered use_nl(OELST OELIN) index(OELST OE_PRICE_LISTS_U1) index(OELIN OE_PRICE_LIST_LINES_N1) */

    END IF;


	--  Debug info
/*
	OE_MSG_PUB.Add_Exc_Msg
	(   p_error_text    =>	'list price is not null - '||
	    ' list_price = '||l_list_price||
	    ' l_prc_method_code = '||l_prc_method_code_out||
	    ' l_rounding_factor = '||l_rounding_factor
	 );
*/


/*
--DBMS_output.put_line('In Kanan fetch list price');
--DBMS_output.put_line('l_rounding_factor: '||l_rounding_factor);
--DBMS_output.put_line('l_prc_method_code_out: '||l_prc_method_code_out);
--DBMS_output.put_line('l_list_price: '||l_list_price);
--DBMS_output.put_line('l_percent_price: '||l_percent_price);
--DBMS_output.put_line('Leaving  Kanan fetch list price');
*/
	--  Calculate list price.

	IF l_percent_price Is NULL Then

	    l_list_price := ROUND ( l_list_price , - l_rounding_factor );
	    l_list_percent := NULL ;

    --QP doing this because arithmetic_operator is null for price list
    -- the only way to know if it is a percent or amt is to check if the column    -- is null. If percent_price is null then it is an AMT.

            l_prc_method_code_out := G_PRC_METHOD_AMOUNT;

	ELSIF l_list_price is Null Then

	    --	List percent is the selected list price

	    l_list_percent := l_percent_price ;
            l_prc_method_code_out := G_PRC_METHOD_PERCENT;
	    IF	p_base_price IS NULL
	    THEN

		--  No base price

		l_list_price := NULL ;

	    ELSE

		l_list_price := l_list_percent * p_base_price / 100 ;

		IF p_item_type_code = G_PRC_ITEM_SERVICE THEN

		    l_list_price := l_list_price * p_service_duration ;

		END IF;

		l_list_price := ROUND ( l_list_price , l_rounding_factor );

	    END IF;

	ELSE

	    --	Unexpected error, invalid pricing method

	    IF	OE_MSG_PUB.Check_Msg_Level (
		OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN

		OE_MSG_PUB.Add_Exc_Msg
		(   G_PKG_NAME  	    ,
		    l_api_name    	    ,
		    'Invalid pricing method ='||l_prc_method_code_out
		);

	    END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	END IF; -- prc_method_code

	p_price_list_id_out	    :=	p_price_list_id		    ;
	p_prc_method_code_out	    :=	l_prc_method_code_out	    ;
	p_list_price		    :=	l_list_price		    ;
	p_list_percent		    :=	l_list_percent		    ;
	p_rounding_factor	    :=	l_rounding_factor	    ;

    --END IF; --	There is a list price

    EXCEPTION

	WHEN NO_DATA_FOUND THEN

	--  Debug info

	OE_MSG_PUB.Add_Exc_Msg
	(   p_error_text    =>	'Primary fetch not successful' );


	    --  Check if the maximum number of attempts has been
	    --	exceeded. When l_fetch attempts is 1 this means there
	    --	should be no more fetch attempts, else, look for a
	    --	secondary list.
    --dbms_output.put_line('In no data found exception');
	    IF l_fetch_attempts > 1 THEN

		l_fetch_attempts := l_fetch_attempts - 1;

		--  Get secondary_price_list_id

		l_price_list_id := Get_Secondary_Price_List ( p_price_list_id );

		IF l_price_list_id IS NOT NULL THEN

		    --	Call Fetch_List_Price using the sec list.

		    Fetch_List_Price
		    ( 	p_api_version_number	    ,
                        FND_API.G_FALSE		    ,
			FND_API.G_VALID_LEVEL_NONE  ,
			l_return_status		    ,
                        p_msg_count		    ,
   			p_msg_data		    ,
		        l_price_list_id		    ,
		      	p_inventory_item_id	    ,
		      	p_unit_code		    ,
		        p_service_duration	    ,
		        p_item_type_code	    ,
		      	p_prc_method_code	    ,
		      	p_pricing_attribute1	    ,
		      	p_pricing_attribute2	    ,
		      	p_pricing_attribute3	    ,
			p_pricing_attribute4	    ,
			p_pricing_attribute5	    ,
		      	p_pricing_attribute6	    ,
		      	p_pricing_attribute7	    ,
		      	p_pricing_attribute8	    ,
		      	p_pricing_attribute9	    ,
		      	p_pricing_attribute10	    ,
		      	p_pricing_attribute11	    ,
		      	p_pricing_attribute12	    ,
		      	p_pricing_attribute13	    ,
		      	p_pricing_attribute14	    ,
			p_pricing_attribute15	    ,
			p_base_price		    ,
			l_pricing_date		    ,
			l_fetch_attempts	    ,
		      	p_price_list_id_out	    ,
		      	p_prc_method_code_out	    ,
		      	l_list_price		    ,
		     	p_list_percent		    ,
		     	p_rounding_factor
		    );

		    IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                        -- Unexpected error, abort processing
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

		    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                        -- Error, abort processing
                        RAISE FND_API.G_EXC_ERROR;

		    ELSE

			--  Set p_list_price. We don't receive the
			--  list price in p_list_price because we need
			--  to check its value after the call.

			p_list_price := l_list_price ;

		    END IF;

		END IF; --  There was a secondary price list.

	    --END IF; -- fetch_attempts > 1
            ELSE    --After all attempts still couldn't find price list
              FND_MESSAGE.SET_NAME('QP','QP_PR_LIST_NOT_FOUND');
              FND_MESSAGE.SET_TOKEN('%',p_inventory_item_id);
	      OE_MSG_PUB.Add;



            END IF;

	WHEN OTHERS THEN

	    -- Unexpected error

	    IF	OE_MSG_PUB.Check_Msg_Level(
		OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN

		OE_MSG_PUB.Add_Exc_Msg
		(   G_PKG_NAME  	    ,
		    l_api_name
		);



	    END IF;

	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END; -- BEGIN select list price block.

    --	At this point, All processing is done, and all the secondary
    --	fetches have been performed.

    --	If list_price is NULL and the fetch level =1 meaning that this
    --	is the execution coresponding to the primary fetch. Then add an
    --	informational message to inform the caller that the item was
    --	not found o the price list.

	--  Debug info
/*
	OE_MSG_PUB.Add_Exc_Msg
	(   p_error_text    =>	'End of Fetch_List_Price - '||
	    ' l_list_price = '||l_list_price||
	    ' G_Fetch_Level = '||G_Fetch_Level
	);
*/


    IF	l_list_price IS NULL AND
	G_Fetch_Level = 1
    THEN

	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
	THEN

	    FND_MESSAGE.SET_NAME('QP','OE_PRC_NO_LIST_PRICE');
	    FND_MESSAGE.SET_TOKEN('PRICE_LIST',	Get_Price_List_Name
						(p_price_list_id) );
	    FND_MESSAGE.SET_TOKEN('ITEM',   Get_Item_Description
					    (p_inventory_item_id) );
	    FND_MESSAGE.SET_TOKEN('UNIT',Get_Unit_Name(p_unit_code ));
	    OE_MSG_PUB.Add;


	 END IF;

    END IF;

    --  Decement G_Fetch_Level

    G_Fetch_Level := G_Fetch_Level - 1;

    -- Get message count and if 1, return message data

    OE_MSG_PUB.Count_And_Get
    (   p_count =>  p_msg_count	,
	p_data  =>  p_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

    	p_return_status := FND_API.G_RET_STS_ERROR;

        -- Get message count and if 1, return message data

        OE_MSG_PUB.Count_And_Get
            (p_count => p_msg_count,
             p_data  => p_msg_data
        );

	--  Decement G_Fetch_Level

	G_Fetch_Level := G_Fetch_Level - 1;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        -- Get message count and if 1, return message data

        OE_MSG_PUB.Count_And_Get
            (p_count => p_msg_count,
             p_data  => p_msg_data
        );

	--  Decrement G_Fetch_Level

	G_Fetch_Level := G_Fetch_Level - 1;


    WHEN OTHERS THEN

    	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	    	l_api_name
	    );
    	END IF;

        -- Get message count and if 1, return message data

        OE_MSG_PUB.Count_And_Get
        (   p_count => p_msg_count,
            p_data  => p_msg_data
        );

	--  Decement G_Fetch_Level

	G_Fetch_Level := G_Fetch_Level - 1;

END; -- Fetch_List_Price


FUNCTION    Get_Sec_Price_List
(   p_price_list_id	IN  NUMBER  )
RETURN NUMBER
IS
l_sec_price_list_id	NUMBER := NULL;
BEGIN

   return null;

END Get_Sec_Price_List;

FUNCTION    Get_Price_List_Name
(   p_price_list_id	IN  NUMBER  )
RETURN VARCHAR2
IS
l_name	VARCHAR2(80) := NULL;
BEGIN

 return null;

END Get_Price_List_Name;

FUNCTION    Get_Item_Description
(   p_item_id	IN  NUMBER  )
RETURN VARCHAR2
IS
l_desc	    VARCHAR2(240)   := NULL;
l_org_id    NUMBER	    := NULL;
BEGIN

    l_org_id := FND_PROFILE.VALUE ('OE_ORGANIZATION_ID');

    IF	p_item_id IS NULL OR
	l_org_id IS NULL
    THEN
	RETURN NULL;
    END IF;

    SELECT  DESCRIPTION
    INTO    l_desc
    FROM    MTL_SYSTEM_ITEMS
    WHERE   INVENTORY_ITEM_ID = p_item_id
    AND	    ORGANIZATION_ID = l_org_id;

    RETURN l_desc;

EXCEPTION

    WHEN OTHERS THEN

	OE_MSG_PUB.Add_Exc_Msg
	(   G_PKG_NAME  	    ,
	    'Get_Item_Description - p_item_id = '||p_item_id||
	    ' org_id ='||l_org_id
	);

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Item_Description;

FUNCTION    Get_Unit_Name
(   p_unit_code	IN  VARCHAR2 )
RETURN VARCHAR2
IS
l_name	VARCHAR2(80) := NULL;
BEGIN

    IF p_unit_code IS NULL THEN
	RETURN NULL;
    END IF;

    SELECT  UNIT_OF_MEASURE
    INTO    l_name
    FROM    MTL_UNITS_OF_MEASURE
    WHERE   UOM_CODE = p_unit_code;

    RETURN l_name;

EXCEPTION

    WHEN OTHERS THEN

	OE_MSG_PUB.Add_Exc_Msg
	(   G_PKG_NAME  	    ,
	    'Get_Unit_Name - p_unit_code  = '||p_unit_code
	);

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Unit_Name;


Function Get_Secondary_Price_List(p_list_header_id in NUMBER) return number
is
l_sec_price_list_id number;
l_context varchar2(30);
l_attribute varchar2(30);
begin

    QP_UTIL.Get_Context_Attribute('PRICE_LIST_ID', l_context, l_attribute);

    select list_header_id
    into l_sec_price_list_id
    from qp_qualifiers
    where qualifier_context = l_context
    and qualifier_attribute = l_attribute
    and qualifier_attr_value = to_char(p_list_header_id)
    and list_header_id <> p_list_header_id
    and list_header_id in ( select list_header_id
                            from qp_list_headers_b
                            where list_type_code = 'PRL' )
    and qualifier_rule_id is null
    and rownum < 2;

    return l_sec_price_list_id;

    exception

       when no_data_found then return null;


end Get_Secondary_Price_List;

Function Get_Inventory_Item_Id( p_list_line_id in NUMBER) return number
is
l_inventory_item_id number;
l_context varchar2(30);
l_attribute varchar2(30);
begin

    QP_UTIL.Get_Context_Attribute('1001', l_context, l_attribute);

    select to_number(product_attr_value)
    into l_inventory_item_id
    from qp_pricing_attributes
    where list_line_id = p_list_line_id
    and product_attribute_context = l_context
    and product_attribute = l_attribute
    and rownum = 1;

    return l_inventory_item_id;

    exception

       when no_data_found then return null;

end Get_Inventory_Item_Id;

Function Get_Customer_Item_Id( p_list_line_id in NUMBER) return number
is
l_customer_item_id number;
l_context varchar2(30);
l_attribute varchar2(30);
begin

    QP_UTIL.Get_Context_Attribute('CUSTOMER_ITEM_ID', l_context, l_attribute);

    select to_number(pricing_attr_value_from)
    into l_customer_item_id
    from qp_pricing_attributes
    where list_line_id = p_list_line_id
    and pricing_attribute_context = l_context
    and pricing_attribute = l_attribute;

    return l_customer_item_id;

    exception

       when no_data_found then return null;



end Get_Customer_Item_Id;


Function Get_Pricing_Attr_Context( p_list_line_id in NUMBER) return varchar2
is
l_pricing_context varchar2(30);
l_context varchar2(30);
l_attribute varchar2(30);
begin

    select pricing_attribute_context
    into l_pricing_context
    from qp_pricing_attributes
    where list_line_id = p_list_line_id
    and pricing_attribute in ('PRICING_ATTRIBUTE1',
                              'PRICING_ATTRIBUTE2',
                              'PRICING_ATTRIBUTE3',
                              'PRICING_ATTRIBUTE4',
                              'PRICING_ATTRIBUTE5',
                              'PRICING_ATTRIBUTE6',
                              'PRICING_ATTRIBUTE7',
                              'PRICING_ATTRIBUTE8',
                              'PRICING_ATTRIBUTE9',
                              'PRICING_ATTRIBUTE10',
                              'PRICING_ATTRIBUTE11',
                              'PRICING_ATTRIBUTE12',
                              'PRICING_ATTRIBUTE13',
                              'PRICING_ATTRIBUTE14',
                              'PRICING_ATTRIBUTE15' )
       and rownum = 1;


    return l_pricing_context;

    exception

       when no_data_found then return null;


end Get_Pricing_Attr_Context;

Function Get_Pricing_Attribute( p_list_line_id in NUMBER,
                                p_pricing_attr in varchar2) return varchar2
is
l_pricing_attribute1 varchar2(240);
l_context varchar2(30);
l_attribute varchar2(30);
begin


    select pricing_attr_value_from
    into l_pricing_attribute1
    from qp_pricing_attributes
    where list_line_id = p_list_line_id
    and pricing_attribute = p_pricing_attr;

    return l_pricing_attribute1;

    exception

       when no_data_found then return null;

end Get_Pricing_Attribute;

Function Does_Pricing_Attribute_Exist
(P_Product_Attr_Context In Varchar2,
 p_Product_Attr In Varchar2,
 P_Product_Attr_Val In Varchar2,
 P_PRODUCT_UOM_CODE In Varchar2,
 P_PRICING_ATTRIBUTE_CONTEXT In Varchar2,
 P_PRICING_ATTRIBUTE In Varchar2,
 P_PRICING_ATTR_VALUE_FROM In Varchar2,
 P_PRICING_ATTR_VALUE_TO In Varchar2,
 P_LIST_LINE_ID In Number,
 P_LIST_HEADER_ID In Number
) Return Varchar2 Is
 Dummy_variable Varchar2(1);
Begin

 SELECT 'x'
 Into Dummy_Variable
 from QP_PRICING_ATTRIBUTES QPPA --, QP_LIST_LINES QPLL
 Where
 PRODUCT_ATTRIBUTE_CONTEXT = P_Product_Attr_Context
 And PRODUCT_ATTRIBUTE = P_Product_Attr
 And PRODUCT_ATTR_VALUE = P_Product_Attr_Val
 And PRODUCT_UOM_CODE = P_PRODUCT_UOM_CODE
 And PRICING_ATTRIBUTE_CONTEXT = P_PRICING_ATTRIBUTE_CONTEXT
 And PRICING_ATTRIBUTE = P_PRICING_ATTRIBUTE
 And P_PRICING_ATTR_VALUE_FROM between
 PRICING_ATTR_VALUE_FROM And Nvl(PRICING_ATTR_VALUE_TO,PRICING_ATTR_VALUE_FROM)
-- AND QPPA.LIST_LINE_ID = QPLL.LIST_LINE_ID
 AND QPPA.LIST_LINE_ID = P_LIST_LINE_ID;

 Return 'Y';
 Exception
  When No_Data_Found Then
    Return 'N';
  When Too_Many_Rows Then
    Return 'D';
End Does_Pricing_Attribute_Exist ;

Function Get_Price_Break_High ( p_list_line_id IN NUMBER ) return number
is
l_context varchar2(30);
l_pricing_attribute varchar2(240);
l_price_break_high number;
l_attribute  varchar2(30);
begin
	QP_UTIL.Get_Context_Attribute ( 'UNITS',l_context, l_attribute);

	select to_number(pricing_attr_value_to) into
	l_price_break_high
	from qp_pricing_attributes
	where list_line_id = p_list_line_id
	and pricing_attribute_context = l_context
	and pricing_attribute = l_attribute;

	return l_price_break_high;

end Get_Price_Break_High;


Function Get_Price_Break_Low ( p_list_line_id IN NUMBER ) return number
is
l_context varchar2(30);
l_pricing_attribute varchar2(240);
l_price_break_low number;
l_attribute  varchar2(30);
begin

	QP_UTIL.Get_Context_Attribute ( 'UNITS',l_context, l_attribute);

	select to_number(pricing_attr_value_from) into
	l_price_break_low
	from qp_pricing_attributes
	where list_line_id = p_list_line_id
	and pricing_attribute_context = l_context
	and pricing_attribute = l_attribute;

	return l_price_break_low;

end Get_Price_Break_Low;

Function Get_Product_UOM_Code ( p_list_line_id IN NUMBER ) return varchar2
is
l_context varchar2(30);
l_pricing_attribute varchar2(240);
l_attribute  varchar2(30);
l_uom_code varchar2(3);
begin

	QP_UTIL.Get_Context_Attribute ( '1001',l_context, l_attribute);

	select product_uom_code
	into l_uom_code
	from qp_pricing_attributes
	where list_line_id = p_list_line_id
	and product_attribute_context = l_context
	and product_attribute = l_attribute
	and rownum = 1;

        return l_uom_code;


end Get_Product_UOM_Code;


END QP_PRICE_LIST_PVT;

/
