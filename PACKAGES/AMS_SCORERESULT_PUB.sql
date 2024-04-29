--------------------------------------------------------
--  DDL for Package AMS_SCORERESULT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_SCORERESULT_PUB" AUTHID CURRENT_USER AS
/* $Header: amspdrss.pls 115.3 2002/01/07 18:52:12 pkm ship      $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Scoreresult_PUB
-- Purpose
--
-- History
-- 24-Jan-2001 choang   Created.
-- 12-Feb-2001 choang   Changed model_score_id to score_id.
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
--             scoreresult_rec_type
--   -------------------------------------------------------
--   Parameters:
--       score_result_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       score_id
--       tree_node
--       num_records
--       response
--       confidence
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
TYPE scoreresult_rec_type IS RECORD
(
   score_result_id         NUMBER := FND_API.G_MISS_NUM,
   last_update_date        DATE := FND_API.G_MISS_DATE,
   last_updated_by         NUMBER := FND_API.G_MISS_NUM,
   creation_date           DATE := FND_API.G_MISS_DATE,
   created_by              NUMBER := FND_API.G_MISS_NUM,
   last_update_login       NUMBER := FND_API.G_MISS_NUM,
   object_version_number   NUMBER := FND_API.G_MISS_NUM,
   score_id                NUMBER := FND_API.G_MISS_NUM,
   tree_node               VARCHAR2(30) := FND_API.G_MISS_CHAR,
   num_records             NUMBER := FND_API.G_MISS_NUM,
   response                VARCHAR2(30) := FND_API.G_MISS_CHAR,
   confidence              NUMBER := FND_API.G_MISS_NUM
);

g_miss_scoreresult_rec          scoreresult_rec_type;
TYPE  scoreresult_tbl_type      IS TABLE OF scoreresult_rec_type INDEX BY BINARY_INTEGER;
g_miss_scoreresult_tbl          scoreresult_tbl_type;

TYPE scoreresult_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      last_update_date   NUMBER := NULL
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Scoreresult
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_scoreresult_rec            IN   scoreresult_rec_type  Required
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

PROCEDURE Create_Scoreresult(
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN   VARCHAR2 := FND_API.G_FALSE,

    x_return_status     OUT  VARCHAR2,
    x_msg_count         OUT  NUMBER,
    x_msg_data          OUT  VARCHAR2,

    p_scoreresult_rec   IN   scoreresult_rec_type  := g_miss_scoreresult_rec,
    x_score_result_id   OUT  NUMBER
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Scoreresult
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_scoreresult_rec            IN   scoreresult_rec_type  Required
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

PROCEDURE Update_Scoreresult(
    p_api_version             IN   NUMBER,
    p_init_msg_list           IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN   VARCHAR2 := FND_API.G_FALSE,

    x_return_status           OUT  VARCHAR2,
    x_msg_count               OUT  NUMBER,
    x_msg_data                OUT  VARCHAR2,

    p_scoreresult_rec         IN    scoreresult_rec_type,
    x_object_version_number   OUT  NUMBER
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Scoreresult
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_SCORE_RESULT_ID                IN   NUMBER
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

PROCEDURE Delete_Scoreresult(
    p_api_version             IN   NUMBER,
    p_init_msg_list           IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN   VARCHAR2 := FND_API.G_FALSE,
    x_return_status           OUT  VARCHAR2,
    x_msg_count               OUT  NUMBER,
    x_msg_data                OUT  VARCHAR2,
    p_score_result_id         IN  NUMBER,
    p_object_version_number   IN   NUMBER
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Scoreresult
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_scoreresult_rec            IN   scoreresult_rec_type  Required
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

PROCEDURE Lock_Scoreresult(
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status     OUT  VARCHAR2,
    x_msg_count         OUT  NUMBER,
    x_msg_data          OUT  VARCHAR2,

    p_score_result_id   IN  NUMBER,
    p_object_version    IN  NUMBER
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Scoreresult
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_score_id        NUMBER
--       p_tree_node             NUMBER
--       p_num_records           NUMBER
--       p_score                 VARCHAR2
--       p_confidence            NUMBER
--       p_positive_score_prob   NUMBER
--
--   OUT
--       x_score_result_id       NUMBER
--       x_return_status         VARCHAR2
--
--   End of Comments
--   ==============================================================================
PROCEDURE Create_ScoreResult (
   p_score_id           IN NUMBER,
   p_tree_node          IN NUMBER,
   p_num_records        IN NUMBER,
   p_score              IN VARCHAR2,
   p_confidence         IN NUMBER,
   p_positive_score_prob   IN NUMBER,
   x_score_result_id    OUT NUMBER,
   x_return_status      OUT VARCHAR2
);


END AMS_Scoreresult_PUB;

 

/
