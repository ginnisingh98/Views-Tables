--------------------------------------------------------
--  DDL for Package OZF_FUNDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_FUNDS_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvfuns.pls 120.2 2005/08/16 21:37:20 appldev ship $ */

TYPE fund_rec_type IS RECORD
(
 fund_id                   NUMBER
,last_update_date          DATE
,last_updated_by           NUMBER
,last_update_login         NUMBER
,creation_date             DATE
,created_by                NUMBER
,created_from              VARCHAR2(30)
,request_id                NUMBER
,program_application_id    NUMBER
,program_id                NUMBER
,program_update_date       DATE
,fund_number               VARCHAR2(30)
,parent_fund_id            NUMBER
,category_id               NUMBER
,fund_type                 VARCHAR2(30)
,status_code               VARCHAR2(30)
,user_status_id            NUMBER
,status_date               DATE
,accrued_liable_account    NUMBER
,ded_adjustment_account    NUMBER
,start_date_active         DATE
,end_date_active           DATE
,currency_code_tc          VARCHAR2(15)
,owner                     NUMBER
,hierarchy                 VARCHAR2(30)
,hierarchy_level           VARCHAR2(30)
,hierarchy_id              NUMBER
,parent_node_id            NUMBER
,node_id                   NUMBER
,object_version_number     NUMBER
,org_id                    NUMBER
,earned_flag               VARCHAR2(1)
,original_budget           NUMBER
,transfered_in_amt         NUMBER
,transfered_out_amt        NUMBER
,holdback_amt              NUMBER
,planned_amt               NUMBER
,committed_amt             NUMBER
,earned_amt                NUMBER
,paid_amt                  NUMBER
,liable_accnt_segments     VARCHAR2(155)
,adjustment_accnt_segments VARCHAR2(155)
,short_name                VARCHAR2(80)
,description               VARCHAR2(4000)
,language                  VARCHAR2(4)
,source_lang               VARCHAR2(4)
,start_period_name         VARCHAR2(15)
,end_period_name           VARCHAR2(15)
,fund_calendar             VARCHAR2(15)
,accrue_to_level_id        NUMBER
,accrual_quantity          NUMBER
,accrual_phase             VARCHAR2(30)
,accrual_cap               NUMBER
,accrual_uom               VARCHAR2(30)
,accrual_method            VARCHAR2(30)
,accrual_operand           VARCHAR2(30)
,accrual_rate              NUMBER
,accrual_basis             VARCHAR2(30)
,accrual_discount_level    VARCHAR2(30)
,custom_setup_id           NUMBER
-- added 06/21/2001 mpande
,threshold_id              NUMBER
,business_unit_id          NUMBER
,country_id                NUMBER
,task_id                   NUMBER
,recal_committed           NUMBER
,attribute_category        VARCHAR2(30)
,attribute1                VARCHAR2(150)
,attribute2                VARCHAR2(150)
,attribute3                VARCHAR2(150)
,attribute4                VARCHAR2(150)
,attribute5                VARCHAR2(150)
,attribute6                VARCHAR2(150)
,attribute7                VARCHAR2(150)
,attribute8                VARCHAR2(150)
,attribute9                VARCHAR2(150)
,attribute10               VARCHAR2(150)
,attribute11               VARCHAR2(150)
,attribute12               VARCHAR2(150)
,attribute13               VARCHAR2(150)
,attribute14               VARCHAR2(150)
,attribute15               VARCHAR2(150)
-- the follwoign columns are obsolete and not used anymore
,fund_usage                VARCHAR2(30)
,plan_type                 VARCHAR2(30)
,plan_id                   NUMBER
,apply_accrual_on          VARCHAR2(30)
,level_value               VARCHAR2(240)
,budget_flag               VARCHAR2(1)
,liability_flag            VARCHAR2(1)
,set_of_books_id           NUMBER
,start_period_id            NUMBER
,end_period_id              NUMBER
,budget_amount_tc          NUMBER
,budget_amount_fc          NUMBER
,available_amount          NUMBER
,distributed_amount        NUMBER
,currency_code_fc          VARCHAR2(15)
,exchange_rate_type        VARCHAR2(30)
,exchange_rate_date        DATE
,exchange_rate             NUMBER
,department_id             NUMBER
,costcentre_id             NUMBER
-- added by feliu on 02/08/02
,rollup_original_budget    NUMBER
,rollup_transfered_in_amt  NUMBER
,rollup_transfered_out_amt NUMBER
,rollup_holdback_amt       NUMBER
,rollup_planned_amt        NUMBER
,rollup_committed_amt      NUMBER
,rollup_earned_amt         NUMBER
,rollup_paid_amt           NUMBER
,rollup_recal_committed    NUMBER
-- added mpande 10/25/2002 11.5.9
,retroactive_flag          VARCHAR2(1)
,qualifier_id              NUMBER
-- niprakas added
,prev_fund_id              NUMBER
,transfered_flag           VARCHAR2(1)
,utilized_amt              NUMBER
,rollup_utilized_amt       NUMBER
-- kdass added
,product_spread_time_id    NUMBER
-- sangara added 06/25/05
,activation_date           DATE
-- kdass - R12 MOAC changes
,ledger_id                 NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Fund
--
-- PURPOSE
--    Create a new fund.
--
-- PARAMETERS
--    p_fund_rec: the new record to be inserted
--    x_fund_id: return the fund_id of the new fund
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If fund_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If fund_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE Create_Fund(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_fund_rec          IN  fund_rec_type
  ,x_fund_id           OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Fund
--
-- PURPOSE
--    Delete a fund.
--
-- PARAMETERS
--    p_fund_id: the fund_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_Fund(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_fund_id           IN  NUMBER
  ,p_object_version    IN  NUMBER
);


-------------------------------------------------------------------
-- PROCEDURE
--    Lock_Fund
--
-- PURPOSE
--    Lock a fund.
--
-- PARAMETERS
--    p_fund_id: the fund_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_Fund(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_fund_id           IN  NUMBER
  ,p_object_version    IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Fund
--
-- PURPOSE
--    Update a fund.
--
-- PARAMETERS
--    p_fund_rec: the record with new items.
--    p_mode    : determines what sort of validation is to be performed during update.
--              : The mode should always be 'UPDATE' except when updating the earned or committed amount
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE Update_Fund(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_fund_rec          IN  fund_rec_type
  ,p_mode              IN  VARCHAR2 := JTF_PLSQL_API.g_update
);


---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Fund
--
-- PURPOSE
--    Validate a fund record.
--
-- PARAMETERS
--    p_fund_rec: the fund record to be validated
--
-- NOTES
--    1. p_fund_rec should be the complete fund record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE Validate_Fund(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_fund_rec          IN  fund_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Fund_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_fund_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_Fund_Items(
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status   OUT NOCOPY VARCHAR2
  ,p_fund_rec        IN  fund_rec_type
);



---------------------------------------------------------------------
-- PROCEDURE
--    Check_Fund_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_fund_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_Fund_Record(
   p_fund_rec         IN  fund_rec_type
  ,p_complete_rec     IN  fund_rec_type := NULL
  ,p_mode             IN  VARCHAR2 := 'INSERT'
  ,x_return_status    OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Init_Fund_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_Fund_Rec(
   x_fund_rec         OUT NOCOPY  fund_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Fund_Rec
--
-- PURPOSE
--    For update_fund, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_fund_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_Fund_Rec(
   p_fund_rec       IN  fund_rec_type
  ,x_complete_rec   OUT NOCOPY fund_rec_type
);

-- ADDED FOR R2 Requirements to get default GL info--- by mpande //6th JULY-2000
---------------------------------------------------------------------
-- PROCEDURE
--    COMPLETE_DEFAULT_GL_INFO
--
-- PURPOSE : A fund should always have a category . When creating a category the user can
--           give the GL info 1) ACCRUED_LIABILITY_ACCOUNT 2) DED_ADJUSTMENT_ACCOUNT
--          When the user is creating a fund the funds API should pickup
--         the default GL INFO if the user has not passed anything.
--        This API gets the defauls GL INFO.
-- PARAMETERS

---------------------------------------------------------------------
PROCEDURE COMPLETE_DEFAULT_GL_INFO(
   p_category_id                IN  NUMBER,
   p_accrued_liability_account  IN OUT NOCOPY  NUMBER,
   p_ded_adjustment_account     IN OUT NOCOPY  NUMBER,
   x_return_status              OUT NOCOPY  VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    check_fund_inter_entity
--
-- PURPOSE
--    Check the inter-entity level business rules.
--
-- PARAMETERS
--    p_fund_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE check_fund_inter_entity(
   p_fund_rec        IN  fund_rec_type,
   p_complete_rec    IN  fund_rec_type,
   p_validation_mode IN  VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    copy_fund
--
-- PURPOSE
--    copy fund. added by feliu.
--
-- PARAMETERS
--   p_source_object_id: Original object id,
--   p_attributes_table: AMS_CpyUtility_PVT.copy_attributes_table_type,
--   p_copy_columns_table: AMS_CpyUtility_PVT.copy_columns_table_type,
--   x_new_object_id: New object Id.
--   x_custom_setup_id: custom_setup_id.
---------------------------------------------------------------------

PROCEDURE copy_fund (
   p_api_version        IN NUMBER,
   p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_source_object_id   IN NUMBER,
   p_attributes_table   IN AMS_CpyUtility_PVT.copy_attributes_table_type,
   p_copy_columns_table IN AMS_CpyUtility_PVT.copy_columns_table_type,
   x_new_object_id      OUT NOCOPY NUMBER,
   x_custom_setup_id    OUT NOCOPY NUMBER
);



---------------------------------------------------------------------
-- PROCEDURE
---   update_rollup_amount
--
-- PURPOSE
--    Update rollup columns. added by feliu
--
-- PARAMETERS
-- p_fund_rec: the fund record.
---------------------------------------------------------------------

PROCEDURE  update_rollup_amount(
   p_api_version        IN       NUMBER
  ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
  ,p_commit             IN       VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2
  ,p_fund_rec           IN       fund_rec_type
);

---------------------------------------------------------------------
-- PROCEDURE
---   update_funds_access
--
-- PURPOSE
--    Update parent funds access. added by feliu
--
-- PARAMETERS
-- p_fund_rec: the fund record.
-- p_mod: the mode for update access.
---------------------------------------------------------------------

PROCEDURE  update_funds_access(
   p_api_version        IN       NUMBER
  ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
  ,p_commit             IN       VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2
  ,p_fund_rec           IN       fund_rec_type
  ,p_mode               IN       VARCHAR2 := JTF_PLSQL_API.G_CREATE
);

END OZF_Funds_PVT;


 

/
