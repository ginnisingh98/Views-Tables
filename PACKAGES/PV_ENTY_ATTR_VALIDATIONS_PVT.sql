--------------------------------------------------------
--  DDL for Package PV_ENTY_ATTR_VALIDATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ENTY_ATTR_VALIDATIONS_PVT" AUTHID CURRENT_USER AS
 /* $Header: pvxvatvs.pls 115.1 2002/12/10 19:19:52 amaram ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_ENTY_ATTR_VALIDATIONS_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

-- Default number of records fetch per call
-- G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
-- ===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             enty_attr_val_rec_type
--   -------------------------------------------------------
--   Parameters:
--       enty_attr_val_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       entity
--       attribute_id
--       party_id
--       attr_value
--       score
--       enabled_flag
--       entity_id
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

--  ===================================================================

TYPE enty_attr_validation_rec_type IS RECORD
(


 validation_id                   NUMBER              := FND_API.G_MISS_NUM
,last_update_date                DATE                := FND_API.G_MISS_DATE
,last_updated_by                 NUMBER              := FND_API.G_MISS_NUM
,creation_date                   DATE                := FND_API.G_MISS_DATE
,created_by                      NUMBER              := FND_API.G_MISS_NUM
,last_update_login               NUMBER              := FND_API.G_MISS_NUM
,object_version_number           NUMBER              := FND_API.G_MISS_NUM
,validation_date			     DATE				 := FND_API.G_MISS_DATE
,validated_by_resource_id		 NUMBER				 := FND_API.G_MISS_NUM
,validation_document_id			 NUMBER				 := FND_API.G_MISS_NUM
,validation_note                 VARCHAR2(4000)      := FND_API.G_MISS_CHAR

);

g_miss_enty_attr_vldtn_rec         enty_attr_validation_rec_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Enty_Attr_Validation
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number  IN   NUMBER                  Required
--       p_init_msg_list       IN   VARCHAR2                Optional  Default = FND_API_G_FALSE
--       p_commit              IN   VARCHAR2                Optional  Default = FND_API.G_FALSE
--       p_validation_level    IN   NUMBER                  Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_enty_attr_validation_rec   IN   enty_attr_validation_rec_type  Required
--
--   OUT
--       x_return_status       OUT  VARCHAR2
--       x_msg_count           OUT  NUMBER
--       x_msg_data            OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Create_Enty_Attr_Validation(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_enty_attr_validation_rec   IN   enty_attr_validation_rec_type  := g_miss_enty_attr_vldtn_rec
    ,x_enty_attr_validation_id    OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Enty_Attr_Validation
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER                  Required
--       p_init_msg_list           IN   VARCHAR2                Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2                Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER                  Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_enty_attr_val_rec       IN   enty_attr_val_rec_type  Required
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

PROCEDURE Update_Enty_Attr_Validation(
       p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_enty_attr_validation_rec   IN   enty_attr_validation_rec_type
    ,x_object_version_number  OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Enty_Attr_Validation
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
--       p_ENTY_ATTR_VAL_ID        IN   NUMBER
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

PROCEDURE Delete_Enty_Attr_Validation(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_enty_attr_validation_id    IN   NUMBER
    ,p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Enty_Attr_Validation
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER                  Required
--       p_init_msg_list           IN   VARCHAR2                Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2                Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER                  Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_enty_attr_val_rec       IN   enty_attr_val_rec_type  Required
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

PROCEDURE Lock_Enty_Attr_Validation(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_enty_attr_validation_id    IN   NUMBER
    ,p_object_version             IN   NUMBER
    );

--  ===============================================================================
--  Start of Comments
--  ===============================================================================
--
--  validation procedures
--
--  p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
--  Note: 1. This is automated generated item level validation procedure.
--           The actual validation detail is needed to be added.
--        2. We can also validate table instead of record. There will be an option for user to choose.
--  End of Comments
--  ===============================================================================

PROCEDURE Validate_Enty_Attr_Validation(
     p_api_version_number   IN   NUMBER
    ,p_init_msg_list        IN   VARCHAR2   := FND_API.G_FALSE
    ,p_validation_level     IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL
    ,p_validation_mode      IN   VARCHAR2   := JTF_PLSQL_API.G_UPDATE
    ,p_enty_attr_validation_rec   IN   enty_attr_validation_rec_type

    ,x_return_status        OUT NOCOPY  VARCHAR2
    ,x_msg_count            OUT NOCOPY  NUMBER
    ,x_msg_data             OUT NOCOPY  VARCHAR2
    );

--  ===============================================================================
--  Start of Comments
--  ===============================================================================
--
--   validation procedures
--
--  p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
--  Note: 1. This is automated generated item level validation procedure.
--           The actual validation detail is needed to be added.
--        2. Validate the unique keys, lookups here
--  End of Comments
--  ===============================================================================

PROCEDURE Check_Enty_Attr_vldtn_Items (
     p_enty_attr_validation_rec   IN   enty_attr_validation_rec_type
    ,p_validation_mode 		 IN    VARCHAR2

    ,x_return_status   		 OUT NOCOPY   VARCHAR2
    );

--  ===============================================================================
--  Start of Comments
--  ===============================================================================
--
--  Record level validation procedures
--
--  p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
--  Note: 1. This is automated generated item level validation procedure.
--           The actual validation detail is needed to be added.
--        2. Developer can manually added inter-field level validation.
--  End of Comments
--  ===============================================================================

PROCEDURE Validate_enty_attr_vldtn_rec(
     p_api_version_number      IN   NUMBER
    ,p_init_msg_list           IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status           OUT NOCOPY  VARCHAR2
    ,x_msg_count               OUT NOCOPY  NUMBER
    ,x_msg_data                OUT NOCOPY  VARCHAR2

    ,p_enty_attr_validation_rec IN   enty_attr_validation_rec_type
    ,p_validation_mode         IN   VARCHAR2     := JTF_PLSQL_API.G_UPDATE
    );

END PV_ENTY_ATTR_VALIDATIONS_PVT;

 

/
