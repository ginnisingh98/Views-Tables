--------------------------------------------------------
--  DDL for Package Body AMS_ATTACHMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ATTACHMENT_PVT" as
/* $Header: amsvatcb.pls 115.15 2004/03/27 02:24:28 julou ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Attachment_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Attachment_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvatcb.pls';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Fnd_Attachment(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,

    p_Fnd_Attachment_rec         IN   fnd_attachment_rec_type,
    x_document_id                OUT NOCOPY NUMBER,
    x_attached_document_id       OUT NOCOPY NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Fnd_Attachment';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full     VARCHAR2(1);
   l_document_ID            NUMBER;
   l_media_ID            NUMBER;
   l_attached_document_ID   NUMBER;
   l_dummy       NUMBER;
   l_seq_num     NUMBER := 10;
   l_row_id     VARCHAR2(255);
   l_Fnd_Attachment_rec fnd_attachment_rec_type;
   l_create_Attached_Doc boolean := true;

   CURSOR c_attached_doc_id IS
      SELECT FND_ATTACHED_DOCUMENTS_S.nextval
      FROM dual;

   CURSOR c_attached_doc_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM FND_ATTACHED_DOCUMENTS
      WHERE document_id = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Fnd_Attachment_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message( 'Private API: Calling table handler fnd_documents_pkg.insert_row');
      END IF;

     l_media_id := p_Fnd_Attachment_rec.media_id;

      -- Invoke table handler
      fnd_documents_pkg.insert_row(
	 X_rowid => l_row_id,
	 X_document_id => x_document_id,
	 X_creation_date => sysdate,
	 X_created_by => FND_GLOBAL.USER_ID,
	 X_last_update_date => sysdate,
	 X_last_updated_by => FND_GLOBAL.USER_ID,
	 X_last_update_login => FND_GLOBAL.CONC_LOGIN_ID,
	 X_datatype_id => p_Fnd_Attachment_rec.datatype_id,
	 X_category_id => p_Fnd_Attachment_rec.category_id,
	 X_security_type => p_Fnd_Attachment_rec.security_type,
	 X_publish_flag => p_Fnd_Attachment_rec.publish_flag,
	 X_usage_type => p_Fnd_Attachment_rec.usage_type,
	 X_language => p_Fnd_Attachment_rec.language,
	 X_description =>p_Fnd_Attachment_rec.description,
	 X_file_name => p_Fnd_Attachment_rec.file_name,
	 X_media_id => l_media_id
	 );
      if (p_Fnd_Attachment_rec.datatype_id = 1) then

	 /* Verify if the media_id is not null */
	 if (p_Fnd_Attachment_rec.media_id is null) then
	     /* It means that a new text needs to be created, otherwise not */
	     /* Populate Short Text */
	     insert into
	     fnd_documents_short_text
	     (media_id,
	      short_text
	     )
	     values
	     (l_media_id,
	      p_Fnd_Attachment_rec.short_text
	     );
          else
	     /*
		Update fnd_documents_tl because FND_API inserts newly generated
		media_id into that table.
             */
	      update fnd_documents_tl
	      set media_id = p_Fnd_Attachment_rec.media_id
	      where document_id = x_document_id;

          end if;

      elsif (p_Fnd_Attachment_rec.datatype_id = 6) then /* File */
	 /* For File we have already generated a file id - the fnd_documents_pkg.insert_row
	    table handler has generated a fnd_lobs_s.nextval but that's not what shoule be the
	    reference to the FND_LOBS table - because the upload program has already generated a
	    sequence */
         /**
	 update fnd_documents_tl
	 set media_id = p_Fnd_Attachment_rec.media_id
	 where document_id = l_document_id;
	 **/
	 null;
      end if;

      if (p_Fnd_Attachment_rec.attachment_type is not null) then

	 if ((p_Fnd_Attachment_rec.attachment_type = 'WEB_TEXT') OR
	    (p_Fnd_Attachment_rec.attachment_type = 'WEB_IMAGE')) then

	    l_create_Attached_Doc := false;

         end if;

      end if;

      if (l_create_Attached_Doc) then

            /*
	      IF p_Fnd_Attachment_rec.attached_DOCUMENT_ID IS NULL THEN
            */
            LOOP
                l_dummy := NULL;
                OPEN c_attached_doc_id;
                FETCH c_attached_doc_id INTO l_attached_document_ID;
                CLOSE c_attached_doc_id;

                OPEN c_attached_doc_id_exists(l_attached_document_ID);
                FETCH c_attached_doc_id_exists INTO l_dummy;
                CLOSE c_attached_doc_id_exists;
                EXIT WHEN l_dummy IS NULL;
            END LOOP;

            l_Fnd_Attachment_rec.attached_document_id := l_attached_document_id;
            x_attached_document_id := l_attached_document_id;


	   /* Populate FND Attachments */
	   fnd_attached_documents_pkg.Insert_Row
	   (  x_rowid => l_row_id,
	      X_attached_document_id => l_attached_document_ID,
	      X_document_id => x_document_ID,
	      X_creation_date => sysdate,
	      X_created_by => FND_GLOBAL.USER_ID,
	      X_last_update_date => sysdate,
	      X_last_updated_by => FND_GLOBAL.USER_ID,
	      X_last_update_login => FND_GLOBAL.CONC_LOGIN_ID,
	      X_seq_num => l_seq_num,
	      X_entity_name => p_Fnd_Attachment_rec.entity_name,
	      x_column1 => null,
	      X_pk1_value => p_Fnd_Attachment_rec.pk1_value,
	      X_pk2_value => null,
	      X_pk3_value => null,
	      X_pk4_value => null,
	      X_pk5_value => null,
	      X_automatically_added_flag => p_Fnd_Attachment_rec.automatically_added_flag,
	      X_datatype_id => null,
	      X_category_id => null,
	      X_security_type => null,
	      X_publish_flag => null,
	      X_usage_type => p_Fnd_Attachment_rec.usage_type,
	      X_language => null,
	      X_media_id => l_media_id,
	      X_doc_attribute_Category => null,
	      X_doc_attribute1 => null,
	      X_doc_attribute2 => null,
	      X_doc_attribute3 => null,
	      X_doc_attribute4 => null,
	      X_doc_attribute5 => null,
	      X_doc_attribute6 => null,
	      X_doc_attribute7 => null,
	      X_doc_attribute8 => null,
	      X_doc_attribute9 => null,
	      X_doc_attribute10 => null,
	      X_doc_attribute11 => null,
	      X_doc_attribute12 => null,
	      X_doc_attribute13 => null,
	      X_doc_attribute14 => null,
	      X_doc_attribute15 => null
	   );
      end if;


      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Fnd_Attachment_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Fnd_Attachment_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Fnd_Attachment_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Create_Fnd_Attachment;

/**
    This procedure updates FND_DOCUMENTS,FND_DOCUMENTS_TL and FND_DOCUMENTS_SHORT_TEX    T. FND_ATTACHED_DOCUMENTS is not updated because it maintains the link between
    FND_DOCUMENTS and FND_DOCUMENT_ENTITIES. In Sales and Marketing the association cannot be updated.

**/

PROCEDURE Update_Fnd_Attachment(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,

    p_Fnd_Attachment_rec               IN    fnd_attachment_rec_type
    )

 IS
CURSOR c_get_Fnd_Documents(l_document_id NUMBER) IS
    SELECT *
    FROM  fnd_documents
    where document_id = l_document_id;

    -- Hint: Developer need to provide Where clause
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Fnd_Attachment';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_document_id number;
l_attached_document_ID    NUMBER;
l_ref_Fnd_Attachment_rec  c_get_fnd_Documents%ROWTYPE ;
l_tar_Fnd_Attachment_rec  AMS_attachment_PVT.fnd_attachment_rec_type := P_fnd_attachment_rec;
l_rowid  ROWID;
l_media_id Number;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Fnd_Attachment_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;

      OPEN c_get_Fnd_Documents( l_tar_fnd_attachment_rec.document_id);

      FETCH c_get_Fnd_Documents INTO l_ref_fnd_attachment_rec  ;

       If ( c_get_Fnd_Documents%NOTFOUND) THEN
		AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
					      p_token_name   => 'INFO',
					      p_token_value  => 'Fnd_Attachment') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;


       IF (p_Fnd_Attachment_rec.concur_last_update_date <> l_ref_fnd_attachment_rec.last_update_date) THEN
		AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RECORD_NOT_FOUND') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN
              AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Fnd_documents;

      -- Debug Message
      --IF (AMS_DEBUG_HIGH_ON) THEN AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');END IF;

      if (p_Fnd_Attachment_rec.datatype_id = 1) then
          if (p_Fnd_Attachment_rec.media_id is null) then
	      SELECT fnd_documents_short_text_s.nextval
	      INTO l_media_id
	      from dual;
          end if;
      end if;

      -- Invoke table handler(fnd_documents_pkg.update_row)
      fnd_documents_pkg.update_row(
	 X_document_id => p_Fnd_Attachment_rec.document_id,
	 X_last_update_date => sysdate,
	 X_last_updated_by => FND_GLOBAL.USER_ID,
	 X_last_update_login => FND_GLOBAL.CONC_LOGIN_ID,
	 X_datatype_id => p_Fnd_Attachment_rec.datatype_id,
	 X_category_id => p_Fnd_Attachment_rec.category_id,
	 X_security_type => p_Fnd_Attachment_rec.security_type,
	 X_security_id => null,
	 X_publish_flag => p_Fnd_Attachment_rec.publish_flag,
	 X_image_type => null,
	 X_storage_type => null,
	 X_usage_type => p_Fnd_Attachment_rec.usage_type,
	 X_start_date_active => null,
	 X_end_date_active => null,
	 X_language => p_Fnd_Attachment_rec.language,
	 X_description =>p_Fnd_Attachment_rec.description,
	 X_file_name => p_Fnd_Attachment_rec.file_name,
	 x_media_id => NVL(p_Fnd_Attachment_rec.media_id,l_media_id)
	 );

	 /* Bug# 2072584 */
	 /* Need to call the previous method call before actually updating
	    FND_DOCUMENTS_SHORT_TEXT in case of text - otherwise
	    the trigger was failing */

       -- Update fnd_documents_short_text based on the datatype_id
       if (p_Fnd_Attachment_rec.datatype_id = 1) then

	  if (p_Fnd_Attachment_rec.media_id is null) then
	     -- Create a record

	      /* Populate Short Text */
	      insert into
	      fnd_documents_short_text
	      (media_id,
	      short_text
	      )
	      values
	      (l_media_id,
	       p_Fnd_Attachment_rec.short_text
	      );

          else
	     update fnd_documents_short_text
	     set short_text =  p_Fnd_Attachment_rec.short_text
	     where media_id = p_Fnd_Attachment_rec.media_id;

             if SQL%NOTFOUND then

		AMS_Utility_PVT.Error_Message(
		   p_message_name => 'API_MISSING_UPDATE_TARGET',
		   p_token_name   => 'INFO',
		   p_token_value  => 'Fnd_Documents_Short_Text') ;
	        RAISE FND_API.G_EXC_ERROR;

	     end if;

          end if;


       end if;


      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Fnd_Attachment_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Fnd_Attachment_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Fnd_Attachment_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Update_Fnd_Attachment;


PROCEDURE Delete_Fnd_Attachment(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_document_id             IN  NUMBER,
    p_datatype_id             IN  NUMBER,
    p_delete_attachment_ref_flag IN VARCHAR2
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Fnd_Attachment';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_datatype_id number;
l_media_id number;
l_datatype_id number;
l_media_exists number;
l_use_fnd_api boolean;

cursor c_get_media_id(p_document_id number)
is
select media_id
from fnd_documents_tl
where document_id= p_document_id
and language = userenv('LANG');

/* Need to check if the file/text is referenced by any other document */
cursor c_check_media_id_reference(p_media_id number,p_document_id number,p_datatype_id number)
is
select 1
from dual
where exists
      (select 1
       from fnd_documents_tl tl
	    ,fnd_documents b
       where b.document_id=tl.document_id
       and tl.media_id = p_media_id
       and b.datatype_id = p_datatype_id
       and b.document_id <> p_document_id
      );

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Fnd_Attachment_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      IF ((p_datatype_id = 6) OR (p_datatype_id = 1)) THEN

	 l_use_fnd_api := false;

	 open c_get_media_id(p_document_id);
	 fetch c_get_media_id into l_media_id;
	 close c_get_media_id;

	 open c_check_media_id_reference(l_media_id,p_document_id,p_datatype_id);
	 fetch c_check_media_id_reference into l_media_exists;
	 close c_check_media_id_reference;

	 /*
	   For FILE/TEXT, checking if file_id/text_id exists in fnd_documents_tl,
	   if so not deleting the lob/text but otherwise delete the content as well
	 */

	 if (l_media_exists is null) then
	    /* Call FND API to delete everything */
            l_use_fnd_api := true;
	 end if;

         if (l_use_fnd_api) then

            FND_DOCUMENTS_PKG.Delete_Row(
               X_document_id => p_document_id,
	       X_datatype_id => p_datatype_id,
	       delete_ref_Flag => p_delete_attachment_ref_flag
	    );
         else

	    delete from fnd_documents
	    where document_id=p_document_id;

            delete from fnd_documents_tl
	    where document_id=p_document_id;

	    delete from fnd_attached_documents
	    where document_id=p_document_id;

	 end if;


      ELSE
	 /* For URL calling the FND API */
         FND_DOCUMENTS_PKG.Delete_Row(
               X_document_id => p_document_id,
	       X_datatype_id => p_datatype_id,
	       delete_ref_Flag => p_delete_attachment_ref_flag
	 );



      END IF;
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Fnd_Attachment_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Fnd_Attachment_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Fnd_Attachment_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Delete_Fnd_Attachment;

/**
 Need to check if I need this or Data Source can provide all the information */
/**
PROCEDURE Complete_Fnd_Document_Rec (
   p_Fnd_Attachment_rec IN fnd_attachment_rec_type,
   x_complete_rec OUT NOCOPY Fnd_Attachment_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM fnd_d
      WHERE prompt_id = p_Fnd_Attachment_rec.prompt_id;
   l_Fnd_Attachment_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_Fnd_Attachment_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_Fnd_Attachment_rec;
   CLOSE c_complete;

   -- prompt_id
   IF p_Fnd_Attachment_rec.prompt_id = FND_API.g_miss_num THEN
      x_complete_rec.prompt_id := l_Fnd_Attachment_rec.prompt_id;
   END IF;

   -- score
   IF p_Fnd_Attachment_rec.score = FND_API.g_miss_num THEN
      x_complete_rec.score := l_Fnd_Attachment_rec.score;
   END IF;

   -- icon_file_name
   IF p_Fnd_Attachment_rec.icon_file_name = FND_API.g_miss_char THEN
      x_complete_rec.icon_file_name := l_Fnd_Attachment_rec.icon_file_name;
   END IF;

   -- last_update_date
   IF p_Fnd_Attachment_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_Fnd_Attachment_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_Fnd_Attachment_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_Fnd_Attachment_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_Fnd_Attachment_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_Fnd_Attachment_rec.creation_date;
   END IF;

   -- created_by
   IF p_Fnd_Attachment_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_Fnd_Attachment_rec.created_by;
   END IF;

   -- last_update_login
   IF p_Fnd_Attachment_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_Fnd_Attachment_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_Fnd_Attachment_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_Fnd_Attachment_rec.object_version_number;
   END IF;

   -- security_group_id
   IF p_Fnd_Attachment_rec.security_group_id = FND_API.g_miss_num THEN
      x_complete_rec.security_group_id := l_Fnd_Attachment_rec.security_group_id;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Fnd_Attachment_Rec;
*/


END AMS_ATTACHMENT_PVT;

/
