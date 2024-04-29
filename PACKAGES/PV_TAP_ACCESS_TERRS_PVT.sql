--------------------------------------------------------
--  DDL for Package PV_TAP_ACCESS_TERRS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_TAP_ACCESS_TERRS_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvtras.pls 115.0 2003/10/15 04:21:17 rdsharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_TAP_ACCESS_TERRS_PVT
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
--             TAP_ACCESS_TERRS_REC_TYPE
--   -------------------------------------------------------
--   Parameters:
--       partner_access_id
--       terr_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       request_id
--       program_application_id
--       program_id
--       program_update_date
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
TYPE TAP_ACCESS_TERRS_REC_TYPE IS RECORD
(
       partner_access_id               NUMBER,
       terr_id                         NUMBER,
       last_update_date                DATE,
       last_updated_by                 NUMBER,
       creation_date                   DATE,
       created_by                      NUMBER,
       last_update_login               NUMBER,
       object_version_number           NUMBER,
       request_id                      NUMBER,
       program_application_id          NUMBER,
       program_id                      NUMBER,
       program_update_date             DATE
);

g_miss_tap_access_terrs_rec          TAP_ACCESS_TERRS_REC_TYPE := NULL;
TYPE  TAP_ACCESS_TERRS_TBL_TYPE      IS TABLE OF TAP_ACCESS_TERRS_REC_TYPE INDEX BY BINARY_INTEGER;
g_miss_tap_access_terrs_tbl          TAP_ACCESS_TERRS_TBL_TYPE;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Tap_Access_Terrs
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
--       p_tap_access_terrs_rec    IN   tap_access_terrs_rec_type  Required
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

PROCEDURE Create_Tap_Access_Terrs(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_tap_access_terrs_rec       IN   tap_access_terrs_rec_type  := g_miss_tap_access_terrs_rec
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Tap_Access_Terrs
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
--       p_tap_access_terrs_rec    IN   tap_access_terrs_rec_type  Required
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

PROCEDURE Update_Tap_Access_Terrs(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_tap_access_terrs_rec       IN    tap_access_terrs_rec_type
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Tap_Access_Terrs
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
--       p_partner_access_id       IN   NUMBER
--       p_terr_id                 IN   NUMBER
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

PROCEDURE Delete_Tap_Access_Terrs(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_partner_access_id		 IN  NUMBER,
    p_terr_id                    IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Tap_Access_Terrs
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
--       p_tap_access_terrs_rec    IN   tap_access_terrs_rec_type  Required
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

PROCEDURE Lock_Tap_Access_Terrs(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_partner_access_id		IN  NUMBER,
    p_terr_id                   IN  NUMBER,
    p_object_version_number     IN  NUMBER
    );


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_Tap_Access_Terrs
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


PROCEDURE Validate_Tap_Access_Terrs(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode            IN    VARCHAR2,
    p_tap_access_terrs_rec       IN   tap_access_terrs_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Territory_Access_Items
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


PROCEDURE Chk_Tap_Access_Terrs_Items (
    p_tap_access_terrs_rec  IN   tap_access_terrs_rec_type,
    p_validation_mode       IN    VARCHAR2,
    x_return_status         OUT NOCOPY   VARCHAR2
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_Tap_Access_Terrs_Rec
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


PROCEDURE Validate_Tap_Access_Terrs_Rec (
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,
    p_tap_access_terrs_rec  IN   tap_access_terrs_rec_type
    );
END PV_TAP_ACCESS_TERRS_PVT;

 

/
