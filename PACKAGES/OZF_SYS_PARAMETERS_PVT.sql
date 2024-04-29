--------------------------------------------------------
--  DDL for Package OZF_SYS_PARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_SYS_PARAMETERS_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvsyss.pls 120.3.12010000.4 2009/07/27 09:30:04 nirprasa ship $ */

TYPE sys_parameters_rec_type IS RECORD
(
  set_of_books_id            NUMBER,
  object_version_number      NUMBER,
  last_update_date           DATE,
  last_updated_by            NUMBER,
  creation_date              DATE,
  created_by                 NUMBER,
  last_update_login          NUMBER,
  request_id                 NUMBER,
  program_application_id     NUMBER,
  program_update_date        DATE,
  program_id                 NUMBER,
  created_from               VARCHAR2(30),
  post_to_gl                 VARCHAR2(1),
  transfer_to_gl_in          VARCHAR2(1),
  ap_payment_term_id         NUMBER,
  rounding_level_flag        VARCHAR2(1),
  gl_id_rounding             NUMBER,
  gl_id_ded_clearing         NUMBER,
  gl_id_ded_adj              NUMBER,
  gl_id_accr_promo_liab      NUMBER,
  gl_id_ded_adj_clearing     NUMBER,
  gl_rec_ded_account         NUMBER,
  gl_rec_clearing_account    NUMBER,
  gl_cost_adjustment_acct    NUMBER,
  gl_contra_liability_acct   NUMBER ,
  gl_pp_accrual_acct         NUMBER,
  gl_date_type               VARCHAR2(30),
  days_due                   NUMBER,
  claim_type_id              NUMBER,
  reason_code_id             NUMBER,
  autopay_claim_type_id      NUMBER,
  autopay_reason_code_id     NUMBER,
  autopay_flag               VARCHAR2(1),
  autopay_periodicity        NUMBER,
  autopay_periodicity_type   VARCHAR2(30),
  accounting_method_option   VARCHAR2(25),
  billback_trx_type_id       NUMBER,
  cm_trx_type_id             NUMBER,
  attribute_category         VARCHAR2(150),
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
  batch_source_id            NUMBER,
  payables_source            VARCHAR2(30),
  default_owner_id           NUMBER,
  auto_assign_flag           VARCHAR2(1),
  exchange_rate_type         VARCHAR2(30),
  order_type_id              NUMBER,
  --11.5.10 enhancements
  gl_acct_for_offinv_flag VARCHAR2(1),
  --short_payment_reason_code_id NUMBER,
  cb_trx_type_id NUMBER,
  pos_write_off_threshold NUMBER,
  neg_write_off_threshold NUMBER,
  adj_rec_trx_id NUMBER,
  wo_rec_trx_id NUMBER,
  neg_wo_rec_trx_id NUMBER,
  un_earned_pay_allow_to VARCHAR2(30),
  un_earned_pay_thold_type VARCHAR2(30),
  un_earned_pay_threshold NUMBER,
  un_earned_pay_thold_flag  VARCHAR2(1),
  header_tolerance_calc_code VARCHAR2(30),
  header_tolerance_operand NUMBER,
  line_tolerance_calc_code VARCHAR2(30),
  line_tolerance_operand NUMBER,

  ship_debit_accrual_flag                   varchar2(1),
  ship_debit_calc_type                      varchar2(30),
  inventory_tracking_flag                   varchar2(1),
  end_cust_relation_flag                    varchar2(1),
  auto_tp_accrual_flag                      varchar2(1),
  gl_balancing_flex_value                   VARCHAR2(150),
  prorate_earnings_flag                     VARCHAR2(1),
  sales_credit_default_type                 VARCHAR2(30),
  net_amt_for_mass_settle_flag              VARCHAR2(1),

  claim_tax_incl_flag                       VARCHAR2(1),
  --For Rule Based Settlement
  rule_based                                VARCHAR2(1),
  approval_new_credit                       VARCHAR2(1),
  approval_matched_credit                   VARCHAR2(1),
  cust_name_match_type                      VARCHAR2(50),
  credit_matching_thold_type                VARCHAR2(50),
  credit_tolerance_operand                  NUMBER,
  -- For Price Protection Parallel Approval ER
  automate_notification_days                NUMBER,
  -- For SSD Default Adjustment Types
  ssd_inc_adj_type_id			    NUMBER,
  ssd_dec_adj_type_id                       NUMBER
);



---------------------------------------------------------------------
-- PROCEDURE
--    Create_Sys_Parameters
--
-- PURPOSE
--    Create a new record of system parameters.
--
-- PARAMETERS
--    p_sys_parameters_rec: the new record to be inserted
--    x_set_of_books_id: return the set_of_books_id of the new system parameters record.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If set_of_books_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If set_of_books_id is not passed in, get one from org definition.
--    4. If a flag column is passed in, check if it is FND_API.g_true/false.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to FND_API.g_false.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE Create_Sys_Parameters(
   p_api_version          IN  NUMBER
  ,p_init_msg_list        IN  VARCHAR2  := FND_API.g_false
  ,p_commit               IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level     IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status        OUT NOCOPY VARCHAR2
  ,x_msg_count            OUT NOCOPY NUMBER
  ,x_msg_data             OUT NOCOPY VARCHAR2

  ,p_sys_parameters_rec   IN  sys_parameters_rec_type
  ,x_set_of_books_id      OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Sys_Parameters
--
-- PURPOSE
--    Delete a record of system parameters.
--
-- PARAMETERS
--    p_set_of_books_id: the set_of_books_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_Sys_Parameters(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_set_of_books_id   IN  NUMBER
  ,p_object_version    IN  NUMBER
);


-------------------------------------------------------------------
-- PROCEDURE
--    Lock_Sys_Parameters
--
-- PURPOSE
--    Lock a system parameters record.
--
-- PARAMETERS
--    p_set_of_books_id: the set_of_books_id
--    p_object_version : the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_Sys_Parameters(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_set_of_books_id   IN  NUMBER
  ,p_object_version    IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Sys_Parameters
--
-- PURPOSE
--    Update a system parameters record.
--
-- PARAMETERS
--    p_sys_parameters_rec: the record with new items.
--    p_mode    : determines what sort of validation is to be performed during update.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE Update_Sys_Parameters(
   p_api_version           IN  NUMBER
  ,p_init_msg_list         IN  VARCHAR2  := FND_API.g_false
  ,p_commit                IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level      IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2

  ,p_sys_parameters_rec    IN  sys_parameters_rec_type
  ,p_mode                  IN  VARCHAR2 := JTF_PLSQL_API.g_update
  ,x_object_version_number OUT NOCOPY NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Sys_Parameters
--
-- PURPOSE
--    Validate a fund utilization record.
--
-- PARAMETERS
--    p_sys_parameters: the system parameters record to be validated
--
-- NOTES
--    1. p_sys_parameters_rec should be a complete record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE Validate_Sys_Parameters(
   p_api_version          IN  NUMBER
  ,p_init_msg_list        IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level     IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status        OUT NOCOPY VARCHAR2
  ,x_msg_count            OUT NOCOPY NUMBER
  ,x_msg_data             OUT NOCOPY VARCHAR2

  ,p_sys_parameters_rec   IN  sys_parameters_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Sys_Parameters_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_sys_parameters_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_Sys_Parameters_Items(
   p_sys_parameters_rec IN  sys_parameters_rec_type
  ,p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status   OUT NOCOPY VARCHAR2

);


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Sys_Parameters_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_sys_parameters_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_Sys_Parameters_Record(
   p_sys_parameters_rec IN  sys_parameters_rec_type
  ,p_complete_rec       IN  sys_parameters_rec_type := NULL
  ,p_mode               IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status      OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Init_Sys_Parameters_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_Sys_Parameters_Rec(
   x_sys_parameters_rec   OUT NOCOPY  sys_parameters_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Sys_Parameters_Rec
--
-- PURPOSE
--    For update_sys_parameters, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_sys_parameters_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_Sys_Parameters_Rec(
   p_sys_parameters_rec IN  sys_parameters_rec_type
  ,x_complete_rec       OUT NOCOPY sys_parameters_rec_type
);


END OZF_Sys_Parameters_PVT;

/
