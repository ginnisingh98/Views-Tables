--------------------------------------------------------
--  DDL for Package OZF_FUND_RECONCILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_FUND_RECONCILE_PVT" AUTHID CURRENT_USER AS
/*$Header: ozfvrecs.pls 120.0 2005/06/01 01:06:54 appldev noship $*/
   ---------------------------------------------------------------------
   -- PROCEDURE
   --    Release fund concurrent program
   --
   -- PURPOSE
   --
   -- PARAMETERS
   --     p_object_type   IN       VARCHAR2
   --     p_object_status IN       VARCHAR2 :=FND_API.G_MISS_CHAR
   --     p_object_code   IN       VARCHAR2 :=fnd_api.G_MISS_CHAR
   --     p_object_end_date   IN      DATE := FND_API.G_MISS_DATE
   --     x_errbuf  OUT VARCHAR2 STANDARD OUT PARAMETER
   --     x_retcode OUT NUMBER STANDARD OUT PARAMETER
   -- NOTES
   --           This API will release the un-paid and committed amounts.

   -- HISTORY
   --    10/16/2002  feliu  Create.

   ----------------------------------------------------------------------
   PROCEDURE release_fund_conc(
       x_errbuf        OUT NOCOPY      VARCHAR2
      ,x_retcode       OUT NOCOPY      NUMBER
      ,p_object_type   IN       VARCHAR2
      ,p_object_status IN       VARCHAR2 :=null
      ,p_object_code   IN       VARCHAR2 :=null
      ,p_object_end_date   IN      VARCHAR2 := null
      ,p_util_paid      IN      VARCHAR2 := null
    /* ,p_api_version           IN       NUMBER
     ,p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_msg_count             OUT NOCOPY      NUMBER
     ,x_msg_data              OUT NOCOPY      VARCHAR2 */
);


/*****************************************************************************************/
-- Start of Comments
-- NAME
--    Reconcile_line
-- PURPOSE
-- This API is called from the java layer from the reconcile button on budget_sourcing screen or from
-- release_fund_concurrent program.
-- It releases all th budget that was requested from a fund to the respective fund by creating transfer records
-- and negative committment.
-- HISTORY
-- 10/08/2002  feliu  CREATED
---------------------------------------------------------------------

   PROCEDURE reconcile_line (
      p_budget_used_by_id     IN       NUMBER
     ,p_budget_used_by_type   IN       VARCHAR2
     ,p_object_currency       IN       VARCHAR2
     ,p_from_paid             IN       VARCHAR2
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
   --    Reconcile_budget_line
   -- PURPOSE
   -- This API is called from the java layer from the reconcile button on budget_sourcing screen
   -- It releases all th ebudget that was requested from a fund to the respective fund by creating transfer records
   -- and negative committment.
   -- HISTORY
   -- 04/30/2001  mpande  CREATED

   PROCEDURE reconcile_budget_line(
      p_budget_used_by_id     IN       NUMBER
     ,p_budget_used_by_type   IN       VARCHAR2
     ,p_object_currency       IN       VARCHAR2
     ,p_api_version           IN       NUMBER
     ,p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_msg_count             OUT NOCOPY      NUMBER
     ,x_msg_data              OUT NOCOPY      VARCHAR2);

---------------------------------------------------------------------
-- PROCEDURE
--    reconcile_budget_utilized
--
-- PURPOSE
--This API will be reconcile un_paid amount. it is called by concurrent program.

-- PARAMETERS
    --  p_budget_used_by_id     IN       object id,
    --  p_budget_used_by_type   IN       object type,
    --  p_object_currency       IN       object currency,

-- NOTES
-- HISTORY
--    09/24/2002  feliu  Create.
----------------------------------------------------------------------

 PROCEDURE reconcile_budget_utilized (
      p_budget_used_by_id     IN       NUMBER
     ,p_budget_used_by_type   IN       VARCHAR2
     ,p_object_currency       IN       VARCHAR2
     ,p_api_version           IN       NUMBER
     ,p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_msg_count             OUT NOCOPY      NUMBER
     ,x_msg_data              OUT NOCOPY      VARCHAR2
 );


---------------------------------------------------------------------
-- PROCEDURE
--    post_utilized_budget_conc
--
-- PURPOSE
--This API will be called by claim to automatic increase committed and utilized budget
--when automatic adjustment is allowed for scan data offer.
--It will increase both committed and utilized amount.

-- PARAMETERS
--      x_errbuf        OUT      VARCHAR2
--     ,x_retcode       OUT      NUMBER

-- NOTES
-- HISTORY
--    09/24/2002  feliu  Create.
----------------------------------------------------------------------

PROCEDURE Post_utilized_budget_conc
 (
       x_errbuf        OUT NOCOPY      VARCHAR2
     ,x_retcode       OUT NOCOPY      NUMBER
/*
 p_api_version           IN       NUMBER
     ,p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_msg_count             OUT NOCOPY      NUMBER
     ,x_msg_data              OUT NOCOPY      VARCHAR2 */
);

/* ---------------------------------------------------------------------
   -- PROCEDURE
   --    Recalculating-recalculate_committed_fund_conc
   -- PURPOSE
   -- This API is called from the concurrent program manager.
   -- It recalculats committed amount base on fund utilization
   ---during certain period
   -- and creating request or transfer records.
   -- PARAMETERS
      p_api_version           IN       NUMBER
     ,p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_msg_count             OUT NOCOPY      NUMBER
     ,x_msg_data              OUT NOCOPY      VARCHAR2

   -- HISTORY
   -- 10/05/2001  feliu  CREATED
*/----------------------------------------------------------------------------
   PROCEDURE recal_comm_fund_conc
   (
      x_errbuf        OUT NOCOPY      VARCHAR2
     ,x_retcode       OUT NOCOPY      NUMBER
   );

      ---------------------------------------------------------------------
   -- PROCEDURE
   --    open_next_years_budget
   --
   -- PURPOSE
   -- This API creates new budgets corresponding to old budgets. The unutilized committed
   -- amount is transferred to new Budgets

  -- PARAMETERS
  --      p_query_id         IN  NUMBER
  --      p_fund_id          IN  NUMBER
  --      p_hierarchy_flag   IN  VARCHAR2
  --      p_amount_flag      IN  VARCHAR2

  -- NOTES
  -- HISTORY
  --  09/10/2003 niprakas  Create.
----------------------------------------------------------------------




   procedure open_next_years_budget (
    x_errbuf OUT NOCOPY     VARCHAR2,
    x_retcode OUT NOCOPY    NUMBER,
    p_query_id   IN     NUMBER,
    p_fund_id      IN   NUMBER,
    p_hierarchy_flag  IN VARCHAR2,
    p_amount_flag    IN  VARCHAR2
   );

END ozf_fund_reconcile_pvt;


 

/
