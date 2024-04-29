--------------------------------------------------------
--  DDL for Package PV_GE_PTNR_RESPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_GE_PTNR_RESPS_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvgprs.pls 115.2 2003/11/18 22:50:50 ktsao noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Ge_Ptnr_Resps_PVT
-- Purpose
--
-- History
--         14-SEP-2003    Karen.Tsao          Created.
--         18-NOV-2003    Karen.Tsao          Modified for new column resp_type_code.
--
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
--             ge_ptnr_resps_rec_type
--   -------------------------------------------------------
--   Parameters:
--       ptnr_resp_id
--       partner_id
--       user_role_code
--       program_id
--       responsibility_id
--       source_resp_map_rule_id
--       object_version_number
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
TYPE ge_ptnr_resps_rec_type IS RECORD
(
     ptnr_resp_id                    NUMBER,
     partner_id                      NUMBER,
     user_role_code                  VARCHAR2(30),
     program_id                      NUMBER,
     responsibility_id               NUMBER,
     source_resp_map_rule_id         NUMBER,
     resp_type_code                  VARCHAR2(10),
     object_version_number           NUMBER,
     created_by                      NUMBER,
     creation_date                   DATE,
     last_updated_by                 NUMBER,
     last_update_date                DATE,
     last_update_login               NUMBER
);

g_miss_ge_ptnr_resps_rec          ge_ptnr_resps_rec_type := NULL;
TYPE  ge_ptnr_resps_tbl_type      IS TABLE OF ge_ptnr_resps_rec_type INDEX BY BINARY_INTEGER;
g_miss_ge_ptnr_resps_tbl          ge_ptnr_resps_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Ge_Ptnr_Resps
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
--       p_ge_ptnr_resps_rec            IN   ge_ptnr_resps_rec_type  Required
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

PROCEDURE Create_Ge_Ptnr_Resps(
  p_api_version_number         IN   NUMBER,
  p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
  p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
  p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

  x_return_status              OUT NOCOPY  VARCHAR2,
  x_msg_count                  OUT NOCOPY  NUMBER,
  x_msg_data                   OUT NOCOPY  VARCHAR2,

  p_ge_ptnr_resps_rec              IN   ge_ptnr_resps_rec_type  := g_miss_ge_ptnr_resps_rec,
  x_ptnr_resp_id              OUT NOCOPY  NUMBER
   );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Ge_Ptnr_Resps
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
--       p_ge_ptnr_resps_rec            IN   ge_ptnr_resps_rec_type  Required
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

PROCEDURE Update_Ge_Ptnr_Resps(
  p_api_version_number         IN   NUMBER,
  p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
  p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
  p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

  x_return_status              OUT NOCOPY  VARCHAR2,
  x_msg_count                  OUT NOCOPY  NUMBER,
  x_msg_data                   OUT NOCOPY  VARCHAR2,

  p_ge_ptnr_resps_rec               IN    ge_ptnr_resps_rec_type
  );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Ge_Ptnr_Resps
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
--       p_ptnr_resp_id                IN   NUMBER
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

PROCEDURE Delete_Ge_Ptnr_Resps(
  p_api_version_number         IN   NUMBER,
  p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
  p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
  p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT NOCOPY  VARCHAR2,
  x_msg_count                  OUT NOCOPY  NUMBER,
  x_msg_data                   OUT NOCOPY  VARCHAR2,
  p_ptnr_resp_id                   IN  NUMBER,
  p_object_version_number      IN   NUMBER
  );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Ge_Ptnr_Resps
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
--       p_ge_ptnr_resps_rec            IN   ge_ptnr_resps_rec_type  Required
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

PROCEDURE Lock_Ge_Ptnr_Resps(
  p_api_version_number         IN   NUMBER,
  p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

  x_return_status              OUT NOCOPY  VARCHAR2,
  x_msg_count                  OUT NOCOPY  NUMBER,
  x_msg_data                   OUT NOCOPY  VARCHAR2,

  p_ptnr_resp_id                   IN  NUMBER,
  p_object_version             IN  NUMBER
  );


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_Ge_Ptnr_Resps
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


PROCEDURE Validate_Ge_Ptnr_Resps(
  p_api_version_number         IN   NUMBER,
  p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
  p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_ge_ptnr_resps_rec               IN   ge_ptnr_resps_rec_type,
  p_validation_mode            IN    VARCHAR2,
  x_return_status              OUT NOCOPY  VARCHAR2,
  x_msg_count                  OUT NOCOPY  NUMBER,
  x_msg_data                   OUT NOCOPY  VARCHAR2
  );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Ge_Ptnr_Resps_Items
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


PROCEDURE Check_Ge_Ptnr_Resps_Items (
  P_ge_ptnr_resps_rec     IN    ge_ptnr_resps_rec_type,
  p_validation_mode  IN    VARCHAR2,
  x_return_status    OUT NOCOPY   VARCHAR2
  );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_Ge_Ptnr_Resps_Rec
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


PROCEDURE Validate_Ge_Ptnr_Resps_Rec (
  p_api_version_number         IN   NUMBER,
  p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
  x_return_status              OUT NOCOPY  VARCHAR2,
  x_msg_count                  OUT NOCOPY  NUMBER,
  x_msg_data                   OUT NOCOPY  VARCHAR2,
  p_ge_ptnr_resps_rec               IN    ge_ptnr_resps_rec_type
  );
END PV_Ge_Ptnr_Resps_PVT;

 

/
