--------------------------------------------------------
--  DDL for Package Body MRP_ASSIGNMENT_SET_HANDLERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_ASSIGNMENT_SET_HANDLERS" AS
/* $Header: MRPHASTB.pls 115.2 99/07/16 12:22:09 porting ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Assignment_Set_Handlers';

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
)
IS
BEGIN

    UPDATE  MRP_ASSIGNMENT_SETS
    SET     ASSIGNMENT_SET_ID              = p_Assignment_Set_rec.Assignment_Set_Id
    ,       ASSIGNMENT_SET_NAME            = p_Assignment_Set_rec.Assignment_Set_Name
    ,       ATTRIBUTE1                     = p_Assignment_Set_rec.Attribute1
    ,       ATTRIBUTE10                    = p_Assignment_Set_rec.Attribute10
    ,       ATTRIBUTE11                    = p_Assignment_Set_rec.Attribute11
    ,       ATTRIBUTE12                    = p_Assignment_Set_rec.Attribute12
    ,       ATTRIBUTE13                    = p_Assignment_Set_rec.Attribute13
    ,       ATTRIBUTE14                    = p_Assignment_Set_rec.Attribute14
    ,       ATTRIBUTE15                    = p_Assignment_Set_rec.Attribute15
    ,       ATTRIBUTE2                     = p_Assignment_Set_rec.Attribute2
    ,       ATTRIBUTE3                     = p_Assignment_Set_rec.Attribute3
    ,       ATTRIBUTE4                     = p_Assignment_Set_rec.Attribute4
    ,       ATTRIBUTE5                     = p_Assignment_Set_rec.Attribute5
    ,       ATTRIBUTE6                     = p_Assignment_Set_rec.Attribute6
    ,       ATTRIBUTE7                     = p_Assignment_Set_rec.Attribute7
    ,       ATTRIBUTE8                     = p_Assignment_Set_rec.Attribute8
    ,       ATTRIBUTE9                     = p_Assignment_Set_rec.Attribute9
    ,       ATTRIBUTE_CATEGORY             = p_Assignment_Set_rec.Attribute_Category
    ,       CREATED_BY                     = p_Assignment_Set_rec.Created_By
    ,       CREATION_DATE                  = p_Assignment_Set_rec.Creation_Date
    ,       DESCRIPTION                    = p_Assignment_Set_rec.Description
    ,       LAST_UPDATED_BY                = p_Assignment_Set_rec.Last_Updated_By
    ,       LAST_UPDATE_DATE               = p_Assignment_Set_rec.Last_Update_Date
    ,       LAST_UPDATE_LOGIN              = p_Assignment_Set_rec.Last_Update_Login
    ,       PROGRAM_APPLICATION_ID         = p_Assignment_Set_rec.Program_Application_Id
    ,       PROGRAM_ID                     = p_Assignment_Set_rec.Program_Id
    ,       PROGRAM_UPDATE_DATE            = p_Assignment_Set_rec.Program_Update_Date
    ,       REQUEST_ID                     = p_Assignment_Set_rec.Request_Id
    WHERE   ASSIGNMENT_SET_ID = p_Assignment_Set_rec.Assignment_Set_Id
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
(   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
)
IS
BEGIN

    INSERT  INTO MRP_ASSIGNMENT_SETS
    (       ASSIGNMENT_SET_ID
    ,       ASSIGNMENT_SET_NAME
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
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    )
    VALUES
    (       p_Assignment_Set_rec.Assignment_Set_Id
    ,       p_Assignment_Set_rec.Assignment_Set_Name
    ,       p_Assignment_Set_rec.Attribute1
    ,       p_Assignment_Set_rec.Attribute10
    ,       p_Assignment_Set_rec.Attribute11
    ,       p_Assignment_Set_rec.Attribute12
    ,       p_Assignment_Set_rec.Attribute13
    ,       p_Assignment_Set_rec.Attribute14
    ,       p_Assignment_Set_rec.Attribute15
    ,       p_Assignment_Set_rec.Attribute2
    ,       p_Assignment_Set_rec.Attribute3
    ,       p_Assignment_Set_rec.Attribute4
    ,       p_Assignment_Set_rec.Attribute5
    ,       p_Assignment_Set_rec.Attribute6
    ,       p_Assignment_Set_rec.Attribute7
    ,       p_Assignment_Set_rec.Attribute8
    ,       p_Assignment_Set_rec.Attribute9
    ,       p_Assignment_Set_rec.Attribute_Category
    ,       p_Assignment_Set_rec.Created_By
    ,       p_Assignment_Set_rec.Creation_Date
    ,       p_Assignment_Set_rec.Description
    ,       p_Assignment_Set_rec.Last_Updated_By
    ,       p_Assignment_Set_rec.Last_Update_Date
    ,       p_Assignment_Set_rec.Last_Update_Login
    ,       p_Assignment_Set_rec.Program_Application_Id
    ,       p_Assignment_Set_rec.Program_Id
    ,       p_Assignment_Set_rec.Program_Update_Date
    ,       p_Assignment_Set_rec.Request_Id
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
(   p_Assignment_Set_Id             IN  NUMBER
)
IS

l_assignment_id         NUMBER;

CURSOR cur_Assignments IS
SELECT assignment_id
FROM   MRP_SR_ASSIGNMENTS
WHERE  ASSIGNMENT_SET_ID = p_Assignment_Set_Id;

BEGIN

    -- Before we delete an assignment set, we need to
    -- delete all the associated assignments

    OPEN cur_Assignments;

    WHILE TRUE LOOP
	FETCH cur_Assignments
	INTO  l_assignment_id;

	EXIT WHEN cur_Assignments%NOTFOUND;

	MRP_Assignment_Handlers.Delete_Row (
		p_Assignment_Id => l_assignment_id) ;
    END LOOP;

    CLOSE cur_Assignments;

    DELETE  FROM MRP_ASSIGNMENT_SETS
    WHERE   ASSIGNMENT_SET_ID = p_Assignment_Set_Id
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
,   p_Assignment_Set_rec            IN  MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   x_Assignment_Set_rec            OUT MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
)
IS
l_Assignment_Set_rec          MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type;
BEGIN

    SELECT  ASSIGNMENT_SET_ID
    ,       ASSIGNMENT_SET_NAME
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
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    INTO    l_Assignment_Set_rec.Assignment_Set_Id
    ,       l_Assignment_Set_rec.Assignment_Set_Name
    ,       l_Assignment_Set_rec.Attribute1
    ,       l_Assignment_Set_rec.Attribute10
    ,       l_Assignment_Set_rec.Attribute11
    ,       l_Assignment_Set_rec.Attribute12
    ,       l_Assignment_Set_rec.Attribute13
    ,       l_Assignment_Set_rec.Attribute14
    ,       l_Assignment_Set_rec.Attribute15
    ,       l_Assignment_Set_rec.Attribute2
    ,       l_Assignment_Set_rec.Attribute3
    ,       l_Assignment_Set_rec.Attribute4
    ,       l_Assignment_Set_rec.Attribute5
    ,       l_Assignment_Set_rec.Attribute6
    ,       l_Assignment_Set_rec.Attribute7
    ,       l_Assignment_Set_rec.Attribute8
    ,       l_Assignment_Set_rec.Attribute9
    ,       l_Assignment_Set_rec.Attribute_Category
    ,       l_Assignment_Set_rec.Created_By
    ,       l_Assignment_Set_rec.Creation_Date
    ,       l_Assignment_Set_rec.Description
    ,       l_Assignment_Set_rec.Last_Updated_By
    ,       l_Assignment_Set_rec.Last_Update_Date
    ,       l_Assignment_Set_rec.Last_Update_Login
    ,       l_Assignment_Set_rec.Program_Application_Id
    ,       l_Assignment_Set_rec.Program_Id
    ,       l_Assignment_Set_rec.Program_Update_Date
    ,       l_Assignment_Set_rec.Request_Id
    FROM    MRP_ASSIGNMENT_SETS
    WHERE   ASSIGNMENT_SET_ID = p_Assignment_Set_rec.Assignment_Set_Id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  (   (l_Assignment_Set_rec.Assignment_Set_Id =
             p_Assignment_Set_rec.Assignment_Set_Id) OR
            ((p_Assignment_Set_rec.Assignment_Set_Id = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_Set_rec.Assignment_Set_Id IS NULL) AND
                (p_Assignment_Set_rec.Assignment_Set_Id IS NULL))))
    AND (   (l_Assignment_Set_rec.Assignment_Set_Name =
             p_Assignment_Set_rec.Assignment_Set_Name) OR
            ((p_Assignment_Set_rec.Assignment_Set_Name = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_Set_rec.Assignment_Set_Name IS NULL) AND
                (p_Assignment_Set_rec.Assignment_Set_Name IS NULL))))
    AND (   (l_Assignment_Set_rec.Attribute1 =
             p_Assignment_Set_rec.Attribute1) OR
            ((p_Assignment_Set_rec.Attribute1 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_Set_rec.Attribute1 IS NULL) AND
                (p_Assignment_Set_rec.Attribute1 IS NULL))))
    AND (   (l_Assignment_Set_rec.Attribute10 =
             p_Assignment_Set_rec.Attribute10) OR
            ((p_Assignment_Set_rec.Attribute10 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_Set_rec.Attribute10 IS NULL) AND
                (p_Assignment_Set_rec.Attribute10 IS NULL))))
    AND (   (l_Assignment_Set_rec.Attribute11 =
             p_Assignment_Set_rec.Attribute11) OR
            ((p_Assignment_Set_rec.Attribute11 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_Set_rec.Attribute11 IS NULL) AND
                (p_Assignment_Set_rec.Attribute11 IS NULL))))
    AND (   (l_Assignment_Set_rec.Attribute12 =
             p_Assignment_Set_rec.Attribute12) OR
            ((p_Assignment_Set_rec.Attribute12 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_Set_rec.Attribute12 IS NULL) AND
                (p_Assignment_Set_rec.Attribute12 IS NULL))))
    AND (   (l_Assignment_Set_rec.Attribute13 =
             p_Assignment_Set_rec.Attribute13) OR
            ((p_Assignment_Set_rec.Attribute13 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_Set_rec.Attribute13 IS NULL) AND
                (p_Assignment_Set_rec.Attribute13 IS NULL))))
    AND (   (l_Assignment_Set_rec.Attribute14 =
             p_Assignment_Set_rec.Attribute14) OR
            ((p_Assignment_Set_rec.Attribute14 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_Set_rec.Attribute14 IS NULL) AND
                (p_Assignment_Set_rec.Attribute14 IS NULL))))
    AND (   (l_Assignment_Set_rec.Attribute15 =
             p_Assignment_Set_rec.Attribute15) OR
            ((p_Assignment_Set_rec.Attribute15 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_Set_rec.Attribute15 IS NULL) AND
                (p_Assignment_Set_rec.Attribute15 IS NULL))))
    AND (   (l_Assignment_Set_rec.Attribute2 =
             p_Assignment_Set_rec.Attribute2) OR
            ((p_Assignment_Set_rec.Attribute2 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_Set_rec.Attribute2 IS NULL) AND
                (p_Assignment_Set_rec.Attribute2 IS NULL))))
    AND (   (l_Assignment_Set_rec.Attribute3 =
             p_Assignment_Set_rec.Attribute3) OR
            ((p_Assignment_Set_rec.Attribute3 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_Set_rec.Attribute3 IS NULL) AND
                (p_Assignment_Set_rec.Attribute3 IS NULL))))
    AND (   (l_Assignment_Set_rec.Attribute4 =
             p_Assignment_Set_rec.Attribute4) OR
            ((p_Assignment_Set_rec.Attribute4 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_Set_rec.Attribute4 IS NULL) AND
                (p_Assignment_Set_rec.Attribute4 IS NULL))))
    AND (   (l_Assignment_Set_rec.Attribute5 =
             p_Assignment_Set_rec.Attribute5) OR
            ((p_Assignment_Set_rec.Attribute5 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_Set_rec.Attribute5 IS NULL) AND
                (p_Assignment_Set_rec.Attribute5 IS NULL))))
    AND (   (l_Assignment_Set_rec.Attribute6 =
             p_Assignment_Set_rec.Attribute6) OR
            ((p_Assignment_Set_rec.Attribute6 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_Set_rec.Attribute6 IS NULL) AND
                (p_Assignment_Set_rec.Attribute6 IS NULL))))
    AND (   (l_Assignment_Set_rec.Attribute7 =
             p_Assignment_Set_rec.Attribute7) OR
            ((p_Assignment_Set_rec.Attribute7 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_Set_rec.Attribute7 IS NULL) AND
                (p_Assignment_Set_rec.Attribute7 IS NULL))))
    AND (   (l_Assignment_Set_rec.Attribute8 =
             p_Assignment_Set_rec.Attribute8) OR
            ((p_Assignment_Set_rec.Attribute8 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_Set_rec.Attribute8 IS NULL) AND
                (p_Assignment_Set_rec.Attribute8 IS NULL))))
    AND (   (l_Assignment_Set_rec.Attribute9 =
             p_Assignment_Set_rec.Attribute9) OR
            ((p_Assignment_Set_rec.Attribute9 = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_Set_rec.Attribute9 IS NULL) AND
                (p_Assignment_Set_rec.Attribute9 IS NULL))))
    AND (   (l_Assignment_Set_rec.Attribute_Category =
             p_Assignment_Set_rec.Attribute_Category) OR
            ((p_Assignment_Set_rec.Attribute_Category = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_Set_rec.Attribute_Category IS NULL) AND
                (p_Assignment_Set_rec.Attribute_Category IS NULL))))
    AND (   (l_Assignment_Set_rec.Created_By =
             p_Assignment_Set_rec.Created_By) OR
            ((p_Assignment_Set_rec.Created_By = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_Set_rec.Created_By IS NULL) AND
                (p_Assignment_Set_rec.Created_By IS NULL))))
    AND (   (l_Assignment_Set_rec.Creation_Date =
             p_Assignment_Set_rec.Creation_Date) OR
            ((p_Assignment_Set_rec.Creation_Date = FND_API.G_MISS_DATE) OR
            (   (l_Assignment_Set_rec.Creation_Date IS NULL) AND
                (p_Assignment_Set_rec.Creation_Date IS NULL))))
    AND (   (l_Assignment_Set_rec.Description =
             p_Assignment_Set_rec.Description) OR
            ((p_Assignment_Set_rec.Description = FND_API.G_MISS_CHAR) OR
            (   (l_Assignment_Set_rec.Description IS NULL) AND
                (p_Assignment_Set_rec.Description IS NULL))))
    AND (   (l_Assignment_Set_rec.Last_Updated_By =
             p_Assignment_Set_rec.Last_Updated_By) OR
            ((p_Assignment_Set_rec.Last_Updated_By = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_Set_rec.Last_Updated_By IS NULL) AND
                (p_Assignment_Set_rec.Last_Updated_By IS NULL))))
    AND (   (l_Assignment_Set_rec.Last_Update_Date =
             p_Assignment_Set_rec.Last_Update_Date) OR
            ((p_Assignment_Set_rec.Last_Update_Date = FND_API.G_MISS_DATE) OR
            (   (l_Assignment_Set_rec.Last_Update_Date IS NULL) AND
                (p_Assignment_Set_rec.Last_Update_Date IS NULL))))
    AND (   (l_Assignment_Set_rec.Last_Update_Login =
             p_Assignment_Set_rec.Last_Update_Login) OR
            ((p_Assignment_Set_rec.Last_Update_Login = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_Set_rec.Last_Update_Login IS NULL) AND
                (p_Assignment_Set_rec.Last_Update_Login IS NULL))))
    AND (   (l_Assignment_Set_rec.Program_Application_Id =
             p_Assignment_Set_rec.Program_Application_Id) OR
            ((p_Assignment_Set_rec.Program_Application_Id = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_Set_rec.Program_Application_Id IS NULL) AND
                (p_Assignment_Set_rec.Program_Application_Id IS NULL))))
    AND (   (l_Assignment_Set_rec.Program_Id =
             p_Assignment_Set_rec.Program_Id) OR
            ((p_Assignment_Set_rec.Program_Id = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_Set_rec.Program_Id IS NULL) AND
                (p_Assignment_Set_rec.Program_Id IS NULL))))
    AND (   (l_Assignment_Set_rec.Program_Update_Date =
             p_Assignment_Set_rec.Program_Update_Date) OR
            ((p_Assignment_Set_rec.Program_Update_Date = FND_API.G_MISS_DATE) OR
            (   (l_Assignment_Set_rec.Program_Update_Date IS NULL) AND
                (p_Assignment_Set_rec.Program_Update_Date IS NULL))))
    AND (   (l_Assignment_Set_rec.Request_Id =
             p_Assignment_Set_rec.Request_Id) OR
            ((p_Assignment_Set_rec.Request_Id = FND_API.G_MISS_NUM) OR
            (   (l_Assignment_Set_rec.Request_Id IS NULL) AND
                (p_Assignment_Set_rec.Request_Id IS NULL))))
    THEN

        --  Row has not changed. Set out parameter.

        x_Assignment_Set_rec           := l_Assignment_Set_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_Assignment_Set_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Assignment_Set_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','BOI_LOCK_ROW_CHANGED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Assignment_Set_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','BOI_LOCK_ROW_DELETED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Assignment_Set_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','BOI_LOCK_ROW_ALREADY_LOCKED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Assignment_Set_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

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
(   p_Assignment_Set_Id             IN  NUMBER
) RETURN MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
IS
l_Assignment_Set_rec          MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type;
BEGIN

    SELECT  ASSIGNMENT_SET_ID
    ,       ASSIGNMENT_SET_NAME
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
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    INTO    l_Assignment_Set_rec.Assignment_Set_Id
    ,       l_Assignment_Set_rec.Assignment_Set_Name
    ,       l_Assignment_Set_rec.Attribute1
    ,       l_Assignment_Set_rec.Attribute10
    ,       l_Assignment_Set_rec.Attribute11
    ,       l_Assignment_Set_rec.Attribute12
    ,       l_Assignment_Set_rec.Attribute13
    ,       l_Assignment_Set_rec.Attribute14
    ,       l_Assignment_Set_rec.Attribute15
    ,       l_Assignment_Set_rec.Attribute2
    ,       l_Assignment_Set_rec.Attribute3
    ,       l_Assignment_Set_rec.Attribute4
    ,       l_Assignment_Set_rec.Attribute5
    ,       l_Assignment_Set_rec.Attribute6
    ,       l_Assignment_Set_rec.Attribute7
    ,       l_Assignment_Set_rec.Attribute8
    ,       l_Assignment_Set_rec.Attribute9
    ,       l_Assignment_Set_rec.Attribute_Category
    ,       l_Assignment_Set_rec.Created_By
    ,       l_Assignment_Set_rec.Creation_Date
    ,       l_Assignment_Set_rec.Description
    ,       l_Assignment_Set_rec.Last_Updated_By
    ,       l_Assignment_Set_rec.Last_Update_Date
    ,       l_Assignment_Set_rec.Last_Update_Login
    ,       l_Assignment_Set_rec.Program_Application_Id
    ,       l_Assignment_Set_rec.Program_Id
    ,       l_Assignment_Set_rec.Program_Update_Date
    ,       l_Assignment_Set_rec.Request_Id
    FROM    MRP_ASSIGNMENT_SETS
    WHERE   ASSIGNMENT_SET_ID = p_Assignment_Set_Id
    ;

    RETURN l_Assignment_Set_rec;

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
(   p_Assignment_Set_Id             IN  NUMBER
,   x_Assignment_Set_rec            OUT MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type
,   x_Assignment_Set_val_rec        OUT MRP_Src_Assignment_PUB.Assignment_Set_Val_Rec_Type
)
IS
BEGIN

    SELECT  ASSIGNMENT_SET_ID
    ,       ASSIGNMENT_SET_NAME
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
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    INTO    x_Assignment_Set_rec.Assignment_Set_Id
    ,       x_Assignment_Set_rec.Assignment_Set_Name
    ,       x_Assignment_Set_rec.Attribute1
    ,       x_Assignment_Set_rec.Attribute10
    ,       x_Assignment_Set_rec.Attribute11
    ,       x_Assignment_Set_rec.Attribute12
    ,       x_Assignment_Set_rec.Attribute13
    ,       x_Assignment_Set_rec.Attribute14
    ,       x_Assignment_Set_rec.Attribute15
    ,       x_Assignment_Set_rec.Attribute2
    ,       x_Assignment_Set_rec.Attribute3
    ,       x_Assignment_Set_rec.Attribute4
    ,       x_Assignment_Set_rec.Attribute5
    ,       x_Assignment_Set_rec.Attribute6
    ,       x_Assignment_Set_rec.Attribute7
    ,       x_Assignment_Set_rec.Attribute8
    ,       x_Assignment_Set_rec.Attribute9
    ,       x_Assignment_Set_rec.Attribute_Category
    ,       x_Assignment_Set_rec.Created_By
    ,       x_Assignment_Set_rec.Creation_Date
    ,       x_Assignment_Set_rec.Description
    ,       x_Assignment_Set_rec.Last_Updated_By
    ,       x_Assignment_Set_rec.Last_Update_Date
    ,       x_Assignment_Set_rec.Last_Update_Login
    ,       x_Assignment_Set_rec.Program_Application_Id
    ,       x_Assignment_Set_rec.Program_Id
    ,       x_Assignment_Set_rec.Program_Update_Date
    ,       x_Assignment_Set_rec.Request_Id
    FROM    MRP_ASSIGNMENT_SETS
    WHERE   ASSIGNMENT_SET_ID = p_Assignment_Set_Id
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

END MRP_Assignment_Set_Handlers;

/
