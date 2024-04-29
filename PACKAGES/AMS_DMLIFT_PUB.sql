--------------------------------------------------------
--  DDL for Package AMS_DMLIFT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DMLIFT_PUB" AUTHID CURRENT_USER AS
/* $Header: amspdlfs.pls 115.2 2002/01/07 18:52:04 pkm ship      $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Dmlift_PUB
-- Purpose
--
-- History
-- 21-Jan-2001 choang   Added overload procedure create_lift for
--                      ODM Accelerator integration.
-- 07-Jan-2002 choang   removed security_group_id
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

TYPE Lift_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      LAST_UPDATE_DATE   NUMBER := NULL
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Dmlift
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
    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2,

    p_lift_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Lift
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

    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2,

    p_lift_rec               IN   Lift_rec_type  := g_miss_Lift_rec,
    x_lift_id                   OUT  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Lift
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

    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2,

    p_lift_rec               IN    lift_rec_type,
    x_object_version_number      OUT  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Lift
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
    x_return_status              OUT  VARCHAR2,
    x_msg_count                  OUT  NUMBER,
    x_msg_data                   OUT  VARCHAR2,
    p_lift_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Lift
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_model_id        IN NUMBER
--       p_quantile        IN NUMBER
--       p_lift            IN NUMBER
--       p_targets         IN NUMBER
--       p_non_targets     IN NUMBER
--       p_targets_cumm    IN NUMBER
--       p_target_density  IN NUMBER
--       p_target_density_cumm IN NUMBER
--       p_target_confidence  IN NUMBER
--       p_non_target_confidence IN NUMBER
--
--   OUT
--       x_lift_id         OUT NUMBER
--       x_return_status           OUT  VARCHAR2
--
--   End of Comments
--   ==============================================================================
--
PROCEDURE Create_Lift (
   p_model_id        IN NUMBER,
   p_quantile        IN NUMBER,
   p_lift            IN NUMBER,
   p_targets         IN NUMBER,
   p_non_targets     IN NUMBER,
   p_targets_cumm    IN NUMBER,
   p_target_density  IN NUMBER,
   p_target_density_cumm IN NUMBER,
   p_target_confidence  IN NUMBER,
   p_non_target_confidence IN NUMBER,
   x_lift_id         OUT NUMBER,
   x_return_status   OUT VARCHAR2
);

END AMS_Dmlift_PUB;

 

/
