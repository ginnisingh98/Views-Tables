--------------------------------------------------------
--  DDL for Package Body WIP_WIP_ENTITIES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WIP_ENTITIES_UTIL" AS
/* $Header: WIPUWENB.pls 115.7 2002/12/01 18:13:29 simishra ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'WIP_Wip_Entities_Util';


--  Function Complete_Record

FUNCTION Complete_Record
(   p_Wip_Entities_rec              IN  WIP_Work_Order_PUB.Wip_Entities_Rec_Type
,   p_old_Wip_Entities_rec          IN  WIP_Work_Order_PUB.Wip_Entities_Rec_Type
) RETURN WIP_Work_Order_PUB.Wip_Entities_Rec_Type
IS
l_Wip_Entities_rec            WIP_Work_Order_PUB.Wip_Entities_Rec_Type := p_Wip_Entities_rec;
BEGIN

    IF l_Wip_Entities_rec.created_by = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.created_by := p_old_Wip_Entities_rec.created_by;
    END IF;

    IF l_Wip_Entities_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_Wip_Entities_rec.creation_date := p_old_Wip_Entities_rec.creation_date;
    END IF;

    IF l_Wip_Entities_rec.description = FND_API.G_MISS_CHAR THEN
        l_Wip_Entities_rec.description := p_old_Wip_Entities_rec.description;
    END IF;

    IF l_Wip_Entities_rec.entity_type = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.entity_type := p_old_Wip_Entities_rec.entity_type;
    END IF;

    IF l_Wip_Entities_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.last_updated_by := p_old_Wip_Entities_rec.last_updated_by;
    END IF;

    IF l_Wip_Entities_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_Wip_Entities_rec.last_update_date := p_old_Wip_Entities_rec.last_update_date;
    END IF;

    IF l_Wip_Entities_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.last_update_login := p_old_Wip_Entities_rec.last_update_login;
    END IF;

    IF l_Wip_Entities_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.organization_id := p_old_Wip_Entities_rec.organization_id;
    END IF;

    IF l_Wip_Entities_rec.primary_item_id = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.primary_item_id := p_old_Wip_Entities_rec.primary_item_id;
    END IF;

    IF l_Wip_Entities_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.program_application_id := p_old_Wip_Entities_rec.program_application_id;
    END IF;

    IF l_Wip_Entities_rec.program_id = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.program_id := p_old_Wip_Entities_rec.program_id;
    END IF;

    IF l_Wip_Entities_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_Wip_Entities_rec.program_update_date := p_old_Wip_Entities_rec.program_update_date;
    END IF;

    IF l_Wip_Entities_rec.request_id = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.request_id := p_old_Wip_Entities_rec.request_id;
    END IF;

    IF l_Wip_Entities_rec.wip_entity_id = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.wip_entity_id := p_old_Wip_Entities_rec.wip_entity_id;
    END IF;

    IF l_Wip_Entities_rec.wip_entity_name = FND_API.G_MISS_CHAR THEN
        l_Wip_Entities_rec.wip_entity_name := p_old_Wip_Entities_rec.wip_entity_name;
    END IF;

    RETURN l_Wip_Entities_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_Wip_Entities_rec              IN  WIP_Work_Order_PUB.Wip_Entities_Rec_Type
) RETURN WIP_Work_Order_PUB.Wip_Entities_Rec_Type
IS
l_Wip_Entities_rec            WIP_Work_Order_PUB.Wip_Entities_Rec_Type := p_Wip_Entities_rec;
BEGIN

    IF l_Wip_Entities_rec.created_by = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.created_by := NULL;
    END IF;

    IF l_Wip_Entities_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_Wip_Entities_rec.creation_date := NULL;
    END IF;

    IF l_Wip_Entities_rec.description = FND_API.G_MISS_CHAR THEN
        l_Wip_Entities_rec.description := NULL;
    END IF;

    IF l_Wip_Entities_rec.entity_type = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.entity_type := NULL;
    END IF;

    IF l_Wip_Entities_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.last_updated_by := NULL;
    END IF;

    IF l_Wip_Entities_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_Wip_Entities_rec.last_update_date := NULL;
    END IF;

    IF l_Wip_Entities_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.last_update_login := NULL;
    END IF;

    IF l_Wip_Entities_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.organization_id := NULL;
    END IF;

    IF l_Wip_Entities_rec.primary_item_id = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.primary_item_id := NULL;
    END IF;

    IF l_Wip_Entities_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.program_application_id := NULL;
    END IF;

    IF l_Wip_Entities_rec.program_id = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.program_id := NULL;
    END IF;

    IF l_Wip_Entities_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_Wip_Entities_rec.program_update_date := NULL;
    END IF;

    IF l_Wip_Entities_rec.request_id = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.request_id := NULL;
    END IF;

    IF l_Wip_Entities_rec.wip_entity_id = FND_API.G_MISS_NUM THEN
        l_Wip_Entities_rec.wip_entity_id := NULL;
    END IF;

    IF l_Wip_Entities_rec.wip_entity_name = FND_API.G_MISS_CHAR THEN
        l_Wip_Entities_rec.wip_entity_name := NULL;
    END IF;

    RETURN l_Wip_Entities_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Wip_Entities_rec              IN  WIP_Work_Order_PUB.Wip_Entities_Rec_Type
)
IS
BEGIN

    UPDATE  WIP_ENTITIES
    SET     CREATED_BY                     = p_Wip_Entities_rec.created_by
    ,       CREATION_DATE                  = p_Wip_Entities_rec.creation_date
    ,       DESCRIPTION                    = p_Wip_Entities_rec.description
    ,       ENTITY_TYPE                    = p_Wip_Entities_rec.entity_type
    ,       LAST_UPDATED_BY                = p_Wip_Entities_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_Wip_Entities_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_Wip_Entities_rec.last_update_login
    ,       ORGANIZATION_ID                = p_Wip_Entities_rec.organization_id
    ,       PRIMARY_ITEM_ID                = p_Wip_Entities_rec.primary_item_id
    ,       PROGRAM_APPLICATION_ID         = p_Wip_Entities_rec.program_application_id
    ,       PROGRAM_ID                     = p_Wip_Entities_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_Wip_Entities_rec.program_update_date
    ,       REQUEST_ID                     = p_Wip_Entities_rec.request_id
    ,       WIP_ENTITY_ID                  = p_Wip_Entities_rec.wip_entity_id
    ,       WIP_ENTITY_NAME                = p_Wip_Entities_rec.wip_entity_name
    WHERE   WIP_ENTITY_ID = p_Wip_Entities_rec.wip_entity_id
    ;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Wip_Entities_rec              IN  WIP_Work_Order_PUB.Wip_Entities_Rec_Type
)
IS
BEGIN

    INSERT  INTO WIP_ENTITIES
    (       CREATED_BY
    ,       CREATION_DATE
    ,       DESCRIPTION
    ,       ENTITY_TYPE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       ORGANIZATION_ID
    ,       PRIMARY_ITEM_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       WIP_ENTITY_ID
    ,       WIP_ENTITY_NAME
    )
    VALUES
    (       p_Wip_Entities_rec.created_by
    ,       p_Wip_Entities_rec.creation_date
    ,       p_Wip_Entities_rec.description
    ,       p_Wip_Entities_rec.entity_type
    ,       p_Wip_Entities_rec.last_updated_by
    ,       p_Wip_Entities_rec.last_update_date
    ,       p_Wip_Entities_rec.last_update_login
    ,       p_Wip_Entities_rec.organization_id
    ,       p_Wip_Entities_rec.primary_item_id
    ,       p_Wip_Entities_rec.program_application_id
    ,       p_Wip_Entities_rec.program_id
    ,       p_Wip_Entities_rec.program_update_date
    ,       p_Wip_Entities_rec.request_id
    ,       p_Wip_Entities_rec.wip_entity_id
    ,       p_Wip_Entities_rec.wip_entity_name
    );

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_wip_entity_id                 IN  NUMBER
)
IS
BEGIN

    DELETE  FROM WIP_ENTITIES
    WHERE   WIP_ENTITY_ID = p_wip_entity_id
    ;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

--  Function Query_Row

FUNCTION Query_Row
(   p_wip_entity_id                 IN  NUMBER
) RETURN WIP_Work_Order_PUB.Wip_Entities_Rec_Type
IS
l_Wip_Entities_rec            WIP_Work_Order_PUB.Wip_Entities_Rec_Type;
BEGIN

    SELECT  CREATED_BY
    ,       CREATION_DATE
    ,       DESCRIPTION
    ,       ENTITY_TYPE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       ORGANIZATION_ID
    ,       PRIMARY_ITEM_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       WIP_ENTITY_ID
    ,       WIP_ENTITY_NAME
    INTO    l_Wip_Entities_rec.created_by
    ,       l_Wip_Entities_rec.creation_date
    ,       l_Wip_Entities_rec.description
    ,       l_Wip_Entities_rec.entity_type
    ,       l_Wip_Entities_rec.last_updated_by
    ,       l_Wip_Entities_rec.last_update_date
    ,       l_Wip_Entities_rec.last_update_login
    ,       l_Wip_Entities_rec.organization_id
    ,       l_Wip_Entities_rec.primary_item_id
    ,       l_Wip_Entities_rec.program_application_id
    ,       l_Wip_Entities_rec.program_id
    ,       l_Wip_Entities_rec.program_update_date
    ,       l_Wip_Entities_rec.request_id
    ,       l_Wip_Entities_rec.wip_entity_id
    ,       l_Wip_Entities_rec.wip_entity_name
    FROM    WIP_ENTITIES
    WHERE   WIP_ENTITY_ID = p_wip_entity_id
    ;

    RETURN l_Wip_Entities_rec;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Row;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_Wip_Entities_rec              IN  WIP_Work_Order_PUB.Wip_Entities_Rec_Type
,   x_Wip_Entities_rec              OUT NOCOPY WIP_Work_Order_PUB.Wip_Entities_Rec_Type
)
IS
l_Wip_Entities_rec            WIP_Work_Order_PUB.Wip_Entities_Rec_Type;
BEGIN

    SELECT  CREATED_BY
    ,       CREATION_DATE
    ,       DESCRIPTION
    ,       ENTITY_TYPE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       ORGANIZATION_ID
    ,       PRIMARY_ITEM_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       WIP_ENTITY_ID
    ,       WIP_ENTITY_NAME
    INTO    l_Wip_Entities_rec.created_by
    ,       l_Wip_Entities_rec.creation_date
    ,       l_Wip_Entities_rec.description
    ,       l_Wip_Entities_rec.entity_type
    ,       l_Wip_Entities_rec.last_updated_by
    ,       l_Wip_Entities_rec.last_update_date
    ,       l_Wip_Entities_rec.last_update_login
    ,       l_Wip_Entities_rec.organization_id
    ,       l_Wip_Entities_rec.primary_item_id
    ,       l_Wip_Entities_rec.program_application_id
    ,       l_Wip_Entities_rec.program_id
    ,       l_Wip_Entities_rec.program_update_date
    ,       l_Wip_Entities_rec.request_id
    ,       l_Wip_Entities_rec.wip_entity_id
    ,       l_Wip_Entities_rec.wip_entity_name
    FROM    WIP_ENTITIES
    WHERE   WIP_ENTITY_ID = p_Wip_Entities_rec.wip_entity_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  WIP_GLOBALS.Equal(p_Wip_Entities_rec.created_by,
                         l_Wip_Entities_rec.created_by)
    AND WIP_GLOBALS.Equal(p_Wip_Entities_rec.creation_date,
                         l_Wip_Entities_rec.creation_date)
    AND WIP_GLOBALS.Equal(p_Wip_Entities_rec.description,
                         l_Wip_Entities_rec.description)
    AND WIP_GLOBALS.Equal(p_Wip_Entities_rec.entity_type,
                         l_Wip_Entities_rec.entity_type)
    AND WIP_GLOBALS.Equal(p_Wip_Entities_rec.last_updated_by,
                         l_Wip_Entities_rec.last_updated_by)
    AND WIP_GLOBALS.Equal(p_Wip_Entities_rec.last_update_date,
                         l_Wip_Entities_rec.last_update_date)
    AND WIP_GLOBALS.Equal(p_Wip_Entities_rec.last_update_login,
                         l_Wip_Entities_rec.last_update_login)
    AND WIP_GLOBALS.Equal(p_Wip_Entities_rec.organization_id,
                         l_Wip_Entities_rec.organization_id)
    AND WIP_GLOBALS.Equal(p_Wip_Entities_rec.primary_item_id,
                         l_Wip_Entities_rec.primary_item_id)
    AND WIP_GLOBALS.Equal(p_Wip_Entities_rec.program_application_id,
                         l_Wip_Entities_rec.program_application_id)
    AND WIP_GLOBALS.Equal(p_Wip_Entities_rec.program_id,
                         l_Wip_Entities_rec.program_id)
    AND WIP_GLOBALS.Equal(p_Wip_Entities_rec.program_update_date,
                         l_Wip_Entities_rec.program_update_date)
    AND WIP_GLOBALS.Equal(p_Wip_Entities_rec.request_id,
                         l_Wip_Entities_rec.request_id)
    AND WIP_GLOBALS.Equal(p_Wip_Entities_rec.wip_entity_id,
                         l_Wip_Entities_rec.wip_entity_id)
    AND WIP_GLOBALS.Equal(p_Wip_Entities_rec.wip_entity_name,
                         l_Wip_Entities_rec.wip_entity_name)
    THEN

        --  Row has not changed. Set out parameter.

        x_Wip_Entities_rec             := l_Wip_Entities_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_Wip_Entities_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Wip_Entities_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','OE_LOCK_ROW_CHANGED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;
EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Wip_Entities_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','OE_LOCK_ROW_DELETED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Wip_Entities_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','OE_LOCK_ROW_ALREADY_LOCKED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Wip_Entities_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;


END WIP_Wip_Entities_Util;

/
