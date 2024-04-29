--------------------------------------------------------
--  DDL for Package Body MRP_DEFAULT_ASSIGNMENT_SET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_DEFAULT_ASSIGNMENT_SET" AS
/* $Header: MRPDASTB.pls 115.2 99/07/16 12:18:46 porting ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Default_Assignment_Set';

--  Boolean table type.

TYPE Boolean_Tbl_Type IS TABLE OF BOOLEAN
INDEX BY BINARY_INTEGER;

--  Package global used within the package.

g_Assignment_Set_rec          MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type;

--  Get functions.

FUNCTION Get_Assignment_Set_Id
RETURN NUMBER
IS
l_Assignment_Set_Id	NUMBER;
BEGIN

    SELECT mrp_assignment_sets_s.nextval
    INTO   l_Assignment_Set_Id
    FROM   DUAL;

    RETURN l_Assignment_Set_Id;

END Get_Assignment_Set_Id;

FUNCTION Get_Assignment_Set_Name
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Assignment_Set_Name;

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

--  Procedure Attributes

PROCEDURE Attributes
(   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_SET_REC
,   p_iteration                     IN  NUMBER := 1
,   x_Assignment_Set_rec            OUT MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
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

    --  Initialize g_Assignment_Set_rec

    g_Assignment_Set_rec := p_Assignment_Set_rec;

    --  Default missing attributes.


    IF g_Assignment_Set_rec.Assignment_Set_Id = FND_API.G_MISS_NUM THEN

        g_Assignment_Set_rec.Assignment_Set_Id := Get_Assignment_Set_Id;

    END IF;


    IF g_Assignment_Set_rec.Assignment_Set_Name = FND_API.G_MISS_CHAR THEN

        g_Assignment_Set_rec.Assignment_Set_Name := Get_Assignment_Set_Name;

        IF g_Assignment_Set_rec.Assignment_Set_Name IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Assignment_Set_Name
                ( g_Assignment_Set_rec.Assignment_Set_Name )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_ASSIGNMENT_SET_NAME
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Assignment_Set_Name := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Attribute1 = FND_API.G_MISS_CHAR THEN

        g_Assignment_Set_rec.Attribute1 := Get_Attribute1;

        IF g_Assignment_Set_rec.Attribute1 IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Attribute1
                ( g_Assignment_Set_rec.Attribute1 )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_ATTRIBUTE1
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Attribute1 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Attribute10 = FND_API.G_MISS_CHAR THEN

        g_Assignment_Set_rec.Attribute10 := Get_Attribute10;

        IF g_Assignment_Set_rec.Attribute10 IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Attribute10
                ( g_Assignment_Set_rec.Attribute10 )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_ATTRIBUTE10
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Attribute10 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Attribute11 = FND_API.G_MISS_CHAR THEN

        g_Assignment_Set_rec.Attribute11 := Get_Attribute11;

        IF g_Assignment_Set_rec.Attribute11 IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Attribute11
                ( g_Assignment_Set_rec.Attribute11 )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_ATTRIBUTE11
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Attribute11 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Attribute12 = FND_API.G_MISS_CHAR THEN

        g_Assignment_Set_rec.Attribute12 := Get_Attribute12;

        IF g_Assignment_Set_rec.Attribute12 IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Attribute12
                ( g_Assignment_Set_rec.Attribute12 )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_ATTRIBUTE12
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Attribute12 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Attribute13 = FND_API.G_MISS_CHAR THEN

        g_Assignment_Set_rec.Attribute13 := Get_Attribute13;

        IF g_Assignment_Set_rec.Attribute13 IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Attribute13
                ( g_Assignment_Set_rec.Attribute13 )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_ATTRIBUTE13
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Attribute13 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Attribute14 = FND_API.G_MISS_CHAR THEN

        g_Assignment_Set_rec.Attribute14 := Get_Attribute14;

        IF g_Assignment_Set_rec.Attribute14 IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Attribute14
                ( g_Assignment_Set_rec.Attribute14 )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_ATTRIBUTE14
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Attribute14 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Attribute15 = FND_API.G_MISS_CHAR THEN

        g_Assignment_Set_rec.Attribute15 := Get_Attribute15;

        IF g_Assignment_Set_rec.Attribute15 IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Attribute15
                ( g_Assignment_Set_rec.Attribute15 )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_ATTRIBUTE15
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Attribute15 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Attribute2 = FND_API.G_MISS_CHAR THEN

        g_Assignment_Set_rec.Attribute2 := Get_Attribute2;

        IF g_Assignment_Set_rec.Attribute2 IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Attribute2
                ( g_Assignment_Set_rec.Attribute2 )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_ATTRIBUTE2
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Attribute2 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Attribute3 = FND_API.G_MISS_CHAR THEN

        g_Assignment_Set_rec.Attribute3 := Get_Attribute3;

        IF g_Assignment_Set_rec.Attribute3 IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Attribute3
                ( g_Assignment_Set_rec.Attribute3 )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_ATTRIBUTE3
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Attribute3 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Attribute4 = FND_API.G_MISS_CHAR THEN

        g_Assignment_Set_rec.Attribute4 := Get_Attribute4;

        IF g_Assignment_Set_rec.Attribute4 IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Attribute4
                ( g_Assignment_Set_rec.Attribute4 )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_ATTRIBUTE4
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Attribute4 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Attribute5 = FND_API.G_MISS_CHAR THEN

        g_Assignment_Set_rec.Attribute5 := Get_Attribute5;

        IF g_Assignment_Set_rec.Attribute5 IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Attribute5
                ( g_Assignment_Set_rec.Attribute5 )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_ATTRIBUTE5
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Attribute5 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Attribute6 = FND_API.G_MISS_CHAR THEN

        g_Assignment_Set_rec.Attribute6 := Get_Attribute6;

        IF g_Assignment_Set_rec.Attribute6 IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Attribute6
                ( g_Assignment_Set_rec.Attribute6 )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_ATTRIBUTE6
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Attribute6 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Attribute7 = FND_API.G_MISS_CHAR THEN

        g_Assignment_Set_rec.Attribute7 := Get_Attribute7;

        IF g_Assignment_Set_rec.Attribute7 IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Attribute7
                ( g_Assignment_Set_rec.Attribute7 )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_ATTRIBUTE7
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Attribute7 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Attribute8 = FND_API.G_MISS_CHAR THEN

        g_Assignment_Set_rec.Attribute8 := Get_Attribute8;

        IF g_Assignment_Set_rec.Attribute8 IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Attribute8
                ( g_Assignment_Set_rec.Attribute8 )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_ATTRIBUTE8
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Attribute8 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Attribute9 = FND_API.G_MISS_CHAR THEN

        g_Assignment_Set_rec.Attribute9 := Get_Attribute9;

        IF g_Assignment_Set_rec.Attribute9 IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Attribute9
                ( g_Assignment_Set_rec.Attribute9 )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_ATTRIBUTE9
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Attribute9 := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Attribute_Category = FND_API.G_MISS_CHAR THEN

        g_Assignment_Set_rec.Attribute_Category := Get_Attribute_Category;

        IF g_Assignment_Set_rec.Attribute_Category IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Attribute_Category
                ( g_Assignment_Set_rec.Attribute_Category )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_ATTRIBUTE_CATEGORY
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Attribute_Category := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Created_By = FND_API.G_MISS_NUM THEN

        g_Assignment_Set_rec.Created_By := Get_Created_By;

        IF g_Assignment_Set_rec.Created_By IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Created_By
                ( g_Assignment_Set_rec.Created_By )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_CREATED_BY
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Created_By := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Creation_Date = FND_API.G_MISS_DATE THEN

        g_Assignment_Set_rec.Creation_Date := Get_Creation_Date;

        IF g_Assignment_Set_rec.Creation_Date IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Creation_Date
                ( g_Assignment_Set_rec.Creation_Date )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_CREATION_DATE
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Creation_Date := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Description = FND_API.G_MISS_CHAR THEN

        g_Assignment_Set_rec.Description := Get_Description;

        IF g_Assignment_Set_rec.Description IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Description
                ( g_Assignment_Set_rec.Description )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_DESCRIPTION
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Description := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Last_Updated_By = FND_API.G_MISS_NUM THEN

        g_Assignment_Set_rec.Last_Updated_By := Get_Last_Updated_By;

        IF g_Assignment_Set_rec.Last_Updated_By IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Last_Updated_By
                ( g_Assignment_Set_rec.Last_Updated_By )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_LAST_UPDATED_BY
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Last_Updated_By := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Last_Update_Date = FND_API.G_MISS_DATE THEN

        g_Assignment_Set_rec.Last_Update_Date := Get_Last_Update_Date;

        IF g_Assignment_Set_rec.Last_Update_Date IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Last_Update_Date
                ( g_Assignment_Set_rec.Last_Update_Date )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_LAST_UPDATE_DATE
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Last_Update_Date := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Last_Update_Login = FND_API.G_MISS_NUM THEN

        g_Assignment_Set_rec.Last_Update_Login := Get_Last_Update_Login;

        IF g_Assignment_Set_rec.Last_Update_Login IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Last_Update_Login
                ( g_Assignment_Set_rec.Last_Update_Login )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_LAST_UPDATE_LOGIN
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Last_Update_Login := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Program_Application_Id = FND_API.G_MISS_NUM THEN

        g_Assignment_Set_rec.Program_Application_Id := Get_Program_Application_Id;

        IF g_Assignment_Set_rec.Program_Application_Id IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Program_Application_Id
                ( g_Assignment_Set_rec.Program_Application_Id )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_PROGRAM_APPLICATION_ID
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Program_Application_Id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Program_Id = FND_API.G_MISS_NUM THEN

        g_Assignment_Set_rec.Program_Id := Get_Program_Id;

        IF g_Assignment_Set_rec.Program_Id IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Program_Id
                ( g_Assignment_Set_rec.Program_Id )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_PROGRAM_ID
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Program_Id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Program_Update_Date = FND_API.G_MISS_DATE THEN

        g_Assignment_Set_rec.Program_Update_Date := Get_Program_Update_Date;

        IF g_Assignment_Set_rec.Program_Update_Date IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Program_Update_Date
                ( g_Assignment_Set_rec.Program_Update_Date )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_PROGRAM_UPDATE_DATE
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Program_Update_Date := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Assignment_Set_rec.Request_Id = FND_API.G_MISS_NUM THEN

        g_Assignment_Set_rec.Request_Id := Get_Request_Id;

        IF g_Assignment_Set_rec.Request_Id IS NOT NULL THEN

            IF  MRP_Validate_Assignment_Set.Val_Request_Id
                ( g_Assignment_Set_rec.Request_Id )
            THEN

                MRP_Assignment_Set_Util.Clear_Dependent_Attr
                (   p_attr_id                     => MRP_Assignment_Set_Util.G_REQUEST_ID
                ,   p_Assignment_Set_rec          => g_Assignment_Set_rec
                ,   x_Assignment_Set_rec          => g_Assignment_Set_rec
                );
            ELSE
                    g_Assignment_Set_rec.Request_Id := NULL;
            END IF;

        END IF;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_Assignment_Set_rec.Assignment_Set_Id = FND_API.G_MISS_NUM
    OR  g_Assignment_Set_rec.Assignment_Set_Name = FND_API.G_MISS_CHAR
    OR  g_Assignment_Set_rec.Attribute1 = FND_API.G_MISS_CHAR
    OR  g_Assignment_Set_rec.Attribute10 = FND_API.G_MISS_CHAR
    OR  g_Assignment_Set_rec.Attribute11 = FND_API.G_MISS_CHAR
    OR  g_Assignment_Set_rec.Attribute12 = FND_API.G_MISS_CHAR
    OR  g_Assignment_Set_rec.Attribute13 = FND_API.G_MISS_CHAR
    OR  g_Assignment_Set_rec.Attribute14 = FND_API.G_MISS_CHAR
    OR  g_Assignment_Set_rec.Attribute15 = FND_API.G_MISS_CHAR
    OR  g_Assignment_Set_rec.Attribute2 = FND_API.G_MISS_CHAR
    OR  g_Assignment_Set_rec.Attribute3 = FND_API.G_MISS_CHAR
    OR  g_Assignment_Set_rec.Attribute4 = FND_API.G_MISS_CHAR
    OR  g_Assignment_Set_rec.Attribute5 = FND_API.G_MISS_CHAR
    OR  g_Assignment_Set_rec.Attribute6 = FND_API.G_MISS_CHAR
    OR  g_Assignment_Set_rec.Attribute7 = FND_API.G_MISS_CHAR
    OR  g_Assignment_Set_rec.Attribute8 = FND_API.G_MISS_CHAR
    OR  g_Assignment_Set_rec.Attribute9 = FND_API.G_MISS_CHAR
    OR  g_Assignment_Set_rec.Attribute_Category = FND_API.G_MISS_CHAR
    OR  g_Assignment_Set_rec.Created_By = FND_API.G_MISS_NUM
    OR  g_Assignment_Set_rec.Creation_Date = FND_API.G_MISS_DATE
    OR  g_Assignment_Set_rec.Description = FND_API.G_MISS_CHAR
    OR  g_Assignment_Set_rec.Last_Updated_By = FND_API.G_MISS_NUM
    OR  g_Assignment_Set_rec.Last_Update_Date = FND_API.G_MISS_DATE
    OR  g_Assignment_Set_rec.Last_Update_Login = FND_API.G_MISS_NUM
    OR  g_Assignment_Set_rec.Program_Application_Id = FND_API.G_MISS_NUM
    OR  g_Assignment_Set_rec.Program_Id = FND_API.G_MISS_NUM
    OR  g_Assignment_Set_rec.Program_Update_Date = FND_API.G_MISS_DATE
    OR  g_Assignment_Set_rec.Request_Id = FND_API.G_MISS_NUM
    THEN

        MRP_Default_Assignment_Set.Attributes
        (   p_Assignment_Set_rec          => g_Assignment_Set_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_Assignment_Set_rec          => x_Assignment_Set_rec
        );

    ELSE

        --  Done defaulting attributes

        x_Assignment_Set_rec := g_Assignment_Set_rec;

    END IF;

END Attributes;

END MRP_Default_Assignment_Set;

/
