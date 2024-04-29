--------------------------------------------------------
--  DDL for Package AMS_DMLIFT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DMLIFT_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvdlfs.pls 115.7 2002/12/09 11:52:15 choang ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DMLift_PVT
-- Purpose
--
-- History
-- 12-Feb-2001 choang   Added p_validation_mode to validate_lift.
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
--             Lift_rec_type
--   -------------------------------------------------------
--   Parameters:
--       LIFT_ID
--       LAST_UPDATE_DATE
--       LAST_UPDATED_BY
--       CREATION_DATE
--       CREATED_BY
--       LAST_UPDATE_LOGIN
--       OBJECT_VERSION_NUMBER
--       MODEL_ID
--       QUANTILE
--       LIFT
--       TARGETS
--       NON_TARGETS
--       TARGETS_CUMM
--       TARGET_DENSITY_CUMM
--       TARGET_DENSITY
--       MARGIN
--       ROI
--       TARGET_CONFIDENCE
--       NON_TARGET_CONFIDENCE
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
TYPE Lift_rec_type IS RECORD
(
       LIFT_ID                         NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       OBJECT_VERSION_NUMBER           NUMBER := FND_API.G_MISS_NUM,
       MODEL_ID                        NUMBER := FND_API.G_MISS_NUM,
       QUANTILE                        NUMBER := FND_API.G_MISS_NUM,
       LIFT                            NUMBER := FND_API.G_MISS_NUM,
       TARGETS                         NUMBER := FND_API.G_MISS_NUM,
       NON_TARGETS                     NUMBER := FND_API.G_MISS_NUM,
       TARGETS_CUMM                    NUMBER := FND_API.G_MISS_NUM,
       TARGET_DENSITY_CUMM             NUMBER := FND_API.G_MISS_NUM,
       TARGET_DENSITY                  NUMBER := FND_API.G_MISS_NUM,
       MARGIN                          NUMBER := FND_API.G_MISS_NUM,
       ROI                             NUMBER := FND_API.G_MISS_NUM,
       TARGET_CONFIDENCE               NUMBER := FND_API.G_MISS_NUM,
       NON_TARGET_CONFIDENCE           NUMBER := FND_API.G_MISS_NUM
);

g_miss_Lift_rec          Lift_rec_type;
TYPE  Lift_tbl_type      IS TABLE OF Lift_rec_type INDEX BY BINARY_INTEGER;
g_miss_Lift_tbl          Lift_tbl_type;


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

PROCEDURE Check_Lift_Items (
    P_Lift_rec     IN    Lift_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    );
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Dmlift
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
--       p_lift_rec            IN   lift_rec_type  Required
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

PROCEDURE Lock_Dmlift(
    p_api_version         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_lift_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Lift
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
--       p_lift_rec            IN   lift_rec_type  Required
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

PROCEDURE Create_Lift(
    p_api_version         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_lift_rec               IN   Lift_rec_type  := g_miss_Lift_rec,
    x_lift_id                   OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Lift
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
--       p_lift_rec            IN   lift_rec_type  Required
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

PROCEDURE Update_Lift(
    p_api_version         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_lift_rec               IN    lift_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Lift
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
--       p_LIFT_ID                IN   NUMBER
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

PROCEDURE Delete_Lift(
    p_api_version         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_lift_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
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

PROCEDURE Validate_Lift_rec(
    p_api_version         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_lift_rec               IN    lift_rec_type
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

PROCEDURE Validate_Lift(
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode   IN VARCHAR2,
    p_lift_rec          IN   Lift_rec_type,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2
    );
END AMS_DMLift_PVT;

 

/
