--------------------------------------------------------
--  DDL for Package Body MRP_SOURCING_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_SOURCING_RULE_PVT" AS
/* $Header: MRPVSRLB.pls 120.1 2006/05/25 05:25:41 atsrivas noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Sourcing_Rule_PVT';

--  Sourcing_Rule

PROCEDURE Sourcing_Rule
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  MRP_GLOBALS.Control_Rec_Type
,   p_Sourcing_Rule_rec             IN  MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
,   p_old_Sourcing_Rule_rec         IN  MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
,   x_Sourcing_Rule_rec             OUT NOCOPY MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
,   x_old_Sourcing_Rule_rec         OUT NOCOPY MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 MRP_GLOBALS.Control_Rec_Type;
l_Sourcing_Rule_rec           MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type := p_Sourcing_Rule_rec;
-- Nocopy Change
l_Sourcing_Rule_out_rec       MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type ;
l_old_Sourcing_Rule_rec       MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type := p_old_Sourcing_Rule_rec;
BEGIN

    --  Load API control record

-- dbms_output.put_line ('Oper :  ' || l_Sourcing_Rule_rec.operation);
    l_control_rec := MRP_GLOBALS.Init_Control_Rec
    (   p_operation     => l_Sourcing_Rule_rec.operation
    ,   p_control_rec   => p_control_rec
    );

    --  Set record return status.

    l_Sourcing_Rule_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  Prepare record.

    IF l_Sourcing_Rule_rec.operation = MRP_Globals.G_OPR_CREATE THEN

        l_Sourcing_Rule_rec.db_flag := FND_API.G_FALSE;

        --  Set missing old record elements to NULL.

        l_old_Sourcing_Rule_rec :=
        MRP_Sourcing_Rule_Util.Convert_Miss_To_Null (l_old_Sourcing_Rule_rec);


    ELSIF l_Sourcing_Rule_rec.operation = MRP_Globals.G_OPR_UPDATE
    OR    l_Sourcing_Rule_rec.operation = MRP_Globals.G_OPR_DELETE
    THEN

        l_Sourcing_Rule_rec.db_flag := FND_API.G_TRUE;

        --  Query Old if missing

        IF  l_old_Sourcing_Rule_rec.Sourcing_Rule_Id = FND_API.G_MISS_NUM
        THEN

            l_old_Sourcing_Rule_rec := MRP_Sourcing_Rule_Handlers.Query_Row
            (   p_Sourcing_Rule_Id            => l_Sourcing_Rule_rec.Sourcing_Rule_Id
            );

        ELSE

            --  Set missing old record elements to NULL.

            l_old_Sourcing_Rule_rec :=
            MRP_Sourcing_Rule_Util.Convert_Miss_To_Null (l_old_Sourcing_Rule_rec);

        END IF;

        --  Complete new record from old

        l_Sourcing_Rule_rec := MRP_Sourcing_Rule_Util.Complete_Record
        (   p_Sourcing_Rule_rec           => l_Sourcing_Rule_rec
        ,   p_old_Sourcing_Rule_rec       => l_old_Sourcing_Rule_rec
        );

    END IF;

    --  Attribute level validation.

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

            MRP_Validate_Sourcing_Rule.Attributes
            (   x_return_status               => l_return_status
            ,   p_Sourcing_Rule_rec           => l_Sourcing_Rule_rec
            ,   p_old_Sourcing_Rule_rec       => l_old_Sourcing_Rule_rec
            );

-- dbms_output.put_line('after attributes : ' || l_return_status);

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

    END IF;

        --  Clear dependent attributes.

    IF  l_control_rec.change_attributes THEN

        MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
        (   p_Sourcing_Rule_rec           => l_Sourcing_Rule_rec
        ,   p_old_Sourcing_Rule_rec       => l_old_Sourcing_Rule_rec
        ,   x_Sourcing_Rule_rec           => l_Sourcing_Rule_out_rec -- Nocopy Change
        );
       l_Sourcing_Rule_rec := l_Sourcing_Rule_out_rec ; -- Nocopy Change

    END IF;

    --  Default missing attributes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        MRP_Default_Sourcing_Rule.Attributes
        (   p_Sourcing_Rule_rec           => l_Sourcing_Rule_rec
        ,   x_Sourcing_Rule_rec           => l_Sourcing_Rule_out_rec -- Nocopy Change
        );
        l_Sourcing_Rule_rec := l_Sourcing_Rule_out_rec ; -- Nocopy Change

    END IF;

    --  Apply attribute changes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        MRP_Sourcing_Rule_Util.Apply_Attribute_Changes
        (   p_Sourcing_Rule_rec           => l_Sourcing_Rule_rec
        ,   p_old_Sourcing_Rule_rec       => l_old_Sourcing_Rule_rec
        ,   x_Sourcing_Rule_rec           => l_Sourcing_Rule_out_rec -- Nocopy Change
        );
       l_Sourcing_Rule_rec := l_Sourcing_Rule_out_rec ; -- Nocopy Change

    END IF;

    --  Entity level validation.

    IF l_control_rec.validate_entity THEN

        IF l_Sourcing_Rule_rec.operation = MRP_Globals.G_OPR_DELETE THEN

            MRP_Validate_Sourcing_Rule.Entity_Delete
            (   x_return_status               => l_return_status
            ,   p_Sourcing_Rule_rec           => l_Sourcing_Rule_rec
            );

        ELSE

            MRP_Validate_Sourcing_Rule.Entity
            (   x_return_status               => l_return_status
            ,   p_Sourcing_Rule_rec           => l_Sourcing_Rule_rec
            ,   p_old_Sourcing_Rule_rec       => l_old_Sourcing_Rule_rec
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

        IF l_Sourcing_Rule_rec.operation = MRP_Globals.G_OPR_DELETE THEN

            MRP_Sourcing_Rule_Handlers.Delete_Row
            (   p_Sourcing_Rule_Id            => l_Sourcing_Rule_rec.Sourcing_Rule_Id
            );

        ELSE

            --  Get Who Information

            l_Sourcing_Rule_rec.last_update_date := SYSDATE;
            l_Sourcing_Rule_rec.last_updated_by := FND_GLOBAL.USER_ID;
            l_Sourcing_Rule_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

            IF l_Sourcing_Rule_rec.operation = MRP_Globals.G_OPR_UPDATE THEN

                MRP_Sourcing_Rule_Handlers.Update_Row (l_Sourcing_Rule_rec);

            ELSIF l_Sourcing_Rule_rec.operation = MRP_Globals.G_OPR_CREATE THEN

                l_Sourcing_Rule_rec.creation_date := SYSDATE;
                l_Sourcing_Rule_rec.created_by := FND_GLOBAL.USER_ID;

                MRP_Sourcing_Rule_Handlers.Insert_Row (l_Sourcing_Rule_rec);

            END IF;

        END IF;

    END IF;

    --  Load OUT parameters

    x_Sourcing_Rule_rec            := l_Sourcing_Rule_rec;
    x_old_Sourcing_Rule_rec        := l_old_Sourcing_Rule_rec;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        l_Sourcing_Rule_rec.return_status := FND_API.G_RET_STS_ERROR;
        x_Sourcing_Rule_rec            := l_Sourcing_Rule_rec;
        x_old_Sourcing_Rule_rec        := l_old_Sourcing_Rule_rec;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        l_Sourcing_Rule_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Sourcing_Rule_rec            := l_Sourcing_Rule_rec;
        x_old_Sourcing_Rule_rec        := l_old_Sourcing_Rule_rec;

        RAISE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sourcing_Rule'
            );
        END IF;

        l_Sourcing_Rule_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Sourcing_Rule_rec            := l_Sourcing_Rule_rec;
        x_old_Sourcing_Rule_rec        := l_old_Sourcing_Rule_rec;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sourcing_Rule;

--  Receiving_Orgs

PROCEDURE Receiving_Orgs
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  MRP_GLOBALS.Control_Rec_Type
,   p_Receiving_Org_tbl             IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type
,   p_old_Receiving_Org_tbl         IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type
,   x_Receiving_Org_tbl             OUT NOCOPY MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type
,   x_old_Receiving_Org_tbl         OUT NOCOPY MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 MRP_GLOBALS.Control_Rec_Type;
l_Receiving_Org_rec           MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type;
l_Receiving_Org_out_rec       MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type; -- Nocopy Change
l_Receiving_Org_tbl           MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type;
l_old_Receiving_Org_rec       MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type;
l_old_Receiving_Org_tbl       MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type;
BEGIN

    --  Init local table variables.

    l_Receiving_Org_tbl            := p_Receiving_Org_tbl;
    l_old_Receiving_Org_tbl        := p_old_Receiving_Org_tbl;

    FOR I IN 1..l_Receiving_Org_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_Receiving_Org_rec := l_Receiving_Org_tbl(I);

        IF l_old_Receiving_Org_tbl.EXISTS(I) THEN
            l_old_Receiving_Org_rec := l_old_Receiving_Org_tbl(I);
        ELSE
            l_old_Receiving_Org_rec := MRP_Sourcing_Rule_PUB.G_MISS_RECEIVING_ORG_REC;
        END IF;

        --  Load API control record

        l_control_rec := MRP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_Receiving_Org_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_Receiving_Org_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_Receiving_Org_rec.operation = MRP_Globals.G_OPR_CREATE THEN

            l_Receiving_Org_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_Receiving_Org_rec :=
            MRP_Receiving_Org_Util.Convert_Miss_To_Null (l_old_Receiving_Org_rec);

        ELSIF l_Receiving_Org_rec.operation = MRP_Globals.G_OPR_UPDATE
        OR    l_Receiving_Org_rec.operation = MRP_Globals.G_OPR_DELETE
        THEN

            l_Receiving_Org_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_Receiving_Org_rec.Sr_Receipt_Id = FND_API.G_MISS_NUM
            THEN

                l_old_Receiving_Org_rec := MRP_Receiving_Org_Handlers.Query_Row
                (   p_Sr_Receipt_Id               => l_Receiving_Org_rec.Sr_Receipt_Id
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_Receiving_Org_rec :=
                MRP_Receiving_Org_Util.Convert_Miss_To_Null (l_old_Receiving_Org_rec);

            END IF;

            --  Complete new record from old

            l_Receiving_Org_rec := MRP_Receiving_Org_Util.Complete_Record
            (   p_Receiving_Org_rec           => l_Receiving_Org_rec
            ,   p_old_Receiving_Org_rec       => l_old_Receiving_Org_rec
            );

        END IF;

        --  Attribute level validation.

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                MRP_Validate_Receiving_Org.Attributes
                (   x_return_status               => l_return_status
                ,   p_Receiving_Org_rec           => l_Receiving_Org_rec
                ,   p_old_Receiving_Org_rec       => l_old_Receiving_Org_rec
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

            MRP_Receiving_Org_Util.Clear_Dependent_Attr
            (   p_Receiving_Org_rec           => l_Receiving_Org_rec
            ,   p_old_Receiving_Org_rec       => l_old_Receiving_Org_rec
            ,   x_Receiving_Org_rec           => l_Receiving_Org_out_rec -- Nocopy Change
            );
             l_Receiving_Org_rec := l_Receiving_Org_out_rec ; -- Nocopy Change

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            MRP_Default_Receiving_Org.Attributes
            (   p_Receiving_Org_rec           => l_Receiving_Org_rec
            ,   x_Receiving_Org_rec           => l_Receiving_Org_out_rec -- Nocopy Change
            );
           l_Receiving_Org_rec := l_Receiving_Org_out_rec ; -- Nocopy Change

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            MRP_Receiving_Org_Util.Apply_Attribute_Changes
            (   p_Receiving_Org_rec           => l_Receiving_Org_rec
            ,   p_old_Receiving_Org_rec       => l_old_Receiving_Org_rec
            ,   x_Receiving_Org_rec           => l_Receiving_Org_out_rec -- Nocopy Change
            );
            l_Receiving_Org_rec := l_Receiving_Org_out_rec ; -- Nocopy Change

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_Receiving_Org_rec.operation = MRP_Globals.G_OPR_DELETE THEN

                MRP_Validate_Receiving_Org.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_Receiving_Org_rec           => l_Receiving_Org_rec
                );

            ELSE

                MRP_Validate_Receiving_Org.Entity
                (   x_return_status               => l_return_status
                ,   p_Receiving_Org_rec           => l_Receiving_Org_rec
                ,   p_old_Receiving_Org_rec       => l_old_Receiving_Org_rec
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

            IF l_Receiving_Org_rec.operation = MRP_Globals.G_OPR_DELETE THEN

                MRP_Receiving_Org_Handlers.Delete_Row
                (   p_Sr_Receipt_Id               => l_Receiving_Org_rec.Sr_Receipt_Id
                );

            ELSE

                --  Get Who Information

                l_Receiving_Org_rec.last_update_date := SYSDATE;
                l_Receiving_Org_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_Receiving_Org_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_Receiving_Org_rec.operation = MRP_Globals.G_OPR_UPDATE THEN

                    MRP_Receiving_Org_Handlers.Update_Row (l_Receiving_Org_rec);

                ELSIF l_Receiving_Org_rec.operation = MRP_Globals.G_OPR_CREATE THEN

                    l_Receiving_Org_rec.creation_date := SYSDATE;
                    l_Receiving_Org_rec.created_by := FND_GLOBAL.USER_ID;

-- dbms_output.put_line ('Inserting Rec Org');
                    MRP_Receiving_Org_Handlers.Insert_Row (l_Receiving_Org_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        l_Receiving_Org_tbl(I)         := l_Receiving_Org_rec;
        l_old_Receiving_Org_tbl(I)     := l_old_Receiving_Org_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_Receiving_Org_rec.return_status := FND_API.G_RET_STS_ERROR;
            l_Receiving_Org_tbl(I)         := l_Receiving_Org_rec;
            l_old_Receiving_Org_tbl(I)     := l_old_Receiving_Org_rec;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_Receiving_Org_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_Receiving_Org_tbl(I)         := l_Receiving_Org_rec;
            l_old_Receiving_Org_tbl(I)     := l_old_Receiving_Org_rec;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_Receiving_Org_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_Receiving_Org_tbl(I)         := l_Receiving_Org_rec;
            l_old_Receiving_Org_tbl(I)     := l_old_Receiving_Org_rec;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Receiving_Orgs'
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_Receiving_Org_tbl            := l_Receiving_Org_tbl;
    x_old_Receiving_Org_tbl        := l_old_Receiving_Org_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        RAISE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Receiving_Orgs'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Receiving_Orgs;

--  Shipping_Orgs

PROCEDURE Shipping_Orgs
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  MRP_GLOBALS.Control_Rec_Type
,   p_Shipping_Org_tbl              IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type
,   p_old_Shipping_Org_tbl          IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type
,   x_Shipping_Org_tbl              OUT NOCOPY MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type
,   x_old_Shipping_Org_tbl          OUT NOCOPY MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 MRP_GLOBALS.Control_Rec_Type;
l_Shipping_Org_rec            MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type;
l_Shipping_Org_out_rec        MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type; -- Nocopy Change
l_Shipping_Org_tbl            MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type;
l_old_Shipping_Org_rec        MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type;
l_old_Shipping_Org_tbl        MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type;
BEGIN

    --  Init local table variables.

    l_Shipping_Org_tbl             := p_Shipping_Org_tbl;
    l_old_Shipping_Org_tbl         := p_old_Shipping_Org_tbl;

    FOR I IN 1..l_Shipping_Org_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_Shipping_Org_rec := l_Shipping_Org_tbl(I);

        IF l_old_Shipping_Org_tbl.EXISTS(I) THEN
            l_old_Shipping_Org_rec := l_old_Shipping_Org_tbl(I);
        ELSE
            l_old_Shipping_Org_rec := MRP_Sourcing_Rule_PUB.G_MISS_SHIPPING_ORG_REC;
        END IF;

        --  Load API control record

        l_control_rec := MRP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_Shipping_Org_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_Shipping_Org_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_Shipping_Org_rec.operation = MRP_Globals.G_OPR_CREATE THEN

            l_Shipping_Org_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_Shipping_Org_rec :=
            MRP_Shipping_Org_Util.Convert_Miss_To_Null (l_old_Shipping_Org_rec);

        ELSIF l_Shipping_Org_rec.operation = MRP_Globals.G_OPR_UPDATE
        OR    l_Shipping_Org_rec.operation = MRP_Globals.G_OPR_DELETE
        THEN

            l_Shipping_Org_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_Shipping_Org_rec.Sr_Source_Id = FND_API.G_MISS_NUM
            THEN

                l_old_Shipping_Org_rec := MRP_Shipping_Org_Handlers.Query_Row
                (   p_Sr_Source_Id                => l_Shipping_Org_rec.Sr_Source_Id
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_Shipping_Org_rec :=
                MRP_Shipping_Org_Util.Convert_Miss_To_Null (l_old_Shipping_Org_rec);

            END IF;

            --  Complete new record from old

            l_Shipping_Org_rec := MRP_Shipping_Org_Util.Complete_Record
            (   p_Shipping_Org_rec            => l_Shipping_Org_rec
            ,   p_old_Shipping_Org_rec        => l_old_Shipping_Org_rec
            );

        END IF;

        --  Attribute level validation.

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                MRP_Validate_Shipping_Org.Attributes
                (   x_return_status               => l_return_status
                ,   p_Shipping_Org_rec            => l_Shipping_Org_rec
                ,   p_old_Shipping_Org_rec        => l_old_Shipping_Org_rec
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

            MRP_Shipping_Org_Util.Clear_Dependent_Attr
            (   p_Shipping_Org_rec            => l_Shipping_Org_rec
            ,   p_old_Shipping_Org_rec        => l_old_Shipping_Org_rec
            ,   x_Shipping_Org_rec            => l_Shipping_Org_out_rec -- Nocopy Change
            );
            l_Shipping_Org_rec := l_Shipping_Org_out_rec; -- Nocopy Change

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            MRP_Default_Shipping_Org.Attributes
            (   p_Shipping_Org_rec            => l_Shipping_Org_rec
            ,   x_Shipping_Org_rec            => l_Shipping_Org_out_rec -- Nocopy Change
            );
           l_Shipping_Org_rec := l_Shipping_Org_out_rec; -- Nocopy Change

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            MRP_Shipping_Org_Util.Apply_Attribute_Changes
            (   p_Shipping_Org_rec            => l_Shipping_Org_rec
            ,   p_old_Shipping_Org_rec        => l_old_Shipping_Org_rec
            ,   x_Shipping_Org_rec            => l_Shipping_Org_out_rec -- Nocopy Change
            );
           l_Shipping_Org_rec := l_Shipping_Org_out_rec; -- Nocopy Change

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_Shipping_Org_rec.operation = MRP_Globals.G_OPR_DELETE THEN

                MRP_Validate_Shipping_Org.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_Shipping_Org_rec            => l_Shipping_Org_rec
                );

            ELSE

                MRP_Validate_Shipping_Org.Entity
                (   x_return_status               => l_return_status
                ,   p_Shipping_Org_rec            => l_Shipping_Org_rec
                ,   p_old_Shipping_Org_rec        => l_old_Shipping_Org_rec
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

            IF l_Shipping_Org_rec.operation = MRP_Globals.G_OPR_DELETE THEN

                MRP_Shipping_Org_Handlers.Delete_Row
                (   p_Sr_Source_Id                => l_Shipping_Org_rec.Sr_Source_Id
                );

            ELSE

                --  Get Who Information

                l_Shipping_Org_rec.last_update_date := SYSDATE;
                l_Shipping_Org_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_Shipping_Org_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_Shipping_Org_rec.operation = MRP_Globals.G_OPR_UPDATE THEN

                    MRP_Shipping_Org_Handlers.Update_Row (l_Shipping_Org_rec);

                ELSIF l_Shipping_Org_rec.operation = MRP_Globals.G_OPR_CREATE THEN

                    l_Shipping_Org_rec.creation_date := SYSDATE;
                    l_Shipping_Org_rec.created_by  := FND_GLOBAL.USER_ID;

                    MRP_Shipping_Org_Handlers.Insert_Row (l_Shipping_Org_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        l_Shipping_Org_tbl(I)          := l_Shipping_Org_rec;
        l_old_Shipping_Org_tbl(I)      := l_old_Shipping_Org_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_Shipping_Org_rec.return_status := FND_API.G_RET_STS_ERROR;
            l_Shipping_Org_tbl(I)          := l_Shipping_Org_rec;
            l_old_Shipping_Org_tbl(I)      := l_old_Shipping_Org_rec;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_Shipping_Org_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_Shipping_Org_tbl(I)          := l_Shipping_Org_rec;
            l_old_Shipping_Org_tbl(I)      := l_old_Shipping_Org_rec;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_Shipping_Org_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_Shipping_Org_tbl(I)          := l_Shipping_Org_rec;
            l_old_Shipping_Org_tbl(I)      := l_old_Shipping_Org_rec;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Shipping_Orgs'
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_Shipping_Org_tbl             := l_Shipping_Org_tbl;
    x_old_Shipping_Org_tbl         := l_old_Shipping_Org_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        RAISE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Shipping_Orgs'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Shipping_Orgs;

--  Start of Comments
--  API name    Process_Sourcing_Rule
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

PROCEDURE Process_Sourcing_Rule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  MRP_GLOBALS.Control_Rec_Type :=
                                        MRP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_Sourcing_Rule_rec             IN  MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_SOURCING_RULE_REC
,   p_old_Sourcing_Rule_rec         IN  MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_SOURCING_RULE_REC
,   p_Receiving_Org_tbl             IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_RECEIVING_ORG_TBL
,   p_old_Receiving_Org_tbl         IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_RECEIVING_ORG_TBL
,   p_Shipping_Org_tbl              IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_SHIPPING_ORG_TBL
,   p_old_Shipping_Org_tbl          IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_SHIPPING_ORG_TBL
,   x_Sourcing_Rule_rec             OUT NOCOPY MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
,   x_Receiving_Org_tbl             OUT NOCOPY MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type
,   x_Shipping_Org_tbl              OUT NOCOPY MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Sourcing_Rule';
l_return_status               VARCHAR2(1);
l_control_rec                 MRP_GLOBALS.Control_Rec_Type;
l_Sourcing_Rule_rec           MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type := p_Sourcing_Rule_rec;
l_Sourcing_Rule_out_rec       MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type ; -- Nocopy Change
l_old_Sourcing_Rule_rec       MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type := p_old_Sourcing_Rule_rec;
l_old_Sourcing_Rule_out_rec   MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type ; -- Nocopy Change
l_Receiving_Org_rec           MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type;
l_Receiving_Org_tbl           MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type;
l_Receiving_Org_out_tbl       MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type; -- Nocopy Change
l_old_Receiving_Org_rec       MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type;
l_old_Receiving_Org_out_tbl   MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type; -- Nocopy Change
l_old_Receiving_Org_tbl       MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type;
l_Shipping_Org_rec            MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type;
l_Shipping_Org_out_tbl        MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type; --Nocopy Change
l_Shipping_Org_tbl            MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type;
l_old_Shipping_Org_rec        MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type;
l_old_Shipping_Org_out_tbl    MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type; -- Nocopy Change
l_old_Shipping_Org_tbl        MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type;

l_tot_alloc_percent     NUMBER;
l_curr_rco_index        NUMBER;
l_curr_rank        NUMBER;
l_count     		NUMBER;
l_organization_id	NUMBER := FND_API.G_MISS_NUM;
org_exists NUMBER;

BEGIN

	 --dbms_output.put_line ('Oper :  ' || l_Sourcing_Rule_rec.operation);
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

    --  Set Save point.
    SAVEPOINT Process_Sourcing_Rule_PVT;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Init local table variables.

    l_Receiving_Org_tbl            := p_Receiving_Org_tbl;
    l_old_Receiving_Org_tbl        := p_old_Receiving_Org_tbl;

    --  Init local table variables.

    l_Shipping_Org_tbl             := p_Shipping_Org_tbl;
    l_old_Shipping_Org_tbl         := p_old_Shipping_Org_tbl;

    --  Sourcing_Rule

    Sourcing_Rule
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_Sourcing_Rule_rec           => l_Sourcing_Rule_rec
    ,   p_old_Sourcing_Rule_rec       => l_old_Sourcing_Rule_rec
    ,   x_Sourcing_Rule_rec           => l_Sourcing_Rule_out_rec -- Nocopy Change
    ,   x_old_Sourcing_Rule_rec       => l_old_Sourcing_Rule_out_rec -- Nocopy Change
    );
    l_Sourcing_Rule_rec := l_Sourcing_Rule_out_rec; -- Nocopy Change
    l_old_Sourcing_Rule_rec := l_old_Sourcing_Rule_out_rec; -- Nocopy Change

    --  Perform Sourcing_Rule group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = MRP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = MRP_GLOBALS.G_ENTITY_SOURCING_RULE)
    THEN

        NULL;

    END IF;

    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_Receiving_Org_tbl.COUNT LOOP

        l_Receiving_Org_rec := l_Receiving_Org_tbl(I);

        IF l_Receiving_Org_rec.operation = MRP_Globals.G_OPR_CREATE
        AND (l_Receiving_Org_rec.Sourcing_Rule_Id IS NULL OR
            l_Receiving_Org_rec.Sourcing_Rule_Id = FND_API.G_MISS_NUM)
        THEN

            --  Copy parent_id.
	    -- dbms_output.put_line ('Parent SR id is : ' || to_char (l_Sourcing_Rule_rec.Sourcing_Rule_Id));

            l_Receiving_Org_tbl(I).Sourcing_Rule_Id := l_Sourcing_Rule_rec.Sourcing_Rule_Id;
        END IF;
    END LOOP;

    --  Receiving_Orgs

    Receiving_Orgs
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_Receiving_Org_tbl           => l_Receiving_Org_tbl
    ,   p_old_Receiving_Org_tbl       => l_old_Receiving_Org_tbl
    ,   x_Receiving_Org_tbl           => l_Receiving_Org_out_tbl -- Nocopy Change
    ,   x_old_Receiving_Org_tbl       => l_old_Receiving_Org_out_tbl -- Nocopy Change
    );
    -- Nocopy Change
    l_Receiving_Org_tbl := l_Receiving_Org_out_tbl ;
    l_old_Receiving_Org_tbl := l_old_Receiving_Org_out_tbl;

    --  Perform Receiving_Org group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = MRP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = MRP_GLOBALS.G_ENTITY_RECEIVING_ORG) AND
	l_sourcing_rule_rec.operation <> MRP_GLOBALS.G_OPR_DELETE
    THEN

        FOR I IN 1..l_Receiving_Org_tbl.COUNT LOOP

            l_Receiving_Org_rec := l_Receiving_Org_tbl(I);

   /** Bug 2257098 : Put a check that for Sourcing rules, one cannot
         pass a receiving organization that is different from the
         Organization for which the sourcing rule is defined.
   **/

        IF (l_sourcing_rule_rec.sourcing_rule_type = 1 AND
              NVL(l_Receiving_Org_rec.receipt_organization_id,-23453) <>
                    NVL(l_sourcing_rule_rec.organization_id,-23453)) THEN

	         -- dbms_output.put_line ('Invalid Receiving Organization');
                FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_VALUE_ERROR');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Receiving_Organization');
                FND_MESSAGE.SET_TOKEN('DETAILS', 'Mismatch between SR Organization and Receiving Organization');
                FND_MSG_PUB.Add;
	            l_Receiving_Org_tbl(I).return_status := FND_API.G_RET_STS_ERROR;

	    END IF;

	    -- The sourcing rule should not have receiving orgs with
	    -- overlapping effectivity dates

	    SELECT count(*)
	    INTO   l_count
	    FROM   MRP_SR_RECEIPT_ORG RO1,
	           MRP_SR_RECEIPT_ORG RO2
	    WHERE  RO1.sourcing_rule_id =
				l_sourcing_rule_rec.sourcing_rule_id
	    AND    RO1.sr_receipt_id = l_Receiving_Org_rec.sr_receipt_id
	    AND    RO2.sourcing_rule_id = RO1.sourcing_rule_id
	    AND    RO2.sr_receipt_id <> RO1.sr_receipt_id
/** Bug 2257098
            AND    RO1.EFFECTIVE_DATE >= RO2.EFFECTIVE_DATE
            AND    RO1.EFFECTIVE_DATE <
                         NVL(RO2.DISABLE_DATE, RO1.EFFECTIVE_DATE + 1);
**/
        AND    NVL(RO2.receipt_organization_id,-23453) = NVL(RO1.receipt_organization_id,-23453)
        AND    ((RO1.EFFECTIVE_DATE = RO2.EFFECTIVE_DATE)
                         OR
                (RO1.EFFECTIVE_DATE > RO2.EFFECTIVE_DATE
            AND    RO1.EFFECTIVE_DATE <= NVL(RO2.DISABLE_DATE, RO1.EFFECTIVE_DATE))
                         OR
               (RO1.EFFECTIVE_DATE < RO2.EFFECTIVE_DATE
            AND    NVL(RO1.DISABLE_DATE,RO2.EFFECTIVE_DATE) >= RO2.EFFECTIVE_DATE));

	    IF l_count > 0 THEN
	        -- dbms_output.put_line ('Overlapping effective dates');
                FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_VALUE_ERROR');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Effective_Date');
                FND_MESSAGE.SET_TOKEN('DETAILS', 'Overlapping Effective ' ||
			'Dates not allowed for Receiving Organizations');
                FND_MSG_PUB.Add;
	        l_Receiving_Org_tbl(I).return_status := FND_API.G_RET_STS_ERROR;
	    END IF;

	END LOOP;

    END IF;

    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_Shipping_Org_tbl.COUNT LOOP

        l_Shipping_Org_rec := l_Shipping_Org_tbl(I);

        IF l_Shipping_Org_rec.operation = MRP_Globals.G_OPR_CREATE
        AND (l_Shipping_Org_rec.Sr_Receipt_Id IS NULL OR
            l_Shipping_Org_rec.Sr_Receipt_Id = FND_API.G_MISS_NUM)
        THEN

            --  Check If parent exists.

            IF l_Receiving_Org_tbl.EXISTS(l_Shipping_Org_rec.Receiving_Org_index) THEN

                --  Copy parent_id.

                l_Shipping_Org_tbl(I).Sr_Receipt_Id := l_Receiving_Org_tbl(l_Shipping_Org_rec.Receiving_Org_index).Sr_Receipt_Id;

            ELSE

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN

                    FND_MESSAGE.SET_NAME('MRP','MRP_API_INV_PARENT_INDEX');
                    FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Shipping_Org');
                    FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
                    FND_MESSAGE.SET_TOKEN('PARENT_INDEX',l_Shipping_Org_rec.Receiving_Org_index);
                    FND_MSG_PUB.Add;

                END IF;
            END IF;
        END IF;
    END LOOP;

    --  Shipping_Orgs

    Shipping_Orgs
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_Shipping_Org_tbl            => l_Shipping_Org_tbl
    ,   p_old_Shipping_Org_tbl        => l_old_Shipping_Org_tbl
    ,   x_Shipping_Org_tbl            => l_Shipping_Org_out_tbl -- Nocopy Change
    ,   x_old_Shipping_Org_tbl        => l_old_Shipping_Org_out_tbl -- Nocopy Change
    );

     -- Nocopy Change
     l_Shipping_Org_tbl := l_Shipping_Org_out_tbl ;
     l_old_Shipping_Org_tbl := l_old_Shipping_Org_out_tbl;

    --  Perform Shipping_Org group requests.

/** Bug 2263575
    1. Commented out nocopy the check that there cannot be two sources
       with the same rank since in 11i this is not true.
    2. When  setting the planning_active flag to 2 based on the total
       allocation % (should be 100 for a plan to be active) added
       a check on rank too.
    3. Wherever we are checking l_Shipping_Org_rec.source_organization_id
       wrt l_sourcing_rule_rec.organization_id,
       replaced l_sourcing_rule_rec.organization_id with
       l_Receiving_Org_rec.receipt_organization_id since for BOD, the
       l_sourcing_rule_rec.organization_id and
       l_Receiving_Org_rec.receipt_organization_id may be different.
    4. For a local SR/BOD, if the source_type = 1(Transfer From) put a check
       that there should be a shipping network defined between the shipping
       org and receiving org.
    5. Put a check that if the SR is global you cannot have source_type
       = 2 (Make At)
**/

    IF p_control_rec.process AND
        (p_control_rec.process_entity = MRP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = MRP_GLOBALS.G_ENTITY_SHIPPING_ORG) AND
	l_sourcing_rule_rec.operation <> MRP_GLOBALS.G_OPR_DELETE
    THEN

	l_tot_alloc_percent := 0;
	l_curr_rco_index := 0;
    l_curr_rank := -23453;

    	FOR I IN 1..l_Shipping_Org_tbl.COUNT LOOP

	    IF ((l_curr_rco_index <>
				l_Shipping_Org_tbl(I).receiving_org_index)
                      OR
           (l_curr_rank <> l_Shipping_Org_tbl(I).rank)) /* Bug 2263575 */
               THEN

	     	IF l_curr_rco_index <> 0 AND l_tot_alloc_percent < 100 THEN
	            UPDATE mrp_sourcing_rules
	            SET    planning_active = 2
  	            WHERE  sourcing_rule_id =
				l_sourcing_rule_rec.sourcing_rule_id;
		    END IF;

		l_tot_alloc_percent := 0;
	    END IF;

        l_Shipping_Org_rec := l_Shipping_Org_tbl(I);
        l_Receiving_Org_rec := l_Receiving_Org_tbl(l_Shipping_Org_rec.Receiving_Org_index); /* Bug 2263575 */
	    l_curr_rco_index := l_Shipping_Org_rec.receiving_org_index;
	    l_curr_rank := l_Shipping_Org_rec.rank; /* Bug 2263575 */

	    IF l_Shipping_Org_rec.source_type = 1 AND
                l_Receiving_Org_rec.receipt_organization_id IS NOT NULL /* Bug 2263575 */
            THEN
	      IF  /** Bug 2263575 l_sourcing_rule_rec.organization_id = **/
            l_Receiving_Org_rec.receipt_organization_id =
			l_Shipping_Org_rec.source_organization_id THEN
		-- dbms_output.put_line ('Source Org should be different');
                FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_VALUE_ERROR');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Source_Organization_Id');
                FND_MESSAGE.SET_TOKEN('DETAILS', 'Source Organization ' ||
			'should be different from Receiving Organization');
                FND_MSG_PUB.Add;
	        l_Shipping_Org_tbl(I).return_status := FND_API.G_RET_STS_ERROR;

          ELSE /* Bug 2263575  */
           BEGIN
            SELECT  1 INTO org_exists
            FROM mtl_interorg_parameters
            WHERE to_organization_id = l_Receiving_Org_rec.receipt_organization_id
            AND   from_organization_id = l_Shipping_Org_rec.source_organization_id;
           EXCEPTION WHEN NO_DATA_FOUND THEN
		     -- dbms_output.put_line ('Shipping Network not defined between source org and receiving org');
                FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_VALUE_ERROR');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Source_Organization_Id');
                FND_MESSAGE.SET_TOKEN('DETAILS', 'Shipping Network ' ||
			'not defined between source org and receiving org');
                FND_MSG_PUB.Add;
	        l_Shipping_Org_tbl(I).return_status := FND_API.G_RET_STS_ERROR;
           END;
          END IF;
	    END IF;

        IF l_Shipping_Org_rec.source_type = 2 AND /* Bug 2263575 */
            l_sourcing_rule_rec.sourcing_rule_type = 1 AND /* Bug 5238229 */
            l_sourcing_rule_rec.organization_id IS NULL THEN
		    -- dbms_output.put_line ('Cannot have source type of Make At for Global SR');
                    FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_VALUE_ERROR');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Source_Type');
                    FND_MESSAGE.SET_TOKEN('DETAILS', 'Cannot have source type of Make At for Global SR');
                    FND_MSG_PUB.Add;
	            l_Shipping_Org_tbl(I).return_status :=
						FND_API.G_RET_STS_ERROR;
        END IF;

	    IF l_Shipping_Org_rec.source_type = 2 AND
		/** Bug 2263575 l_sourcing_rule_rec.organization_id IS NOT NULL **/
            l_Receiving_Org_rec.receipt_organization_id IS NOT NULL
	      THEN
		IF /** Bug 2263575 l_sourcing_rule_rec.organization_id <> **/
            l_Receiving_Org_rec.receipt_organization_id <>
			l_Shipping_Org_rec.source_organization_id THEN
		    -- dbms_output.put_line ('Source Org should be same');
                    FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_VALUE_ERROR');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Source_Organization_Id');
                    FND_MESSAGE.SET_TOKEN('DETAILS', 'Source Organization ' ||
			'should be same as Receiving Organization');
                    FND_MSG_PUB.Add;
	            l_Shipping_Org_tbl(I).return_status :=
						FND_API.G_RET_STS_ERROR;
		END IF;
	    END IF;

	    IF l_Shipping_Org_rec.source_type = 3 AND
		l_Shipping_Org_rec.source_organization_id IS NOT NULL THEN
                -- dbms_output.put_line ('Source Org should be NULL');
                FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_VALUE_ERROR');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Source_Organization_Id');
                FND_MESSAGE.SET_TOKEN('DETAILS',
			'Source Organization should be NULL');
                FND_MSG_PUB.Add;
	        l_Shipping_Org_tbl(I).return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            -- We cannot have two shipping orgs with the same rank

/**** Bug 2263575
            SELECT count(*)
            INTO   l_count
            FROM   MRP_SR_SOURCE_ORG SO1,
                   MRP_SR_SOURCE_ORG SO2
            WHERE  SO1.sr_receipt_id =
                                l_Shipping_Org_rec.sr_receipt_id
            AND    SO1.sr_source_id = l_Shipping_Org_rec.sr_source_id
            AND    SO2.sr_receipt_id = SO1.sr_receipt_id
            AND    SO2.sr_source_id <> SO1.sr_source_id
            AND    NVL(SO2.rank, -999) = NVL(SO1.rank,-9999);

            IF l_count > 0 THEN
                -- dbms_output.put_line ('Cannot have Duplicate Ranks on SHO s');
                FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_VALUE_ERROR');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Rank');
                FND_MESSAGE.SET_TOKEN('DETAILS',
		    'Cannot have Duplicate Ranks on Shipping Organizations');
                FND_MSG_PUB.Add;
	        l_Shipping_Org_tbl(I).return_status := FND_API.G_RET_STS_ERROR;
            END IF;

***/

	    l_tot_alloc_percent := l_tot_alloc_percent +
					l_Shipping_Org_rec.allocation_percent;

	    -- if supplier and supplier site are passed in and there is
	    -- an organization modelled as this supplier at this site,
	    -- populate the source_organization_id

	    l_organization_id := FND_API.G_MISS_NUM;

/* 2448893 - Add to_char to the vendor_id and vendor_site_id in
             l_shipping_org_rec since supplier_id and supplier_site_id in
             mrp_cust_sup_org_v are varchar2 */

	    BEGIN
	    	SELECT organization_id
	    	INTO   l_organization_id
		FROM   mrp_cust_sup_org_v
		WHERE  supplier_id = to_char(l_Shipping_Org_rec.vendor_id)
		AND    supplier_site_id = to_char(l_Shipping_Org_rec.vendor_site_id);

		IF l_organization_id IS NOT NULL AND
				l_organization_id <> FND_API.G_MISS_NUM THEN
		    UPDATE mrp_sr_source_org
		    SET    source_organization_id = l_organization_id
		    WHERE  sr_source_id = l_Shipping_Org_rec.sr_source_id;

		END IF;
	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		    NULL;
	    END;

  	    IF l_tot_alloc_percent > 100 THEN
                 -- dbms_output.put_line ('total alloc percent cannot be > 100');
                FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_VALUE_ERROR');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Rank');
                FND_MESSAGE.SET_TOKEN('DETAILS',
	            'Total Allocation Percent cannot be greater than 100');
                FND_MSG_PUB.Add;
	        l_Shipping_Org_tbl(I).return_status := FND_API.G_RET_STS_ERROR;
            END IF;

	END LOOP;

   	IF l_tot_alloc_percent < 100 THEN /* bug 2263575 : For the last record */
	            UPDATE mrp_sourcing_rules
	            SET    planning_active = 2
  	            WHERE  sourcing_rule_id =
				l_sourcing_rule_rec.sourcing_rule_id;
    END IF;


    END IF;

    --  Step 6. Perform Object group logic

    IF p_control_rec.process AND
        p_control_rec.process_entity = MRP_GLOBALS.G_ENTITY_ALL AND
	l_sourcing_rule_rec.operation <> MRP_GLOBALS.G_OPR_DELETE
    THEN

	-- Every sourcing rule should have at least one receiving org
	-- and every receiving org should have at least one source org

	SELECT count(*)
	INTO   l_count
	FROM   MRP_SR_RECEIPT_ORG
	WHERE  sourcing_rule_id = l_sourcing_rule_rec.sourcing_rule_id;

  	IF l_count = 0 THEN
	    -- dbms_output.put_line ('At least one receiving org req');
            FND_MESSAGE.SET_NAME('MRP','MRP_INCOMPLETE_OBJECT');
            FND_MESSAGE.SET_TOKEN('OBJECT','Sourcing_Rule');
            FND_MESSAGE.SET_TOKEN('DETAILS',
	        'At least one receiving organization is required');
            FND_MSG_PUB.Add;
	    l_sourcing_rule_rec.return_status := FND_API.G_RET_STS_ERROR;
	END IF;

    	FOR I IN 1..l_Receiving_Org_tbl.COUNT LOOP
	    SELECT count(*)
	    INTO   l_count
    	    FROM   MRP_SR_SOURCE_ORG
	    WHERE  sr_receipt_id = l_Receiving_Org_tbl(I).Sr_Receipt_Id;

  	    IF l_count = 0 THEN
		-- dbms_output.put_line ('At least one source req');
            	FND_MESSAGE.SET_NAME('MRP','MRP_INCOMPLETE_ENTITY');
            	FND_MESSAGE.SET_TOKEN('ENTITY','Receiving_Org');
                FND_MESSAGE.SET_TOKEN('DETAILS',
	        	'At least one source organization is required');
           	FND_MSG_PUB.Add;
	        l_Receiving_Org_tbl(I).return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
	END LOOP;

    END IF;

    --  Done processing, load OUT parameters.

    x_Sourcing_Rule_rec            := l_Sourcing_Rule_rec;
    x_Receiving_Org_tbl            := l_Receiving_Org_tbl;
    x_Shipping_Org_tbl             := l_Shipping_Org_tbl;

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

    IF l_Sourcing_Rule_rec.return_status = FND_API.G_RET_STS_ERROR THEN
	ROLLBACK TO Process_Sourcing_Rule_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    FOR I IN 1..l_Receiving_Org_tbl.COUNT LOOP

        IF l_Receiving_Org_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
	    ROLLBACK TO Process_Sourcing_Rule_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END LOOP;

    FOR I IN 1..l_Shipping_Org_tbl.COUNT LOOP

        IF l_Shipping_Org_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
	    ROLLBACK TO Process_Sourcing_Rule_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END LOOP;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Sourcing_Rule'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Sourcing_Rule;

--  Start of Comments
--  API name    Lock_Sourcing_Rule
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

PROCEDURE Lock_Sourcing_Rule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_Sourcing_Rule_rec             IN  MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_SOURCING_RULE_REC
,   p_Receiving_Org_tbl             IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_RECEIVING_ORG_TBL
,   p_Shipping_Org_tbl              IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_SHIPPING_ORG_TBL
,   x_Sourcing_Rule_rec             OUT NOCOPY MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
,   x_Receiving_Org_tbl             OUT NOCOPY MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type
,   x_Shipping_Org_tbl              OUT NOCOPY MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Sourcing_Rule';
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_Receiving_Org_rec           MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type;
l_Shipping_Org_rec            MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type;
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
        FND_MSG_PUB.initialize;
    END IF;

    --  Set Savepoint

    SAVEPOINT Lock_Sourcing_Rule_PVT;

    --  Lock Sourcing_Rule

    IF p_Sourcing_Rule_rec.operation = MRP_Globals.G_OPR_LOCK THEN

        MRP_Sourcing_Rule_Handlers.Lock_Row
        (   p_Sourcing_Rule_rec           => p_Sourcing_Rule_rec
        ,   x_Sourcing_Rule_rec           => x_Sourcing_Rule_rec
        ,   x_return_status               => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    END IF;

    --  Lock Receiving_Org

    FOR I IN 1..p_Receiving_Org_tbl.COUNT LOOP

        IF p_Receiving_Org_tbl(I).operation = MRP_Globals.G_OPR_LOCK THEN

            MRP_Receiving_Org_Handlers.Lock_Row
            (   p_Receiving_Org_rec           => p_Receiving_Org_tbl(I)
            ,   x_Receiving_Org_rec           => l_Receiving_Org_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_Receiving_Org_tbl(I)         := l_Receiving_Org_rec;

        END IF;

    END LOOP;

    --  Lock Shipping_Org

    FOR I IN 1..p_Shipping_Org_tbl.COUNT LOOP

        IF p_Shipping_Org_tbl(I).operation = MRP_Globals.G_OPR_LOCK THEN

            MRP_Shipping_Org_Handlers.Lock_Row
            (   p_Shipping_Org_rec            => p_Shipping_Org_tbl(I)
            ,   x_Shipping_Org_rec            => l_Shipping_Org_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_Shipping_Org_tbl(I)          := l_Shipping_Org_rec;

        END IF;

    END LOOP;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Sourcing_Rule_PVT;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Sourcing_Rule_PVT;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Sourcing_Rule'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Sourcing_Rule_PVT;

END Lock_Sourcing_Rule;

--  Start of Comments
--  API name    Get_Sourcing_Rule
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

PROCEDURE Get_Sourcing_Rule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_Sourcing_Rule_Id              IN  NUMBER
,   x_Sourcing_Rule_rec             OUT NOCOPY MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
,   x_Receiving_Org_tbl             OUT NOCOPY MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type
,   x_Shipping_Org_tbl              OUT NOCOPY MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Sourcing_Rule';
l_Sourcing_Rule_rec           MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type;
l_Receiving_Org_tbl           MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type;
l_Shipping_Org_tbl            MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type;
l_x_Shipping_Org_tbl          MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type;
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
        FND_MSG_PUB.initialize;
    END IF;

    --  Get Sourcing_Rule

    l_Sourcing_Rule_rec :=  MRP_Sourcing_Rule_Handlers.Query_Row
    (   p_Sourcing_Rule_Id            => p_Sourcing_Rule_Id
    );

    --  Get Receiving_Org ( parent = Sourcing_Rule )

    l_Receiving_Org_tbl :=  MRP_Receiving_Org_Handlers.Query_Rows
    (   p_Sourcing_Rule_Id            => l_Sourcing_Rule_rec.Sourcing_Rule_Id
    );


    --  Loop over Receiving_Org's children

    FOR I1 IN 1..l_Receiving_Org_tbl.COUNT LOOP

        --  Get Shipping_Org ( parent = Receiving_Org )

        l_Shipping_Org_tbl :=  MRP_Shipping_Org_Handlers.Query_Rows
        (   p_Sr_Receipt_Id               => l_Receiving_Org_tbl(I1).Sr_Receipt_Id
        );

        FOR I2 IN 1..l_Shipping_Org_tbl.COUNT LOOP
            l_Shipping_Org_tbl(I2).Receiving_Org_Index := I1;
            l_x_Shipping_Org_tbl
            (l_x_Shipping_Org_tbl.COUNT + 1) := l_Shipping_Org_tbl(I2);
        END LOOP;

    END LOOP;

    --  Load out parameters

    x_Sourcing_Rule_rec            := l_Sourcing_Rule_rec;
    x_Receiving_Org_tbl            := l_Receiving_Org_tbl;
    x_Shipping_Org_tbl             := l_x_Shipping_Org_tbl;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Sourcing_Rule'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Sourcing_Rule;

END MRP_Sourcing_Rule_PVT;

/
