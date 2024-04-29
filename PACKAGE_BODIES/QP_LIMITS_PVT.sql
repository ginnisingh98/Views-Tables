--------------------------------------------------------
--  DDL for Package Body QP_LIMITS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_LIMITS_PVT" AS
/* $Header: QPXVLMTB.pls 120.3 2005/10/03 07:28:10 prarasto ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Limits_PVT';

--  Limits

PROCEDURE Limits
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
,   p_old_LIMITS_rec                IN  QP_Limits_PUB.Limits_Rec_Type
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limits_Rec_Type
,   x_old_LIMITS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limits_Rec_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_LIMITS_rec                  QP_Limits_PUB.Limits_Rec_Type := p_LIMITS_rec;
l_old_LIMITS_rec              QP_Limits_PUB.Limits_Rec_Type := p_old_LIMITS_rec;

l_p_LIMITS_rec		      QP_Limits_PUB.Limits_Rec_Type; --[prarasto]

BEGIN

    --  Load API control record

    l_control_rec := QP_GLOBALS.Init_Control_Rec
    (   p_operation     => l_LIMITS_rec.operation
    ,   p_control_rec   => p_control_rec
    );

    --  Set record return status.

    l_LIMITS_rec.return_status     := FND_API.G_RET_STS_SUCCESS;

    --  Prepare record.

    IF l_LIMITS_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

        l_LIMITS_rec.db_flag := FND_API.G_FALSE;

        --  Set missing old record elements to NULL.

        l_old_LIMITS_rec :=
        QP_Limits_Util.Convert_Miss_To_Null (l_old_LIMITS_rec);

    ELSIF l_LIMITS_rec.operation = QP_GLOBALS.G_OPR_UPDATE
    OR    l_LIMITS_rec.operation = QP_GLOBALS.G_OPR_DELETE
    THEN

        l_LIMITS_rec.db_flag := FND_API.G_TRUE;

        --  Query Old if missing

        IF  l_old_LIMITS_rec.limit_id = FND_API.G_MISS_NUM
        THEN

            l_old_LIMITS_rec := QP_Limits_Util.Query_Row
            (   p_limit_id                    => l_LIMITS_rec.limit_id
            );

        ELSE

            --  Set missing old record elements to NULL.

            l_old_LIMITS_rec :=
            QP_Limits_Util.Convert_Miss_To_Null (l_old_LIMITS_rec);

        END IF;

        --  Complete new record from old
        --dbms_output.put_line('Processing Limits - Calling QP_Limits_Util.Complete_Record ' || l_return_status);
        oe_debug_pub.add('Processing Limits - Calling QP_Limits_Util.Complete_Record ' || l_return_status);

        l_LIMITS_rec := QP_Limits_Util.Complete_Record
        (   p_LIMITS_rec                  => l_LIMITS_rec
        ,   p_old_LIMITS_rec              => l_old_LIMITS_rec
        );

    END IF;

    --  Attribute level validation.

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN
    --dbms_output.put_line('Processing Limits - Calling QP_Validate_Limits.Attributes' || l_return_status);
    oe_debug_pub.add('Processing Limits - Calling QP_Validate_Limits.Attributes' || l_return_status);
            QP_Validate_Limits.Attributes
            (   x_return_status               => l_return_status
            ,   p_LIMITS_rec                  => l_LIMITS_rec
            ,   p_old_LIMITS_rec              => l_old_LIMITS_rec
            );

    oe_debug_pub.add('Processing Limits - After QP_Validate_Limits.Attributes ' || l_return_status);
            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

    END IF;

        --  Clear dependent attributes.
    --dbms_output.put_line('Processing Limits - Calling QP_Limits_Util.Clear_Dependent_Attr' || l_return_status);
    oe_debug_pub.add('Processing Limits - Calling QP_Limits_Util.Clear_Dependent_Attr' || l_return_status);
    IF  l_control_rec.change_attributes THEN

	l_p_LIMITS_rec	:= l_LIMITS_rec; --[prarasto]

        QP_Limits_Util.Clear_Dependent_Attr
        (   p_LIMITS_rec                  => l_p_LIMITS_rec
        ,   p_old_LIMITS_rec              => l_old_LIMITS_rec
        ,   x_LIMITS_rec                  => l_LIMITS_rec
        );

    END IF;

    --  Default missing attributes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN
    --dbms_output.put_line('Limit ID Before calling Default Package ' || l_LIMITS_rec.limit_id);
    oe_debug_pub.add('Limit ID Before calling Default Package ' || l_LIMITS_rec.limit_id);
    --dbms_output.put_line('Processing Limits - Calling QP_Default_Limits.Attributes' || l_return_status);
    oe_debug_pub.add('Processing Limits - Calling QP_Default_Limits.Attributes' || l_return_status);
        IF l_LIMITS_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

	l_p_LIMITS_rec	:= l_LIMITS_rec; --[prarasto]

           QP_Default_Limits.Attributes
           (   p_LIMITS_rec                  => l_p_LIMITS_rec
           ,   x_LIMITS_rec                  => l_LIMITS_rec
           );
        END IF;
    --dbms_output.put_line('Limit ID After calling Default Package ' || l_LIMITS_rec.limit_id);
    oe_debug_pub.add('Limit ID After calling Default Package ' || l_LIMITS_rec.limit_id);

    END IF;

    --  Apply attribute changes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN
    --dbms_output.put_line('Processing Limits - Calling QP_Limits_Util.Apply_Attribute_Changes' || l_return_status);
    oe_debug_pub.add('Processing Limits - Calling QP_Limits_Util.Apply_Attribute_Changes' || l_return_status);

	l_p_LIMITS_rec	:= l_LIMITS_rec; --[prarasto]

        QP_Limits_Util.Apply_Attribute_Changes
        (   p_LIMITS_rec                  => l_p_LIMITS_rec
        ,   p_old_LIMITS_rec              => l_old_LIMITS_rec
        ,   x_LIMITS_rec                  => l_LIMITS_rec
        );

    END IF;

    --  Entity level validation.

    IF l_control_rec.validate_entity THEN

        IF l_LIMITS_rec.operation = QP_GLOBALS.G_OPR_CREATE  OR
           l_LIMITS_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

            QP_Validate_Limits.Entity
            (   x_return_status               => l_return_status
            ,   p_LIMITS_rec                  => l_LIMITS_rec
            ,   p_old_LIMITS_rec              => l_old_LIMITS_rec
            );

        END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_LIMITS_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

            QP_Validate_Limits.Entity_Delete
            (   x_return_status               => l_return_status
            ,   p_LIMITS_rec                  => l_LIMITS_rec
            );

        ELSIF l_LIMITS_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

            QP_Validate_Limits.Entity_Update
            (   x_return_status               => l_return_status
            ,   p_LIMITS_rec                  => l_LIMITS_rec
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
    --dbms_output.put_line('Processing Limits - Calling QP_Limits_Util.PRE_WRITE_PROCESS' || l_return_status);
    oe_debug_pub.add('Processing Limits - Calling QP_Limits_Util.PRE_WRITE_PROCESS' || l_return_status);

    	l_p_LIMITS_rec  := l_LIMITS_rec; --[prarasto]

        QP_Limits_Util.PRE_WRITE_PROCESS
        ( p_LIMITS_rec      => l_p_LIMITS_rec
        , p_old_LIMITS_rec  => l_old_LIMITS_rec
        , x_LIMITS_rec      => l_LIMITS_rec
        );
    --dbms_output.put_line('Limit ID After calling PRE_WRITE_PROCESS ' || l_LIMITS_rec.limit_id);
    oe_debug_pub.add('Limit ID After calling PRE_WRITE_PROCESS ' || l_LIMITS_rec.limit_id);

    END IF;

    IF l_control_rec.write_to_db THEN

        IF l_LIMITS_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN
        --dbms_output.put_line('Processing Limits - QP_Limits_Util.Delete_Row' || l_return_status);
        oe_debug_pub.add('Processing Limits - QP_Limits_Util.Delete_Row' || l_return_status);
            QP_Limits_Util.Delete_Row
            (   p_limit_id                    => l_LIMITS_rec.limit_id
            );

        ELSE

            --  Get Who Information

            l_LIMITS_rec.last_update_date  := SYSDATE;
            l_LIMITS_rec.last_updated_by   := FND_GLOBAL.USER_ID;
            l_LIMITS_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

            IF l_LIMITS_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN
            --dbms_output.put_line('Processing Limits - QP_Limits_Util.Update_Row' || l_return_status);
            oe_debug_pub.add('Processing Limits - QP_Limits_Util.Update_Row' || l_return_status);
                QP_Limits_Util.Update_Row (l_LIMITS_rec);

            ELSIF l_LIMITS_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                l_LIMITS_rec.creation_date     := SYSDATE;
                l_LIMITS_rec.created_by        := FND_GLOBAL.USER_ID;
            --dbms_output.put_line('Processing Limits - QP_Limits_Util.Insert_Row' || l_return_status);
            oe_debug_pub.add('Processing Limits - QP_Limits_Util.Insert_Row' || l_return_status);
                QP_Limits_Util.Insert_Row (l_LIMITS_rec);

            END IF;

        END IF;

    END IF;

    --  Load OUT parameters

    x_LIMITS_rec                   := l_LIMITS_rec;
    x_old_LIMITS_rec               := l_old_LIMITS_rec;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
   --dbms_output.put_line('Processing Limits - In Exception' || l_return_status);
    oe_debug_pub.add('Processing Limits - In Exception' || l_return_status);

        l_LIMITS_rec.return_status     := FND_API.G_RET_STS_ERROR;
        x_LIMITS_rec                   := l_LIMITS_rec;
        x_old_LIMITS_rec               := l_old_LIMITS_rec;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        l_LIMITS_rec.return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
        x_LIMITS_rec                   := l_LIMITS_rec;
        x_old_LIMITS_rec               := l_old_LIMITS_rec;

        RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Limits'
            );
        END IF;

        l_LIMITS_rec.return_status     := FND_API.G_RET_STS_UNEXP_ERROR;
        x_LIMITS_rec                   := l_LIMITS_rec;
        x_old_LIMITS_rec               := l_old_LIMITS_rec;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limits;

--  Limit_Attrss

PROCEDURE Limit_Attrss
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_LIMIT_ATTRS_tbl               IN  QP_Limits_PUB.Limit_Attrs_Tbl_Type
,   p_old_LIMIT_ATTRS_tbl           IN  QP_Limits_PUB.Limit_Attrs_Tbl_Type
,   x_LIMIT_ATTRS_tbl               OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Attrs_Tbl_Type
,   x_old_LIMIT_ATTRS_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Attrs_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_LIMIT_ATTRS_rec             QP_Limits_PUB.Limit_Attrs_Rec_Type;
l_LIMIT_ATTRS_tbl             QP_Limits_PUB.Limit_Attrs_Tbl_Type;
l_old_LIMIT_ATTRS_rec         QP_Limits_PUB.Limit_Attrs_Rec_Type;
l_old_LIMIT_ATTRS_tbl         QP_Limits_PUB.Limit_Attrs_Tbl_Type;

l_p_LIMIT_ATTRS_rec	      QP_Limits_PUB.Limit_Attrs_Rec_Type; --[prarasto]
BEGIN

    --  Init local table variables.

    l_LIMIT_ATTRS_tbl              := p_LIMIT_ATTRS_tbl;
    l_old_LIMIT_ATTRS_tbl          := p_old_LIMIT_ATTRS_tbl;

    FOR I IN 1..l_LIMIT_ATTRS_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_LIMIT_ATTRS_rec := l_LIMIT_ATTRS_tbl(I);

        IF l_old_LIMIT_ATTRS_tbl.EXISTS(I) THEN
            l_old_LIMIT_ATTRS_rec := l_old_LIMIT_ATTRS_tbl(I);
        ELSE
            l_old_LIMIT_ATTRS_rec := QP_Limits_PUB.G_MISS_LIMIT_ATTRS_REC;
        END IF;

        --  Load API control record

        l_control_rec := QP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_LIMIT_ATTRS_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_LIMIT_ATTRS_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_LIMIT_ATTRS_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

            l_LIMIT_ATTRS_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_LIMIT_ATTRS_rec :=
            QP_Limit_Attrs_Util.Convert_Miss_To_Null (l_old_LIMIT_ATTRS_rec);

        ELSIF l_LIMIT_ATTRS_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        OR    l_LIMIT_ATTRS_rec.operation = QP_GLOBALS.G_OPR_DELETE
        THEN

            l_LIMIT_ATTRS_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_LIMIT_ATTRS_rec.limit_attribute_id = FND_API.G_MISS_NUM
            THEN

                l_old_LIMIT_ATTRS_rec := QP_Limit_Attrs_Util.Query_Row
                (   p_limit_attribute_id          => l_LIMIT_ATTRS_rec.limit_attribute_id
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_LIMIT_ATTRS_rec :=
                QP_Limit_Attrs_Util.Convert_Miss_To_Null (l_old_LIMIT_ATTRS_rec);

            END IF;

            --  Complete new record from old

            l_LIMIT_ATTRS_rec := QP_Limit_Attrs_Util.Complete_Record
            (   p_LIMIT_ATTRS_rec             => l_LIMIT_ATTRS_rec
            ,   p_old_LIMIT_ATTRS_rec         => l_old_LIMIT_ATTRS_rec
            );

        END IF;

        --  Attribute level validation.

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN
            --dbms_output.put_line('Processing Limit Attributes- Calling QP_Validate_Limit_Attrs.Attributes' || l_return_status);
            oe_debug_pub.add('Processing Limit Attributes- Calling QP_Validate_Limit_Attrs.Attributes' || l_return_status);

                QP_Validate_Limit_Attrs.Attributes
                (   x_return_status               => l_return_status
                ,   p_LIMIT_ATTRS_rec             => l_LIMIT_ATTRS_rec
                ,   p_old_LIMIT_ATTRS_rec         => l_old_LIMIT_ATTRS_rec
                );

            --dbms_output.put_line('Processing Limit Attributes- After QP_Validate_Limit_Attrs.Attributes' || l_return_status);
           oe_debug_pub.add('Processing Limit Attributes- After QP_Validate_Limit_Attrs.Attributes' || l_return_status);
                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;

        END IF;

            --  Clear dependent attributes.

        IF  l_control_rec.change_attributes THEN

	    l_p_LIMIT_ATTRS_rec	:= l_LIMIT_ATTRS_rec; --[prarasto]

            QP_Limit_Attrs_Util.Clear_Dependent_Attr
            (   p_LIMIT_ATTRS_rec             => l_p_LIMIT_ATTRS_rec
            ,   p_old_LIMIT_ATTRS_rec         => l_old_LIMIT_ATTRS_rec
            ,   x_LIMIT_ATTRS_rec             => l_LIMIT_ATTRS_rec
            );

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF l_LIMIT_ATTRS_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

	       l_p_LIMIT_ATTRS_rec	:= l_LIMIT_ATTRS_rec; --[prarasto]

               QP_Default_Limit_Attrs.Attributes
               (   p_LIMIT_ATTRS_rec             => l_p_LIMIT_ATTRS_rec
               ,   x_LIMIT_ATTRS_rec             => l_LIMIT_ATTRS_rec
               );
            END IF;

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            --dbms_output.put_line('Processing Limit Attributes- Calling QP_Limit_Attrs_Util.Apply_Attribute_Changes' || l_return_status);
            oe_debug_pub.add('Processing Limit Attributes- Calling QP_Limit_Attrs_Util.Apply_Attribute_Changes' || l_return_status);

	    l_p_LIMIT_ATTRS_rec	:= l_LIMIT_ATTRS_rec; --[prarasto]

            QP_Limit_Attrs_Util.Apply_Attribute_Changes
            (   p_LIMIT_ATTRS_rec             => l_p_LIMIT_ATTRS_rec
            ,   p_old_LIMIT_ATTRS_rec         => l_old_LIMIT_ATTRS_rec
            ,   x_LIMIT_ATTRS_rec             => l_LIMIT_ATTRS_rec
            );

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_LIMIT_ATTRS_rec.operation = QP_GLOBALS.G_OPR_CREATE OR
               l_LIMIT_ATTRS_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

            --dbms_output.put_line('Processing Limit Attributes- Calling QP_Validate_Limit_Attrs.Entity' || l_return_status);
            oe_debug_pub.add('Processing Limit Attributes- Calling QP_Validate_Limit_Attrs.Entity' || l_return_status);
                QP_Validate_Limit_Attrs.Entity
                (   x_return_status               => l_return_status
                ,   p_LIMIT_ATTRS_rec             => l_LIMIT_ATTRS_rec
                ,   p_old_LIMIT_ATTRS_rec         => l_old_LIMIT_ATTRS_rec
                );

            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            --dbms_output.put_line('Processing Limit Attributes- After QP_Validate_Limit_Attrs.Entity' || l_return_status);
            IF l_LIMIT_ATTRS_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                QP_Validate_Limit_Attrs.Entity_Insert
                (   x_return_status               => l_return_status
                ,   p_LIMIT_ATTRS_rec             => l_LIMIT_ATTRS_rec
                );

            ELSIF l_LIMIT_ATTRS_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Validate_Limit_Attrs.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_LIMIT_ATTRS_rec             => l_LIMIT_ATTRS_rec
                );

            ELSIF l_LIMIT_ATTRS_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                QP_Validate_Limit_Attrs.Entity_Update
                (   x_return_status               => l_return_status
                ,   p_LIMIT_ATTRS_rec             => l_LIMIT_ATTRS_rec
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

            --dbms_output.put_line('Processing Limit Attributes- Calling QP_Limit_Attrs_Util.PRE_WRITE_PROCESS' || l_return_status);
            oe_debug_pub.add('Processing Limit Attributes- Calling QP_Limit_Attrs_Util.PRE_WRITE_PROCESS' || l_return_status);
	    l_p_LIMIT_ATTRS_rec	:= l_LIMIT_ATTRS_rec; --[prarasto]

            QP_Limit_Attrs_Util.PRE_WRITE_PROCESS
            ( p_LIMIT_ATTRS_rec      => l_p_LIMIT_ATTRS_rec
            , p_old_LIMIT_ATTRS_rec  => l_old_LIMIT_ATTRS_rec
            , x_LIMIT_ATTRS_rec      => l_LIMIT_ATTRS_rec
            );

        END IF;

        IF l_control_rec.write_to_db THEN

            IF l_LIMIT_ATTRS_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Limit_Attrs_Util.Delete_Row
                (   p_limit_attribute_id          => l_LIMIT_ATTRS_rec.limit_attribute_id
                );

            ELSE

                --  Get Who Information

                l_LIMIT_ATTRS_rec.last_update_date := SYSDATE;
                l_LIMIT_ATTRS_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_LIMIT_ATTRS_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_LIMIT_ATTRS_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                    QP_Limit_Attrs_Util.Update_Row (l_LIMIT_ATTRS_rec);

                ELSIF l_LIMIT_ATTRS_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                    l_LIMIT_ATTRS_rec.creation_date := SYSDATE;
                    l_LIMIT_ATTRS_rec.created_by   := FND_GLOBAL.USER_ID;

            --dbms_output.put_line('Processing Limit Attributes- Calling QP_Limit_Attrs_Util.Insert_Row' || l_return_status);
            oe_debug_pub.add('Processing Limit Attributes- Calling QP_Limit_Attrs_Util.Insert_Row' || l_return_status);
                    QP_Limit_Attrs_Util.Insert_Row (l_LIMIT_ATTRS_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        l_LIMIT_ATTRS_tbl(I)           := l_LIMIT_ATTRS_rec;
        l_old_LIMIT_ATTRS_tbl(I)       := l_old_LIMIT_ATTRS_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            --dbms_output.put_line('Processing Limit Attributes- In Exception' || l_return_status);
            oe_debug_pub.add('Processing Limit Attributes- In Exception' || l_return_status);
            l_LIMIT_ATTRS_rec.return_status := FND_API.G_RET_STS_ERROR;
            l_LIMIT_ATTRS_tbl(I)           := l_LIMIT_ATTRS_rec;
            l_old_LIMIT_ATTRS_tbl(I)       := l_old_LIMIT_ATTRS_rec;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_LIMIT_ATTRS_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_LIMIT_ATTRS_tbl(I)           := l_LIMIT_ATTRS_rec;
            l_old_LIMIT_ATTRS_tbl(I)       := l_old_LIMIT_ATTRS_rec;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_LIMIT_ATTRS_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_LIMIT_ATTRS_tbl(I)           := l_LIMIT_ATTRS_rec;
            l_old_LIMIT_ATTRS_tbl(I)       := l_old_LIMIT_ATTRS_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Limit_Attrss'
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_LIMIT_ATTRS_tbl              := l_LIMIT_ATTRS_tbl;
    x_old_LIMIT_ATTRS_tbl          := l_old_LIMIT_ATTRS_tbl;

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
            ,   'Limit_Attrss'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limit_Attrss;

--  Limit_Balancess

PROCEDURE Limit_Balancess
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type
,   p_LIMIT_BALANCES_tbl            IN  QP_Limits_PUB.Limit_Balances_Tbl_Type
,   p_old_LIMIT_BALANCES_tbl        IN  QP_Limits_PUB.Limit_Balances_Tbl_Type
,   x_LIMIT_BALANCES_tbl            OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Balances_Tbl_Type
,   x_old_LIMIT_BALANCES_tbl        OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Balances_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_LIMIT_BALANCES_rec          QP_Limits_PUB.Limit_Balances_Rec_Type;
l_LIMIT_BALANCES_tbl          QP_Limits_PUB.Limit_Balances_Tbl_Type;
l_old_LIMIT_BALANCES_rec      QP_Limits_PUB.Limit_Balances_Rec_Type;
l_old_LIMIT_BALANCES_tbl      QP_Limits_PUB.Limit_Balances_Tbl_Type;

l_p_LIMIT_BALANCES_rec	      QP_Limits_PUB.Limit_Balances_Rec_Type; --[prarasto]
BEGIN

    --  Init local table variables.

    l_LIMIT_BALANCES_tbl           := p_LIMIT_BALANCES_tbl;
    l_old_LIMIT_BALANCES_tbl       := p_old_LIMIT_BALANCES_tbl;

            --dbms_output.put_line('Inside Limit Balances -  ' || l_return_status);
            oe_debug_pub.add('Inside Limit Balances -  ' || l_return_status);
    FOR I IN 1..l_LIMIT_BALANCES_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_LIMIT_BALANCES_rec := l_LIMIT_BALANCES_tbl(I);

        IF l_old_LIMIT_BALANCES_tbl.EXISTS(I) THEN
            l_old_LIMIT_BALANCES_rec := l_old_LIMIT_BALANCES_tbl(I);
        ELSE
            l_old_LIMIT_BALANCES_rec := QP_Limits_PUB.G_MISS_LIMIT_BALANCES_REC;
        END IF;

        --  Load API control record

        l_control_rec := QP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_LIMIT_BALANCES_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

            --dbms_output.put_line('Inside Limit Balances 1-  ' || l_return_status);
            oe_debug_pub.add('Inside Limit Balances 1-  ' || l_return_status);
        l_LIMIT_BALANCES_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_LIMIT_BALANCES_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

            l_LIMIT_BALANCES_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_LIMIT_BALANCES_rec :=
            QP_Limit_Balances_Util.Convert_Miss_To_Null (l_old_LIMIT_BALANCES_rec);

        ELSIF l_LIMIT_BALANCES_rec.operation = QP_GLOBALS.G_OPR_UPDATE
        OR    l_LIMIT_BALANCES_rec.operation = QP_GLOBALS.G_OPR_DELETE
        THEN

            l_LIMIT_BALANCES_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_LIMIT_BALANCES_rec.limit_balance_id = FND_API.G_MISS_NUM
            THEN

                l_old_LIMIT_BALANCES_rec := QP_Limit_Balances_Util.Query_Row
                (   p_limit_balance_id            => l_LIMIT_BALANCES_rec.limit_balance_id
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_LIMIT_BALANCES_rec :=
                QP_Limit_Balances_Util.Convert_Miss_To_Null (l_old_LIMIT_BALANCES_rec);

            END IF;

            --  Complete new record from old

            --dbms_output.put_line('Processing Limit Balances - Calling QP_Limit_Balances_Util.Complete_Record ' || l_return_status);
            oe_debug_pub.add('Processing Limit Balances - Calling QP_Limit_Balances_Util.Complete_Record ' || l_return_status);
            l_LIMIT_BALANCES_rec := QP_Limit_Balances_Util.Complete_Record
            (   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
            ,   p_old_LIMIT_BALANCES_rec      => l_old_LIMIT_BALANCES_rec
            );

        END IF;

        --  Attribute level validation.

            --dbms_output.put_line('Inside Limit Balances 2-  ' || l_return_status);
            oe_debug_pub.add('Inside Limit Balances 2-  ' || l_return_status);
        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

            --dbms_output.put_line('Processing Limit Balances - Calling QP_Validate_Limit_Balances.Attributes ' || l_return_status);
            oe_debug_pub.add('Processing Limit Balances - Calling QP_Validate_Limit_Balances.Attributes ' || l_return_status);
                QP_Validate_Limit_Balances.Attributes
                (   x_return_status               => l_return_status
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   p_old_LIMIT_BALANCES_rec      => l_old_LIMIT_BALANCES_rec
                );

            --dbms_output.put_line('Processing Limit Balances - After QP_Validate_Limit_Balances.Attributes ' || l_return_status);
            oe_debug_pub.add('Processing Limit Balances - After QP_Validate_Limit_Balances.Attributes ' || l_return_status);
                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;

        END IF;

            --  Clear dependent attributes.

        IF  l_control_rec.change_attributes THEN

            --dbms_output.put_line('Processing Limit Balances - Calling QP_Limit_Balances_Util.Clear_Dependent_Attr ' || l_return_status);
            oe_debug_pub.add('Processing Limit Balances - Calling QP_Limit_Balances_Util.Clear_Dependent_Attr ' || l_return_status);

	    l_p_LIMIT_BALANCES_rec	:= l_LIMIT_BALANCES_rec; --[prarasto]

            QP_Limit_Balances_Util.Clear_Dependent_Attr
            (   p_LIMIT_BALANCES_rec          => l_p_LIMIT_BALANCES_rec
            ,   p_old_LIMIT_BALANCES_rec      => l_old_LIMIT_BALANCES_rec
            ,   x_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
            );

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            --dbms_output.put_line('Processing Limit Balances - Calling QP_Default_Limit_Balances.Attributes ' || l_return_status);
            oe_debug_pub.add('Processing Limit Balances - Calling QP_Default_Limit_Balances.Attributes ' || l_return_status);
            IF l_LIMIT_BALANCES_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

               l_p_LIMIT_BALANCES_rec	:= l_LIMIT_BALANCES_rec; --[prarasto]

               QP_Default_Limit_Balances.Attributes
               (   p_LIMIT_BALANCES_rec          => l_p_LIMIT_BALANCES_rec
               ,   x_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
               );
            END IF;

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            --dbms_output.put_line('Processing Limit Balances - Calling QP_Limit_Balances_Util.Apply_Attribute_Changes ' || l_return_status);
            oe_debug_pub.add('Processing Limit Balances - Calling QP_Limit_Balances_Util.Apply_Attribute_Changes ' || l_return_status);

            l_p_LIMIT_BALANCES_rec	:= l_LIMIT_BALANCES_rec; --[prarasto]

            QP_Limit_Balances_Util.Apply_Attribute_Changes
            (   p_LIMIT_BALANCES_rec          => l_p_LIMIT_BALANCES_rec
            ,   p_old_LIMIT_BALANCES_rec      => l_old_LIMIT_BALANCES_rec
            ,   x_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
            );

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_LIMIT_BALANCES_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Validate_Limit_Balances.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                );

            ELSE

                QP_Validate_Limit_Balances.Entity
                (   x_return_status               => l_return_status
                ,   p_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
                ,   p_old_LIMIT_BALANCES_rec      => l_old_LIMIT_BALANCES_rec
                );

            END IF;

            --dbms_output.put_line('Processing Limit Balances - After QP_Validate_Limit_Balances.Entity ' || l_return_status);
            oe_debug_pub.add('Processing Limit Balances - After QP_Validate_Limit_Balances.Entity ' || l_return_status);
            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

        --  Step 4. Write to DB

            --dbms_output.put_line('Processing Limit Balances - At write_to_db ' || l_return_status);
            oe_debug_pub.add('Processing Limit Balances - At write_to_db ' || l_return_status);
        IF l_control_rec.write_to_db THEN

            IF l_LIMIT_BALANCES_rec.operation = QP_GLOBALS.G_OPR_DELETE THEN

                QP_Limit_Balances_Util.Delete_Row
                (   p_limit_balance_id            => l_LIMIT_BALANCES_rec.limit_balance_id
                );

            ELSE

                --  Get Who Information

                l_LIMIT_BALANCES_rec.last_update_date := SYSDATE;
                l_LIMIT_BALANCES_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_LIMIT_BALANCES_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_LIMIT_BALANCES_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN

                    QP_Limit_Balances_Util.Update_Row (l_LIMIT_BALANCES_rec);

                ELSIF l_LIMIT_BALANCES_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN

                    l_LIMIT_BALANCES_rec.creation_date := SYSDATE;
                    l_LIMIT_BALANCES_rec.created_by := FND_GLOBAL.USER_ID;

            --dbms_output.put_line('Processing Limit Balances - Calling QP_Limit_Balances_Util.Insert_Row ' || l_return_status);
            oe_debug_pub.add('Processing Limit Balances - Calling QP_Limit_Balances_Util.Insert_Row ' || l_return_status);
                    QP_Limit_Balances_Util.Insert_Row (l_LIMIT_BALANCES_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        l_LIMIT_BALANCES_tbl(I)        := l_LIMIT_BALANCES_rec;
        l_old_LIMIT_BALANCES_tbl(I)    := l_old_LIMIT_BALANCES_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_LIMIT_BALANCES_rec.return_status := FND_API.G_RET_STS_ERROR;
            l_LIMIT_BALANCES_tbl(I)        := l_LIMIT_BALANCES_rec;
            l_old_LIMIT_BALANCES_tbl(I)    := l_old_LIMIT_BALANCES_rec;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_LIMIT_BALANCES_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_LIMIT_BALANCES_tbl(I)        := l_LIMIT_BALANCES_rec;
            l_old_LIMIT_BALANCES_tbl(I)    := l_old_LIMIT_BALANCES_rec;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_LIMIT_BALANCES_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_LIMIT_BALANCES_tbl(I)        := l_LIMIT_BALANCES_rec;
            l_old_LIMIT_BALANCES_tbl(I)    := l_old_LIMIT_BALANCES_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Limit_Balancess'
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_LIMIT_BALANCES_tbl           := l_LIMIT_BALANCES_tbl;
    x_old_LIMIT_BALANCES_tbl       := l_old_LIMIT_BALANCES_tbl;

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
            ,   'Limit_Balancess'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Limit_Balancess;


--  Start of Comments
--  API name    Process_Limits
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

PROCEDURE Process_Limits
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  QP_GLOBALS.Control_Rec_Type :=
                                        QP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMITS_REC
,   p_old_LIMITS_rec                IN  QP_Limits_PUB.Limits_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMITS_REC
,   p_LIMIT_ATTRS_tbl               IN  QP_Limits_PUB.Limit_Attrs_Tbl_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_ATTRS_TBL
,   p_old_LIMIT_ATTRS_tbl           IN  QP_Limits_PUB.Limit_Attrs_Tbl_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_ATTRS_TBL
,   p_LIMIT_BALANCES_tbl            IN  QP_Limits_PUB.Limit_Balances_Tbl_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_BALANCES_TBL
,   p_old_LIMIT_BALANCES_tbl        IN  QP_Limits_PUB.Limit_Balances_Tbl_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_BALANCES_TBL
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limits_Rec_Type
,   x_LIMIT_ATTRS_tbl               OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Attrs_Tbl_Type
,   x_LIMIT_BALANCES_tbl            OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Balances_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Limits';
l_return_status               VARCHAR2(1);
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_LIMITS_rec                  QP_Limits_PUB.Limits_Rec_Type := p_LIMITS_rec;
l_old_LIMITS_rec              QP_Limits_PUB.Limits_Rec_Type := p_old_LIMITS_rec;
l_LIMIT_ATTRS_rec             QP_Limits_PUB.Limit_Attrs_Rec_Type;
l_LIMIT_ATTRS_tbl             QP_Limits_PUB.Limit_Attrs_Tbl_Type;
l_old_LIMIT_ATTRS_rec         QP_Limits_PUB.Limit_Attrs_Rec_Type;
l_old_LIMIT_ATTRS_tbl         QP_Limits_PUB.Limit_Attrs_Tbl_Type;
l_LIMIT_BALANCES_rec          QP_Limits_PUB.Limit_Balances_Rec_Type;
l_LIMIT_BALANCES_tbl          QP_Limits_PUB.Limit_Balances_Tbl_Type;
l_old_LIMIT_BALANCES_rec      QP_Limits_PUB.Limit_Balances_Rec_Type;
l_old_LIMIT_BALANCES_tbl      QP_Limits_PUB.Limit_Balances_Tbl_Type;

l_p_LIMITS_rec		      QP_Limits_PUB.Limits_Rec_Type;     --[prarasto]
l_p_old_LIMITS_rec	      QP_Limits_PUB.Limits_Rec_Type; --[prarasto]
l_p_LIMIT_ATTRS_tbl	      QP_Limits_PUB.Limit_Attrs_Tbl_Type;     --[prarasto]
l_p_old_LIMIT_ATTRS_tbl	      QP_Limits_PUB.Limit_Attrs_Tbl_Type; --[prarasto]
l_p_LIMIT_BALANCES_tbl	      QP_Limits_PUB.Limit_Balances_Tbl_Type;     --[prarasto]
l_p_old_LIMIT_BALANCES_tbl    QP_Limits_PUB.Limit_Balances_Tbl_Type; --[prarasto]

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

    l_LIMIT_ATTRS_tbl              := p_LIMIT_ATTRS_tbl;
    l_old_LIMIT_ATTRS_tbl          := p_old_LIMIT_ATTRS_tbl;

    --  Init local table variables.

    l_LIMIT_BALANCES_tbl           := p_LIMIT_BALANCES_tbl;
    l_old_LIMIT_BALANCES_tbl       := p_old_LIMIT_BALANCES_tbl;

    --  Limits
    --dbms_output.put_line('Processing Limits ' || l_return_status);
    oe_debug_pub.add('Processing Limits ' || l_return_status);

    l_p_LIMITS_rec	:= l_LIMITS_rec;     --[prarasto]
    l_p_old_LIMITS_rec	:= l_old_LIMITS_rec; --[prarasto]

    Limits
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_LIMITS_rec                  => l_p_LIMITS_rec
    ,   p_old_LIMITS_rec              => l_p_old_LIMITS_rec
    ,   x_LIMITS_rec                  => l_LIMITS_rec
    ,   x_old_LIMITS_rec              => l_old_LIMITS_rec
    );
            --dbms_output.put_line('Limit_Id' || l_LIMITS_rec.limit_id);
            oe_debug_pub.add('Limit_Id' || l_LIMITS_rec.limit_id);

    --  Perform LIMITS group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_LIMITS)
    THEN

        NULL;

    END IF;
    IF p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_LIMITS
    THEN

        oe_debug_pub.add('Calling QP_DELAYED_REQESTS_PVT.Process_Delayed_Requests');
        -- FOR ATTR_EACH_EXISTS , NON_EACH_ATTR_COUNT , TOTAL_ATTR_COUNT
        QP_DELAYED_REQUESTS_PVT.Process_Delayed_Requests
           (
             x_return_status => l_return_status
           );
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_LIMIT_ATTRS_tbl.COUNT LOOP

        l_LIMIT_ATTRS_rec := l_LIMIT_ATTRS_tbl(I);

            --dbms_output.put_line('XXXX Limit_ATTR_ID' || l_LIMIT_ATTRS_tbl(I).limit_id);
        IF l_LIMIT_ATTRS_rec.operation = QP_GLOBALS.G_OPR_CREATE
        AND (l_LIMIT_ATTRS_rec.limit_id IS NULL OR
            l_LIMIT_ATTRS_rec.limit_id = FND_API.G_MISS_NUM)
        THEN

            --  Copy parent_id.

            l_LIMIT_ATTRS_tbl(I).limit_id := l_LIMITS_rec.limit_id;
            --dbms_output.put_line('XXXX Limit_ATTR_ID' || l_LIMIT_ATTRS_tbl(I).limit_id);
            oe_debug_pub.add('Limit_ATTR_ID' || l_LIMIT_ATTRS_tbl(I).limit_id);
        END IF;
    END LOOP;

    --  Limit_Attrss

    --dbms_output.put_line('Processing Limit Attributes ');
    oe_debug_pub.add('Processing Limit Attributes ');

    l_p_LIMIT_ATTRS_tbl		:= l_LIMIT_ATTRS_tbl;     --[prarasto]
    l_p_old_LIMIT_ATTRS_tbl	:= l_old_LIMIT_ATTRS_tbl; --[prarasto]

    Limit_Attrss
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_LIMIT_ATTRS_tbl             => l_p_LIMIT_ATTRS_tbl
    ,   p_old_LIMIT_ATTRS_tbl         => l_p_old_LIMIT_ATTRS_tbl
    ,   x_LIMIT_ATTRS_tbl             => l_LIMIT_ATTRS_tbl
    ,   x_old_LIMIT_ATTRS_tbl         => l_old_LIMIT_ATTRS_tbl
    );

    --  Perform LIMIT_ATTRS group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_LIMIT_ATTRS)
    THEN

        NULL;

    END IF;

    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_LIMIT_BALANCES_tbl.COUNT LOOP

        l_LIMIT_BALANCES_rec := l_LIMIT_BALANCES_tbl(I);

        IF l_LIMIT_BALANCES_rec.operation = QP_GLOBALS.G_OPR_CREATE
        AND (l_LIMIT_BALANCES_rec.limit_id IS NULL OR
            l_LIMIT_BALANCES_rec.limit_id = FND_API.G_MISS_NUM)
        THEN

            --  Copy parent_id.

            l_LIMIT_BALANCES_tbl(I).limit_id := l_LIMITS_rec.limit_id;
            --dbms_output.put_line('Limit_BAL_Id' || l_LIMIT_BALANCES_tbl(I).limit_id);
            oe_debug_pub.add('Limit_BAL_Id' || l_LIMIT_BALANCES_tbl(I).limit_id);
        END IF;
    END LOOP;

    --  Limit_Balancess

    --dbms_output.put_line('Processing Limit Balances ');
    oe_debug_pub.add('Processing Limit Balances ');

    l_p_LIMIT_BALANCES_tbl	:= l_LIMIT_BALANCES_tbl;     --[prarasto]
    l_p_old_LIMIT_BALANCES_tbl	:= l_old_LIMIT_BALANCES_tbl; --[prarasto]

    Limit_Balancess
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_LIMIT_BALANCES_tbl          => l_p_LIMIT_BALANCES_tbl
    ,   p_old_LIMIT_BALANCES_tbl      => l_p_old_LIMIT_BALANCES_tbl
    ,   x_LIMIT_BALANCES_tbl          => l_LIMIT_BALANCES_tbl
    ,   x_old_LIMIT_BALANCES_tbl      => l_old_LIMIT_BALANCES_tbl
    );

    --  Perform LIMIT_BALANCES group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_LIMIT_BALANCES)
    THEN

        NULL;

    END IF;


    --  Step 5. Perform Object group logic

    IF p_control_rec.process AND
        p_control_rec.process_entity = QP_GLOBALS.G_ENTITY_ALL
    THEN
-- FOR ATTR_EACH_EXISTS , NON_EACH_ATTR_COUNT , TOTAL_ATTR_COUNT
         QP_DELAYED_REQUESTS_PVT.Process_Delayed_Requests
            (
              x_return_status => l_return_status
            );
         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
         END IF;
         NULL;

    END IF;

    --  Done processing, load OUT parameters.

    x_LIMITS_rec                   := l_LIMITS_rec;
    x_LIMIT_ATTRS_tbl              := l_LIMIT_ATTRS_tbl;
    x_LIMIT_BALANCES_tbl           := l_LIMIT_BALANCES_tbl;

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

    IF l_LIMITS_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    FOR I IN 1..l_LIMIT_ATTRS_tbl.COUNT LOOP

        IF l_LIMIT_ATTRS_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END LOOP;

    FOR I IN 1..l_LIMIT_BALANCES_tbl.COUNT LOOP

        IF l_LIMIT_BALANCES_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
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

     --dbms_output.put_line('Proc Limits - EXCEPTION x_msg_count' || x_msg_count);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
     --dbms_output.put_line('Proc Limits - EXCEPTION x_msg_count' || x_msg_count);

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Limits'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
     --dbms_output.put_line('Proc Limits - EXCEPTION x_msg_count' || x_msg_count);

END Process_Limits;

--  Start of Comments
--  API name    Lock_Limits
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

PROCEDURE Lock_Limits
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMITS_REC
,   p_LIMIT_ATTRS_tbl               IN  QP_Limits_PUB.Limit_Attrs_Tbl_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_ATTRS_TBL
,   p_LIMIT_BALANCES_tbl            IN  QP_Limits_PUB.Limit_Balances_Tbl_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_BALANCES_TBL
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limits_Rec_Type
,   x_LIMIT_ATTRS_tbl               OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Attrs_Tbl_Type
,   x_LIMIT_BALANCES_tbl            OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Balances_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Limits';
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_LIMIT_ATTRS_rec             QP_Limits_PUB.Limit_Attrs_Rec_Type;
l_LIMIT_BALANCES_rec          QP_Limits_PUB.Limit_Balances_Rec_Type;
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

    SAVEPOINT Lock_Limits_PVT;

    --  Lock LIMITS

    IF p_LIMITS_rec.operation = QP_GLOBALS.G_OPR_LOCK THEN

        QP_Limits_Util.Lock_Row
        (   p_LIMITS_rec                  => p_LIMITS_rec
        ,   x_LIMITS_rec                  => x_LIMITS_rec
        ,   x_return_status               => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    END IF;

    --  Lock LIMIT_ATTRS

    FOR I IN 1..p_LIMIT_ATTRS_tbl.COUNT LOOP

        IF p_LIMIT_ATTRS_tbl(I).operation = QP_GLOBALS.G_OPR_LOCK THEN

            QP_Limit_Attrs_Util.Lock_Row
            (   p_LIMIT_ATTRS_rec             => p_LIMIT_ATTRS_tbl(I)
            ,   x_LIMIT_ATTRS_rec             => l_LIMIT_ATTRS_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_LIMIT_ATTRS_tbl(I)           := l_LIMIT_ATTRS_rec;

        END IF;

    END LOOP;

    --  Lock LIMIT_BALANCES

    FOR I IN 1..p_LIMIT_BALANCES_tbl.COUNT LOOP

        IF p_LIMIT_BALANCES_tbl(I).operation = QP_GLOBALS.G_OPR_LOCK THEN

            QP_Limit_Balances_Util.Lock_Row
            (   p_LIMIT_BALANCES_rec          => p_LIMIT_BALANCES_tbl(I)
            ,   x_LIMIT_BALANCES_rec          => l_LIMIT_BALANCES_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_LIMIT_BALANCES_tbl(I)        := l_LIMIT_BALANCES_rec;

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

        ROLLBACK TO Lock_Limits_PVT;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Limits_PVT;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Limits'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Limits_PVT;

END Lock_Limits;

--  Start of Comments
--  API name    Get_Limits
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

PROCEDURE Get_Limits
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_limit_id                      IN  NUMBER
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limits_Rec_Type
,   x_LIMIT_ATTRS_tbl               OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Attrs_Tbl_Type
,   x_LIMIT_BALANCES_tbl            OUT NOCOPY /* file.sql.39 change */ QP_Limits_PUB.Limit_Balances_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Limits';
l_LIMITS_rec                  QP_Limits_PUB.Limits_Rec_Type;
l_LIMIT_ATTRS_tbl             QP_Limits_PUB.Limit_Attrs_Tbl_Type;
l_LIMIT_BALANCES_tbl          QP_Limits_PUB.Limit_Balances_Tbl_Type;
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

    --  Get LIMITS ( parent = LIMITS )

    l_LIMITS_rec :=  QP_Limits_Util.Query_Row
    (   p_limit_id            => p_limit_id
    );

        --  Get LIMIT_ATTRS ( parent = LIMITS )

        l_LIMIT_ATTRS_tbl :=  QP_Limit_Attrs_Util.Query_Rows
        (   p_limit_id              => l_LIMITS_rec.limit_id
        );


        --  Get LIMIT_BALANCES ( parent = LIMITS )

        l_LIMIT_BALANCES_tbl :=  QP_Limit_Balances_Util.Query_Rows
        (   p_limit_id              => l_LIMITS_rec.limit_id
        );


    --  Load out parameters

    x_LIMITS_rec                   := l_LIMITS_rec;
    x_LIMIT_ATTRS_tbl              := l_LIMIT_ATTRS_tbl;
    x_LIMIT_BALANCES_tbl           := l_LIMIT_BALANCES_tbl;

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
            ,   'Get_Limits'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Limits;

END QP_Limits_PVT;

/
