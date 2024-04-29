--------------------------------------------------------
--  DDL for Package AMS_WEB_TRACK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_WEB_TRACK_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvwtgs.pls 120.1 2005/06/27 05:42:20 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Web_Track_PVT
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
--             web_track_rec_type
--   -------------------------------------------------------
--   Parameters:
--       web_tracking_id
--       schedule_id
--       party_id
--       placement_id
--       content_item_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       attribute_category
--       attribute1
--       attribute2
--       attribute3
--       attribute4
--       attribute5
--       attribute6
--       attribute7
--       attribute8
--       attribute9
--       attribute10
--       attribute11
--       attribute12
--       attribute13
--       attribute14
--       attribute15
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
TYPE web_track_rec_type IS RECORD
(
       web_tracking_id                 NUMBER,
       schedule_id                     NUMBER,
       schedule_type		       VARCHAR2(30),
       party_id                        NUMBER,
       placement_id                    NUMBER,
       content_item_id                 NUMBER,
       last_update_date                DATE,
       last_updated_by                 NUMBER,
       creation_date                   DATE,
       created_by                      NUMBER,
       last_update_login               NUMBER,
       object_version_number           NUMBER,
       attribute_category              VARCHAR2(30),
       attribute1                      VARCHAR2(150),
       attribute2                      VARCHAR2(150),
       attribute3                      VARCHAR2(150),
       attribute4                      VARCHAR2(150),
       attribute5                      VARCHAR2(150),
       attribute6                      VARCHAR2(150),
       attribute7                      VARCHAR2(150),
       attribute8                      VARCHAR2(150),
       attribute9                      VARCHAR2(150),
       attribute10                     VARCHAR2(150),
       attribute11                     VARCHAR2(150),
       attribute12                     VARCHAR2(150),
       attribute13                     VARCHAR2(150),
       attribute14                     VARCHAR2(150),
       attribute15                     VARCHAR2(150)
);

g_miss_web_track_rec          web_track_rec_type := NULL;
TYPE  web_track_tbl_type      IS TABLE OF web_track_rec_type INDEX BY BINARY_INTEGER;
g_miss_web_track_tbl          web_track_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Web_Track
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
--       p_web_track_rec            IN   web_track_rec_type  Required
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

PROCEDURE Create_Web_Track(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_web_track_rec              IN   web_track_rec_type  := g_miss_web_track_rec,
    x_web_tracking_id              OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Web_Track
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
--       p_web_track_rec            IN   web_track_rec_type  Required
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

PROCEDURE Update_Web_Track(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_web_track_rec               IN    web_track_rec_type
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Web_Track
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
--       p_web_tracking_id                IN   NUMBER
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

PROCEDURE Delete_Web_Track(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_web_tracking_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Web_Track
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
--       p_web_track_rec            IN   web_track_rec_type  Required
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

PROCEDURE Lock_Web_Track(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_web_tracking_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_Web_Track
--
--   Version : Current version 1.0
--   p_validation_mode is a constant defined in AMS_UTILITY_PVT package
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


PROCEDURE Validate_Web_Track(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_web_track_rec               IN   web_track_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Web_Track_Items
--
--   Version : Current version 1.0
--   p_validation_mode is a constant defined in AMS_UTILITY_PVT package
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


PROCEDURE Check_Web_Track_Items (
    P_web_track_rec     IN    web_track_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_Web_Track_Rec
--
--   Version : Current version 1.0
--   p_validation_mode is a constant defined in AMS_UTILITY_PVT package
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


PROCEDURE Validate_Web_Track_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_web_track_rec               IN    web_track_rec_type
    );


TYPE web_recomms_rec_type IS RECORD
(
       web_recomm_id                   NUMBER,
       web_tracking_id                 NUMBER,
       recomm_object_id                NUMBER,
       recomm_type                     VARCHAR2(80),
       rule_id                         NUMBER,
       offer_id                        NUMBER,
       offer_src_code                  VARCHAR2(30),
       last_update_date                DATE,
       last_updated_by                 NUMBER,
       creation_date                   DATE,
       created_by                      NUMBER,
       last_update_login               NUMBER,
       object_version_number           NUMBER,
       attribute_category              VARCHAR2(30),
       attribute1                      VARCHAR2(150),
       attribute2                      VARCHAR2(150),
       attribute3                      VARCHAR2(150),
       attribute4                      VARCHAR2(150),
       attribute5                      VARCHAR2(150),
       attribute6                      VARCHAR2(150),
       attribute7                      VARCHAR2(150),
       attribute8                      VARCHAR2(150),
       attribute9                      VARCHAR2(150),
       attribute10                     VARCHAR2(150),
       attribute11                     VARCHAR2(150),
       attribute12                     VARCHAR2(150),
       attribute13                     VARCHAR2(150),
       attribute14                     VARCHAR2(150),
       attribute15                     VARCHAR2(150)
);

g_miss_web_recomms_rec          web_recomms_rec_type := NULL;
TYPE  web_recomms_tbl_type      IS TABLE OF web_recomms_rec_type INDEX BY BINARY_INTEGER;
g_miss_web_recomms_tbl          web_recomms_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Web_Recomms
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
--       p_web_recomms_rec            IN   web_recomms_rec_type  Required
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

PROCEDURE Create_Web_Recomms(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_web_recomms_rec              IN   web_recomms_rec_type  := g_miss_web_recomms_rec,
    x_web_recomm_id              OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Web_Recomms
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
--       p_web_recomms_rec            IN   web_recomms_rec_type  Required
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

PROCEDURE Update_Web_Recomms(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_web_recomms_rec               IN    web_recomms_rec_type
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Web_Recomms
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
--       p_web_recomm_id                IN   NUMBER
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

PROCEDURE Delete_Web_Recomms(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_web_recomm_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Web_Recomms
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
--       p_web_recomms_rec            IN   web_recomms_rec_type  Required
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

PROCEDURE Lock_Web_Recomms(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_web_recomm_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_Web_Recomms
--
--   Version : Current version 1.0
--   p_validation_mode is a constant defined in AMS_UTILITY_PVT package
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


PROCEDURE Validate_Web_Recomms(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_web_recomms_rec               IN   web_recomms_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Web_Recomms_Items
--
--   Version : Current version 1.0
--   p_validation_mode is a constant defined in AMS_UTILITY_PVT package
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


PROCEDURE Check_Web_Recomms_Items (
    P_web_recomms_rec     IN    web_recomms_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Validate_Web_Recomms_Rec
--
--   Version : Current version 1.0
--   p_validation_mode is a constant defined in AMS_UTILITY_PVT package
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


PROCEDURE Validate_Web_Recomms_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_web_recomms_rec               IN    web_recomms_rec_type
    );



TYPE impr_obj_id_rec_type is record (
  obj_id number,
  impr_track_id number);

-- objid is ctdid for webadv/offer and prodid for webprod

TYPE  impr_obj_id_tbl_type  IS TABLE OF impr_obj_id_rec_type INDEX BY BINARY_INTEGER;


PROCEDURE Create_Web_Imp_Track(
    p_api_version_number   IN   NUMBER,
    p_init_msg_list        IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit               IN   VARCHAR2  := FND_API.G_FALSE,
    p_validation_level     IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_web_track_rec	   IN   web_track_rec_type,
    p_web_recomms_tbl      IN  web_recomms_tbl_type,
    --p_web_prod             IN  VARCHAR2,
    x_impr_obj_id_rec     OUT NOCOPY impr_obj_id_tbl_type,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2
       );



END AMS_Web_Track_PVT;

 

/
