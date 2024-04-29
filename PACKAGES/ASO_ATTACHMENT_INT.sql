--------------------------------------------------------
--  DDL for Package ASO_ATTACHMENT_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_ATTACHMENT_INT" AUTHID CURRENT_USER AS
/* $Header: asoiatms.pls 120.1 2005/06/29 12:32:35 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_ATTACHMENT_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

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
  ,p_function_name	  IN  VARCHAR2 := null
  ,p_quote_header_id      IN  NUMBER
  ,p_media_id		  IN  NUMBER
  ,x_return_status        OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ,x_msg_count            OUT NOCOPY /* file.sql.39 change */  NUMBER
  ,x_msg_data             OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);


PROCEDURE copy_attachments_to_order(
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.g_false
   ,p_commit              IN  VARCHAR2 := FND_API.g_false
   ,p_quote_header_id     IN  number
   ,p_order_id            IN  number
   ,p_order_line_tbl      IN  ASO_ORDER_INT.Order_Line_Tbl_Type
   ,x_return_status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2
   ,x_msg_count           OUT NOCOPY /* file.sql.39 change */  NUMBER
   ,x_msg_data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);


PROCEDURE delete_attachments(
   p_api_version_number     IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2 := FND_API.g_false
   ,p_commit                IN  VARCHAR2 := FND_API.g_false
   ,p_quote_header_id       IN  NUMBER
   ,p_quote_attachment_ids  IN  JTF_VARCHAR2_TABLE_100
   ,x_return_status         OUT NOCOPY /* file.sql.39 change */  VARCHAR2
   ,x_msg_count             OUT NOCOPY /* file.sql.39 change */  NUMBER
   ,x_msg_data              OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);

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
);

END ASO_ATTACHMENT_INT;

 

/
