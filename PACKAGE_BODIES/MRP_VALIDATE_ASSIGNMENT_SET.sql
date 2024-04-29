--------------------------------------------------------
--  DDL for Package Body MRP_VALIDATE_ASSIGNMENT_SET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_VALIDATE_ASSIGNMENT_SET" AS
/* $Header: MRPLASTB.pls 120.1 2005/06/16 09:22:10 ichoudhu noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Validate_Assignment_Set';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   p_old_Assignment_Set_rec        IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_SET_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Check required attributes.

    IF  p_Assignment_Set_rec.Assignment_Set_Id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Assignment_Set_Id');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    --
    --  Check rest of required attributes here.
    --


    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --
    --  Check conditionally required attributes here.
    --


    --
    --  Validate attribute dependencies here.
    --


    --  Done validating entity

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Validate entity delete.

    NULL;

    --  Done.

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity_Delete'
            );
        END IF;

END Entity_Delete;

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   p_old_Assignment_Set_rec        IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type :=
                                        MRP_Src_Assignment_PUB.G_MISS_ASSIGNMENT_SET_REC
)
IS
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate Assignment_Set attributes

    IF (p_Assignment_Set_rec.Assignment_Set_Id IS NOT NULL AND
        (   p_Assignment_Set_rec.Assignment_Set_Id <>
            p_old_Assignment_Set_rec.Assignment_Set_Id OR
            p_old_Assignment_Set_rec.Assignment_Set_Id IS NULL ))
    THEN
        IF NOT  MRP_Validate.Assignment_Set
            (   p_Assignment_Set_rec.Assignment_Set_Id
            )
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Assignment_Set_Name IS NOT NULL AND
        (   p_Assignment_Set_rec.Assignment_Set_Name <>
            p_old_Assignment_Set_rec.Assignment_Set_Name OR
            p_old_Assignment_Set_rec.Assignment_Set_Name IS NULL )
    THEN
        IF NOT Val_Assignment_Set_Name(p_Assignment_Set_rec.Assignment_Set_Name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Attribute1 IS NOT NULL AND
        (   p_Assignment_Set_rec.Attribute1 <>
            p_old_Assignment_Set_rec.Attribute1 OR
            p_old_Assignment_Set_rec.Attribute1 IS NULL )
    THEN
        IF NOT Val_Attribute1(p_Assignment_Set_rec.Attribute1) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Attribute10 IS NOT NULL AND
        (   p_Assignment_Set_rec.Attribute10 <>
            p_old_Assignment_Set_rec.Attribute10 OR
            p_old_Assignment_Set_rec.Attribute10 IS NULL )
    THEN
        IF NOT Val_Attribute10(p_Assignment_Set_rec.Attribute10) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Attribute11 IS NOT NULL AND
        (   p_Assignment_Set_rec.Attribute11 <>
            p_old_Assignment_Set_rec.Attribute11 OR
            p_old_Assignment_Set_rec.Attribute11 IS NULL )
    THEN
        IF NOT Val_Attribute11(p_Assignment_Set_rec.Attribute11) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Attribute12 IS NOT NULL AND
        (   p_Assignment_Set_rec.Attribute12 <>
            p_old_Assignment_Set_rec.Attribute12 OR
            p_old_Assignment_Set_rec.Attribute12 IS NULL )
    THEN
        IF NOT Val_Attribute12(p_Assignment_Set_rec.Attribute12) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Attribute13 IS NOT NULL AND
        (   p_Assignment_Set_rec.Attribute13 <>
            p_old_Assignment_Set_rec.Attribute13 OR
            p_old_Assignment_Set_rec.Attribute13 IS NULL )
    THEN
        IF NOT Val_Attribute13(p_Assignment_Set_rec.Attribute13) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Attribute14 IS NOT NULL AND
        (   p_Assignment_Set_rec.Attribute14 <>
            p_old_Assignment_Set_rec.Attribute14 OR
            p_old_Assignment_Set_rec.Attribute14 IS NULL )
    THEN
        IF NOT Val_Attribute14(p_Assignment_Set_rec.Attribute14) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Attribute15 IS NOT NULL AND
        (   p_Assignment_Set_rec.Attribute15 <>
            p_old_Assignment_Set_rec.Attribute15 OR
            p_old_Assignment_Set_rec.Attribute15 IS NULL )
    THEN
        IF NOT Val_Attribute15(p_Assignment_Set_rec.Attribute15) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Attribute2 IS NOT NULL AND
        (   p_Assignment_Set_rec.Attribute2 <>
            p_old_Assignment_Set_rec.Attribute2 OR
            p_old_Assignment_Set_rec.Attribute2 IS NULL )
    THEN
        IF NOT Val_Attribute2(p_Assignment_Set_rec.Attribute2) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Attribute3 IS NOT NULL AND
        (   p_Assignment_Set_rec.Attribute3 <>
            p_old_Assignment_Set_rec.Attribute3 OR
            p_old_Assignment_Set_rec.Attribute3 IS NULL )
    THEN
        IF NOT Val_Attribute3(p_Assignment_Set_rec.Attribute3) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Attribute4 IS NOT NULL AND
        (   p_Assignment_Set_rec.Attribute4 <>
            p_old_Assignment_Set_rec.Attribute4 OR
            p_old_Assignment_Set_rec.Attribute4 IS NULL )
    THEN
        IF NOT Val_Attribute4(p_Assignment_Set_rec.Attribute4) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Attribute5 IS NOT NULL AND
        (   p_Assignment_Set_rec.Attribute5 <>
            p_old_Assignment_Set_rec.Attribute5 OR
            p_old_Assignment_Set_rec.Attribute5 IS NULL )
    THEN
        IF NOT Val_Attribute5(p_Assignment_Set_rec.Attribute5) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Attribute6 IS NOT NULL AND
        (   p_Assignment_Set_rec.Attribute6 <>
            p_old_Assignment_Set_rec.Attribute6 OR
            p_old_Assignment_Set_rec.Attribute6 IS NULL )
    THEN
        IF NOT Val_Attribute6(p_Assignment_Set_rec.Attribute6) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Attribute7 IS NOT NULL AND
        (   p_Assignment_Set_rec.Attribute7 <>
            p_old_Assignment_Set_rec.Attribute7 OR
            p_old_Assignment_Set_rec.Attribute7 IS NULL )
    THEN
        IF NOT Val_Attribute7(p_Assignment_Set_rec.Attribute7) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Attribute8 IS NOT NULL AND
        (   p_Assignment_Set_rec.Attribute8 <>
            p_old_Assignment_Set_rec.Attribute8 OR
            p_old_Assignment_Set_rec.Attribute8 IS NULL )
    THEN
        IF NOT Val_Attribute8(p_Assignment_Set_rec.Attribute8) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Attribute9 IS NOT NULL AND
        (   p_Assignment_Set_rec.Attribute9 <>
            p_old_Assignment_Set_rec.Attribute9 OR
            p_old_Assignment_Set_rec.Attribute9 IS NULL )
    THEN
        IF NOT Val_Attribute9(p_Assignment_Set_rec.Attribute9) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Attribute_Category IS NOT NULL AND
        (   p_Assignment_Set_rec.Attribute_Category <>
            p_old_Assignment_Set_rec.Attribute_Category OR
            p_old_Assignment_Set_rec.Attribute_Category IS NULL )
    THEN
        IF NOT Val_Attribute_Category(p_Assignment_Set_rec.Attribute_Category) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Created_By IS NOT NULL AND
        (   p_Assignment_Set_rec.Created_By <>
            p_old_Assignment_Set_rec.Created_By OR
            p_old_Assignment_Set_rec.Created_By IS NULL )
    THEN
        IF NOT Val_Created_By(p_Assignment_Set_rec.Created_By) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Creation_Date IS NOT NULL AND
        (   p_Assignment_Set_rec.Creation_Date <>
            p_old_Assignment_Set_rec.Creation_Date OR
            p_old_Assignment_Set_rec.Creation_Date IS NULL )
    THEN
        IF NOT Val_Creation_Date(p_Assignment_Set_rec.Creation_Date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Description IS NOT NULL AND
        (   p_Assignment_Set_rec.Description <>
            p_old_Assignment_Set_rec.Description OR
            p_old_Assignment_Set_rec.Description IS NULL )
    THEN
        IF NOT Val_Description(p_Assignment_Set_rec.Description) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Last_Updated_By IS NOT NULL AND
        (   p_Assignment_Set_rec.Last_Updated_By <>
            p_old_Assignment_Set_rec.Last_Updated_By OR
            p_old_Assignment_Set_rec.Last_Updated_By IS NULL )
    THEN
        IF NOT Val_Last_Updated_By(p_Assignment_Set_rec.Last_Updated_By) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Last_Update_Date IS NOT NULL AND
        (   p_Assignment_Set_rec.Last_Update_Date <>
            p_old_Assignment_Set_rec.Last_Update_Date OR
            p_old_Assignment_Set_rec.Last_Update_Date IS NULL )
    THEN
        IF NOT Val_Last_Update_Date(p_Assignment_Set_rec.Last_Update_Date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Last_Update_Login IS NOT NULL AND
        (   p_Assignment_Set_rec.Last_Update_Login <>
            p_old_Assignment_Set_rec.Last_Update_Login OR
            p_old_Assignment_Set_rec.Last_Update_Login IS NULL )
    THEN
        IF NOT Val_Last_Update_Login(p_Assignment_Set_rec.Last_Update_Login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Program_Application_Id IS NOT NULL AND
        (   p_Assignment_Set_rec.Program_Application_Id <>
            p_old_Assignment_Set_rec.Program_Application_Id OR
            p_old_Assignment_Set_rec.Program_Application_Id IS NULL )
    THEN
        IF NOT Val_Program_Application_Id(p_Assignment_Set_rec.Program_Application_Id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Program_Id IS NOT NULL AND
        (   p_Assignment_Set_rec.Program_Id <>
            p_old_Assignment_Set_rec.Program_Id OR
            p_old_Assignment_Set_rec.Program_Id IS NULL )
    THEN
        IF NOT Val_Program_Id(p_Assignment_Set_rec.Program_Id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Program_Update_Date IS NOT NULL AND
        (   p_Assignment_Set_rec.Program_Update_Date <>
            p_old_Assignment_Set_rec.Program_Update_Date OR
            p_old_Assignment_Set_rec.Program_Update_Date IS NULL )
    THEN
        IF NOT Val_Program_Update_Date(p_Assignment_Set_rec.Program_Update_Date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Assignment_Set_rec.Request_Id IS NOT NULL AND
        (   p_Assignment_Set_rec.Request_Id <>
            p_old_Assignment_Set_rec.Request_Id OR
            p_old_Assignment_Set_rec.Request_Id IS NULL )
    THEN
        IF NOT Val_Request_Id(p_Assignment_Set_rec.Request_Id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    --  Done validating attributes

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;

END Attributes;

--  Entity attribute validation functions.


--  Function Val_Assignment_Set_Name

FUNCTION Val_Assignment_Set_Name
(   p_Assignment_Set_Name           IN  VARCHAR2
)   RETURN BOOLEAN
IS

l_count		NUMBER;

BEGIN

    IF p_Assignment_Set_Name IS NULL OR
       p_Assignment_Set_Name = FND_API.G_MISS_CHAR
    THEN
	dbms_output.put_line ('Val_Assignment_Set_Name Error');
        FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Assignment_Set_Name');
        FND_MSG_PUB.Add;
        RETURN FALSE;
    ELSE
        -- make sure that this assignment set does
        -- not already exist in the system

        SELECT count(*)
        INTO   l_count
        FROM   MRP_ASSIGNMENT_SETS
        WHERE  assignment_set_name = p_Assignment_Set_Name;

        IF l_count > 0 THEN
	    dbms_output.put_line ('Val_Assignment_Set_Name Error');
            FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Assignment_Set_Name');
            FND_MSG_PUB.Add;
            RETURN FALSE;
        END IF;

    END IF;

    RETURN TRUE;

END Val_Assignment_Set_Name;

--  Function Val_Attribute1

FUNCTION Val_Attribute1
(   p_Attribute1                    IN  VARCHAR2
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Attribute1 IS NULL OR
       p_Attribute1 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Attribute1;

--  Function Val_Attribute10

FUNCTION Val_Attribute10
(   p_Attribute10                   IN  VARCHAR2
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Attribute10 IS NULL OR
       p_Attribute10 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Attribute10;

--  Function Val_Attribute11

FUNCTION Val_Attribute11
(   p_Attribute11                   IN  VARCHAR2
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Attribute11 IS NULL OR
       p_Attribute11 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Attribute11;

--  Function Val_Attribute12

FUNCTION Val_Attribute12
(   p_Attribute12                   IN  VARCHAR2
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Attribute12 IS NULL OR
       p_Attribute12 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Attribute12;

--  Function Val_Attribute13

FUNCTION Val_Attribute13
(   p_Attribute13                   IN  VARCHAR2
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Attribute13 IS NULL OR
       p_Attribute13 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Attribute13;

--  Function Val_Attribute14

FUNCTION Val_Attribute14
(   p_Attribute14                   IN  VARCHAR2
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Attribute14 IS NULL OR
       p_Attribute14 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Attribute14;

--  Function Val_Attribute15

FUNCTION Val_Attribute15
(   p_Attribute15                   IN  VARCHAR2
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Attribute15 IS NULL OR
       p_Attribute15 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Attribute15;

--  Function Val_Attribute2

FUNCTION Val_Attribute2
(   p_Attribute2                    IN  VARCHAR2
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Attribute2 IS NULL OR
       p_Attribute2 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Attribute2;

--  Function Val_Attribute3

FUNCTION Val_Attribute3
(   p_Attribute3                    IN  VARCHAR2
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Attribute3 IS NULL OR
       p_Attribute3 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Attribute3;

--  Function Val_Attribute4

FUNCTION Val_Attribute4
(   p_Attribute4                    IN  VARCHAR2
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Attribute4 IS NULL OR
       p_Attribute4 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Attribute4;

--  Function Val_Attribute5

FUNCTION Val_Attribute5
(   p_Attribute5                    IN  VARCHAR2
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Attribute5 IS NULL OR
       p_Attribute5 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Attribute5;

--  Function Val_Attribute6

FUNCTION Val_Attribute6
(   p_Attribute6                    IN  VARCHAR2
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Attribute6 IS NULL OR
       p_Attribute6 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Attribute6;

--  Function Val_Attribute7

FUNCTION Val_Attribute7
(   p_Attribute7                    IN  VARCHAR2
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Attribute7 IS NULL OR
       p_Attribute7 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Attribute7;

--  Function Val_Attribute8

FUNCTION Val_Attribute8
(   p_Attribute8                    IN  VARCHAR2
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Attribute8 IS NULL OR
       p_Attribute8 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Attribute8;

--  Function Val_Attribute9

FUNCTION Val_Attribute9
(   p_Attribute9                    IN  VARCHAR2
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Attribute9 IS NULL OR
       p_Attribute9 = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Attribute9;

--  Function Val_Attribute_Category

FUNCTION Val_Attribute_Category
(   p_Attribute_Category            IN  VARCHAR2
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Attribute_Category IS NULL OR
       p_Attribute_Category = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Attribute_Category;

--  Function Val_Created_By

FUNCTION Val_Created_By
(   p_Created_By                    IN  NUMBER
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Created_By IS NULL OR
       p_Created_By = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Created_By;

--  Function Val_Creation_Date

FUNCTION Val_Creation_Date
(   p_Creation_Date                 IN  DATE
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Creation_Date IS NULL OR
       p_Creation_Date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Creation_Date;

--  Function Val_Description

FUNCTION Val_Description
(   p_Description                   IN  VARCHAR2
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Description IS NULL OR
       p_Description = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Description;

--  Function Val_Last_Updated_By

FUNCTION Val_Last_Updated_By
(   p_Last_Updated_By               IN  NUMBER
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Last_Updated_By IS NULL OR
       p_Last_Updated_By = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Last_Updated_By;

--  Function Val_Last_Update_Date

FUNCTION Val_Last_Update_Date
(   p_Last_Update_Date              IN  DATE
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Last_Update_Date IS NULL OR
       p_Last_Update_Date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Last_Update_Date;

--  Function Val_Last_Update_Login

FUNCTION Val_Last_Update_Login
(   p_Last_Update_Login             IN  NUMBER
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Last_Update_Login IS NULL OR
       p_Last_Update_Login = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Last_Update_Login;

--  Function Val_Program_Application_Id

FUNCTION Val_Program_Application_Id
(   p_Program_Application_Id        IN  NUMBER
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Program_Application_Id IS NULL OR
       p_Program_Application_Id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Program_Application_Id;

--  Function Val_Program_Id

FUNCTION Val_Program_Id
(   p_Program_Id                    IN  NUMBER
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Program_Id IS NULL OR
       p_Program_Id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Program_Id;

--  Function Val_Program_Update_Date

FUNCTION Val_Program_Update_Date
(   p_Program_Update_Date           IN  DATE
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Program_Update_Date IS NULL OR
       p_Program_Update_Date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Program_Update_Date;

--  Function Val_Request_Id

FUNCTION Val_Request_Id
(   p_Request_Id                    IN  NUMBER
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Request_Id IS NULL OR
       p_Request_Id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Request_Id;

END MRP_Validate_Assignment_Set;

/
