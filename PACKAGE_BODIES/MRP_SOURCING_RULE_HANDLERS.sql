--------------------------------------------------------
--  DDL for Package Body MRP_SOURCING_RULE_HANDLERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_SOURCING_RULE_HANDLERS" AS
/* $Header: MRPHSRLB.pls 115.1 99/07/16 12:23:27 porting ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Sourcing_Rule_Handlers';

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Sourcing_Rule_rec             IN  MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
)
IS
BEGIN

    UPDATE  MRP_SOURCING_RULES
    SET     SOURCING_RULE_ID               = p_Sourcing_Rule_rec.Sourcing_Rule_Id
    ,       ATTRIBUTE1                     = p_Sourcing_Rule_rec.Attribute1
    ,       ATTRIBUTE10                    = p_Sourcing_Rule_rec.Attribute10
    ,       ATTRIBUTE11                    = p_Sourcing_Rule_rec.Attribute11
    ,       ATTRIBUTE12                    = p_Sourcing_Rule_rec.Attribute12
    ,       ATTRIBUTE13                    = p_Sourcing_Rule_rec.Attribute13
    ,       ATTRIBUTE14                    = p_Sourcing_Rule_rec.Attribute14
    ,       ATTRIBUTE15                    = p_Sourcing_Rule_rec.Attribute15
    ,       ATTRIBUTE2                     = p_Sourcing_Rule_rec.Attribute2
    ,       ATTRIBUTE3                     = p_Sourcing_Rule_rec.Attribute3
    ,       ATTRIBUTE4                     = p_Sourcing_Rule_rec.Attribute4
    ,       ATTRIBUTE5                     = p_Sourcing_Rule_rec.Attribute5
    ,       ATTRIBUTE6                     = p_Sourcing_Rule_rec.Attribute6
    ,       ATTRIBUTE7                     = p_Sourcing_Rule_rec.Attribute7
    ,       ATTRIBUTE8                     = p_Sourcing_Rule_rec.Attribute8
    ,       ATTRIBUTE9                     = p_Sourcing_Rule_rec.Attribute9
    ,       ATTRIBUTE_CATEGORY             = p_Sourcing_Rule_rec.Attribute_Category
    ,       CREATED_BY                     = p_Sourcing_Rule_rec.Created_By
    ,       CREATION_DATE                  = p_Sourcing_Rule_rec.Creation_Date
    ,       DESCRIPTION                    = p_Sourcing_Rule_rec.Description
    ,       LAST_UPDATED_BY                = p_Sourcing_Rule_rec.Last_Updated_By
    ,       LAST_UPDATE_DATE               = p_Sourcing_Rule_rec.Last_Update_Date
    ,       LAST_UPDATE_LOGIN              = p_Sourcing_Rule_rec.Last_Update_Login
    ,       ORGANIZATION_ID                = p_Sourcing_Rule_rec.Organization_Id
    ,       PLANNING_ACTIVE                = p_Sourcing_Rule_rec.Planning_Active
    ,       PROGRAM_APPLICATION_ID         = p_Sourcing_Rule_rec.Program_Application_Id
    ,       PROGRAM_ID                     = p_Sourcing_Rule_rec.Program_Id
    ,       PROGRAM_UPDATE_DATE            = p_Sourcing_Rule_rec.Program_Update_Date
    ,       REQUEST_ID                     = p_Sourcing_Rule_rec.Request_Id
    ,       SOURCING_RULE_NAME             = p_Sourcing_Rule_rec.Sourcing_Rule_Name
    ,       SOURCING_RULE_TYPE             = p_Sourcing_Rule_rec.Sourcing_Rule_Type
    ,       STATUS                         = p_Sourcing_Rule_rec.Status
    WHERE   SOURCING_RULE_ID = p_Sourcing_Rule_rec.Sourcing_Rule_Id
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
(   p_Sourcing_Rule_rec             IN  MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
)
IS
BEGIN

    INSERT  INTO MRP_SOURCING_RULES
    (       SOURCING_RULE_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE_CATEGORY
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DESCRIPTION
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       ORGANIZATION_ID
    ,       PLANNING_ACTIVE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       SOURCING_RULE_NAME
    ,       SOURCING_RULE_TYPE
    ,       STATUS
    )
    VALUES
    (       p_Sourcing_Rule_rec.Sourcing_Rule_Id
    ,       p_Sourcing_Rule_rec.Attribute1
    ,       p_Sourcing_Rule_rec.Attribute10
    ,       p_Sourcing_Rule_rec.Attribute11
    ,       p_Sourcing_Rule_rec.Attribute12
    ,       p_Sourcing_Rule_rec.Attribute13
    ,       p_Sourcing_Rule_rec.Attribute14
    ,       p_Sourcing_Rule_rec.Attribute15
    ,       p_Sourcing_Rule_rec.Attribute2
    ,       p_Sourcing_Rule_rec.Attribute3
    ,       p_Sourcing_Rule_rec.Attribute4
    ,       p_Sourcing_Rule_rec.Attribute5
    ,       p_Sourcing_Rule_rec.Attribute6
    ,       p_Sourcing_Rule_rec.Attribute7
    ,       p_Sourcing_Rule_rec.Attribute8
    ,       p_Sourcing_Rule_rec.Attribute9
    ,       p_Sourcing_Rule_rec.Attribute_Category
    ,       p_Sourcing_Rule_rec.Created_By
    ,       p_Sourcing_Rule_rec.Creation_Date
    ,       p_Sourcing_Rule_rec.Description
    ,       p_Sourcing_Rule_rec.Last_Updated_By
    ,       p_Sourcing_Rule_rec.Last_Update_Date
    ,       p_Sourcing_Rule_rec.Last_Update_Login
    ,       p_Sourcing_Rule_rec.Organization_Id
    ,       p_Sourcing_Rule_rec.Planning_Active
    ,       p_Sourcing_Rule_rec.Program_Application_Id
    ,       p_Sourcing_Rule_rec.Program_Id
    ,       p_Sourcing_Rule_rec.Program_Update_Date
    ,       p_Sourcing_Rule_rec.Request_Id
    ,       p_Sourcing_Rule_rec.Sourcing_Rule_Name
    ,       p_Sourcing_Rule_rec.Sourcing_Rule_Type
    ,       p_Sourcing_Rule_rec.Status
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
(   p_Sourcing_Rule_Id              IN  NUMBER
)
IS

l_sr_receipt_id		NUMBER := FND_API.G_MISS_NUM;

CURSOR cur_Receiving_Org IS
SELECT SR_RECEIPT_ID
FROM   MRP_SR_RECEIPT_ORG
WHERE  SOURCING_RULE_ID = p_Sourcing_Rule_Id;

BEGIN

    -- Before we delete a sourcing Rule/BOD, we need to
    -- delete all the associated receiving orgs and
    -- shipping orgs (Note that deleting a shipping org
    -- is taken care of by the delete handler for rec. org

    OPEN cur_Receiving_Org;

    WHILE TRUE LOOP
	FETCH cur_Receiving_Org
	INTO  l_sr_receipt_id;

	EXIT WHEN cur_Receiving_Org%NOTFOUND;

	MRP_Receiving_Org_Handlers.Delete_Row (
			p_Sr_Receipt_Id => l_sr_receipt_id );

    END LOOP;

    CLOSE cur_Receiving_Org;

    DELETE  FROM MRP_SOURCING_RULES
    WHERE   SOURCING_RULE_ID = p_Sourcing_Rule_Id;

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

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT VARCHAR2
,   p_Sourcing_Rule_rec             IN  MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
,   x_Sourcing_Rule_rec             OUT MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
)
IS
l_Sourcing_Rule_rec           MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type;
BEGIN

    SELECT  SOURCING_RULE_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE_CATEGORY
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DESCRIPTION
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       ORGANIZATION_ID
    ,       PLANNING_ACTIVE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       SOURCING_RULE_NAME
    ,       SOURCING_RULE_TYPE
    ,       STATUS
    INTO    l_Sourcing_Rule_rec.Sourcing_Rule_Id
    ,       l_Sourcing_Rule_rec.Attribute1
    ,       l_Sourcing_Rule_rec.Attribute10
    ,       l_Sourcing_Rule_rec.Attribute11
    ,       l_Sourcing_Rule_rec.Attribute12
    ,       l_Sourcing_Rule_rec.Attribute13
    ,       l_Sourcing_Rule_rec.Attribute14
    ,       l_Sourcing_Rule_rec.Attribute15
    ,       l_Sourcing_Rule_rec.Attribute2
    ,       l_Sourcing_Rule_rec.Attribute3
    ,       l_Sourcing_Rule_rec.Attribute4
    ,       l_Sourcing_Rule_rec.Attribute5
    ,       l_Sourcing_Rule_rec.Attribute6
    ,       l_Sourcing_Rule_rec.Attribute7
    ,       l_Sourcing_Rule_rec.Attribute8
    ,       l_Sourcing_Rule_rec.Attribute9
    ,       l_Sourcing_Rule_rec.Attribute_Category
    ,       l_Sourcing_Rule_rec.Created_By
    ,       l_Sourcing_Rule_rec.Creation_Date
    ,       l_Sourcing_Rule_rec.Description
    ,       l_Sourcing_Rule_rec.Last_Updated_By
    ,       l_Sourcing_Rule_rec.Last_Update_Date
    ,       l_Sourcing_Rule_rec.Last_Update_Login
    ,       l_Sourcing_Rule_rec.Organization_Id
    ,       l_Sourcing_Rule_rec.Planning_Active
    ,       l_Sourcing_Rule_rec.Program_Application_Id
    ,       l_Sourcing_Rule_rec.Program_Id
    ,       l_Sourcing_Rule_rec.Program_Update_Date
    ,       l_Sourcing_Rule_rec.Request_Id
    ,       l_Sourcing_Rule_rec.Sourcing_Rule_Name
    ,       l_Sourcing_Rule_rec.Sourcing_Rule_Type
    ,       l_Sourcing_Rule_rec.Status
    FROM    MRP_SOURCING_RULES
    WHERE   SOURCING_RULE_ID = p_Sourcing_Rule_rec.Sourcing_Rule_Id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  (   (l_Sourcing_Rule_rec.Sourcing_Rule_Id =
             p_Sourcing_Rule_rec.Sourcing_Rule_Id) OR
            ((p_Sourcing_Rule_rec.Sourcing_Rule_Id = FND_API.G_MISS_NUM) OR
            (   (l_Sourcing_Rule_rec.Sourcing_Rule_Id IS NULL) AND
                (p_Sourcing_Rule_rec.Sourcing_Rule_Id IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Attribute1 =
             p_Sourcing_Rule_rec.Attribute1) OR
            ((p_Sourcing_Rule_rec.Attribute1 = FND_API.G_MISS_CHAR) OR
            (   (l_Sourcing_Rule_rec.Attribute1 IS NULL) AND
                (p_Sourcing_Rule_rec.Attribute1 IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Attribute10 =
             p_Sourcing_Rule_rec.Attribute10) OR
            ((p_Sourcing_Rule_rec.Attribute10 = FND_API.G_MISS_CHAR) OR
            (   (l_Sourcing_Rule_rec.Attribute10 IS NULL) AND
                (p_Sourcing_Rule_rec.Attribute10 IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Attribute11 =
             p_Sourcing_Rule_rec.Attribute11) OR
            ((p_Sourcing_Rule_rec.Attribute11 = FND_API.G_MISS_CHAR) OR
            (   (l_Sourcing_Rule_rec.Attribute11 IS NULL) AND
                (p_Sourcing_Rule_rec.Attribute11 IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Attribute12 =
             p_Sourcing_Rule_rec.Attribute12) OR
            ((p_Sourcing_Rule_rec.Attribute12 = FND_API.G_MISS_CHAR) OR
            (   (l_Sourcing_Rule_rec.Attribute12 IS NULL) AND
                (p_Sourcing_Rule_rec.Attribute12 IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Attribute13 =
             p_Sourcing_Rule_rec.Attribute13) OR
            ((p_Sourcing_Rule_rec.Attribute13 = FND_API.G_MISS_CHAR) OR
            (   (l_Sourcing_Rule_rec.Attribute13 IS NULL) AND
                (p_Sourcing_Rule_rec.Attribute13 IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Attribute14 =
             p_Sourcing_Rule_rec.Attribute14) OR
            ((p_Sourcing_Rule_rec.Attribute14 = FND_API.G_MISS_CHAR) OR
            (   (l_Sourcing_Rule_rec.Attribute14 IS NULL) AND
                (p_Sourcing_Rule_rec.Attribute14 IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Attribute15 =
             p_Sourcing_Rule_rec.Attribute15) OR
            ((p_Sourcing_Rule_rec.Attribute15 = FND_API.G_MISS_CHAR) OR
            (   (l_Sourcing_Rule_rec.Attribute15 IS NULL) AND
                (p_Sourcing_Rule_rec.Attribute15 IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Attribute2 =
             p_Sourcing_Rule_rec.Attribute2) OR
            ((p_Sourcing_Rule_rec.Attribute2 = FND_API.G_MISS_CHAR) OR
            (   (l_Sourcing_Rule_rec.Attribute2 IS NULL) AND
                (p_Sourcing_Rule_rec.Attribute2 IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Attribute3 =
             p_Sourcing_Rule_rec.Attribute3) OR
            ((p_Sourcing_Rule_rec.Attribute3 = FND_API.G_MISS_CHAR) OR
            (   (l_Sourcing_Rule_rec.Attribute3 IS NULL) AND
                (p_Sourcing_Rule_rec.Attribute3 IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Attribute4 =
             p_Sourcing_Rule_rec.Attribute4) OR
            ((p_Sourcing_Rule_rec.Attribute4 = FND_API.G_MISS_CHAR) OR
            (   (l_Sourcing_Rule_rec.Attribute4 IS NULL) AND
                (p_Sourcing_Rule_rec.Attribute4 IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Attribute5 =
             p_Sourcing_Rule_rec.Attribute5) OR
            ((p_Sourcing_Rule_rec.Attribute5 = FND_API.G_MISS_CHAR) OR
            (   (l_Sourcing_Rule_rec.Attribute5 IS NULL) AND
                (p_Sourcing_Rule_rec.Attribute5 IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Attribute6 =
             p_Sourcing_Rule_rec.Attribute6) OR
            ((p_Sourcing_Rule_rec.Attribute6 = FND_API.G_MISS_CHAR) OR
            (   (l_Sourcing_Rule_rec.Attribute6 IS NULL) AND
                (p_Sourcing_Rule_rec.Attribute6 IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Attribute7 =
             p_Sourcing_Rule_rec.Attribute7) OR
            ((p_Sourcing_Rule_rec.Attribute7 = FND_API.G_MISS_CHAR) OR
            (   (l_Sourcing_Rule_rec.Attribute7 IS NULL) AND
                (p_Sourcing_Rule_rec.Attribute7 IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Attribute8 =
             p_Sourcing_Rule_rec.Attribute8) OR
            ((p_Sourcing_Rule_rec.Attribute8 = FND_API.G_MISS_CHAR) OR
            (   (l_Sourcing_Rule_rec.Attribute8 IS NULL) AND
                (p_Sourcing_Rule_rec.Attribute8 IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Attribute9 =
             p_Sourcing_Rule_rec.Attribute9) OR
            ((p_Sourcing_Rule_rec.Attribute9 = FND_API.G_MISS_CHAR) OR
            (   (l_Sourcing_Rule_rec.Attribute9 IS NULL) AND
                (p_Sourcing_Rule_rec.Attribute9 IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Attribute_Category =
             p_Sourcing_Rule_rec.Attribute_Category) OR
            ((p_Sourcing_Rule_rec.Attribute_Category = FND_API.G_MISS_CHAR) OR
            (   (l_Sourcing_Rule_rec.Attribute_Category IS NULL) AND
                (p_Sourcing_Rule_rec.Attribute_Category IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Created_By =
             p_Sourcing_Rule_rec.Created_By) OR
            ((p_Sourcing_Rule_rec.Created_By = FND_API.G_MISS_NUM) OR
            (   (l_Sourcing_Rule_rec.Created_By IS NULL) AND
                (p_Sourcing_Rule_rec.Created_By IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Creation_Date =
             p_Sourcing_Rule_rec.Creation_Date) OR
            ((p_Sourcing_Rule_rec.Creation_Date = FND_API.G_MISS_DATE) OR
            (   (l_Sourcing_Rule_rec.Creation_Date IS NULL) AND
                (p_Sourcing_Rule_rec.Creation_Date IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Description =
             p_Sourcing_Rule_rec.Description) OR
            ((p_Sourcing_Rule_rec.Description = FND_API.G_MISS_CHAR) OR
            (   (l_Sourcing_Rule_rec.Description IS NULL) AND
                (p_Sourcing_Rule_rec.Description IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Last_Updated_By =
             p_Sourcing_Rule_rec.Last_Updated_By) OR
            ((p_Sourcing_Rule_rec.Last_Updated_By = FND_API.G_MISS_NUM) OR
            (   (l_Sourcing_Rule_rec.Last_Updated_By IS NULL) AND
                (p_Sourcing_Rule_rec.Last_Updated_By IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Last_Update_Date =
             p_Sourcing_Rule_rec.Last_Update_Date) OR
            ((p_Sourcing_Rule_rec.Last_Update_Date = FND_API.G_MISS_DATE) OR
            (   (l_Sourcing_Rule_rec.Last_Update_Date IS NULL) AND
                (p_Sourcing_Rule_rec.Last_Update_Date IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Last_Update_Login =
             p_Sourcing_Rule_rec.Last_Update_Login) OR
            ((p_Sourcing_Rule_rec.Last_Update_Login = FND_API.G_MISS_NUM) OR
            (   (l_Sourcing_Rule_rec.Last_Update_Login IS NULL) AND
                (p_Sourcing_Rule_rec.Last_Update_Login IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Organization_Id =
             p_Sourcing_Rule_rec.Organization_Id) OR
            ((p_Sourcing_Rule_rec.Organization_Id = FND_API.G_MISS_NUM) OR
            (   (l_Sourcing_Rule_rec.Organization_Id IS NULL) AND
                (p_Sourcing_Rule_rec.Organization_Id IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Planning_Active =
             p_Sourcing_Rule_rec.Planning_Active) OR
            ((p_Sourcing_Rule_rec.Planning_Active = FND_API.G_MISS_NUM) OR
            (   (l_Sourcing_Rule_rec.Planning_Active IS NULL) AND
                (p_Sourcing_Rule_rec.Planning_Active IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Program_Application_Id =
             p_Sourcing_Rule_rec.Program_Application_Id) OR
            ((p_Sourcing_Rule_rec.Program_Application_Id = FND_API.G_MISS_NUM) OR
            (   (l_Sourcing_Rule_rec.Program_Application_Id IS NULL) AND
                (p_Sourcing_Rule_rec.Program_Application_Id IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Program_Id =
             p_Sourcing_Rule_rec.Program_Id) OR
            ((p_Sourcing_Rule_rec.Program_Id = FND_API.G_MISS_NUM) OR
            (   (l_Sourcing_Rule_rec.Program_Id IS NULL) AND
                (p_Sourcing_Rule_rec.Program_Id IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Program_Update_Date =
             p_Sourcing_Rule_rec.Program_Update_Date) OR
            ((p_Sourcing_Rule_rec.Program_Update_Date = FND_API.G_MISS_DATE) OR
            (   (l_Sourcing_Rule_rec.Program_Update_Date IS NULL) AND
                (p_Sourcing_Rule_rec.Program_Update_Date IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Request_Id =
             p_Sourcing_Rule_rec.Request_Id) OR
            ((p_Sourcing_Rule_rec.Request_Id = FND_API.G_MISS_NUM) OR
            (   (l_Sourcing_Rule_rec.Request_Id IS NULL) AND
                (p_Sourcing_Rule_rec.Request_Id IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Sourcing_Rule_Name =
             p_Sourcing_Rule_rec.Sourcing_Rule_Name) OR
            ((p_Sourcing_Rule_rec.Sourcing_Rule_Name = FND_API.G_MISS_CHAR) OR
            (   (l_Sourcing_Rule_rec.Sourcing_Rule_Name IS NULL) AND
                (p_Sourcing_Rule_rec.Sourcing_Rule_Name IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Sourcing_Rule_Type =
             p_Sourcing_Rule_rec.Sourcing_Rule_Type) OR
            ((p_Sourcing_Rule_rec.Sourcing_Rule_Type = FND_API.G_MISS_NUM) OR
            (   (l_Sourcing_Rule_rec.Sourcing_Rule_Type IS NULL) AND
                (p_Sourcing_Rule_rec.Sourcing_Rule_Type IS NULL))))
    AND (   (l_Sourcing_Rule_rec.Status =
             p_Sourcing_Rule_rec.Status) OR
            ((p_Sourcing_Rule_rec.Status = FND_API.G_MISS_NUM) OR
            (   (l_Sourcing_Rule_rec.Status IS NULL) AND
                (p_Sourcing_Rule_rec.Status IS NULL))))
    THEN

        --  Row has not changed. Set out parameter.

        x_Sourcing_Rule_rec            := l_Sourcing_Rule_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_Sourcing_Rule_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Sourcing_Rule_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','BOI_LOCK_ROW_CHANGED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Sourcing_Rule_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','BOI_LOCK_ROW_DELETED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Sourcing_Rule_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','BOI_LOCK_ROW_ALREADY_LOCKED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Sourcing_Rule_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

--  Function Query_Row

FUNCTION Query_Row
(   p_Sourcing_Rule_Id              IN  NUMBER
) RETURN MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
IS
l_Sourcing_Rule_rec           MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type;
BEGIN

    SELECT  SOURCING_RULE_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE_CATEGORY
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DESCRIPTION
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       ORGANIZATION_ID
    ,       PLANNING_ACTIVE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       SOURCING_RULE_NAME
    ,       SOURCING_RULE_TYPE
    ,       STATUS
    INTO    l_Sourcing_Rule_rec.Sourcing_Rule_Id
    ,       l_Sourcing_Rule_rec.Attribute1
    ,       l_Sourcing_Rule_rec.Attribute10
    ,       l_Sourcing_Rule_rec.Attribute11
    ,       l_Sourcing_Rule_rec.Attribute12
    ,       l_Sourcing_Rule_rec.Attribute13
    ,       l_Sourcing_Rule_rec.Attribute14
    ,       l_Sourcing_Rule_rec.Attribute15
    ,       l_Sourcing_Rule_rec.Attribute2
    ,       l_Sourcing_Rule_rec.Attribute3
    ,       l_Sourcing_Rule_rec.Attribute4
    ,       l_Sourcing_Rule_rec.Attribute5
    ,       l_Sourcing_Rule_rec.Attribute6
    ,       l_Sourcing_Rule_rec.Attribute7
    ,       l_Sourcing_Rule_rec.Attribute8
    ,       l_Sourcing_Rule_rec.Attribute9
    ,       l_Sourcing_Rule_rec.Attribute_Category
    ,       l_Sourcing_Rule_rec.Created_By
    ,       l_Sourcing_Rule_rec.Creation_Date
    ,       l_Sourcing_Rule_rec.Description
    ,       l_Sourcing_Rule_rec.Last_Updated_By
    ,       l_Sourcing_Rule_rec.Last_Update_Date
    ,       l_Sourcing_Rule_rec.Last_Update_Login
    ,       l_Sourcing_Rule_rec.Organization_Id
    ,       l_Sourcing_Rule_rec.Planning_Active
    ,       l_Sourcing_Rule_rec.Program_Application_Id
    ,       l_Sourcing_Rule_rec.Program_Id
    ,       l_Sourcing_Rule_rec.Program_Update_Date
    ,       l_Sourcing_Rule_rec.Request_Id
    ,       l_Sourcing_Rule_rec.Sourcing_Rule_Name
    ,       l_Sourcing_Rule_rec.Sourcing_Rule_Type
    ,       l_Sourcing_Rule_rec.Status
    FROM    MRP_SOURCING_RULES
    WHERE   SOURCING_RULE_ID = p_Sourcing_Rule_Id
    ;

    RETURN l_Sourcing_Rule_rec;

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

--  Procedure Query_Entity

PROCEDURE Query_Entity
(   p_Sourcing_Rule_Id              IN  NUMBER
,   x_Sourcing_Rule_rec             OUT MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type
,   x_Sourcing_Rule_val_rec         OUT MRP_Sourcing_Rule_PUB.Sourcing_Rule_Val_Rec_Type
)
IS
BEGIN

    SELECT  SOURCING_RULE_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE_CATEGORY
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DESCRIPTION
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       ORGANIZATION_ID
    ,       PLANNING_ACTIVE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       SOURCING_RULE_NAME
    ,       SOURCING_RULE_TYPE
    ,       STATUS
    INTO    x_Sourcing_Rule_rec.Sourcing_Rule_Id
    ,       x_Sourcing_Rule_rec.Attribute1
    ,       x_Sourcing_Rule_rec.Attribute10
    ,       x_Sourcing_Rule_rec.Attribute11
    ,       x_Sourcing_Rule_rec.Attribute12
    ,       x_Sourcing_Rule_rec.Attribute13
    ,       x_Sourcing_Rule_rec.Attribute14
    ,       x_Sourcing_Rule_rec.Attribute15
    ,       x_Sourcing_Rule_rec.Attribute2
    ,       x_Sourcing_Rule_rec.Attribute3
    ,       x_Sourcing_Rule_rec.Attribute4
    ,       x_Sourcing_Rule_rec.Attribute5
    ,       x_Sourcing_Rule_rec.Attribute6
    ,       x_Sourcing_Rule_rec.Attribute7
    ,       x_Sourcing_Rule_rec.Attribute8
    ,       x_Sourcing_Rule_rec.Attribute9
    ,       x_Sourcing_Rule_rec.Attribute_Category
    ,       x_Sourcing_Rule_rec.Created_By
    ,       x_Sourcing_Rule_rec.Creation_Date
    ,       x_Sourcing_Rule_rec.Description
    ,       x_Sourcing_Rule_rec.Last_Updated_By
    ,       x_Sourcing_Rule_rec.Last_Update_Date
    ,       x_Sourcing_Rule_rec.Last_Update_Login
    ,       x_Sourcing_Rule_rec.Organization_Id
    ,       x_Sourcing_Rule_rec.Planning_Active
    ,       x_Sourcing_Rule_rec.Program_Application_Id
    ,       x_Sourcing_Rule_rec.Program_Id
    ,       x_Sourcing_Rule_rec.Program_Update_Date
    ,       x_Sourcing_Rule_rec.Request_Id
    ,       x_Sourcing_Rule_rec.Sourcing_Rule_Name
    ,       x_Sourcing_Rule_rec.Sourcing_Rule_Type
    ,       x_Sourcing_Rule_rec.Status
    FROM    MRP_SOURCING_RULES
    WHERE   SOURCING_RULE_ID = p_Sourcing_Rule_Id
    ;


EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Entity'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Entity;

END MRP_Sourcing_Rule_Handlers;

/
