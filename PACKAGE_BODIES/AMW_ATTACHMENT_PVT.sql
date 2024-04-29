--------------------------------------------------------
--  DDL for Package Body AMW_ATTACHMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_ATTACHMENT_PVT" as
/* $Header: amwvatcb.pls 120.0 2005/05/31 18:34:48 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_Attachment_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_Attachment_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'AMWvatcb.pls';

AMW_DEBUG_HIGH_ON boolean   := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMW_DEBUG_LOW_ON boolean    := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMW_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

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
      IF (AMW_DEBUG_HIGH_ON) THEN
            AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
 AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF (AMW_DEBUG_HIGH_ON) THEN
            AMW_UTILITY_PVT.debug_message( 'Private API: Calling table handler fnd_documents_pkg.insert_row');
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
      IF (AMW_DEBUG_HIGH_ON) THEN
            AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


EXCEPTION

   WHEN AMW_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_API_RESOURCE_LOCKED');

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
END AMW_Attachment_PVT;

/
