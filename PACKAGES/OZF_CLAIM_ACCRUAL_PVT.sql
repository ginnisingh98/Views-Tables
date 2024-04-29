--------------------------------------------------------
--  DDL for Package OZF_CLAIM_ACCRUAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_ACCRUAL_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvcacs.pls 120.6.12010000.9 2010/05/11 06:37:50 kpatro ship $ */

TYPE line_util_rec_type IS RECORD
(
  claim_line_util_id         NUMBER,
  object_version_number      NUMBER,
  last_update_date           DATE,
  last_updated_by            NUMBER,
  creation_date              DATE,
  created_by                 NUMBER,
  last_update_login          NUMBER,
  claim_line_id              NUMBER,
  utilization_id             NUMBER,
  amount                     NUMBER,
  currency_code              VARCHAR2(15),
  exchange_rate_type         VARCHAR2(30),
  exchange_rate_date         DATE,
  exchange_rate              NUMBER,
  acctd_amount               NUMBER,
  util_curr_amount           NUMBER,
  plan_curr_amount           NUMBER,
  scan_unit                  NUMBER,
  activity_product_id        NUMBER,
  uom_code                   VARCHAR2(3),
  quantity                   NUMBER,
  org_id                     NUMBER,
  univ_curr_amount           NUMBER,
  fxgl_acctd_amount          NUMBER,
  utilized_acctd_amount      NUMBER,
  update_from_tbl_flag       VARCHAR2(1)    := FND_API.g_false
);

TYPE line_util_tbl_type is TABLE OF line_util_rec_type
INDEX BY BINARY_INTEGER;

TYPE funds_util_flt_type IS RECORD
(
  claim_line_id              NUMBER,
  fund_id                    NUMBER,
  activity_type              VARCHAR2(30),
  activity_id                NUMBER,
  activity_product_id        NUMBER,
  schedule_id                NUMBER,
  offer_type                 VARCHAR2(30),
  document_class             VARCHAR2(15),
  document_id                NUMBER,
  product_level_type         VARCHAR2(30),
  product_id                 NUMBER,
  reference_type             VARCHAR2(30),
  reference_id               NUMBER,
  utilization_type           VARCHAR2(30),
  total_amount               NUMBER,
  old_total_amount           NUMBER,
  pay_over_all_flag          BOOLEAN,  -- Bugfix 5154157
  total_units                NUMBER,
  old_total_units            NUMBER,
  quantity                   NUMBER,
  uom_code                   VARCHAR2(3),
  cust_account_id            NUMBER,
  relationship_type          VARCHAR2(30),
  related_cust_account_id    NUMBER,
  buy_group_cust_account_id  NUMBER,
  buy_group_party_id         NUMBER,
  select_cust_children_flag  VARCHAR2(1) := 'N',
  pay_to_customer            VARCHAR2(30),
  prorate_earnings_flag      VARCHAR2(1),
  adjustment_type_id         NUMBER := null,
  end_date                   DATE,
  run_mode                   VARCHAR2(30),
  check_sales_rep_flag       VARCHAR2(1),
  group_by_offer             VARCHAR2(1),
  offer_payment_method       VARCHAR2(30),   -- internal use; do not populate
  utiz_currency_code         VARCHAR2(15),
  bill_to_site_use_id        NUMBER,
  utilization_id             NUMBER,      -- Added For Bug 8402328
  autopay_check              VARCHAR2(15) -- Added for Claims-Mulitcurrency ER
);

--//Added for Claims-Mulitcurrency ER
TYPE currency_rec_type IS RECORD
(
  functional_currency_code   VARCHAR2(15),
  offer_currency_code        VARCHAR2(15),
  universal_currency_code    VARCHAR2(15),
  claim_currency_code        VARCHAR2(15),
  transaction_currency_code  VARCHAR2(15),
  association_currency_code  VARCHAR2(15)
);

TYPE offer_performance_rec_type IS RECORD
(
  offer_id                   NUMBER,
  offer_performance_id       NUMBER,
  product_attribute          VARCHAR2(30),
  product_attr_value         VARCHAR2(240),
  start_date                 DATE,
  end_date                   DATE,
  requirement_type           VARCHAR2(30),
  estimated_value            NUMBER,
  uom_code                   VARCHAR2(30)
);

TYPE offer_performance_tbl_type is TABLE OF offer_performance_rec_type
INDEX BY BINARY_INTEGER;

TYPE offer_earning_rec_type IS RECORD
(
  offer_id                   NUMBER,
  acctd_amount_over          NUMBER
);

TYPE offer_earning_tbl_type is TABLE OF offer_earning_rec_type
INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------
-- PROCEDURE
--   Get_Utiz_Sql_Stmt
--
-- PARAMETERS
--    p_summary_view     : Available values
--                          1. OZF_AUTOPAY_PVT -- 'AUTOPAY'
--                          2. OZF_CLAIM_LINE_PVT --'ACTIVITY', 'PRODUCT', 'SCHEDULE'
--    p_funds_util_flt   :
--    p_cust_account_id  : Only be used for OZF_AUTOPAY_PVT
--    x_utiz_sql_stmt    : Return datatype is VARCHAR2(500)
--
-- NOTE
--   1. This statement will be used for both OZF_AUTOPAY_PVT and OZF_CLAIM_LINE_PVT
--      to get funds_utilized SQL statement by giving in search criteria.
--
-- HISTORY
--   25-JUN-2002  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Get_Utiz_Sql_Stmt(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_summary_view        IN  VARCHAR2  := NULL
  ,p_funds_util_flt      IN  funds_util_flt_type
  ,px_currency_rec       IN  OUT NOCOPY currency_rec_type
  ,p_cust_account_id     IN  NUMBER    := NULL

  ,x_utiz_sql_stmt       OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Line_Util_Tbl
--
-- PURPOSE
--    Create multiple records of claim line utils.
--
-- PARAMETERS
--    p_line_util_tbl: the new records to be inserted
--    x_error_index: return the index number in table where error happened.
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Create_Line_Util_Tbl(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_line_util_tbl          IN    line_util_tbl_type
   ,p_currency_rec           IN    currency_rec_type
   ,p_mode                   IN    VARCHAR2 := OZF_CLAIM_UTILITY_PVT.g_auto_mode

   ,x_error_index            OUT NOCOPY   NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Line_Util
--
-- PURPOSE
--    Create a new record of claim line util.
--
-- PARAMETERS
--    p_line_util_rec: the new record to be inserted
--    x_line_util_id: return the claim_line_util_id of the new record.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If claim_line_util_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If claim_line_util_id is not passed in, generate a unique one from
--       the sequence.
--    4. Please don't pass in any FND_API.g_miss_char/num/date for claim_line_util record.
---------------------------------------------------------------------
PROCEDURE Create_Line_Util(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_line_util_rec       IN  line_util_rec_type
  ,p_currency_rec        IN  currency_rec_type
  ,p_mode                IN  VARCHAR2  := OZF_CLAIM_UTILITY_PVT.g_auto_mode

  ,x_line_util_id        OUT NOCOPY NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Line_Util_Tbl
--
-- PURPOSE
--    Update multiple records of claim line utils.
--
-- PARAMETERS
--    p_line_util_tbl: the new records to be updated.
--    x_error_index: return the index number in table where error happened.
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Update_Line_Util_Tbl(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_line_util_tbl          IN    line_util_tbl_type
   ,p_mode                   IN    VARCHAR2 := OZF_CLAIM_UTILITY_PVT.g_auto_mode

   ,x_error_index            OUT NOCOPY   NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Line_Util
--
-- PURPOSE
--    Update a claim line util record.
--
-- PARAMETERS
--    p_line_util_rec: the record with new items.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE Update_Line_Util(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_line_util_rec       IN  line_util_rec_type
  ,p_mode               IN  VARCHAR2  := OZF_CLAIM_UTILITY_PVT.g_auto_mode

  ,x_object_version      OUT NOCOPY NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Delete_Line_Util_Tbl
--
-- PURPOSE
--    Delete multiple records of claim line utils.
--
-- PARAMETERS
--    p_line_util_tbl: the new records to be deleted
--    x_error_index: return the index number in table where error happened.
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Delete_Line_Util_Tbl(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_line_util_tbl          IN    line_util_tbl_type
   ,p_mode                   IN    VARCHAR2 := OZF_CLAIM_UTILITY_PVT.g_auto_mode

   ,x_error_index            OUT NOCOPY   NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Line_Util
--
-- PURPOSE
--    Delete a record of claim line util.
--
-- PARAMETERS
--    p_line_util_id: the claim_line_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_Line_Util(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_line_util_id      IN  NUMBER
  ,p_object_version    IN  NUMBER
  ,p_mode              IN  VARCHAR2 := OZF_CLAIM_UTILITY_PVT.g_auto_mode
);


---------------------------------------------------------------------
-- PROCEDURE
--    Init_Line_Util_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_Line_Util_Rec(
   x_line_util_rec   OUT NOCOPY  line_util_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Line_Util_Rec
--
-- PURPOSE
--    For update_line_util, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_line_util_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_Line_Util_Rec(
   p_line_util_rec      IN  line_util_rec_type
  ,x_complete_rec       OUT NOCOPY line_util_rec_type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Update_Group_Line_Util
--
-- PURPOSE
--    Create multiple records of line utils for Automatic Association.
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Update_Group_Line_Util(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_summary_view        IN  VARCHAR2  := NULL
  ,p_funds_util_flt      IN  funds_util_flt_type
  ,p_mode                IN  VARCHAR2  := OZF_CLAIM_UTILITY_PVT.g_auto_mode
);


---------------------------------------------------------------------
-- PROCEDURE
--    Delete_Group_Line_Util
--
-- PURPOSE
--    Delete multiple records of line utils for Automatic Association.
--
-- PARAMETERS
--    p_claim_line_id:
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Delete_Group_Line_Util(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_funds_util_flt      IN  funds_util_flt_type
  ,p_mode                IN  VARCHAR2  := OZF_CLAIM_UTILITY_PVT.g_auto_mode
);


---------------------------------------------------------------------
-- PROCEDURE
--    Asso_Accruals_To_Claim
--
-- PURPOSE
--    Associate earnings to the given claim based on given filters.
--
-- PARAMETERS
--    p_claim_id:
--    p_funds_util_flt:
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Asso_Accruals_To_Claim(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_claim_id            IN  NUMBER
  ,p_funds_util_flt      IN  funds_util_flt_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Asso_Accruals_To_Claim_Line
--
-- PURPOSE
--    Associate earnings to the given claim line based on line
--    properties
--
-- PARAMETERS
--    p_claim_line_id:
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Asso_Accruals_To_Claim_Line(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_claim_line_id       IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim_For_Accruals
--
-- PURPOSE
--    Create a claim and associate earnings based on search filters.
--
-- PARAMETERS
--    p_claim_rec: claim record
--    p_funds_util_flt: search filter for earnings
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Create_Claim_For_Accruals(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_claim_rec           IN  ozf_claim_pvt.claim_rec_type
  ,p_funds_util_flt      IN  ozf_claim_accrual_pvt.funds_util_flt_type

  ,x_claim_id            OUT NOCOPY NUMBER
);

-------------------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim_Existing_Accruals
--
-- PURPOSE
--    This procedure creates a claim, associates the existing earnings with
--    claim lines.
--
-- PARAMETERS
--    p_claim_rec: Claim Record
--    p_funds_util_flt: Search Filter to find existing earnings
--
-- NOTES
--
-- HISTORY
--    25-JAN-2010  muthsubr  Created.
--                           Bug# 8632964 fixed.
-------------------------------------------------------------------------------
PROCEDURE Create_Claim_Existing_Accruals(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full
  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2
  ,p_claim_rec           IN  ozf_claim_pvt.claim_rec_type
  ,p_funds_util_flt      IN  ozf_claim_accrual_pvt.funds_util_flt_type
  ,x_claim_id            OUT NOCOPY NUMBER
);
---------------------------------------------------------------------
-- PROCEDURE
--    Pay_Claim_For_Accruals
--
-- PURPOSE
--    Create a claim, associate earnings based on search filters, and
--    close the claim
--
-- PARAMETERS
--    p_claim_rec: claim record
--    p_funds_util_flt: search filter for earnings
--    p_accrual_flag: for the bug#8632964
-- NOTES
---------------------------------------------------------------------
PROCEDURE Pay_Claim_For_Accruals(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full
  ,p_accrual_flag        IN  VARCHAR2  DEFAULT NULL

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_claim_rec           IN  ozf_claim_pvt.claim_rec_type
  ,p_funds_util_flt      IN  ozf_claim_accrual_pvt.funds_util_flt_type

  ,x_claim_id            OUT NOCOPY NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_Batch_Payment
--
-- PURPOSE
--    Create claims and initiate payments for resale batches
--
-- PARAMETERS
--    p_resale_batch_id: resale batch id
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Initiate_Batch_Payment(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_resale_batch_id     IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Adjust_Fund_Utilization
--
-- PURPOSE
--    Create adjustment requests for over-utilized earnings and
--    update scan_unit_remaining in ozf_funds_utilized. Called
--    after claim is approved.
--
-- PARAMETERS
--    p_claim_id
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Adjust_Fund_Utilization(
   p_api_version        IN  NUMBER
  ,p_init_msg_list      IN  VARCHAR2  := FND_API.g_false
  ,p_commit             IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2

  ,p_claim_id           IN  NUMBER
  ,p_mode               IN  VARCHAR2  := OZF_CLAIM_UTILITY_PVT.g_auto_mode

  ,x_next_status        OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--   Check_Offer_Performance
--
-- PARAMETERS
--    p_cust_account_id   : customer account id
--    p_offer_id          : offer id
--
-- HISTORY
---------------------------------------------------------------------
PROCEDURE Check_Offer_Performance(
   p_cust_account_id           IN  NUMBER
  ,p_offer_id                  IN  NUMBER
  ,p_resale_flag               IN  VARCHAR2
  ,p_check_all_flag            IN  VARCHAR2

  ,x_performance_flag          OUT NOCOPY VARCHAR2
  ,x_offer_perf_tbl            OUT NOCOPY offer_performance_tbl_type
);

---------------------------------------------------------------------
-- PROCEDURE
--   Check_Offer_Performance_Tbl
--
-- PURPOSE
--    For the associated earnings in the given claim, find the offer
--    performance requirements that the customer has not met.
--
-- PARAMETERS
--    p_claim_id          : customer account id
--
-- HISTORY
---------------------------------------------------------------------
PROCEDURE Check_Offer_Performance_Tbl(
   p_claim_id                  IN  NUMBER

  ,x_offer_perf_tbl            OUT NOCOPY offer_performance_tbl_type
);

---------------------------------------------------------------------
-- PROCEDURE
--   Check_Offer_Earning_Tbl
--
-- PURPOSE
--    For the associated earnings in the given claim, find the offers
--    whose paid amount is greater than the available amount
--
-- PARAMETERS
--    p_claim_id          : customer account id
--
-- HISTORY
---------------------------------------------------------------------
PROCEDURE Check_Offer_Earning_Tbl(
   p_claim_id                  IN  NUMBER

  ,x_offer_earn_tbl            OUT NOCOPY offer_earning_tbl_type
);

---------------------------------------------------------------------
-- FUNCTION
--    Perform_Approval_Required
--
-- PURPOSE
--    Returns TRUE if the claim requires performance approval.
--
-- PARAMETERS
--    p_claim_id
--
-- NOTES
---------------------------------------------------------------------
FUNCTION Perform_Approval_Required(
   p_claim_id           IN  NUMBER
) RETURN VARCHAR2;


---------------------------------------------------------------------
-- FUNCTION
--    Earnings_Approval_Required
--
-- PURPOSE
--    Returns TRUE if the claim requires earnings approval.
--
-- PARAMETERS
--    p_claim_id
--
-- NOTES
---------------------------------------------------------------------
FUNCTION Earnings_Approval_Required(
   p_claim_id           IN  NUMBER
) RETURN VARCHAR2;

---------------------------------------------------------------------
-- FUNCTION
--    Calculate_FXGL_Amount
--
-- PURPOSE
--    Returns FXGL amount of the claim line util
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
FUNCTION Calculate_FXGL_Amount(
   p_line_util_rec       IN  line_util_rec_type
  ,p_currency_rec        IN  currency_rec_type
) RETURN NUMBER;

---------------------------------------------------------------------
-- PROCEDURE
--   Initiate_SD_Payment
--   R12.1 Enhancements
--
-- PURPOSE
--    R12.1 Enhancements
--    Ship & Debit Claim Creation
--
-- PARAMETERS
--    p_ship_debit_id   : Ship & Debit Request/Batch Id
--    p_ship_debit_type : Request Type (SUPPLIER/INTERNAL)
--    p_claim_number    : Only for SUPPLIER request type
--
-- HISTORY
--   19-OCT-2007  psomyaju  Created.
---------------------------------------------------------------------

PROCEDURE Initiate_SD_Payment(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full
  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2
  ,p_ship_debit_id       IN  NUMBER
  ,p_ship_debit_type     IN  VARCHAR2
  ,x_claim_id            OUT NOCOPY NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Payment_Detail
--
-- PURPOSE
--    This procedure will return the payment method, vendor ID,vendor
--    site ID from customer trade profile
--
-- PARAMETERS
-- p_cust_account       - Cust Account ID
-- x_payment_method     - Payment Method
-- x_vendor_id          - Vendor ID
-- x_vendor_site_id     - Vendor Site ID
--
-- NOTES
-- HISTORY
--   30-APR-2010  KPATRO  Created for ER#9453443.
--   5/05/2010    KPATRO  Bug#9679357 : ISSUES FOUND IN RBS UPDATE
--                         FLOW ER UNIT TESTING
---------------------------------------------------------------------

PROCEDURE Get_Payment_Detail
        (p_cust_account        IN  NUMBER,
         p_billto_site_use_id  IN NUMBER,
         x_payment_method      OUT NOCOPY VARCHAR2,
         x_vendor_id           OUT NOCOPY NUMBER,
         x_vendor_site_id      OUT NOCOPY NUMBER,
         x_return_status       OUT NOCOPY VARCHAR2
         );


END OZF_Claim_Accrual_PVT;

/
