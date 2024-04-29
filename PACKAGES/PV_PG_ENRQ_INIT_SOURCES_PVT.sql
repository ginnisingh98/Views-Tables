--------------------------------------------------------
--  DDL for Package PV_PG_ENRQ_INIT_SOURCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PG_ENRQ_INIT_SOURCES_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvpeis.pls 115.2 2002/12/10 20:36:52 jkylee ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Pg_Enrq_Init_Sources_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================

-- Default number of records fetch per call
-- G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             enrq_init_sources_rec_type
--   -------------------------------------------------------
--   Parameters:
--       initiation_source_id
--       object_version_number
--       enrl_request_id
--       prev_membership_id
--       enrl_change_rule_id
--       created_by
--       creation_date
--       last_updated_by
--       last_update_date
--       last_update_login
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
TYPE enrq_init_sources_rec_type IS RECORD
(
       initiation_source_id            NUMBER,
       object_version_number           NUMBER,
       enrl_request_id                 NUMBER,
       prev_membership_id              NUMBER,
       enrl_change_rule_id             NUMBER,
       created_by                      NUMBER,
       creation_date                   DATE,
       last_updated_by                 NUMBER,
       last_update_date                DATE,
       last_update_login               NUMBER
);

g_miss_enrq_init_sources_rec          enrq_init_sources_rec_type := NULL;
TYPE  enrq_init_sources_tbl_type      IS TABLE OF enrq_init_sources_rec_type INDEX BY BINARY_INTEGER;
g_miss_enrq_init_sources_tbl          enrq_init_sources_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Pg_Enrq_Init_Sources
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
--       p_enrq_init_sources_rec            IN   enrq_init_sources_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Create_Pg_Enrq_Init_Sources(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_enrq_init_sources_rec              IN   enrq_init_sources_rec_type  := g_miss_enrq_init_sources_rec,
    x_initiation_source_id              OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Pg_Enrq_Init_Sources
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
--       p_enrq_init_sources_rec            IN   enrq_init_sources_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Update_Pg_Enrq_Init_Sources(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_enrq_init_sources_rec               IN    enrq_init_sources_rec_type
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Pg_Enrq_Init_Sources
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
--       p_initiation_source_id                IN   NUMBER
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
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Pg_Enrq_Init_Sources(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_initiation_source_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Pg_Enrq_Init_Sources
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
--       p_enrq_init_sources_rec            IN   enrq_init_sources_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Lock_Pg_Enrq_Init_Sources(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_initiation_source_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_Pg_Init_Src
--
--   Version : Current version 1.0
--   p_validation_mode is a constant defined in PV_UTILITY_PVT package
--           For create: G_CREATE, for update: G_UPDATE
--   Note: 1. This is automated generated item level validation procedure.
--           The actual validation detail is needed to be added.
--           2. We can also validate table instead of record. There will be an option for user to choose.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================


PROCEDURE Validate_Pg_Init_Src(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_enrq_init_sources_rec               IN   enrq_init_sources_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Enrq_Init_Sources_Items
--
--   Version : Current version 1.0
--   p_validation_mode is a constant defined in PV_UTILITY_PVT package
--           For create: G_CREATE, for update: G_UPDATE
--   Note: 1. This is automated generated item level validation procedure.
--           The actual validation detail is needed to be added.
--           2. Validate the unique keys, lookups here
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================


PROCEDURE Check_Init_Src_Items (
    P_enrq_init_sources_rec     IN    enrq_init_sources_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_Init_Src_Rec
--
--   Version : Current version 1.0
--   p_validation_mode is a constant defined in PV_UTILITY_PVT package
--           For create: G_CREATE, for update: G_UPDATE
--   Note: 1. This is automated generated item level validation procedure.
--           The actual validation detail is needed to be added.
--           2. Developer can manually added inter-field level validation.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================


PROCEDURE Validate_Init_Src_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_enrq_init_sources_rec               IN    enrq_init_sources_rec_type
    );
END PV_Pg_Enrq_Init_Sources_PVT;

 

/
