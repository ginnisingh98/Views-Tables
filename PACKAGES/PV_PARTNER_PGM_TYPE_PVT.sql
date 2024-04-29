--------------------------------------------------------
--  DDL for Package PV_PARTNER_PGM_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PARTNER_PGM_TYPE_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvppts.pls 115.4 2002/12/10 20:48:58 ktsao ship $*/
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_PARTNER_PGM_TYPE_PVT
-- Purpose
--
-- History
--         22-APR-2002    Peter.Nixon     Created
--         11-JUN-2002    Karen.Tsao      Modified to reverse logic of G_MISS_XXX and NULL.
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
--             ptr_prgm_type_rec_type
--   -------------------------------------------------------
--   Parameters:
--       PROGRAM_TYPE_ID
--       active_flag
--       enabled_flag
--       object_version_number
--       creation_date
--       created_by
--       last_update_date
--       last_updated_by
--       last_update_login
--       security_group_id
--       program_type_name
--       program_type_description
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
TYPE ptr_prgm_type_rec_type IS RECORD
(
        PROGRAM_TYPE_ID                  NUMBER
        ,active_flag                     VARCHAR2(1)
        ,enabled_flag                    VARCHAR2(1)
        ,object_version_number           NUMBER
        ,creation_date                   DATE
        ,created_by                      NUMBER
        ,last_update_date                DATE
        ,last_updated_by                 NUMBER
        ,last_update_login               NUMBER
        ,program_type_name               VARCHAR2(60)
        ,program_type_description        VARCHAR2(240)
        ,source_lang                     VARCHAR2(4)
);


g_miss_ptr_prgm_type_rec                   ptr_prgm_type_rec_type;
TYPE  ptr_prgm_type_tbl_type   IS TABLE OF ptr_prgm_type_rec_type INDEX BY BINARY_INTEGER;
g_miss_ptr_prgm_type_tbl                   ptr_prgm_type_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Partner_Pgm_Type
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
--       p_ptr_pgrm_type_rec       IN   ptr_prgm_type_rec_type  Required
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
PROCEDURE Create_Partner_Pgm_Type(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_ptr_prgm_type_rec          IN   ptr_prgm_type_rec_type  := g_miss_ptr_prgm_type_rec
    ,x_PROGRAM_TYPE_ID      OUT NOCOPY  NUMBER
     );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Partner_Pgm_Type
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
--       p_ptr_prgm_type_rec       IN   ptr_prgm_type_rec_type  Required
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
PROCEDURE Update_Partner_Pgm_Type(
     p_api_version_number         IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN  VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2

    ,p_ptr_prgm_type_rec          IN  ptr_prgm_type_rec_type
    );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Partner_Program
--               This procedure performs a soft delete by calling the UPDATE table handler
--               and setting ENABLED_FLAG to 'N'.
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
--       p_PROGRAM_TYPE_ID   IN   NUMBER
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
PROCEDURE Delete_Partner_Pgm_Type(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_PROGRAM_TYPE_ID      IN   NUMBER
    ,p_object_version_number      IN   NUMBER
    );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Partner_Pgm_Type
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
--       p_ptr_prgm_type_rec       IN   ptr_prgm_type_rec_type  Required
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
PROCEDURE Lock_Partner_Pgm_Type(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,px_PROGRAM_TYPE_ID     IN  NUMBER
    ,p_object_version             IN  NUMBER
    );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--       Validate_partner_pgm_type
--
--    p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
--    Note: 1. This is automated generated item level validation PROCEDURE.
--             The actual validation detail is needed to be added.
--          2. We can also validate table instead of record. There will be an option for user to choose.
--   ==============================================================================
--    End of Comments
--   ==============================================================================
PROCEDURE Validate_partner_pgm_type(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2         := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER           := FND_API.G_VALID_LEVEL_FULL
    ,p_ptr_prgm_type_rec          IN   ptr_prgm_type_rec_type
    ,p_validation_mode            IN   VARCHAR2		:= JTF_PLSQL_API.G_UPDATE
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
-- p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation PROCEDURE.
--          The actual validation detail is needed to be added.
--       2. Validate the unique keys, lookups here
--   ==============================================================================
--    End of Comments
--   ==============================================================================
PROCEDURE Check_Items (
     p_ptr_prgm_type_rec     IN    ptr_prgm_type_rec_type
    ,p_validation_mode       IN    VARCHAR2
    ,x_return_status         OUT NOCOPY   VARCHAR2
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
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_ptr_prgm_type_rec          IN   ptr_prgm_type_rec_type
    ,p_validation_mode            IN   VARCHAR2     := JTF_PLSQL_API.g_UPDATE
    );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--       Complete_rec
--
--    p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
--    Note: 1. This is automated generated item level validation PROCEDURE.
--             The actual validation detail is needed to be added.
--          2. Developer can manually added inter-field level validation.
--   ==============================================================================
--    End of Comments
--   ==============================================================================
  PROCEDURE Complete_rec (
     p_ptr_prgm_type_rec          IN   ptr_prgm_type_rec_type
    ,x_complete_rec               OUT NOCOPY  ptr_prgm_type_rec_type
    );


END PV_Partner_Pgm_Type_PVT;

 

/
