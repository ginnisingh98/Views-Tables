--------------------------------------------------------
--  DDL for Package Body ENG_ECO_REVISION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_ECO_REVISION_UTIL" AS
/* $Header: ENGUREVB.pls 115.26 2004/06/03 06:17:10 lkasturi ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ENG_Eco_Revision_Util';
G_CONTROL_REC		      BOM_BO_PUB.Control_Rec_Type;
--bug 3047312
 FUNCTION ret_app_status
 (
   p_change_id                  IN NUMBER
   ,x_change_order_type_id   OUT NOCOPY VARCHAR2
   ,x_route_id               OUT NOCOPY  NUMBER
   ,x_priority_code	     OUT NOCOPY VARCHAR2 -- Bug 3665542
 )
 RETURN NUMBER
 IS
    l_id                          NUMBER;
 BEGIN

     SELECT  approval_status_type, change_order_type_id ,route_id, priority_code
     INTO    l_id, x_change_order_type_id ,x_route_id ,x_priority_code
     FROM    eng_engineering_changes
     WHERE   change_id = p_change_id ;

     RETURN l_id;

 EXCEPTION

     WHEN NO_DATA_FOUND THEN
         RETURN NULL;

     WHEN OTHERS THEN
             RETURN  FND_API.G_MISS_NUM;

 END ret_app_status;



 FUNCTION ret_pro_name
 (
   p_change_order_type_id               IN NUMBER
  ,p_priority_code			IN VARCHAR2 -- Bug 3665542
   )
   RETURN NUMBER
   IS
   l_id NUMBER :=1;
   l_process_name  eng_change_type_processes.process_name%TYPE;
   BEGIN
         SELECT process_name into l_process_name
           FROM eng_change_type_processes
          WHERE change_order_type_id = p_change_order_type_id --;
	  -- Bug 3665542: Added additional where clause to fetch process name
            AND ((p_priority_code is NOT NULL
		  AND eng_change_priority_code = p_priority_code
		  AND organization_id = -1)
                OR
	        (p_priority_code is NULL
		  AND eng_change_priority_code is NULL));
    if l_process_name  is  null then
       l_id :=0;
     else
       l_id :=1;
    end if;
  return l_id;
 -- Bug 3665542: Added exception handling
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
   l_id :=0;
   RETURN l_id;
 WHEN OTHERS THEN
   RETURN  FND_API.G_MISS_NUM;
 END ret_pro_name ;
     -- End Changes 3047312

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := NULL --FND_API.G_MISS_NUM
,   p_eco_revision_rec              IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
,   p_old_eco_revision_rec          IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
,   x_eco_revision_rec              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_eco_revision_rec := p_eco_revision_rec;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_eco_revision_rec              IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
,   p_old_eco_revision_rec          IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
,   x_eco_revision_rec              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Rec_Type
)
IS
BEGIN
    --  Load out record

    x_eco_revision_rec := p_eco_revision_rec;

END Apply_Attribute_Changes;


--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_eco_revision_rec              IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
) RETURN ENG_Eco_PUB.Eco_Revision_Rec_Type
IS
l_eco_revision_rec            ENG_Eco_PUB.Eco_Revision_Rec_Type :=
			      p_eco_revision_rec;
BEGIN

    RETURN l_eco_revision_rec;

END Convert_Miss_To_Null;

/****************************************************************************
*Procedure	: Update_Row
*Parameters IN	: Eco Revision exposed columns record
*		  Eco Revision unexposed columns record
*Parameters OUT	: Mesg Token Table
*		  Return_Status
*Purpose	: Update Row procedure will update any changed columns of the
*		  record. If it fails then an unexpected error will be returned
*		  with message text in Mesg_Token_Tbl and return_status of U.
****************************************************************************/
PROCEDURE Update_Row
(   p_eco_revision_rec		IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
 ,  p_Eco_Rev_Unexp_Rec		IN  Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
 ,  x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 ,  x_Return_Status		OUT NOCOPY VARCHAR2
)
IS
l_Return_Status	VARCHAR2(1);
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
l_err_text	VARCHAR2(2000);
l_user_id               NUMBER;
l_login_id              NUMBER;
l_prog_appid            NUMBER;
l_prog_id               NUMBER;
l_request_id            NUMBER;

BEGIN


    l_user_id           := Eng_Globals.Get_User_Id;
    l_login_id          := Eng_Globals.Get_Login_Id;
    l_request_id        := ENG_GLOBALS.Get_request_id;
    l_prog_appid        := ENG_GLOBALS.Get_prog_appid;
    l_prog_id           := ENG_GLOBALS.Get_prog_id;

    UPDATE  ENG_CHANGE_ORDER_REVISIONS
    SET     REVISION                 = DECODE
				       ( p_eco_revision_rec.new_revision, NULL,
					 p_eco_revision_rec.revision,
					 FND_API.G_MISS_CHAR,
					 p_eco_revision_rec.revision,
				         p_eco_revision_rec.new_revision )
    ,       LAST_UPDATE_DATE         = SYSDATE
    ,       LAST_UPDATED_BY          = l_user_id
    ,       LAST_UPDATE_LOGIN        = l_login_id
    ,       COMMENTS                 = DECODE(  p_eco_revision_rec.comments
					      , FND_API.G_MISS_CHAR
					      , null
					      , p_eco_revision_rec.comments
					      )
    ,       ATTRIBUTE_CATEGORY       = p_eco_revision_rec.attribute_category
    ,       ATTRIBUTE1               = p_eco_revision_rec.attribute1
    ,       ATTRIBUTE2               = p_eco_revision_rec.attribute2
    ,       ATTRIBUTE3               = p_eco_revision_rec.attribute3
    ,       ATTRIBUTE4               = p_eco_revision_rec.attribute4
    ,       ATTRIBUTE5               = p_eco_revision_rec.attribute5
    ,       ATTRIBUTE6               = p_eco_revision_rec.attribute6
    ,       ATTRIBUTE7               = p_eco_revision_rec.attribute7
    ,       ATTRIBUTE8               = p_eco_revision_rec.attribute8
    ,       ATTRIBUTE9               = p_eco_revision_rec.attribute9
    ,       ATTRIBUTE10              = p_eco_revision_rec.attribute10
    ,       ATTRIBUTE11              = p_eco_revision_rec.attribute11
    ,       ATTRIBUTE12              = p_eco_revision_rec.attribute12
    ,       ATTRIBUTE13              = p_eco_revision_rec.attribute13
    ,       ATTRIBUTE14              = p_eco_revision_rec.attribute14
    ,       ATTRIBUTE15              = p_eco_revision_rec.attribute15
    ,       Original_System_Reference =
                                    p_eco_revision_rec.Original_System_Reference
    ,       CHANGE_ID                = p_Eco_Rev_Unexp_Rec.change_id


    WHERE   REVISION_ID = p_Eco_Rev_Unexp_Rec.revision_id;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

EXCEPTION

    WHEN OTHERS THEN

        IF G_CONTROL_REC.caller_type = 'FORM'
        THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE;
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
	 	l_err_text := G_PKG_NAME || ' : Utility (ECO Update) '
                                        || substrb(SQLERRM,1,200);
        	Error_Handler.Add_Error_Token
        	( p_Message_Text => l_err_text
        	, p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
        	, x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
        	);
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Row;

/***************************************************************************
*Procedure	: Insert_Row
*Parameters IN	: Eco Revisions exposed columns record
*		  Eco Revisions unexposed columns record
*Parameters OUT : Mesg Token Table
*		  Return_Status
*Purpose	: Insert a new revision record. Failure to do so will return
*		  an unexpected error with message text in the Mesg token
*		  Table and a return status of U
***************************************************************************/
PROCEDURE Insert_Row
(   p_eco_revision_rec		IN  Eng_Eco_Pub.Eco_Revision_Rec_Type
 ,  p_Eco_Rev_Unexp_Rec		IN  Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
 ,  x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 ,  x_Return_Status		OUT NOCOPY VARCHAR2
)
IS
l_Mesg_token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
l_user_id               NUMBER;
l_login_id              NUMBER;
l_prog_appid            NUMBER;
l_prog_id               NUMBER;
l_request_id            NUMBER;
l_chk_co_app            eng_engineering_changes.approval_status_type%TYPE;
l_change_order_type_id  NUMBER;
l_route_id              NUMBER;
l_process               NUMBER	;
l_priority_code		eng_engineering_changes.priority_code%TYPE; -- Bug 3665542

BEGIN

    l_user_id           := Eng_Globals.Get_User_Id;
    l_login_id          := Eng_Globals.Get_Login_Id;
    l_request_id        := ENG_GLOBALS.Get_request_id;
    l_prog_appid        := ENG_GLOBALS.Get_prog_appid;
    l_prog_id           := ENG_GLOBALS.Get_prog_id;


    INSERT  INTO ENG_CHANGE_ORDER_REVISIONS
    (       REVISION_ID
    ,       CHANGE_NOTICE
    ,       ORGANIZATION_ID
    ,       REVISION
    ,       COMMENTS
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
    ,	    PROGRAM_ID
    ,	    PROGRAM_APPLICATION_ID
    ,       PROGRAM_UPDATE_DATE
    ,	    REQUEST_ID
    ,       LAST_UPDATE_DATE
    ,	    LAST_UPDATED_BY
    ,	    CREATION_DATE
    ,	    CREATED_BY
    ,	    LAST_UPDATE_LOGIN
    ,       Original_System_Reference
    ,       CHANGE_ID
    )
    VALUES
    (       p_Eco_Rev_Unexp_Rec.revision_id
    ,       p_Eco_Revision_Rec.Eco_Name
    ,       p_Eco_Rev_Unexp_Rec.organization_id
    ,       p_eco_revision_rec.revision
    ,       DECODE(  p_eco_revision_rec.comments
		   , FND_API.G_MISS_CHAR
		   , NULL
		   , p_eco_revision_rec.comments
		   )
    ,       p_eco_revision_rec.attribute_category
    ,       p_eco_revision_rec.attribute1
    ,       p_eco_revision_rec.attribute2
    ,       p_eco_revision_rec.attribute3
    ,       p_eco_revision_rec.attribute4
    ,       p_eco_revision_rec.attribute5
    ,       p_eco_revision_rec.attribute6
    ,       p_eco_revision_rec.attribute7
    ,       p_eco_revision_rec.attribute8
    ,       p_eco_revision_rec.attribute9
    ,       p_eco_revision_rec.attribute10
    ,	    p_eco_revision_rec.attribute11
    ,	    p_eco_revision_rec.attribute12
    ,	    p_eco_revision_rec.attribute13
    ,	    p_eco_revision_rec.attribute14
    ,	    p_eco_revision_rec.attribute15
    ,	    l_Prog_Id
    ,	    l_Prog_AppId
    ,       SYSDATE /* Program Update Date */
    ,	    NULL    /* Request Id */
    ,  	    SYSDATE /* Last Upate Date */
    ,	    l_User_Id /* Last Updated By */
    ,       SYSDATE /* Creation Date */
    ,	    l_User_Id /* Created By */
    ,	    l_User_Id /* Last Updated Login */
    ,       p_eco_revision_rec.Original_System_Reference
    ,       p_Eco_Rev_Unexp_Rec.change_id
    );


 /*  Bug no:3047312
    UPDATE eng_engineering_changes
    SET approval_status_type = 1
    WHERE change_id = p_Eco_Rev_Unexp_Rec.change_id;
    end of Bug no:3047312 */
    /*   Bug no:3047312*/
  if ENG_GLOBALS.G_ENG_LAUNCH_IMPORT = 1 then --this should'nt be done for propagation
    l_chk_co_app := ret_app_status ( p_Eco_Rev_Unexp_Rec.change_id,l_change_order_type_id,l_route_id, l_priority_code);
    if l_route_id is null then
       l_process :=    ret_pro_name (l_change_order_type_id, l_priority_code );
    end if;
      if (l_chk_co_app = 5    AND    l_route_id is not null )
       OR
       (l_chk_co_app = 5      AND l_process = 1)
        then
        -- Set ECO to 'Not Submitted For Approval'

        UPDATE eng_engineering_changes
           SET approval_status_type = 1,
               approval_request_date = null,
               approval_date = null,
               last_update_date = SYSDATE,
               last_updated_by = FND_GLOBAL.USER_ID,
	       last_update_login = FND_GLOBAL.LOGIN_ID
         WHERE change_id = p_Eco_Rev_Unexp_Rec.change_id;

        -- Set all "Scheduled" revised items to "Open"

        UPDATE eng_revised_items
           SET status_type = 1,
               last_update_date = SYSDATE,
               last_updated_by = FND_GLOBAL.USER_ID,
	       last_update_login = FND_GLOBAL.LOGIN_ID
         WHERE change_id = p_Eco_Rev_Unexp_Rec.change_id
           AND status_type = 4;

     end if;
   end if;
/*   end of Bug no:3047312 */

EXCEPTION

    WHEN OTHERS THEN

        IF G_CONTROL_REC.caller_type = 'FORM'
        THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE;
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
              Error_Handler.Add_Error_Token
	      (  p_Message_Name      => NULL
               , p_Message_Text      => 'ERROR in Insert Row (ECO Rev) ' ||
                                        SUBSTR(SQLERRM, 1, 100) || ' '   ||
					TO_CHAR(SQLCODE)
               , p_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
	       , x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
	       );
        END IF;
	x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Insert_Row;

/***************************************************************************
*Procedure      : Delete_Row
*Parameters IN  : Eco Revisions Key column
*Parameters OUT : Mesg Token Table
*                 Return_Status
*Purpose        : Delete an Eco Revision Record.
***************************************************************************/

PROCEDURE Delete_Row
(   p_revision_id       IN  NUMBER
 ,  x_Mesg_Token_Tbl	OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 ,  x_Return_Status	OUT NOCOPY VARCHAR2
)
IS
l_Mesg_Token_Tbl	Error_Handler.Mesg_Token_Tbl_Type;
BEGIN

    DELETE  FROM ENG_CHANGE_ORDER_REVISIONS
    WHERE   REVISION_ID = p_revision_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        IF G_CONTROL_REC.caller_type = 'FORM'
        THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE;
        END IF;

    	Error_Handler.Add_Error_Token
	(  p_Message_Name	=> 'OE_LOCK_ROW_DELETED'
         , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
	 , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
	 );
	x_Return_Status := FND_API.G_RET_STS_ERROR;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    WHEN OTHERS THEN

        IF G_CONTROL_REC.caller_type = 'FORM'
        THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE;
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
              Error_Handler.Add_Error_Token
	      (  p_Message_Name		=> NULL
               , p_Message_Text		=> 'ERROR in Delete Row (ECO Rev) ' ||
                                           substr(SQLERRM, 1, 30) || ' '    ||
					   to_char(SQLCODE)
               , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
	       , x_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
	       );
        END IF;

	x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Delete_Row;

/***************************************************************************
*Procedure      : Query_Row
*Parameters IN  : Eco Revisions Key column
*Parameters OUT : Return_Status
*		  Eco Revision exposed column record
*		  Eco Revision unexposed column record
*Purpose        : Query up an Eco Revision Record an seperately return
*		  the record of exposed columns and unexposed record.
***************************************************************************/

PROCEDURE Query_Row
(   p_Change_Notice		IN  VARCHAR2
  , p_Organization_Id		IN  NUMBER
  , p_Revision			IN  VARCHAR2
  , x_Eco_Revision_Rec		OUT NOCOPY Eng_Eco_Pub.Eco_Revision_Rec_Type
  , x_Eco_Rev_Unexp_Rec		OUT NOCOPY Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
  , x_Return_Status		OUT NOCOPY Varchar2
)
IS
l_err_text		VARCHAR2(2000);
BEGIN

    SELECT  REVISION_ID
    ,       CHANGE_NOTICE
    ,       ORGANIZATION_ID
    ,       REVISION
    ,       COMMENTS
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
    ,       CHANGE_ID       --column added
    INTO    x_Eco_Rev_Unexp_Rec.revision_id
    ,       x_eco_revision_rec.Eco_Name
    ,       x_Eco_Rev_Unexp_Rec.organization_id
    ,       x_eco_revision_rec.revision
    ,       x_eco_revision_rec.comments
    ,       x_eco_revision_rec.attribute_category
    ,       x_eco_revision_rec.attribute1
    ,       x_eco_revision_rec.attribute2
    ,       x_eco_revision_rec.attribute3
    ,       x_eco_revision_rec.attribute4
    ,       x_eco_revision_rec.attribute5
    ,       x_eco_revision_rec.attribute6
    ,       x_eco_revision_rec.attribute7
    ,       x_eco_revision_rec.attribute8
    ,       x_eco_revision_rec.attribute9
    ,       x_eco_revision_rec.attribute10
    ,	    x_eco_revision_rec.attribute11
    ,       x_eco_revision_rec.attribute12
    ,       x_eco_revision_rec.attribute13
    ,       x_eco_revision_rec.attribute14
    ,       x_eco_revision_rec.attribute15
    ,       x_Eco_Rev_Unexp_Rec.change_id
    FROM    ENG_CHANGE_ORDER_REVISIONS
    WHERE   REVISION = p_revision
      AND   CHANGE_NOTICE = p_Change_Notice
      AND   ORGANIZATION_ID = p_Organization_Id;

	x_Return_Status := Eng_Globals.G_RECORD_FOUND;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
	x_Return_Status := Eng_Globals.G_RECORD_NOT_FOUND;
    WHEN OTHERS THEN
	x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END Query_Row;

/****************************************************************************
* Procedure	: Perform_Writes
* Parameters IN	: Eco Revision exposed column record
*		  Eco Revision unexposed Column record
* Prameters OUT : Mesg token Tbl
*		  Return Status
* Purpose	: Based on the transaction type, this procedure will call the
*		  insert, update or delete procedures. When it comes to writing
*		  data to the entity tables, this is the only exposed procedure.
******************************************************************************/
PROCEDURE Perform_Writes
(  p_eco_revision_rec		IN  Eng_Eco_Pub.Eco_Revision_Rec_Type
 , p_eco_rev_unexp_rec		IN  Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
 , p_control_rec        	IN  BOM_BO_PUB.Control_Rec_Type
                            	:= BOM_BO_PUB.G_DEFAULT_CONTROL_REC
 , x_mesg_token_tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status		OUT NOCOPY VARCHAR2
)
IS
	l_mesg_token_tbl	Error_Handler.Mesg_Token_Tbl_Type;
	l_return_status		VARCHAR2(1);
BEGIN
	l_return_status := FND_API.G_RET_STS_SUCCESS;

        G_CONTROL_REC := p_control_rec;

	IF p_eco_revision_rec.transaction_type = Eng_Globals.G_OPR_CREATE
	THEN
		Insert_Row
		(  p_eco_revision_rec	=> p_eco_revision_rec
		 , p_eco_rev_unexp_rec	=> p_eco_rev_unexp_rec
		 , x_mesg_token_tbl	=> l_mesg_token_tbl
		 , x_return_status	=> l_return_status
		);
	ELSIF p_eco_revision_rec.transaction_type = Eng_Globals.G_OPR_UPDATE
	THEN
                Update_Row
                (  p_eco_revision_rec   => p_eco_revision_rec
                 , p_eco_rev_unexp_rec  => p_eco_rev_unexp_rec
                 , x_mesg_token_tbl     => l_mesg_token_tbl
                 , x_return_status      => l_return_status
                );

	ELSIF p_eco_revision_rec.transaction_type = Eng_Globals.G_OPR_DELETE
	THEN
		Delete_Row
		(  p_revision_id	=> p_eco_rev_unexp_rec.revision_id
		 , x_mesg_token_tbl	=> l_mesg_token_tbl
		 , x_return_status	=> l_return_status
		 );
	END IF;

	x_return_status := l_return_status;
	x_mesg_token_tbl := l_mesg_token_tbl;

END Perform_Writes;

--  Procedure       lock_Row
--  NOT USED CURRENTLY
PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_eco_revision_rec              IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
,   x_eco_revision_rec              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Rec_Type
,   x_err_text			    OUT NOCOPY VARCHAR2
)
IS
l_eco_revision_rec            ENG_Eco_PUB.Eco_Revision_Rec_Type;
l_err_text		      VARCHAR2(255);
BEGIN
	NULL;
/*
    SELECT  ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       REVISION_ID
    ,       CHANGE_NOTICE
    ,       ORGANIZATION_ID
    ,       REVISION
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATED_BY
    ,       CREATION_DATE
    ,       CREATED_BY
    ,       LAST_UPDATE_LOGIN
    ,       COMMENTS
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
    INTO    l_eco_revision_rec.attribute11
    ,       l_eco_revision_rec.attribute12
    ,       l_eco_revision_rec.attribute13
    ,       l_eco_revision_rec.attribute14
    ,       l_eco_revision_rec.attribute15
    ,       l_eco_revision_rec.program_application_id
    ,       l_eco_revision_rec.program_id
    ,       l_eco_revision_rec.program_update_date
    ,       l_eco_revision_rec.request_id
    ,       l_eco_revision_rec.revision_id
    ,       l_eco_revision_rec.change_notice
    ,       l_eco_revision_rec.organization_id
    ,       l_eco_revision_rec.rev
    ,       l_eco_revision_rec.last_update_date
    ,       l_eco_revision_rec.last_updated_by
    ,       l_eco_revision_rec.creation_date
    ,       l_eco_revision_rec.created_by
    ,       l_eco_revision_rec.last_update_login
    ,       l_eco_revision_rec.comments
    ,       l_eco_revision_rec.attribute_category
    ,       l_eco_revision_rec.attribute1
    ,       l_eco_revision_rec.attribute2
    ,       l_eco_revision_rec.attribute3
    ,       l_eco_revision_rec.attribute4
    ,       l_eco_revision_rec.attribute5
    ,       l_eco_revision_rec.attribute6
    ,       l_eco_revision_rec.attribute7
    ,       l_eco_revision_rec.attribute8
    ,       l_eco_revision_rec.attribute9
    ,       l_eco_revision_rec.attribute10
    FROM    ENG_CHANGE_ORDER_REVISIONS
    WHERE   REVISION_ID = p_eco_revision_rec.revision_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  (   (l_eco_revision_rec.attribute11 =
             p_eco_revision_rec.attribute11) OR
            ((p_eco_revision_rec.attribute11 = FND_API.G_MISS_CHAR) OR
            (   (l_eco_revision_rec.attribute11 IS NULL) AND
                (p_eco_revision_rec.attribute11 IS NULL))))
    AND (   (l_eco_revision_rec.attribute12 =
             p_eco_revision_rec.attribute12) OR
            ((p_eco_revision_rec.attribute12 = FND_API.G_MISS_CHAR) OR
            (   (l_eco_revision_rec.attribute12 IS NULL) AND
                (p_eco_revision_rec.attribute12 IS NULL))))
    AND (   (l_eco_revision_rec.attribute13 =
             p_eco_revision_rec.attribute13) OR
            ((p_eco_revision_rec.attribute13 = FND_API.G_MISS_CHAR) OR
            (   (l_eco_revision_rec.attribute13 IS NULL) AND
                (p_eco_revision_rec.attribute13 IS NULL))))
    AND (   (l_eco_revision_rec.attribute14 =
             p_eco_revision_rec.attribute14) OR
            ((p_eco_revision_rec.attribute14 = FND_API.G_MISS_CHAR) OR
            (   (l_eco_revision_rec.attribute14 IS NULL) AND
                (p_eco_revision_rec.attribute14 IS NULL))))
    AND (   (l_eco_revision_rec.attribute15 =
             p_eco_revision_rec.attribute15) OR
            ((p_eco_revision_rec.attribute15 = FND_API.G_MISS_CHAR) OR
            (   (l_eco_revision_rec.attribute15 IS NULL) AND
                (p_eco_revision_rec.attribute15 IS NULL))))
    AND (   (l_eco_revision_rec.program_application_id =
             p_eco_revision_rec.program_application_id) OR
            ((p_eco_revision_rec.program_application_id = FND_API.G_MISS_NUM) OR
            (   (l_eco_revision_rec.program_application_id IS NULL) AND
                (p_eco_revision_rec.program_application_id IS NULL))))
    AND (   (l_eco_revision_rec.program_id =
             p_eco_revision_rec.program_id) OR
            ((p_eco_revision_rec.program_id = FND_API.G_MISS_NUM) OR
            (   (l_eco_revision_rec.program_id IS NULL) AND
                (p_eco_revision_rec.program_id IS NULL))))
    AND (   (l_eco_revision_rec.program_update_date =
             p_eco_revision_rec.program_update_date) OR
            ((p_eco_revision_rec.program_update_date = FND_API.G_MISS_DATE) OR
            (   (l_eco_revision_rec.program_update_date IS NULL) AND
                (p_eco_revision_rec.program_update_date IS NULL))))
    AND (   (l_eco_revision_rec.request_id =
             p_eco_revision_rec.request_id) OR
            ((p_eco_revision_rec.request_id = FND_API.G_MISS_NUM) OR
            (   (l_eco_revision_rec.request_id IS NULL) AND
                (p_eco_revision_rec.request_id IS NULL))))
    AND (   (l_eco_revision_rec.revision_id =
             p_eco_revision_rec.revision_id) OR
            ((p_eco_revision_rec.revision_id = FND_API.G_MISS_NUM) OR
            (   (l_eco_revision_rec.revision_id IS NULL) AND
                (p_eco_revision_rec.revision_id IS NULL))))
    AND (   (l_eco_revision_rec.change_notice =
             p_eco_revision_rec.change_notice) OR
            ((p_eco_revision_rec.change_notice = FND_API.G_MISS_CHAR) OR
            (   (l_eco_revision_rec.change_notice IS NULL) AND
                (p_eco_revision_rec.change_notice IS NULL))))
    AND (   (l_eco_revision_rec.organization_id =
             p_eco_revision_rec.organization_id) OR
            ((p_eco_revision_rec.organization_id = FND_API.G_MISS_NUM) OR
            (   (l_eco_revision_rec.organization_id IS NULL) AND
                (p_eco_revision_rec.organization_id IS NULL))))
    AND (   (l_eco_revision_rec.rev =
             p_eco_revision_rec.rev) OR
            ((p_eco_revision_rec.rev = FND_API.G_MISS_CHAR) OR
            (   (l_eco_revision_rec.rev IS NULL) AND
                (p_eco_revision_rec.rev IS NULL))))
    AND (   (l_eco_revision_rec.last_update_date =
             p_eco_revision_rec.last_update_date) OR
            ((p_eco_revision_rec.last_update_date = FND_API.G_MISS_DATE) OR
            (   (l_eco_revision_rec.last_update_date IS NULL) AND
                (p_eco_revision_rec.last_update_date IS NULL))))
    AND (   (l_eco_revision_rec.last_updated_by =
             p_eco_revision_rec.last_updated_by) OR
            ((p_eco_revision_rec.last_updated_by = FND_API.G_MISS_NUM) OR
            (   (l_eco_revision_rec.last_updated_by IS NULL) AND
                (p_eco_revision_rec.last_updated_by IS NULL))))
    AND (   (l_eco_revision_rec.creation_date =
             p_eco_revision_rec.creation_date) OR
            ((p_eco_revision_rec.creation_date = FND_API.G_MISS_DATE) OR
            (   (l_eco_revision_rec.creation_date IS NULL) AND
                (p_eco_revision_rec.creation_date IS NULL))))
    AND (   (l_eco_revision_rec.created_by =
             p_eco_revision_rec.created_by) OR
            ((p_eco_revision_rec.created_by = FND_API.G_MISS_NUM) OR
            (   (l_eco_revision_rec.created_by IS NULL) AND
                (p_eco_revision_rec.created_by IS NULL))))
    AND (   (l_eco_revision_rec.last_update_login =
             p_eco_revision_rec.last_update_login) OR
            ((p_eco_revision_rec.last_update_login = FND_API.G_MISS_NUM) OR
            (   (l_eco_revision_rec.last_update_login IS NULL) AND
                (p_eco_revision_rec.last_update_login IS NULL))))
    AND (   (l_eco_revision_rec.comments =
             p_eco_revision_rec.comments) OR
            ((p_eco_revision_rec.comments = FND_API.G_MISS_CHAR) OR
            (   (l_eco_revision_rec.comments IS NULL) AND
                (p_eco_revision_rec.comments IS NULL))))
    AND (   (l_eco_revision_rec.attribute_category =
             p_eco_revision_rec.attribute_category) OR
            ((p_eco_revision_rec.attribute_category = FND_API.G_MISS_CHAR) OR
            (   (l_eco_revision_rec.attribute_category IS NULL) AND
                (p_eco_revision_rec.attribute_category IS NULL))))
    AND (   (l_eco_revision_rec.attribute1 =
             p_eco_revision_rec.attribute1) OR
            ((p_eco_revision_rec.attribute1 = FND_API.G_MISS_CHAR) OR
            (   (l_eco_revision_rec.attribute1 IS NULL) AND
                (p_eco_revision_rec.attribute1 IS NULL))))
    AND (   (l_eco_revision_rec.attribute2 =
             p_eco_revision_rec.attribute2) OR
            ((p_eco_revision_rec.attribute2 = FND_API.G_MISS_CHAR) OR
            (   (l_eco_revision_rec.attribute2 IS NULL) AND
                (p_eco_revision_rec.attribute2 IS NULL))))
    AND (   (l_eco_revision_rec.attribute3 =
             p_eco_revision_rec.attribute3) OR
            ((p_eco_revision_rec.attribute3 = FND_API.G_MISS_CHAR) OR
            (   (l_eco_revision_rec.attribute3 IS NULL) AND
                (p_eco_revision_rec.attribute3 IS NULL))))
    AND (   (l_eco_revision_rec.attribute4 =
             p_eco_revision_rec.attribute4) OR
            ((p_eco_revision_rec.attribute4 = FND_API.G_MISS_CHAR) OR
            (   (l_eco_revision_rec.attribute4 IS NULL) AND
                (p_eco_revision_rec.attribute4 IS NULL))))
    AND (   (l_eco_revision_rec.attribute5 =
             p_eco_revision_rec.attribute5) OR
            ((p_eco_revision_rec.attribute5 = FND_API.G_MISS_CHAR) OR
            (   (l_eco_revision_rec.attribute5 IS NULL) AND
                (p_eco_revision_rec.attribute5 IS NULL))))
    AND (   (l_eco_revision_rec.attribute6 =
             p_eco_revision_rec.attribute6) OR
            ((p_eco_revision_rec.attribute6 = FND_API.G_MISS_CHAR) OR
            (   (l_eco_revision_rec.attribute6 IS NULL) AND
                (p_eco_revision_rec.attribute6 IS NULL))))
    AND (   (l_eco_revision_rec.attribute7 =
             p_eco_revision_rec.attribute7) OR
            ((p_eco_revision_rec.attribute7 = FND_API.G_MISS_CHAR) OR
            (   (l_eco_revision_rec.attribute7 IS NULL) AND
                (p_eco_revision_rec.attribute7 IS NULL))))
    AND (   (l_eco_revision_rec.attribute8 =
             p_eco_revision_rec.attribute8) OR
            ((p_eco_revision_rec.attribute8 = FND_API.G_MISS_CHAR) OR
            (   (l_eco_revision_rec.attribute8 IS NULL) AND
                (p_eco_revision_rec.attribute8 IS NULL))))
    AND (   (l_eco_revision_rec.attribute9 =
             p_eco_revision_rec.attribute9) OR
            ((p_eco_revision_rec.attribute9 = FND_API.G_MISS_CHAR) OR
            (   (l_eco_revision_rec.attribute9 IS NULL) AND
                (p_eco_revision_rec.attribute9 IS NULL))))
    AND (   (l_eco_revision_rec.attribute10 =
             p_eco_revision_rec.attribute10) OR
            ((p_eco_revision_rec.attribute10 = FND_API.G_MISS_CHAR) OR
            (   (l_eco_revision_rec.attribute10 IS NULL) AND
                (p_eco_revision_rec.attribute10 IS NULL))))
    THEN

        --  Row has not changed. Set out parameter.

        x_eco_revision_rec             := l_eco_revision_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_eco_revision_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_eco_revision_rec.return_status := FND_API.G_RET_STS_ERROR;
        Eng_Eco_Pub.Log_Error(  p_who_rec       => ENG_GLOBALS.G_WHO_REC
                              , p_msg_name      => 'OE_LOCK_ROW_CHANGED'
                              , x_err_text      => x_err_text );
    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_eco_revision_rec.return_status := FND_API.G_RET_STS_ERROR;
	Eng_Eco_Pub.Log_Error(  p_who_rec       => ENG_GLOBALS.G_WHO_REC
                              , p_msg_name      => 'OE_LOCK_ROW_DELETED'
                              , x_err_text      => x_err_text );

    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_eco_revision_rec.return_status := FND_API.G_RET_STS_ERROR;
        Eng_Eco_Pub.Log_Error(  p_who_rec       => ENG_GLOBALS.G_WHO_REC
                              , p_msg_name      => 'OE_LOCK_ROW_ALREADY_LOCKED'
                              , x_err_text      => x_err_text );
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_eco_revision_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            x_err_text := G_PKG_NAME || '( Utility ) - Lock_Row' || substr(SQLERRM,1,60);
        END IF;
*/
END Lock_Row;

END ENG_Eco_Revision_Util;

/
