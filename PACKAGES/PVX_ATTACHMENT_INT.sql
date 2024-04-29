--------------------------------------------------------
--  DDL for Package PVX_ATTACHMENT_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PVX_ATTACHMENT_INT" AUTHID CURRENT_USER AS
/* $Header: pvxpaths.pls 120.1 2005/08/23 01:34:58 appldev noship $ */
-- Start of Comments
-- Package name     : PVX_ATTACHMENT_INT
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
  ,x_return_status        OUT  NOCOPY VARCHAR2
  ,x_msg_count            OUT  NOCOPY NUMBER
  ,x_msg_data             OUT  NOCOPY VARCHAR2
);



PROCEDURE delete_attachments(
   p_api_version_number     IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2 := FND_API.g_false
   ,p_commit                IN  VARCHAR2 := FND_API.g_false
   ,p_quote_header_id       IN  NUMBER
   ,p_quote_attachment_ids  IN  JTF_VARCHAR2_TABLE_100
   ,x_return_status         OUT  NOCOPY VARCHAR2
   ,x_msg_count             OUT  NOCOPY NUMBER
   ,x_msg_data              OUT  NOCOPY VARCHAR2
);


END PVX_ATTACHMENT_INT;

 

/
