--------------------------------------------------------
--  DDL for Package Body QP_ATTRIBUTES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_ATTRIBUTES_PVT" AS
/* $Header: QPXVATRB.pls 120.2 2005/07/06 04:51:47 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Attributes_PVT';

--  Con

PROCEDURE Con
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type
,   p_old_CON_rec                   IN  QP_Attributes_PUB.Con_Rec_Type
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Con_Rec_Type
,   x_old_CON_rec                   OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Con_Rec_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_CON_rec                     QP_Attributes_PUB.Con_Rec_Type := p_CON_rec;
l_p_CON_rec                     QP_Attributes_PUB.Con_Rec_Type;
l_old_CON_rec                 QP_Attributes_PUB.Con_Rec_Type := p_old_CON_rec;
BEGIN

    --  Load API control record

    l_control_rec := QP_GLOBALS.Init_Control_Rec
    (   p_operation     => l_CON_rec.operation
    ,   p_control_rec   => p_control_rec
    );

    --  Set record return status.

    l_CON_rec.return_status        := FND_API.G_RET_STS_SUCCESS;

    --  Prepare record.

    IF l_CON_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

        l_CON_rec.db_flag := FND_API.G_FALSE;

        --  Set missing old record elements to NULL.

        l_old_CON_rec :=
        QP_Con_Util.Convert_Miss_To_Null (l_old_CON_rec);

    ELSIF l_CON_rec.operation = QP_GLOBALS.G_OPR_UPDATE
    OR    l_CON_rec.operation = QP_GLOBALS.G_OPR_DELETE
    THEN

        l_CON_rec.db_flag := FND_API.G_TRUE;

        --  Query Old if missing

        IF  l_old_CON_rec.prc_context_id = FND_API.G_MISS_NUM
        THEN

            l_old_CON_rec := QP_Con_Util.Query_Row
            (   p_prc_context_id              => l_CON_rec.prc_context_id
            );

        ELSE

            --  Set missing old record elements to NULL.

            l_old_CON_rec :=
            QP_Con_Util.Convert_Miss_To_Null (l_old_CON_rec);

        END IF;

        --  Complete new record from old

        l_CON_rec := QP_Con_Util.Complete_Record
        (   p_CON_rec                     => l_CON_rec
        ,   p_old_CON_rec                 => l_old_CON_rec
        );

    END IF;

    --  Attribute level validation.


    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

            QP_Validate_Con.Attributes
            (   x_return_status               => l_return_status
            ,   p_CON_rec                     => l_CON_rec
            ,   p_old_CON_rec                 => l_old_CON_rec
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
        l_p_CON_rec := l_CON_rec;
        QP_Con_Util.Clear_Dependent_Attr
        (   p_CON_rec                     => l_p_CON_rec
        ,   p_old_CON_rec                 => l_old_CON_rec
        ,   x_CON_rec                     => l_CON_rec
        );

    END IF;

    --  Default missing attributes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN
        l_p_CON_rec := l_CON_rec;
        QP_Default_Con.Attributes
        (   p_CON_rec                     => l_p_CON_rec
        ,   x_CON_rec                     => l_CON_rec
        );

    END IF;

    --  Apply attribute changes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN
        l_p_CON_rec := l_CON_rec;
        QP_Con_Util.Apply_Attribute_Changes
        (   p_CON_rec                     => l_p_CON_rec
        ,   p_old_CON_rec                 => l_old_CON_rec
        ,   x_CON_rec                     => l_CON_rec
        );

    END IF;

    --  Entity level validation.

    IF l_control_rec.validate_entity THEN

        IF l_CON_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

            QP_Validate_Con.Entity_Delete
            (   x_return_status               => l_return_status
            ,   p_CON_rec                     => l_CON_rec
            );

        ELSE

            QP_Validate_Con.Entity
            (   x_return_status               => l_return_status
            ,   p_CON_rec                     => l_CON_rec
            ,   p_old_CON_rec                 => l_old_CON_rec
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

        IF l_CON_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

            QP_Con_Util.Delete_Row
            (   p_prc_context_id              => l_CON_rec.prc_context_id
            );

        ELSE

            --  Get Who Information

            l_CON_rec.last_update_date     := SYSDATE;
            l_CON_rec.last_updated_by      := FND_GLOBAL.USER_ID;
            l_CON_rec.last_update_login    := FND_GLOBAL.LOGIN_ID;

            IF l_CON_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                QP_Con_Util.Update_Row (l_CON_rec);

            ELSIF l_CON_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                l_CON_rec.creation_date        := SYSDATE;
                l_CON_rec.created_by           := FND_GLOBAL.USER_ID;

                QP_Con_Util.Insert_Row (l_CON_rec);

            END IF;

        END IF;

    END IF;

    --  Load OUT parameters

    x_CON_rec                      := l_CON_rec;
    x_old_CON_rec                  := l_old_CON_rec;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        l_CON_rec.return_status        := FND_API.G_RET_STS_ERROR;
        x_CON_rec                      := l_CON_rec;
        x_old_CON_rec                  := l_old_CON_rec;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        l_CON_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;
        x_CON_rec                      := l_CON_rec;
        x_old_CON_rec                  := l_old_CON_rec;

        RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Con'
            );
        END IF;

        l_CON_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;
        x_CON_rec                      := l_CON_rec;
        x_old_CON_rec                  := l_old_CON_rec;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Con;

--  Segs

PROCEDURE Segs
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_SEG_tbl                       IN  QP_Attributes_PUB.Seg_Tbl_Type
,   p_old_SEG_tbl                   IN  QP_Attributes_PUB.Seg_Tbl_Type
,   x_SEG_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Seg_Tbl_Type
,   x_old_SEG_tbl                   OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Seg_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_SEG_rec                     QP_Attributes_PUB.Seg_Rec_Type;
l_p_SEG_rec                     QP_Attributes_PUB.Seg_Rec_Type;
l_SEG_tbl                     QP_Attributes_PUB.Seg_Tbl_Type;
l_old_SEG_rec                 QP_Attributes_PUB.Seg_Rec_Type;
l_old_SEG_tbl                 QP_Attributes_PUB.Seg_Tbl_Type;
BEGIN

    --  Init local table variables.

    l_SEG_tbl                      := p_SEG_tbl;
    l_old_SEG_tbl                  := p_old_SEG_tbl;

    FOR I IN 1..l_SEG_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_SEG_rec := l_SEG_tbl(I);

        IF l_old_SEG_tbl.EXISTS(I) THEN
            l_old_SEG_rec := l_old_SEG_tbl(I);
        ELSE
            l_old_SEG_rec := QP_Attributes_PUB.G_MISS_SEG_REC;
        END IF;

        --  Load API control record

        l_control_rec := QP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_SEG_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_SEG_rec.return_status        := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_SEG_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

            l_SEG_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_SEG_rec :=
            QP_Seg_Util.Convert_Miss_To_Null (l_old_SEG_rec);

        ELSIF l_SEG_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        OR    l_SEG_rec.operation = QP_GLOBALS.G_OPR_DELETE
        THEN

            l_SEG_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_SEG_rec.segment_id = FND_API.G_MISS_NUM
            THEN

                l_old_SEG_rec := QP_Seg_Util.Query_Row
                (   p_segment_id                  => l_SEG_rec.segment_id
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_SEG_rec :=
                QP_Seg_Util.Convert_Miss_To_Null (l_old_SEG_rec);

            END IF;

            --  Complete new record from old

            l_SEG_rec := QP_Seg_Util.Complete_Record
            (   p_SEG_rec                     => l_SEG_rec
            ,   p_old_SEG_rec                 => l_old_SEG_rec
            );

        END IF;

        --  Attribute level validation.

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                QP_Validate_Seg.Attributes
                (   x_return_status               => l_return_status
                ,   p_SEG_rec                     => l_SEG_rec
                ,   p_old_SEG_rec                 => l_old_SEG_rec
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
            l_p_SEG_rec := l_SEG_rec;
            QP_Seg_Util.Clear_Dependent_Attr
            (   p_SEG_rec                     => l_p_SEG_rec
            ,   p_old_SEG_rec                 => l_old_SEG_rec
            ,   x_SEG_rec                     => l_SEG_rec
            );

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
            l_p_SEG_rec := l_SEG_rec;
            QP_Default_Seg.Attributes
            (   p_SEG_rec                     => l_p_SEG_rec
            ,   x_SEG_rec                     => l_SEG_rec
            );

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
            l_p_SEG_rec := l_SEG_rec;
            QP_Seg_Util.Apply_Attribute_Changes
            (   p_SEG_rec                     => l_p_SEG_rec
            ,   p_old_SEG_rec                 => l_old_SEG_rec
            ,   x_SEG_rec                     => l_SEG_rec
            );

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_SEG_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Validate_Seg.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_SEG_rec                     => l_SEG_rec
                );

            ELSE

                QP_Validate_Seg.Entity
                (   x_return_status               => l_return_status
                ,   p_SEG_rec                     => l_SEG_rec
                ,   p_old_SEG_rec                 => l_old_SEG_rec
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

            IF l_SEG_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Seg_Util.Delete_Row
                (   p_segment_id                  => l_SEG_rec.segment_id
                );

            ELSE

                --  Get Who Information

                l_SEG_rec.last_update_date     := SYSDATE;
                l_SEG_rec.last_updated_by      := FND_GLOBAL.USER_ID;
                l_SEG_rec.last_update_login    := FND_GLOBAL.LOGIN_ID;

                IF l_SEG_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                    QP_Seg_Util.Update_Row (l_SEG_rec);

                ELSIF l_SEG_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                    l_SEG_rec.creation_date        := SYSDATE;
                    l_SEG_rec.created_by           := FND_GLOBAL.USER_ID;

                    QP_Seg_Util.Insert_Row (l_SEG_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        l_SEG_tbl(I)                   := l_SEG_rec;
        l_old_SEG_tbl(I)               := l_old_SEG_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_SEG_rec.return_status        := FND_API.G_RET_STS_ERROR;
            l_SEG_tbl(I)                   := l_SEG_rec;
            l_old_SEG_tbl(I)               := l_old_SEG_rec;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_SEG_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;
            l_SEG_tbl(I)                   := l_SEG_rec;
            l_old_SEG_tbl(I)               := l_old_SEG_rec;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_SEG_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;
            l_SEG_tbl(I)                   := l_SEG_rec;
            l_old_SEG_tbl(I)               := l_old_SEG_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Segs'
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_SEG_tbl                      := l_SEG_tbl;
    x_old_SEG_tbl                  := l_old_SEG_tbl;

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
            ,   'Segs'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Segs;

--  Start of Comments
--  API name    Process_Attributes
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

PROCEDURE Process_Attributes
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type :=
                                        QP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_CON_REC
,   p_old_CON_rec                   IN  QP_Attributes_PUB.Con_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_CON_REC
,   p_SEG_tbl                       IN  QP_Attributes_PUB.Seg_Tbl_Type :=
                                        QP_Attributes_PUB.G_MISS_SEG_TBL
,   p_old_SEG_tbl                   IN  QP_Attributes_PUB.Seg_Tbl_Type :=
                                        QP_Attributes_PUB.G_MISS_SEG_TBL
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Con_Rec_Type
,   x_SEG_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Seg_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Attributes';
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_p_CON_rec                     QP_Attributes_PUB.Con_Rec_Type := p_CON_rec;
l_CON_rec                     QP_Attributes_PUB.Con_Rec_Type := p_CON_rec;
l_p_old_CON_rec                 QP_Attributes_PUB.Con_Rec_Type := p_old_CON_rec;
l_old_CON_rec                 QP_Attributes_PUB.Con_Rec_Type := p_old_CON_rec;
l_p_SEG_rec                     QP_Attributes_PUB.Seg_Rec_Type;
l_SEG_rec                     QP_Attributes_PUB.Seg_Rec_Type;
l_p_SEG_tbl                     QP_Attributes_PUB.Seg_Tbl_Type;
l_SEG_tbl                     QP_Attributes_PUB.Seg_Tbl_Type;
l_old_SEG_rec                 QP_Attributes_PUB.Seg_Rec_Type;
l_p_old_SEG_tbl                 QP_Attributes_PUB.Seg_Tbl_Type;
l_old_SEG_tbl                 QP_Attributes_PUB.Seg_Tbl_Type;
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

    l_SEG_tbl                      := p_SEG_tbl;
    l_old_SEG_tbl                  := p_old_SEG_tbl;

    --  Con

    Con
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_CON_rec                     => l_p_CON_rec
    ,   p_old_CON_rec                 => l_p_old_CON_rec
    ,   x_CON_rec                     => l_CON_rec
    ,   x_old_CON_rec                 => l_old_CON_rec
    );

    --  Perform CON group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_CON)
    THEN

        NULL;

    END IF;

    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_SEG_tbl.COUNT LOOP

        l_SEG_rec := l_SEG_tbl(I);

        IF l_SEG_rec.operation = QP_GLOBALS.G_OPR_CREATE
        AND (l_SEG_rec.prc_context_id IS NULL OR
            l_SEG_rec.prc_context_id = FND_API.G_MISS_NUM)
        THEN

            --  Copy parent_id.

            l_SEG_tbl(I).prc_context_id := l_CON_rec.prc_context_id;
        END IF;
    END LOOP;

  l_p_SEG_tbl := l_SEG_tbl;
  l_p_old_SEG_tbl := l_old_SEG_tbl;

    --  Segs

    Segs
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_SEG_tbl                     => l_p_SEG_tbl
    ,   p_old_SEG_tbl                 => l_p_old_SEG_tbl
    ,   x_SEG_tbl                     => l_SEG_tbl
    ,   x_old_SEG_tbl                 => l_old_SEG_tbl
    );

    --  Perform SEG group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_SEG)
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

    x_CON_rec                      := l_CON_rec;
    x_SEG_tbl                      := l_SEG_tbl;

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

    IF l_CON_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    FOR I IN 1..l_SEG_tbl.COUNT LOOP

        IF l_SEG_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
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
            ,   'Process_Attributes'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Attributes;

--  Start of Comments
--  API name    Lock_Attributes
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

PROCEDURE Lock_Attributes
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_CON_REC
,   p_SEG_tbl                       IN  QP_Attributes_PUB.Seg_Tbl_Type :=
                                        QP_Attributes_PUB.G_MISS_SEG_TBL
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Con_Rec_Type
,   x_SEG_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Seg_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Attributes';
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_SEG_rec                     QP_Attributes_PUB.Seg_Rec_Type;
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

    SAVEPOINT Lock_Attributes_PVT;

    --  Lock CON

    IF p_CON_rec.operation = QP_GLOBALS.G_OPR_LOCK THEN

        QP_Con_Util.Lock_Row
        (   p_CON_rec                     => p_CON_rec
        ,   x_CON_rec                     => x_CON_rec
        ,   x_return_status               => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    END IF;

    --  Lock SEG

    FOR I IN 1..p_SEG_tbl.COUNT LOOP

        IF p_SEG_tbl(I).operation = QP_GLOBALS.G_OPR_LOCK THEN

            QP_Seg_Util.Lock_Row
            (   p_SEG_rec                     => p_SEG_tbl(I)
            ,   x_SEG_rec                     => l_SEG_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_SEG_tbl(I)                   := l_SEG_rec;

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

        ROLLBACK TO Lock_Attributes_PVT;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Attributes_PVT;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Attributes'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Attributes_PVT;

END Lock_Attributes;

--  Start of Comments
--  API name    Get_Attributes
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

PROCEDURE Get_Attributes
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_prc_context_id                IN  NUMBER
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Con_Rec_Type
,   x_SEG_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attributes_PUB.Seg_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Attributes';
l_CON_rec                     QP_Attributes_PUB.Con_Rec_Type;
l_SEG_tbl                     QP_Attributes_PUB.Seg_Tbl_Type;
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

    --  Get CON ( parent = CON )

    l_CON_rec :=  QP_Con_Util.Query_Row
    (   p_prc_context_id      => p_prc_context_id
    );

        --  Get SEG ( parent = CON )

        l_SEG_tbl :=  QP_Seg_Util.Query_Rows
        (   p_prc_context_id        => l_CON_rec.prc_context_id
        );


    --  Load out parameters

    x_CON_rec                      := l_CON_rec;
    x_SEG_tbl                      := l_SEG_tbl;

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
            ,   'Get_Attributes'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Attributes;

END QP_Attributes_PVT;

/
