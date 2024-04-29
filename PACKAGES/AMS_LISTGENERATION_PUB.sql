--------------------------------------------------------
--  DDL for Package AMS_LISTGENERATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LISTGENERATION_PUB" AUTHID CURRENT_USER AS
/* $Header: amsplgns.pls 115.7 2004/04/26 23:58:47 sranka ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_ListGeneration_PUB
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Generate_List
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN     NUMBER   Optional Default =FND_API.G_VALID_LEVEL_FULL,

--       p_list_header_id            IN   ListHeaderId  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   End of Comments
--   ==============================================================================
--

PROCEDURE Generate_List
( p_api_version                IN     NUMBER,
  p_init_msg_list              IN     VARCHAR2   := FND_API.G_TRUE,
  p_commit                     IN     VARCHAR2   := FND_API.G_FALSE,
  p_validation_level           IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_header_id             IN     NUMBER   ,
  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2
 );


PROCEDURE create_list_from_query
( p_api_version            IN    NUMBER,
  p_init_msg_list          IN    VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN    VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_name              in    varchar2,
  p_list_type              in    varchar2,
  p_owner_user_id          in    number,
  p_list_header_id         in    number,
  p_sql_string_tbl         in    AMS_List_Query_PVT.sql_string_tbl      ,
  p_primary_key            in    varchar2,
  p_source_object_name     in    varchar2,
  p_master_type            in    varchar2,
  x_return_status          OUT NOCOPY   VARCHAR2,
  x_msg_count              OUT NOCOPY   NUMBER,
  x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;

PROCEDURE create_list_from_query
( p_api_version            IN    NUMBER,
  p_init_msg_list          IN    VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN    VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_name              in    varchar2,
  p_list_type              in    varchar2,
  p_owner_user_id          in    number,
  p_list_header_id         in    number,
  p_sql_string_tbl         in    AMS_List_Query_PVT.sql_string_tbl      ,
  p_primary_key            in    varchar2,
  p_source_object_name     in    varchar2,
  p_master_type            in    varchar2,
  p_query_param            in    AMS_List_Query_PVT.sql_string_tbl      ,
  x_return_status          OUT NOCOPY   VARCHAR2,
  x_msg_count              OUT NOCOPY   NUMBER,
  x_msg_data               OUT NOCOPY   VARCHAR2
  ) ;
END AMS_ListGeneration_PUB;

 

/
