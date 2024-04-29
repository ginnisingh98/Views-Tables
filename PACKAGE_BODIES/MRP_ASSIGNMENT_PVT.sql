--------------------------------------------------------
--  DDL for Package Body MRP_ASSIGNMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_ASSIGNMENT_PVT" AS
/* $Header: MRPVASNB.pls 120.2 2005/06/24 13:57:28 ichoudhu noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Assignment_PVT';

--  Assignment_Set

PROCEDURE Assignment_Set
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  MRP_GLOBALS.Control_Rec_Type
,   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   p_old_Assignment_Set_rec        IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   x_Assignment_Set_rec            OUT NOCOPY MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   x_old_Assignment_Set_rec        OUT NOCOPY MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 MRP_GLOBALS.Control_Rec_Type;
l_Assignment_Set_rec          MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type := p_Assignment_Set_rec;
l_old_Assignment_Set_rec      MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type := p_old_Assignment_Set_rec;

l_Assignment_Set_rec_out          MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type := p_Assignment_Set_rec;
l_old_Assignment_Set_rec_out      MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type := p_old_Assignment_Set_rec;
BEGIN

    --  Load API control record

    l_control_rec := MRP_GLOBALS.Init_Control_Rec
    (   p_operation     => l_Assignment_Set_rec.operation
    ,   p_control_rec   => p_control_rec
    );

    --  Set record return status.

    l_Assignment_Set_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  Prepare record.

    IF l_Assignment_Set_rec.operation = MRP_Globals.G_OPR_CREATE THEN

        l_Assignment_Set_rec.db_flag := FND_API.G_FALSE;

        --  Set missing old record elements to NULL.

        l_old_Assignment_Set_rec :=
        MRP_Assignment_Set_Util.Convert_Miss_To_Null (l_old_Assignment_Set_rec);

    ELSIF l_Assignment_Set_rec.operation = MRP_Globals.G_OPR_UPDATE
    OR    l_Assignment_Set_rec.operation = MRP_Globals.G_OPR_DELETE
    THEN

        l_Assignment_Set_rec.db_flag := FND_API.G_TRUE;

        --  Query Old if missing

        IF  l_old_Assignment_Set_rec.Assignment_Set_Id = FND_API.G_MISS_NUM
        THEN

            l_old_Assignment_Set_rec := MRP_Assignment_Set_Handlers.Query_Row
            (   p_Assignment_Set_Id           => l_Assignment_Set_rec.Assignment_Set_Id
            );

        ELSE

            --  Set missing old record elements to NULL.

            l_old_Assignment_Set_rec :=
            MRP_Assignment_Set_Util.Convert_Miss_To_Null (l_old_Assignment_Set_rec);

        END IF;

        --  Complete new record from old

        l_Assignment_Set_rec := MRP_Assignment_Set_Util.Complete_Record
        (   p_Assignment_Set_rec          => l_Assignment_Set_rec
        ,   p_old_Assignment_Set_rec      => l_old_Assignment_Set_rec
        );

    END IF;

    --  Attribute level validation.

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

            MRP_Validate_Assignment_Set.Attributes
            (   x_return_status               => l_return_status
            ,   p_Assignment_Set_rec          => l_Assignment_Set_rec
            ,   p_old_Assignment_Set_rec      => l_old_Assignment_Set_rec
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

        MRP_Assignment_Set_Util.Clear_Dependent_Attr
        (   p_Assignment_Set_rec          => l_Assignment_Set_rec
        ,   p_old_Assignment_Set_rec      => l_old_Assignment_Set_rec
        ,   x_Assignment_Set_rec          => l_Assignment_Set_rec_out
        );
        l_Assignment_Set_rec := l_Assignment_Set_rec_out;

    END IF;

    --  Default missing attributes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        MRP_Default_Assignment_Set.Attributes
        (   p_Assignment_Set_rec          => l_Assignment_Set_rec
        ,   x_Assignment_Set_rec          => l_Assignment_Set_rec_out
        );
        l_Assignment_Set_rec := l_Assignment_Set_rec_out;

    END IF;

    --  Apply attribute changes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        MRP_Assignment_Set_Util.Apply_Attribute_Changes
        (   p_Assignment_Set_rec          => l_Assignment_Set_rec
        ,   p_old_Assignment_Set_rec      => l_old_Assignment_Set_rec
        ,   x_Assignment_Set_rec          => l_Assignment_Set_rec_out
        );
        l_Assignment_Set_rec := l_Assignment_Set_rec_out;

    END IF;

    --  Entity level validation.

    IF l_control_rec.validate_entity THEN

        IF l_Assignment_Set_rec.operation = MRP_Globals.G_OPR_DELETE THEN

            MRP_Validate_Assignment_Set.Entity_Delete
            (   x_return_status               => l_return_status
            ,   p_Assignment_Set_rec          => l_Assignment_Set_rec
            );

        ELSE

            MRP_Validate_Assignment_Set.Entity
            (   x_return_status               => l_return_status
            ,   p_Assignment_Set_rec          => l_Assignment_Set_rec
            ,   p_old_Assignment_Set_rec      => l_old_Assignment_Set_rec
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

        IF l_Assignment_Set_rec.operation = MRP_Globals.G_OPR_DELETE THEN

            MRP_Assignment_Set_Handlers.Delete_Row
            (   p_Assignment_Set_Id           => l_Assignment_Set_rec.Assignment_Set_Id
            );

        ELSE

            --  Get Who Information

            l_Assignment_Set_rec.last_update_date := SYSDATE;
            l_Assignment_Set_rec.last_updated_by := FND_GLOBAL.USER_ID;
            l_Assignment_Set_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

            IF l_Assignment_Set_rec.operation = MRP_Globals.G_OPR_UPDATE THEN

                MRP_Assignment_Set_Handlers.Update_Row (l_Assignment_Set_rec);

            ELSIF l_Assignment_Set_rec.operation = MRP_Globals.G_OPR_CREATE THEN

                l_Assignment_Set_rec.creation_date := SYSDATE;
                l_Assignment_Set_rec.created_by := FND_GLOBAL.USER_ID;

                MRP_Assignment_Set_Handlers.Insert_Row (l_Assignment_Set_rec);

            END IF;

        END IF;

    END IF;

    --  Load OUT parameters

    x_Assignment_Set_rec           := l_Assignment_Set_rec;
    x_old_Assignment_Set_rec       := l_old_Assignment_Set_rec;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        l_Assignment_Set_rec.return_status := FND_API.G_RET_STS_ERROR;
        x_Assignment_Set_rec           := l_Assignment_Set_rec;
        x_old_Assignment_Set_rec       := l_old_Assignment_Set_rec;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        l_Assignment_Set_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Assignment_Set_rec           := l_Assignment_Set_rec;
        x_old_Assignment_Set_rec       := l_old_Assignment_Set_rec;

        RAISE;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Assignment_Set'
            );
        END IF;

        l_Assignment_Set_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Assignment_Set_rec           := l_Assignment_Set_rec;
        x_old_Assignment_Set_rec       := l_old_Assignment_Set_rec;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Assignment_Set;

--  Assignments

PROCEDURE Assignments
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  MRP_GLOBALS.Control_Rec_Type
,   p_Assignment_tbl                IN  MRP_Src_Assignment_PUB.Assignment_Tbl_Type
,   p_old_Assignment_tbl            IN  MRP_Src_Assignment_PUB.Assignment_Tbl_Type
,   x_Assignment_tbl                OUT NOCOPY MRP_Src_Assignment_PUB.Assignment_Tbl_Type
,   x_old_Assignment_tbl            OUT NOCOPY MRP_Src_Assignment_PUB.Assignment_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 MRP_GLOBALS.Control_Rec_Type;
l_Assignment_rec              MRP_Src_Assignment_PUB.Assignment_Rec_Type;
l_Assignment_rec_out          MRP_Src_Assignment_PUB.Assignment_Rec_Type;
l_Assignment_tbl              MRP_Src_Assignment_PUB.Assignment_Tbl_Type;
l_old_Assignment_rec          MRP_Src_Assignment_PUB.Assignment_Rec_Type;
l_old_Assignment_tbl          MRP_Src_Assignment_PUB.Assignment_Tbl_Type;
BEGIN

    --  Init local table variables.

    l_Assignment_tbl               := p_Assignment_tbl;
    l_old_Assignment_tbl           := p_old_Assignment_tbl;

    FOR I IN 1..l_Assignment_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_Assignment_rec := l_Assignment_tbl(I);

        IF l_old_Assignment_tbl.EXISTS(I) THEN
            l_old_Assignment_rec := l_old_Assignment_tbl(I);
        ELSE
            l_old_Assignment_rec := MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_REC;
        END IF;

        --  Load API control record

        l_control_rec := MRP_GLOBALS.Init_Control_Rec
        (   p_operation     => l_Assignment_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_Assignment_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_Assignment_rec.operation = MRP_Globals.G_OPR_CREATE THEN

            l_Assignment_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_Assignment_rec :=
            MRP_Assignment_Util.Convert_Miss_To_Null (l_old_Assignment_rec);

        ELSIF l_Assignment_rec.operation = MRP_Globals.G_OPR_UPDATE
        OR    l_Assignment_rec.operation = MRP_Globals.G_OPR_DELETE
        THEN

            l_Assignment_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_Assignment_rec.Assignment_Id = FND_API.G_MISS_NUM
            THEN

                l_old_Assignment_rec := MRP_Assignment_Handlers.Query_Row
                (   p_Assignment_Id               => l_Assignment_rec.Assignment_Id
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_Assignment_rec :=
                MRP_Assignment_Util.Convert_Miss_To_Null (l_old_Assignment_rec);

            END IF;

            --  Complete new record from old

            l_Assignment_rec := MRP_Assignment_Util.Complete_Record
            (   p_Assignment_rec              => l_Assignment_rec
            ,   p_old_Assignment_rec          => l_old_Assignment_rec
            );

        END IF;

        --  Attribute level validation.

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                MRP_Validate_Assignment.Attributes
                (   x_return_status               => l_return_status
                ,   p_Assignment_rec              => l_Assignment_rec
                ,   p_old_Assignment_rec          => l_old_Assignment_rec
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

            MRP_Assignment_Util.Clear_Dependent_Attr
            (   p_Assignment_rec              => l_Assignment_rec
            ,   p_old_Assignment_rec          => l_old_Assignment_rec
            ,   x_Assignment_rec              => l_Assignment_rec_out
            );
        l_Assignment_rec := l_Assignment_rec_out;

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            MRP_Default_Assignment.Attributes
            (   p_Assignment_rec              => l_Assignment_rec
            ,   x_Assignment_rec              => l_Assignment_rec_out
            );
        l_Assignment_rec := l_Assignment_rec_out;

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            MRP_Assignment_Util.Apply_Attribute_Changes
            (   p_Assignment_rec              => l_Assignment_rec
            ,   p_old_Assignment_rec          => l_old_Assignment_rec
            ,   x_Assignment_rec              => l_Assignment_rec_out
            );
        l_Assignment_rec := l_Assignment_rec_out;

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_Assignment_rec.operation = MRP_Globals.G_OPR_DELETE THEN

                MRP_Validate_Assignment.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_Assignment_rec              => l_Assignment_rec
                );

            ELSE

                MRP_Validate_Assignment.Entity
                (   x_return_status               => l_return_status
                ,   p_Assignment_rec              => l_Assignment_rec
                ,   p_old_Assignment_rec          => l_old_Assignment_rec
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

            IF l_Assignment_rec.operation = MRP_Globals.G_OPR_DELETE THEN

                MRP_Assignment_Handlers.Delete_Row
                (   p_Assignment_Id               => l_Assignment_rec.Assignment_Id
                );

            ELSE

                --  Get Who Information

                l_Assignment_rec.last_update_date := SYSDATE;
                l_Assignment_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_Assignment_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_Assignment_rec.operation = MRP_Globals.G_OPR_UPDATE THEN

                    MRP_Assignment_Handlers.Update_Row (l_Assignment_rec);

                ELSIF l_Assignment_rec.operation = MRP_Globals.G_OPR_CREATE THEN

                    l_Assignment_rec.creation_date := SYSDATE;
                    l_Assignment_rec.created_by    := FND_GLOBAL.USER_ID;

                    MRP_Assignment_Handlers.Insert_Row (l_Assignment_rec);

                END IF;

            END IF;

        END IF;

        --  Load tables.

        l_Assignment_tbl(I)            := l_Assignment_rec;
        l_old_Assignment_tbl(I)        := l_old_Assignment_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_Assignment_rec.return_status := FND_API.G_RET_STS_ERROR;
            l_Assignment_tbl(I)            := l_Assignment_rec;
            l_old_Assignment_tbl(I)        := l_old_Assignment_rec;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_Assignment_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_Assignment_tbl(I)            := l_Assignment_rec;
            l_old_Assignment_tbl(I)        := l_old_Assignment_rec;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_Assignment_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_Assignment_tbl(I)            := l_Assignment_rec;
            l_old_Assignment_tbl(I)        := l_old_Assignment_rec;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Assignments'
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_Assignment_tbl               := l_Assignment_tbl;
    x_old_Assignment_tbl           := l_old_Assignment_tbl;

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
            ,   'Assignments'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Assignments;

--  Start of Comments
--  API name    Process_Assignment
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

PROCEDURE Process_Assignment
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  MRP_GLOBALS.Control_Rec_Type :=
                                        MRP_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_SET_REC
,   p_old_Assignment_Set_rec        IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_SET_REC
,   p_Assignment_tbl                IN  MRP_Src_Assignment_PUB.Assignment_Tbl_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_TBL
,   p_old_Assignment_tbl            IN  MRP_Src_Assignment_PUB.Assignment_Tbl_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_TBL
,   x_Assignment_Set_rec            OUT NOCOPY MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   x_Assignment_tbl                OUT NOCOPY MRP_Src_Assignment_PUB.Assignment_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Assignment';
l_return_status               VARCHAR2(1);
l_control_rec                 MRP_GLOBALS.Control_Rec_Type;
l_Assignment_Set_rec          MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type := p_Assignment_Set_rec;
l_old_Assignment_Set_rec      MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type := p_old_Assignment_Set_rec;
l_Assignment_rec              MRP_Src_Assignment_PUB.Assignment_Rec_Type;
l_Assignment_tbl              MRP_Src_Assignment_PUB.Assignment_Tbl_Type;
l_old_Assignment_rec          MRP_Src_Assignment_PUB.Assignment_Rec_Type;
l_old_Assignment_tbl          MRP_Src_Assignment_PUB.Assignment_Tbl_Type;
l_old_Assignment_tbl_out          MRP_Src_Assignment_PUB.Assignment_Tbl_Type;

l_Assignment_Set_rec_out          MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type := p_Assignment_Set_rec;
l_old_Assignment_Set_rec_out      MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type := p_old_Assignment_Set_rec;
l_Assignment_rec_out              MRP_Src_Assignment_PUB.Assignment_Rec_Type;
l_Assignment_tbl_out              MRP_Src_Assignment_PUB.Assignment_Tbl_Type;

l_src_rule_org_id	      NUMBER;
l_category_set_id	      NUMBER;
l_organization_id             NUMBER := FND_API.G_MISS_NUM;

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

    --  Set Save point.
    SAVEPOINT Process_Assignment_PVT;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Init local table variables.

    l_Assignment_tbl               := p_Assignment_tbl;
    l_old_Assignment_tbl           := p_old_Assignment_tbl;

    --  Assignment_Set

    Assignment_Set
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_Assignment_Set_rec          => l_Assignment_Set_rec
    ,   p_old_Assignment_Set_rec      => l_old_Assignment_Set_rec
    ,   x_Assignment_Set_rec          => l_Assignment_Set_rec_out
    ,   x_old_Assignment_Set_rec      => l_old_Assignment_Set_rec_out
    );
    l_Assignment_Set_rec := l_Assignment_Set_rec_out;
    l_old_Assignment_Set_rec := l_old_Assignment_Set_rec_out;

    --  Perform Assignment_Set group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = MRP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = MRP_GLOBALS.G_ENTITY_ASSIGNMENT_SET)
    THEN

        NULL;

    END IF;

    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_Assignment_tbl.COUNT LOOP

        l_Assignment_rec := l_Assignment_tbl(I);

        IF l_Assignment_rec.operation = MRP_Globals.G_OPR_CREATE
        AND (l_Assignment_rec.Assignment_Set_Id IS NULL OR
            l_Assignment_rec.Assignment_Set_Id = FND_API.G_MISS_NUM)
        THEN

            --  Copy parent_id.

            l_Assignment_tbl(I).Assignment_Set_Id := l_Assignment_Set_rec.Assignment_Set_Id;
        END IF;
    END LOOP;

    --  Assignments

    Assignments
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_Assignment_tbl              => l_Assignment_tbl
    ,   p_old_Assignment_tbl          => l_old_Assignment_tbl
    ,   x_Assignment_tbl              => l_Assignment_tbl_out
    ,   x_old_Assignment_tbl          => l_old_Assignment_tbl_out
    );
    l_Assignment_tbl := l_Assignment_tbl_out;
    l_old_Assignment_tbl := l_old_Assignment_tbl_out;

    --  Perform Assignment group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = MRP_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = MRP_GLOBALS.G_ENTITY_ASSIGNMENT)
    THEN

    FOR I IN 1..l_Assignment_tbl.COUNT LOOP

        l_Assignment_rec := l_Assignment_tbl(I);

	BEGIN
            SELECT organization_id
	    INTO   l_src_rule_org_id
	    FROM   MRP_SOURCING_RULES
	    WHERE  sourcing_rule_id = l_Assignment_rec.sourcing_rule_id;
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		NULL;
	END;

	IF (l_Assignment_rec.assignment_type = 1 OR
	    	l_Assignment_rec.assignment_type = 2 OR
		    l_Assignment_rec.assignment_type = 3) AND
	    (l_src_rule_org_id <> NULL AND
			l_Assignment_rec.Sourcing_Rule_Type <> 2) THEN
            FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Sourcing_Rule_Type');
            FND_MESSAGE.SET_TOKEN('DETAILS',
		'Cannot use local Sourcing Rule for this assignment');
            FND_MSG_PUB.Add;
	    l_Assignment_tbl(I).return_status := FND_API.G_RET_STS_ERROR;
  	END IF;

	IF (l_Assignment_rec.assignment_type = 4 OR
	    	l_Assignment_rec.assignment_type = 5 OR
		    l_Assignment_rec.assignment_type = 6) AND
			l_Assignment_rec.Sourcing_Rule_Type = 2 THEN
            FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Sourcing_Rule_Type');
            FND_MESSAGE.SET_TOKEN('DETAILS',
		'Cannot use a Bill of Distribution for this assignment');
            FND_MSG_PUB.Add;
	    l_Assignment_tbl(I).return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	l_category_set_id := FND_PROFILE.value('MRP_SRA_CATEGORY_SET');

	IF l_category_set_id is NULL AND
			l_Assignment_rec.category_id IS NOT NULL THEN
            FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Category_Set_Id');
            FND_MESSAGE.SET_TOKEN('DETAILS',
		'Category_Set_Id cannot be NULL');
            FND_MSG_PUB.Add;
	    l_Assignment_tbl(I).return_status := FND_API.G_RET_STS_ERROR;
	END IF;

        -- if Customer and Ship to site are passed in and there is
        -- an organization modelled as this Customer at this site,
        -- populate the source_organization_id

        l_organization_id := FND_API.G_MISS_NUM;
        BEGIN
            SELECT organization_id
            INTO   l_organization_id
            FROM   mrp_cust_sup_org_v
            WHERE  Customer_Id = to_char(l_Assignment_rec.Customer_Id)
            AND    Ship_To_Site_Id = to_char(l_Assignment_rec.Ship_To_Site_Id);

            IF l_organization_id IS NOT NULL AND
                           l_organization_id <> FND_API.G_MISS_NUM THEN
               UPDATE mrp_sr_assignments
               SET    organization_id = l_organization_id
               WHERE  assignment_id = l_Assignment_rec.assignment_id;

           END IF;
       EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
       END;

    END LOOP;

    END IF;

    --  Step 6. Perform Object group logic

    IF p_control_rec.process AND
        p_control_rec.process_entity = MRP_GLOBALS.G_ENTITY_ALL
    THEN

        NULL;

    END IF;

    --  Done processing, load OUT parameters.

    x_Assignment_Set_rec           := l_Assignment_Set_rec;
    x_Assignment_tbl               := l_Assignment_tbl;

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

    IF l_Assignment_Set_rec.return_status = FND_API.G_RET_STS_ERROR THEN
    	ROLLBACK TO Process_Assignment_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    FOR I IN 1..l_Assignment_tbl.COUNT LOOP

        IF l_Assignment_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
    	    ROLLBACK TO Process_Assignment_PVT;
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
            ,   'Process_Assignment'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Assignment;

--  Start of Comments
--  API name    Lock_Assignment
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

PROCEDURE Lock_Assignment
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_SET_REC
,   p_Assignment_tbl                IN  MRP_Src_Assignment_PUB.Assignment_Tbl_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_TBL
,   x_Assignment_Set_rec            OUT NOCOPY MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   x_Assignment_tbl                OUT NOCOPY MRP_Src_Assignment_PUB.Assignment_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Assignment';
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_Assignment_rec              MRP_Src_Assignment_PUB.Assignment_Rec_Type;
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

    SAVEPOINT Lock_Assignment_PVT;

    --  Lock Assignment_Set

    IF p_Assignment_Set_rec.operation = MRP_Globals.G_OPR_LOCK THEN

        MRP_Assignment_Set_Handlers.Lock_Row
        (   p_Assignment_Set_rec          => p_Assignment_Set_rec
        ,   x_Assignment_Set_rec          => x_Assignment_Set_rec
        ,   x_return_status               => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    END IF;

    --  Lock Assignment

    FOR I IN 1..p_Assignment_tbl.COUNT LOOP

        IF p_Assignment_tbl(I).operation = MRP_Globals.G_OPR_LOCK THEN

            MRP_Assignment_Handlers.Lock_Row
            (   p_Assignment_rec              => p_Assignment_tbl(I)
            ,   x_Assignment_rec              => l_Assignment_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_Assignment_tbl(I)            := l_Assignment_rec;

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

        ROLLBACK TO Lock_Assignment_PVT;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Assignment_PVT;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Assignment'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Assignment_PVT;

END Lock_Assignment;

--  Start of Comments
--  API name    Get_Assignment
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

PROCEDURE Get_Assignment
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_Assignment_Set_Id             IN  NUMBER
,   x_Assignment_Set_rec            OUT NOCOPY MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   x_Assignment_tbl                OUT NOCOPY MRP_Src_Assignment_PUB.Assignment_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Assignment';
l_Assignment_Set_rec          MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type;
l_Assignment_tbl              MRP_Src_Assignment_PUB.Assignment_Tbl_Type;
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

    --  Get Assignment_Set

    l_Assignment_Set_rec :=  MRP_Assignment_Set_Handlers.Query_Row
    (   p_Assignment_Set_Id           => p_Assignment_Set_Id
    );

    --  Get Assignment ( parent = Assignment_Set )

    l_Assignment_tbl :=  MRP_Assignment_Handlers.Query_Rows
    (   p_Assignment_Set_Id           => l_Assignment_Set_rec.Assignment_Set_Id
    );


    --  Load out parameters

    x_Assignment_Set_rec           := l_Assignment_Set_rec;
    x_Assignment_tbl               := l_Assignment_tbl;

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
            ,   'Get_Assignment'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Assignment;

END MRP_Assignment_PVT;

/
