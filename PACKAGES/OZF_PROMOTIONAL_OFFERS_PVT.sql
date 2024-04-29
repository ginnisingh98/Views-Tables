--------------------------------------------------------
--  DDL for Package OZF_PROMOTIONAL_OFFERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_PROMOTIONAL_OFFERS_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvopos.pls 120.1 2005/09/24 14:15:56 julou noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Promotional_Offers_PVT
-- Purpose
--
-- History
--
--   17-Oct-2002  RSSHARMA added last_recal_date and buyer_name
--  Tue May 03 2005:3/35 PM RSSHARMA Added sales_method_flag field
-- NOTE
--
-- End of Comments
-- ===============================================================

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             offers_rec_type
--   -------------------------------------------------------
--   Parameters:
--       offer_id
--       qp_list_header_id
--       offer_type
--       offer_code
--       activity_media_id
--       reusable
--       user_status_id
--       owner_id
--       wf_item_key
--       customer_reference
--       buying_group_contact_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       perf_date_from
--       perf_date_to
--       status_code
--       status_date
--       modifier_level_code
--       order_value_discount_type
--       offer_amount
--       lumpsum_amount
--       lumpsum_payment_type
--       custom_setup_id
--       security_group_id
--       budget_amount_tc
--       budget_amount_fc
--       transaction_currency_Code
--       functional_currency_code
--       distribution_type
--       qualifier_id
--       qualifier_type
--       account_closed_flag
--       budget_offer_yn
--       autopay_flag
--       autopay_days
--       autopay_method
--       autopay_party_attr
--       autopay_party_id
--       tier_level
--       na_rule_header_id
--       beneficiary_account_id
--
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
TYPE offers_rec_type IS RECORD
(
       offer_id                        NUMBER := FND_API.G_MISS_NUM,
       qp_list_header_id               NUMBER := FND_API.G_MISS_NUM,
       offer_type                      VARCHAR2(30) := FND_API.G_MISS_CHAR,
       offer_code                      VARCHAR2(100) := FND_API.G_MISS_CHAR,
       activity_media_id               NUMBER := FND_API.G_MISS_NUM,
       reusable                        VARCHAR2(1) := FND_API.G_MISS_CHAR,
       user_status_id                  NUMBER := FND_API.G_MISS_NUM,
       owner_id                        NUMBER := FND_API.G_MISS_NUM,
       wf_item_key                     VARCHAR2(120) := FND_API.G_MISS_CHAR,
       customer_reference              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       buying_group_contact_id         NUMBER := FND_API.G_MISS_NUM,
       last_update_date                DATE := FND_API.G_MISS_DATE,
       last_updated_by                 NUMBER := FND_API.G_MISS_NUM,
       creation_date                   DATE := FND_API.G_MISS_DATE,
       created_by                      NUMBER := FND_API.G_MISS_NUM,
       last_update_login               NUMBER := FND_API.G_MISS_NUM,
       object_version_number           NUMBER := FND_API.G_MISS_NUM,
       perf_date_from                  DATE := FND_API.G_MISS_DATE,
       perf_date_to                    DATE := FND_API.G_MISS_DATE,
       status_code                     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       status_date                     DATE := FND_API.G_MISS_DATE,
       modifier_level_code             VARCHAR2(30) := FND_API.G_MISS_CHAR,
       order_value_discount_type       VARCHAR2(30) := FND_API.G_MISS_CHAR,
       offer_amount                    NUMBER := FND_API.G_MISS_NUM,
       lumpsum_amount                  NUMBER := FND_API.G_MISS_NUM,
       lumpsum_payment_type            VARCHAR2(30) := FND_API.G_MISS_CHAR,
       custom_setup_id                 NUMBER := FND_API.G_MISS_NUM,
       security_group_id               NUMBER := FND_API.G_MISS_NUM,
       budget_amount_tc                NUMBER := FND_API.G_MISS_NUM,
       budget_amount_fc                NUMBER := FND_API.G_MISS_NUM,
       transaction_currency_Code       VARCHAR2(15) := FND_API.G_MISS_CHAR,
       functional_currency_code        VARCHAR2(15) := FND_API.G_MISS_CHAR,
       distribution_type               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       qualifier_id                    NUMBER  := FND_API.G_MISS_NUM,
       qualifier_type                  VARCHAR2(30) := FND_API.G_MISS_CHAR,
       account_closed_flag             VARCHAR2(1) := FND_API.G_MISS_CHAR,
       budget_offer_yn                 VARCHAR2(1) := FND_API.G_MISS_CHAR,
       break_type                      VARCHAR2(30) := FND_API.G_MISS_CHAR,
       retroactive                     VARCHAR2(1)     := FND_API.G_MISS_CHAR,
       volume_offer_type               VARCHAR2(30)    := FND_API.G_MISS_CHAR,
       budget_source_type              VARCHAR2(30)    := FND_API.G_MISS_CHAR,
       budget_source_id                NUMBER          := FND_API.G_MISS_NUM,
       confidential_flag               VARCHAR2(1)     :=  FND_API.G_MISS_CHAR,
       source_from_parent              VARCHAR2(1)     :=  FND_API.G_MISS_CHAR,
       buyer_name                      VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       last_recal_date                 DATE            := FND_API.G_MISS_DATE,
       autopay_flag                    VARCHAR2(1) :=  FND_API.G_MISS_CHAR,
       autopay_days                    NUMBER := FND_API.G_MISS_NUM,
       autopay_method                  VARCHAR2(30) :=  FND_API.G_MISS_CHAR,
       autopay_party_attr              VARCHAR2(30) :=  FND_API.G_MISS_CHAR,
       autopay_party_id                NUMBER := FND_API.G_MISS_NUM,
       tier_level                      VARCHAR2(30) := FND_API.G_MISS_CHAR,
       na_rule_header_id               NUMBER := FND_API.G_MISS_NUM,
       beneficiary_account_id          NUMBER := FND_API.G_MISS_NUM,
       sales_method_flag                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       org_id                          NUMBER := FND_API.G_MISS_NUM
);

g_miss_offers_rec          offers_rec_type;
TYPE  offers_tbl_type      IS TABLE OF offers_rec_type INDEX BY BINARY_INTEGER;
g_miss_offers_tbl          offers_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Offers
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
--       p_offers_rec            IN   offers_rec_type  Required
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

PROCEDURE Create_Offers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offers_rec               IN   offers_rec_type  := g_miss_offers_rec,
    x_offer_id                   OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Offers
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
--       p_offers_rec            IN   offers_rec_type  Required
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

PROCEDURE Update_Offers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offers_rec               IN    offers_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Offers
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
--       p_OFFER_ID                IN   NUMBER
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

PROCEDURE Delete_Offers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offer_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Offers
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
--       p_offers_rec            IN   offers_rec_type  Required
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

PROCEDURE Lock_Offers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );


-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. We can also validate table instead of record. There will be an option for user to choose.
-- End of Comments

PROCEDURE Validate_offers(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_offers_rec               IN   offers_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Validate the unique keys, lookups here
-- End of Comments

PROCEDURE Check_offers_Items (
    P_offers_rec     IN    offers_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    );

-- Start of Comments
--
-- Record level validation procedures
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Developer can manually added inter-field level validation.
-- End of Comments

PROCEDURE Validate_offers_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offers_rec               IN    offers_rec_type
    );


END OZF_Promotional_Offers_PVT;

 

/
