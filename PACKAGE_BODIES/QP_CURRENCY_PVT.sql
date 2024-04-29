--------------------------------------------------------
--  DDL for Package Body QP_CURRENCY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_CURRENCY_PVT" AS
/* $Header: QPXVCURB.pls 120.2 2005/07/07 04:29:57 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Currency_PVT';

--  Curr_Lists

PROCEDURE Curr_Lists
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type
,   p_old_CURR_LISTS_rec            IN  QP_Currency_PUB.Curr_Lists_Rec_Type
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Lists_Rec_Type
,   x_old_CURR_LISTS_rec            OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Lists_Rec_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_CURR_LISTS_rec              QP_Currency_PUB.Curr_Lists_Rec_Type := p_CURR_LISTS_rec;
l_old_CURR_LISTS_rec          QP_Currency_PUB.Curr_Lists_Rec_Type := p_old_CURR_LISTS_rec;

l_p_CURR_LISTS_rec	      QP_Currency_PUB.Curr_Lists_Rec_Type; --[prarasto]

BEGIN

	/* Debug Code
    oe_debug_pub.add('Entered CURR_LISTS procedure');
    -- oe_debug_pub.add('Check Point-1');
-- Debugging statements only by Sunil
        oe_debug_pub.add('Inside CURR_LISTS: CHECK POINT-1; CHECKING l_control_rec');
        if l_control_rec.default_attributes then
            oe_debug_pub.add('Before Init_Control_rec: default_attributes is TRUE');
        else
            oe_debug_pub.add('Before Init_Control_rec: default_attributes is FALSE');
        end if;
        if l_control_rec.change_attributes then
            oe_debug_pub.add('Before Init_Control_rec: change_attributes is TRUE');
        else
            oe_debug_pub.add('Before Init_Control_rec: change_attributes is FALSE');
        end if;
        IF l_control_rec.write_to_db THEN
          oe_debug_pub.add('Before Init_Control_rec: write_to_db is TRUE');
        ELSE
          oe_debug_pub.add('Before Init_Control_rec: write_to_db is FALSE');
        END IF;
        oe_debug_pub.add('Before Init_Control_rec: Operation: '||l_CURR_LISTS_rec.operation);
        IF l_control_rec.validate_entity THEN
          oe_debug_pub.add('Before Init_Control_rec: validate_entity is TRUE');
        else
          oe_debug_pub.add('Before Init_Control_rec: validate_entity is FALSE');
        end if;
-- Debugging statements only by Sunil
	Debug Code */
    --  Load API control record

    l_control_rec := QP_GLOBALS.Init_Control_Rec
    (   p_operation     => l_CURR_LISTS_rec.operation
    ,   p_control_rec   => p_control_rec
    );
	/* Debug Code
-- Debugging statements only by Sunil
        oe_debug_pub.add('After Init_Control_rec: CHECK POINT-2; CHECKING l_control_rec');
        if l_control_rec.default_attributes then
            oe_debug_pub.add('After Init_Control_rec: default_attributes is TRUE');
        else
            oe_debug_pub.add('After Init_Control_rec: default_attributes is FALSE');
        end if;
        if l_control_rec.change_attributes then
            oe_debug_pub.add('After Init_Control_rec: change_attributes is TRUE');
        else
            oe_debug_pub.add('After Init_Control_rec: change_attributes is FALSE');
        end if;
        IF l_control_rec.write_to_db THEN
          oe_debug_pub.add('After Init_Control_rec: write_to_db is TRUE');
        ELSE
          oe_debug_pub.add('After Init_Control_rec: write_to_db is FALSE');
        END IF;
        oe_debug_pub.add('After Init_Control_rec: Operation: '||l_CURR_LISTS_rec.operation);
        IF l_control_rec.validate_entity THEN
          oe_debug_pub.add('After Init_Control_rec: validate_entity is TRUE');
        else
          oe_debug_pub.add('After Init_Control_rec: validate_entity is FALSE');
        end if;
-- Debugging statements only by Sunil
	Debug Code */

    --  Set record return status.

    l_CURR_LISTS_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  Prepare record.

    IF l_CURR_LISTS_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

        l_CURR_LISTS_rec.db_flag := FND_API.G_FALSE;

        --  Set missing old record elements to NULL.

        l_old_CURR_LISTS_rec :=
        QP_Curr_Lists_Util.Convert_Miss_To_Null (l_old_CURR_LISTS_rec);

    ELSIF l_CURR_LISTS_rec.operation = QP_GLOBALS.G_OPR_UPDATE
    OR    l_CURR_LISTS_rec.operation = QP_GLOBALS.G_OPR_DELETE
    THEN

        l_CURR_LISTS_rec.db_flag := FND_API.G_TRUE;

        --  Query Old if missing

        IF  l_old_CURR_LISTS_rec.currency_header_id = FND_API.G_MISS_NUM
        THEN

            l_old_CURR_LISTS_rec := QP_Curr_Lists_Util.Query_Row
            (   p_currency_header_id          => l_CURR_LISTS_rec.currency_header_id
            );

        ELSE

            --  Set missing old record elements to NULL.

            l_old_CURR_LISTS_rec :=
            QP_Curr_Lists_Util.Convert_Miss_To_Null (l_old_CURR_LISTS_rec);

        END IF;

        --  Complete new record from old

        l_CURR_LISTS_rec := QP_Curr_Lists_Util.Complete_Record
        (   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
        ,   p_old_CURR_LISTS_rec          => l_old_CURR_LISTS_rec
        );

    END IF;

    -- oe_debug_pub.add('Check Pint-2');
    --  Attribute level validation.

   IF ( l_CURR_LISTS_rec.operation = QP_GLOBALS.G_OPR_UPDATE
     or l_CURR_LISTS_rec.operation = QP_GLOBALS.G_OPR_CREATE
     or l_CURR_LISTS_rec.operation = QP_GLOBALS.G_OPR_DELETE ) THEN
    -- Above if statement added by Sunil Pandey in order to avoid header level validations
    -- for detail record
    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

            QP_Validate_Curr_Lists.Attributes
            (   x_return_status               => l_return_status
            ,   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
            ,   p_old_CURR_LISTS_rec          => l_old_CURR_LISTS_rec
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

    END IF;
    -- oe_debug_pub.add('Check Pint-3');

        --  Clear dependent attributes.

    IF  l_control_rec.change_attributes THEN

        l_p_CURR_LISTS_rec := l_CURR_LISTS_rec; --[prarasto]

        QP_Curr_Lists_Util.Clear_Dependent_Attr
        (   p_CURR_LISTS_rec              => l_p_CURR_LISTS_rec
        ,   p_old_CURR_LISTS_rec          => l_old_CURR_LISTS_rec
        ,   x_CURR_LISTS_rec              => l_CURR_LISTS_rec
        );

    END IF;

    -- oe_debug_pub.add('Check Pint-4');
    --  Default missing attributes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

    -- oe_debug_pub.add('Before Calling HDR D Attributes procedure: l_CURR_LISTS_rec.currency_header_id'||l_CURR_LISTS_rec.currency_header_id);

        l_p_CURR_LISTS_rec := l_CURR_LISTS_rec; --[prarasto]

        QP_Default_Curr_Lists.Attributes
        (   p_CURR_LISTS_rec              => l_p_CURR_LISTS_rec
        ,   x_CURR_LISTS_rec              => l_CURR_LISTS_rec
        );
    -- oe_debug_pub.add('After Calling HDR D Attributes procedure: l_CURR_LISTS_rec.currency_header_id'||l_CURR_LISTS_rec.currency_header_id);

    END IF;
    -- oe_debug_pub.add('Check Pint-5');

    --  Apply attribute changes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        l_p_CURR_LISTS_rec := l_CURR_LISTS_rec; --[prarasto]

        QP_Curr_Lists_Util.Apply_Attribute_Changes
        (   p_CURR_LISTS_rec              => l_p_CURR_LISTS_rec
        ,   p_old_CURR_LISTS_rec          => l_old_CURR_LISTS_rec
        ,   x_CURR_LISTS_rec              => l_CURR_LISTS_rec
        );

    END IF;
    -- oe_debug_pub.add('Check Pint-6');

    --  Entity level validation.
    -- oe_debug_pub.add('Inside  CURR_LISTS Just before calling QP_Validate_Curr_Lists L-Package');

    IF l_control_rec.validate_entity THEN

        IF l_CURR_LISTS_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN
            -- Added by sunilpandey to prevent delete operation of details from Public package
            FND_MESSAGE.SET_NAME('QP','QP_CAN_NOT_DELETE_CURR_HDR');
            OE_MSG_PUB.Add;

            RAISE FND_API.G_EXC_ERROR;


           /*
            QP_Validate_Curr_Lists.Entity_Delete
            (   x_return_status               => l_return_status
            ,   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
            );
           */

        ELSE

            QP_Validate_Curr_Lists.Entity
            (   x_return_status               => l_return_status
            ,   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
            ,   p_old_CURR_LISTS_rec          => l_old_CURR_LISTS_rec
            );

        END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;
-- Added by SunilP
    -- oe_debug_pub.add('Inside  CURR_LISTS after calling QP_Validate_Curr_Lists and before calling update_row');
    -- oe_debug_pub.add('Operation: '||l_CURR_LISTS_rec.operation);

/*
    IF l_control_rec.write_to_db THEN
      oe_debug_pub.add('write_to_db is TRUE');
    ELSE
      oe_debug_pub.add('write_to_db is FALSE');
    END IF;
-- Added by SunilP
*/

    --  Step 4. Write to DB

    IF l_control_rec.write_to_db THEN

        IF l_CURR_LISTS_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

            QP_Curr_Lists_Util.Delete_Row
            (   p_currency_header_id          => l_CURR_LISTS_rec.currency_header_id
            );

        ELSE

            --  Get Who Information

            l_CURR_LISTS_rec.last_update_date := SYSDATE;
            l_CURR_LISTS_rec.last_updated_by := FND_GLOBAL.USER_ID;
            l_CURR_LISTS_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

            IF l_CURR_LISTS_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

    -- oe_debug_pub.add('Calling  QP_Curr_Lists_Util.Update_Row from CURR_LISTS package');
                QP_Curr_Lists_Util.Update_Row (l_CURR_LISTS_rec);

            ELSIF l_CURR_LISTS_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                l_CURR_LISTS_rec.creation_date := SYSDATE;
                l_CURR_LISTS_rec.created_by    := FND_GLOBAL.USER_ID;

                QP_Curr_Lists_Util.Insert_Row (l_CURR_LISTS_rec);

            END IF;

        END IF;

    END IF;
   END IF; /* if operation is create, update or delete */

   --  Load OUT parameters

   x_CURR_LISTS_rec               := l_CURR_LISTS_rec;
   x_old_CURR_LISTS_rec           := l_old_CURR_LISTS_rec;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        l_CURR_LISTS_rec.return_status := FND_API.G_RET_STS_ERROR;
        x_CURR_LISTS_rec               := l_CURR_LISTS_rec;
        x_old_CURR_LISTS_rec           := l_old_CURR_LISTS_rec;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        l_CURR_LISTS_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_CURR_LISTS_rec               := l_CURR_LISTS_rec;
        x_old_CURR_LISTS_rec           := l_old_CURR_LISTS_rec;

        RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Curr_Lists'
            );
        END IF;

        l_CURR_LISTS_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_CURR_LISTS_rec               := l_CURR_LISTS_rec;
        x_old_CURR_LISTS_rec           := l_old_CURR_LISTS_rec;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Curr_Lists;

--  Curr_Detailss

PROCEDURE Curr_Detailss
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_CURR_DETAILS_tbl              IN  QP_Currency_PUB.Curr_Details_Tbl_Type
,   p_old_CURR_DETAILS_tbl          IN  QP_Currency_PUB.Curr_Details_Tbl_Type
,   x_CURR_DETAILS_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Details_Tbl_Type
,   x_old_CURR_DETAILS_tbl          OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Details_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_CURR_DETAILS_rec            QP_Currency_PUB.Curr_Details_Rec_Type;
l_CURR_DETAILS_tbl            QP_Currency_PUB.Curr_Details_Tbl_Type;
l_old_CURR_DETAILS_rec        QP_Currency_PUB.Curr_Details_Rec_Type;
l_old_CURR_DETAILS_tbl        QP_Currency_PUB.Curr_Details_Tbl_Type;

l_p_CURR_DETAILS_rec	      QP_Currency_PUB.Curr_Details_Rec_Type; --[prarasto]

BEGIN
    -- oe_debug_pub.add('Entered curr_detailss');

    --  Init local table variables.

    l_CURR_DETAILS_tbl             := p_CURR_DETAILS_tbl;
    l_old_CURR_DETAILS_tbl         := p_old_CURR_DETAILS_tbl;

    FOR I IN 1..l_CURR_DETAILS_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_CURR_DETAILS_rec := l_CURR_DETAILS_tbl(I);

        IF l_old_CURR_DETAILS_tbl.EXISTS(I) THEN
            l_old_CURR_DETAILS_rec := l_old_CURR_DETAILS_tbl(I);
        ELSE
            l_old_CURR_DETAILS_rec := QP_Currency_PUB.G_MISS_CURR_DETAILS_REC;
        END IF;

        --  Load API control record

        l_control_rec := QP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_CURR_DETAILS_rec.operation
        ,   p_control_rec   => p_control_rec
        );

	/* Debug Code
-- Debugging statements only by Sunil
        oe_debug_pub.add('CHECK POINT-1; CHECKING l_control_rec');
        if l_control_rec.default_attributes then
            oe_debug_pub.add('default_attributes is TRUE');
        else
            oe_debug_pub.add('default_attributes is FALSE');
        end if;
        if l_control_rec.change_attributes then
            oe_debug_pub.add('change_attributes is TRUE');
        else
            oe_debug_pub.add('change_attributes is FALSE');
        end if;
        IF l_control_rec.write_to_db THEN
          oe_debug_pub.add('write_to_db is TRUE');
        ELSE
          oe_debug_pub.add('write_to_db is FALSE');
        END IF;
        oe_debug_pub.add('Operation: '||l_CURR_DETAILS_rec.operation);
        IF l_control_rec.validate_entity THEN
          oe_debug_pub.add('validate_entity is TRUE');
        else
          oe_debug_pub.add('validate_entity is FALSE');
        end if;
-- Debugging statements only by Sunil
	Debug Code */

        --  Set record return status.

        l_CURR_DETAILS_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_CURR_DETAILS_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

            l_CURR_DETAILS_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_CURR_DETAILS_rec :=
            QP_Curr_Details_Util.Convert_Miss_To_Null (l_old_CURR_DETAILS_rec);

        ELSIF l_CURR_DETAILS_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        OR    l_CURR_DETAILS_rec.operation = QP_GLOBALS.G_OPR_DELETE
        THEN

            l_CURR_DETAILS_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_CURR_DETAILS_rec.currency_detail_id = FND_API.G_MISS_NUM
            THEN

                l_old_CURR_DETAILS_rec := QP_Curr_Details_Util.Query_Row
                (   p_currency_detail_id          => l_CURR_DETAILS_rec.currency_detail_id
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_CURR_DETAILS_rec :=
                QP_Curr_Details_Util.Convert_Miss_To_Null (l_old_CURR_DETAILS_rec);

            END IF;

            --  Complete new record from old

            l_CURR_DETAILS_rec := QP_Curr_Details_Util.Complete_Record
            (   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
            ,   p_old_CURR_DETAILS_rec        => l_old_CURR_DETAILS_rec
            );

        END IF;
	/* Debug Code
-- Debugging statements only by Sunil
        oe_debug_pub.add('CHECK POINT-2; CHECKING l_control_rec');
        if l_control_rec.default_attributes then
            oe_debug_pub.add('default_attributes is TRUE');
        else
            oe_debug_pub.add('default_attributes is FALSE');
        end if;
        if l_control_rec.change_attributes then
            oe_debug_pub.add('change_attributes is TRUE');
        else
            oe_debug_pub.add('change_attributes is FALSE');
        end if;
        IF l_control_rec.write_to_db THEN
          oe_debug_pub.add('write_to_db is TRUE');
        ELSE
          oe_debug_pub.add('write_to_db is FALSE');
        END IF;
        oe_debug_pub.add('Operation: '||l_CURR_DETAILS_rec.operation);
        IF l_control_rec.validate_entity THEN
          oe_debug_pub.add('validate_entity is TRUE');
        else
          oe_debug_pub.add('validate_entity is FALSE');
        end if;
-- Debugging statements only by Sunil
	Debug Code */

        --  Attribute level validation.

   IF ( l_CURR_DETAILS_rec.operation = QP_GLOBALS.G_OPR_UPDATE
     or l_CURR_DETAILS_rec.operation = QP_GLOBALS.G_OPR_CREATE
     or l_CURR_DETAILS_rec.operation = QP_GLOBALS.G_OPR_DELETE ) THEN
    -- Above if statement added by Sunil Pandey in order to avoid header level validations
    -- for detail record
        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                QP_Validate_Curr_Details.Attributes
                (   x_return_status               => l_return_status
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   p_old_CURR_DETAILS_rec        => l_old_CURR_DETAILS_rec
                );

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;

        END IF;
	/* Debug Code
-- Debugging statements only by Sunil
        oe_debug_pub.add('CHECK POINT-3; CHECKING l_control_rec');
        if l_control_rec.default_attributes then
            oe_debug_pub.add('default_attributes is TRUE');
        else
            oe_debug_pub.add('default_attributes is FALSE');
        end if;
        if l_control_rec.change_attributes then
            oe_debug_pub.add('change_attributes is TRUE');
        else
            oe_debug_pub.add('change_attributes is FALSE');
        end if;
        IF l_control_rec.write_to_db THEN
          oe_debug_pub.add('write_to_db is TRUE');
        ELSE
          oe_debug_pub.add('write_to_db is FALSE');
        END IF;
        oe_debug_pub.add('Operation: '||l_CURR_DETAILS_rec.operation);
        IF l_control_rec.validate_entity THEN
          oe_debug_pub.add('validate_entity is TRUE');
        else
          oe_debug_pub.add('validate_entity is FALSE');
        end if;
-- Debugging statements only by Sunil
	Debug Code */

            --  Clear dependent attributes.

        IF  l_control_rec.change_attributes THEN

	    l_p_CURR_DETAILS_rec := l_CURR_DETAILS_rec; --[prarasto]

            QP_Curr_Details_Util.Clear_Dependent_Attr
            (   p_CURR_DETAILS_rec            => l_p_CURR_DETAILS_rec
            ,   p_old_CURR_DETAILS_rec        => l_old_CURR_DETAILS_rec
            ,   x_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
            );

        END IF;
	/* Debug Code
-- Debugging statements only by Sunil
        oe_debug_pub.add('CHECK POINT-4; CHECKING l_control_rec');
        if l_control_rec.default_attributes then
            oe_debug_pub.add('default_attributes is TRUE');
        else
            oe_debug_pub.add('default_attributes is FALSE');
        end if;
        if l_control_rec.change_attributes then
            oe_debug_pub.add('change_attributes is TRUE');
        else
            oe_debug_pub.add('change_attributes is FALSE');
        end if;
        IF l_control_rec.write_to_db THEN
          oe_debug_pub.add('write_to_db is TRUE');
        ELSE
          oe_debug_pub.add('write_to_db is FALSE');
        END IF;
        oe_debug_pub.add('Operation: '||l_CURR_DETAILS_rec.operation);
        IF l_control_rec.validate_entity THEN
          oe_debug_pub.add('validate_entity is TRUE');
        else
          oe_debug_pub.add('validate_entity is FALSE');
        end if;
-- Debugging statements only by Sunil
	Debug Code */

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

    -- oe_debug_pub.add('Before Calling LINE D Attributes procedure: l_CURR_DETAILS_rec.currency_header_id'||l_CURR_DETAILS_rec.currency_header_id);

	    l_p_CURR_DETAILS_rec := l_CURR_DETAILS_rec; --[prarasto]

            QP_Default_Curr_Details.Attributes
            (   p_CURR_DETAILS_rec            => l_p_CURR_DETAILS_rec
            ,   x_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
            );
    -- oe_debug_pub.add('After Calling LINE D Attributes procedure: l_CURR_DETAILS_rec.currency_header_id'||l_CURR_DETAILS_rec.currency_header_id);

        END IF;
	/* Debug Code
-- Debugging statements only by Sunil
        oe_debug_pub.add('CHECK POINT-5; CHECKING l_control_rec');
        if l_control_rec.default_attributes then
            oe_debug_pub.add('default_attributes is TRUE');
        else
            oe_debug_pub.add('default_attributes is FALSE');
        end if;
        if l_control_rec.change_attributes then
            oe_debug_pub.add('change_attributes is TRUE');
        else
            oe_debug_pub.add('change_attributes is FALSE');
        end if;
        IF l_control_rec.write_to_db THEN
          oe_debug_pub.add('write_to_db is TRUE');
        ELSE
          oe_debug_pub.add('write_to_db is FALSE');
        END IF;
        oe_debug_pub.add('Operation: '||l_CURR_DETAILS_rec.operation);
        IF l_control_rec.validate_entity THEN
          oe_debug_pub.add('validate_entity is TRUE');
        else
          oe_debug_pub.add('validate_entity is FALSE');
        end if;
-- Debugging statements only by Sunil
	Debug Code */

        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

	    l_p_CURR_DETAILS_rec := l_CURR_DETAILS_rec; --[prarasto]

            QP_Curr_Details_Util.Apply_Attribute_Changes
            (   p_CURR_DETAILS_rec            => l_p_CURR_DETAILS_rec
            ,   p_old_CURR_DETAILS_rec        => l_old_CURR_DETAILS_rec
            ,   x_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
            );

        END IF;

	/* Debug Code
-- Debugging statements only by Sunil
        oe_debug_pub.add('CHECK POINT-6; CHECKING l_control_rec');
        if l_control_rec.default_attributes then
            oe_debug_pub.add('default_attributes is TRUE');
        else
            oe_debug_pub.add('default_attributes is FALSE');
        end if;
        if l_control_rec.change_attributes then
            oe_debug_pub.add('change_attributes is TRUE');
        else
            oe_debug_pub.add('change_attributes is FALSE');
        end if;
        IF l_control_rec.write_to_db THEN
          oe_debug_pub.add('write_to_db is TRUE');
        ELSE
          oe_debug_pub.add('write_to_db is FALSE');
        END IF;
        oe_debug_pub.add('Operation: '||l_CURR_DETAILS_rec.operation);
        IF l_control_rec.validate_entity THEN
          oe_debug_pub.add('validate_entity is TRUE');
        else
          oe_debug_pub.add('validate_entity is FALSE');
        end if;
-- Debugging statements only by Sunil
	Debug Code */
        --  Entity level validation.

        -- oe_debug_pub.add('** BEFORE Calling QP_Validate_Curr_Details package; OUTSIDE IF');
        IF l_control_rec.validate_entity THEN
            -- oe_debug_pub.add('** BEFORE Calling QP_Validate_Curr_Details package; INSIDE FIRST IF');

            IF l_CURR_DETAILS_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

		-- Added by sunilpandey to prevent delete operation of details from Public package
                FND_MESSAGE.SET_NAME('QP','QP_CAN_NOT_DELETE_CURR_DTL');
                OE_MSG_PUB.Add;

                RAISE FND_API.G_EXC_ERROR;


		/*
                QP_Validate_Curr_Details.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                );
		*/

            ELSE

                -- oe_debug_pub.add('** BEFORE Calling QP_Validate_Curr_Details.Entity; INSIDE IF');
                QP_Validate_Curr_Details.Entity
                (   x_return_status               => l_return_status
                ,   p_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
                ,   p_old_CURR_DETAILS_rec        => l_old_CURR_DETAILS_rec
                );
        -- oe_debug_pub.add(' Inside V after Entity call; G_MSG_COUNT: '||OE_MSG_PUB.G_MSG_COUNT);

            END IF;

            -- oe_debug_pub.add('After Calling QP_Validate_Curr_Details.Entity from V package; l_return_status :'||l_return_status);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

        --  Step 4. Write to DB

	/* Debug Code
        oe_debug_pub.add('CHECKING VALUES BEFORE LINES INSERT/UPDATE/DELETE_ROW IS CALLED FROM VCUR');
        IF l_control_rec.write_to_db THEN
          oe_debug_pub.add('write_to_db is TRUE');
        ELSE
          oe_debug_pub.add('write_to_db is FALSE');
        END IF;
        oe_debug_pub.add('Operation: '||l_CURR_DETAILS_rec.operation);
	Debug Code */

        IF l_control_rec.write_to_db THEN

            IF l_CURR_DETAILS_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                -- oe_debug_pub.add('QP_Curr_Details_Util.Delete_Row is being called');
                QP_Curr_Details_Util.Delete_Row
                (   p_currency_detail_id          => l_CURR_DETAILS_rec.currency_detail_id
                );
                -- oe_debug_pub.add('QP_Curr_Details_Util.Delete_Row is done');

            ELSE

                --  Get Who Information

                l_CURR_DETAILS_rec.last_update_date := SYSDATE;
                l_CURR_DETAILS_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_CURR_DETAILS_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_CURR_DETAILS_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                    QP_Curr_Details_Util.Update_Row (l_CURR_DETAILS_rec);

                ELSIF l_CURR_DETAILS_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                    l_CURR_DETAILS_rec.creation_date := SYSDATE;
                    l_CURR_DETAILS_rec.created_by  := FND_GLOBAL.USER_ID;

                    QP_Curr_Details_Util.Insert_Row (l_CURR_DETAILS_rec);

                END IF;

            END IF;

        END IF;
   END IF; /* if operation is create, update or delete */

        --  Load tables.

        l_CURR_DETAILS_tbl(I)          := l_CURR_DETAILS_rec;
        l_old_CURR_DETAILS_tbl(I)      := l_old_CURR_DETAILS_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_CURR_DETAILS_rec.return_status := FND_API.G_RET_STS_ERROR;
            l_CURR_DETAILS_tbl(I)          := l_CURR_DETAILS_rec;
            l_old_CURR_DETAILS_tbl(I)      := l_old_CURR_DETAILS_rec;
            -- oe_debug_pub.add('Raised Inner FND_API.G_EXC_ERROR EXCEPTION');
            RAISE FND_API.G_EXC_ERROR;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_CURR_DETAILS_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_CURR_DETAILS_tbl(I)          := l_CURR_DETAILS_rec;
            l_old_CURR_DETAILS_tbl(I)      := l_old_CURR_DETAILS_rec;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_CURR_DETAILS_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_CURR_DETAILS_tbl(I)          := l_CURR_DETAILS_rec;
            l_old_CURR_DETAILS_tbl(I)      := l_old_CURR_DETAILS_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Curr_Detailss'
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_CURR_DETAILS_tbl             := l_CURR_DETAILS_tbl;
    x_old_CURR_DETAILS_tbl         := l_old_CURR_DETAILS_tbl;

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
            ,   'Curr_Detailss'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Curr_Detailss;

--  Start of Comments
--  API name    Process_Currency
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

PROCEDURE Process_Currency
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type :=
                                        QP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_LISTS_REC
,   p_old_CURR_LISTS_rec            IN  QP_Currency_PUB.Curr_Lists_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_LISTS_REC
,   p_CURR_DETAILS_tbl              IN  QP_Currency_PUB.Curr_Details_Tbl_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_DETAILS_TBL
,   p_old_CURR_DETAILS_tbl          IN  QP_Currency_PUB.Curr_Details_Tbl_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_DETAILS_TBL
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Lists_Rec_Type
,   x_CURR_DETAILS_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Details_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Currency';
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_CURR_LISTS_rec              QP_Currency_PUB.Curr_Lists_Rec_Type := p_CURR_LISTS_rec;
l_old_CURR_LISTS_rec          QP_Currency_PUB.Curr_Lists_Rec_Type := p_old_CURR_LISTS_rec;
l_CURR_DETAILS_rec            QP_Currency_PUB.Curr_Details_Rec_Type;
l_CURR_DETAILS_tbl            QP_Currency_PUB.Curr_Details_Tbl_Type;
l_old_CURR_DETAILS_rec        QP_Currency_PUB.Curr_Details_Rec_Type;
l_old_CURR_DETAILS_tbl        QP_Currency_PUB.Curr_Details_Tbl_Type;

l_p_CURR_LISTS_rec            QP_Currency_PUB.Curr_Lists_Rec_Type; --[prarasto]
l_p_old_CURR_LISTS_rec	      QP_Currency_PUB.Curr_Lists_Rec_Type; --[prarasto]
l_p_CURR_DETAILS_tbl	      QP_Currency_PUB.Curr_Details_Tbl_Type;     --[prarasto]
l_p_old_CURR_DETAILS_tbl      QP_Currency_PUB.Curr_Details_Tbl_Type; --[prarasto]

BEGIN

    -- oe_debug_pub.add('@#@#@Inside Process_Currency V');
    --  Standard call to check for call compatibility
    -- oe_debug_pub.add('Markup Value: '||l_CURR_LISTS_rec.base_markup_value);
    -- oe_debug_pub.add('Description: '||l_CURR_LISTS_rec.description);

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

    l_CURR_DETAILS_tbl             := p_CURR_DETAILS_tbl;
    l_old_CURR_DETAILS_tbl         := p_old_CURR_DETAILS_tbl;

    --  Curr_Lists
    -- oe_debug_pub.add('**BEFORE CALLING CURR_LIST Header_id :'||l_CURR_LISTS_rec.currency_header_id);
    -- oe_debug_pub.add('**BEFORE CALLING CURR_LIST Base_Currency_Code :'||l_CURR_LISTS_rec.base_currency_code);
    -- oe_debug_pub.add('Calling  CURR_LISTS from Process_Currency of V package');

    l_p_CURR_LISTS_rec		:= l_CURR_LISTS_rec;     --[prarasto]
    l_p_old_CURR_LISTS_rec	:= l_old_CURR_LISTS_rec; --[prarasto]

    Curr_Lists
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_CURR_LISTS_rec              => l_p_CURR_LISTS_rec
    ,   p_old_CURR_LISTS_rec          => l_p_old_CURR_LISTS_rec
    ,   x_CURR_LISTS_rec              => l_CURR_LISTS_rec
    ,   x_old_CURR_LISTS_rec          => l_old_CURR_LISTS_rec
    );

    -- oe_debug_pub.add('**AFTER CALLING CURR_LIST Header_id :'||l_CURR_LISTS_rec.currency_header_id);
    -- oe_debug_pub.add('**AFTER CALLING CURR_LIST Base_Currency_Code :'||l_CURR_LISTS_rec.base_currency_code);
    -- oe_debug_pub.add('** AFTER  CALLING CURR_LIST Markup Value: '||l_CURR_LISTS_rec.base_markup_value);

    --  Perform CURR_LISTS group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_CURR_LISTS)
    THEN

        NULL;

    END IF;

    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_CURR_DETAILS_tbl.COUNT LOOP

        l_CURR_DETAILS_rec := l_CURR_DETAILS_tbl(I);

        IF l_CURR_DETAILS_rec.operation = QP_GLOBALS.G_OPR_CREATE
        AND (l_CURR_DETAILS_rec.currency_header_id IS NULL OR
            l_CURR_DETAILS_rec.currency_header_id = FND_API.G_MISS_NUM)
        THEN

            --  Copy parent_id.

            l_CURR_DETAILS_tbl(I).currency_header_id := l_CURR_LISTS_rec.currency_header_id;
            --oe_debug_pub.add('##**Header_id :'||l_CURR_LISTS_rec.currency_header_id);
        END IF;
    END LOOP;

    --  Curr_Detailss

    l_p_CURR_DETAILS_tbl	:= l_CURR_DETAILS_tbl;     --[prarasto]
    l_p_old_CURR_DETAILS_tbl	:= l_old_CURR_DETAILS_tbl; --[prarasto]

    Curr_Detailss
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_CURR_DETAILS_tbl            => l_p_CURR_DETAILS_tbl
    ,   p_old_CURR_DETAILS_tbl        => l_p_old_CURR_DETAILS_tbl
    ,   x_CURR_DETAILS_tbl            => l_CURR_DETAILS_tbl
    ,   x_old_CURR_DETAILS_tbl        => l_old_CURR_DETAILS_tbl
    );

    --  Perform CURR_DETAILS group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_CURR_DETAILS)
    THEN

       QP_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => QP_GLOBALS.G_ENTITY_CURR_DETAILS
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;

    --  Step 6. Perform Object group logic

    IF p_control_rec.process AND
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL
    THEN

        NULL;

    END IF;

    --  Done processing, load OUT parameters.

    x_CURR_LISTS_rec               := l_CURR_LISTS_rec;
    x_CURR_DETAILS_tbl             := l_CURR_DETAILS_tbl;

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

    IF l_CURR_LISTS_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    FOR I IN 1..l_CURR_DETAILS_tbl.COUNT LOOP

        IF l_CURR_DETAILS_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
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
            ,   'Process_Currency'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Currency;

--  Start of Comments
--  API name    Lock_Currency
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

PROCEDURE Lock_Currency
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_LISTS_REC
,   p_CURR_DETAILS_tbl              IN  QP_Currency_PUB.Curr_Details_Tbl_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_DETAILS_TBL
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Lists_Rec_Type
,   x_CURR_DETAILS_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Details_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Currency';
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_CURR_DETAILS_rec            QP_Currency_PUB.Curr_Details_Rec_Type;
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

    SAVEPOINT Lock_Currency_PVT;

    --  Lock CURR_LISTS

    -- oe_debug_pub.add('Inside QPXFCURB Lock_Row; p_CURR_LISTS_rec.operation: '||p_CURR_LISTS_rec.operation);

    IF p_CURR_LISTS_rec.operation = QP_GLOBALS.G_OPR_LOCK THEN

        QP_Curr_Lists_Util.Lock_Row
        (   p_CURR_LISTS_rec              => p_CURR_LISTS_rec
        ,   x_CURR_LISTS_rec              => x_CURR_LISTS_rec
        ,   x_return_status               => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    END IF;

    --  Lock CURR_DETAILS

    FOR I IN 1..p_CURR_DETAILS_tbl.COUNT LOOP

        IF p_CURR_DETAILS_tbl(I).operation = QP_GLOBALS.G_OPR_LOCK THEN

            QP_Curr_Details_Util.Lock_Row
            (   p_CURR_DETAILS_rec            => p_CURR_DETAILS_tbl(I)
            ,   x_CURR_DETAILS_rec            => l_CURR_DETAILS_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_CURR_DETAILS_tbl(I)          := l_CURR_DETAILS_rec;

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

        ROLLBACK TO Lock_Currency_PVT;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Currency_PVT;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Currency'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Currency_PVT;

END Lock_Currency;

--  Start of Comments
--  API name    Get_Currency
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

PROCEDURE Get_Currency
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_currency_header_id            IN  NUMBER
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Lists_Rec_Type
,   x_CURR_DETAILS_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Currency_PUB.Curr_Details_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Currency';
l_CURR_LISTS_rec              QP_Currency_PUB.Curr_Lists_Rec_Type;
l_CURR_DETAILS_tbl            QP_Currency_PUB.Curr_Details_Tbl_Type;
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

    --  Get CURR_LISTS ( parent = CURR_LISTS )

    l_CURR_LISTS_rec :=  QP_Curr_Lists_Util.Query_Row
    (   p_currency_header_id  => p_currency_header_id
    );

        --  Get CURR_DETAILS ( parent = CURR_LISTS )

        l_CURR_DETAILS_tbl :=  QP_Curr_Details_Util.Query_Rows
        (   p_currency_header_id    => l_CURR_LISTS_rec.currency_header_id
        );


    --  Load out parameters

    x_CURR_LISTS_rec               := l_CURR_LISTS_rec;
    x_CURR_DETAILS_tbl             := l_CURR_DETAILS_tbl;

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
            ,   'Get_Currency'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Currency;

END QP_Currency_PVT;

/
