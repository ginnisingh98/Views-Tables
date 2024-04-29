--------------------------------------------------------
--  DDL for Package OZF_CLAIM_LINE_HIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_LINE_HIST_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvclhs.pls 115.4 2004/01/13 09:49:29 upoluri ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Claim_Line_Hist_PVT
-- Purpose
--
-- History
--
--    MCHANG      23-OCT-2001      Remove security_group_id.
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
--             claim_line_hist_rec_type
--   -------------------------------------------------------
--   Parameters:
--       claim_line_history_id
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
--       claim_history_id
--       claim_id
--       claim_line_id
--       line_number
--       split_from_claim_line_id
--       amount
--       acctd_amount
--       currency_code
--       exchange_rate_type
--       exchange_rate_date
--       exchange_rate
--       set_of_books_id
--       valid_flag
--       source_object_id
--       source_object_class
--       source_object_type_id
--       source_object_line_id
--       plan_id
--       offer_id
--       payment_method
--       payment_reference_id
--       payment_reference_number
--       payment_reference_date
--       voucher_id
--       voucher_number
--       payment_status
--       approved_flag
--       approved_date
--       approved_by
--       settled_date
--       settled_by
--       performance_complete_flag
--       performance_attached_flag
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
--       utilization_id
--       claim_currency_amount
--       item_id
--       item_description
--       quantity
--       quantity_uom
--       rate
--       activity_type
--       activity_id
--       earnings_associated_flag
--       comments
--       related_cust_account_id
--       relationship_type
--       tax_code
--       select_cust_children_flag
--       buy_group_cust_account_id
--       credit_to
--       sale_date
--       item_type
--       tax_amount
--       claim_curr_tax_amount
--       activity_line_id
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
TYPE claim_line_hist_rec_type IS RECORD
(
       claim_line_history_id           NUMBER,
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
       claim_history_id                NUMBER,
       claim_id                        NUMBER,
       claim_line_id                   NUMBER,
       line_number                     NUMBER,
       split_from_claim_line_id        NUMBER,
       amount                          NUMBER,
       acctd_amount                    NUMBER,
       currency_code                   VARCHAR2(15),
       exchange_rate_type              VARCHAR2(30),
       exchange_rate_date              DATE,
       exchange_rate                   NUMBER,
       set_of_books_id                 NUMBER,
       valid_flag                      VARCHAR2(1),
       source_object_id                NUMBER,
       source_object_class             VARCHAR2(15),
       source_object_type_id           NUMBER,
       source_object_line_id           NUMBER,
       plan_id                         NUMBER,
       offer_id                        NUMBER,
       payment_method                  VARCHAR2(15),
       payment_reference_id            NUMBER,
       payment_reference_number        VARCHAR2(15),
       payment_reference_date          DATE,
       voucher_id                      NUMBER,
       voucher_number                  VARCHAR2(30),
       payment_status                  VARCHAR2(10),
       approved_flag                   VARCHAR2(1),
       approved_date                   DATE,
       approved_by                     NUMBER,
       settled_date                    DATE,
       settled_by                      NUMBER,
       performance_complete_flag       VARCHAR2(1),
       performance_attached_flag       VARCHAR2(1),
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
       org_id                          NUMBER,
       utilization_id                  NUMBER,
       claim_currency_amount           NUMBER,
       item_id                         NUMBER,
       item_description                VARCHAR2(240),
       quantity                        NUMBER,
       quantity_uom                    VARCHAR2(30),
       rate                            NUMBER,
       activity_type                   VARCHAR2(30),
       activity_id                     NUMBER,
       earnings_associated_flag        VARCHAR2(1),
       comments                        VARCHAR2(2000),
       related_cust_account_id         NUMBER,
       relationship_type               VARCHAR2(30),
       tax_code                        VARCHAR2(50),
       select_cust_children_flag       VARCHAR2(1),
       buy_group_cust_account_id       NUMBER,
       credit_to                       VARCHAR2(15),
       sale_date                       DATE,
       item_type                       VARCHAR2(30),
       tax_amount                      NUMBER,
       claim_curr_tax_amount           NUMBER,
       activity_line_id                NUMBER,
        offer_type                 VARCHAR2(30),
        prorate_earnings_flag      VARCHAR2(1),
        earnings_end_date          DATE
);

g_miss_claim_line_hist_rec          claim_line_hist_rec_type;
TYPE  claim_line_hist_tbl_type IS TABLE OF claim_line_hist_rec_type
INDEX BY BINARY_INTEGER;
g_miss_claim_line_hist_tbl          claim_line_hist_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Claim_Line_Hist
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
--       p_claim_line_hist_rec     IN   claim_line_hist_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   Version : Current version 1.0
--
--   End of Comments
--   ==============================================================================
--
PROCEDURE Create_Claim_Line_Hist(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_claim_line_hist_rec        IN   claim_line_hist_rec_type  := g_miss_claim_line_hist_rec,
    x_claim_line_history_id      OUT NOCOPY  NUMBER
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Claim_Line_Hist
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
--       p_claim_line_hist_rec     IN   claim_line_hist_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   Version : Current version 1.0
--
--   End of Comments
--   ==============================================================================
--
PROCEDURE Update_Claim_Line_Hist(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_claim_line_hist_rec        IN   claim_line_hist_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Claim_Line_Hist
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
--       p_CLAIM_LINE_HISTORY_ID   IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   Version : Current version 1.0
--
--   End of Comments
--   ==============================================================================
--
PROCEDURE Delete_Claim_Line_Hist(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_claim_line_history_id      IN   NUMBER,
    p_object_version_number      IN   NUMBER
);


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Claim_Line_Hist
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
--       p_claim_line_hist_rec     IN   claim_line_hist_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--
--   Version : Current version 1.0
--
--   End of Comments
--   ==============================================================================
--
PROCEDURE Lock_Claim_Line_Hist(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_claim_line_history_id      IN   NUMBER,
    p_object_version             IN   NUMBER
);


-- Start of Comments
--
--  validation procedures
--
--  p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--  For create: G_CREATE, for update: G_UPDATE
--
-- End of Comments
PROCEDURE Validate_claim_line_hist(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_claim_line_hist_rec        IN   claim_line_hist_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
);


-- Start of Comments
--
--  validation procedures
--
--  p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--  For create: G_CREATE, for update: G_UPDATE
--
-- End of Comments
PROCEDURE Check_claim_line_hist_Items (
    P_claim_line_hist_rec     IN    claim_line_hist_rec_type,
    p_validation_mode         IN    VARCHAR2,
    x_return_status           OUT NOCOPY   VARCHAR2
);


-- Start of Comments
--
--  Record level validation procedures
--
--  p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--  For create: G_CREATE, for update: G_UPDATE
--
-- End of Comments
PROCEDURE Validate_claim_line_hist_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_claim_line_hist_rec        IN   claim_line_hist_rec_type
);

END OZF_Claim_Line_Hist_PVT;

 

/
