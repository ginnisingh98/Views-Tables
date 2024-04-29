--------------------------------------------------------
--  DDL for Package OZF_OFFER_MARKET_OPTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFER_MARKET_OPTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvomos.pls 120.4 2005/08/24 06:17:39 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--
-- Purpose
--
-- History
--
-- NOTE
--            Mon Jun 20 2005:2/19 PM RSSHARMA Added new procedure copy_vo_discounts
-- Mon Jul 11 2005:7/4 PM RSSHARMA Added function get_combine_discounts to determine if combine schedules
-- should be eneabled in Market Options

-- End of Comments
-- ===============================================================

-- Default number of records fetch per call
-- G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             ozf_offer_line_rec_type
--   -------------------------------------------------------
--   Parameters:
-- offer_market_option_id
-- offer_id
-- qp_list_header_id
-- group_number
-- retroactive_flag
-- beneficiary_party_id
-- combine_schedule_flag
-- volume_tracking_level_code
-- accrue_to_code
-- precedence
-- object_version_number
-- last_update_date
-- last_updated_by
-- creation_date
-- created_by
-- last_update_login
-- security_group_id
--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

--===================================================================
TYPE vo_mo_rec_type IS RECORD
(
offer_market_option_id NUMBER
, offer_id NUMBER
, qp_list_header_id NUMBER
, group_number NUMBER
, retroactive_flag VARCHAR2(1)
, beneficiary_party_id NUMBER
, combine_schedule_flag VARCHAR2(1)
, volume_tracking_level_code VARCHAR2(30)
, accrue_to_code VARCHAR2(30)
, precedence NUMBER
, object_version_number NUMBER
, last_update_date DATE
, last_updated_by NUMBER
, creation_date DATE
, created_by NUMBER
, last_update_login NUMBER
, security_group_id NUMBER
);


g_miss_mo_rec_type          vo_mo_rec_type := NULL;
TYPE  ozf_vo_mo_tbl_type      IS TABLE OF vo_mo_rec_type INDEX BY BINARY_INTEGER;
g_miss_mo_tbl          ozf_vo_mo_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_market_options
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
--       p_vo_mo_rec               IN   vo_mo_rec_type
--   OUT
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--       x_vo_market_option_id  OUT NOCOPY  NUMBER. Market Option id of the market option just created
--   Version : Current version 1.0
--
--   History
--            Mon Jun 20 2005:3/33 PM RSSHARMA Created
--
--   Description
--              : Method to Create New Market Options.
--   End of Comments
--   ==============================================================================

PROCEDURE Create_market_options(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_mo_rec                     IN   vo_mo_rec_type  ,
    x_vo_market_option_id        OUT NOCOPY  NUMBER
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_market_options
--   Type
--           Private
--   Pre-Req
--             validate_market_options
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_mo_rec   IN   vo_mo_rec_type Required Record Containing Market options Data
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Mon Jun 20 2005:7/56 PM  Created
--
--   Description
--              : Method to Update Discount Lines.
--   End of Comments
--   ==============================================================================
PROCEDURE Update_market_options(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_mo_rec                     IN   vo_mo_rec_type
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_market_options
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
--    p_offer_market_option_id    IN  NUMBER
--    p_object_version_number      IN   NUMBER

--
--   OUT
--    x_return_status              OUT NOCOPY  VARCHAR2
--    x_msg_count                  OUT NOCOPY  NUMBER
--    x_msg_data                   OUT NOCOPY  VARCHAR2

--   Version : Current version 1.0
--
--   History
--            Mon Jun 20 2005:7/55 PM  Created
--
--   Description
--   End of Comments
--   ==============================================================================
PROCEDURE Delete_market_options(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offer_market_option_id    IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

FUNCTION get_mo_name(p_qp_list_header_id IN NUMBER, p_qualifier_grouping_no IN NUMBER)
RETURN VARCHAR2;
FUNCTION get_combine_discounts(p_offer_id IN NUMBER)
RETURN VARCHAR2;

END OZF_offer_Market_Options_PVT;


 

/
