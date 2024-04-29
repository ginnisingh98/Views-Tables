--------------------------------------------------------
--  DDL for Package AMS_LIST_QUERY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_QUERY_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvliqs.pls 115.10 2004/04/21 18:50:46 sranka ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_List_Query_PVT
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
--             list_query_rec_type
--   -------------------------------------------------------
--   Parameters:
--       list_query_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       name
--       type
--       enabled_flag
--       primary_key
--       source_object_name
--       public_flag
--       org_id
--       comments
--       act_list_query_used_by_id
--       arc_act_list_query_used_by
--       sql_string
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
TYPE list_query_rec_type IS RECORD
(
       list_query_id                   NUMBER := FND_API.G_MISS_NUM,
       last_update_date                DATE := FND_API.G_MISS_DATE,
       last_updated_by                 NUMBER := FND_API.G_MISS_NUM,
       creation_date                   DATE := FND_API.G_MISS_DATE,
       created_by                      NUMBER := FND_API.G_MISS_NUM,
       last_update_login               NUMBER := FND_API.G_MISS_NUM,
       object_version_number           NUMBER := FND_API.G_MISS_NUM,
       name                            VARCHAR2(240) := FND_API.G_MISS_CHAR,
       type                            VARCHAR2(30) := FND_API.G_MISS_CHAR,
       enabled_flag                    VARCHAR2(1) := FND_API.G_MISS_CHAR,
       primary_key                     VARCHAR2(60) := FND_API.G_MISS_CHAR,
       source_object_name              VARCHAR2(60) := FND_API.G_MISS_CHAR,
       seed_flag                       varchar2(1)  := FND_API.G_MISS_CHAR,
       public_flag                     VARCHAR2(1) := FND_API.G_MISS_CHAR,
       org_id                          NUMBER := FND_API.G_MISS_NUM,
       comments                        VARCHAR2(900) := FND_API.G_MISS_CHAR,
       act_list_query_used_by_id       NUMBER := FND_API.G_MISS_NUM,
       arc_act_list_query_used_by      VARCHAR2(30) := FND_API.G_MISS_CHAR,
       sql_string                      VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       parent_list_query_id            number  := FND_API.G_MISS_NUM,
       sequence_order                  number  := FND_API.G_MISS_NUM
);

TYPE sql_string_tbl      IS TABLE OF VARCHAR2(4000) INDEX  BY BINARY_INTEGER;
g_miss_sql_string_tbl          sql_string_tbl;

TYPE list_query_rec_type_tbl IS RECORD
(
       list_query_id                   NUMBER := FND_API.G_MISS_NUM,
       last_update_date                DATE := FND_API.G_MISS_DATE,
       last_updated_by                 NUMBER := FND_API.G_MISS_NUM,
       creation_date                   DATE := FND_API.G_MISS_DATE,
       created_by                      NUMBER := FND_API.G_MISS_NUM,
       last_update_login               NUMBER := FND_API.G_MISS_NUM,
       object_version_number           NUMBER := FND_API.G_MISS_NUM,
       name                            VARCHAR2(240) := FND_API.G_MISS_CHAR,
       type                            VARCHAR2(30) := FND_API.G_MISS_CHAR,
       enabled_flag                    VARCHAR2(1) := FND_API.G_MISS_CHAR,
       primary_key                     VARCHAR2(60) := FND_API.G_MISS_CHAR,
       source_object_name              VARCHAR2(60) := FND_API.G_MISS_CHAR,
       seed_flag                       varchar2(1)  := FND_API.G_MISS_CHAR,
       public_flag                     VARCHAR2(1) := FND_API.G_MISS_CHAR,
       org_id                          NUMBER := FND_API.G_MISS_NUM,
       comments                        VARCHAR2(900) := FND_API.G_MISS_CHAR,
       act_list_query_used_by_id       NUMBER := FND_API.G_MISS_NUM,
       arc_act_list_query_used_by      VARCHAR2(30) := FND_API.G_MISS_CHAR,
      -- t_sql_string_tbl                sql_string_tbl := g_miss_sql_string_tbl,
       parent_list_query_id            number  := FND_API.G_MISS_NUM,
       sequence_order                  number  := FND_API.G_MISS_NUM
);

 -- TYPE  list_query_tbl_type      IS TABLE OF list_query_rec_type INDEX BY BINARY_INTEGER;

g_miss_list_query_rec          list_query_rec_type;
--TYPE  list_query_tbl_type      IS TABLE OF list_query_rec_type INDEX BY BINARY_INTEGER;
--g_miss_list_query_tbl          list_query_tbl_type;

TYPE list_query_id_Tbl_Type IS TABLE OF number
    INDEX BY BINARY_INTEGER;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_List_Query
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_list_query_rec            IN   list_query_rec_type  Required
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

PROCEDURE Create_List_Query(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level      IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_query_rec         IN   list_query_rec_type  := g_miss_list_query_rec,
    x_list_query_id              OUT NOCOPY  NUMBER
     );

PROCEDURE Create_List_Query(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level      IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_query_rec_tbl     IN   list_query_rec_type_tbl  ,--:= g_miss_list_query_tbl          ,
    p_sql_string_tbl       in sql_string_tbl ,
    x_parent_list_query_id              OUT NOCOPY  NUMBER
     );

PROCEDURE Create_List_Query(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level      IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_query_rec_tbl     IN   list_query_rec_type_tbl  ,--:= g_miss_list_query_tbl          ,
    p_sql_string_tbl      in sql_string_tbl ,
    p_query_param          in sql_string_tbl ,
    x_parent_list_query_id              OUT NOCOPY  NUMBER
     );


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_List_Query
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_list_query_rec            IN   list_query_rec_type  Required
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

PROCEDURE Update_List_Query(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_query_rec               IN    list_query_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

PROCEDURE Update_List_Query(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_query_rec_tbl               IN    list_query_rec_type_tbl,
    p_sql_string_tbl       in sql_string_tbl ,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_List_Query
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_LIST_QUERY_ID                IN   NUMBER
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

PROCEDURE Delete_List_Query(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_query_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

PROCEDURE Delete_parent_List_Query(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_parent_list_query_id       IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_List_Query
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_list_query_rec            IN   list_query_rec_type  Required
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

PROCEDURE Lock_List_Query(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_query_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );


-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. We can also validate table instead of record. There will be an option for user to choose.
-- End of Comments

PROCEDURE Validate_list_query(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_list_query_rec               IN   list_query_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Validate the unique keys, lookups here
-- End of Comments

PROCEDURE Check_list_query_Items (
    P_list_query_rec     IN    list_query_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    );

-- Start of Comments
--
-- Record level validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Developer can manually added inter-field level validation.
-- End of Comments

PROCEDURE Validate_list_query_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_list_query_rec               IN    list_query_rec_type
    );


-- Start of Comments
---------------------------------------------------------------------
-- PROCEDURE
--    Copy_List_Queries
--
-- PURPOSE
--    Take list header id of the list to copy from
--    last update date, last updated by, creation date and
--    created by are defaulted
--    copy the entries pertaining to a particular list in
--     AMS_LIST_QUERIES_ALL into a new set and create new AMS_LIST_SELECT_ACTIONS
--    associate the new list header id with copied parent list query id
--
-- PARAMETERS
--
--
-- End Of Comments



PROCEDURE Copy_List_Queries
( p_api_version              IN     NUMBER,
  p_init_msg_list            IN     VARCHAR2  := FND_API.G_FALSE,
  p_commit                   IN     VARCHAR2  := FND_API.G_FALSE,
  p_validation_level         IN     NUMBER    := FND_API.g_valid_level_full,
  p_source_listheader_id     IN     NUMBER,
  p_new_listheader_id        IN     NUMBER,
  p_new_listheader_name      IN     VARCHAR2,

  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2
);

END AMS_List_Query_PVT;

 

/
