--------------------------------------------------------
--  DDL for Package Body PVX_ATTACHMENT_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PVX_ATTACHMENT_INT" AS
/* $Header: pvxpathb.pls 120.1 2005/08/23 01:31:21 appldev noship $ */
-- Start of Comments
-- Package name     : PVX_ATTACHMENT_INT
-- Purpose          :
-- History          :
--				10/22/2002 hyang - 2633826, added validation in delete_attachments
-- NOTE             :
-- End of Comments



G_PKG_NAME    CONSTANT VARCHAR2(30) :='PVX_ATTACHMENT_INT';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'pvxatit.pls';

-- Add_Attachment
-- IN
--  p_seq_num		   - Attachment Seq Number.
--  p_category_id          - category of the attachment
--  p_document_description - desciption of the document
--  p_datatype_id	   - Datatype identifier
--  p_text	           - Text Input.
--  p_file_name	           - File name
--  p_url	           - URL from which the attachments is invoked from.
--			     This is required to set the back link.
--  p_function_name	   - Function name of the form
--  p_media_id	           - Document Content reference.

PROCEDURE Add_Attachment(
  p_api_version_number    IN  NUMBER
  ,p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit               IN  VARCHAR2 := FND_API.G_FALSE
  ,p_seq_num              IN  VARCHAR2
  ,p_category_id          IN  VARCHAR2
  ,p_document_description IN  VARCHAR2
  ,p_datatype_id          IN  VARCHAR2
  ,p_text		  IN  LONG
  ,p_file_name		  IN  VARCHAR2
  ,p_url	          IN  VARCHAR2
  ,p_function_name	  IN  VARCHAR2
  ,p_quote_header_id      IN  NUMBER
  ,p_media_id		  IN  NUMBER
  ,x_return_status        OUT  NOCOPY VARCHAR2
  ,x_msg_count            OUT  NOCOPY NUMBER
  ,x_msg_data             OUT  NOCOPY VARCHAR2
) IS
  l_api_name               CONSTANT VARCHAR2(30) := 'Add_Attachment';
  l_api_version            CONSTANT NUMBER       := 1.0;

  l_file_name     varchar2(200);

  CURSOR c_get_file_name (l_file_id number) IS
  SELECT file_name
  FROM FND_lobs
  WHERE fnd_lobs.file_id =l_file_id;


BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  Add_ATTACHMENT_PVT;

  IF NOT FND_API.Compatible_API_Call (l_api_version
        	    	    	      ,P_Api_Version_Number
   	       	                      ,l_api_name
		    	    	      ,G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


    OPEN c_get_file_name( p_media_id);
    FETCH c_get_file_name into l_file_name;

    IF c_get_file_name%notFOUND THEN
        l_file_name := p_file_name;
    END IF;
    close c_get_file_name;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
  END IF;



  -- Initialize API return status to error, i.e, its not duplicate
  x_return_status := FND_API.G_RET_STS_SUCCESS;


 FND_WEBATTCH.Add_Attachment(
       seq_num                  => p_seq_num
       ,category_id             => p_category_id
       ,document_description    => p_document_description
       ,datatype_id             => p_datatype_id
       ,text                    => p_text
       ,file_name               => l_file_name
       ,url                     => p_url
       ,function_name           => NULL
       ,entity_name             => 'PVATTACH'
       ,pk1_value               => TO_CHAR(p_quote_header_id)
       ,pk2_value               => NULL
       ,pk3_value               => NULL
       ,pk4_value               => NULL
       ,pk5_value               => NULL
       ,media_id                => p_media_id
       ,user_id                 => to_char(FND_GLOBAL.USER_ID)
     );

  -- End of API body.
  -- Standard check of p_commit.
    IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

  EXCEPTION
	  WHEN FND_API.G_EXC_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Add_Attachment;


PROCEDURE Delete_Attachments(
   p_api_version_number     IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2 := FND_API.g_false
   ,p_commit                IN  VARCHAR2 := FND_API.g_false
   ,p_quote_header_id       IN  NUMBER
   ,p_quote_attachment_ids  IN  JTF_VARCHAR2_TABLE_100
   ,x_return_status         OUT  NOCOPY VARCHAR2
   ,x_msg_count             OUT  NOCOPY NUMBER
   ,x_msg_data              OUT  NOCOPY VARCHAR2
)
IS
  l_api_name               CONSTANT VARCHAR2(30) := 'Delete_Attachments';
  l_api_version            CONSTANT NUMBER       := 1.0;

  l_media_id               NUMBER;
  l_document_id            NUMBER;
  l_entity_name            FND_ATTACHED_DOCUMENTS.ENTITY_NAME%TYPE;

/* 2633826 - hyang: added checking of p_quote_header_id */
  CURSOR c_get_media_id (l_attachment_id varchar2) IS
  SELECT a.media_id, b.document_id
  FROM FND_ATTACHED_DOCUMENTS b
       ,FND_DOCUMENTS_TL a
  WHERE a.document_id = b.document_id
  AND b.attached_document_id = l_attachment_id
  AND b.pk1_value = p_quote_header_id
  AND b.entity_name = 'PVATTACH';

  CURSOR c_get_document_id_rows (p_document_id number) IS
  SELECT a.document_id
  FROM FND_ATTACHED_DOCUMENTS a
  WHERE a.document_id = p_document_id
  AND a.pk1_value <> p_quote_header_id;
  --AND a.entity_name <> 'ASO_QUOTE_HEADERS_ALL';

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  DELETE_ATTACHMENTS_PVT;

  IF NOT FND_API.Compatible_API_Call (l_api_version
        	    	    	      ,P_Api_Version_Number
   	       	                      ,l_api_name
		    	    	      ,G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
  END IF;


  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add (
      'DELETE_ATTACHMENTS: quote_header_id ' || p_quote_header_id,
      1,
      'Y'
    );
  END IF;



  -- Initialize API return status to error, i.e, its not duplicate
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR i in 1..p_quote_attachment_ids.COUNT LOOP

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add ('DELETE_ATTACHMENTS: quote_attachment_id ' || p_quote_attachment_ids(i),1,'Y');
    END IF;

    -- Get the media_id for the attachment.
    OPEN c_get_media_id (p_quote_attachment_ids(i));
    FETCH c_get_media_id into l_media_id, l_document_id;

/*
 * 2633826 - hyang: added validation of quote_header_id.
 * Returns error if association is not found.
 */
    IF c_get_media_id%NOTFOUND
    THEN
      CLOSE c_get_media_id;

      IF fnd_msg_pub.check_msg_level (
           fnd_msg_pub.g_msg_lvl_error
         )
      THEN
        fnd_message.set_name (
          'ASO',
          'ASO_API_INVALID_ID'
        );
	   FND_MESSAGE.Set_Token(
		'COLUMN',
		'QUOTE_HEADER_ID', FALSE);
        fnd_msg_pub.ADD;
      END IF;

      RAISE fnd_api.g_exc_error;
    ELSE
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           aso_debug_pub.add ('DELETE_ATTACHMENTS: l_document_id : ' || l_document_id,1,'Y');
        END IF;
    END IF;

    CLOSE c_get_media_id;

    -- Call the procedure to delete the attachment and document.
    FND_ATTACHED_DOCUMENTS3_PKG.delete_row ( p_quote_attachment_ids(i),
                                           '6', 'N' );

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add ( 'DELETE_ATTACHMENTS: Check to see if the attachment was from an Opportunity...', 1, 'Y');
    END IF;

    OPEN c_get_document_id_rows( l_document_id);
    FETCH c_get_document_id_rows into l_document_id;

    IF c_get_document_id_rows%NOTFOUND
    THEN
      CLOSE c_get_document_id_rows;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add ( 'DELETE_ATTACHMENTS: Attachment is not from an Opportunity...', 1, 'Y');
      END IF;
      DELETE FROM fnd_lobs WHERE file_id = l_media_id;
    ELSE
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.add ( 'DELETE_ATTACHMENTS: Attachment is from an Opportunity...', 1, 'Y');
      END IF;
    END IF;

    IF c_get_document_id_rows%ISOPEN THEN
      CLOSE c_get_document_id_rows;
    END IF;

  END LOOP;

  -- End of API body.
  -- Standard check of p_commit.
  IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

  EXCEPTION
	  WHEN FND_API.G_EXC_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Delete_Attachments;

END PVX_ATTACHMENT_INT;

/
