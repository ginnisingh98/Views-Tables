--------------------------------------------------------
--  DDL for Package AMS_SCORERESULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_SCORERESULT_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvdrss.pls 120.0 2005/06/01 23:32:12 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Scoreresult_PVT
-- Purpose
--
-- History
-- 24-Jan-2001 choang   Created.
-- 26-Jan-2001 choang   Added summarize results.
-- 13-Apr-2001 choang   Added generate_list
-- 21-May-2001 choang   Added overloaded generate_list
-- 10-Jul-2001 choang   Replaced tree_node with decile.
-- 07-Jan-2002 choang   Removed security group id
-- 19-Mar-2003 choang   Bug 2856138 - Added return status for OSOException in JSP.
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
--       decile
--       num_records
--       score
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
       score_result_id        NUMBER := FND_API.G_MISS_NUM,
       last_update_date       DATE := FND_API.G_MISS_DATE,
       last_updated_by        NUMBER := FND_API.G_MISS_NUM,
       creation_date          DATE := FND_API.G_MISS_DATE,
       created_by             NUMBER := FND_API.G_MISS_NUM,
       last_update_login      NUMBER := FND_API.G_MISS_NUM,
       object_version_number  NUMBER := FND_API.G_MISS_NUM,
       score_id               NUMBER := FND_API.G_MISS_NUM,
       decile                 VARCHAR2(30) := FND_API.G_MISS_CHAR,
       num_records            NUMBER := FND_API.G_MISS_NUM,
       score                  VARCHAR2(30) := FND_API.G_MISS_CHAR,
       confidence             NUMBER := FND_API.G_MISS_NUM
);

g_miss_scoreresult_rec          scoreresult_rec_type;
TYPE  scoreresult_tbl_type      IS TABLE OF scoreresult_rec_type INDEX BY BINARY_INTEGER;
g_miss_scoreresult_tbl          scoreresult_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Scoreresult
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
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
    p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,

    p_scoreresult_rec   IN   scoreresult_rec_type := g_miss_scoreresult_rec,
    x_score_result_id   OUT NOCOPY  NUMBER
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Scoreresult
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
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
    p_init_msg_list           IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                  IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level        IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,

    p_scoreresult_rec         IN    scoreresult_rec_type,
    x_object_version_number   OUT NOCOPY  NUMBER
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Scoreresult
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
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
    p_init_msg_list           IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                  IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level        IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    p_score_result_id         IN  NUMBER,
    p_object_version_number   IN   NUMBER
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Scoreresult
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
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

    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,

    p_score_result_id   IN  NUMBER,
    p_object_version    IN  NUMBER
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

PROCEDURE Validate_scoreresult(
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode   IN   VARCHAR2,
    p_scoreresult_rec   IN   scoreresult_rec_type,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2
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

PROCEDURE Check_scoreresult_Items (
    P_scoreresult_rec   IN    scoreresult_rec_type,
    p_validation_mode   IN    VARCHAR2,
    x_return_status     OUT NOCOPY   VARCHAR2
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

PROCEDURE Validate_scoreresult_rec(
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_scoreresult_rec   IN    scoreresult_rec_type
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Summarize_Results
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version     NUMBER     Required
--       p_init_msg_list   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit          VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_score_id        NUMBER
--
--   OUT
--       x_return_status   VARCHAR2
--       x_msg_count       NUMBER
--       x_msg_data        VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--   ==============================================================================
PROCEDURE summarize_results (
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_score_id          IN   NUMBER
);


--
-- Purpose
--    Generate a list based on the selected nodes from scoring run
--    results.
--
-- Parameters
--    p_score_id - scoring run identifier.
--    p_model_type - model type used for scoring.
--    p_tree_node_str - string concatenated from list of deciles chosen by
--       the user in the screen.
--    p_list_name - name of list to be generated.
--    p_owner_user_id - owner of the list.
--    x_list_header_id - new list header identifier.
--
PROCEDURE generate_list (
   p_score_id        IN NUMBER,
   p_model_type      IN VARCHAR2,
   p_tree_node_str   IN VARCHAR2,
   p_list_name       IN VARCHAR2 ,
   p_owner_user_id   IN NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   x_list_header_id  OUT NOCOPY VARCHAR2
);


--
-- Purpose
--    Generate a list based on the selected nodes from scoring run
--    results.
--
-- Parameters
--    p_score_id - scoring run identifier.
--    p_tree_node_str - string concatenated from list of deciles chosen by
--       the user in the screen.
--    p_list_name - name of list to be generated.
--    x_list_header_id - new list header identifier.
--
PROCEDURE generate_list (
   p_score_id        IN NUMBER,
   p_tree_node_str   IN VARCHAR2,
   p_list_name       IN VARCHAR2 ,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   x_list_header_id  OUT NOCOPY VARCHAR2
);

--
-- Purpose
--    Insert the optimal tareting percentile results for a given score id.
--
-- Parameters
--    p_score_id - scoring run identifier.
--
PROCEDURE insert_percentile_results (
    p_score_id          IN   NUMBER
);

END AMS_Scoreresult_PVT;

 

/
