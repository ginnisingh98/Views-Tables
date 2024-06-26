--------------------------------------------------------
--  DDL for Package AMS_DM_TARGET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DM_TARGET_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvdtgs.pls 120.0 2005/05/31 14:39:13 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DM_TARGET_PVT
-- Purpose
--
-- History
--          10-Apr-2002  nyostos  Created.
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
--             dm_target_rec_type
--   -------------------------------------------------------
--   Parameters:
--       target_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       active_flag
--       model_type
--       data_source_id
--       source_field_id
--       target_name
--       description
--       target_source_id
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
TYPE dm_target_rec_type IS RECORD
(
       target_id                       NUMBER := FND_API.G_MISS_NUM,
       last_update_date                DATE := FND_API.G_MISS_DATE,
       last_updated_by                 NUMBER := FND_API.G_MISS_NUM,
       creation_date                   DATE := FND_API.G_MISS_DATE,
       created_by                      NUMBER := FND_API.G_MISS_NUM,
       last_update_login               NUMBER := FND_API.G_MISS_NUM,
       object_version_number           NUMBER := FND_API.G_MISS_NUM,
       active_flag                     VARCHAR2(1) := FND_API.G_MISS_CHAR,
       model_type                      VARCHAR2(30) := FND_API.G_MISS_CHAR,
       data_source_id                  NUMBER := FND_API.G_MISS_NUM,
       source_field_id                 NUMBER := FND_API.G_MISS_NUM,
       target_name		       VARCHAR2(240) := FND_API.G_MISS_CHAR,
       description                     VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       target_source_id                NUMBER := FND_API.G_MISS_NUM
);

g_miss_dm_target_rec          dm_target_rec_type;
TYPE  dm_target_tbl_type      IS TABLE OF dm_target_rec_type INDEX BY BINARY_INTEGER;
g_miss_dm_target_tbl          dm_target_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Dmtarget
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
--       p_dm_target_rec           IN   dm_target_rec_type  Required
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

PROCEDURE Create_Dmtarget(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_dm_target_rec               IN   dm_target_rec_type  := g_miss_dm_target_rec,
    x_target_id                   OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Dmtarget
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
--       p_dm_target_rec            IN   dm_target_rec_type  Required
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

PROCEDURE Update_Dmtarget(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_dm_target_rec              IN    dm_target_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Dmtarget
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
--       p_TARGET_ID               IN   NUMBER
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

PROCEDURE Delete_Dmtarget(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_target_id                  IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Dmtarget
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
--       p_dm_target_rec            IN   dm_target_rec_type  Required
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

PROCEDURE Lock_Dmtarget(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_target_id                  IN  NUMBER,
    p_object_version             IN  NUMBER
    );


-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. We can also validate table instead of record. There will be an option for user to choose.
-- End of Comments

PROCEDURE Validate_dmtarget(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_dm_target_rec              IN   dm_target_rec_type,
    p_validation_mode            IN   VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Validate the unique keys, lookups here
-- End of Comments

PROCEDURE Check_dm_target_Items (
    P_dm_target_rec     IN    dm_target_rec_type,
    p_validation_mode	IN    VARCHAR2,
    x_return_status OUT NOCOPY   VARCHAR2
    );

-- Start of Comments
--
-- Record level validation procedures
--
-- p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Developer can manually added inter-field level validation.
-- End of Comments

PROCEDURE Validate_dm_target_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_dm_target_rec              IN   dm_target_rec_type
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Handle_Data_Source_Disabling
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_data_source_id          IN   NUMBER
--
--   Version : Current version 1.0
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Handle_Data_Source_Disabling(
    p_data_source_id         IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Handle_Data_Source_Enabling
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_data_source_id          IN   NUMBER
--
--   Version : Current version 1.0
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Handle_Data_Source_Enabling(
    p_data_source_id         IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Handle_DS_Assoc_Enabling
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_master_source_id          IN   NUMBER
--       p_sub_source_id             IN   NUMBER
--
--   Version : Current version 1.0
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Handle_DS_Assoc_Enabling(
    p_master_source_id          IN   NUMBER,
    p_sub_source_id             IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Handle_DS_Assoc_Disabling
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_master_source_id          IN   NUMBER
--       p_sub_source_id             IN   NUMBER
--
--   Version : Current version 1.0
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Handle_DS_Assoc_Disabling(
    p_master_source_id          IN   NUMBER,
    p_sub_source_id             IN   NUMBER
    );

PROCEDURE is_target_enabled(
    p_target_id   IN NUMBER,
    x_is_enabled  OUT NOCOPY BOOLEAN
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           in_list
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_string      IN   VARCHAR2     Required
--
--   OUT
--       None
--
--   Version : Current version 1.0
--   History
--          11-May-2005  srivikri  Created. Fix for bug 4360174
--
--   End of Comments
--   ==============================================================================
--

FUNCTION in_list ( p_string IN VARCHAR2 ) RETURN JTF_NUMBER_TABLE;

END AMS_DM_TARGET_PVT;

 

/
