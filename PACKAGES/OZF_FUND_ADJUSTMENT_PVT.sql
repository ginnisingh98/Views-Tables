--------------------------------------------------------
--  DDL for Package OZF_FUND_ADJUSTMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_FUND_ADJUSTMENT_PVT" AUTHID CURRENT_USER AS
/*$Header: ozfvadjs.pls 120.2.12010000.3 2009/07/27 11:52:23 kdass ship $*/

   /*****************************************************************************************/
   -- Start of Comments
   -- NAME
   --    Create Fund Utilization
   -- PURPOSE
   --  Create utilizations for the utlized amount of that  activity
   -- called only from ozf_Act_budgets API for utlized amount creation
   -- HISTORY
   -- 02/23/2001  mpande  CREATED

   PROCEDURE create_fund_utilization(
      p_act_budget_rec   IN       ozf_actbudgets_pvt.act_budgets_rec_type
     ,x_return_status    OUT NOCOPY      VARCHAR2
     ,x_msg_count        OUT NOCOPY      NUMBER
     ,x_msg_data         OUT NOCOPY      VARCHAR2
     ,p_act_util_rec     IN       ozf_actbudgets_pvt.act_util_rec_type := ozf_actbudgets_pvt.G_MISS_ACT_UTIL_REC
     );

   /*****************************************************************************************/
   -- NAME
   --    Create Fund Utilization
   -- PURPOSE
   --  Create utilizations for the utlized amount of that  activity
   --  called only from ozf_Act_budgets API for utlized amount creation
   -- HISTORY
   -- 02/23/2001  mpande  CREATED
   -- 06/21/2004  yzhao   UPDATED added x_utilized_amount to return actual utilized amount

   PROCEDURE create_fund_utilization(
      p_act_budget_rec   IN       ozf_actbudgets_pvt.act_budgets_rec_type
     ,x_return_status    OUT NOCOPY      VARCHAR2
     ,x_msg_count        OUT NOCOPY      NUMBER
     ,x_msg_data         OUT NOCOPY      VARCHAR2
     ,p_act_util_rec     IN       ozf_actbudgets_pvt.act_util_rec_type := ozf_actbudgets_pvt.G_MISS_ACT_UTIL_REC
     ,x_utilized_amount  OUT NOCOPY      NUMBER
     );

   --kdass - added for Bug 8726683
   PROCEDURE create_fund_utilization (
      p_act_budget_rec   IN       ozf_actbudgets_pvt.act_budgets_rec_type
     ,x_return_status    OUT NOCOPY      VARCHAR2
     ,x_msg_count        OUT NOCOPY      NUMBER
     ,x_msg_data         OUT NOCOPY      VARCHAR2
     ,p_act_util_rec     IN       ozf_actbudgets_pvt.act_util_rec_type := ozf_actbudgets_pvt.g_miss_act_util_rec
     ,x_utilized_amount  OUT NOCOPY      NUMBER
     ,x_utilization_id   OUT NOCOPY      NUMBER
   );


   /* =========================================================
   --rec_type to hold the amount
   --This is a private rec type to be used by this API only
   ============================================================*/
   TYPE cost_rec_type IS RECORD(
      cost_id                       NUMBER,
      cost_amount                   NUMBER,   -- amount in object currency
      cost_desc                     VARCHAR2(2000),
      cost_curr                     VARCHAR2(30)   -- now only supports the object_currency
                                                );

   /* =========================================================
   --tbl_type to hold the amount
   --This is a private rec type to be used by this API only
   ============================================================*/

   TYPE cost_tbl_type IS TABLE OF cost_rec_type
      INDEX BY BINARY_INTEGER;

   /*****************************************************************************************/
   -- Start of Comments
   -- NAME
   --    Reconcile_budget_line
   -- PURPOSE
   -- This API is called from the java layer from the reconcile button on budget_sourcing screen
   -- It releases all th ebudget that was requested from a fund to the respective fund by creating transfer records
   -- and negative committment.
   -- HISTORY
   -- 04/30/2001  mpande  CREATED

   PROCEDURE create_budget_amt_utilized(
      p_budget_used_by_id     IN       NUMBER
     ,p_budget_used_by_type   IN       VARCHAR2
     ,p_currency              IN       VARCHAR2
     ,p_cost_tbl              IN       cost_tbl_type
     ,p_api_version           IN       NUMBER
     ,p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_msg_count             OUT NOCOPY      NUMBER
     ,x_msg_data              OUT NOCOPY      VARCHAR2);

   ---------------------------------------------------------------------
   -- PROCEDURE
   --    Convert_Currency
   --
   -- PURPOSE
   --           This API will be used to convert currency for checkbook.
   -- PARAMETERS
   --                  p_from_currency  IN VARCHAR2 From currency
   --                  p_to_currency IN VARCHAR@  To currency
   --                  p_from_amount IN NUMBER    From amount
   -- NOTES

   -- HISTORY
   --    06/08/2001  feliu  Create.
   ----------------------------------------------------------------------
  FUNCTION Convert_Currency (
     p_from_currency      IN  VARCHAR2,
     p_to_currency        IN  VARCHAR2,
     p_from_amount        IN  NUMBER,
     p_conv_type          IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR --Added for bug 7030415
   )RETURN NUMBER;

---------------------------------------------------------------------
   -- PROCEDURE
   --    get_exchange_rate
   -- PURPOSE
   -- Get currency exchange rate. called by BudgetOverVO.java.
   -- PARAMETERS
   --         p_from_currency   IN VARCHAR2,
   --           p_to_currency   IN VARCHAR2,
   --           p_conversion_date IN DATE ,
   --           p_conversion_type IN VARCHAR2,
   --           p_max_roll_days  IN NUMBER,
   --           x_denominator   OUT NUMBER,
   --       x_numerator OUT NUMBER,
   --           x_rate    OUT NUMBER,
   --           x_return_status   OUT  VARCHAR2

   -- HISTORY
   -- 02/05/2002 feliu  CREATED
   ----------------------------------------------------------------------

PROCEDURE get_exchange_rate (
                p_from_currency IN VARCHAR2,
                p_to_currency   IN VARCHAR2,
                p_conversion_date IN DATE ,
                p_conversion_type IN VARCHAR2,
                p_max_roll_days  IN NUMBER,
                x_denominator   OUT NOCOPY NUMBER,
                x_numerator     OUT NOCOPY NUMBER,
                x_rate    OUT NOCOPY NUMBER,
                x_return_status   OUT NOCOPY  VARCHAR2);

      ---------------------------------------------------------------------
   -- PROCEDURE
   --    process_act_budgets
   --
   -- PURPOSE
   --
   -- PARAMETERS
   --         p_api_version
   --         ,x_return_status
--            ,x_msg_count
--            ,x_msg_data
  --          ,p_act_budgets_rec
    --        ,x_act_budget_id
   -- NOTES
   -- HISTORY
   --    4/18/2002  Mumu Pande  Create.
   ----------------------------------------------------------------------
   PROCEDURE process_act_budgets (
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      p_act_budgets_rec   IN       ozf_actbudgets_pvt.act_budgets_rec_type,
      p_act_util_rec     IN       ozf_actbudgets_pvt.act_util_rec_type,
      x_act_budget_id     OUT NOCOPY      NUMBER
   );


   ---------------------------------------------------------------------
   -- PROCEDURE
   --    process_act_budgets
   --
   -- PURPOSE
   --
   -- PARAMETERS
   --         p_api_version
   --         ,x_return_status
   --            ,x_msg_count
   --            ,x_msg_data
   --          ,p_act_budgets_rec
    --        ,x_act_budget_id
    --        x_utilized_amount : actual utilized amount when success
   -- NOTES
   -- HISTORY
   --    6/21/2004  Ying Zhao  Create.
   ----------------------------------------------------------------------
   PROCEDURE process_act_budgets (
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      p_act_budgets_rec   IN       ozf_actbudgets_pvt.act_budgets_rec_type,
      p_act_util_rec     IN       ozf_actbudgets_pvt.act_util_rec_type,
      x_act_budget_id     OUT NOCOPY      NUMBER,
      x_utilized_amount   OUT NOCOPY      NUMBER
   );

   --kdass - added for Bug 8726683
   PROCEDURE process_act_budgets (
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      p_act_budgets_rec   IN  ozf_actbudgets_pvt.act_budgets_rec_type,
      p_act_util_rec      IN  ozf_actbudgets_pvt.act_util_rec_type,
      x_act_budget_id     OUT NOCOPY      NUMBER,
      x_utilized_amount   OUT NOCOPY      NUMBER,
      x_utilization_id    OUT NOCOPY      NUMBER
   );


---------------------------------------------------------------------
-- PROCEDURE
--    post_utilized_budget
--
-- PURPOSE
-- This procedure is called by updating offer API when changing offer status to "ACTIVE'
-- and by post_utilized_budget concurrent program for scan data offer and lump sum offer.
-- It is used to create utilized records when offer start date reaches.

-- PARAMETERS
--       p_offer_id
--       p_offer_type
--      ,p_api_version     IN       NUMBER
--      ,p_init_msg_list   IN       VARCHAR2 := fnd_api.g_false
--      ,p_commit          IN       VARCHAR2 := fnd_api.g_false
--      ,x_msg_count       OUT      NUMBER
--      ,x_msg_data        OUT      VARCHAR2
--      ,x_return_status   OUT      VARCHAR2)

-- NOTES
-- HISTORY
--    09/24/2002  feliu  Create.
----------------------------------------------------------------------
 PROCEDURE post_utilized_budget (
      p_offer_id        IN       NUMBER
     ,p_offer_type      IN       VARCHAR2
     ,p_api_version     IN       NUMBER
     ,p_init_msg_list   IN       VARCHAR2 := fnd_api.g_false
     ,p_commit          IN       VARCHAR2 := fnd_api.g_false
     ,p_check_date      IN       VARCHAR2 := fnd_api.g_true -- do date validation
     ,x_msg_count       OUT NOCOPY      NUMBER
     ,x_msg_data        OUT NOCOPY      VARCHAR2
     ,x_return_status   OUT NOCOPY      VARCHAR2
   );

---------------------------------------------------------------------
-- PROCEDURE
--    adjust_utilized_budget
--
-- PURPOSE
--This API will be called by claim to automatic increase committed and utilized budget
--when automatic adjustment is allowed for scan data offer.
--It will increase both committed and utilized amount.

-- PARAMETERS
--       p_claim_id     IN NUMBER
--       p_offer_id
--       p_product_activity_id
--       p_amount
--      ,p_cust_acct_id         IN         NUMBER
--      ,p_bill_to_cust_acct_id IN         NUMBER
--      ,p_bill_to_site_use_id  IN         NUMBER
--      ,p_ship_to_site_use_id  IN         NUMBER
--      ,p_api_version     IN       NUMBER
--      ,p_init_msg_list   IN       VARCHAR2 := fnd_api.g_false
--      ,p_commit          IN       VARCHAR2 := fnd_api.g_false
--      ,x_msg_count       OUT      NUMBER
--      ,x_msg_data        OUT      VARCHAR2
--      ,x_return_status   OUT      VARCHAR2)

-- NOTES
-- HISTORY
--    09/24/2002  feliu  Create.
--    03/29/2005  kdass  bug 5117557 - added params p_cust_acct_id, p_bill_to_cust_acct_id,
--                       p_bill_to_site_use_id, p_ship_to_site_use_id
----------------------------------------------------------------------
   PROCEDURE  adjust_utilized_budget (
      p_claim_id             IN         NUMBER
     ,p_offer_id             IN         NUMBER
     ,p_product_activity_id  IN         NUMBER
     ,p_amount               IN         NUMBER
     ,p_cust_acct_id         IN         NUMBER
     ,p_bill_to_cust_acct_id IN         NUMBER
     ,p_bill_to_site_use_id  IN         NUMBER
     ,p_ship_to_site_use_id  IN         NUMBER
     ,p_api_version          IN         NUMBER
     ,p_init_msg_list        IN         VARCHAR2 := fnd_api.g_false
     ,p_commit               IN         VARCHAR2 := fnd_api.g_false
     ,x_msg_count            OUT NOCOPY NUMBER
     ,x_msg_data             OUT NOCOPY VARCHAR2
     ,x_return_status        OUT NOCOPY VARCHAR2
   );

/*****************************************************************************************/
-- Start of Comments
-- NAME
--    update_budget_source
-- PURPOSE
-- This API is called from the java layer from the update button on budget_sourcing screen
-- It update source_from_parent column for ams_campaign_schedules_b and AMS_EVENT_OFFERS_ALL_B.
-- HISTORY
-- 12/08/2002  feliu  CREATED
---------------------------------------------------------------------

 PROCEDURE update_budget_source(
      p_object_version_number IN       NUMBER
     ,p_budget_used_by_id     IN       NUMBER
     ,p_budget_used_by_type   IN       VARCHAR2
     ,p_from_parent           IN       VARCHAR2
     ,p_api_version           IN       NUMBER
     ,p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_msg_count             OUT NOCOPY      NUMBER
     ,x_msg_data              OUT NOCOPY      VARCHAR2
   );


 /*****************************************************************************************/
-- Start of Comments
-- NAME
--    post_sf_lumpsum_amount
-- PURPOSE
-- This API is called from soft fund request to create expense based utilization.
-- HISTORY
-- 10/22/2003  feliu  CREATED
---------------------------------------------------------------------
   PROCEDURE post_sf_lumpsum_amount (
      p_offer_id        IN       NUMBER
     ,p_api_version     IN       NUMBER
     ,p_init_msg_list   IN       VARCHAR2 := fnd_api.g_false
     ,p_commit          IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN       NUMBER := fnd_api.g_valid_level_full
     ,x_msg_count       OUT NOCOPY      NUMBER
     ,x_msg_data        OUT NOCOPY      VARCHAR2
     ,x_return_status   OUT NOCOPY      VARCHAR2
   );

/*****************************************************************************************/
--rec_type to hold the fund src curr
--This is a private rec type to be used by this API only
---------------------------------------------------------------------
   TYPE parent_src_rec_type IS RECORD (
      fund_id                       NUMBER
     ,fund_curr                     VARCHAR2 (30)
     ,fund_amount                   NUMBER
     ,plan_amount               NUMBER
     );

/*****************************************************************************************/
--tbl_type to hold the amount
--This is a private rec type to be used by this API only
---------------------------------------------------------------------

   TYPE parent_src_tbl_type IS TABLE OF parent_src_rec_type
      INDEX BY BINARY_INTEGER;

/*****************************************************************************************/
   --
   -- NAME
   --    get_parent_Src
   -- PURPOSE
   -- API to automaticaly populate the parent_source_id ( fund_id), parent_curr, parent_amt
   -- for transfers and requests
   -- HISTORY
   -- 04/27/2001 mpande   Created.
---------------------------------------------------------------------
   PROCEDURE get_parent_src (
      p_budget_source_type   IN       VARCHAR2
     ,p_budget_source_id     IN       NUMBER
     ,p_amount               IN       NUMBER
     ,p_req_curr             IN       VARCHAR2
     ,p_mode                 IN       VARCHAR2 := jtf_plsql_api.g_create
     ,p_old_amount           IN       NUMBER := 0
     ,p_exchange_rate_type   IN       VARCHAR2 DEFAULT NULL -- Added for bug 7030415
     ,x_return_status        OUT NOCOPY      VARCHAR2
     ,x_parent_src_tbl       OUT NOCOPY      parent_src_tbl_type
   );

---------------------------------------------------------------------

END ozf_fund_adjustment_pvt;

/
