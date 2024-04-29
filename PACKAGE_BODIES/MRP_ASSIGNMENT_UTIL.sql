--------------------------------------------------------
--  DDL for Package Body MRP_ASSIGNMENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_ASSIGNMENT_UTIL" AS
/* $Header: MRPUASNB.pls 115.2 99/07/16 12:38:32 porting ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Assignment_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_Assignment_rec                IN  MRP_Src_Assignment_PUB.Assignment_Rec_Type
,   p_old_Assignment_rec            IN  MRP_Src_Assignment_PUB.Assignment_Rec_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_REC
,   x_Assignment_rec                OUT MRP_Src_Assignment_PUB.Assignment_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_Assignment_rec := p_Assignment_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Assignment_Id,p_old_Assignment_rec.Assignment_Id)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Assignment_Set_Id,p_old_Assignment_rec.Assignment_Set_Id)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Assignment_Type,p_old_Assignment_rec.Assignment_Type)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute1,p_old_Assignment_rec.Attribute1)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute10,p_old_Assignment_rec.Attribute10)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute11,p_old_Assignment_rec.Attribute11)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute12,p_old_Assignment_rec.Attribute12)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute13,p_old_Assignment_rec.Attribute13)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute14,p_old_Assignment_rec.Attribute14)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute15,p_old_Assignment_rec.Attribute15)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute2,p_old_Assignment_rec.Attribute2)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute3,p_old_Assignment_rec.Attribute3)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute4,p_old_Assignment_rec.Attribute4)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute5,p_old_Assignment_rec.Attribute5)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute6,p_old_Assignment_rec.Attribute6)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute7,p_old_Assignment_rec.Attribute7)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute8,p_old_Assignment_rec.Attribute8)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute9,p_old_Assignment_rec.Attribute9)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute_Category,p_old_Assignment_rec.Attribute_Category)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Category_Id,p_old_Assignment_rec.Category_Id)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Category_Set_Id,p_old_Assignment_rec.Category_Set_Id)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Created_By,p_old_Assignment_rec.Created_By)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Creation_Date,p_old_Assignment_rec.Creation_Date)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Customer_Id,p_old_Assignment_rec.Customer_Id)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Inventory_Item_Id,p_old_Assignment_rec.Inventory_Item_Id)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Last_Updated_By,p_old_Assignment_rec.Last_Updated_By)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Last_Update_Date,p_old_Assignment_rec.Last_Update_Date)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Last_Update_Login,p_old_Assignment_rec.Last_Update_Login)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Organization_Id,p_old_Assignment_rec.Organization_Id)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Program_Application_Id,p_old_Assignment_rec.Program_Application_Id)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Program_Id,p_old_Assignment_rec.Program_Id)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Program_Update_Date,p_old_Assignment_rec.Program_Update_Date)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Request_Id,p_old_Assignment_rec.Request_Id)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Secondary_Inventory,p_old_Assignment_rec.Secondary_Inventory)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Ship_To_Site_Id,p_old_Assignment_rec.Ship_To_Site_Id)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Sourcing_Rule_Id,p_old_Assignment_rec.Sourcing_Rule_Id)
        THEN
            NULL;
        END IF;

        IF NOT MRP_Globals.Equal(p_Assignment_rec.Sourcing_Rule_Type,p_old_Assignment_rec.Sourcing_Rule_Type)
        THEN
            NULL;
        END IF;

    ELSIF p_attr_id = G_ASSIGNMENT_ID THEN
        NULL;
    ELSIF p_attr_id = G_ASSIGNMENT_SET_ID THEN
        NULL;
    ELSIF p_attr_id = G_ASSIGNMENT_TYPE THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE_CATEGORY THEN
        NULL;
    ELSIF p_attr_id = G_CATEGORY_ID THEN
        NULL;
    ELSIF p_attr_id = G_CATEGORY_SET_ID THEN
        NULL;
    ELSIF p_attr_id = G_CREATED_BY THEN
        NULL;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        NULL;
    ELSIF p_attr_id = G_CUSTOMER_ID THEN
        NULL;
    ELSIF p_attr_id = G_INVENTORY_ITEM_ID THEN
        NULL;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        NULL;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        NULL;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        NULL;
    ELSIF p_attr_id = G_ORGANIZATION_ID THEN
        NULL;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION_ID THEN
        NULL;
    ELSIF p_attr_id = G_PROGRAM_ID THEN
        NULL;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        NULL;
    ELSIF p_attr_id = G_REQUEST_ID THEN
        NULL;
    ELSIF p_attr_id = G_SECONDARY_INVENTORY THEN
        NULL;
    ELSIF p_attr_id = G_SHIP_TO_SITE_ID THEN
        NULL;
    ELSIF p_attr_id = G_SOURCING_RULE_ID THEN
        NULL;
    ELSIF p_attr_id = G_SOURCING_RULE_TYPE THEN
        NULL;
    END IF;

    --Irrespective of whether old/new record values are equal or
    --not, I want to clear these fields.
    --Depending on the Assignment Type, clear the dependent Attributes
    IF p_Assignment_rec.Assignment_Type = 1 THEN
        x_Assignment_rec.Organization_Id := NULL;
        x_Assignment_rec.Customer_Id := NULL;
        x_Assignment_rec.Ship_To_Site_Id := NULL;
        x_Assignment_rec.Inventory_Item_Id := NULL;
        x_Assignment_rec.Category_Id := NULL;
        x_Assignment_rec.Category_Set_Id := NULL;
    ELSIF p_Assignment_rec.Assignment_Type = 2 THEN
  	x_Assignment_rec.Organization_Id := NULL;
        x_Assignment_rec.Customer_Id := NULL;
    	x_Assignment_rec.Ship_To_Site_Id := NULL;
    	x_Assignment_rec.Inventory_Item_Id := NULL;
    ELSIF p_Assignment_rec.Assignment_Type = 3 THEN
        x_Assignment_rec.Organization_Id := NULL;
        x_Assignment_rec.Customer_Id := NULL;
        x_Assignment_rec.Ship_To_Site_Id := NULL;
        x_Assignment_rec.Category_Id := NULL;
        x_Assignment_rec.Category_Set_Id := NULL;
    ELSIF p_Assignment_rec.Assignment_Type = 4 THEN
	IF p_Assignment_rec.Organization_Id IS NOT NULL AND
		p_Assignment_rec.Organization_Id <> FND_API.G_MISS_NUM THEN
            x_Assignment_rec.Customer_Id := NULL;
            x_Assignment_rec.Ship_To_Site_Id := NULL;
	ELSIF p_Assignment_rec.Customer_Id IS NOT NULL AND
		p_Assignment_rec.Customer_Id <> FND_API.G_MISS_NUM THEN
	    x_Assignment_rec.Organization_Id := NULL;
	END IF;
    ELSIF p_Assignment_rec.Assignment_Type = 5 THEN
	IF p_Assignment_rec.Organization_Id IS NOT NULL AND
		p_Assignment_rec.Organization_Id <> FND_API.G_MISS_NUM THEN
            x_Assignment_rec.Customer_Id := NULL;
            x_Assignment_rec.Ship_To_Site_Id := NULL;
	ELSIF p_Assignment_rec.Customer_Id IS NOT NULL AND
		p_Assignment_rec.Customer_Id <> FND_API.G_MISS_NUM THEN
	    x_Assignment_rec.Organization_Id := NULL;
	END IF;
        x_Assignment_rec.Inventory_Item_Id := NULL;
    ELSIF p_Assignment_rec.Assignment_Type = 6 THEN
	IF p_Assignment_rec.Organization_Id IS NOT NULL AND
		p_Assignment_rec.Organization_Id <> FND_API.G_MISS_NUM THEN
            x_Assignment_rec.Customer_Id := NULL;
            x_Assignment_rec.Ship_To_Site_Id := NULL;
	ELSIF p_Assignment_rec.Customer_Id IS NOT NULL AND
		p_Assignment_rec.Customer_Id <> FND_API.G_MISS_NUM THEN
	    x_Assignment_rec.Organization_Id := NULL;
	END IF;
        x_Assignment_rec.Category_Id := NULL;
        x_Assignment_rec.Category_Set_Id := NULL;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_Assignment_rec                IN  MRP_Src_Assignment_PUB.Assignment_Rec_Type
,   p_old_Assignment_rec            IN  MRP_Src_Assignment_PUB.Assignment_Rec_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_REC
,   x_Assignment_rec                OUT MRP_Src_Assignment_PUB.Assignment_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_Assignment_rec := p_Assignment_rec;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Assignment_Id,p_old_Assignment_rec.Assignment_Id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Assignment_Set_Id,p_old_Assignment_rec.Assignment_Set_Id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Assignment_Type,p_old_Assignment_rec.Assignment_Type)
    THEN
	NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute1,p_old_Assignment_rec.Attribute1)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute10,p_old_Assignment_rec.Attribute10)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute11,p_old_Assignment_rec.Attribute11)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute12,p_old_Assignment_rec.Attribute12)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute13,p_old_Assignment_rec.Attribute13)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute14,p_old_Assignment_rec.Attribute14)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute15,p_old_Assignment_rec.Attribute15)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute2,p_old_Assignment_rec.Attribute2)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute3,p_old_Assignment_rec.Attribute3)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute4,p_old_Assignment_rec.Attribute4)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute5,p_old_Assignment_rec.Attribute5)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute6,p_old_Assignment_rec.Attribute6)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute7,p_old_Assignment_rec.Attribute7)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute8,p_old_Assignment_rec.Attribute8)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute9,p_old_Assignment_rec.Attribute9)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Attribute_Category,p_old_Assignment_rec.Attribute_Category)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Category_Id,p_old_Assignment_rec.Category_Id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Category_Set_Id,p_old_Assignment_rec.Category_Set_Id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Created_By,p_old_Assignment_rec.Created_By)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Creation_Date,p_old_Assignment_rec.Creation_Date)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Customer_Id,p_old_Assignment_rec.Customer_Id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Inventory_Item_Id,p_old_Assignment_rec.Inventory_Item_Id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Last_Updated_By,p_old_Assignment_rec.Last_Updated_By)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Last_Update_Date,p_old_Assignment_rec.Last_Update_Date)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Last_Update_Login,p_old_Assignment_rec.Last_Update_Login)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Organization_Id,p_old_Assignment_rec.Organization_Id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Program_Application_Id,p_old_Assignment_rec.Program_Application_Id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Program_Id,p_old_Assignment_rec.Program_Id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Program_Update_Date,p_old_Assignment_rec.Program_Update_Date)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Request_Id,p_old_Assignment_rec.Request_Id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Secondary_Inventory,p_old_Assignment_rec.Secondary_Inventory)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Ship_To_Site_Id,p_old_Assignment_rec.Ship_To_Site_Id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Sourcing_Rule_Id,p_old_Assignment_rec.Sourcing_Rule_Id)
    THEN
        NULL;
    END IF;

    IF NOT MRP_Globals.Equal(p_Assignment_rec.Sourcing_Rule_Type,p_old_Assignment_rec.Sourcing_Rule_Type)
    THEN
        NULL;
    END IF;

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_Assignment_rec                IN  MRP_Src_Assignment_PUB.Assignment_Rec_Type
,   p_old_Assignment_rec            IN  MRP_Src_Assignment_PUB.Assignment_Rec_Type
) RETURN MRP_Src_Assignment_PUB.Assignment_Rec_Type
IS
l_Assignment_rec              MRP_Src_Assignment_PUB.Assignment_Rec_Type := p_Assignment_rec;
BEGIN

    IF l_Assignment_rec.Assignment_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Assignment_Id := p_old_Assignment_rec.Assignment_Id;
    END IF;

    IF l_Assignment_rec.Assignment_Set_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Assignment_Set_Id := p_old_Assignment_rec.Assignment_Set_Id;
    END IF;

    IF l_Assignment_rec.Assignment_Type = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Assignment_Type := p_old_Assignment_rec.Assignment_Type;
    END IF;

    IF l_Assignment_rec.Attribute1 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute1 := p_old_Assignment_rec.Attribute1;
    END IF;

    IF l_Assignment_rec.Attribute10 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute10 := p_old_Assignment_rec.Attribute10;
    END IF;

    IF l_Assignment_rec.Attribute11 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute11 := p_old_Assignment_rec.Attribute11;
    END IF;

    IF l_Assignment_rec.Attribute12 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute12 := p_old_Assignment_rec.Attribute12;
    END IF;

    IF l_Assignment_rec.Attribute13 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute13 := p_old_Assignment_rec.Attribute13;
    END IF;

    IF l_Assignment_rec.Attribute14 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute14 := p_old_Assignment_rec.Attribute14;
    END IF;

    IF l_Assignment_rec.Attribute15 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute15 := p_old_Assignment_rec.Attribute15;
    END IF;

    IF l_Assignment_rec.Attribute2 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute2 := p_old_Assignment_rec.Attribute2;
    END IF;

    IF l_Assignment_rec.Attribute3 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute3 := p_old_Assignment_rec.Attribute3;
    END IF;

    IF l_Assignment_rec.Attribute4 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute4 := p_old_Assignment_rec.Attribute4;
    END IF;

    IF l_Assignment_rec.Attribute5 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute5 := p_old_Assignment_rec.Attribute5;
    END IF;

    IF l_Assignment_rec.Attribute6 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute6 := p_old_Assignment_rec.Attribute6;
    END IF;

    IF l_Assignment_rec.Attribute7 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute7 := p_old_Assignment_rec.Attribute7;
    END IF;

    IF l_Assignment_rec.Attribute8 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute8 := p_old_Assignment_rec.Attribute8;
    END IF;

    IF l_Assignment_rec.Attribute9 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute9 := p_old_Assignment_rec.Attribute9;
    END IF;

    IF l_Assignment_rec.Attribute_Category = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute_Category := p_old_Assignment_rec.Attribute_Category;
    END IF;

    IF l_Assignment_rec.Category_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Category_Id := p_old_Assignment_rec.Category_Id;
    END IF;

    IF l_Assignment_rec.Category_Set_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Category_Set_Id := p_old_Assignment_rec.Category_Set_Id;
    END IF;

    IF l_Assignment_rec.Created_By = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Created_By := p_old_Assignment_rec.Created_By;
    END IF;

    IF l_Assignment_rec.Creation_Date = FND_API.G_MISS_DATE THEN
        l_Assignment_rec.Creation_Date := p_old_Assignment_rec.Creation_Date;
    END IF;

    IF l_Assignment_rec.Customer_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Customer_Id := p_old_Assignment_rec.Customer_Id;
    END IF;

    IF l_Assignment_rec.Inventory_Item_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Inventory_Item_Id := p_old_Assignment_rec.Inventory_Item_Id;
    END IF;

    IF l_Assignment_rec.Last_Updated_By = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Last_Updated_By := p_old_Assignment_rec.Last_Updated_By;
    END IF;

    IF l_Assignment_rec.Last_Update_Date = FND_API.G_MISS_DATE THEN
        l_Assignment_rec.Last_Update_Date := p_old_Assignment_rec.Last_Update_Date;
    END IF;

    IF l_Assignment_rec.Last_Update_Login = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Last_Update_Login := p_old_Assignment_rec.Last_Update_Login;
    END IF;

    IF l_Assignment_rec.Organization_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Organization_Id := p_old_Assignment_rec.Organization_Id;
    END IF;

    IF l_Assignment_rec.Program_Application_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Program_Application_Id := p_old_Assignment_rec.Program_Application_Id;
    END IF;

    IF l_Assignment_rec.Program_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Program_Id := p_old_Assignment_rec.Program_Id;
    END IF;

    IF l_Assignment_rec.Program_Update_Date = FND_API.G_MISS_DATE THEN
        l_Assignment_rec.Program_Update_Date := p_old_Assignment_rec.Program_Update_Date;
    END IF;

    IF l_Assignment_rec.Request_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Request_Id := p_old_Assignment_rec.Request_Id;
    END IF;

    IF l_Assignment_rec.Secondary_Inventory = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Secondary_Inventory := p_old_Assignment_rec.Secondary_Inventory;
    END IF;

    IF l_Assignment_rec.Ship_To_Site_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Ship_To_Site_Id := p_old_Assignment_rec.Ship_To_Site_Id;
    END IF;

    IF l_Assignment_rec.Sourcing_Rule_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Sourcing_Rule_Id := p_old_Assignment_rec.Sourcing_Rule_Id;
    END IF;

    IF l_Assignment_rec.Sourcing_Rule_Type = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Sourcing_Rule_Type := p_old_Assignment_rec.Sourcing_Rule_Type;
    END IF;

    RETURN l_Assignment_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_Assignment_rec                IN  MRP_Src_Assignment_PUB.Assignment_Rec_Type
) RETURN MRP_Src_Assignment_PUB.Assignment_Rec_Type
IS
l_Assignment_rec              MRP_Src_Assignment_PUB.Assignment_Rec_Type := p_Assignment_rec;
BEGIN

    IF l_Assignment_rec.Assignment_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Assignment_Id := NULL;
    END IF;

    IF l_Assignment_rec.Assignment_Set_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Assignment_Set_Id := NULL;
    END IF;

    IF l_Assignment_rec.Assignment_Type = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Assignment_Type := NULL;
    END IF;

    IF l_Assignment_rec.Attribute1 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute1 := NULL;
    END IF;

    IF l_Assignment_rec.Attribute10 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute10 := NULL;
    END IF;

    IF l_Assignment_rec.Attribute11 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute11 := NULL;
    END IF;

    IF l_Assignment_rec.Attribute12 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute12 := NULL;
    END IF;

    IF l_Assignment_rec.Attribute13 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute13 := NULL;
    END IF;

    IF l_Assignment_rec.Attribute14 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute14 := NULL;
    END IF;

    IF l_Assignment_rec.Attribute15 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute15 := NULL;
    END IF;

    IF l_Assignment_rec.Attribute2 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute2 := NULL;
    END IF;

    IF l_Assignment_rec.Attribute3 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute3 := NULL;
    END IF;

    IF l_Assignment_rec.Attribute4 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute4 := NULL;
    END IF;

    IF l_Assignment_rec.Attribute5 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute5 := NULL;
    END IF;

    IF l_Assignment_rec.Attribute6 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute6 := NULL;
    END IF;

    IF l_Assignment_rec.Attribute7 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute7 := NULL;
    END IF;

    IF l_Assignment_rec.Attribute8 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute8 := NULL;
    END IF;

    IF l_Assignment_rec.Attribute9 = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute9 := NULL;
    END IF;

    IF l_Assignment_rec.Attribute_Category = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Attribute_Category := NULL;
    END IF;

    IF l_Assignment_rec.Category_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Category_Id := NULL;
    END IF;

    IF l_Assignment_rec.Category_Set_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Category_Set_Id := NULL;
    END IF;

    IF l_Assignment_rec.Created_By = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Created_By := NULL;
    END IF;

    IF l_Assignment_rec.Creation_Date = FND_API.G_MISS_DATE THEN
        l_Assignment_rec.Creation_Date := NULL;
    END IF;

    IF l_Assignment_rec.Customer_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Customer_Id := NULL;
    END IF;

    IF l_Assignment_rec.Inventory_Item_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Inventory_Item_Id := NULL;
    END IF;

    IF l_Assignment_rec.Last_Updated_By = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Last_Updated_By := NULL;
    END IF;

    IF l_Assignment_rec.Last_Update_Date = FND_API.G_MISS_DATE THEN
        l_Assignment_rec.Last_Update_Date := NULL;
    END IF;

    IF l_Assignment_rec.Last_Update_Login = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Last_Update_Login := NULL;
    END IF;

    IF l_Assignment_rec.Organization_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Organization_Id := NULL;
    END IF;

    IF l_Assignment_rec.Program_Application_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Program_Application_Id := NULL;
    END IF;

    IF l_Assignment_rec.Program_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Program_Id := NULL;
    END IF;

    IF l_Assignment_rec.Program_Update_Date = FND_API.G_MISS_DATE THEN
        l_Assignment_rec.Program_Update_Date := NULL;
    END IF;

    IF l_Assignment_rec.Request_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Request_Id := NULL;
    END IF;

    IF l_Assignment_rec.Secondary_Inventory = FND_API.G_MISS_CHAR THEN
        l_Assignment_rec.Secondary_Inventory := NULL;
    END IF;

    IF l_Assignment_rec.Ship_To_Site_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Ship_To_Site_Id := NULL;
    END IF;

    IF l_Assignment_rec.Sourcing_Rule_Id = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Sourcing_Rule_Id := NULL;
    END IF;

    IF l_Assignment_rec.Sourcing_Rule_Type = FND_API.G_MISS_NUM THEN
        l_Assignment_rec.Sourcing_Rule_Type := NULL;
    END IF;

    RETURN l_Assignment_rec;

END Convert_Miss_To_Null;

--  Function Get_Values

FUNCTION Get_Values
(   p_Assignment_rec                IN  MRP_Src_Assignment_PUB.Assignment_Rec_Type
,   p_old_Assignment_rec            IN  MRP_Src_Assignment_PUB.Assignment_Rec_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_REC
) RETURN MRP_Src_Assignment_PUB.Assignment_Val_Rec_Type
IS
l_Assignment_val_rec          MRP_Src_Assignment_PUB.Assignment_Val_Rec_Type;
BEGIN

    RETURN l_Assignment_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_Assignment_rec                IN  MRP_Src_Assignment_PUB.Assignment_Rec_Type
,   p_Assignment_val_rec            IN  MRP_Src_Assignment_PUB.Assignment_Val_Rec_Type
) RETURN MRP_Src_Assignment_PUB.Assignment_Rec_Type
IS
l_Assignment_rec              MRP_Src_Assignment_PUB.Assignment_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_Assignment_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_Assignment_rec.

    l_Assignment_rec := p_Assignment_rec;


    RETURN l_Assignment_rec;

END Get_Ids;

END MRP_Assignment_Util;

/
