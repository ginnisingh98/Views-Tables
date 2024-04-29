--------------------------------------------------------
--  DDL for Package Body ASO_ATTACHMENT_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_ATTACHMENT_INT" AS
/* $Header: asoiatmb.pls 120.1 2005/06/29 12:32:31 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_ATTACHMENT_INT
-- Purpose          :
-- History          :
--				10/22/2002 hyang - 2633826, added validation in delete_attachments
-- NOTE             :
-- End of Comments


G_PKG_NAME    CONSTANT VARCHAR2(30) :='ASO_ATTACHMENT_INT';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'asoiatmb.pls';

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
  ,x_return_status        OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ,x_msg_count            OUT NOCOPY /* file.sql.39 change */  NUMBER
  ,x_msg_data             OUT NOCOPY /* file.sql.39 change */  VARCHAR2
) IS
  l_api_name               CONSTANT VARCHAR2(30) := 'Add_Attachment';
  l_api_version            CONSTANT NUMBER       := 1.0;
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
       ,file_name               => p_file_name
       ,url                     => p_url
       ,function_name           => NULL
       ,entity_name             => 'ASO_QUOTE_HEADERS_ALL'
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


PROCEDURE Copy_Attachments_To_Order(
    p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.g_false
   ,p_commit              IN  VARCHAR2 := FND_API.g_false
   ,p_quote_header_id     IN  NUMBER
   ,p_order_id	          IN  NUMBER
   ,p_order_line_tbl      IN  ASO_ORDER_INT.Order_Line_Tbl_Type
   ,x_return_status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2
   ,x_msg_count           OUT NOCOPY /* file.sql.39 change */  NUMBER
   ,x_msg_data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
    l_api_name              CONSTANT VARCHAR2(30) := 'Copy_Attachments_To_Order';
    l_api_version           CONSTANT NUMBER       := 1.0;

    CURSOR c_quote_line (l_shipment_id NUMBER) IS
    SELECT quote_line_id
      FROM aso_shipments
     WHERE shipment_id = l_shipment_id;

    l_quote_line_id         NUMBER;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT  COPY_ATTACHMENTS_TO_ORDER_PVT;
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

    -- Initialize API return status to error, i.e, its not duplicate
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('COPY_ATTACHMENTS_TO_ORDER: quote_header_id: ' || p_quote_header_id, 1, 'N');
      aso_debug_pub.add('COPY_ATTACHMENTS_TO_ORDER: order_id:        ' || p_order_id, 1, 'N');
    END IF;

    ASO_ATTACHMENT_INT.Copy_Attachments(
        p_api_version 		=> l_api_version,
        p_init_msg_list         => FND_API.G_FALSE,
        p_commit                => FND_API.G_FALSE,
        p_old_object_code       => 'ASO_QUOTE_HEADERS_ALL',
        p_new_object_code       => 'OE_ORDER_HEADERS',
        p_old_object_id         => p_quote_header_id,
        p_new_object_id         => p_order_id,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data
     );

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('COPY_ATTACHMENTS_TO_ORDER: line tbl count:  ' || p_order_line_tbl.count, 1, 'N');
    END IF;

    FOR i IN 1..p_order_line_tbl.count LOOP

        OPEN c_quote_line (p_Order_Line_Tbl(i).QUOTE_SHIPMENT_LINE_ID);
        FETCH c_quote_line into l_quote_line_id;
        CLOSE c_quote_line;

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('COPY_ATTACHMENTS_TO_ORDER: quote_line_id:   ' || l_quote_line_id, 1, 'N');
          aso_debug_pub.add('COPY_ATTACHMENTS_TO_ORDER: order_line_id:   ' || p_order_line_tbl(i).ORDER_LINE_ID, 1, 'N');
        END IF;

    	ASO_ATTACHMENT_INT.Copy_Attachments(
       		p_api_version 		=> l_api_version,
        	p_init_msg_list         => FND_API.G_FALSE,
        	p_commit                => FND_API.G_FALSE,
        	p_old_object_code       => 'ASO_QUOTE_LINES_ALL',
        	p_new_object_code       => 'OE_ORDER_LINES',
        	p_old_object_id         => l_quote_line_id,
        	p_new_object_id         => p_order_line_tbl(i).ORDER_LINE_ID,
        	x_return_status         => x_return_status,
        	x_msg_count             => x_msg_count,
        	x_msg_data              => x_msg_data
     	);

       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END LOOP;

    -- Standard check of p_commit.
    IF FND_API.to_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_count          =>   x_msg_count,
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

END Copy_Attachments_To_Order;



PROCEDURE Delete_Attachments(
   p_api_version_number     IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2 := FND_API.g_false
   ,p_commit                IN  VARCHAR2 := FND_API.g_false
   ,p_quote_header_id       IN  NUMBER
   ,p_quote_attachment_ids  IN  JTF_VARCHAR2_TABLE_100
   ,x_return_status         OUT NOCOPY /* file.sql.39 change */  VARCHAR2
   ,x_msg_count             OUT NOCOPY /* file.sql.39 change */  NUMBER
   ,x_msg_data              OUT NOCOPY /* file.sql.39 change */  VARCHAR2
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
  AND b.entity_name = 'ASO_QUOTE_HEADERS_ALL';

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

    /*******
    FND_WEBATTCH.DeleteAttachment(
        attached_document_id    => p_quote_attachment_ids(i),
        function_name           => NULL,
        entity_name             => 'ASO_QUOTE_HEADERS_ALL',
        pk1_value               => p_quote_header_id,
        pk2_value               => NULL,
        pk3_value               => NULL,
        pk4_value               => NULL,
        pk5_value               => NULL,
        from_url                => NULL,
        query_only              => 'N'
    );
    ********/
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


/*
 * The Purpose of this procedure is to build a wrapper around fnd attachment apis
 * and use this api to copy attachments in all aso apis. So that if there is a change
 * to fnd apis then its in one place instead of calling the fnd apis directly in aso apis
 * in multiple places. Thus we have changed the parameter to have come name called object.
 *
 * An Object Code refers to the context from which the attachments are to be copied.
 * For instance if this procedure is called from opportunity to quote then ,
 * Old Object Code = 'AS_OPPORTUNITY_ATTCH'
 * New Object Code = 'ASO_QUOTE_HEADERS_ALL'.
 * This value depends on the calling procedure.
 *
 * An object ID can refer to Quote Header Id or Opportunity ID or Quote Line ID or
 * an Order Header Id or Order Line ID depending on the context and from which aso api
 * this procedure is being called.
 *
 * A object can have multiple attachment documents attached to it.  When a
 * new version of object is created from an existing object, all the attachment
 * documents attached to the existing object should be attached to the new
 * version of object, too.
 *
 * This procedure is called when a new version of object is created from an
 * existing object.
 *
 * param p_old_object_code: existing object Code.
 * param p_new_object_code: object code new version.
 * param p_old_object_id: existing object ID.
 * param p_new_object_id: object ID of the new version.
 */
PROCEDURE Copy_Attachments
(
   p_api_version         IN  NUMBER                     ,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_TRUE ,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_old_object_code     IN  VARCHAR2                   ,
   p_new_object_code     IN  VARCHAR2                   ,
   p_old_object_id       IN  NUMBER                     ,
   p_new_object_id       IN  NUMBER                     ,
   x_return_status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2            ,
   x_msg_count           OUT NOCOPY /* file.sql.39 change */  NUMBER              ,
   x_msg_data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS

   G_USER_ID     NUMBER                := FND_GLOBAL.USER_ID;

   L_API_NAME    CONSTANT VARCHAR2(30) := 'Copy_Attachments';
   L_API_VERSION CONSTANT NUMBER       := 1.0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Copy_Attachments_Pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(L_API_VERSION,
                                      p_api_version,
                                      L_API_NAME   ,
                                      G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_Msg_Pub.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('COPY_ATTACHMENTS: old_object_id: ' || p_old_object_id, 1, 'N');
      aso_debug_pub.add('COPY_ATTACHMENTS: new_object_id: ' || p_new_object_id, 1, 'N');
    END IF;

    FND_ATTACHED_DOCUMENTS2_PKG.Copy_Attachments(
        x_from_entity_name          => p_old_object_code,
        x_from_pk1_value            => to_char(p_old_object_id),
        x_to_entity_name            => p_new_object_code,
        x_to_pk1_value              => to_char(p_new_object_id),
        x_automatically_added_flag  => null,
        x_created_by                => G_USER_ID);

   -- Standard check of p_commit.
   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data);

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

END Copy_Attachments;


END ASO_ATTACHMENT_INT;

/
