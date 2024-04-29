--------------------------------------------------------
--  DDL for Package Body ENG_REF_DESIGNATOR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_REF_DESIGNATOR_UTIL" AS
/* $Header: ENGURFDB.pls 115.12 2002/12/14 00:44:17 bbontemp ship $ */

-- /* $Header: ENGURFDB.pls 115.12 2002/12/14 00:44:17 bbontemp ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ENG_Ref_Designator_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER :=NULL-- FND_API.G_MISS_NUM
,   p_ref_designator_rec            IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_old_ref_designator_rec        IN  Bom_Bo_Pub.Ref_Designator_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_REF_DESIGNATOR_REC
,   x_ref_designator_rec            IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
)
IS
BEGIN
    --  Load out record

    x_ref_designator_rec := p_ref_designator_rec;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_ref_designator_rec            IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_old_ref_designator_rec        IN  Bom_Bo_Pub.Ref_Designator_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_REF_DESIGNATOR_REC
,   x_ref_designator_rec            IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
)
IS
BEGIN
    --  Load out record

    x_ref_designator_rec := p_ref_designator_rec;

END Apply_Attribute_Changes;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_ref_designator_rec            IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
) RETURN Bom_Bo_Pub.Ref_Designator_Rec_Type
IS
l_ref_designator_rec          Bom_Bo_Pub.Ref_Designator_Rec_Type :=
			      p_ref_designator_rec;
BEGIN

    IF l_ref_designator_rec.Reference_Designator_Name = FND_API.G_MISS_CHAR THEN
        l_ref_designator_rec.Reference_Designator_Name := NULL;
    END IF;

    IF l_ref_designator_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        l_ref_designator_rec.attribute_category := NULL;
    END IF;

    IF l_ref_designator_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_ref_designator_rec.attribute1 := NULL;
    END IF;

    IF l_ref_designator_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_ref_designator_rec.attribute2 := NULL;
    END IF;

    IF l_ref_designator_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_ref_designator_rec.attribute3 := NULL;
    END IF;

    IF l_ref_designator_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_ref_designator_rec.attribute4 := NULL;
    END IF;

    IF l_ref_designator_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_ref_designator_rec.attribute5 := NULL;
    END IF;

    IF l_ref_designator_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_ref_designator_rec.attribute6 := NULL;
    END IF;

    IF l_ref_designator_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_ref_designator_rec.attribute7 := NULL;
    END IF;

    IF l_ref_designator_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_ref_designator_rec.attribute8 := NULL;
    END IF;

    IF l_ref_designator_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_ref_designator_rec.attribute9 := NULL;
    END IF;

    IF l_ref_designator_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_ref_designator_rec.attribute10 := NULL;
    END IF;

    IF l_ref_designator_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_ref_designator_rec.attribute11 := NULL;
    END IF;

    IF l_ref_designator_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_ref_designator_rec.attribute12 := NULL;
    END IF;

    IF l_ref_designator_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_ref_designator_rec.attribute13 := NULL;
    END IF;

    IF l_ref_designator_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_ref_designator_rec.attribute14 := NULL;
    END IF;

    IF l_ref_designator_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_ref_designator_rec.attribute15 := NULL;
    END IF;

    RETURN l_ref_designator_rec;

END Convert_Miss_To_Null;

/********************************************************************
*
* Procedure     : Update_Row
* Parameters IN : Reference Designator Record as given by the User
*                 Reference Designator Unexposed Record
* Parameters OUT: Return_Status - Indicating success or faliure
*                 Mesg_Token_Tbl - Filled with any errors or warnings
* Purpose       : Will update the Reference Designator record and
*		  if unable to update then return with a status
*		  and Error Message table filled with the message
*
********************************************************************/

PROCEDURE Update_Row
(   p_ref_designator_rec        IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
 ,  p_Ref_Desg_Unexp_Rec	IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
 ,  x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 ,  x_Return_Status		OUT NOCOPY VARCHAR2
)
IS
l_return_status		varchar2(80);
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
l_ref_designator_rec	Bom_Bo_Pub.Ref_Designator_Rec_Type;
l_Token_Tbl		Error_Handler.Token_Tbl_Type;
BEGIN

    UPDATE  BOM_REFERENCE_DESIGNATORS
    SET     LAST_UPDATE_DATE	= SYSDATE
    ,       LAST_UPDATED_BY	= Bom_Globals.Get_User_Id
    ,       LAST_UPDATE_LOGIN   = Bom_Globals.Get_User_Id
    ,       REF_DESIGNATOR_COMMENT =
	    p_ref_designator_rec.ref_designator_comment
    ,       ATTRIBUTE_CATEGORY	= p_ref_designator_rec.attribute_category
    ,       ATTRIBUTE1		= p_ref_designator_rec.attribute1
    ,       ATTRIBUTE2          = p_ref_designator_rec.attribute2
    ,       ATTRIBUTE3          = p_ref_designator_rec.attribute3
    ,       ATTRIBUTE4          = p_ref_designator_rec.attribute4
    ,       ATTRIBUTE5          = p_ref_designator_rec.attribute5
    ,       ATTRIBUTE6          = p_ref_designator_rec.attribute6
    ,       ATTRIBUTE7          = p_ref_designator_rec.attribute7
    ,       ATTRIBUTE8          = p_ref_designator_rec.attribute8
    ,       ATTRIBUTE9          = p_ref_designator_rec.attribute9
    ,       ATTRIBUTE10         = p_ref_designator_rec.attribute10
    ,       ATTRIBUTE11         = p_ref_designator_rec.attribute11
    ,       ATTRIBUTE12         = p_ref_designator_rec.attribute12
    ,       ATTRIBUTE13         = p_ref_designator_rec.attribute13
    ,       ATTRIBUTE14         = p_ref_designator_rec.attribute14
    ,       ATTRIBUTE15         = p_ref_designator_rec.attribute15
    ,       Original_System_Reference =
                                p_ref_designator_rec.Original_System_Reference
    WHERE   COMPONENT_REFERENCE_DESIGNATOR =
	    p_ref_designator_rec.Reference_Designator_Name
    AND     COMPONENT_SEQUENCE_ID =
	    p_Ref_Desg_Unexp_Rec.component_sequence_id
    AND     ACD_TYPE = p_Ref_Designator_Rec.acd_type
    ;

	x_Return_Status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
	Error_Handler.Add_Error_Token
	(  p_Message_Name	=> NULL
         , p_Message_Text	=> 'ERROR in Update Row (Ref Desgs)' ||
         		      	   substr(SQLERRM, 1, 100) || ' '    ||
				   to_char(SQLCODE)
	 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl	=> x_Mesg_Token_Tbl);

	x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Row;

/********************************************************************
*
* Procedure     : Insert_Row
* Parameters IN : Reference Designator Record as given by the User
*                 Reference Designator Unexposed Record
* Parameters OUT: Return_Status - Indicating success or faliure
*                 Mesg_Token_Tbl - Filled with any errors or warnings
* Purpose       : Insert Reference Designator record and if unable to
*		  to insert then return with an error_status and
*		  Error message filled in the Message Token Table.
*
********************************************************************/

PROCEDURE Insert_Row
(   p_ref_designator_rec        IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
 ,  p_Ref_Desg_Unexp_Rec	IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
 ,  x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 ,  x_Return_Status		OUT NOCOPY VARCHAR2
)
IS
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
BEGIN

    INSERT  INTO BOM_REFERENCE_DESIGNATORS
    (       COMPONENT_REFERENCE_DESIGNATOR
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATED_BY
    ,       CREATION_DATE
    ,       CREATED_BY
    ,       LAST_UPDATE_LOGIN
    ,       REF_DESIGNATOR_COMMENT
    ,       CHANGE_NOTICE
    ,       COMPONENT_SEQUENCE_ID
    ,       ACD_TYPE
    ,       REQUEST_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       ATTRIBUTE_CATEGORY
    ,       ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       Original_System_Reference
    )
    VALUES
    (       p_ref_designator_rec.Reference_Designator_Name
    ,       SYSDATE
    ,       Bom_Globals.Get_User_Id
    ,       SYSDATE
    ,       Bom_Globals.Get_User_Id
    ,       Bom_Globals.Get_User_Id
    ,       p_ref_designator_rec.ref_designator_comment
    ,       p_ref_designator_rec.Eco_Name
    ,       p_Ref_Desg_Unexp_Rec.component_sequence_id
    ,       p_ref_designator_rec.acd_type
    ,       NULL /* Request Id */
    ,       Bom_Globals.Get_Prog_AppId
    ,       Bom_Globals.Get_Prog_Id
    ,       SYSDATE
    ,       p_ref_designator_rec.attribute_category
    ,       p_ref_designator_rec.attribute1
    ,       p_ref_designator_rec.attribute2
    ,       p_ref_designator_rec.attribute3
    ,       p_ref_designator_rec.attribute4
    ,       p_ref_designator_rec.attribute5
    ,       p_ref_designator_rec.attribute6
    ,       p_ref_designator_rec.attribute7
    ,       p_ref_designator_rec.attribute8
    ,       p_ref_designator_rec.attribute9
    ,       p_ref_designator_rec.attribute10
    ,       p_ref_designator_rec.attribute11
    ,       p_ref_designator_rec.attribute12
    ,       p_ref_designator_rec.attribute13
    ,       p_ref_designator_rec.attribute14
    ,       p_ref_designator_rec.attribute15
    ,       p_ref_designator_rec.Original_System_Reference
    );

	x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION

    WHEN OTHERS THEN
       Error_Handler.Add_Error_Token
	(  p_Message_Name	=> NULL
         , p_Message_Text	=> 'ERROR in Insert Row (Ref Desgs)' ||
                              	   substr(SQLERRM, 1, 100) || ' ' ||
			      	   to_char(SQLCODE)
	 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl	=> x_Mesg_Token_Tbl
	 );

--dbms_output.put_line('ERROR in Insert Row (Ref Desgs)' ||
--                                   substr(SQLERRM, 1, 100) || ' ' ||
--                                   to_char(SQLCODE)
--		     );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Insert_Row;

/********************************************************************
*
* Procedure     : Delete_Row
* Parameters IN : Reference Designator Key
* Parameters OUT: Return_Status - Indicating success or faliure
*                 Mesg_Token_Tbl - Filled with any errors or warnings
* Purpose       : Insert Reference Designator record and if unable to
*                 to insert then return with an error_status and
*                 Error message filled in the Message Token Table.
*
********************************************************************/

PROCEDURE Delete_Row
(   p_ref_designator               IN  VARCHAR2
,   p_component_sequence_id        IN  NUMBER
,   p_acd_type                     IN  NUMBER
,   x_Mesg_Token_Tbl		   OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_Return_Status		   OUT NOCOPY VARCHAR2
)
IS
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;

BEGIN

    DELETE  FROM BOM_REFERENCE_DESIGNATORS
    WHERE   COMPONENT_REFERENCE_DESIGNATOR = p_ref_designator
    AND     COMPONENT_SEQUENCE_ID = p_component_sequence_id
    AND     ACD_TYPE = p_acd_type
    ;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
       Error_Handler.Add_Error_Token
	(  p_Message_Name	=> NULL
         , p_Message_Text	=> 'ERROR in Delete Row (Ref Desgs)' ||
                              	  substr(SQLERRM, 1, 100) || ' '    ||
			      	  to_char(SQLCODE)
	 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl	=> x_Mesg_Token_Tbl
	 );
         x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END Delete_Row;

/********************************************************************
*
* Procedure     : Query_Row
* Parameters IN : Reference Designator Key
* Parameters OUT: Reference Designator Record of exposed columns
*		  Reference Designator Record of Unexposed Columns
*		  Return_Status - Indicating success or faliure
*                 Mesg_Token_Tbl - Filled with any errors or warnings
* Purpose       : Query Row procedure will query a database record
*		  seperate the values into the exposed and the un-
*		  exposed record and return the values.
*		  If the query fails then the Error Token table will
*		  be filled in with the error message and returned with
*		  and error status otherwise a success
********************************************************************/

PROCEDURE Query_Row
(   p_ref_designator		IN  VARCHAR2
,   p_component_sequence_id	IN  NUMBER
,   p_acd_type			IN  NUMBER
,   x_Ref_Designator_Rec	OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
,   x_Ref_Desg_Unexp_Rec	OUT NOCOPY Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
,   x_Return_Status		OUT NOCOPY VARCHAR2
)
IS
l_ref_designator_rec	Bom_Bo_Pub.Ref_Designator_Rec_Type;
l_Ref_Desg_Unexp_Rec	Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type;
l_err_text		      VARCHAR2(2000);
BEGIN

    SELECT  COMPONENT_REFERENCE_DESIGNATOR
    ,       REF_DESIGNATOR_COMMENT
    ,       CHANGE_NOTICE
    ,       COMPONENT_SEQUENCE_ID
    ,       ACD_TYPE
    ,       ATTRIBUTE_CATEGORY
    ,       ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    INTO    l_ref_designator_rec.Reference_Designator_Name
    ,       l_ref_designator_rec.ref_designator_comment
    ,       l_ref_designator_rec.Eco_Name
    ,       l_Ref_Desg_Unexp_Rec.component_sequence_id
    ,       l_ref_designator_rec.acd_type
    ,       l_ref_designator_rec.attribute_category
    ,       l_ref_designator_rec.attribute1
    ,       l_ref_designator_rec.attribute2
    ,       l_ref_designator_rec.attribute3
    ,       l_ref_designator_rec.attribute4
    ,       l_ref_designator_rec.attribute5
    ,       l_ref_designator_rec.attribute6
    ,       l_ref_designator_rec.attribute7
    ,       l_ref_designator_rec.attribute8
    ,       l_ref_designator_rec.attribute9
    ,       l_ref_designator_rec.attribute10
    ,       l_ref_designator_rec.attribute11
    ,       l_ref_designator_rec.attribute12
    ,       l_ref_designator_rec.attribute13
    ,       l_ref_designator_rec.attribute14
    ,       l_ref_designator_rec.attribute15
    FROM    BOM_REFERENCE_DESIGNATORS
    WHERE   COMPONENT_REFERENCE_DESIGNATOR = p_ref_designator
    AND     COMPONENT_SEQUENCE_ID = p_component_sequence_id
    AND     ACD_TYPE = p_acd_type
    ;

    x_Ref_Designator_Rec := l_ref_designator_rec;
    x_Ref_Desg_Unexp_Rec := l_Ref_Desg_Unexp_Rec;
    x_Return_Status := Bom_Globals.G_RECORD_FOUND;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_Return_Status := Bom_Globals.G_RECORD_NOT_FOUND;

    WHEN OTHERS THEN
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END Query_Row;

PROCEDURE Perform_Writes
(  p_ref_designator_rec		IN  Bom_Bo_Pub.Ref_Designator_rec_Type
 , p_ref_desg_unexp_rec		IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
 , x_mesg_token_tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status		OUT NOCOPY VARCHAR2
)
IS
	l_mesg_token_tbl	Error_Handler.Mesg_Token_Tbl_Type;
	l_return_status		VARCHAR2(1);
BEGIN
	l_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_ref_designator_rec.transaction_type = Bom_Globals.G_OPR_CREATE
	THEN
		Insert_Row(  p_ref_designator_rec	=>
					p_ref_designator_rec
			   , p_ref_desg_unexp_rec	=>
					p_ref_desg_unexp_rec
			   , x_mesg_token_tbl		=> l_mesg_token_tbl
			   , x_return_status		=> l_return_status
			   );
	ELSIF p_ref_designator_rec.transaction_type = Bom_Globals.G_OPR_UPDATE
	THEN
		Update_Row(  p_ref_designator_rec	=>
					p_ref_designator_rec
			   , p_ref_desg_unexp_rec	=>
					p_ref_desg_unexp_rec
			   , x_mesg_token_tbl		=>
					l_mesg_token_tbl
			   , x_return_status		=>
					l_return_status
			    );
	ELSIF p_ref_designator_rec.transaction_type = Bom_Globals.G_OPR_DELETE
	THEN
		Delete_Row
		(   p_ref_designator		=>
			p_ref_designator_rec.reference_designator_name
		,   p_component_sequence_id	=>
			p_ref_desg_unexp_rec.component_sequence_id
		,   p_acd_type			=>
			p_ref_designator_rec.acd_type
		,   x_Mesg_Token_Tbl		=> l_mesg_token_tbl
		,   x_Return_Status		=> l_return_status
		);
	END IF;

	x_return_status := l_return_status;
	x_mesg_token_tbl := l_mesg_token_tbl;

END Perform_Writes;

END ENG_Ref_Designator_Util;

/
