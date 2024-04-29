--------------------------------------------------------
--  DDL for Package AMS_DMPERFORMANCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DMPERFORMANCE_PUB" AUTHID CURRENT_USER AS
/* $Header: amspdpfs.pls 115.2 2002/01/07 18:52:09 pkm ship      $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DMPerformance_PUB
-- Purpose
--
-- History
-- 22-Jan-2001 choang   Added overload procedure create_performance for
--                      ODM Accelerator integration.
-- 07-Jan-2002 choang   Removed security group id
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
--             performance_rec_type
--   -------------------------------------------------------
--   Parameters:
--       performance_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       predicted_value
--       actual_value
--       evaluated_records
--       total_records_predicted
--       model_id
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
TYPE performance_rec_type IS RECORD
(
       performance_id                  NUMBER := FND_API.G_MISS_NUM,
       last_update_date                DATE := FND_API.G_MISS_DATE,
       last_updated_by                 NUMBER := FND_API.G_MISS_NUM,
       creation_date                   DATE := FND_API.G_MISS_DATE,
       created_by                      NUMBER := FND_API.G_MISS_NUM,
       last_update_login               NUMBER := FND_API.G_MISS_NUM,
       object_version_number           NUMBER := FND_API.G_MISS_NUM,
       predicted_value                 VARCHAR2(100) := FND_API.G_MISS_CHAR,
       actual_value                    VARCHAR2(100) := FND_API.G_MISS_CHAR,
       evaluated_records               NUMBER := FND_API.G_MISS_NUM,
       total_records_predicted         NUMBER := FND_API.G_MISS_NUM,
       model_id                        NUMBER := FND_API.G_MISS_NUM
);

g_miss_performance_rec          performance_rec_type;
TYPE  performance_tbl_type      IS TABLE OF performance_rec_type INDEX BY BINARY_INTEGER;
g_miss_performance_tbl          performance_tbl_type;

TYPE performance_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      last_update_date   NUMBER := NULL
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Performance
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
--       p_performance_rec            IN   performance_rec_type  Required
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

PROCEDURE Create_Performance(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2,

    p_performance_rec               IN   performance_rec_type  := g_miss_performance_rec,
    x_performance_id                   OUT  NUMBER
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Performance
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
--       p_performance_rec            IN   performance_rec_type  Required
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

PROCEDURE Update_Performance(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2,

    p_performance_rec               IN    performance_rec_type,
    x_object_version_number      OUT  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Performance
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
--       p_PERFORMANCE_ID                IN   NUMBER
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

PROCEDURE Delete_Performance(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2,
    p_performance_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Performance
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
--       p_performance_rec            IN   performance_rec_type  Required
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

PROCEDURE Lock_Performance(
    p_api_version_number   IN   NUMBER,
    p_init_msg_list        IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status        OUT  VARCHAR2,
    x_msg_count            OUT  NUMBER,
    x_msg_data             OUT  VARCHAR2,

    p_performance_id       IN  NUMBER,
    p_object_version       IN  NUMBER
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Performance
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_model_id           IN NUMBER
--       p_predicted_value    IN VARCHAR2
--       p_actual_value       IN VARCHAR2
--       p_evaluated_records  IN NUMBER
--       p_total_records_predicted  IN NUMBER
--
--   OUT
--       x_performance_id     OUT NUMBER
--       x_return_status      OUT VARCHAR2
--
--   End of Comments
--   ==============================================================================
PROCEDURE Create_Performance (
   p_model_id           IN NUMBER,
   p_predicted_value    IN VARCHAR2,
   p_actual_value       IN VARCHAR2,
   p_evaluated_records  IN NUMBER,
   p_total_records_predicted  IN NUMBER,
   x_performance_id     OUT NUMBER,
   x_return_status      OUT VARCHAR2
);


END AMS_DMPerformance_PUB;

 

/
