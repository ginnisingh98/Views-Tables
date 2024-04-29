--------------------------------------------------------
--  DDL for Package OZF_ACTBUDGETRULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_ACTBUDGETRULES_PVT" AUTHID CURRENT_USER AS
   /*$Header: ozfvarus.pls 120.1 2005/08/05 14:21:31 appldev ship $*/

   -- Start of Comments
   --
   -- NAME
   --   OZF_ACTBUDGETRULES_PVT
   --
   -- PURPOSE
   --   This package is a Private API for managing Activity Budget information for OZF_ACTBUDGETS_PVT.
   --
   --   Procedures:
   --     check_cat_activity_match
   --     check_transfer_amount_exists
   --     check_market_elig_match
   --     check_prod_elig_match
   --     source_has_enough_money
   --     budget_has_enough_money
   --     check_approval_required
   --     check_approval_required
   --     can_plan_more_budget
   --     create_note

   -- NOTES
   -- Created by feliu  04/16/2002
   --         separated from ozf_actbudgets_pvt.

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   check_cat_activity_match
--
-- PURPOSE
--   This procedure is to validate budget record
--
-- NOTES
-- HISTORY
-- 04/10/2001 mpande   CAtegory and activity  should match for the budget and the campaign or schedule
/*****************************************************************************************/
   PROCEDURE check_cat_activity_match (
      p_used_by_id         IN		NUMBER
     ,p_used_by_type       IN		VARCHAR2
     ,p_budget_source_id   IN		NUMBER
     ,x_return_status      OUT NOCOPY	VARCHAR2
   );


/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   check_transfer_amount_exists
-- PARAMETERS
--   p_object_id           IN       NUMBER -- in case of transfer it is the budget_source_id
--  ,p_object_type         IN       VARCHAR2
--  ,p_budget_source_id     IN       NUMBER
--  ,p_budget_source_type   IN       VARCHAR2

   -- PURPOSE
   --   This procedure is to validate budget record
   --
   -- NOTES
   -- HISTORY
   -- 04/10/2001 mpande   Cannot tranfer to a budget if he does not have it from that particular budget
   -- 08/05/2005 feliu    modified for R12.
/*****************************************************************************************/
   PROCEDURE check_transfer_amount_exists (
      p_object_id            IN		NUMBER
     ,p_object_type          IN		VARCHAR2
     ,p_budget_source_id     IN		NUMBER
     ,p_budget_source_type   IN		VARCHAR2
     ,p_transfer_amt         IN		NUMBER
     ,p_transfer_type        IN		VARCHAR2
     ,x_return_status        OUT NOCOPY VARCHAR2
   ) ;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   check_market_elig_match
--
-- PURPOSE
--   This procedure is to validate budget record
--
-- NOTES
-- HISTORY
-- 04/10/2001 mpande   MArket Eligibility  should match for the budget and the campaign or schedule or offer
-- 8/7/2002 mpande commeted
/*****************************************************************************************
   PROCEDURE check_market_elig_match (
      p_used_by_id         IN       NUMBER
     ,p_used_by_type       IN       VARCHAR2
     ,p_budget_source_id   IN       NUMBER
     ,x_return_status      OUT      VARCHAR2
   ) ;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   check_product_elig_match
--
-- PURPOSE
--   This procedure is to validate budget record
--
-- NOTES
-- HISTORY
-- 04/10/2001 mpande   Product Eiligibility should match for the budget and the campaign or schedule
-- 8/7/2002 mpande commeted
/*****************************************************************************************
   PROCEDURE check_prod_elig_match (
      p_used_by_id         IN       NUMBER
     ,p_used_by_type       IN       VARCHAR2
     ,p_budget_source_id   IN       NUMBER
     ,x_return_status      OUT      VARCHAR2
   ) ;
/*****************************************************************************************/
-- Start of Comments
--
   -- NAME
   --    source_has_enough_money
   -- PURPOSE
   --    Return Y if the budget source has enough
   --    money to fund the approved amount for a
   --    budget request; return N, otherwise.
/*****************************************************************************************/
   FUNCTION source_has_enough_money (
      p_source_type       IN   VARCHAR2
     ,p_source_id         IN   NUMBER
     ,p_approved_amount   IN   NUMBER
   )
      RETURN VARCHAR2;
/*****************************************************************************************/
-- Start of Comments
--
   --
   -- NAME
   --    budget_has_enough_money
   -- PURPOSE
   --    Return Y if the budget source has enough
   --    money to fund the approved amount for a
   --    budget request; return N, otherwise.
   -- HISTORY
   -- 20-Feb-2001 mpande   Created.
/*****************************************************************************************/
   FUNCTION budget_has_enough_money (
      p_source_id IN NUMBER
      , p_approved_amount IN NUMBER
    )
      RETURN VARCHAR2;
/*****************************************************************************************/
-- Start of Comments
--
   --
   -- NAME
   --    check_approval_required
   -- PURPOSE
   -- API to check budget approval requre or not
   -- HISTORY
   -- 04/27/2001 mpande   Created.
/*****************************************************************************************/
   FUNCTION check_approval_required (
      p_object          IN   VARCHAR2
     ,p_object_id       IN   NUMBER
     ,p_source_type     IN   VARCHAR2
     ,p_source_id       IN   NUMBER
     ,p_transfer_type   IN   VARCHAR2
   )
      RETURN VARCHAR2;
/*****************************************************************************************/
-- Start of Comments
--
   --
   -- NAME
   --    can_plan_more_budget
   -- PURPOSE
   --    Return T if the object(CAMP, EVEH) planned amount is greater or less than the total request amount
   -- HISTORY
   -- 05/01/2001 mpande   Created.
/*****************************************************************************************/
   FUNCTION can_plan_more_budget (
      p_object_type      IN   VARCHAR2
     ,p_object_id        IN   NUMBER
     ,p_request_amount   IN   NUMBER
     ,p_act_budget_id    IN   NUMBER
   )
      RETURN VARCHAR2;

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--    Create Note
-- PURPOSE
--  Create Note fro justification and comments
-- HISTORY
-- 02/23/2001  mpande  CREATED
/*****************************************************************************************/

   PROCEDURE create_note (
      p_activity_type   IN		VARCHAR2
     ,p_activity_id     IN		NUMBER
     ,p_note            IN		VARCHAR2
     ,p_note_type       IN		VARCHAR2
     ,p_user            IN		NUMBER
     ,x_msg_count       OUT NOCOPY	NUMBER
     ,x_msg_data        OUT NOCOPY	VARCHAR2
     ,x_return_status   OUT NOCOPY	VARCHAR2
   );


END OZF_ACTBUDGETRULES_PVT;

 

/
