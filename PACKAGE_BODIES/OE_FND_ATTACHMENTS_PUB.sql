--------------------------------------------------------
--  DDL for Package Body OE_FND_ATTACHMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_FND_ATTACHMENTS_PUB" as
/* $Header: OEXPATTB.pls 120.0 2005/06/01 00:01:09 appldev noship $ */


G_INVALID_PARAMETER_EXCEPTION  EXCEPTION;
G_PKG_NAME     CONSTANT VARCHAR2(30):= 'Oe_Fnd_Attachments_Pub';


-- public functions
-------------------------------------------------------------------------
PROCEDURE Add_Attachment
(
 p_api_version				in   number,
 p_entity_name				in   varchar,
 p_pk1_value                        in   varchar2,
 p_pk2_value                        in   varchar2 default null,
 p_pk3_value                        in   varchar2 default null,
 p_pk4_value                        in   varchar2 default null,
 p_pk5_value                        in   varchar2 default null,
 p_automatic_flag				in   varchar2 default 'N',
 p_commit					in   varchar2 default fnd_api.G_FALSE,
 p_document_id				in   number,
 x_attachment_id				out NOCOPY /* file.sql.39 change */  number,
 x_return_status                    out NOCOPY /* file.sql.39 change */  varchar2,
 x_msg_count                        out NOCOPY /* file.sql.39 change */  number,
 x_msg_data                         out NOCOPY /* file.sql.39 change */  varchar2
)
IS
   l_api_version           CONSTANT NUMBER := 1.0;
   l_api_name              CONSTANT VARCHAR2(30):= 'Add_Attachment';

   l_user_id	      	number:=fnd_global.USER_ID;
   l_login_id	      	number:=fnd_global.LOGIN_ID;
   l_program_id	      	number:=fnd_global.CONC_PROGRAM_ID;
   l_program_application_id	number:=fnd_global.PROG_APPL_ID;
   l_request_id			number:=fnd_global.CONC_REQUEST_ID;
   l_curr_date          	date  :=sysdate;
   l_program_update_date 	date  :=null;
   l_dummy				varchar(1);
   l_attachment_id            number;
   l_attachment_exists        boolean;

   CURSOR C_ATCHMT
   IS
      SELECT 'Y'
      FROM FND_ATTACHED_DOCUMENTS
      WHERE document_id = p_document_id
      AND   entity_name = p_entity_name
      AND    pk1_value   = p_pk1_value
      AND    (pk2_value IS NULL
           OR  pk2_value = p_pk2_value)
      AND    (pk3_value IS NULL
           OR  pk3_value = p_pk3_value)
      AND    (pk2_value IS NULL
           OR  pk4_value = p_pk4_value)
      AND    (pk2_value IS NULL
           OR  pk5_value = p_pk5_value);


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OE_FND_ATTACHMENTS_PUB.ADD_ATTACHMENT:BEGIN' || P_ENTITY_NAME || ' , '||P_PK1_VALUE ||' , '||P_PK2_VALUE ) ;
   END IF;

    --  Standard call to check for call compatibility
    -----------------------------------------------------------------------
    if not fnd_api.compatible_api_call(   l_api_version
					           , p_api_version
					           , l_api_name
					           , G_PKG_NAME
					           ) then
        raise fnd_api.G_EXC_UNEXPECTED_ERROR;
    end if;

    -- we need to attach the documents only if it is not already attached
    --------------------------------------------------------------------------
    l_attachment_exists := TRUE; -- assume
    open C_ATCHMT;
    fetch C_ATCHMT into l_dummy;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OE_FND_ATTACHMENTS_PUB.ATTACHMENT EXISTS DUMMY=' || L_DUMMY ) ;
    END IF;
    if (C_ATCHMT%NOTFOUND)   then
       l_attachment_exists := FALSE;
       close C_ATCHMT;
    else
      close C_ATCHMT;
    end if;

    if (l_attachment_exists = FALSE) then
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'OE_FND_ATTACHMENTS_PUB.ADD_ATTACHMENT:CALLING PVT.ADD_ATTACHMENT!' ) ;
       END IF;

       Oe_Fnd_Attachments_PVT.Add_Attachment(
                              p_api_version		=> 1.0,
					p_entity_name	=> p_entity_name,
					p_pk1_value		=> p_pk1_value,
					p_pk2_value		=> p_pk2_value,
					p_pk3_value		=> p_pk3_value,
					p_pk4_value		=> p_pk4_value,
					p_pk5_value		=> p_pk5_value,
                              p_automatic_flag  => p_automatic_flag,
                              p_document_id	=> p_document_id,
                              p_validate_flag   => 'Y',
					x_attachment_id	=> x_attachment_id,
				      x_return_status   => x_return_status,
					x_msg_count 	=> x_msg_count,
				      x_msg_data        => x_msg_data
					);

    end if;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OE_FND_ATTACHMENTS_PUB.ADD_ATTACHMENT:END' ) ;
   END IF;

END Add_Attachment;


---------------------------------------------------------------------------
PROCEDURE Add_Attachments
(
 p_api_version                      in   number,
 p_entity_name                      in   varchar2,
 p_pk1_value                        in   varchar2,
 p_pk2_value                        in   varchar2 default null,
 p_pk3_value                        in   varchar2 default null,
 p_pk4_value                        in   varchar2 default null,
 p_pk5_value                        in   varchar2 default null,
 p_process_flag				in   varchar2 default G_RETURN_ON_ERROR,
 p_automatic_attachment			in   varchar2 default 'N',
 p_commit					in   varchar2 default fnd_api.G_FALSE,
 p_document_tbl   		      in out NOCOPY /* file.sql.39 change */ Documet_Tbl_Type,
 x_return_status                    out NOCOPY /* file.sql.39 change */  varchar2,
 x_msg_count                        out NOCOPY /* file.sql.39 change */  number,
 x_msg_data                         out NOCOPY /* file.sql.39 change */  varchar2
)
IS
   l_api_version           CONSTANT NUMBER := 1.0;
   l_api_name              CONSTANT VARCHAR2(30):= 'Add_Attachments';
   l_return_status	   varchar2(1);
   l_msg_count		   number;
   l_msg_data		   varchar2(80);
   l_attach_this_document     boolean := FALSE;
   l_attachment_exists        boolean := FALSE;

   l_dummy				varchar(1);


   CURSOR C_DOC (cp_document_id number)
   IS
      SELECT 'Y'
      FROM FND_DOCUMENTS
      WHERE document_id = cp_document_id;



  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

    --  Standard call to check for call compatibility
    -----------------------------------------------------------------------
    if not fnd_api.compatible_api_call(   l_api_version
					           , p_api_version
					           , l_api_name
					           , G_PKG_NAME
					           ) then
        raise fnd_api.G_EXC_UNEXPECTED_ERROR;
    end if;



   -- do it for all documents in the table
   ----------------------------------------
   for i in 1..p_document_tbl.COUNT loop
      l_attach_this_document := FALSE;
      l_attachment_exists    := FALSE;

      -- if the document_id is passed then validate it..
      -- otherwise create the document on the fly
      ----------------------------------------------------
      if (p_document_tbl(i).document_id is null) then

         -- this version supports only SHORT_TEXT..
         -- raise an error for any other data types
         --------------------------------------------------------------
         if (p_document_tbl(i).datatype_id <> G_DATATYPE_SHORT_TEXT) then
            -- add messages here...
            raise G_INVALID_PARAMETER_EXCEPTION;
         end if;
         Create_Short_Text_Document(
					p_api_version 		=> 1.0,
					p_document_text		=> p_document_tbl(i).content_short_text,
					p_document_category	=> p_document_tbl(i).category_id,
					p_document_description	=> p_document_tbl(i).description,
				      p_language			=> p_document_tbl(i).language,
				      p_security_type         => p_document_tbl(i).security_type,
					p_security_id 		=> p_document_tbl(i).security_id,
					p_publish_flag		=> p_document_tbl(i).publish_flag,
					p_usage_type		=> p_document_tbl(i).usage_type,
				      p_start_date_active	=> p_document_tbl(i).start_date_active,
				      p_end_date_active		=> p_document_tbl(i).end_date_active,
					x_document_id           => p_document_tbl(i).document_id,
				      x_return_status         => l_return_status,
					x_msg_count 		=> l_msg_count,
				      x_msg_data              => l_msg_data
					);
         if (l_return_status <> fnd_api.G_RET_STS_SUCCESS) then
            if (p_process_flag = G_RETURN_ON_ERROR) then
               -- terminate process
               x_return_status := l_return_status;
	         --  Get message count and data
       	   fnd_msg_pub.Count_And_Get(p_count    => x_msg_count
			  			     ,p_data    => x_msg_data );
               return;
            end if;
            l_attach_this_document := FALSE;
         else
            l_attach_this_document := TRUE;
         end if;
      else
         -- no need to create document on the fly..
         -- document id is passed as the parameter.. let's validate it..
         -- before attaching this document, let's validate the document id...
         ------------------------------------------------------------------------
         l_attach_this_document := TRUE;
         open C_DOC(p_document_tbl(i).document_id);
         fetch C_DOC into l_dummy;
         if (C_DOC%NOTFOUND)   then
            -- invalid document id!
            close C_DOC;
            l_attach_this_document := FALSE;
         else
            close C_DOC;
         end if;
      end if;

      if (l_attach_this_document = FALSE AND p_process_flag = G_RETURN_ON_ERROR) then
           -- terminate process
          x_return_status := fnd_api.G_RET_STS_ERROR;
          -- add the error message
          --  Get message count and data
 	    fnd_msg_pub.Count_And_Get(p_count    => x_msg_count
 		  			        ,p_data    => x_msg_data );
          return;
      end if;

      -- the document is valid. attach it to the entity
      if (l_attach_this_document = TRUE) then
         Oe_Fnd_Attachments_PVT.Add_Attachment(
                              p_api_version		=> 1.0,
					p_entity_name	=> p_entity_name,
					p_pk1_value		=> p_pk1_value,
					p_pk2_value		=> p_pk2_value,
					p_pk3_value		=> p_pk3_value,
					p_pk4_value		=> p_pk4_value,
					p_pk5_value		=> p_pk5_value,
                              p_automatic_flag  => p_automatic_attachment,
                              p_document_id	=> p_document_tbl(i).document_id,
                              p_validate_flag   => 'Y',
					x_attachment_id	=> p_document_tbl(i).attachment_id,
				      x_return_status   => l_return_status,
					x_msg_count 	=> l_msg_count,
				      x_msg_data        => l_msg_data
					);

      end if;
   -- end of loop
   --------------
   end loop;
   x_return_status := fnd_api.G_RET_STS_SUCCESS;
   fnd_msg_pub.count_and_get(  p_count  => x_msg_count,
 		                   p_data   => x_msg_data
   			          );


EXCEPTION
   WHEN G_INVALID_PARAMETER_EXCEPTION THEN
      fnd_msg_pub.count_and_get(  p_count  => x_msg_count,
  			               p_data   => x_msg_data
   			             );
      x_return_status := fnd_api.G_RET_STS_ERROR;

   WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data
        fnd_msg_pub.Count_And_Get(p_count   => x_msg_count
					   ,p_data    => x_msg_data );


   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        if fnd_msg_pub.Check_Msg_Level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) then
            fnd_msg_pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        end if;

        --  Get message count and data
        fnd_msg_pub.Count_And_Get(p_count   => x_msg_count
					   ,p_data    => x_msg_data );



END Add_Attachments;


-------------------------------------------------------------------------
PROCEDURE Add_Attachments_Automatic
(
 p_api_version                      in   number,
 p_entity_name                      in   varchar2,
 p_pk1_value                        in   varchar2,
 p_pk2_value                        in   varchar2 default null,
 p_pk3_value                        in   varchar2 default null,
 p_pk4_value                        in   varchar2 default null,
 p_pk5_value                        in   varchar2 default null,
 p_commit					in   varchar2 default fnd_api.G_FALSE,
 x_attachment_count                 out NOCOPY /* file.sql.39 change */  number,
 x_return_status                    out NOCOPY /* file.sql.39 change */  varchar2,
 x_msg_count                        out NOCOPY /* file.sql.39 change */  number,
 x_msg_data                         out NOCOPY /* file.sql.39 change */  varchar2
)
IS
 l_return_status                    varchar2(1);
 l_msg_count                        number;
 l_msg_data                         varchar2(255);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   -- NOTE: done in PVT package
   oe_fnd_attachments_pvt.Add_Attachments_Automatic(
     					      p_api_version => 1.0
					      ,p_entity_name => p_entity_name
					      ,p_pk1_value   => p_pk1_value
					      ,p_pk2_value   => p_pk2_value
					      ,p_pk3_value   => p_pk3_value
					      ,p_pk4_value   => p_pk4_value
					      ,p_pk5_value   => p_pk5_value
					      ,p_commit	   => p_commit
                                    ,x_attachment_count=>x_attachment_count
					      ,x_return_status   => l_return_status
					      ,x_msg_count       => l_msg_count
					      ,x_msg_data        => l_msg_data
					   );


   x_return_status := l_return_status;
   x_msg_count     := l_msg_count;
   x_msg_data      := l_msg_data;

EXCEPTION
   WHEN OTHERS THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OFA:ADD_ATTACHMENTS_AUTOMATIC:AN EXCCEPTION HAS OCCURED' ) ;
     END IF;

     fnd_message.set_name('OE', 'OE_APPLY_ATTACHMENT_EXCEPTION');
     fnd_msg_pub.count_and_get(  p_count  => x_msg_count,
			             p_data   => x_msg_data
			          );
     x_return_status := fnd_api.G_RET_STS_ERROR;
END Add_Attachments_Automatic;

--------------------------------------------------------------------------------------
PROCEDURE Create_Short_Text_Document
(
 p_api_version                      in   number,
 p_document_text				in   varchar2,
 p_document_category                in   number,
 p_document_description			in   varchar2,
 p_language					in   varchar2 default null,
 p_security_type                    in   number default G_SECURITY_TYPE_NONE,
 p_security_id                      in   number default null,
 p_publish_flag                     in   varchar2 default 'Y',
 p_usage_type                       in   varchar2,
 p_start_date_active			in   date default sysdate,
 p_end_date_active			in   date default null,
 p_commit					in   varchar2 default fnd_api.G_FALSE,
 x_document_id                      out NOCOPY /* file.sql.39 change */  number,
 x_return_status                    out NOCOPY /* file.sql.39 change */  varchar2,
 x_msg_count                        out NOCOPY /* file.sql.39 change */  number,
 x_msg_data                         out NOCOPY /* file.sql.39 change */  varchar2
)
IS
   l_media_id		number;
   l_rowid			varchar2(30);
   l_language           varchar2(30);
   l_dummy              varchar2(5);
   l_document_id        number;

   l_user_id	      	number:=fnd_global.USER_ID;
   l_login_id	      	number:=fnd_global.LOGIN_ID;
   l_program_id	      	number:=fnd_global.CONC_PROGRAM_ID;
   l_program_application_id	number:=fnd_global.PROG_APPL_ID;
   l_request_id			number:=fnd_global.CONC_REQUEST_ID;
   l_curr_date          	date  :=sysdate;
   l_program_update_date 	date  :=null;

   CURSOR C_CATEGORY
   IS
      SELECT 'Yes'
      FROM FND_DOCUMENT_CATEGORIES
      WHERE category_id = p_document_category;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OFA:CREATE_SHORT_TEXT_DOCUMENT:BEGIN' ) ;
   END IF;
   -- do the basic validations to test null document
   -------------------------------------------------
   if (p_document_text IS NULL) then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OFA:CREATE_SHORT_TEXT_DOCUMENT:DOCUMENT TEXT IS NULL' ) ;
      END IF;
      fnd_message.set_name('FND', 'ATCHMT-NULL DOCUMENT');
      fnd_msg_pub.add;
      raise G_INVALID_PARAMETER_EXCEPTION;
   end if;

   -- do the basic validations on security type
   ---------------------------------------------
   if (p_security_type <> G_SECURITY_TYPE_NONE AND p_security_id IS NULL) then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OFA:CREATE_SHORT_TEXT_DOCUMENT:INVALID SECURITY COMBINATION' ) ;
      END IF;
      fnd_message.set_name('FND', 'SECURITY_TYPE_NULL');
      fnd_msg_pub.add;
      raise G_INVALID_PARAMETER_EXCEPTION;
   end if;

   -- assign program update date to current date if this is a conc mgr call
   ------------------------------------------------------------------------
   if(l_program_id <> -1) then
      l_program_update_date := l_curr_date;
   end if;

   -- validate and assign language
   ------------------------------------------------------------------------
   if (p_language is null) then
      -- validate the language
      l_language := SUBSTR(USERENV('LANGUAGE'),1,INSTR(USERENV('LANGUAGE'),'_')-1);
   else
      l_language := p_language;
   end if;

   -- validate document_category_id
   ------------------------------------------------------------------------
   open C_CATEGORY;
   fetch C_CATEGORY into l_dummy;
   if (C_CATEGORY%NOTFOUND)   then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OFA:CREATE_SHORT_TEXT_DOCUMENT:INVALID CATEGORY ID' ) ;
      END IF;
      close C_CATEGORY;
      fnd_message.set_name('FND', 'INVALID_DOCUMENT_CATEGORY');
      fnd_msg_pub.add;
      raise G_INVALID_PARAMETER_EXCEPTION;
   else
     close C_CATEGORY;
   end if;


   -- data is valid, create the document by calling fnd_documents_pkg.insert_row
   -----------------------------------------------------------------------------
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OFA:CREATE_SHORT_TEXT_DOCUMENT:INSERING A ROW-> FND_DOCUMENTS_PKG.INSERT_ROW' ) ;
   END IF;

   fnd_documents_pkg.insert_row (
                        x_rowid		=> l_rowid
				,x_document_id	=> l_document_id
				,x_creation_date	=> l_curr_date
				,x_created_by	=> l_user_id
				,x_last_update_date  => l_curr_date
                        ,x_last_updated_by   => l_user_id
				,x_last_update_login => l_login_id
				,x_request_id   	   => l_request_id
				,x_program_application_id => l_program_application_id
				,x_program_id		=> l_program_id
				,x_program_update_date	=> l_program_update_date
				,x_datatype_id	=> G_DATATYPE_SHORT_TEXT
				,x_category_id	=> p_document_category
                        ,x_security_type	=> p_security_type
				,x_security_id	=> p_security_id
				,x_publish_flag	=> p_publish_flag
				,x_image_type     => null
				,x_storage_type	=> null
				,x_usage_type	=> p_usage_type
				,x_start_date_active => p_start_date_active
				,x_end_date_active  => p_end_date_active
				,x_language		=> p_language
				,x_description	=> p_document_description
				,x_file_name	=> null
				,x_media_id		=> l_media_id
				,x_attribute_category => null
				,x_attribute1	=> null
				,x_attribute2	=> null
				,x_attribute3	=> null
				,x_attribute4	=> null
				,x_attribute5	=> null
				,x_attribute6	=> null
				,x_attribute7	=> null
				,x_attribute8	=> null
				,x_attribute9	=> null
				,x_attribute10	=> null
				,x_attribute11	=> null
				,x_attribute12	=> null
				,x_attribute13	=> null
				,x_attribute14	=> null
				,x_attribute15	=> null
			);
    x_document_id := l_document_id;

   -- now we need to insert the document text in fnd_document_short_text table
   ---------------------------------------------------------------------------
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OFA:CREATE_SHORT_TEXT_DOCUMENT:INSERING A ROW INTO FND_DOCUMENTS_SHORT_TEXT ID' || TO_CHAR ( L_DOCUMENT_ID ) ) ;
   END IF;

   INSERT INTO fnd_documents_short_text
   (
     media_id
     ,short_text
   )
   VALUES
   (
     l_media_id
     ,p_document_text
   );

   -- if commit is requested then commit the work
   ----------------------------------------------
   if(p_commit = fnd_api.G_TRUE) then
      commit;
   end if;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OFA:CREATE_SHORT_TEXT_DOCUMENT:END' ) ;
   END IF;

EXCEPTION

   WHEN G_INVALID_PARAMETER_EXCEPTION THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OFA:CREATE_SHORT_TEXT_DOCUMENT:AN INVALID PARAM EXCCEPTION HAS OCCURED' ) ;
     END IF;
     fnd_msg_pub.count_and_get(  p_count  => x_msg_count,
  			               p_data   => x_msg_data
   			             );
      x_return_status := fnd_api.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OFA:CREATE_SHORT_TEXT_DOCUMENT:AN EXCCEPTION HAS OCCURED' ) ;
      END IF;

      fnd_message.set_name('OE', 'CREATE_DOCUMENT_UNEXPECTED_ERROR');
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(  p_count  => x_msg_count,
 			                p_data   => x_msg_data
			             );
      x_return_status := fnd_api.G_RET_STS_ERROR;

END Create_Short_Text_Document;


--------------------------------------------------------------------
PROCEDURE Copy_Attachments
(
 p_api_version                      in   number,
 p_copy_attachments_tbl             in   Copy_Attachments_Tbl_Type
)
IS
   l_user_id	      	number:=fnd_global.USER_ID;
   l_login_id	      	number:=fnd_global.LOGIN_ID;
   l_program_id	      	number:=fnd_global.CONC_PROGRAM_ID;
   l_program_application_id	number:=fnd_global.PROG_APPL_ID;
   l_request_id			number:=fnd_global.CONC_REQUEST_ID;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


   for i in 1..p_copy_attachments_tbl.COUNT loop
      fnd_attached_documents2_pkg.copy_attachments(
			   x_from_entity_name	=>  p_copy_attachments_tbl(i).from_entity_name
			   ,x_from_pk1_value  	=>  p_copy_attachments_tbl(i).from_pk1_value
			   ,x_from_pk2_value  	=>  p_copy_attachments_tbl(i).from_pk2_value
			   ,x_from_pk3_value  	=>  p_copy_attachments_tbl(i).from_pk3_value
			   ,x_from_pk4_value  	=>  p_copy_attachments_tbl(i).from_pk4_value
			   ,x_from_pk5_value  	=>  p_copy_attachments_tbl(i).from_pk5_value
			   ,x_to_entity_name 	=>  p_copy_attachments_tbl(i).to_entity_name
     			   ,x_to_pk1_value     	=>  p_copy_attachments_tbl(i).to_pk1_value
     			   ,x_to_pk2_value     	=>  p_copy_attachments_tbl(i).to_pk2_value
     			   ,x_to_pk3_value     	=>  p_copy_attachments_tbl(i).to_pk3_value
     			   ,x_to_pk4_value     	=>  p_copy_attachments_tbl(i).to_pk4_value
     			   ,x_to_pk5_value     	=>  p_copy_attachments_tbl(i).to_pk5_value
			   ,x_created_by		=>  l_user_id
			   ,x_last_update_login	=>  l_login_id
			   ,x_program_application_id => l_program_application_id
		         ,x_program_id  	=>  l_program_id
			   ,x_request_id		=>  l_request_id
                     );
   end loop;
EXCEPTION
   WHEN OTHERS THEN
/*
      fnd_message.set_name('OE', 'OE_COPY_ATTACHMENT_EXCEPTION');
      fnd_msg_pub.count_and_get(  p_count  => x_msg_count,
 			             p_data   => x_msg_data
			          );
      x_return_status := fnd_api.G_RET_STS_ERROR;
*/
      null;
END Copy_Attachments;


END oe_fnd_attachments_pub;

/
