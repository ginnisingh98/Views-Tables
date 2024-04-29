--------------------------------------------------------
--  DDL for Package PV_PRGM_PTR_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PRGM_PTR_TYPES_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvprps.pls 115.5 2003/05/01 18:52:18 ktsao ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_PRGM_PTR_TYPES_PVT
-- Purpose
--
-- History
--         28-FEB-2002    Paul.Ukken      Created
--         29-APR-2002    Peter.Nixon     Modified
--         14-JUN-2002    Karen.Tsao      Modified to reverse logic of G_MISS_XXX and NULL.
--         01-MAY-2003    Karen.Tsao      Modified to partner_type in prgm_ptr_types_rec_type to VARCHAR2(30).
--
-- NOTE
--
-- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
--                          All rights reserved.
--
-- End of Comments
-- ===============================================================

--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             prgm_ptr_types_rec_type
--   -------------------------------------------------------
--   Parameters:
--       program_partner_types_id
--       PROGRAM_TYPE_ID
--       partner_type
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

--===================================================================
TYPE prgm_ptr_types_rec_type IS RECORD
(
        program_partner_types_id   NUMBER
       ,PROGRAM_TYPE_ID            NUMBER
       ,partner_type               VARCHAR2(30)
       ,last_update_date           DATE
       ,last_updated_by            NUMBER
       ,creation_date              DATE
       ,created_by                 NUMBER
       ,last_update_login          NUMBER
       ,object_version_number      NUMBER

      );

g_miss_prgm_ptr_types_rec          prgm_ptr_types_rec_type;
TYPE prgm_ptr_types_rec_tbl_type   IS TABLE OF prgm_ptr_types_rec_type INDEX BY BINARY_INTEGER;
g_miss_prgm_ptr_types_tbl          prgm_ptr_types_rec_tbl_type;



--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Prgm_Ptr_Type
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number         IN   NUMBER     Required
--       p_init_msg_list              IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                     IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level           IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_prgm_ptr_types_rec         IN   prgm_ptr_types_rec_type  Required
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
PROCEDURE Create_Prgm_Ptr_Type(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_prgm_ptr_types_rec         IN   prgm_ptr_types_rec_type  := g_miss_prgm_ptr_types_rec
    ,x_program_partner_types_id   OUT NOCOPY  NUMBER
    );





--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Prgm_Ptr_Type
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number         IN   NUMBER     Required
--       p_init_msg_list              IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                     IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level           IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_prgm_ptr_types_rec         IN   prgm_ptr_types_rec_type  Required
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
PROCEDURE Update_Prgm_Ptr_Type(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_prgm_ptr_types_rec         IN   prgm_ptr_types_rec_type
    );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Prgm_Ptr_Type
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number        IN   NUMBER     Required
--       p_init_msg_list             IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                    IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level          IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_program_partner_types_id  IN   NUMBER
--       p_object_version_number     IN   NUMBER     Optional  Default = NULL
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
PROCEDURE Delete_Prgm_Ptr_Type(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,x_return_status              OUT NOCOPY  VARCHAR
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_program_partner_types_id   IN   NUMBER
    ,p_object_version_number      IN   NUMBER
    );





--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Prgm_Ptr_Type
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
--       p_prgm_ptr_types_rec      IN   prgm_ptr_types_rec_type  Required
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
PROCEDURE Lock_Prgm_Ptr_Type(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_program_partner_types_id   IN   NUMBER
    ,p_object_version             IN   NUMBER
    );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--       Validate_Prgm_Ptr_Type
--
--    p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
--    Note: 1. This is automated generated item level validation PROCEDURE.
--             The actual validation detail is needed to be added.
--          2. We can also validate table instead of record. There will be an option for user to choose.
--   ==============================================================================
--    End of Comments
--   ==============================================================================
PROCEDURE Validate_Prgm_Ptr_Type(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2         := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER           := FND_API.G_VALID_LEVEL_FULL
    ,p_validation_mode            IN   VARCHAR2
    ,p_prgm_ptr_types_rec         IN   prgm_ptr_types_rec_type
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--       Check_Items
--
--     p_validation_mode is a constant defined in null_UTILITY_PVT package
--              For create: G_CREATE, for update: G_UPDATE
--     Note: 1. This is automated generated item level validation PROCEDURE.
--              The actual validation detail is needed to be added.
--           2. Validate the unique keys, lookups here
--   ==============================================================================
--    End of Comments
--   ==============================================================================
PROCEDURE Check_Items (
     P_prgm_ptr_types_rec     IN    prgm_ptr_types_rec_type
    ,p_validation_mode               IN    VARCHAR2
    ,x_return_status                 OUT NOCOPY   VARCHAR2
    );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--       Validate_Rec
--    Record level validation procedures
--
--    p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
--    Note: 1. This is automated generated item level validation PROCEDURE.
--             The actual validation detail is needed to be added.
--          2. Developer can manually added inter-field level validation.
--   ==============================================================================
--    End of Comments
--   ==============================================================================
PROCEDURE Validate_Rec(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR
    ,p_prgm_ptr_types_rec         IN   prgm_ptr_types_rec_type
    );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--       Complete_Rec
--
--    p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
--    Note: 1. This is automated generated item level validation PROCEDURE.
--             The actual validation detail is needed to be added.
--          2. Developer can manually added inter-field level validation.
--   ==============================================================================
--    End of Comments
--   ==============================================================================
  PROCEDURE Complete_Rec (
     p_prgm_ptr_types_rec         IN   prgm_ptr_types_rec_type
    ,x_complete_rec               OUT NOCOPY  prgm_ptr_types_rec_type
    );



END PV_PRGM_PTR_TYPES_PVT;

 

/
