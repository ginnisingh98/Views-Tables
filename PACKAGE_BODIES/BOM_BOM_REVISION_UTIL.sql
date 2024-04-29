--------------------------------------------------------
--  DDL for Package Body BOM_BOM_REVISION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BOM_REVISION_UTIL" AS
/* $Header: BOMUREVB.pls 120.1 2005/08/17 03:26:54 bbpatel noship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMUREVB.pls
--
--  DESCRIPTION
--
--      Body of package  Bom_Bom_Revision_Util
--
--  NOTES
--
--  HISTORY
--
--  30-JUL-99 Rahul Chitko      Initial Creation
--
****************************************************************************/


PROCEDURE Insert_Row
(  p_bom_revision_rec		IN  Bom_Bo_Pub.Bom_Revision_Rec_Type
 , p_bom_rev_Unexp_Rec     	IN  Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
)
IS
	l_language_code	VARCHAR2(3);
	l_revision_id	NUMBER;
	l_user_id	NUMBER := FND_GLOBAL.User_Id;
	l_login_id	NUMBER := FND_GLOBAL.Login_Id;
BEGIN
        --bug:3254815 Update request id, prog id, prog appl id and prog update date.
	      INSERT INTO MTL_ITEM_REVISIONS_B(
              inventory_item_id,
              organization_id,
              revision,
              revision_label,
              revision_reason,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              implementation_date,
              effectivity_date,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15,
              --description
	      revision_id,
	      object_version_number,
              request_id,
              program_id,
              program_application_id,
              program_update_date
             ) VALUES (
              p_bom_rev_unexp_rec.assembly_item_id,
              p_bom_rev_unexp_rec.Organization_Id,
	      p_bom_revision_rec.Revision,
              --* Added Nvl condition for Bug #3573457
	      Nvl(p_bom_revision_rec.Revision_label,p_bom_revision_rec.Revision),
              p_bom_revision_rec.Revision_reason,
              SYSDATE,
              Bom_Globals.Get_User_Id,
              SYSDATE,
              Bom_Globals.Get_User_Id,
              Bom_Globals.Get_User_Id,
              NVL(p_bom_revision_rec.start_effective_date,sysdate),/*impl date*/--bug:4242412 Replace NULL effectivity date by SYSDATE
              NVL(p_bom_revision_rec.start_effective_date,sysdate),/*eff. date*/--bug:4242412 Replace NULL effectivity date by SYSDATE
              p_bom_revision_rec.Attribute_Category,
              p_bom_revision_rec.Attribute1,
              p_bom_revision_rec.Attribute2,
              p_bom_revision_rec.Attribute3,
              p_bom_revision_rec.Attribute4,
              p_bom_revision_rec.Attribute5,
              p_bom_revision_rec.Attribute6,
              p_bom_revision_rec.Attribute7,
              p_bom_revision_rec.Attribute8,
              p_bom_revision_rec.Attribute9,
              p_bom_revision_rec.Attribute10,
              p_bom_revision_rec.Attribute11,
              p_bom_revision_rec.Attribute12,
              p_bom_revision_rec.Attribute13,
              p_bom_revision_rec.Attribute14,
              p_bom_revision_rec.Attribute15,
              --p_bom_revision_rec.Description
	      mtl_item_revisions_b_s.NEXTVAL,
	      1,
             Fnd_Global.Conc_Request_Id,
             Fnd_Global.Conc_Program_Id,
             Fnd_Global.Prog_Appl_Id,
             SYSDATE
             ) RETURNING revision_id INTO l_revision_id;

	       SELECT userenv('LANG') INTO l_language_code FROM dual;

   		-- Insert into TL table

   		INSERT INTO mtl_item_revisions_TL
                (  Inventory_Item_Id
                ,  Organization_Id
                ,  Revision_id
                 , Language
                 , Source_Lang
                 , Created_By
                 , Creation_Date
                 , Last_Updated_By
                 , Last_Update_Date
                 , Last_Update_Login
                 , Description
                 )
                SELECT p_bom_rev_unexp_rec.assembly_item_id
                     , p_bom_rev_unexp_rec.organization_id
                     , l_revision_id
                     , lang.language_code
                     , l_language_code
                     , l_user_Id
                     , sysdate
                     , l_user_Id
                     , sysdate
                     , l_login_Id
                     , p_bom_revision_rec.description
                  FROM FND_LANGUAGES lang
                 WHERE lang.installed_flag in ('I', 'B');

		x_return_status := FND_API.G_RET_STS_SUCCESS;

		EXCEPTION
			WHEN OTHERS THEN
			    Error_Handler.Add_Error_Token
			    (  p_message_name	=> NULL
			     , p_message_text	=> 'Error Inserting record: ' ||
				SQLERRM
			     , x_mesg_token_tbl	=> x_mesg_token_tbl
			     );
			     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Insert_Row;

PROCEDURE Update_Row
(  p_bom_revision_rec           IN  Bom_Bo_Pub.Bom_Revision_Rec_Type
 , p_bom_rev_Unexp_Rec     	IN  Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
)
IS
	l_language_code	VARCHAR2(3);
	l_revision_id	NUMBER;
	l_user_id	NUMBER := FND_GLOBAL.User_Id;
	l_login_id	NUMBER := FND_GLOBAL.Login_Id;
BEGIN
	UPDATE Mtl_Item_Revisions_b
	   SET --description 	= p_bom_revision_rec.Description,
	       effectivity_date = NVL(p_bom_revision_rec.start_effective_date,sysdate),--bug:4242412 Replace NULL effectivity date by SYSDATE
	       revision_label= p_bom_revision_rec.revision_label,
	       revision_reason= p_bom_revision_rec.revision_reason,
	       last_update_date	= SYSDATE,
	       last_update_login = Bom_Globals.Get_User_Id,
	       last_updated_by	= Bom_Globals.Get_User_Id,
	       Attribute_Category = p_bom_revision_rec.Attribute_Category,
               Attribute1	= p_bom_revision_rec.Attribute1,
               Attribute2	= p_bom_revision_rec.Attribute2,
               Attribute3	= p_bom_revision_rec.Attribute3,
               Attribute4	= p_bom_revision_rec.Attribute4,
               Attribute5	= p_bom_revision_rec.Attribute5,
               Attribute6	= p_bom_revision_rec.Attribute6,
               Attribute7	= p_bom_revision_rec.Attribute7,
               Attribute8	= p_bom_revision_rec.Attribute8,
               Attribute9	= p_bom_revision_rec.Attribute9,
               Attribute10	= p_bom_revision_rec.Attribute10,
               Attribute11	= p_bom_revision_rec.Attribute11,
               Attribute12	= p_bom_revision_rec.Attribute12,
               Attribute13	= p_bom_revision_rec.Attribute13,
               Attribute14	= p_bom_revision_rec.Attribute14,
               Attribute15	= p_bom_revision_rec.Attribute15,
	             object_version_number = object_version_number + 1,
               request_id = Fnd_Global.Conc_Request_Id,
               program_id = Fnd_Global.Conc_Program_Id,
               program_application_id = Fnd_Global.Prog_Appl_Id,
               program_update_date = SYSDATE
         WHERE revision = p_bom_revision_rec.revision
           AND inventory_item_id = p_bom_rev_unexp_rec.assembly_item_id
           AND organization_id   = p_bom_rev_unexp_rec.organization_id
	 RETURNING revision_id INTO l_revision_id;
           -- Added conditions for bug 1888688.

	   SELECT userenv('LANG') INTO l_language_code FROM dual;

	   -- Update the description in the TL table
	   --
	   UPDATE  mtl_item_revisions_TL
             SET  description =  decode(p_bom_Revision_rec.description, null, description, p_bom_Revision_rec.description)
                  , last_updated_by    = l_user_Id
                  , last_update_date   = sysdate
                 WHERE  revision_id = l_revision_id
                   AND  LANGUAGE = l_language_code;

               x_return_status := FND_API.G_RET_STS_SUCCESS;

                EXCEPTION
                        WHEN OTHERS THEN
                            Error_Handler.Add_Error_Token
                            (  p_message_name   => NULL
                             , p_message_text   => 'Error Updating record: ' ||
                                SQLERRM
                             , x_mesg_token_tbl => x_mesg_token_tbl
			     );
                             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Row;

PROCEDURE Perform_Writes
(  p_bom_revision_rec           IN  Bom_Bo_Pub.Bom_Revision_Rec_Type
 , p_bom_rev_Unexp_Rec     	IN  Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              IN OUT NOCOPY VARCHAR2
)
IS
	l_return_status		VARCHAR2(1);
	l_mesg_token_tbl	Error_Handler.Mesg_Token_Tbl_Type;
BEGIN
	IF p_bom_revision_rec.transaction_type = Bom_Globals.G_OPR_CREATE
	THEN
		Insert_Row
		(  p_bom_revision_rec	=> p_bom_revision_rec
		 , p_bom_rev_unexp_rec	=> p_bom_rev_unexp_rec
		 , x_return_status	=> l_return_Status
		 , x_mesg_token_tbl	=> l_mesg_token_tbl
		 );

	ELSIF p_bom_revision_rec.transaction_type = Bom_Globals.G_OPR_UPDATE
	THEN
		Update_Row
		(  p_bom_revision_rec   => p_bom_revision_rec
                 , p_bom_rev_unexp_rec  => p_bom_rev_unexp_rec
                 , x_return_status      => l_return_Status
                 , x_mesg_token_tbl     => l_mesg_token_tbl
                 );

	/* DELETES FOR REVISIONS IS NOT ALLOWD HENCE THERE IS NO DELETE */
	END IF;

	x_return_status := l_return_status;
	x_mesg_token_tbl := l_mesg_token_tbl;
END;


PROCEDURE Query_Row
(  p_revision                   IN  VARCHAR2
 , p_assembly_item_id           IN  NUMBER
 , p_organization_id            IN  NUMBER
 , x_bom_revision_rec           IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Rec_Type
 , x_bom_rev_unexp_rec      	IN OUT NOCOPY Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
 , x_return_status              IN OUT NOCOPY VARCHAR
)
IS
BEGIN
	      SELECT
              inventory_item_id,
              organization_id,
              revision,
              revision_label,
              revision_reason,
	      effectivity_date,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15,
              description
  	INTO  x_bom_rev_unexp_rec.assembly_item_id,
              x_bom_rev_unexp_rec.Organization_Id,
              x_bom_revision_rec.Revision,
              x_bom_revision_rec.Revision_label,
              x_bom_revision_rec.Revision_reason,
	      x_bom_revision_rec.start_effective_date,
              x_bom_revision_rec.Attribute_Category,
              x_bom_revision_rec.Attribute1,
              x_bom_revision_rec.Attribute2,
              x_bom_revision_rec.Attribute3,
              x_bom_revision_rec.Attribute4,
              x_bom_revision_rec.Attribute5,
              x_bom_revision_rec.Attribute6,
              x_bom_revision_rec.Attribute7,
              x_bom_revision_rec.Attribute8,
              x_bom_revision_rec.Attribute9,
              x_bom_revision_rec.Attribute10,
              x_bom_revision_rec.Attribute11,
              x_bom_revision_rec.Attribute12,
              x_bom_revision_rec.Attribute13,
              x_bom_revision_rec.Attribute14,
              x_bom_revision_rec.Attribute15,
              x_bom_revision_rec.Description
	FROM mtl_item_revisions
       WHERE revision = p_revision
	 AND inventory_item_id = p_assembly_item_id
	 AND organization_id   = p_organization_id;

	x_return_status := Bom_Globals.G_RECORD_FOUND;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			x_return_status := Bom_Globals.G_RECORD_NOT_FOUND;
		WHEN OTHERS THEN
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Query_Row;

END Bom_Bom_Revision_Util;

/
