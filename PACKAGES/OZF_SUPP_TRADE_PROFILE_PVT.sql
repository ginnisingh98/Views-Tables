--------------------------------------------------------
--  DDL for Package OZF_SUPP_TRADE_PROFILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_SUPP_TRADE_PROFILE_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvstps.pls 120.0.12010000.5 2009/09/23 09:54:17 nepanda ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_SUPP_TRADE_PROFILE_PVT
-- Purpose
--
-- History
-- 16-SEP-2008 kdass  ER 7377460 - added DFFs for DPP section
-- 09-OCT-2008 kdass  ER 7475578 - Supplier Trade Profile changes for Price Protection price increase enhancement
-- 03-AUG-2009 kdass  ER 8755134 - STP: PRICE PROTECTION OPTIONS FOR SKIP APPROVAL AND SKIP ADJUSTMENT
-- 23-SEP-2009 nepanda ER 8932673 - er: credit memo scenario not handled in current price protection product
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
--             supp_trade_profile_rec_type
--   -------------------------------------------------------
--   Parameters:
--       supp_trade_profile_id
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
--       supplier_id
--       supplier_site_id
--       party_id
--       cust_account_id
--       cust_acct_site_id
--       site_use_id
--       pre_approval_flag
--       approval_communication
--       gl_contra_liability_acct
--       gl_cost_adjustment_acct
--       default_days_covered
--       create_claim_price_increase
--       skip_approval_flag
--       skip_adjustment_flag
--       settlement_method_supplier_inc
--       settlement_method_supplier_dec
--       settlement_method_customer
--       authorization_period
--       grace_days
--       allow_qty_increase
--       qty_increase_tolerance
--       request_communication
--       claim_communication
--       claim_frequency
--       claim_frequency_unit
--       claim_computation_basis
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
--       security_group_id
--       last_paid_date
--       claim_currency_code
--       min_claim_amt
--       min_claim_amt_line_lvl
--       auto_debit
--       days_before_claiming_debit
--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

--===================================================================
TYPE supp_trade_profile_rec_type IS RECORD
(

supp_trade_profile_id                     NUMBER,
object_version_number                     NUMBER,
last_update_date                          DATE,
last_updated_by                           NUMBER,
creation_date                             DATE,
created_by                                NUMBER,
last_update_login                         NUMBER,
request_id                                NUMBER,
program_application_id                    NUMBER,
program_update_date                       DATE,
program_id                                NUMBER,
created_from                              VARCHAR2(30),
supplier_id                               NUMBER,
supplier_site_id                          NUMBER,
party_id                                  NUMBER,
cust_account_id                           NUMBER,
cust_acct_site_id                         NUMBER,
site_use_id                               NUMBER,
pre_approval_flag                         VARCHAR2(1),
approval_communication                    VARCHAR2(30),
gl_contra_liability_acct                  NUMBER,
gl_cost_adjustment_acct                   NUMBER,
default_days_covered                      NUMBER,
create_claim_price_increase               VARCHAR2(1),
--ER 8755134
skip_approval_flag                        VARCHAR2(1),
skip_adjustment_flag                      VARCHAR2(1),
--nepanda : ER 8932673 : start
settlement_method_supplier_inc            VARCHAR2(30),
settlement_method_supplier_dec            VARCHAR2(30),
settlement_method_customer                VARCHAR2(30),
--nepanda : ER 8932673 : end
authorization_period                      NUMBER,
grace_days                                NUMBER,
allow_qty_increase                        VARCHAR2(1),
qty_increase_tolerance                    NUMBER,
request_communication                     VARCHAR2(30),
claim_communication                       VARCHAR2(30),
claim_frequency                           NUMBER,
claim_frequency_unit                      VARCHAR2(30),
claim_computation_basis                   NUMBER,
attribute_category                        VARCHAR2(30),
attribute1                                VARCHAR2(150),
attribute2                                VARCHAR2(150),
attribute3                                VARCHAR2(150),
attribute4                                VARCHAR2(150),
attribute5                                VARCHAR2(150),
attribute6                                VARCHAR2(150),
attribute7                                VARCHAR2(150),
attribute8                                VARCHAR2(150),
attribute9                                VARCHAR2(150),
attribute10                               VARCHAR2(150),
attribute11                               VARCHAR2(150),
attribute12                               VARCHAR2(150),
attribute13                               VARCHAR2(150),
attribute14                               VARCHAR2(150),
attribute15                               VARCHAR2(150),
attribute16                               VARCHAR2(150),
attribute17                               VARCHAR2(150),
attribute18                               VARCHAR2(150),
attribute19                               VARCHAR2(150),
attribute20                               VARCHAR2(150),
attribute21                               VARCHAR2(150),
attribute22                               VARCHAR2(150),
attribute23                               VARCHAR2(150),
attribute24                               VARCHAR2(150),
attribute25                               VARCHAR2(150),
attribute26                               VARCHAR2(150),
attribute27                               VARCHAR2(150),
attribute28                               VARCHAR2(150),
attribute29                               VARCHAR2(150),
attribute30                               VARCHAR2(150),
dpp_attribute_category                    VARCHAR2(30),
dpp_attribute1                            VARCHAR2(150),
dpp_attribute2                            VARCHAR2(150),
dpp_attribute3                            VARCHAR2(150),
dpp_attribute4                            VARCHAR2(150),
dpp_attribute5                            VARCHAR2(150),
dpp_attribute6                            VARCHAR2(150),
dpp_attribute7                            VARCHAR2(150),
dpp_attribute8                            VARCHAR2(150),
dpp_attribute9                            VARCHAR2(150),
dpp_attribute10                           VARCHAR2(150),
dpp_attribute11                           VARCHAR2(150),
dpp_attribute12                           VARCHAR2(150),
dpp_attribute13                           VARCHAR2(150),
dpp_attribute14                           VARCHAR2(150),
dpp_attribute15                           VARCHAR2(150),
dpp_attribute16                           VARCHAR2(150),
dpp_attribute17                           VARCHAR2(150),
dpp_attribute18                           VARCHAR2(150),
dpp_attribute19                           VARCHAR2(150),
dpp_attribute20                           VARCHAR2(150),
dpp_attribute21                           VARCHAR2(150),
dpp_attribute22                           VARCHAR2(150),
dpp_attribute23                           VARCHAR2(150),
dpp_attribute24                           VARCHAR2(150),
dpp_attribute25                           VARCHAR2(150),
dpp_attribute26                           VARCHAR2(150),
dpp_attribute27                           VARCHAR2(150),
dpp_attribute28                           VARCHAR2(150),
dpp_attribute29                           VARCHAR2(150),
dpp_attribute30                           VARCHAR2(150),
org_id                                    NUMBER,
security_group_id                         NUMBER,
claim_currency_code                       VARCHAR2(15),
min_claim_amt                             NUMBER,
min_claim_amt_line_lvl                    NUMBER,
auto_debit                                VARCHAR2(1),
days_before_claiming_debit                NUMBER

);

g_miss_supp_trade_profile_rec          supp_trade_profile_rec_type;
TYPE  supp_trade_profile_tbl_type      IS TABLE OF supp_trade_profile_rec_type INDEX BY BINARY_INTEGER;
g_miss_supp_trade_profile_tbl          supp_trade_profile_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Supp_Trade_Profile
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
--       p_supp_trade_profile_rec            IN   supp_trade_profile_rec_type  Required
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

PROCEDURE Create_Supp_Trade_Profile(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_supp_trade_profile_rec               IN   supp_trade_profile_rec_type  := g_miss_supp_trade_profile_rec,
    x_supp_trade_profile_id                   OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Supp_Trade_Profile
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
--       p_supp_trade_profile_rec            IN   supp_trade_profile_rec_type  Required
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

PROCEDURE Update_Supp_Trade_Profile(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_supp_trade_profile_rec               IN    supp_trade_profile_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Supp_Delete_Trade_Profile
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
--       p_SUPP_TRADE_PROFILE_ID                IN   NUMBER
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

PROCEDURE Delete_Supp_Trade_Profile(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_supp_trade_profile_id                   IN  NUMBER,
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
--       p_supp_trade_profile_rec            IN   supp_trade_profile_rec_type  Required
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

PROCEDURE Lock_Supp_Trade_Profile(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_supp_trade_profile_id                   IN  NUMBER,
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

PROCEDURE Validate_supp_trade_profile(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_supp_trade_profile_rec               IN   supp_trade_profile_rec_type,
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

PROCEDURE Check_supp_trd_prfl_Items (
    P_supp_trade_profile_rec     IN    supp_trade_profile_rec_type,
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

PROCEDURE Validate_supp_trd_prfl_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_supp_trade_profile_rec      IN    supp_trade_profile_rec_type
    );

END OZF_SUPP_TRADE_PROFILE_PVT;




/
