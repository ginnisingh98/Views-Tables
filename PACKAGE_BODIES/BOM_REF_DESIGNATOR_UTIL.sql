--------------------------------------------------------
--  DDL for Package Body BOM_REF_DESIGNATOR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_REF_DESIGNATOR_UTIL" AS
 /* $Header: BOMURFDB.pls 120.4.12010000.4 2015/07/10 12:22:52 nlingamp ship $ */
/****************************************************************************
--
--  Copyright (c) 1996, 2015 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMURFDB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Ref_Designator_Util
--
--  NOTES
--
--  HISTORY
--
--  19-JUL-1999	Rahul Chitko	Initial Creation
--
--  06-May-05   Abhishek Rudresh   Common BOM Attrs update
****************************************************************************/
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'BOM_Ref_Designator_Util';
G_CONTROL_REC                 BOM_BO_PUB.Control_Rec_Type;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
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
 ,  x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 ,  x_Return_Status		IN OUT NOCOPY VARCHAR2
)
IS
l_return_status		varchar2(80);
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
l_ref_designator_rec	Bom_Bo_Pub.Ref_Designator_Rec_Type;
l_Token_Tbl		Error_Handler.Token_Tbl_Type;
l_BO_Id			VARCHAR2(3) := Bom_Globals.Get_Bo_Identifier;
BEGIN
    --bug:3254815 Update request id, prog id, prog appl id and prog update date.
    UPDATE  BOM_REFERENCE_DESIGNATORS
    SET   COMPONENT_REFERENCE_DESIGNATOR =
			 DECODE(p_ref_designator_rec.new_reference_designator,
               		 NULL,p_ref_designator_rec.Reference_Designator_Name,
              		 FND_API.G_MISS_CHAR,
             		 p_ref_designator_rec.Reference_Designator_Name,
              		 p_ref_designator_rec.new_reference_designator
               		)
    ,       LAST_UPDATE_DATE	= SYSDATE
    ,       LAST_UPDATED_BY	= Bom_Globals.Get_User_Id
    ,       LAST_UPDATE_LOGIN   = Bom_Globals.Get_User_Id
    ,       REF_DESIGNATOR_COMMENT =
	    DECODE( p_ref_designator_rec.ref_designator_comment
                  , FND_API.G_MISS_CHAR
                  , NULL
                  , p_ref_designator_rec.ref_designator_comment
                  )
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
    ,       REQUEST_ID          = Fnd_Global.Conc_Request_Id
    ,       PROGRAM_ID          = Fnd_Global.Conc_Program_Id
    ,       PROGRAM_APPLICATION_ID = Fnd_Global.Prog_Appl_Id
    ,       PROGRAM_UPDATE_DATE = SYSDATE
    WHERE   COMPONENT_REFERENCE_DESIGNATOR =
	    p_ref_designator_rec.Reference_Designator_Name
    AND     COMPONENT_SEQUENCE_ID =
	    p_Ref_Desg_Unexp_Rec.component_sequence_id
    AND     ( ( l_BO_Id = Bom_Globals.G_ECO_BO AND
                ACD_TYPE = p_Ref_Designator_Rec.acd_type
               ) OR
               ( l_BO_Id = Bom_Globals.G_BOM_BO AND
                 (acd_type IS NULL or acd_type = 1)
	  /* Bug 5726557; The code is modified to modify the refernce designators
	    when implemneted through an ECO */
                )
             );

  BOMPCMBM.Update_Related_Ref_Desg(p_component_sequence_id => p_Ref_Desg_Unexp_Rec.component_sequence_id
                                  , p_old_ref_desg => p_ref_designator_rec.Reference_Designator_Name
                                  , p_new_ref_desg => nvl(p_ref_designator_rec.new_reference_designator,
                                                          p_ref_designator_rec.Reference_Designator_Name)
                                  , p_acd_type => p_Ref_Designator_Rec.acd_type
                                  , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
                                  , x_Return_Status => x_Return_Status);
	--x_Return_Status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN

        IF G_CONTROL_REC.caller_type = 'FORM'
        THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE;
        END IF;

	Error_Handler.Add_Error_Token
	(  p_Message_Name	=> NULL
         , p_Message_Text	=> 'ERROR in Update Row (Ref Desgs)' ||
         		      	   substr(SQLERRM, 1, 100) || ' '    ||
				   to_char(SQLCODE)
	 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl	=> x_Mesg_Token_Tbl);

	x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Row;

--following function has been added for bug 7713832
FUNCTION Common_CompSeqIdRD( p_comp_seq_id NUMBER)
RETURN NUMBER
IS
  l_src_comp_seq_id          NUMBER;

BEGIN

  SELECT common_component_sequence_id
        INTO l_src_comp_seq_id
        FROM bom_components_b
        WHERE component_sequence_id = p_comp_seq_id
        and component_sequence_id <> common_component_sequence_id;

       RETURN l_src_comp_seq_id;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
         RETURN NULL;

       WHEN OTHERS THEN
         RETURN NULL;
 END;


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
 ,  x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 ,  x_Return_Status		IN OUT NOCOPY VARCHAR2
)
IS
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
l_src_comp_seq_id NUMBER := NULL; --bug 7713832
BEGIN

    --Bug 7712832 changes start
       IF Bom_Globals.Get_Caller_Type = 'MIGRATION' THEN
       l_src_comp_seq_id := Common_CompSeqIdRD( p_comp_seq_id => p_Ref_Desg_Unexp_Rec.component_sequence_id
                                              );
        END IF;
     --Bug 7712832 changes end
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
    ,       Common_Component_Sequence_Id --added for bug 7713832
    )
    VALUES
    (       p_ref_designator_rec.Reference_Designator_Name
    ,       SYSDATE
    ,       Bom_Globals.Get_User_Id
    ,       SYSDATE
    ,       Bom_Globals.Get_User_Id
    ,       Bom_Globals.Get_User_Id
    ,       DECODE( p_ref_designator_rec.ref_designator_comment
                  , FND_API.G_MISS_CHAR
                  , NULL
                  , p_ref_designator_rec.ref_designator_comment )
    ,       p_ref_designator_rec.Eco_Name
    ,       p_Ref_Desg_Unexp_Rec.component_sequence_id
    ,       p_ref_designator_rec.acd_type
    ,       Fnd_Global.Conc_Request_Id /* Request Id */
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
    ,       l_src_comp_seq_id  --bug 7713832
    );
     IF Bom_Globals.Get_Caller_Type <> 'MIGRATION' THEN --Bug 7713832
    /* Added p_acd_type for bug 20345308 to resolve the issue where in, unique constraint error thrown
    when we try to save both 'disable' and 'add' actions of a reference designator at once in an ECO */
    BOMPCMBM.Insert_Related_Ref_Desg(p_component_sequence_id => p_Ref_Desg_Unexp_Rec.component_sequence_id
                                  , p_ref_desg => p_ref_designator_rec.Reference_Designator_Name
				  , p_acd_type => p_ref_designator_rec.acd_type
                                  , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
                                  , x_Return_Status => x_return_status);
    END IF;
	--x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION

    WHEN OTHERS THEN
        IF G_CONTROL_REC.caller_type = 'FORM'
        THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE;
        END IF;

	Error_Handler.Add_Error_Token
	(  p_Message_Name	=> NULL
         , p_Message_Text	=> 'ERROR in Insert Row (Ref Desgs)' ||
                              	   substr(SQLERRM, 1, 100) || ' ' ||
			      	   to_char(SQLCODE)
	 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl	=> x_Mesg_Token_Tbl
	 );

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('ERROR in Insert Row (Ref Desgs)' || substr(SQLERRM, 1, 100) || ' ' || to_char(SQLCODE)); END IF;

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
,   x_Mesg_Token_Tbl		   IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_Return_Status		   IN OUT NOCOPY VARCHAR2
)
IS
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
l_BO_Id			VARCHAR2(3) := Bom_Globals.Get_Bo_Identifier;

BEGIN

    DELETE  FROM BOM_REFERENCE_DESIGNATORS
    WHERE   COMPONENT_REFERENCE_DESIGNATOR = p_ref_designator
    AND     COMPONENT_SEQUENCE_ID = p_component_sequence_id
    AND     ( ( l_BO_Id = Bom_Globals.G_ECO_BO AND
                ACD_TYPE = p_acd_type
               ) OR
               ( l_BO_Id = Bom_Globals.G_BOM_BO AND
                 acd_type IS NULL
                )
             );
    BOMPCMBM.Delete_Related_Ref_Desg(p_src_comp_seq => p_component_sequence_id
                                     , p_ref_desg => p_ref_designator
                                     , x_return_status => x_return_status);

    --x_Return_Status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN

        IF G_CONTROL_REC.caller_type = 'FORM'
        THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE;
        END IF;

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
,   x_Ref_Designator_Rec	IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
,   x_Ref_Desg_Unexp_Rec	IN OUT NOCOPY Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
,   x_Return_Status		IN OUT NOCOPY VARCHAR2
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
    AND     NVL(DECODE(ACD_TYPE, FND_API.G_MISS_NUM, null, acd_type), 1) =
            NVL(DECODE(p_acd_type, FND_API.G_MISS_NUM, null, p_acd_type), 1)
    /* Bug 5726557; The code is modified to modify the refernce designators
	    when implemneted through an ECO */
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
 , p_control_rec                IN  BOM_BO_PUB.Control_Rec_Type
                                := BOM_BO_PUB.G_DEFAULT_CONTROL_REC
 , x_mesg_token_tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status		IN OUT NOCOPY VARCHAR2
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

/*
** Procedure definitions for BOM Business Object
*/
FUNCTION Convert_Miss_To_Null
(   p_bom_ref_designator_rec       IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
) RETURN Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
IS
	l_ref_designator_rec	Bom_Bo_Pub.Ref_Designator_Rec_Type;
	l_ref_desg_unexp_rec	Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type;
	l_bom_ref_designator_rec Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type;
	l_bom_ref_desg_unexp_rec Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type;
BEGIN
	--
	-- Convert the BOM Record to ECO
	--
	Bom_Bo_Pub.Convert_BomDesg_To_EcoDesg
	(  p_bom_ref_designator_rec	=> p_bom_ref_designator_rec
	 , x_ref_designator_rec		=> l_ref_designator_rec
	 , x_ref_desg_unexp_rec		=> l_ref_desg_unexp_rec
	);

	-- Call Conver Missing to Null

	l_ref_designator_rec :=
	Convert_Miss_To_Null
	( p_ref_designator_rec	=> l_ref_designator_rec);

	--
	-- Convert ECO record back to BOM
	--
	Bom_Bo_Pub.Convert_EcoDesg_To_BomDesg
	(  p_ref_designator_rec		=> l_ref_designator_rec
	 , x_bom_ref_designator_rec	=> l_bom_ref_designator_rec
	 , x_bom_ref_desg_unexp_rec	=> l_bom_ref_desg_unexp_rec
	);

	RETURN l_bom_ref_designator_rec;

END Convert_Miss_To_Null;

--  Function Query_Row

PROCEDURE Query_Row
(   p_bom_ref_designator        IN  VARCHAR2
,   p_component_sequence_id     IN  NUMBER
,   p_acd_type                  IN  NUMBER
,   x_bom_Ref_Designator_Rec    IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
,   x_bom_Ref_Desg_Unexp_Rec    IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
,   x_Return_Status             IN OUT NOCOPY VARCHAR2
)
IS
	l_ref_designator_rec	Bom_Bo_Pub.Ref_Designator_Rec_Type;
	l_ref_desg_unexp_rec	Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type;
BEGIN

	Bom_Ref_Designator_Util.Query_Row
	(  p_ref_designator		=> p_bom_ref_designator
	 , p_component_sequence_id	=> p_component_sequence_id
	 , p_acd_type			=> p_acd_type
	 , x_ref_designator_rec		=> l_ref_designator_rec
	 , x_ref_desg_unexp_rec		=> l_ref_desg_unexp_rec
	 , x_return_status		=> x_return_status
	);

	-- Convert the ECO record to BOm for return

	Bom_Bo_Pub.Convert_Ecodesg_To_BomDesg
	(  p_ref_designator_rec		=> l_ref_designator_rec
	 , p_ref_desg_unexp_rec		=> l_ref_Desg_unexp_rec
	 , x_bom_ref_designator_rec	=> x_bom_ref_designator_rec
	 , x_bom_ref_desg_unexp_rec	=> x_bom_ref_desg_unexp_Rec
	);

END Query_Row;

PROCEDURE Perform_Writes
(  p_bom_ref_designator_rec      IN Bom_Bo_Pub.Bom_Ref_Designator_rec_Type
 , p_bom_ref_desg_unexp_rec      IN Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
 , x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status              IN OUT NOCOPY VARCHAR2
)
IS
        l_ref_designator_rec    Bom_Bo_Pub.Ref_Designator_Rec_Type;
        l_ref_desg_unexp_rec    Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type;
BEGIN
	--
	-- Convert Bom Recor to ECO
	--
	Bom_Bo_Pub.Convert_BomDesg_To_EcoDesg
	(  p_bom_ref_designator_rec	=> p_bom_ref_designator_rec
	 , p_bom_ref_desg_unexp_rec	=> p_bom_ref_desg_unexp_rec
	 , x_ref_designator_rec		=> l_ref_designator_rec
	 , x_ref_desg_unexp_rec		=> l_ref_desg_unexp_rec
	);

	-- Call Perform Writes
	Bom_Ref_Designator_Util.Perform_Writes
	(  p_ref_designator_rec		=> l_ref_designator_rec
	 , p_ref_desg_unexp_rec		=> l_ref_desg_unexp_rec
	 , x_return_status		=> x_return_status
	 , x_mesg_token_tbl		=> x_mesg_token_tbl
	);

END Perform_Writes;


END BOM_Ref_Designator_Util;

/
