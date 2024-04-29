--------------------------------------------------------
--  DDL for Package Body MRP_ASSIGNMENT_HANDLERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_ASSIGNMENT_HANDLERS" AS
/* $Header: MRPHASNB.pls 115.3 99/07/16 12:21:47 porting ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Assignment_Handlers';

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Assignment_rec                IN  MRP_Src_Assignment_PUB.Assignment_Rec_Type
)
IS
BEGIN

    UPDATE  MRP_SR_ASSIGNMENTS
    SET     ASSIGNMENT_ID                  = p_Assignment_rec.Assignment_Id
    ,       ASSIGNMENT_SET_ID              = p_Assignment_rec.Assignment_Set_Id
    ,       ASSIGNMENT_TYPE                = p_Assignment_rec.Assignment_Type
    ,       ATTRIBUTE1                     = p_Assignment_rec.Attribute1
    ,       ATTRIBUTE10                    = p_Assignment_rec.Attribute10
    ,       ATTRIBUTE11                    = p_Assignment_rec.Attribute11
    ,       ATTRIBUTE12                    = p_Assignment_rec.Attribute12
    ,       ATTRIBUTE13                    = p_Assignment_rec.Attribute13
    ,       ATTRIBUTE14                    = p_Assignment_rec.Attribute14
    ,       ATTRIBUTE15                    = p_Assignment_rec.Attribute15
    ,       ATTRIBUTE2                     = p_Assignment_rec.Attribute2
    ,       ATTRIBUTE3                     = p_Assignment_rec.Attribute3
    ,       ATTRIBUTE4                     = p_Assignment_rec.Attribute4
    ,       ATTRIBUTE5                     = p_Assignment_rec.Attribute5
    ,       ATTRIBUTE6                     = p_Assignment_rec.Attribute6
    ,       ATTRIBUTE7                     = p_Assignment_rec.Attribute7
    ,       ATTRIBUTE8                     = p_Assignment_rec.Attribute8
    ,       ATTRIBUTE9                     = p_Assignment_rec.Attribute9
    ,       ATTRIBUTE_CATEGORY             = p_Assignment_rec.Attribute_Category
    ,       CATEGORY_ID                    = p_Assignment_rec.Category_Id
    ,       CATEGORY_SET_ID                = p_Assignment_rec.Category_Set_Id
    ,       CREATED_BY                     = p_Assignment_rec.Created_By
    ,       CREATION_DATE                  = p_Assignment_rec.Creation_Date
    ,       CUSTOMER_ID                    = p_Assignment_rec.Customer_Id
    ,       INVENTORY_ITEM_ID              = p_Assignment_rec.Inventory_Item_Id
    ,       LAST_UPDATED_BY                = p_Assignment_rec.Last_Updated_By
    ,       LAST_UPDATE_DATE               = p_Assignment_rec.Last_Update_Date
    ,       LAST_UPDATE_LOGIN              = p_Assignment_rec.Last_Update_Login
    ,       ORGANIZATION_ID                = p_Assignment_rec.Organization_Id
    ,       PROGRAM_APPLICATION_ID         = p_Assignment_rec.Program_Application_Id
    ,       PROGRAM_ID                     = p_Assignment_rec.Program_Id
    ,       PROGRAM_UPDATE_DATE            = p_Assignment_rec.Program_Update_Date
    ,       REQUEST_ID                     = p_Assignment_rec.Request_Id
    ,       SECONDARY_INVENTORY            = p_Assignment_rec.Secondary_Inventory
    ,       SHIP_TO_SITE_ID                = p_Assignment_rec.Ship_To_Site_Id
    ,       SOURCING_RULE_ID               = p_Assignment_rec.Sourcing_Rule_Id
    ,       SOURCING_RULE_TYPE             = p_Assignment_rec.Sourcing_Rule_Type
    WHERE   ASSIGNMENT_ID = p_Assignment_rec.Assignment_Id
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
(   p_Assignment_rec                IN  MRP_Src_Assignment_PUB.Assignment_Rec_Type
)
IS
BEGIN

    INSERT  INTO MRP_SR_ASSIGNMENTS
    (       ASSIGNMENT_ID
    ,       ASSIGNMENT_SET_ID
    ,       ASSIGNMENT_TYPE
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
    ,       CATEGORY_ID
    ,       CATEGORY_SET_ID
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CUSTOMER_ID
    ,       INVENTORY_ITEM_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       ORGANIZATION_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       SECONDARY_INVENTORY
    ,       SHIP_TO_SITE_ID
    ,       SOURCING_RULE_ID
    ,       SOURCING_RULE_TYPE
    )
    VALUES
    (       p_Assignment_rec.Assignment_Id
    ,       p_Assignment_rec.Assignment_Set_Id
    ,       p_Assignment_rec.Assignment_Type
    ,       p_Assignment_rec.Attribute1
    ,       p_Assignment_rec.Attribute10
    ,       p_Assignment_rec.Attribute11
    ,       p_Assignment_rec.Attribute12
    ,       p_Assignment_rec.Attribute13
    ,       p_Assignment_rec.Attribute14
    ,       p_Assignment_rec.Attribute15
    ,       p_Assignment_rec.Attribute2
    ,       p_Assignment_rec.Attribute3
    ,       p_Assignment_rec.Attribute4
    ,       p_Assignment_rec.Attribute5
    ,       p_Assignment_rec.Attribute6
    ,       p_Assignment_rec.Attribute7
    ,       p_Assignment_rec.Attribute8
    ,       p_Assignment_rec.Attribute9
    ,       p_Assignment_rec.Attribute_Category
    ,       p_Assignment_rec.Category_Id
    ,       p_Assignment_rec.Category_Set_Id
    ,       p_Assignment_rec.Created_By
    ,       p_Assignment_rec.Creation_Date
    ,       p_Assignment_rec.Customer_Id
    ,       p_Assignment_rec.Inventory_Item_Id
    ,       p_Assignment_rec.Last_Updated_By
    ,       p_Assignment_rec.Last_Update_Date
    ,       p_Assignment_rec.Last_Update_Login
    ,       p_Assignment_rec.Organization_Id
    ,       p_Assignment_rec.Program_Application_Id
    ,       p_Assignment_rec.Program_Id
    ,       p_Assignment_rec.Program_Update_Date
    ,       p_Assignment_rec.Request_Id
    ,       p_Assignment_rec.Secondary_Inventory
    ,       p_Assignment_rec.Ship_To_Site_Id
    ,       p_Assignment_rec.Sourcing_Rule_Id
    ,       p_Assignment_rec.Sourcing_Rule_Type
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
(   p_Assignment_Id                 IN  NUMBER
)
IS
BEGIN

    DELETE  FROM MRP_SR_ASSIGNMENTS
    WHERE   ASSIGNMENT_ID = p_Assignment_Id
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

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT VARCHAR2
,   p_Assignment_rec                IN  MRP_Src_Assignment_PUB.Assignment_Rec_Type
,   x_Assignment_rec                OUT MRP_Src_Assignment_PUB.Assignment_Rec_Type
)
IS
l_Assignment_rec              MRP_Src_Assignment_PUB.Assignment_Rec_Type;
BEGIN

    SELECT  ASSIGNMENT_ID
    ,       ASSIGNMENT_SET_ID
    ,       ASSIGNMENT_TYPE
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
    ,       CATEGORY_ID
    ,       CATEGORY_SET_ID
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CUSTOMER_ID
    ,       INVENTORY_ITEM_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       ORGANIZATION_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       SECONDARY_INVENTORY
    ,       SHIP_TO_SITE_ID
    ,       SOURCING_RULE_ID
    ,       SOURCING_RULE_TYPE
    INTO    l_Assignment_rec.Assignment_Id
    ,       l_Assignment_rec.Assignment_Set_Id
    ,       l_Assignment_rec.Assignment_Type
    ,       l_Assignment_rec.Attribute1
    ,       l_Assignment_rec.Attribute10
    ,       l_Assignment_rec.Attribute11
    ,       l_Assignment_rec.Attribute12
    ,       l_Assignment_rec.Attribute13
    ,       l_Assignment_rec.Attribute14
    ,       l_Assignment_rec.Attribute15
    ,       l_Assignment_rec.Attribute2
    ,       l_Assignment_rec.Attribute3
    ,       l_Assignment_rec.Attribute4
    ,       l_Assignment_rec.Attribute5
    ,       l_Assignment_rec.Attribute6
    ,       l_Assignment_rec.Attribute7
    ,       l_Assignment_rec.Attribute8
    ,       l_Assignment_rec.Attribute9
    ,       l_Assignment_rec.Attribute_Category
    ,       l_Assignment_rec.Category_Id
    ,       l_Assignment_rec.Category_Set_Id
    ,       l_Assignment_rec.Created_By
    ,       l_Assignment_rec.Creation_Date
    ,       l_Assignment_rec.Customer_Id
    ,       l_Assignment_rec.Inventory_Item_Id
    ,       l_Assignment_rec.Last_Updated_By
    ,       l_Assignment_rec.Last_Update_Date
    ,       l_Assignment_rec.Last_Update_Login
    ,       l_Assignment_rec.Organization_Id
    ,       l_Assignment_rec.Program_Application_Id
    ,       l_Assignment_rec.Program_Id
    ,       l_Assignment_rec.Program_Update_Date
    ,       l_Assignment_rec.Request_Id
    ,       l_Assignment_rec.Secondary_Inventory
    ,       l_Assignment_rec.Ship_To_Site_Id
    ,       l_Assignment_rec.Sourcing_Rule_Id
    ,       l_Assignment_rec.Sourcing_Rule_Type
    FROM    MRP_SR_ASSIGNMENTS
    WHERE   ASSIGNMENT_ID = p_Assignment_rec.Assignment_Id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  (   (l_Assignment_rec.Assignment_Id =
             p_Assignment_rec.Assignment_Id) OR
            ((p_Assignment_rec.Assignment_Id = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_rec.Assignment_Id IS NULL) AND
                (p_Assignment_rec.Assignment_Id IS NULL))))
    AND (   (l_Assignment_rec.Assignment_Set_Id =
             p_Assignment_rec.Assignment_Set_Id) OR
            ((p_Assignment_rec.Assignment_Set_Id = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_rec.Assignment_Set_Id IS NULL) AND
                (p_Assignment_rec.Assignment_Set_Id IS NULL))))
    AND (   (l_Assignment_rec.Assignment_Type =
             p_Assignment_rec.Assignment_Type) OR
            ((p_Assignment_rec.Assignment_Type = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_rec.Assignment_Type IS NULL) AND
                (p_Assignment_rec.Assignment_Type IS NULL))))
    AND (   (l_Assignment_rec.Attribute1 =
             p_Assignment_rec.Attribute1) OR
            ((p_Assignment_rec.Attribute1 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_rec.Attribute1 IS NULL) AND
                (p_Assignment_rec.Attribute1 IS NULL))))
    AND (   (l_Assignment_rec.Attribute10 =
             p_Assignment_rec.Attribute10) OR
            ((p_Assignment_rec.Attribute10 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_rec.Attribute10 IS NULL) AND
                (p_Assignment_rec.Attribute10 IS NULL))))
    AND (   (l_Assignment_rec.Attribute11 =
             p_Assignment_rec.Attribute11) OR
            ((p_Assignment_rec.Attribute11 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_rec.Attribute11 IS NULL) AND
                (p_Assignment_rec.Attribute11 IS NULL))))
    AND (   (l_Assignment_rec.Attribute12 =
             p_Assignment_rec.Attribute12) OR
            ((p_Assignment_rec.Attribute12 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_rec.Attribute12 IS NULL) AND
                (p_Assignment_rec.Attribute12 IS NULL))))
    AND (   (l_Assignment_rec.Attribute13 =
             p_Assignment_rec.Attribute13) OR
            ((p_Assignment_rec.Attribute13 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_rec.Attribute13 IS NULL) AND
                (p_Assignment_rec.Attribute13 IS NULL))))
    AND (   (l_Assignment_rec.Attribute14 =
             p_Assignment_rec.Attribute14) OR
            ((p_Assignment_rec.Attribute14 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_rec.Attribute14 IS NULL) AND
                (p_Assignment_rec.Attribute14 IS NULL))))
    AND (   (l_Assignment_rec.Attribute15 =
             p_Assignment_rec.Attribute15) OR
            ((p_Assignment_rec.Attribute15 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_rec.Attribute15 IS NULL) AND
                (p_Assignment_rec.Attribute15 IS NULL))))
    AND (   (l_Assignment_rec.Attribute2 =
             p_Assignment_rec.Attribute2) OR
            ((p_Assignment_rec.Attribute2 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_rec.Attribute2 IS NULL) AND
                (p_Assignment_rec.Attribute2 IS NULL))))
    AND (   (l_Assignment_rec.Attribute3 =
             p_Assignment_rec.Attribute3) OR
            ((p_Assignment_rec.Attribute3 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_rec.Attribute3 IS NULL) AND
                (p_Assignment_rec.Attribute3 IS NULL))))
    AND (   (l_Assignment_rec.Attribute4 =
             p_Assignment_rec.Attribute4) OR
            ((p_Assignment_rec.Attribute4 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_rec.Attribute4 IS NULL) AND
                (p_Assignment_rec.Attribute4 IS NULL))))
    AND (   (l_Assignment_rec.Attribute5 =
             p_Assignment_rec.Attribute5) OR
            ((p_Assignment_rec.Attribute5 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_rec.Attribute5 IS NULL) AND
                (p_Assignment_rec.Attribute5 IS NULL))))
    AND (   (l_Assignment_rec.Attribute6 =
             p_Assignment_rec.Attribute6) OR
            ((p_Assignment_rec.Attribute6 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_rec.Attribute6 IS NULL) AND
                (p_Assignment_rec.Attribute6 IS NULL))))
    AND (   (l_Assignment_rec.Attribute7 =
             p_Assignment_rec.Attribute7) OR
            ((p_Assignment_rec.Attribute7 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_rec.Attribute7 IS NULL) AND
                (p_Assignment_rec.Attribute7 IS NULL))))
    AND (   (l_Assignment_rec.Attribute8 =
             p_Assignment_rec.Attribute8) OR
            ((p_Assignment_rec.Attribute8 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_rec.Attribute8 IS NULL) AND
                (p_Assignment_rec.Attribute8 IS NULL))))
    AND (   (l_Assignment_rec.Attribute9 =
             p_Assignment_rec.Attribute9) OR
            ((p_Assignment_rec.Attribute9 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_rec.Attribute9 IS NULL) AND
                (p_Assignment_rec.Attribute9 IS NULL))))
    AND (   (l_Assignment_rec.Attribute_Category =
             p_Assignment_rec.Attribute_Category) OR
            ((p_Assignment_rec.Attribute_Category = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_rec.Attribute_Category IS NULL) AND
                (p_Assignment_rec.Attribute_Category IS NULL))))
    AND (   (l_Assignment_rec.Category_Id =
             p_Assignment_rec.Category_Id) OR
            ((p_Assignment_rec.Category_Id = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_rec.Category_Id IS NULL) AND
                (p_Assignment_rec.Category_Id IS NULL))))
    AND (   (l_Assignment_rec.Category_Set_Id =
             p_Assignment_rec.Category_Set_Id) OR
            ((p_Assignment_rec.Category_Set_Id = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_rec.Category_Set_Id IS NULL) AND
                (p_Assignment_rec.Category_Set_Id IS NULL))))
    AND (   (l_Assignment_rec.Created_By =
             p_Assignment_rec.Created_By) OR
            ((p_Assignment_rec.Created_By = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_rec.Created_By IS NULL) AND
                (p_Assignment_rec.Created_By IS NULL))))
    AND (   (l_Assignment_rec.Creation_Date =
             p_Assignment_rec.Creation_Date) OR
            ((p_Assignment_rec.Creation_Date = FND_API.G_MISS_DATE) OR
            (   (l_Assignment_rec.Creation_Date IS NULL) AND
                (p_Assignment_rec.Creation_Date IS NULL))))
    AND (   (l_Assignment_rec.Customer_Id =
             p_Assignment_rec.Customer_Id) OR
            ((p_Assignment_rec.Customer_Id = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_rec.Customer_Id IS NULL) AND
                (p_Assignment_rec.Customer_Id IS NULL))))
    AND (   (l_Assignment_rec.Inventory_Item_Id =
             p_Assignment_rec.Inventory_Item_Id) OR
            ((p_Assignment_rec.Inventory_Item_Id = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_rec.Inventory_Item_Id IS NULL) AND
                (p_Assignment_rec.Inventory_Item_Id IS NULL))))
    AND (   (l_Assignment_rec.Last_Updated_By =
             p_Assignment_rec.Last_Updated_By) OR
            ((p_Assignment_rec.Last_Updated_By = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_rec.Last_Updated_By IS NULL) AND
                (p_Assignment_rec.Last_Updated_By IS NULL))))
    AND (   (l_Assignment_rec.Last_Update_Date =
             p_Assignment_rec.Last_Update_Date) OR
            ((p_Assignment_rec.Last_Update_Date = FND_API.G_MISS_DATE) OR
            (   (l_Assignment_rec.Last_Update_Date IS NULL) AND
                (p_Assignment_rec.Last_Update_Date IS NULL))))
    AND (   (l_Assignment_rec.Last_Update_Login =
             p_Assignment_rec.Last_Update_Login) OR
            ((p_Assignment_rec.Last_Update_Login = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_rec.Last_Update_Login IS NULL) AND
                (p_Assignment_rec.Last_Update_Login IS NULL))))
    AND (   (l_Assignment_rec.Organization_Id =
             p_Assignment_rec.Organization_Id) OR
            ((p_Assignment_rec.Organization_Id = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_rec.Organization_Id IS NULL) AND
                (p_Assignment_rec.Organization_Id IS NULL))))
    AND (   (l_Assignment_rec.Program_Application_Id =
             p_Assignment_rec.Program_Application_Id) OR
            ((p_Assignment_rec.Program_Application_Id = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_rec.Program_Application_Id IS NULL) AND
                (p_Assignment_rec.Program_Application_Id IS NULL))))
    AND (   (l_Assignment_rec.Program_Id =
             p_Assignment_rec.Program_Id) OR
            ((p_Assignment_rec.Program_Id = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_rec.Program_Id IS NULL) AND
                (p_Assignment_rec.Program_Id IS NULL))))
    AND (   (l_Assignment_rec.Program_Update_Date =
             p_Assignment_rec.Program_Update_Date) OR
            ((p_Assignment_rec.Program_Update_Date = FND_API.G_MISS_DATE) OR
            (   (l_Assignment_rec.Program_Update_Date IS NULL) AND
                (p_Assignment_rec.Program_Update_Date IS NULL))))
    AND (   (l_Assignment_rec.Request_Id =
             p_Assignment_rec.Request_Id) OR
            ((p_Assignment_rec.Request_Id = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_rec.Request_Id IS NULL) AND
                (p_Assignment_rec.Request_Id IS NULL))))
    AND (   (l_Assignment_rec.Secondary_Inventory =
             p_Assignment_rec.Secondary_Inventory) OR
            ((p_Assignment_rec.Secondary_Inventory = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_rec.Secondary_Inventory IS NULL) AND
                (p_Assignment_rec.Secondary_Inventory IS NULL))))
    AND (   (l_Assignment_rec.Ship_To_Site_Id =
             p_Assignment_rec.Ship_To_Site_Id) OR
            ((p_Assignment_rec.Ship_To_Site_Id = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_rec.Ship_To_Site_Id IS NULL) AND
                (p_Assignment_rec.Ship_To_Site_Id IS NULL))))
    AND (   (l_Assignment_rec.Sourcing_Rule_Id =
             p_Assignment_rec.Sourcing_Rule_Id) OR
            ((p_Assignment_rec.Sourcing_Rule_Id = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_rec.Sourcing_Rule_Id IS NULL) AND
                (p_Assignment_rec.Sourcing_Rule_Id IS NULL))))
    AND (   (l_Assignment_rec.Sourcing_Rule_Type =
             p_Assignment_rec.Sourcing_Rule_Type) OR
            ((p_Assignment_rec.Sourcing_Rule_Type = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_rec.Sourcing_Rule_Type IS NULL) AND
                (p_Assignment_rec.Sourcing_Rule_Type IS NULL))))
    THEN

        --  Row has not changed. Set out parameter.

        x_Assignment_rec               := l_Assignment_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_Assignment_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Assignment_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','BOI_LOCK_ROW_CHANGED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Assignment_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','BOI_LOCK_ROW_DELETED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Assignment_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','BOI_LOCK_ROW_ALREADY_LOCKED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Assignment_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_Assignment_Id                 IN  NUMBER
) RETURN MRP_Src_Assignment_PUB.Assignment_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_Assignment_Id               => p_Assignment_Id
        )(1);


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
(   p_Assignment_Id                 IN  NUMBER
,   x_Assignment_rec                OUT MRP_Src_Assignment_PUB.Assignment_Rec_Type
,   x_Assignment_val_rec            OUT MRP_Src_Assignment_PUB.Assignment_Val_Rec_Type
)
IS
l_Assignment_tbl              MRP_Src_Assignment_PUB.Assignment_Tbl_Type;
l_Assignment_val_tbl          MRP_Src_Assignment_PUB.Assignment_Val_Tbl_Type;
BEGIN

    Query_Entities
        (   p_Assignment_Id               => p_Assignment_Id
        ,   x_Assignment_tbl              => l_Assignment_tbl
        ,   x_Assignment_val_tbl          => l_Assignment_val_tbl
        );

    --  Assign out records

    x_Assignment_rec               := l_Assignment_tbl(1);
    x_Assignment_val_rec           := l_Assignment_val_tbl(1);


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

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_Assignment_Id                 IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_Assignment_Set_Id             IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN MRP_Src_Assignment_PUB.Assignment_Tbl_Type
IS
l_Assignment_rec              MRP_Src_Assignment_PUB.Assignment_Rec_Type;
l_Assignment_tbl              MRP_Src_Assignment_PUB.Assignment_Tbl_Type;

CURSOR l_Assignment_csr IS
    SELECT  ASSIGNMENT_ID
    ,       ASSIGNMENT_SET_ID
    ,       ASSIGNMENT_TYPE
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
    ,       CATEGORY_ID
    ,       CATEGORY_SET_ID
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CUSTOMER_ID
    ,       INVENTORY_ITEM_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       ORGANIZATION_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       SECONDARY_INVENTORY
    ,       SHIP_TO_SITE_ID
    ,       SOURCING_RULE_ID
    ,       SOURCING_RULE_TYPE
    FROM    MRP_SR_ASSIGNMENTS
    WHERE ( ASSIGNMENT_ID = p_Assignment_Id
    )
    OR (    ASSIGNMENT_SET_ID = p_Assignment_Set_Id
    );

BEGIN

    IF
    (p_Assignment_Id IS NOT NULL
     AND
     p_Assignment_Id <> FND_API.G_MISS_NUM)
    AND
    (p_Assignment_Set_Id IS NOT NULL
     AND
     p_Assignment_Set_Id <> FND_API.G_MISS_NUM)
    THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: Assignment_Id = '|| p_Assignment_Id || ', Assignment_Set_Id = '|| p_Assignment_Set_Id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_Assignment_csr LOOP

        l_Assignment_rec.Assignment_Id := l_implicit_rec.ASSIGNMENT_ID;
        l_Assignment_rec.Assignment_Set_Id := l_implicit_rec.ASSIGNMENT_SET_ID;
        l_Assignment_rec.Assignment_Type := l_implicit_rec.ASSIGNMENT_TYPE;
        l_Assignment_rec.Attribute1    := l_implicit_rec.ATTRIBUTE1;
        l_Assignment_rec.Attribute10   := l_implicit_rec.ATTRIBUTE10;
        l_Assignment_rec.Attribute11   := l_implicit_rec.ATTRIBUTE11;
        l_Assignment_rec.Attribute12   := l_implicit_rec.ATTRIBUTE12;
        l_Assignment_rec.Attribute13   := l_implicit_rec.ATTRIBUTE13;
        l_Assignment_rec.Attribute14   := l_implicit_rec.ATTRIBUTE14;
        l_Assignment_rec.Attribute15   := l_implicit_rec.ATTRIBUTE15;
        l_Assignment_rec.Attribute2    := l_implicit_rec.ATTRIBUTE2;
        l_Assignment_rec.Attribute3    := l_implicit_rec.ATTRIBUTE3;
        l_Assignment_rec.Attribute4    := l_implicit_rec.ATTRIBUTE4;
        l_Assignment_rec.Attribute5    := l_implicit_rec.ATTRIBUTE5;
        l_Assignment_rec.Attribute6    := l_implicit_rec.ATTRIBUTE6;
        l_Assignment_rec.Attribute7    := l_implicit_rec.ATTRIBUTE7;
        l_Assignment_rec.Attribute8    := l_implicit_rec.ATTRIBUTE8;
        l_Assignment_rec.Attribute9    := l_implicit_rec.ATTRIBUTE9;
        l_Assignment_rec.Attribute_Category := l_implicit_rec.ATTRIBUTE_CATEGORY;
        l_Assignment_rec.Category_Id   := l_implicit_rec.CATEGORY_ID;
        l_Assignment_rec.Category_Set_Id := l_implicit_rec.CATEGORY_SET_ID;
        l_Assignment_rec.Created_By    := l_implicit_rec.CREATED_BY;
        l_Assignment_rec.Creation_Date := l_implicit_rec.CREATION_DATE;
        l_Assignment_rec.Customer_Id   := l_implicit_rec.CUSTOMER_ID;
        l_Assignment_rec.Inventory_Item_Id := l_implicit_rec.INVENTORY_ITEM_ID;
        l_Assignment_rec.Last_Updated_By := l_implicit_rec.LAST_UPDATED_BY;
        l_Assignment_rec.Last_Update_Date := l_implicit_rec.LAST_UPDATE_DATE;
        l_Assignment_rec.Last_Update_Login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_Assignment_rec.Organization_Id := l_implicit_rec.ORGANIZATION_ID;
        l_Assignment_rec.Program_Application_Id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_Assignment_rec.Program_Id    := l_implicit_rec.PROGRAM_ID;
        l_Assignment_rec.Program_Update_Date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_Assignment_rec.Request_Id    := l_implicit_rec.REQUEST_ID;
        l_Assignment_rec.Secondary_Inventory := l_implicit_rec.SECONDARY_INVENTORY;
        l_Assignment_rec.Ship_To_Site_Id := l_implicit_rec.SHIP_TO_SITE_ID;
        l_Assignment_rec.Sourcing_Rule_Id := l_implicit_rec.SOURCING_RULE_ID;
        l_Assignment_rec.Sourcing_Rule_Type := l_implicit_rec.SOURCING_RULE_TYPE;

        l_Assignment_tbl(l_Assignment_tbl.COUNT + 1) := l_Assignment_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_Assignment_Id IS NOT NULL
     AND
     p_Assignment_Id <> FND_API.G_MISS_NUM)
    AND
    (l_Assignment_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_Assignment_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Rows'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Rows;

--  Procedure Query_Entities

--

PROCEDURE Query_Entities
(   p_Assignment_Id                 IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_Assignment_Set_Id             IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_Assignment_tbl                OUT MRP_Src_Assignment_PUB.Assignment_Tbl_Type
,   x_Assignment_val_tbl            OUT MRP_Src_Assignment_PUB.Assignment_Val_Tbl_Type
)
IS
l_Assignment_rec              MRP_Src_Assignment_PUB.Assignment_Rec_Type;
l_Assignment_val_rec          MRP_Src_Assignment_PUB.Assignment_Val_Rec_Type;
l_rows_fetched                BOOLEAN := FALSE;

CURSOR l_Assignment_csr IS
    SELECT  ASSIGNMENT_ID
    ,       ASSIGNMENT_SET_ID
    ,       ASSIGNMENT_TYPE
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
    ,       CATEGORY_ID
    ,       CATEGORY_SET_ID
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CUSTOMER_ID
    ,       INVENTORY_ITEM_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       ORGANIZATION_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       SECONDARY_INVENTORY
    ,       SHIP_TO_SITE_ID
    ,       SOURCING_RULE_ID
    ,       SOURCING_RULE_TYPE
    FROM    MRP_SR_ASSIGNMENTS
    WHERE ( ASSIGNMENT_ID = p_Assignment_Id
    )
    OR (    ASSIGNMENT_SET_ID = p_Assignment_Set_Id
    );

BEGIN

    IF
    (p_Assignment_Id IS NOT NULL
     AND
     p_Assignment_Id <> FND_API.G_MISS_NUM)
    AND
    (p_Assignment_Set_Id IS NOT NULL
     AND
     p_Assignment_Set_Id <> FND_API.G_MISS_NUM)
    THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Entities'
                ,   'Keys are mutually exclusive: Assignment_Id = '|| p_Assignment_Id || ', Assignment_Set_Id = '|| p_Assignment_Set_Id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_Assignment_csr LOOP


        l_Assignment_rec.Assignment_Id := l_implicit_rec.ASSIGNMENT_ID;
        l_Assignment_rec.Assignment_Set_Id := l_implicit_rec.ASSIGNMENT_SET_ID;
        l_Assignment_rec.Assignment_Type := l_implicit_rec.ASSIGNMENT_TYPE;
        l_Assignment_rec.Attribute1    := l_implicit_rec.ATTRIBUTE1;
        l_Assignment_rec.Attribute10   := l_implicit_rec.ATTRIBUTE10;
        l_Assignment_rec.Attribute11   := l_implicit_rec.ATTRIBUTE11;
        l_Assignment_rec.Attribute12   := l_implicit_rec.ATTRIBUTE12;
        l_Assignment_rec.Attribute13   := l_implicit_rec.ATTRIBUTE13;
        l_Assignment_rec.Attribute14   := l_implicit_rec.ATTRIBUTE14;
        l_Assignment_rec.Attribute15   := l_implicit_rec.ATTRIBUTE15;
        l_Assignment_rec.Attribute2    := l_implicit_rec.ATTRIBUTE2;
        l_Assignment_rec.Attribute3    := l_implicit_rec.ATTRIBUTE3;
        l_Assignment_rec.Attribute4    := l_implicit_rec.ATTRIBUTE4;
        l_Assignment_rec.Attribute5    := l_implicit_rec.ATTRIBUTE5;
        l_Assignment_rec.Attribute6    := l_implicit_rec.ATTRIBUTE6;
        l_Assignment_rec.Attribute7    := l_implicit_rec.ATTRIBUTE7;
        l_Assignment_rec.Attribute8    := l_implicit_rec.ATTRIBUTE8;
        l_Assignment_rec.Attribute9    := l_implicit_rec.ATTRIBUTE9;
        l_Assignment_rec.Attribute_Category := l_implicit_rec.ATTRIBUTE_CATEGORY;
        l_Assignment_rec.Category_Id   := l_implicit_rec.CATEGORY_ID;
        l_Assignment_rec.Category_Set_Id := l_implicit_rec.CATEGORY_SET_ID;
        l_Assignment_rec.Created_By    := l_implicit_rec.CREATED_BY;
        l_Assignment_rec.Creation_Date := l_implicit_rec.CREATION_DATE;
        l_Assignment_rec.Customer_Id   := l_implicit_rec.CUSTOMER_ID;
        l_Assignment_rec.Inventory_Item_Id := l_implicit_rec.INVENTORY_ITEM_ID;
        l_Assignment_rec.Last_Updated_By := l_implicit_rec.LAST_UPDATED_BY;
        l_Assignment_rec.Last_Update_Date := l_implicit_rec.LAST_UPDATE_DATE;
        l_Assignment_rec.Last_Update_Login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_Assignment_rec.Organization_Id := l_implicit_rec.ORGANIZATION_ID;
        l_Assignment_rec.Program_Application_Id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_Assignment_rec.Program_Id    := l_implicit_rec.PROGRAM_ID;
        l_Assignment_rec.Program_Update_Date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_Assignment_rec.Request_Id    := l_implicit_rec.REQUEST_ID;
        l_Assignment_rec.Secondary_Inventory := l_implicit_rec.SECONDARY_INVENTORY;
        l_Assignment_rec.Ship_To_Site_Id := l_implicit_rec.SHIP_TO_SITE_ID;
        l_Assignment_rec.Sourcing_Rule_Id := l_implicit_rec.SOURCING_RULE_ID;
        l_Assignment_rec.Sourcing_Rule_Type := l_implicit_rec.SOURCING_RULE_TYPE;

        l_rows_fetched                 := l_Assignment_csr%FOUND;

        x_Assignment_tbl(l_Assignment_csr%ROWCOUNT) := l_Assignment_rec;
        x_Assignment_val_tbl(l_Assignment_csr%ROWCOUNT) := l_Assignment_val_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_Assignment_Id IS NOT NULL
     AND
     p_Assignment_Id <> FND_API.G_MISS_NUM)
    AND
    (NOT l_rows_fetched)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Entities'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Entities;

END MRP_Assignment_Handlers;

/
