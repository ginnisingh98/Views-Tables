--------------------------------------------------------
--  DDL for Package OZF_TRADE_PROFILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_TRADE_PROFILE_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvctps.pls 115.4 2003/11/11 12:55:41 pkarthik ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Trade_Profile_PVT
-- Purpose
--
-- History
--
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
--             trade_profile_rec_type
--   -------------------------------------------------------
--   Parameters:
--       trade_profile_id
--       object_version_number
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       request_id
--       program_application_id
--       program_update_date
--       program_id
--       created_from
--       party_id
--       site_use_id
--       autopay_flag
--       claim_threshold
--       claim_currency
--       print_flag
--       internet_deal_view_flag
--       internet_claims_flag
--       autopay_periodicity
--       autopay_periodicity_type
--       payment_method
--       discount_type
--       cust_account_id
--       cust_acct_site_id
--       vendor_id
--       vendor_site_id
--       vendor_site_code
--       context
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
--       org_id
--       days_due
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
TYPE trade_profile_rec_type IS RECORD
(
       trade_profile_id                NUMBER,
       object_version_number           NUMBER,
       last_update_date                DATE,
       last_updated_by                 NUMBER,
       creation_date                   DATE,
       created_by                      NUMBER,
       last_update_login               NUMBER,
       request_id                      NUMBER,
       program_application_id          NUMBER,
       program_update_date             DATE,
       program_id                      NUMBER,
       created_from                    VARCHAR2(30),
       party_id                        NUMBER,
       site_use_id                     NUMBER,
       autopay_flag                    VARCHAR2(1),
       claim_threshold                 NUMBER,
       claim_currency                  VARCHAR2(30),
       print_flag                      VARCHAR2(1),
       internet_deal_view_flag         VARCHAR2(1),
       internet_claims_flag            VARCHAR2(1),
       autopay_periodicity             NUMBER,
       autopay_periodicity_type        VARCHAR2(30),
       payment_method                  VARCHAR2(15),
       discount_type                   VARCHAR2(30),
       cust_account_id                 NUMBER,
       cust_acct_site_id               NUMBER,
       vendor_id                       NUMBER,
       vendor_site_id                  NUMBER,
       vendor_site_code                VARCHAR2(15),
       context                         VARCHAR2(30),
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
       attribute15                     VARCHAR2(150),
       org_id                          NUMBER ,
       days_due                NUMBER,
       pos_write_off_threshold          NUMBER,
       neg_write_off_threshold          NUMBER,
       un_earned_pay_allow_to           VARCHAR2(30),
       un_earned_pay_thold_type         VARCHAR2(30),
       un_earned_pay_threshold          NUMBER,
       un_earned_pay_thold_flag       VARCHAR2(1),
       header_tolerance_calc_code VARCHAR2(30),
       header_tolerance_operand NUMBER,
       line_tolerance_calc_code VARCHAR2(30),
       line_tolerance_operand NUMBER
);

g_miss_trade_profile_rec          trade_profile_rec_type;
TYPE  trade_profile_tbl_type      IS TABLE OF trade_profile_rec_type INDEX BY BINARY_INTEGER;
g_miss_trade_profile_tbl          trade_profile_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Trade_Profile
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
--       p_trade_profile_rec            IN   trade_profile_rec_type  Required
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

PROCEDURE Create_Trade_Profile(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_trade_profile_rec               IN   trade_profile_rec_type  := g_miss_trade_profile_rec,
    x_trade_profile_id                   OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Trade_Profile
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
--       p_trade_profile_rec            IN   trade_profile_rec_type  Required
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

PROCEDURE Update_Trade_Profile(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_trade_profile_rec               IN    trade_profile_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Trade_Profile
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
--       p_TRADE_PROFILE_ID                IN   NUMBER
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

PROCEDURE Delete_Trade_Profile(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_trade_profile_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Trade_Profile
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
--       p_trade_profile_rec            IN   trade_profile_rec_type  Required
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

PROCEDURE Lock_Trade_Profile(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_trade_profile_id                   IN  NUMBER,
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

PROCEDURE Validate_trade_profile(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_trade_profile_rec               IN   trade_profile_rec_type,
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

PROCEDURE Check_trade_profile_Items (
    P_trade_profile_rec     IN    trade_profile_rec_type,
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

PROCEDURE Validate_trade_profile_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_trade_profile_rec               IN    trade_profile_rec_type
    );
END OZF_Trade_Profile_PVT;

 

/
