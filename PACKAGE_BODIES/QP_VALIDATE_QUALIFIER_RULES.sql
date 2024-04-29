--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE_QUALIFIER_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE_QUALIFIER_RULES" AS
/* $Header: QPXLQPRB.pls 120.1 2005/06/09 00:21:19 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Validate_Qualifier_Rules';


FUNCTION Check_Duplicate_Name(p_name  IN VARCHAR2,
						p_qualifier_rule_id IN NUMBER)RETURN BOOLEAN IS
CURSOR c_QualifierName(p_name Varchar2,
				   p_qualifier_rule_id NUMBER )  is
	  SELECT 'DUPLICATE'
	  FROM QP_QUALIFIER_RULES
	  WHERE upper(name) = upper(p_name)
	  AND   qualifier_rule_id <> p_qualifier_rule_id;

l_status  VARCHAR2(20);

BEGIN

       OPEN c_QualifierName(p_name,p_qualifier_rule_id);
	  FETCH c_QualifierName INTO l_status;
	  CLOSE c_QualifierName;

       If l_status = 'DUPLICATE' Then

	     RETURN TRUE;

       Else

	     RETURN FALSE;
       End If;


END Check_Duplicate_Name;

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   p_old_QUALIFIER_RULES_rec       IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIER_RULES_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

l_qualifier_rule_id           NUMBER;
BEGIN

    --  Check required attributes.


    --dbms_output.put_line('entity validation of qualifier rule id');

    IF  p_QUALIFIER_RULES_rec.qualifier_rule_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Qualifier Rule Id');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    --dbms_output.put_line('entity validation of qualifier rule id status '|| l_return_status);
    --dbms_output.put_line('entity validation of name ');

    IF  p_QUALIFIER_RULES_rec.name IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Name');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

 --dbms_output.put_line('entity validation of qualifier name  status '|| l_return_status);
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


    --  Other Validations

        If Check_Duplicate_Name(p_QUALIFIER_RULES_rec.name,
						  p_QUALIFIER_RULES_rec.qualifier_rule_id) Then

               l_return_status := FND_API.G_RET_STS_ERROR;

               IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                   FND_MESSAGE.SET_NAME('QP','QP_DUPLICATE_ATTRIBUTE');
                   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Name');
                   OE_MSG_PUB.Add;
               END IF;
        End If;

   --dbms_output.put_line('status of dup is ' ||l_return_status);


        IF l_return_status = FND_API.G_RET_STS_ERROR THEN

           RAISE FND_API.G_EXC_ERROR;

        END IF;



    --  Done validating entity

    x_return_status := l_return_status;

   --dbms_output.put_line('status of entity validation is ' ||x_return_status);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   p_old_QUALIFIER_RULES_rec       IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIER_RULES_REC
)
IS
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate QUALIFIER_RULES attributes

    --dbms_output.put_line('created_by ');

    IF  p_QUALIFIER_RULES_rec.created_by IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.created_by <>
            p_old_QUALIFIER_RULES_rec.created_by OR
            p_old_QUALIFIER_RULES_rec.created_by IS NULL )
    THEN
        IF NOT QP_Validate.Created_By(p_QUALIFIER_RULES_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;



    --dbms_output.put_line('status is '||x_return_status);


    --dbms_output.put_line('validating creation date');
    IF  p_QUALIFIER_RULES_rec.creation_date IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.creation_date <>
            p_old_QUALIFIER_RULES_rec.creation_date OR
            p_old_QUALIFIER_RULES_rec.creation_date IS NULL )
    THEN
        IF NOT QP_Validate.Creation_Date(p_QUALIFIER_RULES_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    --dbms_output.put_line('status is '||x_return_status);


    --dbms_output.put_line('validating description');

    IF  p_QUALIFIER_RULES_rec.description IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.description <>
            p_old_QUALIFIER_RULES_rec.description OR
            p_old_QUALIFIER_RULES_rec.description IS NULL )
    THEN
        IF NOT QP_Validate.Description(p_QUALIFIER_RULES_rec.description) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;



    --dbms_output.put_line('status is '||x_return_status);



    --dbms_output.put_line('validating last_update_by');

    IF  p_QUALIFIER_RULES_rec.last_updated_by IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.last_updated_by <>
            p_old_QUALIFIER_RULES_rec.last_updated_by OR
            p_old_QUALIFIER_RULES_rec.last_updated_by IS NULL )
    THEN
        IF NOT QP_Validate.Last_Updated_By(p_QUALIFIER_RULES_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;



    --dbms_output.put_line('status is '||x_return_status);




    --dbms_output.put_line('validating last_update_date');

    IF  p_QUALIFIER_RULES_rec.last_update_date IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.last_update_date <>
            p_old_QUALIFIER_RULES_rec.last_update_date OR
            p_old_QUALIFIER_RULES_rec.last_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Date(p_QUALIFIER_RULES_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    --dbms_output.put_line('status is '||x_return_status);


    --dbms_output.put_line('validating last_update_login');

    IF  p_QUALIFIER_RULES_rec.last_update_login IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.last_update_login <>
            p_old_QUALIFIER_RULES_rec.last_update_login OR
            p_old_QUALIFIER_RULES_rec.last_update_login IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Login(p_QUALIFIER_RULES_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    --dbms_output.put_line('status is '||x_return_status);


    --dbms_output.put_line('validating name');

    IF  p_QUALIFIER_RULES_rec.name IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.name <>
            p_old_QUALIFIER_RULES_rec.name OR
            p_old_QUALIFIER_RULES_rec.name IS NULL )
    THEN
        IF NOT QP_Validate.Name(p_QUALIFIER_RULES_rec.name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    --dbms_output.put_line('status is '||x_return_status);



    --dbms_output.put_line('validating program application id');

    IF  p_QUALIFIER_RULES_rec.program_application_id IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.program_application_id <>
            p_old_QUALIFIER_RULES_rec.program_application_id OR
            p_old_QUALIFIER_RULES_rec.program_application_id IS NULL )
    THEN
        IF NOT QP_Validate.Program_Application(p_QUALIFIER_RULES_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    --dbms_output.put_line('status is '||x_return_status);



    --dbms_output.put_line('validating program id');

    IF  p_QUALIFIER_RULES_rec.program_id IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.program_id <>
            p_old_QUALIFIER_RULES_rec.program_id OR
            p_old_QUALIFIER_RULES_rec.program_id IS NULL )
    THEN
        IF NOT QP_Validate.Program(p_QUALIFIER_RULES_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    --dbms_output.put_line('status is '||x_return_status);


    --dbms_output.put_line('validating program update date');

    IF  p_QUALIFIER_RULES_rec.program_update_date IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.program_update_date <>
            p_old_QUALIFIER_RULES_rec.program_update_date OR
            p_old_QUALIFIER_RULES_rec.program_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Program_Update_Date(p_QUALIFIER_RULES_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    --dbms_output.put_line('status is '||x_return_status);


    --dbms_output.put_line('validating qualifier rule  id');

    IF  p_QUALIFIER_RULES_rec.qualifier_rule_id IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.qualifier_rule_id <>
            p_old_QUALIFIER_RULES_rec.qualifier_rule_id OR
            p_old_QUALIFIER_RULES_rec.qualifier_rule_id IS NULL )
    THEN
        IF NOT QP_Validate.Qualifier_Rule(p_QUALIFIER_RULES_rec.qualifier_rule_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    --dbms_output.put_line('status is '||x_return_status);


    --dbms_output.put_line('validating request id');

    IF  p_QUALIFIER_RULES_rec.request_id IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.request_id <>
            p_old_QUALIFIER_RULES_rec.request_id OR
            p_old_QUALIFIER_RULES_rec.request_id IS NULL )
    THEN
        IF NOT QP_Validate.Request(p_QUALIFIER_RULES_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    --dbms_output.put_line('status is '||x_return_status);



    IF  (p_QUALIFIER_RULES_rec.attribute1 IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.attribute1 <>
            p_old_QUALIFIER_RULES_rec.attribute1 OR
            p_old_QUALIFIER_RULES_rec.attribute1 IS NULL ))
    OR  (p_QUALIFIER_RULES_rec.attribute10 IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.attribute10 <>
            p_old_QUALIFIER_RULES_rec.attribute10 OR
            p_old_QUALIFIER_RULES_rec.attribute10 IS NULL ))
    OR  (p_QUALIFIER_RULES_rec.attribute11 IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.attribute11 <>
            p_old_QUALIFIER_RULES_rec.attribute11 OR
            p_old_QUALIFIER_RULES_rec.attribute11 IS NULL ))
    OR  (p_QUALIFIER_RULES_rec.attribute12 IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.attribute12 <>
            p_old_QUALIFIER_RULES_rec.attribute12 OR
            p_old_QUALIFIER_RULES_rec.attribute12 IS NULL ))
    OR  (p_QUALIFIER_RULES_rec.attribute13 IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.attribute13 <>
            p_old_QUALIFIER_RULES_rec.attribute13 OR
            p_old_QUALIFIER_RULES_rec.attribute13 IS NULL ))
    OR  (p_QUALIFIER_RULES_rec.attribute14 IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.attribute14 <>
            p_old_QUALIFIER_RULES_rec.attribute14 OR
            p_old_QUALIFIER_RULES_rec.attribute14 IS NULL ))
    OR  (p_QUALIFIER_RULES_rec.attribute15 IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.attribute15 <>
            p_old_QUALIFIER_RULES_rec.attribute15 OR
            p_old_QUALIFIER_RULES_rec.attribute15 IS NULL ))
    OR  (p_QUALIFIER_RULES_rec.attribute2 IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.attribute2 <>
            p_old_QUALIFIER_RULES_rec.attribute2 OR
            p_old_QUALIFIER_RULES_rec.attribute2 IS NULL ))
    OR  (p_QUALIFIER_RULES_rec.attribute3 IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.attribute3 <>
            p_old_QUALIFIER_RULES_rec.attribute3 OR
            p_old_QUALIFIER_RULES_rec.attribute3 IS NULL ))
    OR  (p_QUALIFIER_RULES_rec.attribute4 IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.attribute4 <>
            p_old_QUALIFIER_RULES_rec.attribute4 OR
            p_old_QUALIFIER_RULES_rec.attribute4 IS NULL ))
    OR  (p_QUALIFIER_RULES_rec.attribute5 IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.attribute5 <>
            p_old_QUALIFIER_RULES_rec.attribute5 OR
            p_old_QUALIFIER_RULES_rec.attribute5 IS NULL ))
    OR  (p_QUALIFIER_RULES_rec.attribute6 IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.attribute6 <>
            p_old_QUALIFIER_RULES_rec.attribute6 OR
            p_old_QUALIFIER_RULES_rec.attribute6 IS NULL ))
    OR  (p_QUALIFIER_RULES_rec.attribute7 IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.attribute7 <>
            p_old_QUALIFIER_RULES_rec.attribute7 OR
            p_old_QUALIFIER_RULES_rec.attribute7 IS NULL ))
    OR  (p_QUALIFIER_RULES_rec.attribute8 IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.attribute8 <>
            p_old_QUALIFIER_RULES_rec.attribute8 OR
            p_old_QUALIFIER_RULES_rec.attribute8 IS NULL ))
    OR  (p_QUALIFIER_RULES_rec.attribute9 IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.attribute9 <>
            p_old_QUALIFIER_RULES_rec.attribute9 OR
            p_old_QUALIFIER_RULES_rec.attribute9 IS NULL ))
    OR  (p_QUALIFIER_RULES_rec.context IS NOT NULL AND
        (   p_QUALIFIER_RULES_rec.context <>
            p_old_QUALIFIER_RULES_rec.context OR
            p_old_QUALIFIER_RULES_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_QUALIFIER_RULES_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_QUALIFIER_RULES_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_QUALIFIER_RULES_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_QUALIFIER_RULES_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_QUALIFIER_RULES_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_QUALIFIER_RULES_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_QUALIFIER_RULES_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_QUALIFIER_RULES_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_QUALIFIER_RULES_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_QUALIFIER_RULES_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_QUALIFIER_RULES_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_QUALIFIER_RULES_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_QUALIFIER_RULES_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_QUALIFIER_RULES_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_QUALIFIER_RULES_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_QUALIFIER_RULES_rec.context
        );
*/

        --  Validate descriptive flexfield.

        --dbms_output.put_line('validating flex fields');



        IF NOT QP_Validate.Desc_Flex( 'QP_QUALIFIER_RULES' ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;


        --dbms_output.put_line('status is '||x_return_status);


    END IF;

    --  Done validating attributes

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;

END Attributes;

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
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

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity_Delete'
            );
        END IF;

END Entity_Delete;

END QP_Validate_Qualifier_Rules;

/
