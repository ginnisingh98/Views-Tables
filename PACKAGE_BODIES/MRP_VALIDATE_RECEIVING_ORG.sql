--------------------------------------------------------
--  DDL for Package Body MRP_VALIDATE_RECEIVING_ORG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_VALIDATE_RECEIVING_ORG" AS
/* $Header: MRPLRCOB.pls 120.1 2005/06/16 10:03:04 ichoudhu noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Validate_Receiving_Org';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_Receiving_Org_rec             IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type
,   p_old_Receiving_Org_rec         IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_RECEIVING_ORG_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Check required attributes.

    IF  p_Receiving_Org_rec.Sr_Receipt_Id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

	dbms_output.put_line ('Error - Sr_Receipt_Id is null');

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Sr_Receipt_Id');
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
,   p_Receiving_Org_rec             IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

l_count		NUMBER;

BEGIN

    --  Validate entity delete.

    -- Check to see if this is the only receiving Org that is
    -- associated with the Sourcing Rule. If yes do not allow delete

    SELECT count(*)
    INTO   l_count
    FROM   MRP_SR_RECEIPT_ORG
    WHERE  sourcing_rule_id = p_Receiving_Org_rec.sourcing_rule_id
    AND    sr_receipt_id <> p_Receiving_Org_rec.sr_receipt_id;

    IF l_count = 0 THEN
	dbms_output.put_line ('This is the only rec. org for the s rule');
        FND_MESSAGE.SET_NAME('MRP','MRP_OPERATION_ERROR');
        FND_MESSAGE.SET_TOKEN('OPERATION','DELETE');
        FND_MESSAGE.SET_TOKEN('ENTITY','Receiving_Org');
        FND_MESSAGE.SET_TOKEN('DETAILS',
	    'There is only one Receiving Organization for the Sourcing Rule');
        FND_MSG_PUB.Add;
	l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

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
,   p_Receiving_Org_rec             IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type
,   p_old_Receiving_Org_rec         IN  MRP_Sourcing_Rule_PUB.Receiving_Org_Rec_Type :=
                                        MRP_Sourcing_Rule_PUB.G_MISS_RECEIVING_ORG_REC
)
IS
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate Receiving_Org attributes

    IF (p_Receiving_Org_rec.Sr_Receipt_Id IS NOT NULL AND
        (   p_Receiving_Org_rec.Sr_Receipt_Id <>
            p_old_Receiving_Org_rec.Sr_Receipt_Id OR
            p_old_Receiving_Org_rec.Sr_Receipt_Id IS NULL ))
    THEN
        IF NOT MRP_Validate.Receiving_Org
            (   p_Receiving_Org_rec.Sr_Receipt_Id
            )
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Attribute1 IS NOT NULL AND
        (   p_Receiving_Org_rec.Attribute1 <>
            p_old_Receiving_Org_rec.Attribute1 OR
            p_old_Receiving_Org_rec.Attribute1 IS NULL )
    THEN
        IF NOT Val_Attribute1(p_Receiving_Org_rec.Attribute1) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Attribute10 IS NOT NULL AND
        (   p_Receiving_Org_rec.Attribute10 <>
            p_old_Receiving_Org_rec.Attribute10 OR
            p_old_Receiving_Org_rec.Attribute10 IS NULL )
    THEN
        IF NOT Val_Attribute10(p_Receiving_Org_rec.Attribute10) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Attribute11 IS NOT NULL AND
        (   p_Receiving_Org_rec.Attribute11 <>
            p_old_Receiving_Org_rec.Attribute11 OR
            p_old_Receiving_Org_rec.Attribute11 IS NULL )
    THEN
        IF NOT Val_Attribute11(p_Receiving_Org_rec.Attribute11) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Attribute12 IS NOT NULL AND
        (   p_Receiving_Org_rec.Attribute12 <>
            p_old_Receiving_Org_rec.Attribute12 OR
            p_old_Receiving_Org_rec.Attribute12 IS NULL )
    THEN
        IF NOT Val_Attribute12(p_Receiving_Org_rec.Attribute12) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Attribute13 IS NOT NULL AND
        (   p_Receiving_Org_rec.Attribute13 <>
            p_old_Receiving_Org_rec.Attribute13 OR
            p_old_Receiving_Org_rec.Attribute13 IS NULL )
    THEN
        IF NOT Val_Attribute13(p_Receiving_Org_rec.Attribute13) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Attribute14 IS NOT NULL AND
        (   p_Receiving_Org_rec.Attribute14 <>
            p_old_Receiving_Org_rec.Attribute14 OR
            p_old_Receiving_Org_rec.Attribute14 IS NULL )
    THEN
        IF NOT Val_Attribute14(p_Receiving_Org_rec.Attribute14) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Attribute15 IS NOT NULL AND
        (   p_Receiving_Org_rec.Attribute15 <>
            p_old_Receiving_Org_rec.Attribute15 OR
            p_old_Receiving_Org_rec.Attribute15 IS NULL )
    THEN
        IF NOT Val_Attribute15(p_Receiving_Org_rec.Attribute15) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Attribute2 IS NOT NULL AND
        (   p_Receiving_Org_rec.Attribute2 <>
            p_old_Receiving_Org_rec.Attribute2 OR
            p_old_Receiving_Org_rec.Attribute2 IS NULL )
    THEN
        IF NOT Val_Attribute2(p_Receiving_Org_rec.Attribute2) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Attribute3 IS NOT NULL AND
        (   p_Receiving_Org_rec.Attribute3 <>
            p_old_Receiving_Org_rec.Attribute3 OR
            p_old_Receiving_Org_rec.Attribute3 IS NULL )
    THEN
        IF NOT Val_Attribute3(p_Receiving_Org_rec.Attribute3) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Attribute4 IS NOT NULL AND
        (   p_Receiving_Org_rec.Attribute4 <>
            p_old_Receiving_Org_rec.Attribute4 OR
            p_old_Receiving_Org_rec.Attribute4 IS NULL )
    THEN
        IF NOT Val_Attribute4(p_Receiving_Org_rec.Attribute4) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Attribute5 IS NOT NULL AND
        (   p_Receiving_Org_rec.Attribute5 <>
            p_old_Receiving_Org_rec.Attribute5 OR
            p_old_Receiving_Org_rec.Attribute5 IS NULL )
    THEN
        IF NOT Val_Attribute5(p_Receiving_Org_rec.Attribute5) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Attribute6 IS NOT NULL AND
        (   p_Receiving_Org_rec.Attribute6 <>
            p_old_Receiving_Org_rec.Attribute6 OR
            p_old_Receiving_Org_rec.Attribute6 IS NULL )
    THEN
        IF NOT Val_Attribute6(p_Receiving_Org_rec.Attribute6) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Attribute7 IS NOT NULL AND
        (   p_Receiving_Org_rec.Attribute7 <>
            p_old_Receiving_Org_rec.Attribute7 OR
            p_old_Receiving_Org_rec.Attribute7 IS NULL )
    THEN
        IF NOT Val_Attribute7(p_Receiving_Org_rec.Attribute7) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Attribute8 IS NOT NULL AND
        (   p_Receiving_Org_rec.Attribute8 <>
            p_old_Receiving_Org_rec.Attribute8 OR
            p_old_Receiving_Org_rec.Attribute8 IS NULL )
    THEN
        IF NOT Val_Attribute8(p_Receiving_Org_rec.Attribute8) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Attribute9 IS NOT NULL AND
        (   p_Receiving_Org_rec.Attribute9 <>
            p_old_Receiving_Org_rec.Attribute9 OR
            p_old_Receiving_Org_rec.Attribute9 IS NULL )
    THEN
        IF NOT Val_Attribute9(p_Receiving_Org_rec.Attribute9) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Attribute_Category IS NOT NULL AND
        (   p_Receiving_Org_rec.Attribute_Category <>
            p_old_Receiving_Org_rec.Attribute_Category OR
            p_old_Receiving_Org_rec.Attribute_Category IS NULL )
    THEN
        IF NOT Val_Attribute_Category(p_Receiving_Org_rec.Attribute_Category) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Created_By IS NOT NULL AND
        (   p_Receiving_Org_rec.Created_By <>
            p_old_Receiving_Org_rec.Created_By OR
            p_old_Receiving_Org_rec.Created_By IS NULL )
    THEN
        IF NOT Val_Created_By(p_Receiving_Org_rec.Created_By) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Creation_Date IS NOT NULL AND
        (   p_Receiving_Org_rec.Creation_Date <>
            p_old_Receiving_Org_rec.Creation_Date OR
            p_old_Receiving_Org_rec.Creation_Date IS NULL )
    THEN
        IF NOT Val_Creation_Date(p_Receiving_Org_rec.Creation_Date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Disable_Date IS NOT NULL AND
        (   p_Receiving_Org_rec.Disable_Date <>
            p_old_Receiving_Org_rec.Disable_Date OR
            p_old_Receiving_Org_rec.Disable_Date IS NULL )
    THEN
        IF NOT Val_Disable_Date(p_Receiving_Org_rec.Effective_Date,
				p_Receiving_Org_rec.Disable_Date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Effective_Date IS NOT NULL AND
        (   p_Receiving_Org_rec.Effective_Date <>
            p_old_Receiving_Org_rec.Effective_Date OR
            p_old_Receiving_Org_rec.Effective_Date IS NULL )
    THEN
        IF NOT Val_Effective_Date(p_Receiving_Org_rec.Effective_Date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Last_Updated_By IS NOT NULL AND
        (   p_Receiving_Org_rec.Last_Updated_By <>
            p_old_Receiving_Org_rec.Last_Updated_By OR
            p_old_Receiving_Org_rec.Last_Updated_By IS NULL )
    THEN
        IF NOT Val_Last_Updated_By(p_Receiving_Org_rec.Last_Updated_By) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Last_Update_Date IS NOT NULL AND
        (   p_Receiving_Org_rec.Last_Update_Date <>
            p_old_Receiving_Org_rec.Last_Update_Date OR
            p_old_Receiving_Org_rec.Last_Update_Date IS NULL )
    THEN
        IF NOT Val_Last_Update_Date(p_Receiving_Org_rec.Last_Update_Date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Last_Update_Login IS NOT NULL AND
        (   p_Receiving_Org_rec.Last_Update_Login <>
            p_old_Receiving_Org_rec.Last_Update_Login OR
            p_old_Receiving_Org_rec.Last_Update_Login IS NULL )
    THEN
        IF NOT Val_Last_Update_Login(p_Receiving_Org_rec.Last_Update_Login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Program_Application_Id IS NOT NULL AND
        (   p_Receiving_Org_rec.Program_Application_Id <>
            p_old_Receiving_Org_rec.Program_Application_Id OR
            p_old_Receiving_Org_rec.Program_Application_Id IS NULL )
    THEN
        IF NOT Val_Program_Application_Id(p_Receiving_Org_rec.Program_Application_Id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Program_Id IS NOT NULL AND
        (   p_Receiving_Org_rec.Program_Id <>
            p_old_Receiving_Org_rec.Program_Id OR
            p_old_Receiving_Org_rec.Program_Id IS NULL )
    THEN
        IF NOT Val_Program_Id(p_Receiving_Org_rec.Program_Id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Program_Update_Date IS NOT NULL AND
        (   p_Receiving_Org_rec.Program_Update_Date <>
            p_old_Receiving_Org_rec.Program_Update_Date OR
            p_old_Receiving_Org_rec.Program_Update_Date IS NULL )
    THEN
        IF NOT Val_Program_Update_Date(p_Receiving_Org_rec.Program_Update_Date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Receipt_Organization_Id IS NOT NULL AND
        (   p_Receiving_Org_rec.Receipt_Organization_Id <>
            p_old_Receiving_Org_rec.Receipt_Organization_Id OR
            p_old_Receiving_Org_rec.Receipt_Organization_Id IS NULL )
    THEN
        IF NOT Val_Receipt_Organization_Id(
			p_Receiving_Org_rec.Sourcing_Rule_id,
			p_Receiving_Org_rec.Receipt_Organization_Id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Request_Id IS NOT NULL AND
        (   p_Receiving_Org_rec.Request_Id <>
            p_old_Receiving_Org_rec.Request_Id OR
            p_old_Receiving_Org_rec.Request_Id IS NULL )
    THEN
        IF NOT Val_Request_Id(p_Receiving_Org_rec.Request_Id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Receiving_Org_rec.Sourcing_Rule_Id IS NOT NULL AND
        (   p_Receiving_Org_rec.Sourcing_Rule_Id <>
            p_old_Receiving_Org_rec.Sourcing_Rule_Id OR
            p_old_Receiving_Org_rec.Sourcing_Rule_Id IS NULL )
    THEN
        IF NOT Val_Sourcing_Rule_Id(p_Receiving_Org_rec.Sourcing_Rule_Id) THEN
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

--  Function Val_Disable_Date

FUNCTION Val_Disable_Date
(   p_Effective_Date                IN  DATE
,   p_Disable_Date                  IN  DATE
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Disable_Date IS NULL OR
       p_Disable_Date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    ELSIF p_Disable_Date < p_Effective_Date THEN
        dbms_output.put_line ('Val_Disable_Date Error');
        FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_VALUE_ERROR');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Disable_Date');
        FND_MESSAGE.SET_TOKEN('DETAILS',
			'Disable_Date Cannot be Less than Effective_Date');
        FND_MSG_PUB.Add;
        RETURN FALSE;
    END IF;

    RETURN TRUE;

END Val_Disable_Date;

--  Function Val_Effective_Date

FUNCTION Val_Effective_Date
(   p_Effective_Date                IN  DATE
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Effective_Date IS NULL OR
       p_Effective_Date = FND_API.G_MISS_DATE
    THEN
	dbms_output.put_line ('Val_Effective_Date Error');
        FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Effective_Date');
        FND_MSG_PUB.Add;
        RETURN FALSE;
    ELSE
	IF p_Effective_Date < trunc(SYSDATE) THEN
	    dbms_output.put_line ('Val_Effective_Date Error');
            FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Effective_Date');
            FND_MESSAGE.SET_TOKEN('DETAILS',
			'Effective_Date Cannot be less than Current Date');
            FND_MSG_PUB.Add;
            RETURN FALSE;
	END IF;
    END IF;

    RETURN TRUE;

END Val_Effective_Date;

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

--  Function Val_Receipt_Organization_Id

FUNCTION Val_Receipt_Organization_Id
(   p_Sourcing_Rule_id              IN  NUMBER
,   p_Receipt_Organization_Id       IN  NUMBER
)   RETURN BOOLEAN
IS

l_count         	number;
l_organization_id	number := FND_API.G_MISS_NUM;

Cursor cur_sr_org is
SELECT organization_id
FROM   mrp_sourcing_rules
WHERE  sourcing_rule_id = p_sourcing_rule_id;

BEGIN

    IF p_Receipt_Organization_Id IS NULL OR
       p_Receipt_Organization_Id = FND_API.G_MISS_NUM
    THEN

	Open cur_sr_org;
	Fetch cur_sr_org INTO l_organization_id;

        IF l_organization_id is not NULL THEN
	    dbms_output.put_line ('Val_Receipt_Organization_Id Error');
            FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Receipt_Organization_Id');
            FND_MSG_PUB.Add;
            RETURN FALSE;
	ELSE
	    RETURN TRUE;
	END IF;

	Close cur_sr_org;

    ELSE
        SELECT count(*)
        INTO   l_count
        FROM   MTL_PARAMETERS
        WHERE  organization_id = p_Receipt_Organization_Id;

        IF l_count = 0 THEN
	    dbms_output.put_line ('Val_Receipt_Organization_Id Error');
            FND_MESSAGE.SET_NAME('MRP','MRP_ATTRIBUTE_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Receipt_Organization_Id');
            FND_MSG_PUB.Add;
            RETURN FALSE;
        END IF;
    END IF;

    RETURN TRUE;

END Val_Receipt_Organization_Id;

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

--  Function Val_Sourcing_Rule_Id

FUNCTION Val_Sourcing_Rule_Id
(   p_Sourcing_Rule_Id              IN  NUMBER
)   RETURN BOOLEAN
IS
BEGIN

    IF p_Sourcing_Rule_Id IS NULL OR
       p_Sourcing_Rule_Id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    RETURN TRUE;

END Val_Sourcing_Rule_Id;

END MRP_Validate_Receiving_Org;

/
