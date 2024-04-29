--------------------------------------------------------
--  DDL for Package Body BOM_COMP_OPERATION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_COMP_OPERATION_UTIL" AS
/* $Header: BOMUCOPB.pls 120.2.12010000.3 2010/02/13 01:37:02 umajumde ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMUCOPB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Comp_Operation_Util
--
--  NOTES
--
--  HISTORY
--
-- 21-AUG-2001	Refai Farook	Initial Creation
****************************************************************************/

--  Global constant holding the package name

G_PKG_NAME       CONSTANT VARCHAR2(30) := 'BOM_Comp_Operation_Util';

/********************************************************************
*
* Procedure	: Update_Row
* Parameter IN	: Component Operation Record
*		  Component Operation Unexposed Cols. Record
* Parameter OUT	: Return_Status - indicating success or failure
*		  Mesg_Token_Tbl - Filled with Errors or warnings
* Purpose	: Update Row procedure will update the production rec
*		  to the new values as entered in the user record.
*		  Any errors are filled in the Mesg_Token_Tbl.
*
********************************************************************/

PROCEDURE Update_Row
(   p_bom_comp_ops_rec             IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
 ,  p_bom_comp_ops_unexp_Rec	   IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
 ,  x_Mesg_Token_Tbl		   IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 ,  x_return_status		   IN OUT NOCOPY VARCHAR2
)
IS
  l_bom_comp_ops_rec    Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type :=
			                     p_bom_comp_ops_rec;
  l_return_status       VARCHAR2(200);
  l_err_text	 	VARCHAR2(255);
  l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
  l_comp_seq_id NUMBER;
BEGIN

    l_return_status := FND_API.G_RET_STS_SUCCESS;

    --bug:3254815 Update request id, prog id, prog appl id and prog update date.
    UPDATE  BOM_COMPONENT_OPERATIONS
    SET    OPERATION_SEQ_NUM
 		=  decode( p_bom_comp_ops_rec.new_additional_op_seq_num,
                          NULL,
                          p_bom_comp_ops_rec.additional_operation_seq_num,
			  FND_API.G_MISS_NUM,
			  p_bom_comp_ops_rec.additional_operation_seq_num,
			  p_bom_comp_ops_rec.new_additional_op_seq_num
                         )
    ,       OPERATION_SEQUENCE_ID
    		=   decode(p_bom_comp_ops_unexp_rec.new_additional_op_seq_id,
                          NULL,
                          p_bom_comp_ops_unexp_rec.additional_operation_seq_id,
                          FND_API.G_MISS_NUM,
                          p_bom_comp_ops_unexp_rec.additional_operation_seq_id,
                          p_bom_comp_ops_unexp_rec.new_additional_op_seq_id
                         )
    ,       ATTRIBUTE_CATEGORY	= p_bom_comp_ops_rec.attribute_category
    ,       ATTRIBUTE1		= p_bom_comp_ops_rec.attribute1
    ,       ATTRIBUTE2          = p_bom_comp_ops_rec.attribute2
    ,       ATTRIBUTE3          = p_bom_comp_ops_rec.attribute3
    ,       ATTRIBUTE4          = p_bom_comp_ops_rec.attribute4
    ,       ATTRIBUTE5          = p_bom_comp_ops_rec.attribute5
    ,       ATTRIBUTE6          = p_bom_comp_ops_rec.attribute6
    ,       ATTRIBUTE7          = p_bom_comp_ops_rec.attribute7
    ,       ATTRIBUTE8          = p_bom_comp_ops_rec.attribute8
    ,       ATTRIBUTE9          = p_bom_comp_ops_rec.attribute9
    ,       ATTRIBUTE10         = p_bom_comp_ops_rec.attribute10
    ,       ATTRIBUTE11         = p_bom_comp_ops_rec.attribute11
    ,       ATTRIBUTE12         = p_bom_comp_ops_rec.attribute12
    ,       ATTRIBUTE13         = p_bom_comp_ops_rec.attribute13
    ,       ATTRIBUTE14         = p_bom_comp_ops_rec.attribute14
    ,       ATTRIBUTE15         = p_bom_comp_ops_rec.attribute15
    ,       LAST_UPDATE_DATE    = SYSDATE
    ,       LAST_UPDATED_BY     = BOM_Globals.Get_User_Id
    ,       LAST_UPDATE_LOGIN   = BOM_Globals.Get_Login_Id
    ,       REQUEST_ID          = Fnd_Global.Conc_Request_Id
    ,       PROGRAM_ID          = Fnd_Global.Conc_Program_Id
    ,       PROGRAM_APPLICATION_ID = Fnd_Global.Prog_Appl_Id
    ,       PROGRAM_UPDATE_DATE = SYSDATE
    WHERE   COMP_OPERATION_SEQ_ID = p_bom_comp_ops_unexp_rec.comp_operation_seq_id ;

    SELECT component_sequence_id
    INTO l_comp_seq_id
    FROM BOM_COMPONENT_OPERATIONS
    WHERE COMP_OPERATION_SEQ_ID = p_bom_comp_ops_unexp_rec.comp_operation_seq_id ;

   IF SQL%NOTFOUND THEN

     Error_Handler.Add_Error_Token
     ( p_Message_name	=> 'BOM_NOT_UPDATE_ROW'
       , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
       , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
     );

     l_return_status := FND_API.G_RET_STS_ERROR;
   ELSE
     BOMPCMBM.Update_Related_Comp_Ops(p_component_sequence_id => l_comp_seq_id
                                  , p_old_operation_seq_num => p_bom_comp_ops_rec.additional_operation_seq_num
                                  , p_new_operation_seq_num => nvl(p_bom_comp_ops_rec.new_additional_op_seq_num,
                                                                   p_bom_comp_ops_rec.additional_operation_seq_num)
                                  , x_Mesg_Token_Tbl        => l_Mesg_Token_Tbl
                                  , x_Return_Status         => l_return_status);

   END IF;

    x_return_status  := l_return_status;
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

EXCEPTION

    WHEN OTHERS THEN
        /* The following IF is to find out if the current level of the error
	   is greater than or equal to the message level threshold defined in the
           profile 'FND_AS_MSG_LEVEL_THRESHOLD' */

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
		l_err_text := G_PKG_NAME ||
                              'Utility (Component Operations Update)' ||
                              SUBSTR(SQLERRM, 1, 100);

		Error_Handler.Add_Error_Token
		(  p_Message_Name	=> NULL
		 , p_Message_Text	=> l_err_text
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
		 );
        END IF;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Row;


--following function has been added for bug 7713832
FUNCTION Common_CompSeqIdCO( p_comp_seq_id NUMBER)
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
* Parameters IN : Component Ops.Record as given by the User
*                 Component Ops Unexposed Cols. Record
* Parameters OUT: Component Operations Record
*                 Return_Status - Indicating success or faliure
*                 Mesg_Token_Tbl - Filled with any errors or warnings
* Purpose       : Will Insert a new component operatins record in
*		  Bom_Component_Operations table.
*
********************************************************************/
PROCEDURE Insert_Row
(   p_bom_comp_ops_rec             IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
 ,  p_bom_Comp_Ops_Unexp_Rec	   IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
 ,  x_Mesg_Token_Tbl		   IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 ,  x_return_status		   IN OUT NOCOPY VARCHAR2
)
IS
l_err_text		VARCHAR2(255);
l_return_status         VARCHAR2(200);
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
l_src_comp_seq_id NUMBER := NULL; --bug 7713832
BEGIN
    --Bug 7712832 changes start
       IF Bom_Globals.Get_Caller_Type = 'MIGRATION' THEN
       l_src_comp_seq_id := Common_CompSeqIdCO( p_comp_seq_id => p_bom_comp_ops_unexp_rec.component_sequence_id
                                              );
        END IF;
     --Bug 7712832 changes end

    INSERT  INTO BOM_COMPONENT_OPERATIONS
    (       COMP_OPERATION_SEQ_ID
    ,       OPERATION_SEQ_NUM
    ,       OPERATION_SEQUENCE_ID
    ,       BILL_SEQUENCE_ID
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATED_BY
    ,       CREATION_DATE
    ,       CREATED_BY
    ,       LAST_UPDATE_LOGIN
    ,       COMPONENT_SEQUENCE_ID
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
    ,       REQUEST_ID
    ,       PROGRAM_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_UPDATE_DATE
    ,       Common_Component_Sequence_Id --added for bug 7713832
    )
    VALUES
    (       BOM_COMPONENT_OPERATIONS_S.NEXTVAL
    ,       p_bom_comp_ops_rec.additional_operation_seq_num
    ,       p_bom_comp_ops_unexp_rec.additional_operation_seq_id
    ,       p_bom_comp_ops_unexp_rec.bill_sequence_id
    ,       SYSDATE
    ,       Bom_globals.Get_User_Id
    ,       SYSDATE
    ,       Bom_Globals.Get_User_Id
    ,       Bom_Globals.Get_User_Id
    ,       p_bom_comp_ops_unexp_rec.component_sequence_id
    ,       p_bom_comp_ops_rec.attribute_category
    ,       p_bom_comp_ops_rec.attribute1
    ,       p_bom_comp_ops_rec.attribute2
    ,       p_bom_comp_ops_rec.attribute3
    ,       p_bom_comp_ops_rec.attribute4
    ,       p_bom_comp_ops_rec.attribute5
    ,       p_bom_comp_ops_rec.attribute6
    ,       p_bom_comp_ops_rec.attribute7
    ,       p_bom_comp_ops_rec.attribute8
    ,       p_bom_comp_ops_rec.attribute9
    ,       p_bom_comp_ops_rec.attribute10
    ,       p_bom_comp_ops_rec.attribute11
    ,       p_bom_comp_ops_rec.attribute12
    ,       p_bom_comp_ops_rec.attribute13
    ,       p_bom_comp_ops_rec.attribute14
    ,       p_bom_comp_ops_rec.attribute15
    ,       Fnd_Global.Conc_Request_Id
    ,       Fnd_Global.Conc_Program_Id
    ,       Fnd_Global.Prog_Appl_Id
    ,       SYSDATE
    ,       l_src_comp_seq_id  --bug 7713832
    );

    --x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF Bom_Globals.Get_Caller_Type <> 'MIGRATION' THEN --Bug 7713832
    BOMPCMBM.Insert_Related_Comp_Ops(p_component_sequence_id => p_bom_comp_ops_unexp_rec.component_sequence_id
                                  , p_operation_seq_num => p_bom_comp_ops_rec.additional_operation_seq_num
                                  , x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
                                  , x_Return_Status     => l_return_status);
   END IF;
   x_return_status := l_return_status;

EXCEPTION

    WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                l_err_text := G_PKG_NAME ||
                              'Utility (Component Operations Insert)' ||
                              SUBSTR(SQLERRM, 1, 100);
		Error_Handler.Add_Error_Token
		(  p_Message_Name	=> NULL
		 , p_Message_text	=> l_err_text
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
	 	);
      END IF;
      x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
      x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;

END Insert_Row;


/********************************************************************
*
* Procedure     : Delete_Row
* Parameters IN : Primary Key of Component Operation Table
* Parameters OUT: Return_Status - Indicating success or faliure
*                 Mesg_Token_Tbl - Filled with any errors or warnings
* Purpose       : Will delete a component operation record using the
*		  primary unique key.
********************************************************************/
PROCEDURE Delete_Row
(   p_comp_operation_seq_id       IN  NUMBER
,   x_Mesg_Token_Tbl		  IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status		  IN OUT NOCOPY VARCHAR2
)
IS
l_return_status         VARCHAR2(200);
l_err_text		VARCHAR2(255);
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
l_comp_seq_id NUMBER;
l_op_seq_num NUMBER;
BEGIN

    l_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT component_sequence_id, operation_seq_num
    INTO l_comp_seq_id, l_op_seq_num
    FROM BOM_COMPONENT_OPERATIONS
    WHERE COMP_OPERATION_SEQ_ID = p_comp_operation_seq_id;

    DELETE  FROM BOM_COMPONENT_OPERATIONS
    WHERE   COMP_OPERATION_SEQ_ID = p_comp_operation_seq_id;

    IF SQL%NOTFOUND THEN

      Error_Handler.Add_Error_Token
      ( p_Message_name	=> 'BOM_NOT_DELETE_ROW'
        , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
        , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
      );

      l_return_status := FND_API.G_RET_STS_ERROR;

    ELSE
      BOMPCMBM.Delete_Related_Comp_Ops(p_src_comp_seq_id => l_comp_seq_id,
                                   p_operation_seq_num => l_op_seq_num,
                                   x_return_status => l_return_status);

    END IF;

    x_return_status := l_return_status;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                l_err_text := G_PKG_NAME ||
                              'Utility (Component Operations Delete_Row)' ||
                              SUBSTR(SQLERRM, 1, 100);

		Error_Handler.Add_Error_Token
		(  p_Message_Name	=> NULL
                 , p_Message_Text	=> l_err_text
		 , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		 );
        END IF;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;

END Delete_Row;

/********************************************************************
*
* Procedure     : Query_Row
* Parameters IN : Component Operation primary key
* Parameters OUT: Component Operation Record of exposed colmuns
*		  Component Operation record of unexposed columns
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
(   p_component_sequence_id       IN  NUMBER
,   p_additional_operation_seq_num IN NUMBER
,   x_bom_comp_ops_rec		  IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
,   x_bom_comp_ops_Unexp_Rec	  IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
,   x_return_status		  IN OUT NOCOPY VARCHAR2
)
IS
l_bom_comp_ops_rec           Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type;
l_bom_comp_ops_unexp_rec     Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type;
BEGIN

    SELECT  ROWID
    ,       COMP_OPERATION_SEQ_ID
    ,       OPERATION_SEQ_NUM
    ,       OPERATION_SEQUENCE_ID
    ,       COMPONENT_SEQUENCE_ID
    ,       BILL_SEQUENCE_ID
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
    INTO
            l_bom_comp_ops_unexp_rec.rowid
    ,       l_bom_comp_ops_unexp_rec.comp_operation_seq_id
    ,       l_bom_comp_ops_rec.operation_sequence_number
    ,       l_bom_comp_ops_unexp_rec.additional_operation_seq_id
    ,       l_bom_comp_ops_unexp_rec.component_sequence_id
    ,       l_bom_comp_ops_unexp_rec.bill_sequence_id
    ,       l_bom_comp_ops_rec.attribute_category
    ,       l_bom_comp_ops_rec.attribute1
    ,       l_bom_comp_ops_rec.attribute2
    ,       l_bom_comp_ops_rec.attribute3
    ,       l_bom_comp_ops_rec.attribute4
    ,       l_bom_comp_ops_rec.attribute5
    ,       l_bom_comp_ops_rec.attribute6
    ,       l_bom_comp_ops_rec.attribute7
    ,       l_bom_comp_ops_rec.attribute8
    ,       l_bom_comp_ops_rec.attribute9
    ,       l_bom_comp_ops_rec.attribute10
    ,       l_bom_comp_ops_rec.attribute11
    ,       l_bom_comp_ops_rec.attribute12
    ,       l_bom_comp_ops_rec.attribute13
    ,       l_bom_comp_ops_rec.attribute14
    ,       l_bom_comp_ops_rec.attribute15
    FROM    BOM_COMPONENT_OPERATIONS
    WHERE   COMPONENT_SEQUENCE_ID = p_component_sequence_id AND
            OPERATION_SEQ_NUM     = p_additional_operation_seq_num ;

    x_bom_comp_ops_Rec       := l_bom_comp_ops_rec;
    x_bom_comp_ops_unexp_Rec := l_bom_comp_ops_unexp_rec;
    x_return_status          := Bom_Globals.G_RECORD_FOUND;

EXCEPTION

    WHEN OTHERS THEN
        x_bom_comp_ops_Rec       := l_bom_comp_ops_rec;
        x_bom_comp_ops_unexp_Rec := l_bom_comp_ops_unexp_rec;
        x_return_status          := Bom_Globals.G_RECORD_NOT_FOUND;

END Query_Row;

PROCEDURE Perform_Writes
(  p_bom_comp_ops_rec		IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
 , p_bom_comp_ops_unexp_rec	IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
 , x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status		IN OUT NOCOPY VARCHAR2
)
IS
	l_Mesg_Token_Tbl	 Error_Handler.Mesg_Token_Tbl_Type;
	l_return_status		 VARCHAR2(1);
	l_bom_comp_ops_rec	 Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type;
	l_bom_comp_ops_unexp_rec Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type;
BEGIN
	l_bom_comp_ops_rec       := p_bom_comp_ops_rec;
	l_bom_comp_ops_unexp_rec := p_bom_comp_ops_unexp_rec;

	IF l_bom_comp_ops_rec.transaction_type = Bom_Globals.G_OPR_CREATE
	THEN
		Insert_Row(  p_bom_comp_ops_rec       => l_bom_comp_ops_rec
			   , p_bom_comp_ops_Unexp_Rec => l_bom_comp_ops_unexp_rec
			   ,  x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
			   ,  x_return_status     => l_return_status
			   );
	ELSIF l_bom_comp_ops_rec.transaction_type = Bom_Globals.G_OPR_UPDATE
	THEN
                Update_Row(  p_bom_comp_ops_rec  => l_bom_comp_ops_rec
                           , p_bom_comp_ops_Unexp_Rec => l_bom_comp_ops_unexp_rec
                           ,  x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
                           ,  x_return_status     => l_return_status
                           );

	ELSIF l_bom_comp_ops_rec.transaction_type = Bom_Globals.G_OPR_DELETE
	THEN
		Delete_Row
		(  p_comp_operation_seq_id	=> l_bom_comp_ops_unexp_rec.comp_operation_seq_id
		 , x_Mesg_Token_Tbl		=> l_Mesg_Token_Tbl
		 , x_return_status		=> l_return_status
		 );

	END IF;

	x_return_status := l_return_status;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Perform_Writes;


END BOM_Comp_Operation_Util;

/
