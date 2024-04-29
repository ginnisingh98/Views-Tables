--------------------------------------------------------
--  DDL for Package Body MRP_DEFAULT_SHIPPING_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_DEFAULT_SHIPPING_ORG" AS
/* $Header: MRPDSHOB.pls 115.2 99/07/16 12:19:21 porting ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Default_Shipping_Org';

--  Boolean table type.

TYPE Boolean_Tbl_Type IS TABLE OF BOOLEAN
INDEX BY BINARY_INTEGER;

--  Package global used within the package.

g_Shipping_Org_rec            MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type;

--  Get functions.

FUNCTION Get_Sr_Source_Id
RETURN NUMBER
IS

l_sr_source_id		NUMBER;

BEGIN

    IF g_Shipping_Org_rec.operation = MRP_GLOBALS.G_OPR_CREATE THEN
    	SELECT mrp_sr_source_org_s.NEXTVAL
	INTO   l_sr_source_id
	FROM   dual;

	RETURN l_sr_source_id;
    ELSE
    	RETURN NULL;
    END IF;

END Get_Sr_Source_Id;

FUNCTION Get_Allocation_Percent
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Allocation_Percent;

FUNCTION Get_Attribute1
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Attribute1;

FUNCTION Get_Attribute10
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Attribute10;

FUNCTION Get_Attribute11
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Attribute11;

FUNCTION Get_Attribute12
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Attribute12;

FUNCTION Get_Attribute13
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Attribute13;

FUNCTION Get_Attribute14
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Attribute14;

FUNCTION Get_Attribute15
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Attribute15;

FUNCTION Get_Attribute2
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Attribute2;

FUNCTION Get_Attribute3
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Attribute3;

FUNCTION Get_Attribute4
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Attribute4;

FUNCTION Get_Attribute5
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Attribute5;

FUNCTION Get_Attribute6
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Attribute6;

FUNCTION Get_Attribute7
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Attribute7;

FUNCTION Get_Attribute8
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Attribute8;

FUNCTION Get_Attribute9
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Attribute9;

FUNCTION Get_Attribute_Category
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Attribute_Category;

FUNCTION Get_Created_By
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Created_By;

FUNCTION Get_Creation_Date
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_Creation_Date;

FUNCTION Get_Last_Updated_By
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Last_Updated_By;

FUNCTION Get_Last_Update_Date
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_Last_Update_Date;

FUNCTION Get_Last_Update_Login
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Last_Update_Login;

FUNCTION Get_Program_Application_Id
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Program_Application_Id;

FUNCTION Get_Program_Id
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Program_Id;

FUNCTION Get_Program_Update_Date
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_Program_Update_Date;

FUNCTION Get_Rank
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Rank;

FUNCTION Get_Request_Id
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Request_Id;

FUNCTION Get_Secondary_Inventory
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Secondary_Inventory;

FUNCTION Get_Ship_Method
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Ship_Method;

FUNCTION Get_Source_Organization_Id
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Source_Organization_Id;

FUNCTION Get_Source_Type
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Source_Type;

FUNCTION Get_Sr_Receipt_Id
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Sr_Receipt_Id;

FUNCTION Get_Vendor_Id
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Vendor_Id;

FUNCTION Get_Vendor_Site_Id
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Vendor_Site_Id;

--  Procedure Attributes

PROCEDURE Attributes
(   p_Shipping_Org_rec              IN  MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_SHIPPING_ORG_REC
,   p_iteration                     IN  NUMBER := 1
,   x_Shipping_Org_rec              OUT MRP_Sourcing_Rule_PUB.Shipping_Org_Rec_Type
)
IS
l_changed_column_tbl          Boolean_Tbl_Type;
BEGIN

    --  Check number of iterations.

    IF p_iteration > MRP_Globals.G_MAX_DEF_ITERATIONS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','BOI_DEF_MAX_ITERATION');
            FND_MSG_PUB.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Initialize g_Shipping_Org_rec

    g_Shipping_Org_rec := p_Shipping_Org_rec;

    --  Default missing attributes.


    IF g_Shipping_Org_rec.Sr_Source_Id = FND_API.G_MISS_NUM THEN

        g_Shipping_Org_rec.Sr_Source_Id := Get_Sr_Source_Id;

    END IF;


    IF g_Shipping_Org_rec.Allocation_Percent = FND_API.G_MISS_NUM THEN

        g_Shipping_Org_rec.Allocation_Percent := Get_Allocation_Percent;

        IF g_Shipping_Org_rec.Allocation_Percent IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Allocation_Percent
                ( g_Shipping_Org_rec.Allocation_Percent )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_ALLOCATION_PERCENT
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Allocation_Percent := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Attribute1 = FND_API.G_MISS_CHAR THEN

        g_Shipping_Org_rec.Attribute1 := Get_Attribute1;

        IF g_Shipping_Org_rec.Attribute1 IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Attribute1
                ( g_Shipping_Org_rec.Attribute1 )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_ATTRIBUTE1
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Attribute1 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Attribute10 = FND_API.G_MISS_CHAR THEN

        g_Shipping_Org_rec.Attribute10 := Get_Attribute10;

        IF g_Shipping_Org_rec.Attribute10 IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Attribute10
                ( g_Shipping_Org_rec.Attribute10 )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_ATTRIBUTE10
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Attribute10 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Attribute11 = FND_API.G_MISS_CHAR THEN

        g_Shipping_Org_rec.Attribute11 := Get_Attribute11;

        IF g_Shipping_Org_rec.Attribute11 IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Attribute11
                ( g_Shipping_Org_rec.Attribute11 )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_ATTRIBUTE11
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Attribute11 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Attribute12 = FND_API.G_MISS_CHAR THEN

        g_Shipping_Org_rec.Attribute12 := Get_Attribute12;

        IF g_Shipping_Org_rec.Attribute12 IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Attribute12
                ( g_Shipping_Org_rec.Attribute12 )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_ATTRIBUTE12
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Attribute12 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Attribute13 = FND_API.G_MISS_CHAR THEN

        g_Shipping_Org_rec.Attribute13 := Get_Attribute13;

        IF g_Shipping_Org_rec.Attribute13 IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Attribute13
                ( g_Shipping_Org_rec.Attribute13 )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_ATTRIBUTE13
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Attribute13 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Attribute14 = FND_API.G_MISS_CHAR THEN

        g_Shipping_Org_rec.Attribute14 := Get_Attribute14;

        IF g_Shipping_Org_rec.Attribute14 IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Attribute14
                ( g_Shipping_Org_rec.Attribute14 )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_ATTRIBUTE14
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Attribute14 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Attribute15 = FND_API.G_MISS_CHAR THEN

        g_Shipping_Org_rec.Attribute15 := Get_Attribute15;

        IF g_Shipping_Org_rec.Attribute15 IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Attribute15
                ( g_Shipping_Org_rec.Attribute15 )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_ATTRIBUTE15
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Attribute15 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Attribute2 = FND_API.G_MISS_CHAR THEN

        g_Shipping_Org_rec.Attribute2 := Get_Attribute2;

        IF g_Shipping_Org_rec.Attribute2 IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Attribute2
                ( g_Shipping_Org_rec.Attribute2 )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_ATTRIBUTE2
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Attribute2 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Attribute3 = FND_API.G_MISS_CHAR THEN

        g_Shipping_Org_rec.Attribute3 := Get_Attribute3;

        IF g_Shipping_Org_rec.Attribute3 IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Attribute3
                ( g_Shipping_Org_rec.Attribute3 )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_ATTRIBUTE3
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Attribute3 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Attribute4 = FND_API.G_MISS_CHAR THEN

        g_Shipping_Org_rec.Attribute4 := Get_Attribute4;

        IF g_Shipping_Org_rec.Attribute4 IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Attribute4
                ( g_Shipping_Org_rec.Attribute4 )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_ATTRIBUTE4
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Attribute4 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Attribute5 = FND_API.G_MISS_CHAR THEN

        g_Shipping_Org_rec.Attribute5 := Get_Attribute5;

        IF g_Shipping_Org_rec.Attribute5 IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Attribute5
                ( g_Shipping_Org_rec.Attribute5 )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_ATTRIBUTE5
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Attribute5 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Attribute6 = FND_API.G_MISS_CHAR THEN

        g_Shipping_Org_rec.Attribute6 := Get_Attribute6;

        IF g_Shipping_Org_rec.Attribute6 IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Attribute6
                ( g_Shipping_Org_rec.Attribute6 )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_ATTRIBUTE6
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Attribute6 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Attribute7 = FND_API.G_MISS_CHAR THEN

        g_Shipping_Org_rec.Attribute7 := Get_Attribute7;

        IF g_Shipping_Org_rec.Attribute7 IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Attribute7
                ( g_Shipping_Org_rec.Attribute7 )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_ATTRIBUTE7
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Attribute7 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Attribute8 = FND_API.G_MISS_CHAR THEN

        g_Shipping_Org_rec.Attribute8 := Get_Attribute8;

        IF g_Shipping_Org_rec.Attribute8 IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Attribute8
                ( g_Shipping_Org_rec.Attribute8 )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_ATTRIBUTE8
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Attribute8 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Attribute9 = FND_API.G_MISS_CHAR THEN

        g_Shipping_Org_rec.Attribute9 := Get_Attribute9;

        IF g_Shipping_Org_rec.Attribute9 IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Attribute9
                ( g_Shipping_Org_rec.Attribute9 )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_ATTRIBUTE9
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Attribute9 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Attribute_Category = FND_API.G_MISS_CHAR THEN

        g_Shipping_Org_rec.Attribute_Category := Get_Attribute_Category;

        IF g_Shipping_Org_rec.Attribute_Category IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Attribute_Category
                ( g_Shipping_Org_rec.Attribute_Category )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_ATTRIBUTE_CATEGORY
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Attribute_Category := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Created_By = FND_API.G_MISS_NUM THEN

        g_Shipping_Org_rec.Created_By := Get_Created_By;

        IF g_Shipping_Org_rec.Created_By IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Created_By
                ( g_Shipping_Org_rec.Created_By )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_CREATED_BY
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Created_By := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Creation_Date = FND_API.G_MISS_DATE THEN

        g_Shipping_Org_rec.Creation_Date := Get_Creation_Date;

        IF g_Shipping_Org_rec.Creation_Date IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Creation_Date
                ( g_Shipping_Org_rec.Creation_Date )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_CREATION_DATE
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Creation_Date := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Last_Updated_By = FND_API.G_MISS_NUM THEN

        g_Shipping_Org_rec.Last_Updated_By := Get_Last_Updated_By;

        IF g_Shipping_Org_rec.Last_Updated_By IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Last_Updated_By
                ( g_Shipping_Org_rec.Last_Updated_By )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_LAST_UPDATED_BY
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Last_Updated_By := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Last_Update_Date = FND_API.G_MISS_DATE THEN

        g_Shipping_Org_rec.Last_Update_Date := Get_Last_Update_Date;

        IF g_Shipping_Org_rec.Last_Update_Date IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Last_Update_Date
                ( g_Shipping_Org_rec.Last_Update_Date )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_LAST_UPDATE_DATE
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Last_Update_Date := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Last_Update_Login = FND_API.G_MISS_NUM THEN

        g_Shipping_Org_rec.Last_Update_Login := Get_Last_Update_Login;

        IF g_Shipping_Org_rec.Last_Update_Login IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Last_Update_Login
                ( g_Shipping_Org_rec.Last_Update_Login )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_LAST_UPDATE_LOGIN
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Last_Update_Login := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Program_Application_Id = FND_API.G_MISS_NUM THEN

        g_Shipping_Org_rec.Program_Application_Id := Get_Program_Application_Id;

        IF g_Shipping_Org_rec.Program_Application_Id IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Program_Application_Id
                ( g_Shipping_Org_rec.Program_Application_Id )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_PROGRAM_APPLICATION_ID
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Program_Application_Id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Program_Id = FND_API.G_MISS_NUM THEN

        g_Shipping_Org_rec.Program_Id := Get_Program_Id;

        IF g_Shipping_Org_rec.Program_Id IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Program_Id
                ( g_Shipping_Org_rec.Program_Id )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_PROGRAM_ID
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Program_Id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Program_Update_Date = FND_API.G_MISS_DATE THEN

        g_Shipping_Org_rec.Program_Update_Date := Get_Program_Update_Date;

        IF g_Shipping_Org_rec.Program_Update_Date IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Program_Update_Date
                ( g_Shipping_Org_rec.Program_Update_Date )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_PROGRAM_UPDATE_DATE
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Program_Update_Date := NULL;
            END IF;

        END IF;

    END IF;


    IF g_Shipping_Org_rec.Rank = FND_API.G_MISS_NUM THEN

        g_Shipping_Org_rec.Rank := Get_Rank;

        IF g_Shipping_Org_rec.Rank IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Rank
                ( g_Shipping_Org_rec.Rank )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_RANK
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Rank := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Request_Id = FND_API.G_MISS_NUM THEN

        g_Shipping_Org_rec.Request_Id := Get_Request_Id;

        IF g_Shipping_Org_rec.Request_Id IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Request_Id
                ( g_Shipping_Org_rec.Request_Id )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_REQUEST_ID
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Request_Id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Secondary_Inventory = FND_API.G_MISS_CHAR THEN

        g_Shipping_Org_rec.Secondary_Inventory := Get_Secondary_Inventory;

        IF g_Shipping_Org_rec.Secondary_Inventory IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Secondary_Inventory
                ( g_Shipping_Org_rec.Secondary_Inventory )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_SECONDARY_INVENTORY
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Secondary_Inventory := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Ship_Method = FND_API.G_MISS_CHAR THEN

        g_Shipping_Org_rec.Ship_Method := Get_Ship_Method;

        IF g_Shipping_Org_rec.Ship_Method IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Ship_Method
                ( g_Shipping_Org_rec.sr_receipt_id,
		  g_Shipping_Org_rec.source_organization_id,
		  g_Shipping_Org_rec.Ship_Method )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_SHIP_METHOD
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Ship_Method := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Source_Organization_Id = FND_API.G_MISS_NUM THEN

        g_Shipping_Org_rec.Source_Organization_Id := Get_Source_Organization_Id;

        IF g_Shipping_Org_rec.Source_Organization_Id IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Source_Organization_Id
                ( g_Shipping_Org_rec.Source_Organization_Id )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_SOURCE_ORGANIZATION_ID
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Source_Organization_Id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Source_Type = FND_API.G_MISS_NUM THEN

        g_Shipping_Org_rec.Source_Type := Get_Source_Type;

        IF g_Shipping_Org_rec.Source_Type IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Source_Type
                ( g_Shipping_Org_rec.Source_Type )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_SOURCE_TYPE
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Source_Type := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Sr_Receipt_Id = FND_API.G_MISS_NUM THEN

        g_Shipping_Org_rec.Sr_Receipt_Id := Get_Sr_Receipt_Id;

        IF g_Shipping_Org_rec.Sr_Receipt_Id IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Sr_Receipt_Id
                ( g_Shipping_Org_rec.Sr_Receipt_Id )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_SR_RECEIPT_ID
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Sr_Receipt_Id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Vendor_Id = FND_API.G_MISS_NUM THEN

        g_Shipping_Org_rec.Vendor_Id := Get_Vendor_Id;

        IF g_Shipping_Org_rec.Vendor_Id IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Vendor_Id
                ( g_Shipping_Org_rec.Vendor_Id )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_VENDOR_ID
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Vendor_Id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Shipping_Org_rec.Vendor_Site_Id = FND_API.G_MISS_NUM THEN

        g_Shipping_Org_rec.Vendor_Site_Id := Get_Vendor_Site_Id;

        IF g_Shipping_Org_rec.Vendor_Site_Id IS NOT NULL THEN

            IF  MRP_Validate_Shipping_Org.Val_Vendor_Site_Id
                ( g_Shipping_Org_rec.Vendor_Id,
		  g_Shipping_Org_rec.Vendor_Site_Id )
            THEN

                MRP_Shipping_Org_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Shipping_Org_Util.G_VENDOR_SITE_ID
                ,   p_Shipping_Org_rec            => g_Shipping_Org_rec
                ,   x_Shipping_Org_rec            => g_Shipping_Org_rec
                );
            ELSE
                    g_Shipping_Org_rec.Vendor_Site_Id := NULL;
            END IF;

        END IF;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_Shipping_Org_rec.Sr_Source_Id = FND_API.G_MISS_NUM
    OR  g_Shipping_Org_rec.Allocation_Percent = FND_API.G_MISS_NUM
    OR  g_Shipping_Org_rec.Attribute1 = FND_API.G_MISS_CHAR
    OR  g_Shipping_Org_rec.Attribute10 = FND_API.G_MISS_CHAR
    OR  g_Shipping_Org_rec.Attribute11 = FND_API.G_MISS_CHAR
    OR  g_Shipping_Org_rec.Attribute12 = FND_API.G_MISS_CHAR
    OR  g_Shipping_Org_rec.Attribute13 = FND_API.G_MISS_CHAR
    OR  g_Shipping_Org_rec.Attribute14 = FND_API.G_MISS_CHAR
    OR  g_Shipping_Org_rec.Attribute15 = FND_API.G_MISS_CHAR
    OR  g_Shipping_Org_rec.Attribute2 = FND_API.G_MISS_CHAR
    OR  g_Shipping_Org_rec.Attribute3 = FND_API.G_MISS_CHAR
    OR  g_Shipping_Org_rec.Attribute4 = FND_API.G_MISS_CHAR
    OR  g_Shipping_Org_rec.Attribute5 = FND_API.G_MISS_CHAR
    OR  g_Shipping_Org_rec.Attribute6 = FND_API.G_MISS_CHAR
    OR  g_Shipping_Org_rec.Attribute7 = FND_API.G_MISS_CHAR
    OR  g_Shipping_Org_rec.Attribute8 = FND_API.G_MISS_CHAR
    OR  g_Shipping_Org_rec.Attribute9 = FND_API.G_MISS_CHAR
    OR  g_Shipping_Org_rec.Attribute_Category = FND_API.G_MISS_CHAR
    OR  g_Shipping_Org_rec.Created_By = FND_API.G_MISS_NUM
    OR  g_Shipping_Org_rec.Creation_Date = FND_API.G_MISS_DATE
    OR  g_Shipping_Org_rec.Last_Updated_By = FND_API.G_MISS_NUM
    OR  g_Shipping_Org_rec.Last_Update_Date = FND_API.G_MISS_DATE
    OR  g_Shipping_Org_rec.Last_Update_Login = FND_API.G_MISS_NUM
    OR  g_Shipping_Org_rec.Program_Application_Id = FND_API.G_MISS_NUM
    OR  g_Shipping_Org_rec.Program_Id = FND_API.G_MISS_NUM
    OR  g_Shipping_Org_rec.Program_Update_Date = FND_API.G_MISS_DATE
    OR  g_Shipping_Org_rec.Rank = FND_API.G_MISS_NUM
    OR  g_Shipping_Org_rec.Request_Id = FND_API.G_MISS_NUM
    OR  g_Shipping_Org_rec.Secondary_Inventory = FND_API.G_MISS_CHAR
    OR  g_Shipping_Org_rec.Ship_Method = FND_API.G_MISS_CHAR
    OR  g_Shipping_Org_rec.Source_Organization_Id = FND_API.G_MISS_NUM
    OR  g_Shipping_Org_rec.Source_Type = FND_API.G_MISS_NUM
    OR  g_Shipping_Org_rec.Sr_Receipt_Id = FND_API.G_MISS_NUM
    OR  g_Shipping_Org_rec.Vendor_Id = FND_API.G_MISS_NUM
    OR  g_Shipping_Org_rec.Vendor_Site_Id = FND_API.G_MISS_NUM
    THEN

        MRP_Default_Shipping_Org.Attributes
        (   p_Shipping_Org_rec            => g_Shipping_Org_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_Shipping_Org_rec            => x_Shipping_Org_rec
        );

    ELSE

        --  Done defaulting attributes

        x_Shipping_Org_rec := g_Shipping_Org_rec;

    END IF;

END Attributes;

END MRP_Default_Shipping_Org;

/
