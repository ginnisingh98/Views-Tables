--------------------------------------------------------
--  DDL for Package PV_PRGM_BENEFITS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PRGM_BENEFITS_PVT" AUTHID CURRENT_USER AS
 /* $Header: pvxvppbs.pls 115.7 2003/11/07 06:13:57 ktsao ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_PRGM_BENEFITS_PVT
-- Purpose
--
-- History
--         28-FEB-2002    Jessica.Lee         Created
--          1-APR-2002    Peter.Nixon         Modified
--                        Changed benefit_id NUMBER to benefit_code VARCHAR2
--         24-SEP-2003    Karen.Tsao          Modified for 11.5.10
--         02-OCT-2003    Karen.Tsao          Modified prgm_benefits_rec_type to add responsibility_id
--         06-NOV-2003    Karen.Tsao          Took out column responsibility_id
-- NOTE
--
-- End of Comments
-- ===============================================================


--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             prgm_benefits_rec_type
--   -------------------------------------------------------
--   Parameters:
--       program_benefits_id
--       program_id
--       benefit_code
--       last_update_login
--       object_version_number
--       last_update_date
--       last_updated_by
--       created_by
--       creation_date
--
--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--    End of Comments
--
--===================================================================
TYPE prgm_benefits_rec_type IS RECORD
(
        program_benefits_id             NUMBER
       ,program_id                      NUMBER
       ,benefit_code                    VARCHAR2(30)
       ,benefit_id                      NUMBER
       ,benefit_type_code               VARCHAR2(30)
       ,delete_flag                     VARCHAR2(1)
       ,last_update_login               NUMBER
       ,object_version_number           NUMBER
       ,last_update_date                DATE
       ,last_updated_by                 NUMBER
       ,created_by                      NUMBER
       ,creation_date                   DATE

);

g_miss_prgm_benefits_rec                     prgm_benefits_rec_type;
TYPE  program_benefits_tbl_type  IS TABLE OF prgm_benefits_rec_type INDEX BY BINARY_INTEGER;
g_miss_program_benefits_tbl                  program_benefits_tbl_type;




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Prgm_Benefits
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
--       p_prgm_benefits_rec       IN   prgm_benefits_rec_type  Required
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
PROCEDURE Create_Prgm_Benefits(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_prgm_benefits_rec          IN   prgm_benefits_rec_type  := g_miss_prgm_benefits_rec
    ,x_program_benefits_id        OUT NOCOPY  NUMBER
    );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Prgm_Benefits
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
--       p_prgm_benefits_rec       IN   prgm_benefits_rec_type  Required
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
PROCEDURE Update_Prgm_Benefits(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_prgm_benefits_rec          IN   prgm_benefits_rec_type
    );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Prgm_Benefits
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
--       p_program_benefits_id     IN   NUMBER
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
--   =============================================================================
PROCEDURE Delete_Prgm_Benefits(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_program_benefits_id        IN   NUMBER
    ,p_object_version_number      IN   NUMBER
    );



--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Prgm_Benefits
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
--       p_prgm_benefits_rec       IN   prgm_benefits_rec_type  Required
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
PROCEDURE Lock_Prgm_Benefits(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,px_program_benefits_id       IN   NUMBER
    ,p_object_version             IN   NUMBER
    );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--        Validate_Prgm_Benefits
--
--   p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
--   Note: 1. This is automated generated item level validation procedure.
--            The actual validation detail is needed to be added.
--         2. We can also validate table instead of record. There will be an option for user to choose.
--   End of Comments
--   =======================================
PROCEDURE Validate_Prgm_Benefits(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2         := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER           := FND_API.G_VALID_LEVEL_FULL
    ,p_prgm_benefits_rec          IN   prgm_benefits_rec_type
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
--   p_validation_mode is a constant defined in null_UTILITY_PVT package
--                    For create: G_CREATE, for update: G_UPDATE
--   Note: 1. This is automated generated item level validation PROCEDURE.
--            The actual validation detail is needed to be added.
--         2. Validate the unique keys, lookups here
--   ==============================================================================
--    End of Comments
--   ==============================================================================
PROCEDURE Check_Items (
     p_prgm_benefits_rec    IN    prgm_benefits_rec_type
    ,p_validation_mode      IN    VARCHAR2

    ,x_return_status        OUT NOCOPY   VARCHAR2
    );




--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--       Validate_rec
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

    ,p_prgm_benefits_rec          IN   prgm_benefits_rec_type
    ,p_validation_mode            IN   VARCHAR2     := Jtf_Plsql_Api.G_UPDATE
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
     p_prgm_benefits_rec          IN   prgm_benefits_rec_type
    ,x_complete_rec               OUT NOCOPY  prgm_benefits_rec_type
    );


END PV_PRGM_BENEFITS_PVT;

 

/
