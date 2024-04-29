--------------------------------------------------------
--  DDL for Package AMS_LIST_SRC_FIELD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_SRC_FIELD_PUB" AUTHID CURRENT_USER AS
/* $Header: amsplsfs.pls 115.5 2002/11/22 08:54:14 jieli ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_List_Src_Field_PUB
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
--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             list_src_field_rec_type
--   -------------------------------------------------------
--   Parameters:
--       list_source_field_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       de_list_source_type_code
--       list_source_type_id
--       field_table_name
--       field_column_name
--       source_column_name
--       source_column_meaning
--       enabled_flag
--       start_position
--       end_position
--       security_group_id
--
--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

--===================================================================
TYPE list_src_field_rec_type IS RECORD
(
       list_source_field_id            NUMBER := FND_API.G_MISS_NUM,
       last_update_date                DATE := FND_API.G_MISS_DATE,
       last_updated_by                 NUMBER := FND_API.G_MISS_NUM,
       creation_date                   DATE := FND_API.G_MISS_DATE,
       created_by                      NUMBER := FND_API.G_MISS_NUM,
       last_update_login               NUMBER := FND_API.G_MISS_NUM,
       object_version_number           NUMBER := FND_API.G_MISS_NUM,
       de_list_source_type_code        VARCHAR2(30) := FND_API.G_MISS_CHAR,
       list_source_type_id             NUMBER := FND_API.G_MISS_NUM,
       field_table_name                VARCHAR2(30) := FND_API.G_MISS_CHAR,
       field_column_name               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       source_column_name              VARCHAR2(120) := FND_API.G_MISS_CHAR,
       source_column_meaning           VARCHAR2(120) := FND_API.G_MISS_CHAR,
       enabled_flag                    VARCHAR2(1) := FND_API.G_MISS_CHAR,
       start_position                  NUMBER := FND_API.G_MISS_NUM,
       end_position                    NUMBER := FND_API.G_MISS_NUM,
       security_group_id               NUMBER := FND_API.G_MISS_NUM,
       analytics_flag                  VARCHAR2(1) := FND_API.G_MISS_CHAR,
       auto_binning_flag               VARCHAR2(1) := FND_API.G_MISS_CHAR,
       no_of_buckets                   NUMBER := FND_API.G_MISS_NUM

);

g_miss_list_src_field_rec          list_src_field_rec_type;
TYPE  list_src_field_tbl_type      IS TABLE OF list_src_field_rec_type INDEX BY BINARY_INTEGER;
g_miss_list_src_field_tbl          list_src_field_tbl_type;

TYPE list_src_field_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      last_update_date   NUMBER := NULL
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_List_Src_Field
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
--       p_list_src_field_rec            IN   list_src_field_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Create_List_Src_Field(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_list_src_field_rec               IN   list_src_field_rec_type  := g_miss_list_src_field_rec,
    x_list_source_field_id                   OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_List_Src_Field
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
--       p_list_src_field_rec            IN   list_src_field_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Update_List_Src_Field(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_list_src_field_rec               IN    list_src_field_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_List_Src_Field
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
--       p_LIST_SOURCE_FIELD_ID                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Delete_List_Src_Field(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_source_field_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_List_Src_Field
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
--       p_list_src_field_rec            IN   list_src_field_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Lock_List_Src_Field(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_list_source_field_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );

END AMS_List_Src_Field_PUB;

 

/
