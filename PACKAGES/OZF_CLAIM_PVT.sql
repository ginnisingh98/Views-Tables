--------------------------------------------------------
--  DDL for Package OZF_CLAIM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvclas.pls 120.5.12010000.2 2009/07/23 17:17:18 kpatro ship $ */


-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             claim_rec_type
--   -------------------------------------------------------
--   Parameters:
--       claim_id
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
--       legal_entity_id
--       write_off_flag
--       write_off_threshold_amount
--       under_write_off_threshold
--       customer_reason
--       ship_to_cust_account_id
--       amount_applied             --Subsequent Receipt Application changes
--       applied_receipt_id         --Subsequent Receipt Application changes
--       applied_receipt_number     --Subsequent Receipt Application changes
--       wo_rec_trx_id              -- Write off Activity Id
--       group_claim_id
--       appr_wf_item_key
--       cstl_wf_item_key
--       batch_type
--       close_status_id
--       open_status_id
--       pre_auth_deduction_number     -- For Rule Based Settlement
--       pre_auth_deduction_normalized -- For Rule Based Settlement
--       offer_id                      -- For Rule Based Settlement
--       settled_from                  -- For Rule Based Settlement
--       approval_in_prog              -- For Rule Based Settlement
--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   Changed by : Uday Poluri     Date:29-05-2003
--                1. Adding new paramters for Auto Write-off of DED/OPM's implementation.
--                2. Removed G_MISS_XXX initialization.
--   Changed by : Sandhya Amaresh Date:17-11-2004
--                1. Changed the length of payment_reference_number from varchar2(15) to varchar2(30)
--   Changed by : Kishore Dhulipati Date:28-06-2005
--                1. Adding new field for legal_entity_id.
--   End of Comments
--===================================================================
TYPE claim_rec_type IS RECORD
(
       claim_id                        NUMBER,
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
       legal_entity_id                 NUMBER,      -- added by kishore.
       write_off_flag                  VARCHAR2(1),
       write_off_threshold_amount      NUMBER,
       under_write_off_threshold       VARCHAR2(5),
       customer_reason                 VARCHAR2(30),
       ship_to_cust_account_id         NUMBER,        -- added by uday
       amount_applied                  NUMBER,        -- Subsequent Receipt application changes
       applied_receipt_id              NUMBER,        -- Subsequent Receipt application changes
       applied_receipt_number          VARCHAR2(30),   -- Subsequent Receipt application changes
       wo_rec_trx_id                   NUMBER,
       group_claim_id                  NUMBER,
       appr_wf_item_key                VARCHAR2(240),
       cstl_wf_item_key                VARCHAR2(240),
       batch_type                      VARCHAR2(30),
       tax_action                      VARCHAR2(30),
       close_status_id                 NUMBER,
       open_status_id                  NUMBER,
       pre_auth_deduction_number       VARCHAR2(30), -- Added for Rule Based Settlement
       pre_auth_deduction_normalized   VARCHAR2(30), -- Added for Rule Based Settlement
       offer_id                        NUMBER,       -- Added for Rule Based Settlement
       settled_from                    VARCHAR2(15), -- Added for Rule Based Settlement
       approval_in_prog                VARCHAR2(1)   -- Added for Rule Based Settlement
);

g_miss_claim_rec          claim_rec_type;
TYPE  claim_tbl_type      IS TABLE OF claim_rec_type INDEX BY BINARY_INTEGER;
g_miss_claim_tbl          claim_tbl_type;


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim
--
-- PURPOSE
--    Create a claim.
--
-- PARAMETERS
--    p_claim     : the new record to be inserted
--    x_claim_id  : return the claim_id of the new reason code
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If claim_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If claim_id is not passed in, generate a unique one from
--       the sequence.
---------------------------------------------------------------------
PROCEDURE  Create_Claim (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim                   IN     claim_rec_type
   ,x_claim_id                OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Update_Claim
--
-- PURPOSE
--    Update a claim code.
--
-- PARAMETERS
--    p_update_claim   : the record with new items.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
----------------------------------------------------------------------
PROCEDURE  Update_Claim (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim                  IN    claim_rec_type
   ,p_event                  IN    VARCHAR2
   ,p_mode                   IN    VARCHAR2 := OZF_claim_Utility_pvt.G_AUTO_MODE
   ,x_object_version_number  OUT NOCOPY   NUMBER
);
---------------------------------------------------------------------
-- PROCEDURE
--    Delete_Claim
--
-- PURPOSE
--    Update a claim code.
--
-- PARAMETERS
--    p_object_id   : the record with new items.
--    p_object_version_number   : object version number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
----------------------------------------------------------------------
PROCEDURE  Delete_Claim (
    p_api_version_number            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_object_id           IN    NUMBER
   ,p_object_version_number  IN    NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,x_msg_data               OUT NOCOPY   VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Claim
--
-- PURPOSE
--    Validate a claim code record.
--
-- PARAMETERS
--    p_validate_claim : the claim code record to be validated
--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE  Validate_Claim (
    p_api_version            IN   NUMBER
   ,p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER
   ,x_msg_data               OUT NOCOPY  VARCHAR2
   ,p_claim                 IN  claim_rec_type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Common_Element
--
-- PURPOSE
--    The precedure does validations on claim elements that was not enforced by UI.
--
-- PARAMETERS
--    p_validate_claim : the claim code record to be validated
--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE  Check_Claim_Common_Element (
    p_api_version            IN   NUMBER
   ,p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER
   ,x_msg_data               OUT NOCOPY  VARCHAR2
   ,p_claim                  IN  claim_rec_type
   ,x_claim                  OUT NOCOPY claim_rec_type
   ,p_mode                   IN  VARCHAR2 := OZF_claim_Utility_pvt.G_AUTO_MODE
   );

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, , flag items, domain constraints.
--
-- PARAMETERS
--    p_claim_rec      : the record to be validated
---------------------------------------------------------------------
PROCEDURE Check_Claim_Items(
   p_validation_mode   IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,p_claim_rec         IN  claim_rec_type
  ,x_return_status     OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Claim_Rec
--
-- PURPOSE
--    For Update_Claim, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_claim_rec  : the record which may contain attributes as
--                    FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--                    have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_Claim_Rec (
   p_claim_rec        IN   claim_rec_type
  ,x_complete_rec     OUT NOCOPY  claim_rec_type
  ,x_return_status    OUT NOCOPY  varchar2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Get_System_Status
--
-- PURPOSE
--    This procedure maps a user_status_id to a system status.
--
-- PARAMETERS
--    p_user_status_id: Id of the status defined by a user.
--    p_status_type:
--    x_system_status: the system status corresponding a user status id
---------------------------------------------------------------------
PROCEDURE Get_System_Status( p_user_status_id IN NUMBER,
                             p_status_type    IN VARCHAR2,
                             x_system_status  OUT NOCOPY VARCHAR,
                             x_msg_data       OUT NOCOPY VARCHAR2,
                             x_msg_count      OUT NOCOPY NUMBER,
                             x_return_status  OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim_History
--
-- PURPOSE
--    This procedure create a history record of a claim if needed.
--
-- PARAMETERS
--    p_user_status_id: Id of the status defined by a user.
--    p_status_type:
--    x_system_status: the system status corresponding a user status id
---------------------------------------------------------------------
PROCEDURE  Create_Claim_History (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2
   ,p_commit                 IN    VARCHAR2
   ,p_validation_level       IN    NUMBER

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_claim                  IN    claim_rec_type
   ,p_event                  IN    VARCHAR2
   ,x_need_to_create         OUT NOCOPY   VARCHAR2
   ,x_claim_history_id       OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Delete_Claim
--
-- PURPOSE
--    This procedure identify the list of deletable or non deletalbe dependent object
--    for a claim.
--
-- PARAMETERS
--    p_object_id                  IN   NUMBER,
--    p_object_version_number      IN   NUMBER,
--    x_dependent_object_tbl       OUT  ozf_utility_pvt.dependent_objects_tbl_type
---------------------------------------------------------------------
PROCEDURE Validate_Delete_Claim (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_object_id                  IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    x_dependent_object_tbl       OUT NOCOPY  ams_utility_pvt.dependent_objects_tbl_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
 );

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim_tbl
--
-- PURPOSE
--    Create mutiple claims at one time.
--
-- PARAMETERS
--    p_claim_tbl     : the new record to be inserted
--
-- NOTES: for all the claims to be created
--    1. object_version_number will be set to 1.
--    2. If claim_number is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
---------------------------------------------------------------------
PROCEDURE  Create_Claim_tbl (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_claim_tbl              IN    claim_tbl_type
   ,x_error_index            OUT NOCOPY   NUMBER
);


-- ------------------------------------------------------------------
-- Bug : 2732290
-- Changed by: (Uday Poluri) Date:03-JUN-2003
-- Comments: add new procedure to update claims from Claim Summary Screen.
-- ------------------------------------------------------------------
---------------------------------------------------------------------
-- PROCEDURE
--    Update_Claim_tbl
--
-- PURPOSE
--    Update mutiple claims at one time
--
-- PARAMETERS
--    p_claim_tbl     : the new record to be inserted
--
-- NOTES: for all the claims to be created
--    1. object_version_number will be set to 1.
--    2. If claim_number is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
---------------------------------------------------------------------
PROCEDURE  Update_Claim_tbl (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY  VARCHAR2
   ,x_msg_data               OUT NOCOPY  VARCHAR2
   ,x_msg_count              OUT NOCOPY  NUMBER
   ,p_claim_tbl              IN    claim_tbl_type
);

-- --End Bug: 2732290 -----------------------------------------

-- ------------------------------------------------------------------
-- Bug : 2710047
-- Changed by: (uday poluri) Date:28-May-2003
-- Comments: Called from OZF_Settlement_Doc_PVT
-- ------------------------------------------------------------------
---------------------------------------------------------------------
-- PROCEDURE
--    get_write_off_threshold
--
-- PURPOSE
--    This procedure gets (-VE and +VE)threshold value from customer profile
--    and system parameters.
--
--
-- PARAMETERS
--    p_cust_account_id : claim cust_account_id
--    x_ded_pos_write_off_threshold : Positive threshold value
--    x_opy_neg_write_off_threshold : Negetive threshold value
--
-- NOTES :
--
----------------------------------------------------------------------
Procedure get_write_off_threshold(p_cust_account_id             IN  NUMBER,
                                  x_ded_pos_write_off_threshold OUT NOCOPY NUMBER,
                                  x_opy_neg_write_off_threshold OUT NOCOPY NUMBER,
                                  X_RETURN_STATUS               OUT NOCOPY VARCHAR2);
-- --End Bug: 2732290 -----------------------------------------

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Claim_Number
--
-- PURPOSE
--    This procedure retrieves a claim number based on the object_type
--    and class.
--
-- PARAMETERS
--    p_claim  : The claim record passed in.
--    p_object_type : The type of object.
--    p_class       : class.
--    x_claim_number :claim number based on the object_type and class.
--    x_return_status
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_Claim_Number( p_split_from_claim_id IN NUMBER,
                            p_custom_setup_id IN NUMBER,
                            x_claim_number   OUT NOCOPY VARCHAR2,
                            x_msg_data       OUT NOCOPY VARCHAR2,
                            x_msg_count      OUT NOCOPY NUMBER,
                            x_return_status  OUT NOCOPY VARCHAR2);

END OZF_CLAIM_PVT;

/
