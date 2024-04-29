--------------------------------------------------------
--  DDL for Package Body QP_ATTR_MAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_ATTR_MAP_PVT" AS
/* $Header: QPXVMAPB.pls 120.6 2005/08/18 15:52:56 sfiresto ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Attr_Map_PVT';

--  Pte

PROCEDURE Pte
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type
,   p_old_PTE_rec                   IN  QP_Attr_Map_PUB.Pte_Rec_Type
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Pte_Rec_Type
,   x_old_PTE_rec                   OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Pte_Rec_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_PTE_rec                     QP_Attr_Map_PUB.Pte_Rec_Type := p_PTE_rec;
l_p_PTE_rec                     QP_Attr_Map_PUB.Pte_Rec_Type;
l_old_PTE_rec                 QP_Attr_Map_PUB.Pte_Rec_Type := p_old_PTE_rec;
BEGIN

    --  Load API control record

    l_control_rec := QP_GLOBALS.Init_Control_Rec
    (   p_operation     => l_PTE_rec.operation
    ,   p_control_rec   => p_control_rec
    );

    --  Set record return status.

    l_PTE_rec.return_status        := FND_API.G_RET_STS_SUCCESS;

    --  Prepare record.

    IF l_PTE_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

        l_PTE_rec.db_flag := FND_API.G_FALSE;

        --  Set missing old record elements to NULL.

        l_old_PTE_rec :=
        QP_Pte_Util.Convert_Miss_To_Null (l_old_PTE_rec);

    ELSIF l_PTE_rec.operation = QP_GLOBALS.G_OPR_UPDATE
    OR    l_PTE_rec.operation = QP_GLOBALS.G_OPR_DELETE
    THEN

        l_PTE_rec.db_flag := FND_API.G_TRUE;

        --  Query Old if missing

        IF  l_old_PTE_rec.lookup_code = FND_API.G_MISS_CHAR
        THEN

            l_old_PTE_rec := QP_Pte_Util.Query_Row
            (   p_lookup_code                 => l_PTE_rec.lookup_code
            );

        ELSE

            --  Set missing old record elements to NULL.

            l_old_PTE_rec :=
            QP_Pte_Util.Convert_Miss_To_Null (l_old_PTE_rec);

        END IF;

        --  Complete new record from old

        l_PTE_rec := QP_Pte_Util.Complete_Record
        (   p_PTE_rec                     => l_PTE_rec
        ,   p_old_PTE_rec                 => l_old_PTE_rec
        );

    END IF;

    --  Attribute level validation.

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

            QP_Validate_Pte.Attributes
            (   x_return_status               => l_return_status
            ,   p_PTE_rec                     => l_PTE_rec
            ,   p_old_PTE_rec                 => l_old_PTE_rec
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
        l_p_PTE_rec := l_PTE_rec;
        QP_Pte_Util.Clear_Dependent_Attr
        (   p_PTE_rec                     => l_p_PTE_rec
        ,   p_old_PTE_rec                 => l_old_PTE_rec
        ,   x_PTE_rec                     => l_PTE_rec
        );

    END IF;

    --  Default missing attributes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN
        l_p_PTE_rec := l_PTE_rec;
        QP_Default_Pte.Attributes
        (   p_PTE_rec                     => l_p_PTE_rec
        ,   x_PTE_rec                     => l_PTE_rec
        );

    END IF;

    --  Apply attribute changes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN
        l_p_PTE_rec := l_PTE_rec;
        QP_Pte_Util.Apply_Attribute_Changes
        (   p_PTE_rec                     => l_p_PTE_rec
        ,   p_old_PTE_rec                 => l_old_PTE_rec
        ,   x_PTE_rec                     => l_PTE_rec
        );

    END IF;

    --  Entity level validation.

    IF l_control_rec.validate_entity THEN

        IF l_PTE_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

            QP_Validate_Pte.Entity_Delete
            (   x_return_status               => l_return_status
            ,   p_PTE_rec                     => l_PTE_rec
            );

        ELSE

            QP_Validate_Pte.Entity
            (   x_return_status               => l_return_status
            ,   p_PTE_rec                     => l_PTE_rec
            ,   p_old_PTE_rec                 => l_old_PTE_rec
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

        IF l_PTE_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

            QP_Pte_Util.Delete_Row
            (   p_lookup_code                 => l_PTE_rec.lookup_code
            );

        ELSE

            --  Get Who Information

            --**l_PTE_rec.last_update_date     := SYSDATE;
            --**l_PTE_rec.last_updated_by      := FND_GLOBAL.USER_ID;
            --**l_PTE_rec.last_update_login    := FND_GLOBAL.LOGIN_ID;

            IF l_PTE_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                QP_Pte_Util.Update_Row (l_PTE_rec);

            ELSIF l_PTE_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                --**l_PTE_rec.creation_date        := SYSDATE;
                --**l_PTE_rec.created_by           := FND_GLOBAL.USER_ID;

                QP_Pte_Util.Insert_Row (l_PTE_rec);

            END IF;

        END IF;

    END IF;

    --  Load OUT parameters

    x_PTE_rec                      := l_PTE_rec;
    x_old_PTE_rec                  := l_old_PTE_rec;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        l_PTE_rec.return_status        := FND_API.G_RET_STS_ERROR;
        x_PTE_rec                      := l_PTE_rec;
        x_old_PTE_rec                  := l_old_PTE_rec;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        l_PTE_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;
        x_PTE_rec                      := l_PTE_rec;
        x_old_PTE_rec                  := l_old_PTE_rec;

        RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pte'
            );
        END IF;

        l_PTE_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;
        x_PTE_rec                      := l_PTE_rec;
        x_old_PTE_rec                  := l_old_PTE_rec;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pte;

--  Rqts

PROCEDURE Rqts
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_RQT_tbl                       IN  QP_Attr_Map_PUB.Rqt_Tbl_Type
,   p_old_RQT_tbl                   IN  QP_Attr_Map_PUB.Rqt_Tbl_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Rqt_Tbl_Type
,   x_old_RQT_tbl                   OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Rqt_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_RQT_rec                     QP_Attr_Map_PUB.Rqt_Rec_Type;
l_p_RQT_rec                     QP_Attr_Map_PUB.Rqt_Rec_Type;
l_RQT_tbl                     QP_Attr_Map_PUB.Rqt_Tbl_Type;
l_old_RQT_rec                 QP_Attr_Map_PUB.Rqt_Rec_Type;
l_old_RQT_tbl                 QP_Attr_Map_PUB.Rqt_Tbl_Type;
BEGIN

    --  Init local table variables.

    l_RQT_tbl                      := p_RQT_tbl;
    l_old_RQT_tbl                  := p_old_RQT_tbl;

    FOR I IN 1..l_RQT_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_RQT_rec := l_RQT_tbl(I);

        IF l_old_RQT_tbl.EXISTS(I) THEN
            l_old_RQT_rec := l_old_RQT_tbl(I);
        ELSE
            l_old_RQT_rec := QP_Attr_Map_PUB.G_MISS_RQT_REC;
        END IF;

        --  Load API control record

        l_control_rec := QP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_RQT_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_RQT_rec.return_status        := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_RQT_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

            l_RQT_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_RQT_rec :=
            QP_Rqt_Util.Convert_Miss_To_Null (l_old_RQT_rec);

        ELSIF l_RQT_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        OR    l_RQT_rec.operation = QP_GLOBALS.G_OPR_DELETE
        THEN

            l_RQT_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_RQT_rec.request_type_code = FND_API.G_MISS_CHAR
            THEN

                l_old_RQT_rec := QP_Rqt_Util.Query_Row
                (   p_request_type_code           => l_RQT_rec.request_type_code
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_RQT_rec :=
                QP_Rqt_Util.Convert_Miss_To_Null (l_old_RQT_rec);

            END IF;

            --  Complete new record from old

            l_RQT_rec := QP_Rqt_Util.Complete_Record
            (   p_RQT_rec                     => l_RQT_rec
            ,   p_old_RQT_rec                 => l_old_RQT_rec
            );

        END IF;

        --  Attribute level validation.

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                QP_Validate_Rqt.Attributes
                (   x_return_status               => l_return_status
                ,   p_RQT_rec                     => l_RQT_rec
                ,   p_old_RQT_rec                 => l_old_RQT_rec
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

            l_p_RQT_rec := l_RQT_rec;
            QP_Rqt_Util.Clear_Dependent_Attr
            (   p_RQT_rec                     => l_p_RQT_rec
            ,   p_old_RQT_rec                 => l_old_RQT_rec
            ,   x_RQT_rec                     => l_RQT_rec
            );

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
            l_p_RQT_rec := l_RQT_rec;
            QP_Default_Rqt.Attributes
            (   p_RQT_rec                     => l_p_RQT_rec
            ,   x_RQT_rec                     => l_RQT_rec
            );

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
            l_p_RQT_rec := l_RQT_rec;
            QP_Rqt_Util.Apply_Attribute_Changes
            (   p_RQT_rec                     => l_p_RQT_rec
            ,   p_old_RQT_rec                 => l_old_RQT_rec
            ,   x_RQT_rec                     => l_RQT_rec
            );

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_RQT_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Validate_Rqt.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_RQT_rec                     => l_RQT_rec
                );

            ELSE

                QP_Validate_Rqt.Entity
                (   x_return_status               => l_return_status
                ,   p_RQT_rec                     => l_RQT_rec
                ,   p_old_RQT_rec                 => l_old_RQT_rec
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

            IF l_RQT_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Rqt_Util.Delete_Row
                (   p_request_type_code           => l_RQT_rec.request_type_code
                );

            ELSE

                --  Get Who Information

                l_RQT_rec.last_update_date     := SYSDATE;
                l_RQT_rec.last_updated_by      := FND_GLOBAL.USER_ID;
                l_RQT_rec.last_update_login    := FND_GLOBAL.LOGIN_ID;

                IF l_RQT_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                    QP_Rqt_Util.Update_Row (l_RQT_rec);

                ELSIF l_RQT_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                    l_RQT_rec.creation_date        := SYSDATE;
                    l_RQT_rec.created_by           := FND_GLOBAL.USER_ID;

                    QP_Rqt_Util.Insert_Row (l_RQT_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        l_RQT_tbl(I)                   := l_RQT_rec;
        l_old_RQT_tbl(I)               := l_old_RQT_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_RQT_rec.return_status        := FND_API.G_RET_STS_ERROR;
            l_RQT_tbl(I)                   := l_RQT_rec;
            l_old_RQT_tbl(I)               := l_old_RQT_rec;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_RQT_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;
            l_RQT_tbl(I)                   := l_RQT_rec;
            l_old_RQT_tbl(I)               := l_old_RQT_rec;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_RQT_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;
            l_RQT_tbl(I)                   := l_RQT_rec;
            l_old_RQT_tbl(I)               := l_old_RQT_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Rqts'
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_RQT_tbl                      := l_RQT_tbl;
    x_old_RQT_tbl                  := l_old_RQT_tbl;

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
            ,   'Rqts'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Rqts;

--  Sscs

PROCEDURE Sscs
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_SSC_tbl                       IN  QP_Attr_Map_PUB.Ssc_Tbl_Type
,   p_old_SSC_tbl                   IN  QP_Attr_Map_PUB.Ssc_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Ssc_Tbl_Type
,   x_old_SSC_tbl                   OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Ssc_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_SSC_rec                     QP_Attr_Map_PUB.Ssc_Rec_Type;
l_p_SSC_rec                     QP_Attr_Map_PUB.Ssc_Rec_Type;
l_SSC_tbl                     QP_Attr_Map_PUB.Ssc_Tbl_Type;
l_old_SSC_rec                 QP_Attr_Map_PUB.Ssc_Rec_Type;
l_old_SSC_tbl                 QP_Attr_Map_PUB.Ssc_Tbl_Type;
BEGIN

    --  Init local table variables.

    l_SSC_tbl                      := p_SSC_tbl;
    l_old_SSC_tbl                  := p_old_SSC_tbl;

    FOR I IN 1..l_SSC_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_SSC_rec := l_SSC_tbl(I);

        IF l_old_SSC_tbl.EXISTS(I) THEN
            l_old_SSC_rec := l_old_SSC_tbl(I);
        ELSE
            l_old_SSC_rec := QP_Attr_Map_PUB.G_MISS_SSC_REC;
        END IF;

        --  Load API control record

        l_control_rec := QP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_SSC_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_SSC_rec.return_status        := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_SSC_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

            l_SSC_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_SSC_rec :=
            QP_Ssc_Util.Convert_Miss_To_Null (l_old_SSC_rec);

        ELSIF l_SSC_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        OR    l_SSC_rec.operation = QP_GLOBALS.G_OPR_DELETE
        THEN

            l_SSC_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_SSC_rec.pte_source_system_id = FND_API.G_MISS_NUM
            THEN

                l_old_SSC_rec := QP_Ssc_Util.Query_Row
                (   p_pte_source_system_id        => l_SSC_rec.pte_source_system_id
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_SSC_rec :=
                QP_Ssc_Util.Convert_Miss_To_Null (l_old_SSC_rec);

            END IF;

            --  Complete new record from old

            l_SSC_rec := QP_Ssc_Util.Complete_Record
            (   p_SSC_rec                     => l_SSC_rec
            ,   p_old_SSC_rec                 => l_old_SSC_rec
            );

        END IF;

        --  Attribute level validation.

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                QP_Validate_Ssc.Attributes
                (   x_return_status               => l_return_status
                ,   p_SSC_rec                     => l_SSC_rec
                ,   p_old_SSC_rec                 => l_old_SSC_rec
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
            l_p_SSC_rec := l_SSC_rec;
            QP_Ssc_Util.Clear_Dependent_Attr
            (   p_SSC_rec                     => l_p_SSC_rec
            ,   p_old_SSC_rec                 => l_old_SSC_rec
            ,   x_SSC_rec                     => l_SSC_rec
            );

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
            l_p_SSC_rec := l_SSC_rec;
            QP_Default_Ssc.Attributes
            (   p_SSC_rec                     => l_p_SSC_rec
            ,   x_SSC_rec                     => l_SSC_rec
            );

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
            l_p_SSC_rec := l_SSC_rec;
            QP_Ssc_Util.Apply_Attribute_Changes
            (   p_SSC_rec                     => l_p_SSC_rec
            ,   p_old_SSC_rec                 => l_old_SSC_rec
            ,   x_SSC_rec                     => l_SSC_rec
            );

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_SSC_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Validate_Ssc.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_SSC_rec                     => l_SSC_rec
                );

            ELSE

                QP_Validate_Ssc.Entity
                (   x_return_status               => l_return_status
                ,   p_SSC_rec                     => l_SSC_rec
                ,   p_old_SSC_rec                 => l_old_SSC_rec
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

            IF l_SSC_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Ssc_Util.Delete_Row
                (   p_pte_source_system_id        => l_SSC_rec.pte_source_system_id
                );

            ELSE

                --  Get Who Information

                l_SSC_rec.last_update_date     := SYSDATE;
                l_SSC_rec.last_updated_by      := FND_GLOBAL.USER_ID;
                l_SSC_rec.last_update_login    := FND_GLOBAL.LOGIN_ID;

                IF l_SSC_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                    QP_Ssc_Util.Update_Row (l_SSC_rec);

                ELSIF l_SSC_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                    l_SSC_rec.creation_date        := SYSDATE;
                    l_SSC_rec.created_by           := FND_GLOBAL.USER_ID;

                    QP_Ssc_Util.Insert_Row (l_SSC_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        l_SSC_tbl(I)                   := l_SSC_rec;
        l_old_SSC_tbl(I)               := l_old_SSC_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_SSC_rec.return_status        := FND_API.G_RET_STS_ERROR;
            l_SSC_tbl(I)                   := l_SSC_rec;
            l_old_SSC_tbl(I)               := l_old_SSC_rec;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_SSC_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;
            l_SSC_tbl(I)                   := l_SSC_rec;
            l_old_SSC_tbl(I)               := l_old_SSC_rec;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_SSC_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;
            l_SSC_tbl(I)                   := l_SSC_rec;
            l_old_SSC_tbl(I)               := l_old_SSC_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Sscs'
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_SSC_tbl                      := l_SSC_tbl;
    x_old_SSC_tbl                  := l_old_SSC_tbl;

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
            ,   'Sscs'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sscs;

--  Psgs

PROCEDURE Psgs
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_PSG_tbl                       IN  QP_Attr_Map_PUB.Psg_Tbl_Type
,   p_old_PSG_tbl                   IN  QP_Attr_Map_PUB.Psg_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Psg_Tbl_Type
,   x_old_PSG_tbl                   OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Psg_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_PSG_rec                     QP_Attr_Map_PUB.Psg_Rec_Type;
l_p_PSG_rec                     QP_Attr_Map_PUB.Psg_Rec_Type;
l_PSG_tbl                     QP_Attr_Map_PUB.Psg_Tbl_Type;
l_old_PSG_rec                 QP_Attr_Map_PUB.Psg_Rec_Type;
l_old_PSG_tbl                 QP_Attr_Map_PUB.Psg_Tbl_Type;
BEGIN

    --  Init local table variables.

    l_PSG_tbl                      := p_PSG_tbl;
    l_old_PSG_tbl                  := p_old_PSG_tbl;

    FOR I IN 1..l_PSG_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_PSG_rec := l_PSG_tbl(I);

        IF l_old_PSG_tbl.EXISTS(I) THEN
            l_old_PSG_rec := l_old_PSG_tbl(I);
        ELSE
            l_old_PSG_rec := QP_Attr_Map_PUB.G_MISS_PSG_REC;
        END IF;

        --  Load API control record

        l_control_rec := QP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_PSG_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_PSG_rec.return_status        := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_PSG_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

            l_PSG_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_PSG_rec :=
            QP_Psg_Util.Convert_Miss_To_Null (l_old_PSG_rec);

        ELSIF l_PSG_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        OR    l_PSG_rec.operation = QP_GLOBALS.G_OPR_DELETE
        THEN

            l_PSG_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_PSG_rec.segment_pte_id = FND_API.G_MISS_NUM
            THEN

                l_old_PSG_rec := QP_Psg_Util.Query_Row
                (   p_segment_pte_id              => l_PSG_rec.segment_pte_id
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_PSG_rec :=
                QP_Psg_Util.Convert_Miss_To_Null (l_old_PSG_rec);

            END IF;

            --  Complete new record from old

            l_PSG_rec := QP_Psg_Util.Complete_Record
            (   p_PSG_rec                     => l_PSG_rec
            ,   p_old_PSG_rec                 => l_old_PSG_rec
            );

        END IF;

        --  Attribute level validation.

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                QP_Validate_Psg.Attributes
                (   x_return_status               => l_return_status
                ,   p_PSG_rec                     => l_PSG_rec
                ,   p_old_PSG_rec                 => l_old_PSG_rec
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
            l_p_PSG_rec := l_PSG_rec;
            QP_Psg_Util.Clear_Dependent_Attr
            (   p_PSG_rec                     => l_p_PSG_rec
            ,   p_old_PSG_rec                 => l_old_PSG_rec
            ,   x_PSG_rec                     => l_PSG_rec
            );

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
            l_p_PSG_rec := l_PSG_rec;
            QP_Default_Psg.Attributes
            (   p_PSG_rec                     => l_p_PSG_rec
            ,   x_PSG_rec                     => l_PSG_rec
            );

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
            l_p_PSG_rec := l_PSG_rec;
            QP_Psg_Util.Apply_Attribute_Changes
            (   p_PSG_rec                     => l_p_PSG_rec
            ,   p_old_PSG_rec                 => l_old_PSG_rec
            ,   x_PSG_rec                     => l_PSG_rec
            );

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_PSG_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Validate_Psg.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_PSG_rec                     => l_PSG_rec
                );

            ELSE

                QP_Validate_Psg.Entity
                (   x_return_status               => l_return_status
                ,   p_PSG_rec                     => l_PSG_rec
                ,   p_old_PSG_rec                 => l_old_PSG_rec
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

            IF l_PSG_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Psg_Util.Delete_Row
                (   p_segment_pte_id              => l_PSG_rec.segment_pte_id
                );

            ELSE

                --  Get Who Information

                l_PSG_rec.last_update_date     := SYSDATE;
                l_PSG_rec.last_updated_by      := FND_GLOBAL.USER_ID;
                l_PSG_rec.last_update_login    := FND_GLOBAL.LOGIN_ID;

                IF l_PSG_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                    QP_Psg_Util.Update_Row (l_PSG_rec);

                ELSIF l_PSG_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                    l_PSG_rec.creation_date        := SYSDATE;
                    l_PSG_rec.created_by           := FND_GLOBAL.USER_ID;

                    QP_Psg_Util.Insert_Row (l_PSG_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        l_PSG_tbl(I)                   := l_PSG_rec;
        l_old_PSG_tbl(I)               := l_old_PSG_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_PSG_rec.return_status        := FND_API.G_RET_STS_ERROR;
            l_PSG_tbl(I)                   := l_PSG_rec;
            l_old_PSG_tbl(I)               := l_old_PSG_rec;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_PSG_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;
            l_PSG_tbl(I)                   := l_PSG_rec;
            l_old_PSG_tbl(I)               := l_old_PSG_rec;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_PSG_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;
            l_PSG_tbl(I)                   := l_PSG_rec;
            l_old_PSG_tbl(I)               := l_old_PSG_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Psgs'
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_PSG_tbl                      := l_PSG_tbl;
    x_old_PSG_tbl                  := l_old_PSG_tbl;

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
            ,   'Psgs'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Psgs;

--  Sous

PROCEDURE Sous
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_SOU_tbl                       IN  QP_Attr_Map_PUB.Sou_Tbl_Type
,   p_old_SOU_tbl                   IN  QP_Attr_Map_PUB.Sou_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Sou_Tbl_Type
,   x_old_SOU_tbl                   OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Sou_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_SOU_rec                     QP_Attr_Map_PUB.Sou_Rec_Type;
l_p_SOU_rec                     QP_Attr_Map_PUB.Sou_Rec_Type;
l_SOU_tbl                     QP_Attr_Map_PUB.Sou_Tbl_Type;
l_old_SOU_rec                 QP_Attr_Map_PUB.Sou_Rec_Type;
l_old_SOU_tbl                 QP_Attr_Map_PUB.Sou_Tbl_Type;
BEGIN

    --  Init local table variables.

    l_SOU_tbl                      := p_SOU_tbl;
    l_old_SOU_tbl                  := p_old_SOU_tbl;

    FOR I IN 1..l_SOU_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_SOU_rec := l_SOU_tbl(I);

        IF l_old_SOU_tbl.EXISTS(I) THEN
            l_old_SOU_rec := l_old_SOU_tbl(I);
        ELSE
            l_old_SOU_rec := QP_Attr_Map_PUB.G_MISS_SOU_REC;
        END IF;

        --  Load API control record

        l_control_rec := QP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_SOU_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_SOU_rec.return_status        := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_SOU_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

            l_SOU_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_SOU_rec :=
            QP_Sou_Util.Convert_Miss_To_Null (l_old_SOU_rec);

        ELSIF l_SOU_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        OR    l_SOU_rec.operation = QP_GLOBALS.G_OPR_DELETE
        THEN

            l_SOU_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_SOU_rec.attribute_sourcing_id = FND_API.G_MISS_NUM
            THEN

    oe_debug_pub.add('attribute_sou is missing');
                l_old_SOU_rec := QP_Sou_Util.Query_Row
                (   p_attribute_sourcing_id       => l_SOU_rec.attribute_sourcing_id
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_SOU_rec :=
                QP_Sou_Util.Convert_Miss_To_Null (l_old_SOU_rec);

            END IF;

            --  Complete new record from old

            l_SOU_rec := QP_Sou_Util.Complete_Record
            (   p_SOU_rec                     => l_SOU_rec
            ,   p_old_SOU_rec                 => l_old_SOU_rec
            );

        END IF;

        --  Attribute level validation.

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                QP_Validate_Sou.Attributes
                (   x_return_status               => l_return_status
                ,   p_SOU_rec                     => l_SOU_rec
                ,   p_old_SOU_rec                 => l_old_SOU_rec
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
            l_p_SOU_rec := l_SOU_rec;
            QP_Sou_Util.Clear_Dependent_Attr
            (   p_SOU_rec                     => l_p_SOU_rec
            ,   p_old_SOU_rec                 => l_old_SOU_rec
            ,   x_SOU_rec                     => l_SOU_rec
            );

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
            l_p_SOU_rec := l_SOU_rec;
            QP_Default_Sou.Attributes
            (   p_SOU_rec                     => l_p_SOU_rec
            ,   x_SOU_rec                     => l_SOU_rec
            );

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
            l_p_SOU_rec := l_SOU_rec;
            QP_Sou_Util.Apply_Attribute_Changes
            (   p_SOU_rec                     => l_p_SOU_rec
            ,   p_old_SOU_rec                 => l_old_SOU_rec
            ,   x_SOU_rec                     => l_SOU_rec
            );

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_SOU_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Validate_Sou.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_SOU_rec                     => l_SOU_rec
                );

            ELSE

                QP_Validate_Sou.Entity
                (   x_return_status               => l_return_status
                ,   p_SOU_rec                     => l_SOU_rec
                ,   p_old_SOU_rec                 => l_old_SOU_rec
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

            IF l_SOU_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Sou_Util.Delete_Row
                (   p_attribute_sourcing_id       => l_SOU_rec.attribute_sourcing_id
                );

            ELSE

                --  Get Who Information

                l_SOU_rec.last_update_date     := SYSDATE;
                l_SOU_rec.last_updated_by      := FND_GLOBAL.USER_ID;
                l_SOU_rec.last_update_login    := FND_GLOBAL.LOGIN_ID;

                IF l_SOU_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                    QP_Sou_Util.Update_Row (l_SOU_rec);

                ELSIF l_SOU_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                    l_SOU_rec.creation_date        := SYSDATE;
                    l_SOU_rec.created_by           := FND_GLOBAL.USER_ID;

                    QP_Sou_Util.Insert_Row (l_SOU_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        l_SOU_tbl(I)                   := l_SOU_rec;
        l_old_SOU_tbl(I)               := l_old_SOU_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_SOU_rec.return_status        := FND_API.G_RET_STS_ERROR;
            l_SOU_tbl(I)                   := l_SOU_rec;
            l_old_SOU_tbl(I)               := l_old_SOU_rec;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_SOU_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;
            l_SOU_tbl(I)                   := l_SOU_rec;
            l_old_SOU_tbl(I)               := l_old_SOU_rec;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_SOU_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;
            l_SOU_tbl(I)                   := l_SOU_rec;
            l_old_SOU_tbl(I)               := l_old_SOU_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Sous'
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_SOU_tbl                      := l_SOU_tbl;
    x_old_SOU_tbl                  := l_old_SOU_tbl;

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
            ,   'Sous'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sous;

--  Fnas

PROCEDURE Fnas
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_FNA_tbl                       IN  QP_Attr_Map_PUB.Fna_Tbl_Type
,   p_old_FNA_tbl                   IN  QP_Attr_Map_PUB.Fna_Tbl_Type
,   x_FNA_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Fna_Tbl_Type
,   x_old_FNA_tbl                   OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Fna_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_FNA_rec                     QP_Attr_Map_PUB.Fna_Rec_Type;
l_p_FNA_rec                   QP_Attr_Map_PUB.Fna_Rec_Type;
l_FNA_tbl                     QP_Attr_Map_PUB.Fna_Tbl_Type;
l_old_FNA_rec                 QP_Attr_Map_PUB.Fna_Rec_Type;
l_old_FNA_tbl                 QP_Attr_Map_PUB.Fna_Tbl_Type;
l_dummy_ret_status            VARCHAR2(1);
BEGIN

    --  Init local table variables.
    l_FNA_tbl                      := p_FNA_tbl;
    l_old_FNA_tbl                  := p_old_FNA_tbl;

    FOR I IN 1..l_FNA_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_FNA_rec := l_FNA_tbl(I);

        IF l_old_FNA_tbl.EXISTS(I) THEN
            l_old_FNA_rec := l_old_FNA_tbl(I);
        ELSE
            l_old_FNA_rec := QP_Attr_Map_PUB.G_MISS_FNA_REC;
        END IF;

        --  Load API control record

        l_control_rec := QP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_FNA_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_FNA_rec.return_status        := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_FNA_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

            l_FNA_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_FNA_rec :=
            QP_Fna_Util.Convert_Miss_To_Null (l_old_FNA_rec);

        ELSIF l_FNA_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        OR    l_FNA_rec.operation = QP_GLOBALS.G_OPR_DELETE
        THEN

            l_FNA_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_FNA_rec.pte_sourcesystem_fnarea_id = FND_API.G_MISS_NUM
            THEN

                l_old_FNA_rec := QP_Fna_Util.Query_Row
                (   p_pte_sourcesystem_fnarea_id  => l_FNA_rec.pte_sourcesystem_fnarea_id
                );
            ELSE

                --  Set missing old record elements to NULL.

                l_old_FNA_rec :=
                QP_Fna_Util.Convert_Miss_To_Null (l_old_FNA_rec);

            END IF;

            --  Complete new record from old

            l_FNA_rec := QP_Fna_Util.Complete_Record
            (   p_FNA_rec                     => l_FNA_rec
            ,   p_old_FNA_rec                 => l_old_FNA_rec
            );

        END IF;

        --  Attribute level validation.

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                QP_Validate_Fna.Attributes
                (   x_return_status               => l_return_status
                ,   p_FNA_rec                     => l_FNA_rec
                ,   p_old_FNA_rec                 => l_old_FNA_rec
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
            l_p_FNA_rec := l_FNA_rec;
            QP_Fna_Util.Clear_Dependent_Attr
            (   p_FNA_rec                     => l_p_FNA_rec
            ,   p_old_FNA_rec                 => l_old_FNA_rec
            ,   x_FNA_rec                     => l_FNA_rec
            );

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
            l_p_FNA_rec := l_FNA_rec;
            QP_Default_Fna.Attributes
            (   p_FNA_rec                     => l_p_FNA_rec
            ,   x_FNA_rec                     => l_FNA_rec
            );

        END IF;

        --  Apply attribute changes
        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
            l_p_FNA_rec := l_FNA_rec;
            QP_Fna_Util.Apply_Attribute_Changes
            (   p_FNA_rec                     => l_p_FNA_rec
            ,   p_old_FNA_rec                 => l_old_FNA_rec
            ,   p_called_from_ui              => l_control_rec.called_from_ui
            ,   x_FNA_rec                     => l_FNA_rec
            );

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_FNA_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Validate_Fna.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_FNA_rec                     => l_FNA_rec
                );

            ELSE

                QP_Validate_Fna.Entity
                (   x_return_status               => l_return_status
                ,   p_FNA_rec                     => l_FNA_rec
                ,   p_old_FNA_rec                 => l_old_FNA_rec
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

            IF l_FNA_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Fna_Util.Delete_Row
                (   p_pte_sourcesystem_fnarea_id  => l_FNA_rec.pte_sourcesystem_fnarea_id
                );

                qp_delayed_requests_PVT.log_request(
                  p_entity_code => QP_GLOBALS.G_ENTITY_FNA,
                  p_entity_id  => l_FNA_rec.pte_source_system_id,
                  p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_FNA,
                  p_requesting_entity_id => l_FNA_rec.pte_source_system_id,
                  p_request_type => QP_GLOBALS.G_CHECK_ENABLED_FUNC_AREAS,
                  x_return_status => l_dummy_ret_status);

                IF l_control_rec.called_from_ui = 'N' THEN
                  QP_Fna_Util.Warn_Disable_Delete_Fna
                    ( p_action             => 'DELETE'
                    , p_called_from_ui     => l_control_rec.called_from_ui
                    , p_functional_area_id => l_FNA_rec.functional_area_id
                    , p_pte_ss_id          => l_FNA_rec.pte_source_system_id
                    );
                END IF;

            ELSE

                --  Get Who Information

                l_FNA_rec.last_update_date     := SYSDATE;
                l_FNA_rec.last_updated_by      := FND_GLOBAL.USER_ID;
                l_FNA_rec.last_update_login    := FND_GLOBAL.LOGIN_ID;

                IF l_FNA_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                    QP_Fna_Util.Update_Row (l_FNA_rec);

                ELSIF l_FNA_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                    l_FNA_rec.creation_date        := SYSDATE;
                    l_FNA_rec.created_by           := FND_GLOBAL.USER_ID;

                    QP_Fna_Util.Insert_Row (l_FNA_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        l_FNA_tbl(I)                   := l_FNA_rec;
        l_old_FNA_tbl(I)               := l_old_FNA_rec;

    --  For loop exception handler.

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_FNA_rec.return_status        := FND_API.G_RET_STS_ERROR;
            l_FNA_tbl(I)                   := l_FNA_rec;
            l_old_FNA_tbl(I)               := l_old_FNA_rec;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_FNA_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;
            l_FNA_tbl(I)                   := l_FNA_rec;
            l_old_FNA_tbl(I)               := l_old_FNA_rec;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_FNA_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;
            l_FNA_tbl(I)                   := l_FNA_rec;
            l_old_FNA_tbl(I)               := l_old_FNA_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Fnas'
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_FNA_tbl                      := l_FNA_tbl;
    x_old_FNA_tbl                  := l_old_FNA_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        if l_control_rec.called_from_ui = 'N' then
	   qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		(p_entity_code => QP_GLOBALS.G_ENTITY_FNA,
	      p_entity_id => l_FNA_rec.pte_source_system_id,
	      x_return_status => l_return_status );
        end if;

        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        if l_control_rec.called_from_ui = 'N' then
	   qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		(p_entity_code => QP_GLOBALS.G_ENTITY_FNA,
	      p_entity_id => l_FNA_rec.pte_source_system_id,
	      x_return_status => l_return_status );
        end if;

        RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Fnas'
            );
        END IF;


        if l_control_rec.called_from_ui = 'N' then
	   qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		(p_entity_code => QP_GLOBALS.G_ENTITY_FNA,
	      p_entity_id => l_FNA_rec.pte_source_system_id,
	      x_return_status => l_return_status );
        end if;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Fnas;

--  Start of Comments
--  API name    Process_Attr_Mapping
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

PROCEDURE Process_Attr_Mapping
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type :=
                                        QP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PTE_REC
,   p_old_PTE_rec                   IN  QP_Attr_Map_PUB.Pte_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PTE_REC
,   p_RQT_tbl                       IN  QP_Attr_Map_PUB.Rqt_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_RQT_TBL
,   p_old_RQT_tbl                   IN  QP_Attr_Map_PUB.Rqt_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_RQT_TBL
,   p_SSC_tbl                       IN  QP_Attr_Map_PUB.Ssc_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SSC_TBL
,   p_old_SSC_tbl                   IN  QP_Attr_Map_PUB.Ssc_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SSC_TBL
,   p_PSG_tbl                       IN  QP_Attr_Map_PUB.Psg_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PSG_TBL
,   p_old_PSG_tbl                   IN  QP_Attr_Map_PUB.Psg_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PSG_TBL
,   p_SOU_tbl                       IN  QP_Attr_Map_PUB.Sou_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SOU_TBL
,   p_old_SOU_tbl                   IN  QP_Attr_Map_PUB.Sou_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SOU_TBL
,   p_FNA_tbl                       IN  QP_Attr_Map_PUB.Fna_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_FNA_TBL
,   p_old_FNA_tbl                   IN  QP_Attr_Map_PUB.Fna_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_FNA_TBL
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Pte_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Rqt_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Ssc_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Psg_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Sou_Tbl_Type
,   x_FNA_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Fna_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Attr_Mapping';
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_PTE_rec                     QP_Attr_Map_PUB.Pte_Rec_Type := p_PTE_rec;
l_p_PTE_rec                   QP_Attr_Map_PUB.Pte_Rec_Type := p_PTE_rec;
l_old_PTE_rec                 QP_Attr_Map_PUB.Pte_Rec_Type := p_old_PTE_rec;
l_p_old_PTE_rec               QP_Attr_Map_PUB.Pte_Rec_Type := p_old_PTE_rec;
l_RQT_rec                     QP_Attr_Map_PUB.Rqt_Rec_Type;
l_RQT_tbl                     QP_Attr_Map_PUB.Rqt_Tbl_Type;
l_p_RQT_tbl                   QP_Attr_Map_PUB.Rqt_Tbl_Type;
l_old_RQT_rec                 QP_Attr_Map_PUB.Rqt_Rec_Type;
l_old_RQT_tbl                 QP_Attr_Map_PUB.Rqt_Tbl_Type;
l_p_old_RQT_tbl               QP_Attr_Map_PUB.Rqt_Tbl_Type;
l_SSC_rec                     QP_Attr_Map_PUB.Ssc_Rec_Type;
l_SSC_tbl                     QP_Attr_Map_PUB.Ssc_Tbl_Type;
l_p_SSC_tbl                   QP_Attr_Map_PUB.Ssc_Tbl_Type;
l_old_SSC_rec                 QP_Attr_Map_PUB.Ssc_Rec_Type;
l_old_SSC_tbl                 QP_Attr_Map_PUB.Ssc_Tbl_Type;
l_p_old_SSC_tbl               QP_Attr_Map_PUB.Ssc_Tbl_Type;
l_PSG_rec                     QP_Attr_Map_PUB.Psg_Rec_Type;
l_PSG_tbl                     QP_Attr_Map_PUB.Psg_Tbl_Type;
l_p_PSG_tbl                   QP_Attr_Map_PUB.Psg_Tbl_Type;
l_old_PSG_rec                 QP_Attr_Map_PUB.Psg_Rec_Type;
l_old_PSG_tbl                 QP_Attr_Map_PUB.Psg_Tbl_Type;
l_p_old_PSG_tbl               QP_Attr_Map_PUB.Psg_Tbl_Type;
l_SOU_rec                     QP_Attr_Map_PUB.Sou_Rec_Type;
l_SOU_tbl                     QP_Attr_Map_PUB.Sou_Tbl_Type;
l_p_SOU_tbl                   QP_Attr_Map_PUB.Sou_Tbl_Type;
l_old_SOU_rec                 QP_Attr_Map_PUB.Sou_Rec_Type;
l_old_SOU_tbl                 QP_Attr_Map_PUB.Sou_Tbl_Type;
l_p_old_SOU_tbl               QP_Attr_Map_PUB.Sou_Tbl_Type;
l_FNA_rec                     QP_Attr_Map_PUB.Fna_Rec_Type;
l_FNA_tbl                     QP_Attr_Map_PUB.Fna_Tbl_Type;
l_p_FNA_tbl                   QP_Attr_Map_PUB.Fna_Tbl_Type;
l_old_FNA_rec                 QP_Attr_Map_PUB.Fna_Rec_Type;
l_old_FNA_tbl                 QP_Attr_Map_PUB.Fna_Tbl_Type;
l_p_old_FNA_tbl               QP_Attr_Map_PUB.Fna_Tbl_Type;
BEGIN
    oe_debug_pub.add('Entered process_attr_mapping.........................');

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

    l_RQT_tbl                      := p_RQT_tbl;
    l_old_RQT_tbl                  := p_old_RQT_tbl;

    --  Init local table variables.

    l_SSC_tbl                      := p_SSC_tbl;
    l_old_SSC_tbl                  := p_old_SSC_tbl;

    --  Init local table variables.

    l_PSG_tbl                      := p_PSG_tbl;
    l_old_PSG_tbl                  := p_old_PSG_tbl;

    --  Init local table variables.

    l_SOU_tbl                      := p_SOU_tbl;
    l_old_SOU_tbl                  := p_old_SOU_tbl;

    --  Init local table variables.

    l_FNA_tbl                      := p_FNA_tbl;
    l_old_FNA_tbl                  := p_old_FNA_tbl;

    --  Pte
    l_p_PTE_rec := l_PTE_rec;
    l_p_old_PTE_rec := l_old_PTE_rec;
    Pte
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_PTE_rec                     => l_p_PTE_rec
    ,   p_old_PTE_rec                 => l_p_old_PTE_rec
    ,   x_PTE_rec                     => l_PTE_rec
    ,   x_old_PTE_rec                 => l_old_PTE_rec
    );

    --  Perform PTE group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_PTE)
    THEN

        NULL;

    END IF;

    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_RQT_tbl.COUNT LOOP

        l_RQT_rec := l_RQT_tbl(I);

        IF l_RQT_rec.operation = QP_GLOBALS.G_OPR_CREATE
        --**AND (l_RQT_rec.lookup_code IS NULL OR
        AND (l_RQT_rec.pte_code IS NULL OR
        --**    l_RQT_rec.lookup_code = FND_API.G_MISS_CHAR)
            l_RQT_rec.pte_code = FND_API.G_MISS_CHAR)
        THEN

            --  Copy parent_id.

            --**l_RQT_tbl(I).lookup_code := l_PTE_rec.lookup_code;
            l_RQT_tbl(I).pte_code := l_PTE_rec.lookup_code;
        END IF;
    END LOOP;

    --  Rqts
    l_p_RQT_tbl := l_RQT_tbl;
    l_p_old_RQT_tbl := l_old_RQT_tbl;
    Rqts
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_RQT_tbl                     => l_p_RQT_tbl
    ,   p_old_RQT_tbl                 => l_p_old_RQT_tbl
    ,   x_RQT_tbl                     => l_RQT_tbl
    ,   x_old_RQT_tbl                 => l_old_RQT_tbl
    );

    --  Perform RQT group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_RQT)
    THEN

        NULL;

    END IF;

    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_SSC_tbl.COUNT LOOP

        l_SSC_rec := l_SSC_tbl(I);

        IF l_SSC_rec.operation = QP_GLOBALS.G_OPR_CREATE
        --**AND (l_SSC_rec.lookup_code IS NULL OR
        AND (l_SSC_rec.pte_code IS NULL OR
            --**l_SSC_rec.lookup_code = FND_API.G_MISS_CHAR)
            l_SSC_rec.pte_code = FND_API.G_MISS_CHAR)
        THEN

            --  Copy parent_id.

            --**l_SSC_tbl(I).lookup_code := l_PTE_rec.lookup_code;
            l_SSC_tbl(I).pte_code := l_PTE_rec.lookup_code;
        END IF;
    END LOOP;

    --  Sscs
    l_p_SSC_tbl := l_SSC_tbl;
    l_p_old_SSC_tbl := l_old_SSC_tbl;
    Sscs
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_SSC_tbl                     => l_p_SSC_tbl
    ,   p_old_SSC_tbl                 => l_p_old_SSC_tbl
    ,   x_SSC_tbl                     => l_SSC_tbl
    ,   x_old_SSC_tbl                 => l_old_SSC_tbl
    );

    --  Perform SSC group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_SSC)
    THEN

        NULL;

    END IF;

    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_PSG_tbl.COUNT LOOP

        l_PSG_rec := l_PSG_tbl(I);

        IF l_PSG_rec.operation = QP_GLOBALS.G_OPR_CREATE
        --**AND (l_PSG_rec.lookup_code IS NULL OR
        AND (l_PSG_rec.pte_code IS NULL OR
            --**l_PSG_rec.lookup_code = FND_API.G_MISS_CHAR)
            l_PSG_rec.pte_code = FND_API.G_MISS_CHAR)
        THEN

            --  Copy parent_id.

            --**l_PSG_tbl(I).lookup_code := l_PTE_rec.lookup_code;
            l_PSG_tbl(I).pte_code := l_PTE_rec.lookup_code;
        END IF;
    END LOOP;

    --  Psgs
    l_p_PSG_tbl := l_PSG_tbl;
    l_p_old_PSG_tbl := l_old_PSG_tbl;
    Psgs
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_PSG_tbl                     => l_p_PSG_tbl
    ,   p_old_PSG_tbl                 => l_p_old_PSG_tbl
    ,   x_PSG_tbl                     => l_PSG_tbl
    ,   x_old_PSG_tbl                 => l_old_PSG_tbl
    );

    --  Perform PSG group requests.
    --dbms_output.put_line('in qp_qttr_mapping_pvt 1 ............................');

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_PSG)
    THEN

        NULL;

    END IF;

    --  Load parent key if missing and operation is create.

    --dbms_output.put_line('in qp_qttr_mapping_pvt 2 ............................');
    --dbms_output.put_line('l_sou_tbl.count='||l_sou_tbl.count);
    FOR I IN 1..l_SOU_tbl.COUNT LOOP

        l_SOU_rec := l_SOU_tbl(I);

    --dbms_output.put_line('in qp_qttr_mapping_pvt 21 ............................');
        IF l_SOU_rec.operation = QP_GLOBALS.G_OPR_CREATE
        --**AND (l_SOU_rec.segment_pte_id IS NULL OR
        AND (l_SOU_rec.segment_id IS NULL OR
            --**l_SOU_rec.segment_pte_id = FND_API.G_MISS_NUM)
            l_SOU_rec.segment_id = FND_API.G_MISS_NUM)
        THEN
    --dbms_output.put_line('in qp_qttr_mapping_pvt inside 21 ............................');
    --dbms_output.put_line('l_sou_rec.psg_index='||l_sou_rec.psg_index);

       --** Added next line
        l_SOU_tbl(I).segment_id := l_PSG_rec.segment_id;
            --  Check If parent exists.

/*
            IF l_PSG_tbl.EXISTS(l_SOU_rec.PSG_index) THEN

                --  Copy parent_id.
    --dbms_output.put_line('in qp_qttr_mapping_pvt 22 ............................');

                --**l_SOU_tbl(I).segment_pte_id := l_PSG_tbl(l_SOU_rec.PSG_index).segment_pte_id;
                l_SOU_tbl(I).segment_id := l_PSG_tbl(l_SOU_rec.PSG_index).segment_id;

            ELSE
    --dbms_output.put_line('in qp_qttr_mapping_pvt 22 else ............................');

                IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
    --dbms_output.put_line('in qp_qttr_mapping_pvt 23 ............................');

                    FND_MESSAGE.SET_NAME('QP','QP_API_INV_PARENT_INDEX');
                    FND_MESSAGE.SET_TOKEN('ENTITY_NAME','SOU');
                    FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
                    FND_MESSAGE.SET_TOKEN('PARENT_INDEX',l_SOU_rec.PSG_index);
                    OE_MSG_PUB.Add;

                END IF;
            END IF;
*/
            END IF;
    END LOOP;

    --  Sous
    --dbms_output.put_line('in qp_qttr_mapping_pvt 3 ............................');

    l_p_SOU_tbl := l_SOU_tbl;
    l_p_old_SOU_tbl := l_old_SOU_tbl;
    Sous
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_SOU_tbl                     => l_p_SOU_tbl
    ,   p_old_SOU_tbl                 => l_p_old_SOU_tbl
    ,   x_SOU_tbl                     => l_SOU_tbl
    ,   x_old_SOU_tbl                 => l_old_SOU_tbl
    );
    --dbms_output.put_line('in qp_qttr_mapping_pvt 4 ............................');

    --  Perform SOU group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_SOU)
    THEN

        NULL;

    END IF;

    --  Load parent key if missing and operation is create.
    FOR I IN 1..l_FNA_tbl.COUNT LOOP

        l_FNA_rec := l_FNA_tbl(I);

        IF l_FNA_rec.operation = QP_GLOBALS.G_OPR_CREATE
        AND (l_FNA_rec.pte_source_system_id IS NULL OR
            l_FNA_rec.pte_source_system_id = FND_API.G_MISS_NUM)
        THEN

          -- Copy parent_id.
          l_FNA_tbl(I).pte_source_system_id := l_SSC_rec.pte_source_system_id;
        END IF;

    END LOOP;

    --  Fnas

    l_p_FNA_tbl := l_FNA_tbl;
    l_p_old_FNA_tbl := l_old_FNA_tbl;
    Fnas
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_FNA_tbl                     => l_p_FNA_tbl
    ,   p_old_FNA_tbl                 => l_p_old_FNA_tbl
    ,   x_FNA_tbl                     => l_FNA_tbl
    ,   x_old_FNA_tbl                 => l_old_FNA_tbl
    );

    --  Perform FNA group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_FNA)
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

    x_PTE_rec                      := l_PTE_rec;
    x_RQT_tbl                      := l_RQT_tbl;
    x_SSC_tbl                      := l_SSC_tbl;
    x_PSG_tbl                      := l_PSG_tbl;
    x_SOU_tbl                      := l_SOU_tbl;
    x_FNA_tbl                      := l_FNA_tbl;

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

    IF l_PTE_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    FOR I IN 1..l_RQT_tbl.COUNT LOOP

        IF l_RQT_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END LOOP;

    FOR I IN 1..l_SSC_tbl.COUNT LOOP

        IF l_SSC_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END LOOP;

    FOR I IN 1..l_PSG_tbl.COUNT LOOP

        IF l_PSG_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END LOOP;

    FOR I IN 1..l_SOU_tbl.COUNT LOOP

        IF l_SOU_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END LOOP;

    FOR I IN 1..l_FNA_tbl.COUNT LOOP

        IF l_FNA_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
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

         if p_control_rec.called_from_ui = 'N' then
	   qp_delayed_requests_pvt.Clear_Request
		(x_return_status => l_return_status);
        end if;

       --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        if p_control_rec.called_from_ui = 'N' then
	   qp_delayed_requests_pvt.Clear_Request
		(x_return_status => l_return_status);
        end if;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        if p_control_rec.called_from_ui = 'N' then
	   qp_delayed_requests_pvt.Clear_Request
		(x_return_status => l_return_status);
        end if;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Attr_Mapping'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Attr_Mapping;

--  Start of Comments
--  API name    Lock_Attr_Mapping
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

PROCEDURE Lock_Attr_Mapping
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PTE_rec                       IN  QP_Attr_Map_PUB.Pte_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PTE_REC
,   p_RQT_tbl                       IN  QP_Attr_Map_PUB.Rqt_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_RQT_TBL
,   p_SSC_tbl                       IN  QP_Attr_Map_PUB.Ssc_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SSC_TBL
,   p_PSG_tbl                       IN  QP_Attr_Map_PUB.Psg_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_PSG_TBL
,   p_SOU_tbl                       IN  QP_Attr_Map_PUB.Sou_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SOU_TBL
,   p_FNA_tbl                       IN  QP_Attr_Map_PUB.Fna_Tbl_Type :=
                                        QP_Attr_Map_PUB.G_MISS_FNA_TBL
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Pte_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Rqt_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Ssc_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Psg_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Sou_Tbl_Type
,   x_FNA_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Fna_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Attr_Mapping';
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_RQT_rec                     QP_Attr_Map_PUB.Rqt_Rec_Type;
l_SSC_rec                     QP_Attr_Map_PUB.Ssc_Rec_Type;
l_PSG_rec                     QP_Attr_Map_PUB.Psg_Rec_Type;
l_SOU_rec                     QP_Attr_Map_PUB.Sou_Rec_Type;
l_FNA_rec                     QP_Attr_Map_PUB.Fna_Rec_Type;
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

    SAVEPOINT Lock_Attr_Mapping_PVT;

    --  Lock PTE

    IF p_PTE_rec.operation = QP_GLOBALS.G_OPR_LOCK THEN

        QP_Pte_Util.Lock_Row
        (   p_PTE_rec                     => p_PTE_rec
        ,   x_PTE_rec                     => x_PTE_rec
        ,   x_return_status               => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    END IF;

    --  Lock RQT

    FOR I IN 1..p_RQT_tbl.COUNT LOOP

        IF p_RQT_tbl(I).operation = QP_GLOBALS.G_OPR_LOCK THEN

            QP_Rqt_Util.Lock_Row
            (   p_RQT_rec                     => p_RQT_tbl(I)
            ,   x_RQT_rec                     => l_RQT_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_RQT_tbl(I)                   := l_RQT_rec;

        END IF;

    END LOOP;

    --  Lock SSC

    FOR I IN 1..p_SSC_tbl.COUNT LOOP

        IF p_SSC_tbl(I).operation = QP_GLOBALS.G_OPR_LOCK THEN

            QP_Ssc_Util.Lock_Row
            (   p_SSC_rec                     => p_SSC_tbl(I)
            ,   x_SSC_rec                     => l_SSC_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_SSC_tbl(I)                   := l_SSC_rec;

        END IF;

    END LOOP;

    --  Lock PSG

    FOR I IN 1..p_PSG_tbl.COUNT LOOP

        IF p_PSG_tbl(I).operation = QP_GLOBALS.G_OPR_LOCK THEN

            QP_Psg_Util.Lock_Row
            (   p_PSG_rec                     => p_PSG_tbl(I)
            ,   x_PSG_rec                     => l_PSG_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_PSG_tbl(I)                   := l_PSG_rec;

        END IF;

    END LOOP;

    --  Lock SOU

    FOR I IN 1..p_SOU_tbl.COUNT LOOP

        IF p_SOU_tbl(I).operation = QP_GLOBALS.G_OPR_LOCK THEN

            QP_Sou_Util.Lock_Row
            (   p_SOU_rec                     => p_SOU_tbl(I)
            ,   x_SOU_rec                     => l_SOU_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_SOU_tbl(I)                   := l_SOU_rec;

        END IF;

    END LOOP;

    --  Lock FNA

    FOR I IN 1..p_FNA_tbl.COUNT LOOP

        IF p_FNA_tbl(I).operation = QP_GLOBALS.G_OPR_LOCK THEN

            QP_Fna_Util.Lock_Row
            (   p_FNA_rec                     => p_FNA_tbl(I)
            ,   x_FNA_rec                     => l_FNA_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_FNA_tbl(I)                   := l_FNA_rec;

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

        ROLLBACK TO Lock_Attr_Mapping_PVT;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Attr_Mapping_PVT;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Attr_Mapping'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Attr_Mapping_PVT;

END Lock_Attr_Mapping;

--  Start of Comments
--  API name    Get_Attr_Mapping
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

PROCEDURE Get_Attr_Mapping
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_lookup_code                   IN  VARCHAR2
,   x_PTE_rec                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Pte_Rec_Type
,   x_RQT_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Rqt_Tbl_Type
,   x_SSC_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Ssc_Tbl_Type
,   x_PSG_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Psg_Tbl_Type
,   x_SOU_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Sou_Tbl_Type
,   x_FNA_tbl                       OUT NOCOPY /* file.sql.39 change */ QP_Attr_Map_PUB.Fna_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Attr_Mapping';
l_PTE_rec                     QP_Attr_Map_PUB.Pte_Rec_Type;
l_RQT_tbl                     QP_Attr_Map_PUB.Rqt_Tbl_Type;
l_SSC_tbl                     QP_Attr_Map_PUB.Ssc_Tbl_Type;
l_PSG_tbl                     QP_Attr_Map_PUB.Psg_Tbl_Type;
l_SOU_tbl                     QP_Attr_Map_PUB.Sou_Tbl_Type;
l_x_SOU_tbl                   QP_Attr_Map_PUB.Sou_Tbl_Type;
l_FNA_tbl                     QP_Attr_Map_PUB.Fna_Tbl_Type;
l_x_FNA_tbl                   QP_Attr_Map_PUB.Fna_Tbl_Type;
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

    --  Get PTE ( parent = PTE )

    l_PTE_rec :=  QP_Pte_Util.Query_Row
    (   p_lookup_code         => p_lookup_code
    );

        --  Get RQT ( parent = PTE )

        l_RQT_tbl :=  QP_Rqt_Util.Query_Rows
        (   p_lookup_code           => l_PTE_rec.lookup_code
        );


        --  Get SSC ( parent = PTE )

        l_SSC_tbl :=  QP_Ssc_Util.Query_Rows
        (   p_lookup_code           => l_PTE_rec.lookup_code
        );


        --  Loop over SSC's children

        FOR I2 IN 1..l_SSC_tbl.COUNT LOOP

            --  Get FNA ( parent = SSC )

            l_FNA_tbl :=  QP_Fna_Util.Query_Rows
            (   p_pte_source_system_id    => l_SSC_tbl(I2).pte_source_system_id
            );

            FOR I3 IN 1..l_FNA_tbl.COUNT LOOP
                l_FNA_tbl(I3).SSC_Index        := I2;
                l_x_FNA_tbl
                (l_x_FNA_tbl.COUNT + 1)        := l_FNA_tbl(I3);
            END LOOP;


        END LOOP;
        --  Get PSG ( parent = PTE )

        l_PSG_tbl :=  QP_Psg_Util.Query_Rows
        (   p_lookup_code           => l_PTE_rec.lookup_code
        );


        --  Loop over PSG's children

        FOR I2 IN 1..l_PSG_tbl.COUNT LOOP

            --  Get SOU ( parent = PSG )

    oe_debug_pub.add('qp_attr_mapping_pvt count='||l_PSG_tbl.count);
            l_SOU_tbl :=  QP_Sou_Util.Query_Rows
            (   p_segment_pte_id          => l_PSG_tbl(I2).segment_pte_id
            );

            FOR I3 IN 1..l_SOU_tbl.COUNT LOOP
                l_SOU_tbl(I3).PSG_Index        := I2;
                l_x_SOU_tbl
                (l_x_SOU_tbl.COUNT + 1)        := l_SOU_tbl(I3);
            END LOOP;


        END LOOP;


    --  Load out parameters

    x_PTE_rec                      := l_PTE_rec;
    x_RQT_tbl                      := l_RQT_tbl;
    x_SSC_tbl                      := l_SSC_tbl;
    x_PSG_tbl                      := l_PSG_tbl;
    x_SOU_tbl                      := l_x_SOU_tbl;
    x_FNA_tbl                      := l_x_FNA_tbl;

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
            ,   'Get_Attr_Mapping'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Attr_Mapping;

--  Start of Comments
--  API name    Check_Enabled_Fnas
--  Type        Private
--  Function  Executes Delayed Request to check for enabled functional areas
--            within the updated PTE/SS combinations.  If there are any PTE/SS
--            combinations that have no enabled fnareas, it adds warning
--            messages to the stack.
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

PROCEDURE Check_Enabled_Fnas
( x_msg_data       OUT NOCOPY VARCHAR2
, x_msg_count      OUT NOCOPY NUMBER
, x_return_status  OUT NOCOPY VARCHAR2)
IS
BEGIN

-- Execute FNA delayed request to check for enabled functional areas
    QP_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
        (p_entity_code   => QP_GLOBALS.G_ENTITY_FNA
        ,p_delete        => FND_API.G_TRUE
        ,x_return_status => x_return_status
        );

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

END Check_Enabled_Fnas;


END QP_Attr_Map_PVT;

/
