--------------------------------------------------------
--  DDL for Package OZF_CLAIMS_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIMS_INT_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvcins.pls 120.1 2005/09/02 06:23:33 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Claims_Int_PVT
-- Purpose
--
-- History
-- 02-Sep-2005  SSHIVALI   R12: Multi-Org Changes
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
--             claims_int_rec_type
--   -------------------------------------------------------
--   Parameters:
--       interface_claim_id
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
--       batch_id
--       claim_id
--       claim_number
--       claim_type_id
--       claim_class
--       claim_date
--       due_date
--       owner_id
--       history_event
--       history_event_date
--       history_event_description
--       split_from_claim_id
--       duplicate_claim_id
--       split_date
--       root_claim_id
--       amount
--       amount_adjusted
--       amount_remaining
--       amount_settled
--       acctd_amount
--       acctd_amount_remaining
--       tax_amount
--       tax_code
--       tax_calculation_flag
--       currency_code
--       exchange_rate_type
--       exchange_rate_date
--       exchange_rate
--       set_of_books_id
--       original_claim_date
--       source_object_id
--       source_object_class
--       source_object_type_id
--       source_object_number
--       cust_account_id
--       cust_billto_acct_site_id
--       cust_shipto_acct_site_id
--       location_id
--       pay_related_account_flag
--       related_cust_account_id
--       related_site_use_id
--       relationship_type
--       vendor_id
--       vendor_site_id
--       reason_type
--       reason_code_id
--       task_template_group_id
--       status_code
--       user_status_id
--       sales_rep_id
--       collector_id
--       contact_id
--       broker_id
--       territory_id
--       customer_ref_date
--       customer_ref_number
--       assigned_to
--       receipt_id
--       receipt_number
--       doc_sequence_id
--       doc_sequence_value
--       gl_date
--       payment_method
--       voucher_id
--       voucher_number
--       payment_reference_id
--       payment_reference_number
--       payment_reference_date
--       payment_status
--       approved_flag
--       approved_date
--       approved_by
--       settled_date
--       settled_by
--       effective_date
--       custom_setup_id
--       task_id
--       country_id
--       order_type_id
--       comments
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
--       deduction_attribute_category
--       deduction_attribute1
--       deduction_attribute2
--       deduction_attribute3
--       deduction_attribute4
--       deduction_attribute5
--       deduction_attribute6
--       deduction_attribute7
--       deduction_attribute8
--       deduction_attribute9
--       deduction_attribute10
--       deduction_attribute11
--       deduction_attribute12
--       deduction_attribute13
--       deduction_attribute14
--       deduction_attribute15
--       org_id
--       customer_reason
--       ship_to_cust_account_id
--
--    Required
--
--    Defaults
--
--   End of Comments
--===================================================================
TYPE claims_int_rec_type IS RECORD
(
       interface_claim_id              NUMBER,
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
       batch_id                        NUMBER,
       claim_id                        NUMBER,
       claim_number                    VARCHAR2(30),
       claim_type_id                   NUMBER,
       claim_class                     VARCHAR2(30),
       claim_date                      DATE,
       due_date                        DATE,
       owner_id                        NUMBER,
       history_event                   VARCHAR2(30),
       history_event_date              DATE,
       history_event_description       VARCHAR2(2000),
       split_from_claim_id             NUMBER,
       duplicate_claim_id              NUMBER,
       split_date                      DATE,
       root_claim_id                   NUMBER,
       amount                          NUMBER,
       amount_adjusted                 NUMBER,
       amount_remaining                NUMBER,
       amount_settled                  NUMBER,
       acctd_amount                    NUMBER,
       acctd_amount_remaining          NUMBER,
       tax_amount                      NUMBER,
       tax_code                        VARCHAR2(50),
       tax_calculation_flag            VARCHAR2(1),
       currency_code                   VARCHAR2(15),
       exchange_rate_type              VARCHAR2(30),
       exchange_rate_date              DATE,
       exchange_rate                   NUMBER,
       set_of_books_id                 NUMBER,
       original_claim_date             DATE,
       source_object_id                NUMBER,
       source_object_class             VARCHAR2(15),
       source_object_type_id           NUMBER,
       source_object_number            VARCHAR2(30),
       cust_account_id                 NUMBER,
       cust_billto_acct_site_id        NUMBER,
       cust_shipto_acct_site_id        NUMBER,
       location_id                     NUMBER,
       pay_related_account_flag        VARCHAR2(1),
       related_cust_account_id         NUMBER,
       related_site_use_id             NUMBER,
       relationship_type               VARCHAR2(30),
       vendor_id                       NUMBER,
       vendor_site_id                  NUMBER,
       reason_type                     VARCHAR2(30),
       reason_code_id                  NUMBER,
       task_template_group_id          NUMBER,
       status_code                     VARCHAR2(30),
       user_status_id                  NUMBER,
       sales_rep_id                    NUMBER,
       collector_id                    NUMBER,
       contact_id                      NUMBER,
       broker_id                       NUMBER,
       territory_id                    NUMBER,
       customer_ref_date               DATE,
       customer_ref_number             VARCHAR2(30),
       assigned_to                     NUMBER,
       receipt_id                      NUMBER,
       receipt_number                  VARCHAR2(30),
       doc_sequence_id                 NUMBER,
       doc_sequence_value              NUMBER,
       gl_date                         DATE,
       payment_method                  VARCHAR2(15),
       voucher_id                      NUMBER,
       voucher_number                  VARCHAR2(30),
       payment_reference_id            NUMBER,
       payment_reference_number        VARCHAR2(15),
       payment_reference_date          DATE,
       payment_status                  VARCHAR2(10),
       approved_flag                   VARCHAR2(1),
       approved_date                   DATE,
       approved_by                     NUMBER,
       settled_date                    DATE,
       settled_by                      NUMBER,
       effective_date                  DATE,
       custom_setup_id                 NUMBER,
       task_id                         NUMBER,
       country_id                      NUMBER,
       order_type_id                   NUMBER,
       comments                        VARCHAR2(2000),
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
       deduction_attribute_category    VARCHAR2(30) ,
       deduction_attribute1            VARCHAR2(150),
       deduction_attribute2            VARCHAR2(150),
       deduction_attribute3            VARCHAR2(150),
       deduction_attribute4            VARCHAR2(150),
       deduction_attribute5            VARCHAR2(150),
       deduction_attribute6            VARCHAR2(150),
       deduction_attribute7            VARCHAR2(150),
       deduction_attribute8            VARCHAR2(150),
       deduction_attribute9            VARCHAR2(150),
       deduction_attribute10           VARCHAR2(150),
       deduction_attribute11           VARCHAR2(150),
       deduction_attribute12           VARCHAR2(150),
       deduction_attribute13           VARCHAR2(150),
       deduction_attribute14           VARCHAR2(150),
       deduction_attribute15           VARCHAR2(150),
       org_id                          NUMBER,
       customer_reason                 VARCHAR2(30),
       ship_to_cust_account_id         NUMBER
);

g_miss_claims_int_rec      claims_int_rec_type;
TYPE  claims_int_tbl_type  IS TABLE OF claims_int_rec_type
      INDEX BY BINARY_INTEGER;
g_miss_claims_int_tbl      claims_int_tbl_type;

--   ===========================================================================
--   Start of Comments
--   ===========================================================================
--   API Name
--           Create_Claims_Int
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER
--            Required
--       p_init_msg_list           IN   VARCHAR2
--            Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2
--            Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER
--            Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_claims_int_rec          IN   claims_int_rec_type
--            Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   End of Comments
--   ===========================================================================
--
PROCEDURE Create_Claims_Int(
    p_api_version_number  IN   NUMBER,
    p_init_msg_list       IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level    IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2,

    p_claims_int_rec      IN   claims_int_rec_type  := g_miss_claims_int_rec,
    x_interface_claim_id  OUT NOCOPY  NUMBER
);

--   ===========================================================================
--    Start of Comments
--   ===========================================================================
--   API Name
--           Update_Claims_Int
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER
--           Required
--       p_init_msg_list           IN   VARCHAR2
--           Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2
--           Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER
--           Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_claims_int_rec          IN   claims_int_rec_type
--           Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--   ===========================================================================
--
PROCEDURE Update_Claims_Int(
    p_api_version_number       IN   NUMBER,
    p_init_msg_list            IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                   IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level         IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status            OUT NOCOPY  VARCHAR2,
    x_msg_count                OUT NOCOPY  NUMBER,
    x_msg_data                 OUT NOCOPY  VARCHAR2,

    p_claims_int_rec           IN   claims_int_rec_type,
    x_object_version_number    OUT NOCOPY  NUMBER
    );

--   ===========================================================================
--    Start of Comments
--   ===========================================================================
--   API Name
--           Delete_Claims_Int
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER
--           Required
--       p_init_msg_list           IN   VARCHAR2
--           Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2
--           Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER
--           Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_INTERFACE_CLAIM_ID      IN   NUMBER
--       p_object_version_number   IN   NUMBER
--           Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   End of Comments
--   ===========================================================================
--
PROCEDURE Delete_Claims_Int(
    p_api_version_number       IN   NUMBER,
    p_init_msg_list            IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                   IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level         IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status            OUT NOCOPY  VARCHAR2,
    x_msg_count                OUT NOCOPY  NUMBER,
    x_msg_data                 OUT NOCOPY  VARCHAR2,
    p_interface_claim_id       IN   NUMBER,
    p_object_version_number    IN   NUMBER
    );

--  ============================================================================
--    Start of Comments
--  ============================================================================
--   API Name
--           Lock_Claims_Int
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER
--           Required
--       p_init_msg_list           IN   VARCHAR2
--           Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2
--           Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER
--           Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_claims_int_rec          IN   claims_int_rec_type
--           Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--
--  End of Comments
--  ============================================================================
--

PROCEDURE Lock_Claims_Int(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_interface_claim_id         IN  NUMBER,
    p_object_version             IN  NUMBER
    );

-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- End of Comments

PROCEDURE Validate_claims_int(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_claims_int_rec             IN   claims_int_rec_type,
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
-- End of Comments

PROCEDURE Check_claims_int_Items (
    P_claims_int_rec     IN    claims_int_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    );

-- Start of Comments
--
-- Record level validation procedures
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- End of Comments

PROCEDURE Validate_claims_int_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_claims_int_rec             IN    claims_int_rec_type
);

--   ==========================================================================
--   Start of Comments
--   ==========================================================================
--   API Name
--           Start_Replicate
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--    ERRBUF
--    RETCODE
--   End of Comments
--   ==========================================================================
--
PROCEDURE Start_Replicate (
    ERRBUF    OUT NOCOPY VARCHAR2,
    RETCODE   OUT NOCOPY NUMBER,
    p_org_id  IN  		 NUMBER DEFAULT NULL
);

--   ==========================================================================
--   ==========================================================================
--   Start of Comments
--   ==========================================================================
--   API Name
--           Purge_Claims
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--    ERRBUF
--    RETCODE
--   End of Comments
--   ==========================================================================
--
PROCEDURE Purge_Claims (
    ERRBUF    OUT NOCOPY VARCHAR2,
    RETCODE   OUT NOCOPY NUMBER,
    p_org_id  IN  		 NUMBER DEFAULT NULL
);

END OZF_Claims_Int_PVT;

 

/
