--------------------------------------------------------
--  DDL for Package Body MRP_DEFAULT_SOURCING_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_DEFAULT_SOURCING_RULE" AS
/* $Header: MRPDSRLB.pls 120.1 2005/06/16 08:11:40 ichoudhu noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Default_Sourcing_Rule';

--  Boolean table type.

TYPE Boolean_Tbl_Type IS TABLE OF BOOLEAN
INDEX BY BINARY_INTEGER;

--  Package global used within the package.

g_Sourcing_Rule_rec           MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type;
g_Sourcing_Rule_out_rec           MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type; --NOCOPY CHANGES

--  Get functions.

FUNCTION Get_Sourcing_Rule_Id
RETURN NUMBER
IS
  l_sourcing_rule_id		NUMBER;
BEGIN

    IF g_Sourcing_Rule_rec.operation = MRP_GLOBALS.G_OPR_CREATE THEN
   	SELECT mrp_sourcing_rules_s.NEXTVAL
     	INTO l_sourcing_rule_id
     	FROM dual;

   	RETURN l_sourcing_rule_id;
    ELSE
	RETURN NULL;
    END IF;

END Get_Sourcing_Rule_Id;

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

FUNCTION Get_Description
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Description;

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

FUNCTION Get_Organization_Id
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Organization_Id;

FUNCTION Get_Planning_Active
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Planning_Active;

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

FUNCTION Get_Request_Id
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Request_Id;

FUNCTION Get_Sourcing_Rule_Name
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Sourcing_Rule_Name;

FUNCTION Get_Sourcing_Rule_Type
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Sourcing_Rule_Type;

FUNCTION Get_Status
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Status;

--  Procedure Attributes

PROCEDURE Attributes
(   p_Sourcing_Rule_rec             IN  MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_SOURCING_RULE_REC
,   p_iteration                     IN  NUMBER := 1
,   x_Sourcing_Rule_rec             OUT NOCOPY MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type --NOCOPY CHANGES
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

    --  Initialize g_Sourcing_Rule_rec

    g_Sourcing_Rule_rec := p_Sourcing_Rule_rec;

    --  Default missing attributes.


    IF g_Sourcing_Rule_rec.Sourcing_Rule_Id = FND_API.G_MISS_NUM THEN

        g_Sourcing_Rule_rec.Sourcing_Rule_Id := Get_Sourcing_Rule_Id;

    END IF;


    IF g_Sourcing_Rule_rec.Attribute1 = FND_API.G_MISS_CHAR THEN

        g_Sourcing_Rule_rec.Attribute1 := Get_Attribute1;

        IF g_Sourcing_Rule_rec.Attribute1 IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Attribute1
                ( g_Sourcing_Rule_rec.Attribute1 )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_ATTRIBUTE1
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec  --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Attribute1 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Attribute10 = FND_API.G_MISS_CHAR THEN

        g_Sourcing_Rule_rec.Attribute10 := Get_Attribute10;

        IF g_Sourcing_Rule_rec.Attribute10 IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Attribute10
                ( g_Sourcing_Rule_rec.Attribute10 )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_ATTRIBUTE10
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Attribute10 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Attribute11 = FND_API.G_MISS_CHAR THEN

        g_Sourcing_Rule_rec.Attribute11 := Get_Attribute11;

        IF g_Sourcing_Rule_rec.Attribute11 IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Attribute11
                ( g_Sourcing_Rule_rec.Attribute11 )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_ATTRIBUTE11
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Attribute11 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Attribute12 = FND_API.G_MISS_CHAR THEN

        g_Sourcing_Rule_rec.Attribute12 := Get_Attribute12;

        IF g_Sourcing_Rule_rec.Attribute12 IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Attribute12
                ( g_Sourcing_Rule_rec.Attribute12 )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_ATTRIBUTE12
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Attribute12 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Attribute13 = FND_API.G_MISS_CHAR THEN

        g_Sourcing_Rule_rec.Attribute13 := Get_Attribute13;

        IF g_Sourcing_Rule_rec.Attribute13 IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Attribute13
                ( g_Sourcing_Rule_rec.Attribute13 )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_ATTRIBUTE13
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec -- NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Attribute13 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Attribute14 = FND_API.G_MISS_CHAR THEN

        g_Sourcing_Rule_rec.Attribute14 := Get_Attribute14;

        IF g_Sourcing_Rule_rec.Attribute14 IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Attribute14
                ( g_Sourcing_Rule_rec.Attribute14 )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_ATTRIBUTE14
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Attribute14 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Attribute15 = FND_API.G_MISS_CHAR THEN

        g_Sourcing_Rule_rec.Attribute15 := Get_Attribute15;

        IF g_Sourcing_Rule_rec.Attribute15 IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Attribute15
                ( g_Sourcing_Rule_rec.Attribute15 )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_ATTRIBUTE15
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Attribute15 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Attribute2 = FND_API.G_MISS_CHAR THEN

        g_Sourcing_Rule_rec.Attribute2 := Get_Attribute2;

        IF g_Sourcing_Rule_rec.Attribute2 IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Attribute2
                ( g_Sourcing_Rule_rec.Attribute2 )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_ATTRIBUTE2
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Attribute2 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Attribute3 = FND_API.G_MISS_CHAR THEN

        g_Sourcing_Rule_rec.Attribute3 := Get_Attribute3;

        IF g_Sourcing_Rule_rec.Attribute3 IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Attribute3
                ( g_Sourcing_Rule_rec.Attribute3 )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_ATTRIBUTE3
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Attribute3 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Attribute4 = FND_API.G_MISS_CHAR THEN

        g_Sourcing_Rule_rec.Attribute4 := Get_Attribute4;

        IF g_Sourcing_Rule_rec.Attribute4 IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Attribute4
                ( g_Sourcing_Rule_rec.Attribute4 )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_ATTRIBUTE4
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Attribute4 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Attribute5 = FND_API.G_MISS_CHAR THEN

        g_Sourcing_Rule_rec.Attribute5 := Get_Attribute5;

        IF g_Sourcing_Rule_rec.Attribute5 IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Attribute5
                ( g_Sourcing_Rule_rec.Attribute5 )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_ATTRIBUTE5
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Attribute5 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Attribute6 = FND_API.G_MISS_CHAR THEN

        g_Sourcing_Rule_rec.Attribute6 := Get_Attribute6;

        IF g_Sourcing_Rule_rec.Attribute6 IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Attribute6
                ( g_Sourcing_Rule_rec.Attribute6 )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_ATTRIBUTE6
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Attribute6 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Attribute7 = FND_API.G_MISS_CHAR THEN

        g_Sourcing_Rule_rec.Attribute7 := Get_Attribute7;

        IF g_Sourcing_Rule_rec.Attribute7 IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Attribute7
                ( g_Sourcing_Rule_rec.Attribute7 )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_ATTRIBUTE7
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Attribute7 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Attribute8 = FND_API.G_MISS_CHAR THEN

        g_Sourcing_Rule_rec.Attribute8 := Get_Attribute8;

        IF g_Sourcing_Rule_rec.Attribute8 IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Attribute8
                ( g_Sourcing_Rule_rec.Attribute8 )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_ATTRIBUTE8
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Attribute8 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Attribute9 = FND_API.G_MISS_CHAR THEN

        g_Sourcing_Rule_rec.Attribute9 := Get_Attribute9;

        IF g_Sourcing_Rule_rec.Attribute9 IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Attribute9
                ( g_Sourcing_Rule_rec.Attribute9 )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_ATTRIBUTE9
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Attribute9 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Attribute_Category = FND_API.G_MISS_CHAR THEN

        g_Sourcing_Rule_rec.Attribute_Category := Get_Attribute_Category;

        IF g_Sourcing_Rule_rec.Attribute_Category IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Attribute_Category
                ( g_Sourcing_Rule_rec.Attribute_Category )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_ATTRIBUTE_CATEGORY
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Attribute_Category := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Created_By = FND_API.G_MISS_NUM THEN

        g_Sourcing_Rule_rec.Created_By := Get_Created_By;

        IF g_Sourcing_Rule_rec.Created_By IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Created_By
                ( g_Sourcing_Rule_rec.Created_By )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_CREATED_BY
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Created_By := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Creation_Date = FND_API.G_MISS_DATE THEN

        g_Sourcing_Rule_rec.Creation_Date := Get_Creation_Date;

        IF g_Sourcing_Rule_rec.Creation_Date IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Creation_Date
                ( g_Sourcing_Rule_rec.Creation_Date )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_CREATION_DATE
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Creation_Date := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Description = FND_API.G_MISS_CHAR THEN

        g_Sourcing_Rule_rec.Description := Get_Description;

        IF g_Sourcing_Rule_rec.Description IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Description
                ( g_Sourcing_Rule_rec.Description )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_DESCRIPTION
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Description := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Last_Updated_By = FND_API.G_MISS_NUM THEN

        g_Sourcing_Rule_rec.Last_Updated_By := Get_Last_Updated_By;

        IF g_Sourcing_Rule_rec.Last_Updated_By IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Last_Updated_By
                ( g_Sourcing_Rule_rec.Last_Updated_By )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_LAST_UPDATED_BY
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Last_Updated_By := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Last_Update_Date = FND_API.G_MISS_DATE THEN

        g_Sourcing_Rule_rec.Last_Update_Date := Get_Last_Update_Date;

        IF g_Sourcing_Rule_rec.Last_Update_Date IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Last_Update_Date
                ( g_Sourcing_Rule_rec.Last_Update_Date )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_LAST_UPDATE_DATE
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Last_Update_Date := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Last_Update_Login = FND_API.G_MISS_NUM THEN

        g_Sourcing_Rule_rec.Last_Update_Login := Get_Last_Update_Login;

        IF g_Sourcing_Rule_rec.Last_Update_Login IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Last_Update_Login
                ( g_Sourcing_Rule_rec.Last_Update_Login )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_LAST_UPDATE_LOGIN
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Last_Update_Login := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Organization_Id = FND_API.G_MISS_NUM THEN

        g_Sourcing_Rule_rec.Organization_Id := Get_Organization_Id;

        IF g_Sourcing_Rule_rec.Organization_Id IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Organization_Id
                ( g_Sourcing_Rule_rec.Organization_Id )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_ORGANIZATION_ID
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Organization_Id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Planning_Active = FND_API.G_MISS_NUM THEN

        g_Sourcing_Rule_rec.Planning_Active := Get_Planning_Active;

        IF g_Sourcing_Rule_rec.Planning_Active IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Planning_Active
                ( g_Sourcing_Rule_rec.Planning_Active )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_PLANNING_ACTIVE
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Planning_Active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Program_Application_Id = FND_API.G_MISS_NUM THEN

        g_Sourcing_Rule_rec.Program_Application_Id := Get_Program_Application_Id;

        IF g_Sourcing_Rule_rec.Program_Application_Id IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Program_Application_Id
                ( g_Sourcing_Rule_rec.Program_Application_Id )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_PROGRAM_APPLICATION_ID
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Program_Application_Id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Program_Id = FND_API.G_MISS_NUM THEN

        g_Sourcing_Rule_rec.Program_Id := Get_Program_Id;

        IF g_Sourcing_Rule_rec.Program_Id IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Program_Id
                ( g_Sourcing_Rule_rec.Program_Id )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_PROGRAM_ID
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Program_Id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Program_Update_Date = FND_API.G_MISS_DATE THEN

        g_Sourcing_Rule_rec.Program_Update_Date := Get_Program_Update_Date;

        IF g_Sourcing_Rule_rec.Program_Update_Date IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Program_Update_Date
                ( g_Sourcing_Rule_rec.Program_Update_Date )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_PROGRAM_UPDATE_DATE
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Program_Update_Date := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Request_Id = FND_API.G_MISS_NUM THEN

        g_Sourcing_Rule_rec.Request_Id := Get_Request_Id;

        IF g_Sourcing_Rule_rec.Request_Id IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Request_Id
                ( g_Sourcing_Rule_rec.Request_Id )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_REQUEST_ID
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Request_Id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Sourcing_Rule_Name = FND_API.G_MISS_CHAR THEN

        g_Sourcing_Rule_rec.Sourcing_Rule_Name := Get_Sourcing_Rule_Name;

        IF g_Sourcing_Rule_rec.Sourcing_Rule_Name IS NOT NULL THEN
           -- bug 3015208
            IF  MRP_Validate_Sourcing_Rule.Val_Sourcing_Rule_Name
                ( g_Sourcing_Rule_rec.Sourcing_Rule_Name,
                  g_Sourcing_Rule_rec.organization_id )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_SOURCING_RULE_NAME
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Sourcing_Rule_Name := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Sourcing_Rule_Type = FND_API.G_MISS_NUM THEN

        g_Sourcing_Rule_rec.Sourcing_Rule_Type := Get_Sourcing_Rule_Type;

        IF g_Sourcing_Rule_rec.Sourcing_Rule_Type IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Sourcing_Rule_Type
                ( g_Sourcing_Rule_rec.Sourcing_Rule_Type )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_SOURCING_RULE_TYPE
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Sourcing_Rule_Type := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Sourcing_Rule_rec.Status = FND_API.G_MISS_NUM THEN

        g_Sourcing_Rule_rec.Status := Get_Status;

        IF g_Sourcing_Rule_rec.Status IS NOT NULL THEN

            IF  MRP_Validate_Sourcing_Rule.Val_Status
                ( g_Sourcing_Rule_rec.Status )
            THEN

                MRP_Sourcing_Rule_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Sourcing_Rule_Util.G_STATUS
                ,   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
                ,   x_Sourcing_Rule_rec           => g_Sourcing_Rule_out_rec --NOCOPY CHANGES
                );
                g_Sourcing_Rule_rec := g_Sourcing_Rule_out_rec; --NOCOPY CHANGES
            ELSE
                    g_Sourcing_Rule_rec.Status := NULL;
            END IF;

        END IF;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_Sourcing_Rule_rec.Sourcing_Rule_Id = FND_API.G_MISS_NUM
    OR  g_Sourcing_Rule_rec.Attribute1 = FND_API.G_MISS_CHAR
    OR  g_Sourcing_Rule_rec.Attribute10 = FND_API.G_MISS_CHAR
    OR  g_Sourcing_Rule_rec.Attribute11 = FND_API.G_MISS_CHAR
    OR  g_Sourcing_Rule_rec.Attribute12 = FND_API.G_MISS_CHAR
    OR  g_Sourcing_Rule_rec.Attribute13 = FND_API.G_MISS_CHAR
    OR  g_Sourcing_Rule_rec.Attribute14 = FND_API.G_MISS_CHAR
    OR  g_Sourcing_Rule_rec.Attribute15 = FND_API.G_MISS_CHAR
    OR  g_Sourcing_Rule_rec.Attribute2 = FND_API.G_MISS_CHAR
    OR  g_Sourcing_Rule_rec.Attribute3 = FND_API.G_MISS_CHAR
    OR  g_Sourcing_Rule_rec.Attribute4 = FND_API.G_MISS_CHAR
    OR  g_Sourcing_Rule_rec.Attribute5 = FND_API.G_MISS_CHAR
    OR  g_Sourcing_Rule_rec.Attribute6 = FND_API.G_MISS_CHAR
    OR  g_Sourcing_Rule_rec.Attribute7 = FND_API.G_MISS_CHAR
    OR  g_Sourcing_Rule_rec.Attribute8 = FND_API.G_MISS_CHAR
    OR  g_Sourcing_Rule_rec.Attribute9 = FND_API.G_MISS_CHAR
    OR  g_Sourcing_Rule_rec.Attribute_Category = FND_API.G_MISS_CHAR
    OR  g_Sourcing_Rule_rec.Created_By = FND_API.G_MISS_NUM
    OR  g_Sourcing_Rule_rec.Creation_Date = FND_API.G_MISS_DATE
    OR  g_Sourcing_Rule_rec.Description = FND_API.G_MISS_CHAR
    OR  g_Sourcing_Rule_rec.Last_Updated_By = FND_API.G_MISS_NUM
    OR  g_Sourcing_Rule_rec.Last_Update_Date = FND_API.G_MISS_DATE
    OR  g_Sourcing_Rule_rec.Last_Update_Login = FND_API.G_MISS_NUM
    OR  g_Sourcing_Rule_rec.Organization_Id = FND_API.G_MISS_NUM
    OR  g_Sourcing_Rule_rec.Planning_Active = FND_API.G_MISS_NUM
    OR  g_Sourcing_Rule_rec.Program_Application_Id = FND_API.G_MISS_NUM
    OR  g_Sourcing_Rule_rec.Program_Id = FND_API.G_MISS_NUM
    OR  g_Sourcing_Rule_rec.Program_Update_Date = FND_API.G_MISS_DATE
    OR  g_Sourcing_Rule_rec.Request_Id = FND_API.G_MISS_NUM
    OR  g_Sourcing_Rule_rec.Sourcing_Rule_Name = FND_API.G_MISS_CHAR
    OR  g_Sourcing_Rule_rec.Sourcing_Rule_Type = FND_API.G_MISS_NUM
    OR  g_Sourcing_Rule_rec.Status = FND_API.G_MISS_NUM
    THEN

        MRP_Default_Sourcing_Rule.Attributes
        (   p_Sourcing_Rule_rec           => g_Sourcing_Rule_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_Sourcing_Rule_rec           => x_Sourcing_Rule_rec
        );

    ELSE

        --  Done defaulting attributes

        x_Sourcing_Rule_rec := g_Sourcing_Rule_rec;

    END IF;

END Attributes;

END MRP_Default_Sourcing_Rule;

/
