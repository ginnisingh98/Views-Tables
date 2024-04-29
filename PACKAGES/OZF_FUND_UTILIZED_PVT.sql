--------------------------------------------------------
--  DDL for Package OZF_FUND_UTILIZED_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_FUND_UTILIZED_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvfuts.pls 120.4.12010000.6 2010/02/17 08:45:39 nepanda ship $ */

TYPE utilization_rec_type IS RECORD
(
 utilization_id            NUMBER
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
,utilization_type          VARCHAR2(30)
,fund_id                   NUMBER
,plan_type                 VARCHAR2(30)
,plan_id                   NUMBER
,component_type            VARCHAR2(30)
,component_id              NUMBER
,object_type               VARCHAR2(30)
,object_id                 NUMBER
,order_id                  NUMBER
,invoice_id                NUMBER
,amount                    NUMBER
,acctd_amount              NUMBER
,currency_code             VARCHAR2(3)
,exchange_rate_type        VARCHAR2(30)
,exchange_rate_date        DATE
,exchange_rate             NUMBER
,adjustment_type           VARCHAR2(30)
,adjustment_date           DATE
,object_version_number     NUMBER
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
,org_id                    NUMBER
,adjustment_desc           VARCHAR2(2000)
,language                  VARCHAR2(4)
,source_lang               VARCHAR2(4)
,camp_schedule_id                NUMBER
,adjustment_type_id        NUMBER
,gl_date                               DATE
,product_level_type          VARCHAR2(30)
,product_id                NUMBER
,ams_activity_budget_id    NUMBER
,amount_remaining          NUMBER
,acctd_amount_remaining    NUMBER
,cust_account_id           NUMBER
,price_adjustment_id       NUMBER
,plan_curr_amount          NUMBER
,plan_curr_amount_remaining NUMBER
,scan_unit                 NUMBER
,scan_unit_remaining       NUMBER
,activity_product_id       NUMBER
,scan_data_id              NUMBER -- this colums is not in the table but required for scan data offers adj
,volume_offer_tiers_id     NUMBER
,gl_posted_flag            VARCHAR2(1)  -- yzhao: 03/20/2003 added
--  11/04/2003   yzhao     11.5.10: added
,billto_cust_account_id    NUMBER
,reference_type            VARCHAR2(30)
,reference_id              NUMBER
/*fix for bug 4778995
,month_id                  NUMBER
,quarter_id                NUMBER
,year_id                   NUMBER
*/
-- 01/02/2004 kdass added for 11.5.10
,order_line_id             NUMBER
-- 03/01/2003  feliu added for 11.5.10
,orig_utilization_id       NUMBER
-- rimehrot added for R12
,bill_to_site_use_id       NUMBER
,ship_to_site_use_id       NUMBER
-- yzhao R12
,univ_curr_amount          NUMBER
,univ_curr_amount_remaining NUMBER
-- kdass R12
,gl_account_credit         NUMBER
,gl_account_debit          NUMBER
,site_use_id               NUMBER -- fix for bug 7512202
--nirprasa ER 8399134
,fund_request_currency_code VARCHAR2(15)
,fund_request_amount        NUMBER
,fund_request_amount_remaining NUMBER
,plan_currency_code         VARCHAR2(15)
);

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Utilization
--
-- PURPOSE
--    Create a new fund utilization.
--
-- PARAMETERS
--    p_utilization_rec: the new record to be inserted
--    x_utilization_id: return the utilization_id of the new utilization record.
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If utilization_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If utilization_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE Create_Utilization(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_create_gl_entry   IN VARCHAR2 := FND_API.g_false
  ,p_utilization_rec   IN  utilization_rec_type
  ,x_utilization_id    OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Utilization
--
-- PURPOSE
--    Delete a fund utilization.
--
-- PARAMETERS
--    p_utilization_id: the utilization_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_Utilization(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_utilization_id    IN  NUMBER
  ,p_object_version    IN  NUMBER
);


-------------------------------------------------------------------
-- PROCEDURE
--    Lock_Utilization
--
-- PURPOSE
--    Lock a fund uilization.
--
-- PARAMETERS
--    p_utilization_id: the utilization_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_Utilization(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_utilization_id    IN  NUMBER
  ,p_object_version    IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Utilization
--
-- PURPOSE
--    Update a fund utilization.
--
-- PARAMETERS
--    p_utilization_rec: the record with new items.
--    p_mode    : determines what sort of validation is to be performed during update.
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE Update_Utilization(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_utilization_rec   IN  utilization_rec_type
  ,p_mode              IN  VARCHAR2 := 'UPDATE'
);


---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Utilization
--
-- PURPOSE
--    Validate a fund utilization record.
--
-- PARAMETERS
--    p_utilization_rec: the fund utilization record to be validated
--
-- NOTES
--    1. p_utilization_rec should be the complete fund record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE Validate_Utilization(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_utilization_rec   IN  utilization_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Utilization_Items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_utilization_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE Check_Utilization_Items(
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status   OUT NOCOPY VARCHAR2
  ,p_utilization_rec IN  utilization_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Utilization_Record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_utilization_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Check_Utilization_Record(
   p_utilization_rec  IN  utilization_rec_type
  ,p_complete_rec     IN  utilization_rec_type := NULL
  ,p_mode             IN  VARCHAR2 := 'INSERT'
  ,x_return_status    OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Init_Utilization_Rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE Init_Utilization_Rec(
   x_utilization_rec   OUT NOCOPY  utilization_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Utilization_Rec
--
-- PURPOSE
--    For update_fund, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_utilization_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_Utilization_Rec(
   p_utilization_rec IN  utilization_rec_type
  ,x_complete_rec    OUT NOCOPY utilization_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    create_act_utilization
--
-- PURPOSE
--    For create act budgets and utilization record.
--    Called by manual fund adjustment.
--
-- PARAMETERS
--    p_act_util_rec: the act budget record which contain information
---                   create act bugets record.
--    p_act_util_rec: the act utilization record which contain information
--                    for utilization.
-- NOTES
--    1. created by feliu on 02/25/2002.
---------------------------------------------------------------------

PROCEDURE create_act_utilization(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec    IN       ozf_actbudgets_pvt.act_budgets_rec_type
     ,p_act_util_rec       IN       ozf_actbudgets_pvt.act_util_rec_type
     ,x_act_budget_id      OUT NOCOPY      NUMBER
);

--kdass - added for Bug 8726683
PROCEDURE create_act_utilization(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec    IN       ozf_actbudgets_pvt.act_budgets_rec_type
     ,p_act_util_rec       IN       ozf_actbudgets_pvt.act_util_rec_type
     ,x_act_budget_id      OUT NOCOPY      NUMBER
     ,x_utilization_id     OUT NOCOPY      NUMBER
);

END OZF_Fund_Utilized_PVT;

/
