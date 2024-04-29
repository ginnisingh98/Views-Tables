--------------------------------------------------------
--  DDL for Package OZF_MO_PRESET_TIERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_MO_PRESET_TIERS_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvmopts.pls 120.2 2005/08/24 06:08:44 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--
-- Purpose
--
-- History
--
-- NOTE
--            Mon Jul 11 2005:6/27 PM RSSHARMA Created

-- End of Comments
-- ===============================================================

-- Default number of records fetch per call
-- G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             mo_preset_rec_type
--   -------------------------------------------------------
--   Parameters:
-- MARKET_PRESET_TIER_ID
-- OFFER_MARKET_OPTION_ID
-- PBH_OFFER_DISCOUNT_ID
-- DIS_OFFER_DISCOUNT_ID
-- OBJECT_VERSION_NUMBER
-- LAST_UPDATE_DATE
-- LAST_UPDATED_BY
-- CREATION_DATE
-- CREATED_BY
-- LAST_UPDATE_LOGIN
--    Required
--
--    Defaults
--
--
--   End of Comments

--===================================================================
TYPE mo_preset_rec_type IS RECORD
(
MARKET_PRESET_TIER_ID NUMBER
, OFFER_MARKET_OPTION_ID NUMBER
, PBH_OFFER_DISCOUNT_ID NUMBER
, DIS_OFFER_DISCOUNT_ID NUMBER
, OBJECT_VERSION_NUMBER NUMBER
, LAST_UPDATE_DATE DATE
, LAST_UPDATED_BY NUMBER
, CREATION_DATE DATE
, CREATED_BY NUMBER
, LAST_UPDATE_LOGIN NUMBER
);


g_miss_mo_preset_rec_type          mo_preset_rec_type := NULL;
TYPE  mo_preset_tbl_type      IS TABLE OF mo_preset_rec_type INDEX BY BINARY_INTEGER;
g_miss_mo_preset_tbl          mo_preset_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_mo_preset_tiers
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_vo_mo_rec               IN   mo_preset_rec_type
--   OUT
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--       x_market_preset_tier_id  OUT NOCOPY  NUMBER. Market Preset id of the market option just created
--   Version : Current version 1.0
--
--   History
--
--   Description
--              : Method to Create New Market Options.
--   End of Comments
--   ==============================================================================
PROCEDURE Create_mo_preset_tiers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_preset_tier_rec              IN   mo_preset_rec_type  ,
    x_market_preset_tier_id      OUT NOCOPY  NUMBER
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_mo_preset_tiers
--   Type
--           Private
--   Pre-Req
--             validate_mo_preset_tiers
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_mo_preset_rec           IN   mo_preset_rec_type Required Record Containing Market Preset Tiers Data
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   History
--
--   Description
--              : Method to Update Preset Tiers.
--   End of Comments
--   ==============================================================================
PROCEDURE Update_mo_preset_tiers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_preset_tier_rec              IN   mo_preset_rec_type
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_mo_preset_tiers
--   Type
--           Private
--   Pre-Req
--   Parameters
--
--   IN
--    p_api_version_number         IN   NUMBER
--    p_init_msg_list              IN   VARCHAR2
--    p_commit                     IN   VARCHAR2
--    p_validation_level           IN   NUMBER
--    p_market_preset_id    IN  NUMBER
--    p_object_version_number      IN   NUMBER

--
--   OUT
--    x_return_status              OUT NOCOPY  VARCHAR2
--    x_msg_count                  OUT NOCOPY  NUMBER
--    x_msg_data                   OUT NOCOPY  VARCHAR2

--   Version : Current version 1.0
--
--   History
--
--   Description
--   End of Comments
--   ==============================================================================
PROCEDURE Delete_mo_preset_tiers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_market_preset_tier_id      IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );


END OZF_MO_PRESET_TIERS_PVT;


 

/
