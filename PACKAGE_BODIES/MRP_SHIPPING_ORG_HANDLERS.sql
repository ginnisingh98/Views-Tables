--------------------------------------------------------
--  DDL for Package Body MRP_SHIPPING_ORG_HANDLERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_SHIPPING_ORG_HANDLERS" AS
/* $Header: MRPHSHOB.pls 115.4 99/07/16 12:23:04 porting ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Shipping_Org_Handlers';

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Shipping_Org_rec              IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type
)
IS
BEGIN

    UPDATE  MRP_SR_SOURCE_ORG
    SET     SR_SOURCE_ID                   = p_Shipping_Org_rec.Sr_Source_Id
    ,       ALLOCATION_PERCENT             = p_Shipping_Org_rec.Allocation_Percent
    ,       ATTRIBUTE1                     = p_Shipping_Org_rec.Attribute1
    ,       ATTRIBUTE10                    = p_Shipping_Org_rec.Attribute10
    ,       ATTRIBUTE11                    = p_Shipping_Org_rec.Attribute11
    ,       ATTRIBUTE12                    = p_Shipping_Org_rec.Attribute12
    ,       ATTRIBUTE13                    = p_Shipping_Org_rec.Attribute13
    ,       ATTRIBUTE14                    = p_Shipping_Org_rec.Attribute14
    ,       ATTRIBUTE15                    = p_Shipping_Org_rec.Attribute15
    ,       ATTRIBUTE2                     = p_Shipping_Org_rec.Attribute2
    ,       ATTRIBUTE3                     = p_Shipping_Org_rec.Attribute3
    ,       ATTRIBUTE4                     = p_Shipping_Org_rec.Attribute4
    ,       ATTRIBUTE5                     = p_Shipping_Org_rec.Attribute5
    ,       ATTRIBUTE6                     = p_Shipping_Org_rec.Attribute6
    ,       ATTRIBUTE7                     = p_Shipping_Org_rec.Attribute7
    ,       ATTRIBUTE8                     = p_Shipping_Org_rec.Attribute8
    ,       ATTRIBUTE9                     = p_Shipping_Org_rec.Attribute9
    ,       ATTRIBUTE_CATEGORY             = p_Shipping_Org_rec.Attribute_Category
    ,       CREATED_BY                     = p_Shipping_Org_rec.Created_By
    ,       CREATION_DATE                  = p_Shipping_Org_rec.Creation_Date
    ,       LAST_UPDATED_BY                = p_Shipping_Org_rec.Last_Updated_By
    ,       LAST_UPDATE_DATE               = p_Shipping_Org_rec.Last_Update_Date
    ,       LAST_UPDATE_LOGIN              = p_Shipping_Org_rec.Last_Update_Login
    ,       PROGRAM_APPLICATION_ID         = p_Shipping_Org_rec.Program_Application_Id
    ,       PROGRAM_ID                     = p_Shipping_Org_rec.Program_Id
    ,       PROGRAM_UPDATE_DATE            = p_Shipping_Org_rec.Program_Update_Date
    ,       RANK                           = p_Shipping_Org_rec.Rank
    ,       REQUEST_ID                     = p_Shipping_Org_rec.Request_Id
    ,       SECONDARY_INVENTORY            = p_Shipping_Org_rec.Secondary_Inventory
    ,       SHIP_METHOD                    = p_Shipping_Org_rec.Ship_Method
    ,       SOURCE_ORGANIZATION_ID         = p_Shipping_Org_rec.Source_Organization_Id
    ,       SOURCE_TYPE                    = p_Shipping_Org_rec.Source_Type
    ,       SR_RECEIPT_ID                  = p_Shipping_Org_rec.Sr_Receipt_Id
    ,       VENDOR_ID                      = p_Shipping_Org_rec.Vendor_Id
    ,       VENDOR_SITE_ID                 = p_Shipping_Org_rec.Vendor_Site_Id
    WHERE   SR_SOURCE_ID = p_Shipping_Org_rec.Sr_Source_Id
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
(   p_Shipping_Org_rec              IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type
)
IS
BEGIN

    INSERT  INTO MRP_SR_SOURCE_ORG
    (       SR_SOURCE_ID
    ,       ALLOCATION_PERCENT
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
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       RANK
    ,       REQUEST_ID
    ,       SECONDARY_INVENTORY
    ,       SHIP_METHOD
    ,       SOURCE_ORGANIZATION_ID
    ,       SOURCE_TYPE
    ,       SR_RECEIPT_ID
    ,       VENDOR_ID
    ,       VENDOR_SITE_ID
    )
    VALUES
    (       p_Shipping_Org_rec.Sr_Source_Id
    ,       p_Shipping_Org_rec.Allocation_Percent
    ,       p_Shipping_Org_rec.Attribute1
    ,       p_Shipping_Org_rec.Attribute10
    ,       p_Shipping_Org_rec.Attribute11
    ,       p_Shipping_Org_rec.Attribute12
    ,       p_Shipping_Org_rec.Attribute13
    ,       p_Shipping_Org_rec.Attribute14
    ,       p_Shipping_Org_rec.Attribute15
    ,       p_Shipping_Org_rec.Attribute2
    ,       p_Shipping_Org_rec.Attribute3
    ,       p_Shipping_Org_rec.Attribute4
    ,       p_Shipping_Org_rec.Attribute5
    ,       p_Shipping_Org_rec.Attribute6
    ,       p_Shipping_Org_rec.Attribute7
    ,       p_Shipping_Org_rec.Attribute8
    ,       p_Shipping_Org_rec.Attribute9
    ,       p_Shipping_Org_rec.Attribute_Category
    ,       p_Shipping_Org_rec.Created_By
    ,       p_Shipping_Org_rec.Creation_Date
    ,       p_Shipping_Org_rec.Last_Updated_By
    ,       p_Shipping_Org_rec.Last_Update_Date
    ,       p_Shipping_Org_rec.Last_Update_Login
    ,       p_Shipping_Org_rec.Program_Application_Id
    ,       p_Shipping_Org_rec.Program_Id
    ,       p_Shipping_Org_rec.Program_Update_Date
    ,       p_Shipping_Org_rec.Rank
    ,       p_Shipping_Org_rec.Request_Id
    ,       p_Shipping_Org_rec.Secondary_Inventory
    ,       p_Shipping_Org_rec.Ship_Method
    ,       p_Shipping_Org_rec.Source_Organization_Id
    ,       p_Shipping_Org_rec.Source_Type
    ,       p_Shipping_Org_rec.Sr_Receipt_Id
    ,       p_Shipping_Org_rec.Vendor_Id
    ,       p_Shipping_Org_rec.Vendor_Site_Id
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
(   p_Sr_Source_Id                  IN  NUMBER
)
IS
BEGIN

    DELETE  FROM MRP_SR_SOURCE_ORG
    WHERE   SR_SOURCE_ID = p_Sr_Source_Id
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
,   p_Shipping_Org_rec              IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type
,   x_Shipping_Org_rec              OUT MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type
)
IS
l_Shipping_Org_rec            MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type;
BEGIN

    SELECT  SR_SOURCE_ID
    ,       ALLOCATION_PERCENT
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
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       RANK
    ,       REQUEST_ID
    ,       SECONDARY_INVENTORY
    ,       SHIP_METHOD
    ,       SOURCE_ORGANIZATION_ID
    ,       SOURCE_TYPE
    ,       SR_RECEIPT_ID
    ,       VENDOR_ID
    ,       VENDOR_SITE_ID
    INTO    l_Shipping_Org_rec.Sr_Source_Id
    ,       l_Shipping_Org_rec.Allocation_Percent
    ,       l_Shipping_Org_rec.Attribute1
    ,       l_Shipping_Org_rec.Attribute10
    ,       l_Shipping_Org_rec.Attribute11
    ,       l_Shipping_Org_rec.Attribute12
    ,       l_Shipping_Org_rec.Attribute13
    ,       l_Shipping_Org_rec.Attribute14
    ,       l_Shipping_Org_rec.Attribute15
    ,       l_Shipping_Org_rec.Attribute2
    ,       l_Shipping_Org_rec.Attribute3
    ,       l_Shipping_Org_rec.Attribute4
    ,       l_Shipping_Org_rec.Attribute5
    ,       l_Shipping_Org_rec.Attribute6
    ,       l_Shipping_Org_rec.Attribute7
    ,       l_Shipping_Org_rec.Attribute8
    ,       l_Shipping_Org_rec.Attribute9
    ,       l_Shipping_Org_rec.Attribute_Category
    ,       l_Shipping_Org_rec.Created_By
    ,       l_Shipping_Org_rec.Creation_Date
    ,       l_Shipping_Org_rec.Last_Updated_By
    ,       l_Shipping_Org_rec.Last_Update_Date
    ,       l_Shipping_Org_rec.Last_Update_Login
    ,       l_Shipping_Org_rec.Program_Application_Id
    ,       l_Shipping_Org_rec.Program_Id
    ,       l_Shipping_Org_rec.Program_Update_Date
    ,       l_Shipping_Org_rec.Rank
    ,       l_Shipping_Org_rec.Request_Id
    ,       l_Shipping_Org_rec.Secondary_Inventory
    ,       l_Shipping_Org_rec.Ship_Method
    ,       l_Shipping_Org_rec.Source_Organization_Id
    ,       l_Shipping_Org_rec.Source_Type
    ,       l_Shipping_Org_rec.Sr_Receipt_Id
    ,       l_Shipping_Org_rec.Vendor_Id
    ,       l_Shipping_Org_rec.Vendor_Site_Id
    FROM    MRP_SR_SOURCE_ORG
    WHERE   SR_SOURCE_ID = p_Shipping_Org_rec.Sr_Source_Id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  (   (l_Shipping_Org_rec.Sr_Source_Id =
             p_Shipping_Org_rec.Sr_Source_Id) OR
            ((p_Shipping_Org_rec.Sr_Source_Id = FND_API.G_MISS_NUM) OR
            (   (l_Shipping_Org_rec.Sr_Source_Id IS NULL) AND
                (p_Shipping_Org_rec.Sr_Source_Id IS NULL))))
    AND (   (l_Shipping_Org_rec.Allocation_Percent =
             p_Shipping_Org_rec.Allocation_Percent) OR
            ((p_Shipping_Org_rec.Allocation_Percent = FND_API.G_MISS_NUM) OR
            (   (l_Shipping_Org_rec.Allocation_Percent IS NULL) AND
                (p_Shipping_Org_rec.Allocation_Percent IS NULL))))
    AND (   (l_Shipping_Org_rec.Attribute1 =
             p_Shipping_Org_rec.Attribute1) OR
            ((p_Shipping_Org_rec.Attribute1 = FND_API.G_MISS_CHAR) OR
            (   (l_Shipping_Org_rec.Attribute1 IS NULL) AND
                (p_Shipping_Org_rec.Attribute1 IS NULL))))
    AND (   (l_Shipping_Org_rec.Attribute10 =
             p_Shipping_Org_rec.Attribute10) OR
            ((p_Shipping_Org_rec.Attribute10 = FND_API.G_MISS_CHAR) OR
            (   (l_Shipping_Org_rec.Attribute10 IS NULL) AND
                (p_Shipping_Org_rec.Attribute10 IS NULL))))
    AND (   (l_Shipping_Org_rec.Attribute11 =
             p_Shipping_Org_rec.Attribute11) OR
            ((p_Shipping_Org_rec.Attribute11 = FND_API.G_MISS_CHAR) OR
            (   (l_Shipping_Org_rec.Attribute11 IS NULL) AND
                (p_Shipping_Org_rec.Attribute11 IS NULL))))
    AND (   (l_Shipping_Org_rec.Attribute12 =
             p_Shipping_Org_rec.Attribute12) OR
            ((p_Shipping_Org_rec.Attribute12 = FND_API.G_MISS_CHAR) OR
            (   (l_Shipping_Org_rec.Attribute12 IS NULL) AND
                (p_Shipping_Org_rec.Attribute12 IS NULL))))
    AND (   (l_Shipping_Org_rec.Attribute13 =
             p_Shipping_Org_rec.Attribute13) OR
            ((p_Shipping_Org_rec.Attribute13 = FND_API.G_MISS_CHAR) OR
            (   (l_Shipping_Org_rec.Attribute13 IS NULL) AND
                (p_Shipping_Org_rec.Attribute13 IS NULL))))
    AND (   (l_Shipping_Org_rec.Attribute14 =
             p_Shipping_Org_rec.Attribute14) OR
            ((p_Shipping_Org_rec.Attribute14 = FND_API.G_MISS_CHAR) OR
            (   (l_Shipping_Org_rec.Attribute14 IS NULL) AND
                (p_Shipping_Org_rec.Attribute14 IS NULL))))
    AND (   (l_Shipping_Org_rec.Attribute15 =
             p_Shipping_Org_rec.Attribute15) OR
            ((p_Shipping_Org_rec.Attribute15 = FND_API.G_MISS_CHAR) OR
            (   (l_Shipping_Org_rec.Attribute15 IS NULL) AND
                (p_Shipping_Org_rec.Attribute15 IS NULL))))
    AND (   (l_Shipping_Org_rec.Attribute2 =
             p_Shipping_Org_rec.Attribute2) OR
            ((p_Shipping_Org_rec.Attribute2 = FND_API.G_MISS_CHAR) OR
            (   (l_Shipping_Org_rec.Attribute2 IS NULL) AND
                (p_Shipping_Org_rec.Attribute2 IS NULL))))
    AND (   (l_Shipping_Org_rec.Attribute3 =
             p_Shipping_Org_rec.Attribute3) OR
            ((p_Shipping_Org_rec.Attribute3 = FND_API.G_MISS_CHAR) OR
            (   (l_Shipping_Org_rec.Attribute3 IS NULL) AND
                (p_Shipping_Org_rec.Attribute3 IS NULL))))
    AND (   (l_Shipping_Org_rec.Attribute4 =
             p_Shipping_Org_rec.Attribute4) OR
            ((p_Shipping_Org_rec.Attribute4 = FND_API.G_MISS_CHAR) OR
            (   (l_Shipping_Org_rec.Attribute4 IS NULL) AND
                (p_Shipping_Org_rec.Attribute4 IS NULL))))
    AND (   (l_Shipping_Org_rec.Attribute5 =
             p_Shipping_Org_rec.Attribute5) OR
            ((p_Shipping_Org_rec.Attribute5 = FND_API.G_MISS_CHAR) OR
            (   (l_Shipping_Org_rec.Attribute5 IS NULL) AND
                (p_Shipping_Org_rec.Attribute5 IS NULL))))
    AND (   (l_Shipping_Org_rec.Attribute6 =
             p_Shipping_Org_rec.Attribute6) OR
            ((p_Shipping_Org_rec.Attribute6 = FND_API.G_MISS_CHAR) OR
            (   (l_Shipping_Org_rec.Attribute6 IS NULL) AND
                (p_Shipping_Org_rec.Attribute6 IS NULL))))
    AND (   (l_Shipping_Org_rec.Attribute7 =
             p_Shipping_Org_rec.Attribute7) OR
            ((p_Shipping_Org_rec.Attribute7 = FND_API.G_MISS_CHAR) OR
            (   (l_Shipping_Org_rec.Attribute7 IS NULL) AND
                (p_Shipping_Org_rec.Attribute7 IS NULL))))
    AND (   (l_Shipping_Org_rec.Attribute8 =
             p_Shipping_Org_rec.Attribute8) OR
            ((p_Shipping_Org_rec.Attribute8 = FND_API.G_MISS_CHAR) OR
            (   (l_Shipping_Org_rec.Attribute8 IS NULL) AND
                (p_Shipping_Org_rec.Attribute8 IS NULL))))
    AND (   (l_Shipping_Org_rec.Attribute9 =
             p_Shipping_Org_rec.Attribute9) OR
            ((p_Shipping_Org_rec.Attribute9 = FND_API.G_MISS_CHAR) OR
            (   (l_Shipping_Org_rec.Attribute9 IS NULL) AND
                (p_Shipping_Org_rec.Attribute9 IS NULL))))
    AND (   (l_Shipping_Org_rec.Attribute_Category =
             p_Shipping_Org_rec.Attribute_Category) OR
            ((p_Shipping_Org_rec.Attribute_Category = FND_API.G_MISS_CHAR) OR
            (   (l_Shipping_Org_rec.Attribute_Category IS NULL) AND
                (p_Shipping_Org_rec.Attribute_Category IS NULL))))
    AND (   (l_Shipping_Org_rec.Created_By =
             p_Shipping_Org_rec.Created_By) OR
            ((p_Shipping_Org_rec.Created_By = FND_API.G_MISS_NUM) OR
            (   (l_Shipping_Org_rec.Created_By IS NULL) AND
                (p_Shipping_Org_rec.Created_By IS NULL))))
    AND (   (l_Shipping_Org_rec.Creation_Date =
             p_Shipping_Org_rec.Creation_Date) OR
            ((p_Shipping_Org_rec.Creation_Date = FND_API.G_MISS_DATE) OR
            (   (l_Shipping_Org_rec.Creation_Date IS NULL) AND
                (p_Shipping_Org_rec.Creation_Date IS NULL))))
    AND (   (l_Shipping_Org_rec.Last_Updated_By =
             p_Shipping_Org_rec.Last_Updated_By) OR
            ((p_Shipping_Org_rec.Last_Updated_By = FND_API.G_MISS_NUM) OR
            (   (l_Shipping_Org_rec.Last_Updated_By IS NULL) AND
                (p_Shipping_Org_rec.Last_Updated_By IS NULL))))
    AND (   (l_Shipping_Org_rec.Last_Update_Date =
             p_Shipping_Org_rec.Last_Update_Date) OR
            ((p_Shipping_Org_rec.Last_Update_Date = FND_API.G_MISS_DATE) OR
            (   (l_Shipping_Org_rec.Last_Update_Date IS NULL) AND
                (p_Shipping_Org_rec.Last_Update_Date IS NULL))))
    AND (   (l_Shipping_Org_rec.Last_Update_Login =
             p_Shipping_Org_rec.Last_Update_Login) OR
            ((p_Shipping_Org_rec.Last_Update_Login = FND_API.G_MISS_NUM) OR
            (   (l_Shipping_Org_rec.Last_Update_Login IS NULL) AND
                (p_Shipping_Org_rec.Last_Update_Login IS NULL))))
    AND (   (l_Shipping_Org_rec.Program_Application_Id =
             p_Shipping_Org_rec.Program_Application_Id) OR
            ((p_Shipping_Org_rec.Program_Application_Id = FND_API.G_MISS_NUM) OR
            (   (l_Shipping_Org_rec.Program_Application_Id IS NULL) AND
                (p_Shipping_Org_rec.Program_Application_Id IS NULL))))
    AND (   (l_Shipping_Org_rec.Program_Id =
             p_Shipping_Org_rec.Program_Id) OR
            ((p_Shipping_Org_rec.Program_Id = FND_API.G_MISS_NUM) OR
            (   (l_Shipping_Org_rec.Program_Id IS NULL) AND
                (p_Shipping_Org_rec.Program_Id IS NULL))))
    AND (   (l_Shipping_Org_rec.Program_Update_Date =
             p_Shipping_Org_rec.Program_Update_Date) OR
            ((p_Shipping_Org_rec.Program_Update_Date = FND_API.G_MISS_DATE) OR
            (   (l_Shipping_Org_rec.Program_Update_Date IS NULL) AND
                (p_Shipping_Org_rec.Program_Update_Date IS NULL))))
    AND (   (l_Shipping_Org_rec.Rank =
             p_Shipping_Org_rec.Rank) OR
            ((p_Shipping_Org_rec.Rank = FND_API.G_MISS_NUM) OR
            (   (l_Shipping_Org_rec.Rank IS NULL) AND
                (p_Shipping_Org_rec.Rank IS NULL))))
    AND (   (l_Shipping_Org_rec.Request_Id =
             p_Shipping_Org_rec.Request_Id) OR
            ((p_Shipping_Org_rec.Request_Id = FND_API.G_MISS_NUM) OR
            (   (l_Shipping_Org_rec.Request_Id IS NULL) AND
                (p_Shipping_Org_rec.Request_Id IS NULL))))
    AND (   (l_Shipping_Org_rec.Secondary_Inventory =
             p_Shipping_Org_rec.Secondary_Inventory) OR
            ((p_Shipping_Org_rec.Secondary_Inventory = FND_API.G_MISS_CHAR) OR
            (   (l_Shipping_Org_rec.Secondary_Inventory IS NULL) AND
                (p_Shipping_Org_rec.Secondary_Inventory IS NULL))))
    AND (   (l_Shipping_Org_rec.Ship_Method =
             p_Shipping_Org_rec.Ship_Method) OR
            ((p_Shipping_Org_rec.Ship_Method = FND_API.G_MISS_CHAR) OR
            (   (l_Shipping_Org_rec.Ship_Method IS NULL) AND
                (p_Shipping_Org_rec.Ship_Method IS NULL))))
    AND (   (l_Shipping_Org_rec.Source_Organization_Id =
             p_Shipping_Org_rec.Source_Organization_Id) OR
            ((p_Shipping_Org_rec.Source_Organization_Id = FND_API.G_MISS_NUM) OR
            (   (l_Shipping_Org_rec.Source_Organization_Id IS NULL) AND
                (p_Shipping_Org_rec.Source_Organization_Id IS NULL))))
    AND (   (l_Shipping_Org_rec.Source_Type =
             p_Shipping_Org_rec.Source_Type) OR
            ((p_Shipping_Org_rec.Source_Type = FND_API.G_MISS_NUM) OR
            (   (l_Shipping_Org_rec.Source_Type IS NULL) AND
                (p_Shipping_Org_rec.Source_Type IS NULL))))
    AND (   (l_Shipping_Org_rec.Sr_Receipt_Id =
             p_Shipping_Org_rec.Sr_Receipt_Id) OR
            ((p_Shipping_Org_rec.Sr_Receipt_Id = FND_API.G_MISS_NUM) OR
            (   (l_Shipping_Org_rec.Sr_Receipt_Id IS NULL) AND
                (p_Shipping_Org_rec.Sr_Receipt_Id IS NULL))))
    AND (   (l_Shipping_Org_rec.Vendor_Id =
             p_Shipping_Org_rec.Vendor_Id) OR
            ((p_Shipping_Org_rec.Vendor_Id = FND_API.G_MISS_NUM) OR
            (   (l_Shipping_Org_rec.Vendor_Id IS NULL) AND
                (p_Shipping_Org_rec.Vendor_Id IS NULL))))
    AND (   (l_Shipping_Org_rec.Vendor_Site_Id =
             p_Shipping_Org_rec.Vendor_Site_Id) OR
            ((p_Shipping_Org_rec.Vendor_Site_Id = FND_API.G_MISS_NUM) OR
            (   (l_Shipping_Org_rec.Vendor_Site_Id IS NULL) AND
                (p_Shipping_Org_rec.Vendor_Site_Id IS NULL))))
    THEN

        --  Row has not changed. Set out parameter.

        x_Shipping_Org_rec             := l_Shipping_Org_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_Shipping_Org_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Shipping_Org_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','BOI_LOCK_ROW_CHANGED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Shipping_Org_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','BOI_LOCK_ROW_DELETED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Shipping_Org_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','BOI_LOCK_ROW_ALREADY_LOCKED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Shipping_Org_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_Sr_Source_Id                  IN  NUMBER
) RETURN MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_Sr_Source_Id                => p_Sr_Source_Id
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
(   p_Sr_Source_Id                  IN  NUMBER
,   x_Shipping_Org_rec              OUT MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type
,   x_Shipping_Org_val_rec          OUT MRP_Sourcing_Rule_PUB.Shipping_Org_Val_Rec_Type
)
IS
l_Shipping_Org_tbl            MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type;
l_Shipping_Org_val_tbl        MRP_Sourcing_Rule_PUB.Shipping_Org_Val_Tbl_Type;
BEGIN

    Query_Entities
        (   p_Sr_Source_Id                => p_Sr_Source_Id
        ,   x_Shipping_Org_tbl            => l_Shipping_Org_tbl
        ,   x_Shipping_Org_val_tbl        => l_Shipping_Org_val_tbl
        );

    --  Assign out records

    x_Shipping_Org_rec             := l_Shipping_Org_tbl(1);
    x_Shipping_Org_val_rec         := l_Shipping_Org_val_tbl(1);


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
(   p_Sr_Source_Id                  IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_Sr_Receipt_Id                 IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type
IS
l_Shipping_Org_rec            MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type;
l_Shipping_Org_tbl            MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type;

CURSOR l_Shipping_Org_csr IS
    SELECT  SR_SOURCE_ID
    ,       ALLOCATION_PERCENT
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
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       RANK
    ,       REQUEST_ID
    ,       SECONDARY_INVENTORY
    ,       SHIP_METHOD
    ,       SOURCE_ORGANIZATION_ID
    ,       SOURCE_TYPE
    ,       SR_RECEIPT_ID
    ,       VENDOR_ID
    ,       VENDOR_SITE_ID
    FROM    MRP_SR_SOURCE_ORG
    WHERE ( SR_SOURCE_ID = p_Sr_Source_Id
    )
    OR (    SR_RECEIPT_ID = p_Sr_Receipt_Id
    );

BEGIN

    IF
    (p_Sr_Source_Id IS NOT NULL
     AND
     p_Sr_Source_Id <> FND_API.G_MISS_NUM)
    AND
    (p_Sr_Receipt_Id IS NOT NULL
     AND
     p_Sr_Receipt_Id <> FND_API.G_MISS_NUM)
    THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: Sr_Source_Id = '|| p_Sr_Source_Id || ', Sr_Receipt_Id = '|| p_Sr_Receipt_Id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_Shipping_Org_csr LOOP

        l_Shipping_Org_rec.Sr_Source_Id := l_implicit_rec.SR_SOURCE_ID;
        l_Shipping_Org_rec.Allocation_Percent := l_implicit_rec.ALLOCATION_PERCENT;
        l_Shipping_Org_rec.Attribute1  := l_implicit_rec.ATTRIBUTE1;
        l_Shipping_Org_rec.Attribute10 := l_implicit_rec.ATTRIBUTE10;
        l_Shipping_Org_rec.Attribute11 := l_implicit_rec.ATTRIBUTE11;
        l_Shipping_Org_rec.Attribute12 := l_implicit_rec.ATTRIBUTE12;
        l_Shipping_Org_rec.Attribute13 := l_implicit_rec.ATTRIBUTE13;
        l_Shipping_Org_rec.Attribute14 := l_implicit_rec.ATTRIBUTE14;
        l_Shipping_Org_rec.Attribute15 := l_implicit_rec.ATTRIBUTE15;
        l_Shipping_Org_rec.Attribute2  := l_implicit_rec.ATTRIBUTE2;
        l_Shipping_Org_rec.Attribute3  := l_implicit_rec.ATTRIBUTE3;
        l_Shipping_Org_rec.Attribute4  := l_implicit_rec.ATTRIBUTE4;
        l_Shipping_Org_rec.Attribute5  := l_implicit_rec.ATTRIBUTE5;
        l_Shipping_Org_rec.Attribute6  := l_implicit_rec.ATTRIBUTE6;
        l_Shipping_Org_rec.Attribute7  := l_implicit_rec.ATTRIBUTE7;
        l_Shipping_Org_rec.Attribute8  := l_implicit_rec.ATTRIBUTE8;
        l_Shipping_Org_rec.Attribute9  := l_implicit_rec.ATTRIBUTE9;
        l_Shipping_Org_rec.Attribute_Category := l_implicit_rec.ATTRIBUTE_CATEGORY;
        l_Shipping_Org_rec.Created_By  := l_implicit_rec.CREATED_BY;
        l_Shipping_Org_rec.Creation_Date := l_implicit_rec.CREATION_DATE;
        l_Shipping_Org_rec.Last_Updated_By := l_implicit_rec.LAST_UPDATED_BY;
        l_Shipping_Org_rec.Last_Update_Date := l_implicit_rec.LAST_UPDATE_DATE;
        l_Shipping_Org_rec.Last_Update_Login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_Shipping_Org_rec.Program_Application_Id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_Shipping_Org_rec.Program_Id  := l_implicit_rec.PROGRAM_ID;
        l_Shipping_Org_rec.Program_Update_Date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_Shipping_Org_rec.Rank        := l_implicit_rec.RANK;
        l_Shipping_Org_rec.Request_Id  := l_implicit_rec.REQUEST_ID;
        l_Shipping_Org_rec.Secondary_Inventory := l_implicit_rec.SECONDARY_INVENTORY;
        l_Shipping_Org_rec.Ship_Method := l_implicit_rec.SHIP_METHOD;
        l_Shipping_Org_rec.Source_Organization_Id := l_implicit_rec.SOURCE_ORGANIZATION_ID;
        l_Shipping_Org_rec.Source_Type := l_implicit_rec.SOURCE_TYPE;
        l_Shipping_Org_rec.Sr_Receipt_Id := l_implicit_rec.SR_RECEIPT_ID;
        l_Shipping_Org_rec.Vendor_Id   := l_implicit_rec.VENDOR_ID;
        l_Shipping_Org_rec.Vendor_Site_Id := l_implicit_rec.VENDOR_SITE_ID;

        l_Shipping_Org_tbl(l_Shipping_Org_tbl.COUNT + 1) := l_Shipping_Org_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_Sr_Source_Id IS NOT NULL
     AND
     p_Sr_Source_Id <> FND_API.G_MISS_NUM)
    AND
    (l_Shipping_Org_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_Shipping_Org_tbl;

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
(   p_Sr_Source_Id                  IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_Sr_Receipt_Id                 IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_Shipping_Org_tbl              OUT MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type
,   x_Shipping_Org_val_tbl          OUT MRP_Sourcing_Rule_PUB.Shipping_Org_Val_Tbl_Type
)
IS
l_Shipping_Org_rec            MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type;
l_Shipping_Org_val_rec        MRP_Sourcing_Rule_PUB.Shipping_Org_Val_Rec_Type;
l_rows_fetched                BOOLEAN := FALSE;

CURSOR l_Shipping_Org_csr IS
    SELECT  SR_SOURCE_ID
    ,       ALLOCATION_PERCENT
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
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       RANK
    ,       REQUEST_ID
    ,       SECONDARY_INVENTORY
    ,       SHIP_METHOD
    ,       SOURCE_ORGANIZATION_ID
    ,       SOURCE_TYPE
    ,       SR_RECEIPT_ID
    ,       VENDOR_ID
    ,       VENDOR_SITE_ID
    FROM    MRP_SR_SOURCE_ORG
    WHERE ( SR_SOURCE_ID = p_Sr_Source_Id
    )
    OR (    SR_RECEIPT_ID = p_Sr_Receipt_Id
    );

BEGIN

    IF
    (p_Sr_Source_Id IS NOT NULL
     AND
     p_Sr_Source_Id <> FND_API.G_MISS_NUM)
    AND
    (p_Sr_Receipt_Id IS NOT NULL
     AND
     p_Sr_Receipt_Id <> FND_API.G_MISS_NUM)
    THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Entities'
                ,   'Keys are mutually exclusive: Sr_Source_Id = '|| p_Sr_Source_Id || ', Sr_Receipt_Id = '|| p_Sr_Receipt_Id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_Shipping_Org_csr LOOP


        l_Shipping_Org_rec.Sr_Source_Id := l_implicit_rec.SR_SOURCE_ID;
        l_Shipping_Org_rec.Allocation_Percent := l_implicit_rec.ALLOCATION_PERCENT;
        l_Shipping_Org_rec.Attribute1  := l_implicit_rec.ATTRIBUTE1;
        l_Shipping_Org_rec.Attribute10 := l_implicit_rec.ATTRIBUTE10;
        l_Shipping_Org_rec.Attribute11 := l_implicit_rec.ATTRIBUTE11;
        l_Shipping_Org_rec.Attribute12 := l_implicit_rec.ATTRIBUTE12;
        l_Shipping_Org_rec.Attribute13 := l_implicit_rec.ATTRIBUTE13;
        l_Shipping_Org_rec.Attribute14 := l_implicit_rec.ATTRIBUTE14;
        l_Shipping_Org_rec.Attribute15 := l_implicit_rec.ATTRIBUTE15;
        l_Shipping_Org_rec.Attribute2  := l_implicit_rec.ATTRIBUTE2;
        l_Shipping_Org_rec.Attribute3  := l_implicit_rec.ATTRIBUTE3;
        l_Shipping_Org_rec.Attribute4  := l_implicit_rec.ATTRIBUTE4;
        l_Shipping_Org_rec.Attribute5  := l_implicit_rec.ATTRIBUTE5;
        l_Shipping_Org_rec.Attribute6  := l_implicit_rec.ATTRIBUTE6;
        l_Shipping_Org_rec.Attribute7  := l_implicit_rec.ATTRIBUTE7;
        l_Shipping_Org_rec.Attribute8  := l_implicit_rec.ATTRIBUTE8;
        l_Shipping_Org_rec.Attribute9  := l_implicit_rec.ATTRIBUTE9;
        l_Shipping_Org_rec.Attribute_Category := l_implicit_rec.ATTRIBUTE_CATEGORY;
        l_Shipping_Org_rec.Created_By  := l_implicit_rec.CREATED_BY;
        l_Shipping_Org_rec.Creation_Date := l_implicit_rec.CREATION_DATE;
        l_Shipping_Org_rec.Last_Updated_By := l_implicit_rec.LAST_UPDATED_BY;
        l_Shipping_Org_rec.Last_Update_Date := l_implicit_rec.LAST_UPDATE_DATE;
        l_Shipping_Org_rec.Last_Update_Login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_Shipping_Org_rec.Program_Application_Id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_Shipping_Org_rec.Program_Id  := l_implicit_rec.PROGRAM_ID;
        l_Shipping_Org_rec.Program_Update_Date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_Shipping_Org_rec.Rank        := l_implicit_rec.RANK;
        l_Shipping_Org_rec.Request_Id  := l_implicit_rec.REQUEST_ID;
        l_Shipping_Org_rec.Secondary_Inventory := l_implicit_rec.SECONDARY_INVENTORY;
        l_Shipping_Org_rec.Ship_Method := l_implicit_rec.SHIP_METHOD;
        l_Shipping_Org_rec.Source_Organization_Id := l_implicit_rec.SOURCE_ORGANIZATION_ID;
        l_Shipping_Org_rec.Source_Type := l_implicit_rec.SOURCE_TYPE;
        l_Shipping_Org_rec.Sr_Receipt_Id := l_implicit_rec.SR_RECEIPT_ID;
        l_Shipping_Org_rec.Vendor_Id   := l_implicit_rec.VENDOR_ID;
        l_Shipping_Org_rec.Vendor_Site_Id := l_implicit_rec.VENDOR_SITE_ID;

        l_rows_fetched                 := l_Shipping_Org_csr%FOUND;

        x_Shipping_Org_tbl(l_Shipping_Org_csr%ROWCOUNT) := l_Shipping_Org_rec;
        x_Shipping_Org_val_tbl(l_Shipping_Org_csr%ROWCOUNT) := l_Shipping_Org_val_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_Sr_Source_Id IS NOT NULL
     AND
     p_Sr_Source_Id <> FND_API.G_MISS_NUM)
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

END MRP_Shipping_Org_Handlers;

/
