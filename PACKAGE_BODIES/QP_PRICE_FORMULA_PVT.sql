--------------------------------------------------------
--  DDL for Package Body QP_PRICE_FORMULA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PRICE_FORMULA_PVT" AS
/* $Header: QPXVPRFB.pls 120.2 2005/07/06 02:00:42 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Price_Formula_PVT';

--  Formula

PROCEDURE Formula
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type
,   p_old_FORMULA_rec               IN  QP_Price_Formula_PUB.Formula_Rec_Type
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Rec_Type
,   x_old_FORMULA_rec               OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Rec_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_FORMULA_rec                 QP_Price_Formula_PUB.Formula_Rec_Type := p_FORMULA_rec;
l_old_FORMULA_rec             QP_Price_Formula_PUB.Formula_Rec_Type := p_old_FORMULA_rec;

--[prarasto]
l_p_FORMULA_rec               QP_Price_Formula_PUB.Formula_Rec_Type;

BEGIN

    oe_debug_pub.add('Entering procedure Formula in Pvt formula package');
    --  Load API control record

    l_control_rec := QP_GLOBALS.Init_Control_Rec
    (   p_operation     => l_FORMULA_rec.operation
    ,   p_control_rec   => p_control_rec
    );

    --  Set record return status.

    l_FORMULA_rec.return_status    := FND_API.G_RET_STS_SUCCESS;

    --  Prepare record.

    IF l_FORMULA_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

        l_FORMULA_rec.db_flag := FND_API.G_FALSE;

        --  Set missing old record elements to NULL.

        l_old_FORMULA_rec :=
        QP_Formula_Util.Convert_Miss_To_Null (l_old_FORMULA_rec);

    ELSIF l_FORMULA_rec.operation = QP_GLOBALS.G_OPR_UPDATE
    OR    l_FORMULA_rec.operation = QP_GLOBALS.G_OPR_DELETE
    THEN

        l_FORMULA_rec.db_flag := FND_API.G_TRUE;

        --  Query Old if missing

        IF  l_old_FORMULA_rec.price_formula_id = FND_API.G_MISS_NUM
        THEN

            l_old_FORMULA_rec := QP_Formula_Util.Query_Row
            (   p_price_formula_id            => l_FORMULA_rec.price_formula_id
            );

        ELSE

            --  Set missing old record elements to NULL.

            l_old_FORMULA_rec :=
            QP_Formula_Util.Convert_Miss_To_Null (l_old_FORMULA_rec);

        END IF;

        --  Complete new record from old

        l_FORMULA_rec := QP_Formula_Util.Complete_Record
        (   p_FORMULA_rec                 => l_FORMULA_rec
        ,   p_old_FORMULA_rec             => l_old_FORMULA_rec
        );

    END IF;

    --  Attribute level validation.

    IF  l_FORMULA_rec.operation = QP_GLOBALS.G_OPR_CREATE OR
	   l_FORMULA_rec.operation = QP_GLOBALS.G_OPR_UPDATE OR
	   l_FORMULA_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

            QP_Validate_Formula.Attributes
            (   x_return_status               => l_return_status
            ,   p_FORMULA_rec                 => l_FORMULA_rec
            ,   p_old_FORMULA_rec             => l_old_FORMULA_rec
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

	l_p_FORMULA_rec := l_FORMULA_rec; --[prarasto]

        QP_Formula_Util.Clear_Dependent_Attr
        (   p_FORMULA_rec                 => l_p_FORMULA_rec
        ,   p_old_FORMULA_rec             => l_old_FORMULA_rec
        ,   x_FORMULA_rec                 => l_FORMULA_rec
        );

    END IF;

    --  Default missing attributes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

	l_p_FORMULA_rec := l_FORMULA_rec; --[prarasto]

        QP_Default_Formula.Attributes
        (   p_FORMULA_rec                 => l_p_FORMULA_rec
        ,   x_FORMULA_rec                 => l_FORMULA_rec
        );

    END IF;

    --  Apply attribute changes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

	l_p_FORMULA_rec := l_FORMULA_rec; --[prarasto]

        QP_Formula_Util.Apply_Attribute_Changes
        (   p_FORMULA_rec                 => l_p_FORMULA_rec
        ,   p_old_FORMULA_rec             => l_old_FORMULA_rec
        ,   x_FORMULA_rec                 => l_FORMULA_rec
        );

    END IF;

    --  Entity level validation.

    IF l_control_rec.validate_entity THEN

        IF l_FORMULA_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

            QP_Validate_Formula.Entity_Delete
            (   x_return_status               => l_return_status
            ,   p_FORMULA_rec                 => l_FORMULA_rec
            );

        ELSE

            QP_Validate_Formula.Entity
            (   x_return_status               => l_return_status
            ,   p_FORMULA_rec                 => l_FORMULA_rec
            ,   p_old_FORMULA_rec             => l_old_FORMULA_rec
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

        IF l_FORMULA_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

            QP_Formula_Util.Delete_Row
            (   p_price_formula_id            => l_FORMULA_rec.price_formula_id
            );

        ELSE

            --  Get Who Information

            l_FORMULA_rec.last_update_date := SYSDATE;
            l_FORMULA_rec.last_updated_by  := FND_GLOBAL.USER_ID;
            l_FORMULA_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

            IF l_FORMULA_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                QP_Formula_Util.Update_Row (l_FORMULA_rec);

            ELSIF l_FORMULA_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                l_FORMULA_rec.creation_date    := SYSDATE;
                l_FORMULA_rec.created_by       := FND_GLOBAL.USER_ID;

                QP_Formula_Util.Insert_Row (l_FORMULA_rec);

            END IF;

        END IF;

    END IF;

    END IF;/* End of IF operation is create, update or delete only */

    --  Load OUT parameters

    x_FORMULA_rec                  := l_FORMULA_rec;
    x_old_FORMULA_rec              := l_old_FORMULA_rec;

    oe_debug_pub.add('Leaving procedure Formula in Pvt formula package' );
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        l_FORMULA_rec.return_status    := FND_API.G_RET_STS_ERROR;
        x_FORMULA_rec                  := l_FORMULA_rec;
        x_old_FORMULA_rec              := l_old_FORMULA_rec;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        l_FORMULA_rec.return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
        x_FORMULA_rec                  := l_FORMULA_rec;
        x_old_FORMULA_rec              := l_old_FORMULA_rec;

        RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Formula'
            );
        END IF;

        l_FORMULA_rec.return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
        x_FORMULA_rec                  := l_FORMULA_rec;
        x_old_FORMULA_rec              := l_old_FORMULA_rec;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Formula;

--  Formula_Liness

PROCEDURE Formula_Liness
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_FORMULA_LINES_tbl             IN  QP_Price_Formula_PUB.Formula_Lines_Tbl_Type
,   p_old_FORMULA_LINES_tbl         IN  QP_Price_Formula_PUB.Formula_Lines_Tbl_Type
,   x_FORMULA_LINES_tbl             OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Lines_Tbl_Type
,   x_old_FORMULA_LINES_tbl         OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Lines_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_FORMULA_LINES_rec           QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_FORMULA_LINES_tbl           QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
l_old_FORMULA_LINES_rec       QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_old_FORMULA_LINES_tbl       QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;

--[prarasto]
l_p_FORMULA_LINES_rec           QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
BEGIN

  oe_debug_pub.add('Entering procedure Formula Liness in Pvt formula package');
    --  Init local table variables.

    l_FORMULA_LINES_tbl            := p_FORMULA_LINES_tbl;
    l_old_FORMULA_LINES_tbl        := p_old_FORMULA_LINES_tbl;

    FOR I IN 1..l_FORMULA_LINES_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_FORMULA_LINES_rec := l_FORMULA_LINES_tbl(I);

        IF l_old_FORMULA_LINES_tbl.EXISTS(I) THEN
            l_old_FORMULA_LINES_rec := l_old_FORMULA_LINES_tbl(I);
        ELSE
            l_old_FORMULA_LINES_rec := QP_Price_Formula_PUB.G_MISS_FORMULA_LINES_REC;
        END IF;

        --  Load API control record

        l_control_rec := QP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_FORMULA_LINES_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_FORMULA_LINES_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_FORMULA_LINES_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

            l_FORMULA_LINES_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_FORMULA_LINES_rec :=
            QP_Formula_Lines_Util.Convert_Miss_To_Null (l_old_FORMULA_LINES_rec);

        ELSIF l_FORMULA_LINES_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        OR    l_FORMULA_LINES_rec.operation = QP_GLOBALS.G_OPR_DELETE
        THEN

            l_FORMULA_LINES_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_FORMULA_LINES_rec.price_formula_line_id = FND_API.G_MISS_NUM
            THEN

                l_old_FORMULA_LINES_rec := QP_Formula_Lines_Util.Query_Row
                (   p_price_formula_line_id       => l_FORMULA_LINES_rec.price_formula_line_id
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_FORMULA_LINES_rec :=
                QP_Formula_Lines_Util.Convert_Miss_To_Null (l_old_FORMULA_LINES_rec);

            END IF;

            --  Complete new record from old

            l_FORMULA_LINES_rec := QP_Formula_Lines_Util.Complete_Record
            (   p_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
            ,   p_old_FORMULA_LINES_rec       => l_old_FORMULA_LINES_rec
            );

        END IF;

        --  Attribute level validation.

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN


                QP_Validate_Formula_Lines.Attributes
                (   x_return_status               => l_return_status
                ,   p_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
                ,   p_old_FORMULA_LINES_rec       => l_old_FORMULA_LINES_rec
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

            l_p_FORMULA_LINES_rec := l_FORMULA_LINES_rec; --[prarasto]

            QP_Formula_Lines_Util.Clear_Dependent_Attr
            (   p_FORMULA_LINES_rec           => l_p_FORMULA_LINES_rec
            ,   p_old_FORMULA_LINES_rec       => l_old_FORMULA_LINES_rec
            ,   x_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
            );

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            l_p_FORMULA_LINES_rec := l_FORMULA_LINES_rec; --[prarasto]

            QP_Default_Formula_Lines.Attributes
            (   p_FORMULA_LINES_rec           => l_p_FORMULA_LINES_rec
            ,   x_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
            );

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            l_p_FORMULA_LINES_rec := l_FORMULA_LINES_rec; --[prarasto]

            QP_Formula_Lines_Util.Apply_Attribute_Changes
            (   p_FORMULA_LINES_rec           => l_p_FORMULA_LINES_rec
            ,   p_old_FORMULA_LINES_rec       => l_old_FORMULA_LINES_rec
            ,   x_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
            );

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_FORMULA_LINES_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Validate_Formula_Lines.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
                );

            ELSE

                QP_Validate_Formula_Lines.Entity
                (   x_return_status               => l_return_status
                ,   p_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
                ,   p_old_FORMULA_LINES_rec       => l_old_FORMULA_LINES_rec
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

            IF l_FORMULA_LINES_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Formula_Lines_Util.Delete_Row
                (   p_price_formula_line_id       => l_FORMULA_LINES_rec.price_formula_line_id
                );

            ELSE

                --  Get Who Information

                l_FORMULA_LINES_rec.last_update_date := SYSDATE;
                l_FORMULA_LINES_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_FORMULA_LINES_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_FORMULA_LINES_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                    QP_Formula_Lines_Util.Update_Row (l_FORMULA_LINES_rec);

                ELSIF l_FORMULA_LINES_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                    l_FORMULA_LINES_rec.creation_date := SYSDATE;
                    l_FORMULA_LINES_rec.created_by := FND_GLOBAL.USER_ID;

                    QP_Formula_Lines_Util.Insert_Row (l_FORMULA_LINES_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        l_FORMULA_LINES_tbl(I)         := l_FORMULA_LINES_rec;
        l_old_FORMULA_LINES_tbl(I)     := l_old_FORMULA_LINES_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_FORMULA_LINES_rec.return_status := FND_API.G_RET_STS_ERROR;
            l_FORMULA_LINES_tbl(I)         := l_FORMULA_LINES_rec;
            l_old_FORMULA_LINES_tbl(I)     := l_old_FORMULA_LINES_rec;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_FORMULA_LINES_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_FORMULA_LINES_tbl(I)         := l_FORMULA_LINES_rec;
            l_old_FORMULA_LINES_tbl(I)     := l_old_FORMULA_LINES_rec;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_FORMULA_LINES_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_FORMULA_LINES_tbl(I)         := l_FORMULA_LINES_rec;
            l_old_FORMULA_LINES_tbl(I)     := l_old_FORMULA_LINES_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Formula_Liness'
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_FORMULA_LINES_tbl            := l_FORMULA_LINES_tbl;
    x_old_FORMULA_LINES_tbl        := l_old_FORMULA_LINES_tbl;

   oe_debug_pub.add('Leaving procedure Formula Liness in Pvt formula package');
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
            ,   'Formula_Liness'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Formula_Liness;

--  Start of Comments
--  API name    Process_Price_Formula
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

PROCEDURE Process_Price_Formula
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type :=
                                        QP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_REC
,   p_old_FORMULA_rec               IN  QP_Price_Formula_PUB.Formula_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_REC
,   p_FORMULA_LINES_tbl             IN  QP_Price_Formula_PUB.Formula_Lines_Tbl_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_LINES_TBL
,   p_old_FORMULA_LINES_tbl         IN  QP_Price_Formula_PUB.Formula_Lines_Tbl_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_LINES_TBL
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Rec_Type
,   x_FORMULA_LINES_tbl             OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Lines_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Price_Formula';
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_FORMULA_rec                 QP_Price_Formula_PUB.Formula_Rec_Type := p_FORMULA_rec;
l_old_FORMULA_rec             QP_Price_Formula_PUB.Formula_Rec_Type := p_old_FORMULA_rec;
l_FORMULA_LINES_rec           QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_FORMULA_LINES_tbl           QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
l_old_FORMULA_LINES_rec       QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_old_FORMULA_LINES_tbl       QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
l_qp_status                   VARCHAR2(1);

--[prarasto]
l_p_FORMULA_rec                 QP_Price_Formula_PUB.Formula_Rec_Type;
l_p_old_FORMULA_rec             QP_Price_Formula_PUB.Formula_Rec_Type;
l_p_FORMULA_LINES_tbl           QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
l_p_old_FORMULA_LINES_tbl       QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;

BEGIN

   oe_debug_pub.add('Entering procedure Process_Price_Formula in Pvt package');
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


    -- Disallow calls to procedure if QP not installed or installed only
    -- as Shared(Basic)

    l_qp_status := QP_UTIL.get_qp_status;

    IF l_qp_status = 'N' THEN

       l_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('QP','QP_PRICING_NOT_INSTALLED');
       OE_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Init local table variables.

    l_FORMULA_LINES_tbl            := p_FORMULA_LINES_tbl;
    l_old_FORMULA_LINES_tbl        := p_old_FORMULA_LINES_tbl;

    --  Formula

    l_p_FORMULA_rec := l_FORMULA_rec;         --[prarasto]
    l_p_old_FORMULA_rec := l_old_FORMULA_rec; --[prarasto]

    Formula
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_FORMULA_rec                 => l_p_FORMULA_rec
    ,   p_old_FORMULA_rec             => l_p_old_FORMULA_rec
    ,   x_FORMULA_rec                 => l_FORMULA_rec
    ,   x_old_FORMULA_rec             => l_old_FORMULA_rec
    );

    --  Perform FORMULA group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_FORMULA)
    THEN

        NULL;

    END IF;

    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_FORMULA_LINES_tbl.COUNT LOOP

        l_FORMULA_LINES_rec := l_FORMULA_LINES_tbl(I);

        IF l_FORMULA_LINES_rec.operation = QP_GLOBALS.G_OPR_CREATE
        AND (l_FORMULA_LINES_rec.price_formula_id IS NULL OR
            l_FORMULA_LINES_rec.price_formula_id = FND_API.G_MISS_NUM)
        THEN

            --  Copy parent_id.

            l_FORMULA_LINES_tbl(I).price_formula_id := l_FORMULA_rec.price_formula_id;
        END IF;
    END LOOP;

    --  Formula_Liness

    l_p_FORMULA_LINES_tbl := l_FORMULA_LINES_tbl;	  --[prarasto]
    l_p_old_FORMULA_LINES_tbl := l_old_FORMULA_LINES_tbl; --[prarasto]

    Formula_Liness
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_FORMULA_LINES_tbl           => l_p_FORMULA_LINES_tbl
    ,   p_old_FORMULA_LINES_tbl       => l_p_old_FORMULA_LINES_tbl
    ,   x_FORMULA_LINES_tbl           => l_FORMULA_LINES_tbl
    ,   x_old_FORMULA_LINES_tbl       => l_old_FORMULA_LINES_tbl
    );

    --  Perform FORMULA_LINES group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_FORMULA_LINES)
    THEN

        NULL;

    END IF;

    --  Step 6. Perform Object group logic

    IF p_control_rec.process AND
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL
    THEN

        NULL;

    END IF;

    --  Done processing, load OUT parameters.

    x_FORMULA_rec                  := l_FORMULA_rec;
    x_FORMULA_LINES_tbl            := l_FORMULA_LINES_tbl;

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

    IF l_FORMULA_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    FOR I IN 1..l_FORMULA_LINES_tbl.COUNT LOOP

        IF l_FORMULA_LINES_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END LOOP;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Leaving procedure Process_Price_Formula in Pvt package');

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
            ,   'Process_Price_Formula'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Price_Formula;

--  Start of Comments
--  API name    Lock_Price_Formula
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

PROCEDURE Lock_Price_Formula
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_REC
,   p_FORMULA_LINES_tbl             IN  QP_Price_Formula_PUB.Formula_Lines_Tbl_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_LINES_TBL
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Rec_Type
,   x_FORMULA_LINES_tbl             OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Lines_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Price_Formula';
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_FORMULA_LINES_rec           QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
BEGIN

    oe_debug_pub.add('Entering procedure Lock_Price_Formula in Pvt package');
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

    SAVEPOINT Lock_Price_Formula_PVT;

    --  Lock FORMULA

    IF p_FORMULA_rec.operation = QP_GLOBALS.G_OPR_LOCK THEN

        QP_Formula_Util.Lock_Row
        (   p_FORMULA_rec                 => p_FORMULA_rec
        ,   x_FORMULA_rec                 => x_FORMULA_rec
        ,   x_return_status               => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    END IF;

    --  Lock FORMULA_LINES

    FOR I IN 1..p_FORMULA_LINES_tbl.COUNT LOOP

        IF p_FORMULA_LINES_tbl(I).operation = QP_GLOBALS.G_OPR_LOCK THEN

            QP_Formula_Lines_Util.Lock_Row
            (   p_FORMULA_LINES_rec           => p_FORMULA_LINES_tbl(I)
            ,   x_FORMULA_LINES_rec           => l_FORMULA_LINES_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_FORMULA_LINES_tbl(I)         := l_FORMULA_LINES_rec;

        END IF;

    END LOOP;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Leaving procedure Lock_Price_Formula in Pvt package');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Price_Formula_PVT;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Price_Formula_PVT;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Price_Formula'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Price_Formula_PVT;

END Lock_Price_Formula;

--  Start of Comments
--  API name    Get_Price_Formula
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

PROCEDURE Get_Price_Formula
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_price_formula_id              IN  NUMBER
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Rec_Type
,   x_FORMULA_LINES_tbl             OUT NOCOPY /* file.sql.39 change */ QP_Price_Formula_PUB.Formula_Lines_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Price_Formula';
l_FORMULA_rec                 QP_Price_Formula_PUB.Formula_Rec_Type;
l_FORMULA_LINES_tbl           QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
BEGIN

    oe_debug_pub.add('Entering procedure Get_Price_Formula in Pvt package');
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

    --  Get FORMULA ( parent = FORMULA )

    l_FORMULA_rec :=  QP_Formula_Util.Query_Row
    (   p_price_formula_id    => p_price_formula_id
    );

        --  Get FORMULA_LINES ( parent = FORMULA )

        l_FORMULA_LINES_tbl :=  QP_Formula_Lines_Util.Query_Rows
        (   p_price_formula_id      => l_FORMULA_rec.price_formula_id
        );


    --  Load out parameters

    x_FORMULA_rec                  := l_FORMULA_rec;
    x_FORMULA_LINES_tbl            := l_FORMULA_LINES_tbl;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Leaving procedure Get_Price_Formula in Pvt package');

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
            ,   'Get_Price_Formula'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Price_Formula;

END QP_Price_Formula_PVT;

/
