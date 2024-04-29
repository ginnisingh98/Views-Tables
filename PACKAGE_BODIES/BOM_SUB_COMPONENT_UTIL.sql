--------------------------------------------------------
--  DDL for Package Body BOM_SUB_COMPONENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_SUB_COMPONENT_UTIL" AS
/* $Header: BOMUSBCB.pls 120.4.12010000.3 2010/02/13 01:41:55 umajumde ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMUSBCB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Sub_Component_Util
--
--  NOTES
--
--  HISTORY
--
-- 17-JUL-1999	Rahul Chitko	Initial Creation
-- 06-May-2005  Abhishek Rudresh Common BOM Attrs Update
****************************************************************************/

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'BOM_Sub_Component_Util';


--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_sub_component_rec             IN  Bom_Bo_Pub.Sub_Component_Rec_Type
) RETURN Bom_Bo_Pub.Sub_Component_Rec_Type
IS
l_sub_component_rec           Bom_Bo_Pub.Sub_Component_Rec_Type := p_sub_component_rec;
BEGIN

/*
    IF l_sub_component_rec.substitute_component_id = FND_API.G_MISS_NUM THEN
        l_sub_component_rec.substitute_component_id := NULL;
    END IF;

    IF l_sub_component_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_sub_component_rec.last_update_date := NULL;
    END IF;

    IF l_sub_component_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_sub_component_rec.last_updated_by := NULL;
    END IF;

    IF l_sub_component_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_sub_component_rec.creation_date := NULL;
    END IF;

    IF l_sub_component_rec.created_by = FND_API.G_MISS_NUM THEN
        l_sub_component_rec.created_by := NULL;
    END IF;

    IF l_sub_component_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_sub_component_rec.last_update_login := NULL;
    END IF;

    IF l_sub_component_rec.substitute_item_quantity = FND_API.G_MISS_NUM THEN
        l_sub_component_rec.substitute_item_quantity := NULL;
    END IF;

    IF l_sub_component_rec.component_sequence_id = FND_API.G_MISS_NUM THEN
        l_sub_component_rec.component_sequence_id := NULL;
    END IF;

    IF l_sub_component_rec.acd_type = FND_API.G_MISS_NUM THEN
        l_sub_component_rec.acd_type := NULL;
    END IF;

    IF l_sub_component_rec.change_notice = FND_API.G_MISS_CHAR THEN
        l_sub_component_rec.change_notice := NULL;
    END IF;

    IF l_sub_component_rec.request_id = FND_API.G_MISS_NUM THEN
        l_sub_component_rec.request_id := NULL;
    END IF;

    IF l_sub_component_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_sub_component_rec.program_application_id := NULL;
    END IF;

    IF l_sub_component_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_sub_component_rec.program_update_date := NULL;
    END IF;

    IF l_sub_component_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        l_sub_component_rec.attribute_category := NULL;
    END IF;

    IF l_sub_component_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_sub_component_rec.attribute1 := NULL;
    END IF;

    IF l_sub_component_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_sub_component_rec.attribute2 := NULL;
    END IF;

    IF l_sub_component_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_sub_component_rec.attribute4 := NULL;
    END IF;

    IF l_sub_component_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_sub_component_rec.attribute5 := NULL;
    END IF;

    IF l_sub_component_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_sub_component_rec.attribute6 := NULL;
    END IF;

    IF l_sub_component_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_sub_component_rec.attribute8 := NULL;
    END IF;

    IF l_sub_component_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_sub_component_rec.attribute9 := NULL;
    END IF;

    IF l_sub_component_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_sub_component_rec.attribute10 := NULL;
    END IF;

    IF l_sub_component_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_sub_component_rec.attribute12 := NULL;
    END IF;

    IF l_sub_component_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_sub_component_rec.attribute13 := NULL;
    END IF;

    IF l_sub_component_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_sub_component_rec.attribute14 := NULL;
    END IF;

    IF l_sub_component_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_sub_component_rec.attribute15 := NULL;
    END IF;

    IF l_sub_component_rec.program_id = FND_API.G_MISS_NUM THEN
        l_sub_component_rec.program_id := NULL;
    END IF;

    IF l_sub_component_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_sub_component_rec.attribute3 := NULL;
    END IF;

    IF l_sub_component_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_sub_component_rec.attribute7 := NULL;
    END IF;

    IF l_sub_component_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_sub_component_rec.attribute11 := NULL;
    END IF;

*/

    RETURN l_sub_component_rec;

END Convert_Miss_To_Null;

/********************************************************************
*
* Procedure	: Update_Row
* Parameter IN	: Substitute Component Record
*		  Sub. Comps Unexposed Cols. Record
* Parameter OUT	: Return_Status - indicating success or failure
*		  Mesg_Token_Tbl - Filled with Errors or warnings
* Purpose	: Update Row procedure will update the production rec
*		  to the new values as entered in the user record.
*		  Any errors are filled in the Mesg_Token_Tbl.
*
********************************************************************/

PROCEDURE Update_Row
(   p_sub_component_rec             IN  Bom_Bo_Pub.Sub_Component_Rec_Type
 ,  p_Sub_Comp_Unexp_Rec	    IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 ,  x_Mesg_Token_Tbl		    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 ,  x_return_status		    IN OUT NOCOPY VARCHAR2
)
IS
l_processed 		BOOLEAN;
l_sub_component_rec     Bom_Bo_Pub.SUB_COMPONENT_REC_TYPE :=
			p_sub_component_rec;
l_return_status         VARCHAR2(200);
l_err_text	 	VARCHAR2(255);
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
BEGIN

    -- Lock the row before updating the row
--dbms_output.put_line('Within Update Row . . .');
--dbms_output.put_line('Comp.SeqId : ' ||
-- to_Char(p_sub_comp_Unexp_rec.component_sequence_id)
--	);
--dbms_output.put_line('Sub. Comp  : ' ||
-- to_Char(p_sub_comp_Unexp_rec.substitute_component_id)
--	);
--dbms_output.put_line('Acd_Type   : ' || to_Char(p_sub_component_rec.acd_type));


    Error_Handler.Write_Debug ('Updating SCOMP Perform Writes ...');

    --bug:3254815 Update request id, prog id, prog appl id and prog update date.
    UPDATE  BOM_SUBSTITUTE_COMPONENTS
    SET    SUBSTITUTE_COMPONENT_ID =  DECODE(p_sub_comp_Unexp_rec.new_substitute_component_id,
               NULL, p_sub_comp_Unexp_rec.substitute_component_id,
               FND_API.G_MISS_NUM,
               p_sub_comp_Unexp_rec.substitute_component_id,
               p_sub_comp_Unexp_rec.new_substitute_component_id
               )
    ,       SUBSTITUTE_ITEM_QUANTITY	=
		p_sub_component_rec.substitute_item_quantity
    ,       ATTRIBUTE_CATEGORY	= p_sub_component_rec.attribute_category
    ,       ATTRIBUTE1		= p_sub_component_rec.attribute1
    ,       ATTRIBUTE2          = p_sub_component_rec.attribute2
    ,       ATTRIBUTE3          = p_sub_component_rec.attribute3
    ,       ATTRIBUTE4          = p_sub_component_rec.attribute4
    ,       ATTRIBUTE5          = p_sub_component_rec.attribute5
    ,       ATTRIBUTE6          = p_sub_component_rec.attribute6
    ,       ATTRIBUTE7          = p_sub_component_rec.attribute7
    ,       ATTRIBUTE8          = p_sub_component_rec.attribute8
    ,       ATTRIBUTE9          = p_sub_component_rec.attribute9
    ,       ATTRIBUTE10         = p_sub_component_rec.attribute10
    ,       ATTRIBUTE11         = p_sub_component_rec.attribute11
    ,       ATTRIBUTE12         = p_sub_component_rec.attribute12
    ,       ATTRIBUTE13         = p_sub_component_rec.attribute13
    ,       ATTRIBUTE14         = p_sub_component_rec.attribute14
    ,       ATTRIBUTE15         = p_sub_component_rec.attribute15
    ,       Original_system_Reference =
                                  p_sub_component_rec.original_system_reference
    ,       Enforce_Int_Requirements = p_sub_comp_unexp_rec.Enforce_Int_Requirements_Code
    ,       LAST_UPDATE_DATE    = SYSDATE
    ,       LAST_UPDATED_BY     = BOM_Globals.Get_User_Id
    ,       LAST_UPDATE_LOGIN   = BOM_Globals.Get_Login_Id
    ,       REQUEST_ID          = Fnd_Global.Conc_Request_Id
    ,       PROGRAM_ID          = Fnd_Global.Conc_Program_Id
    ,       PROGRAM_APPLICATION_ID = Fnd_Global.Prog_Appl_Id
    ,       PROGRAM_UPDATE_DATE = SYSDATE
    WHERE   SUBSTITUTE_COMPONENT_ID =
	    p_sub_comp_Unexp_rec.substitute_component_id
    AND     COMPONENT_SEQUENCE_ID = p_sub_comp_Unexp_rec.component_sequence_id
    AND     nvl(ACD_TYPE,1) = nvl(p_sub_component_rec.acd_type,1)
    /* Bug 5726557; The code is modified to modify the substitute components
    when implemneted through an ECO */
    ;
   -- end if;
--dbms_output.put_line('Update Row successful . . . ');

    BOMPCMBM.Update_Related_Sub_Comp(p_component_sequence_id => p_sub_comp_Unexp_rec.component_sequence_id
                                  , p_old_sub_comp_item_id => p_sub_comp_Unexp_rec.substitute_component_id
                                  , p_new_sub_comp_item_id => nvl(p_sub_comp_Unexp_rec.new_substitute_component_id,
                                                                   p_sub_comp_Unexp_rec.substitute_component_id)
                                  , p_acd_type => p_sub_component_rec.acd_type
                                  , x_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                                  , x_Return_Status   => x_return_status);
    --x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION

    WHEN NO_DATA_FOUND THEN
 	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
		Error_Handler.Add_Error_Token
		(  p_Message_name	=> 'BOM_NOT_UPDATE_ROW'
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		);
	END IF;

	x_return_status := FND_API.G_RET_STS_ERROR;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
		l_err_text := G_PKG_NAME ||
                              'Utility (SubStitute Component Update)' ||
                              SUBSTR(SQLERRM, 1, 100);
--dbms_output.put_line('Update Row Unexpected Error: ' || l_err_text);

		Error_Handler.Add_Error_Token
		(  p_Message_Name	=> NULL
		 , p_Message_Text	=> l_err_text
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
		 );
        END IF;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Row;

--following function has been added for bug 7713832
FUNCTION Common_CompSeqIdSC( p_comp_seq_id NUMBER)
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
* Parameters IN : Substitute Component Record as given by the User
*                 Sub. Comps Unexposed Cols. Record
* Parameters OUT: Substitute Component Record
*                 Return_Status - Indicating success or faliure
*                 Mesg_Token_Tbl - Filled with any errors or warnings
* Purpose       : Will Insert a new substitute component record in
*		  Bom_Substitute_Components table.
*
********************************************************************/
PROCEDURE Insert_Row
(   p_sub_component_rec             IN  Bom_Bo_Pub.Sub_Component_Rec_Type
 ,  p_Sub_Comp_Unexp_Rec	    IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 ,  x_Mesg_Token_Tbl		    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 ,  x_return_status		    IN OUT NOCOPY VARCHAR2
)
IS
l_processed 		BOOLEAN;
l_err_text		VARCHAR2(255);
l_return_status         VARCHAR2(200);
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
l_src_comp_seq_id NUMBER := NULL; --Bug 7713832

BEGIN

    Error_Handler.Write_Debug ('Inserting  SCOMP Perform Writes ...');
     --Bug 7712832 changes start
       IF Bom_Globals.Get_Caller_Type = 'MIGRATION' THEN
       l_src_comp_seq_id := Common_CompSeqIdSC( p_comp_seq_id => p_sub_comp_Unexp_rec.component_sequence_id
                                              );
        END IF;
     --Bug 7712832 changes end

    INSERT  INTO BOM_SUBSTITUTE_COMPONENTS
    (       SUBSTITUTE_COMPONENT_ID
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATED_BY
    ,       CREATION_DATE
    ,       CREATED_BY
    ,       LAST_UPDATE_LOGIN
    ,       SUBSTITUTE_ITEM_QUANTITY
    ,       COMPONENT_SEQUENCE_ID
    ,       ACD_TYPE
    ,       CHANGE_NOTICE
    ,       REQUEST_ID
    ,       PROGRAM_APPLICATION_ID
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
    ,	    ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       PROGRAM_ID
    ,       Original_System_Reference
    ,       Enforce_Int_Requirements
    ,       Common_Component_Sequence_Id  --bug 7713832
    )
    VALUES
    (       p_sub_comp_unexp_rec.substitute_component_id
    ,       SYSDATE
    ,       Bom_globals.Get_User_Id
    ,       SYSDATE
    ,       Bom_Globals.Get_User_Id
    ,       Bom_Globals.Get_User_Id
    ,       p_sub_component_rec.substitute_item_quantity
    ,       p_sub_comp_Unexp_rec.component_sequence_id
    ,       p_sub_component_rec.acd_type
    ,       p_sub_component_rec.Eco_Name
    ,	      Fnd_Global.Conc_Request_Id /* Request Id */
    ,       Bom_Globals.Get_Prog_AppId
    ,       SYSDATE
    ,       p_sub_component_rec.attribute_category
    ,       p_sub_component_rec.attribute1
    ,       p_sub_component_rec.attribute2
    ,       p_sub_component_rec.attribute3
    ,       p_sub_component_rec.attribute4
    ,       p_sub_component_rec.attribute5
    ,       p_sub_component_rec.attribute6
    ,       p_sub_component_rec.attribute7
    ,       p_sub_component_rec.attribute8
    ,       p_sub_component_rec.attribute9
    ,       p_sub_component_rec.attribute10
    ,       p_sub_component_rec.attribute11
    ,       p_sub_component_rec.attribute12
    ,       p_sub_component_rec.attribute13
    ,       p_sub_component_rec.attribute14
    ,       p_sub_component_rec.attribute15
    ,       Bom_Globals.Get_Prog_Id
    ,       p_sub_component_rec.Original_System_Reference
    ,       p_sub_comp_Unexp_rec.enforce_int_requirements_code
    ,       l_src_comp_seq_id --bug 7713832
    );
     IF Bom_Globals.Get_Caller_Type <> 'MIGRATION' THEN --Bug 7713832
    BOMPCMBM.Insert_Related_Sub_Comp(p_component_sequence_id => p_sub_comp_Unexp_rec.component_sequence_id
                                  , p_sub_comp_item_id => p_sub_comp_unexp_rec.substitute_component_id
                                  , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                  , x_Return_Status => x_return_status);
     END IF;
    --x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                l_err_text := G_PKG_NAME ||
                              'Utility (Substitute Component Insert)' ||
                              SUBSTR(SQLERRM, 1, 100);
		Error_Handler.Add_Error_Token
		(  p_Message_Name	=> NULL
		 , p_Message_text	=> l_err_text
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
	 	);
      END IF;
      x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Insert_Row;


/********************************************************************
*
* Procedure     : Delete_Row
* Parameters IN : Primary Key of Substitute Component Table
* Parameters OUT: Return_Status - Indicating success or faliure
*                 Mesg_Token_Tbl - Filled with any errors or warnings
* Purpose       : Will delete a substitute component record using the
*		  primary unique key.
********************************************************************/
PROCEDURE Delete_Row
(   p_substitute_component_id       IN  NUMBER
,   p_change_notice		    IN  VARCHAR2
,   p_component_sequence_id         IN  NUMBER
,   p_acd_type                      IN  NUMBER
,   x_Mesg_Token_Tbl		    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status		    IN OUT NOCOPY VARCHAR2
)
IS
l_processed 		BOOLEAN;
l_return_status         VARCHAR2(200);
l_err_text		VARCHAR2(255);
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
l_BO_Id			VARCHAR2(3) := Bom_Globals.Get_Bo_Identifier;
BEGIN

    IF Bom_Globals.Get_Bo_Identifier = Bom_Globals.G_ECO_BO
    THEN
    	Bom_GLOBALS.Check_Approved_For_Process(p_change_notice,
		 	       Bom_GLOBALS.Get_org_id,
			       l_processed,
			       l_err_text);

    	if (l_processed = TRUE) then
      		Bom_GLOBALS.Set_Request_For_approval(p_change_notice,
			       Bom_GLOBALS.Get_org_id,
			       l_err_text);
    	end if;
    END IF;

    DELETE  FROM BOM_SUBSTITUTE_COMPONENTS
    WHERE   SUBSTITUTE_COMPONENT_ID = p_substitute_component_id
    AND     COMPONENT_SEQUENCE_ID = p_component_sequence_id
    AND     (( l_BO_Id = Bom_Globals.G_ECO_BO AND
               ACD_TYPE = p_acd_type
              ) OR
              (l_BO_Id = Bom_Globals.G_BOM_BO AND
               acd_type IS NULL
               )
              );
    BOMPCMBM.Delete_Related_Sub_Comp(  p_src_comp_seq => p_component_sequence_id
                                     , p_sub_comp_item_id => p_substitute_component_id
                                     , x_return_status => x_return_status);
    --x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                l_err_text := G_PKG_NAME ||
                              'Utility (Substitute Component Delete_Row)' ||
                              SUBSTR(SQLERRM, 1, 100);

		Error_Handler.Add_Error_Token
		(  p_Message_Name	=> NULL
                 , p_Message_Text	=> l_err_text
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 );
        END IF;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Delete_Row;

/********************************************************************
*
* Procedure     : Query_Row
* Parameters IN : Substitute Component primary key
* Parameters OUT: Substitute Component Record of exposed colmuns
*		  Substitute Component record of unexposed columns
*                 Return_Status - Indicating success or faliure
*                 Mesg_Token_Tbl - Filled with any errors or warnings
* Purpose       : Complete Record will take the Database record and
*                 compare it with the user record and will complete
*                 the user record by filling in those values from the
*                 record that the user has left blank.
*                 Any user filled in columns will not be overwritten
*                 even if the values do not match.
********************************************************************/
PROCEDURE Query_Row
(   p_substitute_component_id       IN  NUMBER
,   p_component_sequence_id         IN  NUMBER
,   p_acd_type                      IN  NUMBER
,   x_Sub_Component_Rec		    IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Rec_Type
,   x_Sub_Comp_Unexp_Rec	    IN OUT NOCOPY Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
,   x_return_status		    IN OUT NOCOPY VARCHAR2
)
IS
l_sub_component_rec           Bom_Bo_Pub.Sub_Component_Rec_Type;
l_Token_Tbl		      Error_Handler.Token_Tbl_Type;
l_Mesg_Token_Tbl	      Error_Handler.Mesg_Token_Tbl_Type;
BEGIN

    SELECT  SUBSTITUTE_ITEM_QUANTITY
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
    ,       CHANGE_NOTICE
    ,       ACD_TYPE
    ,       SUBSTITUTE_COMPONENT_ID
    ,       COMPONENT_SEQUENCE_ID
    ,       ENFORCE_INT_REQUIREMENTS
    INTO    l_sub_component_rec.substitute_item_quantity
    ,       l_sub_component_rec.attribute_category
    ,       l_sub_component_rec.attribute1
    ,       l_sub_component_rec.attribute2
    ,       l_sub_component_rec.attribute3
    ,       l_sub_component_rec.attribute4
    ,       l_sub_component_rec.attribute5
    ,       l_sub_component_rec.attribute6
    ,       l_sub_component_rec.attribute7
    ,       l_sub_component_rec.attribute8
    ,       l_sub_component_rec.attribute9
    ,       l_sub_component_rec.attribute10
    ,       l_sub_component_rec.attribute11
    ,       l_sub_component_rec.attribute12
    ,       l_sub_component_rec.attribute13
    ,       l_sub_component_rec.attribute14
    ,       l_sub_component_rec.attribute15
    ,       l_Sub_Component_Rec.Eco_Name
    ,       l_Sub_Component_Rec.Acd_Type
    ,       x_Sub_comp_Unexp_Rec.Substitute_Component_Id
    ,	    x_Sub_Comp_Unexp_Rec.Component_Sequence_Id
    ,	    x_Sub_Comp_Unexp_Rec.enforce_int_requirements_code
    FROM    BOM_SUBSTITUTE_COMPONENTS
    WHERE   SUBSTITUTE_COMPONENT_ID = p_substitute_component_id
    AND     COMPONENT_SEQUENCE_ID = p_component_sequence_id
    AND     NVL(DECODE(ACD_TYPE, FND_API.G_MISS_NUM, null, acd_type), 1) =
            NVL(DECODE(p_acd_type, FND_API.G_MISS_NUM, null, p_acd_type), 1)
	    /* Bug 5726557; The code is modified inorder to update an
	    Substitute component when implemneted through an ECO */
    ;

	IF x_sub_comp_unexp_rec.enforce_int_requirements_code IS NOT NULL AND
		x_sub_comp_unexp_rec.enforce_int_requirements_code <> FND_API.G_MISS_NUM THEN
               SELECT meaning INTO l_sub_component_rec.enforce_int_requirements FROM mfg_lookups
                        WHERE lookup_type = 'BOM_ENFORCE_INT_REQUIREMENTS' AND
                        lookup_code = x_sub_comp_unexp_rec.enforce_int_requirements_code;
	END IF;

    x_Sub_Component_Rec := l_sub_component_rec;
    x_return_status := Bom_Globals.G_RECORD_FOUND;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_Sub_Component_Rec := l_sub_component_rec;
	x_return_status := Bom_Globals.G_RECORD_NOT_FOUND;

    WHEN OTHERS THEN
        x_return_status := Bom_Globals.G_RECORD_NOT_FOUND;

END Query_Row;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 IN OUT NOCOPY VARCHAR2
,   p_sub_component_rec             IN  Bom_Bo_Pub.Sub_Component_Rec_Type
,   x_sub_component_rec             IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Rec_Type
,  x_err_text			    IN OUT NOCOPY VARCHAR2
)
IS
l_sub_component_rec           Bom_Bo_Pub.Sub_Component_Rec_Type;
l_err_text			VARCHAR2(255);
BEGIN
	NULL;
END Lock_Row;

PROCEDURE Perform_Writes
(  p_sub_component_rec		IN  Bom_Bo_Pub.Sub_Component_Rec_Type
 , p_sub_comp_unexp_rec		IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status		IN OUT NOCOPY VARCHAR2
)
IS
	l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
	l_return_status		VARCHAR2(1);
	l_sub_component_rec	Bom_Bo_Pub.Sub_Component_Rec_Type;
	l_sub_comp_unexp_rec	Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type;
BEGIN
	l_sub_component_rec := p_sub_component_rec;
	l_sub_comp_unexp_rec := p_sub_comp_unexp_rec;

	IF l_sub_component_rec.transaction_type IS NULL THEN
	  Error_Handler.Write_Debug ('In SCOMP Perform Writes ...is NULL');
	ELSIF l_sub_component_rec.transaction_type = FND_API.G_MISS_CHAR THEN
	  Error_Handler.Write_Debug ('In SCOMP Perform Writes ...is MISSING');
	ELSE
	  Error_Handler.Write_Debug('In SCOMP Perform Writes...'||l_sub_component_rec.transaction_type);
	END IF;
	IF l_sub_component_rec.transaction_type = Bom_Globals.G_OPR_CREATE
	THEN
		Insert_Row(  p_sub_component_rec  => l_sub_component_rec
			   , p_Sub_Comp_Unexp_Rec => l_sub_comp_unexp_rec
			   ,  x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
			   ,  x_return_status     => l_return_status
			   );
	ELSIF l_sub_component_rec.transaction_type = Bom_Globals.G_OPR_UPDATE
	THEN
                Update_Row(  p_sub_component_rec  => l_sub_component_rec
                           , p_Sub_Comp_Unexp_Rec => l_sub_comp_unexp_rec
                           ,  x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
                           ,  x_return_status     => l_return_status
                           );

	ELSIF l_sub_component_rec.transaction_type = Bom_Globals.G_OPR_DELETE
	THEN
		Delete_Row
		(  p_substitute_component_id	=>
				l_sub_comp_unexp_rec.substitute_component_id
		 , p_change_notice		=>
				l_sub_component_rec.eco_name
		 , p_component_sequence_id	=>
				l_sub_comp_unexp_rec.component_sequence_id
		 , p_acd_type			=>
				l_sub_component_rec.acd_type
		 , x_Mesg_Token_Tbl		=> l_Mesg_Token_Tbl
		 , x_return_status		=> l_return_status
		 );

	END IF;
	Error_Handler.Write_Debug ('After SCOMP Perform Writes ...'||nvl(l_sub_component_rec.transaction_type,'NULL'));

	x_return_status := l_return_status;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Perform_Writes;

/*
** Procedures for BOM Business Object
*/
FUNCTION Convert_Miss_To_Null
(   p_bom_sub_component_rec         IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
) RETURN Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
IS
	l_sub_component_rec	Bom_Bo_Pub.Sub_Component_Rec_Type;
	l_sub_comp_unexp_rec	Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type;
	l_bom_sub_component_rec	Bom_Bo_Pub.Bom_Sub_Component_Rec_Type;
	l_bom_sub_comp_unexp_rec Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type;
BEGIN
	--
	-- Convert the BOM record
	--
	Bom_Bo_Pub.Convert_BomSComp_To_EcoSComp
	(  p_bom_sub_component_rec	=> p_bom_sub_component_rec
	 , x_sub_component_rec		=> l_sub_component_rec
	 , x_sub_comp_unexp_rec		=> l_sub_comp_unexp_rec
	 );

	l_sub_component_rec :=
	Convert_Miss_To_Null
	(  p_sub_component_rec	=> l_sub_component_rec );

	--
	-- Convert the ECO record back
	--
	Bom_Bo_Pub.Convert_EcoSComp_To_BomSComp
	(  p_sub_component_rec		=> l_sub_component_rec
	 , x_bom_sub_component_rec	=> l_bom_sub_component_rec
	 , x_bom_sub_comp_unexp_rec	=> l_bom_sub_comp_unexp_rec
	 );

END Convert_Miss_To_Null;

--  Function Query_Row

PROCEDURE Query_Row
(   p_substitute_component_id  IN  NUMBER
,   p_component_sequence_id    IN  NUMBER
,   p_acd_type                 IN  NUMBER
,   x_bom_Sub_Component_Rec    IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
,   x_bom_Sub_Comp_Unexp_Rec   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
,   x_return_status            IN OUT NOCOPY VARCHAR2
)
IS
	l_sub_component_rec	Bom_Bo_Pub.Sub_Component_Rec_Type;
	l_sub_comp_unexp_rec	Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type;
BEGIN

	--
	-- Call Query Row
	--
	Query_Row
	(  p_substitute_component_id	=> p_substitute_component_id
	 , p_component_sequence_id	=> p_component_sequence_id
	 , p_acd_type			=> p_acd_type
	 , x_sub_component_rec		=> l_sub_component_rec
	 , x_sub_comp_unexp_rec		=> l_sub_comp_unexp_rec
	 , x_return_status		=> x_return_status
	);

	--
	-- Convert the ECO record before retuning
	--
	Bom_Bo_Pub.Convert_EcoSComp_To_BomSComp
	(  p_sub_component_rec		=> l_sub_component_rec
	 , p_sub_comp_unexp_rec		=> l_sub_comp_unexp_rec
	 , x_bom_sub_component_rec	=> x_bom_sub_component_rec
	 , x_bom_sub_comp_unexp_rec	=> x_bom_sub_comp_unexp_rec
	 );

END Query_Row;

PROCEDURE Perform_Writes
(  p_bom_sub_component_rec      IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
 , p_bom_sub_comp_unexp_rec     IN  Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
)
IS
	l_sub_component_rec	Bom_Bo_Pub.Sub_Component_Rec_Type;
	l_sub_comp_unexp_rec	Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type;
BEGIN
	--
	-- Convert the BOM Record to ECO Record
	--
	Bom_Bo_Pub.Convert_BomSComp_To_EcoSComp
	(  p_bom_sub_component_rec	=> p_bom_sub_component_rec
	 , p_bom_sub_comp_unexp_rec	=> p_bom_sub_comp_unexp_rec
	 , x_sub_component_rec		=> l_sub_component_rec
	 , x_sub_comp_unexp_rec		=> l_sub_comp_unexp_rec
	);

	-- Call Perform Writes

	Perform_Writes
	(  p_sub_component_rec	=> l_sub_component_rec
	 , p_sub_comp_unexp_rec	=> l_sub_comp_unexp_rec
	 , x_return_status	=> x_return_status
	 , x_mesg_token_tbl	=> x_mesg_token_tbl
	);

END Perform_Writes;


END BOM_Sub_Component_Util;

/
