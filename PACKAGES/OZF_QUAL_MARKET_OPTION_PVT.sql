--------------------------------------------------------
--  DDL for Package OZF_QUAL_MARKET_OPTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_QUAL_MARKET_OPTION_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvqmos.pls 120.2 2005/08/24 06:28:24 rssharma noship $ */
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
-- qualifier_market_option_id
-- offer_market_option_id
-- precedence
-- qp_list_header_id
-- group_number
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
TYPE qual_mo_rec_type IS RECORD
(
qualifier_market_option_id NUMBER
, offer_market_option_id NUMBER
, qp_qualifier_id NUMBER
, object_version_number NUMBER
, last_update_date DATE
, last_updated_by NUMBER
, creation_date DATE
, created_by NUMBER
, last_update_login NUMBER
, security_group_id NUMBER
);


g_miss_qual_mo_rec_type          qual_mo_rec_type := NULL;
TYPE  ozf_qual_mo_tbl_type      IS TABLE OF qual_mo_rec_type INDEX BY BINARY_INTEGER;
g_miss_qual_mo_tbl          ozf_qual_mo_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_qual_market_options
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
--       p_qual_mo_rec               IN   qual_mo_rec_type
--   OUT NOCOPY
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

PROCEDURE Create_qual_market_options(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_qual_mo_rec                     IN   qual_mo_rec_type  ,
    x_qual_market_option_id        OUT NOCOPY  NUMBER
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           update_qual_market_options
--   Type
--           Private
--   Pre-Req
--             validate_qual_market_options
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_qual_mo_rec             IN   qual_mo_rec_type Required Record Containing qualifier Market options Data
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--
--   History
--            Tue Jun 21 2005:3/2 PM RSSHARMA  Created
--
--   Description
--              : Method to Update Qualifier MO Interface data
--   End of Comments
--   ==============================================================================
PROCEDURE update_qual_market_options(
    p_api_version_number            IN NUMBER
    , p_init_msg_list               IN VARCHAR2       := FND_API.G_FALSE
    , p_commit                      IN VARCHAR2              := FND_API.G_FALSE
    , p_validation_level            IN VARCHAR2    := FND_API.G_VALID_LEVEL_FULL

    , x_return_status               OUT NOCOPY VARCHAR2
    , x_msg_count                   OUT NOCOPY VARCHAR2
    , x_msg_data                    OUT NOCOPY VARCHAR2

    , p_qual_mo_rec                 IN qual_mo_rec_type
    );


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_qual_market_options
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
--    p_qualifier_market_option_id    IN  NUMBER
--    p_object_version_number      IN   NUMBER

--
--   OUT NOCOPY
--    x_return_status              OUT NOCOPY  VARCHAR2
--    x_msg_count                  OUT NOCOPY  NUMBER
--    x_msg_data                   OUT NOCOPY  VARCHAR2

--   Version : Current version 1.0
--
--   History
--            Tue Jun 21 2005:3/25 PM RSSHARMA  Created
--
--   Description
--   End of Comments
--   ==============================================================================
PROCEDURE Delete_qual_market_options(
    p_api_version_number        IN NUMBER
    , p_init_msg_list           IN VARCHAR2     := FND_API.G_FALSE
    , p_commit                  IN VARCHAR2     := FND_API.G_FALSE
    , p_validation_level        IN NUMBER       := FND_API.G_VALID_LEVEL_FULL
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY VARCHAR2
    , x_msg_data                OUT NOCOPY VARCHAR2
    , p_qualifier_market_option_id IN NUMBER
    , p_object_version_number    IN NUMBER
    );

END OZF_QUAL_MARKET_OPTION_PVT;


 

/
