--------------------------------------------------------
--  DDL for Package Body QP_LIST_HEADERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_LIST_HEADERS_PVT" AS
/* $Header: QPXVPRLB.pls 120.6 2005/12/15 11:58:33 rnayani ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_LIST_HEADERS_PVT';

--  Price_List

PROCEDURE Price_List
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN  QP_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_old_PRICE_LIST_rec            OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type := p_PRICE_LIST_rec;
l_p_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type := p_PRICE_LIST_rec;
l_old_PRICE_LIST_rec          QP_Price_List_PUB.Price_List_Rec_Type := p_old_PRICE_LIST_rec;
l_pte_code                    VARCHAR2(30);
l_source_system_code          VARCHAR2(30);
l_saved_pte_code              VARCHAR2(30);
l_saved_source_system_code    VARCHAR2(30);

BEGIN

    --Added for Bug 2444971 - Begin
    FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY', l_pte_code);
    FND_PROFILE.GET('QP_SOURCE_SYSTEM_CODE', l_source_system_code);
    --Added for Bug 2444971 - End

    --  Load API control record

    l_control_rec := QP_GLOBALS.Init_Control_Rec
    (   p_operation     => l_PRICE_LIST_rec.operation
    ,   p_control_rec   => p_control_rec
    );

    --  Set record return status.

    l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --added for moac for inline BSA PL and locked PL --fix for bug 4748511
    if l_PRICE_LIST_rec.operation in (QP_GLOBALS.G_OPR_CREATE, QP_GLOBALS.G_OPR_UPDATE)
    --and l_control_rec.called_from_ui = 'N' --this is not true for price locking API call
    and l_PRICE_LIST_rec.list_source_code IS NOT NULL
    and l_PRICE_LIST_rec.global_flag = 'N'
    and nvl(QP_SECURITY.security_on, 'N') = 'N' then
      l_PRICE_LIST_rec.global_flag := 'Y';
      l_PRICE_LIST_rec.org_id := null;
    end if;

    --  Prepare record.

    IF l_PRICE_LIST_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

        l_PRICE_LIST_rec.db_flag := FND_API.G_FALSE;

        --  Set missing old record elements to NULL.

        l_old_PRICE_LIST_rec :=
        QP_Price_List_Util.Convert_Miss_To_Null (l_old_PRICE_LIST_rec);

    ELSIF l_PRICE_LIST_rec.operation = QP_GLOBALS.G_OPR_UPDATE
    OR    l_PRICE_LIST_rec.operation = QP_GLOBALS.G_OPR_DELETE
    THEN

        l_PRICE_LIST_rec.db_flag := FND_API.G_TRUE;

        --  Query Old if missing

        IF  l_old_PRICE_LIST_rec.list_header_id = FND_API.G_MISS_NUM
        THEN

            l_old_PRICE_LIST_rec := QP_Price_List_Util.Query_Row
            (   p_list_header_id              => l_PRICE_LIST_rec.list_header_id
            );

        ELSE

            --  Set missing old record elements to NULL.

            l_old_PRICE_LIST_rec :=
            QP_Price_List_Util.Convert_Miss_To_Null (l_old_PRICE_LIST_rec);

        END IF;

        --  Complete new record from old

        l_PRICE_LIST_rec := QP_Price_List_Util.Complete_Record
        (   p_PRICE_LIST_rec              => l_PRICE_LIST_rec
        ,   p_old_PRICE_LIST_rec          => l_old_PRICE_LIST_rec
        );

        --Start of code added for Bug 2444971. Added for Patchset H
        BEGIN
          SELECT pte_code, source_system_code
          INTO   l_saved_pte_code, l_saved_source_system_code
          FROM   qp_list_headers_b
          WHERE  list_header_id = l_PRICE_LIST_rec.list_header_id;

        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;

        IF l_saved_pte_code <> l_pte_code OR
           l_saved_source_system_code <> l_source_system_code
        THEN

          l_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP', 'QP_PTE_SS_CODE_MISMATCH');
          FND_MESSAGE.SET_TOKEN('SOURCE_SYSTEM',l_saved_source_system_code);
          FND_MESSAGE.SET_TOKEN('PTE_CODE',l_saved_pte_code);
          OE_MSG_PUB.Add;

          RAISE FND_API.G_EXC_ERROR;

        END IF;
        --End of code added for Bug 2444971. Added for Patchset H

    END IF;

    --  Attribute level validation.

   IF ( l_PRICE_LIST_rec.operation = QP_GLOBALS.G_OPR_UPDATE
      or l_PRICE_LIST_rec.operation = QP_GLOBALS.G_OPR_CREATE
      or l_PRICE_LIST_rec.operation = QP_GLOBALS.G_OPR_DELETE ) THEN

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

            QP_Validate_Price_List.Attributes
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
        QP_Price_List_Util.Clear_Dependent_Attr
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
        QP_Default_Price_List.Attributes
        (   p_PRICE_LIST_rec              => l_p_PRICE_LIST_rec
        ,   x_PRICE_LIST_rec              => l_PRICE_LIST_rec
        );

    END IF;

    --  Apply attribute changes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN
         l_p_PRICE_LIST_rec := l_PRICE_LIST_rec;
        QP_Price_List_Util.Apply_Attribute_Changes
        (   p_PRICE_LIST_rec              => l_p_PRICE_LIST_rec
        ,   p_old_PRICE_LIST_rec          => l_old_PRICE_LIST_rec
        ,   x_PRICE_LIST_rec              => l_PRICE_LIST_rec
        );

    END IF;

    --  Entity level validation.

    IF l_control_rec.validate_entity THEN

        IF l_PRICE_LIST_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

            QP_Validate_Price_List.Entity_Delete
            (   x_return_status               => l_return_status
            ,   p_PRICE_LIST_rec              => l_PRICE_LIST_rec
            );

        ELSE

            QP_Validate_Price_List.Entity
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

        IF l_PRICE_LIST_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

            FND_MESSAGE.SET_NAME('QP', 'QP_CANNOT_DELETE_PRICE_LIST');
		  OE_MSG_PUB.Add;

            RAISE FND_API.G_EXC_ERROR;

            /*QP_Price_List_Util.Delete_Row
            (   p_list_header_id              => l_PRICE_LIST_rec.list_header_id
            );*/

        ELSE

            --  Get Who Information

            l_PRICE_LIST_rec.last_update_date := SYSDATE;
            l_PRICE_LIST_rec.last_updated_by := FND_GLOBAL.USER_ID;
            l_PRICE_LIST_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

            IF l_PRICE_LIST_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                QP_Price_List_Util.Update_Row (l_PRICE_LIST_rec);

            ELSIF l_PRICE_LIST_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                l_PRICE_LIST_rec.creation_date := SYSDATE;
                l_PRICE_LIST_rec.created_by    := FND_GLOBAL.USER_ID;

                QP_Price_List_Util.Insert_Row (l_PRICE_LIST_rec);

            END IF;

        END IF;

    END IF;

   END IF; /* if operation is create, update or delete */

    --  Load OUT parameters

    x_PRICE_LIST_rec               := l_PRICE_LIST_rec;
    x_old_PRICE_LIST_rec           := l_old_PRICE_LIST_rec;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_ERROR;
        x_PRICE_LIST_rec               := l_PRICE_LIST_rec;
        x_old_PRICE_LIST_rec           := l_old_PRICE_LIST_rec;

        -- mkarya If process_price_list has been called from public package, then ONLY call
        -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
        if l_control_rec.called_from_ui = 'N' then
	   qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		(p_entity_code => QP_GLOBALS.G_ENTITY_PRICE_LIST,
	      p_entity_id => l_PRICE_LIST_rec.list_header_id,
	      x_return_status => l_return_status );
        end if;

        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_PRICE_LIST_rec               := l_PRICE_LIST_rec;
        x_old_PRICE_LIST_rec           := l_old_PRICE_LIST_rec;

        -- mkarya If process_price_list has been called from public package, then ONLY call
        -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
        if l_control_rec.called_from_ui = 'N' then
	   qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		(p_entity_code => QP_GLOBALS.G_ENTITY_PRICE_LIST,
	      p_entity_id => l_PRICE_LIST_rec.list_header_id,
	      x_return_status => l_return_status );
        end if;

        RAISE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_List'
            );
        END IF;

        l_PRICE_LIST_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_PRICE_LIST_rec               := l_PRICE_LIST_rec;
        x_old_PRICE_LIST_rec           := l_old_PRICE_LIST_rec;

        -- mkarya If process_price_list has been called from public package, then ONLY call
        -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
        if l_control_rec.called_from_ui = 'N' then
	   qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		(p_entity_code => QP_GLOBALS.G_ENTITY_PRICE_LIST,
	      p_entity_id => l_PRICE_LIST_rec.list_header_id,
	      x_return_status => l_return_status );
        end if;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_List;

--  Price_List_Lines

PROCEDURE Price_List_Lines
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_PRICE_LIST_LINE_tbl           IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   p_old_PRICE_LIST_LINE_tbl       IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_old_PRICE_LIST_LINE_tbl       OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_PRICE_LIST_LINE_rec         QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_p_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_PRICE_LIST_LINE_tbl         QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_old_PRICE_LIST_LINE_rec     QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_old_PRICE_LIST_LINE_tbl     QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_rltd_modifiers_s number;
l_pte_code                    VARCHAR2(30);
l_source_system_code          VARCHAR2(30);
l_saved_pte_code              VARCHAR2(30);
l_saved_source_system_code    VARCHAR2(30);

BEGIN
    --Added for Bug 2444971 - Begin
    FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY', l_pte_code);
    FND_PROFILE.GET('QP_SOURCE_SYSTEM_CODE', l_source_system_code);
    --Added for Bug 2444971 - End

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
            l_old_PRICE_LIST_LINE_rec := QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC;
        END IF;

        --  Load API control record

        l_control_rec := QP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_PRICE_LIST_LINE_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_PRICE_LIST_LINE_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

            l_PRICE_LIST_LINE_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_PRICE_LIST_LINE_rec :=
            QP_Price_List_Line_Util.Convert_Miss_To_Null (l_old_PRICE_LIST_LINE_rec);

        ELSIF l_PRICE_LIST_LINE_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        OR    l_PRICE_LIST_LINE_rec.operation = QP_GLOBALS.G_OPR_DELETE
        THEN

            l_PRICE_LIST_LINE_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_PRICE_LIST_LINE_rec.list_line_id = FND_API.G_MISS_NUM
            THEN

                l_old_PRICE_LIST_LINE_rec := QP_Price_List_Line_Util.Query_Row
                (   p_list_line_id                => l_PRICE_LIST_LINE_rec.list_line_id
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_PRICE_LIST_LINE_rec :=
                QP_Price_List_Line_Util.Convert_Miss_To_Null (l_old_PRICE_LIST_LINE_rec);

            END IF;

            --  Complete new record from old

            l_PRICE_LIST_LINE_rec := QP_Price_List_Line_Util.Complete_Record
            (   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
            ,   p_old_PRICE_LIST_LINE_rec     => l_old_PRICE_LIST_LINE_rec
            );

            --Start of code added for Bug 2444971. Added for Patchset H
            BEGIN
              SELECT pte_code, source_system_code
              INTO   l_saved_pte_code, l_saved_source_system_code
              FROM   qp_list_headers_b
              WHERE  list_header_id = l_PRICE_LIST_LINE_rec.list_header_id;

            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;

            IF l_saved_pte_code <> l_pte_code OR
               l_saved_source_system_code <> l_source_system_code
            THEN

              l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('QP', 'QP_PTE_SS_CODE_MISMATCH');
              FND_MESSAGE.SET_TOKEN('SOURCE_SYSTEM',l_saved_source_system_code);
              FND_MESSAGE.SET_TOKEN('PTE_CODE',l_saved_pte_code);
              OE_MSG_PUB.Add;

              RAISE FND_API.G_EXC_ERROR;

            END IF;
            --End of code added for Bug 2444971. Added for Patchset H

        END IF;

        --  Attribute level validation.

      IF ( l_PRICE_LIST_LINE_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        or l_PRICE_LIST_LINE_rec.operation = QP_GLOBALS.G_OPR_CREATE
        or l_PRICE_LIST_LINE_rec.operation = QP_GLOBALS.G_OPR_DELETE ) THEN

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                QP_Validate_Price_List_Line.Attributes
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
            QP_Price_List_Line_Util.Clear_Dependent_Attr
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
            QP_Default_Price_List_Line.Attributes
            (   p_PRICE_LIST_LINE_rec         => l_p_PRICE_LIST_LINE_rec
            ,   x_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
            );

        END IF;

        --Start of code added for Bug 2444971. Added for Patchset H
        IF l_PRICE_LIST_LINE_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN
          BEGIN
            SELECT pte_code, source_system_code
            INTO   l_saved_pte_code, l_saved_source_system_code
            FROM   qp_list_headers_b
            WHERE  list_header_id = l_PRICE_LIST_LINE_rec.list_header_id;

          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;

          IF l_saved_pte_code <> l_pte_code OR
             l_saved_source_system_code <> l_source_system_code
          THEN

            l_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP', 'QP_PTE_SS_CODE_MISMATCH');
            FND_MESSAGE.SET_TOKEN('SOURCE_SYSTEM',l_saved_source_system_code);
            FND_MESSAGE.SET_TOKEN('PTE_CODE',l_saved_pte_code);
            OE_MSG_PUB.Add;

            RAISE FND_API.G_EXC_ERROR;

          END IF;
        END IF; --If operation is G_OPR_CREATE
        --End of code added for Bug 2444971. Added for Patchset H

        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
            l_p_PRICE_LIST_LINE_rec := l_PRICE_LIST_LINE_rec;
            QP_Price_List_Line_Util.Apply_Attribute_Changes
            (   p_PRICE_LIST_LINE_rec         => l_p_PRICE_LIST_LINE_rec
            ,   p_old_PRICE_LIST_LINE_rec     => l_old_PRICE_LIST_LINE_rec
            ,   x_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
            );

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_PRICE_LIST_LINE_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Validate_Price_List_Line.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_PRICE_LIST_LINE_rec         => l_PRICE_LIST_LINE_rec
                );

            ELSE

                QP_Validate_Price_List_Line.Entity
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

            IF l_PRICE_LIST_LINE_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Price_List_Line_Util.Delete_Row
                (   p_list_line_id                => l_PRICE_LIST_LINE_rec.list_line_id
                );

            ELSE

                --  Get Who Information

                l_PRICE_LIST_LINE_rec.last_update_date := SYSDATE;
                l_PRICE_LIST_LINE_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_PRICE_LIST_LINE_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_PRICE_LIST_LINE_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                    QP_Price_List_Line_Util.Update_Row (l_PRICE_LIST_LINE_rec);

                ELSIF l_PRICE_LIST_LINE_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                    l_PRICE_LIST_LINE_rec.creation_date := SYSDATE;
                    l_PRICE_LIST_LINE_rec.created_by := FND_GLOBAL.USER_ID;

                    QP_Price_List_Line_Util.Insert_Row (l_PRICE_LIST_LINE_rec);

                    IF l_PRICE_LIST_LINE_rec.operation = QP_GLOBALS.G_OPR_CREATE
	               AND l_PRICE_LIST_LINE_rec.PRICE_BREAK_HEADER_index IS NOT NULL
	               AND l_PRICE_LIST_LINE_rec.PRICE_BREAK_HEADER_index <> FND_API.G_MISS_NUM
	               AND (l_PRICE_LIST_LINE_rec.from_rltd_modifier_id IS NULL OR
                        l_PRICE_LIST_LINE_rec.from_rltd_modifier_id = FND_API.G_MISS_NUM)
                    THEN

                      IF l_PRICE_LIST_LINE_tbl.EXISTS(l_PRICE_LIST_LINE_rec.PRICE_BREAK_HEADER_index) AND
		               l_PRICE_LIST_LINE_tbl(l_PRICE_LIST_LINE_rec.PRICE_BREAK_HEADER_index).list_line_type_code = 'PBH'
		            THEN

                         --  Copy parent list_line_id  to  from_rltd_modifier_id.

                         l_PRICE_LIST_LINE_rec.from_rltd_modifier_id :=
				             l_PRICE_LIST_LINE_tbl(l_PRICE_LIST_LINE_rec.PRICE_BREAK_HEADER_index).list_line_id;


                      END IF;

	               END IF;


                    IF   l_PRICE_LIST_LINE_rec.from_rltd_modifier_id IS NOT NULL
                    AND  l_PRICE_LIST_LINE_rec.rltd_modifier_group_no IS NOT NULL
				THEN

				select QP_RLTD_MODIFIERS_S.nextval
				into   l_rltd_modifiers_s from dual;

                                QP_RLTD_MODIFIER_PVT.Insert_Row(
                                l_rltd_modifiers_s
			       , l_PRICE_LIST_LINE_rec.creation_date
                               , l_PRICE_LIST_LINE_rec.created_by
                               , l_price_list_line_rec.last_update_date
                               , l_price_list_line_rec.last_updated_by
                               , l_price_list_line_rec.last_update_login
                               , l_price_list_line_rec.rltd_modifier_group_no
                               , l_price_list_line_rec.from_rltd_modifier_id
                               , l_price_list_line_rec.list_line_id
                               , 'PRICE BREAK'
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               , null
                               );

               qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_PRICE_LIST_LINE,
   	         p_entity_id  => l_price_list_line_rec.list_line_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_PRICE_LIST_LINE,
                 p_requesting_entity_id => l_price_list_line_rec.list_line_id,
                 p_request_type =>QP_GLOBALS.G_UPDATE_LINE_QUAL_IND,
                 x_return_status => l_return_status);

                     END IF;

                END IF;

            END IF;

        END IF;

       END IF; /* if operation is create, update or delete */

        --  Load tables.

        l_PRICE_LIST_LINE_tbl(I)       := l_PRICE_LIST_LINE_rec;
        l_old_PRICE_LIST_LINE_tbl(I)   := l_old_PRICE_LIST_LINE_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            l_PRICE_LIST_LINE_tbl(I)       := l_PRICE_LIST_LINE_rec;
            l_old_PRICE_LIST_LINE_tbl(I)   := l_old_PRICE_LIST_LINE_rec;

            -- mkarya If process_price_list has been called from public package, then ONLY call
            -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
            if l_control_rec.called_from_ui = 'N' then
 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_PRICE_LIST_LINE,
	          p_entity_id => l_PRICE_LIST_LINE_rec.list_line_id,
	          x_return_status => l_return_status );

 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
	          p_entity_id => l_PRICE_LIST_LINE_rec.list_line_id,
	          x_return_status => l_return_status );
            end if;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_PRICE_LIST_LINE_tbl(I)       := l_PRICE_LIST_LINE_rec;
            l_old_PRICE_LIST_LINE_tbl(I)   := l_old_PRICE_LIST_LINE_rec;

            -- mkarya If process_price_list has been called from public package, then ONLY call
            -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
            if l_control_rec.called_from_ui = 'N' then
 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_PRICE_LIST_LINE,
	          p_entity_id => l_PRICE_LIST_LINE_rec.list_line_id,
	          x_return_status => l_return_status );

 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
	          p_entity_id => l_PRICE_LIST_LINE_rec.list_line_id,
	          x_return_status => l_return_status );
            end if;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_PRICE_LIST_LINE_tbl(I)       := l_PRICE_LIST_LINE_rec;
            l_old_PRICE_LIST_LINE_tbl(I)   := l_old_PRICE_LIST_LINE_rec;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                oe_msg_pub.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Price_List_Lines'
                );
            END IF;

            -- mkarya If process_price_list has been called from public package, then ONLY call
            -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
            if l_control_rec.called_from_ui = 'N' then
 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_PRICE_LIST_LINE,
	          p_entity_id => l_PRICE_LIST_LINE_rec.list_line_id,
	          x_return_status => l_return_status );

 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
	          p_entity_id => l_PRICE_LIST_LINE_rec.list_line_id,
	          x_return_status => l_return_status );
            end if;

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

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_List_Lines'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_List_Lines;

--  Qualifierss


PROCEDURE Qualifierss
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_QUALIFIERS_tbl                IN  Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   p_old_QUALIFIERS_tbl            IN  Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   x_old_QUALIFIERS_tbl            OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_QUALIFIERS_rec              Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_p_QUALIFIERS_rec            Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_QUALIFIERS_tbl              Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_old_QUALIFIERS_rec          Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_old_QUALIFIERS_tbl          Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_list_type_code 			QP_LIST_HEADERS_B.LIST_TYPE_CODE%TYPE;
l_pte_code                    VARCHAR2(30);
l_source_system_code          VARCHAR2(30);
l_saved_pte_code              VARCHAR2(30);
l_saved_source_system_code    VARCHAR2(30);

v_count  NUMBER;
v_install  VARCHAR2(1);
BEGIN

    --Added for Bug 2444971 - Begin
    FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY', l_pte_code);
    FND_PROFILE.GET('QP_SOURCE_SYSTEM_CODE', l_source_system_code);
    --Added for Bug 2444971 - End

    --  Init local table variables.

    l_QUALIFIERS_tbl               := p_QUALIFIERS_tbl;
    l_old_QUALIFIERS_tbl           := p_old_QUALIFIERS_tbl;

    FOR I IN 1..l_QUALIFIERS_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_QUALIFIERS_rec := l_QUALIFIERS_tbl(I);

        IF l_old_QUALIFIERS_tbl.EXISTS(I) THEN
            l_old_QUALIFIERS_rec := l_old_QUALIFIERS_tbl(I);
        ELSE
            l_old_QUALIFIERS_rec := Qp_Qualifier_Rules_Pub.G_MISS_QUALIFIERS_REC;
        END IF;

        --  Load API control record

        l_control_rec := QP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_QUALIFIERS_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

            l_QUALIFIERS_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_QUALIFIERS_rec :=
            QP_Qualifiers_Util.Convert_Miss_To_Null (l_old_QUALIFIERS_rec);

        ELSIF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        OR    l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE
        THEN

            l_QUALIFIERS_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_QUALIFIERS_rec.qualifier_id = FND_API.G_MISS_NUM
            THEN

                l_old_QUALIFIERS_rec := QP_Qualifiers_Util.Query_Row
                (   p_qualifier_id                => l_QUALIFIERS_rec.qualifier_id
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_QUALIFIERS_rec :=
                QP_Qualifiers_Util.Convert_Miss_To_Null (l_old_QUALIFIERS_rec);

            END IF;

            --  Complete new record from old

            l_QUALIFIERS_rec := QP_Qualifiers_Util.Complete_Record
            (   p_QUALIFIERS_rec              => l_QUALIFIERS_rec
            ,   p_old_QUALIFIERS_rec          => l_old_QUALIFIERS_rec
            );

            --Start of code added for Bug 2444971. Added for Patchset H
            BEGIN
              SELECT h.pte_code, h.source_system_code, h.list_type_code
              INTO   l_saved_pte_code, l_saved_source_system_code,
                     l_list_type_code
              FROM   qp_list_headers_b h, qp_qualifiers q
              WHERE  h.list_header_id = q.list_header_id
              AND    q.qualifier_id = l_QUALIFIERS_rec.qualifier_id;

            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;

            IF (l_saved_pte_code <> l_pte_code OR
                l_saved_source_system_code <> l_source_system_code)
            AND l_list_type_code IN ('PRL', 'AGR')
            THEN

              l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('QP', 'QP_PTE_SS_CODE_MISMATCH');
              FND_MESSAGE.SET_TOKEN('SOURCE_SYSTEM',l_saved_source_system_code);
              FND_MESSAGE.SET_TOKEN('PTE_CODE',l_saved_pte_code);
              OE_MSG_PUB.Add;

              RAISE FND_API.G_EXC_ERROR;

            END IF;
            --End of code added for Bug 2444971. Added for Patchset H

        END IF;

        --  Attribute level validation.
      IF ( l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        or l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE
        or l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE ) THEN

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                QP_Validate_Qualifiers.Attributes
                (   x_return_status               => l_return_status
                ,   p_QUALIFIERS_rec              => l_QUALIFIERS_rec
                ,   p_old_QUALIFIERS_rec          => l_old_QUALIFIERS_rec
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
              l_p_QUALIFIERS_rec := l_QUALIFIERS_rec;
            QP_Qualifiers_Util.Clear_Dependent_Attr
            (   p_QUALIFIERS_rec              => l_p_QUALIFIERS_rec
            ,   p_old_QUALIFIERS_rec          => l_old_QUALIFIERS_rec
            ,   x_QUALIFIERS_rec              => l_QUALIFIERS_rec
            );

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
               l_p_QUALIFIERS_rec := l_QUALIFIERS_rec;
            QP_Default_Qualifiers.Attributes
            (   p_QUALIFIERS_rec              => l_p_QUALIFIERS_rec
            ,   x_QUALIFIERS_rec              => l_QUALIFIERS_rec
            );

        END IF;

        --Start of code added for Bug 2444971. Added for Patchset H
        IF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE
        THEN
          BEGIN

            SELECT pte_code, source_system_code, list_type_code
            INTO   l_saved_pte_code, l_saved_source_system_code,
                   l_list_type_code
            FROM   qp_list_headers_b
            WHERE  list_header_id = l_QUALIFIERS_rec.list_header_id;

          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;

          IF (l_saved_pte_code <> l_pte_code OR
              l_saved_source_system_code <> l_source_system_code)
          AND l_list_type_code IN ('PRL', 'AGR')
          THEN

            l_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP', 'QP_PTE_SS_CODE_MISMATCH');
            FND_MESSAGE.SET_TOKEN('SOURCE_SYSTEM',l_saved_source_system_code);
            FND_MESSAGE.SET_TOKEN('PTE_CODE',l_saved_pte_code);
            OE_MSG_PUB.Add;

            RAISE FND_API.G_EXC_ERROR;

          END IF;

        END IF; --operation is G_OPR_CREATE
        --End of code added for Bug 2444971. Added for Patchset H

        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
              l_p_QUALIFIERS_rec := l_QUALIFIERS_rec;
            QP_Qualifiers_Util.Apply_Attribute_Changes
            (   p_QUALIFIERS_rec              => l_p_QUALIFIERS_rec
            ,   p_old_QUALIFIERS_rec          => l_old_QUALIFIERS_rec
            ,   x_QUALIFIERS_rec              => l_QUALIFIERS_rec
            );

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Validate_Qualifiers.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_QUALIFIERS_rec              => l_QUALIFIERS_rec
                );

            ELSE

                QP_Validate_Qualifiers.Entity
                (   x_return_status               => l_return_status
                ,   p_QUALIFIERS_rec              => l_QUALIFIERS_rec
                ,   p_old_QUALIFIERS_rec          => l_old_QUALIFIERS_rec
                );

            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

oe_debug_pub.add('qualifier attr value = '||l_qualifiers_rec.qualifier_attr_value);
	   v_install := QP_UTIL.GET_QP_STATUS;
	   IF v_install = 'S' THEN

		/*modified by spgopal for bug: 1381209 08/17/00*/

			BEGIN

			SELECT LIST_TYPE_CODE INTO l_list_type_code
				FROM QP_LIST_HEADERS_B WHERE
				LIST_HEADER_ID = l_QUALIFIERS_rec.LIST_HEADER_ID;
			EXCEPTION
			When NO_DATA_FOUND Then Null;
			END;

			oe_debug_pub.add('in basic qual test');
			if l_list_type_code in ('DLT', 'SLT') then

                       -- mkarya for bug 1820251, error while updating end-date of a header level qualifier
                       -- commented the following lines as there is no condition of only one qualifier
                       -- of type Price List, as per the discussion with product management.
                       /*
			oe_debug_pub.add('in modifier qual test'||l_list_type_code);
				BEGIN

				SELECT COUNT(*) INTO v_count FROM
				QP_QUALIFIERS WHERE
				LIST_HEADER_ID = l_QUALIFIERS_rec.list_header_id
				AND QUALIFIER_CONTEXT = 'MODLIST'
				AND QUALIFIER_ATTRIBUTE = 'QUALIFIER_ATTRIBUTE4';

				EXCEPTION
				When NO_DATA_FOUND Then Null;
				END;


				if v_count > 0  and
					(l_QUALIFIERS_rec.QUALIFIER_CONTEXT = 'MODLIST'
					 and l_QUALIFIERS_rec.QUALIFIER_ATTRIBUTE =
						'QUALIFIER_ATTRIBUTE4') then

		  		fnd_message.set_name('QP', 'QP_BASIC_MOD_MULT_PLIST');
		  		oe_msg_pub.add;
		  		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

				else null;
				end if;
                        */
                           null;
		        -- mkarya for bug 1820251, END
			elsif l_list_type_code = 'PRL' then
		/*end of modifications by spgopal 08/17/00*/

		/* The following if condition has been added for 1606695 */

			if l_qualifiers_rec.operation <> QP_GLOBALS.G_OPR_DELETE
			then
				SELECT COUNT(*)
		  		INTO v_count
		  		FROM qp_secondary_price_lists_v
           			WHERE parent_price_list_id =
					l_qualifiers_rec.qualifier_attr_value;

				IF v_count > 0 THEN
		  		fnd_message.set_name('QP', 'QP_SEC_PRL_COUNT');
		  		oe_msg_pub.add;
		  		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          			END IF;
			end if; 	-- l_qualifiers_rec.operation
			/* 1606695 */



			else Null;

			end if;     --list_type_code
        END IF;

   END IF;

        IF l_control_rec.write_to_db THEN
                   l_p_QUALIFIERS_rec := l_QUALIFIERS_rec;
    	          QP_QUALIFIERS_UTIL.PRE_WRITE_PROCESS
                   ( p_QUALIFIERS_rec      => l_p_QUALIFIERS_rec
                   , p_old_QUALIFIERS_rec  => l_old_QUALIFIERS_rec
                   , x_QUALIFIERS_rec      => l_QUALIFIERS_rec);

        END IF;

        --  Step 4. Write to DB

        IF l_control_rec.write_to_db THEN

            IF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

			IF l_QUALIFIERS_rec.QUALIFIER_CONTEXT = 'MODLIST' AND
				l_QUALIFIERS_rec.QUALIFIER_ATTRIBUTE =
						'QUALIFIER_ATTRIBUTE3' THEN
			--fix for bug 1501138 not allow deletion of coupon qualifiers

				oe_debug_pub.add('1501138 not allow delete qual');
				FND_MESSAGE.SET_NAME('QP', 'QP_CANNOT_DELETE_THIS_QUAL');
				OE_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;
			ELSE

                QP_Qualifiers_Util.Delete_Row
                (   p_qualifier_id                => l_QUALIFIERS_rec.qualifier_id
                );
			END IF;

            ELSE

                --  Get Who Information

                l_QUALIFIERS_rec.last_update_date := SYSDATE;
                l_QUALIFIERS_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_QUALIFIERS_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                    QP_Qualifiers_Util.Update_Row (l_QUALIFIERS_rec);

                ELSIF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                    l_QUALIFIERS_rec.creation_date := SYSDATE;
                    l_QUALIFIERS_rec.created_by    := FND_GLOBAL.USER_ID;

                    QP_Qualifiers_Util.Insert_Row (l_QUALIFIERS_rec);

                END IF;

            END IF;

        END IF;

       END IF; /* if operation is create, update or delete */

        --  Load tables.

        l_QUALIFIERS_tbl(I)            := l_QUALIFIERS_rec;
        l_old_QUALIFIERS_tbl(I)        := l_old_QUALIFIERS_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            l_QUALIFIERS_tbl(I)            := l_QUALIFIERS_rec;
            l_old_QUALIFIERS_tbl(I)        := l_old_QUALIFIERS_rec;

            -- mkarya If process_price_list has been called from public package, then ONLY call
            -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
            if l_control_rec.called_from_ui = 'N' then
 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
	          p_entity_id => l_QUALIFIERS_rec.list_header_id,
	          x_return_status => l_return_status );

 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
	          p_entity_id => l_QUALIFIERS_rec.list_line_id,
	          x_return_status => l_return_status );

 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
	          p_entity_id => l_QUALIFIERS_rec.qualifier_id,
	          x_return_status => l_return_status );
            end if;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_QUALIFIERS_tbl(I)            := l_QUALIFIERS_rec;
            l_old_QUALIFIERS_tbl(I)        := l_old_QUALIFIERS_rec;

            -- mkarya If process_price_list has been called from public package, then ONLY call
            -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
            if l_control_rec.called_from_ui = 'N' then
 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
	          p_entity_id => l_QUALIFIERS_rec.list_header_id,
	          x_return_status => l_return_status );

 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
	          p_entity_id => l_QUALIFIERS_rec.list_line_id,
	          x_return_status => l_return_status );

 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
	          p_entity_id => l_QUALIFIERS_rec.qualifier_id,
	          x_return_status => l_return_status );
            end if;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_QUALIFIERS_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_QUALIFIERS_tbl(I)            := l_QUALIFIERS_rec;
            l_old_QUALIFIERS_tbl(I)        := l_old_QUALIFIERS_rec;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                oe_msg_pub.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Qualifierss'
                );
            END IF;

            -- mkarya If process_price_list has been called from public package, then ONLY call
            -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
            if l_control_rec.called_from_ui = 'N' then
 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
	          p_entity_id => l_QUALIFIERS_rec.list_header_id,
	          x_return_status => l_return_status );

 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
	          p_entity_id => l_QUALIFIERS_rec.list_line_id,
	          x_return_status => l_return_status );

 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
	          p_entity_id => l_QUALIFIERS_rec.qualifier_id,
	          x_return_status => l_return_status );
            end if;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;
    x_old_QUALIFIERS_tbl           := l_old_QUALIFIERS_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        RAISE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Qualifierss'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Qualifierss;



--  Pricing_Attrs

PROCEDURE Pricing_Attrs
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_PRICING_ATTR_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   p_old_PRICING_ATTR_tbl          IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   x_old_PRICING_ATTR_tbl          OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_PRICING_ATTR_rec            QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_p_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_PRICING_ATTR_tbl            QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_old_PRICING_ATTR_rec        QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_old_PRICING_ATTR_tbl        QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_pte_code                    VARCHAR2(30);
l_source_system_code          VARCHAR2(30);
l_saved_pte_code              VARCHAR2(30);
l_saved_source_system_code    VARCHAR2(30);
--Bug 4706180
l_rltd_modifier_grp_type  VARCHAR2(30);

BEGIN

  oe_debug_pub.add('entering pricing attrs');

    --Added for Bug 2444971 - Begin
    FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY', l_pte_code);
    FND_PROFILE.GET('QP_SOURCE_SYSTEM_CODE', l_source_system_code);
    --Added for Bug 2444971 - End

    --  Init local table variables.

    l_PRICING_ATTR_tbl             := p_PRICING_ATTR_tbl;
    l_old_PRICING_ATTR_tbl         := p_old_PRICING_ATTR_tbl;

  oe_debug_pub.add('before for loop ');

    FOR I IN 1..l_PRICING_ATTR_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_PRICING_ATTR_rec := l_PRICING_ATTR_tbl(I);

       --Fetch modfier group type (Bug 4706180) Start
       BEGIN
         SELECT RLTD_MODIFIER_GRP_TYPE
         INTO   l_rltd_modifier_grp_type
         FROM   qp_rltd_modifiers rm
         WHERE  rm.TO_RLTD_MODIFIER_ID = l_PRICING_ATTR_rec.list_line_id;
       EXCEPTION
         WHEN OTHERS THEN
          l_rltd_modifier_grp_type := '';
       END;
       --End

        -- If the 'value to' in the price break is equal to null and the value from is not null then
        -- make the 'value to' equal to 999999999999999 to accomodate a high value
        IF(l_Pricing_Attr_rec.pricing_attr_value_to IS NULL
            AND l_Pricing_Attr_rec.pricing_attr_value_from IS NOT NULL
            -- Bug 4706180
            AND l_rltd_modifier_grp_type = 'PRICE BREAK')
        THEN
            l_Pricing_Attr_rec.pricing_attr_value_to := '999999999999999';
        END IF;

        IF l_old_PRICING_ATTR_tbl.EXISTS(I) THEN
          oe_debug_pub.add('record already exists');
            l_old_PRICING_ATTR_rec := l_old_PRICING_ATTR_tbl(I);
        ELSE
            l_old_PRICING_ATTR_rec := QP_Price_List_PUB.G_MISS_PRICING_ATTR_REC;
        END IF;

        --  Load API control record
         oe_debug_pub.add('before init control rec');

        l_control_rec := QP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_PRICING_ATTR_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

           oe_debug_pub.add(' operation is create ');

            l_PRICING_ATTR_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_PRICING_ATTR_rec :=
            Qp_pll_pricing_attr_Util.Convert_Miss_To_Null (l_old_PRICING_ATTR_rec);

        ELSIF l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        OR    l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_DELETE
        THEN
          oe_debug_pub.add('operation is update');

            l_PRICING_ATTR_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_PRICING_ATTR_rec.pricing_attribute_id = FND_API.G_MISS_NUM
            THEN
                   oe_debug_pub.add('query pricing attributes');

                l_old_PRICING_ATTR_rec := Qp_pll_pricing_attr_Util.Query_Row
                (   p_pricing_attribute_id        => l_PRICING_ATTR_rec.pricing_attribute_id
                );

            ELSE

                --  Set missing old record elements to NULL.

                oe_debug_pub.add('set missing record elements to null');
                l_old_PRICING_ATTR_rec :=
                Qp_pll_pricing_attr_Util.Convert_Miss_To_Null (l_old_PRICING_ATTR_rec);

            END IF;

            --  Complete new record from old

           oe_debug_pub.add('complete new record from old');


            l_PRICING_ATTR_rec := Qp_pll_pricing_attr_Util.Complete_Record
            (   p_PRICING_ATTR_rec            => l_PRICING_ATTR_rec
            ,   p_old_PRICING_ATTR_rec        => l_old_PRICING_ATTR_rec
            );

            --Start of code added for Bug 2444971. Added for Patchset H
            BEGIN
              SELECT h.pte_code, h.source_system_code
              INTO   l_saved_pte_code, l_saved_source_system_code
              FROM   qp_list_headers_b h, qp_list_lines l
              WHERE  h.list_header_id = l.list_header_id
              AND    l.list_line_id = l_PRICING_ATTR_rec.list_line_id;

            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;

            IF l_saved_pte_code <> l_pte_code OR
               l_saved_source_system_code <> l_source_system_code
            THEN

              l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('QP', 'QP_PTE_SS_CODE_MISMATCH');
              FND_MESSAGE.SET_TOKEN('SOURCE_SYSTEM',l_saved_source_system_code);
              FND_MESSAGE.SET_TOKEN('PTE_CODE',l_saved_pte_code);
              OE_MSG_PUB.Add;

              RAISE FND_API.G_EXC_ERROR;

            END IF;
            --End of code added for Bug 2444971. Added for Patchset H

        END IF;

        --  Attribute level validation.
      IF ( l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        or l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_CREATE
        or l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_DELETE ) THEN

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                oe_debug_pub.add('validate the attributes');

                QP_Validate_pll_pricing_attr.Attributes
                (   x_return_status               => l_return_status
                ,   p_PRICING_ATTR_rec            => l_PRICING_ATTR_rec
                ,   p_old_PRICING_ATTR_rec        => l_old_PRICING_ATTR_rec
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

           oe_debug_pub.add('clear dependent attr1');
            l_p_PRICING_ATTR_rec := l_PRICING_ATTR_rec;
            Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
            (   p_PRICING_ATTR_rec            => l_p_PRICING_ATTR_rec
            ,   p_old_PRICING_ATTR_rec        => l_old_PRICING_ATTR_rec
            ,   x_PRICING_ATTR_rec            => l_PRICING_ATTR_rec
            );

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

           oe_debug_pub.add('call attributes ');
             l_p_PRICING_ATTR_rec := l_PRICING_ATTR_rec;
            QP_Default_pll_pricing_attr.Attributes
            (   p_PRICING_ATTR_rec            => l_p_PRICING_ATTR_rec
            ,   x_PRICING_ATTR_rec            => l_PRICING_ATTR_rec
            );

        END IF;

        --Start of code added for Bug 2444971. Added for Patchset H
        IF l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_CREATE
        THEN
          BEGIN
            SELECT h.pte_code, h.source_system_code
            INTO   l_saved_pte_code, l_saved_source_system_code
            FROM   qp_list_headers_b h, qp_list_lines l
            WHERE  h.list_header_id = l.list_header_id
            AND    l.list_line_id = l_PRICING_ATTR_rec.list_line_id;

          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;

          IF l_saved_pte_code <> l_pte_code OR
             l_saved_source_system_code <> l_source_system_code
          THEN

            l_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP', 'QP_PTE_SS_CODE_MISMATCH');
            FND_MESSAGE.SET_TOKEN('SOURCE_SYSTEM',l_saved_source_system_code);
            FND_MESSAGE.SET_TOKEN('PTE_CODE',l_saved_pte_code);
            OE_MSG_PUB.Add;

            RAISE FND_API.G_EXC_ERROR;

          END IF;

        END IF; --operation is G_OPR_CREATE
        --End of code added for Bug 2444971. Added for Patchset H

        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN
            l_p_PRICING_ATTR_rec := l_PRICING_ATTR_rec;
           oe_debug_pub.add('before calling apply attribute changes');
            Qp_pll_pricing_attr_Util.Apply_Attribute_Changes
            (   p_PRICING_ATTR_rec            => l_p_PRICING_ATTR_rec
            ,   p_old_PRICING_ATTR_rec        => l_old_PRICING_ATTR_rec
            ,   x_PRICING_ATTR_rec            => l_PRICING_ATTR_rec
            );

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Validate_pll_pricing_attr.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_PRICING_ATTR_rec            => l_PRICING_ATTR_rec
                );

            ELSE

                QP_Validate_pll_pricing_attr.Entity
                (   x_return_status               => l_return_status
                ,   p_PRICING_ATTR_rec            => l_PRICING_ATTR_rec
                ,   p_old_PRICING_ATTR_rec        => l_old_PRICING_ATTR_rec
                );

            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

        IF l_control_rec.write_to_db THEN
                   l_p_PRICING_ATTR_rec := l_PRICING_ATTR_rec;
    	          QP_pll_PRICING_ATTR_UTIL.PRE_WRITE_PROCESS
                   ( p_Pricing_Attr_rec      => l_p_Pricing_Attr_rec
                   , p_old_Pricing_Attr_rec  => l_old_Pricing_Attr_rec
                   , x_Pricing_Attr_rec      => l_Pricing_Attr_rec);

        END IF;

        --  Step 4. Write to DB

        IF l_control_rec.write_to_db THEN

            IF l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                Qp_pll_pricing_attr_Util.Delete_Row
                (   p_pricing_attribute_id        => l_PRICING_ATTR_rec.pricing_attribute_id
                );

            ELSE

                --  Get Who Information

                l_PRICING_ATTR_rec.last_update_date := SYSDATE;
                l_PRICING_ATTR_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_PRICING_ATTR_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                   oe_debug_Pub.add('before update row');
                    Qp_pll_pricing_attr_Util.Update_Row (l_PRICING_ATTR_rec);

                ELSIF l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                    l_PRICING_ATTR_rec.creation_date := SYSDATE;
                    l_PRICING_ATTR_rec.created_by  := FND_GLOBAL.USER_ID;

                   oe_debug_pub.add('before insert row');

                    Qp_pll_pricing_attr_Util.Insert_Row (l_PRICING_ATTR_rec);

                END IF;

            END IF;

        END IF;

       END IF; /* if operation is create, update or delete */

        --  Load tables.

        l_PRICING_ATTR_tbl(I)          := l_PRICING_ATTR_rec;
        l_old_PRICING_ATTR_tbl(I)      := l_old_PRICING_ATTR_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_ERROR;
            l_PRICING_ATTR_tbl(I)          := l_PRICING_ATTR_rec;
            l_old_PRICING_ATTR_tbl(I)      := l_old_PRICING_ATTR_rec;

            -- mkarya If process_price_list has been called from public package, then ONLY call
            -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
            if l_control_rec.called_from_ui = 'N' then
 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_PRICE_LIST_LINE,
	          p_entity_id => l_PRICING_ATTR_rec.list_line_id,
	          x_return_status => l_return_status );

 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
	          p_entity_id => l_PRICING_ATTR_rec.list_line_id,
	          x_return_status => l_return_status );
            end if;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_PRICING_ATTR_tbl(I)          := l_PRICING_ATTR_rec;
            l_old_PRICING_ATTR_tbl(I)      := l_old_PRICING_ATTR_rec;

            -- mkarya If process_price_list has been called from public package, then ONLY call
            -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
            if l_control_rec.called_from_ui = 'N' then
 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_PRICE_LIST_LINE,
	          p_entity_id => l_PRICING_ATTR_rec.list_line_id,
	          x_return_status => l_return_status );

 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
	          p_entity_id => l_PRICING_ATTR_rec.list_line_id,
	          x_return_status => l_return_status );
            end if;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_PRICING_ATTR_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_PRICING_ATTR_tbl(I)          := l_PRICING_ATTR_rec;
            l_old_PRICING_ATTR_tbl(I)      := l_old_PRICING_ATTR_rec;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                oe_msg_pub.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Pricing_Attrs'
                );
            END IF;

            -- mkarya If process_price_list has been called from public package, then ONLY call
            -- qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
            if l_control_rec.called_from_ui = 'N' then
 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_PRICE_LIST_LINE,
	          p_entity_id => l_PRICING_ATTR_rec.list_line_id,
	          x_return_status => l_return_status );

 	       qp_delayed_requests_pvt.delete_reqs_for_deleted_entity
		    (p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
	          p_entity_id => l_PRICING_ATTR_rec.list_line_id,
	          x_return_status => l_return_status );
            end if;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_PRICING_ATTR_tbl             := l_PRICING_ATTR_tbl;
    x_old_PRICING_ATTR_tbl         := l_old_PRICING_ATTR_tbl;

  oe_debug_pub.add('exiting pricing attrs');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        RAISE;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Attrs'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Attrs;

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
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type :=
                                        QP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   p_old_PRICE_LIST_rec            IN  QP_Price_List_PUB.Price_List_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   p_PRICE_LIST_LINE_tbl           IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_TBL
,   p_old_PRICE_LIST_LINE_tbl       IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_TBL
,   p_QUALIFIERS_tbl                IN  Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type :=
					QP_Price_List_PUB.G_MISS_QUALIFIERS_TBL
                                        --Qp_Qualifier_Rules_Pub.G_MISS_QUALIFIERS_TBL  --2422176
,   p_old_QUALIFIERS_tbl            IN  Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type :=
					QP_Price_List_PUB.G_MISS_QUALIFIERS_TBL
                                        --Qp_Qualifier_Rules_Pub.G_MISS_QUALIFIERS_TBL  --2422176
,   p_PRICING_ATTR_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_TBL
,   p_old_PRICING_ATTR_tbl          IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_TBL
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Price_List';
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type := p_PRICE_LIST_rec;
l_p_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type := p_PRICE_LIST_rec;
l_old_PRICE_LIST_rec          QP_Price_List_PUB.Price_List_Rec_Type := p_old_PRICE_LIST_rec;
l_p_old_PRICE_LIST_rec        QP_Price_List_PUB.Price_List_Rec_Type := p_old_PRICE_LIST_rec;
l_PRICE_LIST_LINE_rec         QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_PRICE_LIST_LINE_tbl         QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_p_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_old_PRICE_LIST_LINE_rec     QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_old_PRICE_LIST_LINE_tbl     QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_p_old_PRICE_LIST_LINE_tbl   QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_QUALIFIERS_rec              Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_QUALIFIERS_tbl              Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_p_QUALIFIERS_tbl            Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_old_QUALIFIERS_rec          Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_old_QUALIFIERS_tbl          Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_p_old_QUALIFIERS_tbl        Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_PRICING_ATTR_rec            QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_PRICING_ATTR_tbl            QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_p_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_old_PRICING_ATTR_rec        QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_old_PRICING_ATTR_tbl        QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_p_old_PRICING_ATTR_tbl      QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_installed_status            VARCHAR2(1);
-- Blanket Agreement
l_qual_exists                 VARCHAR2(1) := 'N';
BEGIN

   oe_debug_pub.add('entering process price list');

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
	  oe_debug_pub.add('in unexpected error 1');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    oe_debug_Pub.add('process_Price_list 1');
    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        oe_msg_pub.initialize;
    END IF;

   /* check for installation status ; if it's basic then this api
      is not available */

    l_installed_status := QP_UTIL.get_qp_status;

    IF l_installed_status = 'N' THEN

       l_return_status := FND_API.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('QP', 'QP_BASIC_PRICING_UNAVAILABLE');
	  OE_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;

    END IF;

      --  Init local table variables.

      l_PRICE_LIST_LINE_tbl          := p_PRICE_LIST_LINE_tbl;
      l_old_PRICE_LIST_LINE_tbl      := p_old_PRICE_LIST_LINE_tbl;

      --  Init local table variables.

      l_QUALIFIERS_tbl               := p_QUALIFIERS_tbl;
      l_old_QUALIFIERS_tbl           := p_old_QUALIFIERS_tbl;

      --  Init local table variables.

      l_PRICING_ATTR_tbl             := p_PRICING_ATTR_tbl;
      l_old_PRICING_ATTR_tbl         := p_old_PRICING_ATTR_tbl;

      --  Price_List
      oe_debug_Pub.add('process_Price_list 2');
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
      oe_debug_Pub.add('process_Price_list 3');

      --  Perform PRICE_LIST group requests.

      IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_PRICE_LIST)
      THEN

         QP_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
            (p_entity_code   => QP_GLOBALS.G_ENTITY_PRICE_LIST
            ,p_delete        => FND_API.G_TRUE
            ,x_return_status => l_return_status
            );
         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
         END IF;

      END IF;

      --  Load parent key if missing and operation is create.

      FOR I IN 1..l_PRICE_LIST_LINE_tbl.COUNT LOOP

          l_PRICE_LIST_LINE_rec := l_PRICE_LIST_LINE_tbl(I);

          IF l_PRICE_LIST_LINE_rec.operation = QP_GLOBALS.G_OPR_CREATE
          AND (l_PRICE_LIST_LINE_rec.list_header_id IS NULL OR
              l_PRICE_LIST_LINE_rec.list_header_id = FND_API.G_MISS_NUM)
          THEN

            --  Copy parent_id.

            l_PRICE_LIST_LINE_tbl(I).list_header_id := l_PRICE_LIST_rec.list_header_id;
          END IF;

      END LOOP;

      --  Price_List_Lines
      oe_debug_Pub.add('process_Price_list 4');
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
      oe_debug_Pub.add('process_Price_list 5');

      --  Perform PRICE_LIST_LINE group requests.

      IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_PRICE_LIST_LINE)
      THEN

         QP_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
            (p_entity_code   => QP_GLOBALS.G_ENTITY_PRICE_LIST_LINE
            ,p_delete        => FND_API.G_TRUE
            ,x_return_status => l_return_status
            );
         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
         END IF;

      END IF;

      --  Load parent key if missing and operation is create.

      FOR I IN 1..l_QUALIFIERS_tbl.COUNT LOOP

          l_QUALIFIERS_rec := l_QUALIFIERS_tbl(I);

          IF l_QUALIFIERS_rec.operation = QP_GLOBALS.G_OPR_CREATE
          AND (l_QUALIFIERS_rec.list_header_id IS NULL OR
              l_QUALIFIERS_rec.list_header_id = FND_API.G_MISS_NUM)
          THEN

            --  Copy parent_id.

            l_QUALIFIERS_tbl(I).list_header_id := l_PRICE_LIST_rec.list_header_id;
          END IF;
      END LOOP;

      --  Qualifierss

      oe_debug_Pub.add('process_Price_list 6');
      l_p_QUALIFIERS_tbl := l_QUALIFIERS_tbl;
      l_p_old_QUALIFIERS_tbl := l_old_QUALIFIERS_tbl;
      Qualifierss
      (   p_validation_level            => p_validation_level
      ,   p_control_rec                 => p_control_rec
      ,   p_QUALIFIERS_tbl              => l_p_QUALIFIERS_tbl
      ,   p_old_QUALIFIERS_tbl          => l_p_old_QUALIFIERS_tbl
      ,   x_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
      ,   x_old_QUALIFIERS_tbl          => l_old_QUALIFIERS_tbl
      );
      oe_debug_Pub.add('process_Price_list 7');


      --  Perform QUALIFIERS group requests.

      IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_QUALIFIERS)
      THEN
        oe_debug_pub.add('process_Price_List 12');
        NULL;

      END IF;

      --  Load parent key if missing and operation is create.

      FOR I IN 1..l_PRICING_ATTR_tbl.COUNT LOOP

          oe_debug_pub.add('process_Price_List 13');
          l_PRICING_ATTR_rec := l_PRICING_ATTR_tbl(I);

          IF l_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_CREATE
          AND (l_PRICING_ATTR_rec.list_line_id IS NULL OR
            l_PRICING_ATTR_rec.list_line_id = FND_API.G_MISS_NUM)
          THEN

          oe_debug_pub.add('process_Price_List 14');
            --  Check If parent exists.

              IF l_PRICE_LIST_LINE_tbl.EXISTS(l_PRICING_ATTR_rec.PRICE_LIST_LINE_index) THEN

                --  Copy parent_id.
          oe_debug_pub.add('process_Price_List 15');

                l_PRICING_ATTR_tbl(I).list_line_id := l_PRICE_LIST_LINE_tbl(l_PRICING_ATTR_rec.PRICE_LIST_LINE_index).list_line_id;


                -- Copy list line's from_rltd_modifier_id to pricing attr's from_rltd_modifier_id

		 l_PRICING_ATTR_tbl(I).from_rltd_modifier_id := l_PRICE_LIST_LINE_tbl(l_PRICING_ATTR_rec.PRICE_LIST_LINE_index).from_rltd_modifier_id;


              ELSE
        oe_debug_pub.add('process_Price_List 16');

                IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
                THEN
        oe_debug_pub.add('process_Price_List 17');

                    FND_MESSAGE.SET_NAME('QP','QP_API_INV_PARENT_INDEX');
        oe_debug_pub.add('process_Price_List 18');
                    FND_MESSAGE.SET_TOKEN('ENTITY_NAME','PRICING_ATTR');
        oe_debug_pub.add('process_Price_List 19');
                    FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
        oe_debug_pub.add('process_Price_List 20');
                    FND_MESSAGE.SET_TOKEN('PARENT_INDEX',l_PRICING_ATTR_rec.PRICE_LIST_LINE_index);
        oe_debug_pub.add('process_Price_List 21');
                    oe_msg_pub.Add;


                END IF;
             END IF;
          END IF;
      END LOOP;
        oe_debug_pub.add('process_Price_List 22');

      --  Pricing_Attrs
      oe_debug_Pub.add('process_Price_list 8');
      l_p_PRICING_ATTR_tbl := l_PRICING_ATTR_tbl;
      l_p_old_PRICING_ATTR_tbl := l_old_PRICING_ATTR_tbl;
      Pricing_Attrs
      (   p_validation_level            => p_validation_level
      ,   p_control_rec                 => p_control_rec
      ,   p_PRICING_ATTR_tbl            => l_p_PRICING_ATTR_tbl
      ,   p_old_PRICING_ATTR_tbl        => l_p_old_PRICING_ATTR_tbl
      ,   x_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
      ,   x_old_PRICING_ATTR_tbl        => l_old_PRICING_ATTR_tbl
      );
      oe_debug_Pub.add('process_Price_list 9');

      --  Perform PRICING_ATTR group requests.

      IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_PRICING_ATTR)
      THEN

        NULL;

      END IF;

      --  Step 6. Perform Object group logic

      IF p_control_rec.process AND
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL
      THEN

	  oe_debug_pub.add('Ren: before processing delayed request');

        QP_DELAYED_REQUESTS_PVT.Process_Delayed_Requests(
                   x_return_status => l_return_status
          );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
        END IF;

	   oe_debug_pub.add('Ren: after processing delayed request');

      END IF;

      --  Done processing, load OUT parameters.

      x_PRICE_LIST_rec               := l_PRICE_LIST_rec;
      x_PRICE_LIST_LINE_tbl          := l_PRICE_LIST_LINE_tbl;
      x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;
      x_PRICING_ATTR_tbl             := l_PRICING_ATTR_tbl;

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

          IF ( l_PRICE_LIST_LINE_tbl(I).return_status = FND_API.G_RET_STS_ERROR AND
          ( l_PRICE_LIST_LINE_rec.list_line_id  <>  FND_API.G_MISS_NUM  OR
                           l_PRICE_LIST_LINE_rec.list_line_id  <>  NULL )  ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

      END LOOP;

      FOR I IN 1..l_QUALIFIERS_tbl.COUNT LOOP

          IF l_QUALIFIERS_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

      END LOOP;

      FOR I IN 1..l_PRICING_ATTR_tbl.COUNT LOOP

          IF l_PRICING_ATTR_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

      END LOOP;

    --  Get message count and data
    oe_debug_Pub.add('process_Price_list 11');

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    -- Create blanket header qualifier

    IF (     p_control_rec.write_to_db --Bug#3309455
         AND x_PRICE_LIST_rec.operation = QP_GLOBALS.G_OPR_CREATE
         AND x_PRICE_LIST_rec.list_source_code = 'BSO'
         AND ( x_PRICE_LIST_rec.orig_system_header_ref <> NULL
            OR x_PRICE_LIST_rec.orig_system_header_ref <> FND_API.G_MISS_CHAR)
       )
    THEN
        oe_debug_pub.add('inside create qualifier for blanket modifier');

	BEGIN
	  select 'Y' into l_qual_exists
	  from qp_qualifiers
	  where list_header_id = x_PRICE_LIST_rec.list_header_id
	   and qualifier_context = 'ORDER'
	   and qualifier_attribute = 'QUALIFIER_ATTRIBUTE5'
	   and qualifier_attr_value = x_PRICE_LIST_rec.orig_system_header_ref;
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	    l_qual_exists := 'N';
	  WHEN OTHERS THEN NULL;
	END;

	IF l_qual_exists = 'N' THEN

	         QP_Qualifier_Rules_PVT.Create_Blanket_Qualifier
	           (   p_list_header_id            => x_PRICE_LIST_rec.list_header_id
	           ,   p_old_list_header_id        => x_PRICE_LIST_rec.list_header_id
	           ,   p_blanket_id                => to_number(x_PRICE_LIST_rec.orig_system_header_ref)
	           ,   p_operation                 => QP_GLOBALS.G_OPR_CREATE
	           ,   x_return_status             => l_return_status
	           );

	        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           oe_debug_pub.add('Unexp Error while creating blanket qualifier');
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           oe_debug_pub.add('Exp Error while creating blanket qualifier');
	           RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;

    END IF;

    oe_debug_pub.add('exiting process price list');


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        -- mkarya If process_price_list has been called from public package, then ONLY call clear_request
        if p_control_rec.called_from_ui = 'N' then
	   qp_delayed_requests_pvt.Clear_Request
		(x_return_status => l_return_status);
        end if;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        -- mkarya If process_price_list has been called from public package, then ONLY call clear_request
        if p_control_rec.called_from_ui = 'N' then
	   qp_delayed_requests_pvt.Clear_Request
		(x_return_status => l_return_status);
        end if;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        -- mkarya If process_price_list has been called from public package, then ONLY call clear_request
        if p_control_rec.called_from_ui = 'N' then
	   qp_delayed_requests_pvt.Clear_Request
		(x_return_status => l_return_status);
        end if;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Price_List'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
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
,   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   p_PRICE_LIST_LINE_tbl           IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_TBL
,   p_QUALIFIERS_tbl                IN  Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type :=
					QP_Price_List_PUB.G_MISS_QUALIFIERS_TBL
                                        --Qp_Qualifier_Rules_Pub.G_MISS_QUALIFIERS_TBL  --2422176
,   p_PRICING_ATTR_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_TBL
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Price_List';
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_PRICE_LIST_LINE_rec         QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_QUALIFIERS_rec              Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_PRICING_ATTR_rec            QP_Price_List_PUB.Pricing_Attr_Rec_Type;
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
        oe_msg_pub.initialize;
    END IF;

    --  Set Savepoint

    SAVEPOINT Lock_Price_List_PVT;

    --  Lock PRICE_LIST

    IF p_PRICE_LIST_rec.operation = QP_GLOBALS.G_OPR_LOCK THEN

        QP_Price_List_Util.Lock_Row
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

        IF p_PRICE_LIST_LINE_tbl(I).operation = QP_GLOBALS.G_OPR_LOCK THEN

            QP_Price_List_Line_Util.Lock_Row
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

    --  Lock QUALIFIERS

    FOR I IN 1..p_QUALIFIERS_tbl.COUNT LOOP

        IF p_QUALIFIERS_tbl(I).operation = QP_GLOBALS.G_OPR_LOCK THEN

            QP_Qualifiers_Util.Lock_Row
            (   p_QUALIFIERS_rec              => p_QUALIFIERS_tbl(I)
            ,   x_QUALIFIERS_rec              => l_QUALIFIERS_rec
            ,   x_return_status               => l_return_status
            );


            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_QUALIFIERS_tbl(I)            := l_QUALIFIERS_rec;

        END IF;

    END LOOP;

    --  Lock PRICING_ATTR

    FOR I IN 1..p_PRICING_ATTR_tbl.COUNT LOOP

        IF p_PRICING_ATTR_tbl(I).operation = QP_GLOBALS.G_OPR_LOCK THEN

            Qp_pll_pricing_attr_Util.Lock_Row
            (   p_PRICING_ATTR_rec            => p_PRICING_ATTR_tbl(I)
            ,   x_PRICING_ATTR_rec            => l_PRICING_ATTR_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_PRICING_ATTR_tbl(I)          := l_PRICING_ATTR_rec;

        END IF;

    END LOOP;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Price_List_PVT;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Price_List_PVT;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Price_List'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
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
,   p_list_header_id                IN  NUMBER
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Price_List';
l_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type;
l_PRICE_LIST_LINE_tbl         QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_QUALIFIERS_tbl              Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_PRICING_ATTR_tbl            QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
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
        oe_msg_pub.initialize;
    END IF;

    --  Get PRICE_LIST ( parent = PRICE_LIST )

    l_PRICE_LIST_rec :=  QP_Price_List_Util.Query_Row
    (   p_list_header_id      => p_list_header_id
    );

        --  Get PRICE_LIST_LINE ( parent = PRICE_LIST )

        l_PRICE_LIST_LINE_tbl :=  QP_Price_List_Line_Util.Query_Rows
        (   p_list_header_id        => l_PRICE_LIST_rec.list_header_id
        );


        --  Loop over PRICE_LIST_LINE's children

        FOR I2 IN 1..l_PRICE_LIST_LINE_tbl.COUNT LOOP

            --  Get PRICING_ATTR ( parent = PRICE_LIST_LINE )

            l_PRICING_ATTR_tbl :=  Qp_pll_pricing_attr_Util.Query_Rows
            (   p_list_line_id            => l_PRICE_LIST_LINE_tbl(I2).list_line_id
            );

            FOR I3 IN 1..l_PRICING_ATTR_tbl.COUNT LOOP
                l_PRICING_ATTR_tbl(I3).PRICE_LIST_LINE_Index := I2;
                l_x_PRICING_ATTR_tbl
                (l_x_PRICING_ATTR_tbl.COUNT + 1) := l_PRICING_ATTR_tbl(I3);
            END LOOP;


        END LOOP;


        --  Get QUALIFIERS ( parent = PRICE_LIST )

        l_QUALIFIERS_tbl :=  QP_Qualifiers_Util_Mod.Query_Rows
        (   p_list_header_id        => l_PRICE_LIST_rec.list_header_id
        );



    --  Load out parameters

    x_PRICE_LIST_rec               := l_PRICE_LIST_rec;
    x_PRICE_LIST_LINE_tbl          := l_PRICE_LIST_LINE_tbl;
    x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;
    x_PRICING_ATTR_tbl             := l_x_PRICING_ATTR_tbl;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Price_List'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Price_List;

END QP_LIST_HEADERS_PVT;

/
