--------------------------------------------------------
--  DDL for Package OZF_CLAIM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_PUB" AUTHID CURRENT_USER AS
/* $Header: ozfpclas.pls 120.4.12010000.2 2009/04/04 07:11:33 kpatro ship $ */
/*#
* This package can be used to;
* 1. create, update, and delete claims and claim lines;
* 2. create claim with earnings associated
* 3. associate earnings to an existing claim or claim line
* 4. create claim with earnings associated and to settle the claim.
* @rep:scope public
* @rep:product OZF
* @rep:lifecycle active
* @rep:displayname Claim Public API
* @rep:compatibility S
* @rep:businessevent None
* @rep:category BUSINESS_ENTITY OZF_CLAIM
*/



-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

--   -------------------------------------------------------
--    Record name  claim_rec_type
--
--    Note: This is automatic generated record definition, it includes
--    all columns defined in the table, developer must manually add or
--    delete some of the attributes.
--   -------------------------------------------------------
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
       claim_line_id                   NUMBER,
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
       acctd_amount_settled            NUMBER,
       acctd_amount_adjusted           NUMBER,
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
       payment_method                  VARCHAR2(30),
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
       activity_type                   VARCHAR2(30),
       activity_id                     NUMBER,
       earnings_associated_flag        VARCHAR2(1),
       quantity                        NUMBER,
       quantity_uom                    VARCHAR2(30),
       rate                            NUMBER,
       item_id                         NUMBER,
       item_description                VARCHAR2(240),
       performance_complete_flag       VARCHAR2(1),
       performance_attached_flag       VARCHAR2(1),
       utilization_id                  NUMBER,
       plan_id                         NUMBER,
       offer_id                        NUMBER,
       valid_flag                      VARCHAR2(1),
       claim_currency_amount           NUMBER,
       split_from_claim_line_id        NUMBER,
       line_number                     NUMBER,
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
       ship_to_cust_account_id         NUMBER,        -- added by uday
       amount_applied                  NUMBER,        -- Subsequent Receipt application changes
       applied_receipt_id              NUMBER,        -- Subsequent Receipt application changes
       applied_receipt_number          VARCHAR2(30),   -- Subsequent Receipt application changes
       wo_rec_trx_id                   NUMBER,
       group_claim_id                  NUMBER,
       appr_wf_item_key                VARCHAR2(240),
       cstl_wf_item_key                VARCHAR2(240),
       batch_type                      VARCHAR2(30)

  );
g_miss_claim_rec          claim_rec_type;
TYPE  claim_tbl_type      IS TABLE OF claim_rec_type INDEX BY BINARY_INTEGER;

--   -------------------------------------------------------
--    Record name      claim_line_rec_type
--    Note: This is automatic generated record definition, it includes
--    all columns defined in the table, developer must manually add or
--    delete some of the attributes.
--   -------------------------------------------------------
  TYPE claim_line_rec_type IS RECORD
(
  claim_line_id              NUMBER  ,
  object_version_number      NUMBER ,
  last_update_date           DATE ,
  last_updated_by            NUMBER,
  creation_date              DATE,
  created_by                 NUMBER,
  last_update_login          NUMBER,
  request_id                 NUMBER,
  program_application_id     NUMBER,
  program_update_date        DATE,
  program_id                 NUMBER,
  created_from               VARCHAR2(30),
  claim_id                   NUMBER,
  line_number                NUMBER,
  split_from_claim_line_id   NUMBER,
  amount                     NUMBER,
  claim_currency_amount      NUMBER,
  acctd_amount               NUMBER,
  currency_code              VARCHAR2(15),
  exchange_rate_type         VARCHAR2(30),
  exchange_rate_date         DATE ,
  exchange_rate              NUMBER,
  set_of_books_id            NUMBER,
  valid_flag                 VARCHAR2(1),
  source_object_id           NUMBER,
  source_object_class        VARCHAR2(15),
  source_object_type_id      NUMBER,
  source_object_line_id      NUMBER,
  plan_id                    NUMBER,
  offer_id                   NUMBER,
  utilization_id             NUMBER,
  payment_method             VARCHAR2(15),
  payment_reference_id       NUMBER,
  payment_reference_number   VARCHAR2(15),
  payment_reference_date     DATE ,
  voucher_id                 NUMBER,
  voucher_number             VARCHAR2(30),
  payment_status             VARCHAR2(30),
  approved_flag              VARCHAR2(1),
  approved_date              DATE ,
  approved_by                NUMBER,
  settled_date               DATE ,
  settled_by                 NUMBER,
  performance_complete_flag  VARCHAR2(1),
  performance_attached_flag  VARCHAR2(1),
  item_id                    NUMBER,
  item_description           VARCHAR2(240),
  quantity                   NUMBER,
  quantity_uom               VARCHAR2(30),
  rate                       NUMBER,
  activity_type              VARCHAR2(30),
  activity_id                NUMBER,
  related_cust_account_id    NUMBER,
  relationship_type          VARCHAR2(30),
  earnings_associated_flag   VARCHAR2(1),
  comments                   VARCHAR2(2000),
  tax_code                   VARCHAR2(50),
  attribute_category         VARCHAR2(30),
  attribute1                 VARCHAR2(150),
  attribute2                 VARCHAR2(150),
  attribute3                 VARCHAR2(150),
  attribute4                 VARCHAR2(150),
  attribute5                 VARCHAR2(150),
  attribute6                 VARCHAR2(150),
  attribute7                 VARCHAR2(150),
  attribute8                 VARCHAR2(150),
  attribute9                 VARCHAR2(150),
  attribute10                VARCHAR2(150),
  attribute11                VARCHAR2(150),
  attribute12                VARCHAR2(150),
  attribute13                VARCHAR2(150),
  attribute14                VARCHAR2(150),
  attribute15                VARCHAR2(150),
  org_id                     NUMBER,
  update_from_tbl_flag       VARCHAR2(1)    := FND_API.g_false,
  tax_action                 VARCHAR2(15),
  sale_date                  DATE,
  item_type                  VARCHAR2(30),
  tax_amount                 NUMBER,
  claim_curr_tax_amount      NUMBER,
  activity_line_id           NUMBER,
  offer_type                 VARCHAR2(30),
  prorate_earnings_flag      VARCHAR2(1),
  earnings_end_date          DATE,
  --12.1 Enhancement : Price Protection
  dpp_cust_account_id        VARCHAR2(20)
);
TYPE claim_line_tbl_type is TABLE OF claim_line_rec_type
INDEX BY BINARY_INTEGER;

TYPE claim_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      object_version_number   NUMBER := NULL
);


--   -------------------------------------------------------
--    Record name      funds_util_flt_type
--   -------------------------------------------------------
TYPE funds_util_flt_type IS RECORD
(
       fund_id                         NUMBER,
       activity_type                   VARCHAR2(30),
       activity_id                     NUMBER,
       activity_product_id             NUMBER,
       offer_type                      VARCHAR2(30),
       document_class                  VARCHAR2(15),
       document_id                     NUMBER,
       product_level_type              VARCHAR2(30),
       product_id                      NUMBER,
       reference_type                  VARCHAR2(30),
       reference_id                    NUMBER,
       utilization_type                VARCHAR2(30),
       cust_account_id                 NUMBER,
       relationship_type               VARCHAR2(30),
       related_cust_account_id         NUMBER,
       buy_group_cust_account_id       NUMBER,
       select_cust_children_flag       VARCHAR2(1),
       pay_to_customer                 VARCHAR2(30),
       prorate_earnings_flag           VARCHAR2(1),
       end_date                        DATE,
       total_amount                    NUMBER,
       total_units                     NUMBER,
       quantity                        NUMBER,
       uom_code                        VARCHAR2(3),
       utilization_id                  NUMBER -- Added For Bug 8402328
);


--   ==============================================================================
--   API Name
--           Create_Claim
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_claim_rec               IN   claim_rec_type  Required
--       p_claim_line_tbl          IN   claim_line_tbl_type Required
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   ==============================================================================
/*#
* This procedure creates a new claim.
* @param  p_api_version_number indicates the version of the API.
* @param p_init_msg_list indicates whether to initialize the message stack.
* @param p_commit indicates whether to commit within the program.
* @param p_validation_level indicates the level of the validation.
* @param x_return_status indicates the status of the program.
* @param x_msg_count provides the number of the messages returned by the program.
* @param x_msg_data returns messages by the program.
* @param p_claim_rec contains the claim details for the new claim to be created.
* @param p_claim_line_tbl is a table structure with the details of the claim lines to be created.
* @param x_claim_id returns the id of the new claim.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Create Claim
* @rep:compatibility S
* @rep:businessevent None
*/

PROCEDURE Create_Claim(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN    NUMBER   := FND_API.g_valid_level_full,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_claim_rec                  IN   claim_rec_type := OZF_Claim_PUB.g_miss_claim_rec,
    p_claim_line_tbl             IN   claim_line_tbl_type,
    x_claim_id                   OUT NOCOPY  NUMBER
);


--   ==============================================================================
--   API Name
--           Update_Claim
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_claim_rec               IN   claim_rec_type  Required
--       p_claim_line_tbl         IN    claim_line_tbl_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   ==============================================================================
/*#
* This procedure updates an existing claim.
* @param p_api_version_number indicates the version of the API.
* @param p_init_msg_list indicates whether to initialize the message stack.
* @param p_commit indicates whether to commit within the program.
* @param p_validation_level indicates the level of the validation.
* @param x_return_status indicates the status of the program.
* @param x_msg_count provides the number of the messages returned by the program.
* @param x_msg_data returns messages by the program.
* @param p_claim_rec is to be populated with the claim header fields to be updated.
* @param p_claim_line_tbl is to be populated with the claim line fields to be updated.
* @param x_object_version_number returns the updated object version number.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Update Claim
* @rep:compatibility S
* @rep:businessevent None
*/

PROCEDURE Update_Claim(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN    NUMBER   := FND_API.g_valid_level_full,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_claim_rec                  IN   claim_rec_type,
    p_claim_line_tbl             IN   claim_line_tbl_type,
    x_object_version_number      OUT NOCOPY  NUMBER
 );


--   ==============================================================================
--   API Name
--           Delete_Claim
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_CLAIM_ID                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   ==============================================================================
/*#
* This procedure deletes an existing claim.
* @param p_api_version_number indicates the version of the API.
* @param p_init_msg_list indicates whether to initialize the message stack.
* @param p_commit indicates whether to commit within the program.
* @param p_validation_level indicates the level of the validation.
* @param x_return_status indicates the status of the program.
* @param x_msg_count provides the number of the messages returned by the program.
* @param x_msg_data returns messages by the program.
* @param p_claim_id is the id of the claim to be deleted.
* @param p_object_version_number is the object version number of the claim to be deleted.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Delete Claim
* @rep:compatibility S
* @rep:businessevent None
*/
PROCEDURE Delete_Claim(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN    NUMBER   := FND_API.g_valid_level_full,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_claim_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );


--   ==============================================================================
--   API Name
--           Create_Claim_Line_Tbl
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   Varchar2   Optional  Default = FND_API.g_valid_level_full
--       p_claim_line_tbl          IN   OZF_CLAIM_LINE_PVT.claim_line_tbl_type
--
--   OUT
--       x_error_index             OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_return_status           OUT  VARCHAR2
--   ==============================================================================
/*#
* This procedure creates a claim line for an existing claim.
* @param p_api_version indicates the version of the API.
* @param p_init_msg_list indicates whether to initialize the message stack.
* @param p_commit indicates whether to commit within the program.
* @param p_validation_level indicates the level of the validation.
* @param x_return_status indicates the status of the program.
* @param x_msg_count provides the number of the messages returned by the program.
* @param x_msg_data returns messages by the program.
* @param p_claim_line_tbl is a table structure with the details of the claim lines to be created.
* @param x_error_index is the index of the line in the table at which the error occured.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Create Claim Line
* @rep:compatibility S
* @rep:businessevent None
*/

   PROCEDURE Create_Claim_Line_Tbl(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_claim_line_tbl         IN    claim_line_tbl_type
   ,x_error_index            OUT NOCOPY   NUMBER);


--   ==============================================================================
--   API Name
--           Update_Claim_Line_Tbl
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version             IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   Varchar2   Optional  Default = FND_API.g_valid_level_full
--       p_claim_line_tbl          IN   OZF_CLAIM_LINE_PVT.claim_line_tbl_type
--       p_change_object_version   IN   VARCHAR2 := FND_API.g_false;
--   OUT
--       x_error_index             OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_return_status           OUT  VARCHAR2
--   ==============================================================================
/*#
* This procedure updates an existing claim line.
* @param p_api_version indicates the version of the API.
* @param p_init_msg_list indicates whether to initialize the message stack.
* @param p_commit indicates whether to commit within the program.
* @param p_validation_level indicates the level of the validation.
* @param x_return_status indicates the status of the program.
* @param x_msg_data returns messages by the program.
* @param x_msg_count provides the number of the messages returned by the program.
* @param p_claim_line_tbl is a table structure with the details of the claim lines to be updated.
* @param p_change_object_version indicates whether the object version number needs to be incremented.
* @param x_error_index is the index of the line in the table at which the error occured.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Update Claim Line
* @rep:compatibility S
* @rep:businessevent None
*/

  PROCEDURE Update_Claim_Line_Tbl(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_claim_line_tbl         IN    claim_line_tbl_type
   ,p_change_object_version  IN    VARCHAR2 := FND_API.g_false
   ,x_error_index            OUT NOCOPY   NUMBER);


--   ==============================================================================
--   API Name
--           Delete_Claim_Line_Tbl
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_change_object_version   IN   VARCHAR2   Required  Default = FND_API.g_false
--       p_claim_line_Tbl          IN   VARCHAR2   Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_error_index             OUT  NUMBER
--   ==============================================================================
/*#
* This procedure deletes an existing claim line.
* @param p_api_version indicates the version of the API.
* @param p_init_msg_list indicates whether to initialize the message stack.
* @param p_commit indicates whether to commit within the program.
* @param p_validation_level indicates the level of the validation.
* @param x_return_status indicates the status of the program.
* @param x_msg_data returns messages by the program.
* @param x_msg_count provides the number of the messages returned by the program.
* @param p_claim_line_tbl is a table structure with the details of the claim lines to be deleted.
* @param p_change_object_version indicates whether the object version number needs to be incremented.
* @param x_error_index is the index of the line in the table at which the error occured.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Delete Claim Line
* @rep:compatibility S
* @rep:businessevent None
*/

PROCEDURE Delete_Claim_Line_Tbl(
   p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_claim_line_tbl         IN    claim_line_tbl_type
   ,p_change_object_version  IN    VARCHAR2 := FND_API.g_false
   ,x_error_index            OUT NOCOPY   NUMBER);


--   ==============================================================================
--   API Name
--           Asso_Accruals_To_Claim
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version             IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_claim_id                IN   NUMBER     Required
--       p_funds_util_flt          IN   FUNDS_UTIL_FLT_TYPE Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   ==============================================================================
/*#
* This procedure Associates Earnings to an existing claim.
* @param p_api_version indicates the version of the API.
* @param p_init_msg_list indicates whether to initialize the message stack.
* @param p_commit indicates whether to commit within the program.
* @param p_validation_level indicates the level of the validation.
* @param x_return_status indicates the status of the program.
* @param x_msg_data returns messages by the program.
* @param x_msg_count provides the number of the messages returned by the program.
* @param p_claim_id is the id of claim to which earnings are to be associated.
* @param p_funds_util_flt is to be populated with the conditions for filtering the accruals for association.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Associate Accruals to a Claim
* @rep:compatibility S
* @rep:businessevent None
*/

PROCEDURE Asso_Accruals_To_Claim(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_claim_id               IN    NUMBER
   ,p_funds_util_flt         IN    funds_util_flt_type);


--   ==============================================================================
--   API Name
--           Asso_Accruals_To_Claim_Line
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version             IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_claim_line_id           IN   NUMBER     Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   ==============================================================================
/*#
* This procedure associates earnings to an existing claim line.
* @param p_api_version indicates the version of the API.
* @param p_init_msg_list indicates whether to initialize the message stack.
* @param p_commit indicates whether to commit within the program.
* @param p_validation_level indicates the level of the validation.
* @param x_return_status indicates the status of the program.
* @param x_msg_data returns messages by the program.
* @param x_msg_count provides the number of the messages returned by the program.
* @param p_claim_line_id is the id of claim line to which earnings are to be associated.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Associate Accruals to a Claim Line
* @rep:compatibility S
* @rep:businessevent None
*/

PROCEDURE Asso_Accruals_To_Claim_Line(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_claim_line_id          IN    NUMBER);


--   ==============================================================================
--   API Name
--           Create_Claim_For_Accruals
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version             IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_claim_rec               IN   CLAIM_REC_TYPE      Required
--       p_funds_util_flt          IN   FUNDS_UTIL_FLT_TYPE Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_claim_id                OUT  NUMBER
--   ==============================================================================
/*#
* This procedure creates a claim with earnings associated.
* @param p_api_version indicates the version of the API.
* @param p_init_msg_list indicates whether to initialize the message stack.
* @param p_commit indicates whether to commit within the program.
* @param p_validation_level indicates the level of the validation.
* @param x_return_status indicates the status of the program.
* @param x_msg_data returns messages by the program.
* @param x_msg_count provides the number of the messages returned by the program.
* @param p_claim_rec is the record structure with the details of the claim to be created.
* @param p_funds_util_flt is to be populated with the conditions for filtering the accruals for association.
* @param x_claim_id is the id of the claim to be created.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Create Claim For Accruals
* @rep:compatibility S
* @rep:businessevent None
*/

PROCEDURE Create_Claim_For_Accruals(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_claim_rec              IN    claim_rec_type
   ,p_funds_util_flt         IN    funds_util_flt_type
   ,x_claim_id               OUT NOCOPY   NUMBER);


--   ==============================================================================
--   API Name
--           Pay_Claim_For_Accruals
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version             IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_claim_rec               IN   CLAIM_REC_TYPE      Required
--       p_funds_util_flt          IN   FUNDS_UTIL_FLT_TYPE Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_claim_id                OUT  NUMBER
--   ==============================================================================
/*#
* This procedure creates a claim with earnings associated and settles the claim.
* @param p_api_version indicates the version of the API.
* @param p_init_msg_list indicates whether to initialize the message stack.
* @param p_commit indicates whether to commit within the program.
* @param p_validation_level indicates the level of the validation.
* @param x_return_status indicates the status of the program.
* @param x_msg_data returns messages by the program.
* @param x_msg_count provides the number of the messages returned by the program.
* @param p_claim_rec is the record structure with the details of the claim to be created.
* @param p_funds_util_flt is to be populated with the conditions for filtering the accruals for association.
* @param x_claim_id is the id of the claim to be created.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Create Claim For Accruals
* @rep:compatibility S
* @rep:businessevent None
*/
PROCEDURE Pay_Claim_For_Accruals(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_claim_rec              IN    claim_rec_type
   ,p_funds_util_flt         IN    funds_util_flt_type
   ,x_claim_id               OUT NOCOPY   NUMBER);
END OZF_Claim_PUB;

/
