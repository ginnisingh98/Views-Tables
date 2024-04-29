--------------------------------------------------------
--  DDL for Package OZF_CLAIMS_HISTORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIMS_HISTORY_PVT" AUTHID CURRENT_USER as
/* $Header: ozfvchis.pls 115.5 2003/11/18 10:31:08 upoluri ship $ */
-- Start of Comments
-- Package name     : OZF_claims_history_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


-- Default number of records fetch per call
-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             claims_history_rec_type
--   -------------------------------------------------------
--   Parameters:
--       claim_history_id
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
--       acctd_amount_adjusted
--       acctd_amount_settled
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
--       letter_id
--       letter_date
--       task_source_object_id
--       task_source_object_type_code
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
--       write_off_flag
--       write_off_threshold_amount
--       under_write_off_threshold
--       customer_reason
--       ship_to_cust_account_id
--       AMOUNT_APPLIED             --Bug:2781186
--       APPLIED_RECEIPT_ID         --Bug:2781186
--       APPLIED_RECEIPT_NUMBER     --Bug:2781186
--       wo_rec_trx_id
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
TYPE claims_history_rec_type IS RECORD
(
       claim_history_id                NUMBER,
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
       acctd_amount_adjusted           NUMBER,
       acctd_amount_settled            NUMBER,
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
       payment_method                  VARCHAR2(30),
       voucher_id                      NUMBER,
       voucher_number                  VARCHAR2(30),
       payment_reference_id            NUMBER,
       payment_reference_number        VARCHAR2(30),
       payment_reference_date          DATE,
       payment_status                  VARCHAR2(30),
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
       letter_id                       NUMBER,
       letter_date                     DATE,
       task_source_object_id           NUMBER,
       task_source_object_type_code    VARCHAR2(30),
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
       deduction_attribute_category    VARCHAR2(30),
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
       write_off_flag                  VARCHAR2(1),
       write_off_threshold_amount      NUMBER,
       under_write_off_threshold       VARCHAR2(5),
       customer_reason                 VARCHAR2(30),
       ship_to_cust_account_id         NUMBER,
       amount_applied                  NUMBER       ,    --Bug:2781186
       applied_receipt_id              NUMBER       ,    --Bug:2781186
       applied_receipt_number          VARCHAR2(30),     --Bug:2781186
       wo_rec_trx_id                   NUMBER,
       group_claim_id                  NUMBER,
       appr_wf_item_key                VARCHAR2(240),
       cstl_wf_item_key                VARCHAR2(240),
       batch_type                      VARCHAR2(30)

);

g_miss_claims_history_rec          claims_history_rec_type;
TYPE  claims_history_tbl_type      IS TABLE OF claims_history_rec_type INDEX BY BINARY_INTEGER;
g_miss_claims_history_tbl          claims_history_tbl_type;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_claims_history
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_CLAIMS_HISTORY_Rec     IN CLAIMS_HISTORY_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_Claims_History(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,

    P_CLAIMS_HISTORY_Rec         IN   CLAIMS_HISTORY_Rec_Type  := G_MISS_CLAIMS_HISTORY_REC,
    X_CLAIM_HISTORY_ID           OUT NOCOPY  NUMBER
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_claims_history
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       P_CLAIMS_HISTORY_Rec     IN CLAIMS_HISTORY_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Update_claims_history(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,

    P_CLAIMS_HISTORY_Rec         IN    CLAIMS_HISTORY_Rec_Type,
    X_Object_Version_Number      OUT NOCOPY  NUMBER
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_claims_history
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_CLAIM_HISTORY_ID IN   NUMBER
--       p_object_version_number  IN   NUMBER     Optional  Default = NULL
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Delete_claims_history(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    P_CLAIM_HISTORY_ID  IN  NUMBER,
    P_Object_Version_Number      IN   NUMBER
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--
--  validation procedures
--
-- p_validation_mode is a constant defined in OZF_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. We can also validate table instead of record. There will be an option for user to choose.
-- End of Comments

PROCEDURE Validate_claims_history(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_CLAIMS_HISTORY_Rec         IN    CLAIMS_HISTORY_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_History
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_claim_id                IN   NUMBER
--
--   OUT:
--       x_claim_history_id        OUT  NUMBER
--       x_return_status           OUT  VARCHAR2
--   Version : Current version 1.0
--
--   Note: This procedure insert a history record of a claim in the
--   ozf_claims_history_all table.
--
--   End of Comments
--
PROCEDURE Create_History(p_claim_id         IN NUMBER,
                         p_history_event    IN  VARCHAR2,
			 p_history_event_description IN VARCHAR2,
                         x_claim_history_id OUT NOCOPY NUMBER,
                         x_return_status OUT NOCOPY VARCHAR2
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Check_Create_History
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_claim                   IN   OZF_CLAIM_PVT.claim_rec_type
--       p_event                   IN   VARCHAR2
--
--   OUT:
--       x_history_event               OUT VARCHAR2,
--       x_history_event_description   OUT VARCHAR2,
--       x_needed_to_create            OUT VARCHAR2
--
--   Version : Current version 1.0
--
--   Note: This procedure checke whether there is a need to create
--   history record for a claim.
--
--   End of Comments
--
PROCEDURE Check_Create_History(p_claim            IN  OZF_CLAIM_PVT.claim_rec_type,
                               p_event            IN  VARCHAR2,
                               x_history_event    OUT NOCOPY VARCHAR2,
                               x_history_event_description OUT NOCOPY VARCHAR2,
                               x_needed_to_create OUT NOCOPY VARCHAR2,
			       x_return_status    OUT NOCOPY VARCHAR2
);

End OZF_claims_history_PVT;

 

/
